
## [MODULE OAG](https://github.com/io-core/Build/blob/main/OAG.Mod)

(N.Wirth, 16.4.2016 / 4.4.2017 / 31.5.2019  Oberon compiler; code generator for RISC / CP 2020 adapted to aarch64)

**OAG** is called from OAP and generates machine code various Oberon language constructs for the Oberon aarch64 architeture.


  ## Imports:
` SYSTEM Files ORS ORB`

## Constants:
```

    WordSize* = 8;
    StkOrg0 = -64; VarOrg0 = 0;  (*for aarch64-0 only*)
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

`  PROCEDURE Put0(op, a, b, c: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L77)


`  PROCEDURE Put1(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L82)


`  PROCEDURE Put1a(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L88)


`  PROCEDURE Put2(op, a, b, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L97)


`  PROCEDURE Put3(op, cond, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L102)


`  PROCEDURE incR;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L107)


`  PROCEDURE CheckRegs*;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L112)


`  PROCEDURE SetCC(VAR x: Item; n: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L119)


`  PROCEDURE Trap(cond, num: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L123)

## ---------- Handling of forward reference, fixups of instruction operands

`  PROCEDURE negated(cond: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L133)


`  PROCEDURE fix(at, with: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L139)


`  PROCEDURE FixOne*(at: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L143)


`  PROCEDURE FixLink*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L147)


`  PROCEDURE FixLinkWith(L0, dst: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L153)


`  PROCEDURE merged(L0, L1: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L162)

## ----------  Loading of operands and addresses into registers
---
**GetSB** loads the static base of a module

`  PROCEDURE GetSB(base: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L182)

---
**NilCheck** ensures a pointer is not NIL

`  PROCEDURE NilCheck;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L193)

---
**load** generates loading the contents of a variable

`  PROCEDURE load(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L201)

---
**loadAdr** generates loading the location of a variable

`  PROCEDURE loadAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L237)

---
**loadCond** generates loading a boolean

`  PROCEDURE loadCond(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L258)

---
**loadTypTagAdr** generates loading a type tag address

`  PROCEDURE loadTypTagAdr(T: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L275)

---
**loadStringAdr** generates loading a string address

`  PROCEDURE loadStringAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L284)

## ----------  Items: Conversion from constants or from Objects on the Heap to Items on the Stack
---
**MakeConstItem** prepares

`  PROCEDURE MakeConstItem*(VAR x: Item; typ: ORB.Type; val: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L298)

---
**MakeRealItem** prepares

`  PROCEDURE MakeRealItem*(VAR x: Item; val: REAL);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L306)

---
**MakeStringItem** prepares

`  PROCEDURE MakeStringItem*(VAR x: Item; len: LONGINT); (*copies string from ORS-buffer to ORG-string array*)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L314)

---
**MakeItem** prepares

`  PROCEDURE MakeItem*(VAR x: Item; y: ORB.Object; curlev: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L328)

## ----------  Code generation for Selectors, Variables, Constants
---
**Field** locates a record field

`  PROCEDURE Field*(VAR x: Item; y: ORB.Object);   (* x := x.y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L347)

---
**Index** locates an array element

`  PROCEDURE Index*(VAR x, y: Item);   (* x := x[y] *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L362)

---
**DeRef** generates a dereference

`  PROCEDURE DeRef*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L401)

---
**Q** prepares

`  PROCEDURE Q(T: ORB.Type; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L418)

---
**FindPtrFlds** prepares

`  PROCEDURE FindPtrFlds(typ: ORB.Type; off: LONGINT; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L430)

---
**BuildTD** prepares

`  PROCEDURE BuildTD*(T: ORB.Type; VAR dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L447)

---
**TypeTest** generates a type test

`  PROCEDURE TypeTest*(VAR x: Item; T: ORB.Type; varpar, isguard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L467)

## ----------  Code generation for Boolean operators
---
**Not** generates

`  PROCEDURE Not*(VAR x: Item);   (* x := ~x *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L501)

---
**And1** generates

`  PROCEDURE And1*(VAR x: Item);   (* x := x & *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L512)

---
**And2** generates

`  PROCEDURE And2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L522)

---
**Or1** generates

`  PROCEDURE Or1*(VAR x: Item);   (* x := x OR *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L532)

---
**Or2** generates

