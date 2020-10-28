
## [MODULE Fonts](https://github.com/io-core/Edit/blob/main/Fonts.Mod)
Module Fonts provides the glyphs used by the Text system and the Graphics system to represent characters.


  ## Imports:
` SYSTEM Files`

## Constants:
```
 FontFileId = 0DBH;

```
## Types:
```
 Font* = POINTER TO FontDesc;
    FontDesc* = RECORD
      name*: ARRAY 32 OF CHAR;
      height*, minX*, maxX*, minY*, maxY*: INTEGER;
      next*: Font;
      T: ARRAY 128 OF INTEGER;
      raster: ARRAY 2360 OF BYTE
    END ;

    LargeFontDesc = RECORD (FontDesc) ext: ARRAY 2560 OF BYTE END ;
    LargeFont = POINTER TO LargeFontDesc;
    RunRec = RECORD beg, end: BYTE END ;
    BoxRec = RECORD dx, x, y, w, h: BYTE END ;
    
  (* raster sizes: Syntax8 1367, Syntax10 1628, Syntax12 1688, Syntax14 1843, Syntax14b 1983,
      Syntax16 2271, Syntax20 3034, Syntac24 4274, Syntax24b 4302  *)

```
## Variables:
```
 Default*, root*: Font;

```
## Procedures:
---

`PROCEDURE GetPat*(fnt: Font; ch: CHAR; VAR dx, x, y, w, h, patadr: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Fonts.Mod#L29)


`PROCEDURE This*(name: ARRAY OF CHAR): Font;` [(source)](https://github.com/io-orig/System/blob/main/Fonts.Mod#L37)


`  PROCEDURE RdInt16(VAR R: Files.Rider; VAR b0: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/Fonts.Mod#L49)


`PROCEDURE Free*;  (*remove all but first two from font list*)` [(source)](https://github.com/io-orig/System/blob/main/Fonts.Mod#L108)

