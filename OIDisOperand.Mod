(* begin-module-use-description
Module OIDisOperand provides x86_64 opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OIDisOperand** provides x86_64 opcodes for the OIDis disassembler.
Rewritten from pymsasid3 (matthieu.kaczmarek@mines-nancy.org) which was rewritten from udis86 (Vivek Mohan <vivek@sig9.com>)

The module provides the opcode operands.

end-module-develop-description *)
MODULE OIDisOperand;   (*CP 2020*)
  IMPORT SYSTEM;

  CONST
    INTEL* = 0;
    AMD* = 1;
    MaxInsnLength* = 15;
    NULL* = 0;

    (* itab prefix bits *)
    Pnone =    0;
    Pc1 =      1;
    Prexb =    2;
    PdepM =    4;
    Pc3 =      8;
    Pinv64 =   16;
    Prexw =    32;
    Pc2 =      64;
    Pdef64 =   128;
    Prexr =    256;
    Poso =     512;
    Paso =     1024;
    Prexx =    2048;
    PImpAddr = 4096;

    (* operand types *)
    opNONE =   0;
    
    opA =      1;
    opE =      2;
    opM =      3;
    opG =      4;
    opI =      5;
    
    opAL =     6;
    opCL =     7;
    opDL =     8;
    opBL =     9;
    opAH =     10;
    opCH =     11;
    opDH =     12;
    opBH =     13;
    
    opALr8b =  14;
    opCLr9b =  15;
    opDLr10b = 16;
    opBLr11b = 17;
    opAHr12b = 18;
    opCHr13b = 19;
    opDHr14b = 20;
    opBHr15b = 21;
    
    opAX =     22;
    opCX =     23;
    opDX =     24;
    opBX =     25;
    opSI =     26;
    opDI =     27;
    opSP =     28;
    opBP =     29;
    
    oprAX =    30;
    oprCX =    31;
    oprDX =    32;
    oprBX =    33; 
    oprSP =    34;
    oprBP =    35;
    oprSI =    36;
    oprDI =    37;
    
    oprAXr8 =  38;
    oprCXr9 =  39;
    oprDXr10 = 40;
    oprBXr11 = 41;
    oprSPr12 = 42;
    oprBPr13 = 43;
    oprSIr14 = 44;
    oprDIr15 = 45;
    
    opeAX =    46;
    opeCX =    47;
    opeDX =    48;
    opeBX =    49;
    opeSP =    50;
    opeBP =    51;
    opeSI =    52;
    opeDI =    53;
    
    opES =     54;
    opCS =     55;
    opSS =     56;
    opDS =     57;
    opFS =     58;
    opGS =     59;
    
    opST0 =    60;
    opST1 =    61;
    opST2 =    62;
    opST3 =    63;
    opST4 =    64;
    opST5 =    65;
    opST6 =    66;
    opST7 =    67;
    
    opJ =      68;
    opS =      69;
    opO =      70;
    opI1 =     71;
    opI3 =     72;
    opV =      73;
    opW =      74;
    opQ =      75;
    opP =      76;
    opR =      77;
    opC =      78;
    opD =      79;
    opVR =     80;
    opPR =     81;
    
    (* operand size constants *)
    szNA =     0;
    szZ =      1;
    szV =      2;
    szP =      3;
    szWP =     4;
    szDP =     5;
    szMDQ =    6;
    szRDQ =    7;
    
    (* the following values are used as is, changing them will break internals *)
    szB =      8;
    szW =      16;
    szD =      32;
    szQ =      64;
    szT =      80;

  TYPE
    (* a single operand of an entry in the instruction table. *)
    IEO = POINTER TO IEODesc;
    IEODesc = RECORD
        type: INTEGER;
        size: INTEGER;
    END;

  VAR
    orSPr12, 
    oBL, 
    oBH, 
    oBP, 
    oAHr12b, 
    oBX, 
    oJz, 
    oJv, 
    oJb, 
    orSIr14, 
    oGS, 
    oD, 
    orBPr13, 
    oOb, 
    oP, 
    oOw, 
    oOv, 
    oGw, 
    oGv, 
    orDX, 
    oGx, 
    oGd, 
    oGb, 
    orBXr11, 
    orDI, 
    orSI, 
    oALr8b, 
    oeDI, 
    oGz, 
    oeDX, 
    oDHr14b, 
    orSP, 
    oPR, 
    oNONE, 
    orCX, 
    ojWP, 
    orDXr10, 
    oMd, 
    oC, 
    oG, 
    oMb, 
    oMt, 
    oS, 
    oMq, 
    oW, 
    oES, 
    orBX, 
    oEd, 
    oDLr10b, 
    oMw, 
    oEb, 
    oEx, 
    oEz, 
    oEw, 
    oEv, 
    oEp, 
    oFS, 
    oMs, 
    orAXr8, 
    oeBP, 
    oIsb, 
    oeBX, 
    orCXr9, 
    ojDP, 
    oCH, 
    oCL, 
    oR, 
    oV, 
    oCS, 
    oCHr13b, 
    oeCX, 
    oeSP, 
    oSS, 
    oSP, 
    oBLr11b, 
    oSI, 
    oeSI, 
    oDL, 
    oDH, 
    oDI, 
    oDX, 
    orBP, 
    oGvw, 
    oI1, 
    oI3, 
    oDS, 
    oST4, 
    oST5, 
    oST6, 
    oST7, 
    oST0, 
    oST1, 
    oST2, 
    oST3, 
    oE, 
    oAH, 
    oM, 
    oAL, 
    oCLr9b, 
    oQ, 
    oeAX, 
    oVR, 
    oAX, 
    orAX, 
    oIz, 
    orDIr15, 
    oIw, 
    oIv, 
    oAp, 
    oCX, 
    oIb, 
    oBHr15b: IEODesc; 
    
