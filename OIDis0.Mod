(* begin-module-use-description
Module OIDis disassembles x86_64 opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OIDis** is a disassembler of x86_64 opcodes.
Rewritten from pymsasid3 (matthieu.kaczmarek@mines-nancy.org) which was rewritten from udis86 (Vivek Mohan <vivek@sig9.com>)

The module sets up a state machine that operates on an input via repeated calls to decode.

OIDis uses OIDisOperand for definitions of opcode operands.

end-module-develop-description *)
MODULE OIDis;   (*CP 2020*)
  IMPORT SYSTEM, Files, Oberon, S:=OToolState, OIDisOperand, OIDisItab, OIDisDecode;
  CONST 
(*    OK* = 0; FINISH* = 1; BAD* = 2; *)

  TYPE

  VAR

  PROCEDURE seek(address: INTEGER): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e := S.OK;
    S.setpc(address);
    e := S.seek(address);
    RETURN e
  END seek;

  PROCEDURE decode*():INTEGER;
  BEGIN
    RETURN OIDisDecode.decode()
  END decode;

  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index: INTEGER): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e:=S.OK;
    S.init(f,index,offset,extent);
    S.setE(e);
    RETURN e
  END originate;

BEGIN (*
  E := 0;
  vendor := OIDisOperand.INTEL;
  mode := 64;
  at := 0;
  pc := 0;
  isz := 0;
  istr := "undecoded";
  cfo := 0;
  cfe := 0; *)
END OIDis.
