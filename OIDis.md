
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

    opUNKN   ="UNKNOWN";
    opBAD    ="BAD";
    opNOP    ="NOP";
    opLDR    ="LDR";
    opSTR    ="STR";
    opMOV    ="MOV";
    opDIV    ="DIV";
    opROL    ="ROL";
    opSHL    ="SHL";
    opROR    ="ROR";
    opSHR    ="SHR";
    opAND    ="AND";
    opOR     ="OR ";
    opSUB    ="SUB";
    opXOR    ="XOR";
    opCMP    ="CMP";
    opADD    ="ADD";
    opADC    ="ADC";
    opSBB    ="SBB";
    opBR     ="BR ";
    opBEQ    ="BEQ";
    opBNE    ="BNE";
    opBGT    ="BGT";
    opBGE    ="BGE";
    opBLT    ="BLT";
    opBLE    ="BLE";
 

```
## Types:
```


```
## Variables:
```

    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
    mnemo0, reg: ARRAY 16, 4 OF CHAR;  (*mnemonics*)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;

```
## Procedures:
---

`  PROCEDURE append(VAR s1: ARRAY OF CHAR; s2: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L59)


`  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L67)


`  PROCEDURE readIn(VAR R: Files.Rider; VAR t: ARRAY OF BYTE; VAR i, pc: INTEGER):CHAR;` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L74)


`  PROCEDURE readInteger(VAR R: Files.Rider; VAR t: ARRAY OF BYTE; VAR isz, pc: INTEGER):INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L81)


`  PROCEDURE regStr(b,r:INTEGER;VAR s:ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L94)


`  PROCEDURE strInt (x: LONGINT; VAR s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L103)


`  PROCEDURE strHex (x: LONGINT; VAR s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L121)


`  PROCEDURE decode*():INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L137)


`  PROCEDURE init*(VAR f: Files.File; i, o, e: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L266)


`  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OIDis.Mod#L277)

