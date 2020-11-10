(* begin-module-use-description
Module OvDis disassembles 32-bit RISCV opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OvDis** is a disassembler of 32-bit RISCV opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.

end-module-develop-description *)
MODULE OvDis;   (*CP 2020*)
  IMPORT SYSTEM, Files, Oberon;
  CONST
    OK* = 0; FINISH* = 1; BAD* = 2;
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV64=5; RISCV32=6;
    BYTEORIENTED=0; WORDORIENTED=1;
  (*opcode formats*)
    DPfmt = 0; MULfmt = 1; MULLfmt = 2; SDSfmt = 3; BEfmt = 4; HDTRfmt = 5; HDTIfmt = 6;
    SDTfmt = 7; UNDfmt = 8; BDTfmt = 9; BRfmt = 10; CDTfmt = 11; CDOfmt = 12; CRTfmt = 13; SWIfmt = 14;
    
  TYPE

  VAR
    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
    mnemo0, cc : ARRAY 16, 4 OF CHAR;  (*arm32 mnemonics*)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;


  PROCEDURE opFormat*(w: LONGINT): LONGINT;
                VAR fmt,cc, a, b, f: LONGINT;
        BEGIN
        cc := w DIV 10000000H;
        a  := w DIV 1000000H MOD 10H;
        b  := w DIV 100000H MOD 10H;
        f   := w DIV 10H MOD 10H;

        IF  (( a = 0 ) OR ( a = 1 ) OR ( a = 2 ) OR ( a = 3 )) THEN
          IF (f = 9) & (a = 0) THEN (*mul / mull *)
            IF ODD(b DIV 8) THEN                       fmt := MULLfmt
            ELSE                                       fmt := MULfmt
            END
          ELSIF (f>9) & ODD(f) & (a<2) THEN (* ldrh/strh *)
            IF ~ODD(b DIV 4) THEN                      fmt := HDTRfmt  
            ELSE                                       fmt := HDTIfmt
            END
          ELSIF (f = 9) & (a=1) THEN (*single swap *)
                                                       fmt := SDSfmt
          ELSIF (a = 1) & ((b = 2) OR (b = 6) OR (b = 0) 
             OR (b = 4)) OR (a = 3)&((b = 2) OR (b = 6)) 
             THEN(* msr /mrs *)
                                                       fmt :=  -1
          ELSE
            IF (b DIV 2 + a*8 MOD 10H = 0DH) OR 
               (b DIV 2 + a*8 MOD 10H = 0FH) 
               THEN (* Mov, Mvn*)
                                                       fmt := DPfmt
            ELSIF (b DIV 2 + a*8 MOD 10H >= 8H) & 
                  (b DIV 2 + a*8 MOD 10H <=  0BH) 
                  THEN (* cmp, tst*)
                                                       fmt := DPfmt
            ELSE
                                                       fmt := DPfmt
            END;
            IF ODD(a DIV 2) THEN    (* Immidiate Data processing *)
                                                       fmt := DPfmt
            ELSE    (* Data processing *)
                                                       fmt :=  DPfmt
            END
          END
        ELSIF ((a=4) OR (a=5) OR (a=6) OR (a=7)) THEN (* ldf, str *)
          IF (a >= 6) & ODD(f) THEN       (* undef *)
                                                       fmt := UNDfmt
          ELSE    (*ldr, str *)
                                                       fmt := SDTfmt
          END
        ELSIF ((a=8) OR (a=9)) THEN (* ldm, stm *)     fmt := BDTfmt
        ELSIF a=0AH THEN (* Branch *)                  fmt := BRfmt
        ELSIF a=0BH THEN (* Branch and Link *)         fmt := BRfmt
        ELSIF a=0CH THEN (* FP Push/Pop *)             fmt := CDTfmt
        ELSIF a=0DH THEN (* FP Ldc / Stc *)            fmt := CDTfmt
        ELSIF a=0EH THEN (* FP Operation *)            fmt := CDOfmt
        ELSIF a=0FH THEN (* SWI *)                     fmt := SWIfmt
        END
        RETURN fmt
  END opFormat;

