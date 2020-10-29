(* begin-module-use-description
Module OIDis disassembles x86_64 opcodes.

end-module-use-description *)
(* begin-module-develop-description

(CP 2020)

**OIDis** is a disassembler of x86_64 opcodes.
Rewritten from pymsasid3 (matthieu.kaczmarek@mines-nancy.org) which was rewritten from udis86 (Vivek Mohan <vivek@sig9.com>)

The module sets up a state machine that operates on an input via repeated calls to decode.

OIDis uses OIOperand for definitions of opcode operands.

end-module-develop-description *)
MODULE OIDis;   (*CP 2020*)
  IMPORT SYSTEM, Oberon, OIDisOperand;
  CONST
  TYPE
  VAR 
    error, vendor, mode, pc, entrypoint: INTEGER;
  
  PROCEDURE seek(address: INTEGER): INTEGER;
  BEGIN
(*        input.hook.seek(address) *)
        pc := address;
  RETURN 0
  END seek;

  PROCEDURE NextDecode*():INTEGER;
  BEGIN
(*        dec.decode; *)
  RETURN 0
  END NextDecode;

  PROCEDURE StartDecode*(address: INTEGER): INTEGER;
  VAR err: INTEGER;
  BEGIN
        err := seek(address);
        IF err # 0 THEN
          err := NextDecode();
          IF err # 0 THEN
(*            Inst.inst(input);  *)
          END
        END
  RETURN 0
  END StartDecode;

BEGIN 
(*
    def __init__(self, mode=None, source='',syntax=intel.intel_syntax,
                 vendor=VENDOR_INTEL, hook=BufferHook):
*)
        error := 0;
        vendor := OIDisOperand.INTEL;
        mode := 64;
        pc := 0;
        entrypoint := pc;
(*
        self.input = Input(hook, source)
        self.entry_point = self.pc = int(self.input.hook.entry_point)
        self.syntax = syntax
*)
END OIDis.
