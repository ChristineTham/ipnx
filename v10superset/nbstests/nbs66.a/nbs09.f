C*****    PART9    *****************************************************
C*****
C*****    ANSI FORTRAN   (X3.9-1966)     TEST PROGRAMS
C*****
C*****    PREPARED BY THE NATIONAL BUREAU OF STANDARDS      VERSION 3
C*****
C*****    JUNE 1973
C*****
C*****    PART 9  OF 14 PARTS
C*****
C*****    SEGMENTS INCLUDED
C*****
C*****      CPXAD - 140 ADDITION AND SUBTRACTION OF COMPLEX NUMBERS
C*****
C*****      CPXMU - 141 MULTIPLICATION OF COMPLEX NUMBERS
C*****
C*****      CPXDV - 142 DIVISION OF COMPLEX NUMBERS
C*****
C*****      CPXEX - 143 EXPONENTIATION OF COMPLEX NUMBERS
C*****
C*****      CPXOP - 144 ARITHMETIC OPERATIONS ON COMPLEX NUMBERS
C*****
C*****      CREAD - 145 ADDITION, SUBTRACTION OF COMPLEX, REAL NUMBERS
C*****
C*****      CREMU - 146 MULTIPLICATION OF COMPLEX BY REAL NUMBERS
C*****
C*****      CREDV - 147 DIVISION OF REAL, COMPLEX BY COMPLEX, REAL NOS.
C*****
C*****      CREOP - 148 COMBINED OPERATIONS ON COMPLEX AND REAL NOS.
C*****
C*****      MISC3 - 149 BLANKS IN AND CONT. OF STATEMENT TO MAX. LINES
C*****
C*****      MISC4 - 150 SPECIAL CHARACTERS FOR CONTINUATIONS
C*****
C*****  THE FOLLOWING SPECIFICATIONS ARE TO BE USED ONLY WHEN
C*****  SEGMENTS 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150
C*****  ARE RUN AS ONE MAIN PROGRAM.
C*****
      DIMENSION A1S(5), A2S(2,2)
      INTEGER AVI, I1I(5), I2I(2,2)
      COMPLEX AVC, BVC, CVC, DVC, EVC, FVC, GVC, HVC, IVC, JVC,
     1   PVC, RVC, SVC, TVC, UVC,
     2   AAVC, ABVC, BAVC, BCVC, CAVC, CCVC, CDVC, DAVC, DCVC, ASVC,
     3   BSVC, CSVC, DSVC, DBVC, DDVC, MAVC, MBVC, MCVC, MDVC, BBVC,
     4   AAAVC, ABAVC, ACAVC, ADAVC, AASVC, ABSVC, ACSVC, ADSVC
      COMPLEX NUMVC, DENVC, QAVC, QBVC, QCVC, QDVC
C*****
C*****
C*****  END OF SPECIFICATIONS FOR SEGMENTS
C*****  140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150
C***********************************************************************
C*****
C*****                            CPXAD - (140)
C*****
C***********************************************************************
C*****                       GENERAL PURPOSE
C*****     TO TEST ADDITION AND SUBTRACTION OF COMPLEX NUMBERS   ASA REF
C*****     INCLUDES OPERATIONS WITH UP TO 9 TERMS                 6.1
C*****     DOES NOT TEST FOR ACCURACY
C*****
C*****ADDITION AND SUBTRACTION OF 2 TERMS
C*****
C*****  S P E C I F I C A T I O N S  SEGMENT 140
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 140, REMOVE THE PRECEDING
C*****  SPECIFICATIONS.  THE FOLLOWING SPECIFICATIONS WHICH APPEAR
C*****  AS COMMENTS MUST HAVE THE C= IN COLUMNS 1  AND 2  REMOVED.
C*****
C=    COMPLEX  AVC, BVC, CVC, DVC, EVC, FVC, GVC, HVC, IVC, JVC, AAVC,
C=   1 ABVC,BAVC,BBVC,CCVC,CDVC,BCVC,DCVC
C*****
C*****  I N P U T - O U T P U T  T A P E  ASSIGNMENT STATEMENTS
      IRVI = 5
      NUVI = 6
C*****  IDENTIFY THE SOURCE OF THE TEST PROGRAMS
      WRITE(NUVI,0071)
