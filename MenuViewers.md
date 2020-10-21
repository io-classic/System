
## [MODULE MenuViewers](https://github.com/io-core/Oberon/blob/main/MenuViewers.Mod)

  ## Imports:
` Input Display Viewers Oberon`

## Constants:
```
 extend* = 0; reduce* = 1; FrameColor = Display.white;

```
## Types:
```
 Viewer* = POINTER TO ViewerDesc;

    ViewerDesc* = RECORD (Viewers.ViewerDesc)
      menuH*: INTEGER
    END;

    ModifyMsg* = RECORD (Display.FrameMsg)
      id*: INTEGER;
      dY*, Y*, H*: INTEGER
    END;

  PROCEDURE Copy (V: Viewer; VAR V1: Viewer);
```
## Variables:
```
 Menu, Main: Display.Frame; M: Oberon.CopyMsg;
  BEGIN Menu := V.dsc; Main := V.dsc.next;
    NEW(V1); V1^ := V^; V1.state := 0;
    M.F := NIL; Menu.handle(Menu, M); V1.dsc := M.F;
    M.F := NIL; Main.handle(Main, M); V1.dsc.next := M.F
  END Copy;

```
## Procedures:
---

`  PROCEDURE Copy (V: Viewer; VAR V1: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L17)


`  PROCEDURE Draw (V: Viewers.Viewer);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L25)


`  PROCEDURE Extend (V: Viewer; newY: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L33)


`  PROCEDURE Reduce (V: Viewer; newY: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L44)


`  PROCEDURE Grow (V: Viewer; oldH: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L48)


`  PROCEDURE Shrink (V: Viewer; newH: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L58)


`  PROCEDURE Adjust (F: Display.Frame; id, dY, Y, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L62)


`  PROCEDURE Restore (V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L67)


`  PROCEDURE Modify (V: Viewer; Y, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L81)


`  PROCEDURE Change (V: Viewer; X, Y: INTEGER; Keys: SET);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L105)


`  PROCEDURE Suspend (V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L161)


`  PROCEDURE Handle* (V: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L168)


`  PROCEDURE New* (Menu, Main: Display.Frame; menuH, X, Y: INTEGER): Viewer; ` [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod#L201)

