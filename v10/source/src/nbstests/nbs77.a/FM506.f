*HEADER,FORTR,FM506
*FILES1,FORTR,FM506
C***********************************************************************
C*****  FORTRAN 77
C*****   FM506
C*****                       BLKD3 - (262)
C*****   USES BLOCK DATA SUBPROGRAM AN507 AND SUBROUTINE SN508
C***********************************************************************
C*****  TESTING OF BLOCK DATA SUBPROGRAMS                       ANS REF
C*****          VARYING CHARACTER VARIABLE LENGTHS                16
C*****  THIS SEGMENT USES SEGMENTS 704 AND 705, BLOCK DATA PROGRAM
C*****  AN507 AND SUBROUTINE SN508
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
C*****  S P E C I F I C A T I O N S  SEGMENT 262
C*****
C*****  CHARACTER*3 C3XVK, F3XVK
C*****  CHARACTER*2 D2XVK
C*****  CHARACTER*5 E5XVK
C*****  COMMON /BLK8/ C3XVK, D2XVK, E5XVK, F3XVK
C*****
      NUVI = 4
C*****
        CALL SN508(NUVI)
C*****
C*****          END OF TEST SEGMENT 262
        STOP
        END
*HEADER,FORTR,FM506,SUBRTN,FM507
C***********************************************************************
C***** FORTRAN 77
C*****   FM507                  BDS3 - (704)
C*****     BLOCK DATA SUBPROGRAM AN507 USED BY FM506
C***********************************************************************
C*****
C***** GENERAL PURPOSE
C*****          THIS SEGMENT CONTAINS A BLOCK DATA SUBPROGRAM THAT IS
C*****  TO BE RUN WITH TEST SEGMENT FM506 (262)
C*****          THIS SEGMENT WILL TEST CHARACTER VARIABLES WITH VARYING
C*****  LENGHTS IN COMMON AREAS
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
        BLOCK DATA AN507
C*****
        CHARACTER*3 C3XVK, F3XVK
        CHARACTER*2 D2XVK
        CHARACTER*5 E5XVK
        COMMON /BLK8/ C3XVK, D2XVK, E5XVK, F3XVK
        DATA C3XVK, D2XVK, E5XVK, F3XVK /'123', 'GH', 'LONGS', 'END'/
C*****
        END
*HEADER,FORTR,FM506,SUBRTN,FM508
C***********************************************************************
C***** FORTRAN 77
C*****   FM508                  BLKD3Q - (705)
C*****  THIS SUBROUTINE IS CALLED BY FM506
C***********************************************************************
C*****
C***** GENERAL PURPOSE
C*****  THIS SEGMENT IS TO BE RUN WITH TEST SEGMENT 262
C*****     THIS SEGMENT CONTAINS A SUBROUTINE THAT CHECKS TO SEE IF
C*****  IF THE BLOCK DATA PROGRAM CORRECTLY INITIALIZED CHARACTER
C*****  VARIABLES INTERMIXED WITH DIFFERENT LENGTHS
C*****
        SUBROUTINE SN508 (NWVI)
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
        CHARACTER*3 C3XVK, F3XVK
        CHARACTER*2 D2XVK
        CHARACTER*5 E5XVK, CVCORR
        COMMON /BLK8/ C3XVK, D2XVK, E5XVK, F3XVK
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
      IVTOTL = 4
      ZPROG = 'FM506'
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
        WRITE(NUVI,26200)
26200   FORMAT( 1H , /  39H BLKD3 - (262) BLOCK DATA SUBPROGRAM --//
     1          36H  VARYING CHARACTER VARIABLE LENGTHS//
     2          15H  ANS REF. - 16)
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
CT001*  TEST 1                                     3 CHARACTER VARIABLE
           IVTNUM = 1
           IVCOMP = 0
           IF (C3XVK.EQ.'123') IVCOMP = 1
           IF (IVCOMP - 1) 20010, 10010, 20010
10010      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0011
20010      IVFAIL = IVFAIL + 1
           CVCORR = '123'
           WRITE (NUVI, 80018) IVTNUM, C3XVK, CVCORR
 0011      CONTINUE
CT002*  TEST 2                                     2 CHARACTER VARIABLE
           IVTNUM = 2
           IVCOMP = 0
           IF (D2XVK.EQ.'GH') IVCOMP = 1
           IF (IVCOMP - 1) 20020, 10020, 20020
10020      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0021
20020      IVFAIL = IVFAIL + 1
           CVCORR = 'GH'
           WRITE (NUVI, 80018) IVTNUM, D2XVK, CVCORR
 0021      CONTINUE
CT003*  TEST 3                                     5 CHARACTER VARIABLE
           IVTNUM = 3
           IVCOMP = 0
           IF (E5XVK.EQ.'LONGS') IVCOMP = 1
           IF (IVCOMP - 1) 20030, 10030, 20030
10030      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0031
20030      IVFAIL = IVFAIL + 1
           CVCORR = 'LONGS'
           WRITE (NUVI, 80018) IVTNUM, E5XVK, CVCORR
 0031      CONTINUE
CT004*  TEST 4                                     3 CHARACTER VARIABLE
           IVTNUM = 4
           IVCOMP = 0
           IF (F3XVK.EQ.'END') IVCOMP = 1
           IF (IVCOMP - 1) 20040, 10040, 20040
10040      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0041
20040      IVFAIL = IVFAIL + 1
           CVCORR = 'END'
           WRITE (NUVI, 80018) IVTNUM, F3XVK, CVCORR
 0041      CONTINUE
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
        END
*END-OF,FM506
