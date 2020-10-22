
## [MODULE TextFrames](https://github.com/io-core/Edit/blob/main/TextFrames.Mod)

  ## Imports:
` Modules Input Display Viewers Fonts Texts Oberon MenuViewers`

## Constants:
```
 replace* = 0; insert* = 1; delete* = 2; unmark* = 3; (*message id*)
    BS = 8X; TAB = 9X; CR = 0DX; DEL = 7FX;

```
## Types:
```
 Line = POINTER TO LineDesc;
    LineDesc = RECORD
      len: LONGINT;
      wid: INTEGER;
      eot: BOOLEAN;
      next: Line
    END;

    Location* = RECORD
      org*, pos*: LONGINT;
      dx*, x*, y*: INTEGER;
      lin: Line
    END;

    Frame* = POINTER TO FrameDesc;
    FrameDesc* = RECORD
      (Display.FrameDesc)
      text*: Texts.Text;
      org*: LONGINT;
      col*: INTEGER;
      lsp*: INTEGER;
      left*, right*, top*, bot*: INTEGER;
      markH*: INTEGER;
      time*: LONGINT;
      hasCar*, hasSel*, hasMark: BOOLEAN;
      carloc*: Location;
      selbeg*, selend*: Location;
      trailer: Line
    END;

    UpdateMsg* = RECORD (Display.FrameMsg)
      id*: INTEGER;
      text*: Texts.Text;
      beg*, end*: LONGINT
    END;

    CopyOverMsg = RECORD (Display.FrameMsg)
      text: Texts.Text;
      beg, end: LONGINT
    END;

```
## Variables:
```
 TBuf*, DelBuf: Texts.Buffer;
    menuH*, barW*, left*, right*, top*, bot*, lsp*: INTEGER; (*standard sizes*)
    asr, dsr, selH, markW, eolW: INTEGER;
    nextCh: CHAR;
    ScrollMarker: Oberon.Marker;
    W, KW: Texts.Writer; (*keyboard writer*)

```
## Procedures:
---

`  PROCEDURE Min (i, j: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L59)


`  PROCEDURE ReplConst (col: INTEGER; F: Frame; X, Y, W, H: INTEGER; mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L66)


`  PROCEDURE FlipSM(X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L73)


`  PROCEDURE UpdateMark (F: Frame);  (*in scroll bar*)` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L85)


`  PROCEDURE SetChangeMark (F: Frame; on: BOOLEAN);  (*in corner*)` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L94)


`  PROCEDURE Width (VAR R: Texts.Reader; len: LONGINT): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L103)


`  PROCEDURE DisplayLine (F: Frame; L: Line;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L113)


`  PROCEDURE Validate (T: Texts.Text; VAR pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L128)


`  PROCEDURE Mark* (F: Frame; on: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L139)


`  PROCEDURE Restore* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L147)


`  PROCEDURE Suspend* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L166)


`  PROCEDURE Extend* (F: Frame; newY: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L170)


`  PROCEDURE Reduce* (F: Frame; newY: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L194)


`  PROCEDURE Show* (F: Frame; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L209)


`  PROCEDURE LocateLine (F: Frame; y: INTEGER; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L252)


`  PROCEDURE LocateString (F: Frame; x, y: INTEGER; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L261)


`  PROCEDURE LocateChar (F: Frame; x, y: INTEGER; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L290)


`  PROCEDURE LocatePos (F: Frame; pos: LONGINT; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L310)


`  PROCEDURE Pos* (F: Frame; X, Y: INTEGER): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L325)


`  PROCEDURE FlipCaret (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L330)


`  PROCEDURE SetCaret* (F: Frame; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L337)


`  PROCEDURE TrackCaret* (F: Frame; X, Y: INTEGER; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L341)


`  PROCEDURE RemoveCaret* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L355)


`  PROCEDURE FlipSelection (F: Frame; VAR beg, end: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L359)


`  PROCEDURE SetSelection* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L374)


`  PROCEDURE TrackSelection* (F: Frame; X, Y: INTEGER; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L383)


`  PROCEDURE RemoveSelection* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L410)


`  PROCEDURE TrackLine* (F: Frame; X, Y: INTEGER; VAR org: LONGINT; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L414)


`  PROCEDURE TrackWord* (F: Frame; X, Y: INTEGER; VAR pos: LONGINT; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L437)


`  PROCEDURE Replace* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L460)


`  PROCEDURE Insert* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L486)


`  PROCEDURE Delete* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L536)


`  PROCEDURE Recall*(VAR B: Texts.Buffer);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L585)


`  PROCEDURE RemoveMarks (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L591)


`  PROCEDURE NotifyDisplay* (T: Texts.Text; op: INTEGER; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L595)


`  PROCEDURE Call* (F: Frame; pos: LONGINT; new: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L600)


`  PROCEDURE Write* (F: Frame; ch: CHAR; fnt: Fonts.Font; col, voff: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L621)


`  PROCEDURE Defocus* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L646)


`  PROCEDURE Neutralize* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L650)


`  PROCEDURE Modify* (F: Frame; id, dY, Y, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L654)


`  PROCEDURE Open* (F: Frame; H: Display.Handler; T: Texts.Text; org: LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L667)


`  PROCEDURE Copy* (F: Frame; VAR F1: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L677)


`  PROCEDURE CopyOver(F: Frame; text: Texts.Text; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L682)


`  PROCEDURE GetSelection* (F: Frame; VAR text: Texts.Text; VAR beg, end, time: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L692)


`  PROCEDURE Update* (F: Frame; VAR M: UpdateMsg);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L704)


`  PROCEDURE Edit* (F: Frame; X, Y: INTEGER; Keys: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L714)


`  PROCEDURE Handle* (F: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L798)


`  PROCEDURE Menu (name, commands: ARRAY OF CHAR): Texts.Text;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L824)


`  PROCEDURE Text* (name: ARRAY OF CHAR): Texts.Text;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L831)


`  PROCEDURE NewMenu* (name, commands: ARRAY OF CHAR): Frame;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L836)


`  PROCEDURE NewText* (text: Texts.Text; pos: LONGINT): Frame;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L842)

