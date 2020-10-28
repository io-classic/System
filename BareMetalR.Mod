(* begin-module-use-description
Module BareMetalR exercises features of the compiler in bringing Oberon up from bare metal on RISC5.

end-module-use-description *)
(* begin-module-develop-description
Module BareMetalR exercises features of the compiler in bringing Oberon up from bare metal on RISC5.

end-module-develop-description *)
MODULE* BareMetalR;
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
END BareMetalR.
