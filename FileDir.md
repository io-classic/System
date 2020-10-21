
## [MODULE FileDir](https://github.com/io-core/Files/blob/main/FileDir.Mod)

  ## Imports:
` SYSTEM Kernel`

## Constants:
```
 FnLength*    = 32;
        SecTabSize*   = 64;
        ExTabSize*   = 12;
        SectorSize*   = 1024;
        IndexSize*   = SectorSize DIV 4;
        HeaderSize*  = 352;
        DirRootAdr*  = 29;
        DirPgSize*   = 24;
        N = DirPgSize DIV 2;
        DirMark*    = 9B1EA38DH;
        HeaderMark* = 9BA71D86H;
        FillerSize = 52;

```
## Types:
```
 DiskAdr      = INTEGER;
    FileName*       = ARRAY FnLength OF CHAR;
    SectorTable*    = ARRAY SecTabSize OF DiskAdr;
    ExtensionTable* = ARRAY ExTabSize OF DiskAdr;
    EntryHandler*   = PROCEDURE (name: FileName; sec: DiskAdr; VAR continue: BOOLEAN);

    FileHeader* =
      RECORD (*first page of each file on disk*)
        mark*: INTEGER;
        name*: FileName;
        aleng*, bleng*, date*: INTEGER;
        ext*:  ExtensionTable;
        sec*: SectorTable;
        fill: ARRAY SectorSize - HeaderSize OF BYTE;
      END ;

    FileHd* = POINTER TO FileHeader;
    IndexSector* = ARRAY IndexSize OF DiskAdr;
    DataSector* = ARRAY SectorSize OF BYTE;

    DirEntry* =  (*B-tree node*)
      RECORD
        name*: FileName;
        adr*:  DiskAdr; (*sec no of file header*)
        p*:    DiskAdr  (*sec no of descendant in directory*)
      END ;

    DirPage*  =
      RECORD mark*:  INTEGER;
        m*:     INTEGER;
        p0*:    DiskAdr;  (*sec no of left descendant in directory*)
        fill:  ARRAY FillerSize OF BYTE;
        e*:  ARRAY DirPgSize OF DirEntry
      END ;

  (*Exported procedures: Search, Insert, Delete, Enumerate, Init*)

  PROCEDURE Search*(name: FileName; VAR A: DiskAdr);
```
## Variables:
```
 i, L, R: INTEGER; dadr: DiskAdr;
      a: DirPage;
  BEGIN dadr := DirRootAdr; A := 0;
    REPEAT Kernel.GetSector(dadr, a); ASSERT(a.mark = DirMark);
      L := 0; R := a.m; (*binary search*)
      WHILE L < R DO
        i := (L+R) DIV 2;
        IF name <= a.e[i].name THEN R := i ELSE L := i+1 END
      END ;
      IF (R < a.m) & (name = a.e[R].name) THEN A := a.e[R].adr (*found*)
      ELSIF R = 0 THEN dadr := a.p0
      ELSE dadr := a.e[R-1].p
      END ;
    UNTIL (dadr = 0) OR (A # 0)
  END Search;

```
## Procedures:
---

`  PROCEDURE Search*(name: FileName; VAR A: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L57)


`  PROCEDURE insert(name: FileName;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L74)


`  PROCEDURE Insert*(name: FileName; fad: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L134)


`  PROCEDURE underflow(VAR c: DirPage;  (*ancestor page*)` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L149)


`  PROCEDURE delete(name: FileName;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L198)


`    PROCEDURE del(VAR a: DirPage; R: INTEGER; dpg1: DiskAdr; VAR h: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L209)


`  PROCEDURE Delete*(name: FileName; VAR fad: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L244)


`  PROCEDURE enumerate(prefix:   ARRAY OF CHAR;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L258)


`  PROCEDURE Enumerate*(prefix: ARRAY OF CHAR; proc: EntryHandler);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L284)


`PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L291)


`    PROCEDURE MarkSectors(VAR A: ARRAY OF DiskAdr; k: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L295)


`      PROCEDURE sift(VAR A: ARRAY OF DiskAdr; L, R: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L300)


`    PROCEDURE TraverseDir(VAR A: ARRAY OF DiskAdr; VAR k: INTEGER; dpg: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L334)