(*
GPR = {
    'T_NONE' :  [ # None
        None,
    ],

    8 :        [[ # 8 bit GPRs, non-REX
        'al',   'cl',   'dl',   'bl',
        'ah',   'ch',   'dh',   'bh',
        'r8b',  'r9b',  'r10b', 'r11b',
        'r12b', 'r13b', 'r14b', 'r15b',
    ],
                [ # 8 bit GPRs, with REX prefix
        'al',   'cl',   'dl',   'bl',
        'spl',  'bpl',  'sil',  'dil',
        'r8b',  'r9b',  'r10b', 'r11b',
        'r12b', 'r13b', 'r14b', 'r15b',
    ]],
     
    16 :        [ # 16 bit GPRs
    'ax',   'cx',   'dx',   'bx',
    'sp',   'bp',   'si',   'di',
    'r8w',  'r9w',  'r10w', 'r11w',
    'r12w', 'r13w', 'r14w', 'r15w',
    ],
    
  
    32 :        [ # 32 bit GPRs 
        'eax',  'ecx',  'edx',  'ebx',
        'esp',  'ebp',  'esi',  'edi',
        'r8d',  'r9d',  'r10d', 'r11d',
        'r12d', 'r13d', 'r14d', 'r15d',
    ],

    64 :        [ # 64 bit GPRs
        'rax',  'rcx',  'rdx',  'rbx',
        'rsp',  'rbp',  'rsi',  'rdi',
        'r8',   'r9',   'r10',  'r11',
        'r12',  'r13',  'r14',  'r15',
    ],
  
    'T_SEG' :   [ # segment registers 
        'es',   'cs',   'ss',   'ds',
        'fs',   'gs',   
    ],

    'T_CRG' :   [ # control registers
        'cr0',  'cr1',  'cr2',  'cr3',
        'cr4',  'cr5',  'cr6',  'cr7',
        'cr8',  'cr9',  'cr10', 'cr11',
        'cr12', 'cr13', 'cr14', 'cr15',
    ],

    'T_DBG' :   [ # debug registers 
        'dr0',  'dr1',  'dr2',  'dr3',
        'dr4',  'dr5',  'dr6',  'dr7',
        'dr8',  'dr9',  'dr10', 'dr11',
        'dr12', 'dr13', 'dr14', 'dr15',
    ],

    'T_MMX' :   [ # mmx registers
        'mm0',  'mm1',  'mm2',  'mm3',
        'mm4',  'mm5',  'mm6',  'mm7',
    ],

   
    'T_ST' :    [ # x87 registers
        'st0',  'st1',  'st2',  'st3',
        'st4',  'st5',  'st6',  'st7', 
    ],

 
    'T_XMM' :   [ # extended multimedia registers
        'xmm0',     'xmm1',     'xmm2',
        'xmm3',     'xmm4',     'xmm5',
        'xmm6',     'xmm7',     'xmm8',
        'xmm9',     'xmm10',    'xmm11',
        'xmm12',    'xmm13',    'xmm14',
        'xmm15',
    ],

    'IP' :      [ # program counter
        'rip',
    ],
  
    'OP' :      [ # operand Types 
        'OpREG',   'OpMEM',   'OpPTR',
        'OpIMM',   'OpJIMM',  'OpCONST',
    ],
}

*)

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

