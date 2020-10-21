
## [MODULE ORTool](https://github.com/io-core/Build/blob/main/ORTool.Mod)

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

`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L7)


`  PROCEDURE ReadType(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L13)


`  PROCEDURE DecSym*;  (*decode symbol file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L59)


`  PROCEDURE WriteReg(r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L100)


`  PROCEDURE opcode(w: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L110)


`  PROCEDURE Sync(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L145)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L150)


`  PROCEDURE DecObj*;   (*decode object file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L154)

