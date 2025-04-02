
;* SK*DOS BIOS FOR THE 68K-MBC COMPUTER
;* USING THE I/O PROVIDED BY THE PIC

;* (C) 2025 BY PHILIPPE ROEHR

;* 000 24/01/2025 INITIAL VERSION
;* 001 31/03/2025 IMPROVE SPEED
;* 002 01/04/2025 BETTER MAPPING OF DISKS - USEABLE DRIVE COMMAND

;****** CAUTION - THE NEXT ADDRESSES MAY CHANGE!!!! ****
;LVL5IA   EQU      $2F52               LEVEL 5 VECTOR
;PUTCD5   EQU      $4AFC               PUTCHR INTERNAL
;*******************************************************

DOSORG      EQU      $1000              ; BEGINNING LOCATION OF SK*DOS
WINTAB      EQU      DOSORG+$200        ; WINCHESTER DATA TABLE
VRBLES      EQU      DOSORG+$400        ; BEGINNING OF SK*DOS VARIABLE AREA
GETDAT      EQU      DOSORG+$00C        ; VECTOR TO GET THE DATE
INTIME      EQU      DOSORG+$012        ; VECTOR TO GET THE TIME
CDAY        EQU      VRBLES+751         ; CURRENT DATE - DAY
CMONTH      EQU      VRBLES+750         ; CURRENT DATE - MONTH
CYEAR       EQU      VRBLES+752         ; CURRENT DATE - YEAR
BREAK       EQU      VRBLES+762         ; BREAK ADDRESS
DICOLD      EQU      DOSORG+$100        ; DISK COLD-START INIT
DIWARM      EQU      DOSORG+$106        ; DISK WARM-START INIT
DIREAD      EQU      DOSORG+$10C        ; DISK READ
DIWRIT      EQU      DOSORG+$112        ; DISK WRITE
DICHEK      EQU      DOSORG+$118        ; DISK READY CHECK
DIMOFF      EQU      DOSORG+$11E        ; TURN OFF DISK MOTOR
DIREST      EQU      DOSORG+$124        ; PRIMARY DISK RESTORE
DISEEK      EQU      DOSORG+$12A        ; PRIMARY DISK SEEK
ERRTYP      EQU      VRBLES+782         ; ERROR TYPE
INDOS       EQU      VRBLES+794         ; 0=OUTSIDE DOS, ELSE IN DOS
INECHO      EQU      VRBLES+800         ; INPUT ECHO FLAG
DEVOUT      EQU      VRBLES+3275        ; OUTPUT DEVICE NUMBER
STPRAT      EQU      DOSORG+$130        ; STEPRATES FOR THREE DRIVES
VERFLG      EQU      DOSORG+$13A        ; VERIFY FLAG
DRUSED      EQU      DOSORG+$13C        ; DRIVE USED TABLE
NRETRY      EQU      DOSORG+$150        ; FLOPPY RETRY COUNTER
FOTHER      EQU      DOSORG+$151        ; =0 IF SK*DOS, ELSE # SECT/SIDE
NUMBHD      EQU      DOSORG+$152        ; NUMBER OF HARD DRIVES
SINITV      EQU      DOSORG+$180        ; SERIAL PORT INIT
STATVE      EQU      DOSORG+$186        ; SERIAL PORT STATUS CHECK
STATV1      EQU      DOSORG+$1D4        ; INPUT STATUS CHECK W/O TYPEAHEAD
OUTCHV      EQU      DOSORG+$18C        ; OUTPUT TO PORT
OFFINI      EQU      DOSORG+$018        ; INITIAL OFFSET VALUE
INCHV       EQU      DOSORG+$192        ; INPUT FROM KBD WITH ECHO
KINPUV      EQU      DOSORG+$198        ; INPUT W/O ECHO
KINPV1      EQU      DOSORG+$1DA        ; INPUT W/O ECHO  W/O TYPEAHEAD
ICNTRL      EQU      DOSORG+$1A4        ; INPUT CONTROL
MONITV      EQU      DOSORG+$1AA        ; RETURN TO MONITOR
RESETV      EQU      DOSORG+$1B0        ; RESET MONITOR/SYSTEM
TIMINI      EQU      DOSORG+$1B6        ; TIMER INITIALIZE
TIMOFF      EQU      DOSORG+$1BC        ; TIMER OFF
TIMON       EQU      DOSORG+$1C2        ; TIMER ON
OSTATV      EQU      DOSORG+$1C8        ; OUTPUT STATUS VECTOR
GETDTV      EQU      DOSORG+$1CE        ; GET DATE AND TIME VECTOR
KILLV1      EQU      DOSORG+$1E0        ; FLUSH TYPEAHEAD BUFFER
PSTRNV      EQU      DOSORG+$B6         ; PRINT STRING VECTOR
ASKDAV      EQU      DOSORG+$B0         ; ASK FOR DATE VECTOR


