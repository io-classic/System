
## [MODULE OaG](https://github.com/io-core/Build/blob/main/OaG.Mod)
Module OaG generates the 32-bit ARM processor-specific instructions for executing an Oberon program. 


(N.Wirth, 16.4.2016 / 4.4.2017 / 31.5.2019  Oberon compiler; code generator for RISC / CP 2020 adapted to 32-bit ARM)

**OaG** is called from OaP and generates machine code various Oberon language constructs for the Oberon 32-bit ARM architeture.


  ## Imports:
` SYSTEM Files ORS ORB`

## Constants:
```

    WordSize* = 4;
(*    StkOrg0 = -64; VarOrg0 = 0;  (*for RISC-0 only*) *)
(*    MT = 12; SP = 14; LNK = 15;   (*dedicated registers*) *)
(*    maxCode = 8000; maxStrx = 2400; maxTD = 160; C24 = 1000000H; *)
(*    Reg = 10; RegI = 11; Cond = 12;  (*internal item modes*) *)

  (*frequently used opcodes*) (* U = 2000H; *) V = 1000H;
(*    Mov = 0; Lsl = 1; Asr = 2; Ror= 3; And = 4; Ann = 5; Ior = 6; Xor = 7;
    Add = 8; Sub = 9; Cmp = 9; Mul = 10; Div = 11;
    Fad = 12; Fsb = 13; Fml = 14; Fdv = 15; *)
(*    Ldr = 8; Str = 10; *)
(*    BR = 0; BLR = 1; BC = 2; BL = 3; *)
(*    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;*)

                ObjMark = 0F5X;
                CodeLength = 32768; (* 128K Code. Don't make it bigger (because of fixup list limits! *)
                ConstLength = 1024; (* in Words *)
                StrConstLength = 4096; (* in Bytes, ziemlich willkrlich, kann ruhig VIEL groesser sein *)
                MaxConstDist = ConstLength-15; (* in Words including a safety range *)
                MaxUnknownProcs = 128;
                MaxPtrs = 512; MaxRecs = 128; MaxComs = 40; MaxExts = 15;

                (* Constants for Bit x set *)
                C22 = 400000H; C23 = 800000H; C24 = 1000000H; C25 = 2000000H;

                (* Op-Codes Single Data Transfer (SDT) *)
                LDR* = 51H; (* LDR, pre-indexed, no write-back *)
                STR* = 50H; (* STR, pre-indexed, no write-back *)
                LDRB* = 55H; (* LDRB, pre-indexed, no write-back *)
                STRB* = 54H; (* STRB, pre-indexed, no write-back *)
                        LDRpost* = 41H; (* LDR, post-indexed, no write-back-bit *)
                STRpost* = 40H; (* STR, post-indexed, no write-back-bit *)
                LDRBpost* = 45H; (* LDRB, post-indexed, no write-back-bit *)
                STRBpost* = 44H; (* STRB, post-indexed, no write-back-bit *)
                        (* Op-Codes Halfword Data Transfer (HDT) *)
                LDRSH* = 11000F0H; (* LDRSH, pre-indexed, no write-back *)
                STRH* = 10000B0H; (* STRH, pre-indexed, no write-back *)
                LDRSB* = 11000D0H; (* LDRSB, pre-indexed, no write-back *)

                (* Op-Codes Block Data Transfer (BDT) *)
                LDMIA* = 89H; STMIA* = 88H; STMDB* = 90H;

                (* Op-Codes Data Processing: S-Bit is always set (except for MOV and RSBnoflags ) ! *)
                AND* = 1; EOR* = 3; SUB* = 5; RSBnoflags* = 6; RSB* = 7; ADD* = 9; ADCop = 11; SBCop = 13; RSC = 15; TST* = 17;
                TEQ = 19;
                CMP* = 21; CMN* = 23;  ORR* = 25; MOV* = 26; MOVS* = 27; BIC* = 29; MVN* = 30; MVNS = 31;

                (* Op-Codes Branch Instructions *)
                (* B* = 10; BL* = 11; *)

                (* Op-Codes Multiplication *)
                MUL* = 0; MLA* = 200000H;

                (* Op-Codes Long Multiplication *)
                SMULL* = 00C00090H;

                (* Conditions *)
                EQ* = 0; NE* = 1; CS* = 2; CC* = 3;  MI* = 4; PL* = 5; VS* = 6; VC* = 7;
                HI* = 8; LS* = 9; GE* = 10; LT* = 11;  GT* = 12; LE* = 13; AL* = 14; NV* = 15;

                (* Register Numbers *)
                PC* = 15; LR* = 14; SP* = 13; FP* = 12; FirstUniversalReg = 9;

                (* Const Types *)
                Constant = 0; StringAddr = 1; ProcAddr = 2; ExtAddr = 3;

    StkOrg0 = -64; VarOrg0 = 0;

    MT = 10; SB = 11; (*SP = 13; *) LNK = 14;   (*dedicated registers*)
(*    MT = 12; SB = 13; SP = 14; LNK = 15;  *) (*dedicated registers - RISC*)
    maxCode = 8000; maxStrx = 2400; maxTD = 120; (*C24 = 1000000H; *)
    Reg = 10; RegI = 11; Cond = 12;  (*internal item modes*)

  (*opcode formats*)
   DPfmt = 0; MULfmt = 1; MULLfmt = 2; SDSfmt = 3; BEfmt = 4; HDTRfmt = 5; HDTIfmt = 6;   SDTfmt = 7; UNDfmt = 8; BDTfmt = 9; BRfmt = 10; CDTfmt = 11; CDOfmt = 12; CRTfmt = 13; SWIfmt = 14;

  (*frequently used opcodes*)  U = 2000H;    And = 0; Eor = 1; Sub = 2; Rsb = 3; Add = 4; Adc = 5; Sbc = 6; Rsc = 7;    Tst = 8; Teq = 9; Cmp = 10; Cmn = 11; Orr = 12; Mov = 13; Bic = 14; Mvn = 15;
    Lsl = 1; Asr = 2; Ror= 3;  Ann = 5; Ior = 6; Xor = 7;
    Mul = 10; Div = 11;
    Fad = 12; Fsb = 13; Fml = 14; Fdv = 15;
    Ldr = 51H; Str = 50H;
 (*   Ldr = 8; Str = 10; *)
    BR = 0; BLR = 1; BC = 2;  BL = 3;
  (*  MI = 0;  PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14; *)





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

`PROCEDURE Put0(op, dst, src0, src1: LONGINT); (*register operation*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L150)


