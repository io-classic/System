
## [MODULE Graphics](https://github.com/io-core/Draw/blob/main/Graphics.Mod)

  ## Imports:
` SYSTEM Files Modules Fonts (*Printer*) Texts Oberon`

## Constants:
```
 NameLen* = 32; GraphFileId = 0FAX; LibFileId = 0FBX;

```
## Types:
```

    Graph* = POINTER TO GraphDesc;
    Object* = POINTER TO ObjectDesc;
    Method* = POINTER TO MethodDesc;

    Line* = POINTER TO LineDesc;
    Caption* = POINTER TO CaptionDesc;
    Macro* = POINTER TO MacroDesc;

    ObjectDesc* = RECORD
        x*, y*, w*, h*: INTEGER;
        col*: BYTE;
        selected*, marked*: BOOLEAN;
        do*: Method;
        next: Object
      END ;

    Msg* = RECORD END ;
    WidMsg* = RECORD (Msg) w*: INTEGER END ;
    ColorMsg* = RECORD (Msg) col*: INTEGER END ;
    FontMsg* = RECORD (Msg) fnt*: Fonts.Font END ;
    Name* = ARRAY NameLen OF CHAR;

    GraphDesc* = RECORD
        time*: LONGINT;
        sel*, first: Object;
        changed*: BOOLEAN
      END ;

    MacHead* = POINTER TO MacHeadDesc;
    MacExt* = POINTER TO MacExtDesc;
    Library* = POINTER TO LibraryDesc;

    MacHeadDesc* = RECORD
        name*: Name;
        w*, h*: INTEGER;
        ext*: MacExt;
        lib*: Library;
        first: Object;
        next: MacHead
      END ;

    LibraryDesc* = RECORD
        name*: Name;
        first: MacHead;
        next: Library
      END ;

    MacExtDesc* = RECORD END ;

    Context* = RECORD
        nofonts, noflibs, nofclasses: INTEGER;
        font: ARRAY 10 OF Fonts.Font;
        lib: ARRAY 4 OF Library;
        class: ARRAY 6 OF Modules.Command
      END;

    MethodDesc* = RECORD
        module*, allocator*: Name;
        new*: Modules.Command;
        copy*: PROCEDURE (from, to: Object);
        draw*, change*: PROCEDURE (obj: Object; VAR msg: Msg);
        selectable*: PROCEDURE (obj: Object; x, y: INTEGER): BOOLEAN;
        read*: PROCEDURE (obj: Object; VAR R: Files.Rider; VAR C: Context);
        write*: PROCEDURE (obj: Object; cno: INTEGER; VAR R: Files.Rider; VAR C: Context);
        print*: PROCEDURE (obj: Object; x, y: INTEGER)
      END ;

    LineDesc* = RECORD (ObjectDesc)
        unused*: INTEGER
      END ;

    CaptionDesc* = RECORD (ObjectDesc)
        pos*, len*: INTEGER
      END ;

    MacroDesc* = RECORD (ObjectDesc)
        mac*: MacHead
      END ;

```
## Variables:
```
 width*, res*: INTEGER;
    new: Object;
    T*: Texts.Text;  (*captions*)
    LineMethod*, CapMethod*, MacMethod* : Method;
    GetLib0: PROCEDURE (name: ARRAY OF CHAR; replace: BOOLEAN; VAR Lib: Library);

```
## Procedures:
---

`  PROCEDURE New*(obj: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L95)


`  PROCEDURE Add*(G: Graph; obj: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L99)


`  PROCEDURE ThisObj*(G: Graph; x, y: INTEGER): Object;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L104)


`  PROCEDURE SelectObj*(G: Graph; obj: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L111)


`  PROCEDURE SelectArea*(G: Graph; x0, y0, x1, y1: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L116)


`  PROCEDURE Draw*(G: Graph; VAR M: Msg);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L130)


`  PROCEDURE List*(G: Graph);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L136)


`  PROCEDURE Deselect*(G: Graph);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L150)


`  PROCEDURE DrawSel*(G: Graph; VAR M: Msg);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L156)


`  PROCEDURE Change*(G: Graph; VAR M: Msg);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L165)


`  PROCEDURE Move*(G: Graph; dx, dy: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L174)


`  PROCEDURE Copy*(Gs, Gd: Graph; dx, dy: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L215)