;* SK*DOS FCB EQUATES

FCBPHY      EQU     72                  ; PHYSICAL DRIVE NUMBER
FCBDAT      EQU     96                  ; BEGINNING OF DATA BUFFER (256 BYTES)
FCBCSE      EQU     35                  ; CURRENT SECTOR IN BUFFER
FCBCTR      EQU     34                  ; CURRENT TRACK IN BUFFER
FCBDRV      EQU     3                   ; LOGICAL DRIVE NUMBER
FCBERR      EQU     1                   ; ERROR CODE

;* IOS EQUATES

IOBASE      EQU     $FFFFC              ; ADDRESS BASE FOR THE I/O PORTS
EXCWR_PORT  EQU     IOBASE+0            ; ADDRESS OF THE EXECUTE WRITE OPCODE WRITE PORT
EXCRD_PORT  EQU     IOBASE+0            ; ADDRESS OF THE EXECUTE READ OPCODE READ PORT
STOPC_PORT  EQU     IOBASE+1            ; ADDRESS OF THE STORE OPCODE WRITE PORT
SER1RX_PORT EQU     IOBASE+1            ; ADDRESS OF THE SERIAL 1 RX READ PORT
SYSFLG_PORT EQU     IOBASE+2            ; ADDRESS OF THE SYSFLAGS READ PORT
SER2RX_PORT EQU     IOBASE+3            ; ADDRESS OF THE SERIAL 2 RX READ PORT
USRLED_OPC  EQU     $00                 ; USER LED OPCODE
SER1TX_OPC  EQU     $01                 ; SERIAL 1 TX OPCODE
SETIRQ_OPC  EQU     $02                 ; SETIRQ OPCODE
SELDISK_OPC EQU     $09                 ; SELDISK OPCODE
SELTRCK_OPC EQU     $0A                 ; SELTRACK OPCODE
SELSECT_OPC EQU     $0B                 ; SELSECT OPCODE
WRTSECT_OPC EQU     $0C                 ; WRITESECT OPCODE
SER2TX_OPC  EQU     $10                 ; SERIAL 2 TX OPCODE
GETDAT_OPC  EQU     $84
ERRDSK_OPC  EQU     $85                 ; ERRDISK OPCODE
RDSECT_OPC  EQU     $86                 ; READSECT OPCODE
SDMOUNT_OPC EQU     $87                 ; SDMOUNT OPCODE
FLUSHBF_OPC EQU     $88                 ; FLUSHBUFF OPCODE

;* COMMON ASCII CODES

CR          EQU     $0D                 ; CARRIAGE RETURN
LF          EQU     $0A                 ; LINE FEED
EOS         EQU     $04                 ; END OF STRING
SPA         EQU     $20                 ; SPACE

;* ADJUST SOME SK*DOS PARAMETERS

;* SET INITIAL DISKS NUMBER
;*    LOGICAL 0 = PHYSICAL $20
;*    LOGICAL 1 = PHYSICAL $21
        ORG       DRUSED
        FCB       $20
        FCB       $21