0071  FORMAT (41H1 F O R T R A N  T E S T  P R O G R A M S//
     1 42H  PREPARED BY NATIONAL BUREAU OF STANDARDS//
     3 37H  FOR USE ON LARGE FORTRAN PROCESSORS  //
     4 42H  IN ACCORDANCE WITH ASA FORTRAN X3.9-1966//
     5 23H  VERSION 3     PART 9 ///)
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
      WRITE (NUVI, 1401)
1401  FORMAT(1H1,1X,34HCPXAD - (140) COMPLEX ADDITION AND/16X,
     111HSUBTRACTION//2X,14HASA REF. - 6.1//2X,7HRESULTS//)
      AVC=(1.467,2.560)
      BVC=(3.568,7.480)
      CVC=AVC+BVC
      DVC=AVC+(3.568,7.480)
      EVC=(1.9467,2.9560)+BVC
      FVC=(1.467,2.560)+(3.568,7.480)
      GVC=AVC-BVC
      HVC = (.1467E+1,.2560E1) - BVC
      IVC = AVC - (3568E-3,.7480E+1)
      JVC=(1.467,2.560)-(3.568,7.480)
C*****ADDITION AND SUBTRACTION OF 3 TERMS
      AAVC=AVC+BVC-CVC
      ABVC=AVC+(3.568,7.480)-DVC
      BAVC=(1.467,2.560)+BVC-CVC
      BBVC=(1.467,2.560)+(3.568,7.480)-FVC
      BCVC=AVC-BVC-GVC
      CCVC=(1.467,2.560)-BVC-HVC
      CDVC=AVC-(3.568,7.480)-IVC
      DCVC=(1.467,2.560)-(3.568,7.480)-JVC
      WRITE(NUVI,1402) AAVC,ABVC,BAVC,BBVC,BCVC,CCVC,CDVC,DCVC
C*****ADDITION AND SUBTRACTION OF 5 TERMS
      AAVC=AVC-(1.89,6.48)-AAVC-BVC+(0.0,9.830)
      ABVC=AVC-(1.89,6.48)-AAVC-BVC+(0.0,9.830)
      WRITE(NUVI,1402)ABVC
 1402 FORMAT(2X,2F8.4)
      AAVC=AVC-(1.89,6.48)-BVC+(0.0,9.83)+CVC
C*****ADDITION AND SUBTRACTION OF 6 TERMS
      ABVC=AVC-(1.89,6.48)-BVC+(0.0,9.83)+CVC-AAVC
      WRITE(NUVI,1402) ABVC
C*****ADDITION AND SUBTRACTION OF 8 TERMS
      AAVC=AVC+BVC-CVC+(0.34,6.45)-(4.54,6.85)+DVC+(1.0,0.0)-EVC
C*****ADDITION AND SUBTRACTION OF 9 TERMS
      ABVC=AVC+BVC-CVC+(0.34,6.45)-(4.54,6.85)+DVC+(1.0,0.0)-EVC-AAVC
      WRITE (NUVI,1403) ABVC
 1403 FORMAT(2X,2F8.4//2X,35HTEST IS POSITIVE IF NUMBERS PRINTED/2X ,
     117HABOVE ARE 0.0,0.0)
C*****    END OF TEST SEGMENT 140
C*****  WHEN EXECUTING ONLY SEGMENT 140, THE  STOP  AND  END  CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                   CPXMU - (141)
C***********************************************************************
C*****                  GENERAL PURPOSE
C*****    TO TEST MULTIPLICATION OF COMPLEX NUMBERS              ASA REF
C*****    INCLUDES OPERATIONS WITH UP TO 10 TERMS                6.1
C*****    DOES NOT TEST FOR ACCURACY
C*****
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 141
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 141, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    COMPLEX AVC, BVC, CVC, DVC, EVC, FVC, GVC, HVC, IVC, JVC
C=   1   ,AAVC, ABVC, BAVC, BBVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 141, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1411)
1411  FORMAT (1H1,1 X,36HCPXMU - (141) COMPLEX MULTIPLICATION//2X,
     114HASA REF. - 6.1//2X,7HRESULTS//)
C*****MULTIPLICATION OF TWO TERMS
      AVC = (-0.5,0.86602)
      BVC = (-0.5,-0.86602)
      AAVC = (AVC * BVC )
      ABVC =  AVC * (-0.5,-0.86602)
      BAVC = (-0.5,0.86602) * BVC
      BBVC = (-0.5,0.86602)*(-0.5,-0.86602)
      WRITE(NUVI,1412) AAVC,ABVC,BAVC,BBVC
C*****MULTIPLICATION OF 3 TERMS
      AVC=(0.0,1.0)
      BVC=(1.0,0.0)
      CVC=(0.0,-1.0)
      AAVC=AVC*BVC*CVC
      ABVC=(0.0,1.0)*BVC*(0.0,-1.0)
      WRITE(NUVI,1412) AAVC,ABVC
 1412  FORMAT(2X,2F8.3)
C*****MULTIPLICATION OF 4 TERMS
      AVC=(0.30901,0.95105)
      BVC=(-0.80901,0.58778)
      CVC=(-0.80901,-0.58778)
      DVC=(0.30901,-0.95105)
      AAVC=AVC*BVC*CVC*DVC
      ABVC=AVC*(-0.80901,0.58778)*CVC*(0.30901,-0.95105)
      WRITE(NUVI,1412) AAVC,ABVC
C*****MULTIPLICATION OF 5 TERMS
      AVC=(0.5,0.86602)
      BVC=(-0.5,0.86602)
      CVC = (1.0,0.0)
      DVC=(-0.5,-0.86602)
      EVC=(0.5,-0.86602)
      AAVC=AVC*BVC*CVC*DVC*EVC
      ABVC=AVC*(-0.5,0.86602)*CVC*(-0.5,-0.86602)*EVC
      WRITE(NUVI,1412) AAVC,ABVC
C*****MULTIPLICATION OF 6 TERMS
      AVC = (0.98480,0.17364)
      BVC=(-0.17364,0.98480)
      CVC=(-0.86602,0.5)
      DVC=(-0.93969,-0.34202)
      EVC=(0.34202,-0.93969)
      FVC=(0.86602,-0.5)
      AAVC=AVC*BVC*CVC*DVC*EVC*FVC
      ABVC=AVC*(-0.17364,0.98480)*CVC*(-0.93969,-0.34202)*EVC*(0.86602,
     1-0.5)
      WRITE(NUVI,1412) AAVC,ABVC
C*****MULTIPLICATION OF 7 TERMS
      AVC=(0.70710,0.70710)
      BVC=(0.0,1.0)
      CVC=(-0.70710,0.70710)
      DVC=(1.0,0.0)
      EVC=(-0.70710,-0.70710)
      FVC=(0.0,-1.0)
      GVC=(0.70710,-0.70710)
      AAVC=AVC*BVC*CVC*DVC*EVC*FVC*GVC
      ABVC=AVC*(0.0,1.0)*CVC*( 1.0,0.0)*EVC*(0.0,-1.0)*GVC
      WRITE(NUVI,1412) AAVC,ABVC
C*****MULTIPLICATION OF 8 TERMS
      AVC=(0.76604,0.64278)
      BVC=(0.17364,0.98480)
      CVC=(-0.5,0.86602)
      DVC=(-0.93969,0.34202)
      EVC=(-0.93969,-0.34202)
      FVC=(-0.5,-0.86602)
      GVC=(0.17364,-0.98480)
      HVC=(0.76604,-0.64278)
      AAVC=AVC*BVC*CVC*DVC*EVC*FVC*GVC*HVC
      ABVC=AVC*(0.17364,0.98480)*CVC*DVC*(-0.93969,-0.34202)*FVC*GVC*HVC
      WRITE(NUVI,1412) AAVC,ABVC
C*****MULTIPLICATION OF 9 TERMS
      AVC=(0.80901,0.58778)
      BVC=(0.30901,0.95105)
      CVC=(-0.94832,0.31730)
      DVC=(-0.80901,0.58778)
      EVC = (1.0,0.0)
      FVC=(-0.80901,-0.58778)
      GVC=(-0.94832,-0.31730)
      HVC=(0.30901,-0.95105)
      IVC=(0.80901,-0.58778)
      AAVC=AVC*BVC*CVC*DVC*EVC*FVC*GVC*HVC*IVC
      ABVC=AVC*(0.30901,0.95105)*CVC*(-0.80901,0.58778)*( 1.0,0.0)*FVC*
     1GVC*HVC*IVC
      WRITE(NUVI,1412) AAVC,ABVC
C*****MULTIPLICATION OF 10 TERMS
      AVC=(0.86602,0.5)
      BVC=(0.5,0.86602)
      CVC=(0.0,1.0)
      DVC=(-0.5,0.86602)
      EVC=(-0.86602,0.5)
      FVC=(-1.0,0.0)
      GVC=(-0.86602,-0.5)
      HVC=(-0.5,-0.86602)
      IVC=(0.0,-1.0)
      JVC=(0.0,1.0)
      AAVC=AVC*BVC*CVC*DVC*EVC*FVC*GVC*HVC*IVC*JVC
      ABVC=AVC*(0.5,0.86602)*CVC*(-0.5,0.86602)*EVC*FVC*GVC*HVC*(0.0,-1.
     10)*JVC
      WRITE(NUVI,1412) AAVC,ABVC
      WRITE(NUVI,1413)
1413  FORMAT (1H0,35HTEST IS POSITIVE IF NUMBERS PRINTED/1X,
     117HABOVE ARE 1.0,0.0)
      WRITE(NUVI, 1414)
1414  FORMAT (//39H  ERROR SHOULD NOT EXCEED + OR - .001  )
C*****    END OF TEST SEGMENT 141
C*****  WHEN EXECUTING ONLY SEGMENT 141, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                         CPXDV-(142)
C*****
C***********************************************************************
C*****                GENERAL PURPOSE
C*****      TO TEST DIVISION OF COMPLEX NUMBERS                  ASA REF
C*****                                                            6.1
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 142
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 142, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    COMPLEX NUMVC,DENVC,QAVC,QBVC,QCVC,QDVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 142, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1421)
1421  FORMAT(1H1,1X,25HCPXDX - (142) DIVISION OF/16X,
     115HCOMPLEX NUMBERS//15H  ASA REF.- 6.1//2X,7HRESULTS//)
C***** TEST NUMBER 1
      NUMVC=(0.36602,1.36602)
      DENVC=(0.86602,0.5)
      QAVC=NUMVC/DENVC
      QBVC=(0.36602,1.3660) /DENVC
      QCVC=NUMVC/(0.86602,0.5)
      QDVC=(0.36602,1.36602)/(0.86602,0.5)
      WRITE(NUVI,1422)  QAVC,QBVC,QCVC,QDVC
C*****TEST NUMBER 2
      NUMVC=(0.0,1.41420)
      DENVC=(0.70710,0.70710)
      QAVC=NUMVC/DENVC
      QBVC=(0.0,1.41420)/DENVC
      QCVC=NUMVC/(0.70710,0.70710)
      QDVC=(0.0,1.41420)/(0.70710,0.70710)
      WRITE(NUVI,1422) QAVC,QBVC,QCVC,QDVC
 1422 FORMAT(2X,2F8.4)
C*****TEST NUMBER 3
      NUMVC=(-0.36602,1.36602)
      DENVC=(0.5,0.86602)
      QAVC=NUMVC/DENVC
      QBVC=(-0.36602,1.36602)/DENVC
      QCVC=NUMVC/(0.5,0.86602)
      QDVC=(-0.36602,1.36602)/(0.5,0.86602)
      WRITE(NUVI,1422) QAVC,QBVC,QCVC,QDVC
C*****TEST NUMBER 4
      NUMVC=(0.73204,2.73204)
      DENVC=(1.73204,1.0)
      QAVC=NUMVC/DENVC
      QBVC=(0.73204,2.73204)/DENVC
      QCVC=NUMVC/(1.73204,1.0)
      QDVC=(0.73204,2.73204)/(1.73204,1.0)
      WRITE(NUVI,1422) QAVC,QBVC,QCVC,QDVC
C***** TEST NUMBER 5
      NUMVC=(0.0,2.82840)
      DENVC=(1.41420,1.41420)
      QAVC=NUMVC/DENVC
      QBVC=(0.0,2.82840)/DENVC
      QCVC=NUMVC/(1.41420,1.41420)
      QDVC=(0.0,2.82840)/(1.41420,1.41420)
      WRITE(NUVI,1422) QAVC,QBVC,QCVC,QDVC
      WRITE(NUVI,1423)
1423  FORMAT (//2X,35HTEST IS POSITIVE IF NUMBERS PRINTED/2X,
     117HABOVE ARE 1.0,1.0)
      WRITE (NUVI, 1424)
1424  FORMAT (//39H  ERROR SHOULD NOT EXCEED + OR - .0001 )
C*****    END OF TEST SEGMENT 142
C*****  WHEN EXECUTING ONLY SEGMENT 142, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                   CPXEX(143)
C*****
C***********************************************************************
C*****                 GENERAL PURPOSE
C*****    TO TEST EXPONENTIATION OF COMPLEX NUMBERS              ASA REF
C*****    BY INTEGERS                                               6.1
C*****    EXPONENT VALUES VARY FROM 3 TO 100
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 143
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 143, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    COMPLEX AVC,BVC,CVC,DVC,EVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 143, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1431)
1431  FORMAT(1H1,1 X,36HCPXEX - (143) COMPLEX EXPONENTIATION//
     1 2X,11HASA.REF.6.1//2X,29HRESULTS BASED ON THE FUNCTION//
     2 2X,25H1.0 = SIN**2(X)+COS**2(X)//)
C***** EXPONENT=3
      AVC   = (-0.5,0.8660254)
      AVI=3
      BVC=AVC**3
      CVC   = (-0.5,0.8660254) ** 3
      DVC   = (-0.5,0.8660254) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432) BVC,CVC,DVC,EVC
C***** EXPONENT=4
      AVC=(0.0,1.0)
      AVI=4
      BVC=AVC**4
      CVC=(0.0,1.0)**4
      DVC=(0.0,1.0)**AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
 1432 FORMAT (2X,2F8.4)
C***** EXPONENT=6
      AVC   = ( 0.5,0.8660254)
      AVI=6
      BVC=AVC**6
      CVC   = ( 0.5,0.8660254) ** 6
      DVC   = ( 0.5,0.8660254) ** AVI
      EVC= AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
C***** EXPONENT=8
      AVC   = (0.7071068,0.7071068)
      AVI=8
      BVC=AVC**8
      CVC   = (0.7071068,0.7071068) ** 8
      DVC   = (0.7071068,0.7071068) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
C***** EXPONENT=10
      AVC   = (0.8090170,0.5877853)
      AVI=10
      BVC=AVC**10
      CVC   = (0.8090170,0.5877853) ** 10
      DVC   = (0.8090170,0.5877853) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
C*****EXPONENT=20
      AVC   = (0.9510565,0.3090170)
      AVI=20
      BVC=AVC**20
      CVC   = (0.9510565,0.3090170) ** 20
      DVC   = (0.9510565,0.3090170) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
C***** EXPONENT=40
      AVC   = (0.9876883,0.1564345)
      AVI=40
      BVC=AVC**40
      CVC   = (0.9876883,0.1564345) ** 40
      DVC   = (0.9876883,0.1564345) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
C***** EXPONENT=60
      AVC   = (0.9945219,0.1045285)
      AVI=60
      BVC=AVC**60
      CVC   = (0.9945219,0.1045285) ** 60
      DVC   = (0.9945219,0.1045285) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
C*****EXPONENT=80
      AVI = 80
      AVC   = (0.9969173,0.0784591)
      BVC=AVC**80
      CVC   = (0.9969173,0.0784591) ** 80
      DVC   = (0.9969173,0.0784591) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
C***** EXPONENT=100
      AVC   = (0.9980267,0.0627905)
      AVI=100
      BVC=AVC**100
      CVC   = (0.9980267,0.0627905) ** 100
      DVC   = (0.9980267,0.0627905) ** AVI
      EVC=AVC**AVI
      WRITE(NUVI,1432)  BVC,CVC,DVC,EVC
      WRITE (NUVI,1433)
 1433 FORMAT (//  37H  TEST IS POSITIVE IF NUMBERS PRINTED/2X,
     1  26HABOVE ARE CLOSE TO 1.0,0.0)
      WRITE (NUVI, 1434)
1434  FORMAT(// 39H  ERROR SHOULD NOT EXCEED + OR - .0001 )
C*****    END OF TEST SEGMENT 143
C*****  WHEN EXECUTING ONLY SEGMENT 143, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       CPXOP - (144)
C*****
C***********************************************************************
C*****             GENERAL PURPOSE                              ASA REF
C*****  TO TEST ARITHMETIC OPERATIONS ON COMPLEX NUMBERS.       6.1
C*****  OPERATIONS INCLUDE ALL BASIC OPERATORS (+,-,*,**) ACTING
C*****  ON COMPLEX NUMBERS
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 144
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 144, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    INTEGER AVI
C=    COMPLEX  AVC, BVC, CVC, DVC, EVC, FVC, GVC,HVC,PVC,RVC,SVC,TVC,UVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 144, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1441)
 1441  FORMAT(1H1,1X,32HCPXOP - (144) COMPLEX OPERATIONS//2X,
     111HASA REF 6.1//2X,7HRESULTS//)
      AVC = (0.9396926,0.3420201)
      BVC = (1.2817127,0.5976725)
      CVC = (0.0, 1.4142136)
      DVC = (0.7071068, 0.7071068)
      EVC = (1.0986841, 0.4550899)
      AVI = 2
      RVC=(AVC*BVC+(0.9396926,0.3420201)*BVC+AVC*(1.2817127,0.5976725)-
     1(0.9396926,0.3420201)*(1.2817127,0.5976725)+CVC/DVC+(0.0,1.4142136
     2)/DVC+CVC/(0.7071068,0.7071068)-(0.0,1.4142136)/(0.7071068,
     3 0.7071068)+EVC**2-EVC**AVI+(1.0986841,0.4550899)**2+(1.0986841,
     4 0.4550899)**AVI)**2/(0.0, 72.0)
      FVC=(0.0,4.0)
      GVC=(0.43301,0.3)
      HVC=(0.43301,0.2)
      PVC=(1.73204,1.0)
      SVC=FVC/((GVC+HVC)*(PVC**2))
      TVC=(0.0,4.0)/(((0.43301,0.3)+(0.43301,0.2))*((1.73204,1.0)**2))
      UVC=FVC/((GVC+(0.43301,0.2))*(PVC**2))
      WRITE (NUVI,1442) RVC,SVC,TVC,UVC
1442  FORMAT ( 4(2X,2F8.4/) /37H  TEST IS POSITIVE IF NUMBERS PRINTED /
     12X, 17HABOVE ARE 1.0,0.0 )
      WRITE (NUVI, 1443)
1443  FORMAT(// 39H  ERROR SHOULD NOT EXCEED + OR - .0001 )
C*****    END OF TEST SEGMENT 144
C*****  WHEN EXECUTING ONLY SEGMENT 144, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                      CREAD-(145)
C*****
C***********************************************************************
C*****  GENERAL PURPOSE                                         ASA REF
C*****  TO TEST ADDITION AND SUBTRACTION OF COMPLEX               6.1
C*****  AND REAL NUMBERS
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 145
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 145, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    COMPLEX AVC,BAVC,CAVC,DAVC,ASVC,BSVC,CSVC,AAVC
C=   2 ,       DSVC,AAAVC,ABAVC,ACAVC,ADAVC,AASVC,ABSVC,ACSVC,ADSVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 145, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1450)
 1450 FORMAT(1H1,1X,38HCREAD - (145) ADDITION AND SUBTRACTION/
     1 10X,27HOF COMPLEX AND REAL NUMBERS//2X,
     1 12HASA REF. 6.1//2X,7HRESULTS//)
      AVC=(5.4,7.5)
      AVS=4.2
C***** ADDITION AND SUBTRACTION OF 2 NUMBERS
      AAVC=AVC-AVS
      BAVC=(5.4,7.5)-AVS
      CAVC=AVC-4.2
      DAVC=(5.4,7.5)-4.2
      ASVC=AVC+AVS
      BSVC=(5.4,7.5)+AVS
      CSVC=AVC+4.2
      DSVC=(5.4,7.5)+4.2
C***** ADDITION AND SUBTRACTION OF 3 NUMBERS
      AAAVC=AVC-AVS-AAVC
      ABAVC=(5.4,7.5)-AVS-BAVC
      ACAVC=AVC-4.2-(1.2,7.5)
      ADAVC=(5.4,7.5)-4.2-(1.2,7.5)
      AASVC=AVC+AVS-ASVC
      ABSVC=(5.4,7.5)+AVS-BSVC
      ACSVC=AVC+4.2-(9.6,7.5)
      ADSVC=(5.4,7.5)+4.2-(9.6,7.5)
      WRITE(NUVI,1451)ABAVC,ACAVC,ADAVC,AASVC,ABSVC,ACSVC,ADSVC,AAAVC
1451  FORMAT( 2X, 2F8.4)
C***** ADDITION AND SUBTRACTION OF 7 NUMBERS
      ADSVC=AVC-(5.4,7.5)+AVS-4.2+ASVC-3.2-(6.4,7.5)
      WRITE(NUVI,1452) ADSVC
 1452 FORMAT(2X,2F8.4//37H  TEST IS POSITIVE IF NUMBERS PRINTED/2X,
     1 17HABOVE ARE 0.0,0.0)
C*****    END OF TEST SEGMENT 145
C*****  WHEN EXECUTING ONLY SEGMENT 145, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       CREMU - (146)
C*****
C***********************************************************************
C*****             GENERAL PURPOSE                              ASA REF
C*****    TO TEST MULTIPLICATION OF COMPLEX NUMBERS BY            6.1
C*****    REAL NUMBERS
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 146
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 146, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    COMPLEX AVC,BVC,     MAVC,MBVC,MCVC,MDVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 146, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1461)
 1461 FORMAT(1H1,1X,39HCREMU - (146) MULTIPLICATION OF COMPLEX/16X,
     1 7HBY REAL   //2X,
     2 11HASA.REF.6.1//2X,7HRESULTS//)
C*****MULTIPLICATION OF A COMPLEX NUMBER BY A REAL NUMBER
      AVC=(1.6,3.2)
      AVS=0.625
      MAVC=AVC*AVS
      MBVC=(1.6,3.2)*AVS
      MCVC=AVC*0.625
      MDVC=(1.6,3.2)*0.625
      WRITE (NUVI,1463) MAVC,MBVC,MCVC,MDVC
1463  FORMAT(4(2X,2F8.4/)//37H  TEST IS POSITIVE IF NUMBERS PRINTED/,2X,
     417HABOVE ARE 1.0,2.0 )
C*****MULTIPLICATION OF 4 TERMS
      AVS=4.0
      BVS=0.25
      AVC=(0.93969,0.34202)
      BVC=(1.28168,0.59764)
      MAVC=AVS*AVC*BVS*BVC
      MBVC=4.0*BVS*AVC*BVC
      MCVC=4.0*BVS*(0.93969,0.34202)*BVC
      MDVC=4.0*0.25*(0.93969,0.34202)*(1.28168,0.59764)
      WRITE (NUVI,1462) MAVC,MBVC,MCVC,MDVC
 1462 FORMAT(//4(2X,2F8.4/)//37H  TEST IS POSITIVE IF NUMBERS PRINTED/
     12X,17HABOVE ARE 1.0,1.0)
      WRITE (NUVI, 1464)
1464  FORMAT(// 39H  ERROR SHOULD NOT EXCEED + OR - .0001 )
C*****    END OF TEST SEGMENT 146
C*****  WHEN EXECUTING ONLY SEGMENT 146, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       CREDV - (147)
C*****
C***********************************************************************
C*****             GENERAL PURPOSE                              ASA REF
C*****  TO TEST DIVISION OF REAL (COMPLEX) NUMBERS BY             6.1
C*****  COMPLEX (REAL) NUMBERS
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 147
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 147, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    COMPLEX AVC,DAVC,DBVC,DCVC,DDVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 147, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1471)
1471  FORMAT (1H1,1X,33HCREDV - (147) DIVISION OF COMPLEX/16X,16HAND REA
     1L NUMBERS//2X,11HASA REF 6.1//2X,7HRESULTS//)
C*****DIVISION OF REAL BY COMPLEX
      AVS=2.0
      AVC=(1.0, -1.0)
      DAVC=AVS/AVC
      DBVC=2.0/AVC
      DCVC=AVS/(1.0, -1.0)
      DDVC=2.0/(1.0, -1.0)
      WRITE (NUVI,1473) DAVC,DBVC,DCVC,DDVC
1473  FORMAT( 2X, 2F8.4)
C*****DIVISION OF COMPLEX BY REAL
      AVS=2.5463
      AVC=(2.5463,2.5463)
      DAVC=AVC/AVS
      DBVC=(2.5463,2.5463)/AVS
      DCVC=AVC/2.5463
      DDVC=(2.5463,2.5463)/2.5463
      WRITE (NUVI,1472) DAVC,DBVC,DCVC,DDVC
1472  FORMAT (4(2X,2F8.4/)//37H  TEST IS POSITIVE IF NUMBERS PRINTED/
     1 2X,17HABOVE ARE 1.0,1.0)
      WRITE (NUVI, 1474)
1474  FORMAT(// 39H  ERROR SHOULD NOT EXCEED + OR - .0001 )
C*****    END OF TEST SEGMENT 147
C*****  WHEN EXECUTING ONLY SEGMENT 147, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       CREOP - (148)
C*****
C***********************************************************************
C*****                GENERAL PURPOSE                           ASA REF
C*****   TO TEST COMBINED OPERATIONS ON COMPLEX AND REAL NUMBERS    6.1
C*****DIVISION OF TWO POLYNOMIALS
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 148
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 148, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    INTEGER AVI
C=    COMPLEX AVC,BVC,CVC,DVC,RVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 148, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1481)
 1481 FORMAT(1H1,1X,36HCREOP - (148) OPERATIONS ON REAL AND/16X,15HCOMPL
     1EX NUMBERS//  2X,12HASA REF. 6.1//2X, 7HRESULTS//)
      AVC=(1.0,1.0)
      AVS=1.0
      BVS = 2.0
      BVC=(1.0,-1.0)
      RVC = (BVS + AVC *(1.+AVC * (-1.+(1.0,1.0)*(-1. +AVC))))/
     1 (4.0+BVC*(2.0+BVC*(-AVS+BVC*(0.5+BVC))))
      WRITE (NUVI,1483) RVC
1483  FORMAT(             2X,2F8.4//37H  TEST IS POSITIVE IF NUMBERS PRI
     3NTED/2X,18HABOVE ARE 2.0,-1.0//)
C*****COMPLEX ARITHMETIC EXPRESSION
      AVC=(1.60,3.2)
      AVS=0.625
      BVS=2.0
      BVC=(1.0,-1.0)
      CVS=2.5
      CVC=(2.5,2.5)
      DVC = (1.09866,0.45508)
      AVI = 2
      RVC=(AVC*AVS+(1.6,3.2)*AVS-AVC*0.625-(1.6,3.2)*0.625+BVS/BVC
     1-BVS/(1.0,-1.0)+2.0/BVC+2.0/(1.0,-1.0)+CVC/CVS-(2.5,2.5)/CVS+
     2CVC/2.5+(2.5,2.5)/2.5+DVC**AVI-(1.09866,0.45508)**2+DVC**2+
     3(1.09866,0.45508)**AVI)**2/(0.0,72.0)
      WRITE (NUVI,1482) RVC
 1482 FORMAT(2X,2F8.4//   37H  TEST IS POSITIVE IF NUMBERS PRINTED/2X,
     1 17HABOVE ARE 1.0,0.0)
      WRITE (NUVI, 1484)
1484  FORMAT(// 39H  ERROR SHOULD NOT EXCEED + OR - .0001 )
C*****    END OF TEST SEGMENT 148
C*****  WHEN EXECUTING ONLY SEGMENT 148, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       MISC3 - (149)
C*****
C***********************************************************************
C*****                GENERAL PURPOSE                           ASA REF
C*****   TO TEST EFFECT OF BLANKS WITHIN STATEMENT,             3.1.4.1
C*****   CONTINUATION OF STATEMENT TO MAX.NO.OF LINES,         3.2.4,3.3
C*****   AND USE OF SPECIAL CHARACTERS TO INDICATE CONTINUATION   3.2.4
C*****   LINE -
C*****   FOR BASIC INTEGERS AND REAL NUMBERS
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 149
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 149, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    DIMENSION A1S(5),A2S(2,2)
C=    INTEGER I1I(5),I2I(2,2)
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 149, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI,1490)
1490  FORMAT(1H1,1X,37HMISC3 - (149) EFFECT OF BLANKS WITHIN/16X,
     122HSTMNT AND CONTINUATION/16X,20HOF STMNT TO 20 LINES//
     239H  ASA REFS. - 3.1.4.1  3.2.4.3.3  3.2.4//2X,7HRESULTS  )
      J  A  C   V  I        =              1
      I
     =1
     +I
     -(
     *2
     /)                     =2
      I     2I(   2  ,  1)   =   3
      A   CV     S    =    -   1  .0   E    0
      A   1   S   (    2)     =     -2     00  .  E   -  2
      A   2   S   (   2    ,   1  )    =   -  .0 3    E  +  2
      K   B
     *        CVI
     (                 =
     )                  J     A
     $                   C           V
     .                            I
     ,                                 +         I
     /                                             1    I
     =                                                     (   2
     1                                                          )
     2                                                                 +
     3I
     4            2
     5                  I
     6                       (
     7                                 2
     8   ,
     9                                     1
     A                                     )
     B                                                 -         6
      C             M
     =           A
     ,                  V       S
     (                         =
     $                             A
     *                                      C
     .                                                 V
     )                                                                 S
     /+
     1    A            1
     2                   S
     3                                                                 (
     42)                                                               +
     5            A
     6                  2
     7                            S          (
     8                     2                        ,          1
     9)
     A                +
     B                           6       .                 0
      W     RI  T  E     (NU  VI  , 1 49 1 ) KB CVI  , CMA  VS
1 491 F O RM A T (//I10//F11.1// 2 X, 35HTEST IS POSITIVE IF NUMBERS PRI
     1NTED/  2    X,    1   1HABOVE ARE 0)
C*****    END OF TEST SEGMENT 149
C*****  WHEN EXECUTING ONLY SEGMENT 149, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
C***********************************************************************
C*****
C*****                       MISC4 - (150)
C*****
C***********************************************************************
C*****                GENERAL PURPOSE                           ASA REF
C*****   TO TEST EFFECT OF BLANKS WITHIN STATEMENT,             3.1.4.1
C*****   CONTINUATION OF STATEMENT TO 20 LINES,                3.2.4.3.3
C*****   AND USE OF SPECIAL CHARACTERS TO INDICATE CONTINUATION   3.2.4
C*****  CONTINUATION LINE CAN CONTAIN FORTRAN CHARACTERS
C*****  (OTHER THAN C IN COLUMN 1) IN COLUMNS 1 THRU 5 (CLARIFICATION 3)
C*****
C*****  S P E C I F I C A T I O N S   SEGMENT 150
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 150, THE SPECIFICATION STATEMENTS
C*****  WHICH APPEAR AS COMMENTS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    INTEGER AVI
C=    COMPLEX AVC,BVC,CVC,DVC,RVC
C*****
C*****  O U T O U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.
C*****
C*****  WHEN EXECUTING ONLY SEGMENT 150, THE FOLLOWING STATEMENT
C*****  NUVI = 6  MUST HAVE THE C=  IN COLUMNS  1  AND  2  REMOVED.
C*****
C=    NUVI = 6
C*****
      WRITE (NUVI, 1500)
1 500 F  O  RM  A   T(  1   H1  ,   1   X   ,  13   HMISC4 - (150)
     X,1X,  2 3  HEFFECT OF BLANKS WITHIN    /   16X,   22HSTMNT AND CON
     YTINUATION/ 16X,  20HOF STMNT TO 20 LINES//
     I39H  ASA REFS. - 3.1.4.1  3.2.4.3.3  3.2.4//2X,7HRESULTS//)
      AVC = (1   .0   ,  1    .0)
      AVS = 1.      0
      B V S      =                2 .                    0
      BVC=   (1 .0   ,-  1 .0)
      RVC = (B VS +A  V   C*(  1 . +A VC *(  - 1.+    (1    .0,   1
     T.  0   )   *(    -     1  .0+   A  V     C )   ))  )   /(
     U4  .0   +     BV    C   *     (2    .   0    +    BVC     *
     V(   -    A   V      S   + B  V  C   *(     0   .  5   +  B
     WV   C  )     )    )   )
      RVC       =            RV     C      +(-2.0,      +1     .0)
      W   RI   T E      (N  UV   I ,  15  02   )     R    VC
1502  FORMAT( 2X, 2F8.4)
C*****COMPLEX ARITHMETIC EXPRESSION
C*****  STATEMENT LABEL NOT REFERENCED                              3.4
1503  A
VC=1.+V
     -C
     *    =
     /     (
     (1
     ).
     ,6
     .0
     I,
     J3
     K.
     L2
     M                         )
C*****  CONTINUE STATEMENT WITH NO LABEL                            3.4
      CONTINUE
      AVS = 0.625
      BVS = 2.0
      BVC = (1.0,-1.0)
      CVS = 2.5
      CVC = (2.5,2.5)
      DVC = (1.0986841, 0.4550899)
      AVI = 2
      RVC                       =
     B(AVC*AVS
     C+(1.6,3.2)
     D*AVS-AVC
     E*0.625
     F-(1.6,3.2)
     G*0.625
     H+BVS/BVC
     I-BVS/(1.0,-1.0)
     J+2.0/BVC+2.0/
     K(1.0,-1.0)+CVC/CVS
     L-(2.5,2.5)/CVS+CVC/2.5
     M+(2.5,2.5)/2.5+DVC**AVI
     N-(1.0986841,0.4550899)**2
     O+DVC**2
     P+
     Q(1.0986841,0.4550899)
     R**AVI)
     S**2/(0.0,72.0)
     T       -(1.0,0.0)
      W   R    I  T   E   (  N U V I  ,    1  5 0 1) R  V  C
15 01 FORM  AT(/          /2     X  ,  2    F      8      .          4
1501 Z/ /  3      7H  TEST IS POSITIVE IF NUMBERS PRINTED/    2X
     =,   1   7     HABOVE ARE 0.0,0.0       )
C*****    END OF TEST SEGMENT 150
C*****  WHEN EXECUTING ONLY SEGMENT 150, THE STOP AND END CARDS
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE  C=
C*****  IN COLUMNS  1  AND  2  REMOVED.
C=    STOP
C=    END
      STOP
      END
