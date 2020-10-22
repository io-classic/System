
## [MODULE SCC](https://github.com/io-core/System/blob/main/SCC.Mod)

  ## Imports:
` SYSTEM Kernel`

## Constants:
```

    swi = -60; spiData = -48; spiCtrl = -44;
    netSelect = 1; spiFast = 2; netEnable = 3;
    HdrSize = 8; MaxPayload = 512; SubPacket = 32; Wait = 50; SendTries = 50;
    MaxPacket = (HdrSize + MaxPayload + SubPacket-1) DIV SubPacket *
SubPacket;

```
## Types:
```
 Header* =
    RECORD valid*: BOOLEAN;
      dadr*, sadr*, typ*: BYTE;
      len*: INTEGER (*of data following header*)
    END ;

```
## Variables:
```

    filter*: BOOLEAN; Adr*: BYTE; rcvd: INTEGER;
    rx: RECORD
      hd: Header;
      dat: ARRAY MaxPacket-HdrSize OF BYTE
    END;

```
## Procedures:
---

`  PROCEDURE SPICtrl(s: SET);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L28)


`  PROCEDURE SPI(n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L33)


`  PROCEDURE StartCmd(cmd: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L38)


`  PROCEDURE WriteReg1(reg, dat: INTEGER);  (*disables radio!*)` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L42)


`  PROCEDURE SubRcv(dst: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L46)


`  PROCEDURE SubSnd(src: INTEGER; VAR timeout: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L58)


`  PROCEDURE Flush();` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L87)


`  PROCEDURE ResetRcv;` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L92)


`  PROCEDURE Listen(b: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L96)


`  PROCEDURE Start*(filt: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L103)


`  PROCEDURE SendPacket*(VAR head: Header; dat: ARRAY OF BYTE);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L113)


`  PROCEDURE Available*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L136)


`  PROCEDURE Receive*(VAR x: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L141)


`  PROCEDURE Rcvd(time: INTEGER): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L146)


`  PROCEDURE ReceiveHead*(VAR head: Header);  (*actually, recv whole packet*)` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L157)


`  PROCEDURE Skip*(m: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L175)


`  PROCEDURE Stop*;` [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod#L180)

