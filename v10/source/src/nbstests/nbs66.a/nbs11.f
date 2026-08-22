C*****    PART11    ****************************************************
C*****
C*****    ANSI FORTRAN   (X3.9-1966)     TEST PROGRAMS
C*****
C*****    PREPARED BY THE NATIONAL BUREAU OF STANDARDS      VERSION 3
C*****
C*****    JUNE 1973
C*****
C*****    PART 11 OF 14 PARTS
C*****
C*****    SEGMENTS INCLUDED
C*****
C*****      DPFCP - 165 DOUBLE PRECISION FUNCTIONS
C*****
C*****        AFD - 405   REAL ARGUMENT
C*****
C*****        BFD - 415   INTEGER ARGUMENT
C*****
C*****        CFD - 425   D.P. ARGUMENT
C*****
C*****        DFD - 435   COMPLEX ARGUMENTS
C*****
C*****        EFD - 445   LOGICAL ARGUMENT
C*****
C*****        FFD - 455   EXTERNAL PROCEDURE
C*****
C*****        GFD - 465   ARRAY NAME
C*****
C*****        HFD - 475   DIFFERENT TYPES OF ARGUMENTS
C*****
C*****      BFCCP - 166 LOGICAL FUNCTIONS
C*****
C*****        AFB - 406   REAL ARGUMENT
C*****
C*****        BFB - 416   INTEGER ARGUMENT
C*****
C*****        CFB - 426   D.P. ARGUMENT
C*****
C*****        DFB - 436   LOGICAL ARGUMENT
C*****
C*****        EFB - 446   COMPLEX ARGUMENT
C*****
C*****        FFB - 456   ARRAY NAME
C*****
C*****        GFB - 466   EXTERNAL PROCEDURE
C*****
C*****        HFB - 476   DIFFERENT TYPES OF ARGUMENTS
C*****
C*****      SBRTN - 167  SUBROUTINE SUBPROGRAM
C*****
C*****        AAQ - 407  INTEGER AND REAL VARIABLES AND ARRAY ELEMENTS
C*****
C*****        ABQ - 417  ARRAY ELEMENTS
C*****
C*****        ACQ - 427  NO ARGUMENT LIST
C*****
C*****      FSBRT - 168 SUBROUTINE SUBPROGRAM
C*****
C*****        ADQ - 408   DIFFERENT TYPES OF ARGUMENTS
C*****
C*****        AEQ - 418   ARRAY NAMES AND INTEGER ARGUMENTS
C*****
C*****        AFQ - 428   NO ARGUMENT LIST
C*****
C*****      BLKDT - 169 BLOCK DATA
C*****
C*****        BLOKD - 409   BLOCK DATA SUBPROGRAM
C*****
C*****  THE FOLLOWING SPECIFICATIONS ARE TO BE USED ONLY WHEN
C*****  SEGMENTS 165, 166, 167, 168, 169  ARE RUN AS ONE MAIN PROGRAM.
C*****
      DIMENSION A1S(5), A2S(2,2), A3S(3,3,3)
      DIMENSION IAB1I(4), IAB2I(3,3), IAB3I(2,2,2), AB1S(4)
     1  ,AB2S(3,3), AB3S(2,2,2)
      INTEGER I1I(5), I2I(2,2), I3I(2,2,2)
      DOUBLE PRECISION AVD, A1D(4),A2D(2,2),A3D(2,2,2)
      DOUBLE PRECISION AFD,BFD,CFD,DFD,EFD,FFD,GFD,HFD
      DOUBLE PRECISION AXVD, AX1D, AX2D,AX3D
     1  ,DXVD,DX1D,DX2D,DX3D
      LOGICAL A1B(2), A2B(2,2), A3B(2,2,2),AXVB, AX1B, AX2B, AX3B,AVB
     1  ,BVB,AFB,BFB,CFB,DFB,EFB,FFB,GFB,HFB , DXVB,DX1B,DX2B,DX3B
      COMPLEX AVC,A1C(12),A2C(2,2), A3C(2,2,1)
      COMPLEX AXVC, AX1C, AX2C, AX3C,DXVC, DX1C, DX2C, DZ3C
      COMMON AXVS,CXVS
      COMMON      IXVI,IAX1I(4),IAX2I(3,3),IAX3I(2,2,2),BXVS,
     -     AX1S(4),AX2S(3,3),AX3S(2,2,2),AXVD,AX1D(2),AX2D(2,2),
     B        AX3D(2,2,2), AXVC, AX1C(2), AX2C(2,2), AX3C(2,2,2), AXVB,
     C        AX1B(2), AX2B(2,2), AX3B(2,2,2)
      COMMON /BLK1/JXVI, JAX1I(2), JAX2I(3,3)
     A       /BLK2/DXVS, DX1S(2), DX2S(2,2)
     B       /BLK3/DXVD, DX1D(2), DX2D(2,2)
     C       /BLK4/DXVC, DX1C(2), DX2C(2,2)
     D       /BLK5/DXVB, DX1B(2), DX2B(2,2)
     E       /BLK6/JAX3I(2,2,2), DX3S(2,2,2), DX3D(2,2,2),
     F             DZ3C(2,2,2), DX3B(2,2,2)
      EXTERNAL AFB,CFD,AFD
      INTRINSIC SQRT
