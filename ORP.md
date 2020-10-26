
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

## Constants:
```


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
---
**Check** marks an error if the current symbol does not match the expeted symbol.

`  PROCEDURE Check(s: INTEGER; msg: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L103)


`  PROCEDURE qualident(VAR obj: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L108)


`  PROCEDURE CheckBool(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L120)


`  PROCEDURE CheckInt(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L125)


`  PROCEDURE CheckReal(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L130)


`  PROCEDURE CheckSet(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L135)


`  PROCEDURE CheckSetVal(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L140)


`  PROCEDURE CheckConst(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L148)


`  PROCEDURE CheckReadOnly(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L153)


`  PROCEDURE CheckExport(VAR expo: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L158)


`  PROCEDURE IsExtension(t0, t1: ORB.Type): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L167)

---
**TypeTest** checks for assignment type compatibility.

`  PROCEDURE TypeTest(VAR x: ORG.Item; T: ORB.Type; guard: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L182)


`  PROCEDURE selector(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L205)


`  PROCEDURE EqualSignatures(t0, t1: ORB.Type): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L249)


`  PROCEDURE CompTypes(t0, t1: ORB.Type; varpar: BOOLEAN): BOOLEAN;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L268)


`  PROCEDURE Parameter(par: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L279)


`  PROCEDURE ParamList(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L307)


`  PROCEDURE StandFunc(VAR x: ORG.Item; fct: LONGINT; restyp: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L325)


`  PROCEDURE element(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L369)


`  PROCEDURE set(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L378)


`  PROCEDURE factor(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L394)


`  PROCEDURE term(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L426)


`  PROCEDURE SimpleExpression(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L449)


`  PROCEDURE expression0(VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L467)

---
**StandProc** sets the keyboard initial state and populates the scancode to ascii table.

`  PROCEDURE StandProc(pno: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L519)


`  PROCEDURE StatSequence;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L556)


`    PROCEDURE TypeCase(obj: ORB.Object; VAR x: ORG.Item);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L562)


`    PROCEDURE SkipCase;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L574)

---
**IdentList** matches a comma separated list of identifiers.

`  PROCEDURE IdentList(class: INTEGER; VAR first: ORB.Object);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L697)


`  PROCEDURE ArrayType(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L713)


`  PROCEDURE RecordType(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L729)


`  PROCEDURE FPSection(VAR adr: LONGINT; VAR nofpar: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L774)


`  PROCEDURE ProcedureType(ptype: ORB.Type; VAR parblksize: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L793)


`  PROCEDURE FormalType0(VAR typ: ORB.Type; dim: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L817)


`  PROCEDURE CheckRecLevel(lev: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L836)


`  PROCEDURE Type0(VAR type: ORB.Type);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L841)


`  PROCEDURE Declarations(VAR varsize: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L883)


`  PROCEDURE ProcedureDecl;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L949)


`  PROCEDURE Import;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L997)


`  PROCEDURE Module;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L1014)

---
**Option** checks if a new symbol file may be generated.

`  PROCEDURE Option(VAR S: Texts.Scanner);` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L1066)

---
**Compile** locates the source code to a module, initializes the scanner, and begins parsing at 'Module'.

`  PROCEDURE Compile*;` [(source)](https://github.com/io-orig/System/blob/main/ORP.Mod#L1078)

---
**The initialzation code for this module** opens a writer to print marked errors and initializes the Oberon parser state.
