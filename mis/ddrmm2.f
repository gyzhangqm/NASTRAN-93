      SUBROUTINE DDRMM2 (*,*,*,*)        
C        
C     PERFORMS SORT2 TYPE PROCESSING FOR MODULE DDRMM.        
C        
      LOGICAL         SORT2    ,COL1     ,FRSTID   ,IDOUT    ,TRNSNT  , 
     1                LMINOR   ,ANYXY        
      INTEGER         BUF1     ,BUF2     ,BUF3     ,BUF4     ,BUF5    , 
     1                BUF6     ,BUFF     ,EOR      ,RD       ,RDREW   , 
     2                WRT      ,WRTREW   ,CLS      ,CLSREW   ,ELEM    , 
     3                IA(4)    ,SETS     ,ENTRYS   ,SYSBUF   ,OUTPT   , 
     4                PASSES   ,OUTFIL   ,FILE     ,DHSIZE   ,FILNAM  , 
     5                SETID    ,FORM     ,DEVICE   ,PHASE    ,SCRT    , 
     6                SCRT1    ,SCRT2    ,SCRT3    ,SCRT4    ,SCRT5   , 
     7                SCRT6    ,SCRT7    ,TYPOUT   ,DVAMID(3),BUF(150), 
     8                Z(1)     ,UVSOL    ,BUFA(75) ,BUFB(75) ,COMPLX  , 
     9                SUBCAS   ,SAVDAT   ,SAVPOS   ,BUFSAV  ,ELWORK(300)
      REAL            RIDREC(1),LAMBDA        
      CHARACTER       UFM*23   ,UWM*25   ,UIM*29   ,SFM*25   ,SWM*27    
      COMMON /XMSSG / UFM      ,UWM      ,UIM      ,SFM      ,SWM       
      COMMON /STDATA/ LMINOR   ,NSTXTR   ,NPOS     ,SAVDAT(75)        , 
     1                SAVPOS(25)         ,BUFSAV(10)        
      COMMON /SYSTEM/ SYSBUF   ,OUTPT        
      COMMON /NAMES / RD       ,RDREW    ,WRT      ,WRTREW   ,CLSREW  , 
     1                CLS        
      COMMON /ZBLPKX/ A(4)     ,IROW        
      COMMON /ZNTPKX/ AOUT(4)  ,IROWO    ,IEOL     ,IEOR        
      COMMON /GPTA1 / NELEM    ,LAST     ,INCR     ,ELEM(1)        
CZZ   COMMON /ZZDDRM/ RZ(1)        
      COMMON /ZZZZZZ/ RZ(1)        
      COMMON /MPYADX/ MCBA(7)  ,MCBB(7)  ,MCBC(7)  ,MCBD(7)  ,LZ      , 
     1                ITFLAG   ,ISINAB   ,ISINC    ,IPREC    ,ISCRT     
      COMMON /CLSTRS/ COMPLX(1)        
      COMMON /DDRMC1/ IDREC(146),BUFF(6) ,PASSES   ,OUTFIL   ,JFILE   , 
     1                MCB(7)   ,ENTRYS   ,SETS(5,3),INFILE   ,LAMBDA  , 
     2                FILE     ,SORT2    ,COL1     ,FRSTID   ,NCORE   , 
     3                NSOLS    ,DHSIZE   ,FILNAM(2),RBUF(150),IDOUT   , 
     4                ICC      ,NCC      ,ILIST    ,NLIST    ,NWDS    , 
     5                SETID    ,TRNSNT   ,I1       ,I2       ,PHASE   , 
     6                ITYPE1   ,ITYPE2   ,NPTSF    ,LSF      ,NWDSF   , 
     7                SCRT(7)  ,IERROR   ,ITEMP    ,DEVICE   ,FORM    , 
     8                ISTLST   ,LSTLST   ,UVSOL    ,NLAMBS   ,NWORDS  , 
     9                OMEGA    ,IPASS    ,SUBCAS        
      COMMON /CONDAS/ PI       ,TWOPI        
      EQUIVALENCE    (SCRT1,SCRT(1)), (SCRT2,SCRT(2)), (SCRT3,SCRT(3)), 
     1               (SCRT4,SCRT(4)), (SCRT5,SCRT(5)), (SCRT6,SCRT(6)), 
     2               (SCRT7,SCRT(7)), (BUF1 ,BUFF(1)), (BUF2 ,BUFF(2)), 
     3               (BUF3 ,BUFF(3)), (BUF4 ,BUFF(4)), (BUF5 ,BUFF(5)), 
     4               (BUF6 ,BUFF(6)), (A(1) ,  IA(1)), (Z(1) ,  RZ(1)), 
     5               (BUF(1),RBUF(1),BUFA(1)), (BUFB(1),BUF(76)),       
     6               (IDREC(1),RIDREC(1))        