`PROCEDURE Put0a(op, dst, src0, src1, shmd, shcnt: LONGINT); (*register operation with shift*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L151)


`PROCEDURE Put0b(op, dst, src0, src1, shmd, shreg: LONGINT); (*register operation with shift cnt from reg*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L152)


`PROCEDURE Put0c(op, dst, src0, src1, src2: LONGINT); (*multiply*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L153)


`PROCEDURE Put1(op, dst, src, imm: LONGINT); (*register operation with immediate*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L154)


`PROCEDURE Put2(op, reg, base, offset: LONGINT); (*Load/store with offset literal*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L155)


`PROCEDURE Put3(op, reg, base, offreg, shift: LONGINT); (*Load/store with offset from register*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L156)


`PROCEDURE Put4(op, base: LONGINT; regs: SET); (*Load/Store multiple*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L157)


`PROCEDURE Put5(cond, offset: LONGINT); (*Branch conditional*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L158)


`PROCEDURE Put5a(offset: LONGINT); (*Branch and Link*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L159)


`PROCEDURE Put6(cond, num: LONGINT); (*SWI conditional*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L160)

---
**Put0** 

`  PROCEDURE Put0(op, a, b, c: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L168)


`  PROCEDURE Put1(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L179)


`  PROCEDURE Put1a(op, a, b, im: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L185)


`  PROCEDURE Put2(op, a, b, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L194)


`  PROCEDURE Put3(op, cond, off: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L199)


`  PROCEDURE incR;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L204)


`  PROCEDURE CheckRegs*;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L209)


`  PROCEDURE SetCC(VAR x: Item; n: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L216)


