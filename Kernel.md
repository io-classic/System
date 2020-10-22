
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
    
(* ---------- New: heap allocation ----------*)

```
## Procedures:
---

`  PROCEDURE GetBlock(VAR p: LONGINT; len: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L40)


`  PROCEDURE GetBlock128(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L59)


`  PROCEDURE GetBlock64(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L68)


`  PROCEDURE GetBlock32(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L77)


`   PROCEDURE New*(VAR ptr: LONGINT; tag: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L86)


`  PROCEDURE Mark*(pref: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L103)


`  PROCEDURE Scan*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L124)


`  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L154)


`  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L162)


`  PROCEDURE SPICmd(n, arg: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L168)


`  PROCEDURE SDShift(VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L180)


`  PROCEDURE ReadSD(src, dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L188)


`  PROCEDURE WriteSD(dst, src: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L202)


`  PROCEDURE InitSecMap*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L216)


`  PROCEDURE MarkSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L222)


`  PROCEDURE FreeSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L227)


`  PROCEDURE AllocSector*(hint: INTEGER; VAR sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L232)


`  PROCEDURE GetSector*(src: INTEGER; VAR dst: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L242)


`  PROCEDURE PutSector*(dst: INTEGER; VAR src: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L248)


`  PROCEDURE Time*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L256)


`  PROCEDURE Clock*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L261)


`  PROCEDURE SetClock*(dt: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L265)


`  PROCEDURE Install*(Padr, at: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L269)


`  PROCEDURE Trap(VAR a: INTEGER; b: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L273)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L281)