C*****  END OF SPECIFICATIONS FOR SEGMENTS
C*****  165, 166, 167, 168, 169
C*****
C***********************************************************************
C*****
C*****                             DPFCP-(165)
C*****
C***********************************************************************
C*****                         GENERAL PURPOSE
C*****    1.TO TEST DOUBLE PRECISION FUNCTIONS IN FULL FORTRAN     8.3.1
C*****    2.DUMMY ARGUMENTS ARE REAL,INTEGER,COMPLEX,LOGICAL,
C*****    DOUBLE PRECISION,EXTERNAL PROCEDURE,ARRAY NAME
C*****    3.FUNCTIONS CONTAIN UP TO 20 ARGUMENTS
C*****    4.IN REFERENCE,ACTUAL ARGUMENTS ARE VARIABLE1NAME,
C*****     ARRAY NAME,ARRAY ELEMENT NAME,OR ARITHMETIC EXPRESSION. 8.3.2
C*****RESTRICTIONS OBSERVED
C*****    1.ITEMS(2),(3),(4),(5),(6) OF PARAGRAPH 8.3.1
C*****    2 LAST SENTENCE  OF PARAGRAPH 3.2
C*****     THIS SEGMENT IS TO BE RUN WITH SEGMENTS
C*****     405, 415, 425, 435, 445, 455, 465, 475          WHICH
C*****    WHICH  CONTAINS ALL FUNCTIONS BEING TESTED HERE
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 165
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 165, REMOVE THE PRECEDING
C*****  SPECIFICATIONS.  THE FOLLOWING SPECIFICATIONS WHICH
C*****  APPEAR AS COMMENTS MUST HAVE THE C=  IN COLUMNS 1 AND 2 REMOVED.
C*****
C=    DIMENSION A1S(5),A2S(2,2),A3S(3,3,3)
C=    INTEGER I1I(5),I2I(2,2),I3I(2,2,2)
C=    LOGICAL A1B(2),A2B(2,2),A3B(2,2,2),AVB,BVB
C=    DOUBLE PRECISION AFD, BFD, CFD, DFD, EFD, FFD, GFD, HFD,AVD
C=   1, A1D(4),A2D(2,2),A3D(2,2,2)
C=    COMPLEX AVC,A1C(12),A2C(2,2),A3C(2,2,1)
C=    COMMON AXVS,CXVS
C=     EXTERNAL  CFD,AFD
C*****
C*****  I N P U T  O U T P U T  T A P E  ASSIGNMENT STATEMENTS
      IRVI = 5
      NUVI = 6
C*****  IDENTIFY THE SOURCE OF THE TEST PROGRAMS
      WRITE(NUVI,0071)