(*
  PROCEDURE a32opcode(w: LONGINT);
        IF   fmt=DPfmt THEN
                    i := w DIV 200000H MOD 10H;
                   Texts.WriteString(W, a32mnemo0[i]);
                   a32WriteReg( w DIV 1000H MOD 10H);
                   IF i # 13 THEN
                     a32WriteReg( w DIV 10000H MOD 10H)
                   END;
                   IF ODD(w DIV 2000000H) THEN (* immediate *)
                     IF w DIV 100H MOD 10H # 0 THEN
                       Texts.WriteString(W, " (");
                       Texts.WriteInt(W,  w  MOD 100H ,0);
                       Texts.WriteString(W, " ror ");
                       Texts.WriteInt(W,  w  DIV 100H MOD 10H ,0);
                       Texts.WriteString(W, ")");
                     ELSE
                       Texts.WriteString(W, " ");
                       Texts.WriteInt(W,  w  MOD 100H ,0);
                     END
                  ELSE (* register *)
                     IF w DIV 100H MOD 10H # 0 THEN
                       Texts.WriteString(W, " (");
                       a32WriteReg(  w  MOD 10H );
                       Texts.WriteString(W, " shft ");
                       Texts.WriteInt(W,  w  DIV 10H MOD 100H ,0);
                       Texts.WriteString(W, ")");
                     ELSE
                       a32WriteReg(  w  MOD 10H );
                     END
                  END
        ELSIF  fmt=SDTfmt THEN
          IF ODD( w DIV 100000H ) THEN
                      Texts.WriteString(W, "LDR");
          ELSE
                      Texts.WriteString(W, "STR");
          END;
                   a32WriteReg( w DIV 1000H MOD 10H);
                   a32WriteReg( w DIV 10000H MOD 10H);
                     Texts.WriteString(W, " ");
          IF ODD( w DIV 800000H ) THEN
                     Texts.WriteInt(W,  w  MOD 1000H ,0);
          ELSE
                     Texts.WriteInt(W,  - ( w  MOD 1000H ) ,0);
          END
        ELSIF  fmt=BRfmt THEN
          IF ODD( w DIV 1000000H ) THEN
                     Texts.WriteString(W, "BL")
          ELSE
                     Texts.WriteString(W, "B ")
          END;
          Texts.WriteString(W, a32cc[ w DIV 10000000H ] );
          Texts.WriteInt(W,  w  DIV 10H MOD 1000000H ,0);

        END
  END a32opcode;
*)


  PROCEDURE a32Reg(r: LONGINT; VAR s: ARRAY OF CHAR; i: INTEGER);

  BEGIN 
    IF    r < 10 THEN s[i]:= "R"; s[i+1]:=CHR(r MOD 10H+ORD("0"))
    ELSIF r = 10 THEN s[i]:= "M"; s[i+1]:="T"
    ELSIF r = 11 THEN s[i]:= "S"; s[i+1]:="B"
    ELSIF r = 12 THEN s[i]:= "F"; s[i+1]:="P"
    ELSIF r = 13 THEN s[i]:= "S"; s[i+1]:="P"
    ELSIF r = 14 THEN s[i]:= "L"; s[i+1]:="R"
    ELSE  s[i]:= "P"; s[i+1]:="C"
    END
  END a32Reg;

  PROCEDURE PlaceInt* (x: LONGINT;VAR s: ARRAY OF CHAR; p: INTEGER; VAR c:INTEGER);
    VAR i: INTEGER; x0: LONGINT;
      a: ARRAY 10 OF CHAR;
  BEGIN
    IF ROR(x, 31) = 1 THEN (* WriteString(W, " -2147483648") *)
    ELSE i := 0;
      IF x < 0 THEN x0 := -x ELSE x0 := x END;
      REPEAT
        a[i] := CHR(x0 MOD 10 + 30H); x0 := x0 DIV 10; INC(i)
      UNTIL x0 = 0;
      c:=0;
      IF x < 0 THEN s[c+p]:= "-"; INC(c) END;
      REPEAT DEC(i); s[c+p]:= a[i]; INC(c) UNTIL i = 0
    END
  END PlaceInt;




