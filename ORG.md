
## [MODULE ORG](https://github.com/io-core/Build/blob/main/ORG.Mod)

(N.Wirth, 16.4.2016 / 4.4.2017 / 31.5.2019  Oberon compiler; code generator for RISC / AP 1.9.20 Extended Oberon / CP 10.20 Integrated Oberon)

**ORG** is called from ORP and generates machine code various Oberon-2i language constructs for the Oberon RISC5 architeture.


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

`  PROCEDURE Put0(op, a, b, c: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L68)


`  PROCEDURE Put1(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L73)


`  PROCEDURE Put1a(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L79)


`  PROCEDURE Put2(op, a, b, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L88)


`  PROCEDURE Put3(op, cond, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L93)


`  PROCEDURE incR;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L98)


`  PROCEDURE CheckRegs*;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L103)


`  PROCEDURE SetCC(VAR x: Item; n: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L110)


`  PROCEDURE Trap(cond, num: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L114)


`  PROCEDURE negated(cond: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L120)


`  PROCEDURE fix(at, with: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L126)


`  PROCEDURE FixOne*(at: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L130)


`  PROCEDURE FixLink*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L134)


`  PROCEDURE FixLinkWith(L0, dst: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L140)


`  PROCEDURE merged(L0, L1: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L149)


`  PROCEDURE GetSB(base: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L161)


`  PROCEDURE NilCheck;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L168)


`  PROCEDURE load(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L172)


`  PROCEDURE loadAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L204)


`  PROCEDURE loadCond(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L221)


`  PROCEDURE loadTypTagAdr(T: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L234)


`  PROCEDURE loadStringAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L239)


`  PROCEDURE MakeConstItem*(VAR x: Item; typ: ORB.Type; val: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L245)


`  PROCEDURE MakeRealItem*(VAR x: Item; val: REAL);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L249)


`  PROCEDURE MakeStringItem*(VAR x: Item; len: LONGINT); (*copies string from ORS-buffer to ORG-string array*)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L253)


`  PROCEDURE MakeItem*(VAR x: Item; y: ORB.Object; curlev: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L263)


`  PROCEDURE Field*(VAR x: Item; y: ORB.Object);   (* x := x.y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L274)


`  PROCEDURE Index*(VAR x, y: Item);   (* x := x[y] *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L285)


`  PROCEDURE DeRef*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L320)


`  PROCEDURE Q(T: ORB.Type; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L333)


`  PROCEDURE FindPtrFlds(typ: ORB.Type; off: LONGINT; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L341)


`  PROCEDURE BuildTD*(T: ORB.Type; VAR dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L354)


`  PROCEDURE TypeTest*(VAR x: Item; T: ORB.Type; varpar, isguard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L370)


`  PROCEDURE Not*(VAR x: Item);   (* x := ~x *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L396)


`  PROCEDURE And1*(VAR x: Item);   (* x := x & *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L403)


`  PROCEDURE And2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L409)


`  PROCEDURE Or1*(VAR x: Item);   (* x := x OR *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L415)


`  PROCEDURE Or2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L421)


`  PROCEDURE Neg*(VAR x: Item);   (* x := -x *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L429)


`  PROCEDURE AddOp*(op: LONGINT; VAR x, y: Item);   (* x := x +- y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L446)


`  PROCEDURE log2(m: LONGINT; VAR e: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L463)


`  PROCEDURE MulOp*(VAR x, y: Item);   (* x := x * y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L469)


`  PROCEDURE DivOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L481)


`  PROCEDURE RealOp*(op: INTEGER; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L510)


`  PROCEDURE Singleton*(VAR x: Item);  (* x := {x} *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L522)


`  PROCEDURE Set*(VAR x, y: Item);   (* x := {x .. y} *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L529)


`  PROCEDURE In*(VAR x, y: Item);  (* x := x IN y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L548)


`  PROCEDURE SetOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L556)


`  PROCEDURE IntRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L586)


`  PROCEDURE RealRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L599)


`  PROCEDURE StringRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L607)


`  PROCEDURE StrToChar*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L621)


`  PROCEDURE Store*(VAR x, y: Item); (* x := y *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L625)


`  PROCEDURE StoreStruct*(VAR x, y: Item); (* x := y, frame = 0 *)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L640)


`  PROCEDURE CopyString*(VAR x, y: Item);  (* x := y *) ` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L670)


`  PROCEDURE OpenArrayParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L686)


`  PROCEDURE VarParam*(VAR x: Item; ftype: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L692)


`  PROCEDURE ValueParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L703)


`  PROCEDURE StringParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L707)


`  PROCEDURE For0*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L713)


`  PROCEDURE For1*(VAR x, y, z, w: Item; VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L717)


`  PROCEDURE For2*(VAR x, y, w: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L730)


`  PROCEDURE Here*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L736)


`  PROCEDURE FJump*(VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L740)


`  PROCEDURE CFJump*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L744)


`  PROCEDURE BJump*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L750)


`  PROCEDURE CBJump*(VAR x: Item; L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L754)


`  PROCEDURE Fixup*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L760)


`  PROCEDURE SaveRegs(r: LONGINT);  (* R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L764)


`  PROCEDURE RestoreRegs(r: LONGINT); (*R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L771)


`  PROCEDURE PrepCall*(VAR x: Item; VAR r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L778)


`  PROCEDURE Call*(VAR x: Item; r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L785)


`  PROCEDURE Enter*(parblksize, locblksize: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L809)


`  PROCEDURE Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L823)


`  PROCEDURE Increment*(upordown: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L837)


`  PROCEDURE Include*(inorex: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L853)


`  PROCEDURE Assert*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L863)


`  PROCEDURE New*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L873)


`  PROCEDURE Pack*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L877)


`  PROCEDURE Unpk*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L883)


`  PROCEDURE Led*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L890)


`  PROCEDURE Get*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L894)


`  PROCEDURE Put*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L898)


`  PROCEDURE Copy*(VAR x, y, z: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L902)


`  PROCEDURE LDPSR*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L915)


`  PROCEDURE LDREG*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L919)


`  PROCEDURE Abs*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L928)


`  PROCEDURE Odd*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L938)


`  PROCEDURE Floor*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L942)


`  PROCEDURE Float*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L946)


`  PROCEDURE Ord*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L950)


`  PROCEDURE Len*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L955)


`  PROCEDURE Shift*(fct: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L964)


`  PROCEDURE ADC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L973)


`  PROCEDURE SBC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L977)


`  PROCEDURE UML*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L981)


`  PROCEDURE Bit*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L985)


`  PROCEDURE Register*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L993)


`  PROCEDURE H*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L998)


`  PROCEDURE Adr*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1003)


`  PROCEDURE Condition*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1012)


`  PROCEDURE Open*(v: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1016)


`  PROCEDURE SetDataSize*(dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1023)


`  PROCEDURE Header*;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1027)


`  PROCEDURE NofPtrs(typ: ORB.Type): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1034)


`  PROCEDURE FindPtrs(VAR R: Files.Rider; typ: ORB.Type; adr: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1047)


`  PROCEDURE Close*(VAR modid: ORS.Ident; key, nofent: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORG.Mod#L1060)

