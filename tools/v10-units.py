#!/usr/bin/env python3
"""
/usr/lib/Units and /usr/lib/Monetary.Units for V10's units(7), made from the
one units table any V10 tape carries.

    tools/v10-units.py            # regenerate both, and prove them
    tools/v10-units.py --check    # fail if either has drifted or does not prove

WHY THIS EXISTS.  V10's units is the yacc rewrite (cmd/units/units.y) and it
reads /usr/lib/Units, then /usr/lib/Monetary.Units (units.y:484).  No tape
carries either file, so the program the build installs answered every run with

    /usr/lib/Units: No such file or directory

and exited.  The only table on the tapes is cmd/units/old/usr.lib.units, which
the program beside it read: old/units.c, 4BSD's (`@(#)units.c 4.1 (Berkeley)
10/1/80'), carrying Bell Labs' additions -- the PDP-11 disk geometries, the UBL
monsters, the Australian beer.  Its syntax is the old program's, and the new
parser rejects it on almost every line:

    old                     new
    / comment               # comment
    *a* .. *j*              @0 .. @9       the primitive dimensions
    2.997925+8              2.997925e8     the exponent has no `e'
    1|180                   1/180          a fraction
    sec2                    sec^2          a trailing digit is a power
    pi-radian               pi radian      `-' separates factors
    kg/m2-sec2              kg/(m^2 sec^2) EVERYTHING after `/' divides;
                                           in units.y `/' takes one term

So the table is translated, and the translation is not trusted: this file also
carries a port of each program's reader -- old/units.c's init(), convr(),
getflt() and lookup(), and units.y's readunits(), yylex(), grammar and look2()
-- and every unit the old table defines is evaluated by both, as a user would
type its name.  They must agree on every dimension and on the value to 1e-12.
That is the whole check; a translation that merely parses would have passed
`sec2', which units.y reads as an unknown unit with coefficient 5551212
(units.y:236) and defines anyway, because readunits never looks at nerror.

THE PORTS WERE CHECKED AGAINST THE C, once, on 8 Oct 2026: units.y through
byacc and old/units.c, both compiled on a Linux host with only their `%g'
widened to `%.17g', asked for all 484 units -- and the C programs agreed with
each other and with these ports on every one, to 1e-12.  To repeat it, make
cdate.h say `long cdate=0x7fffffff;': Units.bin is a dump of the unit table,
name POINTERS included (units.y:429), which on a VAX with one binary is fine
and on a host with address randomisation is a crash on the second run.

TWO FILES, BECAUSE units.y READS TWO.  The `/ Money' section -- the old table's
own `epoch Jul 29, 1981 wall st j' -- goes to Monetary.Units, which is what that
second file is for: the manual (units.7) says the exchange rates come from the
AP wire, kept in td's Monetary.units on alice.  It matters that the file exists
at all: readunits perror()s a missing one on every run, and its Units.bin cache
is only trusted when both files stat (units.y:358).

TWO RATES ARE NOT CARRIED.  The 1981 table gives iranrial `.0000 $' and
iraqdinar `0.000 $'.  old/units.c:161 turns a factor of zero into ONE, so the
old program said a rial was a dollar; units.y would keep the zero and divide by
it.  Neither is the rate.  Both lines, and the rial and dinar that name them,
are carried as comments.

NOR IS THE ROOFER'S SQUARE, `square 100 ft2'.  units.y's lexer turns `square'
into its squaring operator before lookup sees the word (units.y:229), so the
unit could be defined and never asked for -- and `?' would list it.  It too is
a comment, and the check expects exactly these five to be absent.
"""

import argparse
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OLD = os.path.join(REPO, "v10", "usr", "src", "cmd", "units", "old", "usr.lib.units")
OUT_UNITS = os.path.join(REPO, "v10", "usr", "src", "build", "etc", "Units")
OUT_MONEY = os.path.join(REPO, "v10", "usr", "src", "build", "etc", "Monetary.Units")

# Not carried, and why -- see the module comment.  The check fails if any OTHER
# unit is missing, and if any of these turns up.
ZERO_RATE = ("iranrial", "iraqdinar")
ZERO_ALIAS = ("rial", "dinar")
SHADOWED = ("square",)

# Every other unit must come out the same to this much.  The two readers reach a
# decimal by different roads -- getflt() builds the mantissa digit by digit and
# multiplies by ten n times; units.y calls atof() -- so the last bit or two of a
# double may differ.  Nothing a translation error produces is that small.
RTOL = 1e-12


