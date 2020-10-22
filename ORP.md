
## [MODULE ORP](https://github.com/io-core/Build/blob/main/ORP.Mod)

(N. Wirth 1.7.97 / 8.3.2020  Oberon compiler for RISC in Oberon-07)

**ORP** implements a one-pass recursive descent parser for the language Oberon.

The structure of the parser is derived from the structure of the language, with constituent parts of the language 
(e.g. Module, Procedure, Type, Expression, Term, Parameter) represented by a procedure of that name, invoked from the 
encompassing construct. Each procedure consumes and validates a part of the program source text while populating the 
symbol table and execution context and also generating machine code faithfully representing that language construct.

This module (ORP) relies on module ORG for code generation, ORB for the symbol table, execution context tracking and reserved words, and ORS
for lexical parsing and built-in type identification.


  ## Imports:
` Texts Oberon ORS ORB ORG`

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

`  PROCEDURE Check(s: INTEGER; msg: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L91)


`  PROCEDURE qualident(VAR obj: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L96)


`  PROCEDURE CheckBool(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L108)


`  PROCEDURE CheckInt(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L113)


`  PROCEDURE CheckReal(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L118)


`  PROCEDURE CheckSet(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L123)


`  PROCEDURE CheckSetVal(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L128)


`  PROCEDURE CheckConst(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L136)


`  PROCEDURE CheckReadOnly(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L141)


`  PROCEDURE CheckExport(VAR expo: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L146)


`  PROCEDURE IsExtension(t0, t1: ORB.Type): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L155)


`  PROCEDURE TypeTest(VAR x: ORG.Item; T: ORB.Type; guard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L162)


`  PROCEDURE selector(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L185)


`  PROCEDURE EqualSignatures(t0, t1: ORB.Type): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L229)


`  PROCEDURE CompTypes(t0, t1: ORB.Type; varpar: BOOLEAN): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L248)


`  PROCEDURE Parameter(par: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L259)


`  PROCEDURE ParamList(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L287)


`  PROCEDURE StandFunc(VAR x: ORG.Item; fct: LONGINT; restyp: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L305)


`  PROCEDURE element(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L349)


`  PROCEDURE set(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L358)


`  PROCEDURE factor(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L374)


`  PROCEDURE term(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L406)


`  PROCEDURE SimpleExpression(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L429)


`  PROCEDURE expression0(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L447)


`  PROCEDURE StandProc(pno: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L491)


`  PROCEDURE StatSequence;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L528)


`    PROCEDURE TypeCase(obj: ORB.Object; VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L534)


`    PROCEDURE SkipCase;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L546)


`  PROCEDURE IdentList(class: INTEGER; VAR first: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L661)


`  PROCEDURE ArrayType(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L677)


`  PROCEDURE RecordType(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L693)


`  PROCEDURE FPSection(VAR adr: LONGINT; VAR nofpar: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L738)


`  PROCEDURE ProcedureType(ptype: ORB.Type; VAR parblksize: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L757)


`  PROCEDURE FormalType0(VAR typ: ORB.Type; dim: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L781)


`  PROCEDURE CheckRecLevel(lev: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L800)


`  PROCEDURE Type0(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L805)


`  PROCEDURE Declarations(VAR varsize: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L847)


`  PROCEDURE ProcedureDecl;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L913)


`  PROCEDURE Import;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L961)


`  PROCEDURE Module;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L978)


`  PROCEDURE Option(VAR S: Texts.Scanner);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L1022)


`  PROCEDURE Compile*;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L1030)

