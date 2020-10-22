# Packages

## Kernel
Package handles basic os functionality including device access and garbage collection.



#### [MODULE Kernel](https://github.com/io-orig/System/blob/main/Kernel.md) [(source)](https://github.com/io-orig/System/blob/main/Kernel.Mod)

  **imports:** ` SYSTEM`

**Procedures:**
```
  New*(VAR ptr: LONGINT; tag: LONGINT)

  Mark*(pref: LONGINT)

  Scan*

  InitSecMap*

  MarkSector*(sec: INTEGER)

  FreeSector*(sec: INTEGER)

  AllocSector*(hint: INTEGER; VAR sec: INTEGER)

  GetSector*(src: INTEGER; VAR dst: Sector)

  PutSector*(dst: INTEGER; VAR src: Sector)

  Time*(): INTEGER

  Clock*(): INTEGER

  SetClock*(dt: INTEGER)

  Install*(Padr, at: INTEGER)

  Init*

```
## Files
Package handles persistent storage and the file and directory interface of Oberon.



#### [MODULE FileDir](https://github.com/io-orig/System/blob/main/FileDir.md) [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod)

  **imports:** ` SYSTEM Kernel`

**Procedures:**
```
  Search*(name: FileName; VAR A: DiskAdr)

  Insert*(name: FileName; fad: DiskAdr)

  Delete*(name: FileName; VAR fad: DiskAdr)

  Enumerate*(prefix: ARRAY OF CHAR; proc: EntryHandler)

  Init*

```


#### [MODULE Files](https://github.com/io-orig/System/blob/main/Files.md) [(source)](https://github.com/io-orig/System/blob/main/Files.Mod)

  **imports:** ` SYSTEM Kernel FileDir`

**Procedures:**
```
  Old*(name: ARRAY OF CHAR): File

  New*(name: ARRAY OF CHAR): File

  Register*(f: File)

  Close*(f: File)

  Purge*(f: File)

  Delete*(name: ARRAY OF CHAR; VAR res: INTEGER)

  Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER)

  Length*(f: File): INTEGER

  Date*(f: File): INTEGER

  Set*(VAR r: Rider; f: File; pos: INTEGER)

  Pos*(VAR r: Rider): INTEGER

  Base*(VAR r: Rider): File

  ReadByte*(VAR r: Rider; VAR x: BYTE)

  ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER)

  Read*(VAR r: Rider; VAR ch: CHAR)

  ReadInt*(VAR R: Rider; VAR x: INTEGER)

  ReadSet*(VAR R: Rider; VAR s: SET)

  ReadReal*(VAR R: Rider; VAR x: REAL)

  ReadString*(VAR R: Rider; VAR x: ARRAY OF CHAR)

  ReadNum*(VAR R: Rider; VAR x: INTEGER)

  WriteByte*(VAR r: Rider; x: BYTE)

  WriteBytes*(VAR r: Rider; x: ARRAY OF BYTE; n: INTEGER)

  Write*(VAR r: Rider; ch: CHAR)

  WriteInt*(VAR R: Rider; x: INTEGER)

  WriteSet*(VAR R: Rider; s: SET)

  WriteReal*(VAR R: Rider; x: REAL)

  WriteString*(VAR R: Rider; x: ARRAY OF CHAR)

  WriteNum*(VAR R: Rider; x: INTEGER)

  Init*

  RestoreList* (*after mark phase of garbage collection*)

```
## Modules
Package manages compiled module loading and unloading in Oberon.



#### [MODULE Modules](https://github.com/io-orig/System/blob/main/Modules.md) [(source)](https://github.com/io-orig/System/blob/main/Modules.Mod)

  **imports:** ` SYSTEM Files`

**Procedures:**
```
  Load*(name: ARRAY OF CHAR; VAR newmod: Module)

  ThisCommand*(mod: Module; name: ARRAY OF CHAR): Command

  Free*(name: ARRAY OF CHAR)

  Init*

```
## Oberon
Package implements the user-interaction functionality and the task loop of the system.



#### [MODULE MenuViewers](https://github.com/io-orig/System/blob/main/MenuViewers.md) [(source)](https://github.com/io-orig/System/blob/main/MenuViewers.Mod)

  **imports:** ` Input Display Viewers Oberon`

**Procedures:**
```
  Handle* (V: Display.Frame; VAR M: Display.FrameMsg)

  New* (Menu, Main: Display.Frame; menuH, X, Y: INTEGER): Viewer 

```


#### [MODULE Oberon](https://github.com/io-orig/System/blob/main/Oberon.md) [(source)](https://github.com/io-orig/System/blob/main/Oberon.Mod)

  **imports:** ` SYSTEM Kernel Files Modules Input Display Viewers Fonts Texts`

