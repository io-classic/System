
## [MODULE Modules](https://github.com/io-core/Modules/blob/main/Modules.Mod)

(Link and load on RISC; NW 20.10.2013 / 8.1.2019)

After the BootLoader loads the Inner Core (`Kernel`, `FileDir`, `Files`, `Modules`) into memory, the 
BEGIN section at the end of this module is the next code to execute. Modules, Files, Filedir, and Kernel
cooperate in initializing the state of the Oberon system.

Once the system is initialized, `Modules` dynamically loads the `Oberon` module which recursively requires `Input`, `Display`, `Viewers`, `Fonts`, and `Texts` to also be loaded.

The `Oberon` module in turn, at the end of its initialization, dynamically loads the `System` module which further requires `MenuViewers` and `TextFrames`.

At this point the Oberon system is responsive to user commands.


  ## Imports:
` SYSTEM Files`

## Constants:
```
 
    versionkey = 1X; 
    MT         = 12; 
    DescSize   = 80;

```
## Types:
```
 
    Module*     = POINTER TO ModDesc;
    Command*    = PROCEDURE;
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
---
**ThisFile** appends `.rsc` to the module name, opens it, and returns the file.

`  PROCEDURE ThisFile(name: ARRAY OF CHAR): Files.File;` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L65)

---
**error** places the error number and error name in global varaibles `res` and `importing` for later reference.

`  PROCEDURE error(n: INTEGER; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L78)

---
**Check** conditionally sets global variable `res` to 0 (valid) or 1 (invalid) when checking to see if the string is a valid name. 

`  PROCEDURE Check(s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L86)

---
**Load** recursively loads from disk into the module area of memory the imports of a module and then the module itself. 

`  PROCEDURE Load*(name: ARRAY OF CHAR; VAR newmod: Module);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L101)

---
**ThisCommand** finds and executes a parameterless procedure of module `mod` identified by the string `name`.

`  PROCEDURE ThisCommand*(mod: Module; name: ARRAY OF CHAR): Command;` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L248)

---
**Free** recursively removes modules imported by a module and the module itself from memory if no other loaded modules import it, or returns an error.

`  PROCEDURE Free*(name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L269)

---
**Init** calls `Files.Init`, sets the module table start and allocation pointer and module root and limit and makes room for the stack by decreasing the limit.

`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod#L286)

---
**The initialzation code for this module** calls `Init` and then dynamically loads the `Oberon` module and its imports. `Oberon` is not expected to return.
