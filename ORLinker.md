
## [MODULE ORLinker](https://github.com/io-core/Build/blob/main/ORLinker.Mod)
    
(Link and create binary on RISC; NW 20.10.2013 CP 21.05.2014)
    
**ORLinker** can generate and install a bootable inner core binary for the Oberon RISC5 architeture.
  

  ## Imports:
` SYSTEM Files Modules Kernel Texts Oberon`

## Constants:
```
 versionkey = 1X; MT = 12; DescSize = 80;

```
## Types:
```


```
## Variables:
```
 
    binroot, M: Modules.Module;
    binMTOrg, binStart, binAllocPtr, res*: INTEGER;
    importing*, imported*: Modules.ModuleName;
    limit: INTEGER;
    W: Texts.Writer;
    Mlist: ARRAY 16 OF Modules.ModuleName;
 

```
## Procedures:
---

`  PROCEDURE ThisFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L28)


`  PROCEDURE zero( VAR s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L37)


`  PROCEDURE ThisBinFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L44)


`  PROCEDURE error(n: INTEGER; name: Modules.ModuleName);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L54)


`  PROCEDURE Check(s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L58)


`  PROCEDURE ck( i : INTEGER );` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L69)


`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L84)


`  PROCEDURE LinkOne*(name: ARRAY OF CHAR; VAR newmod: Modules.Module);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L90)


`  PROCEDURE Load*;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L247)


`  PROCEDURE Strip*;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L251)


`  PROCEDURE Link*;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L303)


`  PROCEDURE ThisCommand*(mod: Modules.Module; name: ARRAY OF CHAR): Modules.Command;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L368)

