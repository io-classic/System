
## [MODULE Input](https://github.com/io-core/Oberon/blob/main/Input.Mod)
Module Input reads keyboard and mouse raw data and returns ASCII values and mouse state to Oberon.


(NW 5.10.86 / 15.11.90 Ceres-2; PDR 21.4.12 / NW 15.5.2013 Ceres-4 / PDW 19.4.2016)

**Input** is the interface to the keyboard and mouse in Oberon.


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
## ---------- Keyboard
---
**Peek** checks to see if a key has been pressed or released.

`  PROCEDURE Peek();` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L40)

---
**Available** returns the available keypress.

`  PROCEDURE Available*(): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L61)

---  
**Read** delivers ascii values of pressed keys.

`  PROCEDURE Read*(VAR ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L70)

## ---------- Mouse
---  
**Mouse** provides the curent position and button state of the mouse.

`  PROCEDURE Mouse*(VAR keys: SET; VAR x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L89)

---  
**SetMouseLimits** restricts the mouse to the extent of the screen.

`  PROCEDURE SetMouseLimits*(w, h: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L102)

## ---------- Initialization
---
**Init** sets the keyboard initial state and populates the scancode to ascii table.

`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L115)

