
## [MODULE Kernel](https://github.com/io-core/Kernel/blob/main/Kernel.Mod)

  ## Imports:
` SYSTEM`

## Constants:
```
 
    SectorLength* = 1024;
    timer = -64; spiData = -48; spiCtrl = -44;
    CARD0 = 1; SPIFAST = 4;
    FSoffset = 80000H; (*256MB in 512-byte blocks*)
    mapsize = 10000H; (*1K sectors, 64MB*)

```
## Types:
```
 
    Sector* = ARRAY SectorLength OF BYTE;

```
## Variables:
```
 
    allocated*, NofSectors*: INTEGER;
    heapOrg*, heapLim*: INTEGER; 
    stackOrg* ,  stackSize*, MemLim*: INTEGER;
    clock: INTEGER;
    list0, list1, list2, list3: INTEGER;  (*lists of free blocks of size n*256, 128, 64, 32 bytes*)
    data: INTEGER; (*SPI data in*)
    sectorMap: ARRAY mapsize DIV 32 OF SET;

```
## Procedures:
---
## ---------- Heap Allocation
---
**GetBlock** gets a block from the heap of a regular size. 

`  PROCEDURE GetBlock(VAR p: LONGINT; len: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L62)

---
**GetBlock128** gets a 128-byte block from the heap.

`  PROCEDURE GetBlock128(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L85)

---
**GetBlock64** gets a 64-byte block from the heap. 

`  PROCEDURE GetBlock64(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L98)

---
**GetBlock32** gets a 32-byte block from the heap.

`  PROCEDURE GetBlock32(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L111)

---
**New** gets an appropriate block from the heap to hold a new object and initializes it to zero. 

`   PROCEDURE New*(VAR ptr: LONGINT; tag: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L124)

## ---------- Garbage Collection
---
**Mark** traverses the heap from roots, identifying live objects. 

`  PROCEDURE Mark*(pref: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L147)

---
**Scan** traverses the heap de-allocating unreachable objects. 

`  PROCEDURE Scan*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L172)

## ---------- SPI Block Operations (see also BootLoad.Mod for the same procedures)
---
**SPIIdle** 

`  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L208)

---
**SPI** 

`  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L220)

---
**SPICmd** 

`  PROCEDURE SPICmd(n, arg: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L230)

---
**SDShift** 

`  PROCEDURE SDShift(VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L246)

---
**ReadSD** 

`  PROCEDURE ReadSD(src, dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L258)

---
**WriteSD** 

`  PROCEDURE WriteSD(dst, src: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L276)

## ---------- Disk Sector Operations
---
**InitSecMap** 

`  PROCEDURE InitSecMap*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L298)

---
**MarkSector** 

`  PROCEDURE MarkSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L308)

---
**FreeSector** 

`  PROCEDURE FreeSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L317)

---
**AllocSector** 

`  PROCEDURE AllocSector*(hint: INTEGER; VAR sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L326)

---
**GetSector** 

`  PROCEDURE GetSector*(src: INTEGER; VAR dst: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L340)

---
**PutSector** 

`  PROCEDURE PutSector*(dst: INTEGER; VAR src: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L350)

## ---------- Time and Clock Operations
---
**Time** gets the current timer value.

`  PROCEDURE Time*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L364)

---
**Clock** gets the current clock value.

`  PROCEDURE Clock*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L373)

---
**SetClock** sets the clock.

`  PROCEDURE SetClock*(dt: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L381)

## ---------- Trap and Fault Handling
---
**Install** constructs a branch instruction to the specified trap handler and places it.

`  PROCEDURE Install*(Padr, at: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L393)

---
**Trap** is a temporary trap handler used in system initialization that either allocates memory (trap 0) or 
emits the trap number on the LEDs and goes into an infinite loop.

`  PROCEDURE Trap(VAR a: INTEGER; b: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L402)

---
**Init** is called by Modules on system startup to install a temporary trap handler and then initialize memory and the sector map. 

`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L414)

