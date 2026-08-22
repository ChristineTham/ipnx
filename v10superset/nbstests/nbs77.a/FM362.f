*HEADER,FORTR,FM362
*FILES1,FORTR,FM362,X
C***********************************************************************
C*****  FORTRAN 77
C*****   FM362               XMIN - (167)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                       SUBSET REF
C*****    TEST INTRINSIC FUNCTIONS AMIN0,AMIN1,MIN0,MIN1         15.3
C*****    CHOOSING SMALLEST VALUE.                             (TABLE 5)
C*****
CBB** ********************** BBCCOMNT **********************************
C****
C****            1978 FORTRAN COMPILER VALIDATION SYSTEM
C****                          VERSION 2.0
C****
C****
C****           SUGGESTIONS AND COMMENTS SHOULD BE FORWARDED TO
C****                   GENERAL SERVICES ADMINISTRATION
C****                   FEDERAL SOFTWARE TESTING CENTER
C****                   5203 LEESBURG PIKE, SUITE 1100
C****                      FALLS CHURCH, VA. 22041
C****
C****                          (703) 756-6153
C****
CBE** ********************** BBCCOMNT **********************************
CBB** ********************** BBCINITA **********************************
C**** SPECIFICATION STATEMENTS
C****
      CHARACTER ZVERS*13, ZVERSD*17, ZDATE*17, ZPROG*5, ZCOMPL*20,
     1          ZNAME*20, ZTAPE*10, ZPROJ*13, REMRKS*31, ZTAPED*13
CBE** ********************** BBCINITA **********************************
CBB** ********************** BBCINITB **********************************
C**** INITIALIZE SECTION
      DATA  ZVERS,                  ZVERSD,             ZDATE
     1      /'VERSION 2.0  ',  '82/08/02*18.33.46',  '*NO DATE*TIME'/
      DATA       ZCOMPL,             ZNAME,             ZTAPE
     1      /'*NONE SPECIFIED*', '*NO COMPANY NAME*', '*NO TAPE*'/
      DATA       ZPROJ,           ZTAPED,         ZPROG
     1      /'*NO PROJECT*',   '*NO TAPE DATE',  'XXXXX'/
      DATA   REMRKS /'                               '/
C**** THE FOLLOWING 9 COMMENT LINES (CZ01, CZ02, ...) CAN BE REPLACED
C**** FOR IDENTIFYING THE TEST ENVIRONMENT
C****
CZ01  ZVERS  = 'VERSION OF THE COMPILER VALIDATION SYSTEM'
CZ02  ZVERSD = 'CREATION DATE/TIME OF THE COMPILER VALIDATION SYSTEM'
CZ03  ZPROG  = 'PROGRAM NAME'
CZ04  ZDATE  = 'DATE OF TEST'
CZ05  ZCOMPL = 'COMPILER IDENTIFICATION'
CZ06  ZPROJ  = 'PROJECT NUMBER/IDENTIFICATION'
CZ07  ZNAME  = 'NAME OF USER'
CZ08  ZTAPE  = 'TAPE OWNER/ID'
CZ09  ZTAPED = 'DATE TAPE COPIED'
C
      IVPASS = 0
      IVFAIL = 0
      IVDELE = 0
      IVINSP = 0
      IVTOTL = 0
      IVTOTN = 0
      ICZERO = 0
C
C     I01 CONTAINS THE LOGICAL UNIT NUMBER FOR THE CARD READER.
      I01 = 05
C     I02 CONTAINS THE LOGICAL UNIT NUMBER FOR THE PRINTER.
      I02 = 06
C
CX010   REPLACED BY FEXEC X-010 CONTROL CARD (CARD-READER UNIT NUMBER).
C     THE CX010 CARD IS FOR OVERRIDING THE PROGRAM DEFAULT I01 = 5
CX011   REPLACED BY FEXEC X-011 CONTROL CARD.  CX011 IS FOR SYSTEMS
C     REQUIRING ADDITIONAL STATEMENTS FOR FILES ASSOCIATED WITH CX010.
C
CX020   REPLACED BY FEXEC X-020 CONTROL CARD (PRINTER UNIT NUMBER).
C     THE CX020 CARD IS FOR OVERRIDING THE PROGRAM DEFAULT I02= 6
CX021   REPLACED BY FEXEC X-021 CONTROL CARD.  CX021 IS FOR SYSTEMS
C     REQUIRING ADDITIONAL STATEMENTS FOR FILES ASSOCIATED WITH CX020.
C
CBE** ********************** BBCINITB **********************************
      NUVI = I02
      IVTOTL = 47
      ZPROG = 'FM362'
