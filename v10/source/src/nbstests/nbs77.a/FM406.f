*HEADER,FORTR,FM406
*FILES1,FORTR,FM406,X
C***********************************************************************
C*****  FORTRAN 77
C*****   FM406
C*****                       INTER2 - (391)
C*****
C***********************************************************************
C*****  TESTING OF INTERNAL FILES -                           SUBSET REF
C*****          USING WRITE                                     12.2.5
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
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 391
C*****
        LOGICAL AVB
        CHARACTER A4VK*4, A5VK*5, A10VK*10, A38VK*38
        CHARACTER CVCORR*38, AVCORR(8)*38
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
      IVTOTL = 12
      ZPROG = 'FM406'
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
C*****
C*****    HEADER FOR SEGMENT 391
C*****
        WRITE(NUVI,39100)
39100   FORMAT(1H ,/ 45H INTER2 - (391) INTERNAL FILES -- USING WRITE
     1          //21H SUBSET REF. - 12.2.5)
CBB** ********************** BBCHED0B **********************************
C**** WRITE DETAIL REPORT HEADERS
C****
      WRITE (I02,90004)
      WRITE (I02,90004)
      WRITE (I02,90013)
      WRITE (I02,90014)
      WRITE (I02,90015) IVTOTL
CBE** ********************** BBCHED0B **********************************
        WRITE (NUVI, 39199)
39199   FORMAT (1H ,48X,31HNOTE 1: OPTIONAL LEADING ZERO  /
     1          1H ,48X,31H   MAY BE BLANK FOR ABSOLUTE   /
     2          1H ,48X,31H   VALUE < 1                   /
     3          1H ,48X,31HNOTE 2: LEADING PLUS SIGN IS   /
     4          1H ,48X,31H   OPTIONAL                    /
     5          1H ,48X,31HNOTE 3: E EXPONENT MAY BE E+   /
     6          1H ,48X,31H   OR +0 BEFORE VALUE          )
CT001*  TEST 1                              CHARACTER VARIABLE, INTEGER
           IVTNUM = 1
        A10VK = 'XXXXXXXXXX'
        KVI = 3
        WRITE(A10VK,39101) KVI
39101   FORMAT(I2)
           IVCOMP = 0
           AVCORR(1) = ' 3        '
           AVCORR(2) = '+3        '
           DO 40011 I = 1, 2
           IF (A10VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40011, 10010, 40011
40011      CONTINUE
           GO TO 20010
10010      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0011
20010      IVFAIL = IVFAIL + 1
           CVCORR = ' 3        '
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A10VK
           WRITE (NUVI, 80022) CVCORR
 0011      CONTINUE
CT002*  TEST 2                                          REAL, FW.D
           IVTNUM = 2
        A10VK = 'XXXXXXXXXX'
        AVS = 2.1
        WRITE(A10VK,39103) AVS
39103   FORMAT(F3.1)
           IVCOMP = 0
           IF (A10VK.EQ.'2.1       ') IVCOMP = 1
           IF (IVCOMP - 1) 20020, 10020, 20020
10020      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0021
20020      IVFAIL = IVFAIL + 1
           CVCORR = '2.1       '
           WRITE (NUVI, 80018) IVTNUM, A10VK, CVCORR
 0021      CONTINUE
CT003*  TEST 3                                   CHECK FOR MISSING SIGN
           IVTNUM = 3
        A10VK = 'XXXXXXXXXX'
        AVS = -0.0001
        WRITE(A10VK,39104) AVS
39104   FORMAT(F4.1)
           IVCOMP = 0
           AVCORR(1) = ' 0.0      '
           AVCORR(2) = '  .0      '
           AVCORR(3) = '+0.0      '
           AVCORR(4) = ' +.0      '
           DO 40031 I = 1, 4
           IF (A10VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40031, 10030, 40031
40031      CONTINUE
           GO TO 20030
10030      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0031
20030      IVFAIL = IVFAIL + 1
           CVCORR = ' 0.0      '
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A10VK
           WRITE (NUVI, 80022) CVCORR
 0031      CONTINUE
CT004*  TEST 4                              CONVERSION ERROR
           IVTNUM = 4
        A10VK = 'XXXXXXXXXX'
        AVS = 231.75
        WRITE(A10VK,39105) AVS
39105   FORMAT(F4.2)
           IVCOMP = 0
           IF (A10VK.EQ.'****      ') IVCOMP = 1
           IF (IVCOMP - 1) 20040, 10040, 20040
10040      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0041
20040      IVFAIL = IVFAIL + 1
           CVCORR = '****      '
           WRITE (NUVI, 80018) IVTNUM, A10VK, CVCORR
 0041      CONTINUE
CT005*  TEST 5                                          REAL, EW.D
           IVTNUM = 5
        A10VK = 'XXXXXXXXXX'
        AVS = 23.45E2
        WRITE(A10VK,39106) AVS
39106   FORMAT(1X,E9.4)
           IVCOMP = 0
           AVCORR(1) = ' .2345E+04'
           AVCORR(2) = ' .2345+004'
           DO 40051 I = 1, 2
           IF (A10VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40051, 10050, 40051
40051      CONTINUE
           GO TO 20050
10050      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0051
20050      IVFAIL = IVFAIL + 1
           CVCORR = ' .2345E+04'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A10VK
           WRITE (NUVI, 80022) CVCORR
 0051      CONTINUE
CT006*  TEST 6                                          REAL, EW.DEN
           IVTNUM = 6
        A10VK = 'XXXXXXXXXX'
        WRITE(A10VK,39107) AVS
39107   FORMAT(1X,E8.4E1)
           IVCOMP = 0
           AVCORR(1) = ' .2345E+4 '
           AVCORR(2) = ' .2345+04 '
           DO 40061 I = 1, 2
           IF (A10VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40061, 10060, 40061
40061      CONTINUE
           GO TO 20060
10060      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0061
20060      IVFAIL = IVFAIL + 1
           CVCORR = ' .2345E+4 '
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A10VK
           WRITE (NUVI, 80022) CVCORR
 0061      CONTINUE
CT007*  TEST 7                                          LOGICAL
           IVTNUM = 7
        A10VK = 'XXXXXXXXXX'
        AVB = .TRUE.
        WRITE(A10VK,39108) AVB
39108   FORMAT(L6)
           IVCOMP = 0
           IF (A10VK.EQ.'     T    ') IVCOMP = 1
           IF (IVCOMP - 1) 20070, 10070, 20070
10070      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0071
20070      IVFAIL = IVFAIL + 1
           CVCORR = '     T    '
           WRITE (NUVI, 80018) IVTNUM, A10VK, CVCORR
 0071      CONTINUE
CT008*  TEST 8                                          CHARACTER, AW
           IVTNUM = 8
        A10VK = 'XXXXXXXXXX'
        A4VK = 'TEST'
        WRITE(A10VK,39109) A4VK
39109   FORMAT(A4)
           IVCOMP = 0
           IF (A10VK.EQ.'TEST      ') IVCOMP = 1
           IF (IVCOMP - 1) 20080, 10080, 20080
10080      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0081
20080      IVFAIL = IVFAIL + 1
           CVCORR = 'TEST      '
           WRITE (NUVI, 80018) IVTNUM, A10VK, CVCORR
 0081      CONTINUE
CT009*  TEST 9                                          BLANK RECORD
           IVTNUM = 9
         A10VK = 'XXXXXXXXXX'
         WRITE(A10VK,39110)
39110    FORMAT()
            IVCOMP = 0
            IF (A10VK.EQ.'          ') IVCOMP = 1
            IF (IVCOMP - 1) 20090, 10090, 20090
10090       IVPASS = IVPASS + 1
            WRITE (NUVI, 80002) IVTNUM
            GO TO 0091
20090       IVFAIL = IVFAIL + 1
            CVCORR = '          '
            WRITE (NUVI, 80018) IVTNUM, A10VK, CVCORR
 0091       CONTINUE
CT010*  TEST 10                                         MIXED TYPES
           IVTNUM = 10
        A38VK = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        KVI = 23
        AVS = 23.345
        AVB = .TRUE.
        A4VK = 'ENDS'
        WRITE(A38VK,39111) KVI, AVS, AVB, A4VK
39111   FORMAT(I5,1X,F8.3,1X,L5,1X,A4)
           IVCOMP = 0
           AVCORR(1) = '   23   23.345     T ENDS             '
           AVCORR(2) = '  +23  +23.345     T ENDS             '
           AVCORR(3) = '   23  +23.345     T ENDS             '
           AVCORR(4) = '  +23   23.345     T ENDS             '
           DO 40101 I = 1, 4
           IF (A38VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40101, 10100, 40101
40101      CONTINUE
           GO TO 20100
10100      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0101
20100      IVFAIL = IVFAIL + 1
           CVCORR = '   23   23.345     T ENDS             '
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A38VK
           WRITE (NUVI, 80022) CVCORR
 0101      CONTINUE
CT011*  TEST 11                                 MIXED TYPES, WITH
C*****                                  CHARACTER AND HOLLERITH STRINGS
           IVTNUM = 11
        A38VK = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        AVS = 23.456
        AVB = .FALSE.
        KVI = 98
        A5VK = 'YOURS'
        WRITE(A38VK,39112) AVS, AVB, KVI, A5VK
39112   FORMAT(F7.3,1X,L5,1X,I5,1X,A5,1X,'PROGRAMS',1X,3HONE)
           IVCOMP = 0
           AVCORR(1) = ' 23.456     F    98 YOURS PROGRAMS ONE'
           AVCORR(2) = '+23.456     F   +98 YOURS PROGRAMS ONE'
           AVCORR(3) = ' 23.456     F   +98 YOURS PROGRAMS ONE'
           AVCORR(4) = '+23.456     F    98 YOURS PROGRAMS ONE'
           DO 40111 I = 1, 4
           IF (A38VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40111, 10110, 40111
40111      CONTINUE
           GO TO 20110
10110      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0111
20110      IVFAIL = IVFAIL + 1
           CVCORR = ' 23.456     F    98 YOURS PROGRAMS ONE'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A38VK
           WRITE (NUVI, 80022) CVCORR
 0111      CONTINUE
CT012*  TEST 12                           MIXED TYPES, WITH EXPRESSION
           IVTNUM = 12
        A38VK = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        AVS = 5.2345
        BVS = 1.2345
        AVB = .TRUE.
        WRITE(A38VK,39113) AVS, 5, BVS*2, AVB, 'TWO'
39113   FORMAT(F9.4,1X,I4,1X,3HBVS,1X,F9.4,1X,L1,1X,A3)
           IVCOMP = 0
           AVCORR(1) = '   5.2345    5 BVS    2.4690 T TWO    '
           AVCORR(2) = '   5.2345    5 BVS   +2.4690 T TWO    '
           AVCORR(3) = '   5.2345   +5 BVS    2.4690 T TWO    '
           AVCORR(4) = '   5.2345   +5 BVS   +2.4690 T TWO    '
           AVCORR(5) = '  +5.2345    5 BVS    2.4690 T TWO    '
           AVCORR(6) = '  +5.2345    5 BVS   +2.4690 T TWO    '
           AVCORR(7) = '  +5.2345   +5 BVS    2.4690 T TWO    '
           AVCORR(8) = '  +5.2345   +5 BVS   +2.4690 T TWO    '
           DO 40121 I = 1, 8
           IF (A38VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40121, 10120, 40121
40121      CONTINUE
           GO TO 20120
10120      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0121
20120      IVFAIL = IVFAIL + 1
           CVCORR = '   5.2345    5 BVS    2.4690 T TWO    '
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A38VK
           WRITE (NUVI, 80022) CVCORR
 0121      CONTINUE
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
C*****    END OF TEST SEGMENT 391
      STOP
      END
*END-OF,FM406