**Procedures:**
```
  SetUser* (VAR user, password: ARRAY OF CHAR)

  Clock*(): LONGINT

  SetClock* (d: LONGINT)

  Time*(): LONGINT

  DrawMouse*(m: Marker; x, y: INTEGER)

  DrawMouseArrow*(x, y: INTEGER)

  FadeMouse*

  DrawPointer*(x, y: INTEGER)

  RemoveMarks* (X, Y, W, H: INTEGER)

  OpenDisplay* (UW, SW, H: INTEGER)

  DisplayWidth* (X: INTEGER): INTEGER

  DisplayHeight* (X: INTEGER): INTEGER

  OpenTrack* (X, W: INTEGER)

  UserTrack* (X: INTEGER): INTEGER

  SystemTrack* (X: INTEGER): INTEGER

  AllocateUserViewer* (DX: INTEGER; VAR X, Y: INTEGER)

  AllocateSystemViewer* (DX: INTEGER; VAR X, Y: INTEGER)

  MarkedViewer* (): Viewers.Viewer

  PassFocus* (V: Viewers.Viewer)

  OpenLog*(T: Texts.Text)

  SetPar*(F: Display.Frame; T: Texts.Text; pos: LONGINT)

  Call* (name: ARRAY OF CHAR; VAR res: INTEGER)

  GetSelection* (VAR text: Texts.Text; VAR beg, end, time: LONGINT)

  NewTask*(h: Handler; period: INTEGER): Task

  Install* (T: Task)

  Remove* (T: Task)

  Collect* (count: INTEGER)

  SetFont* (fnt: Fonts.Font)

  SetColor* (col: INTEGER)

  SetOffset* (voff: INTEGER)

  Loop*

  Reset*

```


#### [MODULE Input](https://github.com/io-orig/System/blob/main/Input.md) [(source)](https://github.com/io-orig/System/blob/main/Input.Mod)

  **imports:** ` SYSTEM`

**Procedures:**
```
  Available*(): INTEGER

  Read*(VAR ch: CHAR)

  Mouse*(VAR keys: SET; VAR x, y: INTEGER)

  SetMouseLimits*(w, h: INTEGER)

  Init*

```


#### [MODULE Display](https://github.com/io-orig/System/blob/main/Display.md) [(source)](https://github.com/io-orig/System/blob/main/Display.Mod)

  **imports:** ` SYSTEM`

**Procedures:**
```
  Handle*(F: Frame; VAR M: FrameMsg)

  Dot*(col, x, y, mode: INTEGER)

  ReplConst*(col, x, y, w, h, mode: INTEGER)

  CopyPattern*(col, patadr, x, y, mode: INTEGER)  (*only for modes = paint, invert*)

  CopyBlock*(sx, sy, w, h, dx, dy, mode: INTEGER) (*only for mode = replace*)

  ReplPattern*(col, patadr, x, y, w, h, mode: INTEGER)

```


#### [MODULE Viewers](https://github.com/io-orig/System/blob/main/Viewers.md) [(source)](https://github.com/io-orig/System/blob/main/Viewers.Mod)

  **imports:** ` Display`

**Procedures:**
```
  Open* (V: Viewer; X, Y: INTEGER)

  Change* (V: Viewer; Y: INTEGER)

  Close* (V: Viewer)

  Recall* (VAR V: Viewer)

  This* (X, Y: INTEGER): Viewer

  Next* (V: Viewer): Viewer

  Locate* (X, H: INTEGER; VAR fil, bot, alt, max: Display.Frame)

  InitTrack* (W, H: INTEGER; Filler: Viewer)

  OpenTrack* (X, W: INTEGER; Filler: Viewer)

  CloseTrack* (X: INTEGER)

  Broadcast* (VAR M: Display.FrameMsg)

```
## Edit
Package manages the text and font handling in Oberon.



#### [MODULE Edit](https://github.com/io-orig/System/blob/main/Edit.md) [(source)](https://github.com/io-orig/System/blob/main/Edit.Mod)

  **imports:** ` Files Fonts Texts Display Viewers Oberon MenuViewers TextFrames`

**Procedures:**
```
  Open*

  Store*

  CopyLooks*

  ChangeFont*

  ChangeColor*

  ChangeOffset*

  Search*  (*uses global variables M, pat, d for Boyer-Moore search*)

  Locate*

  Recall*

```


#### [MODULE Fonts](https://github.com/io-orig/System/blob/main/Fonts.md) [(source)](https://github.com/io-orig/System/blob/main/Fonts.Mod)

  **imports:** ` SYSTEM Files`

**Procedures:**
```
  GetPat*(fnt: Font; ch: CHAR; VAR dx, x, y, w, h, patadr: INTEGER)

  This*(name: ARRAY OF CHAR): Font

  Free*  (*remove all but first two from font list*)

```


