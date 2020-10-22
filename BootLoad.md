
## [MODULE BootLoad](https://github.com/io-core/Kernel/blob/main/BootLoad.Mod)

(NW 20.10.2013 / PR 4.2.2014; boot from SDHC disk or line)

    ORP.Compile @
    ORX.WriteFile BootLoad.rsc 512 "D:/Verilog/RISC5/prom.mem"~ 


  ## Imports:
` SYSTEM`

## Constants:
```
 
    MT = 12; SP = 14; LNK = 15;
    MTOrg = 20H; MemLim = 0E7EF0H; stackOrg = 80000H;
    swi = -60; led = -60; rsData = -56; rsCtrl = -52;
    spiData = -48; spiCtrl = -44;
    CARD0 = 1; SPIFAST = 4;
    FSoffset = 80000H;   (*block offset*)
```
## Types:
```


```
## Variables:
```


```
## Procedures:
---
---
**RecInt** get a 32-bit binary value from the serial line.

`  PROCEDURE RecInt(VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L31)

---
**LoadFromLine** Load the binary image of the inner core of Oberon from the serial line.

`  PROCEDURE LoadFromLine;` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L45)

## ---------- disk
---
**SPIIdle** send n FFs slowly with no card selected.

`  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L63)

---
**SPI** send&rcv byte slowly with card selected.

`  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L74)

---
**SPICmd** Send an SPI command.

`  PROCEDURE SPICmd(n, arg: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L83)

---
**InitSPI** Initialize the SPI interface.

`  PROCEDURE InitSPI;` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L99)

---
**SDShift** Interrogate SPI card.

`  PROCEDURE SDShift(VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L120)

---
**ReadSD** Retrieve one block from the SD card via SPI.

`  PROCEDURE ReadSD(src, dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L132)

---
**LoadFromDisk** Retreive the Innner Core of Oberon from the SD Card.

`  PROCEDURE LoadFromDisk;` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L150)

---
**The initialzation code for this module** sets the stack and Module table origin, 
calls the appropriate Load routine, then places the MemoryLimit, and stackOrg in memory for Oberon to find and jumps to the start of memory.

