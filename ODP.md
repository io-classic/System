
## [MODULE ODP](https://github.com/io-core/Build/blob/main/ODP.Mod)

  ## Imports:
` Texts Oberon ORS ORB ODG`

```
## Types:
```
 PtrBase = POINTER TO PtrBaseDesc;
    PtrBaseDesc = RECORD  (*list of names of pointer base types*)
      name: ORS.Ident; type: ORB.Type; next: PtrBase
    END ;
  
```
## Variables:
```
 sym: INTEGER;   (*last symbol read*)
    dc: LONGINT;    (*data counter*)
    level, exno, version: INTEGER;
    newSF: BOOLEAN;  (*option flag*)
    expression: PROCEDURE (VAR x: ORG.Item);  (*to avoid forward reference*)
    Type: PROCEDURE (VAR type: ORB.Type);
    FormalType: PROCEDURE (VAR typ: ORB.Type; dim: INTEGER);
    modid: ORS.Ident;
    pbsList: PtrBase;   (*list of names of pointer base types*)
    dummy: ORB.Object;
    W: Texts.Writer;

```
## Procedures:
---

`  PROCEDURE Check(s: INTEGER; msg: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L26)


`  PROCEDURE qualident(VAR obj: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L31)


`  PROCEDURE CheckBool(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L43)


`  PROCEDURE CheckInt(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L48)


`  PROCEDURE CheckReal(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L53)


`  PROCEDURE CheckSet(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L58)


`  PROCEDURE CheckSetVal(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L63)


`  PROCEDURE CheckConst(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L71)


`  PROCEDURE CheckReadOnly(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L76)


`  PROCEDURE CheckExport(VAR expo: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L81)


`  PROCEDURE IsExtension(t0, t1: ORB.Type): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L90)


`  PROCEDURE TypeTest(VAR x: ORG.Item; T: ORB.Type; guard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L97)


`  PROCEDURE selector(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L120)


`  PROCEDURE EqualSignatures(t0, t1: ORB.Type): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L164)


`  PROCEDURE CompTypes(t0, t1: ORB.Type; varpar: BOOLEAN): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L183)


`  PROCEDURE Parameter(par: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L194)


`  PROCEDURE ParamList(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L222)


`  PROCEDURE StandFunc(VAR x: ORG.Item; fct: LONGINT; restyp: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L240)


`  PROCEDURE element(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L284)


`  PROCEDURE set(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L293)


`  PROCEDURE factor(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L309)


`  PROCEDURE term(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L341)


`  PROCEDURE SimpleExpression(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L364)


`  PROCEDURE expression0(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L382)


`  PROCEDURE StandProc(pno: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L426)


`  PROCEDURE StatSequence;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L463)


`    PROCEDURE TypeCase(obj: ORB.Object; VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L469)


`    PROCEDURE SkipCase;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L481)


`  PROCEDURE IdentList(class: INTEGER; VAR first: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L596)


`  PROCEDURE ArrayType(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L612)


`  PROCEDURE RecordType(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L628)


`  PROCEDURE FPSection(VAR adr: LONGINT; VAR nofpar: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L673)


`  PROCEDURE ProcedureType(ptype: ORB.Type; VAR parblksize: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L692)


`  PROCEDURE FormalType0(VAR typ: ORB.Type; dim: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L716)


`  PROCEDURE CheckRecLevel(lev: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L735)


`  PROCEDURE Type0(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L740)


`  PROCEDURE Declarations(VAR varsize: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L782)


`  PROCEDURE ProcedureDecl;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L848)


`  PROCEDURE Import;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L896)


`  PROCEDURE Module;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L913)


`  PROCEDURE Option(VAR S: Texts.Scanner);` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L957)


`  PROCEDURE Generate*;` [(source)](https://github.com/io-orig/System/blob/main/ODP.Mod#L965)