#### [MODULE TextFrames](https://github.com/io-orig/System/blob/main/TextFrames.md) [(source)](https://github.com/io-orig/System/blob/main/TextFrames.Mod)

  **imports:** ` Modules Input Display Viewers Fonts Texts Oberon MenuViewers`

**Procedures:**
```
  Mark* (F: Frame; on: BOOLEAN)

  Restore* (F: Frame)

  Suspend* (F: Frame)

  Extend* (F: Frame; newY: INTEGER)

  Reduce* (F: Frame; newY: INTEGER)

  Show* (F: Frame; pos: LONGINT)

  Pos* (F: Frame; X, Y: INTEGER): LONGINT

  SetCaret* (F: Frame; pos: LONGINT)

  TrackCaret* (F: Frame; X, Y: INTEGER; VAR keysum: SET)

  RemoveCaret* (F: Frame)

  SetSelection* (F: Frame; beg, end: LONGINT)

  TrackSelection* (F: Frame; X, Y: INTEGER; VAR keysum: SET)

  RemoveSelection* (F: Frame)

  TrackLine* (F: Frame; X, Y: INTEGER; VAR org: LONGINT; VAR keysum: SET)

  TrackWord* (F: Frame; X, Y: INTEGER; VAR pos: LONGINT; VAR keysum: SET)

  Replace* (F: Frame; beg, end: LONGINT)

  Insert* (F: Frame; beg, end: LONGINT)

  Delete* (F: Frame; beg, end: LONGINT)

  Recall*(VAR B: Texts.Buffer)

  NotifyDisplay* (T: Texts.Text; op: INTEGER; beg, end: LONGINT)

  Call* (F: Frame; pos: LONGINT; new: BOOLEAN)

  Write* (F: Frame; ch: CHAR; fnt: Fonts.Font; col, voff: INTEGER)

  Defocus* (F: Frame)

  Neutralize* (F: Frame)

  Modify* (F: Frame; id, dY, Y, H: INTEGER)

  Open* (F: Frame; H: Display.Handler; T: Texts.Text; org: LONGINT

  Copy* (F: Frame; VAR F1: Frame)

  GetSelection* (F: Frame; VAR text: Texts.Text; VAR beg, end, time: LONGINT)

  Update* (F: Frame; VAR M: UpdateMsg)

  Edit* (F: Frame; X, Y: INTEGER; Keys: SET)

  Handle* (F: Display.Frame; VAR M: Display.FrameMsg)

  Text* (name: ARRAY OF CHAR): Texts.Text

  NewMenu* (name, commands: ARRAY OF CHAR): Frame

  NewText* (text: Texts.Text; pos: LONGINT): Frame

```


#### [MODULE Texts](https://github.com/io-orig/System/blob/main/Texts.md) [(source)](https://github.com/io-orig/System/blob/main/Texts.Mod)

  **imports:** ` Files Fonts`

**Procedures:**
```
  Load* (VAR R: Files.Rider; T: Text)

  Open* (T: Text; name: ARRAY OF CHAR)

  Store* (VAR W: Files.Rider; T: Text)

  Close*(T: Text; name: ARRAY OF CHAR)

  OpenBuf* (B: Buffer)

  Save* (T: Text; beg, end: LONGINT; B: Buffer)

  Copy* (SB, DB: Buffer)

  Insert* (T: Text; pos: LONGINT; B: Buffer)

  Append* (T: Text; B: Buffer)

  Delete* (T: Text; beg, end: LONGINT; B: Buffer)

  ChangeLooks* (T: Text; beg, end: LONGINT; sel: SET; fnt: Fonts.Font; col, voff: INTEGER)

  Attributes*(T: Text; pos: LONGINT; VAR fnt: Fonts.Font; VAR col, voff: INTEGER)

  OpenReader* (VAR R: Reader; T: Text; pos: LONGINT)

  Read* (VAR R: Reader; VAR ch: CHAR)

  Pos* (VAR R: Reader): LONGINT

  OpenScanner* (VAR S: Scanner; T: Text; pos: LONGINT)

  Scan* (VAR S: Scanner)

  OpenWriter* (VAR W: Writer)

  SetFont* (VAR W: Writer; fnt: Fonts.Font)

  SetColor* (VAR W: Writer; col: INTEGER)

  SetOffset* (VAR W: Writer; voff: INTEGER)

  Write* (VAR W: Writer; ch: CHAR)

  WriteLn* (VAR W: Writer)

  WriteString* (VAR W: Writer; s: ARRAY OF CHAR)

  WriteInt* (VAR W: Writer; x, n: LONGINT)

  WriteHex* (VAR W: Writer; x: LONGINT)

  WriteReal* (VAR W: Writer; x: REAL; n: INTEGER)

  WriteRealFix* (VAR W: Writer; x: REAL; n, k: INTEGER)

  WriteClock* (VAR W: Writer; d: LONGINT)

```
## Draw
Package provides line-oriented drawing primitives and a vector drawing tool.



