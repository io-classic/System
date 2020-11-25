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
    Rfmt = 0; Ifmt = 1; Sfmt = 2; Bfmt = 3; Ufmt = 4; Jfmt = 5; Afmt = 6; Badfmt = -1; Reserved = -2;
    DPfmt = 0; MULfmt = 1; MULLfmt = 2; SDSfmt = 3; BEfmt = 4; HDTRfmt = 5; HDTIfmt = 6;
    SDTfmt = 7; UNDfmt = 8; BDTfmt = 9; BRfmt = 10; CDTfmt = 11; CDOfmt = 12; CRTfmt = 13; SWIfmt = 14;
  (*opcodes*)
    opLUI    ="LUI"  ; opSLTIU  ="SLTIU" ; opEBREAK ="EBREAK"; opSRLW   ="SRLW"  ;  
    opAUIPC  ="AUIPC"; opXORI   ="XORI"  ; opCSRRW  ="CSRRW" ; opSRAW   ="SRAW"  ;
    opJAL    ="JAL"  ; opORI    ="ORI"   ; opCSRRS  ="CSRRS" ; opMUL    ="MUL"   ;
    opJALR   ="JALR" ; opANDI   ="ANDI"  ; opCSRRC  ="CSRRC" ; opMULH   ="MULH"  ;
    opBEQ    ="BEQ"  ; opSLLI   ="SLLI"  ; opCSRRWI ="CSRRWI"; opMULHSU ="MULHSU";
    opBNE    ="BNE"  ; opSRLI   ="SRLI"  ; opCSRRSI ="CSRRSI"; opMULHU  ="MULHU" ;
    opBLT    ="BLT"  ; opSRAI   ="SRAI"  ; opCSRRCI ="CSRRCI"; opDIV    ="DIV"   ;
    opBGE    ="BGE"  ; opADD    ="ADD"   ; opLWU    ="LWU"   ; opDIVU   ="DIVU"  ;
    opBLTU   ="BLTU" ; opSUB    ="SUB"   ; opLD     ="LD"    ; opREM    ="REM"   ;
    opBGEU   ="BGEU" ; opSLL    ="SLL"   ; opSD     ="SD"    ; opREMU   ="REMU"  ;
    opLB     ="LB"   ; opSLT    ="SLT"   ; opSLLIx  ="SLLIx" ; opMULW   ="MULW"  ;
    opLH     ="LH"   ; opSLTU   ="SLTU"  ; opSRLIx  ="SRLIx" ; opDIVW   ="DIVW"  ;
    opLW     ="LW"   ; opXOR    ="XOR"   ; opSRAIx  ="SRAIx" ; opDIVUW  ="DIVUW" ;
    opLBU    ="LBU"  ; opSRL    ="SRL"   ; opADDIW  ="ADDIW" ; opREMW   ="REMW"  ;
    opLHU    ="LHU"  ; opSRA    ="SRA"   ; opSLLIW  ="SLLIW" ; opREMUW  ="REMUW" ;
    opSB     ="SB"   ; opOR     ="OR"    ; opSRLIW  ="SRLIW" ;                       
    opSH     ="SH"   ; opAND    ="AND"   ; opSRAIW  ="SRAIW" ;                       
    opSW     ="SW"   ; opFENCE  ="FENCE" ; opADDW   ="ADDW"  ;                       
    opADDI   ="ADDI" ; opFENCEI ="FENCEI"; opSUBW   ="SUBW"  ; opBAD    ="BAD";                      
    opSLTI   ="SLTI" ; opECALL  ="ECALL" ; opSLLW   ="SLLW"  ; opUNKN   ="UNKNOWN" ;                      

  TYPE

  VAR
    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