# -----------------------------------------------------------------------------
# old/units.c, the reader the table was written for
# -----------------------------------------------------------------------------

OLD_NDIM = 10
OLD_NTAB = 601              # table[NTAB]; a full table makes hash() spin
OLD_NAMES = OLD_NTAB * 10   # names[NTAB*10], where every name is copied
OLD_NAMELEN = 20            # convr's `char name[20]': longer overruns it
OLD_PREFIX = [              # units.c:28-47, in order: the first match wins
    (1e-18, b"atto"), (1e-15, b"femto"), (1e-12, b"pico"), (1e-9, b"nano"),
    (1e-6, b"micro"), (1e-3, b"milli"), (1e-2, b"centi"), (1e-1, b"deci"),
    (1e1, b"deka"), (1e2, b"hecta"), (1e2, b"hecto"), (1e3, b"kilo"),
    (1e6, b"mega"), (1e6, b"meg"), (1e9, b"giga"), (1e12, b"tera"),
]
OLD_SEP = set(b"123456789-/ \t\n")   # convr's case labels: each ends a name


class OldReader:
    """old/units.c's init() over the whole table.

    Kept to the C's shape on purpose -- get() and its one character of
    pushback, getflt() reading the leading number and nothing else, lookup()
    trying the name, then a prefix, then a trailing `s' -- because the point is
    to reproduce what that program computed, quirks included, not what the
    table seems to say.
    """

    def __init__(self, data):
        self.data = data
        self.pos = 0
        self.peekc = 0
        self.table = {}
        self.order = []          # (name, line number), definitions in order
        self.errors = []
        self.line = 1            # where get() is
        self.at = 1              # the line being defined, for messages
        self.namebytes = 0

    def get(self):
        if self.peekc:
            c, self.peekc = self.peekc, 0
            return c
        if self.pos >= len(self.data):
            return 0
        c = self.data[self.pos]
        self.pos += 1
        if c == 10:
            self.line += 1
        return c

    def getflt(self):
        d = 0.0
        dp = 0
        c = self.get()
        while c in (32, 9):
            c = self.get()
        while True:
            if 48 <= c <= 57:
                d = d * 10.0 + (c - 48)
                if dp:
                    dp += 1
                c = self.get()
                continue
            if c == 46:
                dp += 1
                c = self.get()
                continue
            break
        if dp:
            dp -= 1
        if c in (43, 45):
            neg = c == 45
            i = 0
            c = self.get()
            while 48 <= c <= 57:
                i = i * 10 + (c - 48)
                c = self.get()
            if neg:
                i = -i
            dp -= i
        e = 1.0
        for _ in range(abs(dp)):
            e *= 10.0
        if dp < 0:
            d *= e
        else:
            d /= e
        if c == 124:            # `|': a fraction, and the divisor recurses
            return d / self.getflt()
        self.peekc = c
        return d

    def lookup(self, name, p, den, c):
        e = 1.0
        while True:
            if name in self.table:
                f, dims = self.table[name]
                while True:
                    if den:
                        p[0] /= f * e
                        p[1] = [a - b for a, b in zip(p[1], dims)]
                    else:
                        p[0] *= f * e
                        p[1] = [a + b for a, b in zip(p[1], dims)]
                    if 50 <= c <= 57:       # a digit 2-9 after the name
                        c -= 1
                        continue
                    return 0
            for f, pn in OLD_PREFIX:
                if name.startswith(pn):
                    e *= f
                    name = name[len(pn):]
                    break
            else:
                if len(name) > 1 and name.endswith(b"s"):
                    name = name[:-1]
                    continue
                self.errors.append("line %d: cannot recognize %s"
                                   % (self.at, name.decode()))
                return 1

    def convr(self):
        p = [self.getflt(), [0] * OLD_NDIM]
        if p[0] == 0.0:
            p[0] = 1.0                  # units.c:161
        den = 0
        name = bytearray()
        while True:
            c = self.get()
            if c == 0:
                # The C appends the NUL and loops forever.
                raise SystemExit("old table: line %d ends without a newline"
                                 % self.line)
            if c in OLD_SEP:
                if name:
                    if len(name) >= OLD_NAMELEN:
                        self.errors.append("line %d: %s overruns name[20]"
                                           % (self.at, name.decode()))
                    self.lookup(bytes(name), p, den, c)
                    name = bytearray()
                if c == 47:
                    den += 1
                if c == 10:
                    return p
                continue
            name.append(c)

    def run(self):
        for i in range(OLD_NDIM):
            dims = [0] * OLD_NDIM
            dims[i] = 1
            self.table[b"*%c*" % (97 + i)] = (1.0, dims)
            self.namebytes += 4
        self.table[b""] = (1.0, [0] * OLD_NDIM)
        while True:
            c = self.get()
            if c == 0:
                break
            if c == 47:                 # `/' at the start of a line
                while c not in (10, 0):
                    c = self.get()
                continue
            if c == 10:
                continue
            np = bytearray()
            line = self.line
            while c not in (32, 9):
                np.append(c)
                c = self.get()
                if c in (0, 10):
                    # A bare name copies the previous unit (units.c:317).  The
                    # table has none, and the converter would have to invent a
                    # spelling for one, so refuse it rather than model it.
                    raise SystemExit("old table: line %d: %s has no definition"
                                     % (line, np.decode()))
            name = bytes(np)
            if name in self.table:
                # units.c:354 leaves the rest of the line to be misread as a
                # string of one-character definitions.  Not modelled; refused.
                raise SystemExit("old table: line %d: redefinition %s"
                                 % (line, name.decode()))
            self.at = line
            # Into the table only once convr() returns: units.c:335 sets
            # lp->name after it, so a definition cannot see itself.
            self.table[name] = tuple(self.convr())
            self.order.append((name, line))
            self.namebytes += len(name) + 1
        if len(self.table) >= OLD_NTAB:
            self.errors.append("%d names fill table[%d]"
                               % (len(self.table), OLD_NTAB))
        if self.namebytes > OLD_NAMES:
            self.errors.append("%d bytes of names overrun names[%d]"
                               % (self.namebytes, OLD_NAMES))
        return self


