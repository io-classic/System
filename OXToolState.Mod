(* begin-module-use-description
Module OXToolState describes the current architecture independent state of an object file being disassembled.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OXToolState** describes the current architecture independent state of an object file being disassembled.

end-module-develop-description *)
MODULE OXToolState;   (*CP 2020*)
  IMPORT SYSTEM, Files;
  CONST
    OK* = 0; FINISH* = 1; BAD* = 2;

  TYPE

  VAR
    E*, at*, pc*, isz*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;

  PROCEDURE setE*(i:INTEGER);
  BEGIN
    E := i;
  END setE;

  PROCEDURE setat*(i:INTEGER);
  BEGIN
    at := i;
  END setat;

  PROCEDURE setpc*(i:INTEGER);
  BEGIN
    pc := i;
  END setpc;

  PROCEDURE movepc*(i: INTEGER);
  BEGIN
    pc := pc + i;
  END movepc;

  PROCEDURE setisz*(i:INTEGER);
  BEGIN
    isz := i;
  END setisz;

  PROCEDURE setibytes*(i:INTEGER; b: BYTE);
  BEGIN
    ibytes[i] := b;
  END setibytes;

  PROCEDURE setistr*(s:ARRAY OF CHAR);
  BEGIN
    istr := s;
  END setistr;

  PROCEDURE Rbyte*(a:INTEGER):CHAR;
    VAR ch:CHAR;
  BEGIN
    Files.Set(R,F,cfo+a);
    Files.Read(R, ch);
  RETURN ch
  END Rbyte;

  PROCEDURE Rpos*():INTEGER;
  BEGIN
  RETURN Files.Pos(R)
  END Rpos;

  PROCEDURE seek*(address: INTEGER): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e := OK;
    pc := address;
    Files.Set(R,F,cfo+pc)
    RETURN e
  END seek;

  PROCEDURE init*(VAR f: Files.File; i, o, e: INTEGER);
  BEGIN
    F := f;
    pc := i;
    at := i;
    cfo := o;
    cfe := e;
    Files.Set(R, f, cfo+pc);
  END init;


BEGIN
  E := 0;
  vendor := 0;
  mode := 64;
  at := 0;
  pc := 0;
  isz := 0;
  istr := "undecoded";
  cfo := 0;
  cfe := 0;
END OXToolState.