(*    mnemo0: ARRAY 75, 10 OF CHAR;  (*riscv mnemonics*) *)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;


  PROCEDURE opFormat*(w: LONGINT): LONGINT;
    VAR fmt,cc, a, b, f: LONGINT;
  BEGIN

    
    IF (w MOD 4) = 3 THEN
      a := w DIV 4 MOD 32;
      IF (a = 0) OR (a = 4) OR (a = 6) THEN fmt := Ifmt 
      ELSIF (a = 5) OR (a = 13) THEN fmt := Ufmt 
      ELSIF (a = 27) THEN fmt := Jfmt 
      ELSIF (a = 24) THEN fmt := Bfmt 
      ELSIF (a = 8) OR (a = 9) THEN fmt := Sfmt 
      ELSIF (a = 4) OR (a = 12) OR (a = 6) OR (a = 14) OR (a = 16) OR (a = 17) OR (a = 18) OR (a = 19) THEN fmt := Rfmt 
      ELSIF (a = 11) THEN fmt := Afmt 
      ELSE  fmt := Reserved
      END
    ELSE
      fmt := Badfmt
    END
  RETURN fmt
  END opFormat;

  PROCEDURE append(VAR s1: ARRAY OF CHAR; s2: ARRAY OF CHAR);
    VAR c1,c2: INTEGER;
  BEGIN
    c1:=0; WHILE (c1 < LEN(s1)) & (s1[c1] # 0X) DO INC(c1) END; 
    c2:=0; WHILE (c1 < LEN(s1)) & (c2 < LEN(s2)) & (s2[c2] # 0X) DO s1[c1]:=s2[c2];INC(c1);INC(c2) END; 
    IF c1 < LEN(s1) THEN s1[c1]:=0X END
  END append;

  PROCEDURE v32reg(r: LONGINT; VAR s: ARRAY OF CHAR);
  BEGIN 
    s[0]:=" ";
    IF    r < 25 THEN s[1]:= "R"; s[2]:=CHR(r DIV 10 MOD 10+ORD("0")); s[3]:=CHR(r MOD 10+ORD("0"))
    ELSIF r = 26 THEN s[1]:= "M"; s[2]:="T"; s[3]:=" "
    ELSIF r = 27 THEN s[1]:= "S"; s[2]:="B"; s[3]:=" "
    ELSIF r = 28 THEN s[1]:= "F"; s[2]:="P"; s[3]:=" "
    ELSIF r = 29 THEN s[1]:= "S"; s[2]:="P"; s[3]:=" "
    ELSIF r = 30 THEN s[1]:= "L"; s[2]:="R"; s[3]:=" "
    ELSE              s[1]:= "P"; s[2]:="C"; s[3]:=" "
    END;
    s[4]:=0X
  END v32reg;

  PROCEDURE strInt (x: LONGINT; VAR s: ARRAY OF CHAR);
    VAR i,c: INTEGER; x0: LONGINT;
      a: ARRAY 12 OF CHAR;
  BEGIN
    IF ROR(x, 31) = 1 THEN s:= " -2147483648"
    ELSE i := 0;
      IF x < 0 THEN x0 := -x ELSE x0 := x END;
      REPEAT
        a[i] := CHR(x0 MOD 10 + 30H); x0 := x0 DIV 10; INC(i)
      UNTIL x0 = 0;
      s[0] := " ";
      c:=1;
      IF x < 0 THEN s[c]:= "-"; INC(c) END;
      REPEAT DEC(i); s[c]:= a[i]; INC(c) UNTIL i = 0;
      s[c]:=0X;
    END
  END strInt;


(* RV32G *)
  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);
    VAR 
      k, op, u, a, b, c, d, fmt, i,t,t2: LONGINT; 
      have: BOOLEAN;
      reg: ARRAY 5 OF CHAR; num: ARRAY 12 OF CHAR;
  BEGIN

        fmt := opFormat( w );
        s:=opUNKN;
        a:= w DIV 4 MOD 32;
        have := FALSE;
        IF fmt = Rfmt THEN s:= "Rfmt";
          IF    a = 4  THEN have:= TRUE; b:= w DIV 1000H MOD 8;
            IF b = 0 THEN s:= opADDI END;
            IF b = 1 THEN s:= opUNKN END;
            IF b = 2 THEN s:= opSLTI END;
            IF b = 3 THEN s:= opSLTIU END;
            IF b = 4 THEN s:= opXORI END;
            IF b = 5 THEN s:= opUNKN END;
            IF b = 6 THEN s:= opORI END;
            IF b = 7 THEN s:= opANDI END;
          ELSIF a = 12 THEN
          ELSIF a = 6  THEN
          ELSIF a = 14 THEN
          ELSIF a = 16 THEN
          ELSIF a = 17 THEN
          ELSIF a = 18 THEN
          ELSIF a = 19 THEN
          END
        END;
        IF fmt = Ifmt THEN s:= "Ifmt"; 
          IF a = 0 THEN have:=TRUE; b:= w DIV 1000H MOD 8;
            IF    b = 0  THEN  s:= opLB 
            ELSIF b = 1  THEN  s:= opLH 
            ELSIF b = 2  THEN  s:= opLW 
            ELSIF b = 3  THEN  s:= opLD
            ELSIF b = 4  THEN  s:= opLBU 
            ELSIF b = 5  THEN  s:= opLHU 
            ELSIF b = 6  THEN  s:= opLWU
            ELSIF b = 7  THEN  have:= FALSE
            END 
          ELSIF a = 4 THEN have:=TRUE; b:= w DIV 1000H MOD 8;
            IF    b = 0  THEN  s:= opADDI 
            ELSIF b = 1  THEN  have:= FALSE
            ELSIF b = 2  THEN  s:= opSLTI 
            ELSIF b = 3  THEN  s:= opSLTIU
            ELSIF b = 4  THEN  s:= opXORI
            ELSIF b = 5  THEN  have:= FALSE
            ELSIF b = 6  THEN  s:= opORI
            ELSIF b = 7  THEN  s:= opANDI
            END 
          ELSIF a = 6 THEN
          END
        END;
        IF fmt = Sfmt THEN s:= "Sfmt"; 
          IF a = 8 THEN have:=TRUE; b:= w DIV 1000H MOD 8;
            IF    b = 0  THEN  s:= opSB
            ELSIF b = 1  THEN  s:= opSH
            ELSIF b = 2  THEN  s:= opSW
            ELSIF b = 3  THEN  s:= opSD
            ELSE have:=FALSE 
            END;
            IF have THEN
	       v32reg(w DIV 8000 MOD 32,reg);
               append(s, reg);
	       v32reg(w DIV 100000 MOD 32,reg);
               append(s, reg);
               strInt((w DIV 128 MOD 32)+((w DIV 2000000 MOD 8000)*32), num); (* TODO: Handle sign bit extension *)
               append(s, num);
            END 
          ELSIF a = 9 THEN b:= w DIV 1000H MOD 8;
     (*       IF    b = 2  THEN  s:= opFSW 
            ELSIF b = 3  THEN  s:= opFSD
            END *)
          END
        END;
        IF fmt = Bfmt THEN s:= "Bfmt" END;
        IF fmt = Ufmt THEN s:= "Ufmt" END;
        IF fmt = Jfmt THEN s:= "Jfmt" END;
        IF fmt = Afmt THEN s:= "Afmt" END;
        IF fmt = Reserved THEN s:= "Reserved" END;
(*
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
          
          PlaceInt(w  DIV 10H MOD 1000000H ,s,6,t); s[6+t]:=0X;
        ELSIF fmt=CDTfmt THEN s:= " -CDT- "
        ELSIF fmt=CDOfmt THEN s:=" -CDO- "
        ELSIF fmt=CRTfmt THEN s:=" -CRT- "
        ELSIF fmt=SWIfmt THEN s:=" -SWI- "
        END
*)

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
END OvDis.
