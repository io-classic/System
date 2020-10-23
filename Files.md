
## [MODULE Files](https://github.com/io-core/Files/blob/main/Files.Mod)

  ## Imports:
` SYSTEM Kernel FileDir`

## Constants:
```
 MaxBufs    = 4;
      HS        = FileDir.HeaderSize;
      SS        = FileDir.SectorSize;
      STS       = FileDir.SecTabSize;
      XS        = FileDir.IndexSize;

```
## Types:
```
  DiskAdr = INTEGER;
      File*    = POINTER TO FileDesc;
      Buffer  = POINTER TO BufferRecord;
      Index   = POINTER TO IndexRecord;

    Rider* =
      RECORD eof*: BOOLEAN;
        res*: INTEGER;
        file: File;
        apos, bpos: INTEGER;
        buf: Buffer
      END ;

    FileDesc =
      RECORD next: INTEGER; (*list of files invisible to the GC*)
        nofbufs, aleng, bleng: INTEGER;
        modH, registered: BOOLEAN;
        firstbuf: Buffer;
        sechint: DiskAdr;
        name: FileDir.FileName;
        date: INTEGER;
        ext:  ARRAY FileDir.ExTabSize OF Index;
        sec: FileDir.SectorTable
      END ;

    BufferRecord =
      RECORD apos, lim: INTEGER;
        mod: BOOLEAN;
        next: Buffer;
        data: FileDir.DataSector
      END ;

    IndexRecord =
      RECORD adr: DiskAdr;
        mod: BOOLEAN;
        sec: FileDir.IndexSector
      END ;

    (*aleng * SS + bleng = length (including header)
      apos * SS + bpos = current position
      0 <= bpos <= lim <= SS
      0 <= apos <= aleng < PgTabSize
      (apos < aleng) & (lim = SS) OR (apos = aleng) *)

```
## Variables:
```
 root: INTEGER (*File*);  (*list of open files*)

```
## Procedures:
---
## ---------- API: Old, New, Register, Close, Purge, Delete, Rename, Date, Length
---
**Check** verifies a FileName is in an acceptable format.

`  PROCEDURE Check(s: ARRAY OF CHAR;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L73)

---
**Old** opens an existing file or returns the file handle or NIL.

`  PROCEDURE Old*(name: ARRAY OF CHAR): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L95)

---
**New** creates a new file and returns a file handle.

`  PROCEDURE New*(name: ARRAY OF CHAR): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L134)

---
**UpdateHeader** updates the file header.

`  PROCEDURE UpdateHeader(f: File; VAR F: FileDir.FileHeader);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L162)


`  PROCEDURE ReadBuf(f: File; buf: Buffer; pos: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L169)


`  PROCEDURE WriteBuf(f: File; buf: Buffer);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L180)


`  PROCEDURE Buf(f: File; pos: INTEGER): Buffer;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L206)


`  PROCEDURE GetBuf(f: File; pos: INTEGER): Buffer;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L214)


`  PROCEDURE Unbuffer(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L229)


`  PROCEDURE Register*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L255)


`  PROCEDURE Close*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L265)


`  PROCEDURE Purge*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L270)


`  PROCEDURE Delete*(name: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L287)


`  PROCEDURE Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L297)


`  PROCEDURE Length*(f: File): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L315)


`  PROCEDURE Date*(f: File): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L319)


`  PROCEDURE Set*(VAR r: Rider; f: File; pos: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L325)


`  PROCEDURE Pos*(VAR r: Rider): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L339)


`  PROCEDURE Base*(VAR r: Rider): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L343)


`  PROCEDURE ReadByte*(VAR r: Rider; VAR x: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L347)


`  PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L364)


`  PROCEDURE Read*(VAR r: Rider; VAR ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L370)


`  PROCEDURE ReadInt*(VAR R: Rider; VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L387)


`  PROCEDURE ReadSet*(VAR R: Rider; VAR s: SET);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L393)


`  PROCEDURE ReadReal*(VAR R: Rider; VAR x: REAL);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L398)


`  PROCEDURE ReadString*(VAR R: Rider; VAR x: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L403)


`  PROCEDURE ReadNum*(VAR R: Rider; VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L413)


`  PROCEDURE NewExt(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L422)


`  PROCEDURE WriteByte*(VAR r: Rider; x: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L429)


`  PROCEDURE WriteBytes*(VAR r: Rider; x: ARRAY OF BYTE; n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L450)


`  PROCEDURE Write*(VAR r: Rider; ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L456)


`  PROCEDURE WriteInt*(VAR R: Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L477)


`  PROCEDURE WriteSet*(VAR R: Rider; s: SET);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L484)


`  PROCEDURE WriteReal*(VAR R: Rider; x: REAL);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L488)


`  PROCEDURE WriteString*(VAR R: Rider; x: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L492)


`  PROCEDURE WriteNum*(VAR R: Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L498)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L506)


`  PROCEDURE RestoreList*; (*after mark phase of garbage collection*)` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L510)


`    PROCEDURE mark(f: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L513)

