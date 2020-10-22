
## [MODULE Checkers](https://github.com/io-core/Extras/blob/main/Checkers.Mod)

  ## Imports:
` SYSTEM Display Viewers Oberon MenuViewers TextFrames`

```
## Types:
```
 Frame = POINTER TO FrameDesc;

    FrameDesc = RECORD (Display.FrameDesc)
        col: INTEGER
      END ;

```
## Variables:
```
 i: INTEGER;
    checks: INTEGER;
    pat: ARRAY 17 OF INTEGER;

```
## Procedures:
---

`  PROCEDURE Restore(F: Frame);` [(source)](https://github.com/io-orig/System/blob/main/Checkers.Mod#L14)


`  PROCEDURE Handle(G: Display.Frame; VAR M: Display.FrameMsg);` [(source)](https://github.com/io-orig/System/blob/main/Checkers.Mod#L20)


`  PROCEDURE Open*;` [(source)](https://github.com/io-orig/System/blob/main/Checkers.Mod#L35)