;* THE FOLLOWING ORG POINT DEPENDENT ON TOP OF SK*DOS. BEFORE
;* ASSEMBLING, DO A LOCATE ON SK*DOS.COR TO CHECK THE TOP
;* ADDRESS, AND THEN MAKE ORG HIGHER THAN THAT

;* THIS ORG DEPENDS ON THE LAST ADDRESS OF SK*DOS.COR
         ORG      $6300

;***************************************
;**** --- PART 1 - DISK DRIVERS --- ****
;***************************************

;* CAUTION - THESE DRIVERS MUST PRESERVE ALL REGISTERS!!!

;****************************************
;**** --- PART 1A - DRIVER SELECT -- ****
;****************************************

;* ON 68K-MBC THERE IS ONLY HARD DISK $20 TO $27

;* THIS TABLE IS FEED BY HDSEEK ROUTINE
;* AND HAVE THE IOS PARAM FOR THE NEXT DISK ACCESS
;* CALCULATED FROM FLEX TRACK / SECTOR PARAMS

;* AS INITIAL DISK WE PUT A WRONG VALUE (2) TO FORCE A DISK SELECT AT FIRST USAGE
IOSDKS      DC.B    2                   ; DISK NUMBER XX IN DS1NXX FOR NEXT RW
IOSTRKL     DS.B    1                   ; TRACK LSB FOR NEXT RW
IOSTRKM     DS.B    1                   ; TRACK MSB
IOSSEC      DS.B    1                   ; SECTOR FOR NEXT RW

;************************
;*** READ ENTRY POINT ***
;************************

; ===========================================================================
;
; READ 256 BYTES SECTOR
; A4 FCB TO USE
; IOS SECTOR IS 512 BYTES BUT ALL ODD BYTES ARE DISCARDED SO BUFFER RECEIVE ONLY 256 BYTES
;
; ===========================================================================

READSECT    MOVEM.L A1/D1/D3,-(SP)
            BSR     HDSEEK
            MOVE.B  #SELTRCK_OPC,(STOPC_PORT)       ; SELECT SET TRACK OP CODE
            MOVE.B  IOSTRKL,(EXCWR_PORT).L          ; WRITE TRACK LSB
            MOVE.B  IOSTRKM,(EXCWR_PORT).L          ; WRITE TRACK MSB
            LEA     FCBDAT(A4),A1                   ; SET BUFFER ADDRESS
            MOVE.B  #SELSECT_OPC,(STOPC_PORT).L     ; SELECT SET SECTOR OP CODE
            MOVE.B  IOSSEC,(EXCWR_PORT).L           ; SELECT SECTOR
            MOVE.B  #RDSECT_OPC,(STOPC_PORT).L      ; SELECT READ SECTOR OP CODE
            MOVE.W  #255,D3                         ; PREPARE FOR 2 x 256 BYTES / SECTOR READ
LREAD       MOVE.B  (EXCRD_PORT),(A1)+              ; READ AND STORE EVEN BYTES
            MOVE.B  (EXCRD_PORT),D1                 ; READ ODD BYTES - DISCARDED
            DBLT     D3,LREAD                       ; D3 < 0 ? - NO DO AGAIN
            MOVEM.L (SP)+,D3/D1/A1
            RTS

;************************
;*** WRITE ENTRY POINT ***
;************************

; ===========================================================================
;
; WRITE 256 BYTES SECTOR
; A4 FCB TO USE
; IOS SECTOR IS 512 BYTES BUT NULL ODD BYTES ARE ADDED SO 512 BYTES WILL BE WRITED TO SECTOR
;
; ===========================================================================

