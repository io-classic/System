(* begin-module-short-description
implements processor-specific code generation.
end-module-short-description *)

(* begin-module-use-description  vim:fdm=marker fmr=(*%,%*) fdl=0 fen 
Module OXX generates the processor-specific instructions for executing an Oberon program.

end-module-use-description *)
(* begin-module-develop-description
Module OXX implements the processor-specific backends used by OXG

(C.Perkins 2020)

**OXX** is called from ORP and generates machine code various Oberon language constructs for the Oberon RISC5 architeture.

end-module-develop-description *)
MODULE OXX; (* C.Perkis 2020*)
  IMPORT SYSTEM, Files, OXT, OXS, OXB;

  
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
    

  VAR       
    code*: ARRAY maxCode OF LONGINT;
    data*: ARRAY maxTD OF LONGINT;  (*type descriptors*)
    str*: ARRAY maxStrx OF CHAR;
    fixorgP*, fixorgD*, fixorgT*: LONGINT;   (*origins of lists of locations to be fixed up by loader*)
    err: ARRAY 32 OF CHAR;
(*
    regmap: ARRAY 16 OF INTEGER; (*shuffle of registers for allocation/use*)
    it0: ARRAY 16 OF INTEGER;
    it1: ARRAY 16 OF INTEGER;
    it2: ARRAY 4 OF INTEGER;
    it3: ARRAY 16 OF INTEGER;
*)  
  
  (* begin-section-description
## ---------- Fixup Chains Updating
  end-section-description *)

  

  PROCEDURE setFixOrgP*(v: LONGINT);  
  (* begin-procedure-description
---
**setFixOrgP**
  end-procedure-description *)
  BEGIN 
    fixorgP := v
  END setFixOrgP;                     

  PROCEDURE setFixOrgD*(v: LONGINT);  
  (* begin-procedure-description
---
**setFixOrgD**
  end-procedure-description *)
  BEGIN 
    fixorgD := v
  END setFixOrgD;                     

  PROCEDURE setFixOrgT*(v: LONGINT);  
  (* begin-procedure-description
---
**setFixOrgT**
  end-procedure-description *)
  BEGIN 
    fixorgT := v
  END setFixOrgT;                     

  

  (* begin-section-description
## ---------- Utility Operations
  end-section-description *)

  (* begin-procedure-description
---
**PutCodeWord** places a word value v at location a in the code array.
  end-procedure-description *)
  PROCEDURE PutCodeWord(a,v: INTEGER);
  BEGIN
    code[a] := v;
  END PutCodeWord;

  (* begin-procedure-description
---
**Put1Byte** places a byte in in the instruction stream which is expected to have 8 zero bits at that location.
  end-procedure-description *)
  PROCEDURE Put1Byte(a: INTEGER; VAR pc, pcb: INTEGER);
    VAR b: ARRAY 4 OF INTEGER;
  BEGIN
    b[0]:=code[pc] MOD 100H; b[1]:= code[pc] DIV 100H MOD 100H; b[2]:= code[pc] DIV 10000H MOD 100H; b[3]:= code[pc] DIV 1000000H MOD 100H;
    b[pcb]:=ORD(a); code[pc]:=b[0]+b[1]*100H+b[2]*10000H+b[3]*1000000H;
    INC(pcb); IF pcb > 3 THEN pcb :=0; INC(pc) END
  END Put1Byte;

  (* begin-procedure-description
---
**Put2Bytes** places two bytes in in the instruction stream.
  end-procedure-description *)
  PROCEDURE Put2Bytes(a, b: INTEGER; VAR pc, pcb: INTEGER);
  BEGIN
    Put1Byte(a,pc,pcb);
    Put1Byte(b,pc,pcb);
  END Put2Bytes;

  (* begin-procedure-description
---
**Put3Bytes** places three bytes in in the instruction stream.
  end-procedure-description *)
  PROCEDURE Put3Bytes(a, b, c: INTEGER; VAR pc, pcb: INTEGER);
  BEGIN
    Put1Byte(a,pc,pcb);
    Put1Byte(b,pc,pcb);
    Put1Byte(c,pc,pcb);
  END Put3Bytes;

  (* begin-procedure-description
---
**Put4Bytes** places four bytes in in the instruction stream.
  end-procedure-description *)
  PROCEDURE Put4Bytes(a, b, c, d: INTEGER; VAR pc, pcb: INTEGER);
  BEGIN
    Put1Byte(a,pc,pcb);
    Put1Byte(b,pc,pcb);
    Put1Byte(c,pc,pcb);
    Put1Byte(d,pc,pcb);
  END Put4Bytes;

  (* begin-procedure-description
---
**Put2Integer** places an integer as 2 bytes in in the instruction stream.
  end-procedure-description *)
  PROCEDURE Put2Integer(i: INTEGER; VAR pc, pcb: INTEGER);
  BEGIN
    Put1Byte(i MOD 100H,pc,pcb);
    Put1Byte(i DIV 100H MOD 100H,pc,pcb);
  END Put2Integer;

  (* begin-procedure-description
---
**Put4Integer** places an integer as 4 bytes in in the instruction stream.
  end-procedure-description *)
  PROCEDURE Put4Integer(i: INTEGER; VAR pc, pcb: INTEGER);
  BEGIN
    Put1Byte(i MOD 100H,pc,pcb);
    Put1Byte(i DIV 100H MOD 100H,pc,pcb);
    Put1Byte(i DIV 10000H MOD 100H,pc,pcb);
    Put1Byte(i DIV 1000000H MOD 100H,pc,pcb);
  END Put4Integer;



  (* begin-procedure-description
---
**Init** prepares an interface for writing to the code for OXT and calls OXT to set the register map for the current architecture.
  end-procedure-description *)
  PROCEDURE Init*;               
    VAR cp : OXT.CodePlacer;
  BEGIN
    NEW(cp);
    cp.CodeWord := PutCodeWord;
    cp.OneByte := Put1Byte;
    cp.TwoBytes := Put2Bytes;
    cp.ThreeBytes := Put3Bytes;
    cp.FourBytes := Put4Bytes;
    cp.TwoByteInteger := Put2Integer;
    cp.FourByteInteger := Put4Integer;
    OXT.SetCodePlacer(cp);
    OXT.setRegMap;
  END Init;                     


  PROCEDURE fix*(at, with: LONGINT);
  BEGIN
    IF OXS.ccARCH = OXS.RISC5 THEN
       code[at] := code[at] DIV C24 * C24 + (with MOD C24);
    END
  END fix;

  PROCEDURE FixOne*(pc,pcb,at: LONGINT);
  BEGIN fix(at, pc-at-1)
  END FixOne;

  PROCEDURE FixLink*(pc,pcb,L: LONGINT);
    VAR L1: LONGINT;
  BEGIN
    IF OXS.ccARCH = OXS.RISC5 THEN
      WHILE L # 0 DO L1 := code[L] MOD 40000H; fix(L, pc-L-1); L := L1 END
    END
  END FixLink;

  PROCEDURE FixLinkWith*(L0, dst: LONGINT);
    VAR L1: LONGINT;
  BEGIN
    IF OXS.ccARCH = OXS.RISC5 THEN
      WHILE L0 # 0 DO
        L1 := code[L0] MOD C24;
        code[L0] := code[L0] DIV C24 * C24 + ((dst - L0 - 1) MOD C24); L0 := L1;
      END
    END
  END FixLinkWith;

  PROCEDURE merged*(L0, L1: LONGINT): LONGINT;
    VAR L2, L3: LONGINT;
  BEGIN
    IF OXS.ccARCH = OXS.RISC5 THEN
      IF L0 # 0 THEN L3 := L0;
        REPEAT L2 := L3; L3 := code[L2] MOD 40000H UNTIL L3 = 0;
        code[L2] := code[L2] + L1; L1 := L0;
      END ;
    END ;
    RETURN L1
  END merged;


  (* begin-procedure-description
---
**MakeStringItem** prepares
  end-procedure-description *)
  PROCEDURE InternString*(VAR strx: LONGINT; len: LONGINT); (*copies string from OXS-buffer to OXG-string array*)
    VAR i: LONGINT;
  BEGIN i := 0;
    IF strx + len + 4 < maxStrx THEN
      WHILE len > 0 DO str[strx] := OXS.str[i]; INC(strx); INC(i); DEC(len) END ;
      WHILE strx MOD 4 # 0 DO str[strx] := 0X; INC(strx) END
    ELSE OXS.Mark("too many strings")
    END
  END InternString;


  (* begin-procedure-description
---
**SetCode** prepares
  end-procedure-description *)
  PROCEDURE SetCode*(i,v: LONGINT);
  BEGIN code[i]:=v
  END SetCode;

  (* begin-procedure-description
---
**SetData** prepares
  end-procedure-description *)
  PROCEDURE SetData*(i,v: LONGINT);
  BEGIN data[i]:=v
  END SetData;


  (* begin-procedure-description
---
**NofPtrs** determines the number of Garbage Collection Roots.
  end-procedure-description *)
  PROCEDURE NofPtrs(typ: OXB.Type): LONGINT;
    VAR fld: OXB.Object; n: LONGINT;
  BEGIN
    IF (typ.form = OXB.Pointer) OR (typ.form = OXB.NilTyp) THEN n := 1
    ELSIF typ.form = OXB.Record THEN
      fld := typ.dsc; n := 0;
      WHILE fld # NIL DO n := NofPtrs(fld.type) + n; fld := fld.next END
    ELSIF typ.form = OXB.Array THEN n := NofPtrs(typ.base) * typ.len
    ELSE n := 0
    END ;
    RETURN n
  END NofPtrs;

  (* begin-procedure-description
---
**FindPtrs** locates Garbage Collection roots.
  end-procedure-description *)
  PROCEDURE FindPtrs(VAR R: Files.Rider; typ: OXB.Type; adr: LONGINT);
    VAR fld: OXB.Object; i, s: LONGINT;
  BEGIN
    IF (typ.form = OXB.Pointer) OR (typ.form = OXB.NilTyp) THEN Files.WriteInt(R, adr)
    ELSIF typ.form = OXB.Record THEN
      fld := typ.dsc;
      WHILE fld # NIL DO FindPtrs(R, fld.type, fld.val + adr); fld := fld.next END
    ELSIF typ.form = OXB.Array THEN
      s := typ.base.size;
      FOR i := 0 TO typ.len-1 DO FindPtrs(R, typ.base, i*s + adr) END
    END
  END FindPtrs;


  (* begin-procedure-description
---
**Close** writes the completed binary to disk.
  end-procedure-description *)
  PROCEDURE Close*(VAR pc, pcb: LONGINT; 
                   VAR modid: OXS.Ident; 
                   key, nofent, entry: LONGINT; 
                   version, varsize, tdx, strx: INTEGER);
    VAR obj: OXB.Object;
      i, t, comsize, nofimps, nofptrs, size: LONGINT;
      name: OXS.Ident;
      F: Files.File; R: Files.Rider;
  BEGIN  
    IF version = 0 THEN (* baremetal module exit code - branch to reset vector via register 0*)
      IF OXS.ccARCH = OXS.RISC5 THEN OXT.RPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.RPut3(pc, pcb, BR, 7, 0)   END;
      IF OXS.ccARCH = OXS.X8664 THEN OXT.IPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.IPut3(pc, pcb, BR, 7, 0)   END;
      IF OXS.ccARCH = OXS.ARM64 THEN OXT.APut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.APut3(pc, pcb, BR, 7, 0)   END;
      IF OXS.ccARCH = OXS.ARM32 THEN OXT.aPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.aPut3(pc, pcb, BR, 7, 0)   END;
      IF OXS.ccARCH = OXS.CORTEX4 THEN OXT.CPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.CPut3(pc, pcb, BR, 7, 0)   END;
      IF OXS.ccARCH = OXS.CORTEX0 THEN OXT.cPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.cPut3(pc, pcb, BR, 7, 0)   END;
      IF OXS.ccARCH = OXS.RISCV64 THEN OXT.VPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.VPut3(pc, pcb, BR, 7, 0) END;
      IF OXS.ccARCH = OXS.RISCV32 THEN OXT.vPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.vPut3(pc, pcb, BR, 7, 0) END;
      IF OXS.ccARCH = OXS.WASM THEN OXT.WPut1(3,  pc, pcb, Mov, 0, 0, 0); OXT.WPut3(pc, pcb, BR, 7, 0) END;
    ELSE (* regular module exit code *)
      IF OXS.ccARCH = OXS.RISC5 THEN OXT.RPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.RPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.RPut3(pc, pcb, BR, 7, LNK)   END;
      IF OXS.ccARCH = OXS.X8664 THEN OXT.IPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.IPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.IPut3(pc, pcb, BR, 7, LNK)   END;
      IF OXS.ccARCH = OXS.ARM64 THEN OXT.APut2(pc, pcb, Ldr, LNK, SP, 0); OXT.APut1(4,  pc, pcb, Add, SP, SP, 4); OXT.APut3(pc, pcb, BR, 7, LNK)   END;
      IF OXS.ccARCH = OXS.ARM32 THEN OXT.aPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.aPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.aPut3(pc, pcb, BR, 7, LNK)   END;
      IF OXS.ccARCH = OXS.CORTEX4 THEN OXT.CPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.CPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.CPut3(pc, pcb, BR, 7, LNK)   END;
      IF OXS.ccARCH = OXS.CORTEX0 THEN OXT.cPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.cPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.cPut3(pc, pcb, BR, 7, LNK)   END;
      IF OXS.ccARCH = OXS.RISCV64 THEN OXT.VPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.VPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.VPut3(pc, pcb, BR, 7, LNK) END;
      IF OXS.ccARCH = OXS.RISCV32 THEN OXT.vPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.vPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.vPut3(pc, pcb, BR, 7, LNK) END;
      IF OXS.ccARCH = OXS.WASM THEN OXT.WPut2(pc, pcb, Ldr, LNK, SP, 0); OXT.WPut1(4,  pc, pcb, Add, SP, SP, 4); OXT.WPut3(pc, pcb, BR, 7, LNK) END;
    END ;
