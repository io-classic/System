
## [MODULE Batch](https://github.com/io-core/System/blob/main/Batch.Mod)

  ## Imports:
` Kernel FileDir Files Display Texts TextFrames Viewers Oberon`

## Constants:
```

    BatchStopped = 0;
    BatchRunning = 1;
    BatchWaitGC = 2;
    BatchFailed = 3;
    OberonVerifyVersion = "OR Compiler 22.7.2018";

```
## Types:
```

    FileList = POINTER TO FileListDesc;

    FileListDesc = RECORD
        name: FileDir.FileName;
        next: FileList;
      END;

```
## Variables:
```

    pat: ARRAY 32 OF CHAR;
    fl: FileList;
    state: INTEGER;
    emptyReader: Texts.Reader;
    script: Texts.Reader;
    scriptFrame: TextFrames.Frame;
    gcWaitTask: Oberon.Task;
    gcWaitAllocated: INTEGER;

```
## Procedures:
---

`  PROCEDURE ClearLog*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L33)


`  PROCEDURE WriteLog*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L41)


`  PROCEDURE VerifyLog*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L74)


`  PROCEDURE AddFileToList(name: FileDir.FileName; adr: LONGINT; VAR cont: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L123)


`  PROCEDURE DeleteFiles*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L150)


`  PROCEDURE Collect*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L174)


`  PROCEDURE Continue;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L180)


`  PROCEDURE GCWait;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L214)


`  PROCEDURE Run*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L230)

