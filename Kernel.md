
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

`  PROCEDURE GetBlock(VAR p: LONGINT; len: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L59)

---
**GetBlock128** gets a 128-byte block from the heap.

`  PROCEDURE GetBlock128(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L82)

---
**GetBlock64** gets a 64-byte block from the heap. 

`  PROCEDURE GetBlock64(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L95)

---
**GetBlock32** gets a 32-byte block from the heap.

`  PROCEDURE GetBlock32(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L108)

---
**New** gets an appropriate block from the heap to hold a new object and initializes it to zero. 

`   PROCEDURE New*(VAR ptr: LONGINT; tag: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L121)

## ---------- Garbage Collection
---
**Mark** traverses the heap from roots, identifying live objects. 

`  PROCEDURE Mark*(pref: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L144)

---
**Scan** traverses the heap de-allocating unreachable objects. 

`  PROCEDURE Scan*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L169)

## ---------- SPI Block Operations (see also BootLoad.Mod for the same procedures)
---
**SPIIdle** 

`  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L205)

---
**SPI** 

`  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L217)

---
**SPICmd** 

`  PROCEDURE SPICmd(n, arg: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L227)

---
**SDShift** 

`  PROCEDURE SDShift(VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L243)

---
**ReadSD** 

`  PROCEDURE ReadSD(src, dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L255)

---
**WriteSD** 

`  PROCEDURE WriteSD(dst, src: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L273)

## ---------- Disk Sector Operations
---
**InitSecMap** 

`  PROCEDURE InitSecMap*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L295)

---
**MarkSector** 

`  PROCEDURE MarkSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L305)

---
**FreeSector** 

`  PROCEDURE FreeSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L314)

---
**AllocSector** 

`  PROCEDURE AllocSector*(hint: INTEGER; VAR sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L323)

---
**GetSector** 

`  PROCEDURE GetSector*(src: INTEGER; VAR dst: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L337)

---
**PutSector** 

`  PROCEDURE PutSector*(dst: INTEGER; VAR src: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L347)

## ---------- Time and Clock Operations
---
**Time** gets the current timer value.

`  PROCEDURE Time*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L361)

---
**Clock** gets the current clock value.

`  PROCEDURE Clock*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L370)

---
**SetClock** sets the clock.

`  PROCEDURE SetClock*(dt: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L378)

## ---------- Trap and Fault Handling
---
**Install** constructs a branch instruction to the specified trap handler and places it.

`  PROCEDURE Install*(Padr, at: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L390)

---
**Trap** is a temporary trap handler used in system initialization that either allocates memory (trap 0) or 
emits the trap number on the LEDs and goes into an infinite loop.

`  PROCEDURE Trap(VAR a: INTEGER; b: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L399)

---
**Init** is called by Modules on system startup to install a temporary trap handler and then initialize memory and the sector map. 

`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L411)

