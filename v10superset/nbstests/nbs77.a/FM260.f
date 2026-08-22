*HEADER,FORTR,FM260
*FILES1,FORTR,FM260,X
C***********************************************************************
C*****  FORTRAN 77
C*****   FM260
C*****                       BLKIF3 - (302)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                      SUBSET REF
C*****    TEST BLOCK IF STATEMENTS                          11.1 - 11.3
C*****          WITH DO, ARITHMETIC IF, LOGICAL IF,         11.6 - 11.10
C*****                  COMPUTED GOTO, ASSIGN GOTO
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
      ZPROG = 'FM260'
          IVTOTL = 2
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
C*****
C*****    HEADER FOR SEGMENT 302
        WRITE(NUVI,30200)
30200   FORMAT(1H ,24H BLKIF3 - (302) BLOCK IF//
     1      36H  WITH OTHER CONTROL CONSTRUCTS (II)//
     2      40H  SUBSET REF.  11.1 - 11.3, 11.6 - 11.10)
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
           WRITE (NUVI, 30225)
CT001*  TEST 1          BLOCK IF WITH DO, ARITHMETIC IF, COMPUTED GOTO,
C*****                  ASSIGNED GOTO
           IVTNUM = 1
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80004) IVTNUM
        JVI = 1
        KVI = 1
        ASSIGN  0017 TO MVI
        DO 0011 IVI =  1, 9
                IF (IVI - 6) 0010, 0013, 0016
 0010           IF (IVI .LE. 3) THEN
                        GOTO (0019, 0012, 0012) IVI
 0012                   KVI = KVI + 1
                ELSE
                        KVI = 5
                        IF (IVI .NE. 5) KVI = 4
                ENDIF
                GOTO 0019
 0013           DO 0015 NVI = 1,3
                        KVI = 8
                        IF ((IVI + NVI) .EQ. 7) THEN
                                 KVI = 6
                                 GOTO 0014
                        ELSEIF (NVI .EQ. 2) THEN
                                  KVI = 7
C*****                                    LABEL ON A ENDIF IS PERMITTED
 0014                   ENDIF
                        LVI = KVI - JVI
                        WRITE(NUVI,30215) LVI
                        JVI = JVI + 1
 0015                   CONTINUE
                GOTO 0011
 0016           LVI = 10
                GOTO MVI, (0017, 0018)
 0017           ASSIGN 0018 TO MVI
                LVI = 9
 0018           IF (IVI .LE. 8) THEN
                        KVI = LVI
                ELSE
                        KVI = 11
                ENDIF
 0019           LVI = KVI - JVI
                WRITE (NUVI, 30215) LVI
                JVI = JVI + 1
 0011           CONTINUE
CT002*  TEST 2                                 DO WITH NESTED BLOCK IFS
           IVTNUM = 2
           IVINSP = IVINSP + 1
           WRITE (NUVI, 80004) IVTNUM
        JVI = 1
        DO 0021 IVI = 1, 8
                KVI = 0
                IF (IVI .LT. 5) THEN
                        IF (IVI .LE. 2) THEN
                                IF (IVI - 1 .EQ. 0) THEN
                                        KVI = KVI + 1
                                ELSE
                                        KVI = KVI + 2
                                ENDIF
                                KVI = KVI * 2
                        ELSE
                                IF (IVI .EQ. 3) THEN
                                        DO 0020 NVI = 1,IVI
 0020                                           KVI = KVI + 10
                                ELSE
                                        DO 0022 NVI = 1, IVI
 0022                                           KVI = KVI + 10
                                ENDIF
                                KVI = KVI / 10 * 2
                        ENDIF
                        KVI = KVI * 3
                 ELSE
                        IF (IVI .LE. 6) THEN
                                IF (IVI - 5 .EQ. 0) THEN
                                        KVI = KVI + 105
                                ELSE
                                        KVI = KVI + 106
                                ENDIF
                                KVI = (KVI - 100) * 3
                        ELSE
                                IF (IVI .LE. 7) THEN
                                        KVI = KVI - 7
                                ELSE
                                        KVI = KVI - 8
                                ENDIF
                                KVI = KVI + IVI * 4
                        ENDIF
                        KVI = KVI * 2
                ENDIF
                LVI = KVI / 6 - JVI
                WRITE (NUVI,30215) LVI
                JVI = JVI + 1
 0021   CONTINUE
C*****
30215   FORMAT(1H ,26X,I10)
30225   FORMAT (/49X,'TEST 1 (11 COMPUTED RESULTS)'/
     1           49X,'TEST 2 (8 COMPUTED RESULTS)'/
     2           49X,'ALL ANSWERS SHOULD BE ZERO')
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
C*****    END OF TEST SEGMENT 302
      STOP
      END
*END-OF,FM260
