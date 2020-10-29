
## [MODULE ORTool](https://github.com/io-core/Build/blob/main/ORTool.Mod)
Module ORTool provides symbol file, module file, and loaded module reporting tools.

ORP.Compile Target.Mod/s ~
ORTool.DecSym Target.smb ~ (if a regular module)
ORTool.DecObj Target.rsc ~ (if a regular module)
ORTool.DecBin Target.bin ~ (if a bare metal module)


(NW 18.2.2013 / CP 2020)

**ORTool** reports on and transforms the object files produced by the compiler's code generation module ORG.

Any change to ORG is likely to require a matching change in ORTool.


  ## Imports:
` SYSTEM Files Modules Input Texts Viewers MenuViewers TextFrames Oberon ORB`

```
```
## Variables:
```
 
    T: Texts.Text; V: MenuViewers.Viewer; W: Texts.Writer;
    Form: INTEGER;  (*result of ReadType*)
    mnemo0, mnemo1: ARRAY 16, 4 OF CHAR;  (*mnemonics*)

```
## Procedures:
---

`  PROCEDURE OpenViewer(T: Texts.Text; title: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L26)


`  PROCEDURE Clear*;  (*used to clear output*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L35)


`  PROCEDURE Recall*;` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L40)


`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L48)


`  PROCEDURE ReadType(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L54)


`  PROCEDURE DecSym*;  (*decode symbol file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L100)


`  PROCEDURE WriteReg(r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L141)


`  PROCEDURE opcode(w: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L151)


`  PROCEDURE Sync(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L186)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L191)


`  PROCEDURE DecBin*;   (*decode bare metal binary file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L195)


`  PROCEDURE DecObj*;   (*decode object file*)` [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod#L218)

