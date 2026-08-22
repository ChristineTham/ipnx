*HEADER,FORTR,FM829
*FILES1,FORTR,FM829,X
C***********************************************************************
C*****  FORTRAN 77
C*****   FM829
C*****                       YGEN1 - (206)
C*****
C***********************************************************************
C*****  TESTING OF GENERIC FUNCTIONS                            ANS REF
C*****          INT, REAL, DBLE, CMPLX                           15.3
C*****                                                          TABLE 5
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
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 206
        DOUBLE PRECISION AVD, BVD, CVD, DVCORR
        COMPLEX AVC, BVC, CVC, ZVCORR
        REAL R2E(2)
        EQUIVALENCE (BVC, R2E)
C*****
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
      IVTOTL = 35
      ZPROG = 'FM829'
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
C*****    HEADER FOR SEGMENT 206
        WRITE(NUVI,20600)
20600   FORMAT( 1H , /  35H YGEN1 - (206) GENERIC FUNCTIONS --//
     1          24H  INT, REAL, DBLE, CMPLX//
     2          17H  ANS REF. - 15.3)
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
CT001*  TEST 1                          TEST OF INT
C*****                                          WITH INTEGER ARG
           IVTNUM = 1
        LVI = INT(485)
           IF (LVI -   485) 20010, 10010, 20010
10010      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0011
20010      IVFAIL = IVFAIL + 1
           IVCORR =   485
           WRITE (NUVI, 80010) IVTNUM, LVI, IVCORR
 0011      CONTINUE
CT002*  TEST 2                                  WITH DOUBLE PREC ARG
           IVTNUM = 2
        LVI = INT(1.375D0)
           IF (LVI -     1) 20020, 10020, 20020
10020      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0021
20020      IVFAIL = IVFAIL + 1
           IVCORR =     1
           WRITE (NUVI, 80010) IVTNUM, LVI, IVCORR
 0021      CONTINUE
CT003*  TEST 3                                  WITH COMPLEX ARG
           IVTNUM = 3
        LVI = INT((1.24, 5.67))
           IF (LVI -     1) 20030, 10030, 20030
10030      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0031
20030      IVFAIL = IVFAIL + 1
           IVCORR =     1
           WRITE (NUVI, 80010) IVTNUM, LVI, IVCORR
 0031      CONTINUE
CT004*  TEST 4                          TEST OF INT AND IFIX
C*****                                          WITH REAL ARGS
           IVTNUM = 4
        LVI = INT(6.0001) + IFIX(-1.750)
           IF (LVI -     5) 20040, 10040, 20040
10040      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0041
20040      IVFAIL = IVFAIL + 1
           IVCORR =     5
           WRITE (NUVI, 80010) IVTNUM, LVI, IVCORR
 0041      CONTINUE
CT005*  TEST 5                          TEST OF INT AND IDINT
C*****                                          WITH DOUBLE PREC ARGS
           IVTNUM = 5
        AVD = -1.11D1
        LVI = INT(AVD) * IDINT(3.5D0)
           IF (LVI +    33) 20050, 10050, 20050
10050      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0051
20050      IVFAIL = IVFAIL + 1
           IVCORR =   -33
           WRITE (NUVI, 80010) IVTNUM, LVI, IVCORR
 0051      CONTINUE
CT006*  TEST 6             INTEGER, REAL, DOUBLE PRECISION, AND COMPLEX
C*****                                                        ARGUMENTS
           IVTNUM = 6
        LVI = INT(-327) + INT(6.75) * INT(123) - INT(6.0001D0)
     1        / IFIX(13.3) + INT((2.4, 3.5)) + IDINT(-3.375D0)
           IF (LVI -   410) 20060, 10060, 20060
10060      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0061
20060      IVFAIL = IVFAIL + 1
           IVCORR =   410
           WRITE (NUVI, 80010) IVTNUM, LVI, IVCORR
 0061      CONTINUE
CT007*  TEST 7                          TEST OF REAL
C*****                                          WITH REAL ARG
           IVTNUM = 7
        AVS = -3.0
        BVS = REAL(AVS)
           IF (BVS +  0.30002E+01) 20070, 10070, 40070
40070      IF (BVS +  0.29998E+01) 10070, 10070, 20070
10070      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0071
20070      IVFAIL = IVFAIL + 1
           RVCORR = -3.0
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0071      CONTINUE
CT008*  TEST 8                                  WITH DOUBLE PRECISION
           IVTNUM = 8
        AVD = 0.96875D0
        BVS = REAL(AVD)
           IF (BVS -  0.96870E+00) 20080, 10080, 40080
