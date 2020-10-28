
## [MODULE OITool](https://github.com/io-core/Build/blob/main/OITool.Mod)

  ## Imports:
` SYSTEM Files Texts Oberon ORB`

```
```
## Variables:
```
 W: Texts.Writer;
    Form: INTEGER;  (*result of ReadType*)
    mnemo0, mnemo1: ARRAY 16, 4 OF CHAR;  (*mnemonics*)

```
## Procedures:
---

`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L15)


`  PROCEDURE ReadType(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L21)


`  PROCEDURE DecSym*;  (*decode symbol file*)` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L67)


`  PROCEDURE WriteReg(r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L108)


`  PROCEDURE opcode(w: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L118)


`  PROCEDURE Sync(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L153)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L158)


`  PROCEDURE DecObj*;   (*decode object file*)` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L162)