# -----------------------------------------------------------------------------
# units.y, the reader the machine runs
# -----------------------------------------------------------------------------

NDIM = 11                   # units.y:5
NUNIT = 700                 # units.y:6
NSTRBUF = 8192              # units.y:7
LINEMAX = 511               # readunits' fgets into buf[512]
PREFIX = [                  # units.y:69-102, in order: the first match wins
    (b"exa", 1e18), (b"peta", 1e15), (b"tera", 1e12), (b"giga", 1e9),
    (b"mega", 1e6), (b"meg", 1e6), (b"myria", 1e4), (b"kilo", 1e3),
    (b"hekta", 1e2), (b"hekto", 1e2), (b"deka", 1e1), (b"sesqui", 1.5),
    (b"hemi", .5), (b"demi", .5), (b"semi", .5), (b"deci", 1e-1),
    (b"centi", 1e-2), (b"milli", 1e-3), (b"micro", 1e-6), (b"nano", 1e-9),
    (b"pico", 1e-12), (b"femto", 1e-15), (b"atto", 1e-18),
    (b"G", 1e9), (b"M", 1e6), (b"k", 1e3), (b"m", 1e-3), (b"u", 1e-6),
    (b"n", 1e-9), (b"p", 1e-12),
]
NOTID = set(b"\0*/@()^ \t\n")   # idcharfn(): everything else is a name byte
KEYWORD = {b"square": "SQUARE", b"sq": "SQUARE", b"cubic": "CUBE", b"cu": "CUBE"}
ZERO = [0] * NDIM


class ParseError(Exception):
    pass