(* ARM v7 *)
  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);
    VAR k, op, u, a, b, c, d, fmt, i,t,t2: LONGINT;
  BEGIN

        fmt := opFormat( w );
        IF   fmt=DPfmt THEN
          i := w DIV 200000H MOD 10H; s[0]:=mnemo0[i][0];s[1]:=mnemo0[i][1];s[2]:=mnemo0[i][2];s[3]:=" ";
          a32Reg(w DIV 1000H MOD 10H,s,4);s[6]:=" ";
          IF i # 13 THEN a32Reg(w DIV 10000H MOD 10H,s,7);s[9]:=" ";
          ELSE s[7]:=" ";s[8]:=" ";s[9]:=" "; END;
          IF ODD(w DIV 2000000H) THEN (* immediate *)
            IF w DIV 100H MOD 10H # 0 THEN 
                       s[10]:="(";  
                       PlaceInt(  w  MOD 100H ,s,11,t); s[11+t]:=" "; s[12+t]:="r"; s[13+t]:="o"; s[14+t]:="r"; s[15+t]:=" ";
                       t2:=16+t;
                       PlaceInt( w  DIV 100H MOD 10H ,s,t2,t);s[t2+t]:=")";s[t2+t+1]:=0X;
            ELSE 
                       PlaceInt( w  MOD 100H ,s,10,t); s[10+t]:=0X;
            END
          ELSE (* register *)
            IF w DIV 100H MOD 10H # 0 THEN 
                       s[10]:="("; a32Reg(  w  MOD 10H,s,11 );s[13]:=" ";s[14]:="s";s[15]:="h";s[16]:="t";s[17]:=" ";
                       PlaceInt(  w  DIV 10H MOD 100H ,s,18,t); 
                       s[18+t]:=")";s[18+t+1]:=0X;
            ELSE
                       a32Reg(  w  MOD 10H, s, 10 ); s[12]:=0X;
            END
          END
        ELSIF  fmt=MULfmt  THEN s:=" -mul- "
        ELSIF  fmt=MULfmt  THEN s:=" -mul- "
        ELSIF fmt=MULLfmt  THEN s:=" -mull- "
        ELSIF fmt=SDSfmt    THEN s:=" -SDS- "
        ELSIF fmt=BEfmt    THEN s:=" -BE- "
        ELSIF fmt=HDTRfmt THEN s:=" -HDTR- "
        ELSIF fmt=HDTIfmt THEN s:=" -HDTI- "
        ELSIF  fmt=SDTfmt THEN
          IF ODD( w DIV 100000H ) THEN s[0]:= "L";s[1]:="D";s[2]:="R";s[3]:=" ";
          ELSE                         s[0]:= "S";s[1]:="T";s[2]:="R";s[3]:=" ";
          END;
          a32Reg( w DIV 1000H MOD 10H,s,4); s[6]:=" ";
          a32Reg( w DIV 10000H MOD 10H,s,7); s[9]:=" ";
          IF ODD( w DIV 800000H ) THEN s[10]:=" ";
            PlaceInt(      w  MOD 1000H   ,s,11,t); s[11+t]:=0X;
          ELSE                       
            PlaceInt(  - ( w  MOD 1000H ) ,s,11,t); s[11+t]:=0X;
          END
        ELSIF  fmt=UNDfmt THEN s:=" -UND- "
        ELSIF  fmt=BDTfmt THEN s:=" -BDT- "
        ELSIF  fmt=BRfmt THEN s[0]:="B";
          IF ODD( w DIV 1000000H ) THEN s[1]:= "L"
          ELSE                          s[1]:= " "
          END; 
          i:= w DIV 10000000H MOD 10H;
          s[2]:=cc[ i ][0];s[3]:=cc[ i ][1];s[4]:=cc[ i ][2];s[5]:=" ";
          PlaceInt(w  DIV 10H MOD 1000000H ,s,6,t); s[6+t]:=0X;
        ELSIF fmt=CDTfmt THEN s:= " -CDT- "
        ELSIF fmt=CDOfmt THEN s:=" -CDO- "
        ELSIF fmt=CRTfmt THEN s:=" -CRT- "
        ELSIF fmt=SWIfmt THEN s:=" -SWI- "
        END

  END opcode;

  PROCEDURE decode*():INTEGER;
    VAR e,i: INTEGER; b: CHAR; t: ARRAY 32 OF CHAR;
  BEGIN
    e := OK;
    at :=pc;
    isz := 4;
    Files.ReadInt(R,i);
    ibytes[0]:=i MOD 100H;
    ibytes[1]:=i DIV 100H MOD 100H;
    ibytes[2]:=i DIV 10000H MOD 100H;
    ibytes[3]:=i DIV 1000000H MOD 100H; 
    INC(pc,4);
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
  E := 0;
  wo := WORDORIENTED;
  vendor := 0;
  mode := 32;
  at := 0;
  pc := 0;
  isz := 0;
  istr := "undecoded riscv 32";
  cfo := 0;
  cfe := 0;
  mnemo0[0] := "AND";
  mnemo0[1] := "EOR";
  mnemo0[2] := "SUB";
  mnemo0[3] := "RSB";
  mnemo0[4] := "ADD";
  mnemo0[5] := "ADC";
  mnemo0[6] := "SBC";
  mnemo0[7] := "RSC";
  mnemo0[8] := "TST";
  mnemo0[9] := "TEQ";
  mnemo0[10] := "CMP";
  mnemo0[11] := "CMN";
  mnemo0[12] := "ORR";
  mnemo0[13] := "MOV";
  mnemo0[14] := "BIC";
  mnemo0[15] := "MVN";
  cc[0] := "EQ ";
  cc[1] := "NE ";
  cc[2] := "CS ";
  cc[3] := "CC ";
  cc[4] := "MI ";
  cc[5] := "PL ";
  cc[6] := "VS ";
  cc[7] := "VC ";
  cc[8] := "HI ";
  cc[9] := "LS ";
  cc[10] := "GE ";
  cc[11] := "LT ";
  cc[12] := "GT ";
  cc[13] := "LE ";
  cc[14] := "AL ";
  cc[15] := "XX ";
END OvDis.
