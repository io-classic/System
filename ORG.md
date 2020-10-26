
## [MODULE ORG](https://github.com/io-core/Build/blob/main/ORG.Mod)

(N.Wirth, 16.4.2016 / 4.4.2017 / 31.5.2019  Oberon compiler; code generator for RISC)

**ORG** is called from ORP and generates machine code various Oberon language constructs for the Oberon RISC5 architeture.


  ## Imports:
` SYSTEM Files ORS ORB`

## Constants:
```

    WordSize* = 4;
    StkOrg0 = -64; VarOrg0 = 0;  (*for RISC-0 only*)
    MT = 12; SP = 14; LNK = 15;   (*dedicated registers*)
    maxCode = 8000; maxStrx = 2400; maxTD = 160; C24 = 1000000H;
    Reg = 10; RegI = 11; Cond = 12;  (*internal item modes*)

  (*frequently used opcodes*)  U = 2000H; V = 1000H;
    Mov = 0; Lsl = 1; Asr = 2; Ror= 3; And = 4; Ann = 5; Ior = 6; Xor = 7;
    Add = 8; Sub = 9; Cmp = 9; Mul = 10; Div = 11;
    Fad = 12; Fsb = 13; Fml = 14; Fdv = 15;
    Ldr = 8; Str = 10;
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;

```
## Types:
```
 
    Item* = RECORD
      mode*: INTEGER;
      type*: ORB.Type;
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

```
## Variables:
```
 
    pc*, varsize: LONGINT;   (*program counter, data index*)
    tdx, strx: LONGINT;
    entry: LONGINT;   (*main entry point*)
    RH: LONGINT;  (*available registers R[0] ... R[H-1]*)
    frame: LONGINT;  (*frame offset changed in SaveRegs and RestoreRegs*)
    fixorgP, fixorgD, fixorgT: LONGINT;   (*origins of lists of locations to be fixed up by loader*)
    check: BOOLEAN;  (*emit run-time checks*)
    version: INTEGER;  (* 0 = RISC-0, 1 = RISC-5 *)
    relmap: ARRAY 6 OF INTEGER;  (*condition codes for relations*)
    code: ARRAY maxCode OF LONGINT;
    data: ARRAY maxTD OF LONGINT;  (*type descriptors*)
    str: ARRAY maxStrx OF CHAR;

```
## Procedures:
---
## ---------- Instruction assemblers according to formats
---
**Put0** 

`  PROCEDURE Put0(op, a, b, c: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L80)


`  PROCEDURE Put1(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L85)


`  PROCEDURE Put1a(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L91)


`  PROCEDURE Put2(op, a, b, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L100)


`  PROCEDURE Put3(op, cond, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L105)


`  PROCEDURE incR;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L110)


`  PROCEDURE CheckRegs*;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L115)


`  PROCEDURE SetCC(VAR x: Item; n: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L122)


`  PROCEDURE Trap(cond, num: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L126)

## ---------- Handling of forward reference, fixups of instruction operands

`  PROCEDURE negated(cond: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L136)


`  PROCEDURE fix(at, with: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L142)


`  PROCEDURE FixOne*(at: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L146)


`  PROCEDURE FixLink*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L150)


`  PROCEDURE FixLinkWith(L0, dst: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L156)


`  PROCEDURE merged(L0, L1: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L165)

## ----------  Loading of operands and addresses into registers

`  PROCEDURE GetSB(base: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L181)


`  PROCEDURE NilCheck;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L188)


`  PROCEDURE load(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L192)


`  PROCEDURE loadAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L224)


`  PROCEDURE loadCond(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L241)


`  PROCEDURE loadTypTagAdr(T: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L254)


`  PROCEDURE loadStringAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L259)

## ----------  Items: Conversion from constants or from Objects on the Heap to Items on the Stack

`  PROCEDURE MakeConstItem*(VAR x: Item; typ: ORB.Type; val: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L269)


`  PROCEDURE MakeRealItem*(VAR x: Item; val: REAL);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L273)


`  PROCEDURE MakeStringItem*(VAR x: Item; len: LONGINT); (*copies string from ORS-buffer to ORG-string array*)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L277)


`  PROCEDURE MakeItem*(VAR x: Item; y: ORB.Object; curlev: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L287)

## ----------  Code generation for Selectors, Variables, Constants

`  PROCEDURE Field*(VAR x: Item; y: ORB.Object);   (* x := x.y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L302)


`  PROCEDURE Index*(VAR x, y: Item);   (* x := x[y] *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L313)


`  PROCEDURE DeRef*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L348)


`  PROCEDURE Q(T: ORB.Type; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L361)


`  PROCEDURE FindPtrFlds(typ: ORB.Type; off: LONGINT; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L369)


`  PROCEDURE BuildTD*(T: ORB.Type; VAR dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L382)


`  PROCEDURE TypeTest*(VAR x: Item; T: ORB.Type; varpar, isguard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L398)

## ----------  Code generation for Boolean operators

`  PROCEDURE Not*(VAR x: Item);   (* x := ~x *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L428)


`  PROCEDURE And1*(VAR x: Item);   (* x := x & *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L435)


`  PROCEDURE And2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L441)


`  PROCEDURE Or1*(VAR x: Item);   (* x := x OR *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L447)


`  PROCEDURE Or2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L453)

## ----------  Code generation for arithmetic operators

`  PROCEDURE Neg*(VAR x: Item);   (* x := -x *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L465)


`  PROCEDURE AddOp*(op: LONGINT; VAR x, y: Item);   (* x := x +- y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L482)


`  PROCEDURE log2(m: LONGINT; VAR e: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L499)


`  PROCEDURE MulOp*(VAR x, y: Item);   (* x := x * y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L505)