C        
      DATA    EOR  , NOEOR / 1, 0 /, DVAMID / 2001, 2010, 2011 /        
C        
C     FORMATION OF DATA-MATRIX AND SUBSEQUENT MULTIPLICATION BY SAME OF 
C     THE SOLUTION MATRIX (TRNNSPOSED), AND ULTIMATE OUTPUT OF TRANSIENT
C     OR FREQUENCY SOLUTIONS.        
C        
      IPASS  = 1        
      IOMEGA = NLIST  + 1        
      NOMEGA = IOMEGA - 1        
      MINOR  = 0        
   20 COL1   = .TRUE.        
      FRSTID = .TRUE.        
      SETID  = SETS(1,IPASS)        
      DEVICE = SETS(2,IPASS)        
      FORM   = SETS(3,IPASS)        
      ISTLST = SETS(4,IPASS)        
      LSTLST = SETS(5,IPASS)        
C        
C     GET LIST OF XYPLOT REQUESTED IDS FOR CURRENT SUBCASE AND        
C     OUTFIL TYPE.        
C        
      GO TO (22,23,24,25), JFILE        
C        
C     DISPLACEMENT, VELOCITY, ACCELERATION        
C        
   22 IXYTYP = IPASS        
      GO TO 26        
C        
C     SPCF        
C        
   23 IXYTYP = 4        
      GO TO 26        
C        
C     STRESS        
C        
   24 IXYTYP = 6        
      GO TO 26        
C        
C     FORCE        
C        
   25 IXYTYP = 7        
      GO TO 26        
C        
   26 IXY  = NOMEGA + 1        
      CALL DDRMMP (*480,Z(IXY),BUF3-IXY,LXY,IXYTYP,SUBCAS,Z(BUF3),ANYXY)
      IF (.NOT.ANYXY .AND. SETID.EQ.0) GO TO 400        
      NXY  = IXY + LXY - 1        
      IERROR = 23        
      FILE = SCRT4        
      CALL OPEN (*450,SCRT4,Z(BUF3),WRTREW)        
      FILE = SCRT5        
      CALL OPEN (*450,SCRT5,Z(BUF2),WRTREW)        
      CALL FNAME (SCRT5,FILNAM)        
      CALL WRITE (SCRT5,FILNAM,2,EOR)        
C        
C     LOGIC TO BUILD SORT-2 FORMAT DATA MATRIX.        
C        
C     EACH COLUMN WRITTEN HERE ENCOMPASSES ALL EIGENVALUES FOR        
C     ONE COMPONENT OF ONE ID.  THE NUMBER OF COLUMNS THUS EQUALS       
C     THE SUM OF ALL COMPONENTS OF ALL REQUESTED ID-S.        
C        
C     READ AN OFP-ID RECORD AND SET PARAMETERS.        
C     (ON ENTRY TO THIS PROCESSOR ONE ID-RECORD IS AT HAND)        
C        
      FILE   = INFILE        
      IERROR = 19        
      MCB(1) = SCRT5        
      MCB(2) = 0        
      MCB(3) = NLAMBS        
      MCB(4) = 2        
      MCB(5) = 1        
      MCB(6) = 0        
      MCB(7) = 0        
      IF (IPASS.EQ.1 .AND. FRSTID) GO TO 50        
   40 CALL READ (*160,*160,INFILE,IDREC,146,EOR,NWDS)        
