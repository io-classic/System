
## [MODULE ODG](https://github.com/io-core/Build/blob/main/ODG.Mod)

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

`  PROCEDURE Put0(op, a, b, c: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L53)


`  PROCEDURE Put1(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L58)


`  PROCEDURE Put1a(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L64)


`  PROCEDURE Put2(op, a, b, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L73)


`  PROCEDURE Put3(op, cond, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L78)


`  PROCEDURE incR;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L83)


`  PROCEDURE CheckRegs*;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L88)


`  PROCEDURE SetCC(VAR x: Item; n: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L95)


`  PROCEDURE Trap(cond, num: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L99)


`  PROCEDURE negated(cond: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L105)


`  PROCEDURE fix(at, with: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L111)


`  PROCEDURE FixOne*(at: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L115)


`  PROCEDURE FixLink*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L119)


`  PROCEDURE FixLinkWith(L0, dst: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L125)


`  PROCEDURE merged(L0, L1: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L134)


`  PROCEDURE GetSB(base: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L146)


`  PROCEDURE NilCheck;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L153)


`  PROCEDURE load(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L157)


`  PROCEDURE loadAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L189)


`  PROCEDURE loadCond(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L206)


`  PROCEDURE loadTypTagAdr(T: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L219)


`  PROCEDURE loadStringAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L224)


`  PROCEDURE MakeConstItem*(VAR x: Item; typ: ORB.Type; val: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L230)


`  PROCEDURE MakeRealItem*(VAR x: Item; val: REAL);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L234)


`  PROCEDURE MakeStringItem*(VAR x: Item; len: LONGINT); (*copies string from ORS-buffer to ORG-string array*)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L238)


`  PROCEDURE MakeItem*(VAR x: Item; y: ORB.Object; curlev: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L248)


`  PROCEDURE Field*(VAR x: Item; y: ORB.Object);   (* x := x.y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L259)


`  PROCEDURE Index*(VAR x, y: Item);   (* x := x[y] *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L270)


`  PROCEDURE DeRef*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L305)


`  PROCEDURE Q(T: ORB.Type; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L318)


`  PROCEDURE FindPtrFlds(typ: ORB.Type; off: LONGINT; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L326)


`  PROCEDURE BuildTD*(T: ORB.Type; VAR dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L339)


`  PROCEDURE TypeTest*(VAR x: Item; T: ORB.Type; varpar, isguard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L355)


`  PROCEDURE Not*(VAR x: Item);   (* x := ~x *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L381)


`  PROCEDURE And1*(VAR x: Item);   (* x := x & *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L388)


`  PROCEDURE And2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L394)


`  PROCEDURE Or1*(VAR x: Item);   (* x := x OR *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L400)


`  PROCEDURE Or2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L406)


`  PROCEDURE Neg*(VAR x: Item);   (* x := -x *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L414)


`  PROCEDURE AddOp*(op: LONGINT; VAR x, y: Item);   (* x := x +- y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L431)


`  PROCEDURE log2(m: LONGINT; VAR e: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L448)


`  PROCEDURE MulOp*(VAR x, y: Item);   (* x := x * y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L454)


`  PROCEDURE DivOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L466)


`  PROCEDURE RealOp*(op: INTEGER; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L495)


`  PROCEDURE Singleton*(VAR x: Item);  (* x := {x} *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L507)


`  PROCEDURE Set*(VAR x, y: Item);   (* x := {x .. y} *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L514)


`  PROCEDURE In*(VAR x, y: Item);  (* x := x IN y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L533)


`  PROCEDURE SetOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L541)


`  PROCEDURE IntRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L571)


`  PROCEDURE RealRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L584)


`  PROCEDURE StringRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L592)


`  PROCEDURE StrToChar*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L606)


`  PROCEDURE Store*(VAR x, y: Item); (* x := y *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L610)


`  PROCEDURE StoreStruct*(VAR x, y: Item); (* x := y, frame = 0 *)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L625)


`  PROCEDURE CopyString*(VAR x, y: Item);  (* x := y *) ` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L655)


`  PROCEDURE OpenArrayParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L671)


`  PROCEDURE VarParam*(VAR x: Item; ftype: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L677)


`  PROCEDURE ValueParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L688)


`  PROCEDURE StringParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L692)


`  PROCEDURE For0*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L698)


`  PROCEDURE For1*(VAR x, y, z, w: Item; VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L702)


`  PROCEDURE For2*(VAR x, y, w: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L715)


`  PROCEDURE Here*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L721)


`  PROCEDURE FJump*(VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L725)


`  PROCEDURE CFJump*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L729)


`  PROCEDURE BJump*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L735)


`  PROCEDURE CBJump*(VAR x: Item; L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L739)


`  PROCEDURE Fixup*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L745)


`  PROCEDURE SaveRegs(r: LONGINT);  (* R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L749)


`  PROCEDURE RestoreRegs(r: LONGINT); (*R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L756)


`  PROCEDURE PrepCall*(VAR x: Item; VAR r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L763)


`  PROCEDURE Call*(VAR x: Item; r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L770)


`  PROCEDURE Enter*(parblksize, locblksize: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L794)


`  PROCEDURE Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L808)


`  PROCEDURE Increment*(upordown: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L822)


`  PROCEDURE Include*(inorex: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L838)


`  PROCEDURE Assert*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L848)


`  PROCEDURE New*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L858)


`  PROCEDURE Pack*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L862)


`  PROCEDURE Unpk*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L868)


`  PROCEDURE Led*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L875)


`  PROCEDURE Get*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L879)


`  PROCEDURE Put*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L883)


`  PROCEDURE Copy*(VAR x, y, z: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L887)


`  PROCEDURE LDPSR*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L900)


`  PROCEDURE LDREG*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L904)


`  PROCEDURE Abs*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L913)


`  PROCEDURE Odd*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L923)


`  PROCEDURE Floor*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L927)


`  PROCEDURE Float*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L931)


`  PROCEDURE Ord*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L935)


`  PROCEDURE Len*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L940)


`  PROCEDURE Shift*(fct: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L949)


`  PROCEDURE ADC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L958)


`  PROCEDURE SBC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L962)


`  PROCEDURE UML*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L966)


`  PROCEDURE Bit*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L970)


`  PROCEDURE Register*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L978)


`  PROCEDURE H*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L983)


`  PROCEDURE Adr*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L988)


`  PROCEDURE Condition*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L997)


`  PROCEDURE Open*(v: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L1001)


`  PROCEDURE SetDataSize*(dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L1008)


`  PROCEDURE Header*;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L1012)


`  PROCEDURE NofPtrs(typ: ORB.Type): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L1019)


`  PROCEDURE FindPtrs(VAR R: Files.Rider; typ: ORB.Type; adr: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L1032)


`  PROCEDURE Close*(VAR modid: ORS.Ident; key, nofent: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODG.Mod#L1045)