CBB** ********************** BBCHED0A **********************************
C****
C**** WRITE REPORT TITLE
C****
      WRITE (I02, 90002)
      WRITE (I02, 90006)
      WRITE (I02, 90007)
      WRITE (I02, 90008)  ZVERS, ZVERSD
      WRITE (I02, 90009)  ZPROG, ZPROG
      WRITE (I02, 90010)  ZDATE, ZCOMPL
CBE** ********************** BBCHED0A **********************************
C*****
C*****    HEADER FOR SEGMENT 167
        WRITE (NUVI,16700)
16700   FORMAT (1H , // 2X,36HXMIN - (167) INTRINSIC FUNCTIONS--  //13X,
     1          24HAMIN0, AMIN1, MIN0, MIN1/ 13X,
     2          25H(CHOOSING SMALLEST VALUE)//2X,
     3          18HSUBSET REF. - 15.3)
CBB** ********************** BBCHED0B **********************************
C**** WRITE DETAIL REPORT HEADERS
C****
      WRITE (I02,90004)
      WRITE (I02,90004)
      WRITE (I02,90013)
      WRITE (I02,90014)
      WRITE (I02,90015) IVTOTL
CBE** ********************** BBCHED0B **********************************
C*****
C*****    TEST OF AMIN0
C*****
        WRITE(NUVI, 16702)
16702   FORMAT (/ 8X, 13HTEST OF AMIN0)
CT001*  TEST 1                                       BOTH VALUES ZERO
           IVTNUM = 1
        IIBVI = 0
        IIDVI = 0
        RIAVS = AMIN0(IIBVI, IIDVI)
           IF (RIAVS + 0.00005) 20010, 10010, 40010
40010      IF (RIAVS - 0.00005) 10010, 10010, 20010
10010      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0011
20010      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0011      CONTINUE
CT002*  TEST 2                      FIRST VALUE NON-ZERO, SECOND ZERO
           IVTNUM = 2
        IIBVI = 6
        IIDVI = 0
        RIAVS = AMIN0(IIBVI, IIDVI)
           IF (RIAVS + 0.00005) 20020, 10020, 40020
40020      IF (RIAVS - 0.00005) 10020, 10020, 20020
10020      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0021
20020      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0021      CONTINUE
CT003*  TEST 3                                      BOTH VALUES EQUAL
           IVTNUM = 3
        IIBVI = 7
        IIDVI = 7
        RIAVS = AMIN0(IIBVI, IIDVI)
           IF (RIAVS - 6.9996) 20030, 10030, 40030
40030      IF (RIAVS - 7.0004) 10030, 10030, 20030
10030      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0031
20030      IVFAIL = IVFAIL + 1
           RVCORR = 7.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0031      CONTINUE
CT004*  TEST 4                                       VALUES NOT EQUAL
           IVTNUM = 4
        IIBVI = 7
        IIDVI = 5
        RIAVS = AMIN0(IIBVI, IIDVI)
           IF (RIAVS - 4.9997) 20040, 10040, 40040
40040      IF (RIAVS - 5.0003) 10040, 10040, 20040
10040      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0041
20040      IVFAIL = IVFAIL + 1
           RVCORR = 5.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0041      CONTINUE
CT005*  TEST 5                      FIRST VALUE NEGATIVE, SECOND ZERO
           IVTNUM = 5
        IIBVI = -6
        IIDVI = 0
        RIAVS = AMIN0(IIBVI, IIDVI)
           IF (RIAVS + 6.0003) 20050, 10050, 40050
40050      IF (RIAVS + 5.9997) 10050, 10050, 20050
10050      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0051
20050      IVFAIL = IVFAIL + 1
           RVCORR = -6.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0051      CONTINUE
