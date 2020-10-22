
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

`  PROCEDURE GetBlock(VAR p: LONGINT; len: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L43)


`  PROCEDURE GetBlock128(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L62)


`  PROCEDURE GetBlock64(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L71)


`  PROCEDURE GetBlock32(VAR p: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L80)


`   PROCEDURE New*(VAR ptr: LONGINT; tag: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L89)


`  PROCEDURE Mark*(pref: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L106)


`  PROCEDURE Scan*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L127)


`  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L157)


`  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L165)


`  PROCEDURE SPICmd(n, arg: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L171)


`  PROCEDURE SDShift(VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L183)


`  PROCEDURE ReadSD(src, dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L191)


`  PROCEDURE WriteSD(dst, src: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L205)


`  PROCEDURE InitSecMap*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L219)


`  PROCEDURE MarkSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L225)


`  PROCEDURE FreeSector*(sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L230)


`  PROCEDURE AllocSector*(hint: INTEGER; VAR sec: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L235)


`  PROCEDURE GetSector*(src: INTEGER; VAR dst: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L245)


`  PROCEDURE PutSector*(dst: INTEGER; VAR src: Sector);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L251)


`  PROCEDURE Time*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L259)


`  PROCEDURE Clock*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L264)


`  PROCEDURE SetClock*(dt: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L268)


`  PROCEDURE Install*(Padr, at: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L272)


`  PROCEDURE Trap(VAR a: INTEGER; b: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L276)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod#L284)