C        
C     OFP-ID RECORD IS WRITTEN TO THE MAP FILE ONLY ON CHANGE OF        
C     MINOR ID.        
C        
   50 MAJOR = MOD(IDREC(2),1000)        
      IF (MAJOR .NE. ITYPE1) GO TO 420        
      IDVICE = DEVICE        
      ID   = IDREC(5)/10        
      IF (SETID) 80,65,60        
   60 NEXT = 1        
      CALL SETFND (*65,Z(ISTLST),LSTLST,ID,NEXT)        
      GO TO 80        
   65 IF (.NOT.ANYXY) GO TO 70        
      CALL BISLOC (*70,ID,Z(IXY),1,LXY,JP)        
      IDVICE = 0        
      GO TO 80        
C        
C     ID IS NOT TO BE OUTPUT THUS SKIP UPCOMING OFP-DATA-RECORD.        
C        
   70 CALL FWDREC (*460,INFILE)        
      GO TO 40        
C        
C     ID IS TO BE OUTPUT THUS CONTINUE.        
C        
   80 NUMWDS = NLAMBS*IDREC(10)        
      IDATA  = NXY + 1        
      NDATA  = IDATA + NUMWDS - 1        
      IF (NDATA .LT. BUF3) GO TO 100        
C        
C     INSUFFICIENT CORE        
C        
      INSUF = NDATA - BUF3        
      WRITE  (OUTPT,90) UWM,INFILE,INSUF        
   90 FORMAT (A25,' 2337.  (DDRMM2-2)  DATA BLOCK',I5,' CAN NOT BE ',   
     1       'PROCESSED DUE TO', /5X,'A CORE INSUFFICIENCY OF APPROXI', 
     2       'MATELY',I11,' DECIMAL WORDS.')        
      GO TO 440        
  100 IF (.NOT.FRSTID) GO TO 110        
C        
C     VERY FIRST ID RECORD,  THUS SET MINOR ID.        
C        
      FRSTID = .FALSE.        
      GO TO 120        
  110 IF (IDREC(3) .EQ. MINOR) GO TO 130        
C        
C     CHANGE IN MINOR ID, I.E. NEW ELEMENT TYPE.  COMPLETE CURRENT      
C     RECORD OF MAP AND OUTPUT ANOTHER ID-RECORD.        
C        
      CALL WRITE (SCRT4,0,0,EOR)        
  120 CALL WRITE (SCRT4,IDREC,146,EOR)        
      MINOR = IDREC(3)        
C        
C     SAME TYPE OF DATA THUS CONTINUE ON.        
C        
  130 LENTRY = IDREC(10)        
      I1 = NWORDS + 1        
      I2 = LENTRY        
C        
C     READ AND OUTPUT ONE FULL OFP-DATA RECORD.        
C        
      CALL READ (*460,*470,INFILE,Z(IDATA),NUMWDS,EOR,NWDS)        
      DO 150 I = I1,I2        
C        
C     START NEW COLUMN        
C        
      CALL BLDPK (1,1,SCRT5,0,0)        
      IROW  = 0        
      JDATA = IDATA + I - 1        
      KDATA = NDATA - LENTRY + I        
      DO 140 J = JDATA,KDATA,LENTRY        
      IROW = IROW + 1        
      A(1) = RZ(J)        
C        
C     ELIMINATE INTEGERS        
C        
C     OLD LOGIC -        
C     IF (MACH.NE.5 .AND. IABS(IA(1)).LT.100000000) A(1) = 0.0        
C     IF (MACH.EQ.5 .AND. (IA(1).LE.127 .AND. IA(1).GE.1)) A(1) = 0.0   
C     OLD LOGIC SHOULD INCLUDE ALPHA MACHINE (MACH=21)        
C        
C     NEW LOGIC, BY G.CHAN/UNISYS  8/91 -        
      IF (NUMTYP(IA(1)) .LE. 1) A(1) = 0.0        
C        
      CALL ZBLPKI        
  140 CONTINUE        
C        
C     COMPLETE COLUMN        
C        
      CALL BLDPKN (SCRT5,0,MCB)        
  150 CONTINUE        