40080      IF (BVS -  0.96880E+00) 10080, 10080, 20080
10080      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0081
20080      IVFAIL = IVFAIL + 1
           RVCORR = 0.96875
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0081      CONTINUE
CT009*  TEST 9                                  WITH COMPLEX
           IVTNUM = 9
        BVS = REAL((2.5, -3.0))
           IF (BVS -  0.24998E+01) 20090, 10090, 40090
40090      IF (BVS -  0.25002E+01) 10090, 10090, 20090
10090      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0091
20090      IVFAIL = IVFAIL + 1
           RVCORR = 2.5
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0091      CONTINUE
CT010*  TEST 10                         TEST OF REAL AND FLOAT
           IVTNUM = 10
        BVS = REAL(6) + FLOAT(8)
           IF (BVS -  0.13999E+02) 20100, 10100, 40100
40100      IF (BVS -  0.14001E+02) 10100, 10100, 20100
10100      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0101
20100      IVFAIL = IVFAIL + 1
           RVCORR = 14.0
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0101      CONTINUE
CT011*  TEST 11                         TEST OF REAL AND SNGL
           IVTNUM = 11
        AVD = 2.5D0
        BVS = REAL(AVD) + SNGL(0.35875D2)
           IF (BVS -  0.38373E+02) 20110, 10110, 40110
40110      IF (BVS -  0.38377E+02) 10110, 10110, 20110
10110      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0111
20110      IVFAIL = IVFAIL + 1
           RVCORR = 38.375
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0111      CONTINUE
CT012*  TEST 12                         TEST OF REAL, FLOAT, AND SNGL
           IVTNUM = 12
        BVS = REAL(13) + FLOAT(9) * SNGL(0.7625D1) - REAL(2.625D0) +
     1          REAL(3.5) / REAL((2.0, 4.0))
           IF (BVS -  0.80746E+02) 20120, 10120, 40120
40120      IF (BVS -  0.80754E+02) 10120, 10120, 20120
10120      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0121
20120      IVFAIL = IVFAIL + 1
           RVCORR = 80.75
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0121      CONTINUE
CT013*  TEST 13                         TEST OF DBLE
C*****                                          WITH INTEGER ARG
           IVTNUM = 13
        LVI = 9
        BVD = DBLE(LVI)
           IF (BVD -  0.89995D+01) 20130, 10130, 40130
40130      IF (BVD -  0.90005D+01) 10130, 10130, 20130
10130      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0131
20130      IVFAIL = IVFAIL + 1
           DVCORR = 9.0D0
           WRITE (NUVI, 80031) IVTNUM, BVD, DVCORR
 0131      CONTINUE
CT014*  TEST 14                                 WITH REAL ARG
           IVTNUM = 14
        AVS = 10.5
        BVD = DBLE(AVS)
           IF (BVD -  0.10499D+02) 20140, 10140, 40140
40140      IF (BVD -  0.10501D+02) 10140, 10140, 20140
10140      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0141
20140      IVFAIL = IVFAIL + 1
           DVCORR = 10.5D0
           WRITE (NUVI, 80031) IVTNUM, BVD, DVCORR
 0141      CONTINUE
CT015*  TEST 15                                 WITH DOUBLE PREC ARG
           IVTNUM = 15
        AVD = 9.9D0
        BVD = DBLE(AVD)
           IF (BVD -  0.9899999995D+01) 20150, 10150, 40150
40150      IF (BVD -  0.9900000005D+01) 10150, 10150, 20150
10150      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0151
20150      IVFAIL = IVFAIL + 1
           DVCORR = 9.9D0
           WRITE (NUVI, 80031) IVTNUM, BVD, DVCORR
 0151      CONTINUE
CT016*  TEST 16                                 WITH COMPLEX ARG
           IVTNUM = 16
        AVC = (2.5, 5.5)
        BVD = DBLE(AVC)
           IF (BVD -  0.24998D+01) 20160, 10160, 40160
40160      IF (BVD -  0.25002D+01) 10160, 10160, 20160
10160      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0161
20160      IVFAIL = IVFAIL + 1
           DVCORR = 2.5D0
           WRITE (NUVI, 80031) IVTNUM, BVD, DVCORR
 0161      CONTINUE
CT017*  TEST 17                         TEST OF CMPLX WITH ONE ARG
C*****                                          WITH INTEGER ARG
           IVTNUM = 17
        BVC = CMPLX(9)
           IF (R2E(1) -  0.89995E+01) 20170, 40172, 40171