CT006*  TEST 6                       BOTH VALUES EQUAL, BOTH NEGATIVE
           IVTNUM = 6
        IIBVI = -7
        IIDVI = -7
        RIAVS = AMIN0(IIBVI, IIDVI)
           IF (RIAVS + 7.0004) 20060, 10060, 40060
40060      IF (RIAVS + 6.9996) 10060, 10060, 20060
10060      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0061
20060      IVFAIL = IVFAIL + 1
           RVCORR = -7.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0061      CONTINUE
CT007*  TEST 7                        VALUES NOT EQUAL, BOTH NEGATIVE
           IVTNUM = 7
        IIBVI = -7
        IIDVI = -5
        RIAVS = AMIN0(IIBVI, IIDVI)
           IF (RIAVS + 7.0004) 20070, 10070, 40070
40070      IF (RIAVS + 6.9996) 10070, 10070, 20070
10070      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0071
20070      IVFAIL = IVFAIL + 1
           RVCORR = -7.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0071      CONTINUE
CT008*  TEST 8  FIRST VALUE NON-ZERO, 2ND ZERO PRECEDED BY MINUS SIGN
           IVTNUM = 8
        IIDVI = 6
        IIEVI = 0
        RIAVS = AMIN0(IIDVI, -IIEVI)
           IF (RIAVS + 0.00005) 20080, 10080, 40080
40080      IF (RIAVS - 0.00005) 10080, 10080, 20080
10080      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0081
20080      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0081      CONTINUE
CT009*  TEST 9                                            3 ARGUMENTS
           IVTNUM = 9
        IIBVI = 0
        IICVI = 9
        IIDVI = 8
        RIAVS = AMIN0(IIBVI, IICVI, IIDVI)
           IF (RIAVS + 0.00005) 20090, 10090, 40090
40090      IF (RIAVS - 0.00005) 10090, 10090, 20090
10090      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0091
20090      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0091      CONTINUE
CT010*  TEST 10                                           4 ARGUMENTS
           IVTNUM = 10
        IIBVI = 34
        IICVI = 8
        IIDVI = 4
        RIAVS = AMIN0(IIDVI, IIBVI, IICVI, IIDVI)
           IF (RIAVS - 3.9998) 20100, 10100, 40100
40100      IF (RIAVS - 4.0002) 10100, 10100, 20100
10100      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0101
20100      IVFAIL = IVFAIL + 1
           RVCORR = 4.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0101      CONTINUE
CT011*  TEST 11                                           5 ARGUMENTS
           IVTNUM = 11
        IIDVI = 4.0
        IIEVI = 5.0
        RIAVS = AMIN0(IIDVI, -IIDVI, -IIEVI, +IIDVI, IIEVI)
           IF (RIAVS + 5.0003) 20110, 10110, 40110
40110      IF (RIAVS + 4.9997) 10110, 10110, 20110
10110      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0111
20110      IVFAIL = IVFAIL + 1
           RVCORR = -5.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0111      CONTINUE
C*****
        WRITE (NUVI, 90002)
        WRITE (NUVI, 90013)
        WRITE (NUVI, 90014)
C*****    TEST OF AMIN1
C*****
        WRITE(NUVI, 16704)
16704   FORMAT (/ 8X, 13HTEST OF AMIN1)
CT012*  TEST 12                                      BOTH VALUES ZERO
           IVTNUM = 12
        RIBVS = 0.0
        RIDVS = 0.0
        RIAVS = AMIN1(RIBVS, RIDVS)
           IF (RIAVS + 0.00005) 20120, 10120, 40120
40120      IF (RIAVS - 0.00005) 10120, 10120, 20120
10120      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0121
20120      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0121      CONTINUE
CT013*  TEST 13                     FIRST VALUE NON-ZERO, SECOND ZERO
           IVTNUM = 13
        RIBVS = 5.625
        RIDVS = 0.0
        RIAVS = AMIN1(RIBVS, RIDVS)
           IF (RIAVS + 0.00005) 20130, 10130, 40130
