MODULE Fail;   (*NW 30.5.2013, CP 2021*)
  IMPORT SYSTEM, Oberon;

  CONST

  TYPE 
    R = POINTER TO RDesc;
    RDesc = RECORD
     a: ARRAY 4 OF INTEGER
    END;

  VAR 
    z, led, cnt: INTEGER;
    T: Oberon.Task;

   
  (* begin-procedure-description
---
**Run** fields the system millisecond interrupt and toggles the LED every half second.
  end-procedure-description *)
  PROCEDURE Run*;
  BEGIN Oberon.Install(T)
  END Run;


  (* begin-procedure-description
---
**Stop** fields the system millisecond interrupt and toggles the LED every half second.
  end-procedure-description *)
  PROCEDURE Stop*;
  BEGIN Oberon.Remove(T)
  END Stop;


  (* begin-procedure-description
---
**Int** fields the system millisecond interrupt and toggles the LED every half second.
  end-procedure-description *)
  PROCEDURE Tick;
  BEGIN INC(z); LED(z);
    IF z > 5 THEN
      z := 0; ASSERT(FALSE)
    END
  END Tick;


  (* begin-procedure-description
---
**Int** fields the system millisecond interrupt and toggles the LED every half second.
  end-procedure-description *)
  PROCEDURE* Int; (*interrupt handler called every millisecond*)
  BEGIN 
    INC(cnt);
    IF cnt = 500 THEN led := 3 - led; LED(led); cnt := 0 END 
  END Int;


  (* begin-procedure-description
---
**On** enables the system millisecond interrupt.
  end-procedure-description *)
  PROCEDURE On*;
  BEGIN SYSTEM.LDPSR(1)
  END On;


  (* begin-procedure-description
---
**Off** disables the system millisecond interrupt.
  end-procedure-description *)
  PROCEDURE Off*;
  BEGIN SYSTEM.LDPSR(0)
  END Off;


  (* begin-procedure-description
---
**Bounds** generates a bounds check failure.
  end-procedure-description *)
  PROCEDURE Bounds*;
    VAR rd: RDesc; x,i: INTEGER;
  BEGIN 
    x:=0; WHILE x < 10 DO i:=rd.a[x]; INC(x) END  (* out of bounds error *)
  END Bounds;


  (* begin-procedure-description
---
**Assert** generates an assertion failure.
  end-procedure-description *)
  PROCEDURE Assert*;
  BEGIN ASSERT(FALSE)
  END Assert;


  (* begin-procedure-description
---
**Nil** generates a nil pointer dereference.
  end-procedure-description *)
  PROCEDURE Nil*;
    VAR r: R; i: INTEGER;
  BEGIN i:=r.a[0]  (* nil pointer error *)
  END Nil;


  (* begin-procedure-description
---
**The initialzation code for this module** installs the Int interrupt procedure in the system interrupt vector.
  end-procedure-description *)
BEGIN 
  z := 0; T := Oberon.NewTask(Tick, 500);
  led := 1; cnt := 0; (*install Int at address 4*)
  SYSTEM.PUT(4, 0E7000000H + (SYSTEM.ADR(Int) DIV 4) - 2) (* relative forward branch with pc already incremented *) 
END Fail.