40171      IF (R2E(1) -  0.90005E+01) 40172, 40172, 20170
40172      IF (R2E(2) +  0.50000E-04) 20170, 10170, 40170
40170      IF (R2E(2) -  0.50000E-04) 10170, 10170, 20170
10170      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0171
20170      IVFAIL = IVFAIL + 1
           ZVCORR = (9,0)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0171      CONTINUE
CT018*  TEST 18                                 WITH REAL
           IVTNUM = 18
        BVC = CMPLX(4.093)
           IF (R2E(1) -  0.40928E+01) 20180, 40182, 40181
40181      IF (R2E(1) -  0.40932E+01) 40182, 40182, 20180
40182      IF (R2E(2) +  0.50000E-04) 20180, 10180, 40180
40180      IF (R2E(2) -  0.50000E-04) 10180, 10180, 20180
10180      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0181
20180      IVFAIL = IVFAIL + 1
           ZVCORR = (4.093,0.0)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0181      CONTINUE
CT019*  TEST 19                                 WITH DOUBLE PREC ARG
           IVTNUM = 19
        AVD = 0.375D-3
        BVC = CMPLX(AVD)
           IF (R2E(1) -  0.37498E-03) 20190, 40192, 40191
40191      IF (R2E(1) -  0.37502E-03) 40192, 40192, 20190
40192      IF (R2E(2) +  0.50000E-04) 20190, 10190, 40190
40190      IF (R2E(2) -  0.50000E-04) 10190, 10190, 20190
10190      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0191
20190      IVFAIL = IVFAIL + 1
           ZVCORR = (0.375E-3, 0.0E0)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0191      CONTINUE
CT020*  TEST 20                                 WITH COMPLEX
           IVTNUM = 20
        AVC = (4.5, 1.2)
        BVC = CMPLX(AVC)
           IF (R2E(1) -  0.44997E+01) 20200, 40202, 40201
40201      IF (R2E(1) -  0.45003E+01) 40202, 40202, 20200
40202      IF (R2E(2) -  0.11999E+01) 20200, 10200, 40200
40200      IF (R2E(2) -  0.12001E+01) 10200, 10200, 20200
10200      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0201
20200      IVFAIL = IVFAIL + 1
           ZVCORR = (4.5, 1.2)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0201      CONTINUE
CT021*  TEST 21                         TEST OF CMPLX WITH TWO ARGS
C*****                                          WITH INTEGER ARGS
           IVTNUM = 21
        BVC = CMPLX(3, 1)
           IF (R2E(1) -  0.29998E+01) 20210, 40212, 40211
40211      IF (R2E(1) -  0.30002E+01) 40212, 40212, 20210
40212      IF (R2E(2) -  0.99995E+00) 20210, 10210, 40210
40210      IF (R2E(2) -  0.10001E+01) 10210, 10210, 20210
10210      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0211
20210      IVFAIL = IVFAIL + 1
           ZVCORR = (3.0, 1.0)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0211      CONTINUE
CT022*  TEST 22                                 WITH REAL ARGS
           IVTNUM = 22
        BVC = CMPLX(8.34, 634.3)
           IF (R2E(1) -  0.83395E+01) 20220, 40222, 40221
40221      IF (R2E(1) -  0.83405E+01) 40222, 40222, 20220
40222      IF (R2E(2) -  0.63426E+03) 20220, 10220, 40220
40220      IF (R2E(2) -  0.63434E+03) 10220, 10220, 20220
10220      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0221
20220      IVFAIL = IVFAIL + 1
           ZVCORR = (8.34, 634.3)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0221      CONTINUE
CT023*  TEST 23                                 WITH DOUBLE PREC ARGS
           IVTNUM = 23
        AVD = 0.96875D0
        BVD = 3.5D-1
        BVC = CMPLX(AVD, BVD)
           IF (R2E(1) -  0.96870E+00) 20230, 40232, 40231
40231      IF (R2E(1) -  0.96880E+00) 40232, 40232, 20230
40232      IF (R2E(2) -  0.34998E+00) 20230, 10230, 40230
40230      IF (R2E(2) -  0.35002E+00) 10230, 10230, 20230
10230      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0231
20230      IVFAIL = IVFAIL + 1
           ZVCORR = (0.96875, 0.35)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0231      CONTINUE
