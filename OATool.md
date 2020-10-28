
## [MODULE OATool](https://github.com/io-core/Build/blob/main/OATool.Mod)

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

`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L16)


`  PROCEDURE ReadType(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L22)


`  PROCEDURE DecSym*;  (*decode symbol file*)` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L68)


`  PROCEDURE WriteReg(r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L109)


`  PROCEDURE opcode(w: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L119)


`  PROCEDURE Sync(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L154)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L159)


`  PROCEDURE DecObj*;   (*decode object file*)` [(source)](https://github.com/io-orig/System/blob/main/OATool.Mod#L163)
