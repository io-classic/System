
## [MODULE OXTool](https://github.com/io-core/Build/blob/main/OXTool.Mod)
Module OXTool provides symbol file, module file, and loaded module reporting tools.

ORP.Compile Target.Mod/s ~
OXTool.DecSym Target.smb ~ (if a regular module)
OXTool.DecObj Target.rsc ~ (if a regular module)
OXTool.DecBin Target.bin ~ (if a bare metal module)


(NW 18.2.2013 / CP 2020)

**OXTool** reports on and transforms the object files produced by the compiler's code generation module O[RIAa]G.

Any change to O[RIAa]G is likely to require a matching change in OXTool.


  ## Imports:
` SYSTEM Files Modules Input Texts Viewers MenuViewers TextFrames Oberon OXDis`

## Constants:
```
 
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV=5;
    BYTEORIENTED=0; WORDORIENTED=1;
    versionkey* = 1; maxTypTab = 64; 
    (* class values*) Head* = 0;
      Const* = 1; Var* = 2; Par* = 3; Fld* = 4; Typ* = 5;
      SProc* = 6; SFunc* = 7; Mod* = 8;
    (* form values*)
      Byte* = 1; Bool* = 2; Char* = 3; Int* = 4; Real* = 5; Set* = 6;
      Pointer* = 7; NilTyp* = 8; NoTyp* = 9; Proc* = 10;
      String* = 11; Array* = 12; Record* = 13;

  VAR 
    T: Texts.Text; V: MenuViewers.Viewer; W: Texts.Writer;
    Form: INTEGER;  (*result of ReadType*)


  PROCEDURE OpenViewer(T: Texts.Text; title: ARRAY OF CHAR);
    VAR X, Y: INTEGER;
  BEGIN
    Oberon.AllocateUserViewer(0, X, Y);
    V := MenuViewers.New(
        TextFrames.NewMenu(title, "System.Close  System.Copy  System.Grow  Edit.Search  Edit.Store"),
        TextFrames.NewText(T, 0), TextFrames.menuH, X, Y)
  END OpenViewer;

  PROCEDURE Clear*;  (*used to clear output*)
    VAR buf: Texts.Buffer;
  BEGIN NEW(buf); Texts.OpenBuf(buf); Texts.Delete(T, 0, T.len, buf)
  END Clear;

  PROCEDURE Recall*;
    VAR M: Viewers.ViewerMsg;
  BEGIN
    IF (V # NIL) & (V.state = 0) THEN
      Viewers.Open(V, V.X, V.Y + V.H); M.id := Viewers.restore; V.handle(V, M)
    END
  END Recall;

  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);
    VAR b: BYTE;
  BEGIN Files.ReadByte(R, b);
    IF b < 80H THEN n := b ELSE n := b - 100H END
  END Read;

  PROCEDURE ArchFromExt(VAR s: ARRAY OF CHAR):INTEGER;
  VAR
    a,l,e: INTEGER;
  BEGIN
    a:=BADARCH;
    l:=LEN(s); e:=0; WHILE (e < l) & ( s[e] # 0X) DO INC(e) END;
    IF l > 4 THEN 
      IF (s[e-3] = "r") & (s[e-2] = "s") & (s[e-1] = "c") THEN a:= RISC5 END;
      IF (s[e-3] = "i") & (s[e-2] = "6") & (s[e-1] = "4") THEN a:= X8664 END;
      IF (s[e-3] = "a") & (s[e-2] = "6") & (s[e-1] = "4") THEN a:= AARCH64 END;
      IF (s[e-3] = "a") & (s[e-2] = "3") & (s[e-1] = "2") THEN a:= ARM32 END;
      IF (s[e-3] = "v") & (s[e-2] = "6") & (s[e-1] = "4") THEN a:= RISCV END;
      IF (s[e-3] = "v") & (s[e-2] = "3") & (s[e-1] = "2") THEN a:= RISCV END
    END
    RETURN a
  END ArchFromExt;

  PROCEDURE ReadType(VAR R: Files.Rider);
    VAR key, len, lev, size, off: INTEGER;
      ref, mno, class, form, readonly: INTEGER;
      name, modname: ARRAY 32 OF CHAR;
  BEGIN Read(R, ref); Texts.Write(W, " "); Texts.Write(W, "[");
    IF ref < 0 THEN Texts.Write(W, "^"); Texts.WriteInt(W, -ref, 1)
    ELSE Texts.WriteInt(W, ref, 1);
      Read(R, form); Texts.WriteString(W, "  form = "); Texts.WriteInt(W, form, 1);
      IF form = Pointer THEN ReadType(R)
      ELSIF form = Array THEN
        ReadType(R); Files.ReadNum(R, len); Files.ReadNum(R, size);
        Texts.WriteString(W, "  len = "); Texts.WriteInt(W, len, 1);
        Texts.WriteString(W, "  size = "); Texts.WriteInt(W, size, 1)
      ELSIF form = Record THEN
        ReadType(R);  (*base type*)
        Files.ReadNum(R, off); Texts.WriteString(W, "  exno = "); Texts.WriteInt(W, off, 1); 
        Files.ReadNum(R, off); Texts.WriteString(W, "  extlev = "); Texts.WriteInt(W, off, 1);
        Files.ReadNum(R, size); Texts.WriteString(W, "  size = "); Texts.WriteInt(W, size, 1);
        Texts.Write(W, " "); Texts.Write(W, "{"); Read(R, class);
        WHILE class # 0 DO (*fields*)
          Files.ReadString(R, name);
          IF name[0] # 0X THEN Texts.Write(W, " "); Texts.WriteString(W, name); ReadType(R)
          ELSE Texts.WriteString(W, " --")
          END ;
          Files.ReadNum(R, off); Texts.WriteInt(W, off, 4); Read(R, class)
        END ;
        Texts.Write(W, "}")
      ELSIF form = Proc THEN
        ReadType(R); Texts.Write(W, "("); Read(R, class);
        WHILE class # 0 DO
          Texts.WriteString(W, " class = "); Texts.WriteInt(W, class, 1); Read(R, readonly);
          IF readonly = 1 THEN Texts.Write(W, "#") END ;
          ReadType(R); Read(R, class)
        END ;
        Texts.Write(W, ")")
      END ;
      Files.ReadString(R, modname);
      IF modname[0] # 0X THEN
        Files.ReadInt(R, key); Files.ReadString(R, name);
        Texts.Write(W, " "); Texts.WriteString(W, modname); Texts.Write(W, "."); Texts.WriteString(W, name);
        Texts.WriteHex(W, key)
      END
    END ;
    Form := form; Texts.Write(W, "]")
  END ReadType;

(* begin-section-description
## ---------- Command Invocation
  end-section-description *)

  (* begin-procedure-description
---
**Option** checks if a new symbol file may be generated.
  end-procedure-description *)
  PROCEDURE Option(VAR S: Texts.Scanner):INTEGER;
    VAR opt:INTEGER;
  BEGIN opt := RISC5;
    IF S.nextCh = "/" THEN
      Texts.Scan(S); Texts.Scan(S);
      IF (S.class = Texts.Name) & (S.s[0] = "I") THEN opt := X8664 END;
      IF (S.class = Texts.Name) & (S.s[0] = "A") THEN opt := AARCH64 END;
      IF (S.class = Texts.Name) & (S.s[0] = "a") THEN opt := ARM32 END;
      IF (S.class = Texts.Name) & (S.s[0] = "V") THEN opt := RISCV END;
      IF (S.class = Texts.Name) & (S.s[0] = "v") THEN opt := RISCV END
    END
  RETURN opt
  END Option;

  PROCEDURE DecSym*;  (*decode symbol file*)
    VAR class, typno, k: INTEGER;
      name: ARRAY 32 OF CHAR;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Texts.WriteString(W, "smb-decode "); Texts.WriteString(W, S.s);
      Texts.WriteLn(W); Texts.Append(T, W.buf);
      F := Files.Old(S.s);
      IF F # NIL THEN
        Files.Set(R, F, 0); Files.ReadInt(R, k); Files.ReadInt(R, k);
        Files.ReadString(R, name); Texts.WriteString(W, name); Texts.WriteHex(W, k);
        Read(R, class); Texts.WriteInt(W, class, 3); (*sym file version*)
        IF class = versionkey THEN
          Texts.WriteLn(W); Read(R, class);
          WHILE class # 0 DO
            Texts.WriteInt(W, class, 4); Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name);
            ReadType(R);
            IF class = Typ THEN
              Texts.Write(W, "("); Read(R, class);
              WHILE class # 0 DO  (*pointer base fixup*)
                Texts.WriteString(W, " ->"); Texts.WriteInt(W, class, 4); Read(R, class)
              END ;
              Texts.Write(W, ")")
            ELSIF (class = Const) OR (class = Var) THEN
              Files.ReadNum(R, k); Texts.WriteInt(W, k, 5);  (*Reals, Strings!*)
            END ;
            Texts.WriteLn(W); Texts.Append(T, W.buf);
            Read(R, class)
          END
        ELSE Texts.WriteString(W, " bad symfile version")
        END
      ELSE Texts.WriteString(W, " not found")
      END ;
      Texts.WriteLn(W); Texts.Append(T, W.buf)
    END
  END DecSym;
  
(* ---------------------------------------------------*)

   PROCEDURE WriteHexBytes (x: LONGINT);
     VAR i: INTEGER; y: LONGINT;
       a: ARRAY 10 OF CHAR;
   BEGIN i := 0; Texts.Write(W, " ");
     REPEAT y := x MOD 10H;
       IF y < 10 THEN a[i] := CHR(y + 30H) ELSE a[i] := CHR(y + 37H) END;
       x := x DIV 10H; INC(i)
     UNTIL i = 8;
     Texts.Write(W, a[1]);Texts.Write(W, a[0]);Texts.Write(W, " ");
     Texts.Write(W, a[3]);Texts.Write(W, a[2]);Texts.Write(W, " ");
     Texts.Write(W, a[5]);Texts.Write(W, a[4]);Texts.Write(W, " ");
     Texts.Write(W, a[7]);Texts.Write(W, a[6]);Texts.Write(W, " ");
   END WriteHexBytes;
 
   PROCEDURE HighNib(b: BYTE): CHAR;
     VAR ch: CHAR;
   BEGIN
     ch := CHR((b DIV 16) MOD 16 + ORD("0"));
     IF ch > "9" THEN ch := CHR(ORD(ch) + 7) END;
   RETURN ch
   END HighNib;
 
   PROCEDURE LowNib(b: BYTE): CHAR;
     VAR ch: CHAR;
   BEGIN
     ch := CHR(b MOD 16 + ORD("0"));
     IF ch > "9" THEN ch := CHR(ORD(ch) + 7) END;
   RETURN ch
   END LowNib;
  
  PROCEDURE Sync(VAR R: Files.Rider);
    VAR ch: CHAR;
  BEGIN Files.Read(R, ch); Texts.WriteString(W, "Sync "); Texts.Write(W, ch); Texts.WriteLn(W)
  END Sync;
  
  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);
  BEGIN Files.WriteByte(R, x)  (* -128 <= x < 128 *)
  END Write;

  PROCEDURE decodeSection(VAR R: Files.Rider; VAR F: Files.File; VAR n,s,x: INTEGER);
    VAR i,e: INTEGER;
  BEGIN
    e := OXDis.originate(R,F,s,n*4,0,x);
    WHILE e # OXDis.FINISH DO
      e := OXDis.decode();
      Texts.WriteInt(W, OXDis.at, 4); Texts.Write(W, 9X);
      IF OXDis.wo = BYTEORIENTED THEN
        i:=0;WHILE i < OXDis.isz DO
          Texts.Write(W, HighNib(OXDis.ibytes[i])); Texts.Write(W, LowNib(OXDis.ibytes[i])); Texts.Write(W, " ");
          INC(i);
        END;
      ELSE
        i:=OXDis.isz -1;WHILE i >= 0 DO
          Texts.Write(W, HighNib(OXDis.ibytes[i])); Texts.Write(W, LowNib(OXDis.ibytes[i]));
          DEC(i);
        END;
      END;
      Texts.Write(W, 9X); Texts.WriteString(W, OXDis.istr); Texts.WriteLn(W);
    END
  END decodeSection;


  PROCEDURE DecBin*;   (*decode bare metal binary file*)
    VAR class, i, n, key, size, fix, adr, data, len, s, x, a: INTEGER;
      ch: CHAR;
      fn: ARRAY 32 OF CHAR;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      fn:=S.s;
      x:=Option(S);
      
      Texts.WriteString(W, "bin-decode "); Texts.WriteString(W, fn); F := Files.Old(fn);
      IF F # NIL THEN
        Files.Set(R, F, 0); 
        Texts.WriteString(W, "code"); Texts.WriteLn(W);
        n:=Files.Length(F) DIV 4;
        s := Files.Pos(R); 
        decodeSection(R, F, n, s, x);
      ELSE Texts.WriteString(W, " not found"); Texts.WriteLn(W)
      END ;
      Texts.Append(T, W.buf)
    END
  END DecBin;

  PROCEDURE DecObj*;   (*decode object file*)
    VAR class, i, n, key, size, fix, adr, data, len, s, x: INTEGER;
      ch: CHAR;
      name: ARRAY 32 OF CHAR;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Texts.WriteString(W, "obj-decode "); Texts.WriteString(W, S.s); 
      x:=ArchFromExt(S.s);
      IF x # 0 THEN
        F := Files.Old(S.s);
        IF F # NIL THEN
          Files.Set(R, F, 0); Files.ReadString(R, name); Texts.WriteLn(W); Texts.WriteString(W, name);
          Files.ReadInt(R, key); Texts.WriteHex(W, key); Read(R, class); Texts.WriteInt(W, class, 4); (*version*)
          Files.ReadInt(R, size); Texts.WriteInt(W, size, 6); Texts.WriteLn(W);
          Texts.WriteString(W, "imports:"); Texts.WriteLn(W); Files.ReadString(R, name);
          WHILE name[0] # 0X DO
            Texts.Write(W, 9X); Texts.WriteString(W, name);
            Files.ReadInt(R, key); Texts.WriteHex(W, key); Texts.WriteLn(W);
            Files.ReadString(R, name)
          END ;
        (* Sync(R); *)
          Texts.WriteString(W, "type descriptors"); Texts.WriteLn(W);
          Files.ReadInt(R, n); n := n DIV 4; i := 0;
          WHILE i < n DO Files.ReadInt(R, data); Texts.WriteHex(W, data); INC(i) END ;
          Texts.WriteLn(W);
          Texts.WriteString(W, "data"); Files.ReadInt(R, data); Texts.WriteInt(W, data, 6); Texts.WriteLn(W);
          Texts.WriteString(W, "strings"); Texts.WriteLn(W);
          Files.ReadInt(R, n); i := 0;
          WHILE i < n DO Files.Read(R, ch); Texts.Write(W, ch); INC(i) END ;
          Texts.WriteLn(W);
          Texts.WriteString(W, "code"); Texts.WriteLn(W);
          Files.ReadInt(R, n); i := 0;

          s := Files.Pos(R); 
          decodeSection(R, F, n, s, x);

          Files.Set(R,F,s+(n*4));
          Texts.WriteString(W, "commands:"); Texts.WriteLn(W);
          Files.ReadString(R, name);
          WHILE name[0] # 0X DO
            Texts.Write(W, 9X); Texts.WriteString(W, name);
            Files.ReadInt(R, adr); Texts.WriteInt(W, adr, 5); Texts.WriteLn(W);
            Files.ReadString(R, name)
          END ;
          Texts.WriteString(W, "entries"); Texts.WriteLn(W);
          Files.ReadInt(R, n); i := 0;
          WHILE i < n DO
            Files.ReadInt(R, adr); Texts.WriteInt(W, adr, 6); INC(i)
          END ;
          Texts.WriteLn(W);
          Texts.WriteString(W, "pointer refs"); Texts.WriteLn(W); Files.ReadInt(R, adr);
          WHILE adr # -1 DO Texts.WriteInt(W, adr, 6); Files.ReadInt(R, adr) END ;
          Texts.WriteLn(W);
          Files.ReadInt(R, data); Texts.WriteString(W, "fixP = "); Texts.WriteInt(W, data, 8); Texts.WriteLn(W);
          Files.ReadInt(R, data); Texts.WriteString(W, "fixD = "); Texts.WriteInt(W, data, 8); Texts.WriteLn(W);
          Files.ReadInt(R, data); Texts.WriteString(W, "fixT = "); Texts.WriteInt(W, data, 8); Texts.WriteLn(W);
          Files.ReadInt(R, data); Texts.WriteString(W, "entry = "); Texts.WriteInt(W, data, 8); Texts.WriteLn(W);
          Files.Read(R, ch);
          IF ch # "O" THEN Texts.WriteString(W, "format eror"); Texts.WriteLn(W) END
        (* Sync(R); *)
        ELSE Texts.WriteString(W, " not found"); Texts.WriteLn(W)
        END ;
      ELSE 
        i:=LEN(S.s);
        Texts.WriteString(W, " not understood extension");
        name[0]:=S.s[i-3];
        name[1]:=S.s[i-2];
        name[2]:=S.s[i-1];
        name[3]:=0X;
        Texts.WriteString(W, name);
        Texts.WriteLn(W)
      END;
      Texts.Append(T, W.buf)
    END
  END DecObj;

BEGIN
  Texts.OpenWriter(W); T := TextFrames.Text(""); OpenViewer(T, "OXTool.Text");
  Texts.WriteString(W, "OXTool 2020"); Texts.WriteLn(W); Texts.Append(T, W.buf);
END OXTool.
```
```
## Variables:
```
 
    T: Texts.Text; V: MenuViewers.Viewer; W: Texts.Writer;
    Form: INTEGER;  (*result of ReadType*)

