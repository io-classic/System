(* begin-module-short-description
tracks objects and types while compiling the Oberon language.
end-module-short-description *)

(* begin-module-use-description
Module OXB manages the symbol table for the Oberon compiler and reads and writes 'smb' files


end-module-use-description *)
(* begin-module-develop-description

(NW 25.6.2014  / AP 4.3.2020 / 8.3.2019  in Oberon-07 / CP 11.2020)

**OXB** is called from ORP and OXG and tracks the state of identifiers and objects as code compilation progresses.

end-module-develop-description *)
MODULE OXB;   (*NW 25.6.2014  / AP 4.3.2020 / 8.3.2019  in Oberon-07 / CP 11.2020*)
  IMPORT Files, OXS;
  (*Definition of data types Object and Type, which together form the data structure
    called "symbol table". Contains procedures for creation of Objects, and for search:
    NewObj, this, thisimport, thisfield (and OpenScope, CloseScope).
    Handling of import and export, i.e. reading and writing of "symbol files" is done by procedures
    Import and Export. This module contains the list of standard identifiers, with which
    the symbol table (universe), and that of the pseudo-module SYSTEM are initialized. *)

  CONST 
    versionkey* = 1; maxTypTab = 64;
    (* class values*) Head* = 0;
      Const* = 1; Var* = 2; Par* = 3; Fld* = 4; Typ* = 5;
      SProc* = 6; SFunc* = 7; Mod* = 8;

    (* form values*)  (* BYTE <= SHORTINT <= INTEGER <= LONGINT , FLOAT <= DOUBLE *)
      Byte* = 1; Bool* = 2; Char* = 3; Short* = 4; Int* = 5; Long* = 6; Real* = 7; Double* = 8; Set* = 9;
      Pointer* = 10; Interface* = 11; Continuation* = 12; NilTyp* = 13; NoTyp* = 14; Proc* = 15;
      String* = 16; Array* = 17; Record* = 18; TProc* = 19;
      Ptrs* = {Pointer, Interface, NilTyp}; Procs* = {Proc, NoTyp}; 
      
  TYPE 
    Object* = POINTER TO ObjDesc;
    Module* = POINTER TO ModDesc;
    Type* = POINTER TO TypeDesc;

    ObjDesc*= RECORD
      class*, exno*: BYTE;
      expo*, rdo*: BOOLEAN;   (*exported / read-only*)
      lev*: INTEGER;
      next*, dsc*: Object;
      type*: Type;
      name*: OXS.Ident;
      val* (*,val2* *): LONGINT
    END ;

    ModDesc* = RECORD (ObjDesc) orgname*: OXS.Ident END ;

    TypeDesc* = RECORD
      form*, ref*, mno*: INTEGER;  (*ref is only used for import/export*)
      nofpar*: INTEGER;  (*for procedures, extension level for records*)
      len*: LONGINT;  (*for arrays, len < 0 => open array; for records: adr of descriptor*)
      dsc*, typobj*: Object;
      base*: Type;  (*for arrays, records, pointers*)
      size*: LONGINT;  (*in bytes; always multiple of 4, except for Byte, Bool and Char*)
    END ;

  (* Object classes and the meaning of "val":
    class    val
    ----------
    Var      address
    Par      address
    Const    value
    Fld      offset
    Typ      type descriptor (TD) address
    SProc    inline code number
    SFunc    inline code number
    Mod      key

  Type forms and the meaning of "dsc" and "base":
    form     dsc      base
    ------------------------
    Pointer  -        type of dereferenced object
    Proc     params   result type
    Array    -        type of elements
    Record   fields   extension *)

  VAR 
    topScope*, universe, system*: Object;
    byteType*, boolType*, charType*: Type;
    shortType*, longType*, doubleType*: Type; 
    intType*, realType*, setType*, nilType*, noType*, strType*: Type;
    nofmod, Ref: INTEGER;
    typtab: ARRAY maxTypTab OF Type;

  (* begin-section-description
## ---------- Scopes
  end-section-description *)

  PROCEDURE NewObj*(VAR obj: Object; id: OXS.Ident; class: INTEGER);  (*insert new Object with name id*)
    VAR new, x: Object;
  BEGIN x := topScope;
    WHILE (x.next # NIL) & (x.next.name # id) DO x := x.next END ;
    IF x.next = NIL THEN
      NEW(new); new.name := id; new.class := class; new.next := NIL; new.rdo := FALSE; new.dsc := NIL;
      x.next := new; obj := new
    ELSE obj := x.next; OXS.Mark("mult def")
    END 
  END NewObj;

  PROCEDURE thisObj*(): Object;
    VAR s, x: Object;
  BEGIN s := topScope;
    REPEAT x := s.next;
      WHILE (x # NIL) & (x.name # OXS.id) DO x := x.next END ;
      s := s.dsc
    UNTIL (x # NIL) OR (s = NIL);
    RETURN x
  END thisObj;

  PROCEDURE thisimport*(mod: Object): Object;
    VAR obj: Object;
  BEGIN
    IF mod.rdo THEN
      IF mod.name[0] # 0X THEN
        obj := mod.dsc;
        WHILE (obj # NIL) & (obj.name # OXS.id) DO obj := obj.next END
      ELSE obj := NIL
      END
    ELSE obj := NIL
    END ;
    RETURN obj
  END thisimport;

  PROCEDURE thisfield*(rec: Type): Object;
    VAR fld: Object;
  BEGIN fld := rec.dsc;
    WHILE (fld # NIL) & (fld.name # OXS.id) DO fld := fld.next END ;
    RETURN fld
  END thisfield;

  PROCEDURE OpenScope*;
    VAR s: Object;
  BEGIN NEW(s); s.class := Head; s.dsc := topScope; s.next := NIL; topScope := s
  END OpenScope;

  PROCEDURE CloseScope*;
  BEGIN topScope := topScope.dsc
  END CloseScope;

  (*------------------------------- Import ---------------------------------*)

  (* begin-section-description
## ---------- Import
  end-section-description *)

  (* begin-procedure-description
---
**MakeFileName**  ??
  end-procedure-description *)
  PROCEDURE MakeFileName*(VAR FName: OXS.Ident; name, ext: ARRAY OF CHAR);
    VAR i, j: INTEGER;
  BEGIN i := 0; j := 0;  (*assume name suffix less than 4 characters*)
    WHILE (i < OXS.IdLen-5) & (name[i] > 0X) DO FName[i] := name[i]; INC(i) END ;
    REPEAT FName[i]:= ext[j]; INC(i); INC(j) UNTIL ext[j] = 0X;
    FName[i] := 0X
  END MakeFileName;
  
  (* begin-procedure-description
---
**ThisModule** ??
  end-procedure-description *)
  PROCEDURE ThisModule(name, orgname: OXS.Ident; decl: BOOLEAN; key: LONGINT): Object;
    VAR mod: Module; obj, obj1: Object;
  BEGIN obj1 := topScope; obj := obj1.next;  (*search for module*)
    WHILE (obj # NIL) & (obj(Module).orgname # orgname) DO obj1 := obj; obj := obj1.next END ;
    IF obj = NIL THEN  (*new module, search for alias*)
      obj := topScope.next;
      WHILE (obj # NIL) & (obj.name # name) DO obj := obj.next END ;
      IF obj = NIL THEN (*insert new module*)
        NEW(mod); mod.class := Mod; mod.rdo := FALSE;
        mod.name := name; mod.orgname := orgname; mod.val := key;
        mod.lev := nofmod; INC(nofmod); mod.dsc := NIL; mod.next := NIL;
        IF decl THEN mod.type := noType ELSE mod.type := nilType END ;
        obj1.next := mod; obj := mod
      ELSIF decl THEN
        IF obj.type.form = NoTyp THEN OXS.Mark("mult def") ELSE OXS.Mark("invalid import order") END
      ELSE OXS.Mark("conflict with alias")
      END
    ELSIF decl THEN (*module already present, explicit import by declaration*)
      IF  obj.type.form = NoTyp THEN OXS.Mark("mult def") ELSE OXS.Mark("invalid import order") END
    END ;
    RETURN obj
  END ThisModule;
  
  (* begin-procedure-description
---
**Read** reads an adjusted byte in from the symbol file.
  end-procedure-description *)
  PROCEDURE Read(VAR R: Files.Rider; VAR x: INTEGER);
    VAR b: BYTE;
  BEGIN Files.ReadByte(R, b);
    IF b < 80H THEN x := b ELSE x := b - 100H END
  END Read;
  
  (* begin-procedure-description
---
**InType** reads a type in from the symbol file of an imported module.
  end-procedure-description *)
  PROCEDURE InType(VAR R: Files.Rider; thismod: Object; VAR T: Type);
    VAR key: LONGINT;
      ref, class, form, np, readonly: INTEGER;
      fld, par, obj, mod, last: Object;
      t: Type;
      name, modname: OXS.Ident;
  BEGIN Read(R, ref);
    IF ref < 0 THEN T := typtab[-ref]  (*already read*)
    ELSE NEW(t); T := t; typtab[ref] := t; t.mno := thismod.lev;
      Read(R, form); t.form := form;
      IF form = Pointer THEN InType(R, thismod, t.base); t.size := 4
      ELSIF form = Array THEN
        InType(R, thismod, t.base); Files.ReadNum(R, t.len); Files.ReadNum(R, t.size)
      ELSIF form = Record THEN
        InType(R, thismod, t.base);
        IF t.base.form = NoTyp THEN t.base := NIL; obj := NIL ELSE obj := t.base.dsc END ;
        Files.ReadNum(R, t.len); (*TD adr/exno*)
        Files.ReadNum(R, t.nofpar);  (*ext level*)
        Files.ReadNum(R, t.size);
        Read(R, class); last := NIL;
        WHILE class # 0 DO  (*fields*)
          NEW(fld); fld.class := class; Files.ReadString(R, fld.name);
          IF last = NIL THEN t.dsc := fld ELSE last.next := fld END ;
          last := fld;
          IF fld.name[0] # 0X THEN fld.expo := TRUE; InType(R, thismod, fld.type) ELSE fld.expo := FALSE; fld.type := nilType END ;
          Files.ReadNum(R, fld.val); Read(R, class)
        END ;
        IF last = NIL THEN t.dsc := obj ELSE last.next := obj END
      ELSIF form IN {Proc, TProc} THEN
        InType(R, thismod, t.base);
        obj := NIL; np := 0; Read(R, class);
        WHILE class # 0 DO  (*parameters*)
          NEW(par); par.class := class; Read(R, readonly); par.rdo := readonly = 1; 
          InType(R, thismod, par.type); par.next := obj; obj := par; INC(np); Read(R, class)
        END ;
        t.dsc := obj; t.nofpar := np; t.size := 4
      END ;
      Files.ReadString(R, modname);
      IF modname[0] #  0X THEN  (*re-import ========*)
        Files.ReadInt(R, key); Files.ReadString(R, name);
        mod := ThisModule(modname, modname, FALSE, key);
        obj := mod.dsc;  (*search type*)
        WHILE (obj # NIL) & (obj.name # name) DO obj := obj.next END ;
        IF obj # NIL THEN T := obj.type   (*type object found in object list of mod*)
        ELSE (*insert new type object in object list of mod*)
          NEW(obj); obj.name := name; obj.class := Typ; obj.next := mod.dsc; mod.dsc := obj; obj.type := t;
          t.mno := mod.lev; t.typobj := obj; T := t
        END ;
        typtab[ref] := T
      END
    END
  END InType;
  
  (* begin-procedure-description
---
**Import** reads in the symbol file for an imported module so that its exported constants, types, variables, and procedures may be referenced. 
  end-procedure-description *)
  PROCEDURE Import*(VAR modid, modid1: OXS.Ident);
    VAR key: LONGINT; class, k: INTEGER;
      obj: Object;  t: Type;
      thismod: Object;
      modname, fname: OXS.Ident;
      F: Files.File; R: Files.Rider;
  BEGIN
    IF modid1 = "SYSTEM" THEN
      thismod := ThisModule(modid, modid1, TRUE,  key); DEC(nofmod);
      thismod.lev := 0; thismod.dsc := system; thismod.rdo := TRUE
    ELSE MakeFileName(fname, modid1, ".smb"); F := Files.Old(fname);
      IF F # NIL THEN
        Files.Set(R, F, 0); Files.ReadInt(R, key); Files.ReadInt(R, key); Files.ReadString(R, modname);
        thismod := ThisModule(modid, modid1, TRUE, key); thismod.rdo := TRUE;
        Read(R, class); (*version key*)
        IF class # versionkey THEN OXS.Mark("wrong version") END ;
        Read(R, class);
        WHILE class # 0 DO
          NEW(obj); obj.class := class; Files.ReadString(R, obj.name);
          InType(R, thismod, obj.type); obj.lev := -thismod.lev;
          IF class = Typ THEN
            t := obj.type; t.typobj := obj; Read(R, k);  (*fixup bases of previously declared pointer types*)
            WHILE k # 0 DO typtab[k].base := t; Read(R, k) END
          ELSE
            IF class = Const THEN
              IF obj.type.form = Real THEN Files.ReadInt(R, obj.val) ELSE Files.ReadNum(R, obj.val) END
            ELSIF class = Var THEN Files.ReadNum(R, obj.val); obj.rdo := TRUE
            END
          END ;
          obj.next := thismod.dsc; thismod.dsc := obj; Read(R, class)
        END ;
      ELSE OXS.Mark("import not available")
      END
    END
  END Import;
  
  (*-------------------------------- Export ---------------------------------*)

  (* begin-section-description
## ---------- Export
  end-section-description *)

  (* begin-procedure-description
---
**Write** delivers a byte from the integer to the symbol file.
  end-procedure-description *)
  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);
  BEGIN Files.WriteByte(R, x)
  END Write;

  (* begin-procedure-description
---
**OutType** writes a type to the symbol file
  end-procedure-description *)
  PROCEDURE OutType(VAR R: Files.Rider; t: Type);
    VAR obj, mod, fld, bot: Object;

    PROCEDURE OutPar(VAR R: Files.Rider; par: Object; n: INTEGER);
      VAR cl: INTEGER;
    BEGIN
      IF n > 0 THEN
        OutPar(R, par.next, n-1); cl := par.class;
        Write(R, cl);
        IF par.rdo THEN Write(R, 1) ELSE Write(R, 0) END ;
        OutType(R, par.type)
      END
    END OutPar;

    PROCEDURE FindHiddenPointers(VAR R: Files.Rider; typ: Type; offset: LONGINT);
      VAR fld: Object; i, n: LONGINT;
    BEGIN
      IF (typ.form = Pointer) OR (typ.form = NilTyp) THEN Write(R, Fld); Write(R, 0); Files.WriteNum(R, offset)
      ELSIF typ.form = Record THEN fld := typ.dsc;
        WHILE fld # NIL DO FindHiddenPointers(R, fld.type, fld.val + offset); fld := fld.next END
      ELSIF typ.form = Array THEN i := 0; n := typ.len;
        WHILE i < n DO FindHiddenPointers(R, typ.base, typ.base.size * i + offset); INC(i) END
      END
    END FindHiddenPointers;

  BEGIN
    IF t.ref > 0 THEN (*type was already output*) Write(R, -t.ref)
    ELSE obj := t.typobj;
      IF obj # NIL THEN Write(R, Ref); t.ref := Ref; INC(Ref) ELSE (*anonymous*) Write(R, 0) END ;
      Write(R, t.form);
      IF t.form = Pointer THEN OutType(R, t.base)
      ELSIF t.form = Array THEN OutType(R, t.base); Files.WriteNum(R, t.len); Files.WriteNum(R, t.size)
      ELSIF t.form = Record THEN
        IF t.base # NIL THEN OutType(R, t.base); bot := t.base.dsc ELSE OutType(R, noType); bot := NIL END ;
        IF obj # NIL THEN Files.WriteNum(R, obj.exno) ELSE Write(R, 0) END ;
        Files.WriteNum(R, t.nofpar); Files.WriteNum(R, t.size);
        fld := t.dsc;
        WHILE fld # bot DO  (*fields*)
          IF fld.expo THEN
            Write(R, Fld); Files.WriteString(R, fld.name); OutType(R, fld.type); Files.WriteNum(R, fld.val)  (*offset*)
          ELSE FindHiddenPointers(R, fld.type, fld.val)
          END ;
          fld := fld.next
        END ;
        Write(R, 0)
      ELSIF t.form IN {Proc, TProc} THEN OutType(R, t.base); OutPar(R, t.dsc, t.nofpar); Write(R, 0)
      END ;
      IF (t.mno > 0) & (obj # NIL) THEN  (*re-export, output name*)
        mod := topScope.next;
        WHILE (mod # NIL) & (mod.lev # t.mno) DO mod := mod.next END ;
        IF mod # NIL THEN Files.WriteString(R, mod(Module).orgname); Files.WriteInt(R, mod.val); Files.WriteString(R, obj.name)
        ELSE OXS.Mark("re-export not found"); Write(R, 0)
        END
      ELSE Write(R, 0)
      END
    END
  END OutType;

  (* begin-procedure-description
---
**Export** writes out the symbol file for a module.
  end-procedure-description *)
  PROCEDURE Export*(VAR modid: OXS.Ident; VAR newSF: BOOLEAN; VAR key: LONGINT);
    VAR x, sum, oldkey: LONGINT;
      obj, obj0: Object;
      filename: OXS.Ident;
      F, F1: Files.File; R, R1: Files.Rider;
  BEGIN Ref := Record + 1; MakeFileName(filename, modid, ".smb");
    F := Files.New(filename); Files.Set(R, F, 0);
    Files.WriteInt(R, 0); (*placeholder*)
    Files.WriteInt(R, 0); (*placeholder for key to be inserted at the end*)
    Files.WriteString(R, modid); Write(R, versionkey);
    obj := topScope.next;
    WHILE obj # NIL DO
      IF obj.expo THEN
        Write(R, obj.class); Files.WriteString(R, obj.name);
        OutType(R, obj.type);
        IF obj.class = Typ THEN
          IF obj.type.form = Record THEN
            obj0 := topScope.next;  (*check whether this is base of previously declared pointer types*)
            WHILE obj0 # obj DO
              IF (obj0.type.form = Pointer) & (obj0.type.base = obj.type) & (obj0.type.ref > 0) THEN Write(R, obj0.type.ref) END ;
              obj0 := obj0.next
            END
          END ;
          Write(R, 0)
        ELSIF obj.class = Const THEN
          IF obj.type.form = Proc THEN Files.WriteNum(R, obj.exno)
          ELSIF obj.type.form = Real THEN Files.WriteInt(R, obj.val)
          ELSE Files.WriteNum(R, obj.val)
          END
        ELSIF obj.class = Var THEN Files.WriteNum(R, obj.exno)
        END
      END ;
      obj := obj.next
    END ;
    REPEAT Write(R, 0) UNTIL Files.Length(F) MOD 4 = 0;
    FOR Ref := Record+1 TO maxTypTab-1 DO typtab[Ref] := NIL END ;
    Files.Set(R, F, 0); sum := 0; Files.ReadInt(R, x);  (* compute key (checksum) *)
    WHILE ~R.eof DO sum := sum + x; Files.ReadInt(R, x) END ;
    F1 := Files.Old(filename); (*sum is new key*)
    IF F1 # NIL THEN Files.Set(R1, F1, 4); Files.ReadInt(R1, oldkey) ELSE oldkey := sum+1 END ;
    IF sum # oldkey THEN
      IF newSF OR (F1 = NIL) THEN
        key := sum; newSF := TRUE; Files.Set(R, F, 4); Files.WriteInt(R, sum); Files.Register(F)  (*insert checksum*)
      ELSE OXS.Mark("new symbol file inhibited")
      END
    ELSE newSF := FALSE; key := sum
    END
  END Export;

  (* begin-procedure-description
---
**Clear** prepares the top scope of the program.
  end-procedure-description *)
  PROCEDURE Clear*;
  BEGIN topScope := universe; nofmod := 1
  END Clear;

  (* begin-section-description
## ---------- Initialization
  end-section-description *)

  (* begin-procedure-description
---
**type** allocates a pre-defined type object
  end-procedure-description *)
  PROCEDURE type(ref, form: INTEGER; size: LONGINT): Type;
    VAR tp: Type;
  BEGIN NEW(tp); tp.form := form; tp.size := size; tp.ref := ref; tp.base := NIL;
    typtab[ref] := tp; RETURN tp
  END type;

  (* begin-procedure-description
---
**Enter** introduces a pre-defined type, function, or procedure.
  end-procedure-description *)
  PROCEDURE Enter*(name: ARRAY OF CHAR; cl: INTEGER; type: Type; n: LONGINT);
    VAR obj: Object;
  BEGIN NEW(obj); obj.name := name; obj.class := cl; obj.type := type; obj.val := n; obj.dsc := NIL;
    IF cl = Typ THEN type.typobj := obj END ;
    obj.next := system; system := obj
  END Enter;
 
  (* begin-procedure-description
---
**PrepSYSTEM** prepares the SYSTEM scope for entry of types, functions, or procedures.
  end-procedure-description *)
  PROCEDURE PrepSYSTEM*;
  BEGIN 
    topScope := NIL; OpenScope; topScope.next := system; universe := topScope; 
    system := NIL;  (* initialize "unsafe" pseudo-module SYSTEM*)
  END PrepSYSTEM;

 
  (* begin-procedure-description
---
**Init** registers base Oberon types and populates the the object table with predeclared types,functions and procedures.
  end-procedure-description *)
  PROCEDURE Init*(wordsize: INTEGER); 
  BEGIN
    byteType := type(Byte, Int, 1);
    boolType := type(Bool, Bool, 1);
    charType := type(Char, Char, 1);
    shortType := type(Short, Short, 2); 
    longType := type(Long, Long, 8);   
    doubleType := type(Double, Double, 8);  
    IF wordsize = 4 THEN 
      intType := type(Int, Int, 4);
      realType := type(Real, Real, 4);
      setType := type(Set, Set, 4);
      nilType := type(NilTyp, NilTyp, 4);
      noType := type(NoTyp, NoTyp, 4);
      strType := type(String, String, 8);
    ELSE
      intType := type(Int, Int, 8);
      realType := type(Real, Real, 8);
      setType := type(Set, Set,8);
      nilType := type(NilTyp, NilTyp, 8);
      noType := type(NoTyp, NoTyp, 8);
      strType := type(String, String, 16);
    END;
      
    (*initialize universe with data types and in-line procedures;
      INTEGER and LONGINT are register size in 32 and 64 bit systems.
      REAL and LONGREAL resgister size in 32 and 64 bit systems.
      LED, ADC, SBC; LDPSR, LDREG, REG, COND are not in language definition*)
    system := NIL;  (*n = procno*10 + nofpar*)
(*
    Enter("UML", SFunc, intType, 132);  (*functions*)
    Enter("SBC", SFunc, intType, 122);
    Enter("ADC", SFunc, intType, 112);
    Enter("ROR", SFunc, intType, 92);
    Enter("ASR", SFunc, intType, 82);
    Enter("LSL", SFunc, intType, 72);
    Enter("LEN", SFunc, intType, 61);
    Enter("CHR", SFunc, charType, 51);
    Enter("ORD", SFunc, intType, 41);
    Enter("FLT", SFunc, realType, 31);
    Enter("FLOOR", SFunc, intType, 21);
    Enter("ODD", SFunc, boolType, 11);
    Enter("ABS", SFunc, intType, 1);
    Enter("LED", SProc, noType, 81);  (*procedures*)
    Enter("UNPK", SProc, noType, 72);
    Enter("PACK", SProc, noType, 62);
    Enter("NEW", SProc, noType, 51);
    Enter("ASSERT", SProc, noType, 41);
    Enter("EXCL", SProc, noType, 32);
    Enter("INCL", SProc, noType, 22);
    Enter("DEC", SProc, noType, 11);
    Enter("INC", SProc, noType, 1);
    Enter("SET", Typ, setType, 0);   (*types*)
    Enter("BOOLEAN", Typ, boolType, 0);
    Enter("BYTE", Typ, byteType, 0);
    Enter("CHAR", Typ, charType, 0);
    IF wordsize = 4 THEN Enter("LONGREAL", Typ, realType, 0) END;
    IF wordsize = 8 THEN Enter("LONGREAL", Typ, doubleType, 0) END;
    Enter("REAL", Typ, realType, 0);
    IF wordsize = 4 THEN Enter("LONGINT", Typ, intType, 0) END;
    IF wordsize = 8 THEN Enter("LONGINT", Typ, longType, 0) END;
    Enter("INTEGER", Typ, intType, 0);
    IF wordsize = 8 THEN Enter("SHORTINT", Typ, shortType, 0) END; 

    PrepSYSTEM;

    Enter("H", SFunc, intType, 201);     (*functions*)
    Enter("COND", SFunc, boolType, 191);
    Enter("SIZE", SFunc, intType, 181);
    Enter("ADR", SFunc, intType, 171);
    Enter("VAL", SFunc, intType, 162);
    Enter("REG", SFunc, intType, 151);
    Enter("BIT", SFunc, boolType, 142);
    Enter("REGREG", SProc, noType, 212);  (*procedures*)
    Enter("LDREG", SProc, noType, 142); 
    Enter("LDPSR", SProc, noType, 131);
    Enter("COPY", SProc, noType, 123);
    Enter("PUT", SProc, noType, 112);
    Enter("GET", SProc, noType, 102);
*)
  END Init;
BEGIN
END OXB.
