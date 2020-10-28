
## [MODULE ORLinker](https://github.com/io-core/Build/blob/main/ORLinker.Mod)
    
(Link and create binary on RISC; NW 20.10.2013 CP 21.05.2014 / 28.10.2020)
    
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
## ---------- Utility Procedures
---
**ThisFile** returns a file handle for the compiled module.

`  PROCEDURE ThisFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L47)

---
**Zero** clears the contents of a string buffer.

`  PROCEDURE zero( VAR s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L60)

---
**ThisBinFile** returns a file handle for output of the linked or stripped binary.

`  PROCEDURE ThisBinFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L71)

---
**error** sets an error value.

`  PROCEDURE error(n: INTEGER; name: Modules.ModuleName);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L85)

---
**check** sets an error if a filename is invalid.

`  PROCEDURE Check(s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L93)

---
**ck** ??

`  PROCEDURE ck( i : INTEGER );` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L108)

---
**LinkOne** recursively assembles the just-loaded-state of a module and the modules it imports to an area of Oberon's module section.

`  PROCEDURE LinkOne*(name: ARRAY OF CHAR; VAR newmod: Modules.Module);` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L127)

## ---------- Commands
---
**Load** places a binary file in the boot sectors of the Oberon filesystem.

`  PROCEDURE Load*;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L291)

---
**Strip** writes a new file containing only the code section of a compiled module.

`  PROCEDURE Strip*;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L299)

---
**Link** writes a new file containing the just-loaded-state of a module and the modules it imports.

`  PROCEDURE Link*;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L355)

---
**ThisCommand** dispatches command procedures.

`  PROCEDURE ThisCommand*(mod: Modules.Module; name: ARRAY OF CHAR): Modules.Command;` [(source)](https://github.com/io-orig/System/blob/main/ORLinker.Mod#L424)

## ---------- Initialization
---
**The initialzation code for this module** opens a text writer for output.
