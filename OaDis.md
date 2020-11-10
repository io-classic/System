
## [MODULE OaDis](https://github.com/io-core/Build/blob/main/OaDis.Mod)
Module OaDis disassembles 32-bit ARM opcodes.


(CP 2020)

**OaDis** is a disassembler of 32-bit ARM opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.


  ## Imports:
` SYSTEM Files Oberon`

## Constants:
```

    OK* = 0; FINISH* = 1; BAD* = 2;
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV64=5; RISCV32=6;
    BYTEORIENTED=0; WORDORIENTED=1;
  (*opcode formats*)
    DPfmt = 0; MULfmt = 1; MULLfmt = 2; SDSfmt = 3; BEfmt = 4; HDTRfmt = 5; HDTIfmt = 6;
    SDTfmt = 7; UNDfmt = 8; BDTfmt = 9; BRfmt = 10; CDTfmt = 11; CDOfmt = 12; CRTfmt = 13; SWIfmt = 14;
    
```
## Types:
```


```
## Variables:
```

    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
    mnemo0, cc : ARRAY 16, 4 OF CHAR;  (*arm32 mnemonics*)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;

```
## Procedures:
---

`  PROCEDURE opFormat*(w: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L35)


`  PROCEDURE a32opcode(w: LONGINT);` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L94)


`  PROCEDURE a32Reg(r: LONGINT; VAR s: ARRAY OF CHAR; i: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L152)


`  PROCEDURE PlaceInt* (x: LONGINT;VAR s: ARRAY OF CHAR; p: INTEGER; VAR c:INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L165)


`  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L185)


`  PROCEDURE decode*():INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L248)


`  PROCEDURE init*(VAR f: Files.File; i, o, e: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L267)


`  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OaDis.Mod#L278)

