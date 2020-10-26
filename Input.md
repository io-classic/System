
## [MODULE Input](https://github.com/io-core/Oberon/blob/main/Input.Mod)

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
  PROCEDURE Read*(VAR ch: CHAR);

`  PROCEDURE Read*(VAR ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L69)

  BEGIN
    WHILE ~Recd DO Peek() END ;
    IF Shift OR Ctrl THEN INC(kbdCode, 80H) END; (*ctrl implies shift*)
  (* ch := kbdTab[kbdCode]; *)
    SYSTEM.GET(KTabAdr + kbdCode, ch);
    IF Ctrl THEN ch := CHR(ORD(ch) MOD 20H) END;
    Recd := FALSE
  END Read;


  (* begin-section-description
## ---------- Mouse
## ---------- Mouse
  end-section-description *)

  (* begin-procedure-description
---  
**Mouse** provides the curent position and button state of the mouse.
  PROCEDURE Mouse*(VAR keys: SET; VAR x, y: INTEGER);

`  PROCEDURE Mouse*(VAR keys: SET; VAR x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L87)

    VAR w: INTEGER;
  BEGIN SYSTEM.GET(msAdr, w);
    keys := SYSTEM.VAL(SET, w DIV 1000000H MOD 8);
    x := w MOD 1000H; y := (w DIV 1000H) MOD 1000H;
    IF x >= MW THEN x := MW-1 END;
    IF y >= MH THEN y := MH-1 END
  END Mouse;

  (* begin-procedure-description
---  
**SetMouseLimits** restricts the mouse to the extent of the screen.
  PROCEDURE SetMouseLimits*(w, h: INTEGER);

`  PROCEDURE SetMouseLimits*(w, h: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L99)

  BEGIN MW := w; MH := h
  END SetMouseLimits;


  (* begin-section-description
## ---------- Initialization
## ---------- Initialization
  end-section-description *)

  (* begin-procedure-description
---
**Init** sets the keyboard initial state and populates the scancode to ascii table.

`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Input.Mod#L112)

