
## [MODULE ALinker](https://github.com/io-core/Build/blob/main/ALinker.Mod)
    
(Link and create binary on RISC; NW 20.10.2013 CP 21.05.2014 CP 2020)
    
**ALinker** can generate and install a bootable inner core binary for the Oberon aarch64 architeture.
  

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

`  PROCEDURE ThisFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L28)


`  PROCEDURE zero( VAR s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L37)


`  PROCEDURE ThisBinFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L44)


`  PROCEDURE error(n: INTEGER; name: Modules.ModuleName);` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L54)


`  PROCEDURE Check(s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L58)


`  PROCEDURE ck( i : INTEGER );` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L69)


`  PROCEDURE LinkOne*(name: ARRAY OF CHAR; VAR newmod: Modules.Module);` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L85)


`  PROCEDURE Load*;` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L242)


`  PROCEDURE Link*;` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L247)


`  PROCEDURE ThisCommand*(mod: Modules.Module; name: ARRAY OF CHAR): Modules.Command;` [(source)](https://github.com/io-orig/System/blob/main/ALinker.Mod#L312)

