
## [MODULE System](https://github.com/io-core/System/blob/main/System.Mod)

  ## Imports:
` SYSTEM Kernel FileDir Files Modules Input Display Viewers Fonts Texts Oberon MenuViewers TextFrames`

## Constants:
```

    StandardMenu = "System.Close System.Copy System.Grow Edit.Search Edit.Store";
    LogMenu = "Edit.Locate Edit.Search System.Copy System.Grow System.Clear";

```
## Types:
```


```
## Variables:
```
 
    W: Texts.Writer;
    pat: ARRAY 32 OF CHAR;

```
## Procedures:
---

`  PROCEDURE GetArg(VAR S: Texts.Scanner);` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L27)


`  PROCEDURE EndLine;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L36)


`  PROCEDURE SetUser*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L42)


`  PROCEDURE SetFont*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L53)


`  PROCEDURE SetColor*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L59)


`  PROCEDURE SetOffset*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L65)


`  PROCEDURE Date*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L71)


`  PROCEDURE Collect*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L85)


`  PROCEDURE Open*;  (*open viewer in system track*)` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L91)


`  PROCEDURE Clear*;  (*clear Log*)` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L104)


`  PROCEDURE Close*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L112)


`  PROCEDURE CloseTrack*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L121)


`  PROCEDURE Recall*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L126)


`  PROCEDURE Copy*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L134)


`  PROCEDURE Grow*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L141)


`  PROCEDURE Free1(VAR S: Texts.Scanner);` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L158)


`  PROCEDURE Free*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L165)


`  PROCEDURE FreeFonts*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L182)


`  PROCEDURE List(name: FileDir.FileName; adr: LONGINT; VAR cont: BOOLEAN);` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L188)


`  PROCEDURE Directory*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L218)


`  PROCEDURE CopyFiles*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L248)


`  PROCEDURE RenameFiles*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L276)


`  PROCEDURE DeleteFiles*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L298)


`  PROCEDURE Watch*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L312)


`  PROCEDURE ShowModules*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L323)


`  PROCEDURE ShowCommands*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L344)


`  PROCEDURE ShowFonts*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L371)


`  PROCEDURE OpenViewers;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L380)


`  PROCEDURE ExtendDisplay*;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L395)


`  PROCEDURE Trap(VAR a: INTEGER; b: INTEGER);` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L411)


`  PROCEDURE Abort;` [(source)](https://github.com/io-orig/System/blob/main/System.Mod#L424)

