
## [MODULE Oberon](https://github.com/io-core/Oberon/blob/main/Oberon.Mod)

  ## Imports:
` SYSTEM Kernel Files Modules Input Display Viewers Fonts Texts`

## Constants:
```
 (*message ids*)
    consume* = 0; track* = 1; defocus* = 0; neutralize* = 1; mark* = 2;
    off = 0; idle = 1; active = 2;   (*task states*)
    BasicCycle = 20;
    ESC = 1BX; SETSTAR = 1AX;

```
## Types:
```
 Painter* = PROCEDURE (x, y: INTEGER);
    Marker* = RECORD Fade*, Draw*: Painter END;
    
    Cursor* = RECORD
        marker*: Marker; on*: BOOLEAN; X*, Y*: INTEGER
    END;

    InputMsg* = RECORD (Display.FrameMsg)
      id*: INTEGER;
      keys*: SET;
      X*, Y*: INTEGER;
      ch*: CHAR;
      fnt*: Fonts.Font;
      col*, voff*: INTEGER
    END;

    SelectionMsg* = RECORD (Display.FrameMsg)
      time*: LONGINT;
      text*: Texts.Text;
      beg*, end*: LONGINT
    END;

    ControlMsg* = RECORD (Display.FrameMsg)
      id*, X*, Y*: INTEGER
    END;

    CopyMsg* = RECORD (Display.FrameMsg)
      F*: Display.Frame
    END;

    Task* = POINTER TO TaskDesc;

    Handler* = PROCEDURE;

    TaskDesc* = RECORD
      state, nextTime, period*: INTEGER;
      next: Task;
      handle: Handler
    END;

```
## Variables:
```
 User*: ARRAY 8 OF CHAR; Password*: LONGINT;
    Arrow*, Star*: Marker;
    Mouse, Pointer: Cursor;
    FocusViewer*: Viewers.Viewer;
    Log*: Texts.Text;

```
## Procedures:
---

`  PROCEDURE Code(VAR s: ARRAY OF CHAR): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L81)


`  PROCEDURE SetUser* (VAR user, password: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L93)


`  PROCEDURE Clock*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L97)


`  PROCEDURE SetClock* (d: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L101)


`  PROCEDURE Time*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L105)


`  PROCEDURE FlipArrow (X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L111)


`  PROCEDURE FlipStar (X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L122)


`  PROCEDURE OpenCursor(VAR c: Cursor);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L133)


`  PROCEDURE FadeCursor(VAR c: Cursor);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L137)


`  PROCEDURE DrawCursor(VAR c: Cursor; m: Marker; x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L141)


`  PROCEDURE DrawMouse*(m: Marker; x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L151)


`  PROCEDURE DrawMouseArrow*(x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L155)


`  PROCEDURE FadeMouse*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L159)


`  PROCEDURE DrawPointer*(x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L163)


`  PROCEDURE RemoveMarks* (X, Y, W, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L169)


`  PROCEDURE HandleFiller (V: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L179)


`  PROCEDURE OpenDisplay* (UW, SW, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L195)


`  PROCEDURE DisplayWidth* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L206)


`  PROCEDURE DisplayHeight* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L210)


`  PROCEDURE OpenTrack* (X, W: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L214)


`  PROCEDURE UserTrack* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L221)


`  PROCEDURE SystemTrack* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L225)


`  PROCEDURE UY (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L229)


`  PROCEDURE AllocateUserViewer* (DX: INTEGER; VAR X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L238)


`  PROCEDURE SY (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L245)


`  PROCEDURE AllocateSystemViewer* (DX: INTEGER; VAR X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L262)


`  PROCEDURE MarkedViewer* (): Viewers.Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L269)


`  PROCEDURE PassFocus* (V: Viewers.Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L273)


`  PROCEDURE OpenLog*(T: Texts.Text);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L278)


`  PROCEDURE SetPar*(F: Display.Frame; T: Texts.Text; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L283)


`  PROCEDURE Call* (name: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L287)


`  PROCEDURE GetSelection* (VAR text: Texts.Text; VAR beg, end, time: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L307)


`  PROCEDURE GC;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L314)


`  PROCEDURE NewTask*(h: Handler; period: INTEGER): Task;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L330)


`  PROCEDURE Install* (T: Task);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L335)


`  PROCEDURE Remove* (T: Task);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L342)


`  PROCEDURE Collect* (count: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L351)


`  PROCEDURE SetFont* (fnt: Fonts.Font);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L355)


`  PROCEDURE SetColor* (col: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L359)


`  PROCEDURE SetOffset* (voff: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L363)


`  PROCEDURE Loop*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L367)


`  PROCEDURE Reset*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L400)

