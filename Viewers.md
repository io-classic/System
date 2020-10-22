
## [MODULE Viewers](https://github.com/io-core/Oberon/blob/main/Viewers.Mod)

(JG 14.9.90 / NW 15.9.13 / AP 13.2.20 Extended Oberon)

**Viewers** introduces the core functionality for graphical interaction in Oberon.

Viewers operate on Frames, which are the arrangeable components of User interaction in Oberon.

Viewers coordinate via messages. Extensions of `Viewer` will extend `ViewerMsg` for corresponding functionaltiy.

Extensions of `Viewer` inherit the basic UI functionaltiy declared in this module, including the creation, expansion, closure, focus tracking, etc. of viewers.


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

`  PROCEDURE Open* (V: Viewer; X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L42)


`  PROCEDURE Change* (V: Viewer; Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L65)


`  PROCEDURE RestoreTrack (S: Display.Frame);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L79)


`  PROCEDURE Close* (V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L92)


`  PROCEDURE Recall* (VAR V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L114)


`  PROCEDURE This* (X, Y: INTEGER): Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L118)


`  PROCEDURE Next* (V: Viewer): Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L131)


`  PROCEDURE Locate* (X, H: INTEGER; VAR fil, bot, alt, max: Display.Frame);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L135)


`  PROCEDURE InitTrack* (W, H: INTEGER; Filler: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L158)


`  PROCEDURE OpenTrack* (X, W: INTEGER; Filler: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L173)


`  PROCEDURE CloseTrack* (X: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L193)


`  PROCEDURE Broadcast* (VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L207)