(*
    IF version = 0 THEN (* Initial jump to entry point for baremetal module *)
      IF OXS.ccARCH = OXS.RISC5 THEN   END;
      IF OXS.ccARCH = OXS.X8664 THEN code[0] := 0E9H + ((entry -5) * 100H); code[1] := 90909000H  END; (* 32-bit pc-relative jump *)
      IF OXS.ccARCH = OXS.ARM64 THEN code[0] := (14H * 1000000H) + (entry DIV 4) END; (* 24-bit pc-relative jump *)
      IF OXS.ccARCH = OXS.ARM32 THEN code[0] := 0EAH * 1000000H  + (entry - 8) DIV 4 END; (* 24-bit pc-relative jump *)
      IF OXS.ccARCH = OXS.CORTEX4 THEN code[0] := (14H * 1000000H) + (entry DIV 4) END; (* 24-bit pc-relative jump *)
      IF OXS.ccARCH = OXS.CORTEX0 THEN code[0] := 0EAH * 1000000H  + (entry - 8) DIV 4 END; (* 24-bit pc-relative jump *)
      IF OXS.ccARCH = OXS.RISCV64 THEN code[0] := 6FH + (vUJ(entry) * 1000H) END;
      IF OXS.ccARCH = OXS.RISCV32 THEN code[0] := 6FH + (vUJ(entry) * 1000H) END;
      IF OXS.ccARCH = OXS.WASM THEN code[0] := 6FH + (vUJ(entry) * 1000H) END;
    END;
*)
    obj := OXB.topScope.next; nofimps := 0; comsize := 4; nofptrs := 0;
    WHILE obj # NIL DO
      IF (obj.class = OXB.Mod) & (obj.dsc # OXB.system) THEN INC(nofimps) (*count imports*)
      ELSIF (* (obj.exno # 0) & *) (obj.class = OXB.Const) & (obj.type.form = OXB.Proc)
         (* & (obj.type.nofpar = 0) *) &  (obj.type.base = OXB.noType) THEN (*count commands*)
        i := 0;  WHILE obj.name[i] # 0X DO INC(i) END ;
        i := (i+4) DIV 4 * 4; INC(comsize, i+8)
      ELSIF obj.class = OXB.Var THEN INC(nofptrs, NofPtrs(obj.type))  (*count pointers*)
      END ;
      obj := obj.next
    END ;
    INC(comsize, 12); (* BEGIN entry *)

    size := varsize + strx + comsize + (pc + nofimps + nofent + nofptrs + 1)*4;  (*varsize includes type descriptors*)
     
    IF OXS.ccARCH = OXS.RISC5 THEN OXB.MakeFileName(name, modid, ".rsc")   END;
    IF OXS.ccARCH = OXS.X8664 THEN OXB.MakeFileName(name, modid, ".i64")   END;
    IF OXS.ccARCH = OXS.ARM64 THEN OXB.MakeFileName(name, modid, ".a64")   END;
    IF OXS.ccARCH = OXS.ARM32 THEN OXB.MakeFileName(name, modid, ".a32")   END;
    IF OXS.ccARCH = OXS.CORTEX4 THEN OXB.MakeFileName(name, modid, ".cm4")   END;
    IF OXS.ccARCH = OXS.CORTEX0 THEN OXB.MakeFileName(name, modid, ".cm0")   END;
    IF OXS.ccARCH = OXS.RISCV64 THEN OXB.MakeFileName(name, modid, ".v64") END;
    IF OXS.ccARCH = OXS.RISCV32 THEN OXB.MakeFileName(name, modid, ".v32") END;
    IF OXS.ccARCH = OXS.WASM THEN OXB.MakeFileName(name, modid, ".w64") END;

    F := Files.New(name); Files.Set(R, F, 0); 
    IF version = 1 THEN
      Files.WriteString(R, modid);
      Files.WriteInt(R, key);
      Files.Write(R, CHR(version));
      Files.WriteInt(R, size);
      obj := OXB.topScope.next;
      WHILE (obj # NIL) & (obj.class = OXB.Mod) DO  (*imports*)
        IF obj.dsc # OXB.system THEN Files.WriteString(R, obj(OXB.Module).orgname); Files.WriteInt(R, obj.val) END ;
        obj := obj.next
      END ;
      Files.Write(R, 0X);
      Files.WriteInt(R, tdx*4);
      i := 0;
      WHILE i < tdx DO Files.WriteInt(R, data[i]); INC(i) END ; (*type descriptors*)
      Files.WriteInt(R, varsize - tdx*4);  (*data*)
      Files.WriteInt(R, strx);
      FOR i := 0 TO strx-1 DO Files.Write(R, str[i]) END ;  (*strings*)
      Files.WriteInt(R, pc);  (*code len*)
    ELSE

      (* do the equivalent of the above for a binary Oberon-0 program *)

    END;

    FOR i := 0 TO pc-1 DO Files.WriteInt(R, code[i]) END ;  (*program*)
    obj := OXB.topScope.next;

    IF version = 1 THEN
      WHILE obj # NIL DO  (*procedure names list. commands are procedures that are public with no parameters*)
        IF (* (obj.exno # 0) & *) (obj.class = OXB.Const) & (obj.type.form = OXB.Proc) &
            (* (obj.type.nofpar = 0) & *) (obj.type.base = OXB.noType) THEN
          Files.WriteString(R, obj.name); 
          IF obj.type.nofpar = 0 THEN  t:=0 (*command*) ELSE t:=1 (* not a command *) END;
          IF obj.exno = 0 THEN  INC(t,2) (*private*) END; (* otherwise public *)
	  Files.WriteInt(R, obj.val+t);
(*          Files.WriteInt(R, obj.val2); (* frame size *) *)
        END ;
        obj := obj.next
      END ;
      Files.WriteString(R, "BEGIN");
      Files.WriteInt(R, entry+2);
      Files.WriteInt(R, 4); 

      Files.Write(R, 0X);
      Files.WriteInt(R, nofent); Files.WriteInt(R, entry);
      obj := OXB.topScope.next;
      WHILE obj # NIL DO  (*entries*)
        IF obj.exno # 0 THEN
          IF (obj.class = OXB.Const) & (obj.type.form = OXB.Proc) OR (obj.class = OXB.Var) THEN
            Files.WriteInt(R, obj.val);
          ELSIF obj.class = OXB.Typ THEN
            IF obj.type.form = OXB.Record THEN Files.WriteInt(R,  obj.type.len MOD 10000H)
            ELSIF (obj.type.form = OXB.Pointer) & ((obj.type.base.typobj = NIL) OR (obj.type.base.typobj.exno = 0)) THEN
              Files.WriteInt(R,  obj.type.base.len MOD 10000H)
            END
          END
        END ;
        obj := obj.next
      END ;
      obj := OXB.topScope.next;
      WHILE obj # NIL DO  (*pointer variables*)
        IF obj.class = OXB.Var THEN FindPtrs(R, obj.type, obj.val) END ;
        obj := obj.next
      END ;
      Files.WriteInt(R, -1);
      Files.WriteInt(R, fixorgP); Files.WriteInt(R, fixorgD); Files.WriteInt(R, fixorgT); Files.WriteInt(R, entry);
      Files.Write(R, "O"); Files.Register(F)
    ELSE
    (* do the equivalent for a binary Oberon-0 program *)
      Files.Register(F)
    END
  END Close;



BEGIN
END OXX.

