
## [MODULE BootLoad](https://github.com/io-core/Kernel/blob/main/BootLoad.Mod)
Module BootLoad is the firmware for the RISC Oberon platform.

    ORP.Compile BootLoad.Mod ~
    ORF.WriteFile BootLoad.rsc prom.mem ~                      


(NW 20.10.2013 / PR 4.2.2014; boot from SDHC disk or line)

    ORP.Compile BootLoad.Mod ~
    ORF.WriteFile BootLoad.rsc prom.mem ~ 


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
## ---------- Boot Via RS232 Serial
---
**RecInt** gets a 32-bit binary value from the serial line.

`  PROCEDURE RecInt(VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L38)

---
**LoadFromLine** Loads the binary image of the inner core of Oberon from the serial line.

`  PROCEDURE LoadFromLine;` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L52)

## ---------- Boot Via SPI SD Card
---
**SPIIdle** sends n FFs slowly with no card selected.

`  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L70)

---
**SPI** Delivers a value to SPI data on CARD0 and waits for acceptance.

`  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L81)

---
**SPICmd** Synchronously ends an SPI command and its argument.

`  PROCEDURE SPICmd(n, arg: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L90)

---
**InitSPI** Initializes the SPI interface.

`  PROCEDURE InitSPI;` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L106)

---
**SDShift** Interrogates an SPI storage card.

`  PROCEDURE SDShift(VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L127)

---
**ReadSD** Retrieves one block from the SD card via SPI.

`  PROCEDURE ReadSD(src, dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L139)

---
**LoadFromDisk** Retreives the Innner Core of Oberon from the SD Card.

`  PROCEDURE LoadFromDisk;` [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod#L157)

---
**The initialzation code for this module** sets the stack and Module table origin, 
calls the appropriate Load routine, then places the MemoryLimit, and stackOrg in memory for Oberon to find and jumps to the start of memory.