40130      IF (RIAVS - 0.00005) 10130, 10130, 20130
10130      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0131
20130      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0131      CONTINUE
CT014*  TEST 14                                     BOTH VALUES EQUAL
           IVTNUM = 14
        RIBVS = 6.5
        RIDVS = 6.5
        RIAVS = AMIN1(RIBVS, RIDVS)
           IF (RIAVS - 6.4996) 20140, 10140, 40140
40140      IF (RIAVS - 6.5004) 10140, 10140, 20140
10140      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0141
20140      IVFAIL = IVFAIL + 1
           RVCORR = 6.5
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0141      CONTINUE
CT015*  TEST 15                                      VALUES NOT EQUAL
           IVTNUM = 15
        RIBVS = 7.125
        RIDVS = 5.125
        RIAVS = AMIN1(RIBVS, RIDVS)
           IF (RIAVS - 5.1247) 20150, 10150, 40150
40150      IF (RIAVS - 5.1253) 10150, 10150, 20150
10150      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0151
20150      IVFAIL = IVFAIL + 1
           RVCORR = 5.125
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0151      CONTINUE
CT016*  TEST 16                     FIRST VALUE NEGATIVE, SECOND ZERO
           IVTNUM = 16
        RIBVS = -5.625
        RIDVS = 0.0
        RIAVS = AMIN1(RIBVS, RIDVS)
           IF (RIAVS + 5.6253) 20160, 10160, 40160
40160      IF (RIAVS + 5.6247) 10160, 10160, 20160
10160      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0161
20160      IVFAIL = IVFAIL + 1
           RVCORR = -5.625
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0161      CONTINUE
CT017*  TEST 17                      BOTH VALUES EQUAL, BOTH NEGATIVE
           IVTNUM = 17
        RIBVS = -6.5
        RIDVS = -6.5
        RIAVS = AMIN1(RIBVS, RIDVS)
           IF (RIAVS + 6.5004) 20170, 10170, 40170
40170      IF (RIAVS + 6.4996) 10170, 10170, 20170
10170      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0171
20170      IVFAIL = IVFAIL + 1
           RVCORR = -6.5
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0171      CONTINUE
CT018*  TEST 18                       VALUES NOT EQUAL, BOTH NEGATIVE
           IVTNUM = 18
        RIBVS = -7.125
        RIDVS = -5.125
        RIAVS = AMIN1(RIBVS, RIDVS)
           IF (RIAVS + 7.1254) 20180, 10180, 40180
40180      IF (RIAVS + 7.1246) 10180, 10180, 20180
10180      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0181
20180      IVFAIL = IVFAIL + 1
           RVCORR = -7.125
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0181      CONTINUE
CT019*  TEST 19 FIRST VALUE NON-ZERO, 2ND ZERO PRECEDED BY MINUS SIGN
           IVTNUM = 19
        RIDVS = 5.625
        RIEVS = 0.0
        RIAVS = AMIN1(RIDVS, -RIEVS)
           IF (RIAVS + 0.00005) 20190, 10190, 40190
40190      IF (RIAVS - 0.00005) 10190, 10190, 20190
10190      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0191
20190      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0191      CONTINUE
CT020*  TEST 20                                EXPRESSION AS ARGUMENT
           IVTNUM = 20
        RIDVS = 3.5
        RIEVS = 4.0
        RIAVS = AMIN1(RIDVS + RIEVS, -RIEVS - RIDVS)
           IF (RIAVS + 7.5004) 20200, 10200, 40200
40200      IF (RIAVS + 7.4996) 10200, 10200, 20200
10200      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0201
20200      IVFAIL = IVFAIL + 1
           RVCORR = -7.5
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0201      CONTINUE
CT021*  TEST 21                                           3 ARGUMENTS
           IVTNUM = 21
        RIBVS = 0.0
        RICVS = 1.0
        RIDVS = 10.9
        RIAVS = AMIN1(RIDVS, RICVS, RIBVS)
           IF (RIAVS + 0.00005) 20210, 10210, 40210
