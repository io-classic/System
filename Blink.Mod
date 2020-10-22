(* begin-package-description
### _Package Overview:_
The Extras package provides:

Example modules demonstrating the use of Oberon.

### _Package Use:_

USAGE:
```
Blink.Run
```

### _Modules in this package:_
end-package-description *)

(* begin-module-use-description
Module Edit provides document editing capability.

end-module-use-description *)
MODULE Blink;   (*NW 30.5.2013*)
  IMPORT SYSTEM, Oberon;
  VAR z: INTEGER;
    T: Oberon.Task;
  
  PROCEDURE Run*;
  BEGIN Oberon.Install(T)
  END Run;

  PROCEDURE Stop*;
  BEGIN Oberon.Remove(T)
  END Stop;

  PROCEDURE Tick;
  BEGIN z := 1-z; LED(z)
  END Tick;

BEGIN z := 0; T := Oberon.NewTask(Tick, 500)
END Blink.
