
## [MODULE Blink](https://github.com/io-core/Extras/blob/main/Blink.Mod)
Module Edit provides document editing capability.


  ## Imports:
` SYSTEM Oberon`

```
```
## Variables:
```
 z: INTEGER;
    T: Oberon.Task;
  
  PROCEDURE Run*;
  BEGIN Oberon.Install(T)
  END Run;

```
## Procedures:
---

`  PROCEDURE Run*;` [(source)](https://github.com/io-orig/System/blob/main/Blink.Mod#L26)


`  PROCEDURE Stop*;` [(source)](https://github.com/io-orig/System/blob/main/Blink.Mod#L30)


`  PROCEDURE Tick;` [(source)](https://github.com/io-orig/System/blob/main/Blink.Mod#L34)