`  PROCEDURE Delete*(G: Graph);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L228)


`  PROCEDURE WMsg(s0, s1: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L244)


`  PROCEDURE InitContext(VAR C: Context);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L249)


`  PROCEDURE FontNo*(VAR W: Files.Rider; VAR C: Context; fnt: Fonts.Font): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L254)


`  PROCEDURE StoreElems(VAR W: Files.Rider; VAR C: Context; obj: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L265)


`  PROCEDURE Store*(G: Graph; VAR W: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L281)


`  PROCEDURE WriteObj*(VAR W: Files.Rider; cno: INTEGER; obj: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L286)


`  PROCEDURE WriteFile*(G: Graph; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L291)


`  PROCEDURE Print*(G: Graph; x0, y0: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L297)


`  PROCEDURE GetClass*(module, allocator: ARRAY OF CHAR; VAR com: Modules.Command);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L305)


`  PROCEDURE Font*(VAR R: Files.Rider; VAR C: Context): Fonts.Font;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L315)


`  PROCEDURE ReadObj(VAR R: Files.Rider; obj: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L320)


`  PROCEDURE LoadElems(VAR R: Files.Rider; VAR C: Context; VAR fobj: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L327)


`  PROCEDURE Load*(G: Graph; VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L352)


`  PROCEDURE Open*(G: Graph; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L357)


`  PROCEDURE SetWidth*(w: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L368)


`  PROCEDURE GetLib*(name: ARRAY OF CHAR; replace: BOOLEAN; VAR Lib: Library);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L374)


`  PROCEDURE NewLib*(Lname: ARRAY OF CHAR): Library;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L406)


`  PROCEDURE StoreLib*(L: Library; Fname: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L412)


`  PROCEDURE RemoveLibraries*;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L435)


`  PROCEDURE ThisMac*(L: Library; Mname: ARRAY OF CHAR): MacHead;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L439)


`  PROCEDURE DrawMac*(mh: MacHead; VAR M: Msg);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L446)


`  PROCEDURE OpenMac*(mh: MacHead; G: Graph; x, y: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L454)


`  PROCEDURE MakeMac*(G: Graph; VAR head: MacHead);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L464)


`  PROCEDURE InsertMac*(mh: MacHead; L: Library; VAR new: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L487)


`  PROCEDURE NewLine;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L500)


`  PROCEDURE CopyLine(src, dst: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L505)


`  PROCEDURE ChangeLine(obj: Object; VAR M: Msg);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L509)


`  PROCEDURE LineSelectable(obj: Object; x, y: INTEGER): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L521)


`  PROCEDURE ReadLine(obj: Object; VAR R: Files.Rider; VAR C: Context);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L526)


`  PROCEDURE WriteLine(obj: Object; cno: INTEGER; VAR W: Files.Rider; VAR C: Context);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L530)


`  PROCEDURE NewCaption;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L543)


`  PROCEDURE CopyCaption(src, dst: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L548)


`  PROCEDURE ChangeCaption(obj: Object;  VAR M: Msg);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L559)


`  PROCEDURE CaptionSelectable(obj: Object; x, y: INTEGER): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L578)


`  PROCEDURE ReadCaption(obj: Object; VAR R: Files.Rider; VAR C: Context);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L583)


`  PROCEDURE WriteCaption(obj: Object; cno: INTEGER; VAR W: Files.Rider; VAR C: Context);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L591)


`  PROCEDURE NewMacro;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L621)


`  PROCEDURE CopyMacro(src, dst: Object);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L626)


`  PROCEDURE ChangeMacro(obj: Object; VAR M: Msg);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L631)


`  PROCEDURE MacroSelectable(obj: Object; x, y: INTEGER): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L636)


`  PROCEDURE ReadMacro(obj: Object; VAR R: Files.Rider; VAR C: Context);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L641)


`  PROCEDURE WriteMacro(obj: Object; cno: INTEGER; VAR W1: Files.Rider; VAR C: Context);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L647)


`  PROCEDURE Notify(T: Texts.Text; op: INTEGER; beg, end: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L666)


`  PROCEDURE InstallDrawMethods*(drawLine, drawCaption, drawMacro: PROCEDURE (obj: Object; VAR msg: Msg));` [(source)](https://github.com/io-orig/System/blob/main/Graphics.Mod#L670)