class NewReader:
    """units.y's readunits() over Units then Monetary.Units.

    The table is the C's: NUNIT slots, hashed by hash() and probed linearly,
    names copied into an NSTRBUF buffer, a duplicate name stored again and
    shadowed by the first.  The grammar is units.y's, with yacc's resolution of
    its conflicts -- `^' binds tighter than square and cubic, and a `/' takes
    the one term after it.
    """

    def __init__(self):
        self.slot = [None] * NUNIT
        self.strp = 0
        self.errors = []
        self.where = ""

    @staticmethod
    def hash(s):
        i = 0
        for j, ch in enumerate(s):
            i += ch * j
        return i % NUNIT

    def look2(self, s):
        coef = 1.0
        while True:
            i = j = self.hash(s)
            while self.slot[j] is not None:
                name, c, dims = self.slot[j]
                if name == s:
                    return (c * coef, dims)
                j = (j + 1) % NUNIT
                if j == i:
                    break
            for pn, pc in PREFIX:
                if s.startswith(pn):
                    coef *= pc
                    s = s[len(pn):]
                    if not s:
                        return (coef, ZERO)
                    break
            else:
                return None

    def lookup(self, name):
        u = self.look2(name)
        if u is None and name.endswith(b"s"):
            u = self.look2(name[:-1])
        if u is None:
            self.errors.append("%s: Unknown unit %s" % (self.where, name.decode()))
        return u

    # yylex
    def lex(self, text):
        toks = []
        i = 0
        n = len(text)
        while True:
            while i < n and text[i] in (32, 9):
                i += 1
            if i >= n:
                toks.append(("EOF", None))
                return toks
            c = text[i]
            if 48 <= c <= 57 or c in (45, 46):
                start = i
                digits = dots = 0
                while True:
                    if 48 <= text[i] <= 57:
                        digits += 1
                    elif text[i] == 46:
                        dots += 1
                    i += 1
                    if i >= n or not (48 <= text[i] <= 57 or text[i] == 46):
                        break
                if not digits or dots > 1:
                    raise ParseError("Bad number")
                if i < n and text[i] in (101, 69):
                    i += 1
                    if i < n and text[i] in (43, 45):
                        i += 1
                    if i >= n or not 48 <= text[i] <= 57:
                        raise ParseError("Bad number")
                    while i < n and 48 <= text[i] <= 57:
                        i += 1
                toks.append(("NUMBER", float(text[start:i])))
                continue
            if c not in NOTID:
                start = i
                while i < n and text[i] not in NOTID:
                    i += 1
                word = text[start:i]
                if word in KEYWORD:
                    toks.append((KEYWORD[word], None))
                else:
                    toks.append(("NAME", word))
                continue
            if c in b"*/()^@":
                toks.append((chr(c), None))
                i += 1
                continue
            raise ParseError("Bad char")

    # the grammar, units.y:26-35
    def parse(self, text):
        self.toks = self.lex(text)
        self.k = 0
        v = self.unit()
        if self.toks[self.k][0] != "EOF":
            raise ParseError("syntax error at %s" % self.toks[self.k][0])
        return v

    def peek(self):
        return self.toks[self.k][0]

    def take(self):
        t = self.toks[self.k]
        self.k += 1
        return t

    def unit(self):
        v = (1.0, ZERO)
        while True:
            t = self.peek()
            if t == "/":
                self.take()
                u = self.u()
                v = (v[0] / u[0], [a - b for a, b in zip(v[1], u[1])])
            elif t in ("NUMBER", "NAME", "@", "(", "SQUARE", "CUBE"):
                u = self.u()
                v = (v[0] * u[0], [a + b for a, b in zip(v[1], u[1])])
            else:
                return v

    def u(self):
        kind, val = self.take()
        if kind == "NUMBER":
            v = (val, ZERO)
        elif kind == "NAME":
            v = self.lookup(val)
            if v is None:
                v = (5551212.0, ZERO)       # units.y:236
        elif kind == "@":
            kind, val = self.take()
            if kind != "NUMBER":
                raise ParseError("syntax error after @")
            d = int(val)
            if d != val:
                raise ParseError("Primitive unit must be integral")
            if not 0 <= d < NDIM:
                raise ParseError("Primitive unit out of range")
            dims = [0] * NDIM
            dims[d] = 1
            v = (1.0, dims)
        elif kind == "(":
            v = self.unit()
            if self.take()[0] != ")":
                raise ParseError("syntax error: no )")
        elif kind == "SQUARE":
            v = self.pwr(self.u(), 2)
        elif kind == "CUBE":
            v = self.pwr(self.u(), 3)
        else:
            raise ParseError("syntax error at %s" % kind)
        while self.peek() == "^":
            self.take()
            kind, val = self.take()
            if kind != "NUMBER":
                raise ParseError("syntax error after ^")
            v = self.pwr(v, val)
        return v

    @staticmethod
    def pwr(v, f):
        if f != int(f):
            raise ParseError("Sorry, only integer powers")
        return (v[0] ** f, [a * int(f) for a in v[1]])

    def readfile(self, label, text):
        for lineno, raw in enumerate(text.split(b"\n"), 1):
            self.where = "%s:%d" % (label, lineno)
            if len(raw) + 1 > LINEMAX:
                self.errors.append("%s: longer than fgets' buf[512]" % self.where)
            buf = raw.split(b"#", 1)[0]
            buf = buf.lstrip(b" \t")
            if not buf:
                continue
            k = 0
            while k < len(buf) and buf[k] not in NOTID:
                k += 1
            if k == len(buf) or buf[k] not in (32, 9):
                self.errors.append("%s: Bad unit `%s'" % (self.where, buf.decode()))
                continue
            name = buf[:k]
            if name in KEYWORD:
                # Definable, but yylex turns the word into an operator before
                # lookup ever sees it, so nobody can ask for it.
                self.errors.append("%s: %s is a keyword and unreachable"
                                   % (self.where, name.decode()))
            try:
                v = self.parse(buf[k + 1:])
            except ParseError as e:
                self.errors.append("%s: %s" % (self.where, e))
                continue
            i = j = self.hash(name)
            while self.slot[j] is not None:
                if self.slot[j][0] == name:
                    self.errors.append("%s: %s defined twice; the first wins"
                                       % (self.where, name.decode()))
                j = (j + 1) % NUNIT
                if j == i:
                    raise SystemExit("%s: Units: out of space (NUNIT)" % self.where)
            self.strp += len(name) + 1
            if self.strp > NSTRBUF:
                raise SystemExit("%s: Units: out of space (copy)" % self.where)
            self.slot[j] = (name, v[0], v[1])

    def ask(self, name):
        """What `You have: <name>' evaluates to."""
        self.where = "asking for %s" % name.decode()
        try:
            return self.parse(name)
        except ParseError as e:
            self.errors.append("%s: %s" % (self.where, e))
            return None


