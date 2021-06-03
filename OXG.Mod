(* begin-module-short-description
implements processor-agnostic code generation.
end-module-short-description *)

(* begin-module-use-description
Module OXG generates the processor-specific instructions for executing an Oberon program. 

OXG uses SYSTEM, Files, OXS, OXB, OXT, OXX


end-module-use-description *)
(* begin-module-develop-description

(N.Wirth, 16.4.2016 / 4.4.2017 / 31.5.2019  Oberon compiler; code generator for RISC)

**OXG** is called from ORP and generates machine code various Oberon language constructs for the Oberon RISC5 architeture.

end-module-develop-description *)
MODULE OXG; (* N.Wirth, 16.4.2016 / 4.4.2017 / 31.5.2019  Oberon compiler; code generator for RISC*)
  IMPORT SYSTEM, Files, OXS, OXB, OXT, OXX;
  (*Code generator for Oberon compiler for RISC processor.
     Procedural interface to Parser OSAP; result in array "code".
     Procedure Close writes code-files*)

  CONST
    StkOrg0 = -64; VarOrg0 = 0;  (*for RISC-0 only*)
    MT = 12; TL = 13; SP = 14; LNK = 15;   (*dedicated registers*)
    maxCode = 10000; maxStrx = 6400; maxTD = 160; C24 = 1000000H;
    Reg = 10; RegI = 11; Cond = 12;  (*internal item modes*)

  (*frequently used opcodes*)  U = 2000H; V = 1000H;
    Mov = 0; Lsl = 1; Asr = 2; Ror= 3; And = 4; Ann = 5; Ior = 6; Xor = 7;
    Add = 8; Sub = 9; Cmp = 9; Mul = 10; Div = 11;
    Fad = 12; Fsb = 13; Fml = 14; Fdv = 15; MovU = 16;
    Ldr = 8; Str = 10;
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;

  TYPE 
    Item* = RECORD
      mode*: INTEGER;
      type*: OXB.Type;
      a*, b*, r: LONGINT;
      rdo*: BOOLEAN  (*read only*)
    END ;

  (* Item forms and meaning of fields:
    mode    r      a       b
    --------------------------------
    Const   -     value (proc adr)  (immediate value)
    Var     base   off     -               (direct adr)
    Par      -     off0     off1         (indirect adr)
    Reg    regno
    RegI   regno   off     -
    Cond  cond   Fchain  Tchain  *)

  VAR 
    pc*, pcb*, varsize: LONGINT;   (*program counter, data index*)
    tdx, strx: LONGINT;
    entry: LONGINT;   (*main entry point*)
    RH: LONGINT;  (*available registers R[0] ... R[H-1]*)
    frame: LONGINT;  (*frame offset changed in SaveRegs and RestoreRegs*)
    check: BOOLEAN;  (*emit run-time checks*)
    version: INTEGER;  (* 0 = RISC-0, 1 = RISC-5 *)
    relmap: ARRAY 6 OF INTEGER;  (*condition codes for relations*)
    xPut0: PROCEDURE  (VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
    xPut1: PROCEDURE  (o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
    xPut1a: PROCEDURE (o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
    xPut2: PROCEDURE  (VAR pc, pcb: LONGINT; op, a, b, off: LONGINT);
    xPut3: PROCEDURE  (VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    xHeader: PROCEDURE (VAR pc, pcb, RH, entry, version: LONGINT);

  (* begin-section-description
## ---------- Instruction assemblers according to formats
  end-section-description *)

  PROCEDURE incR;
  BEGIN
    IF RH < MT-1 THEN INC(RH) ELSE OXS.Mark("register stack overflow") END
  END incR;

  PROCEDURE CheckRegs*;
  BEGIN
    IF RH # 0 THEN OXS.Mark("Reg Stack"); RH := 0 END ;
    IF pc >= maxCode - 40 THEN OXS.Mark("program too long") END ;
    IF frame # 0 THEN OXS.Mark("frame error"); frame := 0 END
  END CheckRegs;

  PROCEDURE SetCC(VAR x: Item; n: LONGINT);
  BEGIN x.mode := Cond; x.a := 0; x.b := 0; x.r := n
  END SetCC;

  PROCEDURE Trap(cond, num: LONGINT);
  BEGIN xPut3(pc, pcb, BLR, cond, OXS.Pos()*100H + num*10H + MT)
  END Trap;

  (* begin-section-description
## ---------- Handling of forward reference, fixups of instruction operands
  end-section-description *)

  PROCEDURE negated(cond: LONGINT): LONGINT;
  BEGIN
    IF cond < 8 THEN cond := cond+8 ELSE cond := cond-8 END ;
    RETURN cond
  END negated;

  PROCEDURE FixOne*(at: LONGINT);
  BEGIN OXX.fix(at, pc-at-1)
  END FixOne;

  PROCEDURE FixLink*(L: LONGINT);
  BEGIN
    OXX.FixLink(pc,pcb,L)
  END FixLink;


  (* begin-section-description
## ----------  Loading of operands and addresses into registers
  end-section-description *)

  (* begin-procedure-description
---
**GetSB** loads the static base of a module
  end-procedure-description *)
  PROCEDURE GetSB(base: LONGINT);
  BEGIN
    IF version = 0 THEN xPut1(5, pc, pcb, Mov, RH, 0, VarOrg0)
    ELSE xPut2(pc, pcb, Ldr, RH, -base, pc-OXX.fixorgD); OXX.setFixOrgD(pc-1)
    END
  END GetSB;

  (* begin-procedure-description
---
**NilCheck** ensures a pointer is not NIL
  end-procedure-description *)
  PROCEDURE NilCheck;
  BEGIN IF check THEN Trap(EQ, 4) END
  END NilCheck;

  (* begin-procedure-description
---
**load** generates loading the contents of a variable
  end-procedure-description *)
  PROCEDURE load(VAR x: Item);
    VAR op,q: LONGINT;
  BEGIN
    IF x.type.size = 1 THEN op := Ldr+1 ELSE op := Ldr END ;
    IF x.mode # Reg THEN
      IF x.mode = OXB.Const THEN
        IF x.type.form = OXB.Proc THEN
          IF x.r > 0 THEN OXS.Mark("not allowed")
          ELSIF x.r = 0 THEN xPut3(pc, pcb, BL, 7, 0); xPut1a(80, pc, pcb, RH, Sub, RH, LNK, pc*4 - x.a)
          ELSE GetSB(x.r); xPut1(6, pc, pcb, Add, RH, RH, x.a + 100H) (*mark as progbase-relative*)
          END
        ELSIF (x.a <= 0FFFFH) & (x.a >= -10000H) THEN xPut1(7, pc, pcb, Mov, RH, 0, x.a)
        ELSE xPut1a(8, pc, pcb, RH, Mov, RH, 0, x.a)
          (* xPut1(8, pc, pcb, MovU, RH, 0, x.a DIV 10000H MOD 10000H);
             IF x.a MOD 10000H # 0 THEN xPut1(9, pc, pcb, Ior, RH, RH, x.a MOD 10000H) END;  *)
        END ;
        x.r := RH; incR
      ELSIF x.mode = OXB.Var THEN
        IF x.r > 0 THEN (*local*) xPut2(pc, pcb, op, RH, SP, x.a + frame)
        ELSE GetSB(x.r); xPut2(pc, pcb, op, RH, RH, x.a)
        END ;
        x.r := RH; incR
      ELSIF x.mode = OXB.Par THEN xPut2(pc, pcb, Ldr, RH, SP, x.a + frame); xPut2(pc, pcb, op, RH, RH, x.b); x.r := RH; incR
      ELSIF x.mode = RegI THEN xPut2(pc, pcb, op, x.r, x.r, x.a)
      ELSIF x.mode = Cond THEN
        xPut3(pc, pcb, BC, negated(x.r), 2);
        OXX.FixLink(pc,pcb,x.b); xPut1(10, pc, pcb, Mov, RH, 0, 1); xPut3(pc, pcb, BC, 7, 1);
        OXX.FixLink(pc,pcb,x.a); xPut1(11, pc, pcb, Mov, RH, 0, 0); x.r := RH; incR
      END ;
      x.mode := Reg
    END;

  END load;

  (* begin-procedure-description
---
**loadAdr** generates loading the location of a variable
  end-procedure-description *)
  PROCEDURE loadAdr(VAR x: Item);
  BEGIN
    IF x.mode = OXB.Var THEN
      IF x.r > 0 THEN (*local*) xPut1a(81, pc, pcb, RH, Add, RH, SP, x.a + frame)
      ELSE GetSB(x.r); xPut1a(82, pc, pcb, RH, Add, RH, RH, x.a)
      END ;
      x.r := RH; incR
    ELSIF x.mode = OXB.Par THEN xPut2(pc, pcb, Ldr, RH, SP, x.a + frame);
      IF x.b # 0 THEN xPut1a(83, pc, pcb, RH, Add, RH, RH, x.b) END ;
      x.r := RH; incR
    ELSIF x.mode = RegI THEN
      IF x.a # 0 THEN xPut1a(84, pc, pcb, RH, Add, x.r, x.r, x.a) END
    ELSE OXS.Mark("address error")
    END ;
    x.mode := Reg
  END loadAdr;

  (* begin-procedure-description
---
**loadCond** generates loading a boolean
  end-procedure-description *)
  PROCEDURE loadCond(VAR x: Item);
  BEGIN
    IF x.type.form = OXB.Bool THEN
      IF x.mode = OXB.Const THEN x.r := 15 - x.a*8
      ELSE load(x);
        IF OXX.code[pc-1] DIV 40000000H # -2 THEN xPut1(12, pc, pcb, Cmp, x.r, x.r, 0) END ;
        x.r := NE; DEC(RH)
      END ;
      x.mode := Cond; x.a := 0; x.b := 0
    ELSE OXS.Mark("not Boolean?")
    END
  END loadCond;

  (* begin-procedure-description
---
**loadTypTagAdr** generates loading a type tag address
  end-procedure-description *)
  PROCEDURE loadTypTagAdr(T: OXB.Type);
    VAR x: Item;
  BEGIN x.mode := OXB.Var; x.a := T.len; x.r := -T.mno; loadAdr(x)
  END loadTypTagAdr;

  (* begin-procedure-description
---
**loadStringAdr** generates loading a string address
  end-procedure-description *)
  PROCEDURE loadStringAdr(VAR x: Item);
  BEGIN GetSB(0); xPut1a(85, pc, pcb, RH, Add, RH, RH, varsize+x.a); x.mode := Reg; x.r := RH; incR
  END loadStringAdr;

  (* Items: Conversion from constants or from Objects on the Heap to Items on the Stack*)

  (* begin-section-description
## ----------  Items: Conversion from constants or from Objects on the Heap to Items on the Stack
  end-section-description *)

  (* begin-procedure-description
---
**MakeConstItem** prepares
  end-procedure-description *)
  PROCEDURE MakeConstItem*(VAR x: Item; typ: OXB.Type; val: LONGINT);
  BEGIN x.mode := OXB.Const; x.type := typ; x.a := val
  END MakeConstItem;

  (* begin-procedure-description
---
**MakeRealItem** prepares
  end-procedure-description *)
  PROCEDURE MakeRealItem*(VAR x: Item; val: REAL);
  BEGIN x.mode := OXB.Const; x.type := OXB.realType; x.a := SYSTEM.VAL(LONGINT, val)
  END MakeRealItem;


  (* begin-procedure-description
---
**MakeStringItem** prepares
  end-procedure-description *)
  PROCEDURE MakeStringItem*(VAR x: Item; len: LONGINT); (*copies string from OXS-buffer to OXG-string array*)
    VAR i: LONGINT;
  BEGIN x.mode := OXB.Const; x.type := OXB.strType; x.a := strx; x.b := len; OXX.InternString(strx,len)
(*
    i := 0;
    IF strx + len + 4 < maxStrx THEN
      WHILE len > 0 DO str[strx] := OXS.str[i]; INC(strx); INC(i); DEC(len) END ;
      WHILE strx MOD 4 # 0 DO str[strx] := 0X; INC(strx) END
    ELSE OXS.Mark("too many strings")
    END
*)
  END MakeStringItem;


  (* begin-procedure-description
---
**MakeItem** prepares
  end-procedure-description *)
  PROCEDURE MakeItem*(VAR x: Item; y: OXB.Object; curlev: LONGINT);
  BEGIN x.mode := y.class; x.type := y.type; x.a := y.val; x.rdo := y.rdo;
    IF y.class = OXB.Par THEN x.b := 0
    ELSIF (y.class = OXB.Const) & (y.type # NIL) & (y.type.form = OXB.String) THEN x.b := y.lev  (*len*) ;
    ELSE x.r := y.lev
    END ;
    IF (y.lev > 0) & (y.lev # curlev) & (y.class # OXB.Const) THEN OXS.Mark("not accessible ") END
  END MakeItem;

  (* Code generation for Selectors, Variables, Constants *)

  (* begin-section-description
## ----------  Code generation for Selectors, Variables, Constants
  end-section-description *)

  (* begin-procedure-description
---
**Field** locates a record field
  end-procedure-description *)
  PROCEDURE Field*(VAR x: Item; y: OXB.Object);   (* x := x.y *)
  BEGIN;
    IF x.mode = OXB.Var THEN
      IF x.r >= 0 THEN x.a := x.a + y.val
      ELSE loadAdr(x); x.mode := RegI; x.a := y.val
      END
    ELSIF x.mode = RegI THEN x.a := x.a + y.val
    ELSIF x.mode = OXB.Par THEN x.b := x.b + y.val
    END
  END Field;

  (* begin-procedure-description
---
**Index** locates an array element
  end-procedure-description *)
  PROCEDURE Index*(VAR x, y: Item);   (* x := x[y] *)
    VAR s, lim: LONGINT;
  BEGIN s := x.type.base.size; lim := x.type.len;
    IF (y.mode = OXB.Const) & (lim >= 0) THEN
      IF (y.a < 0) OR (y.a >= lim) THEN OXS.Mark("bad index") END ;
      IF x.mode IN {OXB.Var, RegI} THEN x.a := y.a * s + x.a
      ELSIF x.mode = OXB.Par THEN x.b := y.a * s + x.b
      END
    ELSE load(y);
      IF check THEN  (*check array bounds*)
        IF lim >= 0 THEN xPut1a(86, pc, pcb, RH, Cmp, RH, y.r, lim)
        ELSE (*open array*)
          IF x.mode IN {OXB.Var, OXB.Par} THEN xPut2(pc, pcb, Ldr, RH, SP, x.a+4+frame); xPut0( pc, pcb, Cmp, RH, y.r, RH)
          ELSE OXS.Mark("error in Index")
          END
        END ;
        Trap(10, 1)  (*BCC*)
      END ;
      IF s = 4 THEN xPut1(13, pc, pcb, Lsl, y.r, y.r, 2) ELSIF s > 1 THEN xPut1a(87, pc, pcb, RH, Mul, y.r, y.r, s) END ;
      IF x.mode = OXB.Var THEN
        IF x.r > 0 THEN xPut0( pc, pcb, Add, y.r, SP, y.r); INC(x.a, frame)
        ELSE GetSB(x.r);
          IF x.r = 0 THEN xPut0( pc, pcb, Add, y.r, RH, y.r)
          ELSE xPut1a(88, pc, pcb, RH, Add, RH, RH, x.a); xPut0( pc, pcb, Add, y.r, RH, y.r); x.a := 0
          END
        END ;
        x.r := y.r; x.mode := RegI
      ELSIF x.mode = OXB.Par THEN
        xPut2(pc, pcb, Ldr, RH, SP, x.a + frame);
        xPut0( pc, pcb, Add, y.r, RH, y.r); x.mode := RegI; x.r := y.r; x.a := x.b
      ELSIF x.mode = RegI THEN xPut0( pc, pcb, Add, x.r, x.r, y.r); DEC(RH)
      END
    END
  END Index;

  (* begin-procedure-description
---
**DeRef** generates a dereference
  end-procedure-description *)
  PROCEDURE DeRef*(VAR x: Item);
  BEGIN
    IF x.mode = OXB.Var THEN
      IF x.r > 0 THEN (*local*) xPut2(pc, pcb, Ldr, RH, SP, x.a + frame) ELSE GetSB(x.r); xPut2(pc, pcb, Ldr, RH, RH, x.a) END ;
      NilCheck; x.r := RH; incR
    ELSIF x.mode = OXB.Par THEN
      xPut2(pc, pcb, Ldr, RH, SP, x.a + frame); xPut2(pc, pcb, Ldr, RH, RH, x.b); NilCheck; x.r := RH; incR
    ELSIF x.mode = RegI THEN xPut2(pc, pcb, Ldr, x.r, x.r, x.a); NilCheck
    ELSIF x.mode # Reg THEN OXS.Mark("bad mode in DeRef")
    END ;
    x.mode := RegI; x.a := 0; x.b := 0
  END DeRef;

  (* begin-procedure-description
---
**Q** prepares
  end-procedure-description *)
  PROCEDURE Q(T: OXB.Type; VAR dcw: LONGINT);
  BEGIN (*one entry of type descriptor extension table*)
    IF T.base # NIL THEN
      Q(T.base, dcw); OXX.SetData(dcw, (T.mno*1000H + T.len) * 1000H + dcw - OXX.fixorgT);
      OXX.setFixOrgT(dcw); INC(dcw)
    END
  END Q;

  (* begin-procedure-description
---
**FindPtrFlds** prepares
  end-procedure-description *)
  PROCEDURE FindPtrFlds(typ: OXB.Type; off: LONGINT; VAR dcw: LONGINT);
    VAR fld: OXB.Object; i, s: LONGINT;
  BEGIN
    IF (typ.form = OXB.Pointer) OR (typ.form = OXB.NilTyp) THEN OXX.SetData(dcw, off); INC(dcw)
    ELSIF typ.form = OXB.Record THEN
      fld := typ.dsc;
      WHILE fld # NIL DO FindPtrFlds(fld.type, fld.val + off, dcw); fld := fld.next END
    ELSIF typ.form = OXB.Array THEN
      s := typ.base.size;
      FOR i := 0 TO typ.len-1 DO FindPtrFlds(typ.base, i*s + off, dcw) END
    END
  END FindPtrFlds;

  (* begin-procedure-description
---
**BuildTD** prepares
  end-procedure-description *)
  PROCEDURE BuildTD*(T: OXB.Type; VAR dc: LONGINT);
    VAR dcw, k, s: LONGINT;  (*dcw = word address*)
  BEGIN dcw := dc DIV 4; s := T.size; (*convert size for heap allocation*)
    IF s <= 24 THEN s := 32 ELSIF s <= 56 THEN s := 64 ELSIF s <= 120 THEN s := 128
    ELSE s := (s+263) DIV 256 * 256
    END ;
    T.len := dc; OXX.SetData(dcw, s); INC(dcw);  (*len used as address*)
    k := T.nofpar;   (*extension level!*)
    IF k > 3 THEN OXS.Mark("ext level too large")
    ELSE Q(T, dcw);
      WHILE k < 3 DO OXX.SetData(dcw, -1); INC(dcw); INC(k) END
    END ;
    FindPtrFlds(T, 0, dcw); OXX.SetData(dcw, -1); INC(dcw); tdx := dcw; dc := dcw*4;
    IF tdx >= maxTD THEN OXS.Mark("too many record types"); tdx := 0 END
  END BuildTD;

  (* begin-procedure-description
---
**TypeTest** generates a type test
  end-procedure-description *)
  PROCEDURE TypeTest*(VAR x: Item; T: OXB.Type; varpar, isguard: BOOLEAN);
    VAR pc0: LONGINT;
  BEGIN
    IF T = NIL THEN
      IF x.mode >= Reg THEN DEC(RH) END ;
      SetCC(x, 7)
    ELSE (*fetch tag into RH*)
      IF varpar THEN xPut2(pc, pcb, Ldr, RH, SP, x.a+4+frame)
      ELSE load(x);
        pc0 := pc; xPut3(pc, pcb, BC, EQ, 0);  (*NIL belongs to every pointer type*)
        xPut2(pc, pcb, Ldr, RH, x.r, -8)
      END ;
      xPut2(pc, pcb, Ldr, RH, RH, T.nofpar*4); incR;
      loadTypTagAdr(T);  (*tag of T*)
      xPut0( pc, pcb, Cmp, RH-1, RH-1, RH-2); DEC(RH, 2);
      IF ~varpar THEN OXX.fix(pc0, pc - pc0 - 1) END ;
      IF isguard THEN
        IF check THEN Trap(NE, 2) END
      ELSE SetCC(x, EQ);
        IF ~varpar THEN DEC(RH) END
      END
    END
  END TypeTest;

  (* Code generation for Boolean operators *)

  (* begin-section-description
## ----------  Code generation for Boolean operators
  end-section-description *)

  (* begin-procedure-description
---
**Not** generates
  end-procedure-description *)
  PROCEDURE Not*(VAR x: Item);   (* x := ~x *)
    VAR t: LONGINT;
  BEGIN
    IF x.mode # Cond THEN loadCond(x) END ;
    x.r := negated(x.r); t := x.a; x.a := x.b; x.b := t
  END Not;

  (* begin-procedure-description
---
**And1** generates
  end-procedure-description *)
  PROCEDURE And1*(VAR x: Item);   (* x := x & *)
  BEGIN
    IF x.mode # Cond THEN loadCond(x) END ;
    xPut3(pc, pcb, BC, negated(x.r), x.a); x.a := pc-1; OXX.FixLink(pc,pcb,x.b); x.b := 0
  END And1;

  (* begin-procedure-description
---
**And2** generates
  end-procedure-description *)
  PROCEDURE And2*(VAR x, y: Item);
  BEGIN
    IF y.mode # Cond THEN loadCond(y) END ;
    x.a := OXX.merged(y.a, x.a); x.b := y.b; x.r := y.r
  END And2;

  (* begin-procedure-description
---
**Or1** generates
  end-procedure-description *)
  PROCEDURE Or1*(VAR x: Item);   (* x := x OR *)
  BEGIN
    IF x.mode # Cond THEN loadCond(x) END ;
    xPut3(pc, pcb, BC, x.r, x.b);  x.b := pc-1; OXX.FixLink(pc,pcb,x.a); x.a := 0
  END Or1;

  (* begin-procedure-description
---
**Or2** generates
  end-procedure-description *)
  PROCEDURE Or2*(VAR x, y: Item);
  BEGIN
    IF y.mode # Cond THEN loadCond(y) END ;
    x.a := y.a; x.b := OXX.merged(y.b, x.b); x.r := y.r
  END Or2;

  (* Code generation for arithmetic operators *)

  (* begin-section-description
## ----------  Code generation for arithmetic operators
  end-section-description *)

  PROCEDURE Neg*(VAR x: Item);   (* x := -x *)
  BEGIN
    IF x.type.form = OXB.Int THEN
      IF x.mode = OXB.Const THEN x.a := -x.a
      ELSE load(x); xPut1(14, pc, pcb, Mov, RH, 0, 0); xPut0( pc, pcb, Sub, x.r, RH, x.r)
      END
    ELSIF x.type.form = OXB.Real THEN
      IF x.mode = OXB.Const THEN x.a := x.a + 7FFFFFFFH + 1
      ELSE load(x); xPut1(15, pc, pcb, Mov, RH, 0, 0); xPut0( pc, pcb, Fsb, x.r, RH, x.r)
      END
    ELSE (*form = Set*)
      IF x.mode = OXB.Const THEN x.a := -x.a-1 
      ELSE load(x); xPut1(16, pc, pcb, Xor, x.r, x.r, -1)
      END
    END
  END Neg;

  (* begin-procedure-description
---
**AddOp** generates an add operation
  end-procedure-description *)
  PROCEDURE AddOp*(op: LONGINT; VAR x, y: Item);   (* x := x +- y *)
  BEGIN
    IF op = OXS.plus THEN
      IF (x.mode = OXB.Const) & (y.mode = OXB.Const) THEN x.a := x.a + y.a
      ELSIF y.mode = OXB.Const THEN load(x);
        IF y.a # 0 THEN xPut1a(89, pc, pcb, RH, Add, x.r, x.r, y.a) END;
      ELSE load(x); load(y); xPut0( pc, pcb, Add, RH-2, x.r, y.r); DEC(RH); x.r := RH-1
      END
    ELSE (*op = OXS.minus*)
      IF (x.mode = OXB.Const) & (y.mode = OXB.Const) THEN x.a := x.a - y.a
      ELSIF y.mode = OXB.Const THEN load(x);
        IF y.a # 0 THEN xPut1a(90, pc, pcb, RH, Sub, x.r, x.r, y.a) END;
      ELSE load(x); load(y); xPut0( pc, pcb, Sub, RH-2, x.r, y.r); DEC(RH); x.r := RH-1
      END
    END
  END AddOp;

  (* begin-procedure-description
---
**log2** generates a log2 operation
  end-procedure-description *)
  PROCEDURE log2(m: LONGINT; VAR e: LONGINT): LONGINT;
  BEGIN e := 0;
    WHILE ~ODD(m) DO m := m DIV 2; INC(e) END ;
    RETURN m
  END log2;
  
  (* begin-procedure-description
---
**MulOp** generates a multipy operation
  end-procedure-description *)
  PROCEDURE MulOp*(VAR x, y: Item);   (* x := x * y *)
    VAR e: LONGINT;
  BEGIN
    IF (x.mode = OXB.Const) & (y.mode = OXB.Const) THEN x.a := x.a * y.a
    ELSIF (y.mode = OXB.Const) & (y.a >= 2) & (log2(y.a, e) = 1) THEN load(x); xPut1(17, pc, pcb, Lsl, x.r, x.r, e)
    ELSIF y.mode = OXB.Const THEN load(x); xPut1a(91, pc, pcb, RH, Mul, x.r, x.r, y.a)
    ELSIF (x.mode = OXB.Const) & (x.a >= 2) & (log2(x.a, e) = 1) THEN load(y); xPut1(18, pc, pcb, Lsl, y.r, y.r, e); x.mode := Reg; x.r := y.r
    ELSIF x.mode = OXB.Const THEN load(y); xPut1a(92, pc, pcb, RH, Mul, y.r, y.r, x.a); x.mode := Reg; x.r := y.r
    ELSE load(x); load(y); xPut0( pc, pcb, Mul, RH-2, x.r, y.r); DEC(RH); x.r := RH-1
    END
  END MulOp;

  (* begin-procedure-description
---
**DivOp** generates a divide operation
  end-procedure-description *)
  PROCEDURE DivOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)
    VAR e: LONGINT;
  BEGIN
    IF op = OXS.div THEN
      IF (x.mode = OXB.Const) & (y.mode = OXB.Const) THEN
        IF y.a > 0 THEN x.a := x.a DIV y.a ELSE OXS.Mark("bad divisor") END
      ELSIF (y.mode = OXB.Const) & (y.a >= 2) & (log2(y.a, e) = 1) THEN load(x); xPut1(19, pc, pcb, Asr, x.r, x.r, e)
      ELSIF y.mode = OXB.Const THEN
        IF y.a > 0 THEN load(x); xPut1a(93, pc, pcb, RH, Div, x.r, x.r, y.a) ELSE OXS.Mark("bad divisor") END
      ELSE load(y);
        IF check THEN Trap(LE, 6) END ;
        load(x); xPut0( pc, pcb, Div, RH-2, x.r, y.r); DEC(RH); x.r := RH-1
      END
    ELSE (*op = OXS.mod*)
      IF (x.mode = OXB.Const) & (y.mode = OXB.Const) THEN
        IF y.a > 0 THEN x.a := x.a MOD y.a ELSE OXS.Mark("bad modulus") END
      ELSIF (y.mode = OXB.Const) & (y.a >= 2) & (log2(y.a, e) = 1) THEN load(x);
        IF e <= 16 THEN xPut1(20, pc, pcb, And, x.r, x.r, y.a-1) ELSE xPut1(21, pc, pcb, Lsl, x.r, x.r, 32-e); xPut1(22, pc, pcb, Ror, x.r, x.r, 32-e) END
      ELSIF y.mode = OXB.Const THEN
        IF y.a > 0 THEN load(x); xPut1a(94, pc, pcb, RH, Div, x.r, x.r, y.a); xPut0( pc, pcb, Mov+U, x.r, 0, 0) ELSE OXS.Mark("bad modulus") END
      ELSE load(y);
        IF check THEN Trap(LE, 6) END ;
        load(x); xPut0( pc, pcb, Div, RH-2, x.r, y.r); xPut0( pc, pcb, Mov+U, RH-2, 0, 0); DEC(RH); x.r := RH-1
      END
    END
  END DivOp;

  (* Code generation for REAL operators *)

  (* begin-section-description
## ----------  Code generation for REAL operators
  end-section-description *)

  (* begin-procedure-description
---
**RealOp** generates operations on reals
  end-procedure-description *)
  PROCEDURE RealOp*(op: INTEGER; VAR x, y: Item);   (* x := x op y *)
  BEGIN load(x); load(y);
    IF op = OXS.plus THEN xPut0( pc, pcb, Fad, RH-2, x.r, y.r)
    ELSIF op = OXS.minus THEN xPut0( pc, pcb, Fsb, RH-2, x.r, y.r)
    ELSIF op = OXS.times THEN xPut0( pc, pcb, Fml, RH-2, x.r, y.r)
    ELSIF op = OXS.rdiv THEN xPut0( pc, pcb, Fdv, RH-2, x.r, y.r)
    END ;
    DEC(RH); x.r := RH-1
  END RealOp;

  (* Code generation for STRING operators *)

  (* begin-section-description
## ----------  Code generation for STRING operators
  end-section-description *)

  (* begin-procedure-description
---
**StringOp** generates operations on reals
  end-procedure-description *)
  PROCEDURE StringOp*(op: INTEGER; VAR x, y: Item);   (* x := x op y *)
  BEGIN load(x); load(y);
    IF op = OXS.plus THEN 
    END ;
    DEC(RH); x.r := RH-1
  END StringOp;

  (* Code generation for set operators *)

  (* begin-section-description
## ----------  Code generation for set operators
  end-section-description *)

  (* begin-procedure-description
---
**Singleton** generates a set of one set item.
  end-procedure-description *)
  PROCEDURE Singleton*(VAR x: Item);  (* x := {x} *)
  BEGIN
    IF x.mode = OXB.Const THEN x.a := LSL(1, x.a) 
    ELSE load(x); xPut1(23, pc, pcb, Mov, RH, 0, 1); xPut0( pc, pcb, Lsl, x.r, RH,  x.r)
    END
  END Singleton;

  (* begin-procedure-description
---
**Set** generates a set value from two set items.
  end-procedure-description *)
  PROCEDURE Set*(VAR x, y: Item);   (* x := {x .. y} *)
  BEGIN
    IF (x.mode = OXB.Const) & ( y.mode = OXB.Const) THEN
      IF x.a <= y.a THEN x.a := LSL(2, y.a) - LSL(1, x.a) ELSE x.a := 0 END
    ELSE
      IF (x.mode = OXB.Const) & (x.a <= 16) THEN x.a := LSL(-1, x.a)
      ELSE load(x); xPut1(24, pc, pcb, Mov, RH, 0, -1); xPut0( pc, pcb, Lsl, x.r, RH, x.r)
      END ;
      IF (y.mode = OXB.Const) & (y.a < 16) THEN xPut1(25, pc, pcb, Mov, RH, 0, LSL(-2, y.a)); y.mode := Reg; y.r := RH; incR
      ELSE load(y); xPut1(26, pc, pcb, Mov, RH, 0, -2); xPut0( pc, pcb, Lsl, y.r, RH, y.r)
      END ;
      IF x.mode = OXB.Const THEN
        IF x.a # 0 THEN xPut1(27, pc, pcb, Xor, y.r, y.r, -1); xPut1a(95, pc, pcb, RH, And, RH-1, y.r, x.a) END ;
        x.mode := Reg; x.r := RH-1
      ELSE DEC(RH); xPut0( pc, pcb, Ann, RH-1, x.r, y.r)
      END
    END
  END Set;

  (* begin-procedure-description
---
**In** generates a test for if an item is in a set
  end-procedure-description *)
  PROCEDURE In*(VAR x, y: Item);  (* x := x IN y *)
  BEGIN load(y);
    IF x.mode = OXB.Const THEN xPut1(28, pc, pcb, Ror, y.r, y.r, (x.a + 1) MOD 20H); DEC(RH)
    ELSE load(x); xPut1(29, pc, pcb, Add, x.r, x.r, 1); xPut0( pc, pcb, Ror, y.r, y.r, x.r); DEC(RH, 2)
    END ;
    SetCC(x, MI)
  END In;

  (* begin-procedure-description
---
**SetOp** generates operations on sets
  end-procedure-description *)
  PROCEDURE SetOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)
    VAR xset, yset: SET; (*x.type.form = Set*)
  BEGIN
    IF (x.mode = OXB.Const) & (y.mode = OXB.Const) THEN
      xset := SYSTEM.VAL(SET, x.a); yset := SYSTEM.VAL(SET, y.a);
      IF op = OXS.plus THEN xset := xset + yset
      ELSIF op = OXS.minus THEN xset := xset - yset
      ELSIF op = OXS.times THEN xset := xset * yset
      ELSIF op = OXS.rdiv THEN xset := xset / yset
      END ;
      x.a := SYSTEM.VAL(LONGINT, xset)
    ELSIF y.mode = OXB.Const THEN
      load(x);
      IF op = OXS.plus THEN xPut1a(96, pc, pcb, RH, Ior, x.r, x.r, y.a)
      ELSIF op = OXS.minus THEN xPut1a(97, pc, pcb, RH, Ann, x.r, x.r, y.a)
      ELSIF op = OXS.times THEN xPut1a(98, pc, pcb, RH, And, x.r, x.r, y.a)
      ELSIF op = OXS.rdiv THEN xPut1a(99, pc, pcb, RH, Xor, x.r, x.r, y.a)
      END ;
    ELSE load(x); load(y);
      IF op = OXS.plus THEN xPut0( pc, pcb, Ior, RH-2, x.r, y.r)
      ELSIF op = OXS.minus THEN xPut0( pc, pcb, Ann, RH-2, x.r, y.r)
      ELSIF op = OXS.times THEN xPut0( pc, pcb, And, RH-2, x.r, y.r)
      ELSIF op = OXS.rdiv THEN xPut0( pc, pcb, Xor, RH-2, x.r, y.r)
      END ;
      DEC(RH); x.r := RH-1
    END 
  END SetOp;

  (* Code generation for relations *)

  (* begin-section-description
## ----------  Code generation for relations
  end-section-description *)

  (* begin-procedure-description
---
**IntRelation** generates an integer comparison
  end-procedure-description *)
  PROCEDURE IntRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)
  BEGIN
    IF (y.mode = OXB.Const) & (y.type.form # OXB.Proc) THEN
      load(x);
      IF (y.a # 0) OR ~(op IN {OXS.eql, OXS.neq}) OR (OXX.code[pc-1] DIV 40000000H # -2) THEN xPut1a(100, pc, pcb, RH, Cmp, x.r, x.r, y.a) END ;
      DEC(RH)
    ELSE
      IF (x.mode = Cond) OR (y.mode = Cond) THEN OXS.Mark("not implemented") END ;
      load(x); load(y); xPut0( pc, pcb, Cmp, x.r, x.r, y.r); DEC(RH, 2)
    END ;
    SetCC(x, relmap[op - OXS.eql])
  END IntRelation;

  (* begin-procedure-description
---
**RealRelation** generates a real comparison
  end-procedure-description *)
  PROCEDURE RealRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)
  BEGIN load(x);
    IF (y.mode = OXB.Const) & (y.a = 0) THEN DEC(RH)
    ELSE load(y); xPut0( pc, pcb, Fsb, x.r, x.r, y.r); DEC(RH, 2)
    END ;
    SetCC(x, relmap[op - OXS.eql])
  END RealRelation;

  (* begin-procedure-description
---
**StringRelation** generates a string comparison
  end-procedure-description *)
  PROCEDURE StringRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)
    (*x, y are char arrays or strings*)
  BEGIN
    IF x.type.form = OXB.String THEN loadStringAdr(x) ELSE loadAdr(x) END ;
    IF y.type.form = OXB.String THEN loadStringAdr(y) ELSE loadAdr(y) END ;
    xPut2(pc, pcb, Ldr+1, RH, x.r, 0); xPut1(30, pc, pcb, Add, x.r, x.r, 1);
    xPut2(pc, pcb, Ldr+1, RH+1, y.r, 0); xPut1(31, pc, pcb, Add, y.r, y.r, 1);
    xPut0( pc, pcb, Cmp, RH+2, RH, RH+1); xPut3(pc, pcb, BC, NE, 2);
    xPut1(32, pc, pcb, Cmp, RH+2, RH, 0); xPut3(pc, pcb, BC, NE, -8);
    DEC(RH, 2); SetCC(x, relmap[op - OXS.eql])
  END StringRelation;

  (* Code generation of Assignments *)

  (* begin-section-description
## ----------  Code generation of Assigments
  end-section-description *)

  (* begin-procedure-description
---
**StrToChar** ??
  end-procedure-description *)
  PROCEDURE StrToChar*(VAR x: Item);
  BEGIN x.type := OXB.charType; DEC(strx, 4); x.a := ORD(OXX.str[x.a])
  END StrToChar;

  (* begin-procedure-description
---
**Store** generates the copying of the value of one word-sized variable into another word-sized variable.
  end-procedure-description *)
  PROCEDURE Store*(VAR x, y: Item); (* x := y *)
    VAR op: LONGINT;
  BEGIN  load(y);
    IF x.type.size = 1 THEN op := Str+1 ELSE op := Str END ;
    IF x.mode = OXB.Var THEN
      IF x.r > 0 THEN (*local*) xPut2(pc, pcb, op, y.r, SP, x.a + frame)
      ELSE GetSB(x.r); xPut2(pc, pcb, op, y.r, RH, x.a)
      END
    ELSIF x.mode = OXB.Par THEN xPut2(pc, pcb, Ldr, RH, SP, x.a + frame); xPut2(pc, pcb, op, y.r, RH, x.b);
    ELSIF x.mode = RegI THEN xPut2(pc, pcb, op, y.r, x.r, x.a); DEC(RH);
    ELSE OXS.Mark("bad mode in Store")
    END ;
    DEC(RH)
  END Store;

  (* begin-procedure-description
---
**StoreStruct** generates copying the contents of one structure into another structure.
  end-procedure-description *)
  PROCEDURE StoreStruct*(VAR x, y: Item); (* x := y, frame = 0 *)
    VAR s, pc0: LONGINT;
  BEGIN
    IF y.type.size # 0 THEN
      loadAdr(x); loadAdr(y);
      IF (x.type.form = OXB.Array) &  (x.type.len > 0) THEN
        IF y.type.len >= 0 THEN 
          IF x.type.size = y.type.size THEN xPut1a(101, pc, pcb, RH, Mov, RH, 0, (y.type.size+3) DIV 4)
          ELSE OXS.Mark("different length/size, not implemented")
          END
        ELSE (*y  open array*) xPut2(pc, pcb, Ldr, RH, SP, y.a+4); s := y.type.base.size;  (*element size*)
          pc0 := pc; xPut3(pc, pcb, BC, EQ, 0);
          IF s = 1 THEN xPut1(33, pc, pcb, Add, RH, RH, 3); xPut1(34, pc, pcb, Asr, RH, RH, 2)
          ELSIF s # 4 THEN xPut1a(102, pc, pcb, RH, Mul, RH, RH, s DIV 4)
          END ;
          IF check THEN
            xPut1a(103, pc, pcb, RH, Mov, RH+1, 0, (x.type.size+3) DIV 4); xPut0( pc, pcb, Cmp, RH+1, RH, RH+1); Trap(GT, 3)
          END ;
          OXX.fix(pc0, pc + 5 - pc0)
        END
      ELSIF x.type.form = OXB.Record THEN xPut1a(104, pc, pcb, RH, Mov, RH, 0, x.type.size DIV 4)
      ELSE OXS.Mark("inadmissible assignment")
      END ;
      xPut2(pc, pcb, Ldr, RH+1, y.r, 0); xPut1(35, pc, pcb, Add, y.r, y.r, 4);
      xPut2(pc, pcb, Str, RH+1, x.r, 0); xPut1(36, pc, pcb, Add, x.r, x.r, 4);
      xPut1(37, pc, pcb, Sub, RH, RH, 1); xPut3(pc, pcb, BC, NE, -6)
    END ;
    RH := 0
  END StoreStruct;

  (* begin-procedure-description
---
**CopyString** generates copying the contents of one string variable into another string variable.
  end-procedure-description *)
  PROCEDURE CopyString*(VAR x, y: Item);  (* x := y *) 
     VAR len: LONGINT;
   BEGIN loadAdr(x); len := x.type.len;
    IF len >= 0 THEN
      IF len <  y.b THEN OXS.Mark("string too long") END
    ELSIF check THEN xPut2(pc, pcb, Ldr, RH, SP, x.a+4);  (*open array len, frame = 0*)
      xPut1(38, pc, pcb, Cmp, RH, RH, y.b); Trap(LT, 3)
    END ;
    loadStringAdr(y);
    xPut2(pc, pcb, Ldr, RH, y.r, 0); xPut1(39, pc, pcb, Add, y.r, y.r, 4);
    xPut2(pc, pcb, Str, RH, x.r, 0); xPut1(40, pc, pcb, Add, x.r, x.r, 4);
    xPut1(41, pc, pcb, Asr, RH, RH, 24); xPut3(pc, pcb, BC, NE,  -6);  RH := 0
   END CopyString;
  
  (* Code generation for parameters *)
  
  (* begin-section-description
## ----------  Code generation for parameters
  end-section-description *)

  (* begin-procedure-description
---
**OpenArrayParam** generates placing the address of an open array variable in a register, allocating the register.
  end-procedure-description *)
  PROCEDURE OpenArrayParam*(VAR x: Item);
  BEGIN loadAdr(x);
    IF x.type.len >= 0 THEN xPut1a(105, pc, pcb, RH, Mov, RH, 0, x.type.len) ELSE xPut2(pc, pcb, Ldr, RH, SP, x.a+4+frame) END ;
    incR
  END OpenArrayParam;

  (* begin-procedure-description
---
**VarParam** generates placing the address of a variable in a register, allocating the register.
  end-procedure-description *)
  PROCEDURE VarParam*(VAR x: Item; ftype: OXB.Type);
    VAR xmd: INTEGER;
  BEGIN xmd := x.mode; loadAdr(x);
    IF (ftype.form = OXB.Array) & (ftype.len < 0) THEN (*open array*)
      IF x.type.len >= 0 THEN xPut1a(106, pc, pcb, RH, Mov, RH, 0, x.type.len) ELSE  xPut2(pc, pcb, Ldr, RH, SP, x.a+4+frame) END ;
      incR
    ELSIF ftype.form = OXB.Record THEN
      IF xmd = OXB.Par THEN xPut2(pc, pcb, Ldr, RH, SP, x.a+4+frame); incR ELSE loadTypTagAdr(x.type) END
    END
  END VarParam;

  (* begin-procedure-description
---
**ValueParam** generates placing a value in a register.
  end-procedure-description *)
  PROCEDURE ValueParam*(VAR x: Item);
  BEGIN load(x)
  END ValueParam;

  (* begin-procedure-description
---
**StringParam** generates placing the location of a string in a register, allocating the register.
  end-procedure-description *)
  PROCEDURE StringParam*(VAR x: Item);
  BEGIN loadStringAdr(x); xPut1(42, pc, pcb, Mov, RH, 0, x.b); incR  (*len*)
  END StringParam;

  (*For Statements*)

  (* begin-section-description
## ----------  For Statements
  end-section-description *)

  (* begin-procedure-description
---
**For0** generates the initial part of a FOR statement
  end-procedure-description *)
  PROCEDURE For0*(VAR x, y: Item);
  BEGIN load(y)
  END For0;

  (* begin-procedure-description
---
**FOR1** generates the central part of a FOR statement
  end-procedure-description *)
  PROCEDURE For1*(VAR x, y, z, w: Item; VAR L: LONGINT);
  BEGIN 
    IF z.mode = OXB.Const THEN xPut1a(107, pc, pcb, RH, Cmp, RH, y.r, z.a)
    ELSE load(z); xPut0( pc, pcb, Cmp, RH-1, y.r, z.r); DEC(RH)
    END ;
    L := pc;
    IF w.a > 0 THEN xPut3(pc, pcb, BC, GT, 0)
    ELSIF w.a < 0 THEN xPut3(pc, pcb, BC, LT, 0)
    ELSE OXS.Mark("zero increment"); xPut3(pc, pcb, BC, MI, 0)
    END ;
    Store(x, y)
  END For1;

  (* begin-procedure-description
---
**FOR2** generates the final part of a FOR statement.
  end-procedure-description *)
  PROCEDURE For2*(VAR x, y, w: Item);
  BEGIN load(x); DEC(RH); xPut1a(108, pc, pcb, RH, Add, x.r, x.r, w.a)
  END For2;

  (* Branches, procedure calls, procedure prolog and epilog *)

  (* begin-section-description
## ----------  Branches, procedure calls, procedure prolog and epilog
  end-section-description *)

  (* begin-procedure-description
---
**Here** returns the next available code location.
  end-procedure-description *)
  PROCEDURE Here*(): LONGINT;
  BEGIN RETURN pc
  END Here;

  (* begin-procedure-description
---
**FJump** generates a forward jump.
  end-procedure-description *)
  PROCEDURE FJump*(VAR L: LONGINT);
  BEGIN xPut3(pc, pcb, BC, 7, L); L := pc-1
  END FJump;

  (* begin-procedure-description
---
**CFJump** generates a conditional forward jump
  end-procedure-description *)
  PROCEDURE CFJump*(VAR x: Item);
  BEGIN
    IF x.mode # Cond THEN loadCond(x) END ;
    xPut3(pc, pcb, BC, negated(x.r), x.a); OXX.FixLink(pc,pcb,x.b); x.a := pc-1
  END CFJump;

  (* begin-procedure-description
---
**BJump** generates a backwards jump.
  end-procedure-description *)
  PROCEDURE BJump*(L: LONGINT);
  BEGIN xPut3(pc, pcb, BC, 7, L-pc-1)
  END BJump;

  (* begin-procedure-description
---
**CBJump** generates a conditional backwards jump.
  end-procedure-description *)
  PROCEDURE CBJump*(VAR x: Item; L: LONGINT);
  BEGIN
    IF x.mode # Cond THEN loadCond(x) END ;
    xPut3(pc, pcb, BC, negated(x.r), L-pc-1); OXX.FixLink(pc,pcb,x.b); OXX.FixLinkWith(x.a, L)
  END CBJump;

  (* begin-procedure-description
---
**Fixup** fixes ???
  end-procedure-description *)
  PROCEDURE Fixup*(VAR x: Item);
  BEGIN OXX.FixLink(pc,pcb,x.a)
  END Fixup;

  (* begin-procedure-description
---
**SaveRegs** saves register values in preparation for a procedure call.
  end-procedure-description *)
  PROCEDURE SaveRegs(r: LONGINT);  (* R[0 .. r-1]*)
    VAR r0: LONGINT;
  BEGIN (*r > 0*) r0 := 0;
    xPut1(43, pc, pcb, Sub, SP, SP, r*4); INC(frame, 4*r);
    REPEAT xPut2(pc, pcb, Str, r0, SP, (r-r0-1)*4); INC(r0) UNTIL r0 = r
  END SaveRegs;

  (* begin-procedure-description
---
**RestoreRegs** brings values back into registers after a procedure call.
  end-procedure-description *)
  PROCEDURE RestoreRegs(r: LONGINT); (*R[0 .. r-1]*)
    VAR r0: LONGINT;
  BEGIN (*r > 0*) r0 := r;
    REPEAT DEC(r0); xPut2(pc, pcb, Ldr, r0, SP, (r-r0-1)*4) UNTIL r0 = 0;
    xPut1(44, pc, pcb, Add, SP, SP, r*4); DEC(frame, 4*r)
  END RestoreRegs;

  (* begin-procedure-description
---
**PrepCall** generates generates a sequence that preapreas for a procedure call.
  end-procedure-description *)
  PROCEDURE PrepCall*(VAR x: Item; VAR r: LONGINT);
  BEGIN (*x.type.form = OXB.Proc*)
    IF x.mode > OXB.Par THEN load(x) END ;
    r := RH;
    IF RH > 0 THEN SaveRegs(RH); RH := 0 END
  END PrepCall;

  (* begin-procedure-description
---
**Call** generates the procedure call sequence.
  end-procedure-description *)
  PROCEDURE Call*(VAR x: Item; r: LONGINT);
  BEGIN (*x.type.form = OXB.Proc*)
    IF x.mode = OXB.Const THEN
      IF x.r >= 0 THEN xPut3(pc, pcb, BL, 7, (x.a DIV 4)-pc-1)
      ELSE (*imported*)
        IF pc - OXX.fixorgP < 1000H THEN
          xPut3(pc, pcb, BL, 7, ((-x.r) * 100H + x.a) * 1000H + pc-OXX.fixorgP); OXX.setFixOrgP( pc-1 )
        ELSE OXS.Mark("fixup impossible")
        END
      END
    ELSE
      IF x.mode <= OXB.Par THEN load(x); DEC(RH)
      ELSE xPut2(pc, pcb, Ldr, RH, SP, 0); xPut1(45, pc, pcb, Add, SP, SP, 4); DEC(r); DEC(frame, 4)
      END ;
      IF check THEN Trap(EQ, 5) END ;
      xPut3(pc, pcb, BLR, 7, RH)
    END ;
    IF x.type.base.form = OXB.NoTyp THEN (*procedure*) RH := 0
    ELSE (*function*)
      IF r > 0 THEN xPut0( pc, pcb, Mov, r, 0, 0); RestoreRegs(r) END ;
      x.mode := Reg; x.r := r; RH := r+1
    END
  END Call;

  (* begin-procedure-description
---
**Enter** generates the procedure entry sequence.
  end-procedure-description *)
  PROCEDURE Enter*(parblksize, locblksize, wordsize: LONGINT; int: BOOLEAN);
    VAR a, r: LONGINT;
  BEGIN frame := 0;
    IF ~int THEN (*procedure prolog*)
      IF locblksize >= 10000H THEN OXS.Mark("too many locals") END ;
      a := wordsize; r := 0;
      xPut1(46, pc, pcb, Sub, SP, SP, locblksize); xPut2(pc, pcb, Str, LNK, SP, 0);
      WHILE a < parblksize DO xPut2(pc, pcb, Str, r, SP, a); INC(r); INC(a, wordsize) END
    ELSE (*interrupt procedure*)
      xPut1(47, pc, pcb, Sub, SP, SP, locblksize); xPut2(pc, pcb, Str, 0, SP, 0); xPut2(pc, pcb, Str, 1, SP, 4); xPut2(pc, pcb, Str, 2, SP, 8)
      (*R0, R1, R2 saved on stack*)
    END
  END Enter;

  (* begin-procedure-description
---
**Return** generates the procedure return sequence.
  end-procedure-description *)
  PROCEDURE Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN);
  BEGIN
    IF form # OXB.NoTyp THEN load(x) END ;
    IF ~int THEN (*procedure epilog*)
      xPut2(pc, pcb, Ldr, LNK, SP, 0); xPut1(48, pc, pcb, Add, SP, SP, size); xPut3(pc, pcb, BR, 7, LNK)
    ELSE (*interrupt return, restore R2, R1, R0*)
      xPut2(pc, pcb, Ldr, 2, SP, 8); xPut2(pc, pcb, Ldr, 1, SP, 4); xPut2(pc, pcb, Ldr, 0, SP, 0); xPut1(49, pc, pcb, Add, SP, SP, size);
      xPut3(pc, pcb, BR, 7, 10H) (*RTI*)
    END ;
    RH := 0
  END Return;

  (* In-line code procedures*)

  (* begin-section-description
## ----------  In-line code procedures
  end-section-description *)

  (* begin-procedure-description
---
**Increment** generates an inline routine that increments a variable.
  end-procedure-description *)
  PROCEDURE Increment*(upordown: LONGINT; VAR x, y: Item);
    VAR op, zr, v: LONGINT;
  BEGIN (*frame = 0*)
    IF upordown = 0 THEN op := Add ELSE op := Sub END ;
    IF x.type = OXB.byteType THEN v := 1 ELSE v := 0 END ;
    IF y.type.form = OXB.NoTyp THEN y.mode := OXB.Const; y.a := 1 END ;
    IF (x.mode = OXB.Var) & (x.r > 0) THEN
      zr := RH; xPut2(pc, pcb, Ldr+v, zr, SP, x.a); incR;
      IF y.mode = OXB.Const THEN xPut1a(199, pc, pcb, RH, op, zr, zr, y.a) ELSE load(y); xPut0( pc, pcb, op, zr, zr, y.r); DEC(RH) END ;
      xPut2(pc, pcb, Str+v, zr, SP, x.a); DEC(RH)
    ELSE loadAdr(x); zr := RH; xPut2(pc, pcb, Ldr+v, RH, x.r, 0); incR;
      IF y.mode = OXB.Const THEN xPut1a(110, pc, pcb, RH, op, zr, zr, y.a) ELSE load(y); xPut0( pc, pcb, op, zr, zr, y.r); DEC(RH) END ;
      xPut2(pc, pcb, Str+v, zr, x.r, 0); DEC(RH, 2)
    END
  END Increment;

  (* begin-procedure-description
---
**Include** generates a routine that ??
  end-procedure-description *)
  PROCEDURE Include*(inorex: LONGINT; VAR x, y: Item);
    VAR op, zr: LONGINT;
  BEGIN loadAdr(x); zr := RH; xPut2(pc, pcb, Ldr, RH, x.r, 0); incR;
    IF inorex = 0 THEN op := Ior ELSE op := Ann END ;
    IF y.mode = OXB.Const THEN xPut1a(111, pc, pcb, RH, op, zr, zr, LSL(1, y.a))
    ELSE load(y); xPut1(50, pc, pcb, Mov, RH, 0, 1); xPut0( pc, pcb, Lsl, y.r, RH, y.r); xPut0( pc, pcb, op, zr, zr, y.r); DEC(RH)
    END ;
    xPut2(pc, pcb, Str, zr, x.r, 0); DEC(RH, 2)
  END Include;

  (* begin-procedure-description
---
**Assert** generates an inline routine that traps on a condition.
  end-procedure-description *)
  PROCEDURE Assert*(VAR x: Item);
    VAR cond: LONGINT;
  BEGIN
    IF x.mode # Cond THEN loadCond(x) END ;
    IF x.a = 0 THEN cond := negated(x.r)
    ELSE xPut3(pc, pcb, BC, x.r, x.b); OXX.FixLink(pc,pcb,x.a); x.b := pc-1; cond := 7
    END ;
    Trap(cond, 7); OXX.FixLink(pc,pcb,x.b)
  END Assert; 

  (* begin-procedure-description
---
**New** generates an inline routine that allocates heap memory via trap 0.
  end-procedure-description *)
  PROCEDURE New*(VAR x: Item);
  BEGIN loadAdr(x); loadTypTagAdr(x.type.base); Trap(7, 0); RH := 0
  END New;

  (* begin-procedure-description
---
**Pack** generates an inline routine that ??
  end-procedure-description *)
  PROCEDURE Pack*(VAR x, y: Item);
    VAR z: Item;
  BEGIN z := x; load(x); load(y);
    xPut1(51, pc, pcb, Lsl, y.r, y.r, 23); xPut0( pc, pcb, Add, x.r, x.r, y.r); DEC(RH); Store(z, x)
  END Pack;

  (* begin-procedure-description
---
**Unpk** generates in inline routine that ??
  end-procedure-description *)
  PROCEDURE Unpk*(VAR x, y: Item);
    VAR z, e0: Item;
  BEGIN  z := x; load(x); e0.mode := Reg; e0.r := RH; e0.type := OXB.intType;
    xPut1(52, pc, pcb, Asr, RH, x.r, 23); xPut1(53, pc, pcb, Sub, RH, RH, 127); Store(y, e0); incR;
    xPut1(54, pc, pcb, Lsl, RH, RH, 23); xPut0( pc, pcb, Sub, x.r, x.r, RH); Store(z, x)
  END Unpk;

  (* begin-procedure-description
---
**Led** generates an inline routine that displays a bit pattern on the LED display.
  end-procedure-description *)
  PROCEDURE Led*(VAR x: Item);
  BEGIN load(x); xPut1(55, pc, pcb, Mov, RH, 0, -60); xPut2(pc, pcb, Str, x.r, RH, 0); DEC(RH)
  END Led;

  (* begin-procedure-description
---
**Ouch** generates an inline routine that sends a character to debug output.
  end-procedure-description *)
  PROCEDURE Ouch*(VAR x: Item);
  BEGIN load(x); xPut1(55, pc, pcb, Mov, RH, 0, -28); xPut2(pc, pcb, Str, x.r, RH, 0); DEC(RH)
  END Ouch;

  (* begin-procedure-description
---
**Get** generates an inline routine that loads a value from an IO register.
  end-procedure-description *)
  PROCEDURE Get*(VAR x, y: Item);
  BEGIN load(x); x.type := y.type; x.mode := RegI; x.a := 0; Store(y, x)
  END Get;

  (* begin-procedure-description
---
**Put** generates an inline routine that stores a value in an IO register.
  end-procedure-description *)
  PROCEDURE Put*(VAR x, y: Item);
  BEGIN load(x); x.type := y.type; x.mode := RegI; x.a := 0; Store(x, y)
  END Put;

  (* begin-procedure-description
---
**Copy** generates an inline memory copy routine.     
  end-procedure-description *)
  PROCEDURE Copy*(VAR x, y, z: Item);
  BEGIN load(x); load(y);
    IF z.mode = OXB.Const THEN
      IF z.a > 0 THEN load(z) ELSE OXS.Mark("bad count") END
    ELSE load(z);
      IF check THEN Trap(LT, 3) END ;
      xPut3(pc, pcb, BC, EQ, 6)
    END ;
    xPut2(pc, pcb, Ldr, RH, x.r, 0); xPut1(56, pc, pcb, Add, x.r, x.r, 4);
    xPut2(pc, pcb, Str, RH, y.r, 0); xPut1(57, pc, pcb, Add, y.r, y.r, 4);
    xPut1(58, pc, pcb, Sub, z.r, z.r, 1); xPut3(pc, pcb, BC, NE, -6); DEC(RH, 3)
  END Copy;

  (* begin-procedure-description
---
**LDPSR** places the processor status register in a variable     
  end-procedure-description *)
  PROCEDURE LDPSR*(VAR x: Item);
  BEGIN (*x.mode = Const*)  xPut3(pc, pcb, 0, 15, x.a + 20H)
  END LDPSR;

  (* begin-procedure-description
---
**REGREG** loads a register with the contents of another register     
  end-procedure-description *)
  PROCEDURE REGREG*(VAR x, y: Item);
  BEGIN
    xPut0( pc, pcb, Mov, x.a, 0, y.a)
  END REGREG;

  (* begin-procedure-description
---
**LDREG** places a register value in a variable     
  end-procedure-description *)
  PROCEDURE LDREG*(VAR x, y: Item);
  BEGIN
    IF y.mode = OXB.Const THEN xPut1a(112, pc, pcb, RH, Mov, x.a, 0, y.a)
    ELSE load(y); xPut0( pc, pcb, Mov, x.a, 0, y.r); DEC(RH)
    END
  END LDREG;

  (*In-line code functions*)

  (* begin-section-description
## ----------  In-line code functions
  end-section-description *)

  (* begin-procedure-description
---
**Abs** generates an inline functionn that takes the absolute value     
  end-procedure-description *)
  PROCEDURE Abs*(VAR x: Item);
  BEGIN
    IF x.mode = OXB.Const THEN x.a := ABS(x.a)
    ELSE load(x);
      IF x.type.form = OXB.Real THEN xPut1(59, pc, pcb, Lsl, x.r, x.r, 1); xPut1(60, pc, pcb, Ror, x.r, x.r, 1)
      ELSE xPut1(61, pc, pcb, Cmp, x.r, x.r, 0); xPut3(pc, pcb, BC, GE, 2); xPut1(62, pc, pcb, Mov, RH, 0, 0); xPut0( pc, pcb, Sub, x.r, RH, x.r)
      END
    END
  END Abs;

  (* begin-procedure-description
---
**Odd** generates an inlinen function that checks whether a value is odd.     
  end-procedure-description *)
  PROCEDURE Odd*(VAR x: Item);
  BEGIN load(x); xPut1(63, pc, pcb, And, x.r, x.r, 1); SetCC(x, NE); DEC(RH)
  END Odd;

  (* begin-procedure-description
---
**Floor** generates an inline function that produces the floor of a value.     
  end-procedure-description *)
  PROCEDURE Floor*(VAR x: Item);
  BEGIN load(x); xPut1(64, pc, pcb, Mov+U, RH, 0, 4B00H); xPut0( pc, pcb, Fad+V, x.r, x.r, RH)
  END Floor;

  (* begin-procedure-description
---
**Float** generates an inline function that produces a float.     
  end-procedure-description *)
  PROCEDURE Float*(VAR x: Item);
  BEGIN load(x); xPut1(65, pc, pcb, Mov+U, RH, 0, 4B00H);  xPut0( pc, pcb, Fad+U, x.r, x.r, RH)
  END Float;

  (* begin-procedure-description
---
**Ord** generates an inline function that presents the ordinal value of its parameter.     
  end-procedure-description *)
  PROCEDURE Ord*(VAR x: Item);
  BEGIN
    IF x.mode IN {OXB.Var, OXB.Par, RegI, Cond} THEN load(x) END
  END Ord;

  (* begin-procedure-description
---
**Len** generates an inline function that presents the length of an array.     
  end-procedure-description *)
  PROCEDURE Len*(VAR x: Item);
  BEGIN
    IF x.type.len >= 0 THEN
      IF x.mode = RegI THEN DEC(RH) END ;
      x.mode := OXB.Const; x.a := x.type.len
    ELSE (*open array*) xPut2(pc, pcb, Ldr, RH, SP, x.a + 4 + frame); x.mode := Reg; x.r := RH; incR
    END 
  END Len;

  (* begin-procedure-description
---
**Shift** generates an inline function that performs bit shifts.      
  end-procedure-description *)
  PROCEDURE Shift*(fct: LONGINT; VAR x, y: Item);
    VAR op: LONGINT;
  BEGIN load(x);
    IF fct = 0 THEN op := Lsl ELSIF fct = 1 THEN op := Asr ELSE op := Ror END ;
    IF y.mode = OXB.Const THEN xPut1(66, pc, pcb, op, x.r, x.r, y.a MOD 20H)
    ELSE load(y); xPut0( pc, pcb, op, RH-2, x.r, y.r); DEC(RH); x.r := RH-1
    END
  END Shift;

  (* begin-procedure-description
---
**ADC** generates an inline function that Adds with Carry     
  end-procedure-description *)
  PROCEDURE ADC*(VAR x, y: Item);
  BEGIN load(x); load(y); xPut0( pc, pcb, Add+2000H, x.r, x.r, y.r); DEC(RH)
  END ADC;

  (* begin-procedure-description
---
**SBC** generates an inline function that Subtracts with Carry 
  end-procedure-description *)
  PROCEDURE SBC*(VAR x, y: Item);
  BEGIN load(x); load(y); xPut0( pc, pcb, Sub+2000H, x.r, x.r, y.r); DEC(RH)
  END SBC;

  (* begin-procedure-description
---
**UML** generates an unsigned multiply 
  end-procedure-description *)
  PROCEDURE UML*(VAR x, y: Item);
  BEGIN load(x); load(y); xPut0( pc, pcb, Mul+2000H, x.r, x.r, y.r); DEC(RH)
  END UML;

  (* begin-procedure-description
---
**Bit** generates an inline function presenting the yth bit of x      
  end-procedure-description *)
  PROCEDURE Bit*(VAR x, y: Item);
  BEGIN load(x); xPut2(pc, pcb, Ldr, x.r, x.r, 0);
    IF y.mode = OXB.Const THEN xPut1(67, pc, pcb, Ror, x.r, x.r, y.a+1); DEC(RH)
    ELSE load(y); xPut1(68, pc, pcb, Add, y.r, y.r, 1); xPut0( pc, pcb, Ror, x.r, x.r, y.r); DEC(RH, 2)
    END ;
    SetCC(x, MI)
  END Bit;

  (* begin-procedure-description
---
**Register** generates an inline function presenting a general register's contents      
  end-procedure-description *)
  PROCEDURE Register*(VAR x: Item);
  BEGIN (*x.mode = Const*)
    xPut0( pc, pcb, Mov, RH, 0, x.a MOD 10H); x.mode := Reg; x.r := RH; incR
  END Register;

  (* begin-procedure-description
---
**H** genrates an inline funtion presenting the contents of the H register.     
  end-procedure-description *)
  PROCEDURE H*(VAR x: Item);
  BEGIN (*x.mode = Const*)
    xPut0( pc, pcb, Mov+U + x.a MOD 2 * V, RH, 0, 0); x.mode := Reg; x.r := RH; incR
  END H;

  (* begin-procedure-description
---
**PAU** genrates an inline funtion that records a one-shot continuation.     
  end-procedure-description *)
  PROCEDURE Pau*(VAR x: Item);
  BEGIN (*x.mode = Const*)
    (* completely wrong code, replace with recording a continuation *)
    xPut0( pc, pcb, Mov+U + x.a MOD 2 * V, RH, 0, 0); x.mode := Reg; x.r := RH; incR
  END Pau;

  (* begin-procedure-description
---
**Ply** genrates an inline funtion that invokes a one-shot continuation.     
  end-procedure-description *)
  PROCEDURE Ply*(VAR x: Item);
  BEGIN (*x.mode = Const*)
    (* completely wrong code, replace with continuation invocation *)
    xPut0( pc, pcb, Mov+U + x.a MOD 2 * V, RH, 0, 0); x.mode := Reg; x.r := RH; incR
  END Ply;

  (* begin-procedure-description
---
**Adr** generates an inline function presenting the memory address of its parameter.      
  end-procedure-description *)
  PROCEDURE Adr*(VAR x: Item);
  BEGIN 
    IF x.mode IN {OXB.Var, OXB.Par, RegI} THEN loadAdr(x)
    ELSIF (x.mode = OXB.Const) & (x.type.form = OXB.Proc) THEN load(x)
    ELSIF (x.mode = OXB.Const) & (x.type.form = OXB.String) THEN loadStringAdr(x)
    ELSE OXS.Mark("not addressable")
    END
  END Adr;

  (* begin-procedure-description
---
**Condition** generates an inline function presenting a condition.     
  end-procedure-description *)
  PROCEDURE Condition*(VAR x: Item);
  BEGIN (*x.mode = Const*) SetCC(x, x.a)
  END Condition;

  (* begin-procedure-description
---
**Open** initializes the OXG module code generation engine.     
  end-procedure-description *)
  PROCEDURE Open*(v: INTEGER);
  BEGIN pc := 0; tdx := 0; strx := 0; RH := 0; OXX.setFixOrgP(0); OXX.setFixOrgD(0); OXX.setFixOrgT(0); check := v # 0; version := v;
    IF v = 0 THEN pc := 1;
      REPEAT OXX.SetCode(pc, 0); INC(pc) UNTIL pc = 8
    END;
    IF OXS.ccARCH = OXS.RISC5 THEN xPut0 := OXT.RPut0; xPut1 := OXT.RPut1; xPut1a := OXT.RPut1a; xPut2 := OXT.RPut2; xPut3 := OXT.RPut3; xHeader := OXT.RHeader END;
    IF OXS.ccARCH = OXS.X8664 THEN xPut0 := OXT.IPut0; xPut1 := OXT.IPut1; xPut1a := OXT.IPut1a; xPut2 := OXT.IPut2; xPut3 := OXT.IPut3; xHeader := OXT.IHeader END;
    IF OXS.ccARCH = OXS.ARM64 THEN xPut0 := OXT.APut0; xPut1 := OXT.APut1; xPut1a := OXT.APut1a; xPut2 := OXT.APut2; xPut3 := OXT.APut3; xHeader := OXT.AHeader END;
    IF OXS.ccARCH = OXS.ARM32 THEN xPut0 := OXT.aPut0; xPut1 := OXT.aPut1; xPut1a := OXT.aPut1a; xPut2 := OXT.aPut2; xPut3 := OXT.aPut3; xHeader := OXT.aHeader END;
    IF OXS.ccARCH = OXS.CORTEX4 THEN xPut0 := OXT.CPut0; xPut1 := OXT.CPut1; xPut1a := OXT.CPut1a; xPut2 := OXT.CPut2; xPut3 := OXT.CPut3; xHeader := OXT.CHeader END;
    IF OXS.ccARCH = OXS.CORTEX0 THEN xPut0 := OXT.cPut0; xPut1 := OXT.cPut1; xPut1a := OXT.cPut1a; xPut2 := OXT.cPut2; xPut3 := OXT.cPut3; xHeader := OXT.cHeader END;
    IF OXS.ccARCH = OXS.RISCV64 THEN xPut0 := OXT.VPut0; xPut1 := OXT.VPut1; xPut1a := OXT.VPut1a; xPut2 := OXT.VPut2; xPut3 := OXT.VPut3; xHeader := OXT.VHeader END;
    IF OXS.ccARCH = OXS.RISCV32 THEN xPut0 := OXT.vPut0; xPut1 := OXT.vPut1; xPut1a := OXT.vPut1a; xPut2 := OXT.vPut2; xPut3 := OXT.vPut3; xHeader := OXT.vHeader END;
    IF OXS.ccARCH = OXS.WASM THEN xPut0 := OXT.WPut0; xPut1 := OXT.WPut1; xPut1a := OXT.WPut1a; xPut2 := OXT.WPut2; xPut3 := OXT.WPut3; xHeader := OXT.WHeader END;
 
    OXX.Init;
  END Open;

  (* begin-procedure-description
---
**SetDataSize** sets the amount of space reserved for module global variables.     
  end-procedure-description *)
  PROCEDURE SetDataSize*(dc: LONGINT);
  BEGIN varsize := dc
  END SetDataSize;

  (* begin-procedure-description
---
**Header** prepares the code introductory sequence for a compiled module     
  end-procedure-description *)
  PROCEDURE Header*;
  BEGIN 
    xHeader(pc,pcb,RH,entry,version)
  END Header;

  (* begin-procedure-description
---
**NofPtrs** determines the number of Garbage Collection Roots.
  end-procedure-description *)
  PROCEDURE NofPtrs(typ: OXB.Type): LONGINT;
    VAR fld: OXB.Object; n: LONGINT;
  BEGIN
    IF (typ.form = OXB.Pointer) OR (typ.form = OXB.NilTyp) THEN n := 1
    ELSIF typ.form = OXB.Record THEN
      fld := typ.dsc; n := 0;
      WHILE fld # NIL DO n := NofPtrs(fld.type) + n; fld := fld.next END
    ELSIF typ.form = OXB.Array THEN n := NofPtrs(typ.base) * typ.len
    ELSE n := 0
    END ;
    RETURN n
  END NofPtrs;

  (* begin-procedure-description
---
**FindPtrs** locates Garbage Collection roots.
  end-procedure-description *)
  PROCEDURE FindPtrs(VAR R: Files.Rider; typ: OXB.Type; adr: LONGINT);
    VAR fld: OXB.Object; i, s: LONGINT;
  BEGIN
    IF (typ.form = OXB.Pointer) OR (typ.form = OXB.NilTyp) THEN Files.WriteInt(R, adr)
    ELSIF typ.form = OXB.Record THEN
      fld := typ.dsc;
      WHILE fld # NIL DO FindPtrs(R, fld.type, fld.val + adr); fld := fld.next END
    ELSIF typ.form = OXB.Array THEN
      s := typ.base.size;
      FOR i := 0 TO typ.len-1 DO FindPtrs(R, typ.base, i*s + adr) END
    END
  END FindPtrs;



  (* begin-procedure-description
---
**Close** writes the completed binary to disk.
  end-procedure-description *)
  PROCEDURE Close*(VAR modid: OXS.Ident; key, nofent: LONGINT);
  BEGIN
    OXX.Close(pc, pcb, modid, key, nofent, entry, version, varsize, tdx, strx);
  END Close;


  (* begin-procedure-description
---
**The initialzation code for this module** merely sets the 6 values in the global relmap array.

This module's global variables are initialized by ORP calling OXG.Open, once it has begun parsing the source code's Module
definition and determined that its module imports are available and of compatible object filetype.
  end-procedure-description *)
BEGIN relmap[0] := 1; relmap[1] := 9; relmap[2] := 5; relmap[3] := 6; relmap[4] := 14; relmap[5] := 13;
(*      Close := OXX.Close; *)

END OXG.
