
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

`  PROCEDURE Code(VAR s: ARRAY OF CHAR): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L82)


`  PROCEDURE SetUser* (VAR user, password: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L94)


`  PROCEDURE Clock*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L98)


`  PROCEDURE SetClock* (d: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L102)


`  PROCEDURE Time*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L106)


`  PROCEDURE FlipArrow (X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L112)


`  PROCEDURE FlipStar (X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L123)


`  PROCEDURE OpenCursor(VAR c: Cursor);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L134)


`  PROCEDURE FadeCursor(VAR c: Cursor);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L138)


`  PROCEDURE DrawCursor(VAR c: Cursor; m: Marker; x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L142)


`  PROCEDURE DrawMouse*(m: Marker; x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L152)


`  PROCEDURE DrawMouseArrow*(x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L156)


`  PROCEDURE FadeMouse*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L160)


`  PROCEDURE DrawPointer*(x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L164)


`  PROCEDURE RemoveMarks* (X, Y, W, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L170)


`  PROCEDURE HandleFiller (V: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L180)


`  PROCEDURE OpenDisplay* (UW, SW, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L196)


`  PROCEDURE DisplayWidth* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L207)


`  PROCEDURE DisplayHeight* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L211)


`  PROCEDURE OpenTrack* (X, W: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L215)


`  PROCEDURE UserTrack* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L222)


`  PROCEDURE SystemTrack* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L226)


`  PROCEDURE UY (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L230)


`  PROCEDURE AllocateUserViewer* (DX: INTEGER; VAR X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L239)


`  PROCEDURE SY (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L246)


`  PROCEDURE AllocateSystemViewer* (DX: INTEGER; VAR X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L263)


`  PROCEDURE MarkedViewer* (): Viewers.Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L270)


`  PROCEDURE PassFocus* (V: Viewers.Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L274)


`  PROCEDURE OpenLog*(T: Texts.Text);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L279)


`  PROCEDURE SetPar*(F: Display.Frame; T: Texts.Text; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L284)


`  PROCEDURE Call* (name: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L288)


`  PROCEDURE GetSelection* (VAR text: Texts.Text; VAR beg, end, time: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L308)


`  PROCEDURE GC;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L315)


`  PROCEDURE NewTask*(h: Handler; period: INTEGER): Task;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L331)


`  PROCEDURE Install* (T: Task);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L336)


`  PROCEDURE Remove* (T: Task);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L343)


`  PROCEDURE Collect* (count: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L352)


`  PROCEDURE SetFont* (fnt: Fonts.Font);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L356)


`  PROCEDURE SetColor* (col: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L360)


`  PROCEDURE SetOffset* (voff: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L364)


`  PROCEDURE Loop*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L368)


`  PROCEDURE Reset*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L401)

