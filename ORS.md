
## [MODULE ORS](https://github.com/io-core/Build/blob/main/ORS.Mod)

  ## Imports:
` SYSTEM Texts Oberon`

## Constants:
```
 IdLen* = 32;
    NKW = 34;  (*nof keywords*)
    maxExp = 38; stringBufSize = 256;
  
    (*lexical symbols*)
    null = 0; times* = 1; rdiv* = 2; div* = 3; mod* = 4;
    and* = 5; plus* = 6; minus* = 7; or* = 8; eql* = 9;
    neq* = 10; lss* = 11; leq* = 12; gtr* = 13; geq* = 14;
    in* = 15; is* = 16; arrow* = 17; period* = 18;
    char* = 20; int* = 21; real* = 22; false* = 23; true* = 24;
    nil* = 25; string* = 26; not* = 27; lparen* = 28; lbrak* = 29;
    lbrace* = 30; ident* = 31;
    if* = 32; while* = 34; repeat* = 35; case* = 36; for* = 37;
    comma* = 40; colon* = 41; becomes* = 42; upto* = 43; rparen* = 44;
    rbrak* = 45; rbrace* = 46; then* = 47; of* = 48; do* = 49;
    to* = 50; by* = 51; semicolon* = 52; end* = 53; bar* = 54;
    else* = 55; elsif* = 56; until* = 57; return* = 58;
    array* = 60; record* = 61; pointer* = 62; const* = 63; type* = 64;
    var* = 65; procedure* = 66; begin* = 67; import* = 68; module* = 69; eot = 70;

```
## Types:
```
 Ident* = ARRAY IdLen OF CHAR;

```
## Variables:
```
 ival*, slen*: LONGINT;  (*results of Get*)
    rval*: REAL;
    id*: Ident;  (*for identifiers*)
    str*: ARRAY stringBufSize OF CHAR;
    errcnt*: INTEGER;

```
## Procedures:
---

`  PROCEDURE CopyId*(VAR ident: Ident);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L50)


`  PROCEDURE Pos*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L54)


`  PROCEDURE Mark*(msg: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L58)


`  PROCEDURE Identifier(VAR sym: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L68)


`  PROCEDURE String;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L83)


`  PROCEDURE HexString;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L95)


`  PROCEDURE Ten(e: LONGINT): REAL;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L115)


`  PROCEDURE Number(VAR sym: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L125)


`  PROCEDURE comment;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L194)


`  PROCEDURE Get*(VAR sym: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L208)


`  PROCEDURE Init*(T: Texts.Text; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L263)


`  PROCEDURE EnterKW(sym: INTEGER; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L267)

