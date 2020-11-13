(* begin-module-use-description
Module OXDis provides an interface for disassembling opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OXDis** provides an interface for disassembling opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.

end-module-develop-description *)
MODULE OXDis;   (*CP 2020*)
  IMPORT SYSTEM, Files, ORDis, OIDis, OADis, OaDis, OvDis;
  CONST
    OK* = 0; FINISH* = 1; BAD* = 2;
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV=5; 
    BYTEORIENTED=0; WORDORIENTED=1;
  TYPE

  VAR
    E*, at*, pc*, isz*, Arch*,wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;

  PROCEDURE decode*():INTEGER;
    VAR e,i: INTEGER; b: CHAR; t: ARRAY 32 OF CHAR;
  BEGIN
    e := BAD;
    IF Arch = RISC5 THEN 
      e := ORDis.decode();
      at:=ORDis.at;
      pc:=ORDis.pc;
      isz:=ORDis.isz;
      ibytes:=ORDis.ibytes;
      istr:=ORDis.istr;
    END;
    IF Arch = X8664 THEN
      e := OIDis.decode();
      at:=OIDis.at;
      pc:=OIDis.pc;
      isz:=OIDis.isz;
      ibytes:=OIDis.ibytes;
      istr:=OIDis.istr;
    END;
    IF Arch = AARCH64 THEN
      e := OADis.decode();
      at:=OADis.at;
      pc:=OADis.pc;
      isz:=OADis.isz;
      ibytes:=OADis.ibytes;
      istr:=OADis.istr;
    END;
    IF Arch = ARM32 THEN
      e := OaDis.decode();
      at:=OaDis.at;
      pc:=OaDis.pc;
      isz:=OaDis.isz;
      ibytes:=OaDis.ibytes;
      istr:=OaDis.istr;
    END;
    IF Arch = RISCV THEN
      e := OvDis.decode();
      at:=OvDis.at;
      pc:=OvDis.pc;
      isz:=OvDis.isz;
      ibytes:=OvDis.ibytes;
      istr:=OvDis.istr;
    END;
    E:=e;
    RETURN e
  END decode;

  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index, arch: INTEGER): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e := BAD;
    Arch:=arch;
    IF Arch = RISC5   THEN e := ORDis.originate(r,f,offset,extent,index); wo:=ORDis.wo END;
    IF Arch = X8664   THEN e := OIDis.originate(r,f,offset,extent,index); wo:=OIDis.wo END;
    IF Arch = AARCH64 THEN e := OADis.originate(r,f,offset,extent,index); wo:=OADis.wo END;
    IF Arch = ARM32   THEN e := OaDis.originate(r,f,offset,extent,index); wo:=OaDis.wo END;
    IF Arch = RISCV   THEN e := OvDis.originate(r,f,offset,extent,index); wo:=OvDis.wo END;
    E:=e;
  RETURN e
  END originate;

BEGIN
  E := 0;
  at := 0;
  pc := 0;
  isz := 0;
  istr := "uninitialized decoder";
END OXDis.
