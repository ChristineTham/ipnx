C*****    PART10    ****************************************************
C*****
C*****    ANSI FORTRAN   (X3.9-1966)     TEST PROGRAMS
C*****
C*****    PREPARED BY THE NATIONAL BUREAU OF STANDARDS      VERSION 3
C*****
C*****    JUNE 1973
C*****
C*****    PART 10 OF 14 PARTS
C*****
C*****    SEGMENTS INCLUDED
C*****
C*****      BRFCP - 160 REAL EXTERNAL FUNCTIONS
C*****
C*****        AFS - 400    REAL ARGUMENT
C*****
C*****        BFS - 420    REAL ARGUMENTS
C*****
C*****        CFS - 430    INTEGER ARGUMENT
C*****
C*****        DFS - 440    INTEGER ARGUMENTS
C*****
C*****        EFS - 450    ARRAY NAME
C*****
C*****        FFS - 460    DIFFERENT TYPES OF ARGUMENTS
C*****
C*****      BIFCP - 161 INTEGER EXTERNAL FUNCTIONS
C*****
C*****       IAFI - 401    REAL ARGUMENT
C*****
C*****       IBFI - 421    REAL ARGUMENTS
C*****
C*****       ICFI - 431    INTEGER ARGUMENT
C*****
C*****       IDFI - 441    INTEGER ARGUMENTS
C*****
C*****       IEFI - 451    ARRAY NAME
C*****
C*****       IFFI - 461    DIFFERENT TYPES OF ARGUMENTS
C*****
C*****      FRFCP - 162 REAL FUNCTIONS
C*****
C*****        GFS - 402    D.P. ARGUMENT
C*****
C*****        HFS - 422    COMPLEX ARGUMENTS
C*****
C*****       IRFS - 432    LOGICAL ARGUMENT
C*****
C*****       JRFS - 442    EXTERNAL PROCEDURE
C*****
C*****        RFS - 452    DIFFERENT TYPES OF ARGUMENTS
C*****
C*****      FIFCP - 163 INTEGER FUNCTIONS
C*****
C*****        IFI - 403    D.P. ARGUMENT
C*****
C*****        JFI - 423    COMPLEX ARGUMENTS
C*****
C*****        KFI - 433    LOGICAL ARGUMENT
C*****
C*****        LFI - 443    EXTERNAL PROCEDURE
C*****
C*****        MFI - 453    DIFFERENT TYPES OF ARGUMENTS
C*****
C*****      CFCCP - 164 COMPLEX FUNCTIONS
C*****
C*****        AFC - 404    REAL ARGUMENT
C*****
C*****        BFC - 414    INTEGER ARGUMENT
C*****
C*****        CFC - 424    ARRAY NAME
C*****
C*****        DFC - 434    D.P. ARGUMENT
C*****
C*****        EFC - 444    COMPLEX ARGUMENT
C*****
C*****        FFC - 454    LOGICAL ARGUMENT
C*****
C*****        HFC - 464    DIFFERENT TYPES OF ARGUMENTS
C*****
C*****  THE FOLLOWING SPECIFICATIONS ARE TO BE USED ONLY WHEN
C*****  SEGMENTS 160, 161, 162, 163, 164
C*****  ARE RUN AS ONE MAIN PROGRAM.
C*****
      DIMENSION  A1S(5), A2S(2,2) , A3S(3,3,3)
      INTEGER I1I(5), I2I(2,2), I3I(2,2,2)
      REAL JRFS, IRFS
      LOGICAL A1B(2), A2B(2,2), A3B(2,2,2), AVB, BVB
      DOUBLE PRECISION AVD, A1D(4), A2D(2,2), A3D(2,2,2)
      COMPLEX AVC, BVC,AFC, BFC, CFC, DFC, EFC, FFC, HFC
     1   , A1C(12), A2C(2,2), A3C(2,2,1)
      COMMON AXVS, CXVS
      EXTERNAL GFS, BFC, IFI
C*****
C*****  END OF SPECIFICATIONS FOR SEGMENTS
C*****  160,161, 162, 163, 164
C***********************************************************************
C*****
C*****                  BRFCP - (160)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                          ASA REF
C*****    1.TO TEST REAL FUNCTIONS                                 8.3.1
C*****    2.DUMMY ARGUMENTS ARE REAL OR INTEGER VARIABLES,OR
C*****      ARRAY NAMES
C*****    3.FUNCTIONS CONTAIN UP TO 20 ARGUMENTS
C*****    4.IN REFERENCE, ACTUAL ARGUMENTS ARE VARIABLE NAME,
C*****      ARRAY NAME, ARRAY ELEMENT NAME, OR AN ARITHMETIC
C*****      EXPRESSION                                             8.3.2
C*****  RESTRICTIONS OBSERVED
C*****    1.ITEMS(2),(3),(4),(5),(6) OF PARAGRAPH 8.3.1
C*****    2.LAST SENTENCE OF PARAGRAPH 3.2
C*****    THIS SEGMENT IS TO BE RUN WITH SEGMENTS
C*****     400, 420, 430, 440, 450, 460                    WHICH
C*****     CONTAINS ALL FUNCTIONS BEING TESTED HERE.
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 160
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 160, REMOVE THE PRECEDING
C*****  SPECIFICATIONS.  THE FOLLOWING SPECIFICATIONS WHICH
C*****  APPEAR AS COMMENTS MUST HAVE THE C= IN COLUMNS 1 AND 2 REMOVED.
C*****
C=    DIMENSION A1S(5),A2S(2,2)
C*****
C*****  I N P U T  - O U T P U T  T A P E  ASSIGNMENT STATEMENT
      IRVI = 5
      NUVI = 6
C*****  IDENTIFY THE SOURCE OF THE TEST PROGRAMS
      WRITE(NUVI,0071)