C        
C     OUTPUT TO MAP THE ID PLUS ANY OTHER DATA NECESSARY.        
C        
      BUF(1) = 10*ID + IDVICE        
      IF (NWORDS .EQ. 2) BUF(2) = Z(IDATA+1)        
      NSTXTR = 0        
      IF (ITYPE1.NE.5 .OR. SAVDAT(MINOR).EQ.0) GO TO 155        
      NPOS   = SAVDAT(MINOR)/100        
      NSTXTR = SAVDAT(MINOR) - NPOS * 100        
      DO 151 I = 1,NSTXTR        
      J = SAVPOS(NPOS+I-1)        
  151 BUF(I+1) = Z(IDATA+J-1)        
  155 CALL WRITE (SCRT4,BUF,NWORDS+NSTXTR,NOEOR)        
C        
C     GO FOR NEXT ID.        
C        
      GO TO 40        
C        
C     END OF FILE ON INFILE.  MAP AND DATA MATRIX NOW COMPLETE.        
C        
  160 CALL WRTTRL (MCB)        
      CALL CLOSE (SCRT5,CLSREW)        
      CALL CLOSE (INFILE,CLSREW)        
      CALL WRITE (SCRT4,0,0,EOR)        
      CALL CLOSE (SCRT4,CLSREW)        
C        
C     SOLUTION MATRIX MAY BE FOUND BASED ON SORT-2 INFILE.        
C        
C     SOLVE,        
C                               T        
C        (MODAL SOLUTION MATRIX)     X      (DATA MATRIX)        
C          NLAMBS X NSOLUTIONS             NLAMBS X NCOMPS        
C        =======================           ===============        
C        
C     RESULTANT MATRIX IS NSOLUTIONS BY NCOMPS IN SIZE.        
C        
C        
C     MATRIX MULTIPLY SETUP AND CALL.        
C        
      MCBA(1) = UVSOL        
      IF (TRNSNT) MCBA(1) = SCRT(IPASS)        
      CALL RDTRL (MCBA)        
      MCBB(1) = SCRT5        
      CALL RDTRL (MCBB)        
      MCBC(1) = 0        
      MCBD(1) = SCRT6        
      MCBD(2) = 0        
      MCBD(3) = NSOLS        
      MCBD(4) = 2        
      MCBD(5) = 1        
      MCBD(6) = 0        
      MCBD(7) = 0        
      IF (.NOT.TRNSNT) MCBD(5) = 3        
      ITFLAG  = 1        
      NXY1    = NXY + 1        
      IF (MOD(NXY1,2) .EQ. 0) NXY1 = NXY1 + 1        
      LZ      = KORSZ(Z(NXY1))        
      ISINAB  = 1        
      ISINC   = 1        
      IPREC   = 1        
      ISCRT   = SCRT7        
      CALL MPYAD (Z(NXY1),Z(NXY1),Z(NXY1))        
      MCBD(1) = SCRT6        
      CALL WRTTRL (MCBD)        
C        
C     PRODUCT MATRIX IS NOW OUTPUT USING THE MAP ON SCRT4.        
C     EACH COLUMN OF SCRT6 CONTAINS ALL THE TIME OR FREQUENCY STEP      
C     VALUES FOR ONE COMPONENT OF ONE ID.        
C        
C     THUS A NUMBER OF COLUMNS ENCOMPASSING THE COMPONENTS OF ONE ID    
C     MUST FIT IN CORE.        
C        
      IERROR = 20        
      FILE = OUTFIL        
      CALL OPEN (*450,OUTFIL,Z(BUF1),WRT)        
      FILE = SCRT4        
      CALL OPEN (*450,SCRT4,Z(BUF2),RDREW)        
      FILE = SCRT6        
      CALL OPEN (*450,SCRT6,Z(BUF3),RDREW)        
      CALL FWDREC (*460,SCRT6)        
C        
C     READ AN OFP-ID-RECORD FROM THE MAP, AND ALLOCATE SPACE NEEDED     
C     FOR SOLUTION DATA.        
C        
      FILE = SCRT4        
  170 CALL READ (*400,*470,SCRT4,IDREC,146,EOR,NWDS)        
      MINOR = IDREC(3)        
C        
C        
C     SET DISPLACEMENT, VELOCITY, OR ACCELERATION OFP MAJOR-ID IF       
C     INFILE IS MODAL DISPLACEMETNS = EIGENVECTORS...        
C        
      IF (ITYPE1 .NE. 7) GO TO 175        
      IDREC(2) = DVAMID(IPASS)        
  175 IF (.NOT.TRNSNT) IDREC(2) = IDREC(2) + 1000        
