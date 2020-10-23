
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
 
    DiskAdr         = INTEGER;
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

```
## Variables:
```


```
## Procedures:
---
## ---------- API: Search, Insert, Delete, Enumerate, Init
---
**Search** finds the DiskAdr for a given FileName.

`  PROCEDURE Search*(name: FileName; VAR A: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L95)

---
**insert** is the recursive procedure for finding a DirEntry to place a FileName in.

`  PROCEDURE insert(name: FileName;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L116)

---
**Insert** starts the process of finding a DirEntry to place a FileName in.

`  PROCEDURE Insert*(name: FileName; fad: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L180)

---
**underflow** handles the case of DirPage underflow on DirEntry deletion.

`  PROCEDURE underflow(VAR c: DirPage;  (*ancestor page*)` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L199)

---
**delete** is the recursive function that searches for and removes a DirEntry.

`  PROCEDURE delete(name: FileName;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L252)

---
**del** is the interior procedure that re-writes a DirPage to remove a DirEntry.

`    PROCEDURE del(VAR a: DirPage; R: INTEGER; dpg1: DiskAdr; VAR h: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L267)

---
**Delete** starts the process of removing a DirEntry with a given FileName.

`  PROCEDURE Delete*(name: FileName; VAR fad: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L306)

---
**enumerate** is the recursive function that iteratively calls a passed-in procedure on DirEntries with names that match a prefix.

`  PROCEDURE enumerate(prefix:   ARRAY OF CHAR;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L324)

---
**Enumerate** starts the process of listing directory entries matching a prefix.

`  PROCEDURE Enumerate*(prefix: ARRAY OF CHAR; proc: EntryHandler);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L354)

---
**Init** preapres Oberon to use the disk by marking used sectors in the Kernel sector map.

`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L365)


`    PROCEDURE MarkSectors(VAR A: ARRAY OF DiskAdr; k: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L369)


`      PROCEDURE sift(VAR A: ARRAY OF DiskAdr; L, R: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L374)


`    PROCEDURE TraverseDir(VAR A: ARRAY OF DiskAdr; VAR k: INTEGER; dpg: DiskAdr);` [(source)](https://github.com/io-orig/System/blob/main/FileDir.Mod#L408)

