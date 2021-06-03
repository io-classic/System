(* begin-module-short-description
emits target architecture opcodes.
end-module-short-description *)

(* begin-module-use-description  vim:fdm=marker fmr=(*%,%*) fdl=0 fen 
Module OXT generates the processor-specific opcodes for executing an Oberon program.

end-module-use-description *)
(* begin-module-develop-description
Module OXT implements the processor-specific opcodes used by OXX

(C.Perkins 2021)

**OXT** is called from OXX and generates machine code various Oberon language constructs.

end-module-develop-description *)
MODULE OXT; (* C.Perkis 2021*)
  IMPORT SYSTEM, Files, OXS, OXB;

  
  CONST     
    WordSize* = 4;
    RStkOrg0 = -64;
    IStkOrg0 = -64;
    AStkOrg0 = -64;
    aStkOrg0 = -64;
    VStkOrg0 = -64;
    vStkOrg0 = -64;
    MT = 12; TL = 13; SP = 14; LNK = 15;   (*dedicated registers*)
    maxCode = 10000; maxStrx = 6400; maxTD = 160; C24 = 1000000H;
    Reg = 10; RegI = 11; Cond = 12;  (*internal item modes*)

    (*frequently used opcodes*)  U = 2000H; V = 1000H;
    Mov = 0; Lsl = 1; Asr = 2; Ror= 3; And = 4; Ann = 5; Ior = 6; Xor = 7;
    Add = 8; Sub = 9; Cmp = 9; Mul = 10; Div = 11;
    Fad = 12; Fsb = 13; Fml = 14; Fdv = 15; MovU = 16;
    Ldr = 8; Ldb = 9; Str = 10; Stb = 11;
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
    BMI =  0; BEQ =  1; BCS =  2; BVS =  3; 
    BLS =  4; BLT =  5; BLE =  6; B   =  7;
    BPL =  8; BNE =  9; BVC = 10; BCC = 11;
    BHI = 12; BGE = 13; BGT = 14; BNO = 15;
    



  TYPE      
    CodePlacer* = POINTER TO CodePlacerProcs;
    CodePlacerProcs* = RECORD
      CodeWord*:   PROCEDURE (a,v: INTEGER);
      OneByte*:    PROCEDURE (a: INTEGER; VAR pc, pcb: INTEGER);
      TwoBytes*:   PROCEDURE (a, b: INTEGER; VAR pc, pcb: INTEGER);
      ThreeBytes*: PROCEDURE (a, b, c: INTEGER; VAR pc, pcb: INTEGER);
      FourBytes*:  PROCEDURE (a, b, c, d: INTEGER; VAR pc, pcb: INTEGER);
      TwoByteInteger*:  PROCEDURE (i: INTEGER; VAR pc, pcb: INTEGER);
      FourByteInteger*:  PROCEDURE (i: INTEGER; VAR pc, pcb: INTEGER);
    END; 

  VAR
    regmap: ARRAY 16 OF INTEGER; (*shuffle of registers for allocation/use*)
    it0: ARRAY 16 OF INTEGER;
    it1: ARRAY 16 OF INTEGER;
    it2: ARRAY 4 OF INTEGER;
    it3: ARRAY 16 OF INTEGER;
    Put: CodePlacer;


(* begin-procedure-description
---
**SetCodePlacer** initializes the interface for depositing values into the code array
  end-procedure-description *)
  PROCEDURE SetCodePlacer*(cp: CodePlacer);
  BEGIN 
    Put := cp;
  END SetCodePlacer;

  (* begin-section-description
## ---------- RISC5 instruction generation
  end-section-description *)