C        
C     RESET APPROACH CODE FROM EIGENVALUE TO TRANSIENT OR FREQUENCY     
C        
      IAPP = 5        
      IF (TRNSNT) IAPP = 6        
      IDREC(1) = 10*IAPP + DEVICE        
      LENTRY = IDREC(10) - NWORDS        
      NCOLS = LENTRY        
      IF (.NOT.TRNSNT) LENTRY = LENTRY + LENTRY        
C        
C     IF FREQUENCY RESPONSE PROBLEM AND THIS IS THE VELOCITY OR        
C     ACCELERATION PASS THEN MOVE DOWN ANY XY LIST OF POINTS AND        
C     ADD AN OMEGA TABLE.  SOMETIMES THE MOVEDOWN OF THE XY LIST IS     
C     REDUNDANT.        
C        
C     XY LIST IS MOVED FROM BOTTOM UP INCASE XY LIST IS LONGER THAN     
C     THE OMEGA LIST WILL BE.        
C        
      IF (TRNSNT .OR. IPASS.EQ.1) GO TO 177        
      NOMEGA = IOMEGA + NSOLS - 1        
      IF (LXY .EQ. 0) GO TO 177        
      JXY = NXY        
      KXY = NOMEGA + LXY        
      DO 176 I = 1,LXY        
      Z(KXY) = Z(JXY)        
      JXY = JXY - 1        
      KXY = KXY - 1        
  176 CONTINUE        
C        
  177 IXY = NOMEGA + 1        
      NXY = IXY + LXY - 1        
      IDATA = NXY + 1        
      NDATA = IDATA + LENTRY*NSOLS - 1        
      TYPOUT= 3        
      IF (TRNSNT) TYPOUT = 1        
C        
C     FILL TITLE, SUBTITLE, AND LABEL FROM CASECC FOR THIS SUBCASE.     
C        
      DO 178 I = 1,96        
      IDREC(I+50) = Z(ICC+I+37)        
  178 CONTINUE        
      IDREC(4) = SUBCAS        
C        
C     CHECK FOR SUFFICIENT CORE.        
C        
      IF (NDATA .LT. BUF3) GO TO 190        
      INSUF = NDATA - BUF3        
      WRITE  (OUTPT,180) UWM,OUTFIL,INSUF        
  180 FORMAT (A25,' 2338.  (DDRMM2-3)  DATA BLOCK',I5,        
     1       ' MAY NOT BE FULLY COMPLETED DUE TO A CORE INSUFFICIENCY', 
     2       /5X,'OF APPROXIMATELY',I11,' DECIMAL WORDS.')        
      GO TO 440        
C        
C     LOOP ON ID-S AVAILABLE FROM THE MAP        
C        
C        
C     COMPUTE OMEGAS IF NECESSARY        
C     (NOTE, VELOCITY PASS MAY NOT ALWAYS OCCUR)        
C        
  190 IF (TRNSNT .OR. IPASS.EQ.1) GO TO 195        
      JLIST = IOMEGA - 1        
      DO 193 I = ILIST,NLIST        
      JLIST = JLIST + 1        
      RZ(JLIST) = RZ(I)*TWOPI        
  193 CONTINUE        
      IF (IPASS .EQ. 2) GO TO 195        
      DO 194 I = IOMEGA,NOMEGA        
      RZ(I) = -RZ(I)**2        
  194 CONTINUE        
C        
  195 CALL READ (*460,*170,SCRT4,BUF,NWORDS,NOEOR,NWDS)        
      LMINOR = .TRUE.        
      IF (ITYPE1.NE.5 .OR. SAVDAT(MINOR).EQ.0)  GO TO 196        
      NPOS   = SAVDAT(MINOR)/100        
      NSTXTR = SAVDAT(MINOR) - NPOS*100        
      CALL READ (*460,*470,SCRT4,BUFSAV(1),NSTXTR,NOEOR,NWDS)        
      LMINOR = .FALSE.        
  196 CONTINUE        
C        
C     PREPARE AND OUTPUT THE OFP-ID-RECORD AFTER FIRST ENTRY IS COMBINED
C     AS IN THE CASE OF A FREQUENCY COMPLEX PROBLEM.        
C        
      IDOUT = .FALSE.        
      IDREC(5) = BUF(1)        
