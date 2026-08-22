*HEADER,FORTR,FM909
*FILES1,FORTR,FM909,X
C***********************************************************************
C*****  FORTRAN 77
C*****   FM909
C*****                       INTER4 - (393)
C*****
C***********************************************************************
C*****  TESTING OF INTERNAL FILES -                            ANS. REF
C*****          USING WRITE                                     12.2.5
C*****
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
C*****  S P E C I F I C A T I O N S  SEGMENT 393
C*****
        LOGICAL AVB
        DOUBLE PRECISION AVD, BVD, CVD, DVD, B1D(5)
        COMPLEX AVC, BVC, CVC
        CHARACTER A8VK*8, A97VK*97, CVCORR*97, AVCORR(24)*97
        CHARACTER*29 A291K(5)
        CHARACTER*43 A431K(2)
        CHARACTER*1 A97E1(97), A97E2(97)
        EQUIVALENCE (A97VK, A97E1), (A431K, A97E1)
        EQUIVALENCE (CVCORR, A97E2)
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
      IVTOTL = 27
      ZPROG = 'FM909'
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
C*****    HEADER FOR SEGMENT 393
C*****
        WRITE(NUVI,39300)
39300   FORMAT(1H ,/ 46H INTER4 - (393) INTERNAL FILES --  USING WRITE
     1        //19H ANS. REF. - 12.2.5)
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
39199   FORMAT (1H ,48X,31HNOTE 1: FOR NUMERIC VALUES,    /
     1          1H ,48X,31H   OPTIONAL LEADING ZERO MAY BE/
     2          1H ,48X,31H   BLANK FOR ABSOLUTE VALUE < 1/
     3          1H ,48X,31HNOTE 2: LEADING PLUS SIGN IS   /
     4          1H ,48X,31H   OPTIONAL FOR NUMERIC VALUES /
     5          1H ,48X,31HNOTE 3: E FORMAT EXPONENT MAY  /
     6          1H ,48X,31H   BE E+NN OR +0NN FOR REALS   /
     7          1H ,48X,31HNOTE 4: D FORMAT EXPONENT MAY  /
     8          1H ,48X,31H   BE D+NN, E+NN, OR +0NN FOR  /
     9          1H ,48X,31H   DOUBLE PRECISION VALUES     /)
C*****
CT001*  TEST 1                          DOUBLE PRECISION INTO VARIABLE
           IVTNUM = 1
        A97VK = 'XXXXXXXXXXXXXXXXXX'
        AVD = 23.456D3
        WRITE(UNIT=A97VK,FMT=39301) AVD
39301   FORMAT(13X,D10.5)
           IVCOMP = 0
           AVCORR(1) = '             .23456D+05'
           AVCORR(2) = '             .23456E+05'
           AVCORR(3) = '             .23456+005'
           DO 40011 I = 1, 3
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40011, 10010, 40011
40011      CONTINUE
           GO TO 20010
10010      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0011
20010      IVFAIL = IVFAIL + 1
           CVCORR = '             .23456D+05'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
70010      FORMAT(1H ,16X,10HCOMPUTED: ,54A1)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
70020      FORMAT(1H ,26X,43A1)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
70030      FORMAT(1H ,16X,10HCORRECT:  ,54A1)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
70040      FORMAT(1H ,26X,43A1)
 0011      CONTINUE
CT002*  TEST 2                                   INTO ARRAY ELEMENT
           IVTNUM = 2
        AVD = 2.1D1
        A431K(1) = ' '
        A431K(2) = 'WRONG'
        WRITE(UNIT=A431K(1),FMT=39303) AVD
39303   FORMAT(D12.7)
           IVCOMP = 0
           AVCORR(1) = '.2100000D+02'
           AVCORR(2) = '.2100000E+02'
           AVCORR(3) = '.2100000+002'
           DO 40021 I = 1, 3
           IF (A431K(1).EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40021, 10020, 40021
40021      CONTINUE
           GO TO 20020
10020      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0021
20020      IVFAIL = IVFAIL + 1
           CVCORR = '.2100000D+02'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A431K(1)
           WRITE (NUVI, 80022) CVCORR
 0021      CONTINUE
CT003*  TEST 3                                     CHARACTER SUBSTRING
           IVTNUM = 3
        A97VK = ' SOME WHERE'
        AVD = 23.45D2
        WRITE(UNIT=A97VK(21:),FMT=39305) AVD
39305   FORMAT(11X,D14.9)
           IVCOMP = 0
           AVCORR(1) = ' SOME WHERE                    .234500000D+04'
           AVCORR(2) = ' SOME WHERE                    .234500000E+04'
           AVCORR(3) = ' SOME WHERE                    .234500000+004'
           DO 40031 I = 1, 3
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40031, 10030, 40031
40031      CONTINUE
           GO TO 20030
10030      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0031
20030      IVFAIL = IVFAIL + 1
           CVCORR =    ' SOME WHERE                    .234500000D+04'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0031      CONTINUE
C*****    TESTS 4 - 5                              ARRAY, SINGLE RECORD
CT004*  TEST 4
           IVTNUM = 4
        CVD = 23.45D2
        A431K(2) = ' '
        WRITE(UNIT=A431K,FMT=39306) CVD
39306   FORMAT(24X,D19.10)
           IVCOMP = 0
           AVCORR(1) = '                           0.2345000000D+04'
           AVCORR(2) = '                           0.2345000000E+04'
           AVCORR(3) = '                           0.2345000000+004'
           AVCORR(4) = '                            .2345000000D+04'
           AVCORR(5) = '                            .2345000000E+04'
           AVCORR(6) = '                            .2345000000+004'
           AVCORR(7) = '                           +.2345000000D+04'
           AVCORR(8) = '                           +.2345000000E+04'
           AVCORR(9) = '                           +.2345000000+004'
           AVCORR(10) = '                          +0.2345000000D+04'
           AVCORR(11) = '                          +0.2345000000E+04'
           AVCORR(12) = '                          +0.2345000000+004'
           DO 40041 I = 1, 12
           IF (A431K(1).EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40041, 10040, 40041
40041      CONTINUE
           GO TO 20040
10040      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0041
20040      IVFAIL = IVFAIL + 1
           CVCORR = '                           0.2345000000D+04'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70050) (A97E1(I), I = 1,43)
           WRITE (NUVI, 70060) (A97E2(I), I = 1,43)
70050      FORMAT(1H ,16X,10HCOMPUTED: ,43A1)
70060      FORMAT(1H ,16X,10HCORRECT:  ,43A1)
 0041      CONTINUE
CT005*  TEST 5
           IVTNUM = 5
           IVCOMP = 0
           IF (A431K(2).EQ.' ') IVCOMP = 1
           IF (IVCOMP - 1) 20050, 10050, 20050
10050      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0051
20050      IVFAIL = IVFAIL + 1
           CVCORR = ' '
           WRITE (NUVI, 80018) IVTNUM, A431K(2), CVCORR
 0051      CONTINUE
C*****    TESTS 6 - 10             ARRAY, 5 RECORDS, ONE BLANK
CT006*  TEST 6
           IVTNUM = 6
        B1D(1) = 11D1
        B1D(2) = 21D1
        B1D(3) = 31D1
        B1D(4) = 32D1
        B1D(5) = 51D1
        WRITE(UNIT=A291K,FMT=39307) (B1D(JVI), JVI=1,5)
39307   FORMAT(E11.6E2/1X,E10.5E2/2X,2(E9.4E2,3X)//4X,E7.2E2)
           IVCOMP = 0
           IF (A291K(1).EQ.'.110000E+03') IVCOMP = 1
           IF (IVCOMP - 1) 20060, 10060, 20060
10060      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0061
20060      IVFAIL = IVFAIL + 1
           CVCORR = '.110000E+03'
           WRITE (NUVI, 80018) IVTNUM, A291K(1), CVCORR
 0061      CONTINUE
CT007*  TEST 7
           IVTNUM = 7
           IVCOMP = 0
           IF (A291K(2).EQ.' .21000E+03') IVCOMP = 1
           IF (IVCOMP - 1) 20070, 10070, 20070
10070      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0071
20070      IVFAIL = IVFAIL + 1
           CVCORR = ' .21000E+03'
           WRITE (NUVI, 80018) IVTNUM, A291K(2), CVCORR
 0071      CONTINUE
CT008*  TEST 8
           IVTNUM = 8
           IVCOMP = 0
           IF (A291K(3).EQ.'  .3100E+03   .3200E+03') IVCOMP = 1
           IF (IVCOMP - 1) 20080, 10080, 20080
10080      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0081
20080      IVFAIL = IVFAIL + 1
           CVCORR = '  .3100+003   .3200E+03'
           WRITE (NUVI, 70070) IVTNUM, A291K(3), CVCORR
70070      FORMAT (1H ,2X,I3,4X,7H FAIL  ,/,1H ,16X,10HCOMPUTED: ,
     1             A29,/,1H ,16X,10HCORRECT:  ,A29)
 0081      CONTINUE
CT009*  TEST 9
           IVTNUM = 9
           IVCOMP = 0
           IF (A291K(4).EQ.' ') IVCOMP = 1
           IF (IVCOMP - 1) 20090, 10090, 20090
10090      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0091
20090      IVFAIL = IVFAIL + 1
           CVCORR = ' '
           WRITE (NUVI, 80018) IVTNUM, A291K(4), CVCORR
 0091      CONTINUE
CT010*  TEST 10
           IVTNUM = 10
           IVCOMP = 0
           IF (A291K(5).EQ.'    .51E+03') IVCOMP = 1
           IF (IVCOMP - 1) 20100, 10100, 20100
10100      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0101
20100      IVFAIL = IVFAIL + 1
           CVCORR = '    .51E+03'
           WRITE (NUVI, 80018) IVTNUM, A291K(5), CVCORR
 0101      CONTINUE
C*****
        WRITE(NUVI, 90002)
        WRITE(NUVI, 90013)
        WRITE(NUVI, 90014)
C*****
CT011*  TEST 11                           VARIABLE, MORE THEN ONE FIELD
           IVTNUM = 11
        AVD = 34.58673D2
        BVD = 34.58673D2
        CVD = 34.58673D2
        DVD = 34.58673D2
        WRITE(UNIT=A97VK,FMT=39309) AVD, BVD, CVD, DVD
39309   FORMAT(D10.5,1X,F10.5,1X,D11.5,G11.5)
           IVCOMP = 0
           CVCORR = '.34587D+04 3458.67300 0.34587D+04 3458.7'
           IF (A97VK.EQ.CVCORR) IVCOMP = 1
           IF (IVCOMP - 1) 20110, 10110, 20110
10110      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0111
20110      IVFAIL = IVFAIL + 1
           REMRKS = '54 PERMISSIBLE REPRESENTATIONS'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'SEE NOTES ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0111      CONTINUE
CT012*  TEST 12                                 GW.D FIELD WITH D.P.
           IVTNUM = 12
        AVD = 314.5673D0
        BVD = 14.45673D-1
        CVD = 85.7343D6
        WRITE(UNIT=A97VK,FMT=39310) AVD, BVD, CVD
39310   FORMAT(G12.5,1X,G14.5E3,1X,G10.5E2)
           IVCOMP = 0
           AVCORR(1) = '  314.57        1.4457      .85734E+08'
           AVCORR(2) = ' +314.57        1.4457      .85734E+08'
           AVCORR(3) = '  314.57       +1.4457      .85734E+08'
           AVCORR(4) = ' +314.57       +1.4457      .85734E+08'
           DO 40121 I = 1, 4
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40121, 10120, 40121
40121      CONTINUE
           GO TO 20120
10120      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0121
20120      IVFAIL = IVFAIL + 1
           CVCORR = '  314.57        1.4457      .85734E+08'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS. SEE '
           WRITE (NUVI, 80050) REMRKS
           REMRKS = 'NOTES ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0121      CONTINUE
CT013*  TEST 13                         DIFFERENT TYPES IN SAME RECORD
           IVTNUM = 13
        KVI = 348
        AVS = 34.783
        AVD = 384.3847D1
        AVB = .TRUE.
        BVS = 3.4857
        A8VK = 'KDFJ D/.'
        WRITE(UNIT=A97VK,FMT=39311) KVI, AVS, AVD, AVB, BVS, A8VK
39311   FORMAT(I4,1X,E9.4,1X,D10.4,1X,L4,1X,F12.5,1X,A8)
           IVCOMP = 0
           CVCORR = ' 348 .3478E+02 0.3844D+04    T      3.48570 KDFJ D/
     1.'
           IF (A97VK.EQ.CVCORR) IVCOMP = 1
           IF (IVCOMP - 1) 20130, 10130, 20130
10130      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0131
20130      IVFAIL = IVFAIL + 1
           REMRKS = '72 PERMISSIBLE REPRESENTATIONS'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'SEE NOTES ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0131      CONTINUE
CT014*  TEST 14                                 POSITIONAL EDITING
           IVTNUM = 14
        AVB = .TRUE.
        AVS = 10.98
        A8VK = 'THISISIT'
        AVD = 3.4945D2
        BVS = 3.4945
        KVI = 3
        WRITE(UNIT=A97VK,FMT=39312) AVB, AVS, A8VK, AVD, BVS, KVI
39312   FORMAT(L1,T5,F5.2,A8,TR2,E10.4E2,TL10,F6.4,6X,I1)
           IVCOMP = 0
           IF (A97VK.EQ.'T   10.98THISISIT  3.4945E+03  3')
     1     IVCOMP = 1
           IF (IVCOMP - 1) 20140, 10140, 20140
10140      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0141
20140      IVFAIL = IVFAIL + 1
           CVCORR = 'T   10.98THISISIT  3.4945E+03  3'
           WRITE (NUVI, 80008) IVTNUM
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0141      CONTINUE
CT015*  TEST 15                                      COLON AND SIGN
           IVTNUM = 15
        AVB = .TRUE.
        AVS = 98.11
        A8VK = 'THISISIT'
        AVD = 3.4945D2
        KVI = 33
        WRITE(UNIT=A97VK,FMT=39313) AVB, AVS, A8VK, AVD, KVI
39313   FORMAT(L1,S,F7.2,A8,SP,D11.5,6X,SS,I2,:,F9.3)
           IVCOMP = 0
           AVCORR(1) = 'T  98.11THISISIT+.34945D+03      33'
           AVCORR(2) = 'T  98.11THISISIT+.34945E+03      33'
           AVCORR(3) = 'T  98.11THISISIT+.34945+003      33'
           DO 40151 I = 1, 3
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40151, 10150, 40151
40151      CONTINUE
           GO TO 20150
10150      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0151
20150      IVFAIL = IVFAIL + 1
           CVCORR = 'T  98.11THISISIT+.34945D+03      33'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0151      CONTINUE
CT016*  TEST 16                             COMPLEX TYPES INTO VARIABLE
           IVTNUM = 16
        AVC = (2.343, 34.394)
        WRITE(UNIT=A97VK,FMT=39314) AVC
39314   FORMAT(F10.5,1X,F10.5)
           IVCOMP = 0
           AVCORR(1) = '   2.34300   34.39400'
           AVCORR(2) = '   2.34300  +34.39400'
           AVCORR(3) = '  +2.34300   34.39400'
           AVCORR(4) = '  +2.34300  +34.39400'
           DO 40161 I = 1, 4
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40161, 10160, 40161
40161      CONTINUE
           GO TO 20160
10160      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0161
20160      IVFAIL = IVFAIL + 1
           CVCORR = '  +2.34300  +34.39400'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0161      CONTINUE
CT017*  TEST 17
           IVTNUM = 17
        AVC = (34.84, 349.887)
        WRITE(UNIT=A97VK,FMT=39315) AVC
39315   FORMAT(E12.5,1X,E12.5)
           IVCOMP = 0
           IF (A97VK.EQ.' 0.34840E+02  0.34989E+03') IVCOMP = 1
           IF (IVCOMP - 1) 20170, 10170, 20170
10170      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0171
20170      IVFAIL = IVFAIL + 1
           CVCORR = ' 0.34840E+02  0.34989E+03'
           REMRKS = '16 PERMISSIBLE REPRESENTATIONS'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'SEE NOTES ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0171      CONTINUE
CT018*  TEST 18                                       LIST OF COMPLEX
           IVTNUM = 18
        AVC = (2.34, 2.456)
        BVC = (2.34, 2.456)
        CVC = (2.34, 2.456)
        WRITE(UNIT=A97VK,FMT=39316) AVC, BVC, CVC
39316   FORMAT(2(G9.4,1X),2(G10.4E2,1X),2(G11.5E3,1X))
           IVCOMP = 0
           AVCORR(1) = '2.340     2.456      2.340      2.456     2.3400
     1      2.4560'
           AVCORR(2) = '2.340     2.456      2.340     +2.456     2.3400
     1      2.4560'
           AVCORR(3) = '2.340     2.456     +2.340      2.456     2.3400
     1      2.4560'
           AVCORR(4) = '2.340     2.456     +2.340     +2.456     2.3400
     1      2.4560'
           DO 40181 I = 1, 4
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40181, 10180, 40181
40181      CONTINUE
           GO TO 20180
10180      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0181
20180      IVFAIL = IVFAIL + 1
           CVCORR = '2.340     2.456      2.340      2.456     2.3400
     1   2.4560'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0181      CONTINUE
CT019*  TEST 19                                    LIST FROM SUBSTRING
           IVTNUM = 19
        AVC = (5.6798, 0.9876)
        BVC = (5.6798, 0.9876)
        CVC = (5.6798, 0.9876)
        WRITE(UNIT=A97VK(1:),FMT=39317) AVC, BVC, CVC
39317   FORMAT(2(E6.2E1,1X),1X,2(E7.2E2,1X),1X,2(E9.2E3,1X))
           IVCOMP = 0
           AVCORR(1) = '.57E+1 .99E+0  .57E+01 .99E+00   .57E+001  .99E+
     1000'
           AVCORR(2) = '.57E+1 .99E+0  .57E+01 .99E+00   .57E+001 0.99E+
     1000'
           AVCORR(3) = '.57E+1 .99E+0  .57E+01 .99E+00   .57E+001 +.99E+
     1000'
           AVCORR(4) = '.57E+1 .99E+0  .57E+01 .99E+00  0.57E+001  .99E+
     1000'
           AVCORR(5) = '.57E+1 .99E+0  .57E+01 .99E+00  0.57E+001 0.99E+
     1000'
           AVCORR(6) = '.57E+1 .99E+0  .57E+01 .99E+00  0.57E+001 +.99E+
     1000'
           AVCORR(7) = '.57E+1 .99E+0  .57E+01 .99E+00  +.57E+001  .99E+
     1000'
           AVCORR(8) = '.57E+1 .99E+0  .57E+01 .99E+00  +.57E+001 0.99E+
     1000'
           AVCORR(9) = '.57E+1 .99E+0  .57E+01 .99E+00  +.57E+001 +.99E+
     1000'
           DO 40191 I = 1, 9
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40191, 10190, 40191
40191      CONTINUE
           GO TO 20190
10190      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0191
20190      IVFAIL = IVFAIL + 1
           CVCORR = '.57E+1 .99E+0  .57E+01 .99E+00  0.57E+001 0.99E+000
     1'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0191      CONTINUE
CT020*  TEST 20                                         MIXED TYPES
           IVTNUM = 20
        AVC = (0.934, 34.567)
        AVS = 34.65
        AVD = 0.6354D1
        WRITE(UNIT=A97VK,FMT=39318) AVC, AVS, AVD
39318   FORMAT(F7.3,1X,F7.3,1X,F10.5,1X,E13.5E2)
           IVCOMP = 0
           IF (A97VK.EQ.'  0.934  34.567   34.65000   0.63540E+01') IVCO
     1MP = 1
           IF (IVCOMP - 1) 20200, 10200, 20200
10200      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0201
20200      IVFAIL = IVFAIL + 1
           CVCORR = '  0.934  34.567   34.65000   0.63540E+01'
           REMRKS = '32 PERMISSIBLE REPRESENTATIONS'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'SEE NOTES ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0201      CONTINUE
C*****
        WRITE(NUVI, 90002)
        WRITE(NUVI, 90013)
        WRITE(NUVI, 90014)
C*****
CT021*  TEST 21                     MIXED TYPES WITH POSITIONAL EDITING
           IVTNUM = 21
        AVC = (0.345, 34.349)
        AVB = .FALSE.
        AVD = 34.859D-1
        AVS = 10.0
        A8VK = '12345678'
        WRITE(UNIT=A97VK,FMT=39319) AVC, AVB, AVD, AVS, A8VK
39319   FORMAT(F9.4,1X,E9.4,1X,L1,1X,D12.5,1X,G9.4,A8)
           IVCOMP = 0
           IF (A97VK.EQ.'   0.3450 .3435E+02 F  0.34859D+01 10.00    123
     145678') IVCOMP = 1
           IF (IVCOMP - 1) 20210, 10210, 20210
10210      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0211
20210      IVFAIL = IVFAIL + 1
           CVCORR = '   0.3450 .3435E+02 F  0.34859D+01 10.00    1234567
     18'
           REMRKS = '96 PERMISSIBLE REPRESENTATIONS'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'SEE NOTES ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0211      CONTINUE
C*****    TESTS 22 - 26                     MIXED TYPES INTO 5 RECORDS
CT022*  TEST 22
           IVTNUM = 22
        KVI = 98
        AVD = 84.0489D1
        AVB = .TRUE.
        AVC = (34.0435, 34.94)
        A8VK = 'THE LAST'
        WRITE(UNIT=A291K,FMT=39320) KVI, AVD, AVB, AVC, A8VK
39320   FORMAT(I5/E10.5E2//1X,L6,2(1X,E10.3)/A8)
           IVCOMP = 0
           AVCORR(1) = '   98'
           AVCORR(2) = '  +98'
           DO 40221 I = 1, 2
           IF (A291K(1).EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40221, 10220, 40221
40221      CONTINUE
           GO TO 20220
10220      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0221
20220      IVFAIL = IVFAIL + 1
           CVCORR = '   98'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 80020) A291K(1)
           WRITE (NUVI, 80022) CVCORR
 0221      CONTINUE
CT023*  TEST 23
           IVTNUM = 23
           IVCOMP = 0
           IF (A291K(2).EQ.'.84049E+03') IVCOMP = 1
           IF (IVCOMP - 1) 20230, 10230, 20230
10230      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0231
20230      IVFAIL = IVFAIL + 1
           CVCORR = '.84049E+03'
           WRITE (NUVI, 80018) IVTNUM, A291K(2), CVCORR
 0231      CONTINUE
CT024*  TEST 24
           IVTNUM = 24
           IVCOMP = 0
           IF (A291K(3).EQ.' ') IVCOMP = 1
           IF (IVCOMP - 1) 20240, 10240, 20240
10240      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0241
20240      IVFAIL = IVFAIL + 1
           CVCORR = ' '
           WRITE (NUVI, 80018) IVTNUM, A291K(3), CVCORR
 0241      CONTINUE
CT025*  TEST 25
           IVTNUM = 25
           IVCOMP = 0
           IF (A291K(4).EQ.'      T  0.340E+02  0.349E+02') IVCOMP = 1
           IF (IVCOMP - 1) 20250, 10250, 20250
10250      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0251
20250      IVFAIL = IVFAIL + 1
           CVCORR = '      T  0.340E+02  0.349E+02'
           REMRKS = '64 PERMISSIBLE REPRESENTATIONS'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'SEE NOTES ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70080) A291K(4), CVCORR
70080      FORMAT (1H ,16X,10HCOMPUTED: , A29,/
     1             1H ,16X,10HCORRECT:  ,A29)
 0251      CONTINUE
CT026*  TEST 26
           IVTNUM = 26
           IVCOMP = 0
           IF (A291K(5).EQ.'THE LAST') IVCOMP = 1
           IF (IVCOMP - 1) 20260, 10260, 20260
10260      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0261
20260      IVFAIL = IVFAIL + 1
           CVCORR = 'THE LAST'
           WRITE (NUVI, 80018) IVTNUM, A291K(5), CVCORR
 0261      CONTINUE
CT027*  TEST 27                      MIXED TYPES WITH SS, SP, NX, AND :
           IVTNUM = 27
        JVI = 34
        AVS = 34.983
        BVS = 345.3
        AVD = 95.83D2
        AVB = .FALSE.
        A8VK = '.FALSE.1'
        WRITE(UNIT=A97VK,FMT=39321)JVI, AVS, AVD, AVB, A8VK, BVS
39321   FORMAT(S,I2,1X,SP,F7.3,SS,1X,D10.5,L2,1X,A8,1X,E10.5,:,I5,F10.4)
           IVCOMP = 0
           AVCORR(1) = '34 +34.983 .95830D+04 F .FALSE.1 .34530E+03'
           AVCORR(2) = '34 +34.983 .95830D+04 F .FALSE.1 .34530+003'
           AVCORR(3) = '34 +34.983 .95830E+04 F .FALSE.1 .34530E+03'
           AVCORR(4) = '34 +34.983 .95830E+04 F .FALSE.1 .34530+003'
           AVCORR(5) = '34 +34.983 .95830+004 F .FALSE.1 .34530E+03'
           AVCORR(6) = '34 +34.983 .95830+004 F .FALSE.1 .34530+003'
           DO 40271 I = 1, 6
           IF (A97VK.EQ.AVCORR(I)) IVCOMP = 1
           IF (IVCOMP - 1) 40271, 10270, 40271
40271      CONTINUE
           GO TO 20270
10270      IVPASS = IVPASS + 1
           WRITE (NUVI, 80002) IVTNUM
           GO TO 0271
20270      IVFAIL = IVFAIL + 1
           CVCORR = '34 +34.983 .95830D+04 F .FALSE.1 .34530E+03'
           REMRKS = 'COMPUTED VALUE NOT CONSISTENT'
           WRITE (NUVI, 80008) IVTNUM, REMRKS
           REMRKS = 'WITH PERMISSIBLE OPTIONS ABOVE'
           WRITE (NUVI, 80050) REMRKS
           WRITE (NUVI, 70010) (A97E1(I), I = 1,54)
           WRITE (NUVI, 70020) (A97E1(I), I= 55,97)
           WRITE (NUVI, 70030) (A97E2(I), I = 1,54)
           WRITE (NUVI, 70040) (A97E2(I), I= 55,97)
 0271      CONTINUE
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
C*****    END OF TEST SEGMENT 393
      STOP
      END
*END-OF,FM909
