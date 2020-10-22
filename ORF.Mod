MODULE ORF;  (*Oberon Firmware Generator for RISC / AP 13.6.20 Extended Oberon / CP 22.10.20 WriteFile reverted to po2013 format*)
  IMPORT Files, Texts, Oberon;
  CONST CR = 0DX; noerr = 0; badfile = 4;  (*copied from Modules for use as cross development tool*)

  TYPE Writer = PROCEDURE(VAR R: Files.Rider; x: LONGINT);

  VAR res*: INTEGER;
    W: Texts.Writer;

  PROCEDURE WriteHex(VAR R: Files.Rider; x: LONGINT);  (*write a 4 byte LONGINT in 8 digit hex format*)
    VAR i: INTEGER; y: LONGINT;
      a: ARRAY 10 OF CHAR;
  BEGIN i := 0;
    REPEAT y := x MOD 10H;
      IF y < 10 THEN a[i] := CHR(y + 30H) ELSE a[i] := CHR(y + 37H) END ;
      x := x DIV 10H; INC(i)
    UNTIL i = 8;
    REPEAT DEC(i); Files.Write(R, a[i]) UNTIL i = 0 ;
    Files.Write(R, CR)
  END WriteHex;

  PROCEDURE OutCode(VAR R, R1: Files.Rider; write: Writer; VAR codelen, entry, res: INTEGER);
    VAR n, data: INTEGER; ch: CHAR; b: BYTE;               (*codelen in words, entry in bytes*)
      F: Files.File;
      name: ARRAY 32 OF CHAR;
  BEGIN F := Files.Base(R); Files.ReadString(R, name); Files.ReadInt(R, data); (*key*)
    Files.ReadByte(R, b); (*version*) Files.ReadInt(R, data); (*size*)
    Files.ReadString(R, name); (*imports*)
    WHILE ~R.eof & (name[0] # 0X) DO Files.ReadInt(R, data); (*key*) Files.ReadString(R, name) END ;
    Files.ReadInt(R, n); Files.Set(R, F, Files.Pos(R) + n); (*type descriptors*)
    Files.ReadInt(R, n); (*variable space*)
    Files.ReadInt(R, n); Files.Set(R, F, Files.Pos(R) + n); (*strings*)
    Files.ReadInt(R, codelen); n := 0;
    WHILE ~R.eof & (n < codelen) DO Files.ReadInt(R, data); write(R1, data); INC(n) END ; (*write code*)
    Files.ReadString(R, name);
    res := noerr;
  END OutCode;

  PROCEDURE WriteFile*;  (*write code section of M.rsc in hex format to output file*)
    VAR f, g: Files.File; Rf, Rg: Files.Rider;
      n, codelen, filelen, entry: INTEGER;
      name: ARRAY 32 OF CHAR;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S); res := -1;
    IF S.class = Texts.Name THEN name := S.s; Texts.Scan(S);
      IF S.class = Texts.Name THEN Texts.WriteString(W, "  WriteFile "); res := -2;
        Texts.WriteString(W, name); Texts.Write(W, " "); Texts.WriteString(W, S.s);
        f := Files.Old(name);
        IF f # NIL THEN
          IF Files.Length(f) > 0 THEN
            g := Files.New(S.s); Files.Set(Rf, f, 0); Files.Set(Rg, g, 0);
            OutCode(Rf, Rg, WriteHex, codelen, entry, res);
            IF res = noerr THEN
              filelen := ((codelen DIV 512) + 1) * 512; n := codelen;
              WHILE n < filelen DO WriteHex(Rg, 0); INC(n) END ; (*zero-fill*)
              Texts.WriteInt(W, codelen*4, 6); Texts.WriteInt(W, entry, 6);
              Texts.WriteString(W, "  done"); Files.Register(g)
            ELSIF res = badfile THEN Texts.WriteString(W, "  input file format error")
            END
          ELSE Texts.WriteString(W, "  input file empty")
          END
        ELSE Texts.WriteString(W, "  input file not found")
        END
      END
    END ;
    IF res = -1 THEN Texts.WriteString(W, "Usage: ORX.WriteFile M.rsc M.mem") END ;
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf); (* Oberon.Return(res) *)
  END WriteFile;

BEGIN Texts.OpenWriter(W); Texts.WriteString(W, "OR Firmware Generator  AP 13.6.20 CP 22.10.20");
  Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
END ORF.
