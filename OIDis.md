
## [MODULE OIDis](https://github.com/io-core/Build/blob/main/OIDis.Mod)
Module OIDis disassembles x86_64 opcodes.


(CP 2020)

**OIDis** is a disassembler of x86_64 opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.


  ## Imports:
` SYSTEM Files Oberon`

## Constants:
```
 
    OK* = 0; FINISH* = 1; BAD* = 2;
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV64=5; RISCV32=6;
    BYTEORIENTED=0; WORDORIENTED=1;

```
## Types:
```


```
## Variables:
```

    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
    mnemo0, mnemo1: ARRAY 16, 4 OF CHAR;  (*mnemonics*)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;

```
## Procedures:
---

`  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L31)


`  PROCEDURE decode*():INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L37)


`  PROCEDURE init*(VAR f: Files.File; i, o, e: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L58)


`  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L69)

