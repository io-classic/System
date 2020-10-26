
## [MODULE Display](https://github.com/io-core/Oberon/blob/main/Display.Mod)

(NW 5.11.2013 / 17.1.2019 / PDW 21.1.2019)

**Display** is the interface to the hardware framebuffer in Oberon.

On initialization the origial base address is queried for a magic value to determine
if the base has moved and if the resolution is something other than 1024x768.

Only monochrome screens are implemented in this version of Display.Mod

A pattern is an array of bytes; the first is its width (< 32), the second its height, the rest the raster data.


  ## Imports:
` SYSTEM`

## Constants:
```
 
    black* = 0; white* = 1;  (*black = background*)
    replace* = 0; paint* = 1; invert* = 2;  (*modes*)
    (* base = 0E7F00H; *)  (*adr of 1024 x 768 pixel, monocolor display frame*)
    (* In the emulator, the frame buffer address might be moved depending on memory configuration *)

```
## Types:
```
 
    Frame* = POINTER TO FrameDesc;
    FrameMsg* = RECORD END ;
    Handler* = PROCEDURE (F: Frame; VAR M: FrameMsg);
    FrameDesc* = RECORD next*, dsc*: Frame;
        X*, Y*, W*, H*: INTEGER;
        handle*: Handler
      END ;

```
## Variables:
```
 
    Base*, Width*, Height*, Span: INTEGER;
    arrow*, star*, hook*, updown*, block*, cross*, grey*: INTEGER;
    (*a pattern is an array of bytes; the first is its width (< 32), the second its height, the rest the raster*)

```
## Procedures:
---
## ---------- General
---
**Handle** dispatches a handle message to the appropriate frame.

`  PROCEDURE Handle*(F: Frame; VAR M: FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Display.Mod#L54)

## ---------- Raster Ops
---
**Dot** modifies a pixel on the display.

`  PROCEDURE Dot*(col, x, y, mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Display.Mod#L69)

---
**ReplConst** paints a color into a rectangular area or inverts the area.

`  PROCEDURE ReplConst*(col, x, y, w, h, mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Display.Mod#L84)

---
**CopyPattern** copies a bitmap to a location in a color, possibly inverting the destination area.

`  PROCEDURE CopyPattern*(col, patadr, x, y, mode: INTEGER);  (*only for modes = paint, invert*)` [(source)](https://github.com/io-orig/System/blob/main/Display.Mod#L126)

---
**CopyBlock** copies a rectangular area to a location on the display.

`  PROCEDURE CopyBlock*(sx, sy, w, h, dx, dy, mode: INTEGER); (*only for mode = replace*)` [(source)](https://github.com/io-orig/System/blob/main/Display.Mod#L157)

---
**ReplPattern** replicates a pattern over a rectangular area of the display.

`  PROCEDURE ReplPattern*(col, patadr, x, y, w, h, mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Display.Mod#L217)

## ---------- Initialization
---
**InitResolution** determines the frame buffer base address and screen geometry.

`  PROCEDURE InitResolution;` [(source)](https://github.com/io-orig/System/blob/main/Display.Mod#L256)

---
**The initialzation code for this module** detects the screen origin and geometry and then installs icons for cursors and a background pattern.
