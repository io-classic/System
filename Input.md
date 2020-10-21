
## [MODULE Input](https://github.com/io-core/Oberon/blob/main/Input.Mod)

  ## Imports:
` SYSTEM`

## Constants:
```
 msAdr = -40; kbdAdr = -36;

```
## Types:
```


```
## Variables:
```
 kbdCode: BYTE; (*last keyboard code read*)
    Recd, Up, Shift, Ctrl, Ext: BOOLEAN;
    KTabAdr: INTEGER;  (*keyboard code translation table*)
    MW, MH, MX, MY: INTEGER; (*mouse limits and coords*)
    MK: SET; (*mouse keys*)

```
## Procedures:
---

`  PROCEDURE Peek();` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L18)


`  PROCEDURE Available*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L34)


`  PROCEDURE Read*(VAR ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L39)


`  PROCEDURE Mouse*(VAR keys: SET; VAR x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L49)


`  PROCEDURE SetMouseLimits*(w, h: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L58)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L62)