`  PROCEDURE DivOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L517)

## ----------  Code generation for REAL operators

`  PROCEDURE RealOp*(op: INTEGER; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L550)

## ----------  Code generation for set operators

`  PROCEDURE Singleton*(VAR x: Item);  (* x := {x} *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L566)


`  PROCEDURE Set*(VAR x, y: Item);   (* x := {x .. y} *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L573)


`  PROCEDURE In*(VAR x, y: Item);  (* x := x IN y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L592)


`  PROCEDURE SetOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L600)

## ----------  Code generation for relations

`  PROCEDURE IntRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L634)


`  PROCEDURE RealRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L647)


`  PROCEDURE StringRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L655)

## ----------  Code generation of Assigments

`  PROCEDURE StrToChar*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L673)


`  PROCEDURE Store*(VAR x, y: Item); (* x := y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L677)


`  PROCEDURE StoreStruct*(VAR x, y: Item); (* x := y, frame = 0 *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L692)


`  PROCEDURE CopyString*(VAR x, y: Item);  (* x := y *) ` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L722)

## ----------  Code generation for parameters

`  PROCEDURE OpenArrayParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L742)


`  PROCEDURE VarParam*(VAR x: Item; ftype: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L748)


`  PROCEDURE ValueParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L759)


`  PROCEDURE StringParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L763)

## ----------  For Statements

`  PROCEDURE For0*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L773)


`  PROCEDURE For1*(VAR x, y, z, w: Item; VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L777)


`  PROCEDURE For2*(VAR x, y, w: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L790)

## ----------  Branches, procedure calls, procedure prolog and epilog

`  PROCEDURE Here*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L800)


`  PROCEDURE FJump*(VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L804)


`  PROCEDURE CFJump*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L808)


`  PROCEDURE BJump*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L814)


`  PROCEDURE CBJump*(VAR x: Item; L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L818)


`  PROCEDURE Fixup*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L824)


`  PROCEDURE SaveRegs(r: LONGINT);  (* R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L828)


`  PROCEDURE RestoreRegs(r: LONGINT); (*R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L835)


`  PROCEDURE PrepCall*(VAR x: Item; VAR r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L842)


`  PROCEDURE Call*(VAR x: Item; r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L849)


`  PROCEDURE Enter*(parblksize, locblksize: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L873)


`  PROCEDURE Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L887)

## ----------  In-line code procedures

`  PROCEDURE Increment*(upordown: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L905)


`  PROCEDURE Include*(inorex: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L921)


`  PROCEDURE Assert*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L931)


`  PROCEDURE New*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L941)


`  PROCEDURE Pack*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L945)


`  PROCEDURE Unpk*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L951)


`  PROCEDURE Led*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L958)


`  PROCEDURE Get*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L962)


`  PROCEDURE Put*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L966)

---
**Copy** generates an inline memory copy routine.     

`   PROCEDURE Copy*(VAR x, y, z: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L974)

---
**LDPSR** places the processor status register in a variable     

`   PROCEDURE LDPSR*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L991)

---
**LDREG** places a register value in a variable     

`   PROCEDURE LDREG*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L999)

## ----------  In-line code functions
---
**Abs** generates an inline functionn that takes the absolute value     

`   PROCEDURE Abs*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1016)

---
**Odd** generates an inlinen function that checks whether a value is odd.     

`   PROCEDURE Odd*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1030)

---
**Floor** generates an inline function that produces the floor of a value.     

`   PROCEDURE Floor*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1038)

---
**Float** generates an inline function that produces a float.     

`   PROCEDURE Float*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1046)

---
**Ord** generates an inline function that presents the ordinal value of its parameter.     

`   PROCEDURE Ord*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1054)

---
**Len** generates an inline function that presents the length of an array.     

`   PROCEDURE Len*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1063)

---
**Shift** generates an inline function that performs bit shifts.      

`   PROCEDURE Shift*(fct: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1076)

---
**ADC** generates an inline function that Adds with Carry     

`   PROCEDURE ADC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1089)

---
**SBC** generates an inline function that Subtracts with Carry 

`   PROCEDURE SBC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1097)

---
**UML** generates an inline function ??     

`   PROCEDURE UML*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1105)

---
**Bit** generates an inline function presenting the yth bit of x      

`   PROCEDURE Bit*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1113)

---
**Register** generates an inline function presenting a general register's contents      

`   PROCEDURE Register*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1125)

---
**H** genrates an inline funtion presenting the contents of the H register.     

`   PROCEDURE H*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1134)

---
**Adr** generates an inline function presenting the memory address of its parameter.      

`   PROCEDURE Adr*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1143)

---
**Condition** generates an inline function presenting a condition.     

`   PROCEDURE Condition*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1156)

---
**Open** initializes the ORG module code generation engine.     

`   PROCEDURE Open*(v: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1164)

---
**SetDataSize** sets the amount of space reserved for module global variables.     

`   PROCEDURE SetDataSize*(dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1175)

---
**Header** prepares the code introductory sequence for a compiled module     

`   PROCEDURE Header*;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1183)

---
**NofPtrs** determines the number of Garbage Collection Roots.

`  PROCEDURE NofPtrs(typ: ORB.Type): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1194)

---
**FindPtrs** locates Garbage Collection roots.

`  PROCEDURE FindPtrs(VAR R: Files.Rider; typ: ORB.Type; adr: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1211)

---
**Close** writes the completed binary to disk.

`  PROCEDURE Close*(VAR modid: ORS.Ident; key, nofent: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1228)

---
**The initialzation code for this module** merely sets the 6 values in the global relmap array.

This module's global variables are initialized by ORP calling ORG.Open, once it has begun parsing the source code's Module
definition and determined that its module imports are available and of compatible object filetype.