#### [MODULE Graphics](https://github.com/io-orig/System/blob/main/Graphics.md) [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod)

  **imports:** ` SYSTEM Files Modules Fonts (*Printer*) Texts Oberon`

**Procedures:**
```
  New*(obj: Object)

  Add*(G: Graph; obj: Object)

  ThisObj*(G: Graph; x, y: INTEGER): Object

  SelectObj*(G: Graph; obj: Object)

  SelectArea*(G: Graph; x0, y0, x1, y1: INTEGER)

  Draw*(G: Graph; VAR M: Msg)

  List*(G: Graph)

  Deselect*(G: Graph)

  DrawSel*(G: Graph; VAR M: Msg)

  Change*(G: Graph; VAR M: Msg)

  Move*(G: Graph; dx, dy: INTEGER)

  Copy*(Gs, Gd: Graph; dx, dy: INTEGER)

  Delete*(G: Graph)

  FontNo*(VAR W: Files.Rider; VAR C: Context; fnt: Fonts.Font): INTEGER

  Store*(G: Graph; VAR W: Files.Rider)

  WriteObj*(VAR W: Files.Rider; cno: INTEGER; obj: Object)

  WriteFile*(G: Graph; name: ARRAY OF CHAR)

  Print*(G: Graph; x0, y0: INTEGER)

  GetClass*(module, allocator: ARRAY OF CHAR; VAR com: Modules.Command)

  Font*(VAR R: Files.Rider; VAR C: Context): Fonts.Font

  Load*(G: Graph; VAR R: Files.Rider)

  Open*(G: Graph; name: ARRAY OF CHAR)

  SetWidth*(w: INTEGER)

  GetLib*(name: ARRAY OF CHAR; replace: BOOLEAN; VAR Lib: Library)

  NewLib*(Lname: ARRAY OF CHAR): Library

  StoreLib*(L: Library; Fname: ARRAY OF CHAR)

  RemoveLibraries*

  ThisMac*(L: Library; Mname: ARRAY OF CHAR): MacHead

  DrawMac*(mh: MacHead; VAR M: Msg)

  OpenMac*(mh: MacHead; G: Graph; x, y: INTEGER)

  MakeMac*(G: Graph; VAR head: MacHead)

  InsertMac*(mh: MacHead; L: Library; VAR new: BOOLEAN)

  InstallDrawMethods*(drawLine, drawCaption, drawMacro: PROCEDURE (obj: Object; VAR msg: Msg))

```


#### [MODULE MacroTool](https://github.com/io-orig/System/blob/main/MacroTool.md) [(source)](https://github.com/io-orig/System/blob/main/MacroTool.Mod)

  **imports:** ` Texts Oberon Graphics GraphicFrames`

**Procedures:**
```
  OpenMacro*

  MakeMacro*  (*lib mac*)

  LoadLibrary*  (*lib file name*)

  StoreLibrary*  (*lib file name*)

```


#### [MODULE Draw](https://github.com/io-orig/System/blob/main/Draw.md) [(source)](https://github.com/io-orig/System/blob/main/Draw.Mod)

  **imports:** ` Files Fonts Viewers Texts Oberon
**Procedures:**
```
  Open*

  Delete*

  SetWidth*

  ChangeColor*

  ChangeWidth*

  ChangeFont*

  Ticks*

  Restore*

  Store*

  MacroTool.md

  MacroTool.Mod

```


#### [MODULE GraphicFrames](https://github.com/io-orig/System/blob/main/GraphicFrames.md) [(source)](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod)

  **imports:** ` SYSTEM Display Viewers Input Fonts Texts Graphics Oberon MenuViewers`

**Procedures:**
```
  Restore*(F: Frame)

  Focus*(): Frame

  Selected*(): Frame

  This*(x, y: INTEGER): Frame

  Draw*(F: Frame)

  Erase*(F: Frame)

  DrawObj*(F: Frame; obj: Graphics.Object)

  EraseObj*(F: Frame; obj: Graphics.Object)

  Change*(F: Frame; VAR msg: Graphics.Msg)

  Defocus*(F: Frame)

  Deselect*(F: Frame)

  Macro*(Lname, Mname: ARRAY OF CHAR)

  Handle*(G: Display.Frame; VAR M: Display.FrameMsg)

  Store*(F: Frame; name: ARRAY OF CHAR)

  ReplConst*(F: Frame; col, x, y, w, h, mode: INTEGER)

  ReplPattern*(F: Frame; col, patadr, x, y, w, h, mode: INTEGER)

  Open*(G: Frame; graph: Graphics.Graph) 

