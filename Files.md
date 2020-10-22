
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

`  PROCEDURE Check(s: ARRAY OF CHAR;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L65)


`  PROCEDURE Old*(name: ARRAY OF CHAR): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L83)


`  PROCEDURE New*(name: ARRAY OF CHAR): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L118)


`  PROCEDURE UpdateHeader(f: File; VAR F: FileDir.FileHeader);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L142)


`  PROCEDURE ReadBuf(f: File; buf: Buffer; pos: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L149)


`  PROCEDURE WriteBuf(f: File; buf: Buffer);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L160)


`  PROCEDURE Buf(f: File; pos: INTEGER): Buffer;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L186)


`  PROCEDURE GetBuf(f: File; pos: INTEGER): Buffer;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L194)


`  PROCEDURE Unbuffer(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L209)


`  PROCEDURE Register*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L235)


`  PROCEDURE Close*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L245)


`  PROCEDURE Purge*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L250)


`  PROCEDURE Delete*(name: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L267)


`  PROCEDURE Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L277)


`  PROCEDURE Length*(f: File): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L295)


`  PROCEDURE Date*(f: File): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L299)


`  PROCEDURE Set*(VAR r: Rider; f: File; pos: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L305)


`  PROCEDURE Pos*(VAR r: Rider): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L319)


`  PROCEDURE Base*(VAR r: Rider): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L323)


`  PROCEDURE ReadByte*(VAR r: Rider; VAR x: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L327)


`  PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L344)


`  PROCEDURE Read*(VAR r: Rider; VAR ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L350)


`  PROCEDURE ReadInt*(VAR R: Rider; VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L367)


`  PROCEDURE ReadSet*(VAR R: Rider; VAR s: SET);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L373)


`  PROCEDURE ReadReal*(VAR R: Rider; VAR x: REAL);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L378)


`  PROCEDURE ReadString*(VAR R: Rider; VAR x: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L383)


`  PROCEDURE ReadNum*(VAR R: Rider; VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L393)


`  PROCEDURE NewExt(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L402)


`  PROCEDURE WriteByte*(VAR r: Rider; x: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L409)


`  PROCEDURE WriteBytes*(VAR r: Rider; x: ARRAY OF BYTE; n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L430)


`  PROCEDURE Write*(VAR r: Rider; ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L436)


`  PROCEDURE WriteInt*(VAR R: Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L457)


`  PROCEDURE WriteSet*(VAR R: Rider; s: SET);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L464)


`  PROCEDURE WriteReal*(VAR R: Rider; x: REAL);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L468)


`  PROCEDURE WriteString*(VAR R: Rider; x: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L472)


`  PROCEDURE WriteNum*(VAR R: Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L478)


`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L486)


`  PROCEDURE RestoreList*; (*after mark phase of garbage collection*)` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L490)


`    PROCEDURE mark(f: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L493)

