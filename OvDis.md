
## [MODULE OvDis](https://github.com/io-core/Build/blob/main/OvDis.Mod)
Module OvDis disassembles 32-bit RISCV opcodes.


(CP 2020)

**OvDis** is a disassembler of 32-bit RISCV opcodes.
The module sets up a state machine that operates on an input via repeated calls to decode.


  ## Imports:
` SYSTEM Files Oberon`

## Constants:
```

    OK* = 0; FINISH* = 1; BAD* = 2;
    BADARCH=0; RISC5=1; X8664=2; AARCH64=3; ARM32=4; RISCV64=5; RISCV32=6;
    BYTEORIENTED=0; WORDORIENTED=1;
  (*opcode formats*)
    Rfmt = 0; Ifmt = 1; Sfmt = 2; Bfmt = 3; Ufmt = 4; Jfmt = 5; Afmt = 6; Badfmt = -1; Reserved = -2;
    DPfmt = 0; MULfmt = 1; MULLfmt = 2; SDSfmt = 3; BEfmt = 4; HDTRfmt = 5; HDTIfmt = 6;
    SDTfmt = 7; UNDfmt = 8; BDTfmt = 9; BRfmt = 10; CDTfmt = 11; CDOfmt = 12; CRTfmt = 13; SWIfmt = 14;
  (*opcodes*)
    opLUI    ="LUI"  ; opSLTIU  ="SLTIU" ; opEBREAK ="EBREAK"; opSRLW   ="SRLW"  ;  
    opAUIPC  ="AUIPC"; opXORI   ="XORI"  ; opCSRRW  ="CSRRW" ; opSRAW   ="SRAW"  ;
    opJAL    ="JAL"  ; opORI    ="ORI"   ; opCSRRS  ="CSRRS" ; opMUL    ="MUL"   ;
    opJALR   ="JALR" ; opANDI   ="ANDI"  ; opCSRRC  ="CSRRC" ; opMULH   ="MULH"  ;
    opBEQ    ="BEQ"  ; opSLLI   ="SLLI"  ; opCSRRWI ="CSRRWI"; opMULHSU ="MULHSU";
    opBNE    ="BNE"  ; opSRLI   ="SRLI"  ; opCSRRSI ="CSRRSI"; opMULHU  ="MULHU" ;
    opBLT    ="BLT"  ; opSRAI   ="SRAI"  ; opCSRRCI ="CSRRCI"; opDIV    ="DIV"   ;
    opBGE    ="BGE"  ; opADD    ="ADD"   ; opLWU    ="LWU"   ; opDIVU   ="DIVU"  ;
    opBLTU   ="BLTU" ; opSUB    ="SUB"   ; opLD     ="LD"    ; opREM    ="REM"   ;
    opBGEU   ="BGEU" ; opSLL    ="SLL"   ; opSD     ="SD"    ; opREMU   ="REMU"  ;
    opLB     ="LB"   ; opSLT    ="SLT"   ; opSLLIx  ="SLLIx" ; opMULW   ="MULW"  ;
    opLH     ="LH"   ; opSLTU   ="SLTU"  ; opSRLIx  ="SRLIx" ; opDIVW   ="DIVW"  ;
    opLW     ="LW"   ; opXOR    ="XOR"   ; opSRAIx  ="SRAIx" ; opDIVUW  ="DIVUW" ;
    opLBU    ="LBU"  ; opSRL    ="SRL"   ; opADDIW  ="ADDIW" ; opREMW   ="REMW"  ;
    opLHU    ="LHU"  ; opSRA    ="SRA"   ; opSLLIW  ="SLLIW" ; opREMUW  ="REMUW" ;
    opSB     ="SB"   ; opOR     ="OR"    ; opSRLIW  ="SRLIW" ;                       
    opSH     ="SH"   ; opAND    ="AND"   ; opSRAIW  ="SRAIW" ;                       
    opSW     ="SW"   ; opFENCE  ="FENCE" ; opADDW   ="ADDW"  ;                       
    opADDI   ="ADDI" ; opFENCEI ="FENCEI"; opSUBW   ="SUBW"  ; opBAD    ="BAD";                      
    opSLTI   ="SLTI" ; opECALL  ="ECALL" ; opSLLW   ="SLLW"  ; opUNKN   ="UNKNOWN" ;                      

```
## Types:
```


```
## Variables:
```

    E*, at*, pc*, isz*, wo*: INTEGER;
    ibytes*: ARRAY 32 OF BYTE;
    istr*: ARRAY 32 OF CHAR;
(*    mnemo0: ARRAY 75, 10 OF CHAR;  (*riscv mnemonics*) *)
    vendor*, mode*, cfo*, cfe*: INTEGER;
    R*: Files.Rider;
    F*: Files.File;

```
## Procedures:
---

`  PROCEDURE opFormat*(w: LONGINT): LONGINT;` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L57)


`  PROCEDURE append(VAR s1: ARRAY OF CHAR; s2: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L79)


`  PROCEDURE v32reg(r: LONGINT; VAR s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L87)


`  PROCEDURE strInt (x: LONGINT; VAR s: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L101)


`  PROCEDURE opcode(w: LONGINT; VAR s:ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L123)


`  PROCEDURE decode*():INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L264)


`  PROCEDURE init*(VAR f: Files.File; i, o, e: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L283)


`  PROCEDURE originate*(r: Files.Rider; f: Files.File; offset, extent, index: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/OvDis.Mod#L294)