`  PROCEDURE Trap(cond, num: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L220)

## ---------- Handling of forward reference, fixups of instruction operands

`  PROCEDURE negated(cond: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L230)


`  PROCEDURE fix(at, with: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L236)


`  PROCEDURE FixOne*(at: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L240)


`  PROCEDURE FixLink*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L244)


`  PROCEDURE FixLinkWith(L0, dst: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L250)


`  PROCEDURE merged(L0, L1: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L259)

## ----------  Loading of operands and addresses into registers
---
**GetSB** loads the static base of a module

`  PROCEDURE GetSB(base: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L279)

---
**NilCheck** ensures a pointer is not NIL

`  PROCEDURE NilCheck;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L290)

---
**load** generates loading the contents of a variable

`  PROCEDURE load(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L298)

---
**loadAdr** generates loading the location of a variable

`  PROCEDURE loadAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L334)

---
**loadCond** generates loading a boolean

`  PROCEDURE loadCond(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L355)

---
**loadTypTagAdr** generates loading a type tag address

`  PROCEDURE loadTypTagAdr(T: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L372)

---
**loadStringAdr** generates loading a string address

`  PROCEDURE loadStringAdr(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L381)

## ----------  Items: Conversion from constants or from Objects on the Heap to Items on the Stack
---
**MakeConstItem** prepares

`  PROCEDURE MakeConstItem*(VAR x: Item; typ: ORB.Type; val: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L395)

---
**MakeRealItem** prepares

`  PROCEDURE MakeRealItem*(VAR x: Item; val: REAL);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L403)

---
**MakeStringItem** prepares

`  PROCEDURE MakeStringItem*(VAR x: Item; len: LONGINT); (*copies string from ORS-buffer to ORG-string array*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L411)

---
**MakeItem** prepares

`  PROCEDURE MakeItem*(VAR x: Item; y: ORB.Object; curlev: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L425)

## ----------  Code generation for Selectors, Variables, Constants
---
**Field** locates a record field

`  PROCEDURE Field*(VAR x: Item; y: ORB.Object);   (* x := x.y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L444)

---
**Index** locates an array element

`  PROCEDURE Index*(VAR x, y: Item);   (* x := x[y] *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L459)

---
**DeRef** generates a dereference

`  PROCEDURE DeRef*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L498)

---
**Q** prepares

`  PROCEDURE Q(T: ORB.Type; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L515)

---
**FindPtrFlds** prepares

`  PROCEDURE FindPtrFlds(typ: ORB.Type; off: LONGINT; VAR dcw: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L527)

---
**BuildTD** prepares

`  PROCEDURE BuildTD*(T: ORB.Type; VAR dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L544)

---
**TypeTest** generates a type test

`  PROCEDURE TypeTest*(VAR x: Item; T: ORB.Type; varpar, isguard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L564)

## ----------  Code generation for Boolean operators
---
**Not** generates

`  PROCEDURE Not*(VAR x: Item);   (* x := ~x *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L598)

---
**And1** generates

`  PROCEDURE And1*(VAR x: Item);   (* x := x & *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L609)

---
**And2** generates

`  PROCEDURE And2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L619)

---
**Or1** generates

`  PROCEDURE Or1*(VAR x: Item);   (* x := x OR *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L629)

---
**Or2** generates

`  PROCEDURE Or2*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L639)

## ----------  Code generation for arithmetic operators

`  PROCEDURE Neg*(VAR x: Item);   (* x := -x *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L651)

---
**AddOp** generates an add operation

`  PROCEDURE AddOp*(op: LONGINT; VAR x, y: Item);   (* x := x +- y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L672)

---
**log2** generates a log2 operation

`  PROCEDURE log2(m: LONGINT; VAR e: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L693)

---
**MulOp** generates a multipy operation

`  PROCEDURE MulOp*(VAR x, y: Item);   (* x := x * y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L703)

---
**DivOp** generates a divide operation

`  PROCEDURE DivOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L719)

## ----------  Code generation for REAL operators
---
**RealOp** generates operations on reals

`  PROCEDURE RealOp*(op: INTEGER; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L756)

