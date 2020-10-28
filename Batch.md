
## [MODULE Batch](https://github.com/io-core/System/blob/main/Batch.Mod)
Module Batch provides for automatic sequential execution of Oberon commands.

Module Batch provides for automatic sequential execution of Oberon commands.


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

`  PROCEDURE ClearLog*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L37)


`  PROCEDURE WriteLog*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L45)


`  PROCEDURE VerifyLog*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L78)


`  PROCEDURE AddFileToList(name: FileDir.FileName; adr: LONGINT; VAR cont: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L127)


`  PROCEDURE DeleteFiles*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L154)


`  PROCEDURE Collect*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L178)


`  PROCEDURE Continue;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L184)


`  PROCEDURE GCWait;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L218)


`  PROCEDURE Run*;` [(source)](https://github.com/io-orig/System/blob/main/Batch.Mod#L234)

