
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

`  PROCEDURE GetBlock(VAR p: LONGINT; len: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L54)

---
**GetBlock128** gets a 128-byte block from the heap.

`  PROCEDURE GetBlock128(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L77)

---
**GetBlock64** gets a 64-byte block from the heap. 

`  PROCEDURE GetBlock64(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L90)

---
**GetBlock32** gets a 32-byte block from the heap.

`  PROCEDURE GetBlock32(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L103)

---
**New** gets an appropriate block from the heap to hold a new object and initializes it to zero. 

`   PROCEDURE New*(VAR ptr: LONGINT; tag: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L116)

## ---------- Garbage Collection
---
**Mark** traverses the heap from roots, identifying live objects. 

`  PROCEDURE Mark*(pref: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L139)

---
**Scan** traverses the heap de-allocating unreachable objects. 

`  PROCEDURE Scan*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L164)

## ---------- SPI Block Operations (see also BootLoad.Mod for the same procedures)
---
**SPIIdle** 

`  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L200)

---
**SPI** 

`  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L212)

---
**SPICmd** 

`  PROCEDURE SPICmd(n, arg: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L222)

---
**SDShift** 

`  PROCEDURE SDShift(VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L238)

---
**ReadSD** 

`  PROCEDURE ReadSD(src, dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L250)

---
**WriteSD** 

`  PROCEDURE WriteSD(dst, src: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L268)

## ---------- Disk Sector Operations
---
**InitSecMap** 

`  PROCEDURE InitSecMap*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L290)

---
**MarkSector** 

`  PROCEDURE MarkSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L300)

---
**FreeSector** 

`  PROCEDURE FreeSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L309)

---
**AllocSector** 

`  PROCEDURE AllocSector*(hint: INTEGER; VAR sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L318)

---
**GetSector** 

`  PROCEDURE GetSector*(src: INTEGER; VAR dst: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L332)

---
**PutSector** 

`  PROCEDURE PutSector*(dst: INTEGER; VAR src: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L342)


`  PROCEDURE Time*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L350)


`  PROCEDURE Clock*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L355)


`  PROCEDURE SetClock*(dt: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L359)


`  PROCEDURE Install*(Padr, at: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L363)


`  PROCEDURE Trap(VAR a: INTEGER; b: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L367)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L375)