40210      IF (RIAVS - 0.00005) 10210, 10210, 20210
10210      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0211
20210      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0211      CONTINUE
CT022*  TEST 22                                           4 ARGUMENTS
           IVTNUM = 22
        RIBVS = -9.0
        RICVS = 10.0
        RIDVS = 3.5
        RIAVS = AMIN1(RIDVS, RICVS, -RIBVS, RIDVS)
           IF (RIAVS - 3.4998) 20220, 10220, 40220
40220      IF (RIAVS - 3.5002) 10220, 10220, 20220
10220      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0221
20220      IVFAIL = IVFAIL + 1
           RVCORR = 3.5
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0221      CONTINUE
CT023*  TEST 23                                           5 ARGUMENTS
           IVTNUM = 23
        RIDVS = 3.5
        RIEVS = 4.5
        RIAVS = AMIN1(RIDVS, -RIDVS, -RIEVS, +RIDVS, RIEVS)
           IF (RIAVS + 4.5003) 20230, 10230, 40230
40230      IF (RIAVS + 4.4997) 10230, 10230, 20230
10230      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0231
20230      IVFAIL = IVFAIL + 1
           RVCORR = -4.5
           WRITE (NUVI, 80012) IVTNUM, RIAVS, RVCORR
 0231      CONTINUE
C*****
        WRITE (NUVI, 90002)
        WRITE (NUVI, 90013)
        WRITE (NUVI, 90014)
C*****    TEST OF MIN0
C*****
        WRITE(NUVI, 16705)
16705   FORMAT (/ 8X, 12HTEST OF MIN0)
CT024*  TEST 24                                      BOTH VALUES ZERO
           IVTNUM = 24
        IIBVI = 0
        IIDVI = 0
        IIAVI = MIN0(IIBVI, IIDVI)
           IF (IIAVI - 0) 20240, 10240, 20240
10240      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0241
20240      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0241      CONTINUE
CT025*  TEST 25                     FIRST VALUE NON-ZERO, SECOND ZERO
           IVTNUM = 25
        IIBVI = 6
        IIDVI = 0
        IIAVI = MIN0(IIBVI, IIDVI)
           IF (IIAVI - 0) 20250, 10250, 20250
10250      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0251
20250      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0251      CONTINUE
CT026*  TEST 26                                     BOTH VALUES EQUAL
           IVTNUM = 26
        IIBVI = 7
        IIDVI = 7
        IIAVI = MIN0(IIBVI, IIDVI)
           IF (IIAVI - 7) 20260, 10260, 20260
10260      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0261
20260      IVFAIL = IVFAIL + 1
           IVCORR = 7
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0261      CONTINUE
CT027*  TEST 27                                      VALUES NOT EQUAL
           IVTNUM = 27
        IIBVI = 7
        IIDVI = 5
        IIAVI = MIN0(IIBVI, IIDVI)
           IF (IIAVI - 5) 20270, 10270, 20270
10270      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0271
20270      IVFAIL = IVFAIL + 1
           IVCORR = 5
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0271      CONTINUE
CT028*  TEST 28                     FIRST VALUE NEGATIVE, SECOND ZERO
           IVTNUM = 28
        IIBVI = -6
        IIDVI = 0
        IIAVI = MIN0(IIBVI, IIDVI)
           IF (IIAVI + 6) 20280, 10280, 20280
10280      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0281
20280      IVFAIL = IVFAIL + 1
           IVCORR = -6
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0281      CONTINUE
CT029*  TEST 29                      BOTH VALUES EQUAL, BOTH NEGATIVE
           IVTNUM = 29
        IIBVI = -7
        IIDVI = -7
        IIAVI = MIN0(IIBVI, IIDVI)
           IF (IIAVI + 7) 20290, 10290, 20290
10290      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0291
20290      IVFAIL = IVFAIL + 1
           IVCORR = -7
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0291      CONTINUE
CT030*  TEST 30                       VALUES NOT EQUAL, BOTH NEGATIVE
           IVTNUM = 30
        IIBVI = -7
        IIDVI = -5
        IIAVI = MIN0(IIBVI, IIDVI)
           IF (IIAVI + 7) 20300, 10300, 20300