```


#### [MODULE GraphTool](https://github.com/io-orig/System/blob/main/GraphTool.md) [(source)](https://github.com/io-orig/System/blob/main/GraphTool.Mod)

  **imports:** ` Files Texts Oberon`

**Procedures:**
```
  DecGraph*

  DecGraph1*

  DecLibrary1*

  ConvertLibrary*

```


#### [MODULE Rectangles](https://github.com/io-orig/System/blob/main/Rectangles.md) [(source)](https://github.com/io-orig/System/blob/main/Rectangles.Mod)

  **imports:** ` SYSTEM Display Files Input Texts Oberon Graphics GraphicFrames`

**Procedures:**
```
  New*

  Make*  (*command*)

```


#### [MODULE Curves](https://github.com/io-orig/System/blob/main/Curves.md) [(source)](https://github.com/io-orig/System/blob/main/Curves.Mod)

  **imports:** ` Display Files Oberon Graphics GraphicFrames`

**Procedures:**
```
  New*

  MakeLine*  (*command*)

  MakeCircle*  (*command*)

  MakeEllipse*  (*command*)

```
## System
Package prepares the user interface and manages viewers for the user.



#### [MODULE Blink](https://github.com/io-orig/System/blob/main/Blink.md) [(source)](https://github.com/io-orig/System/blob/main/Blink.Mod)

  **imports:** ` SYSTEM Oberon`

**Procedures:**
```
  Run*

  Stop*

```


#### [MODULE Math](https://github.com/io-orig/System/blob/main/Math.md) [(source)](https://github.com/io-orig/System/blob/main/Math.Mod)

**Procedures:**
```
  sqrt*(x: REAL): REAL

  exp*(x: REAL): REAL

  ln*(x: REAL): REAL

  sin*(x: REAL): REAL

  cos*(x: REAL): REAL