WRTSECT     MOVEM.L A1/D3,-(SP)
            BSR     HDSEEK
            MOVE.B  #SELTRCK_OPC,(STOPC_PORT).L     ; SELECT SET TRACK OP CODE
            MOVE.B  IOSTRKL,(EXCWR_PORT).L          ; WRITE TRACK LSB
            MOVE.B  IOSTRKM,(EXCWR_PORT).L          ; WRITE TRACK MSB
            LEA     FCBDAT(A4),A1                   ; SET BUFFER ADDRESS
            MOVE.B  #SELSECT_OPC,(STOPC_PORT).L     ; SELECT SET SECTOR OP CODE
            MOVE.B  IOSSEC,(EXCWR_PORT).L           ; SELECT SECTOR
            MOVE.B  #WRTSECT_OPC,(STOPC_PORT).L     ; SELECT WRITE SECTOR OP CODE
            MOVE.W  #255,D3                         ; PREPARE FOR 2 x 256 BYTE MOVE
LWRT        MOVE.B  (A1)+,(EXCWR_PORT)              ; WRITE EVEN BYTES
            MOVE.B  #$0,(EXCWR_PORT)                ; WRITE ODD BYTES
            DBLT    D3,LWRT                         ; D3 < 0 ? NO DO AGAIN
            MOVEM.L (SP)+,D3/A1
            RTS

; ===========================================================================
;
; IOS TRACK/SECTOR CALCULATION FROM FLEX TRACK/SECTOR
; SELECT DISK INTO IOS REGISTER
;
; THIS ROUTINE ASSUME THERE IS TWO HARD DRIVES ($20 AND $24) WITH ONLY
; ONE PARTITION ON EACH DISK.
;
; DISK GEOMETRY FIXED
;   - IOS DISK FORMAT 512 TRACKS $00->$1FF  / 32 SECTORS $00->$1F
;   - SK*DOS DISK FORMAT 64 TRACKS $00->$3F / 256 SECTORS $00->$FF
;
; A4 POINT TO FLEX FCB TO USE
;
; ===========================================================================

HDSEEK      MOVEM.L D1/D2/A6,-(SP)
            MOVE.L  #0,D2
            MOVE.B  FCBDRV(A4),D2                   ; LOAD LOGICAL DRIVE NUMBER
            LEA     DRUSED,A6
            MOVE.B  0(A6,D2.L),D2                   ; D2 IS NOW PHYSICAL DRIVE NUMBER
            SUB.B   #$20,D2                         ; SUBSTRACT $20 - D2 IS NOW XX IN DS1NXX.DSK
            CMP.B   IOSDKS,D2                       ; CHECK IF DISK ALREADY SELECTED
            BEQ     DSK0                            ; YES DO NOTHING
            MOVE.B  D2,IOSDKS                       ; MUST CHANGE SELECTED DISK
            MOVE.B  #SELDISK_OPC,(STOPC_PORT).L     ; SELECT DISK OP CODE
            MOVE.B  IOSDKS,(EXCWR_PORT).L           ; SELECT DISK
DSK0        MOVE.L  #0,D1                           ; CLEAR D1 AND D2
            MOVE.L  #0,D2
            MOVE.B  FCBCTR(A4),D1                   ; GET FLEX TRK NUMBER ($00->$3F)
            MOVE.B  FCBCSE(A4),D2                   ; GET FLEX SECT NUMBER ($00->$FF)
            MULU.W  #$100,D1
            ADD.W   D2,D1                           ; D1 IS NOW THE LBA NUMBER WITH 512 BYTES SECTOR
            DIVU.W  #$20,D1                         ; AFTER THE DIVISION D1 MSB WORD IS THE REMAINDER (SECTOR) AND D1 LSB WORD IS THE QUOTIENT (TRACK)
            MOVE.B  D1,IOSTRKL                      ; WRITE TRACK LSB ($0000 TO $01FF)
            LSR.L   #08,D1                          ; SHIFT D1 8 BITS RIGHT SO GET TRACK NUMBER MSB
            MOVE.B  D1,IOSTRKM                      ; WRITE TRACK MSB
            LSR.L   #08,D1                          ; GET D1 MSB WORD => D1.B IS FIRST IOS SECTOR NUMBER TO USE
            MOVE.B  D1,IOSSEC                       ; WRITE SECTOR ($00 TO $1F)
            MOVEM.L (SP)+,D2/D1/A6
            RTS