10300      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0301
20300      IVFAIL = IVFAIL + 1
           IVCORR = -7
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0301      CONTINUE
CT031*  TEST 31 FIRST VALUE NON-ZERO, 2ND ZERO PRECEDED BY MINUS SIGN
           IVTNUM = 31
        IIDVI = 6
        IIEVI = 0
        IIAVI = MIN0(IIDVI, -IIEVI)
           IF (IIAVI - 0) 20310, 10310, 20310
10310      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0311
20310      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0311      CONTINUE
CT032*  TEST 32                      EXPRESSION PRESENTED TO FUNCTION
           IVTNUM = 32
        IIDVI = 3
        IIEVI = 4
        IIAVI = MIN0(IIDVI + IIEVI, -IIEVI - IIDVI)
           IF (IIAVI + 7) 20320, 10320, 20320
10320      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0321
20320      IVFAIL = IVFAIL + 1
           IVCORR = -7
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0321      CONTINUE
CT033*  TEST 33                                           3 ARGUMENTS
           IVTNUM = 33
        IIBVI = 0
        IICVI = 10
        IIDVI = -11
        IIAVI = MIN0(IICVI, IIBVI, -IIDVI)
           IF (IIAVI - 0) 20330, 10330, 20330
10330      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0331
20330      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0331      CONTINUE
CT034*  TEST 34                                           4 ARGUMENTS
           IVTNUM = 34
        IIAVI = 10
        IIBVI = -4
        IICVI = 8
        IIDVI = 4
        IIAVI = MIN0(IIAVI, -IIBVI, IICVI, IIDVI)
           IF (IIAVI - 4) 20340, 10340, 20340
10340      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0341
20340      IVFAIL = IVFAIL + 1
           IVCORR = 4
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0341      CONTINUE
CT035*  TEST 35                                           5 ARGUMENTS
           IVTNUM = 35
        IIDVI = 4
        IIEVI = 5
        IIAVI = MIN0(IIDVI, -IIDVI, -IIEVI, +IIDVI, IIEVI)
           IF (IIAVI + 5) 20350, 10350, 20350
10350      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0351
20350      IVFAIL = IVFAIL + 1
           IVCORR = -5
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0351      CONTINUE
C*****
        WRITE (NUVI, 90002)
        WRITE (NUVI, 90013)
        WRITE (NUVI, 90014)
C*****    TEST OF MIN1
C*****
        WRITE(NUVI, 16707)
16707   FORMAT (/ 8X, 12HTEST OF MIN1)
CT036*  TEST 36                                      BOTH VALUES ZERO
           IVTNUM = 36
        RIBVS = 0.0
        RIDVS = 0.0
        IIAVI = MIN1(RIBVS, RIDVS)
           IF (IIAVI - 0) 20360, 10360, 20360
10360      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0361
20360      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0361      CONTINUE
CT037*  TEST 37                     FIRST VALUE NON-ZERO, SECOND ZERO
           IVTNUM = 37
        RIBVS = 5.625
        RIDVS = 0.0
        IIAVI = MIN1(RIBVS, RIDVS)
           IF (IIAVI - 0) 20370, 10370, 20370
10370      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0371
20370      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0371      CONTINUE
CT038*  TEST 38                                     BOTH VALUES EQUAL
           IVTNUM = 38
        RIBVS = 6.5
        RIDVS = 6.5
        IIAVI = MIN1(RIBVS, RIDVS)
           IF (IIAVI - 6) 20380, 10380, 20380
10380      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0381
20380      IVFAIL = IVFAIL + 1
           IVCORR = 6
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0381      CONTINUE
CT039*  TEST 39                                      VALUES NOT EQUAL
           IVTNUM = 39
        RIBVS = 7.125
        RIDVS = 5.125
        IIAVI = MIN1(RIBVS, RIDVS)
           IF (IIAVI - 5) 20390, 10390, 20390
10390      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0391
20390      IVFAIL = IVFAIL + 1
           IVCORR = 5
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0391      CONTINUE
CT040*  TEST 40                     FIRST VALUE NEGATIVE, SECOND ZERO
           IVTNUM = 40
        RIBVS = -5.625
        RIDVS = 0.0
        IIAVI = MIN1(RIBVS, RIDVS)
           IF (IIAVI + 5) 20400, 10400, 20400