## ----------  Code generation for set operators
---
**Singleton** generates a set of one set item.

`  PROCEDURE Singleton*(VAR x: Item);  (* x := {x} *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L776)

---
**Set** generates a set value from two set items.

`  PROCEDURE Set*(VAR x, y: Item);   (* x := {x .. y} *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L787)

---
**In** generates a test for if an item is in a set

`  PROCEDURE In*(VAR x, y: Item);  (* x := x IN y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L810)

---
**SetOp** generates operations on sets

`  PROCEDURE SetOp*(op: LONGINT; VAR x, y: Item);   (* x := x op y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L822)

## ----------  Code generation for relations
---
**IntRelation** generates an integer comparison

`  PROCEDURE IntRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L860)

---
**RealRelation** generates a real comparison

`  PROCEDURE RealRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L877)

---
**StringRelation** generates a string comparison

`  PROCEDURE StringRelation*(op: INTEGER; VAR x, y: Item);   (* x := x < y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L889)

## ----------  Code generation of Assigments
---
**StrToChar** ??

`  PROCEDURE StrToChar*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L911)

---
**Store** generates the copying of the value of one word-sized variable into another word-sized variable.

`  PROCEDURE Store*(VAR x, y: Item); (* x := y *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L919)

---
**StoreStruct** generates copying the contents of one structure into another structure.

`  PROCEDURE StoreStruct*(VAR x, y: Item); (* x := y, frame = 0 *)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L938)

---
**CopyString** generates copying the contents of one string variable into another string variable.

`  PROCEDURE CopyString*(VAR x, y: Item);  (* x := y *) ` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L972)

## ----------  Code generation for parameters
---
**OpenArrayParam** generates placing the address of an open array variable in a register, allocating the register.

`  PROCEDURE OpenArrayParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L996)

---
**VarParam** generates placing the address of a variable in a register, allocating the register.

`  PROCEDURE VarParam*(VAR x: Item; ftype: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1006)

---
**ValueParam** generates placing a value in a register.

`  PROCEDURE ValueParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1021)

---
**StringParam** generates placing the location of a string in a register, allocating the register.

`  PROCEDURE StringParam*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1029)

## ----------  For Statements
---
**For0** generates the initial part of a FOR statement

`  PROCEDURE For0*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1043)

---
**FOR1** generates the central part of a FOR statement

`  PROCEDURE For1*(VAR x, y, z, w: Item; VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1051)

---
**FOR2** generates the final part of a FOR statement.

`  PROCEDURE For2*(VAR x, y, w: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1068)

## ----------  Branches, procedure calls, procedure prolog and epilog
---
**Here** returns the next available code location.

`  PROCEDURE Here*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1082)

---
**FJump** generates a forward jump.

`  PROCEDURE FJump*(VAR L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1090)

---
**CFJump** generates a conditional forward jump

`  PROCEDURE CFJump*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1098)

---
**BJump** generates a backwards jump.

`  PROCEDURE BJump*(L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1108)

---
**CBJump** generates a conditional backwards jump.

`  PROCEDURE CBJump*(VAR x: Item; L: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1116)

---
**Fixup** fixes ???

`  PROCEDURE Fixup*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1126)

---
**SaveRegs** saves register values in preparation for a procedure call.

`  PROCEDURE SaveRegs(r: LONGINT);  (* R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1134)

---
**RestoreRegs** brings values back into registers after a procedure call.

`  PROCEDURE RestoreRegs(r: LONGINT); (*R[0 .. r-1]*)` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1145)

---
**PrepCall** generates generates a sequence that preapreas for a procedure call.

`  PROCEDURE PrepCall*(VAR x: Item; VAR r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1156)

---
**Call** generates the procedure call sequence.

`  PROCEDURE Call*(VAR x: Item; r: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1167)

---
**Enter** generates the procedure entry sequence.

`  PROCEDURE Enter*(parblksize, locblksize: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1195)

---
**Return** generates the procedure return sequence.

`  PROCEDURE Return*(form: INTEGER; VAR x: Item; size: LONGINT; int: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1213)

