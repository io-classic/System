(* begin-module-use-description
Module ORDis disassembles RISC5 opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**ORDis** is a disassembler of RISC5 opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.

end-module-develop-description *)
MODULE ORDis;   (*CP 2020*)
  IMPORT SYSTEM, Files, Oberon;
  CONST 
    OK* = 0; FINISH* = 1; BAD* = 2;
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV64=5; RISCV32=6;
    BYTEORIENTED=0; WORDORIENTED=1;

  TYPE

  VAR
    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
    mnemo0, mnemo1: ARRAY 16, 4 OF CHAR;  (*mnemonics*)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;

  PROCEDURE WriteReg(r: LONGINT; p: INTEGER; VAR s: ARRAY OF CHAR);
  BEGIN 
    IF r < 10 THEN s[p]:="R"; s[p+1]:= CHR(ORD("0")+((r MOD 16) MOD 10)); s[p+2]:=" "
    ELSIF r < 12 THEN s[p]:="R"; s[p+1]:= CHR(ORD("0")+((r MOD 16) DIV 10));s[p+2]:= CHR(ORD("0")+((r MOD 16) MOD 10));
    ELSIF r = 12 THEN s[p]:="M"; s[p+1]:= "T"; s[p+2]:="R"
    ELSIF r = 13 THEN s[p]:="S"; s[p+1]:= "B"; s[p+2]:="R"  
    ELSIF r = 14 THEN s[p]:="S"; s[p+1]:= "P"; s[p+2]:="R"
    ELSE s[p]:="L"; s[p+1]:= "N"; s[p+2]:="K"
    END
  END WriteReg;

  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);
    VAR k, op, u, a, b, c: LONGINT;
  BEGIN
      k := w DIV 40000000H MOD 4;
      a := w DIV 1000000H MOD 10H;
      b := w DIV 100000H MOD 10H;
      op := w DIV 10000H MOD 10H;
      u := w DIV 20000000H MOD 2;
      IF k = 0 THEN
        s[0]:=mnemo0[op][0];  s[1]:=mnemo0[op][1]; s[2]:=mnemo0[op][2]; s[3]:=" ";
        IF u = 1 THEN s[3]:="'" ELSE s[3]:=" " END ; s[4]:=" ";
        WriteReg(a,4,s);  s[7]:=" "; WriteReg(b,8,s);  s[11]:=" "; WriteReg(w MOD 10H,12,s);
        s[15]:=0X;
      ELSIF k = 1 THEN
        s[0]:=mnemo0[op][0];  s[1]:=mnemo0[op][1]; s[2]:=mnemo0[op][2]; s[3]:=" ";
        IF u = 1 THEN s[3]:="'" ELSE s[3]:=" " END ; s[4]:=" ";
        WriteReg(a,4,s);  s[7]:=" "; WriteReg(b,8,s);  s[11]:=" "; w := w MOD 10000H;
        IF w >= 8000H THEN w := w - 10000H END ;
(*
        Texts.WriteInt(W, w, 7)  *)
        s[12]:=0X;
      ELSIF k = 2 THEN  (*LDR/STR*)
        IF u = 1 THEN s[0]:="S"; s[1]:="T" ELSE s[0]:="L"; s[1]:="D"  END ; s[2]:="R"; s[3]:=" "; s[4]:=" ";
(*        WriteReg(a); WriteReg(b); w := w MOD 100000H;
        IF w >= 80000H THEN w := w - 100000H END ;
        Texts.WriteInt(W, w, 8) *)
        s[5]:=0X;
      ELSIF k = 3 THEN  (*Branch instr*)
        s[0]:= "B";
        IF ODD(w DIV 10000000H) THEN s[1]:= "L" ELSE s[1]:= " " END ;
(*        Texts.WriteString(W, mnemo1[a]);
        IF u = 0 THEN WriteReg(w MOD 10H) ELSE
          w := w MOD 100000H;
          IF w >= 80000H THEN w := w - 100000H END ;
          Texts.WriteInt(W, w, 8)  
        END *)
        s[2]:=0X;
      END
  END opcode;

  PROCEDURE decode*():INTEGER;
    VAR e,i: INTEGER; b: CHAR; t: ARRAY 32 OF CHAR;
  BEGIN
    e := OK;
    at :=pc;
    isz := 0;
    WHILE isz < 4 DO
      Files.Set(R,F,cfo+pc);
      Files.Read(R, b);
      ibytes[isz]:=ORD(b);
      INC(pc);
      INC(isz)
    END;
    i:=ibytes[0]+(ibytes[1]*100H)+(ibytes[2]*10000H)+(ibytes[3]*1000000H);
    opcode(i,istr);
    IF pc >= cfe THEN e:= FINISH END;
    IF R.eof THEN e:= FINISH END;
    E:=e;
    RETURN e
  END decode;

  PROCEDURE init*(VAR f: Files.File; i, o, e: INTEGER);
  BEGIN
    F := f;
    E:=OK;
    pc := i;
    at := i;
    cfo := o;
    cfe := e;
    Files.Set(R, f, cfo+pc);
  END init;

  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index: INTEGER): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e:=OK;
    init(f,index,offset,extent);
    E:=e;
    RETURN e
  END originate;

BEGIN 
  E := OK;
  wo:= WORDORIENTED;
  vendor := 0;
  mode := 64;
  at := 0;
  pc := 0;
  isz := 0;
  istr := "undecoded risc5";
  cfo := 0;
  cfe := 0;
  mnemo0[0] := "MOV";
  mnemo0[1] := "LSL";
  mnemo0[2] := "ASR";
  mnemo0[3] := "ROR";
  mnemo0[4] := "AND";
  mnemo0[5] := "ANN";
  mnemo0[6] := "IOR";
  mnemo0[7] := "XOR";
  mnemo0[8] := "ADD";
  mnemo0[9] := "SUB";
  mnemo0[10] := "MUL";
  mnemo0[11] := "DIV";
  mnemo0[12] := "FAD";
  mnemo0[13] := "FSB";
  mnemo0[14] := "FML";
  mnemo0[15] := "FDV";
  mnemo1[0] := "MI ";
  mnemo1[8] := "PL";
  mnemo1[1] := "EQ ";
  mnemo1[9] := "NE ";
  mnemo1[2] := "LS ";
  mnemo1[10] := "HI ";
  mnemo1[5] := "LT ";
  mnemo1[13] := "GE ";
  mnemo1[6] := "LE ";
  mnemo1[14] := "GT ";
  mnemo1[15] := "NO ";
END ORDis.
