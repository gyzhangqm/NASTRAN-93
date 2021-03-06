      SUBROUTINE OFP        
C        
C     THE OUTPUT FILE PROCESSOR        
C        
C     THIS SUBROUTINE IS THE MAIN AND ONLY DRIVER.        
C     OFP1 OUTPUTS HEADINGS ONLY.        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL          AXIC,FLUID,TEMPER,ONEFIL,HEADNG,SOLSET,ELEMEN,   
     1                 PNCHED,HEAT,GPFB,ESE,DUMMY,GPST,EOR,PACK,STRAIN  
      INTEGER          REAL(10),IMAG(5),ISAVE(20),GSE(4),I15BLK(2),     
     1                 FILEX(6),B(23,4),FMT(300),IOUT(100),TSAVE(96),   
     2                 SCAN(2),ID(50),BUFF(1),OF(56)        
      REAL             FREAL(10),FIMAG(2),OUT(100)        
      DOUBLE PRECISION DOUT(50)        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM,SWM        
      COMMON /BLANK /  ICARD,OPTION(2)        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /OFPCOM/  TEMPER,MPUNCH        
      COMMON /OFPBD1/  D(1)        
      COMMON /OFPBD5/  ESINGL(64),E(1)        
CZZ   COMMON /ZZOFPX/  CORE(1)        
      COMMON /ZZZZZZ/  CORE(1)        
      COMMON /OFP1ID/  IDM(2)        
      COMMON /OUTPUT/  HEAD(96)        
      EQUIVALENCE      (KSYSTM( 1),SYSBUF), (KSYSTM( 2),L     ),        
     1                 (KSYSTM( 9),MAXLNS), (KSYSTM(12),LINE  ),        
     2                 (KSYSTM(38),AXIF  ), (KSYSTM(56),ITHERM),        
     3                 (FREAL (1),REAL(1)), (FIMAG (1),IMAG(1)),        
     4                 (ID    (3),IELTYP ), (IOUT(1),OUT(1),DOUT(1)),   
     5                 (L1, OF(1),CORE(1)), (L2,OF(2)), (L3,OF(3)),     
     6                 (L4, OF(4)), (L5,OF(5)), (ID(1),OF(6)),        
     7                 (BUFF(1),OF(56))        
      DATA    PE    /  4H1P,E /,   PF   / 4H0P,F /        
      DATA    E236  /  4H23.6 /,   F236 / 4H14.1 /        
      DATA    E156  /  4H15.6 /,   F156 / 4H6.1  /        
      DATA    I8    /  4H,I8, /,   I12  / 4H,I11 /        
      DATA    I2X   /  4H2X   /,   I2XX / 4H,2X  /        
      DATA    I1X   /  4H(1X  /,   I1XX / 4H,1X  /        
      DATA    ISTAR /  4H,1H* /,   I15X / 4H/14X /        
      DATA    IH0   /  4H/1H0 /,   I1H0 / 4H(1H0 /        
      DATA    I9X   /  4H,9X  /,   I6X  / 4H,6X  /        
      DATA    F174  /  4H17.4 /        
      DATA    STATIC,  REIGEN  ,   FREQ ,  TRANS  , BK1  , CEIGEN  /    
     1        1     ,  2       ,   5    ,  6      , 8    , 9       /    
      DATA    A4    ,  COMMA   ,   CPAREN, OPAREN , METHD /        
     1        4HA4  ,  4H,     ,   4H)   , 4H(    , 0     /        
      DATA    EEND  /  195    /,   I15BLK/ 4HA4,  , 4H11X /,        
     1        GSE   /  4HG     ,   4HS   , 4HE    , 4HM   /        
      DATA    FILEX /  101, 102,  103,104, 105    , 106   /        
      DATA    IBLANK,  E9PT1  /    4H    , 195    /        
      DATA    IHEAT /  4HHEAT /,   CENTER/ 4HTER  /        
      DATA    PHASE /  4H1P9E /,   SCAN  / 4HSCAN , 4HNED /        
      DATA    HEX1  ,  HEX2, HEX3 /4HHEX1, 4HHEX2 , 4HHEX3/        
C        
C        
C     THE FOLLOWING ARE ZERO POINTERS TO THE DATA-BLOCK AND LINE-SET    
C     SELECTION LISTS.  TO THIS THE SUBSET SELECTION POINTER IS ADDED.  
C     THE SUBSET SELECTION POINTER IS BASED ON INFORMATION IN THE ID    
C     RECORD.        
C        
C     A MINUS ONE IN THE FOLLOWING ARRAY INDICATES AN UNDEFINED OUTPUT. 
C        
C            S O R T - I    S O R T - I I        
C          *************** ****************        ZERO-BASE        
C          REAL    COMPLEX REAL    COMPLEX    POINTERS INTO C-ARY       
C     *************************************   *******************       
C     DISPLACEMENT VECTOR        
      DATA B( 1,1),B( 1,2),B( 1,3),B( 1,4) /    0,   4,   2,   6 /      
C        
C     LOAD VECTOR        
      DATA B( 2,1),B( 2,2),B( 2,3),B( 2,4) /    8,  12,  10,  14 /      
C        
C     SPCF VECTOR        
      DATA B( 3,1),B( 3,2),B( 3,3),B( 3,4) /   16,  20,  18,  22 /      
C        
C     ELEMENT FORCE   (ZERO POINTERS INTO OVERLAY BLOCK DATA)        
      DATA B( 4,1),B( 4,2),B( 4,3),B( 4,4) /    0,   0,   0,   0 /      
C        
C     ELEMENT STRESS  (ZERO POINTERS FOR OVERLAY BLOCK DATA)        
      DATA B( 5,1),B( 5,2),B( 5,3),B( 5,4) /    0,   0,   0,   0 /      
C        
C     EIGENVALUE SUMMARY        
      DATA B( 6,1),B( 6,2),B( 6,3),B( 6,4) /   38,  39,  -1,  -1 /      
C        
C     EIGENVECTOR        
      DATA B( 7,1),B( 7,2),B( 7,3),B( 7,4) /   72,  40,  -1,  -1 /      
C        
C     GPST        
      DATA B( 8,1),B( 8,2),B( 8,3),B( 8,4) /   73,  -1,  -1,  -1 /      
C        
C     EIGENVALUE ANALYSIS SUMMARY        
      DATA B( 9,1),B( 9,2),B( 9,3),B( 9,4) /   64,  68,  -1,  -1 /      
C        
C     VELOCITY VECTOR        
      DATA B(10,1),B(10,2),B(10,3),B(10,4) /   24,  30,  26,  32 /      
C        
C     ACCELERATION VECTOR        
      DATA B(11,1),B(11,2),B(11,3),B(11,4) /   25,  34,  27,  36 /      
C        
C     NON-LINEAR-FORCE VECTOR        
      DATA B(12,1),B(12,2),B(12,3),B(12,4) /   28,  -1,  29,  -1 /      
C        
C     GRID-POINT-WEIGHT-OUTPUT        
      DATA B(13,1),B(13,2),B(13,3),B(13,4) /   -1,  -1,  -1,  -1 /      
C        
C     EIGENVECTOR (SOLUTION SET FROM VDR)        
      DATA B(14,1),B(14,2),B(14,3),B(14,4) /   -1,  60,  -1,  62 /      
C        
C     DISP-VECTOR (SOLUTION SET FROM VDR)        
      DATA B(15,1),B(15,2),B(15,3),B(15,4) /   42,  44,  43,  46 /      
C        
C     VELO-VECTOR (SOLUTION SET FROM VDR)        
      DATA B(16,1),B(16,2),B(16,3),B(16,4) /   48,  50,  49,  52 /      
C        
C     ACCE-VECTOR (SOLUTION SET FROM VDR)        
      DATA B(17,1),B(17,2),B(17,3),B(17,4) /   54,  56,  55,  58 /      
C        
C     ELEMENT STRAIN ENERGY (FROM GPFDR)        
      DATA B(18,1),B(18,2),B(18,3),B(18,4) /   74,  -1,  -1,  -1 /      
C        
C     GRID POINT FORCE BALANCE (FROM GPFDR)        
      DATA B(19,1),B(19,2),B(19,3),B(19,4) /   76,  -1,  -1,  -1 /      
C        
C     MPCFORCE VECTOR        
      DATA B(20,1),B(20,2),B(20,3),B(20,4) /   78,  -1,  -1,  -1 /      
C        
C     ELEMENT STRAIN/CURVATURE (ZERO POINTER FOR OVERLAY BLOCK DATA)    
      DATA B(21,1),B(21,2),B(21,3),B(21,4) /    0,  -1,  -1,  -1 /      
C        
C     STRESSES IN LAYERED COMPOSITE ELEMENTS (ZERO POINTER)        
      DATA B(22,1),B(22,2),B(22,3),B(22,4) /    0,   0,   0,   0 /      
C        
C     FORCES IN LAYERED COMPOSITE ELEMENTS   (ZERO POINTER)        
      DATA B(23,1),B(23,2),B(23,3),B(23,4) /    0,   0,   0,   0 /      
C     ************************************   *******************        
C        
C     SAVE OLD TITLES WHATEVER THEY BE AND RESTORE BEFORE RETURNING     
C        
      CALL TOTAPE (3,BUFF(1))        
      HEAT = .FALSE.        
      IF (ITHERM .NE. 0) HEAT = .TRUE.        
      OPTION(1) = 0        
      IF (HEAT) OPTION(1) = IHEAT        
      ONEFIL = .FALSE.        
      GO TO 10        
C        
C        
      ENTRY OFPDMP (IFILE1)        
C     =====================        
C        
      ONEFIL = .TRUE.        
   10 DO 20 I = 1,96        
   20 TSAVE(I) = HEAD(I)        
C        
      ICORE = KORSZ(BUFF)        
      IF (ICORE .GE. SYSBUF) GO TO 40        
      WRITE  (6,30) UWM,ICORE,SYSBUF        
   30 FORMAT (A25,' 2043, OFP HAS INSUFFICIENT CORE FOR ONE GINO ',     
     1       'BUFFER ****    OFP NOT EXECUTED.')        
      RETURN        
C        
   40 LINE  = 0        
      IFILE = 0        
C        
C     LOOP FOR 6 FILES        
C        
   50 IFILE = IFILE + 1        
      IF (ONEFIL .AND. IFILE.GT.1) GO TO 2060        
      FILE = FILEX(IFILE)        
      IF (ONEFIL) FILE = IFILE1        
      CALL OPEN (*2050,FILE,BUFF(1),0)        
      FROM = 55        
      CALL FWDREC (*2020,FILE)        
   60 CALL READ (*2040,*2040,FILE,  ID(1),50,0,FLAG)        
      CALL READ (*2040,*2040,FILE,HEAD(1),96,1,FLAG)        
      AXIC   = .FALSE.        
      TEMPER = .FALSE.        
      DUMMY  = .FALSE.        
      GPST   = .FALSE.        
      SORT   =  1        
      PNCHED = .FALSE.        
      HEADNG = .FALSE.        
      GPFB   = .FALSE.        
      ESE    = .FALSE.        
      STRAIN = .FALSE.        
C        
C     COMPUTE I AND J, THE B ARRAY SUBSCRIPTS        
C        
      J = ID(2)/1000        
      I = ID(2) - J*1000        
      J = J + 1        
      IF (I.NE.4 .AND. I.NE.5 .AND. I.NE.21) GO TO 70        
      ICURV = ID(3)/1000        
      ID(3) = ID(3) - 1000*ICURV        
C        
   70 PACK   = .FALSE.        
      SOLSET = .FALSE.        
      FLUID  = .FALSE.        
      IF (AXIF .NE. 0) FLUID = .TRUE.        
      ELEMEN = .FALSE.        
      IAPP = ID(1)/10        
      NADD = 1        
      FROM = 75        
      IF (J .GT. 4) GO TO 2020        
      FROM = 77        
      IF (J) 2020,80,80        
   80 FROM = 80        
      IF (I.LT.1 .OR. I.GT.23) GO TO 2020        
      IF (J .GT. 2) SORT = 2        
      IF (J.NE.3 .OR. IAPP.NE.STATIC) GO TO 120        
      IF (HEAD(74).EQ.SCAN(1) .AND. HEAD(75).EQ.SCAN(2)) GO TO 100      
      DO 90 IHD = 65,96        
   90 HEAD(IHD) = IBLANK        
      GO TO 120        
  100 DO 110 IHD = 65,72        
      IF (IHD .GE. 68) HEAD(IHD+22) = IBLANK        
  110 HEAD(IHD) = IBLANK        
  120 GO TO (150,150,150,230,240,270,150,290,300,150,        
     1       150,150,340,380,380,380,380,390,400,220,        
     2       410,420,420), I        
  150 PACK = .TRUE.        
      IF (ID(3) .EQ. 1000) AXIC = .TRUE.        
      GO TO (200,210,220,160,160,160,280,160,160,310,320,330), I        
  160 CALL MESAGE (-61,0,0)        
C        
C     DISPLACEMENT VECTOR        
C        
  200 IF (J.EQ.3 .AND. IAPP.EQ.TRANS) NADD = 7        
      IF (OPTION(1) .NE. IHEAT) GO TO 500        
      IF (I.EQ.1 .AND. (J.EQ.1 .OR. J.EQ.3)) TEMPER =.TRUE.        
      GO TO 500        
C        
C     LOAD VECTOR        
C        
  210 IF (J.EQ.3 .AND. IAPP.EQ.TRANS) NADD = 7        
      GO TO 500        
C        
C     SPCF VECTOR, MPCF VECTOR        
C        
  220 IF (J.EQ.3 .AND. IAPP.EQ.TRANS) NADD = 7        
      GO TO 500        
C        
C     ELEMENT FORCE, ELEMENT STRESS        
C        
  230 CONTINUE        
  240 FROM = 240        
      IF (ID(3).LT. 1 .OR.  ID(3).GT.100) GO TO 2020        
      IF (ID(3).GT.52 .AND. ID(3).LT. 62) DUMMY = .TRUE.        
      ELEMEN = .TRUE.        
      IOPT   = 2        
      IF (ICURV.GT.0 .AND. J.EQ.1) GO TO 260        
      IF (ICURV.GT.0 .AND. (J.EQ.2 .OR. J.EQ.4)) GO TO 250        
      NADD = 6*(ID(3)-1) + 1        
      IF (J.EQ.2 .OR. J.EQ.4) NADD = NADD*2 - 1        
      GO TO 500        
  250 FROM = 250        
      IF (ICURV .GT. 1) GO TO 2020        
      NADD = 0        
      IF (ID(3) .EQ.  6) NADD =  1        
      IF (ID(3) .EQ. 17) NADD = 13        
      IF (ID(3) .EQ. 18) NADD = 25        
      IF (ID(3) .EQ. 19) NADD = 37        
      GO TO 500        
C        
C     ELEMENT STRESS IN MATERIAL COORDINATE SYSTEM        
C        
  260 FROM = 260        
      IF (ICURV .GT. 2) GO TO 2020        
      NADD = 0        
      IF (ID(3) .EQ.  6) NADD =  1        
      IF (ID(3) .EQ. 17) NADD =  7        
      IF (ID(3) .EQ. 18) NADD = 13        
      IF (ID(3) .EQ. 19) NADD = 19        
      IF (ICURV .EQ.  2) NADD = 25        
      GO TO 500        
C        
C     EIGENVALUE SUMMARY        
C        
  270 CONTINUE        
      GO TO 500        
C        
C     EIGENVECTOR        
C        
  280 CONTINUE        
      GO TO 500        
C        
C     GPST        
C        
  290 GPST = .TRUE.        
      GO TO 500        
C        
C     EIGENVALUE ANALYSIS SUMMARY        
C       ID(3) = 1  DETERMINANT METHOD TABLE        
C       ID(3) = 2  INVERSE POWER TABLE        
C       ID(3) = 3  DETERMINANT METHOD SWEPT FUNCTION DATA VECTORS       
C       ID(3) = 4  UPPER HESSENBERG METHOD TABLE        
C        
  300 NADD = 6*(ID(3)-1) + 1        
      FROM = 300        
      IF (ID(3) .GT. 4) GO TO 2020        
      GO TO 500        
C        
C     VELOCITY VECTOR        
C        
  310 CONTINUE        
      GO TO 500        
C        
C     ACCELERATION VECTOR        
C        
  320 CONTINUE        
      GO TO 500        
C        
C     NON-LINERAR FORCE VECTOR        
C        
  330 SOLSET = .TRUE.        
      GO TO 500        
C        
C     GRID-POINT-WEIGHT-OUTPUT        
C     (FROM = 345 AND 355 ARE SETUP IN OFPGPW)        
C        
  340 FROM = 340        
      IF (J .GT. 1) GO TO 2020        
      CALL OFPGPW (*2020,FILE,DOUT,FROM)        
      GO TO 60        
C        
C     EIGENVECTOR, DISPLACEMENT, VELOCITY, ACCELERATION        
C     (VDR OUTPUT ONLY)        
C        
  380 PACK   = .TRUE.        
      SOLSET = .TRUE.        
      GO TO 500        
C        
C     ELEMENT STRAIN ENERGY.        
C        
  390 ESE  = .TRUE.        
      IOPT =  3        
      GO TO 500        
C        
C     GRID POINT FORCE BALANCE.        
C        
  400 GPFB = .TRUE.        
      IOPT =  4        
      LASTID = 0        
      GO TO 500        
C        
C     ELEMENT STRAIN/CURVATURE        
C        
  410 FROM = 410        
      IF (ID(3).NE.6 .AND. ID(3).NE.17 .AND. ID(3).NE.18 .AND.        
     1    ID(3).NE.19) GO TO 2020        
      FROM = 415        
      IF (ICURV .GT. 2) GO TO 2020        
      STRAIN = .TRUE.        
      ELEMEN = .TRUE.        
      IOPT = 2        
      NADD = 0        
      IF (ID(3) .EQ.  6) NADD =  1        
      IF (ID(3) .EQ. 17) NADD =  7        
      IF (ID(3) .EQ. 18) NADD = 13        
      IF (ID(3) .EQ. 19) NADD = 19        
      IF (ICURV .EQ.  1) NADD = NADD + 24        
      IF (ICURV .EQ.  2) NADD = 49        
      GO TO 500        
C        
C     STRESSES AND FORCES IN LAYERED COMPOSITE ELEMENTS        
C        
  420 CALL OFCOMP (*60,FILE,J,IELTYP,IAPP,HEADNG,PNCHED,I)        
      GO TO 60        
C        
  500 FROM = 500        
      IF (B(I,J) .EQ. -1) GO TO 2020        
      IF (PACK ) IOPT = 1        
      POINT = NADD + B(I,J)*6        
C        
C     IS THIS MAGNITUDE / PHASE OUTPUT        
C        
      IF (ID(9).EQ.3 .AND. (IAPP.EQ.FREQ .OR. IAPP.EQ.CEIGEN))        
     1    POINT = POINT + 6        
C        
      IF (STRAIN) GO TO 660        
      IF (ELEMEN) GO TO 510        
C        
C     CALL NON-STRESS AND NON-FORCE OVERLAY.        
C        
      CALL OFPMIS (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 505        
      GO TO 690        
C        
C     CALL PARTICULAR STRESS OR FORCE OVERLAY CONSIDERING        
C     REAL, COMPLEX, SORT1, SORT2.        
C        
  510 IF (DUMMY) GO TO 580        
      IF (ICURV .LE. 0) GO TO 515        
      IF (J .EQ. 1) GO TO 650        
      IF (J .EQ. 2) GO TO 670        
      IF (J .EQ. 4) GO TO 680        
  515 ITYPE = J + 4*(5-I)        
      GO TO (520,530,540,560,570,610,620,640), ITYPE        
C        
  520 CALL OFPRS1 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 525        
      GO TO 690        
C        
  530 CALL OFPCS1 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 535        
      GO TO 690        
C        
  540 IF (IAPP .NE. STATIC) GO TO 550        
      CALL OFRS2S (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 545        
      GO TO 690        
  550 CALL OFPRS2 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 555        
      GO TO 690        
C        
  560 CALL OFPCS2 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 565        
      GO TO 690        
C        
  570 CALL OFPRF1 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 575        
      IF (.NOT.HEAT .OR. ID(3).EQ.82) GO TO 690        
      IF (ID(10) .NE. -9) GO TO 600        
      L2 = 405        
      L4 = 0        
      L5 = 406        
      ID(10) = 9        
      GO TO 700        
C        
  580 CALL ODUM (1,IX,ITYPE,NMULT,NLINES,ID)        
      DUMMY = .FALSE.        
      FROM = 580        
      GO TO 690        
C        
C     REAL FORCE SORT 1 (HEAT)        
C        
  600 L2 = 297        
      IF (ID(10) .EQ. 5) L2 = 302        
      L4 = 0        
      L5 = 298        
      IF (ID(10) .EQ. 5) L5 = 300        
      GO TO 700        
C        
  610 CALL OFPCF1 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 615        
      IF (HEAT) GO TO 2020        
      GO TO 690        
C        
  620 IF (IAPP .NE. STATIC) GO TO 630        
      CALL OFRF2S (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 625        
      GO TO 690        
  630 CALL OFPRF2 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 635        
      IF (.NOT.HEAT .OR. ID(3).EQ.82) GO TO 690        
C        
C     REAL FORCE SORT 2 (HEAT)        
C        
      L1 = 108        
      L2 = 297        
      IF (ID(10) .EQ. 5) L2 = 302        
      L5 = 299        
      IF (ID(10) .EQ. 5) L5 = 301        
      GO TO 700        
C        
  640 CALL OFPCF2 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 645        
      IF (HEAT) GO TO 2020        
      GO TO 690        
C        
  650 CALL OFPSS1 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 655        
      GO TO 690        
  660 CALL OFPSN1 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 665        
      GO TO 690        
C        
  670 CALL OFPCC1 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 675        
      GO TO 690        
C        
  680 CALL OFPCC2 (IX,L1,L2,L3,L4,L5,POINT)        
      FROM = 685        
C        
  690 IF (IX .EQ. 0) GO TO 2000        
C        
C     IF THERMAL DISPLACEMENTS IN -HEAT- PROBLEMS, CHANGE HEADING       
C     FROM  DISPLACEMENT TO TEMPERATURE        
C        
  700 IF (TEMPER .AND. L2.EQ.1) L2 = 253        
      IF (TEMPER .AND. L3.EQ.1) L3 = 253        
C        
C     HEAT PROBLEMS REAL-SORT1-VECTORS ONLY        
C        
      IF (HEAT .AND. PACK .AND. J.EQ.1) L5 = 296        
      IF (HEAT .AND. SORT.EQ.2 .AND. .NOT.ELEMEN) L5 = 303        
      IF (AXIC) L4 = -1        
      IF (AXIC) L5 = 203        
      IF (AXIC .AND. IAPP.EQ.TRANS  .AND. J.EQ.3) L5 = 402        
      IF (AXIC .AND. IAPP.EQ.STATIC .AND. J.EQ.3) L5 = 403        
      IF (AXIC .AND. IAPP.EQ.FREQ   .AND. J.EQ.4) L5 = 404        
      IF (J .NE. 1) GO TO 710        
      IF (IAPP.EQ.TRANS .AND. I.NE.8) L1 = 106        
      IF ((IAPP.EQ.REIGEN .OR. IAPP.EQ.BK1) .AND. I.NE.6 .AND. I.NE.8   
     1   .AND. I.NE.9) L1 = 102        
      GO TO 720        
  710 IF (J .NE. 2) GO TO 720        
      IF (IAPP.EQ.CEIGEN .AND. I.NE.6 .AND. I.NE.9) L1 = 110        
  720 IDD = 0        
      IF (SORT .EQ. 1) GO TO 730        
      IDD   = ID(5)        
      ITEMP = IDD/10        
      DEVICE= IDD - 10*ITEMP        
      DEVICE= MOD(DEVICE,8)        
      IDD   = ITEMP        
      ID(5) = IDD        
      IF (HEAT .AND. .NOT.ELEMEN .AND. SORT.EQ.2) L5 = 303        
      IF (IAPP .EQ. STATIC) IDD = -1        
C        
C     SORT2 HARMONIC VECTOR OUTPUT        
C        
  730 IF (.NOT.PACK .OR. .NOT.FLUID .OR. SORT.EQ.1) GO TO 750        
      IF (ID(5) .LT. 500000) GO TO 740        
      IF (L1 .EQ. 107) L1 = 229        
  740 FLUID = .FALSE.        
      IF (ESE  .OR.   GPFB) GO TO 800        
  750 IF (PACK .OR. ELEMEN) GO TO 800        
      CALL OFP1        
      HEADNG = .TRUE.        
C        
C     OUTPUT THE DATA BLOCK        
C        
  800 EOR = .FALSE.        
      IF (ELEMEN  .AND. ID(3).EQ.35) AXIC = .TRUE.        
      IF (ELEMEN  .AND. ID(3).EQ.70) AXIC = .TRUE.        
      IF (ELEMEN  .AND. ID(3).EQ.71) AXIC = .TRUE.        
      IF (AXIC) SOLSET = .TRUE.        
C        
C     D(IX) CONTINS TWO VALUES IN A PACKED 4 DIGIT NUMBER.        
C     THE RIGHT 2 DIGITS GIVES THE NUMBER OF LINES FORMAT PRODUCES.     
C     THE LEFT 2 DIGITS GIVES THE NUMBER OF DATA VECTORS PER LINE.      
C     IF  THE LEFT 2 DIGITS ARE 0 OR NULL, 1 VECTOR IS ASSUMED.        
C        
      IF (HEAT ) GO TO 810        
      IF (DUMMY) GO TO 820        
      NMULT  = D(IX)/100        
      NLINES = D(IX) - NMULT*100        
      GO TO 820        
  810 NMULT  = 1        
      NLINES = 1        
  820 IF (NMULT .EQ. 0) NMULT = 1        
      NWDS  = ID(10)*NMULT        
      NWDSAV= NWDS        
      MAXN  = MAXLNS - NLINES        
C        
      IF (NWDS .EQ. 0) GO TO 60        
  900 IF (EOR) GO TO 60        
      FROM  = 900        
      CALL READ (*2020,*910,FILE,IOUT(1),NWDS,0,FLAG)        
      GO TO 920        
  910 IF (FLAG .EQ. 0) GO TO 60        
      NWDS  = FLAG        
      NWDSAV= NWDS        
      EOR   = .TRUE.        
  920 I1    = 0        
      IF (AXIC) GO TO 930        
      IGSE  = IOUT(2)        
      IF (PACK .OR. GPST) IOUT(2) = GSE(IGSE)        
      IF (ESE  .OR. GPFB) GO TO 930        
      IF (.NOT.PACK .AND. .NOT.ELEMEN) GO TO 1030        
  930 IF (SORT .EQ. 2) GO TO 990        
      INCR = ID(10)        
      I  = 1        
      K1 = 1        
  940 ITEMP  = IOUT(I)/10        
      DEVICE = IOUT(I) - 10*ITEMP        
      DEVICE = MOD(DEVICE,8)        
      IOUT(I)= ITEMP        
      IF (DEVICE .LT. 4) GO TO 950        
      CALL OFPPUN (IOUT(I),IOUT(I),INCR,IOPT,IDD,PNCHED)        
      DEVICE = DEVICE - 4        
  950 IF (DEVICE .GT. 0) GO TO 980        
C        
C     ELIMINATE VECTOR FROM MULTIPLE VECTOR PER LINE        
C        
      NWDS = NWDS - INCR        
      IF (NWDS .GT. I) GO TO 960        
      DEVICE = 1        
      IF (NWDS .GT. 0) GO TO 990        
      IF (EOR) GO TO 60        
      NWDS = NWDSAV        
      GO TO 900        
  960 K1 = K1 + INCR        
      K2 = K1 + INCR - 1        
      JJ = I - 1        
      DO 970 J = K1,K2        
      JJ = JJ + 1        
  970 IOUT(JJ) = IOUT(J)        
      GO TO 940        
  980 I = I + INCR        
      IF (I .LE. NWDS) GO TO 940        
  990 IF (DEVICE .LT. 4) GO TO 1020        
      IF (ELEMEN) GO TO 1000        
      CALL OFPPUN (IOUT(1),IOUT(1),NWDS,IOPT,IDD,PNCHED)        
      GO TO 1020        
C        
C     SORT 2 ELEMENT PUNCH        
C        
 1000 INCR = ID(10)        
      DO 1010 JJ = 1,NWDS,INCR        
      CALL OFPPUN (IOUT(JJ),IOUT(JJ),INCR,IOPT,IDD,PNCHED)        
 1010 CONTINUE        
 1020 IF (DEVICE.NE.1 .AND. DEVICE.NE.5) GO TO 900        
 1030 IF (.NOT.PACK .OR. AXIC) GO TO 1100        
      IF (FLUID .AND. SORT.EQ.1 .AND. IOUT(1).GE.500000) GO TO 1800     
 1040 IF (IOUT(2) .NE. GSE(1)) GO TO 1720        
C        
C     BUILD FORMAT CHECKING DATA FOR SPECIAL CASES.        
C        
 1100 I = 1        
      IF (HEAT .AND. ELEMEN .AND. ID(3).NE.82) GO TO 1400        
      IF (DUMMY) GO TO 1640        
      FMT(1) = OPAREN        
      IFMT = 1        
C        
C     SET METHD TO +2 FOR METHOD 2 IN OFPPNT IF MACHINE CAN NOT USE     
C     METHOD 1 (METHD = 0).  (SEE SUBROUTINE OFPPNT.)   ** MACHX **     
C        
C     METHD = +2        
C        
      J = IX + 1        
      GO TO 1120        
 1110 J = J + 1        
      IFMT = IFMT + 1        
      FMT(IFMT) = COMMA        
C        
C     IF K IS NEGATIVE THEN BUILDING BLOCK IS NOT FOR A VARIABLE.       
C     IN THIS CASE THEN K IS ACTUAL POINTER TO BE USED IN THE ESINGL ARR
C        
 1120 K = D(J)        
      IF (K) 1130,1300,1140        
 1130 K = -K        
      IFMT = IFMT + 1        
      FMT(IFMT) = ESINGL(K)        
      GO TO 1110        
C        
C     CHECK FOR  SPECIAL PACKING FORMATS        
C        
 1140 K = 5*K - 5        
      IF (.NOT. AXIC) GO TO 1150        
      IF (K.NE.200 .AND. K.NE.275) GO TO 1160        
      IF (IOUT(2) .EQ. IBLANK) GO TO 1230        
      GO TO 1240        
 1150 IF (.NOT.PACK .OR. IOUT(2).EQ.GSE(1)) GO TO 1160        
      IF ((I.GE.I1 .AND. I.LE.8) .OR. (I.GE.I2 .AND. I.LE.14))        
     1   GO TO 1250        
C        
C     IF SOLSET AND K=0 OR K=80 OR K=365 OR K=75 USE I15BLK IF INTEGER 1
C        
 1160 IF (.NOT. SOLSET) GO TO 1170        
      IF (K.NE.0 .AND. K.NE.80 .AND. K.NE.365 .AND. K.NE.75) GO TO 1170 
      IF (IOUT(I) .NE. 1) GO TO 1170        
      IOUT(I) = IBLANK        
      IFMT = IFMT + 2        
      FMT(IFMT-1) = I15BLK(1)        
      FMT(IFMT  ) = I15BLK(2)        
      IF (AXIC) FMT(IFMT) = I2X        
      GO TO 1260        
C        
C     CHECK FOR  0.0 ON AN E-FORMAT        
C        
 1170 IF (K .LT. EEND) IF (OUT(I)) 1230,1240,1230        
      IF (K .EQ.  440) IF (OUT(I)) 1230,1240,1230        
C        
C     CHECK FOR MID-EDGE OR CENTER STRESS POINTS ON ISOPARAMETRIC       
C     SOLID ELEMENTS        
C        
      IF ((K.NE.390 .AND. K.NE.395) .OR. IOUT(I).NE.0) GO TO 1190       
      IF (K .EQ. 395) GO TO 1180        
      IOUT(I) = CENTER        
      GO TO 1240        
 1180 IOUT(I) = IBLANK        
      GO TO 1240        
C        
C     CHECK FOR SPECIAL INTEGER ON E9.1 FORMAT ONLY        
C        
 1190 IF (K.NE.E9PT1 .OR. IOUT(I).NE.1) GO TO 1200        
      IOUT(I) = IBLANK        
      GO TO 1240        
C        
C     CHECK FOR SPECIAL GPST FORMATS        
C        
 1200 IF (IOUT(I).NE.0 .OR. K.LT.301 .OR. K.GT.325) GO TO 1210        
      IOUT(I) = IBLANK        
      GO TO 1240        
C        
C     CHECK FOR HARMONIC NUMBER OR POINT ANGLE        
C        
 1210 IF (K.NE.355 .AND. K.NE.360 .AND. K.NE.445) GO TO 1220        
      IF (IOUT(I).LE.0 .OR. IOUT(I).GE.1000) GO TO 1220        
      IOUT(I) = IOUT(I) - 1        
      GO TO 1240        
C        
C     CHECK FOR PHASE ANGLE ON STRESSES WITH TRAPAX AND TRIAAX ELEMENTS 
C        
C     COMMENTS FROM G.CHAN/UNISYS   1/93        
C     FMT AND PHASE ARE LOCAL. I SEE NOBODY SETTING UP FMT() TO PHASE.  
C     PHASE IS '1PE9'. IN ANSI FORTRAN STANDARD, A COMMA IS NEEDED      
C     BETWEEN P AND E IF PHASE IS REALLY USED IN SETTING UP FMT().      
C        
 1220 IF (K.NE.430 .OR. ID(9).NE.3 .OR. IAPP.NE.FREQ .OR. FMT(IFMT-4)   
     1    .NE.PHASE) GO TO 1230        
      GO TO 1240        
C        
C     NO OTHER SPECIAL CHECKS AT THIS TIME        
C        
C     *** ADD FORMAT BLOCKS ***        
C        
C     STANDARD BLOCKS        
C        
 1230 IFMT = IFMT + 2        
      FMT(IFMT-1) = E(K+1)        
      FMT(IFMT  ) = E(K+2)        
      GO TO 1260        
C        
C     ALTERNATE BLOCKS        
C        
 1240 IFMT = IFMT + 3        
      FMT(IFMT-2) = E(K+3)        
      FMT(IFMT-1) = E(K+4)        
      FMT(IFMT  ) = E(K+5)        
      GO TO 1260        
C        
C     SPECIAL BLOCKS FOR PACKED OUTPUT        
C        
 1250 IFMT = IFMT + 1        
      FMT(IFMT) = A4        
      GO TO 1260        
C        
 1260 I = I + 1        
      GO TO 1110        
C        
C     OUTPUT THE LINE OR LINES OF DATA WITH THE NEW FORMAT        
C        
 1300 FMT(IFMT) = CPAREN        
      IF (LINE.GT.MAXN .OR. .NOT.HEADNG) CALL OFP1        
      HEADNG = .TRUE.        
      NWDS = NWDSAV        
C        
C     IF GRID-POINT-FORCE-BALANCE ENTRY, BLANK OUT NONEXISTENT (ZERO)   
C     ELEMENT ID-S.        
C        
      IF (.NOT.GPFB) GO TO 1330        
      IF (IOUT(2)) 1320,1310,1320        
 1310 IOUT(2) = IBLANK        
      FMT( 9) = A4        
      FMT(10) = I9X        
C        
C     ALSO, FOR GPFB, SET FORMAT TO SPACE TWO LINES ON NEW POINT-ID.    
C        
 1320 IF (IOUT(1) .EQ. LASTID) GO TO 1330        
      LASTID = IOUT(1)        
      FMT(2) = IH0        
      LINE   = LINE + 2        
 1330 CALL OFPPNT (IOUT,IOUT,NWDS,FMT,IFMT,METHD)        
      GO TO 1700        
C        
C     ELEMENT FORCES IN HEAT PROBLEMS        
C        
 1400 IF (LINE.GT.MAXN .OR. .NOT.HEADNG) CALL OFP1        
      HEADNG = .TRUE.        
      IF (SORT .EQ. 2) GO TO 1520        
C        
C     BRANCH ON SPECIAL HBDY OUTPUT        
C        
      IF (NWDS    .EQ. 5) GO TO 1460        
      IF (IOUT(5) .EQ. 1) GO TO 1440        
      IF (IOUT(6) .EQ. 1) GO TO 1420        
      IF (IOUT(2).EQ.HEX1 .OR. IOUT(2).EQ.HEX2) GO TO 1480        
      IF (IOUT(2) .EQ. HEX3) GO TO 1500        
      WRITE  (L,1410) IOUT(1),(OUT(I),I=2,9)        
 1410 FORMAT (I14,4X,2A4,6(1P,E17.6))        
      GO TO 1700        
 1420 WRITE  (L,1430) IOUT(1),OUT(2),OUT(3),OUT(4),OUT(5),OUT(7),OUT(8) 
 1430 FORMAT (I14,4X,2A4,2(1P,E17.6),17X,2(1P,E17.6))        
      GO TO 1700        
 1440 WRITE  (L,1450) IOUT(1),OUT(2),OUT(3),OUT(4),OUT(7)        
 1450 FORMAT (I14,4X,2A4,1P,E17.6,34X,1P,E17.6)        
      GO TO 1700        
C        
 1460 WRITE  (L,1470) IOUT(1),OUT(2),OUT(3),OUT(4),OUT(5)        
 1470 FORMAT (18X,I18,4(1P,E18.6))        
      GO TO 1700        
C        
 1480 WRITE  (L,1490) (IOUT(I),I=1,3),(OUT(I),I=4,9)        
 1490 FORMAT (I14,1X,A4,I7,6(1P,E17.6))        
      GO TO 1700        
 1500 WRITE  (L,1510) (IOUT(I),I=1,3),(OUT(I),I=4,9)        
 1510 FORMAT (I14,2X,A4,2X,A4,6(1P,E17.6))        
      GO TO 1700        
C        
C     BRANCH ON SPECIAL HBDY FORCES        
C        
 1520 IF (NWDS    .EQ. 5) GO TO 1580        
      IF (IOUT(5) .EQ. 1) GO TO 1560        
      IF (IOUT(6) .EQ. 1) GO TO 1540        
      IF (IOUT(2).EQ.HEX1 .OR. IOUT(2).EQ.HEX2) GO TO 1600        
      IF (IOUT(2) .EQ. HEX3) GO TO 1620        
      WRITE  (L,1530) (OUT(I),I=1,9)        
 1530 FORMAT (1P,E14.6,4X,2A4,6(1P,E17.6))        
      GO TO  1700        
 1540 WRITE  (L,1550) (OUT(KK),KK=1,5),OUT(7),OUT(8)        
 1550 FORMAT (1P,E14.6,4X,2A4,2(1P,E17.6),17X,2(1P,E17.6))        
      GO TO  1700        
 1560 WRITE  (L,1570) (OUT(KK),KK= 1,4),OUT(7)        
 1570 FORMAT (1P,E14.6,4X,2A4,1P,E17.6,34X,1P,E17.6)        
      GO TO  1700        
 1580 WRITE  (L,1590) (OUT(KK),KK=1,5)        
 1590 FORMAT (18X,5(1P,E18.6))        
      GO TO  1700        
 1600 WRITE  (L,1610) OUT(1),OUT(2),IOUT(3),(OUT(I),I=4,9)        
 1610 FORMAT (1P,E14.6,1X,A4,I7,6(1P,E17.6))        
      GO TO  1700        
 1620 WRITE  (L,1630) (OUT(I),I=1,9)        
 1630 FORMAT (1P,E14.6,2X,A4,2X,A4,6(1P,E17.6))        
      GO TO  1700        
C        
C     DUMMY ELEMENT        
C        
 1640 IF (LINE.GT.MAXN .OR. .NOT.HEADNG) CALL ODUM (2,L,ITYPE,IAPP,0,ID)
      HEADNG = .TRUE.        
      NWDS   = NWDSAV        
      CALL ODUM (3,L,ITYPE,IAPP,NWDS,IOUT)        
      GO TO 1700        
C        
 1700 LINE = LINE + NLINES        
      IF (EOR ) GO TO 60        
      IF (AXIC) GO TO 900        
      IF (.NOT.PACK .OR. IOUT(2).EQ.GSE(1) .OR. I1.EQ.9) GO TO 900      
C        
C     TRANSFER THE SAVED BLOCK        
C        
      DO 1710 I = 1,NWDS        
 1710 IOUT(I) = ISAVE(I)        
      IF (.NOT.FLUID) GO TO 1040        
      IF (IOUT(1) .GE. 500000) GO TO 1800        
      GO TO 1040        
C        
C     SPECIAL ROUTINE TO PACK SCALAR OR EXTRA POINTS OUTPUT..        
C     PACKING IS PERFORMED ONLY WHEN IDS ARE SEQUENTIAL,        
C     AND THE TYPE REMAINS THE SAME.        
C        
 1720 I = 1        
      GRDPT = IOUT(1)        
      TYPE  = IOUT(2)        
 1730 IF (I .EQ. 6) GO TO 1760        
 1740 FROM = 1740        
      CALL READ (*2020,*1790,FILE,ISAVE(1),NWDS,0,FLAG)        
      IGSE = ISAVE(2)        
      IF (PACK) ISAVE(2) = GSE(IGSE)        
      IF (SORT .EQ. 2) GO TO 1750        
      ITEMP  = ISAVE(1)/10        
      DEVICE = ISAVE(1) - 10*ITEMP        
      DEVICE = MOD(DEVICE,8)        
      ISAVE(1) = ITEMP        
 1750 IF (DEVICE .GE. 4) CALL OFPPUN (ISAVE(1),ISAVE(1),NWDS,IOPT,IDD,  
     1                                PNCHED)        
      IF (DEVICE.NE.1 .AND. DEVICE.NE.3 .AND. DEVICE.NE.5 .AND.        
     1    DEVICE.NE.7) GO TO 1740        
      J = GRDPT + I        
      IF (FLUID .AND. ISAVE(1).GE.500000) GO TO 1760        
      IF (ISAVE(2).NE.TYPE .OR. ISAVE(1).NE.(GRDPT+I)) GO TO 1760       
C        
C     PACK THIS VECTOR INTO LINE OF DATA        
C     IF COMPLEX TWO LINES OF DATA        
C     IMAGINARY PART WILL BE PACKED EVEN IF IT DOES NOT EXIST.        
C        
      I = I + 1        
      IOUT(I+2) = ISAVE(3)        
      IOUT(I+8) = ISAVE(9)        
      GO TO 1730        
C        
C     PUT BLANKS IN ANY OPEN SLOTS        
C        
 1760 J = I + 3        
      IF (J .GT. 8) GO TO 1780        
      DO 1770 K  = J,8        
      IOUT(K  ) = IBLANK        
 1770 IOUT(K+6) = IBLANK        
C        
 1780 I1 = J        
      I2 = J + 6        
      GO TO 1100        
C        
 1790 EOR = .TRUE.        
      GO TO 1760        
C        
C     SPECIAL LOGIC FOR SORT-1 VECTOR OUTPUT IN A FLUID PROBLEM FOR     
C     HARMONIC POINTS ONLY        
C        
 1800 OLDHRM = -1        
      L5  = 230        
      LINE= MAXN + 1        
      K   = 0        
      EOR = .FALSE.        
      GO TO 1820        
 1810 FROM = 1810        
      CALL READ (*2020,*1840,FILE,IOUT(1),NWDS,0,FLAG)        
C        
C     PUNCH PROCESSING        
C        
      ITEMP  = IOUT(1)/10        
      DEVICE = IOUT(1) - 10*ITEMP        
      IOUT(1)= ITEMP        
      IF (DEVICE .LT. 4) GO TO 1820        
      DEVICE = MOD(DEVICE,8)        
      CALL OFPPUN (IOUT(1), IOUT(1),INCR,IOPT,IDD,PNCHED)        
      DEVICE = DEVICE - 4        
      IF (DEVICE .LE. 0) GO TO 1810        
C        
C     DECODE THE HARMONIC        
C        
 1820 ITEMP = MOD(IOUT(1),500000)        
      NHARM = (IOUT(1)-ITEMP)/500000        
      IOUT(1) = ITEMP        
      IF (OLDHRM .EQ. -1) OLDHRM = NHARM        
      IF (NHARM.NE.OLDHRM .OR. K.GE.5) GO TO 1850        
      K = K + 1        
 1830 REAL(2*K-1) = IOUT(1)        
      REAL(2*K  ) = IOUT(3)        
      IMAG(  K  ) = IOUT(9)        
      GO TO 1810        
C        
C     OUTPUT THE LINE OF DATA        
C        
 1840 EOR = .TRUE.        
      IF (K .LE. 0) GO TO 60        
C        
C     BUILD THE FORMAT        
C        
 1850 FMT(1) = I1X        
      IF (NLINES .GT. 1) FMT(1) = I1H0        
      FMT(2) = I12        
      FMT(3) = I2XX        
      IFMT   = 3        
C        
C     ADD STAR IF THIS IS AN UN-SYMETRIC HARMONIC        
C        
      IF (MOD(OLDHRM,2) .EQ. 0) GO TO 1860        
      FMT(3) = ISTAR        
      FMT(4) = I1XX        
      IFMT   = 4        
C        
C     VARIABLES IN MAIN LINE        
C        
 1860 DO 1890 I = 1,K        
      FMT(IFMT+1) = I8        
      IF (FREAL(2*I)) 1870,1880,1870        
 1870 FMT(IFMT+2) = PE        
      FMT(IFMT+3) = E156        
      IFMT = IFMT + 3        
      GO TO 1890        
 1880 FMT(IFMT+2) = PF        
      FMT(IFMT+3) = F156        
      FMT(IFMT+4) = I9X        
      IFMT = IFMT + 4        
 1890 CONTINUE        
C        
C     VARIABLES IN SECOND LINE IF COMPLEX        
C        
      IF (NLINES .LE. 1) GO TO 1940        
      IFMT = IFMT + 1        
      FMT(IFMT) = I15X        
      DO 1930 I = 1,K        
      IFMT = IFMT + 1        
      FMT(IFMT) = COMMA        
      IF (FIMAG(I)) 1910,1900,1910        
 1900 FMT(IFMT+1) = PF        
      FMT(IFMT+2) = F236        
      FMT(IFMT+3) = I9X        
      IFMT = IFMT + 3        
      GO TO 1930        
 1910 IF (L3 .EQ. 126) GO TO 1920        
      FMT(IFMT+1) = PE        
      FMT(IFMT+2) = E236        
      IFMT = IFMT + 2        
      GO TO 1930        
 1920 FMT(IFMT+1) = PF        
      FMT(IFMT+2) = F174        
      FMT(IFMT+3) = I6X        
      IFMT = IFMT + 3        
 1930 CONTINUE        
C        
C     COMPLETE FORMAT        
C        
 1940 FMT(IFMT+1) = CPAREN        
      IF (LINE .GT. MAXN) CALL OFP1        
      LINE = LINE + NLINES        
      K2   = 2*K        
      IHARM= (OLDHRM-1)/2        
      IF (NLINES .LE. 1) GO TO  1950        
CVAXR 6/93     WRITE (L,FMT) IHARM,(FREAL(I),I=1,K2),(FIMAG(I),I=1,K)        
      WRITE (L,FMT) IHARM,(REAL(I),FREAL(I+1),I=1,K2,2),
     &                    (FIMAG(I),I=1,K)
      GO TO 1960        
CVAXR 6/931950 WRITE (L,FMT) IHARM,(FREAL(I),I=1,K2)        
1950  CONTINUE
      WRITE(L,FMT) IHARM,(REAL(I),FREAL(I+1),I=1,K2,2)
 1960 K = 1        
      OLDHRM = NHARM        
      IF (.NOT. EOR) GO TO 1830        
      GO TO 60        
C        
C     ERROR CONDITION THIS FILE        
C        
 2000 WRITE  (L,2010) SWM,IX,POINT,FROM        
 2010 FORMAT (A27,', OFP BLOCK DATA ROUTINES UNAVAILABLE FOR THIS ',    
     1       'ELEMENT.',11X,'IX,POINT,FROM =,',3I5)        
 2020 WRITE  (L,2030) UWM,FROM        
 2030 FORMAT (A25,' 3030, OFP UNABLE TO PROCESS DATA BLOCK.  A TABLE ', 
     1       'PRINT OF THE DATA BLOCK FOLLOWS.   FROM =',I5,'/OFP')     
      CALL CLOSE  (FILE,1)        
      CALL TABPRT (FILE)        
      GO TO 2050        
C        
C     CLOSE FILE UP        
C        
 2040 CALL CLOSE (FILE,1)        
 2050 IF (IFILE .EQ. 6) GO TO 2060        
      GO TO 50        
C        
C     RESTORE TITLES TO WHATEVER THEY WERE AT ENTRY TO OFP        
C        
 2060 DO 2070 I = 1,96        
 2070 HEAD(I) = TSAVE(I)        
      RETURN        
      END        