# -----------------------------------------------------------------------------
# the translation
# -----------------------------------------------------------------------------

def number(text):
    """getflt()'s leading number, re-spelled for atof: (spelling, rest).

    `2.997925+8' -> `2.997925e8', `1-6|4' -> `1e-6/4'.  No number at all is
    an empty spelling, which both readers take as a factor of one."""
    terms = []
    i = 0
    while True:
        while i < len(text) and text[i] in " \t":
            i += 1
        j = i
        while j < len(text) and (text[j].isdigit() or text[j] == "."):
            j += 1
        mant = text[i:j]
        exp = ""
        if j < len(text) and text[j] in "+-":
            k = j + 1
            while k < len(text) and text[k].isdigit():
                k += 1
            exp = text[j:k]
            j = k
        if len(exp) > 1:
            exp = "e" + exp.lstrip("+")
        else:
            exp = ""                    # getflt eats a lone sign
        if exp and not mant:
            raise SystemExit("an exponent with no mantissa: %r" % text)
        terms.append(mant + exp)
        if j < len(text) and text[j] == "|":
            i = j + 1
            continue
        if len(terms) > 2:
            raise SystemExit("a fraction of %d terms: %r" % (len(terms), text))
        return "/".join(terms), text[j:]


def factors(text):
    """convr()'s names, as (name, power, in-denominator)."""
    out = []
    den = False
    name = ""
    for c in text + "\n":
        if c in "123456789-/ \t\n":
            if name:
                out.append((name, int(c) if c.isdigit() else 1, den))
                name = ""
            if c == "/":
                den = True
            continue
        name += c
    return out


def term(name, power):
    if name.startswith("*") and name.endswith("*") and len(name) == 3:
        return "@%d" % (ord(name[1]) - ord("a"))
    return name if power == 1 else "%s^%d" % (name, power)


def expression(text):
    num, rest = number(text)
    fs = factors(rest)
    top = [term(n, p) for n, p, d in fs if not d]
    bottom = [term(n, p) for n, p, d in fs if d]
    out = " ".join(([num] if num else []) + top)
    if bottom:
        div = bottom[0] if len(bottom) == 1 else "(%s)" % " ".join(bottom)
        out += "/" + div
    return out


HEADER_UNITS = """\
# /usr/lib/Units: what units(7) reads first.  A line is `name expression';
# `#' begins a comment; @n is the n'th primitive dimension; terms side by side
# multiply, `/' divides by the one term after it, `^' raises to a power.
#
# GENERATED by tools/v10-units.py -- edit that, or the table it reads, and
# rerun it.  The table is cmd/units/old/usr.lib.units, the only one any v10
# tape carries, written for the old program beside it; no tape carries this
# file.  Every unit below evaluates, under a port of units.y's own reader, to
# what the old table gave it under a port of old/units.c's, and --check fails
# the day one does not.  The money is in Monetary.Units.

"""