## ----------  In-line code procedures
---
**Increment** generates an inline routine that increments a variable.

`  PROCEDURE Increment*(upordown: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1237)

---
**Include** generates a routine that ??

`  PROCEDURE Include*(inorex: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1257)

---
**Assert** generates an inline routine that traps on a condition.

`  PROCEDURE Assert*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1271)

---
**New** generates an inline routine that allocates heap memory via trap 0.

`  PROCEDURE New*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1285)

---
**Pack** generates an inline routine that ??

`  PROCEDURE Pack*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1293)

---
**Unpk** generates in inline routine that ??

`  PROCEDURE Unpk*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1303)

---
**Led** generates an inline routine that displays a bit pattern on the LED display.

`  PROCEDURE Led*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1314)

---
**Get** generates an inline routine that loads a value from an IO register.

`  PROCEDURE Get*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1322)

---
**Put** generates an inline routine that stores a value in an IO register.

`  PROCEDURE Put*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1330)

---
**Copy** generates an inline memory copy routine.     

`  PROCEDURE Copy*(VAR x, y, z: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1338)

---
**LDPSR** places the processor status register in a variable     

`  PROCEDURE LDPSR*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1355)

---
**LDREG** places a register value in a variable     

`  PROCEDURE LDREG*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1363)

## ----------  In-line code functions
---
**Abs** generates an inline functionn that takes the absolute value     

`  PROCEDURE Abs*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1380)

---
**Odd** generates an inlinen function that checks whether a value is odd.     

`  PROCEDURE Odd*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1394)

---
**Floor** generates an inline function that produces the floor of a value.     

`  PROCEDURE Floor*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1402)

---
**Float** generates an inline function that produces a float.     

`  PROCEDURE Float*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1410)

---
**Ord** generates an inline function that presents the ordinal value of its parameter.     

`  PROCEDURE Ord*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1418)

---
**Len** generates an inline function that presents the length of an array.     

`  PROCEDURE Len*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1427)

---
**Shift** generates an inline function that performs bit shifts.      

`  PROCEDURE Shift*(fct: LONGINT; VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1440)

---
**ADC** generates an inline function that Adds with Carry     

`  PROCEDURE ADC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1453)

---
**SBC** generates an inline function that Subtracts with Carry 

`  PROCEDURE SBC*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1461)

---
**UML** generates an inline function ??     

`  PROCEDURE UML*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1469)

---
**Bit** generates an inline function presenting the yth bit of x      

`  PROCEDURE Bit*(VAR x, y: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1477)

---
**Register** generates an inline function presenting a general register's contents      

`  PROCEDURE Register*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1489)

---
**H** genrates an inline funtion presenting the contents of the H register.     

`  PROCEDURE H*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1498)

---
**Adr** generates an inline function presenting the memory address of its parameter.      

`  PROCEDURE Adr*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1507)

---
**Condition** generates an inline function presenting a condition.     

`  PROCEDURE Condition*(VAR x: Item);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1520)

---
**Open** initializes the ORG module code generation engine.     

`  PROCEDURE Open*(v: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1528)

---
**SetDataSize** sets the amount of space reserved for module global variables.     

`  PROCEDURE SetDataSize*(dc: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1539)

---
**Header** prepares the code introductory sequence for a compiled module     

`  PROCEDURE Header*;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1547)

---
**NofPtrs** determines the number of Garbage Collection Roots.

`  PROCEDURE NofPtrs(typ: ORB.Type): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1559)

---
**FindPtrs** locates Garbage Collection roots.

`  PROCEDURE FindPtrs(VAR R: Files.Rider; typ: ORB.Type; adr: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1576)

---
**Close** writes the completed binary to disk.

`  PROCEDURE Close*(VAR modid: ORS.Ident; key, nofent: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaG.Mod#L1593)

---
**The initialzation code for this module** merely sets the 6 values in the global relmap array.

This module's global variables are initialized by OAP calling OAG.Open, once it has begun parsing the source code's Module
definition and determined that its module imports are available and of compatible object filetype.
