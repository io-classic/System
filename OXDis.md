
## [MODULE OXDis](https://github.com/io-core/Build/blob/main/OXDis.Mod)
Module OXDis provides an interface for disassembling opcodes.


(CP 2020)

**OXDis** provides an interface for disassembling opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.


  ## Imports:
` SYSTEM Files ORDis OIDis OADis OaDis OVDis OvDis`

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

    E*, at*, pc*, isz*, Arch*,wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;

```
## Procedures:
---

`  PROCEDURE decode*():INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OXDis.Mod#L26)


`  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index, arch: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OXDis.Mod#L82)

