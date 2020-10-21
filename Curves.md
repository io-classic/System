
## [MODULE Curves](https://github.com/io-core/Draw/blob/main/Curves.Mod)

  ## Imports:
` Display Files Oberon Graphics GraphicFrames`

```
## Types:
```

    Curve* = POINTER TO CurveDesc;

    CurveDesc* = RECORD (Graphics.ObjectDesc)
        kind*, lw*: INTEGER
      END ;

  (*kind: 0 = up-line, 1 = down-line, 2 = circle, 3 = ellipse*)

```
## Variables:
```
 method*: Graphics.Method;

```
## Procedures:
---

`  PROCEDURE Dot(f: GraphicFrames.Frame; col, x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L15)


`  PROCEDURE mark(f: GraphicFrames.Frame; col, x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L20)


`  PROCEDURE line(f: GraphicFrames.Frame; col: INTEGER; x, y, w, h, d: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L29)


`  PROCEDURE circle(f: GraphicFrames.Frame; col: INTEGER; x0, y0, r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L48)


`  PROCEDURE ellipse(f: GraphicFrames.Frame; col: INTEGER; x0, y0, a, b: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L65)


`  PROCEDURE New*;` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L90)


`  PROCEDURE Copy(src, dst: Graphics.Object);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L95)


`  PROCEDURE Draw(obj: Graphics.Object; VAR M: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L100)


`  PROCEDURE Selectable(obj: Graphics.Object; x, y: INTEGER): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L146)


`  PROCEDURE Change(obj: Graphics.Object; VAR M: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L160)


`  PROCEDURE Read(obj: Graphics.Object; VAR R: Files.Rider; VAR C: Graphics.Context);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L165)


`  PROCEDURE Write(obj: Graphics.Object; cno: INTEGER; VAR W: Files.Rider; VAR C: Graphics.Context);` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L171)


`  PROCEDURE MakeLine*;  (*command*)` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L176)


`  PROCEDURE MakeCircle*;  (*command*)` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L197)


`  PROCEDURE MakeEllipse*;  (*command*)` [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod#L215)