0071  FORMAT (41H1 F O R T R A N  T E S T  P R O G R A M S//
     1 42H  PREPARED BY NATIONAL BUREAU OF STANDARDS//
     3 37H  FOR USE ON LARGE FORTRAN PROCESSORS  //
     4 42H  IN ACCORDANCE WITH ASA FORTRAN X3.9-1966//
     5 23H  VERSION 3     PART 11///)
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
C*****
      WRITE (NUVI,1650)
 1650 FORMAT(1H1,1X,30HDPFCP - (165) DOUBLE PRECISION/ 16X, 9HFUNCTIONS
     1 //2X,21HASA REFS. 8.3.1,8.3.2//2X, 7HRESULTS)
C***** TEST 1
      MAVI = 1
      IVI = AFD(1.0) - 1.0D0
       IF (IVI)  1652,1653,1652
C***** TEST 2
 1657 MAVI =2
      IVI=BFD(1)-1.0D0
      IF(IVI)1652,1653,1652
C***** TEST 3
 1658 MAVI =3
       AVD=1.0D0
	print *, 'TEST 3 ivi=',CFD(AVD)-1.0D0
       IF(IVI) 1652,1653,1652
C***** TEST 4 .ONE ARGUMENT IS ARRAY ELEMENT NAME
 1659 MAVI =4
      AVC = (1.0,1.0)
      A1C(1)=(1.0,-1.0)
      IVI=DFD(AVC,A1C(1))
      IF (IVI) 1652,1653,1652
C***** TEST 5,6
 7014 MAVI =5
      AVB=.TRUE.
      IVI=EFD(AVB)-1.0D0
      IF(IVI)1652,1653,1652
 7015 MAVI = 6
      AVB=.FALSE.
      IVI=EFD(AVB)
      IF(IVI)1652,1653,1652
C***** TEST 7
 7016 MAVI = 7
      IVI = FFD (1.E0,AFD) - 1.0D0
      IF (IVI) 1652,1653,1652
C***** TEST 8
 7017 MAVI = 8
      A1D(1)=1.0D0
      A1D(2)=-1.0D0
      IVI=GFD(A1D)
      IF (IVI) 1652,1653,1652
C***** TESTS 9,10,11,12
 7018 IAVI = 1
      AVD=1.0D0
      A1D(1)=1.0D0
      A2D(1,1)=1.0D0
      A3D(1,1,1)= 1.0D0
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
      MAVI = 9
      IVI=HFD(AVS,IAVI,AVB,AVC,AVD,A1S,A2S,A3S,I1I,I2I,I3I ,A1B,A2B,A3B,
     1A1C,A2C,A3C,A1D,A2D,A3D,CFD)
      IF (IVI)   1652,1653,1652
 7019 MAVI = 10
      IVI=AXVS
      IF (IVI) 1652,1653,1652
 7020 MAVI = 11
      WRITE (NUVI,1656) AVC,MAVI
1656  FORMAT(//2F5.1//2X,5HTEST ,I2,31H IS POSITIVE IF NUMBERS PRINTED/
     1 2X,17HABOVE ARE 0.0,0.0)
 7021 MAVI = 12
      BVB = AVB.AND.A1B(1).AND.A2B(1,1).AND.A3B(1,1,1)
      IF(BVB) GO TO 1653
 1652 WRITE(NUVI,1654)MAVI
      GO TO 1651
 1653 WRITE(NUVI,1655)MAVI
 1654 FORMAT(/2X,5HTEST ,I2,12H IS NEGATIVE)
 1655 FORMAT(/2X,5HTEST ,I2,12H IS POSITIVE)
 1651 GO TO (1657,1658,1659,7014,7015,7016,7017,7018,7019,7020,7021,
     1 7022) ,MAVI
 7022 CONTINUE
C*****    END OF TEST SEGMENT 165
C*****  WHEN EXECUTING ONLY SEGMENT 165, THE  STOP  AND  END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                      BFCCP-(166)
C*****
C***********************************************************************
C*****                     GENERAL PURPOSE
C*****    1.TO TEST LOGICAL FUNCTIONS IN FULL FORTRAN
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
C*****     THIS SEGMENT IS TO BE RUN WITH SEGMENTS
C*****     406, 416, 426, 436, 446, 456, 466, 476          WHICH
C*****    CONTAINS ALL FUNCTIONS BEING TESTED HERE.
C*****LOGICAL FUNCTION OF REAL ARGUMENT(TEST 1)
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 166
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 166, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    DIMENSION A1S(5),A2S(2,2),A3S(3,3,3)
C=    INTEGER I1I(5),I2I(2,2),I3I(2,2,2)
C=    LOGICAL AVB,AFB,BFB,CFB,DFB,EFB,FFB,GFB,HFB
C=   1, A1B(2),A2B(2,2),A3B(2,2,2)
C=    DOUBLE PRECISION AVD,A1D(4),A2D(2,2),A3D(2,2,2)
C=    COMPLEX AVC,A1C(12),A2C(2,2),A3C(2,2,1)
C=    COMMON AXVS,CXVS
C=     EXTERNAL AFB
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 166, THE FOLLOWING STATEMENT
C*****  NUVI  =  6  MUST HAVE THE C= IN COLUMNS 1  AND  2  REMOVED.
C=    NUVI = 6
      MAVI=1
      WRITE(NUVI,1662)
 1662 FORMAT(1H1,1X,31HBFCCP - (166) LOGICAL FUNCTIONS//2X,
     1 13HASA REF 8.3.1//2X,7HRESULTS)
      AVB=AFB(1.0)
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
      GO TO 1665
1660  FORMAT (/7H  TEST ,I2,12H IS POSITIVE)
1661  FORMAT (/7H  TEST ,I2,12H IS NEGATIVE)
1664  WRITE(NUVI,1660) MAVI
      GO TO (1665,1666,1667,1668,1669,7030,7031,7032,7033,7034), MAVI
C***** LOGICAL FUNCTION OF INTEGER ARGUMENT (TEST 2)
1665  MAVI=2
      AVB=BFB(1)
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
C*****LOGICAL FUNCTION OF DOUBLE PRECISION ARGUMENT(TEST 3)
1666  MAVI=3
      AVD=1.0D0
      AVB=CFB(AVD)
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
C***** LOGICAL FUNCTION OF LOGICAL ARGUMENT(TEST 4)
1667  MAVI=4
      AVB=DFB(.TRUE.)
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
C*****LOGICAL FUNCTION OF COMPLEX ARGUMENT(TEST 5)
1668  MAVI=5
      AVB=EFB((1.0,1.0))
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
C***** LOGICAL FUNCTION OF ARRAY NAME (TEST 6)
1669   MAVI=6
       A1S(1)=1.0
       A1S(2)=0.0
       AVB=FFB(A1S)
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
C***** LOGICAL FUNCTION OF EXTERNAL PROCEDURE(TEST 7)
7030   MAVI=7
      AVB= GFB(AFB,1.0)
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
C*****LOGICAL FUNCTION OF DIFFERENT TYPES OF ARGUMENTS
7031  MAVI=8
      AVD = 1.0D0
      AVC = (1.0,1.0)
      IAVI = 1
      AVB=.TRUE.
      A1B(1)=.TRUE.
      A2B(1,1)=.TRUE.
      A3B(1,1,1)=.TRUE.
      A1C(1)=(1.0,1.0)
      A2C(1,1)=(1.0,1.0)
      A3C(1,1,1)=(-2.0,-2.0)
      A1D(1)=1.0D0
      A2D(1,1)=1.0D0
      A3D(1,1,1)=-2.0D0
      I1I(1)=1
      I2I(1,1)=1
      I3I(1,1,1)=1
      A1S(1)=1.0
      A2S(1,1)=1.0
      A3S(1,1,1)=1.0
      AXVS=1.0
      AVB= HFB(AVS,IAVI,AVB,AVD,AVC,A1S,A2S,A3S,I1I,I2I,I3I,A1B,A2B,
     1A3B,A1C,A2C,A3C,A1D,A2D,A3D,AFB)
      IF (AVB) GO TO 1664
      WRITE(NUVI,1661) MAVI
7032  MAVI = 9
      IAVI=AVD
      IF(IAVI.EQ.0) GO TO 1664
      WRITE(NUVI,1661) MAVI
7033  IAVI=1
      MAVI=10
      IAVI=AVS
      IF(IAVI.EQ.0) GO TO 1664
      WRITE(NUVI,1661) MAVI
7034  MAVI=11
      WRITE(NUVI,1663) AVC,MAVI
1663  FORMAT (//2F8.4//7H  TEST ,I2,31H IS POSITIVE IF NUMBERS PRINTED/
     119H  ABOVE ARE 0.0,0.0//2X,12HEND OF (166))
C*****    END OF TEST SEGMENT 166
C*****  WHEN EXECUTING ONLY SEGMENT 166, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C= IN
C***** COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       SBRTN - (167)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                         ASA REFS
C*****    TO TEST SUBROUTINE SUBPROGRAMS                         8.4.1
C*****  RESTRICTIONS OBSERVED
C*****    SYMBOLIC NAME OF A SUBROUTINE MAY NOT APPEAR IN ANY 8.4.1.//19
C*****    STATEMENT IN THIS SUBROUTINE EXCEPT IN THE
C*****    SUBROUTINE STATEMENT ITSELF
C*****  * SYMBOLIC NAMES OF DUMMY ARGUMENTS MAY NOT APPEAR    8.4.1.1/23
C*****    IN EQUIVALENCE OR COMMON STATEMENTS IN THE SUBPROGRAM
C*****  * SUBROUTINES MAY NOT CONTAIN A FUNCTION STATEMENT,   8.4.1.//29
C*****    ANOTHER SUBROUTINE STATEMENT, OR ANY STATEMENT THAT
C*****    DIRECTLY OR INDIRECTLY REFERENCES THE SUBROUTINE
C*****    BEING DEFINED.
C*****  * AT LEAST ONE RETURN STATEMENT MUST BE IN A SUBROUTINE
C*****                                                        8.4.1.1/33
C*****  GENERAL COMMENTS
C*****    THIS SEGMENT IS TO BE RUN WITH SEGMENT 407, 417, 427
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 167
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 167, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    DIMENSION IAB1I(4), IAB2I(3,3), AB1S(4), AB2S(3,3)
C=    COMMON AXVS, CXVS, IXVI, IAX1I(4), IAX2I(3,3), IAX3I(2,2,2),
C=   1       BXVS, AX1S(4), AX2S(3,3)
C=    EXTERNAL SQRT
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 167, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C= IN COLUMNS 1 AND 2 REMOVED.
C=    NUVI = 6
C*****
C*****    WRITE HEADING
      WRITE (NUVI,1670)
1670  FORMAT(1H1,1X,35HSBRTN - (167) SUBROUTINE SUBPROGRAM/
     1 /2X,16HASA REF. - 8.4.1//2X,7HRESULTS)
C*****    SET ALL VARIABLES AND SOME ELEMENTS IN ARRAYS TO ZERO
      IAVI = 4
      AVS = 0.0
      IAB1I(1) = 0
      IAB1I(3) = 0
      IAB2I(1,2) = 0
      IAB2I(3,3) = 0
C*****
      AB1S(1) = 0.0
      AB1S(4) = 0.0
      AB2S(1,3) = 0.0
      AB2S(2,3) = 0.0
C*****
      IXVI = 0
      BXVS = 0.0
      IAX1I(2) = 0
      IAX2I(1,2) = 0
C*****
      AX1S(2) = 0.0
      AX2S(1,2) = 0.0
C*****
C*****    SET ELEMENTS IN INTEGER AND REAL ARRAY TO 1 TO TEST
C*****    EXPRESSIONS IN SUBROUTINE ARGUMENT
      IAB1I(2) = 1
      IAB1I(4) = 1
      IAB2I(2,1) = 1
      IAB2I(2,2) = 1
C*****
      AB1S(2) = 1.0
      AB1S(3) = 1.0
      AB2S(1,2) = 1.0
      AB2S(2,2) = 1.0
C*****
      CALL  AAQ(IAVI, AVS, IAB1I, IAB2I, AB1S, AB2S, SQRT,
     1IAB1I(2)+IAB1I(4)*IAB2I(2,1)-IAB2I(2,2),
     2AB1S(2)+AB1S(3)*AB2S(1,2)-AB2S(2,2),1.0)
      CALL ACQ
C*****    WRITE RESULTS
      WRITE (NUVI,1671) IAVI, AVS, IAB1I(1), IAB1I(3), IAB2I(1,2),
     A                  IAB2I(3,3), AB1S(1), AB1S(4),
     B                  AB2S(1,3), AB2S(2,3), IXVI, BXVS,
     C                  IAX1I(2), IAX2I(1,2), AX1S(2),
     D                  AX2S(1,2)
1671  FORMAT  (//I10/F11.1/4(I10/),4(F11.1/),I10/F11.1/2(I10/),2(F11.1/
     A))
      WRITE (NUVI,1672)
1672  FORMAT (//2X,38HTEST SUCCESSFUL IF ALL RESULTS EQUAL 1//)
C*****    END OF TEST SEGMENT 167
C*****  WHEN EXECUTING ONLY SEGMENT 167, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS, MUST HAVE THE C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       FSBRT - (168)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                         ASA REFS
C*****    TO TEST SUBROUTINE SUBPROGRAM IN FORTRAN               8.4.1
C*****  RESTRICTIONS OBSERVED
C*****    SYMBOLIC NAME OF A SUBROUTINE MAY NOT APPEAR IN ANY 8.4.1.1/56
C*****    STATEMENT IN THIS SUBROUTINE EXCEPT IN THE
C*****    SUBROUTINE STATEMENT ITSELF.
C*****  * SYMBOLIC NAME OF DUMMY ARGUMENTS MAY NOT APPEAR     8.4.1.1/39
C*****    IN EQUIVALENCE OR COMMON STATEMENTS IN THE SUBPROGRAM
C*****  * SUBROUTINES MAY NOT CONTAIN A FUNCTION STATEMENT,   8.4.1.1/45
C*****    ANOTHER SUBROUTINE STATEMENT, OR ANY STATEMENT THAT
C*****    DIRECTLY OR INDIRECTLY REFERENCES THE SUBROUTINE
C*****    BEING DEFINED.
C*****  * AT LEAST ONE RETURN STATEMENT MUST BE IN A SUBROUTINE
C*****                                                        8.4.1.1/49
C*****  GENERAL COMMENTS
C*****    THIS SEGMENT IS TO BE RUN WITH SEGMENT 408 , 418, 428
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 168
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 168, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    DIMENSION IAB1I(4), IAB2I(3,3), IAB3I(2,2,2), AB1S(4), AB2S(3,3),
C=   A          AB3S(2,2,2)
C=    COMMON AXVS, CXVS, IXVI, IAX1I(4), IAX2I(3,3), IAX3I(2,2,2),
C=   A      BXVS, AX1S(4), AX2S(3,3), AX3S(2,2,2), AXVD, AX1D(2),
C=   B      AX2D(2,2), AX3D(2,2,2), AXVC, AX1C(2), AX2C(2,2),
C=   C      AX3C(2,2,2), AXVB, AX1B(2), AX2B(2,2), AX3B(2,2,2)
C=    DOUBLE PRECISION AXVD, AX1D, AX2D, AX3D
C=    DOUBLE PRECISION AVD,A1D(4),A2D(2,2),A3D(2,2,2)
C=    COMPLEX AXVC, AX1C, AX2C, AX3C
C=    COMPLEX AVC,A1C(12),A2C(2,2),A3C(2,2,1)
C=    LOGICAL AXVB, AX1B, AX2B, AX3B
C=    LOGICAL A1B(2),A2B(2,2),A3B(2,2,2),AVB
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 168, THE FOLLOWING STATEMENT
C*****  NUVI  =  6  MUST HAVE THE C= IN COLUMNS 1  AND  2  REMOVED.
C=    NUVI = 6
C*****    SET INTEGER VARIABLES AND SOME ELEMENTS IN ARRAYS TO ZERO
C*****    WRITE HEADING
      WRITE (NUVI,1680)
1680  FORMAT (1H1,1X,36HFSBRT - (168) SUBROUTINE SUBPROGRAMS/
     A/18H  ASA REF. - 8.4.1//2X,7HRESULTS)
      IAVI = 0
      IAB1I(1) = 0
      IAB2I(1,2) = 0
      IAB3I(1,1,2) = 0
      IXVI = 0
      IAX1I(1) = 0
      IAX2I(1,2) = 0
      IAX3I(1,1,2) = 0
C*****    SET REAL VARIABLES AND SOME ELEMENTS IN ARRAYS TO ONE
      AVS = 1.
      AB1S(1) = 1.
      AB2S(1,2) = 1.
      AB3S(1,1,2) = 1.
      BXVS = 1.
      AX1S(2) = 1.
      AX2S(1,2) = 1.
      AX3S(1,1,2) = 1.
C*****    SET DP VARIABLES AND SOME ELEMENTS IN ARRAY TO TWO
      AVD = 2.0D0
      A1D(1) = 2.0D0
      A2D(1,2) = 2.0D0
      A3D(1,1,2) = 2.0D0
      AXVD = 2.0D0
      AX1D(1) = 2.0D0
      AX2D(1,2) = 2.D0
      AX3D(1,1,2) = 2.0D0
C*****    SET COMPLEX VARIABLES AND SOME ELEMENTS IN ARRAYS TO (3.0,3.0)
      AVC = (3.0,3.0)
      A1C(1) = (3.0,3.0)
      A2C(1,2) = (3.0,3.0)
      A3C(1,2,1) = (3.0,3.0)
      AXVC = (3.0,3.0)
      AX1C(1) = (3.0,3.0)
      AX2C(1,2) = (3.0,3.0)
      AX3C(1,1,2) = (3.0,3.0)
C*****    SET LOGICAL VARIABLES AND SOME ELEMENTS IN ARRAYS TO .FALSE.
      AVB = .FALSE.
      A1B(1) = .FALSE.
      A2B(1,2) = .FALSE.
      A3B(1,1,2) = .FALSE.
      AXVB = .FALSE.
      AX1B(1) = .FALSE.
      AX2B(1,2) = .FALSE.
      AX3B(1,1,2) = .FALSE.
C*****    SET INTEGER AND REAL VARIABLES FOR EXPRESSION USAGE IN
C*****    DUMMY ARGUMENT
      IAB1I(4) = 0
      IAB1I(2) = 0
      AB1S(4) = 0.0
      AB1S(2) = 0.0
      JAVI = 1
      KAVI = 1
      LAVI = 1
      MAVI = 1
      NAVI = 1
      ABVS = 1.
      ACVS = 1.
      ADVS = 2.
      AEVS = 2.
      AFVS = 2.
      CALL ADQ(IAVI,IAB1I, IAB2I, IAB3I, AVS, AB1S, AB2S, AB3S, AVD,
     A         A1D, A2D, A3D, AVC, A1C, A2C, A3C, AVB, A1B, A2B, A3B,
     B         JAVI+KAVI*LAVI-MAVI/NAVI,1,ABVS+ACVS*ADVS-AEVS/AFVS,2.)
      WRITE (NUVI,1681)
      CALL AFQ
1681  FORMAT ( /28H  TEST IS SUCCESSFUL IF EACH/
     A28H  GROUP CONTAINS SAME VALUES)
      WRITE (NUVI,1682) IAVI, IAB1I(1), IAB1I(2), IAB1I(4), IAB2I(1,2),
     A                  IAB3I(1,1,2), IXVI, IAX1I(1), IAX2I(1,2),
     B                  IAX3I(1,1,2), AVS, AB1S(1), AB2S(1,2), AB3S(1,1,
     C2),AB1S(2),AB1S(4),   BXVS, AX1S(2), AX2S(1,2), AX3S(1,1,2), AVD,
     D                  A1D(1), A2D(1,2), A3D(1,1,2), AXVD, AX1D(1),
     E                  AX2D(1,2), AX3D(1,1,2), AVC, A1C(1), A2C(1,2),
     F                  A3C(1,2,1), AXVC, AX1C(1), AX2C(1,2),
     G                  AX3C(1,1,2), AVB, A1B(1), A2B(1,2), A3B(1,1,2),
     H                  AXVB, AX1B(1), AX2B(1,2), AX3B(1,1,2)
1682  FORMAT (  10(I10/)/
     1            10(F11.1/)/
     2             8(1PD15.1/)/
     3             8(0PF5.1,F5.1/)/
     4             8(L10/) )
C*****    END OF TEST SEGMENT 168
C*****  WHEN EXECUTING ONLY SEGMENT 168, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C= IN
C***** COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       BLKDT - (169)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                         ASA REFS
C*****    TO TEST BLOCK DATA SUBPROGRAM                           8.5
C*****  GENERAL COMMENTS
C*****    THIS SEGMENT IS TO BE RUN WITH SEGMENT 409.  THIS
C*****    SEGMENT WRITES OUT THE DATA FORMED IN SEGMENT 409.
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 169
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 169, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    COMMON /BLK1/JXVI, JAX1I(2), JAX2I(3,3)
C=   A       /BLK2/DXVS, DX1S(2), DX2S(2,2)
C=   B       /BLK3/DXVD, DX1D(2), DX2D(2,2)
C=   C       /BLK4/DXVC, DX1C(2), DX2C(2,2)
C=   D       /BLK5/DXVB, DX1B(2), DX2B(2,2)
C=   E       /BLK6/JAX3I(2,2,2), DX3S(2,2,2), DX3D(2,2,2),
C=   F             DZ3C(2,2,2), DX3B(2,2,2)
C=    DOUBLE PRECISION DXVD, DX1D, DX2D, DX3D
C=    COMPLEX          DXVC, DX1C, DX2C, DZ3C
C=    LOGICAL          DXVB, DX1B, DX2B, DX3B
C*****
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 169, THE FOLLOWING STATEMENT
C*****  NUVI  =  6  MUST HAVE THE C= IN COLUMNS 1  AND  2  REMOVED.
C=    NUVI = 6
C*****    WRITE HEADING FOR SEGMENT 169
      WRITE (NUVI,1690)
1690  FORMAT (1H1,1X,35HBLKDT - (169) BLOCK DATA SUBPROGRAM//
     A16H  ASA REF. - 8.5//2X,7HRESULTS)
      WRITE (NUVI,1691)
1691  FORMAT ( /28H  TEST IS SUCCESSFUL IF EACH/
     A28H  GROUP CONTAINS SAME VALUES)
      WRITE (NUVI,1692) JAX2I(1,1), JAX1I(2), JAX2I(2,1), JAX3I(2,2,1)
     A     ,DX3S(1,2,1), DX1S(1), DX2S(1,1), DX3S(2,2,1), DX2D(2,2)
     B     ,DX1D(2), DX2D(2,1), DX3D(2,2,1), DX2C(2,2), DX1C(2)
     C     ,DX2C(2,1), DZ3C(2,1,1), DX2B(2,2),  DX1B(2), DX2B(2,1)
     D     ,DX3B(2,2,1), JAX2I(3,1),
     E     DX3B(2,1,2), DX2S(2,2)
1692  FORMAT (// 4(I10/)//
     A             4(F12.1/)//
     B             4(1PD16.1/)//
     C             4(0PF6.1,F6.1/)//
     D             4(L10/)//
     F             3(2H  ,A2/))
C*****    END OF TEST SEGMENT 169
C*****  WHEN EXECUTING ONLY SEGMENT 169, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C= IN
C***** COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
      STOP
      END
C***********************************************************************
C*****
C*****                       AFD - (405)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF REAL ARGUMENT (TEST 1)
      DOUBLE PRECISION FUNCTION  AFD(AWVS)
      AFD=AWVS
      RETURN
      END
C***********************************************************************
C*****
C*****                       BFD -(415)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF INTEGER ARGUMENT(TEST2)
      DOUBLE PRECISION FUNCTION BFD(IWVI)
      BFD=1.0D0**IWVI
      RETURN
      END
C***********************************************************************
C*****
C*****                       CFD - (425)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF DOUBLE PRECISION ARGUMENT(TEST 3)
      DOUBLE PRECISION FUNCTION CFD(AWVD)
      DOUBLE PRECISION AWVD
      CFD=AWVD
      RETURN
      END
C***********************************************************************
C*****
C*****                       DFD -(435)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF COMPLEX ARGUMENT(TEST 4)
      DOUBLE PRECISION FUNCTION DFD(AWVC,BWVC)
      COMPLEX AWVC,BWVC,CVC
      CVC =BWVC*AWVC
      DFD=AIMAG(CVC)
      RETURN
      END
C***********************************************************************
C*****
C*****                       EFD - (445)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF LOGICAL ARGUMENT(TEST 5,6)
      DOUBLE PRECISION FUNCTION EFD(AWVB)
      LOGICAL AWVB
      IF(AWVB) GO TO 4451
4450  IF(.NOT.AWVB) GO TO 4452
      RETURN
4451  EFD = 1.0D0
      GO TO 4450
4452  EFD = 0.0D0
      RETURN
      END
C***********************************************************************
C*****
C*****                       FFD - (455)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF EXTERNAL PROCEDURE (TEST 7)
      DOUBLE PRECISION FUNCTION FFD(BWVS,BWFD)
      DOUBLE PRECISION      BWFD
      FFD = BWFD (BWVS)
      RETURN
      END
C***********************************************************************
C*****
C*****                       GFD - (465)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF  ARRAY NAME (TEST 8)
      DOUBLE PRECISION FUNCTION GFD(AW1D)
      DIMENSION AW1D(2)
      DOUBLE PRECISION AW1D
      GFD= AW1D(1)+AW1D(2)
      RETURN
      END
C*****
C*****
C*****                       HFD - (475)
C*****
C***********************************************************************
C*****DOUBLE PRECISION FUNCTION OF DIFFERENT TYPES OF ARGUMENTS.USE CAN
C*****BE MADE OF ADJUSTABLE DIMENSION.SOME ARGUMENTS CAN BE PASSED
C*****THROUGH A COMMON STATEMENT.
      DOUBLE PRECISION FUNCTION HFD(AWVS,IWVI,AWVB,AWVC,AWVD,AW1S,AW2S,
     1 AW3S,IW1I,IW2I,IW3I,AW1B,AW2B,AW3B,AW1C,AW2C,AW3C,AW1D,AW2D,
     2 AW3D,CWFD)
       DIMENSION  AW1S(IWVI),AW2S(IWVI,IWVI),AW3S(IWVI,IWVI,IWVI),
     1            IW1I(IWVI),IW2I(IWVI,IWVI),IW3I(IWVI,IWVI,IWVI),
     2            AW1C(IWVI),AW2C(IWVI,IWVI),AW3C(IWVI,IWVI,IWVI),
     3            AW1D(IWVI),AW2D(IWVI,IWVI),AW3D(IWVI,IWVI,IWVI),
     4            AW1B(IWVI),AW2B(IWVI,IWVI),AW3B(IWVI,IWVI,IWVI)
      DOUBLE PRECISION  AWVD,AW1D,AW2D,AW3D, CWFD, X
      COMPLEX AWVC,AW1C,AW2C,AW3C
      REAL AW1S, AW2S, AW3S
      LOGICAL  AWVB,AW1B,AW2B,AW3B
      COMMON BXVS
      X = AWVD - AW1D(IWVI)+AW2D(IWVI,IWVI)-AW3D(IWVI,IWVI,IWVI)
      HFD = X
	print *, 'TRACER X=',X ,AWVD , AW1D(IWVI),AW2D(IWVI,IWVI)
     1 ,AW3D(IWVI,IWVI,IWVI)
     1 + CWFD(AWVD) - 1.0D0
      AWVC=AW1C(IWVI)+AW2C(IWVI,IWVI)-AW3C(IWVI,IWVI,IWVI)-(1.0,1.0)
      BXVS=AWVS**IWVI-AW1S(IWVI)**IW1I(IWVI)+AW2S(IWVI,IWVI)**IW2I
     1  (IWVI,IWVI)-AW3S(IWVI,IWVI,IWVI)**IW3I(IWVI,IWVI,IWVI)
       AWVB=IWVI.EQ.1
      AW1B(IWVI)=IWVI.EQ.1
      AW2B(IWVI,IWVI)=IWVI.EQ.1
      AW3B(IWVI,IWVI,IWVI)=IWVI.EQ.1
      RETURN
      END
C***********************************************************************
C*****
C*****                       AFB - (406)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF REAL ARGUMENT (TEST 1)
      LOGICAL FUNCTION AFB(AWVS)
      AFB= AWVS.GT.0.0
      RETURN
      END
C***********************************************************************
C*****
C*****                       BFB - (416)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF INTEGER ARGUMENT (TEST 2)
      LOGICAL FUNCTION BFB(IWVI)
      BFB= IWVI.GT.0
      RETURN
      END
C***********************************************************************
C*****
C*****                       CFB - (426)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF DOUBLE PRECISION ARGUMENT(TEST 3)
      LOGICAL FUNCTION CFB(AWVD)
      DOUBLE PRECISION AWVD
      CFB= AWVD.GT.0.0D0
      RETURN
      END
C***********************************************************************
C*****
C*****                       DFB - (436)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF LOGICAL ARGUMENT (TEST 4)
      LOGICAL FUNCTION DFB(AWVB)
      LOGICAL AWVB
      DFB=AWVB
      RETURN
      END
C***********************************************************************
C*****
C*****                       EFB - (446)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF COMPLEX ARGUMENT (TEST 5)
      LOGICAL FUNCTION EFB(AWVC)
      COMPLEX AWVC
      AVS =AIMAG(AWVC)
      EFB = AVS .GT.0.0
      RETURN
      END
C***********************************************************************
C*****
C*****                       FFB - (456)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF ARRAY NAME (TEST 6)
      LOGICAL FUNCTION FFB(AW1S)
      DIMENSION AW1S(2)
      BVS =AW1S(1)+AW1S(2)
      FFB= BVS .GT.0.0
      RETURN
      END
C***********************************************************************
C*****
C*****                       GFB - (466)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF EXTERNAL PROCEDURE (TEST 7)
      LOGICAL FUNCTION  GFB(AWFB,AWVS)
      LOGICAL AWFB
      GFB= AWFB(AWVS)
      RETURN
      END
C***********************************************************************
C*****
C*****                       HFB - (476)
C*****
C***********************************************************************
C*****LOGICAL FUNCTION OF DIFFERENT TYPES OF ARGUMENTS(TEST 8,9,10,11)
      LOGICAL FUNCTION HFB(AWVS,IWVI,AWVB,AWVD,AWVC,AW1S,AW2S,AW3S,
     1IW1I,IW2I,IW3I,AW1B,AW2B,AW3B,AW1C,AW2C,AW3C,AW1D,AW2D,AW3D,AWFB)
      COMMON BXVS
      COMPLEX AWVC,AW1C,AW2C,AW3C
      DOUBLE PRECISION AWVD,AW1D,AW3D, AW2D
      LOGICAL AWVB,AW1B,AW2B,AW3B,AWFB
      DIMENSION   AW1C(IWVI),AW2C(IWVI,2),AW3C(IWVI,2,2),
     1            AW1B(IWVI),AW2B(IWVI,2),AW3B(IWVI,2,2)    ,
     2            AW1S(IWVI),AW2S(IWVI,2),AW3S(IWVI,2,2)    ,
     3            AW1D(IWVI),AW2D(IWVI,2),AW3D(IWVI,2,2)    ,
     4            IW1I(IWVI),IW2I(IWVI,2),IW3I(IWVI,2,2)
      HFB = AWVB.AND.AW1B(IWVI).AND.AW2B(IWVI,IWVI).AND.AW3B(IWVI,
     1 IWVI,IWVI).AND.AWFB(1.0)
      AWVC=AW1C(IWVI)+AW2C(IWVI,IWVI)+AW3C(IWVI,IWVI,IWVI)
      AWVD=AW1D(IWVI)+AW2D(IWVI,IWVI)+AW3D(IWVI,IWVI,IWVI)
      AWVS=BXVS+AW1S(IWVI)**IW1I(IWVI)-AW2S(IWVI,IWVI)**IW2I(IWVI,IWVI)
     1  -AW3S(IWVI,IWVI,IWVI)**IW3I(IWVI,IWVI,IWVI)
      RETURN
      END
C***********************************************************************
C*****
C*****                       AAQ - (407)
C*****
C***********************************************************************
C*****    THIS SUBROUTINE IS TO BE RUN WITH SEGMENT 167
      SUBROUTINE AAQ (IWVI, AWVS, IAW1I, IAW2I, AW1S, AW2S, SQFI,
     1MWVI, BWVS, CWVS)
      DIMENSION  IAW1I(4), IAW2I(3,3), AW1S(4),
     1           AW2S(3,3)
      IWVI = INT(SQFI(FLOAT(IWVI) + .5)) - 1
      AWVS = AWVS + 1.0
      IAVI = 5
      IAW1I(1) = MWVI
      IAW1I(3) = IAW1I(3) + 1
      IAW2I(3,3) = IAW2I(3,3) + 1
      AW1S(1) = BWVS
      AW2S(1,3) = CWVS
C*****
C*****    CALL A SUBROUTINE FROM ANOTHER SUBROUTINE
      CALL ABQ(IAW2I, AW1S, AW2S)
      RETURN
      END
C***********************************************************************
C*****
C*****                       ABQ - (417)
C*****
C***********************************************************************
      SUBROUTINE ABQ(ICW2I, CW1S, CW2S)
      DIMENSION ICW2I(3,3), CW1S(4), CW2S(3,3)
      ICW2I(1,2) = ICW2I(1,2) + 1
C*****
      CW1S(4) = CW1S(4) + 1.0
      CW2S(2,3) = CW2S(2,3) + 1.0
      RETURN
      END
C***********************************************************************
C*****
C*****                       ACQ - (427)
C*****
C***********************************************************************
      SUBROUTINE ACQ
      DIMENSION  IDX1I(4), IDX2I(3,3), IDX3I(2,2,2)
     1         ,AAX1S(4), AAX2S(3,3)
      COMMON ABXVS, ACXVS, IAXVI, IDX1I, IDX2I, IDX3I,
     1       AAXVS, AAX1S, AAX2S
      IAXVI = IAXVI+1
      AAXVS = AAXVS +1.0
      IDX1I(2) = IDX1I(2) + 1
      IDX2I(1,2) = IDX2I(1,2) + 1
C*****
      AAX1S(2) = AAX1S(2) * 2. + 1.0
      AAX2S(1,2) = AAX2S(1,2) + 4.0 - 3.0
C*****
      RETURN
C*****    END OF TEST SEGMENT 427
      END
C***********************************************************************
C*****
C*****                       ADQ - (408)
C*****
C***********************************************************************
C*****  SUBROUTINE ADQ CALLED BY SEG. FSBRT(168)
      SUBROUTINE ADQ(IWVI,IAW1I,IAW2I,IAW3I,AWVS,AW1S,AW2S,AW3S,
     A               AWVD,AW1D,AW2D,AW3D,AWVC,AW1C,AW2C,AW3C,
     B               AWVB,AW1B,AW2B,AW3B,KWVI,MWVI,BWVS,CWVS)
      DIMENSION IAW1I(4), IAW2I(3,3), IAW3I(2,2,2), AW1S(4), AW2S(3,3),
     A           AW3S(2,2,2), AW1D(2), AW2D(2,2), AW3D(2,2,2), AW1C(2),
     B          AW2C(2,2), AW3C(2,2,1), AW1B(2), AW2B(2,2),
     C           AW3B(2,2,2)
      DOUBLE PRECISION  AWVD, AW1D, AW2D, AW3D
      COMPLEX           AWVC, AW1C, AW2C, AW3C
      LOGICAL           AWVB, AW1B, AW2B, AW3B
C*****    STORE INTEGER AND REAL EXPRESSIONS
      IAW1I(4) = KWVI
      IAW1I(2) = MWVI
      AW1S(4) = BWVS
      AW1S(2) = CWVS
      CALL AEQ (IWVI,IAW1I,IAW2I,IAW3I,AWVS,AW1S,AW2S,AW3S)
C*****    INCREMENT DOUBLE PRECISION
      AWVD = AWVD + AWVD
      AW1D(1) = AW1D(1) + AW1D(1)
      AW2D(1,2) = AW2D(1,2) + AW2D(1,2)
      AW3D(1,1,2) = AW3D(1,1,2) + AW3D(1,1,2)
C*****    INCREMENT COMPLEX
      AWVC = AWVC + AWVC
      AW1C(1) = AW1C(1) + AW1C(1)
      AW2C(1,2) = AW2C(1,2) + AW2C(1,2)
      AW3C(1,2,1) = AW3C(1,2,1) + AW3C(1,2,1)
C*****    CHANGE LOGICAL
      AWVB = .NOT. AWVB
      AW1B(1) = .NOT. AW1B(1)
      AW2B(1,2) = .NOT. AW2B(1,2)
      AW3B(1,1,2) = .NOT. AW3B(1,1,2)
      RETURN
      END
C***********************************************************************
C*****
C*****                       AEQ - (418)
C*****
C***********************************************************************
C*****  SUBROUTINE AEQ CALLED BY SEG  ADQ(408) WHICH IS
C*****  CALLED BY SEG. FSBRT(168)
      SUBROUTINE AEQ(KWVI, KAW1I, KAW2I, KAW3I, AAWVS, AAW1S, AAW2S,
     A               AAW3S)
      DIMENSION KAW1I(4),KAW2I(3,3),KAW3I(2,2,2),AAW1S(4),AAW2S(3,3),
     A           AAW3S(2,2,2)
C*****    INCREMENT INTEGERS
      KWVI = KWVI + 1
      KAW1I(1) = KAW1I(1) + 1
      KAW2I(1,2) = KAW2I(1,2) + 1
      KAW3I(1,1,2) = KAW3I(1,1,2)+1
C*****    INCREMENT REAL
      AAWVS = AAWVS + 1.
      AAW1S(1) = AAW1S(1) + 1.
      AAW2S(1,2) = AAW2S(1,2) + 1.
      AAW3S(1,1,2) = AAW3S(1,1,2) + 1.
      RETURN
      END
C***********************************************************************
C*****
C*****                       AFQ - (428)
C*****
C***********************************************************************
C*****  SUBROUTINE AFQ CALLED BY SEG. FSBRT(168)
      SUBROUTINE AFQ
      COMMON ABXVS, ACXVS, IAXVI, IAX1I(4), IAX2I(3,3), IAX3I(2,2,2),
     A      AXVS, AX1S(4), AX2S(3,3), AX3S(2,2,2), AXVD, AX1D(2),
     2      AX2D(2,2), AX3D(2,2,2),AXVC, AX1C(2), AX2C(2,2), AX3C(2,2,2)
     3     ,AXVB, AX1B(2), AX2B(2,2), AX3B(2,2,2)
      DOUBLE PRECISION AXVD, AX1D, AX2D, AX3D
      COMPLEX AXVC, AX1C, AX2C, AX3C
      LOGICAL AXVB, AX1B, AX2B, AX3B
C*****    SET INTEGERS TO 1
      IAXVI = 1
      IAX1I(1) = 1
      IAX2I(1,2) = 1
      IAX3I(1,1,2) = 1
C*****    SET REAL TO 2
      AXVS = 2.
      AX1S(2) = 2.
      AX2S(1,2) = 2.
      AX3S(1,1,2) = 2.
C*****    SET DP TO 4
      AXVD = 4.0D0
      AX1D(1) = 4.0D0
      AX2D(1,2) = 4.0D0
      AX3D(1,1,2) = 4.0D0
C*****    SET COMPLEX TO 6
      AXVC = (6.0,6.0)
      AX1C(1) = (6.0,6.0)
      AX2C(1,2) = (6.0,6.0)
      AX3C(1,1,2) = (6.0,6.0)
C*****    CHANGE LOGICAL
      AXVB = .TRUE.
      AX1B(1) = .TRUE.
      AX2B(1,2) = .TRUE.
      AX3B(1,1,2) = .TRUE.
      RETURN
      END
C***********************************************************************
C*****
C*****                       BLOKD - (409)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE
C*****    THIS SEGMENT CONTAINS ONE BLOCK DATA SUBPROGRAM.
C*****    IT IS TO BE RUN WITH SEGMENT 169
C*****  GENERAL COMMENTS
C*****    THIS SEGMENT USES ALL THE PERMISSIBLE STATEMENTS IN A
C*****    BLOCK DATA SUBPROGRAM. THE DATA STATEMENT CONSISTS OF ALL
C*****    TYPES OF VARIABLES AND ARRAYS.  A HOLLERITH CONSTANT
C*****    IS ASSIGNED TO INTEGER, REAL AND LOGICAL
      BLOCK DATA
      COMMON /BLK1/JXVI, JAX1I(2), JAX2I(3,3)
     A       /BLK2/DXVS, DX1S(2), DX2S(2,2)
     B       /BLK3/DXVD, DX1D(2), DX2D(2,2)
     C       /BLK4/DXVC, DX1C(2), DX2C(2,2)
     D       /BLK5/DXVB, DX1B(2), DX2B(2,2)
     E       /BLK6/JAX3I(2,2,2), DX3S(2,2,2), DX3D(2,2,2),
     F             DZ3C(2,2,2), DX3B(2,2,2)
      DIMENSION CY3C(2,2,2)
      DOUBLE PRECISION DXVD, DX1D, DX2D, DX3D
      COMPLEX          DXVC, DX1C, DX2C, DZ3C, CY3C
      LOGICAL          DXVB, DX1B, DX2B, DX3B
      INTEGER JXVI
      REAL DXVS
      EQUIVALENCE (DZ3C(1,1,1), CY3C(1,1,1))
      DATA JAX2I(1,1), JAX1I(2), JAX2I(2,1), JAX3I(2,2,1),DX3S(1,2,1),
     A     DX1S(1), DX2S(1,1), DX3S(2,2,1), DX2D(2,2), DX1D(2),
     B     DX2D(2,1), DX3D(2,2,1), DX2C(2,2), DX1C(2), DX2C(2,1),
     C     DZ3C(2,1,1), DX2B(2,2), DX1B(2), DX2B(2,1), DX3B(2,2,1),
     D     JAX2I(3,1),DX3B(2,1,2),DX2S(2,2)/4*2,4*3.0,4*4.0D0,4*(4.,5.),
     E      4*.TRUE.,                2HAB, 2HAB, 2HAB/
C*****    END OF TEST SEGMENT 409
      END