(* rex prefix bits *)
  PROCEDURE REXW(r: INTEGER): INTEGER;
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

(* scable-index-base bits *)
  PROCEDURE SIBS(b: INTEGER): INTEGER;
  BEGIN
    RETURN b DIV 64
  END SIBS;

  PROCEDURE SIBI(b: INTEGER): INTEGER;
  BEGIN
    RETURN (b DIV 8) MOD 8
  END SIBI;

  PROCEDURE SIBB(b: INTEGER): INTEGER;
  BEGIN
    RETURN b MOD 8
  END SIBB;

(* modrm bits *)
  PROCEDURE MODRMREG(b: INTEGER): INTEGER;   
  BEGIN
    RETURN (b DIV 8) MOD 8
  END MODRMREG;

  PROCEDURE MODRMNNN(b: INTEGER): INTEGER;
  BEGIN
    RETURN (b DIV 8) MOD 8
  END MODRMNNN;

  PROCEDURE MODRMMOD(b: INTEGER): INTEGER; 
  BEGIN
    RETURN (b DIV 64) MOD 4
  END MODRMMOD;

  PROCEDURE MODRMRM(b: INTEGER): INTEGER;   
  BEGIN
    RETURN b MOD 8
  END MODRMRM;

  PROCEDURE ieoset( VAR o: IEODesc; a, b: INTEGER);
  BEGIN
    o.type := a;
    o.size := b;
  END ieoset;

