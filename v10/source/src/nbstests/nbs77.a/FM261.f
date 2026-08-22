*HEADER,FORTR,FM261
*FILES1,FORTR,FM261
C***********************************************************************
C*****  FORTRAN 77
C*****   FM261
C*****                       BLKIF4 - (303)
C*****   THIS PROGRAM CALLS SUBROUTINES SN262, SN263 AND INTEGER
C        FUNCTION IF264
C***********************************************************************
C*****  GENERAL PURPOSE                                      SUBSET REF
C*****    TEST BLOCK IF STATEMENTS                           11.6 - 11.9
C*****                  WITH SUBROUTINE CALLS                   15.6
C*****                  USES SUBROUTINES SN262 (750), SN263 (751)
C*****                          AND FUNCTION IF264 (752)
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
      ZPROG = 'FM261'
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
C*****   TOTAL NUMBER OF EXPECTED TESTS
          IVTOTL = 2
C*****    HEADER FOR SEGMENT 303
        WRITE(NUVI,30300)
30300   FORMAT(1H ,/24H BLKIF4 - (303) BLOCK IF//
     1         31H  BLOCK IF WITH SUBPROGRAM CALL//
     2         31H  SUBSET REF. 11.6 - 11.9, 15.6)
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
           WRITE (NUVI, 30325)
CT001*  TEST 1                           BLOCK IF WITH SUBROUTINE CALLS
           IVTNUM = 1
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80004) IVTNUM
        IVI = 3
        CALL SN262 (IVI)
        IF (IVI .GT. 0) THEN
                CALL SN262 (IVI)
        ELSE
                CALL SN263 (IVI)
        ENDIF
        LVI =  7 - IVI
        WRITE (NUVI, 30301) LVI
C*****     CONTINUE
CT002*  TEST 2                     CALL OF FUNCTION CONTAINING BLOCK IF
           IVTNUM = 2
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80004) IVTNUM
        IVI = 7
        IVI = IF264 (IVI .GT. 0)
        LVI = 8 - IVI
        WRITE (NUVI, 30301) LVI
        IVI = IF264 (LVI .NE. 0)
        LVI = 6 - IVI
        WRITE (NUVI, 30301) LVI
C*****
30325   FORMAT (/49X,'TEST 1 (1 COMPUTED RESULT)'/
     1           49X,'TEST 2 (2 COMPUTED RESULTS)'/
     2           49X,'ALL ANSWERS SHOULD BE ZERO')
30301   FORMAT (1H ,26X,I10)
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
C*****    END OF TEST SEGMENT 303
      STOP
      END
*HEADER,FORTR,FM261,SUBRTN,FM262
C***********************************************************************
C*****  FORTRAN 77
C*****   FM262
C*****    SN262              SN262 - (750)
C*****    SUBROUTINE CALLED BY FM261
C***********************************************************************
C*****
        SUBROUTINE SN262 (IWVI)
C*****
        IWVI = IWVI + 2
C*****
        RETURN
        END
*HEADER,FORTR,FM261,SUBRTN,FM263
C***********************************************************************
C*****  FORTRAN 77
C*****   FM263
C*****    SN263              SN263 - (751)
C*****    SUBROUTINE CALLED BY FM261
C***********************************************************************
C*****
        SUBROUTINE SN263 (IWVI)
C*****
        IWVI = IWVI * (-10)
C*****
        RETURN
        END
*HEADER,FORTR,FM261,SUBRTN,FM264
C***********************************************************************
C*****  FORTRAN 77
C*****   FM264
C*****    IF264              IF264 - (752)
C*****    INTEGER FUNCTION CALLED BY FM261
C***********************************************************************
C*****
        INTEGER FUNCTION IF264 (AWVB)
        LOGICAL AWVB
C*****
        IF (AWVB) THEN
                IF264 = 8
                RETURN
        ELSE
                IF264 = 6
        ENDIF
C*****
        RETURN
        END
*END-OF,FM261
