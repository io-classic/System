(* begin-module-use-description
Module OIDisDecode decodes an x86_64 instruction.
    
end-module-use-description *)
(* begin-module-develop-description
    
(CP 2020)
    
**OIDisDecode** decodes an x86_64 instructions for the OIDis disassembler.
Rewritten from pymsasid3 (matthieu.kaczmarek@mines-nancy.org) which was rewritten from udis86 (Vivek Mohan <vivek@sig9.com>)
    
The module performs the opcode decoding.
    
end-module-develop-description *)
MODULE OIDisDecode;   (*CP 2020*)
  IMPORT SYSTEM, C:=OIDisOpcodes, S:=OToolState, I:=OIDisItab, O:=OIDisOperand;
    
  CONST

  TYPE

  VAR
    ie*: I.itabEntryDesc;
    havePfx*: BOOLEAN;
    pfxrex*: BYTE;
    pfxseg*: BYTE;
    pfxadr*: BYTE;
    pfxlock*: BYTE;
    pfxinsn*: BYTE;
    pfxopr*: BYTE;
    pfxrepne*: BYTE;
    pfxrep*: BYTE;
    pfxrepe*: BYTE;

    adrmode*: BYTE;

    oprmode*: INTEGER;
    (* dismode --> S.mode *)

  PROCEDURE pC0(n: INTEGER): INTEGER;
  BEGIN
    RETURN n MOD 1
  END pC0;

  PROCEDURE pREXB(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 2) MOD 1
  END pREXB;

  PROCEDURE pDEPM(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 4) MOD 1
  END pDEPM;

  PROCEDURE pC2(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 8) MOD 1
  END pC2;

  PROCEDURE pINV64(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 16) MOD 1
  END pINV64;

  PROCEDURE pREXW(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 32) MOD 1
  END pREXW;

  PROCEDURE pC1(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 64) MOD 1
  END pC1;

  PROCEDURE pDEF64(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 128) MOD 1
  END pDEF64;

  PROCEDURE pREXR(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 256) MOD 1
  END pREXR;

  PROCEDURE pOSO(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 512) MOD 1
  END pOSO;

  PROCEDURE pASO(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 1024) MOD 1
  END pASO;

  PROCEDURE pREXX(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 2048) MOD 1
  END pREXX;

  PROCEDURE pIMPADDR(n: INTEGER): INTEGER;
  BEGIN
    RETURN (n DIV 4096) MOD 1
  END pIMPADDR;

  PROCEDURE REXW(r: BYTE): BYTE;
  BEGIN
    RETURN (r MOD 10H) DIV 8
  END REXW;

  PROCEDURE REXR(r: INTEGER): INTEGER;
  BEGIN
    RETURN (r MOD 8H) DIV 4
  END REXR;

  PROCEDURE REXX(r: INTEGER): INTEGER;
  BEGIN
    RETURN (r MOD 4H) DIV 2
  END REXX;

  PROCEDURE REXB(r: INTEGER): INTEGER;
  BEGIN
    RETURN r MOD 2H
  END REXB;

  PROCEDURE REXPFXMASK(n: INTEGER): INTEGER;
  BEGIN
    RETURN ((pREXW(n) * 8) +
            (pREXR(n) * 4) +
            (pREXX(n) * 2) +
            pREXB(n))
  END REXPFXMASK;

  (* Extracts instruction prefixes. *)
  PROCEDURE getPrefixes(): INTEGER;
    VAR e,i: INTEGER; curr: BYTE; havePfx: BOOLEAN;
  BEGIN
    e:=S.OK;

    havePfx := TRUE;
    i := 0;
    S.setisz(0);

    WHILE havePfx DO
      curr:=ORD(S.Rbyte(S.pc));

      (*  # rex prefixes in 64bit mode *)

      IF (S.mode = 64) & ((curr DIV 10H MOD 10H) = 4) THEN
            pfxrex := curr; S.movepc(1); S.setibytes(S.isz, curr); S.setisz(S.isz+1);
      ELSE
            havePfx := FALSE;
            IF curr = 2EH THEN pfxseg := ORD("c"); pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 36H THEN pfxseg := ORD("s"); pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 3EH THEN pfxseg := ORD("d"); pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 26H THEN pfxseg := ORD("e"); pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 64H THEN pfxseg := ORD("f"); pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 65H THEN pfxseg := ORD("g"); pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 67H THEN pfxadr := 67H; pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 0F0H THEN pfxlock := 0F0H; pfxrex  := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 66H THEN IF pfxinsn = 0 THEN pfxinsn := 66H; pfxopr := 66H; pfxrex := 0 END; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 0F2H THEN pfxinsn := 0F2H; pfxrepne := 0F2H; pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
            IF curr = 0F3H THEN pfxinsn := 0F3H; pfxrep  := 0F3H; pfxrepe := 0F3H; pfxrex := 0; havePfx := TRUE; S.movepc(1);S.setibytes(S.isz, curr); S.setisz(S.isz+1); END;
      END
    END;

(*
    # speculatively determine the effective operand mode,
    # based on the prefixes and the current disassembly
    # mode. This may be inaccurate, but useful for mode
    # dependent decoding.
*)
    IF S.mode = 64 THEN
        IF REXW(pfxrex) # 0 THEN oprmode := 64 
        ELSIF pfxopr # 0 THEN oprmode := 16
(*      ELSIF O.PDEF64( inst.itab_entry.prefix ) # 0 THEN oprmode := 64 *)
        ELSE oprmode := 32 END;
        IF pfxadr # 0 THEN adrmode := 32
        ELSE adrmode := 64 END;
    END;
    IF S.mode = 32 THEN
        IF pfxopr # 0 THEN oprmode := 16
        ELSE oprmode := 32 END;
        IF pfxadr # 0 THEN adrmode := 16 
        ELSE adrmode := 32 END
    END;
    IF S.mode = 16 THEN
        IF pfxopr # 0 THEN oprmode := 32
        ELSE oprmode := 16;
        IF pfxadr # 0 THEN adrmode := 32 
        ELSE adrmode := 16 END
    END;
  END;
  RETURN e
  END getPrefixes;



  (* Searches the instruction tables for the right entry. *)
  PROCEDURE searchItab(): INTEGER;
    VAR e: INTEGER; curr, index: BYTE; itabo, itabe: INTEGER; done: BOOLEAN;
  BEGIN
    done := FALSE;
    ie.operator := C.undetermined;
    
    e := S.OK;
    curr:=ORD(S.Rbyte(S.pc)); S.movepc(1); S.setibytes(S.isz, curr); S.setisz(S.isz+1);

    (* resolve xchg, nop, pause crazyness *)
    IF 90H = curr THEN
        IF ~((S.mode = 64) & (REXB(pfxrex)#0)) THEN
            IF pfxrep # 0 THEN pfxrep := 0; ie := I.iTable[I.ipause] ELSE ie := I.iTable[I.inop] END;
            done := TRUE;
        END

    (* get top-level table *)
    ELSIF 0FH = curr THEN
(*
        table = ITAB__0F
        curr  = u.input.next()
        if u.error:
            return -1
        # 2byte opcodes can be modified by 0x66, F3, and F2 prefixes
        if 0x66 == inst.pfx.insn:
            if itab_list[ITAB__PFX_SSE66__0F][curr].operator != C.invalid:
                table = ITAB__PFX_SSE66__0F
                inst.pfx.opr = 0
        elif 0xF2 == inst.pfx.insn:
            if itab_list[ITAB__PFX_SSEF2__0F][curr].operator != C.invalid:
                table = ITAB__PFX_SSEF2__0F
                inst.pfx.repne = 0
        elif 0xF3 == inst.pfx.insn:
            if itab_list[ITAB__PFX_SSEF3__0F][curr].operator != C.invalid:
                table = ITAB__PFX_SSEF3__0F
                inst.pfx.repe = 0
                inst.pfx.rep  = 0
*)
    (* pick an instruction from the 1byte table *)
    ELSE
      itabo := I.i1byte;
      
      (* table = ITAB__1BYTE  *)
    END;
    IF ~ done THEN

      index := curr;

      WHILE ~ done DO 
        ie := I.iTable[ itabo + index ]; 

        (* if operator constant is a standard instruction constant our search is over. *)
        
        IF ie.operator = C.invalid THEN
          done := TRUE
        ELSE
(*
          table = e.prefix
*)      
          IF ie.operator =  C.grpreg THEN (* peek? *)
              itabo := ie.prefix;
              curr  := ORD(S.Rbyte(S.pc));
              index := O.MODRMREG(curr)
          ELSIF ie.operator =  C.grpmod THEN (* peek? *)
              itabo := ie.prefix;
              curr  := ORD(S.Rbyte(S.pc));
              index := O.MODRMMOD(curr);
              IF index = 3 THEN
                  index := I.ItabModIndx11;
              ELSE
                  index := I.ItabModIndxNOT11;
              END
          ELSIF ie.operator =  C.grprm THEN  (* no peek? *)
              itabo := ie.prefix;
              curr  := ORD(S.Rbyte(S.pc));
              index := O.MODRMRM(curr)
      
          ELSIF ie.operator =  C.grpx87 THEN  (* no peek? *)
              itabo := ie.prefix;
              curr  := ORD(S.Rbyte(S.pc));
              index := curr - 0C0H
      
          ELSIF ie.operator =  C.grposize THEN
              itabo := ie.prefix;
              IF S.mode = 64 THEN
                  index := I.ItabModeIndx64
              ELSIF S.mode = 32 THEN 
                  index := I.ItabModeIndx32
              ELSE
                  index := I.ItabModeIndx16
              END
          ELSIF ie.operator =  C.grpasize THEN
              itabo := ie.prefix;
              IF S.mode = 64 THEN
                  index := I.ItabModeIndx64
              ELSIF S.mode = 32 THEN 
                  index := I.ItabModeIndx32
              ELSE
                  index := I.ItabModeIndx16
              END
          ELSIF ie.operator =  C.grpmode THEN
              itabo := ie.prefix;
              IF S.mode = 64 THEN
                  index := I.ItabModeIndx64
              ELSIF S.mode = 32 THEN
                  index := I.ItabModeIndx32
              ELSE
                  index := I.ItabModeIndx16
              END
          ELSIF ie.operator =  C.grpv THEN
              itabo := ie.prefix;
              IF S.vendor = O.INTEL THEN
                  index := I.ItabVendorIndxINTEL
              ELSIF S.vendor = O.AMD THEN
                  index := I.ItabVendorIndxAMD
              ELSE
                  
              END
          
              
          ELSE
              
          END;
      
        END;
        done := TRUE;
      END
    END
  RETURN e
  END searchItab;


  PROCEDURE resolveOperandSize( s: INTEGER): INTEGER;
  BEGIN
(*
    if s ==  SZ_V:
        return inst.opr_mode
    elif s ==  SZ_Z:  
        if inst.opr_mode == 16:
            return 16
        else:
            return 32
    elif s ==  SZ_P:  
        if inst.opr_mode == 16:
            return SZ_WP
        else:
            return SZ_DP
    elif s ==  SZ_MDQ:
        if inst.opr_mode == 16:
            return 32
        else:
            return inst.opr_mode
    elif s ==  SZ_RDQ:
        if u.dis_mode == 64:
            return 64
        else:
            return 32
    else:
        return s
*)
  RETURN s
  END resolveOperandSize;


  PROCEDURE resolveOperator(): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e:=S.OK;
(*
    # far/near flags 
    inst.branch_dist = None
    # readjust operand sizes for call/jmp instrcutions 
    if inst.operator == 'call' or inst.operator == 'jmp':
        # WP: 16bit pointer 
        if inst.operand[0].size == SZ_WP:
            inst.operand[0].size = 16
            inst.branch_dist = 'far'
        # DP: 32bit pointer
        elif inst.operand[0].size == SZ_DP:
            inst.operand[0].size = 32
            inst.branch_dist = 'far'
        elif inst.operand[0].size == 8:
            inst.branch_dist = 'near'
    # resolve 3dnow weirdness 
    elif inst.operator == '3dnow': 
        inst.operator = itab_list[ITAB__3DNOW][u.input.current()].operator
    # SWAPGS is only valid in 64bits mode
    if inst.operator == 'swapgs' and u.dis_mode != 64:
        u.error = 1
        return -1
    return 0
*)
  RETURN e
  END resolveOperator;

(*
def decode_a(u, inst, op):
    """Decodes operands of the type seg:offset."""
    if inst.opr_mode == 16:  
        # seg16:off16 
        op.type = 'OP_PTR'
        op.size = 32
        op.lval = Ptr(u.input.read(16), u.input.read(16))
    else:
        # seg16:off32 
        op.type = 'OP_PTR'
        op.size = 48
        op.lval = Ptr(u.input.read(32), u.input.read(16))

def decode_gpr(u, inst, s, rm):
    """Returns decoded General Purpose Register."""
    s = resolve_operand_size(u, inst, s)
          
    if s == 64:
        return GPR[64][rm]
    elif s == SZ_DP or s == 32:
        return GPR[32][rm]
    elif s == SZ_WP or s == 16:
        return GPR[16][rm]
    elif s ==  8:
        if u.dis_mode == 64 and inst.pfx.rex:
            return GPR[8][1][rm]
        else: 
            return GPR[8][0][rm]
    else:
        return None

def resolve_gpr64(u, inst, gpr_op):
    """64bit General Purpose Register-Selection."""
    if gpr_op in  range(OP_rAXr8, OP_rDIr15 + 1) :
        index = (gpr_op - OP_rAXr8) |(REX_B(inst.pfx.rex) << 3)          
    else:
        index = gpr_op - OP_rAX
    if inst.opr_mode == 16:
        return GPR[16][index]
    elif u.dis_mode == 32 or (inst.opr_mode == 32 and REX_W(inst.pfx.rex) == 0):
        return GPR[32][index]
    return GPR[64][index]

def resolve_gpr32(u, inst, gpr_op):
    """32bit General Purpose Register-Selection."""
    index = gpr_op - OP_eAX
    if(inst.opr_mode == 16):
        return GPR[16][index]
    return GPR[32][index]

def resolve_reg(regtype, i):
    """Resolves the register type."""
    return GPR[regtype][i]

def decode_imm(u, inst, s, op):
    """Decodes Immediate values."""
    op.size = resolve_operand_size(u, inst, s)
    op.type = 'OP_IMM'
    op.lval = u.input.read(op.size) 

def decode_modrm(u, inst, op, s, rm_type, opreg, reg_size, reg_type):
    """Decodes ModRM Byte."""
    u.input.next()

    # get mod, r/m and reg fields
    mod = MODRM_MOD(u.input.current())
    rm  = (REX_B(inst.pfx.rex) << 3) | MODRM_RM(u.input.current())
    reg = (REX_R(inst.pfx.rex) << 3) | MODRM_REG(u.input.current())

    op.size = resolve_operand_size(u, inst, s)

    # if mod is 11b, then the m specifies a gpr/mmx/sse/control/debug 
    if mod == 3:
        op.type = 'OP_REG'
        if rm_type ==  'T_GPR':
            op.base = decode_gpr(u, inst, op.size, rm)
        else:   
            op.base = resolve_reg(rm_type, (REX_B(inst.pfx.rex) << 3) |(rm&7))

    # else its memory addressing 
    else: 
        op.type = 'OP_MEM'
        op.seg = inst.pfx.seg
        # 64bit addressing 
        if inst.adr_mode == 64:

            op.base = GPR[64][rm]

            # get offset type
            if mod == 1:
                op.offset = 8
            elif mod == 2:
                op.offset = 32
            elif mod == 0 and(rm & 7) == 5:          
                op.base = 'rip'
                op.offset = 32
            else:
                op.offset = 0

            # Scale-Index-Base(SIB)
            if rm & 7 == 4:
                u.input.next()
                
                op.scale = (1 << SIB_S(u.input.current())) & ~1
                op.index = GPR[64][(SIB_I(u.input.current()) |(REX_X(inst.pfx.rex) << 3))]
                op.base  = GPR[64][(SIB_B(u.input.current()) |(REX_B(inst.pfx.rex) << 3))]

                # special conditions for base reference
                if op.index == 'rsp':
                    op.index = None
                    op.scale = 0

                if op.base == 'rbp' or op.base == 'r13':
                    if mod == 0: 
                        op.base = None
                    if mod == 1:
                        op.offset = 8
                    else:
                        op.offset = 32

        # 32-Bit addressing mode 
        elif inst.adr_mode == 32:

            # get base 
            op.base = GPR[16][rm]

            # get offset type 
            if mod == 1:
                op.offset = 8
            elif mod == 2:
                op.offset = 32
            elif mod == 0 and rm == 5:
                op.base = None
                op.offset = 32
            else:
                op.offset = 0

            # Scale-Index-Base(SIB)
            if(rm & 7) == 4:
                u.input.next()

                op.scale = (1 << SIB_S(u.input.current())) & ~1
                op.index = GPR[32][SIB_I(u.input.current()) |(REX_X(inst.pfx.rex) << 3)]
                op.base  = GPR[32][SIB_B(u.input.current()) |(REX_B(inst.pfx.rex) << 3)]

                if op.index == 'esp':
                    op.index = None
                    op.scale = 0

                # special condition for base reference 
                if op.base == 'ebp':
                    if mod == 0:
                        op.base = None
                    if mod == 1:
                        op.offset = 8
                    else:
                        op.offset = 32

        # 16bit addressing mode 
        else:
            if rm == 0: 
                op.base = 'bx'
                op.index = 'si'
            elif rm == 1: 
                op.base = 'bx'
                op.index = 'di'
            elif rm == 2: 
                op.base = 'bp'
                op.index = 'si'
            elif rm == 3: 
                op.base = 'bp'
                op.index = 'di'
            elif rm == 4: 
                op.base = 'si'
            elif rm == 5: 
                op.base = 'di'
            elif rm == 6: 
                op.base = 'bp'
            elif rm == 7: 
                op.base = 'bx'
                
            if mod == 0 and rm == 6:
                op.offset = 16
                op.base = None
            elif mod == 1:
                op.offset = 8
            elif mod == 2: 
                op.offset = 16

    # extract offset, if any 
    if op.offset in [8, 16, 32, 64]: 
        op.lval  = u.input.read(op.offset)
        bound = pow(2, op.offset - 1)
        if op.lval >= bound:
            op.lval = -(2 * bound - op.lval)

    # resolve register encoded in reg field
    if opreg:
        opreg.type = 'OP_REG'
        opreg.size = resolve_operand_size(u, inst, reg_size)
        if reg_type == 'T_GPR': 
            opreg.base = decode_gpr(u, inst, opreg.size, reg)
        else:
            opreg.base = resolve_reg(reg_type, reg)

def decode_o(u, inst, s, op):
    """Decodes offset."""
    op.seg = inst.pfx.seg
    op.offset = inst.adr_mode 
    op.lval = u.input.read(inst.adr_mode) 
    op.type = 'OP_MEM'
    op.size = resolve_operand_size(u, inst, s)
*)


  PROCEDURE disasmOperands(): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e:=S.OK;
(*
    """Disassembles Operands."""
    # get type
    def get_mopt(x): return x.type
    mopt = list(map(get_mopt, inst.itab_entry.operand))
    # get size
    def get_mops(x): return x.size
    mops = list(map(get_mops, inst.itab_entry.operand))

    if mopt[2] != OP_NONE:
        inst.operand = [Operand(), Operand(), Operand()]
    elif mopt[1] != OP_NONE:
        inst.operand = [Operand(), Operand()] 
    elif mopt[0] != OP_NONE:
        inst.operand = [Operand()]
    
    # These flags determine which operand to apply the operand size
    # cast to.
    cast = [P_C0, P_C1, P_C2]
    for i in range(len(inst.operand)):
        inst.operand[i].cast = cast[i](inst.itab_entry.prefix)

    # iop = instruction operand 
    #iop = inst.operand
        
    if mopt[0] == OP_A:
        decode_a(u, inst, inst.operand[0])    
    # M[b] ... 
    # E, G/P/V/I/CL/1/S 
    elif mopt[0] == OP_M or mopt[0] == OP_E:
        if mopt[0] == OP_M and MODRM_MOD(u.input.peek()) == 3:
            u.error = 1
        if mopt[1] == OP_G:
            decode_modrm(u, inst, inst.operand[0], mops[0], 'T_GPR', inst.operand[1], mops[1], 'T_GPR')
            if mopt[2] == OP_I:
                decode_imm(u, inst, mops[2], inst.operand[2])
            elif mopt[2] == OP_CL:
                inst.operand[2].type = 'OP_REG'
                inst.operand[2].base = 'cl'
                inst.operand[2].size = 8
        elif mopt[1] == OP_P:
            decode_modrm(u, inst, inst.operand[0], mops[0], 'T_GPR', inst.operand[1], mops[1], 'T_MMX')
        elif mopt[1] == OP_V:
            decode_modrm(u, inst, inst.operand[0], mops[0], 'T_GPR', inst.operand[1], mops[1], 'T_XMM')
        elif mopt[1] == OP_S:
            decode_modrm(u, inst, inst.operand[0], mops[0], 'T_GPR', inst.operand[1], mops[1], 'T_SEG')
        else:
            decode_modrm(u, inst, inst.operand[0], mops[0], 'T_GPR', NULL, 0, 'T_NONE')
            if mopt[1] == OP_CL:
                inst.operand[1].type = 'OP_REG'
                inst.operand[1].base = 'cl'
                inst.operand[1].size = 8
            elif mopt[1] == OP_I1:
                inst.operand[1].type = 'OP_IMM'
                inst.operand[1].lval = 1
            elif mopt[1] == OP_I:
                decode_imm(u, inst, mops[1], inst.operand[1])

    # G, E/PR[,I]/VR 
    elif mopt[0] == OP_G:
        if mopt[1] == OP_M:
            if MODRM_MOD(u.input.peek()) == 3:
                u.error = 1
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_GPR')
        elif mopt[1] == OP_E:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_GPR')
            if mopt[2] == OP_I:
                decode_imm(u, inst, mops[2], inst.operand[2])
        elif mopt[1] == OP_PR:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_MMX', inst.operand[0], mops[0], 'T_GPR')
            if mopt[2] == OP_I:
                decode_imm(u, inst, mops[2], inst.operand[2])
        elif mopt[1] == OP_VR:
            if MODRM_MOD(u.input.peek()) != 3:
                u.error = 1
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_XMM', inst.operand[0], mops[0], 'T_GPR')
        elif mopt[1] == OP_W:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_XMM', inst.operand[0], mops[0], 'T_GPR')

    # AL..BH, I/O/DX 
    elif mopt[0] in [OP_AL, OP_CL, OP_DL, OP_BL,
                   OP_AH, OP_CH, OP_DH, OP_BH]:
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = GPR[8][0][mopt[0] - OP_AL]
        inst.operand[0].size = 8

        if mopt[1] == OP_I:
            decode_imm(u, inst, mops[1], inst.operand[1])
        elif mopt[1] == OP_DX:
            inst.operand[1].type = 'OP_REG'
            inst.operand[1].base = 'dx'
            inst.operand[1].size = 16
        elif mopt[1] == OP_O:
            decode_o(u, inst, mops[1], inst.operand[1])

    # rAX[r8]..rDI[r15], I/rAX..rDI/O
    elif mopt[0] in [OP_rAXr8, OP_rCXr9, OP_rDXr10, OP_rBXr11,
                   OP_rSPr12, OP_rBPr13, OP_rSIr14, OP_rDIr15,
                   OP_rAX, OP_rCX, OP_rDX, OP_rBX,
                   OP_rSP, OP_rBP, OP_rSI, OP_rDI]:
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = resolve_gpr64(u, inst, mopt[0])

        if mopt[1] == OP_I:
            decode_imm(u, inst, mops[1], inst.operand[1])
        elif mopt[1] in [OP_rAX, OP_rCX, OP_rDX, OP_rBX,
                       OP_rSP, OP_rBP, OP_rSI, OP_rDI]:
            inst.operand[1].type = 'OP_REG'
            inst.operand[1].base = resolve_gpr64(u, inst, mopt[1])
        elif mopt[1] == OP_O:
            decode_o(u, inst, mops[1], inst.operand[1])  
            inst.operand[0].size = resolve_operand_size(u, inst, mops[1])

    elif mopt[0] in [OP_ALr8b, OP_CLr9b, OP_DLr10b, OP_BLr11b,
                   OP_AHr12b, OP_CHr13b, OP_DHr14b, OP_BHr15b]:
        gpr = (mopt[0] - OP_ALr8b +(REX_B(inst.pfx.rex) << 3))
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = GPR[8][inst.pfx.rex != 0][gpr]
        if mopt[1] == OP_I:
            decode_imm(u, inst, mops[1], inst.operand[1])

    # eAX..eDX, DX/I 
    elif mopt[0] in [OP_eAX, OP_eCX, OP_eDX, OP_eBX,
                   OP_eSP, OP_eBP, OP_eSI, OP_eDI]:
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = resolve_gpr32(u, inst, mopt[0])
        if mopt[1] == OP_DX:
            inst.operand[1].type = 'OP_REG'
            inst.operand[1].base = 'dx'
            inst.operand[1].size = 16
        elif mopt[1] == OP_I:
            decode_imm(u, inst, mops[1], inst.operand[1])

    # ES..GS 
    elif mopt[0] in [OP_ES, OP_CS, OP_DS,
                   OP_SS, OP_FS, OP_GS]:

        # in 64bits mode, only fs and gs are allowed 
        if u.dis_mode == 64:
            if mopt[0] != OP_FS and mopt[0] != OP_GS:
                u.error = 1
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = GPR['T_SEG'][mopt[0] - OP_ES]
        inst.operand[0].size = 16

    # J 
    elif mopt[0] == OP_J:
        decode_imm(u, inst, mops[0], inst.operand[0])
        # MK take care of signs
        bound = pow(2, inst.operand[0].size - 1)
        if inst.operand[0].lval >= bound:
            inst.operand[0].lval = -(2 * bound - inst.operand[0].lval)
        inst.operand[0].type = 'OP_JIMM'

    # PR, I 
    elif mopt[0] == OP_PR:
        if MODRM_MOD(u.input.peek()) != 3:
            u.error = 1
        decode_modrm(u, inst, inst.operand[0], mops[0], 'T_MMX', NULL, 0, 'T_NONE')
        if mopt[1] == OP_I:
            decode_imm(u, inst, mops[1], inst.operand[1])

    # VR, I 
    elif mopt[0] == OP_VR:
        if MODRM_MOD(u.input.peek()) != 3:
            u.error = 1
        decode_modrm(u, inst, inst.operand[0], mops[0], 'T_XMM', NULL, 0, 'T_NONE')
        if mopt[1] == OP_I:
            decode_imm(u, inst, mops[1], inst.operand[1])

    # P, Q[,I]/W/E[,I],VR 
    elif mopt[0] == OP_P:
        if mopt[1] == OP_Q:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_MMX', inst.operand[0], mops[0], 'T_MMX')
            if mopt[2] == OP_I:
                decode_imm(u, inst, mops[2], inst.operand[2])
        elif mopt[1] == OP_W:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_XMM', inst.operand[0], mops[0], 'T_MMX')
        elif mopt[1] == OP_VR:
            if MODRM_MOD(u.input.peek()) != 3:
                u.error = 1
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_XMM', inst.operand[0], mops[0], 'T_MMX')
        elif mopt[1] == OP_E:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_MMX')
            if mopt[2] == OP_I:
                decode_imm(u, inst, mops[2], inst.operand[2])

    # R, C/D 
    elif mopt[0] == OP_R:
        if mopt[1] == OP_C:
            decode_modrm(u, inst, inst.operand[0], mops[0], 'T_GPR', inst.operand[1], mops[1], 'T_CRG')
        elif mopt[1] == OP_D:
            decode_modrm(u, inst, inst.operand[0], mops[0], 'T_GPR', inst.operand[1], mops[1], 'T_DBG')

    # C, R 
    elif mopt[0] == OP_C:
        decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_CRG')

    # D, R 
    elif mopt[0] == OP_D:
        decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_DBG')

    # Q, P 
    elif mopt[0] == OP_Q:
        decode_modrm(u, inst, inst.operand[0], mops[0], 'T_MMX', inst.operand[1], mops[1], 'T_MMX')

    # S, E 
    elif mopt[0] == OP_S:
        decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_SEG')

    # W, V 
    elif mopt[0] == OP_W:
        decode_modrm(u, inst, inst.operand[0], mops[0], 'T_XMM', inst.operand[1], mops[1], 'T_XMM')

    # V, W[,I]/Q/M/E 
    elif mopt[0] == OP_V:
        if mopt[1] == OP_W:
            # special cases for movlps and movhps 
            if MODRM_MOD(u.input.peek()) == 3:
                if inst.operator == 'movlps':
                    inst.operator = 'movhlps'
                elif inst.operator == 'movhps':
                    inst.operator = 'movlhps'
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_XMM', inst.operand[0], mops[0], 'T_XMM')
            if mopt[2] == OP_I:
                decode_imm(u, inst, mops[2], inst.operand[2])
        elif mopt[1] == OP_Q:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_MMX', inst.operand[0], mops[0], 'T_XMM')
        elif mopt[1] == OP_M:
            if MODRM_MOD(u.input.peek()) == 3:
                u.error = 1
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_XMM')
        elif mopt[1] == OP_E:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_GPR', inst.operand[0], mops[0], 'T_XMM')
        elif mopt[1] == OP_PR:
            decode_modrm(u, inst, inst.operand[1], mops[1], 'T_MMX', inst.operand[0], mops[0], 'T_XMM')

    # DX, eAX/AL
    elif mopt[0] == OP_DX:
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = 'dx'
        inst.operand[0].size = 16

        if mopt[1] == OP_eAX:
            inst.operand[1].type = 'OP_REG'    
            inst.operand[1].base = resolve_gpr32(u, inst, mopt[1])
        elif mopt[1] == OP_AL:
            inst.operand[1].type = 'OP_REG'
            inst.operand[1].base = 'al'
            inst.operand[1].size = 8

    # I, I/AL/eAX
    elif mopt[0] == OP_I:
        decode_imm(u, inst, mops[0], inst.operand[0])
        if mopt[1] == OP_I:
            decode_imm(u, inst, mops[1], inst.operand[1])
        elif mopt[1] == OP_AL:
            inst.operand[1].type = 'OP_REG'
            inst.operand[1].base = 'al'
            inst.operand[1].size = 16
        elif mopt[1] == OP_eAX:
            inst.operand[1].type = 'OP_REG'    
            inst.operand[1].base = resolve_gpr32(u, inst, mopt[1])

    # O, AL/eAX
    elif mopt[0] == OP_O:
        decode_o(u, inst, mops[0], inst.operand[0])
        inst.operand[1].type = 'OP_REG'
        inst.operand[1].size = resolve_operand_size(u, inst, mops[0])
        if mopt[1] == OP_AL:
            inst.operand[1].base = 'al' 
        elif mopt[1] == OP_eAX:
            inst.operand[1].base = resolve_gpr32(u, inst, mopt[1])
        elif mopt[1] == OP_rAX:
            inst.operand[1].base = resolve_gpr64(u, inst, mopt[1])      

    # 3
    elif mopt[0] == OP_I3:
        inst.operand[0].type = 'OP_IMM'
        inst.operand[0].lval = 3

    # ST(n), ST(n) 
    elif mopt[0] in [OP_ST0, OP_ST1, OP_ST2, OP_ST3,
                   OP_ST4, OP_ST5, OP_ST6, OP_ST7]:
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = GPR['T_ST'][mopt[0] - OP_ST0]
        inst.operand[0].size = 0

        if mopt[1] in [OP_ST0, OP_ST1, OP_ST2, OP_ST3,
                     OP_ST4, OP_ST5, OP_ST6, OP_ST7]:
            inst.operand[1].type = 'OP_REG'
            inst.operand[1].base = GPR['T_ST'][mopt[1] - OP_ST0]
            inst.operand[1].size = 0

    # AX 
    elif mopt[0] == OP_AX:
        inst.operand[0].type = 'OP_REG'
        inst.operand[0].base = 'ax'
        inst.operand[0].size = 16

    # none 
    else:
        for op in inst.operand:
            op.type = None

    return 0
*)
  RETURN e
  END disasmOperands;


  PROCEDURE doMode(): INTEGER;
    VAR e: INTEGER;
  BEGIN
    e:=S.OK;
(*
    # if in error state, bail out 
    if u.error:
        return -1 

    # propagate perfix effects 
    if u.dis_mode == 64:  # set 64bit-mode flags
        # Check validity of  instruction m64 
        if P_INV64(inst.itab_entry.prefix):
            u.error = 1
            return -1

        # effective rex prefix is the  effective mask for the 
        # instruction hard-coded in the opcode map.
        inst.pfx.rex = ((inst.pfx.rex & 0x40) 
                        |(inst.pfx.rex & REX_PFX_MASK(inst.itab_entry.prefix)))

        # calculate effective operand size 
        if REX_W(inst.pfx.rex) or P_DEF64(inst.itab_entry.prefix):
            inst.opr_mode = 64
        elif inst.pfx.opr:
            inst.opr_mode = 16
        else:
            inst.opr_mode = 32

        # calculate effective address size
        if inst.pfx.adr:
            inst.adr_mode = 32 
        else:
            inst.adr_mode = 64
    elif u.dis_mode == 32: # set 32bit-mode flags 
        if inst.pfx.opr:
            inst.opr_mode = 16 
        else:
            inst.opr_mode = 32
        if inst.pfx.adr:
            inst.adr_mode = 16 
        else: 
            inst.adr_mode = 32
    elif u.dis_mode == 16: # set 16bit-mode flags 
        if inst.pfx.opr:
            inst.opr_mode = 32 
        else: 
            inst.opr_mode = 16
        if inst.pfx.adr:
            inst.adr_mode = 32 
        else: 
            inst.adr_mode = 16

    return 0
*)
  RETURN e
  END doMode;

  PROCEDURE decode*():INTEGER;
    VAR e: INTEGER; b: CHAR; t: ARRAY 32 OF CHAR;
  BEGIN
    e := S.OK;
    S.setat(S.pc);
    
    IF e = S.OK THEN e:= getPrefixes() END;
    IF e = S.OK THEN e:= searchItab() END;
    IF e = S.OK THEN e:= doMode() END;
    IF e = S.OK THEN e:= disasmOperands() END;
    IF e = S.OK THEN e:= resolveOperator() END;
    

(*
    """Instruction decoder. Returns the number of bytes decoded."""
    inst = Inst(myInput = self.input, add = self.pc, mode = self.dis_mode, syntax = self.syntax)
    self.error = 0
    self.input.start ()
    if get_prefixes(self, inst) != 0:
        pass # ;print('prefixes error') # error 
    elif search_itab(self, inst) != 0:
        pass #; print('itab error') # error 
    elif do_mode(self, inst) != 0:
        pass #; print('mode error') # error 
    elif disasm_operands(self, inst) != 0:
        pass #; print('operand error') # error 
    elif resolve_operator(self, inst) != 0:
        pass #; print('operator error') # error 
    # Handle decode error.
    if self.error:
        inst.clear()
    inst.size = self.input.ctr + 1
    inst.raw = self.input.buffer[0:inst.size]
    inst.set_pc(inst.add + inst.size)
    return inst
*)
    C.code(ie.operator,t);
    S.setistr(t);
   (* S.setpc(S.pc + S.isz); *)
    IF S.pc >= S.cfe THEN e:= S.FINISH END;
    IF S.R.eof THEN e:= S.FINISH END;
    S.setE(e);
  RETURN e
  END decode;

END OIDisDecode.