CT024*  TEST 24                         TEST OF INT AND =
C*****                                          WITH REAL EXPR
           IVTNUM = 24
        CVS = 0.0
        CVD = 0.0D0
        CVC = (0.0,0.0)
        LVI = 0
        AVS = 5.0
        IVI = 1.0 * 5.0 + 6.0
        KVI = LVI + INT(1.0 * AVS + 6.0)
           IF (KVI -    11) 20240, 10240, 20240
10240      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0241
20240      IVFAIL = IVFAIL + 1
           IVCORR =    11
           WRITE (NUVI, 80010) IVTNUM, KVI, IVCORR
 0241      CONTINUE
CT025*  TEST 25                                 WITH DOUBLE PREC EXPR
           IVTNUM = 25
        AVD = 3.48D0
        IVI = 3.48D0 * 47.98D0
        KVI = LVI + INT(AVD * 47.98D0)
           IF (KVI -   166) 20250, 10250, 20250
10250      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0251
20250      IVFAIL = IVFAIL + 1
           IVCORR =   166
           WRITE (NUVI, 80010) IVTNUM, KVI, IVCORR
 0251      CONTINUE
CT026*  TEST 26                                 WITH COMPLEX EXPR
           IVTNUM = 26
        AVC = (3.9, 5.0)
        IVI = (3.4, 4.5) + (3.9, 5.0)
        KVI = LVI + INT((3.4, 4.5) + AVC)
           IF (KVI -     7) 20260, 10260, 20260
10260      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0261
20260      IVFAIL = IVFAIL + 1
           IVCORR =     7
           WRITE (NUVI, 80010) IVTNUM, KVI, IVCORR
 0261      CONTINUE
CT027*  TEST 27                         TEST OF REAL AND =
C*****                                          WITH INT EXPR
           IVTNUM = 27
        IVI = 20
        AVS = 20 + 34 / 20
        BVS = CVS + REAL(IVI + 34 / IVI)
           IF (BVS -  0.20999E+02) 20270, 10270, 40270
40270      IF (BVS -  0.21001E+02) 10270, 10270, 20270
10270      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0271
20270      IVFAIL = IVFAIL + 1
           RVCORR = 21.0
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0271      CONTINUE
CT028*  TEST 28                                 WITH DOUBLE PREC EXPR
           IVTNUM = 28
        JVI = 28
        AVD = 0.9834D0
        AVS = 3.0748D0 / 0.9834D0
        BVS = CVS + REAL(3.0748D0 / AVD)
           IF (BVS -  0.31265E+01) 20280, 10280, 40280
40280      IF (BVS -  0.31269E+01) 10280, 10280, 20280
10280      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0281
20280      IVFAIL = IVFAIL + 1
           RVCORR = 3.1267033
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0281      CONTINUE
CT029*  TEST 29                                 WITH COMPLEX
           IVTNUM = 29
        JVI = 29
        AVC = (1.0, 384.9)
        AVS = (3.495, 98.734) * (1.0, 384.9)
        BVS = CVS + REAL((3.495, 98.734) * AVC)
           IF (BVS +  0.38001E+05) 20290, 10290, 40290
40290      IF (BVS +  0.37997E+05) 10290, 10290, 20290
10290      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0291
20290      IVFAIL = IVFAIL + 1
           RVCORR = -37999.222
           WRITE (NUVI, 80012) IVTNUM, BVS, RVCORR
 0291      CONTINUE
CT030*  TEST 30                         TEST OF DBLE AND =
C*****                                          WITH INTEGER EXPR
           IVTNUM = 30
        JVI = 30
        IVI = 5
        AVD = 1 * 5 + 6
        BVD = CVD + DBLE(1 * IVI + 6)
           IF (BVD -  0.10999D+02) 20300, 10300, 40300
40300      IF (BVD -  0.11001D+02) 10300, 10300, 20300
10300      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0301
20300      IVFAIL = IVFAIL + 1
           DVCORR = .11000000D+02
           WRITE (NUVI, 80031) IVTNUM, BVD, DVCORR
 0301      CONTINUE
CT031*  TEST 31                                 WITH REAL EXPR
           IVTNUM = 31
        JVI = 31
        AVS = -4.5
        AVD = 1.3 / (-4.5)
        BVD = CVD + DBLE(1.3 / AVS)
           IF (BVD +  0.28891D+00) 20310, 10310, 40310
40310      IF (BVD +  0.28887D+00) 10310, 10310, 20310
10310      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0311
20310      IVFAIL = IVFAIL + 1
           DVCORR = -0.288888888888888889D+00
           WRITE (NUVI, 80031) IVTNUM, BVD, DVCORR
 0311      CONTINUE
