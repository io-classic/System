
## [MODULE GraphicFrames](https://github.com/io-core/Draw/blob/main/GraphicFrames.Mod)

  ## Imports:
` SYSTEM Display Viewers Input Fonts Texts Graphics Oberon MenuViewers`

## Constants:
```
 (*update message ids*)
    drawobj = 1; drawobjs = 2; drawobjd = 3;
    drawnorm = 4; drawsel = 5; drawdel = 6;

    markW = 5;

```
## Types:
```

    Frame* = POINTER TO FrameDesc;
    Location* = POINTER TO LocDesc;

    LocDesc* = RECORD
        x*, y*: INTEGER;
        next*: Location
      END ;

    FrameDesc* = RECORD (Display.FrameDesc)
        graph*: Graphics.Graph;
        Xg*, Yg*: INTEGER;  (*pos rel to graph origin*)
        X1*, Y1*: INTEGER;  (*right and upper margins*)
        x*, y*, col*: INTEGER;  (*x = X + Xg, y = Y + Yg*)
        marked*, ticked*: BOOLEAN;
        mark*: LocDesc
      END ;

    DrawMsg* = RECORD (Graphics.Msg)
        f*: Frame;
        x*, y*, col*, mode*: INTEGER
      END ;

    UpdateMsg = RECORD (Display.FrameMsg)
        id: INTEGER;
        graph: Graphics.Graph;
        obj: Graphics.Object
      END ;

    ChangedMsg = RECORD (Display.FrameMsg)
        f: Frame;
        graph: Graphics.Graph;
        mode: INTEGER
      END ;

    SelQuery = RECORD (Display.FrameMsg)
        f: Frame; time: LONGINT
      END ;

    FocusQuery = RECORD (Display.FrameMsg)
        f: Frame
      END ;

    PosQuery = RECORD (Display.FrameMsg)
        f: Frame; x, y: INTEGER
      END ;

    DispMsg = RECORD (Display.FrameMsg)
        x1, y1, w: INTEGER;
        pat: INTEGER;
        graph: Graphics.Graph
      END ;

```
## Variables:
```
 Crosshair*: Oberon.Marker;
    tack*, dotted*, dotted1*: INTEGER;  (*patterns*)
    newcap: Graphics.Caption;
    TBuf: Texts.Buffer;
    DW, DH, CL: INTEGER;
    W: Texts.Writer;

```
## Procedures:
---

`  PROCEDURE SetChangeMark(F: Frame; col: INTEGER); (*set mark in corner of frame*)` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L74)


`  PROCEDURE Restore*(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L83)


`  PROCEDURE FlipCross(X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L100)


`  PROCEDURE Focus*(): Frame;` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L111)


`  PROCEDURE Selected*(): Frame;` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L116)


`  PROCEDURE This*(x, y: INTEGER): Frame;` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L121)


`  PROCEDURE Mark(F: Frame; mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L126)


`  PROCEDURE Draw*(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L131)


`  PROCEDURE DrawNorm(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L136)


`  PROCEDURE Erase*(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L141)


`  PROCEDURE DrawObj*(F: Frame; obj: Graphics.Object);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L146)


`  PROCEDURE EraseObj*(F: Frame; obj: Graphics.Object);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L151)


`  PROCEDURE Change*(F: Frame; VAR msg: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L156)


`  PROCEDURE FlipMark(x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L161)


`  PROCEDURE Defocus*(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L167)


`  PROCEDURE Deselect*(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L177)


`  PROCEDURE Macro*(Lname, Mname: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L186)


`  PROCEDURE CaptionCopy(F: Frame;` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L209)


`  PROCEDURE NewLine(F: Frame; G: Graphics.Graph; x, y, w, h: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L230)


`  PROCEDURE Edit(F: Frame; x0, y0: INTEGER; k0: SET);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L237)


`  PROCEDURE NewCaption(F: Frame; col: INTEGER; font: Fonts.Font);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L322)


`  PROCEDURE InsertChar(F: Frame; ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L330)


`  PROCEDURE DeleteChar(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L340)


`  PROCEDURE GetSelection(F: Frame; VAR text: Texts.Text; VAR beg, end, time: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L355)


`  PROCEDURE Handle*(G: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L365)


`  PROCEDURE Store*(F: Frame; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L423)


`  PROCEDURE ReplConst*(F: Frame; col, x, y, w, h, mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L429)


`  PROCEDURE ReplPattern*(F: Frame; col, patadr, x, y, w, h, mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L438)


`  PROCEDURE DrawLine(obj: Graphics.Object; VAR M: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L447)


`  PROCEDURE DrawCaption(obj: Graphics.Object; VAR M: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L467)


`  PROCEDURE DrawMacro(obj: Graphics.Object; VAR M: Graphics.Msg);` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L496)


`  PROCEDURE Open*(G: Frame; graph: Graphics.Graph); ` [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod#L516)

