
## [MODULE ORB](https://github.com/io-core/Build/blob/main/ORB.Mod)

(NW 25.6.2014  / AP 4.3.2020 / 5.3.2019  in Oberon-07 / AP 24.4.20 Extended Oberon / CP 10.20 Integrated Oberon)

**ORB** is called from ORP and ORG and tracks the state of identifiers and objects as code compilation progresses.


  ## Imports:
` Files ORS`

## Constants:
```
 versionkey* = 1; maxTypTab = 64;
    (* class values*) Head* = 0;
      Const* = 1; Var* = 2; Par* = 3; Fld* = 4; Typ* = 5;
      SProc* = 6; SFunc* = 7; Mod* = 8;

    (* form values*)
      Byte* = 1; Bool* = 2; Char* = 3; Int* = 4; Real* = 5; Set* = 6;
      Pointer* = 7; NilTyp* = 8; NoTyp* = 9; Proc* = 10;
      String* = 11; Array* = 12; Record* = 13;
      
```
## Types:
```
 Object* = POINTER TO ObjDesc;
    Module* = POINTER TO ModDesc;
    Type* = POINTER TO TypeDesc;

    ObjDesc*= RECORD
      class*, exno*: BYTE;
      expo*, rdo*: BOOLEAN;   (*exported / read-only*)
      lev*: INTEGER;
      next*, dsc*: Object;
      type*: Type;
      name*: ORS.Ident;
      val*: LONGINT
    END ;

    ModDesc* = RECORD (ObjDesc) orgname*: ORS.Ident END ;

    TypeDesc* = RECORD
      form*, ref*, mno*: INTEGER;  (*ref is only used for import/export*)
      nofpar*: INTEGER;  (*for procedures, extension level for records*)
      len*: LONGINT;  (*for arrays, len < 0 => open array; for records: adr of descriptor*)
      dsc*, typobj*: Object;
      base*: Type;  (*for arrays, records, pointers*)
      size*: LONGINT;  (*in bytes; always multiple of 4, except for Byte, Bool and Char*)
    END ;

  (* Object classes and the meaning of "val":
    class    val
    ----------
    Var      address
    Par      address
    Const    value
    Fld      offset
    Typ      type descriptor (TD) address
    SProc    inline code number
    SFunc    inline code number
    Mod      key

  Type forms and the meaning of "dsc" and "base":
    form     dsc      base
    ------------------------
    Pointer  -        type of dereferenced object
    Proc     params   result type
    Array    -        type of elements
    Record   fields   extension *)

```
## Variables:
```
 topScope*, universe, system*: Object;
    byteType*, boolType*, charType*: Type;
    intType*, realType*, setType*, nilType*, noType*, strType*: Type;
    nofmod, Ref: INTEGER;
    typtab: ARRAY maxTypTab OF Type;

```
## Procedures:
---

`  PROCEDURE NewObj*(VAR obj: Object; id: ORS.Ident; class: INTEGER);  (*insert new Object with name id*)` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L85)


`  PROCEDURE thisObj*(): Object;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L96)


`  PROCEDURE thisimport*(mod: Object): Object;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L106)


`  PROCEDURE thisfield*(rec: Type): Object;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L120)


`  PROCEDURE OpenScope*;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L127)


`  PROCEDURE CloseScope*;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L132)


`  PROCEDURE MakeFileName*(VAR FName: ORS.Ident; name, ext: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L138)


`  PROCEDURE ThisModule(name, orgname: ORS.Ident; decl: BOOLEAN; key: LONGINT): Object;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L146)


`  PROCEDURE Read(VAR R: Files.Rider; VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L169)


`  PROCEDURE InType(VAR R: Files.Rider; thismod: Object; VAR T: Type);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L175)


`  PROCEDURE Import*(VAR modid, modid1: ORS.Ident);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L228)


`  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L266)


`  PROCEDURE OutType(VAR R: Files.Rider; t: Type);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L270)


`    PROCEDURE OutPar(VAR R: Files.Rider; par: Object; n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L273)


`    PROCEDURE FindHiddenPointers(VAR R: Files.Rider; typ: Type; offset: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L284)


`  PROCEDURE Export*(VAR modid: ORS.Ident; VAR newSF: BOOLEAN; VAR key: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L328)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L377)


`  PROCEDURE type(ref, form: INTEGER; size: LONGINT): Type;` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L381)


`  PROCEDURE enter(name: ARRAY OF CHAR; cl: INTEGER; type: Type; n: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORB.Mod#L387)

