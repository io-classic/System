(* begin-module-use-description
Module OVDis disassembles 64-bit RISCV opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OVDis** is a disassembler of 64-bit RISCV opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.

end-module-develop-description *)
MODULE OVDis;   (*CP 2020*)
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

  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);
    VAR k, op, u, a, b, c: LONGINT;
  BEGIN
    IF (w DIV 8000000H MOD 1 = 0) THEN
      IF (w DIV 10000000H MOD 1 = 0) THEN
        s:="UNALLOCATED"
      ELSE
        IF (w DIV 4000000H MOD 1 = 0) THEN
	  s:="IMMEDIATE"
        ELSE
          s:="BRANCH"
        END
      END
    ELSE
      IF (w DIV 2000000H MOD 1 = 0) THEN
        s:="LOAD/STORE"
      ELSE
        IF (w DIV 4000000H MOD 1 = 0) THEN
          s:="DP REGISTER"
        ELSE
          s:="DP SIMD"
        END
      END
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
  E := 0;
  wo := WORDORIENTED;
  vendor := 0;
  mode := 64;
  at := 0;
  pc := 0;
  isz := 0;
  istr := "undecoded riscv 64";
  cfo := 0;
  cfe := 0;
END OVDis.
