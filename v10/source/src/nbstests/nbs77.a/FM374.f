*HEADER,FORTR,FM374
*FILES1,FORTR,FM374,X
C***********************************************************************
C*****  FORTRAN 77
C*****   FM374
C*****                       XTAN - (191)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                      SUBSET REF
C*****    TEST INTRINSIC FUNCTION TAN                          15.3
C*****                                                        TABLE 5
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
      IVTOTL = 14
      ZPROG = 'FM374'
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
C*****    HEADER FOR SEGMENT 191
        WRITE(NUVI,19100)
19100   FORMAT(1H , / 34H  XTAN - (191) INTRINSIC FUNCTIONS//
     1         17H  TAN   (TANGENT)//
     2         20H  SUBSET REF. - 15.3)
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
        PIVS = 3.1415926535897932384626434
C*****
CT001*  TEST 1                             ZERO (0.0), SINCE TAN(0) = 0
           IVTNUM = 1
        BVS = 0.0
        AVS = TAN(BVS)
           IF (AVS + 0.00005) 20010, 10010, 40010
40010      IF (AVS - 0.00005) 10010, 10010, 20010
10010      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0011
20010      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0011      CONTINUE
CT002*  TEST 2                                                     2*PI
           IVTNUM = 2
        BVS = 6.2831853071
        AVS = TAN(BVS)
           IF (AVS + 0.00005) 20020, 10020, 40020
40020      IF (AVS - 0.00005) 10020, 10020, 20020
10020      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0021
20020      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0021      CONTINUE
CT003*  TEST 3                                                     3*PI
           IVTNUM = 3
        BVS = 9.424777960
        AVS = TAN(BVS)
           IF (AVS + 0.00005) 20030, 10030, 40030
40030      IF (AVS - 0.00005) 10030, 10030, 20030
10030      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0031
20030      IVFAIL = IVFAIL + 1
           RVCORR = 0.0
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0031      CONTINUE
CT004*  TEST 4                                                     PI/4
           IVTNUM = 4
        AVS = TAN(PIVS / 4.0)
           IF (AVS - 0.99995) 20040, 10040, 40040
40040      IF (AVS - 1.0001) 10040, 10040, 20040
10040      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0041
20040      IVFAIL = IVFAIL + 1
           RVCORR = 1.0
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0041      CONTINUE
CT005*  TEST 5                                                   5*PI/4
           IVTNUM = 5
        BVS = 5.0 * PIVS / 4.0
        AVS = TAN(BVS)
           IF (AVS - 0.99995) 20050, 10050, 40050
40050      IF (AVS - 1.0001) 10050, 10050, 20050
10050      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0051
20050      IVFAIL = IVFAIL + 1
           RVCORR = 1.0
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0051      CONTINUE
CT006*  TEST 6                                         A NEGATIVE VALUE
           IVTNUM = 6
        BVS = -2.0 / 1.0
        AVS = TAN(BVS)
           IF (AVS - 2.1849) 20060, 10060, 40060
40060      IF (AVS - 2.1852) 10060, 10060, 20060
10060      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0061
20060      IVFAIL = IVFAIL + 1
           RVCORR = 2.18503986326151
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0061      CONTINUE
CT007*  TEST 7                                         A POSITIVE VALUE
           IVTNUM = 7
        BVS = 350.0 / 100.0
        AVS = TAN(BVS)
           IF (AVS - 0.37456) 20070, 10070, 40070
40070      IF (AVS - 0.37461) 10070, 10070, 20070
10070      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0071
20070      IVFAIL = IVFAIL + 1
           RVCORR = 0.37458564015859
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0071      CONTINUE
CT008*  TEST 8                                           (PI / 2) - 1/8
           IVTNUM = 8
        BVS = 1.4457963267
        AVS = TAN(BVS)
           IF (AVS - 7.9578) 20080, 10080, 40080
40080      IF (AVS - 7.9587) 10080, 10080, 20080
10080      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0081
20080      IVFAIL = IVFAIL + 1
           RVCORR = 7.95828986586701
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0081      CONTINUE
CT009*  TEST 9                                         (PI / 2) + 1/256
           IVTNUM = 9
        BVS = 1.5747025767
        AVS = TAN(BVS)
           IF (AVS + 256.02) 20090, 10090, 40090
40090      IF (AVS + 255.98) 10090, 10090, 20090
10090      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0091
20090      IVFAIL = IVFAIL + 1
           RVCORR = -255.99869791534212
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0091      CONTINUE
CT010*  TEST 10                                         3*PI/2 - 1/1024
           IVTNUM = 10
        AVS = TAN((3.0 * PIVS / 2.0) - 1.0 / 1024.0)
           IF (AVS - 1023.9) 20100, 10100, 40100
40100      IF (AVS - 1024.1) 10100, 10100, 20100
10100      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0101
20100      IVFAIL = IVFAIL + 1
           RVCORR = 1023.99967447914597
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0101      CONTINUE
CT011*  TEST 11                                           3*PI/2 + 1/64
           IVTNUM = 11
        BVS = (3.0 * PIVS / 2.0) + 1.0 / 64.0
        AVS = TAN(BVS)
           IF (AVS + 63.998) 20110, 10110, 40110
40110      IF (AVS + 63.991) 10110, 10110, 20110
10110      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0111
20110      IVFAIL = IVFAIL + 1
           RVCORR = -63.99479158189365
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0111      CONTINUE
CT012*  TEST 12               LARGE ARGUMENT TO TEST ARGUMENT REDUCTION
           IVTNUM = 12
        AVS = TAN(2000.0)
           IF (AVS + 2.5312) 20120, 10120, 40120
40120      IF (AVS + 2.5308) 10120, 10120, 20120
10120      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0121
20120      IVFAIL = IVFAIL + 1
           RVCORR = -2.53099832809334
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0121      CONTINUE
CT013*  TEST 13                               ARGUMENT OF LOW MAGNITUDE
           IVTNUM = 13
        BVS = PIVS * 1.0E-35
        AVS = TAN(BVS)
           IF (AVS - 3.1414E-35) 20130, 10130, 40130
40130      IF (AVS - 3.1418E-35) 10130, 10130, 20130
10130      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0131
20130      IVFAIL = IVFAIL + 1
           RVCORR = 3.14159265358979E-35
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0131      CONTINUE
CT014*  TEST 14                              THE FUNCTION APPLIED TWICE
           IVTNUM = 14
        AVS = TAN(PIVS / 6.0) * TAN(PIVS / 6.0)
           IF (AVS - 0.33331) 20140, 10140, 40140
40140      IF (AVS - 0.33335) 10140, 10140, 20140
10140      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0141
20140      IVFAIL = IVFAIL + 1
           RVCORR = 0.33333333333333
           WRITE (NUVI, 80012) IVTNUM, AVS, RVCORR
 0141      CONTINUE
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
C*****    END OF TEST SEGMENT 191
      STOP
      END

*END-OF,FM374