(* begin-procedure-description
---
**RPut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE RPut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN (*emit format-0 instruction*)
    Put.CodeWord(pc, ((a*10H + b) * 10H + op) * 10000H + c);
    INC(pc);
  END RPut0;

  (* begin-procedure-description
---
**RPut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE RPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*emit format-1 instruction,  -10000H <= im < 10000H*)
    IF op = MovU THEN   (*  U = 2000H; V = 1000H; *)
      IF im < 0 THEN
        Put.CodeWord(pc, (((a+70H) * 10H + b) * 10H ) * 10000H + (im MOD 10000H))
      ELSE
        Put.CodeWord(pc, (((a+60H) * 10H + b) * 10H ) * 10000H + (im MOD 10000H))
      END;
    ELSE
      IF im < 0 THEN INC(op, V) END ;
      Put.CodeWord(pc, (((a+40H) * 10H + b) * 10H + op) * 10000H + (im MOD 10000H));
    END;   
    INC(pc);
 
  END RPut1;

  (* begin-procedure-description
---
**RPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE RPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -10000H <= im < 10000H*)
    IF (im >= -10000H) & (im <= 0FFFFH) THEN RPut1(o, pc, pcb, op, a, b, im);
    ELSE RPut1(o, pc, pcb, Mov+U, RH, 0, im DIV 10000H);
      IF im MOD 10000H # 0 THEN RPut1(o, pc, pcb, Ior, RH, RH, im MOD 10000H) END ;
      RPut0(pc, pcb, op, a, b, RH);
    END

  END RPut1a;

  (* begin-procedure-description
---
**RPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE RPut2*(VAR pc, pcb: LONGINT; op, a, b, off: LONGINT);
  BEGIN (*emit load/store instruction*)
    Put.CodeWord(pc, ((op * 10H + a) * 10H + b) * 100000H + (off MOD 100000H)); INC(pc);
  END RPut2;


  (* begin-procedure-description
---
**RPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE RPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
  BEGIN (*emit branch instruction*)
    Put.CodeWord(pc, ((op+12) * 10H + cond) * 1000000H + (off MOD 1000000H)); INC(pc);
  END RPut3;


  (* begin-procedure-description
---
**RHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE RHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN Put.CodeWord(0, 0E7000000H-1 + pc);  RPut1a(120, pc, pcb, RH, Mov, SP, 0, RStkOrg0)  (*BAREMETAL*)
    ELSE RPut1(121, pc, pcb, Sub, SP, SP, 4); RPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END RHeader;

  (* begin-section-description
## ---------- i64 instruction generation
  end-section-description *)


  (* begin-procedure-description
---
**ISetTables** maps registers between the RISC5 model machine and the x86_64 actual machine and prepares opcode tables for x86_64.
  end-procedure-description *)
  PROCEDURE ISetTables;
  BEGIN    (* RSP = SP, RBP = MT, RBX = LNK *)
      regmap[0]:=8; regmap[1]:=9; regmap[2]:=10; regmap[3]:=11; regmap[4]:=12; regmap[5]:=13; regmap[6]:=14; regmap[7]:=15;
      regmap[8]:=1; regmap[9]:=2; regmap[10]:=6; regmap[11]:=7; regmap[MT]:=5; regmap[13]:=0; regmap[SP]:=4; regmap[LNK]:=3;

      it0[Mov]:= 089C0H;  it0[Lsl]:= 0C1E0H;  it0[Asr]:= 0C1E8H;  it0[Ror]:= 0C1C8H; 
      it0[And]:= 021F8H;  it0[Ann]:= 021F8H;  it0[Ior]:= 009F8H;  it0[Xor]:= 031F8H;
      it0[Add]:= 001F8H;  it0[Sub]:= 029F8H;  it0[Mul]:= 0F7E0H;  it0[Div]:= 0F7F0H;
      it0[Fad]:= 0F7F0H;  it0[Fsb]:= 0F7F0H;  it0[Fml]:= 0F7F0H;  it0[Fdv]:= 0F7F0H;

      it1[Mov]:= 4C7C0H;  it1[Lsl]:= 1C1E0H;  it1[Asr]:= 1C1E8H;  it1[Ror]:= 1C1C8H; 
      it1[And]:= 481E0H;  it1[Ann]:= 40000H;  it1[Ior]:= 481C8H;  it1[Xor]:= 481F0H;
      it1[Add]:= 481C0H;  it1[Sub]:= 481E8H;  it1[Mul]:= 40000H;  it1[Div]:= 40000H;
      it1[Fad]:= 40000H;  it1[Fsb]:= 40000H;  it1[Fml]:= 40000H;  it1[Fdv]:= 40000H;

      it2[Ldr-8]:= 00000H;  it2[Ldb-8]:= 00000H;  it2[Str-8]:= 00000H;  it2[Stb-8]:= 00000H; 

      it3[BMI]:= 40000H;  it3[BEQ]:= 40000H;  it3[BCS]:= 40000H;  it3[BVS]:= 40000H; 
      it3[BLS]:= 40000H;  it3[BLT]:= 40000H;  it3[BLE]:= 40000H;  it3[B  ]:= 40000H;
      it3[BPL]:= 40000H;  it3[BNE]:= 40000H;  it3[BVC]:= 40000H;  it3[BCC]:= 40000H;
      it3[BHI]:= 40000H;  it3[BGE]:= 40000H;  it3[BGT]:= 40000H;  it3[BNO]:= 40000H;

  END ISetTables;


(* begin-procedure-description
---
**IPut0** places a register <= Register Operation Register instruction in the code array.

When the destination register (ai) is not the same as the first operand register (bi) 
the AX register is used as an intermediate register.

  end-procedure-description *)
  PROCEDURE IPut0*(VAR pc, pcb: LONGINT; op, ai, bi, ci: LONGINT);
    VAR a,b,a0,a1,b1,c,t:INTEGER;
  BEGIN (*emit format-0 instruction*)
(*
    a:=regmap[ai]; b:=regmap[bi]; c:=regmap[ci];

    a1:=a MOD 8; a0:=48H; IF a > 8 THEN a0 := 49H END;
    IF a # b THEN
      b1:=b MOD 8; IF b > 8 THEN a0 := a0 + 2 END;
      Put.ThreeBytes( a0, 89H, 0C0H+(b1*8H)+a1, pc, pcb);  (* MOV ai <= bi *)
      a0:=48H; IF a > 8 THEN a0 := 49H END;
    END;

    b1:=c MOD 8; IF c > 8 THEN a0 := a0 + 2 END;

    IF op < 16 THEN
      Put.ThreeBytes( a0, it0[op] DIV 100H MOD 100H, (it0[op] MOD 100H) + (b1*8H)+a1, pc, pcb )
    ELSE
      Put.OneByte( 90H, pc, pcb)
    END
*)
  END IPut0;

  (* begin-procedure-description
---
**IPut1** places a register <= Register Operation Immediate instruction in the code array.

When the destination register (ai) is not the same as the first operand register (bi)
the AX register is used as an intermediate register.

The immediate value may be up to 32-bits in size.

If the 'U' bit is set and the operation is a move, the value is shifted left 32-bits.

  end-procedure-description *)
  PROCEDURE IPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, ai, bi, im: LONGINT);
    VAR a,b,a0,a1,b0,b1,osz:INTEGER;
  BEGIN (*emit format-1 instruction,  -10000H <= im < 10000H*)
(*
    a:=regmap[ai];b:=regmap[bi];

    a1:=a MOD 8; a0:=48H; IF a > 8 THEN a0 := 49H END;
    IF a # b THEN
      b1:=b MOD 8; IF b > 8 THEN a0 := a0 + 2 END;
      Put.ThreeBytes( a0, 89H, 0C0H+(b1*8H)+a1, pc, pcb);  (* MOV ai <= bi *)
      a0:=48H; IF a > 8 THEN a0 := 49H END;
    END;

    osz:=4;
    a1:=a MOD 8; a0:=48H; IF a > 8 THEN a0 := 49H END;

    IF op < 16 THEN
      Put.ThreeBytes( a0, it1[op] DIV 100H MOD 100H, (it1[op] MOD 100H) + a1, pc, pcb ); osz := it1[op] DIV 10000H
    ELSE
      Put.OneByte( 90H, pc, pcb)
    END;

    IF osz = 4 THEN
      Put.FourByteInteger( im, pc, pcb )
    ELSE
      Put.OneByte( im, pc, pcb )
    END
*)
  END IPut1;



  (* begin-procedure-description
---
**IPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE IPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -10000H <= im < 10000H*)
(*
    IF (im >= -10000H) & (im <= 0FFFFH) THEN IPut1(o, pc, pcb, op, a, b, im);
    ELSE IPut1(o, pc, pcb, Mov+U, RH, 0, im DIV 10000H);
      IF im MOD 10000H # 0 THEN IPut1(o, pc, pcb, Ior, RH, RH, im MOD 10000H) END ;
      IPut0(pc, pcb, op, a, b, RH);
    END
*)
  END IPut1a;



  (* begin-procedure-description
---
**IPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE IPut2*(VAR pc, pcb: LONGINT; op, ai, bi, off: LONGINT);
    VAR a,b,a0,a1,b0,b1:INTEGER;
  BEGIN (*emit load/store instruction*)
(*
    a:=regmap[ai];b:=regmap[bi];
    a1:=a MOD 8; a0:=48H; IF a > 8 THEN a0 := 49H END;
    IF op = Ldr THEN
      Put.ThreeBytes( a0, 8BH, 80H + a1, pc, pcb ); Put.FourByteInteger( off, pc, pcb )
    ELSIF op = Str THEN
      Put.ThreeBytes( a0, 89H, 80H + a1, pc, pcb ); Put.FourByteInteger( off, pc, pcb )
    ELSE
     Put.ThreeBytes( 090H, 090H, 090H, pc, pcb )
    END
*)
  END IPut2;



  (* begin-procedure-description
---
**IPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE IPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    VAR opc,osz,disp: INTEGER;
  BEGIN (*emit branch instruction*)
(*
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
*)

    disp:=(off * 4) - 4;
    IF    op = BR  THEN (*via register*)
      IF (off = 15) THEN
        Put.OneByte( 0C3H, pc, pcb); osz:=0
      ELSE
        opc:=0E9H; osz:=4
      END
    ELSIF op = BLR THEN (*via register and depositing link*)
        Put.OneByte( 090H, pc, pcb); osz:=0
    ELSIF op = BC  THEN (*via offset from pc*)

      IF    (cond = 7)  THEN
                       IF (disp < -127) OR (disp > 127) THEN opc:=0E9H; osz:=4  ELSE opc:= 090H; osz:=1 END;
      ELSIF (cond = EQ) THEN
                        IF (disp < -127) OR (disp > 127) THEN opc:=074H; osz:=4  ELSE opc:= 084H; osz:=1 END;
      ELSIF (cond = NE) THEN
                        IF (disp < -127) OR (disp > 127) THEN opc:=075H; osz:=4  ELSE opc:= 085H; osz:=1 END;
      ELSIF (cond = GT) THEN
                        IF (disp < -127) OR (disp > 127) THEN opc:=07FH; osz:=4  ELSE opc:= 08FH; osz:=1 END;
      ELSIF (cond = GE) THEN
                        IF (disp < -127) OR (disp > 127) THEN opc:=07DH; osz:=4  ELSE opc:= 08DH; osz:=1 END;
      ELSIF (cond = LT) THEN
                        IF (disp < -127) OR (disp > 127) THEN opc:=06CH; osz:=4  ELSE opc:= 07CH; osz:=1 END;
      ELSIF (cond = LE) THEN
                        IF (disp < -127) OR (disp > 127) THEN opc:=07EH; osz:=4  ELSE opc:= 08EH; osz:=1 END;
      ELSE opc:=90H; disp:=90H; osz:=1
      END;

    ELSIF op = BL  THEN (*via offset from pc and depositing link -- convert to jsr *)
      opc:=0E8H; osz:=4
    END;


    IF osz = 4 THEN
        Put.OneByte( opc, pc, pcb); Put.FourByteInteger( disp, pc, pcb)
    ELSIF osz = 1 THEN
        Put.OneByte( opc, pc, pcb); Put.OneByte( disp, pc, pcb)
    END

  END IPut3;


  (* begin-procedure-description
---
**IHeader** prepares the code introductory sequence for a compiled X8664 module
  end-procedure-description *)
  PROCEDURE IHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN
      Put.CodeWord(0, 0E9H + ((entry - 5) * 100H)); Put.CodeWord(1, 90909000H); (* 32-bit pc-relative jump *)
      IPut1(121, pc, pcb, Sub, SP, SP, 8); IPut2(pc, pcb, Str, LNK, SP, 0) 
    ELSE 
      IPut1(121, pc, pcb, Sub, SP, SP, 8); IPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END IHeader;

  (* begin-section-description
## ---------- ARM64 instruction generation
  end-section-description *)


  (* begin-procedure-description
---
**ASetTables** maps registers between the RISC5 model machine and the aarch64 actual machine and prepares opcode tables for aarch64.
  end-procedure-description *)
  PROCEDURE ASetTables;
    VAR i: INTEGER;
  BEGIN

      regmap[MT]:=29; regmap[13]:=13; regmap[SP]:=31; regmap[LNK]:=30;

      it0[Mov]:= 0AA000000H;  it0[Lsl]:=         0H;  it0[Asr]:=         0H;  it0[Ror]:=         0H; 
      it0[And]:=         0H;  it0[Ann]:=         0H;  it0[Ior]:=         0H;  it0[Xor]:=         0H;
      it0[Add]:= 0AB000000H;  it0[Sub]:= 0EB000000H;  it0[Mul]:=         0H;  it0[Div]:=         0H;
      it0[Fad]:=         0H;  it0[Fsb]:=         0H;  it0[Fml]:=         0H;  it0[Fdv]:=         0H;

      it1[Mov]:= 0D2000000H;  it1[Lsl]:=         0H;  it1[Asr]:=         0H;  it1[Ror]:=         0H; 
      it1[And]:=         0H;  it1[Ann]:=         0H;  it1[Ior]:=         0H;  it1[Xor]:=         0H;
      it1[Add]:= 091000000H;  it1[Sub]:= 0D1000000H;  it1[Mul]:=         0H;  it1[Div]:=         0H;
      it1[Fad]:=         0H;  it1[Fsb]:=         0H;  it1[Fml]:=         0H;  it1[Fdv]:=         0H;

      it2[Ldr-8]:=     00000H;  it2[Ldb-8]:=     00000H;  it2[Str-8]:=     00000H;  it2[Stb-8]:=     00000H; 

      it3[BMI]:=     40000H;  it3[BEQ]:=     40000H;  it3[BCS]:=     40000H;      it3[BVS]:= 40000H; 
      it3[BLS]:=     40000H;  it3[BLT]:=     40000H;  it3[BLE]:=     40000H;      it3[B  ]:= 40000H;
      it3[BPL]:=     40000H;  it3[BNE]:=     40000H;  it3[BVC]:=     40000H;      it3[BCC]:= 40000H;
      it3[BHI]:=     40000H;  it3[BGE]:=     40000H;  it3[BGT]:=     40000H;      it3[BNO]:= 40000H;

  END ASetTables;


(* begin-procedure-description
---
**APut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE APut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN (*emit format-0 instruction*)
    IF   op = Mov THEN 
      IF a = SP THEN
        Put.CodeWord(pc, 9100001FH + (regmap[c] * 20H))
      ELSIF c = SP THEN
        Put.CodeWord(pc, 910003E0H + regmap[a] )
      ELSE
        Put.CodeWord(pc, it0[op] + (regmap[c] * 10000H) + (1FH * 20H) + regmap[a])
      END
    ELSIF op < 16 THEN
      Put.CodeWord(pc, it0[op] + (regmap[c] * 10000H) + (regmap[b] * 20H) + regmap[a])
    ELSE
      Put.CodeWord(pc, -1)
    END;
    INC(pc)
  END APut0;

  (* begin-procedure-description
---
**APut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE APut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*emit format-1 instruction,  -10000H <= im < 10000H*)
    IF   op = Mov THEN 
      Put.CodeWord(pc, (1A5H * 800000H) + (im * 20H) + regmap[a])
    ELSIF op < 16 THEN
      Put.CodeWord(pc, it1[op] + (im * 400H) + (regmap[b] * 20H) + regmap[a])
    ELSE
      Put.CodeWord(pc, -1)
    END;
    INC(pc)
  END APut1;

  (* begin-procedure-description
---
**APut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE APut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -100H <= im < 100H*)
    IF (im >= -100H) & (im <= 0FFH) THEN APut1(o, pc, pcb, op, a, b, im);
    ELSE 
      Put.CodeWord(pc, 0D2800000H + regmap[a]  +  (im MOD 10000H * 20H)) ; INC(pc);     (* movw opcode *)
      Put.CodeWord(pc, 0F2A00000H + regmap[a]  +  (im DIV 10000H MOD 10000H * 20H)) ; INC(pc);    (* movt opcode *)
(* need to handle 64-bit and negative values.
      Put.CodeWord(pc, 0F2C00000H + regmap[a]  +  (im DIV 100000000H MOD 10000H)) ; INC(pc);    (* movt opcode *)
      Put.CodeWord(pc, 0F2E00000H + regmap[a]  +  (im DIV 1000000000000H MOD 10000H)) ; INC(pc);    (* movt opcode *)
*)
      IF op MOD 16 # 0 THEN
        APut0(pc, pcb, op, a, b, a)
      END
    END
  END APut1a;

  (* begin-procedure-description
---
**APut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE APut2*(VAR pc, pcb: LONGINT; op, ai, bi, off: LONGINT);
    VAR a,b:INTEGER;
  BEGIN (*emit load/store instruction*)
    a:=regmap[ai];b:=regmap[bi];
    IF op = Ldr THEN
      Put.CodeWord(pc, 0F8400000H + ((off MOD 200H) * 1000H) + (b * 20H) + a)
    ELSIF op = Str THEN
      Put.CodeWord(pc, 0F8000000H + ((off MOD 200H) * 1000H) + (b * 20H) + a)
    ELSE
      Put.CodeWord(pc,0)
    END;
    INC(pc)
  END APut2;

  (* begin-procedure-description
---
**APut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE APut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    VAR opc,osz,disp: INTEGER;
  BEGIN (*emit branch instruction*)
(*
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
*)
    disp:=off;
    IF    op = BR  THEN (*via register*)
      IF off = 15 THEN
        Put.CodeWord(pc, 0D65F03C0H); INC(pc) (* substitute ret *)
      ELSE
        Put.CodeWord(pc, 0D61FH * 10000H + (regmap[off] * 20H)); INC(pc)
      END
    ELSIF op = BLR THEN (*via register and depositing link*)
      Put.CodeWord(pc, 0D63FH * 10000H + (regmap[off] * 20H)); INC(pc)

    ELSIF op = BC  THEN (*via offset from pc*)
      Put.CodeWord(pc,14000000H + ((off+1 ) MOD 4000000H)); INC(pc)
    ELSIF op = BL  THEN (*via offset from pc and depositing link*)
      Put.CodeWord(pc,94000000H + ((off+1 ) MOD 4000000H)); INC(pc)
    END;
END APut3;

  (* begin-procedure-description
---
**AHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE AHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN 
      Put.CodeWord(0, (14H * 1000000H) + (entry DIV 4)); (* 24-bit pc-relative jump *)
(*      APut1(121, pc, pcb, Sub, SP, SP, 16); APut2(pc, pcb, Str, LNK, SP, 0)  *)
    ELSE 
      APut1(121, pc, pcb, Sub, SP, SP, 16); APut2(pc, pcb, Str, LNK, SP, 0)
    END
  END AHeader;


  (* begin-section-description
## ---------- ARM32 instruction generation
  end-section-description *)


  (* begin-procedure-description
---
**aSetTables** maps registers between the RISC5 model machine and the arm actual machine and prepares opcode tables for arm 32-bit.
  end-procedure-description *)
  PROCEDURE aSetTables;
  BEGIN
      regmap[MT]:=12; regmap[SP]:=13; regmap[LNK]:=14;

      it0[Mov]:= 0E1A00000H;  it0[Lsl]:= 0E1A00100H;  it0[Asr]:= 0E1A00000H;  it0[Ror]:= 0E1A00000H; 
      it0[And]:= 0E0000000H;  it0[Ann]:=         0H;  it0[Ior]:=         0H;  it0[Xor]:= 0E0200000H;
      it0[Add]:= 0E0800000H;  it0[Sub]:= 0E0400000H;  it0[Mul]:=         0H;  it0[Div]:=         0H;
      it0[Fad]:=         0H;  it0[Fsb]:=         0H;  it0[Fml]:=         0H;  it0[Fdv]:=         0H;

      it1[Mov]:= 0E3A00000H;  it1[Lsl]:=         0H;  it1[Asr]:=         0H;  it1[Ror]:=         0H; 
      it1[And]:= 0E2000000H;  it1[Ann]:=         0H;  it1[Ior]:= 0E3800000H;  it1[Xor]:= 0E2200000H;
      it1[Add]:= 0E2800000H;  it1[Sub]:= 0E2400000H;  it1[Mul]:=         0H;  it1[Div]:=         0H;
      it1[Fad]:=         0H;  it1[Fsb]:=         0H;  it1[Fml]:=         0H;  it1[Fdv]:=         0H;

      it2[Ldr-8]:=     00000H;  it2[Ldb-8]:=     00000H;  it2[Str-8]:=     00000H;  it2[Stb-8]:=     00000H; 

      it3[BMI]:=     40000H;  it3[BEQ]:=     40000H;  it3[BCS]:=     40000H;  it3[BVS]:=     40000H; 
      it3[BLS]:=     40000H;  it3[BLT]:=     40000H;  it3[BLE]:=     40000H;  it3[B  ]:= 0EA000000H;
      it3[BPL]:=     40000H;  it3[BNE]:=     40000H;  it3[BVC]:=     40000H;  it3[BCC]:=     40000H;
      it3[BHI]:=     40000H;  it3[BGE]:=     40000H;  it3[BGT]:=     40000H;  it3[BNO]:=     40000H;
  END aSetTables;
(*
(* begin-procedure-description
---
**aUMT** convert an integer to mov m/t immediate format
  end-procedure-description *)
  PROCEDURE aUMT( i : LONGINT ): LONGINT;
    VAR c,d:LONGINT;
  BEGIN
        c := (i DIV 1000H MOD 8) * 10000H;
        d := (i MOD 1000H);
  RETURN c + d
  END aUMT;
*)

(* begin-procedure-description
---
**aPut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE aPut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN (*emit format-0 instruction*)
    IF op < 16 THEN Put.CodeWord(pc, it0[op] + (regmap[a] * 10000H) + (regmap[b] * 1000H) + regmap[c]) ; INC(pc) 
    ELSE Put.CodeWord(pc,-1); INC(pc)
    END;
  END aPut0;


  (* begin-procedure-description
---
**aPut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE aPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*emit format-1 instruction,  -100H <= im < 100H*)
    IF op = 0 THEN
      Put.CodeWord(pc, 0E3000000H + (regmap[a] * 1000H) + (im  DIV 1000H MOD 8) * 10000H + im MOD 1000H) ; INC(pc);     (* movw opcode *)
    ELSIF op < 16 THEN
      IF im < 0 THEN (* mvn then reg op *)
        Put.CodeWord(pc, 0E3E00000H + (regmap[b] * 10000H) + (regmap[a] * 1000H) (* + (s * 100H) *) + ((0-im) MOD 100H)); INC(pc);
        IF op # Mov THEN
          aPut0(pc, pcb, op, a, b, a)
        END
      ELSE 
        Put.CodeWord(pc, it1[op] + (regmap[b] * 10000H) + (regmap[a] * 1000H) (* + (s * 100H) *) + (im MOD 100H)); INC(pc)
      END
    ELSE (* op modifier bit set *)
      IF op MOD 16 = 0 THEN (* move to top 16 bits *)
        Put.CodeWord(pc, 0E3400000H + (im DIV 1000H MOD 10H * 10000H) + (regmap[a] * 1000H) + (im MOD 1000H)); INC(pc);    (* movt opcode *)
      ELSE 
        Put.CodeWord(pc,-1); INC(pc)
      END
    END;
    
  END aPut1;

  (* begin-procedure-description
---
**aPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE aPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -100H <= im < 100H*)
    IF (im >= -100H) & (im <= 0FFH) THEN aPut1(o, pc, pcb, op, a, b, im);
    ELSE 
      Put.CodeWord(pc, 0E3000000H + (regmap[a] * 1000H) + (im DIV 1000H MOD 10H) * 10000H + im MOD 1000H) ; INC(pc);     (* movw opcode *)
      Put.CodeWord(pc, 0E3400000H + (regmap[a] * 1000H) + (im DIV 10000000H MOD 10H) * 10000H + (im DIV 10000H MOD 1000H)) ; INC(pc);    (* movt opcode *)
      IF op MOD 16 # 0 THEN
        aPut0(pc, pcb, op, a, b, a)
      END
    END

  END aPut1a;

  (* begin-procedure-description
---
**aPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE aPut2*(VAR pc, pcb: LONGINT; op, ai, bi, off: LONGINT);
    VAR a,b:INTEGER;
  BEGIN (*emit load/store instruction*)
    a:=regmap[ai];b:=regmap[bi];
    IF op = Ldr THEN
      Put.CodeWord(pc, 0E5900000H + (off MOD 1000H)  + (b * 10000H) + (a * 1000H))
    ELSIF op = Str THEN
      Put.CodeWord(pc, 0E5800000H + (off MOD 1000H)  + (b * 10000H) + (a * 1000H))
    ELSE
      Put.CodeWord(pc,0)
    END;
    INC(pc)
  END aPut2;

  (* begin-procedure-description
---
**aPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE aPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    VAR opc,osz,disp: INTEGER;
  BEGIN (*emit branch instruction*)
(*
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
*)
    disp:=off;
    IF disp < 0 THEN INC(disp,-1) END;
    IF    op = BR  THEN (*via register*)
      Put.CodeWord(pc, 0E12FFF10H + regmap[off]) ; INC(pc)
    ELSIF op = BLR THEN (*via register and depositing link*)
      Put.CodeWord(pc, 0E12FFF30H + regmap[off]) ; INC(pc)
    ELSIF op = BC  THEN (*via offset from pc*)
      Put.CodeWord(pc, it3[cond] + (disp MOD 1000000H)); INC(pc)
    ELSIF op = BL  THEN (*via offset from pc and depositing link*)
      Put.CodeWord(pc, it3[cond] + 1000000H + (disp MOD 1000000H)); INC(pc)
    END;
END aPut3;

  (* begin-procedure-description
---
**aHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE aHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN 
      Put.CodeWord(0, 0EAH * 1000000H  + (entry - 8) DIV 4 ); (* 24-bit pc-relative jump *)
      (* aPut1(121, pc, pcb, Mov+U, SP, SP, 07FFFH) *)
    ELSE 
      aPut1(121, pc, pcb, Sub, SP, SP, 4); aPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END aHeader;


  (* begin-section-description
## ---------- CORTEX0 instruction generation
  end-section-description *)


  (* begin-procedure-description
---
**CSetTables** maps registers between the RISC5 model machine and the aarch64 actual machine and prepares opcode tables for aarch64.
  end-procedure-description *)
  PROCEDURE CSetTables;
    VAR i: INTEGER;
  BEGIN

      regmap[MT]:=11; regmap[13]:=12; regmap[SP]:=13; regmap[LNK]:=14;

      it0[Mov]:=     0BF00H;  it0[Lsl]:=     00000H;  it0[Asr]:=     0BF00H;  it0[Ror]:=     0BF00H; 
      it0[And]:=     0BF00H;  it0[Ann]:=     0BF00H;  it0[Ior]:=     08300H;  it0[Xor]:=     0BF00H;
      it0[Add]:=     0BF00H;  it0[Sub]:=     0BF00H;  it0[Mul]:=     0BF00H;  it0[Div]:=     0BF00H;
      it0[Fad]:=     0BF00H;  it0[Fsb]:=     0BF00H;  it0[Fml]:=     0BF00H;  it0[Fdv]:=     0BF00H;

      it1[Mov]:=     0BF00H;  it1[Lsl]:=     04080H;  it1[Asr]:=     0BF00H;  it1[Ror]:=     0BF00H; 
      it1[And]:=     0BF00H;  it1[Ann]:=     0BF00H;  it1[Ior]:=     0BF00H;  it1[Xor]:=     0BF00H;
      it1[Add]:=     0BF00H;  it1[Sub]:=     01E00H;  it1[Mul]:=     0BF00H;  it1[Div]:=     0BF00H;
      it1[Fad]:=     0BF00H;  it1[Fsb]:=     0BF00H;  it1[Fml]:=     0BF00H;  it1[Fdv]:=     0BF00H;

      it2[Ldr-8]:=     0BF00H;  it2[Ldb-8]:=     0BF00H;  it2[Str-8]:=     0BF00H;  it2[Stb-8]:=     0BF00H; 

      it3[BMI]:=      1A00H;  it3[BEQ]:=      1A00H;  it3[BCS]:=      1A00H;      it3[BVS]:=  1A00H; 
      it3[BLS]:=      1A00H;  it3[BLT]:=      1A00H;  it3[BLE]:=      1A00H;      it3[B  ]:=  1A00H;
      it3[BPL]:=      1A00H;  it3[BNE]:=      1A00H;  it3[BVC]:=      1A00H;      it3[BCC]:=  1A00H;
      it3[BHI]:=      1A00H;  it3[BGE]:=      1A00H;  it3[BGT]:=      1A00H;      it3[BNO]:=  1A00H;

  END CSetTables;


(* begin-procedure-description
---
**CPut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE CPut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN (*emit format-0 instruction*)
    IF   op = Mov THEN 
      Put.TwoByteInteger(0BF00H,pc,pcb);
    ELSIF op < 16 THEN
      Put.TwoByteInteger(it0[op]+regmap[c],pc,pcb);
(* 
      Put.CodeWord(pc, it0[op] + (regmap[c] * 10000H) + (regmap[b] * 20H) + regmap[a])
*)
    ELSE
      Put.TwoByteInteger(0BF00H,pc,pcb);
(* 
      Put.CodeWord(pc, -1)
*)
    END;
(*
    INC(pc)
*)
  END CPut0;

  (* begin-procedure-description
---
**CPut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE CPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*emit format-1 instruction,  -10000H <= im < 10000H*)
    IF   op = Mov THEN
      IF ( im < 127) & (im > -128 ) THEN
        Put.TwoByteInteger(02000H + regmap[a] * 100H + im,pc,pcb);
      ELSE
        Put.FourByteInteger(00000F24FH  + im MOD 8 * 10000H + regmap[a] * 1000000H (*+  off DIV 10000H MOD 800H + off MOD 1000H * 10000H *) ,pc,pcb);
      END
    ELSIF op < 16 THEN
      Put.TwoByteInteger( it1[op] + regmap[a] * 10000H + im MOD 100H,pc,pcb);
(* 
      Put.CodeWord(pc, it1[op] + (im * 400H) + (regmap[b] * 20H) + regmap[a])
*)
    ELSE
      Put.TwoByteInteger(0BF00H,pc,pcb);
(* 
      Put.CodeWord(pc, -1)
*)
    END;
(*
    INC(pc)
*)
  END CPut1;

  (* begin-procedure-description
---
**CPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE CPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -100H <= im < 100H*)
    Put.TwoByteInteger(0BF00H,pc,pcb);
(*
    IF (im >= -100H) & (im <= 0FFH) THEN CPut1(o, pc, pcb, op, a, b, im);
    ELSE 
      Put.CodeWord(pc, 0D2800000H + regmap[a]  +  (im MOD 10000H * 20H)) ; INC(pc);     (* movw opcode *)
      Put.CodeWord(pc, 0F2A00000H + regmap[a]  +  (im DIV 10000H MOD 10000H * 20H)) ; INC(pc);    (* movt opcode *)
(* need to handle 64-bit and negative values.
      Put.CodeWord(pc, 0F2C00000H + regmap[a]  +  (im DIV 100000000H MOD 10000H)) ; INC(pc);    (* movt opcode *)
      Put.CodeWord(pc, 0F2E00000H + regmap[a]  +  (im DIV 1000000000000H MOD 10000H)) ; INC(pc);    (* movt opcode *)
*)
      IF op MOD 16 # 0 THEN
        CPut0(pc, pcb, op, a, b, a)
      END
    END
*)
  END CPut1a;

  (* begin-procedure-description
---
**CPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE CPut2*(VAR pc, pcb: LONGINT; op, ai, bi, off: LONGINT);
    VAR a,b:INTEGER;
  BEGIN (*emit load/store instruction*)
    Put.TwoByteInteger(0BF00H,pc,pcb);
(*
    a:=regmap[ai];b:=regmap[bi];
    IF op = Ldr THEN
      Put.CodeWord(pc, 0F8400000H + ((off MOD 200H) * 1000H) + (b * 20H) + a)
    ELSIF op = Str THEN
      Put.CodeWord(pc, 0F8000000H + ((off MOD 200H) * 1000H) + (b * 20H) + a)
    ELSE
      Put.CodeWord(pc,0)
    END;
    INC(pc)
*)
  END CPut2;

  (* begin-procedure-description
---
**CPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE CPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    VAR opc,osz,disp: INTEGER;
  BEGIN (*emit branch instruction*)
(*
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
*)
    disp:=off;
    IF    op = BR  THEN (*via register*)
      IF off = 15 THEN
        Put.TwoByteInteger(4770H,pc,pcb); (* B LR *)
      ELSE
        Put.TwoByteInteger(4700H + (regmap[off]*8),pc,pcb);
      END
    ELSIF op = BLR THEN (*via register and depositing link*)
      Put.TwoByteInteger(0F0000000H ,pc,pcb);
(*
      Put.CodeWord(pc, 0D63FH * 10000H + (regmap[off] * 20H)); INC(pc)
*)
    ELSIF op = BC  THEN (*via offset from pc*)
    Put.TwoByteInteger(0BF00H,pc,pcb);
(*
      Put.CodeWord(pc,14000000H + ((off+1 ) MOD 4000000H)); INC(pc)
*)
    ELSIF op = BL  THEN (*via offset from pc and depositing link*)
      off := off * 2;
      Put.FourByteInteger(0F000F000H  +  off DIV 10000H MOD 800H + off MOD 1000H * 10000H ,pc,pcb);
    END;
END CPut3;

  (* begin-procedure-description
---
**CHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE CHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN 
      Put.CodeWord(0, 0E000H +  (((entry - 2) DIV 2) MOD 8000)  ); (* 12-bit pc-relative jump (even addresses) *)
(*      CPut1(121, pc, pcb, Sub, SP, SP, 16); CPut2(pc, pcb, Str, LNK, SP, 0)  *)
    ELSE 
      CPut1(121, pc, pcb, Sub, SP, SP, 16); CPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END CHeader;


  (* begin-section-description
## ---------- CORTEX0 instruction generation
  end-section-description *)


  (* begin-procedure-description
---
**cSetTables** maps registers between the RISC5 model machine and the arm actual machine and prepares opcode tables for arm 32-bit.
  end-procedure-description *)
  PROCEDURE cSetTables;
  BEGIN
(*      regmap[MT]:=12; regmap[SP]:=13; regmap[LNK]:=14; *)
      regmap[MT]:=11; regmap[13]:=12; regmap[SP]:=13; regmap[LNK]:=14;

      it0[Mov]:= 0E1A00000H;  it0[Lsl]:= 0E1A00100H;  it0[Asr]:= 0E1A00000H;  it0[Ror]:= 0E1A00000H; 
      it0[And]:= 0E0000000H;  it0[Ann]:=         0H;  it0[Ior]:=         0H;  it0[Xor]:= 0E0200000H;
      it0[Add]:= 0E0800000H;  it0[Sub]:= 0E0400000H;  it0[Mul]:=         0H;  it0[Div]:=         0H;
      it0[Fad]:=         0H;  it0[Fsb]:=         0H;  it0[Fml]:=         0H;  it0[Fdv]:=         0H;

      it1[Mov]:= 0E3A00000H;  it1[Lsl]:=         0H;  it1[Asr]:=         0H;  it1[Ror]:=         0H; 
      it1[And]:= 0E2000000H;  it1[Ann]:=         0H;  it1[Ior]:= 0E3800000H;  it1[Xor]:= 0E2200000H;
      it1[Add]:= 0E2800000H;  it1[Sub]:= 0E2400000H;  it1[Mul]:=         0H;  it1[Div]:=         0H;
      it1[Fad]:=         0H;  it1[Fsb]:=         0H;  it1[Fml]:=         0H;  it1[Fdv]:=         0H;

      it2[Ldr-8]:=     00000H;  it2[Ldb-8]:=     00000H;  it2[Str-8]:=     00000H;  it2[Stb-8]:=     00000H; 

      it3[BMI]:=     40000H;  it3[BEQ]:=     40000H;  it3[BCS]:=     40000H;  it3[BVS]:=     40000H; 
      it3[BLS]:=     40000H;  it3[BLT]:=     40000H;  it3[BLE]:=     40000H;  it3[B  ]:= 0EA000000H;
      it3[BPL]:=     40000H;  it3[BNE]:=     40000H;  it3[BVC]:=     40000H;  it3[BCC]:=     40000H;
      it3[BHI]:=     40000H;  it3[BGE]:=     40000H;  it3[BGT]:=     40000H;  it3[BNO]:=     40000H;
  END cSetTables;
(*
(* begin-procedure-description
---
**cUMT** convert an integer to mov m/t immediate format
  end-procedure-description *)
  PROCEDURE cUMT( i : LONGINT ): LONGINT;
    VAR c,d:LONGINT;
  BEGIN
        c := (i DIV 1000H MOD 8) * 10000H;
        d := (i MOD 1000H);
  RETURN c + d
  END cUMT;
*)

(* begin-procedure-description
---
**cPut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE cPut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN (*emit format-0 instruction*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    IF op < 16 THEN Put.CodeWord(pc, it0[op] + (regmap[a] * 10000H) + (regmap[b] * 1000H) + regmap[c]) ; INC(pc) 
    ELSE Put.CodeWord(pc,-1); INC(pc)
    END;
*)
  END cPut0;


  (* begin-procedure-description
---
**cPut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE cPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*emit format-1 instruction,  -100H <= im < 100H*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    IF op = 0 THEN
      Put.CodeWord(pc, 0E3000000H + (regmap[a] * 1000H) + (im  DIV 1000H MOD 8) * 10000H + im MOD 1000H) ; INC(pc);     (* movw opcode *)
    ELSIF op < 16 THEN
      IF im < 0 THEN (* mvn then reg op *)
        Put.CodeWord(pc, 0E3E00000H + (regmap[b] * 10000H) + (regmap[a] * 1000H) (* + (s * 100H) *) + ((0-im) MOD 100H)); INC(pc);
        IF op # Mov THEN
          cPut0(pc, pcb, op, a, b, a)
        END
      ELSE 
        Put.CodeWord(pc, it1[op] + (regmap[b] * 10000H) + (regmap[a] * 1000H) (* + (s * 100H) *) + (im MOD 100H)); INC(pc)
      END
    ELSE (* op modifier bit set *)
      IF op MOD 16 = 0 THEN (* move to top 16 bits *)
        Put.CodeWord(pc, 0E3400000H + (im DIV 1000H MOD 10H * 10000H) + (regmap[a] * 1000H) + (im MOD 1000H)); INC(pc);    (* movt opcode *)
      ELSE 
        Put.CodeWord(pc,-1); INC(pc)
      END
    END;
*)    
  END cPut1;

  (* begin-procedure-description
---
**cPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE cPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -100H <= im < 100H*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    IF (im >= -100H) & (im <= 0FFH) THEN cPut1(o, pc, pcb, op, a, b, im);
    ELSE 
      Put.CodeWord(pc, 0E3000000H + (regmap[a] * 1000H) + (im DIV 1000H MOD 10H) * 10000H + im MOD 1000H) ; INC(pc);     (* movw opcode *)
      Put.CodeWord(pc, 0E3400000H + (regmap[a] * 1000H) + (im DIV 10000000H MOD 10H) * 10000H + (im DIV 10000H MOD 1000H)) ; INC(pc);    (* movt opcode *)
      IF op MOD 16 # 0 THEN
        cPut0(pc, pcb, op, a, b, a)
      END
    END
*)
  END cPut1a;

  (* begin-procedure-description
---
**cPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE cPut2*(VAR pc, pcb: LONGINT; op, ai, bi, off: LONGINT);
    VAR a,b:INTEGER;
  BEGIN (*emit load/store instruction*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    a:=regmap[ai];b:=regmap[bi];
    IF op = Ldr THEN
      Put.CodeWord(pc, 0E5900000H + (off MOD 1000H)  + (b * 10000H) + (a * 1000H))
    ELSIF op = Str THEN
      Put.CodeWord(pc, 0E5800000H + (off MOD 1000H)  + (b * 10000H) + (a * 1000H))
    ELSE
      Put.CodeWord(pc,0)
    END;
    INC(pc)
*)
  END cPut2;

  (* begin-procedure-description
---
**cPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE cPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    VAR opc,osz,disp: INTEGER;
  BEGIN (*emit branch instruction*)
(*
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    disp:=off;
    IF disp < 0 THEN INC(disp,-1) END;
    IF    op = BR  THEN (*via register*)
      Put.CodeWord(pc, 0E12FFF10H + regmap[off]) ; INC(pc)
    ELSIF op = BLR THEN (*via register and depositing link*)
      Put.CodeWord(pc, 0E12FFF30H + regmap[off]) ; INC(pc)
    ELSIF op = BC  THEN (*via offset from pc*)
      Put.CodeWord(pc, it3[cond] + (disp MOD 1000000H)); INC(pc)
    ELSIF op = BL  THEN (*via offset from pc and depositing link*)
      Put.CodeWord(pc, it3[cond] + 1000000H + (disp MOD 1000000H)); INC(pc)
    END;
*)
END cPut3;

  (* begin-procedure-description
---
**cHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE cHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN 
      Put.CodeWord(0, 0E000H +  (((entry - 2) DIV 2) MOD 8000)  ); (* 12-bit pc-relative jump (even addresses) *)
      (* cPut1(121, pc, pcb, Mov+U, SP, SP, 07FFFH) *)
    ELSE 
      cPut1(121, pc, pcb, Sub, SP, SP, 4); aPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END cHeader;



  (* begin-section-description
## ---------- RISCV64 instruction generation
  end-section-description *)



  (* begin-procedure-description
---
**VSetTables** maps registers between the RISC5 model machine and the rv64 actual machine and prepares opcode tables for riscv64.
  end-procedure-description *)
  PROCEDURE VSetTables;
    VAR i: INTEGER;
  BEGIN
      FOR i:= 0 TO 15 DO regmap[i]:=10+i END; regmap[MT]:=3; regmap[SP]:=2; regmap[LNK]:=1;

      it0[Mov]:=         0H;  it0[Lsl]:=      1033H;  it0[Asr]:=         0H;  it0[Ror]:=         0H; 
      it0[And]:=      7033H;  it0[Ann]:=         0H;  it0[Ior]:=      6033H;  it0[Xor]:=      4033H;
      it0[Add]:=      0033H;  it0[Sub]:=  40000033H;  it0[Mul]:=         0H;  it0[Div]:=         0H;
      it0[Fad]:=         0H;  it0[Fsb]:=         0H;  it0[Fml]:=         0H;  it0[Fdv]:=         0H;

      it1[Mov]:=         0H;  it1[Lsl]:=      1013H;  it1[Asr]:=         0H;  it1[Ror]:=         0H; 
      it1[And]:=      7013H;  it1[Ann]:=         0H;  it1[Ior]:=      6013H;  it1[Xor]:=      4013H;
      it1[Add]:=      0013H;  it1[Sub]:=      0013H;  it1[Mul]:=         0H;  it1[Div]:=         0H;
      it1[Fad]:=         0H;  it1[Fsb]:=         0H;  it1[Fml]:=         0H;  it1[Fdv]:=         0H;

      it2[Ldr-8]:=    2003H;  it2[Ldb-8]:=    0003H;  it2[Str-8]:=    2023H;  it2[Stb-8]:=    0023H; 

      it3[BMI]:=     00063H;  it3[BEQ]:=     00063H;  it3[BCS]:=     00063H;      it3[BVS]:= 00063H; 
      it3[BLS]:=     00063H;  it3[BLT]:=     00063H;  it3[BLE]:=     00063H;      it3[B  ]:= 00063H;
      it3[BPL]:=     00063H;  it3[BNE]:=     00063H;  it3[BVC]:=     00063H;      it3[BCC]:= 00063H;
      it3[BHI]:=     00063H;  it3[BGE]:=     00063H;  it3[BGT]:=     00063H;      it3[BNO]:= 00063H;

  END VSetTables;


(* begin-procedure-description
---
**vUJ** convert an integer to UJ immediate format
  end-procedure-description *)
  PROCEDURE vUJ( i : LONGINT ): LONGINT;
    VAR a,b,c,d:LONGINT;
  BEGIN
	a := (i DIV 100000H) * 40000H;
	b := (i DIV 2 MOD 200H) * 200H;
	c := (i DIV 800H MOD 2) * 100H;
	d := (i DIV 1000H MOD 100H);
  RETURN (a + b + c + d) * 1000H
  END vUJ;

(* begin-procedure-description
---
**VPut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE VPut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN (*emit format-0 instruction*)
    IF op < 16 THEN
      Put.CodeWord(pc, it0[op] + (regmap[a] * 80H) + (regmap[b] * 8000H) + (regmap[c] * 10000H) )
    ELSE 
      Put.CodeWord(pc,0)
    END;
    INC(pc)
  END VPut0;

  (* begin-procedure-description
---
**VPut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE VPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*emit format-1 instruction,  -1000H <= im < 1000H*) (* smaller than RISC5! *)
    IF    op = Mov THEN
      Put.CodeWord(pc, it1[Ior] + (regmap[a] * 80H) + (im * 100000H))
    ELSIF op = Sub THEN
      Put.CodeWord(pc, it1[op] + (regmap[a] * 80H) + (regmap[b] * 8000H) + ((0-im) * 100000H))
    ELSIF op < 16  THEN
      Put.CodeWord(pc, it1[op] + (regmap[a] * 80H) + (regmap[b] * 8000H) + (im * 100000H))
    ELSE
      Put.CodeWord(pc,0)
    END;
    INC(pc)
  END VPut1;

  (* begin-procedure-description
---
**VPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE VPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -10000H <= im < 10000H*)
    IF (im >= -1000H) & (im <= 0FFFH) THEN VPut1(o, pc, pcb, op, a, b, im);
    ELSE 
      Put.CodeWord(pc, 00000037H + (regmap[a] * 80H) + (im DIV 1000H * 1000H)) ; INC(pc);    (* lui opcode *)
      IF (im MOD 1000H) # 0 THEN VPut1(o,pc,pcb,Ior,a,a,im MOD 1000H) END;
      IF op MOD 16 # 0 THEN
        VPut0(pc, pcb, op, a, b, a)
      END
    END

  END VPut1a;

  (* begin-procedure-description
---
**VPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE VPut2*(VAR pc, pcb: LONGINT; op, a, b, off: LONGINT);
  BEGIN (*emit load/store instruction*)
    IF op < Str THEN
      Put.CodeWord(pc, it2[op-8] + ((regmap[a] MOD 20H) * 80H) + (regmap[b] * 8000H) + (off MOD 1000H * 100000H)); INC(pc);
    ELSE 
      Put.CodeWord(pc, it2[op-8] + ((off MOD 20H) * 80H) + (regmap[b] * 8000H) + (regmap[a] * 100000H) + (off DIV 20H MOD 80H * 2000000H)); INC(pc);
    END 
  END VPut2;

  (* begin-procedure-description
---
**VPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE VPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    VAR opc,osz,disp: INTEGER;
  BEGIN (*emit branch instruction*)
(*
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
*)
    disp:=off;
    IF    op = BR  THEN (*via register*)
      Put.CodeWord(pc, 67H + (regmap[off] * 8000H)) ; INC(pc)
    ELSIF op = BLR THEN (*via register and depositing link*)
      Put.CodeWord(pc, 67H + (regmap[off] * 8000H) + (regmap[LNK] * 80H)) ; INC(pc)
    ELSIF op = BC  THEN (*via offset from pc*)
      Put.CodeWord(pc, 6FH + vUJ(off * 4 + 4) ) ; INC(pc)
    ELSIF op = BL  THEN (*via offset from pc and depositing link*)
      Put.CodeWord(pc, 6FH + vUJ(off * 4 + 4) + (regmap[LNK]*80H)) ; INC(pc)
    END;
  END VPut3;

  (* begin-procedure-description
---
**VHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE VHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN 
      Put.CodeWord(0, 6FH + vUJ(entry));
      (* VPut1(121, pc, pcb, Sub, SP, SP, 8);  VPut2(pc, pcb, Str, LNK, SP, 0) *)
    ELSE 
      VPut1(121, pc, pcb, Sub, SP, SP, 8); VPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END VHeader;




  (* begin-section-description
## ---------- RISCV32 instruction generation
  end-section-description *)

  (* begin-procedure-description
---
**vSetTables** configures opcode tables for riscv32.
  end-procedure-description *)
  PROCEDURE vSetTables;
    VAR i: INTEGER;
  BEGIN
      FOR i:= 0 TO 15 DO regmap[i]:=10+i END; regmap[MT]:=3; regmap[SP]:=2; regmap[LNK]:=1;
  END vSetTables;                   


(* begin-procedure-description
---
**vPut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE vPut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN VPut0(pc,pcb,op,a,b,c)
  END vPut0;

  (* begin-procedure-description
---
**vPut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE vPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN VPut1(o,pc,pcb,op,a,b,im) 
  END vPut1;

  (* begin-procedure-description
---
**vPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE vPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN VPut1a(o,pc,pcb,RH,op,a,b,im)
  END vPut1a;

  (* begin-procedure-description
---
**vPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE vPut2*(VAR pc, pcb: LONGINT; op, a, b, off: LONGINT);
  BEGIN VPut2(pc,pcb,op,a,b,off)
  END vPut2;

  (* begin-procedure-description
---
**vPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE vPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
  BEGIN VPut3(pc,pcb,op,cond,off)
  END vPut3;

  (* begin-procedure-description
---
**vHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE vHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN
      Put.CodeWord(0, 6FH + vUJ(entry))  ;
      (* vPut1(121, pc, pcb, Sub, SP, SP, 4);  vPut2(pc, pcb, Str, LNK, SP, 0) *)
    ELSE
      vPut1(121, pc, pcb, Sub, SP, SP, 4); vPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END vHeader;

  (* begin-section-description
## ---------- WASM instruction generation
  end-section-description *)


  (* begin-procedure-description
---
**WSetTables** maps registers between the RISC5 model machine and the wasm virtual machine and prepares opcode tables for wasm.
  end-procedure-description *)
  PROCEDURE WSetTables;
  BEGIN
(*      regmap[MT]:=12; regmap[SP]:=13; regmap[LNK]:=14; *)
      regmap[MT]:=11; regmap[13]:=12; regmap[SP]:=13; regmap[LNK]:=14;

      it0[Mov]:= 0E1A00000H;  it0[Lsl]:= 0E1A00100H;  it0[Asr]:= 0E1A00000H;  it0[Ror]:= 0E1A00000H; 
      it0[And]:= 0E0000000H;  it0[Ann]:=         0H;  it0[Ior]:=         0H;  it0[Xor]:= 0E0200000H;
      it0[Add]:= 0E0800000H;  it0[Sub]:= 0E0400000H;  it0[Mul]:=         0H;  it0[Div]:=         0H;
      it0[Fad]:=         0H;  it0[Fsb]:=         0H;  it0[Fml]:=         0H;  it0[Fdv]:=         0H;

      it1[Mov]:= 0E3A00000H;  it1[Lsl]:=         0H;  it1[Asr]:=         0H;  it1[Ror]:=         0H; 
      it1[And]:= 0E2000000H;  it1[Ann]:=         0H;  it1[Ior]:= 0E3800000H;  it1[Xor]:= 0E2200000H;
      it1[Add]:= 0E2800000H;  it1[Sub]:= 0E2400000H;  it1[Mul]:=         0H;  it1[Div]:=         0H;
      it1[Fad]:=         0H;  it1[Fsb]:=         0H;  it1[Fml]:=         0H;  it1[Fdv]:=         0H;

      it2[Ldr-8]:=     00000H;  it2[Ldb-8]:=     00000H;  it2[Str-8]:=     00000H;  it2[Stb-8]:=     00000H; 

      it3[BMI]:=     40000H;  it3[BEQ]:=     40000H;  it3[BCS]:=     40000H;  it3[BVS]:=     40000H; 
      it3[BLS]:=     40000H;  it3[BLT]:=     40000H;  it3[BLE]:=     40000H;  it3[B  ]:= 0EA000000H;
      it3[BPL]:=     40000H;  it3[BNE]:=     40000H;  it3[BVC]:=     40000H;  it3[BCC]:=     40000H;
      it3[BHI]:=     40000H;  it3[BGE]:=     40000H;  it3[BGT]:=     40000H;  it3[BNO]:=     40000H;
  END WSetTables;

(* begin-procedure-description
---
**WPut0** PutRegFromRegOpReg
  end-procedure-description *)
  PROCEDURE WPut0*(VAR pc, pcb: LONGINT; op, a, b, c: LONGINT);
  BEGIN (*emit format-0 instruction*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    IF op < 16 THEN Put.CodeWord(pc, it0[op] + (regmap[a] * 10000H) + (regmap[b] * 1000H) + regmap[c]) ; INC(pc) 
    ELSE Put.CodeWord(pc,-1); INC(pc)
    END;
*)
  END WPut0;


  (* begin-procedure-description
---
**WPut1** PutRegFromRegOpImmSmall
  end-procedure-description *)
  PROCEDURE WPut1*(o: INTEGER; VAR pc, pcb: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*emit format-1 instruction,  -100H <= im < 100H*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    IF op = 0 THEN
      Put.CodeWord(pc, 0E3000000H + (regmap[a] * 1000H) + (im  DIV 1000H MOD 8) * 10000H + im MOD 1000H) ; INC(pc);     (* movw opcode *)
    ELSIF op < 16 THEN
      IF im < 0 THEN (* mvn then reg op *)
        Put.CodeWord(pc, 0E3E00000H + (regmap[b] * 10000H) + (regmap[a] * 1000H) (* + (s * 100H) *) + ((0-im) MOD 100H)); INC(pc);
        IF op # Mov THEN
          WPut0(pc, pcb, op, a, b, a)
        END
      ELSE 
        Put.CodeWord(pc, it1[op] + (regmap[b] * 10000H) + (regmap[a] * 1000H) (* + (s * 100H) *) + (im MOD 100H)); INC(pc)
      END
    ELSE (* op modifier bit set *)
      IF op MOD 16 = 0 THEN (* move to top 16 bits *)
        Put.CodeWord(pc, 0E3400000H + (im DIV 1000H MOD 10H * 10000H) + (regmap[a] * 1000H) + (im MOD 1000H)); INC(pc);    (* movt opcode *)
      ELSE 
        Put.CodeWord(pc,-1); INC(pc)
      END
    END;
*)    
  END WPut1;

  (* begin-procedure-description
---
**WPut1a** PutRegFromRegOpImmLargeViaRH
  end-procedure-description *)
  PROCEDURE WPut1a*(o: INTEGER; VAR pc, pcb, RH: LONGINT; op, a, b, im: LONGINT);
  BEGIN (*same as RPut1, but with range test  -100H <= im < 100H*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    IF (im >= -100H) & (im <= 0FFH) THEN cPut1(o, pc, pcb, op, a, b, im);
    ELSE 
      Put.CodeWord(pc, 0E3000000H + (regmap[a] * 1000H) + (im DIV 1000H MOD 10H) * 10000H + im MOD 1000H) ; INC(pc);     (* movw opcode *)
      Put.CodeWord(pc, 0E3400000H + (regmap[a] * 1000H) + (im DIV 10000000H MOD 10H) * 10000H + (im DIV 10000H MOD 1000H)) ; INC(pc);    (* movt opcode *)
      IF op MOD 16 # 0 THEN
        WPut0(pc, pcb, op, a, b, a)
      END
    END
*)
  END WPut1a;

  (* begin-procedure-description
---
**WPut2** PutRegLdStRegOffset
  end-procedure-description *)
  PROCEDURE WPut2*(VAR pc, pcb: LONGINT; op, ai, bi, off: LONGINT);
    VAR a,b:INTEGER;
  BEGIN (*emit load/store instruction*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    a:=regmap[ai];b:=regmap[bi];
    IF op = Ldr THEN
      Put.CodeWord(pc, 0E5900000H + (off MOD 1000H)  + (b * 10000H) + (a * 1000H))
    ELSIF op = Str THEN
      Put.CodeWord(pc, 0E5800000H + (off MOD 1000H)  + (b * 10000H) + (a * 1000H))
    ELSE
      Put.CodeWord(pc,0)
    END;
    INC(pc)
*)
  END WPut2;

  (* begin-procedure-description
---
**WPut3** PutBrCondOffset
  end-procedure-description *)
  PROCEDURE WPut3*(VAR pc, pcb: LONGINT; op, cond, off: LONGINT);
    VAR opc,osz,disp: INTEGER;
  BEGIN (*emit branch instruction*)
(*
    BR = 0; BLR = 1; BC = 2; BL = 3;
    MI = 0; PL = 8; EQ = 1; NE = 9; LT = 5; GE = 13; LE = 6; GT = 14;
*)
    Put.TwoByteInteger(1A00H,pc,pcb);
(*
    disp:=off;
    IF disp < 0 THEN INC(disp,-1) END;
    IF    op = BR  THEN (*via register*)
      Put.CodeWord(pc, 0E12FFF10H + regmap[off]) ; INC(pc)
    ELSIF op = BLR THEN (*via register and depositing link*)
      Put.CodeWord(pc, 0E12FFF30H + regmap[off]) ; INC(pc)
    ELSIF op = BC  THEN (*via offset from pc*)
      Put.CodeWord(pc, it3[cond] + (disp MOD 1000000H)); INC(pc)
    ELSIF op = BL  THEN (*via offset from pc and depositing link*)
      Put.CodeWord(pc, it3[cond] + 1000000H + (disp MOD 1000000H)); INC(pc)
    END;
*)
END WPut3;

  (* begin-procedure-description
---
**WHeader** prepares the code introductory sequence for a compiled module
  end-procedure-description *)
  PROCEDURE WHeader*(VAR pc, pcb, RH, entry, version: LONGINT);
  BEGIN entry := pc*4;
    IF version = 0 THEN 
      Put.CodeWord(0, 0E000H +  (((entry - 2) DIV 2) MOD 8000)  ); (* 12-bit pc-relative jump (even addresses) *)
      (* cPut1(121, pc, pcb, Mov+U, SP, SP, 07FFFH) *)
    ELSE 
      cPut1(121, pc, pcb, Sub, SP, SP, 4); aPut2(pc, pcb, Str, LNK, SP, 0)
    END
  END WHeader;



  (* begin-procedure-description
---
**setRegMap**
  end-procedure-description *)
  PROCEDURE setRegMap*;               
    VAR i : INTEGER;
  BEGIN
    FOR i:= 0 TO 15 DO regmap[i]:=i END;  
    IF OXS.ccARCH = OXS.X8664 THEN ISetTables;
    ELSIF OXS.ccARCH = OXS.ARM64 THEN ASetTables;
    ELSIF OXS.ccARCH = OXS.ARM32 THEN aSetTables;
    ELSIF OXS.ccARCH = OXS.RISCV64 THEN VSetTables;
    ELSIF OXS.ccARCH = OXS.RISCV32 THEN vSetTables
    ELSIF OXS.ccARCH = OXS.CORTEX4 THEN CSetTables;
    ELSIF OXS.ccARCH = OXS.CORTEX0 THEN cSetTables
    ELSIF OXS.ccARCH = OXS.WASM THEN WSetTables
    END
  END setRegMap;                     


BEGIN
END OXT.

