
## [MODULE Oberon](https://github.com/io-core/Oberon/blob/main/Oberon.Mod)

(JG 6.9.90 / 23.9.93 / 13.8.94 / NW 14.4.2013 / 22.12.2015)

The Oberon module coordiates the display area as a user-manipulatable workspace with tracks and panes.

The Oberon module transforms keystrokes and mouse movements and button presses into user interface messages 
delivered message handlers that are installed as the user initiates interactive content such as `Edit.Open` or
`System.Directory`.

The Oberon module provides the extensible UI functionality but the initial arrangement of content on system startup that the
user may interact with is provided by the System module.


  ## Imports:
` SYSTEM Kernel Files Modules Input Display Viewers Fonts Texts`

## Constants:
```
 
    consume* = 0; track* = 1; defocus* = 0; neutralize* = 1; mark* = 2; (*message ids*)
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
## ---------- User Identification
---
**Code** Encodes a password provided by the user.

`  PROCEDURE Code(VAR s: ARRAY OF CHAR): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L117)

---
**SetUser** sets the current user of the system. 

`  PROCEDURE SetUser* (VAR user, password: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L133)

---
**Clock** returns the current time.

`  PROCEDURE Clock*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L141)

---
**SetClock** sets the system time.

`  PROCEDURE SetClock* (d: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L149)

---
**Time** returns the current system timestamp.

`  PROCEDURE Time*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L157)

---
**FlipArrow** displays or removes the arrow at the x,y location on the screen.

`  PROCEDURE FlipArrow (X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L167)

---
**FlipStar** displays or removes the star at the x,y location on the screen.

`  PROCEDURE FlipStar (X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L182)

---
**OpenCursor** prepares a cursor initial state.

`  PROCEDURE OpenCursor(VAR c: Cursor);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L197)

---
**FadeCursor** removes a cursor from the screen.

`  PROCEDURE FadeCursor(VAR c: Cursor);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L205)

---
**DrawCursor** places a cursor on the screen at location x,y.

`  PROCEDURE DrawCursor(VAR c: Cursor; m: Marker; x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L213)

---
**DrawMouse** places the mouse cursor with marker m on the screen. 

`  PROCEDURE DrawMouse*(m: Marker; x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L227)

---
**DrawMouseArrow** places the mouse arrow on the screen. 

`  PROCEDURE DrawMouseArrow*(x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L235)

---
**FadeMouse** removes the mouse cursor from the screen.

`  PROCEDURE FadeMouse*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L243)

---
**DrawPointer** places the star marker on the screen.

`  PROCEDURE DrawPointer*(x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L251)

## ---------- Display Management
---
**RemoveMarks** remove the mouse cursor and the star marker from the screen.

`  PROCEDURE RemoveMarks* (X, Y, W, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L264)

---
**HandleFiller** fill the blank area of the display not delegated to other display frames.

`  PROCEDURE HandleFiller (V: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L278)

---
**OpenDisplay** Set the initial values for the display.

`  PROCEDURE OpenDisplay* (UW, SW, H: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L298)

---
**DisplayWidth** export the width of the display. 

`  PROCEDURE DisplayWidth* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L313)

---
**DisplayHeight** export the height of the display.

`  PROCEDURE DisplayHeight* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L321)

---
**OpenTrack** prepare a vertical slice of the display for holding viewers.

`  PROCEDURE OpenTrack* (X, W: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L329)

---
**UserTrack** returns the width of the user (left) track.

`  PROCEDURE UserTrack* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L340)

---
**SystemTrack** returns the width of the system (right) track.

`  PROCEDURE SystemTrack* (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L348)

---
**UY** locate a vertical position for a new user viewer.

`  PROCEDURE UY (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L356)

---
**AllocateUserViewer** allocate a new viewer on the user (left) track.

`  PROCEDURE AllocateUserViewer* (DX: INTEGER; VAR X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L369)

---
**SY** locate a vertical position for a new system viewer.

`  PROCEDURE SY (X: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L380)

---
**AllocateSystemViewer** allocate a new viewer on the system (right) track.

`  PROCEDURE AllocateSystemViewer* (DX: INTEGER; VAR X, Y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L401)

---
**MarkedViewer** returns the viewer with the mark.

`  PROCEDURE MarkedViewer* (): Viewers.Viewer;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L412)

---
**PassFocus** moves which viewer has the focus to the viewer `V`.

`  PROCEDURE PassFocus* (V: Viewers.Viewer);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L420)

---
**OpenLog** sets the Oberon log to the specified text.

`  PROCEDURE OpenLog*(T: Texts.Text);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L429)

## ---------- Command Interpretation
---
**SetPar** sets the parameter for an anticpated command invocation to the indicated viewer, frame, text, and position.

`  PROCEDURE SetPar*(F: Display.Frame; T: Texts.Text; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L443)

---
**Call** looks up and calls a command matching the `name` parameter.

`  PROCEDURE Call* (name: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L451)

---
**GetSelection** produces the user's selected text in VAR parameters.

`  PROCEDURE GetSelection* (VAR text: Texts.Text; VAR beg, end, time: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L475)

---
**GC** initiates garbage collection.

`  PROCEDURE GC;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L486)

---
**NewTask** prepares a task entry that calls a handler in the background.

`  PROCEDURE NewTask*(h: Handler; period: INTEGER): Task;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L506)

---
**Install** places the task entry in the list of tasks to process in the background.

`  PROCEDURE Install* (T: Task);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L515)

---
**Remove** takes the task entry out of the list of tasks to process in the background.

`  PROCEDURE Remove* (T: Task);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L526)

---
**Collect** ?? 

`  PROCEDURE Collect* (count: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L539)

---
**SetFont** changes the current font to be used when adding text.

`  PROCEDURE SetFont* (fnt: Fonts.Font);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L547)

---
**SetColor** changes the current color to be used when adding text.

`  PROCEDURE SetColor* (col: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L555)

---
**SetOffset**  ??

`  PROCEDURE SetOffset* (voff: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L563)

---
**Loop** is the central dispatch of input event messages in the Oberon UI and the background task dispatcher.

`  PROCEDURE Loop*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L571)

---
**Reset** resets the background tasks and the stack pointer. 

`  PROCEDURE Reset*;` [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod#L608)

---
**The initialzation code for this module** prepares the arrow, star, cursor behavior procedures, opens the display, sets GC as a background task, loads the System module then enters the UI loop.