```


#### [MODULE RISC](https://github.com/io-orig/System/blob/main/RISC.md) [(source)](https://github.com/io-orig/System/blob/main/RISC.Mod)

  **imports:** ` SYSTEM Texts Oberon`

**Procedures:**
```
  Execute*(VAR M: ARRAY OF LONGINT; pc: LONGINT

```


#### [MODULE PIO](https://github.com/io-orig/System/blob/main/PIO.md) [(source)](https://github.com/io-orig/System/blob/main/PIO.Mod)

  **imports:** ` SYSTEM`

**Procedures:**
```
  Send*(x: LONGINT)

  Receive*(VAR x: LONGINT)

  Reset*

```


#### [MODULE BootLoad](https://github.com/io-orig/System/blob/main/BootLoad.md) [(source)](https://github.com/io-orig/System/blob/main/BootLoad.Mod)

  **imports:** ` SYSTEM`

**Procedures:**
```
```


#### [MODULE System](https://github.com/io-orig/System/blob/main/System.md) [(source)](https://github.com/io-orig/System/blob/main/System.Mod)

  **imports:** ` SYSTEM Kernel FileDir Files Modules
**Procedures:**
```
  SetUser*

  SetFont*

  SetColor*

  SetOffset*

  Date*

  Collect*

  Open*  (*open viewer in system track*)

  Clear*  (*clear Log*)

  Close*

  CloseTrack*

  Recall*

  Copy*

  Grow*

  Free*

  FreeFonts*

  Directory*

  CopyFiles*

  RenameFiles*

  DeleteFiles*

  Watch*

  ShowModules*

  ShowCommands*

  ShowFonts*

  ExtendDisplay*

```


#### [MODULE Tools](https://github.com/io-orig/System/blob/main/Tools.md) [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod)

  **imports:** ` SYSTEM Kernel Files Modules Input Texts Viewers MenuViewers TextFrames Oberon`

**Procedures:**
```
  Clear*  (*used to clear output*)

  Recall*

  Inspect*

  Sector*

  ShowFile*

  Convert*   (*convert selected text to txt-format*)

  Id*

```


#### [MODULE PCLink1](https://github.com/io-orig/System/blob/main/PCLink1.md) [(source)](https://github.com/io-orig/System/blob/main/PCLink1.Mod)

  **imports:** ` SYSTEM Files Texts Oberon`

**Procedures:**
```
  Run*

  Stop*

```


#### [MODULE RS232](https://github.com/io-orig/System/blob/main/RS232.md) [(source)](https://github.com/io-orig/System/blob/main/RS232.Mod)

  **imports:** ` SYSTEM`

**Procedures:**
```
  Send*(x: INTEGER)

  Rec*(VAR x: INTEGER)

  SendInt*(x: INTEGER)

  SendHex*(x: INTEGER)

  SendReal*(x: REAL)

  SendStr*(x: ARRAY OF CHAR)

  RecInt*(VAR x: INTEGER)

  RecReal*(VAR x: REAL)

  RecStr*(VAR x: ARRAY OF CHAR)

  Line*

  End*

```


#### [MODULE Net](https://github.com/io-orig/System/blob/main/Net.md) [(source)](https://github.com/io-orig/System/blob/main/Net.Mod)

  **imports:** ` SYSTEM SCC Files Viewers Texts TextFrames MenuViewers Oberon`

**Procedures:**
```
  SendFiles*

  ReceiveFiles*

  SendMsg*

  GetTime*

  StartServer*

  Unprotect*

  WProtect*

  Reset*

  StopServer*

  SCCStatus*

```


#### [MODULE SCC](https://github.com/io-orig/System/blob/main/SCC.md) [(source)](https://github.com/io-orig/System/blob/main/SCC.Mod)

  **imports:** ` SYSTEM Kernel`

**Procedures:**
```
  Start*(filt: BOOLEAN)

  SendPacket*(VAR head: Header; dat: ARRAY OF BYTE)

  Available*(): INTEGER

  Receive*(VAR x: BYTE)

  ReceiveHead*(VAR head: Header)  (*actually, recv whole packet*)

  Skip*(m: INTEGER)

  Stop*

```


#### [MODULE Batch](https://github.com/io-orig/System/blob/main/Batch.md) [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod)
Module Batch provides for automatic sequential execution of Oberon commands.


  **imports:** ` Kernel FileDir Files Display Texts TextFrames Viewers Oberon`

**Procedures:**
```
  ClearLog*

  WriteLog*

  VerifyLog*

  DeleteFiles*

  Collect*

  Run*

```
## Build
Package provides the compiler and associated program building and debugging tools for Oberon.



#### [MODULE ORTool](https://github.com/io-orig/System/blob/main/ORTool.md) [(source)](https://github.com/io-orig/System/blob/main/ORTool.Mod)

  **imports:** ` SYSTEM Files Texts Oberon ORB`

**Procedures:**
```
  DecSym*  (*decode symbol file*)

  DecObj*   (*decode object file*)

```


#### [MODULE ORB](https://github.com/io-orig/System/blob/main/ORB.md) [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod)

  **imports:** ` Files ORS`

**Procedures:**
```
  NewObj*(VAR obj: Object; id: ORS.Ident; class: INTEGER)  (*insert new Object with name id*)

  thisObj*(): Object

  thisimport*(mod: Object): Object

  thisfield*(rec: Type): Object

  OpenScope*

  CloseScope*

  MakeFileName*(VAR FName: ORS.Ident; name, ext: ARRAY OF CHAR)

  Import*(VAR modid, modid1: ORS.Ident)

  Export*(VAR modid: ORS.Ident; VAR newSF: BOOLEAN; VAR key: LONGINT)

  Init*

```


#### [MODULE ORC](https://github.com/io-orig/System/blob/main/ORC.md) [(source)](https://github.com/io-orig/System/blob/main/ORC.Mod)

  **imports:** ` SYSTEM Files Texts Oberon V24`

**Procedures:**
```
  Flush*

  Open*

  TestReq*

  Load*  (*linked boot file  F.bin*)

  Send*

  Receive*

  Close*

  SR*  (*send, then receive sequence of items*)

```


#### [MODULE ORG](https://github.com/io-orig/System/blob/main/ORG.md) [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod)

  **imports:** ` SYSTEM Files ORS ORB`

**Procedures:**
```
  CheckRegs*

  FixOne*(at: LONGINT)

  FixLink*(L: LONGINT)

  MakeConstItem*(VAR x: Item; typ: ORB.Type; val: LONGINT)

  MakeRealItem*(VAR x: Item; val: REAL)

  MakeStringItem*(VAR x: Item; len: LONGINT) (*copies string from ORS-buffer to ORG-string array*)

  MakeItem*(VAR x: Item; y: ORB.Object; curlev: LONGINT)

  Field*(VAR x: Item; y: ORB.Object)   (* x := x.y *)

  Index*(VAR x, y: Item)   (* x := x[y] *)

  DeRef*(VAR x: Item)

  BuildTD*(T: ORB.Type; VAR dc: LONGINT)

  TypeTest*(VAR x: Item; T: ORB.Type; varpar, isguard: BOOLEAN)

  Not*(VAR x: Item)   (* x :=  x *)

  And1*(VAR x: Item)   (* x := x & *)

  And2*(VAR x, y: Item)

  Or1*(VAR x: Item)   (* x := x OR *)

  Or2*(VAR x, y: Item)

  Neg*(VAR x: Item)   (* x := -x *)

  AddOp*(op: LONGINT; VAR x, y: Item)   (* x := x +- y *)

  MulOp*(VAR x, y: Item)   (* x := x * y *)

  DivOp*(op: LONGINT; VAR x, y: Item)   (* x := x op y *)

  RealOp*(op: INTEGER; VAR x, y: Item)   (* x := x op y *)

  Singleton*(VAR x: Item)  (* x := {x} *)

  Set*(VAR x, y: Item)   (* x := {x .. y} *)

  In*(VAR x, y: Item)  (* x := x IN y *)

  SetOp*(op: LONGINT; VAR x, y: Item)   (* x := x op y *)

  IntRelation*(op: INTEGER; VAR x, y: Item)   (* x := x < y *)

  RealRelation*(op: INTEGER; VAR x, y: Item)   (* x := x < y *)

  StringRelation*(op: INTEGER; VAR x, y: Item)   (* x := x < y *)

  StrToChar*(VAR x: Item)

  Store*(VAR x, y: Item) (* x := y *)

  StoreStruct*(VAR x, y: Item) (* x := y, frame = 0 *)

  CopyString*(VAR x, y: Item)  (* x := y *) 

  OpenArrayParam*(VAR x: Item)

  VarParam*(VAR x: Item; ftype: ORB.Type)

  ValueParam*(VAR x: Item)

  StringParam*(VAR x: Item)

  For0*(VAR x, y: Item)

  For1*(VAR x, y, z, w: Item; VAR L: LONGINT)

  For2*(VAR x, y, w: Item)

  Here*(): LONGINT

  FJump*(VAR L: LONGINT)

  CFJump*(VAR x: Item)

  BJump*(L: LONGINT)

  CBJump*(VAR x: Item; L: LONGINT)

  Fixup*(VAR x: Item)

  PrepCall*(VAR x: Item; VAR r: LONGINT)

  Call*(VAR x: Item; r: LONGINT)

  Enter*(parblksize, locblksize: LONGINT; int: BOOLEAN)

  Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN)

  Increment*(upordown: LONGINT; VAR x, y: Item)

  Include*(inorex: LONGINT; VAR x, y: Item)

  Assert*(VAR x: Item)

  New*(VAR x: Item)

  Pack*(VAR x, y: Item)

  Unpk*(VAR x, y: Item)

  Led*(VAR x: Item)

  Get*(VAR x, y: Item)

  Put*(VAR x, y: Item)

  Copy*(VAR x, y, z: Item)

  LDPSR*(VAR x: Item)

  LDREG*(VAR x, y: Item)

  Abs*(VAR x: Item)

  Odd*(VAR x: Item)

  Floor*(VAR x: Item)

  Float*(VAR x: Item)

  Ord*(VAR x: Item)

  Len*(VAR x: Item)

  Shift*(fct: LONGINT; VAR x, y: Item)

  ADC*(VAR x, y: Item)

  SBC*(VAR x, y: Item)

  UML*(VAR x, y: Item)

  Bit*(VAR x, y: Item)

  Register*(VAR x: Item)

  H*(VAR x: Item)

  Adr*(VAR x: Item)

  Condition*(VAR x: Item)

  Open*(v: INTEGER)

  SetDataSize*(dc: LONGINT)

  Header*

  Close*(VAR modid: ORS.Ident; key, nofent: LONGINT)

```


#### [MODULE ORP](https://github.com/io-orig/System/blob/main/ORP.md) [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod)

  **imports:** ` Texts Oberon ORS ORB ORG`

**Procedures:**
```
  Compile*

```


#### [MODULE ORS](https://github.com/io-orig/System/blob/main/ORS.md) [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod)

  **imports:** ` SYSTEM Texts Oberon`

**Procedures:**
```
  CopyId*(VAR ident: Ident)

  Pos*(): LONGINT

  Mark*(msg: ARRAY OF CHAR)

  Get*(VAR sym: INTEGER)

  Init*(T: Texts.Text; pos: LONGINT)

```


#### [MODULE ODP](https://github.com/io-orig/System/blob/main/ODP.md) [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod)

  **imports:** ` Texts Oberon ORS ORB ODG`

**Procedures:**
```
  Generate*

```


#### [MODULE ODG](https://github.com/io-orig/System/blob/main/ODG.md) [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod)

  **imports:** ` SYSTEM Files ORS ORB`

**Procedures:**
```
  CheckRegs*

  FixOne*(at: LONGINT)

  FixLink*(L: LONGINT)

  MakeConstItem*(VAR x: Item; typ: ORB.Type; val: LONGINT)

  MakeRealItem*(VAR x: Item; val: REAL)

  MakeStringItem*(VAR x: Item; len: LONGINT) (*copies string from ORS-buffer to ORG-string array*)

  MakeItem*(VAR x: Item; y: ORB.Object; curlev: LONGINT)

  Field*(VAR x: Item; y: ORB.Object)   (* x := x.y *)

  Index*(VAR x, y: Item)   (* x := x[y] *)

  DeRef*(VAR x: Item)

  BuildTD*(T: ORB.Type; VAR dc: LONGINT)

  TypeTest*(VAR x: Item; T: ORB.Type; varpar, isguard: BOOLEAN)

  Not*(VAR x: Item)   (* x :=  x *)

  And1*(VAR x: Item)   (* x := x & *)

  And2*(VAR x, y: Item)

  Or1*(VAR x: Item)   (* x := x OR *)

  Or2*(VAR x, y: Item)

  Neg*(VAR x: Item)   (* x := -x *)

  AddOp*(op: LONGINT; VAR x, y: Item)   (* x := x +- y *)

  MulOp*(VAR x, y: Item)   (* x := x * y *)

  DivOp*(op: LONGINT; VAR x, y: Item)   (* x := x op y *)

  RealOp*(op: INTEGER; VAR x, y: Item)   (* x := x op y *)

  Singleton*(VAR x: Item)  (* x := {x} *)

  Set*(VAR x, y: Item)   (* x := {x .. y} *)

  In*(VAR x, y: Item)  (* x := x IN y *)

  SetOp*(op: LONGINT; VAR x, y: Item)   (* x := x op y *)

  IntRelation*(op: INTEGER; VAR x, y: Item)   (* x := x < y *)

  RealRelation*(op: INTEGER; VAR x, y: Item)   (* x := x < y *)

  StringRelation*(op: INTEGER; VAR x, y: Item)   (* x := x < y *)

  StrToChar*(VAR x: Item)

  Store*(VAR x, y: Item) (* x := y *)

  StoreStruct*(VAR x, y: Item) (* x := y, frame = 0 *)

  CopyString*(VAR x, y: Item)  (* x := y *) 

  OpenArrayParam*(VAR x: Item)

  VarParam*(VAR x: Item; ftype: ORB.Type)

  ValueParam*(VAR x: Item)

  StringParam*(VAR x: Item)

  For0*(VAR x, y: Item)

  For1*(VAR x, y, z, w: Item; VAR L: LONGINT)

  For2*(VAR x, y, w: Item)

  Here*(): LONGINT

  FJump*(VAR L: LONGINT)

  CFJump*(VAR x: Item)

  BJump*(L: LONGINT)

  CBJump*(VAR x: Item; L: LONGINT)

  Fixup*(VAR x: Item)

  PrepCall*(VAR x: Item; VAR r: LONGINT)

  Call*(VAR x: Item; r: LONGINT)

  Enter*(parblksize, locblksize: LONGINT; int: BOOLEAN)

  Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN)

  Increment*(upordown: LONGINT; VAR x, y: Item)

  Include*(inorex: LONGINT; VAR x, y: Item)

  Assert*(VAR x: Item)

  New*(VAR x: Item)

  Pack*(VAR x, y: Item)

  Unpk*(VAR x, y: Item)

  Led*(VAR x: Item)

  Get*(VAR x, y: Item)

  Put*(VAR x, y: Item)

  Copy*(VAR x, y, z: Item)

  LDPSR*(VAR x: Item)

  LDREG*(VAR x, y: Item)

  Abs*(VAR x: Item)

  Odd*(VAR x: Item)

  Floor*(VAR x: Item)

  Float*(VAR x: Item)

  Ord*(VAR x: Item)

  Len*(VAR x: Item)

  Shift*(fct: LONGINT; VAR x, y: Item)

  ADC*(VAR x, y: Item)

  SBC*(VAR x, y: Item)

  UML*(VAR x, y: Item)

  Bit*(VAR x, y: Item)

  Register*(VAR x: Item)

  H*(VAR x: Item)

  Adr*(VAR x: Item)

  Condition*(VAR x: Item)

  Open*(v: INTEGER)

  SetDataSize*(dc: LONGINT)

  Header*

  Close*(VAR modid: ORS.Ident; key, nofent: LONGINT)

```


#### [MODULE ORL](https://github.com/io-orig/System/blob/main/ORL.md) [(source)](https://github.com/io-orig/System/blob/main/ORL.Mod)
Module ORL links modules to create bin files that may be placed in the boot sectors of an Oberon disk image

ORL uses SYSTEM, Kernel, Files, Modules, Texts, Oberon



  **imports:** ` SYSTEM Kernel Files Modules Texts Oberon`

**Procedures:**
```
  Link*  (*link multiple object files together and create a single boot file M.bin from them*)

  Load*  (*load prelinked boot file M.bin onto the boot area of the local disk*)

  RelocateLoaded*(start, dst: INTEGER)  (*relocate prelinked binary loaded at Mem[start] for execution at dst*)

  Relocate*  (*relocate prelinked binary M.bin for execution at destadr and write result to output file R.bin*)

  Execute*  (*load and execute prelinked binary M.bin*)

```