10400      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0401
20400      IVFAIL = IVFAIL + 1
           IVCORR = -5
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0401      CONTINUE
CT041*  TEST 41                      BOTH VALUES EQUAL, BOTH NEGATIVE
           IVTNUM = 41
        RIBVS = -6.5
        RIDVS = -6.5
        IIAVI = MIN1(RIBVS, RIDVS)
           IF (IIAVI + 6) 20410, 10410, 20410
10410      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0411
20410      IVFAIL = IVFAIL + 1
           IVCORR = -6
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0411      CONTINUE
CT042*  TEST 42                       VALUES NOT EQUAL, BOTH NEGATIVE
           IVTNUM = 42
        RIBVS = -7.125
        RIDVS = -5.125
        IIAVI = MIN1(RIBVS, RIDVS)
           IF (IIAVI + 7) 20420, 10420, 20420
10420      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0421
20420      IVFAIL = IVFAIL + 1
           IVCORR = -7
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0421      CONTINUE
CT043*  TEST 43 FIRST VALUE NON-ZERO, 2ND ZERO PRECEDED BY MINUS SIGN
           IVTNUM = 43
        RIDVS = 5.625
        RIEVS = 0.0
        IIAVI = MIN1(RIDVS, -RIEVS)
           IF (IIAVI - 0) 20430, 10430, 20430
10430      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0431
20430      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0431      CONTINUE
CT044*  TEST 44                      EXPRESSION PRESENTED TO FUNCTION
           IVTNUM = 44
        RIDVS = 3.5
        RIEVS = 4.0
        IIAVI = MIN1(RIDVS + RIEVS, -RIEVS - RIDVS)
           IF (IIAVI + 7) 20440, 10440, 20440
10440      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0441
20440      IVFAIL = IVFAIL + 1
           IVCORR = -7
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0441      CONTINUE
CT045*  TEST 45                                           3 ARGUMENTS
           IVTNUM = 45
        RIBVS = 0.0
        RICVS = 1.0
        RIDVS = 2.0
        IIAVI = MIN1(RIBVS, RICVS, RIDVS)
           IF (IIAVI - 0) 20450, 10450, 20450
10450      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0451
20450      IVFAIL = IVFAIL + 1
           IVCORR = 0
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0451      CONTINUE
CT046*  TEST 46                                           4 ARGUMENTS
           IVTNUM = 46
        RIAVS = -3.5
        RIBVS = 12.0
        RICVS = 3.6
        RIDVS = 3.5
        IIAVI = MIN1(-RIAVS, RIBVS, RICVS, RIDVS)
           IF (IIAVI - 3) 20460, 10460, 20460
10460      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0461
20460      IVFAIL = IVFAIL + 1
           IVCORR = 3
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0461      CONTINUE
CT047*  TEST 47                                           5 ARGUMENTS
           IVTNUM = 47
        RIDVS = 3.5
        RIEVS = 4.5
        IIAVI = MIN1(RIDVS, -RIDVS, -RIEVS, +RIDVS, RIEVS)
           IF (IIAVI + 4) 20470, 10470, 20470
10470      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0471
20470      IVFAIL = IVFAIL + 1
           IVCORR = -4
           WRITE (NUVI, 80010) IVTNUM, IIAVI, IVCORR
 0471      CONTINUE
C*****
CBB** ********************** BBCSUM0  **********************************
C**** WRITE OUT TEST SUMMARY
C****
      IVTOTN = IVPASS + IVFAIL + IVDELE + IVINSP
      WRITE (I02, 90004)
      WRITE (I02, 90014)
      WRITE (I02, 90004)
      WRITE (I02, 90020) IVPASS
      WRITE (I02, 90022) IVFAIL
      WRITE (I02, 90024) IVDELE
      WRITE (I02, 90026) IVINSP
      WRITE (I02, 90028) IVTOTN, IVTOTL
CBE** ********************** BBCSUM0  **********************************
CBB** ********************** BBCFOOT0 **********************************
C**** WRITE OUT REPORT FOOTINGS
C****
      WRITE (I02,90016) ZPROG, ZPROG
      WRITE (I02,90018) ZPROJ, ZNAME, ZTAPE, ZTAPED
      WRITE (I02,90019)