CT032*  TEST 32                                 WITH COMPLEX EXPR
           IVTNUM = 32
        JVI = 32
        AVC = (3.9, 5.0)
        AVD = (3.4, 4.5) + (3.9, 5.0)
        BVD = CVD + DBLE((3.4, 4.5) + AVC)
           IF (BVD -  0.72996D+01) 20320, 10320, 40320
40320      IF (BVD -  0.73004D+01) 10320, 10320, 20320
10320      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0321
20320      IVFAIL = IVFAIL + 1
           DVCORR = .73000000D+01
           WRITE (NUVI, 80031) IVTNUM, BVD, DVCORR
 0321      CONTINUE
CT033*  TEST 33                         TEST OF CMPLX AND =
C*****                                          WITH INTEGER EXPR
           IVTNUM = 33
        JVI = 33
        IVI = 673
        AVC = 394 - 673
        BVC = CVC + CMPLX(394 - IVI)
           IF (R2E(1) +  0.27902E+03) 20330, 40332, 40331
40331      IF (R2E(1) +  0.27898E+03) 40332, 40332, 20330
40332      IF (R2E(2) +  0.50000E-04) 20330, 10330, 40330
40330      IF (R2E(2) -  0.50000E-04) 10330, 10330, 20330
10330      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0331
20330      IVFAIL = IVFAIL + 1
           ZVCORR = (-279.00000, .00000000)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0331      CONTINUE
CT034*  TEST 34                                 WITH REAL EXPR
           IVTNUM = 34
        JVI = 34
        AVS = 3.48
        AVC = 3.48 * 47.98
        BVC = CVC + CMPLX(AVS * 47.98)
           IF (R2E(1) -  0.16696E+03) 20340, 40342, 40341
40341      IF (R2E(1) -  0.16698E+03) 40342, 40342, 20340
40342      IF (R2E(2) +  0.50000E-04) 20340, 10340, 40340
40340      IF (R2E(2) -  0.50000E-04) 10340, 10340, 20340
10340      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0341
20340      IVFAIL = IVFAIL + 1
           ZVCORR = (166.97040, .00000000)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0341      CONTINUE
CT035*  TEST 35
           IVTNUM = 35
        JVI = 35
        AVD = 0.94D1
        AVC = 3.0283D3 / 0.94D1
        BVC = CVC + CMPLX(3.0283D3 / AVD)
           IF (R2E(1) -  0.32214E+03) 20350, 40352, 40351
40351      IF (R2E(1) -  0.32218E+03) 40352, 40352, 20350
40352      IF (R2E(2) +  0.50000E-04) 20350, 10350, 40350
40350      IF (R2E(2) -  0.50000E-04) 10350, 10350, 20350
10350      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0351
20350      IVFAIL = IVFAIL + 1
           ZVCORR = (322.15957, .000000000)
           WRITE (NUVI, 80045) IVTNUM, BVC, ZVCORR
 0351      CONTINUE
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
CBB** ********************** BBCFMAT1 **********************************
C**** FORMATS FOR TEST DETAIL LINES - FULL LANGUAGE
C****
80031 FORMAT (1H ,2X,I3,4X,7H FAIL  ,/,1H ,16X,10HCOMPUTED= ,
     1D17.10,/,1H ,16X,10HCORRECT=  ,D17.10)
80033 FORMAT (1H ,16X,10HCOMPUTED= ,D17.10,10X,A31)
80035 FORMAT (1H ,16X,10HCORRECT=  ,D17.10,10X,A31)
80037 FORMAT (1H ,16X,10HCOMPUTED= ,1H(,E12.5,2H, ,E12.5,1H),6X,A31)
80039 FORMAT (1H ,16X,10HCORRECT=  ,1H(,E12.5,2H, ,E12.5,1H),6X,A31)
80041 FORMAT (1H ,16X,10HCOMPUTED= ,1H(,F12.5,2H, ,F12.5,1H),6X,A31)
80043 FORMAT (1H ,16X,10HCORRECT=  ,1H(,F12.5,2H, ,F12.5,1H),6X,A31)
80045 FORMAT (1H ,2X,I3,4X,7H FAIL  ,/,1H ,16X,10HCOMPUTED= ,
     11H(,F12.5,2H, ,F12.5,1H)/,1H ,16X,10HCORRECT=  ,
     21H(,F12.5,2H, ,F12.5,1H))
CBE** ********************** BBCFMAT1 **********************************
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
C*****    END OF TEST SEGMENT 206
      STOP
      END
*END-OF,FM829
