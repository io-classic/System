(* begin-module-use-description
Module BootLoad compiles to a binary to be placed in the firmware of a system that will boot to Oberon.

end-module-use-description *)
(* begin-module-develop-description

(NW 20.10.2013 / PR 4.2.2014; boot from SDHC disk or line)

    ORP.Compile @
    ORX.WriteFile BootLoad.rsc 512 "D:/Verilog/RISC5/prom.mem"~ 

end-module-develop-description *)
MODULE* BootLoad;  (*NW 20.10.2013 / PR 4.2.2014; boot from SDHC disk or line*)
  IMPORT SYSTEM;
  (* sw0: init SD; sw1: line|disk*)
  CONST 
    MT = 12; SP = 14; LNK = 15;
    MTOrg = 20H; MemLim = 0E7EF0H; stackOrg = 80000H;
    swi = -60; led = -60; rsData = -56; rsCtrl = -52;
    spiData = -48; spiCtrl = -44;
    CARD0 = 1; SPIFAST = 4;
    FSoffset = 80000H;   (*block offset*)
  TYPE

  VAR

  (* begin-section-description
## ---------- Boot Via RS232 Serial
  end-section-description *)

  (* begin-procedure-description
---
**RecInt** gets a 32-bit binary value from the serial line.
  end-procedure-description *)
  PROCEDURE RecInt(VAR x: INTEGER);
    VAR z, y, i: INTEGER;
  BEGIN z := 0;  i := 4;
    REPEAT i := i-1;
      REPEAT UNTIL SYSTEM.BIT(rsCtrl, 0);
      SYSTEM.GET(rsData, y); z := ROR(z+y, 8)
    UNTIL i = 0;
    x := z
  END RecInt;

  (* begin-procedure-description
---
**LoadFromLine** Loads the binary image of the inner core of Oberon from the serial line.
  end-procedure-description *)
  PROCEDURE LoadFromLine;
    VAR len, adr, dat: INTEGER;
  BEGIN RecInt(len);
    WHILE len > 0 DO
      RecInt(adr);
      REPEAT RecInt(dat); SYSTEM.PUT(adr, dat); adr := adr + 4; len := len - 4 UNTIL len = 0;
      RecInt(len)
    END
  END LoadFromLine;

  (* begin-section-description
## ---------- Boot Via SPI SD Card
  end-section-description *)

  (* begin-procedure-description
---
**SPIIdle** sends n FFs slowly with no card selected.
  end-procedure-description *)
  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)
  BEGIN SYSTEM.PUT(spiCtrl, 0);
    WHILE n > 0 DO DEC(n); SYSTEM.PUT(spiData, -1);
      REPEAT UNTIL SYSTEM.BIT(spiCtrl, 0)
    END
  END SPIIdle;

  (* begin-procedure-description
---
**SPI** Delivers a value to SPI data on CARD0 and waits for acceptance.
  end-procedure-description *)
  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)
  BEGIN SYSTEM.PUT(spiCtrl, CARD0); SYSTEM.PUT(spiData, n);
    REPEAT UNTIL SYSTEM.BIT(spiCtrl, 0)
  END SPI;

  (* begin-procedure-description
---
**SPICmd** Synchronously ends an SPI command and its argument.
  end-procedure-description *)
  PROCEDURE SPICmd(n, arg: INTEGER);
    VAR i, data, crc: INTEGER;
  BEGIN (*send cmd*)
    REPEAT SPIIdle(1); SYSTEM.GET(spiData, data) UNTIL data = 255; (*flush while unselected*)
    REPEAT SPI(255); SYSTEM.GET(spiData, data) UNTIL data = 255; (*flush while selected*)
    IF n = 8 THEN crc := 135 ELSIF n = 0 THEN crc := 149 ELSE crc := 255 END;
    SPI(n MOD 64 + 64); (*send command*)
    FOR i := 24 TO 0 BY -8 DO SPI(ROR(arg, i)) END; (*send arg*)
    SPI(crc); i := 32;
    REPEAT SPI(255); SYSTEM.GET(spiData, data); DEC(i) UNTIL (data < 80H) OR (i = 0)
  END SPICmd;

  (* begin-procedure-description
---
**InitSPI** Initializes the SPI interface.
  end-procedure-description *)
  PROCEDURE InitSPI;
    VAR res, data: INTEGER;
  BEGIN SPIIdle(9); (*first, idle for at least 80 clks*)
    SPICmd(0, 0); (*CMD0 when card selected, sets MMC SPI mode*)
    SPICmd(8, 1AAH); SPI(-1); SPI(-1); SPI(-1); (*CMD8 for SD cards*)
    REPEAT (*until card becomes ready*)
      (*ACMD41, optionally with high-capacity (HCS) bit set, starts init*)
      SPICmd(55, 0); (*APP cmd follows*)
      SPICmd(41, LSL(1(*HCS*), 30));
      SYSTEM.GET(spiData, res);
      SPI(-1); SPI(-1); SPI(-1); (*flush response*)
      SPIIdle(10) (*was 10000*)
    UNTIL res = 0;
    (*CMD16 set block size as a precaution (should default)*)
    SPICmd(16, 512); SPIIdle(1)
  END InitSPI;

  (* begin-procedure-description
---
**SDShift** Interrogates an SPI storage card.
  end-procedure-description *)
  PROCEDURE SDShift(VAR n: INTEGER);
    VAR data: INTEGER;
  BEGIN SPICmd(58, 0);  (*CMD58 get card capacity bit*)
    SYSTEM.GET(spiData, data); SPI(-1);
    IF (data # 0) OR ~SYSTEM.BIT(spiData, 6) THEN n := n * 512 END ;  (*non-SDHC card*)
    SPI(-1); SPI(-1); SPIIdle(1)  (*flush response*)
  END SDShift;

  (* begin-procedure-description
---
**ReadSD** Retrieves one block from the SD card via SPI.
  end-procedure-description *)
  PROCEDURE ReadSD(src, dst: INTEGER);
    VAR i, data: INTEGER;
  BEGIN SDShift(src); SPICmd(17, src); (*CMD17 read one block*)
    i := 0; (*wait for start data marker*)
    REPEAT SPI(-1); SYSTEM.GET(spiData, data); INC(i) UNTIL data = 254;
    SYSTEM.PUT(spiCtrl, SPIFAST + CARD0);
    FOR i := 0 TO 508 BY 4 DO
      SYSTEM.PUT(spiData, -1);
      REPEAT UNTIL SYSTEM.BIT(spiCtrl, 0);
      SYSTEM.GET(spiData, data); SYSTEM.PUT(dst, data); INC(dst, 4)
    END;
    SPI(255); SPI(255); SPIIdle(1) (*may be a checksum; deselect card*)
  END ReadSD;

  (* begin-procedure-description
---
**LoadFromDisk** Retreives the Innner Core of Oberon from the SD Card.
  end-procedure-description *)
  PROCEDURE LoadFromDisk;
    VAR src, dst, adr, lim: INTEGER;
  BEGIN src := FSoffset + 4;   (*start at boot block*)
    ReadSD(src, 0); SYSTEM.GET(16, lim);
    INC(src); dst := 512;
    WHILE dst < lim DO ReadSD(src, dst); INC(src); INC(dst, 512) END
  END LoadFromDisk;

  (* begin-procedure-description
---
**The initialzation code for this module** sets the stack and Module table origin, 
calls the appropriate Load routine, then places the MemoryLimit, and stackOrg in memory for Oberon to find and jumps to the start of memory.

  end-procedure-description *)
BEGIN SYSTEM.LDREG(SP, stackOrg); SYSTEM.LDREG(MT, MTOrg);
  IF SYSTEM.REG(LNK) = 0 THEN (*cold start*)
    LED(80H); InitSPI;
    IF SYSTEM.BIT(swi, 0) THEN LED(81H); LoadFromLine ELSE LED(82H); LoadFromDisk END ;
  ELSIF SYSTEM.BIT(swi, 0) THEN LED(81H); LoadFromLine
  END ;
  SYSTEM.PUT(12, MemLim); SYSTEM.PUT(24, stackOrg); LED(84H)
END BootLoad.
