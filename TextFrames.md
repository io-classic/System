
## [MODULE TextFrames](https://github.com/io-core/Edit/blob/main/TextFrames.Mod)

  ## Imports:
` Modules Input Display Viewers Fonts Texts Oberon MenuViewers`

## Constants:
```
 
    replace* = 0; insert* = 1; delete* = 2; unmark* = 3; (*message id*)
    BS = 8X; TAB = 9X; CR = 0DX; NL = 0AX; DEL = 7FX

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

`  PROCEDURE Min (i, j: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L60)


`  PROCEDURE ReplConst (col: INTEGER; F: Frame; X, Y, W, H: INTEGER; mode: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L67)


`  PROCEDURE FlipSM(X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L74)


`  PROCEDURE UpdateMark (F: Frame);  (*in scroll bar*)` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L86)


`  PROCEDURE SetChangeMark (F: Frame; on: BOOLEAN);  (*in corner*)` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L95)


`  PROCEDURE Width (VAR R: Texts.Reader; len: LONGINT): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L104)


`  PROCEDURE DisplayLine (F: Frame; L: Line;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L114)


`  PROCEDURE Validate (T: Texts.Text; VAR pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L129)


`  PROCEDURE Mark* (F: Frame; on: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L140)


`  PROCEDURE Restore* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L148)


`  PROCEDURE Suspend* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L167)


`  PROCEDURE Extend* (F: Frame; newY: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L171)


`  PROCEDURE Reduce* (F: Frame; newY: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L195)


`  PROCEDURE Show* (F: Frame; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L210)


`  PROCEDURE LocateLine (F: Frame; y: INTEGER; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L253)


`  PROCEDURE LocateString (F: Frame; x, y: INTEGER; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L262)


`  PROCEDURE LocateChar (F: Frame; x, y: INTEGER; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L291)


`  PROCEDURE LocatePos (F: Frame; pos: LONGINT; VAR loc: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L311)


`  PROCEDURE Pos* (F: Frame; X, Y: INTEGER): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L326)


`  PROCEDURE FlipCaret (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L331)


`  PROCEDURE SetCaret* (F: Frame; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L338)


`  PROCEDURE TrackCaret* (F: Frame; X, Y: INTEGER; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L342)


`  PROCEDURE RemoveCaret* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L356)


`  PROCEDURE FlipSelection (F: Frame; VAR beg, end: Location);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L360)


`  PROCEDURE SetSelection* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L375)


`  PROCEDURE TrackSelection* (F: Frame; X, Y: INTEGER; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L384)


`  PROCEDURE RemoveSelection* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L411)


`  PROCEDURE TrackLine* (F: Frame; X, Y: INTEGER; VAR org: LONGINT; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L415)


`  PROCEDURE TrackWord* (F: Frame; X, Y: INTEGER; VAR pos: LONGINT; VAR keysum: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L438)


`  PROCEDURE Replace* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L461)


`  PROCEDURE Insert* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L487)


`  PROCEDURE Delete* (F: Frame; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L537)


`  PROCEDURE Recall*(VAR B: Texts.Buffer);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L586)


`  PROCEDURE RemoveMarks (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L592)


`  PROCEDURE NotifyDisplay* (T: Texts.Text; op: INTEGER; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L596)


`  PROCEDURE Call* (F: Frame; pos: LONGINT; new: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L601)


`  PROCEDURE Write* (F: Frame; ch: CHAR; fnt: Fonts.Font; col, voff: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L622)


`  PROCEDURE Defocus* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L647)


`  PROCEDURE Neutralize* (F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L651)


`  PROCEDURE Modify* (F: Frame; id, dY, Y, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L655)


`  PROCEDURE Open* (F: Frame; H: Display.Handler; T: Texts.Text; org: LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L668)


`  PROCEDURE Copy* (F: Frame; VAR F1: Frame);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L678)


`  PROCEDURE CopyOver(F: Frame; text: Texts.Text; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L683)


`  PROCEDURE GetSelection* (F: Frame; VAR text: Texts.Text; VAR beg, end, time: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L693)


`  PROCEDURE Update* (F: Frame; VAR M: UpdateMsg);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L705)


`  PROCEDURE Edit* (F: Frame; X, Y: INTEGER; Keys: SET);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L715)


`  PROCEDURE Handle* (F: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L799)


`  PROCEDURE Menu (name, commands: ARRAY OF CHAR): Texts.Text;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L825)


`  PROCEDURE Text* (name: ARRAY OF CHAR): Texts.Text;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L832)


`  PROCEDURE NewMenu* (name, commands: ARRAY OF CHAR): Frame;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L837)


`  PROCEDURE NewText* (text: Texts.Text; pos: LONGINT): Frame;` [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod#L843)