BEGIN
(* populate itab entry operand definitions *)
  ieoset(orSPr12 , oprSPr12, szNA);
  ieoset(oBL ,     opBL, szNA);
  ieoset(oBH ,     opBH, szNA);
  ieoset(oBP ,     opBP, szNA);
  ieoset(oAHr12b , opAHr12b, szNA);
  ieoset(oBX ,     opBX, szNA);
  ieoset(oJz ,     opJ, szZ);
  ieoset(oJv ,     opJ, szV);
  ieoset(oJb ,     opJ, szB);
  ieoset(orSIr14 , oprSIr14, szNA);
  ieoset(oGS ,     opGS, szNA);
  ieoset(oD ,      opD, szNA);
  ieoset(orBPr13 , oprBPr13, szNA);
  ieoset(oOb ,     opO, szB);
  ieoset(oP ,      opP, szNA);
  ieoset(oOw ,     opO, szW);
  ieoset(oOv ,     opO, szV);
  ieoset(oGw ,     opG, szW);
  ieoset(oGv ,     opG, szV);
  ieoset(orDX ,    oprDX, szNA);
  ieoset(oGx ,     opG, szMDQ);
  ieoset(oGd ,     opG, szD);
  ieoset(oGb ,     opG, szB);
  ieoset(orBXr11 , oprBXr11, szNA);
  ieoset(orDI ,    oprDI, szNA);
  ieoset(orSI ,    oprSI, szNA);
  ieoset(oALr8b ,  opALr8b, szNA);
  ieoset(oeDI ,    opeDI, szNA);
  ieoset(oGz ,     opG, szZ);
  ieoset(oeDX ,    opeDX, szNA);
  ieoset(oDHr14b , opDHr14b, szNA);
  ieoset(orSP ,    oprSP, szNA);
  ieoset(oPR ,     opPR, szNA);
  ieoset(oNONE ,   opNONE, szNA);
  ieoset(orCX ,    oprCX, szNA);
  ieoset(ojWP ,    opJ, szWP);
  ieoset(orDXr10 , oprDXr10, szNA);
  ieoset(oMd ,     opM, szD);
  ieoset(oC ,      opC, szNA);
  ieoset(oG ,      opG, szNA);
  ieoset(oMb ,     opM, szB);
  ieoset(oMt ,     opM, szT);
  ieoset(oS ,      opS, szNA);
  ieoset(oMq ,     opM, szQ);
  ieoset(oW ,      opW, szNA);
  ieoset(oES ,     opES, szNA);
  ieoset(orBX ,    oprBX, szNA);
  ieoset(oEd ,     opE, szD);
  ieoset(oDLr10b , opDLr10b, szNA);
  ieoset(oMw ,     opM, szW);
  ieoset(oEb ,     opE, szB);
  ieoset(oEx ,     opE, szMDQ);
  ieoset(oEz ,     opE, szZ);
  ieoset(oEw ,     opE, szW);
  ieoset(oEv ,     opE, szV);
  ieoset(oEp ,     opE, szP);
  ieoset(oFS ,     opFS, szNA);
  ieoset(oMs ,     opM, szW);
  ieoset(orAXr8 ,  oprAXr8, szNA);
  ieoset(oeBP ,    opeBP, szNA);
  ieoset(oIsb ,    opI, szB);
  ieoset(oeBX ,    opeBX, szNA);
  ieoset(orCXr9 ,  oprCXr9, szNA);
  ieoset(ojDP ,    opJ, szDP);
  ieoset(oCH ,     opCH, szNA);
  ieoset(oCL ,     opCL, szNA);
  ieoset(oR ,      opR, szRDQ);
  ieoset(oV ,      opV, szNA);
  ieoset(oCS ,     opCS, szNA);
  ieoset(oCHr13b , opCHr13b, szNA);
  ieoset(oeCX ,    opeCX, szNA);
  ieoset(oeSP ,    opeSP, szNA);
  ieoset(oSS ,     opSS, szNA);
  ieoset(oSP ,     opSP, szNA);
  ieoset(oBLr11b , opBLr11b, szNA);
  ieoset(oSI ,     opSI, szNA);
  ieoset(oeSI ,    opeSI, szNA);
  ieoset(oDL ,     opDL, szNA);
  ieoset(oDH ,     opDH, szNA);
  ieoset(oDI ,     opDI, szNA);
  ieoset(oDX ,     opDX, szNA);
  ieoset(orBP ,    oprBP, szNA);
  ieoset(oGvw ,    opG, szMDQ);
  ieoset(oI1 ,     opI1, szNA);
  ieoset(oI3 ,     opI3, szNA);
  ieoset(oDS ,     opDS, szNA);
  ieoset(oST4 ,    opST4, szNA);
  ieoset(oST5 ,    opST5, szNA);
  ieoset(oST6 ,    opST6, szNA);
  ieoset(oST7 ,    opST7, szNA);
  ieoset(oST0 ,    opST0, szNA);
  ieoset(oST1 ,    opST1, szNA);
  ieoset(oST2 ,    opST2, szNA);
  ieoset(oST3 ,    opST3, szNA);
  ieoset(oE ,      opE, szNA);
  ieoset(oAH ,     opAH, szNA);
  ieoset(oM ,      opM, szNA);
  ieoset(oAL ,     opAL, szNA);
  ieoset(oCLr9b ,  opCLr9b, szNA);
  ieoset(oQ ,      opQ, szNA);
  ieoset(oeAX ,    opeAX, szNA);
  ieoset(oVR ,     opVR, szNA);
  ieoset(oAX ,     opAX, szNA);
  ieoset(orAX ,    oprAX, szNA);
  ieoset(oIz ,     opI, szZ);
  ieoset(orDIr15 , oprDIr15, szNA);
  ieoset(oIw ,     opI, szW);
  ieoset(oIv ,     opI, szV);
  ieoset(oAp ,     opA, szP);
  ieoset(oCX ,     opCX, szNA);
  ieoset(oIb ,     opI, szB);
  ieoset(oBHr15b , opBHr15b, szNA);
END OIDisOperand.

