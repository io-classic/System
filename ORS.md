
## [MODULE ORS](https://github.com/io-core/Build/blob/main/ORS.Mod)
Module ORS does lexical analysis of the Oberon source code and defines symbols and operations


(NW 19.9.93 / 20.3.2017  Scanner in Oberon-07)

**ORS** is called from ORP, ORG, and ORB and converts the source text to symbols for their consumption.

Oberon Scanner does lexical analysis. Input is Oberon-Text, output is
sequence of symbols, i.e identifiers, numbers, strings, and special symbols.
Recognises all Oberon keywords and skips comments. The keywords are recorded in a table.

`Get(sym)` delivers next symbol from input text with Reader R.

`Mark(msg)` records error and delivers error message with Writer W.

If Get delivers ident, then the identifier (a string) is in variable id, 
if int or char in ival, if real in rval, and if string in str (and slen) 


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
    ch: CHAR;  (*last character read*)
    errpos: LONGINT;
    R: Texts.Reader;
    W: Texts.Writer;
    k: INTEGER;
    KWX: ARRAY 10 OF INTEGER;
    keyTab: ARRAY NKW OF
        RECORD sym: INTEGER; id: ARRAY 12 OF CHAR END;
  
  (* begin-section-description
## ---------- Lexer
  end-section-description *)

```
## Procedures:
---
## ---------- Lexer
---
**CopyId** duplicates an identifier.

`  PROCEDURE CopyId*(VAR ident: Ident);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L81)

---
**Pos** reports the location in the source text not couting the most current character.

`  PROCEDURE Pos*(): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L89)

---
**Mark** reports an error to the Oberon system log.

`  PROCEDURE Mark*(msg: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L97)

---
**Identifier** matches an alphanumeric identifier.

`  PROCEDURE Identifier(VAR sym: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L111)

---
**String** matches a quote delimeted string.

`  PROCEDURE String;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L130)

---
**HexString** matches a hex string.

`  PROCEDURE HexString;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L146)

---
**Ten** ??

`  PROCEDURE Ten(e: LONGINT): REAL;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L170)

---
**Number** matches a number.

`  PROCEDURE Number(VAR sym: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L184)

---
**Comment** matches comments.

`  PROCEDURE comment;` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L257)

---
**Get** gets the next symbol from the source text.

`  PROCEDURE Get*(VAR sym: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L275)

## ---------- Initialization
---
**Init** opens the source text for reading and gets the first character.

`  PROCEDURE Init*(T: Texts.Text; pos: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L340)

---
**EnterKW** adds a symbol to the keyword table.

`  PROCEDURE EnterKW(sym: INTEGER; name: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/ORS.Mod#L348)

---
**The initialzation code for this module** populats the table of reserved keywords.