C        
C     SET STRESS OR FORCE COMPLEX DATA PTRS IF NECESSARY.        
C        
      IF (TRNSNT) GO TO 220        
      IF (ITYPE1 .EQ. 4) GO TO 200        
      IF (ITYPE1 .EQ. 5) GO TO 210        
      GO TO 220        
C        
C     FORCES ASSUMED        
C        
  200 IELEM = (IDREC(3)-1)*INCR        
      LSF   = ELEM(IELEM+19)        
      NPTSF = ELEM(IELEM+21)        
      GO TO 220        
C        
C     STRESSES ASSUMED        
C        
  210 IELEM = (IDREC(3)-1)*INCR        
      LSF   = ELEM(IELEM+18)        
      NPTSF = ELEM(IELEM+20)        
      GO TO 220        
C        
C     UNPACK DATA FOR ALL COMPONENTS AND ALL SOLUTION STEPS        
C     FOR THIS ID.  (NCOLS COLUMNS ARE NEEDED)        
C        
C        
C     ZERO THE DATA SPACE        
C        
  220 DO 230 I = IDATA,NDATA        
      Z(I) = 0        
  230 CONTINUE        
C        
C     UNPACK NOW-ZERO TERMS.        
C        
      JDATA = IDATA - LENTRY        
      DO 270 I = 1,NCOLS        
      CALL INTPK (*260,SCRT6,0,TYPOUT,0)        
C        
C     COLUMN I HAS ONE OR MORE NON-ZEROES AVAILABLE.        
C        
  240 CALL ZNTPKI        
      ITEMP = JDATA + IROWO*LENTRY        
      IF (.NOT.TRNSNT) GO TO (246,247,248), IPASS        
C        
C     TRANSIENT OUTPUTS        
C        
      RZ(ITEMP) = AOUT(1)        
      IF (IEOL) 240,240,260        
C        
C    DISPLACEMENTS, AND SPCFS (FREQ RESPONSE)        
C        
  246 RZ(ITEMP) = AOUT(1)        
      ITEMP     = ITEMP + NCOLS        
      RZ(ITEMP) = AOUT(2)        
      IF (IEOL) 240,240,260        
C        
C     VELOCITIES  (FREQ RESPONSE)        
C        
  247 KLIST     = IOMEGA + IROWO - 1        
      RZ(ITEMP) =-RZ(KLIST)*AOUT(2)        
      ITEMP     = ITEMP + NCOLS        
      RZ(ITEMP) = RZ(KLIST)*AOUT(1)        
      IF (IEOL) 240,240,260        
C        
C     ACCELERATIONS (FREQ RESPONSE)        
C        
  248 KLIST     = IOMEGA + IROWO - 1        
      RZ(ITEMP) = RZ(KLIST)*AOUT(1)        
      ITEMP     = ITEMP + NCOLS        
      RZ(ITEMP) = RZ(KLIST)*AOUT(2)        
      IF (IEOL) 240,240,260        
  260 JDATA = JDATA + 1        
  270 CONTINUE        
C        
C     OUTPUT LINES OF DATA COMBINING THEM FOR COMPLEX REAL/IMAGINARY OR 
C     MAG/PHASE OFP FORMATS IF NECESSARY.        
C        
      JLIST = ILIST - 1        
      DO 390 I = IDATA,NDATA,LENTRY        
      JWORDS = NWORDS        
      IJ = I + NCOLS - 1        
      DO 280 J = I,IJ        
      JWORDS = JWORDS + 1        
      BUF(JWORDS) = Z(J)        
      IF (TRNSNT) GO TO 280        
      ITEMP = J + NCOLS        
      BUF(JWORDS+75) = Z(ITEMP)        
  280 CONTINUE        
C        
C     IF TRANSIENT, ENTRY IS NOW READY FOR OUTPUT.        
C        
      IF (TRNSNT)  GO TO 365        
C        
C     MAP COMPLEX OUTPUTS TOGETHER PER -COMPLX- ARRAY.        
C        
      IF (ITYPE1.EQ.4 .OR. ITYPE1.EQ.5) GO TO 300        
