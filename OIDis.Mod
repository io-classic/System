(* begin-module-use-description
Module OIDis disassembles x86_64 opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OIDis** is a disassembler of x86_64 opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.

end-module-develop-description *)
MODULE OIDis;   (*CP 2020*)
  IMPORT SYSTEM, Files, Oberon;
  CONST 
    OK* = 0; FINISH* = 1; BAD* = 2;
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV64=5; RISCV32=6;
    BYTEORIENTED=0; WORDORIENTED=1;

    opUNKN   ="UNKNOWN";
    opBAD    ="BAD";
    opNOP    ="NOP";
    opLDR    ="LDR";
    opSTR    ="STR";
    opMOV    ="MOV";
    opDIV    ="DIV";
    opROL    ="ROL";
    opSHL    ="SHL";
    opROR    ="ROR";
    opSHR    ="SHR";
    opAND    ="AND";
    opOR     ="OR ";
    opSUB    ="SUB";
    opXOR    ="XOR";
    opCMP    ="CMP";
    opADD    ="ADD";
    opADC    ="ADC";
    opSBB    ="SBB";
    opBR     ="BR ";
    opBEQ    ="BEQ";
    opBNE    ="BNE";
    opBGT    ="BGT";
    opBGE    ="BGE";
    opBLT    ="BLT";
    opBLE    ="BLE";
 

  TYPE

  VAR
    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
    mnemo0, reg: ARRAY 16, 4 OF CHAR;  (*mnemonics*)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;

  PROCEDURE append(VAR s1: ARRAY OF CHAR; s2: ARRAY OF CHAR);
    VAR c1,c2: INTEGER;
  BEGIN
    c1:=0; WHILE (c1 < LEN(s1)) & (s1[c1] # 0X) DO INC(c1) END;
    c2:=0; WHILE (c1 < LEN(s1)) & (c2 < LEN(s2)) & (s2[c2] # 0X) DO s1[c1]:=s2[c2];INC(c1);INC(c2) END;
    IF c1 < LEN(s1) THEN s1[c1]:=0X END
  END append;

  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);
    VAR k, op, u, a, b, c: LONGINT;
  BEGIN
    s:="UNDECODED X86_64"
  END opcode;


  PROCEDURE readIn(VAR R: Files.Rider; VAR t: ARRAY OF BYTE; VAR i, pc: INTEGER):CHAR;
  VAR d: CHAR;
  BEGIN
    Files.Read(R, d); t[i]:=ORD(d); INC(pc); INC(i)
  RETURN d
  END readIn;

  PROCEDURE readInteger(VAR R: Files.Rider; VAR t: ARRAY OF BYTE; VAR isz, pc: INTEGER):INTEGER;
  VAR d: CHAR; i,v:INTEGER;
  BEGIN
   
    Files.Read(R, d); t[isz]:=ORD(d); v:=  ORD(d);      INC(pc); INC(isz); 
    Files.Read(R, d); t[isz]:=ORD(d); v:=v+ORD(d) * 100H; INC(pc); INC(isz); 
    Files.Read(R, d); t[isz]:=ORD(d); v:=v+ORD(d) * 10000H; INC(pc); INC(isz); 
    Files.Read(R, d); t[isz]:=ORD(d); v:=v+ORD(d) * 1000000H; INC(pc); INC(isz); 
    
  RETURN v
  END readInteger;


  PROCEDURE regStr(b,r:INTEGER;VAR s:ARRAY OF CHAR);
  BEGIN
    IF ((b=0) OR (b=1)) & (r < 8) THEN
      s[0]:=" ";s[1]:=0X; append(s,reg[b*8+r]);
    ELSE
      s:="BADREG"
    END
  END regStr;

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

  PROCEDURE strHex (x: LONGINT; VAR s: ARRAY OF CHAR);
    VAR t:INTEGER;
  BEGIN
    s[10]:=0X;
    s[9]:="H";
    t:=x MOD 10H;       IF t<10 THEN s[8]:=CHR(t+48) ELSE s[8]:=CHR(t+55) END;
    t:=x DIV 10H MOD 10H;IF t<10 THEN s[7]:=CHR(t+48) ELSE s[7]:=CHR(t+55) END;
    t:=x DIV 100H MOD 10H;IF t<10 THEN s[6]:=CHR(t+48) ELSE s[6]:=CHR(t+55) END;
    t:=x DIV 1000H MOD 10H;IF t<10 THEN s[5]:=CHR(t+48) ELSE s[5]:=CHR(t+55) END;
    t:=x DIV 10000H MOD 10H;IF t<10 THEN s[4]:=CHR(t+48) ELSE s[4]:=CHR(t+55) END;
    t:=x DIV 100000H MOD 10H;IF t<10 THEN s[3]:=CHR(t+48) ELSE s[3]:=CHR(t+55) END;
    t:=x DIV 1000000H MOD 10H;IF t<10 THEN s[2]:=CHR(t+48) ELSE s[2]:=CHR(t+55) END;
    t:=x DIV 10000000H MOD 10H;IF t<10 THEN s[1]:=CHR(t+48) ELSE s[1]:=CHR(t+55) END;
    s[0]:=" ";
  END strHex;

  PROCEDURE decode*():INTEGER;
    VAR e,i,z: INTEGER; b,c,d: CHAR; t: ARRAY 32 OF CHAR; done: BOOLEAN;
  BEGIN
    e := OK;
    at :=pc;
    isz := 0;
    done := FALSE;
    istr := opUNKN;

    Files.Set(R,F,cfo+pc);

    b:=readIn(R,ibytes,isz,pc);
(*    Files.Read(R, b); ibytes[isz]:=ORD(b); INC(pc); INC(isz); *)

    IF b = 90X THEN 
      istr := opNOP
    ELSIF (b = 0E9X) OR (b = 0EBX) OR (b = 0FX) (*(b = 0EBX)*) THEN
      istr := opBR;
      IF b=0EBX THEN
          d:=readIn(R,ibytes,isz,pc);
          strHex(ORD(d),t);
          append(istr,t);
      ELSIF b=0E9X THEN
          i:=readInteger(R,ibytes,isz,pc);
          strHex(i,t);
          append(istr,t);
      ELSE
          c:=readIn(R,ibytes,isz,pc);
          IF c = 0EBX THEN 
          ELSIF (c=074X) OR (c=084X) THEN istr := opBEQ
          ELSIF (c=075X) OR (c=085X) THEN istr := opBNE
          ELSIF (c=07FX) OR (c=08FX) THEN istr := opBGT
          ELSIF (c=07DX) OR (c=08DX) THEN istr := opBGE
          ELSIF (c=06CX) OR (c=07CX) THEN istr := opBLT
          ELSIF (c=07EX) OR (c=08EX) THEN istr := opBLE
          END;
          i:=readInteger(R,ibytes,isz,pc);
          strHex(i,t);
          append(istr,t);
      END
    ELSIF (b = 48X) OR (b = 49X) OR (b = 4CX) OR (b = 4DX) THEN 

      c:=readIn(R,ibytes,isz,pc);
      IF (c =  89X) OR (c = 8BX) THEN d:= readIn(R,ibytes,isz,pc);
        z:=(ORD(b) DIV 4 MOD 2 * 2)+(ORD(b) MOD 2);
        i:=ORD(d) DIV 8 * 8;
	IF (c = 89X) & (i = 0F8H) THEN istr := opMOV 
        ELSIF (c = 89X) & (i = 80H) THEN istr := opSTR 
        ELSIF (c = 8BX) & (i = 80H) THEN istr := opLDR 
        ELSE istr := opBAD 
        END;
        IF z = 0 THEN regStr(0,ORD(d)MOD 8,t); append(istr,t); regStr(0,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
        IF z = 1 THEN regStr(0,ORD(d)MOD 8,t); append(istr,t); regStr(1,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
        IF z = 2 THEN regStr(1,ORD(d)MOD 8,t); append(istr,t); regStr(0,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
        IF z = 3 THEN regStr(1,ORD(d)MOD 8,t); append(istr,t); regStr(1,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
        IF (i = 80H) & ((c=89X)  OR (c=8BX)) THEN
          i:=readInteger(R,ibytes,isz,pc);
          strHex(i,t);
          append(istr,t);
        END;
        IF (z<0) OR (z>3) THEN append(istr, opBAD) END;
      ELSIF c = 0C1X THEN d:= readIn(R,ibytes,isz,pc);
        IF    d = 0C0X THEN istr := opROL
        ELSIF d = 0C8X THEN istr := opROR
        ELSIF d = 0E0X THEN istr := opSHL
        ELSIF d = 0E8X THEN istr := opSHR
        ELSE istr := opBAD
        END
      ELSIF c = 0C7X THEN d:=readIn(R,ibytes,isz,pc);
        istr := opMOV;
        IF b = 48X THEN regStr(0,ORD(d) MOD 8,t); append(istr,t)  END;
        IF b = 49X THEN regStr(1,ORD(d) MOD 8,t); append(istr,t)  END;
        IF (b = 4CX) OR (b = 4DX) THEN append(istr, opBAD) END;
        i:=readInteger(R,ibytes,isz,pc);
        strHex(i,t);
        append(istr,t);
      ELSIF c = 0F7X THEN d:=readIn(R,ibytes,isz,pc);
        i:=ORD(d) DIV 8 * 8;
        IF i = 0E0H THEN istr := opMOV ELSIF i = 0F0H THEN istr := opDIV ELSE istr := opBAD END;
        IF b = 48X THEN regStr(0,ORD(d) MOD 8,t); append(istr,t)  END;
        IF b = 49X THEN regStr(1,ORD(d) MOD 8,t); append(istr,t)  END;
        IF (b = 4CX) OR (b = 4DX) THEN append(istr, opBAD) END;
      ELSIF c =  81X THEN d:=readIn(R,ibytes,isz,pc);
        istr := opBAD;
        i:=ORD(d) DIV 8 * 8;
        IF    i = 0C0H THEN istr := opADD
        ELSIF i = 0C8H THEN istr := opOR
        ELSIF i = 0D0H THEN istr := opADC 
        ELSIF i = 0D8H THEN istr := opSBB  
        ELSIF i = 0E0H THEN istr := opAND
        ELSIF i = 0E8H THEN istr := opSUB
        ELSIF i = 0F0H THEN istr := opXOR
        ELSIF i = 0F8H THEN istr := opCMP
        END;
        IF b = 48X THEN regStr(0,ORD(d) MOD 8,t); append(istr,t)  END;
        IF b = 49X THEN regStr(1,ORD(d) MOD 8,t); append(istr,t)  END;
        IF (b = 4CX) OR (b = 4DX) THEN append(istr, opBAD) END;
        
        i:=readInteger(R,ibytes,isz,pc);
        strHex(i,t);
        append(istr,t);
      ELSIF (c =  01X) OR (c = 09X) OR (c = 11X) OR (c = 19X) OR (c = 21X) OR (c = 29X) OR (c = 31X) OR (c = 39X) THEN d:=readIn(R,ibytes,isz,pc);
        istr := opBAD;
        i:=ORD(d) DIV 8 * 8;
        IF    (c = 001X) & (i = 0F8H) THEN istr := opADD
        ELSIF (c = 009X) & (i = 0F8H) THEN istr := opOR
        ELSIF (c = 011X) & (i = 0F8H) THEN istr := opADC
        ELSIF (c = 019X) & (i = 0F8H) THEN istr := opSBB   
        ELSIF (c = 021X) & (i = 0F8H) THEN istr := opAND
        ELSIF (c = 029X) & (i = 0F8H) THEN istr := opSUB
        ELSIF (c = 031X) & (i = 0F8H) THEN istr := opXOR
        ELSIF (c = 039X) & (i = 0F8H) THEN istr := opCMP
        END;
        IF b = 48X THEN regStr(0,ORD(d)MOD 8,t); append(istr,t); regStr(0,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
        IF b = 49X THEN regStr(0,ORD(d)MOD 8,t); append(istr,t); regStr(0,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
        IF b = 4CX THEN regStr(0,ORD(d)MOD 8,t); append(istr,t); regStr(0,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
        IF b = 4DX THEN regStr(0,ORD(d)MOD 8,t); append(istr,t); regStr(0,ORD(d)DIV 8 MOD 8,t); append(istr,t); END;
(*        i:=readInteger(R,ibytes,isz,pc);
        strHex(i,t);
        append(istr,t); *)
      ELSE istr := opBAD
      END
    END;
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
  wo:= BYTEORIENTED;
  vendor := 0;
  mode := 64;
  at := 0;
  pc := 0;
  isz := 0;
  istr := "undecoded x86_64";
  cfo := 0;
  cfe := 0;
  reg[0]:="RAX";
  reg[1]:="RCX";
  reg[2]:="RDX";
  reg[3]:="RBX";
  reg[4]:="RSP";
  reg[5]:="RBP";
  reg[6]:="RSI";
  reg[7]:="RDI";
  reg[8]:="R8 ";
  reg[9]:="R9 ";
  reg[10]:="R10";
  reg[11]:="R11";
  reg[12]:="R12";
  reg[13]:="R13";
  reg[14]:="R14";
  reg[15]:="R15";
END OIDis.
