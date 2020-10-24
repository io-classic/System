
## [MODULE Viewers](https://github.com/io-core/Oberon/blob/main/Viewers.Mod)

(JG 14.9.90 / NW 15.9.2013)

**Viewers** introduces the core functionality for graphical interaction in Oberon.

Tracks are vertical columns of display space and viewers are partitions of that vertical space. 

Different kinds of viewers import this module and extend its functionality in specialized 
ways, e.g. MenuViewers for simple one-line menus of commands and TextViewers for text areas 
that can scroll, be edited, receive copy and paste, etc.

This module concerns itself with operations on all tracks and viewers including opening, closing, moving, hiding and restoring them.

This module also introduces the messages understood by viewers and provides the mechanism for locating viewers and dispatching messages to viewers.

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
## ---------- Viewer Operations
---
**Open** opens a viewer.

`  PROCEDURE Open* (V: Viewer; X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L59)

---
**Change** adjusts the vertical position of the viewer.

`  PROCEDURE Change* (V: Viewer; Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L86)

---
**RestoreTrack** brings back a track that was obscured by an expanded viewer.

`  PROCEDURE RestoreTrack (S: Display.Frame);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L104)

---
**Close** removes a viewer from the track.

`  PROCEDURE Close* (V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L121)

---
**Recall** brings back a closed viewer.

`  PROCEDURE Recall* (VAR V: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L147)

---
**This** identifies the viewer containing the coordinates.

`  PROCEDURE This* (X, Y: INTEGER): Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L155)

---
**Next** returns the next viewer in the global viewer list.

`  PROCEDURE Next* (V: Viewer): Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L172)

---
**Locate** finds ??

`  PROCEDURE Locate* (X, H: INTEGER; VAR fil, bot, alt, max: Display.Frame);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L180)

---
**InitTrack** prepares a track to accept viewers.

`  PROCEDURE InitTrack* (W, H: INTEGER; Filler: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L207)

---
**OpenTrack** places the track on the screen.

`  PROCEDURE OpenTrack* (X, W: INTEGER; Filler: Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L226)

---
**CloseTrack** removes the track from the screen.

`  PROCEDURE CloseTrack* (X: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L250)

---
**Broadcast** sends a message to all frames.

`  PROCEDURE Broadcast* (VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod#L268)

---
**The initialzation code for this module** initializes empty tracks for use later by the System module and user programs.
