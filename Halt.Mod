(* begin-module-use-description
Module Halt halts the processor in some emulators of RISC Oberon.

end-module-use-description *)
MODULE Halt;   (*CP 27.10.2020*)
  IMPORT SYSTEM;

  CONST
    halt = -32; 

  TYPE

  VAR

  PROCEDURE Halt*(x: INTEGER);
  BEGIN
    SYSTEM.PUT(halt, x)
  END Halt;

  PROCEDURE Now*;
  BEGIN
    Halt(0)
  END Now;
  
BEGIN 
END Halt.
