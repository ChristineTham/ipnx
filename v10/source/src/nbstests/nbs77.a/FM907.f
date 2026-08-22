*HEADER,FORTR,FM907
*FILES1,FORTR,FM907,X
C***********************************************************************
C*****  FORTRAN 77
C*****   FM907
C*****                       LSTDO2 - (373)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                         ANS REF
C*****    TEST LIST DIRECTED OUTPUT                             13.6
C*****    DOUBLE PRECISION AND COMPLEX DATA TYPES INCLUDED      12.4
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
C*****  S P E C I F I C A T I O N S  SEGMENT 373
        DOUBLE PRECISION AVD, BVD, CVD
        COMPLEX AVC, BVC, CVC, DVC
        CHARACTER A4VK*4
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
      IVTOTL = 8
      ZPROG = 'FM907'
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
C*****  HEADING FOR SEGMENT 373
        WRITE(NUVI,37300)
37300   FORMAT(1H , /16H LSTDO2 - (373) ,
     1         21H LIST DIRECTED OUTPUT,
     2         32H FOR D.P. AND COMPLEX DATA TYPES//
     3         22H ANS REF. - 13.6  12.4)
CBB** ********************** BBCHED0B **********************************
C**** WRITE DETAIL REPORT HEADERS
C****
      WRITE (I02,90004)
      WRITE (I02,90004)
      WRITE (I02,90013)
      WRITE (I02,90014)
      WRITE (I02,90015) IVTOTL
CBE** ********************** BBCHED0B **********************************
           WRITE (NUVI, 70000)
70000      FORMAT (1H ,48X,31HTHE CORRECT LINE OF EACH TEST  /
     1             1H ,48X,31HIS HOLLERITH INFORMATION.      /
     2             1H ,48X,31HCOLUMN SPACING,  LINE BREAKS,  /
     3             1H ,48X,31HAND THE NUMBER OF DECIMAL      /
     4             1H ,48X,31HPLACES FOR DOUBLE PRECISION    /
     5             1H ,48X,31HOR COMPLEX NUMBERS ARE         /
     6             1H ,48X,31HPROCESSOR DEPENDENT.           /
     7             1H ,48X,31HEITHER E OR F FORMAT MAY BE    /
     8             1H ,48X,31HUSED FOR DOUBLE PRECISION OR   /
     9             1H ,48X,31HCOMPLEX NUMBERS.               /)
CT001*  TEST 1 - DOUBLE PRECISION
           IVTNUM = 1
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        AVD = 2.5D0
        WRITE(NUVI, *) AVD
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70011)
70011      FORMAT (1H ,6X,3H2.5)
CT002*  TEST 2 - COMPLEX
           IVTNUM = 2
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        AVC = (3.0, 4.0)
        WRITE(NUVI, *) AVC
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70021)
70021      FORMAT(1H ,6X,10H (3.0,4.0))
CT003*  TEST 3 - SEVERAL DOUBLE PRECISION
           IVTNUM = 3
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        AVD = 2.5D0
        BVD = 2.5D-10
        CVD = 2.5D+10
        WRITE(NUVI, *) AVD, BVD, CVD
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70031)
70031      FORMAT(1H ,6X,21H2.5  2.5D-10  2.5D+10)
CT004*  TEST 4 - SEVERAL COMPLEX
           IVTNUM = 4
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        AVC = (0.0, 1.0)
        BVC = (8.0, 10.0)
        CVC = (-5.0, 0.0)
        DVC = (0.0, 0.0)
        WRITE(NUVI,*) AVC, BVC, CVC, DVC
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70041)
70041      FORMAT(1H ,6X,48H (0.0,1.0)   (8.0,10.0)   (-5.0,0.0)   (0.0,
     10.0))
CT005*  TEST 5 - MIXED LIST
           IVTNUM = 5
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        AVC = (3.0, 4.0)
        BVC = (-3.0, -4.0)
        AVD = 5.0D0
        BVD = -5.0D0
        WRITE(NUVI,*) AVC, AVD, BVD, BVC
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70051)
70051      FORMAT(1H ,6X,35H (3.0,4.0)  5.0  -5.0   (-3.0,-4.0))
CT006*  TEST 6 - MIXED MODE EXPRESSION
           IVTNUM = 6
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        AVC = (2.0, 3.0)
        IVI = 3
        WRITE(NUVI, *) AVC * IVI
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70061)
70061      FORMAT(1H ,6X,10H (6.0,9.0))
CT007*  TEST 7 - MIXED MODE EXPRESSION
           IVTNUM = 7
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        IVI = 2
        AVS = 6.5
        WRITE(NUVI, *) AVS / IVI
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70071)
70071      FORMAT(1H ,6X,4H3.25)
CT008*  TEST 8 - MIXED LIST
           IVTNUM = 8
           WRITE (NUVI, 80004) IVTNUM
           WRITE (NUVI, 80020)
        A4VK = 'GOOD'
        AVS = 2.5
        AVC = (4, -6)
        WRITE(NUVI, *) AVC / 2, .TRUE., AVS ** 3, A4VK // 'BYE',
     1  ' FOR NOW'
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80022)
           WRITE (NUVI, 70081)
70081      FORMAT(1H ,6X,40H (2.0,-3.0)  T  15.625  GOODBYE  FOR NOW)
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
C*****    END OF TEST SEGMENT 373
        STOP
        END
*END-OF,FM907
