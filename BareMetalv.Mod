(* begin-module-use-description
Module BareMetalv exercises features of the compiler in bringing Oberon up from bare metal on 32-bit RISCV.

end-module-use-description *)
(* begin-module-develop-description
Module BareMetalv exercises features of the compiler in bringing Oberon up from bare metal on 32-bit RISCV.

end-module-develop-description *)
MODULE* BareMetalv;
  CONST
  TYPE
  VAR x, y, z: INTEGER;

BEGIN LED(1); z := 0;
  REPEAT LED(z); x := 1000;
     REPEAT y := 1000;
       REPEAT y := y-1 UNTIL y = 0;
       x := x-1
     UNTIL x = 0;
     z := z+1
  UNTIL FALSE
END BareMetalv.