`  PROCEDURE Or2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L542)

## ----------  Code generation for arithmetic operators

`  PROCEDURE Neg*(VAR x: Item);   (* x := -x *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L554)

---
**AddOp** generates an add operation

`  PROCEDURE AddOp*(op: LONGINT; VAR x, y: Item);   (* x := x +- y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L575)

---
**log2** generates a log2 operation

`  PROCEDURE log2(m: LONGINT; VAR e: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L596)

---
**MulOp** generates a multipy operation

`  PROCEDURE MulOp*(VAR x, y: Item);   (* x := x * y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L606)

---
**DivOp** generates a divide operation

`  PROCEDURE DivOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L622)

## ----------  Code generation for REAL operators
---
**RealOp** generates operations on reals

`  PROCEDURE RealOp*(op: INTEGER; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L659)

## ----------  Code generation for set operators
---
**Singleton** generates a set of one set item.

`  PROCEDURE Singleton*(VAR x: Item);  (* x := {x} *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L679)

---
**Set** generates a set value from two set items.

`  PROCEDURE Set*(VAR x, y: Item);   (* x := {x .. y} *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L690)

---
**In** generates a test for if an item is in a set

`  PROCEDURE In*(VAR x, y: Item);  (* x := x IN y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L713)

---
**SetOp** generates operations on sets

`  PROCEDURE SetOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L725)

## ----------  Code generation for relations
---
**IntRelation** generates an integer comparison

`  PROCEDURE IntRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L763)

---
**RealRelation** generates a real comparison

`  PROCEDURE RealRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L780)

---
**StringRelation** generates a string comparison

`  PROCEDURE StringRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L792)

## ----------  Code generation of Assigments
---
**StrToChar** ??

`  PROCEDURE StrToChar*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L814)

---
**Store** generates the copying of the value of one word-sized variable into another word-sized variable.

`  PROCEDURE Store*(VAR x, y: Item); (* x := y *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L822)

---
**StoreStruct** generates copying the contents of one structure into another structure.

`  PROCEDURE StoreStruct*(VAR x, y: Item); (* x := y, frame = 0 *)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L841)

---
**CopyString** generates copying the contents of one string variable into another string variable.

`  PROCEDURE CopyString*(VAR x, y: Item);  (* x := y *) ` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L875)

## ----------  Code generation for parameters
---
**OpenArrayParam** generates placing the address of an open array variable in a register, allocating the register.

`  PROCEDURE OpenArrayParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L899)

---
**VarParam** generates placing the address of a variable in a register, allocating the register.

`  PROCEDURE VarParam*(VAR x: Item; ftype: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L909)

---
**ValueParam** generates placing a value in a register.

`  PROCEDURE ValueParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L924)

---
**StringParam** generates placing the location of a string in a register, allocating the register.

`  PROCEDURE StringParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L932)

## ----------  For Statements
---
**For0** generates the initial part of a FOR statement

`  PROCEDURE For0*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L946)

---
**FOR1** generates the central part of a FOR statement

`  PROCEDURE For1*(VAR x, y, z, w: Item; VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L954)

---
**FOR2** generates the final part of a FOR statement.

`  PROCEDURE For2*(VAR x, y, w: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L971)

## ----------  Branches, procedure calls, procedure prolog and epilog
---
**Here** returns the next available code location.

`  PROCEDURE Here*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L985)

---
**FJump** generates a forward jump.

`  PROCEDURE FJump*(VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L993)

---
**CFJump** generates a conditional forward jump

`  PROCEDURE CFJump*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1001)

---
**BJump** generates a backwards jump.

`  PROCEDURE BJump*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1011)

---
**CBJump** generates a conditional backwards jump.

`  PROCEDURE CBJump*(VAR x: Item; L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1019)

---
**Fixup** fixes ???

`  PROCEDURE Fixup*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1029)

---
**SaveRegs** saves register values in preparation for a procedure call.

`  PROCEDURE SaveRegs(r: LONGINT);  (* R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1037)

---
**RestoreRegs** brings values back into registers after a procedure call.

`  PROCEDURE RestoreRegs(r: LONGINT); (*R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1048)

---
**PrepCall** generates generates a sequence that preapreas for a procedure call.