```
## Procedures:
---

`  PROCEDURE OpenViewer(T: Texts.Text; title: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L38)


`  PROCEDURE Clear*;  (*used to clear output*)` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L47)


`  PROCEDURE Recall*;` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L52)


`  PROCEDURE Read(VAR R: Files.Rider; VAR n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L60)


`  PROCEDURE ArchFromExt(VAR s: ARRAY OF CHAR):INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L66)


`  PROCEDURE ReadType(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L83)

## ---------- Command Invocation
---
**Option** checks if a new symbol file may be generated.

`  PROCEDURE Option(VAR S: Texts.Scanner):INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L137)


`  PROCEDURE DecSym*;  (*decode symbol file*)` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L151)


`   PROCEDURE WriteHexBytes (x: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L192)


`   PROCEDURE HighNib(b: BYTE): CHAR;` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L206)


`   PROCEDURE LowNib(b: BYTE): CHAR;` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L214)


`  PROCEDURE Sync(VAR R: Files.Rider);` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L222)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L227)


`  PROCEDURE decodeSection(VAR R: Files.Rider; VAR F: Files.File; VAR n,s,x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L231)


`  PROCEDURE DecBin*;   (*decode bare metal binary file*)` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L254)


`  PROCEDURE DecObj*;   (*decode object file*)` [(source)](https://github.com/io-orig/System/blob/main/OXTool.Mod#L278)

