
## [MODULE Rectangles](https://github.com/io-core/Draw/blob/main/Rectangles.Mod)

  ## Imports:
` SYSTEM Display Files Input Texts Oberon Graphics GraphicFrames`

```
## Types:
```

    Rectangle* = POINTER TO RectDesc;
    RectDesc* = RECORD (Graphics.ObjectDesc)
        lw*, vers*: INTEGER
      END ;

```
## Variables:
```
 method*: Graphics.Method;
    tack*, grey*: INTEGER;

```
## Procedures:
---

`  PROCEDURE New*;` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L13)


`  PROCEDURE Copy(src, dst: Graphics.Object);` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L18)


`  PROCEDURE mark(f: GraphicFrames.Frame; col, x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L23)


`  PROCEDURE Draw(obj: Graphics.Object; VAR M: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L27)


`    PROCEDURE draw(f: GraphicFrames.Frame; col, x, y, w, h, lw: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L30)


`  PROCEDURE Selectable(obj: Graphics.Object; x, y: INTEGER): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L55)


`  PROCEDURE Change(obj: Graphics.Object; VAR M: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L60)


`  PROCEDURE Read(obj: Graphics.Object; VAR R: Files.Rider; VAR C: Graphics.Context);` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L69)


`  PROCEDURE Write(obj: Graphics.Object; cno: INTEGER; VAR W: Files.Rider; VAR C: Graphics.Context);` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L76)


`  PROCEDURE Make*;  (*command*)` [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod#L92)

