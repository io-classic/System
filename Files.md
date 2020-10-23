
## [MODULE Files](https://github.com/io-core/Files/blob/main/Files.Mod)

  ## Imports:
` SYSTEM Kernel FileDir`

## Constants:
```
 
    MaxBufs   = 4;
    HS        = FileDir.HeaderSize;
    SS        = FileDir.SectorSize;
    STS       = FileDir.SecTabSize;
    XS        = FileDir.IndexSize;

```
## Types:
```
  
    DiskAdr = INTEGER;
    File*   = POINTER TO FileDesc;
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
## ---------- File Directory API
#### Old, New, Register, Close, Purge, Delete, Rename, Date, Length
---
**Check** verifies a FileName is in an acceptable format.

`  PROCEDURE Check(s: ARRAY OF CHAR;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L81)

---
**Old** opens an existing file or returns the file handle or NIL.

`  PROCEDURE Old*(name: ARRAY OF CHAR): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L103)

---
**New** creates a new file and returns a file handle.

`  PROCEDURE New*(name: ARRAY OF CHAR): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L142)

---
**UpdateHeader** updates the file header.

`  PROCEDURE UpdateHeader(f: File; VAR F: FileDir.FileHeader);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L170)

---
**ReadBuf** retrieves a file buffer's sector contents from disk.

`  PROCEDURE ReadBuf(f: File; buf: Buffer; pos: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L181)

---
**WriteBuf** places a file buffer's sector contents on disk, allocating a sector if necessary.

`  PROCEDURE WriteBuf(f: File; buf: Buffer);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L196)

---
**Buf** returns the buffer for file `f` in memory for a sector at file sector index `pos` or NIL.

`  PROCEDURE Buf(f: File; pos: INTEGER): Buffer;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L226)

---
**GetBuf** returns a buffer for file `f` for a sector at file sector index `pos`, loading from disk if necessary, potentially spilling a buffer.

`  PROCEDURE GetBuf(f: File; pos: INTEGER): Buffer;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L238)

---
**Unbuffer** writes modified buffers and the file header for a file back to disk, allocating new sectors as necessary.

`  PROCEDURE Unbuffer(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L257)

---
**Register** makes temporary (created with `New`) file permanent by inserting it into the on-disk directory structure.

`  PROCEDURE Register*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L287)

---
**Close** flushes all outstanding changes to a file to disk.

`  PROCEDURE Close*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L301)

---
**Purge** returns disk sectors used by a file to free space.

`  PROCEDURE Purge*(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L310)

---
**Delete** removes a file from the directory and frees the disk sectors used by the file.

`  PROCEDURE Delete*(name: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L331)

---
**Rename** Changes the name of a file.

`  PROCEDURE Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L345)

---
**Length** returns the length of the file.

`  PROCEDURE Length*(f: File): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L367)

---
**Date** returns the last modified date of the file.

`  PROCEDURE Date*(f: File): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L375)

## ---------- File Reading API
#### Set, Pos, Base, ReadByte, ReadBytes, Read, ReadInt, ReadSet, ReadReal, ReadString, ReadNum

`  PROCEDURE Set*(VAR r: Rider; f: File; pos: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L386)


`  PROCEDURE Pos*(VAR r: Rider): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L400)


`  PROCEDURE Base*(VAR r: Rider): File;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L404)


`  PROCEDURE ReadByte*(VAR r: Rider; VAR x: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L408)


`  PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L425)


`  PROCEDURE Read*(VAR r: Rider; VAR ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L431)


`  PROCEDURE ReadInt*(VAR R: Rider; VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L448)


`  PROCEDURE ReadSet*(VAR R: Rider; VAR s: SET);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L454)


`  PROCEDURE ReadReal*(VAR R: Rider; VAR x: REAL);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L459)


`  PROCEDURE ReadString*(VAR R: Rider; VAR x: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L464)


`  PROCEDURE ReadNum*(VAR R: Rider; VAR x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L474)

## ---------- File Writing API
#### WriteByte, WriteBytes, Write, WriteInt, WriteReal, WriteString, WriteNum

`  PROCEDURE NewExt(f: File);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L488)


`  PROCEDURE WriteByte*(VAR r: Rider; x: BYTE);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L495)


`  PROCEDURE WriteBytes*(VAR r: Rider; x: ARRAY OF BYTE; n: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L516)


`  PROCEDURE Write*(VAR r: Rider; ch: CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L522)


`  PROCEDURE WriteInt*(VAR R: Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L543)


`  PROCEDURE WriteSet*(VAR R: Rider; s: SET);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L550)


`  PROCEDURE WriteReal*(VAR R: Rider; x: REAL);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L554)


`  PROCEDURE WriteString*(VAR R: Rider; x: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L558)


`  PROCEDURE WriteNum*(VAR R: Rider; x: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L564)

## ---------- System Use

`  PROCEDURE Init*;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L575)


`  PROCEDURE RestoreList*; (*after mark phase of garbage collection*)` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L579)


`    PROCEDURE mark(f: INTEGER): INTEGER;` [(source)](https://github.com/io-orig/System/blob/main/Files.Mod#L582)