; *******************************************************
; * CHKRDY - CHECK IF DRIVE SPEC BY FCB IS READY
; *******************************************************
;*
;* INPUT: A4 POINTS TO FCB, FCBDRV(A4) IS DRIVE NUMBER
;* OUTPUT:        RETURN ZERO AND CLC IF NO ERROR;
;*                NONZERO AND ERROR $80 IN D6 IF NOT READY
;* REGISTERS USED: D6 - A6 (NEED NOT RESTORE)
;*
;* ON 68K-MBC DISKS ALLWAYS READY - JUST CHECK IF PHYSICAL DISK >= $20 AND <= $27

CHKRDY      CLR.L    D6
            MOVE.B   FCBDRV(A4),D6                  ; GET LOGICAL DRIVE NUMBER
            LEA      DRUSED,A6
            MOVE.B   0(A6,D6.L),D6                  ; D6 IS NOW PHYSICAL DRIVE NUMBER ($20 --> $27)
            SUB.B    #$20,D6                        ; SUBSTRACT $20
            BLT      DSKNOK                         ; < 0 NOT OK
            CMP.B    #7,D6                          ; > 7 NOT OK
            BHI      DSKNOK
            BRA      DSKOK                          ; >=0 AND <=7 OK

DSKNOK      MOVE.B   #$80,D6                        ; NOT IN 0-7 - SET NOT READY BIT
            OR.B     #$01,CCR                       ; SET CARRY
            RTS

DSKOK       CLR.L    D6                             ; NO ERROR
            AND.B    #$FE,CCR                       ; CLEAR CARRY
            RTS      RTS

;******************************************
;**** --- PART 2 - CONSOLE DRIVERS --- ****
;******************************************

;* CONVENTIONS: D1-D5 AND A1-A5 MUST BE PRESERVED
;*              (EXCEPT WHEN D5 IS FOR INPUT)
;*              OTHER REGISTERS ARE SCRATCH

;*********************************************
;* SERINI - SERIAL PORT INITIALIZATION ROUTINE
;*********************************************

SERINI      RTS                         ; DO NOTHING

;* CONSOLE INPUT PORT STATUS CHECK - MULTIPLE
;*
;*    INPUT: NONE
;*    OUTPUT: RETURN ZERO IF NO CHARACTER READY,
;*                   NON-ZERO IF CHARACTER IS THERE
;*                   D5=1 TO SHOW 1 CHARACTER READY
;*    REGISTERS USED: NONE

STATM

;* CONSOLE INPUT PORT STATUS CHECK - SINGLE CHAR
;*
;*    INPUT: NONE
;*    OUTPUT: RETURN ZERO IF NO CHARACTER READY,
;*                   NON-ZERO IF CHARACTER IS THERE
;*                   D5=1 TO SHOW 1 CHARACTER READY
;*    REGISTERS USED: NONE

STAT

;* CHECK SERIAL PORT
INCHE0      BTST    #2,SYSFLG_PORT      ; CHECK IF SERIAL 1 RX BUFFER EMPTY (0 EMPTY - 1 CHAR WAITING)
            RTS                         ; AND RETURN WITH IT

;* OUTPUT PORT STATUS CHECK.
;*
;*    INPUT: NONE
;*    OUTPUT: RETURN ZERO IF NOT READY
;*    REGISTERS USED: NONE

OSTAT       ANDI.B  #$FB,CCR            ; ALWAYS READY SO CLEAR Z
            RTS                         ; RETURN WITH ZERO IF NOTHING

;***********************************************************
;* OUTPUT CHAR ON SERIAL PORT (MAIN CONSOLE)
;***********************************************************

OUTEEE      BSR.S   OSTAT                          ; CHECK IF PORT READY
            BEQ.S   OUTEEE                         ; WAIT IF NOT
            MOVE.B  #SER1TX_OPC,(STOPC_PORT).L     ; WRITE SEND CHAR OPCODE
            MOVE.B  D5,(EXCWR_PORT).L              ; EXECUTE SEND CHAR
            RTS