CBE** ********************** BBCFOOT0 **********************************
CBB** ********************** BBCFMT0A **********************************
C**** FORMATS FOR TEST DETAIL LINES
C****
80000 FORMAT (1H ,2X,I3,4X,7HDELETED,32X,A31)
80002 FORMAT (1H ,2X,I3,4X,7H PASS  ,32X,A31)
80004 FORMAT (1H ,2X,I3,4X,7HINSPECT,32X,A31)
80008 FORMAT (1H ,2X,I3,4X,7H FAIL  ,32X,A31)
80010 FORMAT (1H ,2X,I3,4X,7H FAIL  ,/,1H ,15X,10HCOMPUTED= ,
     1I6,/,1H ,15X,10HCORRECT=  ,I6)
80012 FORMAT (1H ,2X,I3,4X,7H FAIL  ,/,1H ,16X,10HCOMPUTED= ,
     1E12.5,/,1H ,16X,10HCORRECT=  ,E12.5)
80018 FORMAT (1H ,2X,I3,4X,7H FAIL  ,/,1H ,16X,10HCOMPUTED= ,
     1A21,/,1H ,16X,10HCORRECT=  ,A21)
80020 FORMAT (1H ,16X,10HCOMPUTED= ,A21,1X,A31)
80022 FORMAT (1H ,16X,10HCORRECT=  ,A21,1X,A31)
80024 FORMAT (1H ,16X,10HCOMPUTED= ,I6,16X,A31)
80026 FORMAT (1H ,16X,10HCORRECT=  ,I6,16X,A31)
80028 FORMAT (1H ,16X,10HCOMPUTED= ,E12.5,10X,A31)
80030 FORMAT (1H ,16X,10HCORRECT=  ,E12.5,10X,A31)
80050 FORMAT (1H ,48X,A31)
CBE** ********************** BBCFMT0A **********************************
CBB** ********************** BBCFMT0B **********************************
C**** FORMAT STATEMENTS FOR PAGE HEADERS
C****
90002 FORMAT (1H1)
90004 FORMAT (1H )
90006 FORMAT (1H ,20X,31HFEDERAL SOFTWARE TESTING CENTER)
90007 FORMAT (1H ,19X,34HFORTRAN COMPILER VALIDATION SYSTEM)
90008 FORMAT (1H ,21X,A13,A17)
90009 FORMAT (1H ,/,2H *,A5,6HBEGIN*,12X,15HTEST RESULTS - ,A5,/)
90010 FORMAT (1H ,8X,16HTEST DATE*TIME= ,A17,15H  -  COMPILER= ,A20)
90013 FORMAT (1H ,8H TEST   ,10HPASS/FAIL ,6X,17HDISPLAYED RESULTS,
     1       7X,7HREMARKS,24X)
90014 FORMAT (1H ,46H----------------------------------------------,
     1        33H---------------------------------)
90015 FORMAT (1H ,48X,17HTHIS PROGRAM HAS ,I3,6H TESTS,/)
C****
C**** FORMAT STATEMENTS FOR REPORT FOOTINGS
C****
90016 FORMAT (1H ,/,2H *,A5,4HEND*,14X,14HEND OF TEST - ,A5,/)
90018 FORMAT (1H ,A13,13X,A20,7H   *   ,A10,1H/,
     1        A13)
90019 FORMAT (1H ,26HFOR OFFICIAL USE ONLY     ,35X,15HCOPYRIGHT  1982)
C****
C**** FORMAT STATEMENTS FOR RUN SUMMARY
C****
90020 FORMAT (1H ,21X,I5,13H TESTS PASSED)
90022 FORMAT (1H ,21X,I5,13H TESTS FAILED)
90024 FORMAT (1H ,21X,I5,14H TESTS DELETED)
90026 FORMAT (1H ,21X,I5,25H TESTS REQUIRE INSPECTION)
90028 FORMAT (1H ,21X,I5,4H OF ,I3,15H TESTS EXECUTED)
CBE** ********************** BBCFMT0B **********************************
C*****
C*****    END OF TEST SEGMENT 167
        STOP
        END

*END-OF,FM362
