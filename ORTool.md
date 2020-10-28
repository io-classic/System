
## [MODULE ORTool](https://github.com/io-core/Build/blob/main/ORTool.Mod)
Module ORTool provides symbol file, module file, and loaded module reporting tools.

ORP.Compile Target.Mod/s ~
ORTool.DecSym Target.smb ~ (if a regular module)
ORTool.DecObj Target.rsc ~ (if a regular module)
ORTool.DecBin Target.bin ~ (if a bare metal module)


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

`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L16)


`  PROCEDURE ReadType(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L22)


`  PROCEDURE DecSym*;  (*decode symbol file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L68)


`  PROCEDURE WriteReg(r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L109)


`  PROCEDURE opcode(w: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L119)


`  PROCEDURE Sync(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L154)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L159)


`  PROCEDURE DecBin*;   (*decode bare metal binary file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L163)


`  PROCEDURE DecObj*;   (*decode object file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L185)