;***********************************************************
;* GET CHARACTER FROM SERIAL PORT WITHOUT ECHO
;***********************************************************

KINPUT      BTST     #2,SYSFLG_PORT     ; TEST IF CHAR RECEIVED
            BEQ.S    KINPUT             ; WAIT IF NOT
            MOVE.B   SER1RX_PORT,D5     ; GET CHARACTER
            RTS

;***********************************************************
;* GET CHARACTER FROM SERIAL PORT WITH ECHO
;***********************************************************

INEEE       BSR.S   KINPUT              ; GET CHAR
            BSR.S   OUTEEE              ; ECHO IT
            RTS

;* RE-ENTER MONITOR WITHOUT RESET
;* THIS COMMAND DOES NOT CHANGE EXCEPTION VECTORS
;*
;*    INPUT: NONE
;*    OUTPUT: NONE
;*    REGISTERS USED: A5



;* RESET MONITOR/SYSTEM AS IF RESET FROM SCRATCH
;* THIS COMMAND RESETS EXCEPTION VECTORS TO MONITOR'S,
;* ERASES BREAKPOINT TABLE, RESET BAUD RATE, ETC.
;*
;*    INPUT: NONE
;*    OUTPUT: NONE
;*    REGISTERS USED: A5



;* TIMER ON, OFF, INIT
;*
;*    INPUT: NONE
;*    OUTPUT: NONE
;*    REGISTERS USED: NONE

TIMRTS      RTS                         ; RTS DO NOTHING

;*****************************************
;*** --- PART 3 - GET DATE ROUTINE --- ***
;*****************************************

;* THIS ROUTINE GETS THE DATE DURING BOOTING,
;* AND PUTS IT INTO THE MONTH, DAY, YEAR LOCATIONS.

INPDAT      MOVE.L  D1,-(SP)
            MOVE.B  #GETDAT_OPC,(STOPC_PORT).L  ; SEND GET DATE + TIME CODE
            MOVE.B  EXCRD_PORT,CDAY             ; GET SECOND
            MOVE.B  EXCRD_PORT,CDAY             ; GET MINUT
            MOVE.B  EXCRD_PORT,CDAY             ; GET HOUR
            MOVE.B  EXCRD_PORT,CDAY             ; GET DAY
            MOVE.B  EXCRD_PORT,CMONTH           ; GET MONTH
            MOVE.B  EXCRD_PORT,CYEAR            ; GET YEAR
            MOVE.B  EXCRD_PORT,D1               ; GET TEMP
            MOVE.L (SP)+,D1
            RTS

;*****************************************
;*** --- PART 4 - GET TIME ROUTINE --- ***
;*****************************************

;*************** PART 4 A ************************
;* THIS ROUTINE IS CALLED EVERY TIME SK*DOS OPENS A FILE
;* FOR WRITING, READS THE TIME OF DAY FROM THE MK48T02 CLOCK
;* ON THE PT-68K BOARD, CONVERTS THE TIME INTO A
;* ONE-BYTE CODE, AND PUTS IT INTO D5 SO THAT
;* SK*DOS CAN PUT IT INTO THE DIRECTORY, NEXT TO THE DATE.
;* CAUTION - ALL REGISTERS MUST BE PRESERVED EXCEPT A5-A6,D5-D7.

SETIME   MOVEM.L    D0-D1,-(SP)
         MOVE.B     #GETDAT_OPC,(STOPC_PORT).L  ; SEND GET DATE + TIME CODE
         MOVE.B     EXCRD_PORT,D5               ; GET SECOND - DONT CARE
         MOVE.B     EXCRD_PORT,D5               ; GET MINUT
         MOVE.B     EXCRD_PORT,D0               ; GET HOUR
         MOVE.B     EXCRD_PORT,D1               ; GET DAY - DONT CARE
         MOVE.B     EXCRD_PORT,D1               ; GET MONTH - DONT CARE
         MOVE.B     EXCRD_PORT,D1               ; GET YEAR - DONT CARE
         MOVE.B     EXCRD_PORT,D1               ; GET TEMP - DONT CARE