0071  FORMAT (41H1 F O R T R A N  T E S T  P R O G R A M S//
     1 42H  PREPARED BY NATIONAL BUREAU OF STANDARDS//
     3 37H  FOR USE ON LARGE FORTRAN PROCESSORS  //
     4 42H  IN ACCORDANCE WITH ASA FORTRAN X3.9-1966//
     5 23H  VERSION 3     PART 10///)
C*****  3 OF 6 INPUT CARDS IDENTIFY THE USERS SYSTEM AND COMPILER
C       PREPARED BY USER
C       READ, NO LIST
C       PREPARED BY USER
C       READ, NO LIST
C       PREPARED BY USER
C       READ, NO LIST
      READ(IRVI,0070)
      READ(IRVI,0072)
      READ(IRVI,0073)
0070  FORMAT(40H   BASED ON ASA FORTRAN X3.9-1966       /)
0072  FORMAT(40H   TEST PROGRAMS                        /)
0073  FORMAT(40H   FORTRAN COMPILER                     /)
      WRITE(NUVI,0070)
      WRITE(NUVI,0072)
      WRITE(NUVI,0073)
      WRITE(NUVI,1604)
1604  FORMAT(1H1,1X,37HBRFCP - (160) REAL EXTERNAL FUNCTIONS/
     1 /2X,16HASA REF. - 8.3.1//28H  RESULTS SHOULD BE POSITIVE)
      IAVI=2
      A1S(1)=1.0
      A1S(2)=1.0
      A2S(2,2)=1.0
      A2S(2,1)=1.0
      AVS=1.0
      BVS=2.0
      CVS=1.0
      DVS=1.0
      EVS=1.0
      IVI=AFS(2.0)-8.0
      MAVI=1
      IF(IVI)1600,1601,1600
 1605 IVI=BFS(2.0,BVS)-4.0
      MAVI=2
      IF(IVI)1600,1601,1600
 1606 IVI = CFS(2) -16.0
      MAVI=3
      IF(IVI)1600,1601,1600
 1607 IVI=DFS(2,IAVI)-1.0
      MAVI=4
      IF(IVI)1600,1601,1600
 1608 IVI=EFS(A1S)-2.0
      MAVI=5
      IF(IVI)1600,1601,1600
 1609 IVI=FFS(IAVI,AVS,+2,-1.0,A1S,IAVI,CVS,A1S,1.0,IAVI,A1S,A1S,BVS,DVS
     1 ,A1S(1),A2S,A2S,A2S,EVS+1.0,IAVI-1) + 1.0
	print *, IAVI,AVS,+2,-1.0,A1S,IAVI,CVS,A1S,1.0,IAVI,A1S,A1S,
&	BVS,DVS,A1S(1),A2S,A2S,A2S,EVS+1.0,IAVI-1
      MAVI=6
      IF(IVI) 1600,1601,1600
 1600 WRITE (NUVI,1602)MAVI
      GO TO 7001
 1601 WRITE (NUVI,1603)MAVI
1602  FORMAT (//2X,5HTEST ,I1,12H IS NEGATIVE)
1603  FORMAT (//2X,5HTEST ,I1,12H IS POSITIVE)
 7001 GO TO (1605,1606,1607,1608,1609,7000  ),MAVI
 7000 CONTINUE
C*****    END OF TEST SEGMENT 160
C*****  WHEN EXECUTING ONLY SEGMENT 160, THE STOP  AND  END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=  IN
C*****  COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                  BIFCP - (161)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                          ASA REF
C*****    1-TO TEST INTEGER FUNCTIONS                              8.3.1
C*****    2-DUMMY ARGUMENTS ARE REAL OR INTEGER VARIABLES OR
C*****      ARRAY NAMES                                            8.3.1
C*****    3-FUNCTIONS CONTAIN UP TO 20 ARGUMENTS
C*****    4-IN REFERENCE,ACTUAL ARGUMENTS ARE VARIABLE NAME,
C*****     ARRAY NAME,ARRAY ELEMENT NAME,OR AN ARITHMETIC
C*****     EXPRESSION                                              8.3.2
C*****RESTRICTIONS OBSERVED
C*****    1-ITEMS (2),(3),(4),(5),(6) OF PARAGRAPH  8.3.1
C*****    2-LAST SENTENCE OF PARAGRAPH 3.2
C*****     THIS SEGMENT IS TO BE RUN WITH SEGMENTS
C*****     401, 421, 431, 441, 451, 461  WHICH
C*****     CONTAINS ALL FUNCTIONS BEING TESTED HERE.
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 161
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 161, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=
C*****  IN COLUMNS 1  AND  2  REMOVED.
C*****
C=    DIMENSION A1S(5)
C=    INTEGER I1I(5)
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 161, THE STATEMENT  NUVI = 6
C*****  MUST HAVE THE C= IN COLUMNS  1  AND 2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE(NUVI,1614)
1614  FORMAT(1H1,1X,40HBIFCP - (161) INTEGER EXTERNAL FUNCTIONS/
     1 16X,26HWITH INTEGER AND REAL ARGS//2X,16HASA REF. - 8.3.1//
     228H  RESULTS SHOULD BE POSITIVE)
      IAVI=2
      A1S(1)=1.0
      A1S(2)=1.0
      I1I(1)=1
      I1I(2)=1
      AVS=1.0
      BVS=2.0
      CVS=1.0
      DVS=1.0
      EVS=1.0
      IVI=IAFI(2.0) - 8
      MAVI=1
      IF (IVI) 1610,1611,1610
 1615 IVI=IBFI(2.0,BVS)-4
      MAVI=2
      IF (IVI) 1610,1611,1610
 1616 IVI = ICFI(2) - 16
      MAVI=3
      IF (IVI) 1610,1611,1610
 1617 IVI=IDFI(2,IAVI)-1
      MAVI=4
      IF (IVI) 1610,1611,1610
1618  IVI=IEFI(I1I)-2
      MAVI=5
      IF (IVI) 1610,1611,1610
 1619 IVI=IFFI(IAVI,AVS,2,-1.0,A1S,IAVI,CVS,A1S,1.0,IAVI,A1S,A1S,BVS,
     1DVS,A1S(1),A1S,A1S,A1S,EVS+1.0,IAVI-1) + 1
      MAVI=6
      IF(IVI) 1610,1611,1610
 1610 WRITE(NUVI,1612)MAVI
      GO TO 7002
 1611 WRITE(NUVI,1613)MAVI
1612  FORMAT (//2X,5HTEST ,I1,12H IS NEGATIVE)
1613  FORMAT (//2X,5HTEST ,I1,12H IS POSITIVE)
 7002 GO TO (1615,1616,1617,1618,1619,7003),MAVI
 7003 CONTINUE
C*****    END OF TEST SEGMENT 161
C*****  WHEN EXECUTING ONLY SEGMENT 161, THE  STOP  AND  END  CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                  FRFCP - (162)
C*****
C***********************************************************************
C*****                   GENERAL PURPOSE                        ASA REF
C*****  1.TO TEST REAL FUNCTIONS IN FULL FORTRAN
C*****  2.THIS SEGMENT COMPLETES SEGMENT (160) IN ORDER TO TEST
C*****    FOR ALL FEATURES REQUIRED IN FULL FORTRAN                8.3.1
C*****  3.DUMMY ARGUMENTS CAN BE INTEGER(TESTED IN 160),REAL(TESTED IN
C*****    160),ARRAY NAME(TESTED IN 160),DOUBLE PRECISION,COMPLEX,
C*****    LOGICAL OR EXTERNAL PROCEDURE                            8.3.1
C*****  4.DUMMY ARGUMENTS MAY BE REDEFINED IN SUBPROGRAM(ITEM 4)   8.3.1
C*****  5.IN REFERENCE, ACTUAL ARGUMENTS MAY BE AS IN (160) AND
C*****    BESIDES EXTERNAL PROCEDURE. IN THIS CASE, EXTERNAL       8.3.2
C*****    PROCEDURE IS REFERENCED BY AN EXTERNAL STATEMENT
C*****  6.USE CAN BE MADE OF ADJUSTABLE DIMENSION
C*****RESTRICTIONS OBSERVED
C*****  1.ITEMS (1), (2), (3), (5) OF 8.3.1
C*****  2.PARAGRAPH 8.3.2, LINE 18 TO END OF PARAGRAPH
C*****     THIS SEGMENT   USES   5 REAL FUNCTIONS
C*****     THIS SEGMENT IS TO BE RUN WITH SEGMENTS
C*****     402, 422, 432, 442, 452   WHICH
C*****    WHICH CONTAINS ALL FUNCTIONS BEING TESTED HERE
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 162
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 162, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=
C*****  IN COLUMNS 1  AND  2  REMOVED.
C*****
C=    DIMENSION A1S(5),A2S(2,2),A3S(3,3,3)
C=    INTEGER I1I(5),I2I(2,2),I3I(2,2,2)
C=    REAL JRFS,IRFS
C=    LOGICAL A1B(2),A2B(2,2),A3B(2,2,2),AVB,BVB
C=    DOUBLE PRECISION AVD,A1D(4),A2D(2,2),A3D(2,2,2)
C=    COMPLEX AVC,BVC,A1C(12),A2C(2,2),A3C(2,2,1)
C=    COMMON AXVS,CXVS
C=    EXTERNAL GFS
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 162, THE STATEMENT  NUVI = 6
C*****  MUST HAVE THE C= IN COLUMNS  1  AND 2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI,1624)
1624  FORMAT(1H1,1X,33HFRFCP - (162) REAL FUNCTIONS WITH/10X,31HLOGICAL,
     1 D.P., AND COMPLEX ARGS//16H  ASA REF. 8.3.1//
     228H  RESULTS SHOULD BE POSITIVE)
C*****TEST 1
      AVD = 1.0D0
      MAVI = 1
      IVI = 1.0-GFS(AVD)
      IF (IVI) 1620,1621,1620
C*****TEST 2
 1625 MAVI =2
      AVC = (1.0,-1.0)
      BVC = (1.0,1.0)
      IVI = HFS(AVC,BVC)
      IF (IVI) 1620,1621,1620
C*****TEST 3
 1626 MAVI=3
      AVB = .TRUE.
      IVI = IRFS(AVB)*2.0
      AVB = .FALSE.
      JVI = IRFS(AVB)*4.0
      LVI = IVI + JVI - 4
      IF (LVI) 1620,1621,1620
C*****TEST 4
 1627 MAVI=4
      IVI = JRFS(AVD,GFS)
      IF (IVI-1) 1620,1621,1620
C*****TEST 5,6,7
 1628 AXVS = 1.0
      AVS = 1.0
      A1S(1) = 1.0
      A2S(1,1) = 1.0
      A3S(1,1,1) = 1.0
      AVB = .FALSE.
      A1B(1) = .FALSE.
      A2B(1,1) = .FALSE.
      A3B(1,1,1) = .FALSE.
      IAVI = 1
      I1I(1) = 1
      I2I(1,1) =1
      I3I(1,1,1) =1
      A1C(1) = (1.0,1.0)
      A2C(1,1) = (1.0,1.0)
      A3C(1,1,1) = (-2.0,-2.0)
      AVD = 1.0D0
      A1D(1) = 1.0D0
      A2D(1,1) = 1.0D0
      A3D(1,1,1) = 1.0D0
      IVI= RFS(AVS,IAVI,AVB,AVC,AVD,A1S,A2S,A3S,I1I,I2I,I3I,A1B,A2B,A3B,
     1 A1C,A2C,A3C,A1D,A2D,A3D,GFS)
      MAVI = 5
      IF (IVI) 1620,1621,1620
 1629 MAVI = 6
      BVB = AVB.AND.A1B(1).AND.A2B(1,1).AND.A3B(1,1,1)
      IF (BVB) GO TO 1621
      GO TO 1620
 7010 IVI=REAL(AVC)
      JVI = AIMAG(AVC)
      MAVI = 7
      BVB = IVI.EQ.0.AND.JVI.EQ.0
      IF (BVB) GO TO 1621
1620  WRITE (NUVI,1622) MAVI
      GO TO 7011
1621  WRITE (NUVI,1623) MAVI
 1622 FORMAT(//2X,5HTEST ,I1,13H IS NEGATIVE.)
 1623 FORMAT (//2X,5HTEST ,I1,13H IS POSITIVE.)
 7011 GO TO (1625,1626,1627,1628,1629,7010,7012),MAVI
 7012 CONTINUE
C*****     END OF TEST SEGMENT 162
C*****  WHEN EXECUTING ONLY SEGMENT 162, THE  STOP  AND  END  CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                  FIFCP - (163)
C*****
C***********************************************************************
C*****                  GENERAL PURPOSE                         ASA REF
C*****  1.TO TEST INTEGER FUNCTIONS IN FULL FORTRAN
C*****  2.THIS SEGMENT COMPLETES SEGMENT (161) IN ORDER TO TEST
C*****    FOR ALL FEATURES REQUIRED IN FULL FORTRAN.              8.3.1
C*****  3.DUMMY ARGUMENTS CAN BE INTEGER(TESTED IN 161),REAL(TESTED
C*****    IN 161),DOUBLE PRECISION,COMPLEX,LOGICAL,OR EXTERNAL PROCEDURE
C*****  4.DUMMY ARGUMENTS MAY BE REDIFINED IN SUBPROGRAM(ITEM 4)
C*****  5. IN REFERENCE,ACTUAL ARGUMENTS MAY BE AS IN (161) AND BESIDES
C*****    EXTERNAL PROCEDURE.IN THIS CASE,EXTERNAL PROCEDURE IS
C*****    REFERENCED BY AN EXTERNAL STATEMENT.
C*****  6. USE CAN BE MADE OF ADJUSTABLE DIMENSION.
C*****RESTRICTIONS OBSERVED
C*****   1.ITEMS (1),(2),(3),(5), OF 8.3.1
C*****  2 PARAGRAPH 8.3.2,LINE 18 TO END OF PARAGRAPH
C*****     THIS SEGMENT   USES   5 INTEGER FUNCTIONS
C*****     THIS SEGMENT IS TO BE RUN WITH SEGMENTS
C*****     403, 423, 433, 443, 453                         WHICH
C*****    WHICH CONTAINS ALL FUNCTIONS BEING TESTED HERE
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 163
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 163, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=
C*****  IN COLUMNS 1  AND  2  REMOVED.
C*****
C=    EXTERNAL IFI
C=    DIMENSION A1S(5),A2S(2,2),A3S(3,3,3)
C=    INTEGER I1I(5),I2I(2,2),I3I(2,2,2)
C=    LOGICAL AVB,BVB,A1B(2),A2B(2,2),A3B(2,2,2)
C=    DOUBLE PRECISION AVD,A1D(4),A2D(2,2),A3D(2,2,2)
C=    COMPLEX AVC,BVC,A1C(12),A2C(2,2),A3C(2,2,1)
C=    COMMON AXVS,CXVS
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 163, THE STATEMENT  NUVI = 6
C*****  MUST HAVE THE C= IN COLUMNS  1  AND 2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE(NUVI,1634)
 1634 FORMAT (1H1,1X,33HFIFCP - (163) INTEGER FUNCTION IN/ 16X,
     1 12HFULL FORTRAN//2X,
     214HASA REF. 8.3.1//28H  RESULTS SHOULD BE POSITIVE)
C***** TEST 1
      AVD=1.0D0
      MAVI=1
      IVI=1-IFI(AVD)
      IF (IVI) 1630,1631,1630
C***** TEST 2
 1635 MAVI=2
      AVC=(1.0, 1.0)
      BVC=(1.0,-1.0)
      IVI=JFI(AVC,BVC)
      IF (IVI) 1630,1631,1630
C*****TEST 3
 1636 MAVI=3
      AVB=.TRUE.
      IVI=KFI(AVB)*2
      AVB=.FALSE.
      JVI=IVI+KFI(AVB)-4
      IF (JVI) 1630,1631,1630
C***** TEST 4
 1637 MAVI=4
      IVI=LFI(AVD,IFI)-1
      IF (IVI) 1630,1631,1630
C***** TESTS 5,6,7
 1638 AXVS=1.0
      AVS = 1.
      A1S(1)=1.0
      A2S(1,1)=1.0
      A3S(1,1,1)=1.0
      IAVI=1
      I1I(1) = 1
      I2I(1,1)=1
      I3I(1,1,1)=1
      A1C(1)=(1.0,1.0)
      A2C(1,1)=(1.0,1.0)
      A3C(1,1,1)=(-2.0,-2.0)
      AVD=1.0D0
      A1D(1)=1.0D0
      A2D(1,1)=1.0D0
      A3D(1,1,1)=1.0D0
      IVI=MFI(AVS,IAVI,AVB,AVC,AVD,A1S,A2S,A3S,I1I,I2I,I3I,A1B,A2B,A3B,
     1A1C,A2C,A3C,A1D,A2D,A3D,IFI)
      MAVI=5
      IF (IVI) 1630,1631,1630
 1639 MAVI=6
      BVB=AVB.AND.A1B(1).AND.A2B(1,1).AND.A3B(1,1,1)
      IF (BVB) GO TO 1631
      IF (.NOT.BVB) GO TO 1630
 7007 IVI=REAL(AVC)
      JVI=AIMAG(AVC)
      MAVI=7
      IF (IVI+JVI) 1630,1631,1630
 1630 WRITE(NUVI,1632) MAVI
      GO TO 7008
 1631 WRITE(NUVI,1633) MAVI
 1632 FORMAT (//2X,5HTEST ,I2,12H IS NEGATIVE)
 1633 FORMAT(//2X,5HTEST , I2,12H IS POSITIVE)
 7008      GO TO (1635,1636,1637,1638,1639,7007,7009),MAVI
 7009 CONTINUE
C*****    END OF TEST SEGMENT 163
C*****  WHEN EXECUTING ONLY SEGMENT 163, THE  STOP  AND  END  CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                        CFCCP-(164)
C*****
C***********************************************************************
C*****                   GENERAL PURPOSE                         ASA REF
C*****    1.TO TEST COMPLEX FUNCTIONS IN FULL FORTRAN             8.3.1
C*****    2.DUMMY ARGUMENTS ARE REAL,INTEGER,COMPLEX,LOGICAL,
C*****    DOUBLE PRECISION,EXTERNAL PROCEDURE,ARRAY NAME.
C*****    3.FUNCTIONS CONTAIN UP TO 20 ARGUMENTS
C*****    4.IN REFERENCE ACTUAL ARGUMENTS ARE VARIABLE NAME
C*****    ARRAY NAME,ARRAY ELEMENT NAME,ARITHMETIC EXPRESSION
C*****    EXTERNAL PROCEDURE
C*****    6.USE CAN BE MADE OF ADJUSTABLE DIMENTION
C*****    7.ARGUMENTS CAN BE PASSED THROUGH COMMON
C*****RESTRICTIONS OBSERVED
C*****    1.ITEMS(2),(3),(4),(5),(6) OF PARAGRAPH
C*****    2.LAST SENTENCE OF PARAGRAPH 3.2
C*****    THIS SEGMENT   USES   8 COMPLEX FUNCTIONS
C*****     THIS SEGMENT IS TO BE RUN WITH SEGMENTS
C*****     404, 414, 424, 434, 444, 454, 464
C*****    WHICH CONTAIN  ALL FUNCTIONS BEING TESTED HERE
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 164
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 164, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=
C*****  IN COLUMNS 1  AND  2  REMOVED.
C*****
C=    DIMENSION A1S(5),A2S(2,2),A3S(3,3,3)
C=    INTEGER I1I(5),I2I(2,2),I3I(2,2,2)
C=    LOGICAL AVB,A1B(2),A3B(2,2,2),A2B(2,2),BVB
C=    DOUBLE PRECISION AVD,A1D(4),A2D(2,2),A3D(2,2,2)
C=    COMPLEX AFC,BFC,CFC,DFC,EFC,FFC,HFC,AVC,BVC
C=   1,A1C(12),A2C(2,2),A3C(2,2,1)
C=    COMMON AXVS,CXVS
C=    EXTERNAL BFC
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 164, THE STATEMENT  NUVI = 6
C*****  MUST HAVE THE C= IN COLUMNS  1  AND 2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE(NUVI,1641)
 1641 FORMAT(1H1,1X,31HCFCCP - (164) COMPLEX FUNCTIONS//2X,
     1 21HASA REFS. 8.3.1,8.3.2//2X, 7HRESULTS)
C***** TEST 1
      BVC=AFC(1.0)
      MAVI=1
      WRITE(NUVI,1642) BVC,MAVI
1642  FORMAT(1H0,2F5.1,9H -- TEST ,I2,20H POSITIVE IF 0.0,0.0)
C***** TEST 2
       MAVI=2
      BVC= BFC(1)-(1.0,1.0)
      WRITE(NUVI,1642)BVC,MAVI
C***** TEST 3
       MAVI=3
      A1S(1)=1.0
      A1S(2)=1.0
      BVC=CFC(A1S)
      WRITE(NUVI,1642)BVC,MAVI
C***** TEST 4
      MAVI=4
      BVC = DFC (1.D0)
      WRITE(NUVI,1642)BVC,MAVI
C*****TEST 5
      MAVI=5
      AVC=(1.0,1.0)
      BVC=EFC(AVC)
      WRITE(NUVI,1642)BVC,MAVI
C*****TEST 6
      MAVI=6
      AVB=.TRUE.
      BVC=FFC(AVB)-(1.0,1.0)
      WRITE(NUVI,1642)BVC,MAVI
C***** TEST 7
       MAVI=7
       AVB=.FALSE.
       BVC=FFC(AVB)
       WRITE(NUVI,1642)BVC,MAVI
C***** TEST 8,9,10
      IVI=1
      AVD=1.0D0
      A1D(1)=1.0D0
      A2D(1,1)=1.0D0
      A3D(1,1,1)=1.0D0
      AVS=1.0
      A1S(1)=1.0
      A2S(1,1)=1.0
      A3S(1,1,1)=1.0
      A1C(1)=(1.0,1.0)
      A2C(1,1)=(1.0,1.0)
      A3C(1,1,1)=(1.0,1.0)
      I1I(1)=1
      I2I(1,1)=1
      I3I(1,1,1)=1
      AVC = (0.0,0.0)
      BVC= HFC(AVS,IVI,AVB,AVC,AVD,A1S,A2S,A3S,I1I,I2I,I3I,A1B,A2B,A3B,
     1A1C,A2C,A3C,A1D,A2D,A3D,BFC)
      MAVI = 8
      WRITE (NUVI,1642) BVC,MAVI
      MAVI=9
      IF(AXVS) 1643,1644,1643
 1648 MAVI = 10
      BVB=AVB.AND.A1B(1).AND.A2B(1,1).AND. A3B(1,1,1)
      IF (BVB) GO TO 1644
 1643 WRITE(NUVI,1645)MAVI
      GO TO 1647
 1644 WRITE(NUVI,1646)MAVI
1645  FORMAT(/15X,5HTEST ,I2,12H IS NEGATIVE)
1646  FORMAT(/15X,5HTEST ,I2,12H IS POSITIVE)
1647  IF (MAVI  - 9) 1649,1648,1649
1649  CONTINUE
C*****    END OF TEST SEGMENT 164
C*****  WHEN EXECUTING ONLY SEGMENT 164, THE  STOP  AND  END  CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
      STOP
      END
C***********************************************************************
C*****
C*****                       AFS - (400)
C*****
C***********************************************************************
C*****REAL FUNCTION OF REAL ARGUMENT (TEST 1)
      FUNCTION  AFS(AWVS)
      AFS=4.0*AWVS
      RETURN
      END
C***********************************************************************
C*****
C*****                       BFS - (420)
C*****
C***********************************************************************
C*****REAL FUNCTION OF REAL ARGUMENTS (TEST 2)
      FUNCTION BFS(AWVS,BWVS)
      BFS=AWVS+BWVS
      RETURN
      END
C***********************************************************************
C*****
C*****                       CFS - (430)
C*****
C***********************************************************************
C*****REAL FUNCTION OF INTEGER ARGUMENT  (TEST 3)
      FUNCTION  CFS(IWVI)
      CFS=4.0**IWVI
      RETURN
      END
C***********************************************************************
C*****
C*****                       DFS - (440)
C*****
C***********************************************************************
C*****REAL FUNCTION OF INTEGER ARGUMENTS (TEST 4)
      FUNCTION DFS(IWVI,JWVI)
      KVI  = IWVI - JWVI
      DFS=4.6**KVI
      RETURN
      END
C***********************************************************************
C*****
C*****                       EFS - (450)
C*****
C***********************************************************************
C*****REAL FUNCTION OF ARRAY NAME(TEST 5)
      FUNCTION EFS(AW1S)
      DIMENSION AW1S(2)
      EFS=AW1S(1)+AW1S(2)
      RETURN
      END
C***********************************************************************
C*****
C*****                       FFS - (460)
C*****
C***********************************************************************
C*****REAL FUNCTION OF DIFFERENT TYPES OF ARGUMENTS(TEST 6)
      FUNCTION FFS(IWVI,AWVS,JWVI,BWVS,AW1S,KWVI,CWVS,BW1S,DWVS,LWVI,
     1CW1S,DW1S,EWVS,FWVS,GWVS,BW2S,CW2S,DW2S,HWVS,MWVI)
      DIMENSION  AW1S(2),BW1S(2),CW1S(2),DW1S(2),BW2S(2,2),CW2S(2,2),
     1DW2S(2,2)
      print *, 'FUNCTION FFS:\n',IWVI,AWVS,JWVI,BWVS,AW1S,KWVI,CWVS,
     1BW1S,DWVS,LWVI,CW1S,DW1S,EWVS,FWVS,GWVS,BW2S,CW2S,DW2S,HWVS,MWVI
      FFS=AWVS**IWVI-BWVS**JWVI-AW1S(1)-CWVS**KWVI+BW1S(2)-DWVS+CW1S(1)
     1**LWVI+DW1S(1)-EWVS+FWVS-GWVS+BW2S(2,1)-CW2S(2,2)+DW2S(2,2)-HWVS**
     2MWVI
	print *, 'ffs=', ffs
      RETURN
      END
C***********************************************************************
C*****
C*****                       IAFI - (401)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF REAL ARGUMENT (TEST 1)
      FUNCTION IAFI(AWVS)
      IAFI=4.0*AWVS
      RETURN
      END
C***********************************************************************
C*****
C*****                       IBFI - (421)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF TWO REAL ARGUMENTS (TEST 2)
      FUNCTION IBFI(AWVS,BWVS)
      IBFI=AWVS+BWVS
      RETURN
      END
C***********************************************************************
C*****
C*****                       ICFI - (431)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF INTEGER ARGUMENT(TEST 3)
      FUNCTION ICFI(IWVI)
      ICFI=4.0**IWVI
      RETURN
      END
C***********************************************************************
C*****
C*****                       IDFI - (441)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF INTEGER ARGUMENTS (TEST 4)
      INTEGER FUNCTION IDFI (IWVI, JWVI)
      REAL KUVS
      DATA KUVS /4.6/
      IDFI = IWVI - JWVI
      IDFI = KUVS ** IDFI
      RETURN
      E N D
C***********************************************************************
C*****
C*****                       IEFI - (451)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF ARRAY NAME (TEST 5)
      FUNCTION IEFI(IAW1I)
      DIMENSION IAW1I(2)
      IEFI=IAW1I(1)+IAW1I(2)
      RETURN
      END
C***********************************************************************
C*****
C*****                       IFFI - (461)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF DIFFERENT TYPES OF ARGUMENTS(TEST 6)
      FUNCTION IFFI(IWVI,AWVS,JWVI,BWVS,AW1S,KWVI,CWVS,BW1S,DWVS,LWVI,
     1CW1S,DW1S,EWVS,FWVS,GWVS,EW1S,GW1S,HW1S,HWVS,MWVI)
      DIMENSION AW1S(2),BW1S(2),CW1S(2),DW1S(2),EW1S(5), GW1S(5),
     1 HW1S(5)
      IFFI=AWVS**IWVI-BWVS**JWVI+AW1S(1)-CWVS**KWVI+BW1S(2)-DWVS+CW1S(1)
     1**LWVI+DW1S(1)-EWVS+FWVS-GWVS+EW1S(1)  -GW1S(2)  +HW1S(2)  -HWVS**
     2MWVI
      RETURN
      END
C***********************************************************************
C*****
C*****                       GFS - (402)
C*****
C***********************************************************************
C***** REAL FUNCTION OF DOUBLE PRECISION ARGUMENT (TEST 1)
      FUNCTION  GFS(AWVD)
      DOUBLE PRECISION  AWVD
      GFS = AWVD
      RETURN
      END
C***********************************************************************
C*****
C*****                       HFS - (422)
C*****
C***********************************************************************
C*****REAL FUNCTION OF COMPLEX ARGUMENT (TEST 2)
      FUNCTION HFS(AWVC,BWVC)
      COMPLEX  AWVC,BWVC,CVC
      CVC  = AWVC * BWVC
      HFS = AIMAG(CVC)
      RETURN
      END
C***********************************************************************
C*****
C*****                       IRFS -  (432)
C*****
C***********************************************************************
C*****REAL FUNCTION OF LOGICAL ARGUMENT (TEST 3)
      REAL FUNCTION IRFS(AWVB)
      LOGICAL  AWVB
      IF (AWVB) GO TO 4321
4320  IF (.NOT. AWVB) GO TO 4322
      RETURN
4321  IRFS = 2.0
      GO TO 4320
4322  IRFS = 0.0
      RETURN
      END
C***********************************************************************
C*****
C*****                       JRFS - (442)
C*****
C***********************************************************************
C*****REAL FUNCTION OF EXTERNAL PROCEDURE (TEST 4)
      REAL FUNCTION JRFS( BWVD,BWFS)
      DOUBLE PRECISION BWVD
      JRFS = BWFS(BWVD)
      RETURN
      END
C***********************************************************************
C*****
C*****                       RFS - (452)
C*****
C***********************************************************************
C*****REAL FUNCTION OF DIFFERENT TYPES OF ARGUMENTS. USE IS MADE OF
C*****ADJUSTABLE DIMENSION (TEST 5, 6, 7)
      FUNCTION RFS(AWVS,IWVI,AWVB,AWVC,AWVD,AW1S,AW2S,AW3S,IW1I,IW2I,
     1IW3I,AW1B,AW2B,AW3B,AW1C,AW2C,AW3C,AW1D,AW2D,AW3D,AWFS)
      LOGICAL AWVB,AW1B,AW2B,AW3B
      COMPLEX AWVC,AW1C,AW2C,AW3C
      DOUBLE PRECISION AWVD, AW1D,AW2D,AW3D
      DIMENSION AW1S(IWVI),AW2S(IWVI,IWVI),AW3S(IWVI,IWVI,IWVI) ,
     1          IW1I(IWVI),IW2I(IWVI,IWVI),IW3I(IWVI,IWVI,IWVI) ,
     2          AW1B(IWVI),AW2B(IWVI,IWVI),AW3B(IWVI,IWVI,IWVI) ,
     3          AW1C(IWVI),AW2C(IWVI,IWVI),AW3C(IWVI,IWVI,IWVI) ,
     4          AW1D(IWVI),AW2D(IWVI,IWVI),AW3D(IWVI,IWVI,IWVI)
      COMMON BXVS
      RFS =AWVS**IWVI+AW1S(IWVI)**IW1I(IWVI)-AW2S(IWVI,IWVI)**IW2I
     1 (IWVI,IWVI)+AW3S(IWVI,IWVI,IWVI)**IW3I(IWVI,IWVI,IWVI)-AWVD+
     2 AW1D(IWVI)-AW2D(IWVI,IWVI)-AW3D(IWVI,IWVI,IWVI)+AWFS(AWVD)-BXVS
      AWVB = IWVI.EQ.1
      AW1B(IWVI) = IWVI .EQ. 1
      AW2B(IWVI,IWVI) = IWVI .EQ. 1
      AW3B(IWVI,IWVI,IWVI) = IWVI.EQ.1
      AWVC = AW1C(IWVI) +AW2C(IWVI,IWVI)+AW3C(IWVI,IWVI,IWVI)
      RETURN
C*****    END OF TEST SEGMENT 402
      END
C***********************************************************************
C*****
C*****                       IFI - (403)
C*****
C***********************************************************************
C***** INTEGER FUNCTION OF DOUBLE PRECISION ARGUMENT(TEST 1)
      FUNCTION IFI(AWVD)
      DOUBLE PRECISION AWVD
      IFI=AWVD
      RETURN
      END
C***********************************************************************
C*****
C*****                       JFI - (423)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF COMPLEX ARGUMENT(TEST 2)
      FUNCTION JFI(AWVC,BWVC)
      COMPLEX AWVC,BWVC,CVC
      CVC =AWVC*BWVC
      JFI=AIMAG(CVC)
      RETURN
      END
C***********************************************************************
C*****
C*****                       KFI - (433)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF LOGICAL ARGUMENT(TEST 3)
      FUNCTION KFI(AWVB)
      LOGICAL AWVB
      IF (AWVB) GO TO 4331
4330  IF (.NOT.AWVB) GO TO 4332
      RETURN
4331  KFI = 2
      GO TO 4330
4332  KFI = 0
      RETURN
      END
C***********************************************************************
C*****
C*****                       LFI - (443)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF EXTERNAL PROCEDURE(TEST 4)
      FUNCTION LFI(BWVD,IWFI)
      DOUBLE PRECISION BWVD
      LFI=IWFI(BWVD)
      RETURN
      END
C***********************************************************************
C*****
C*****                       MFI - (453)
C*****
C***********************************************************************
C*****INTEGER FUNCTION OF DIFFERENT TYPES OF ARGUMENTS.USE IS MADE OF
C***** ADJUSTABLE DIMENSION(TEST 5,6,7)
      FUNCTION MFI(AWVS,IWVI,AWVB,AWVC,AWVD,AW1S,AW2S,AW3S,IW1I,IW2I,
     1IW3I,AW1B,AW2B,AW3B,AW1C,AW2C,AW3C,AW1D,AW2D,AW3D,IWFI)
      DOUBLE PRECISION AWVD,AW1D,AW2D,AW3D
      LOGICAL AWVB,AW1B,AW2B,AW3B
      COMPLEX AWVC,AW1C,AW2C,AW3C
      DIMENSION AW1S(IWVI),AW2S(IWVI,IWVI),AW3S(IWVI,IWVI,IWVI) ,
     1          IW1I(IWVI),IW2I(IWVI,IWVI),IW3I(IWVI,IWVI,IWVI) ,
     2          AW1B(IWVI),AW2B(IWVI,IWVI),AW3B(IWVI,IWVI,IWVI),
     3          AW1C(IWVI),AW2C(IWVI,IWVI),AW3C(IWVI,IWVI,IWVI)  ,
     4          AW1D(IWVI),AW2D(IWVI,IWVI),AW3D(IWVI,IWVI,IWVI)
      COMMON BXVS
      MFI =AWVS**IWVI+AW1S(IWVI)**IW1I(IWVI)-AW2S(IWVI,IWVI)**IW2I
     1 (IWVI,IWVI)+AW3S(IWVI,IWVI,IWVI)**IW3I(IWVI,IWVI,IWVI)-AWVD+
     2 AW1D(IWVI)-AW2D(IWVI,IWVI)-AW3D(IWVI,IWVI,IWVI)+BXVS**IWFI(AWVD)
     3 -1.0
      AWVB=IWVI.EQ.1
      AW1B(IWVI) = IWVI .EQ. 1
      AW2B(IWVI,IWVI) = IWVI.EQ.1
      AW3B(IWVI,IWVI,IWVI) = IWVI.EQ.1
      AWVC = AW1C(IWVI) +AW2C(IWVI,IWVI)+AW3C(IWVI,IWVI,IWVI)
      RETURN
      END
C***********************************************************************
C*****
C*****                       AFC - (404)
C*****
C***********************************************************************
C*****COMPLEX FUNCTION OF REAL ARGUMENT (TEST 1)
      COMPLEX FUNCTION AFC(AWVS)
      AFC = (-1.0,0.0)+AWVS
      RETURN
      END
C***********************************************************************
C*****
C*****                       BFC - (414)
C*****
C***********************************************************************
C*****COMPLEX FUNCTION OF INTEGER ARGUMENT (TEST 2)
      COMPLEX FUNCTION BFC(IWVI)
      BFC=(1.0,1.0)**IWVI
      RETURN
      END
C***********************************************************************
C*****
C*****                       CFC - (424)
C*****
C***********************************************************************
C*****COMPLEX FUNCTION OF ARRAY NAME (TEST 3)
      COMPLEX FUNCTION CFC(AW1S)
      DIMENSION AW1S(2)
      CFC = (2.0,0.0)-AW1S(1)-AW1S(2)
      RETURN
      END
C***********************************************************************
C*****
C*****                       DFC - (434)
C*****
C***********************************************************************
C*****COMPLEX FUNCTION OF DOUBLE PRECISION ARGUMENT (TEST 4)
      COMPLEX FUNCTION DFC(AWVD)
      DOUBLE PRECISION AWVD
      AVS  = AWVD
      DFC = (1.0,1.0) * AVS - (1.0,1.0)
      RETURN
      END
C***********************************************************************
C*****
C*****                       EFC - (444)
C*****
C***********************************************************************
C*****COMPLEX FUNCTION OF COMPLEX ARGUMENT (TEST 5)
      COMPLEX FUNCTION EFC(AWVC)
      COMPLEX AWVC
      EFC=AWVC- (1.0,1.0)
      RETURN
      END
C***********************************************************************
C*****
C*****                       FFC - (454)
C*****
C*****COMPLEX FUNCTION OF LOGICAL ARGUMENT(TESTS 6,7)
      COMPLEX FUNCTION FFC(AWVB)
      LOGICAL AWVB
      IF (AWVB) GO TO 4541
4540  IF (.NOT.AWVB) GO TO 4542
      RETURN
4541  FFC = (1.0,1.0)
      GO TO 4540
4542  FFC = (0.0,0.0)
      RETURN
      END
C***********************************************************************
C*****
C*****                       HFC - (464)
C*****
C***********************************************************************
C*****COMPLEX FUNCTION OF DIFFERENT TYPES OF ARGUMENTS (TESTS 8,9,10
      COMPLEX FUNCTION  HFC(AWVS,IWVI,AWVB,AWVC,AWVD,AW1S,AW2S,AW3S,
     1 IW1I,IW2I,IW3I,AW1B,AW2B,AW3B,AW1C,AW2C,AW3C,AW1D,AW2D,AW3D,AWFC)
       DIMENSION AW1S(IWVI),AW2S(IWVI,IWVI),AW3S(IWVI,IWVI,IWVI),
     1           IW1I(IWVI),IW2I(IWVI,IWVI),IW3I(IWVI,IWVI,IWVI),
     2           AW1B(IWVI),AW2B(IWVI,IWVI),AW3B(IWVI,IWVI,IWVI),
     3           AW1C(IWVI),AW2C(IWVI,IWVI),AW3C(IWVI,IWVI,IWVI),
     4           AW1D(IWVI),AW2D(IWVI,IWVI),AW3D(IWVI,IWVI,IWVI)
      COMMON BXVS
      LOGICAL AWVB,AW1B,AW2B,AW3B
      COMPLEX AWVC,AW1C,AW2C,AW3C, AWFC
      DOUBLE PRECISION AWVD,AW1D,AW2D,AW3D
      HFC = AWVC
      BXVS=AWVS**IWVI+AW1S(IWVI)**IW1I(IWVI)-AW2S(IWVI,IWVI)**IW2I
     1 (IWVI,IWVI)+AW3S(IWVI,IWVI,IWVI)**IW3I(IWVI,IWVI,IWVI)-AWVD+
     2 AW1D(IWVI)-AW2D(IWVI,IWVI)-AW3D(IWVI,IWVI,IWVI)
      AWVB = IWVI.EQ.1
      AW1B(IWVI) = IWVI.EQ.1
      AW2B(IWVI,IWVI) = IWVI .EQ. 1
      AW3B(IWVI,IWVI,IWVI) = IWVI.EQ.1
      RETURN
C*****    END OF TEST SEGMENT 464
      END
