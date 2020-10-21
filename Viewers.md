
## [MODULE Viewers](https://github.com/io-core/Oberon/blob/main/Viewers.Mod)

  ## Imports:
` Display`

## Constants:
```
 restore* = 0; modify* = 1; suspend* = 2; (*message ids*)
    inf = 65535;

```
## Types:
```
 Viewer* = POINTER TO ViewerDesc;
    ViewerDesc* = RECORD (Display.FrameDesc) state*: INTEGER END;

    (*state > 1: displayed; state = 1: filler; state = 0: closed; state < 0: suspended*)

    ViewerMsg* = RECORD (Display.FrameMsg)
        id*: INTEGER;
        X*, Y*, W*, H*: INTEGER;
        state*: INTEGER
      END;

    Track = POINTER TO TrackDesc;
    TrackDesc = RECORD (ViewerDesc) under: Display.Frame END;

```
## Variables:
```
 curW*, minH*, DH: INTEGER;
    FillerTrack: Track; FillerViewer,
    backup: Viewer; (*last closed viewer*)

```
## Procedures:
---

`  PROCEDURE Open* (V: Viewer; X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L25)


`  PROCEDURE Change* (V: Viewer; Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L48)


`  PROCEDURE RestoreTrack (S: Display.Frame);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L62)


`  PROCEDURE Close* (V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L75)


`  PROCEDURE Recall* (VAR V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L97)


`  PROCEDURE This* (X, Y: INTEGER): Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L101)


`  PROCEDURE Next* (V: Viewer): Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L114)


`  PROCEDURE Locate* (X, H: INTEGER; VAR fil, bot, alt, max: Display.Frame);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L118)


`  PROCEDURE InitTrack* (W, H: INTEGER; Filler: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L141)


`  PROCEDURE OpenTrack* (X, W: INTEGER; Filler: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L156)


`  PROCEDURE CloseTrack* (X: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L176)


`  PROCEDURE Broadcast* (VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L190)

