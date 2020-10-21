
## [MODULE ORL](https://github.com/io-core/Build/blob/main/ORL.Mod)

  ## Imports:
` SYSTEM Kernel Files Modules Texts Oberon`

## Constants:
```
 versionkey = 1X; versionkey0 = 0X; DescSize = 96; MnLength = 32; BootSec = 2; FPrint = 12345678H;
    noerr* = 0; nofile* = 1; badversion* = 2; badkey* = 3; badfile* = 4; nospace* = 5;
    TrapAdr = 4; DestAdr = 8; MemAdr = 12; AllocAdr = 16; RootAdr = 20; StackAdr = 24; FPrintAdr = 28; ModAdr = 32;
    U = 20000000H; V = 10000000H; B = 100000H;  (*modifier bits*)
    MOV = 40000000H; IOR = 40060000H;  (*F1 register instructions*)
    F2 = -2;  (*F2 memory instruction*)
    F3 = -1; BCT = 0E7000000H; BLT = 0F7000000H;  (*F3 branch instructions*)
    C4 = 10H; C6 = 40H; C8 = 100H; C10 = 400H; C12 = 1000H; C14 = 4000H; C16 = 10000H; C18 = 40000H;
    C20 = 100000H; C22 = 400000H; C24 = 1000000H; C26 = 4000000H; C28 = 10000000H; C30 = 40000000H;

```
## Types:
```
  (*copied from Modules for use as cross linker/loader*)
    Module* = POINTER TO ModDesc;
    Command* = PROCEDURE;
    ModuleName* = ARRAY MnLength OF CHAR;
    ModDesc* = RECORD
      name*: ModuleName;
      next*: Module;
      key*, num*, size*, refcnt*: INTEGER;
      data*, str*, tdx*, code*, imp*, cmd*, ent*, ptr*, pvr*: INTEGER;  (*addresses*)
      selected*, marked, hidden, sel: BOOLEAN;
      smb*: INTEGER
    END ;

```
## Variables:
```
 root: Module;
    AllocPtr, Start, limit, res*: INTEGER;
    importing*, imported*: ModuleName;
    W: Texts.Writer;

```
## Procedures:
---

`  PROCEDURE MakeFileName(VAR FName: ARRAY OF CHAR; name, ext: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L38)


`  PROCEDURE ThisFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L46)


`  PROCEDURE ThisSmb(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L52)


`  PROCEDURE error(n: INTEGER; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L61)


`  PROCEDURE Check(s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L65)


`  PROCEDURE LinkOne(name: ARRAY OF CHAR; VAR newmod: Module);` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L76)


`  PROCEDURE Link*;  (*link multiple object files together and create a single boot file M.bin from them*)` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L254)


`  PROCEDURE Load*;  (*load prelinked boot file M.bin onto the boot area of the local disk*)` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L308)


`  PROCEDURE RelocateLoaded*(start, dst: INTEGER);  (*relocate prelinked binary loaded at Mem[start] for execution at dst*)` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L333)


`  PROCEDURE Relocate*;  (*relocate prelinked binary M.bin for execution at destadr and write result to output file R.bin*)` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L385)


`  PROCEDURE Execute*;  (*load and execute prelinked binary M.bin*)` [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod#L425)

