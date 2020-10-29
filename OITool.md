
## [MODULE OITool](https://github.com/io-core/Build/blob/main/OITool.Mod)
Module OITool provides symbol file, module file, and loaded module reporting tools for x86_64 binary modules.

OIP.Compile Target.Mod/s ~
OITool.DecSym Target.smb ~ (if a regular module)
OITool.DecObj Target.i64 ~ (if a regular module)
OITool.DecBin Target.bin ~ (if a bare metal module)


(NW 18.2.2013 / CP 2020)

**OITool** reports on and transforms the object files produced by the compiler's code generation module OIG.

Any change to OIG is likely to require a matching change in OITool.


  ## Imports:
` SYSTEM Files Modules Input Texts Viewers MenuViewers TextFrames Oberon ORB OIDis`

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

`  PROCEDURE OpenViewer(T: Texts.Text; title: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L26)


`  PROCEDURE Clear*;  (*used to clear output*)` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L35)


`  PROCEDURE Recall*;` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L40)


`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L48)


`  PROCEDURE ReadType(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L54)


`  PROCEDURE DecSym*;  (*decode symbol file*)` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L100)


`  PROCEDURE WriteReg(r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L141)


`  PROCEDURE opcode(w: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L151)


`  PROCEDURE Sync(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L189)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L194)


`  PROCEDURE DecBin*;   (*decode bare metal binary file*)` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L198)


`  PROCEDURE DecObj*;   (*decode object file*)` [(source)](https://github.com/io-orig/System/blob/main/OITool.Mod#L221)