;* NOW COMPUTE TIME BYTE D5
         DIVU       #6,D5                       ; DIVIDE MINUTES BY 6
         MULU       #10,D0                      ; HOURS * 10
         ADD.B      D0,D5                       ; HOURS * 10 + MINUTES / 6 IN D5
         BNE.S      EXSET                       ; IF NOT 00
         MOVE.B     #$F0,D5                     ; CHANGE 00 TO F0
EXSET    MOVEM.L    (SP)+,D0-D1
         RTS                                    ; RETURN

;****************************************
;*** --- PART 5 - OFFSET --- ****
;****************************************

; THE FOLLOWING SETS "OFFSET" ABOVE THESE DRIVERS

DRVEND      EQU     *                   ; THE END OF THESE DRIVERS
            ORG     OFFINI
            DC.L    DRVEND              ; DRVEND AT OFFINI

;****************************************
;*** --- PART 6 - VECTORS --- ****
;****************************************

; THE FOLLOWING VECTORS STEER SK*DOS TO THESE DRIVERS

            ORG     GETDAT
            JMP.L   INPDAT              ; GO TO DATE PATCH TO GET DATE


            ORG     INTIME
            JMP.L   SETIME              ; GO TO TIME PATCH TO GET TIME

            ORG     DICOLD
            ;JMP.L   HDCOLD              ; COLD INIT HARD DISK DRIVERS

            ORG     DIWARM              ; NOTHING NEEDED

            ORG     DIREAD
            JMP     READSECT            ; PRIMARY READ ROUTINE

            ORG     DIWRIT
            JMP     WRTSECT             ; PRIMARY WRITE ROUTINE

            ORG     DICHEK
            JMP     CHKRDY              ; PRIMARY DISK READY CHECK

            ORG     DIMOFF
            ;JMP     MOTROF              ; TURN OFF MOTOR IMMED

            ORG     DIREST
            ;JMP     DREST               ; PRIMARY DISK RESTORE

            ORG     DISEEK
            ;JMP     DSEEK               ; PRIMARY DISK SEEK

            ORG     SINITV
            JMP     SERINI              ; SERIAL PORT INITIALIZATION ROUTINE

            ORG     STATVE
            JMP     STATM               ; CHECK KEYBOARD STATUS - MULTIPLE

            ORG     OUTCHV
            JMP     OUTEEE              ; OUTPUT CHARACTER TO TERMINAL

            ORG     INCHV
            JMP     INEEE               ; KEYBOARD INPUT WITH ECHO MULT

            ORG     KINPUV
            JMP     KINPUT              ; KEYBOARD INPUT WITHOUT ECHO MULT

            ORG     ICNTRL
            ;JMP     BICONT              ; INPUT CHANNEL CONTROL

            ORG     OSTATV
            JMP     OSTAT               ; CHECK OUTPUT STATUS

            ORG     MONITV
            ;JMP     MONITX              ; RE-ENTER MONITOR

            ORG     RESETV
            ;JMP     RESETX              ; RESET MONITOR/SYSTEM

            ORG     TIMINI
            JMP     TIMRTS              ; TIMER INITIALIZE

            ORG     TIMOFF
            JMP     TIMRTS              ; TIMER OFF

            ORG     TIMON
            JMP     TIMRTS              ; TIMER ON

            ORG     GETDTV
            ;JMP     GETDT               ; GET DATE AND TIME

            ORG     STATV1
            ;JMP.L   STAT                ; CHECK KBD STATUS - 1 CHAR

            ORG     KINPV1
            ;JMP.L   INCH8               ; KBD INPUT W/O ECHO 1 CHAR

            ORG     KILLV1
            ;JMP.L   KILLTA              ; ERASE TYPEAHEAD BUFFER
