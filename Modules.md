
## [MODULE Modules](https://github.com/io-core/Modules/blob/main/Modules.Mod)

  ## Imports:
` SYSTEM Files`

## Constants:
```
 versionkey = 1X; MT = 12; DescSize = 80;

```
## Types:
```
 Module* = POINTER TO ModDesc;
    Command* = PROCEDURE;
    ModuleName* = ARRAY 32 OF CHAR;

    ModDesc* = RECORD
        name*: ModuleName;
        next*: Module;
        key*, num*, size*, refcnt*: INTEGER;
        data*, code*, imp*, cmd*, ent*, ptr*, unused: INTEGER  (*addresses*)
      END ;

```
## Variables:
```
 root*, M: Module;
    MTOrg*, AllocPtr*, res*: INTEGER;
    importing*, imported*: ModuleName;
    limit: INTEGER;

```
## Procedures:
---

`  PROCEDURE ThisFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L30)


`  PROCEDURE error(n: INTEGER; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L39)


`  PROCEDURE Check(s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L43)


`  PROCEDURE Load*(name: ARRAY OF CHAR; VAR newmod: Module);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L54)


`  PROCEDURE ThisCommand*(mod: Module; name: ARRAY OF CHAR): Command;` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L197)


`  PROCEDURE Free*(name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L214)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L227)