C        
C     POINT DATA        
C        
      DO 290 K = 3,8        
      IF (FORM .EQ. 3) CALL MAGPHA (BUFA(K),BUFB(K))        
      BUFA(K+6) = BUFB(K)        
  290 CONTINUE        
      JWORDS = 14        
      GO TO 370        
C        
C     ELEMENT STRESS OR FORCE DATA.        
C        
  300 IOUT = 0        
      L = NPTSF        
      IF (LMINOR)  GO TO 310        
      DO 305 K = 1,NSTXTR        
      J = SAVPOS(NPOS+K-1)        
  305 BUF(J) = BUFSAV(K)        
  310 NPT = COMPLX(L)        
      IF (NPT) 320,350,340        
  320 NPT = -NPT        
      IF (FORM .NE. 3) GO TO 340        
C        
C     COMPUTE MAGNITUDE/PHASE        
C        
      CALL MAGPHA (BUFA(NPT),BUFB(NPT))        
  330 IOUT = IOUT + 1        
      ELWORK(IOUT) = BUFA(NPT)        
      L = L + 1        
      GO TO 310        
  340 IF (NPT .LE. LSF) GO TO 330        
      NPT  = NPT - LSF        
      IOUT = IOUT + 1        
      ELWORK(IOUT) = BUFB(NPT)        
      L = L + 1        
      GO TO 310        
C        
C     MOVE OUTPUT DATA        
C        
  350 DO 360 L = 1,IOUT        
      BUF(L) = ELWORK(L)        
  360 CONTINUE        
      JWORDS = IOUT        
      GO TO 370        
  365 CONTINUE        
      IF (LMINOR)  GO TO 370        
      DO 366 K = 1,NSTXTR        
      J = SAVPOS(NPOS+K-1)        
  366 BUF(J) = BUFSAV(K)        
C        
C     CALL DDRMMS TO RECOMPUTE SOME ELEMENT STRESS QUANTITIES        
C     IN TRANSIENT PROBLEMS ONLY.        
C        
  370 IF (TRNSNT .AND. ITYPE1.EQ.5) CALL DDRMMS (BUF,IDREC(3),BUF4,BUF5)
      IF (IDOUT) GO TO 380        
      IDREC( 9) = FORM        
      IDREC(10) = JWORDS        
      CALL WRITE (OUTFIL,IDREC,146,EOR)        
      IDOUT = .TRUE.        
  380 JLIST = JLIST + 1        
      RBUF(1) = RZ(JLIST)        
      CALL WRITE (OUTFIL,BUF,JWORDS,NOEOR)        
  390 CONTINUE        
      CALL WRITE (OUTFIL,0,0,EOR)        
C        
C     GO FOR NEXT OUTPUT ID        
C        
      GO TO 190        
C        
C  END OF DATA ON MAP FILE (SCRT4).        
C        
  400 CALL CLOSE (OUTFIL,CLS)        
      CALL CLOSE (INFILE,CLSREW)        
      CALL CLOSE (SCRT4,CLSREW)        
      CALL CLOSE (SCRT6,CLSREW)        
      IPASS = IPASS + 1        
      IF (IPASS .GT. PASSES) GO TO 410        
C        
C     PREPARE FOR ANOTHER PASS        
C        
      FILE = INFILE        
      CALL OPEN (*450,INFILE,Z(BUF1),RDREW)        
      CALL FWDREC (*460,INFILE)        
      GO TO 20        
  410 RETURN        
C        
C     CHANGE IN MAJOR OFP-ID DETECTED ON -INFILE-.        
C        
  420 WRITE  (OUTPT,430) SWM,INFILE        
  430 FORMAT (A27,' 2339.  (DDRMM2-1) A CHANGE IN WORD 2 OF THE OFP-ID',
     1       ' RECORDS OF DATA BLOCK',I5, /5X,'HAS BEEN DETECTED. ',    
     2       ' POOCESSING OF THIS DATA BLOCK HAS BEEN TERMINATED.')     
  440 IPASS = 3        
      GO TO 400        
C        
C     UNDEFINED FILE.        
C        
  450 RETURN 1        
C        
C     END OF FILE        
C        
  460 RETURN 2        
C        
C     END OF RECORD.        
C        
  470 RETURN 3        
C        
C     INSUFFICIENT CORE        
C        
  480 RETURN 4        
      END        
