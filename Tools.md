
## [MODULE Tools](https://github.com/io-core/System/blob/main/Tools.Mod)
Module Tools provides commands for inspecting memory, disk, etc.


  ## Imports:
` SYSTEM Kernel Files Modules Input Texts Viewers MenuViewers TextFrames Oberon`

```
```
## Variables:
```
 T: Texts.Text; V: MenuViewers.Viewer; W: Texts.Writer;

```
## Procedures:
---

`  PROCEDURE OpenViewer(T: Texts.Text; title: ARRAY OF CHAR);` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L9)


`  PROCEDURE Clear*;  (*used to clear output*)` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L18)


`  PROCEDURE Recall*;` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L23)


`  PROCEDURE Inspect*;` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L31)


`  PROCEDURE Sector*;` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L46)


`  PROCEDURE ShowFile*;` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L63)


`  PROCEDURE Convert*;   (*convert selected text to txt-format*)` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L83)


`  PROCEDURE Id*;` [(source)](https://github.com/io-orig/System/blob/main/Tools.Mod#L107)