`  PROCEDURE PrepCall*(VAR x: Item; VAR r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1059)

---
**Call** generates the procedure call sequence.

`  PROCEDURE Call*(VAR x: Item; r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1070)

---
**Enter** generates the procedure entry sequence.

`  PROCEDURE Enter*(parblksize, locblksize: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1098)

---
**Return** generates the procedure return sequence.

`  PROCEDURE Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1116)

## ----------  In-line code procedures
---
**Increment** generates an inline routine that increments a variable.

`  PROCEDURE Increment*(upordown: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1138)

---
**Include** generates a routine that ??

`  PROCEDURE Include*(inorex: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1158)

---
**Assert** generates an inline routine that traps on a condition.

`  PROCEDURE Assert*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1172)

---
**New** generates an inline routine that allocates heap memory via trap 0.

`  PROCEDURE New*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1186)

---
**Pack** generates an inline routine that ??

`  PROCEDURE Pack*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1194)

---
**Unpk** generates in inline routine that ??

`  PROCEDURE Unpk*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1204)

---
**Led** generates an inline routine that displays a bit pattern on the LED display.

`  PROCEDURE Led*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1215)

---
**Get** generates an inline routine that loads a value from an IO register.

`  PROCEDURE Get*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1223)

---
**Put** generates an inline routine that stores a value in an IO register.

`  PROCEDURE Put*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1231)

---
**Copy** generates an inline memory copy routine.     

`  PROCEDURE Copy*(VAR x, y, z: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1239)

---
**LDPSR** places the processor status register in a variable     

`  PROCEDURE LDPSR*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1256)

---
**LDREG** places a register value in a variable     

`  PROCEDURE LDREG*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1264)

## ----------  In-line code functions
---
**Abs** generates an inline functionn that takes the absolute value     

`  PROCEDURE Abs*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1281)

---
**Odd** generates an inlinen function that checks whether a value is odd.     

`  PROCEDURE Odd*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1295)

---
**Floor** generates an inline function that produces the floor of a value.     

`  PROCEDURE Floor*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1303)

---
**Float** generates an inline function that produces a float.     

`  PROCEDURE Float*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1311)

---
**Ord** generates an inline function that presents the ordinal value of its parameter.     

`  PROCEDURE Ord*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1319)

---
**Len** generates an inline function that presents the length of an array.     

`  PROCEDURE Len*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1328)

---
**Shift** generates an inline function that performs bit shifts.      

`  PROCEDURE Shift*(fct: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1341)

---
**ADC** generates an inline function that Adds with Carry     

`  PROCEDURE ADC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1354)

---
**SBC** generates an inline function that Subtracts with Carry 

`  PROCEDURE SBC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1362)

---
**UML** generates an inline function ??     

`  PROCEDURE UML*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1370)

---
**Bit** generates an inline function presenting the yth bit of x      

`  PROCEDURE Bit*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1378)

---
**Register** generates an inline function presenting a general register's contents      

`  PROCEDURE Register*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1390)

---
**H** genrates an inline funtion presenting the contents of the H register.     

`  PROCEDURE H*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1399)

---
**Adr** generates an inline function presenting the memory address of its parameter.      

`  PROCEDURE Adr*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1408)

---
**Condition** generates an inline function presenting a condition.     

`  PROCEDURE Condition*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1421)

---
**Open** initializes the ORG module code generation engine.     

`  PROCEDURE Open*(v: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1429)

---
**SetDataSize** sets the amount of space reserved for module global variables.     

`  PROCEDURE SetDataSize*(dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1440)

---
**Header** prepares the code introductory sequence for a compiled module     

`  PROCEDURE Header*;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1448)

---
**NofPtrs** determines the number of Garbage Collection Roots.

`  PROCEDURE NofPtrs(typ: ORB.Type): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1459)

---
**FindPtrs** locates Garbage Collection roots.

`  PROCEDURE FindPtrs(VAR R: Files.Rider; typ: ORB.Type; adr: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1476)

---
**Close** writes the completed binary to disk.

`  PROCEDURE Close*(VAR modid: ORS.Ident; key, nofent: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OAG.Mod#L1493)

---
**The initialzation code for this module** merely sets the 6 values in the global relmap array.

This module's global variables are initialized by OAP calling OAG.Open, once it has begun parsing the source code's Module
definition and determined that its module imports are available and of compatible object filetype.