HEADER_MONEY = """\
# /usr/lib/Monetary.Units: what units(7) reads after Units, and the exchange
# rates.  The manual has these come off the AP wire into td's Monetary.units on
# alice; what a v10 tape carries is the old table's `/ Money' section, at its
# own date, below.  units.y must find this file: it complains on every run
# without it, and never trusts Units.bin.
#
# GENERATED by tools/v10-units.py from cmd/units/old/usr.lib.units.

"""

NOT_CARRIED = ("# NOT CARRIED: the 1981 table has no rate here.  old/units.c read a "
               "zero as one\n# (units.c:161), so it said this was a dollar; "
               "units.y would divide by zero.\n")
NOT_REACHABLE = ("# NOT CARRIED: units.y reads `square' as its squaring operator "
                 "(units.y:229),\n# so this unit could be defined and never "
                 "asked for.\n")


def convert(data):
    """The old table -> (Units, Monetary.Units), line for line."""
    units, money = [HEADER_UNITS], [HEADER_MONEY]
    out = units
    for raw in data.decode().split("\n")[:-1]:
        if raw.startswith("/"):
            if raw.strip() == "/ Money":
                out = money
            elif out is money and not raw.startswith("/ epoch") and raw.strip():
                out = units             # the next section ends the money
            out.append("#" + raw[1:] + "\n")
            continue
        if not raw.strip():
            out.append("\n")
            continue
        k = 0
        while raw[k] not in " \t":
            k += 1
        j = k
        while raw[j] in " \t":
            j += 1
        name, gap, text = raw[:k], raw[k:j], raw[j:].rstrip(" \t")
        line = name + gap + expression(text) + "\n"
        if name in ZERO_RATE:
            line = NOT_CARRIED + "# " + line
        elif name in ZERO_ALIAS:
            line = "# " + line
        elif name in SHADOWED:
            line = NOT_REACHABLE + "# " + line
        out.append(line)
    return "".join(units).encode(), "".join(money).encode()


# -----------------------------------------------------------------------------
# the proof
# -----------------------------------------------------------------------------

def prove(data, units, money):
    """Both readers over their tables; every old unit asked of the new one."""
    old = OldReader(data).run()
    new = NewReader()
    new.readfile("Units", units)
    new.readfile("Monetary.Units", money)
    problems = []
    absent = set(ZERO_RATE + ZERO_ALIAS + SHADOWED)
    compared = 0
    for name, line in old.order:
        n = name.decode()
        ofac, odims = old.table[name]
        if n in absent:
            if new.look2(name) is not None:
                problems.append("%s is carried, and should not be" % n)
            continue
        got = new.ask(name)
        if got is None:
            continue
        nfac, ndims = got
        want = list(odims) + [0] * (NDIM - OLD_NDIM)
        if list(ndims) != want:
            problems.append("%s (line %d): dimensions %s, the old table's %s"
                            % (n, line, ndims, want))
        elif abs(nfac - ofac) > RTOL * abs(ofac):
            problems.append("%s (line %d): %.17g, the old table's %.17g"
                            % (n, line, nfac, ofac))
        compared += 1
    used = sum(s is not None for s in new.slot)
    problems = (["old table: " + e for e in old.errors]
                + ["new table: " + e for e in new.errors] + problems)
    return problems, compared, used, new.strp


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="fail if the committed files differ or do not prove")
    args = ap.parse_args()

    data = open(OLD, "rb").read()
    units, money = convert(data)
    problems, compared, used, strp = prove(data, units, money)
    for p in problems:
        print("v10-units: " + p)

    if args.check:
        stale = [p for p, want in ((OUT_UNITS, units), (OUT_MONEY, money))
                 if not os.path.exists(p) or open(p, "rb").read() != want]
        for p in stale:
            print("v10-units: %s is stale -- rerun tools/v10-units.py"
                  % os.path.relpath(p, REPO))
        ok = not problems and not stale
    else:
        if problems:
            sys.exit("v10-units: not written")
        for p, want in ((OUT_UNITS, units), (OUT_MONEY, money)):
            with open(p, "wb") as f:
                f.write(want)
        ok = True
    print("v10-units: %d units agree with the old table; %d of %d slots, "
          "%d of %d bytes of names" % (compared, used, NUNIT, strp, NSTRBUF))
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
