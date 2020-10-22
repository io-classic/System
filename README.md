# Packages

| Package |          |
| ------- | -------- |
| [Kernel](https://github.com/io-orig/System#Kernel) | handles basic os functionality including device access and garbage collection. |
|   | [Kernel.Mod](Kernel.Mod)  |
| [Files](https://github.com/io-orig/System#Files) | handles persistent storage and the file and directory interface of Oberon. |
|   | [FileDir.Mod](FileDir.Mod) [Files.Mod](Files.Mod)  |
| [Modules](https://github.com/io-orig/System#Modules) | manages compiled module loading and unloading in Oberon. |
|   | [Modules.Mod](Modules.Mod)  |
| [Oberon](https://github.com/io-orig/System#Oberon) | implements the user-interaction functionality and the task loop of the system. |
|   | [MenuViewers.Mod](MenuViewers.Mod) [Oberon.Mod](Oberon.Mod) [Input.Mod](Input.Mod) [Display.Mod](Display.Mod) [Viewers.Mod](Viewers.Mod)  |
| [Edit](https://github.com/io-orig/System#Edit) | manages the text and font handling in Oberon. |
|   | [Edit.Mod](Edit.Mod) [Fonts.Mod](Fonts.Mod) [TextFrames.Mod](TextFrames.Mod) [Texts.Mod](Texts.Mod)  |
| [Draw](https://github.com/io-orig/System#Draw) | provides line-oriented drawing primitives and a vector drawing tool. |
|   | [Graphics.Mod](Graphics.Mod) [MacroTool.Mod](MacroTool.Mod) [Draw.Mod](Draw.Mod) [GraphicFrames.Mod](GraphicFrames.Mod) [GraphTool.Mod](GraphTool.Mod) [Rectangles.Mod](Rectangles.Mod) [Curves.Mod](Curves.Mod)  |
| [System](https://github.com/io-orig/System#System) | prepares the user interface and manages viewers for the user. |
|   | [Blink.Mod](Blink.Mod) [Math.Mod](Math.Mod) [RISC.Mod](RISC.Mod) [PIO.Mod](PIO.Mod) [BootLoad.Mod](BootLoad.Mod) [System.Mod](System.Mod) [Tools.Mod](Tools.Mod) [PCLink1.Mod](PCLink1.Mod) [RS232.Mod](RS232.Mod) [Net.Mod](Net.Mod) [SCC.Mod](SCC.Mod) [Batch.Mod](Batch.Mod)  |
| [Build](https://github.com/io-orig/System#Build) | provides the compiler and associated program building and debugging tools for Oberon. |
|   | [ORTool.Mod](ORTool.Mod) [ORB.Mod](ORB.Mod) [ORC.Mod](ORC.Mod) [ORG.Mod](ORG.Mod) [ORP.Mod](ORP.Mod) [ORS.Mod](ORS.Mod) [ODP.Mod](ODP.Mod) [ODG.Mod](ODG.Mod) [ORL.Mod](ORL.Mod)  |

## The Kernel Package
This package handles basic os functionality including device access and garbage collection.

includes: [Kernel.Mod](Kernel.Mod)  



#### MODULE Kernel [_doc_](https://github.com/io-orig/System/blob/main/Kernel.md) [_src_](https://github.com/io-orig/System/blob/main/Kernel.Mod)

  **imports:** ` SYSTEM`

## The Files Package
This package handles persistent storage and the file and directory interface of Oberon.

includes: [FileDir.Mod](FileDir.Mod) [Files.Mod](Files.Mod)  



#### MODULE FileDir [_doc_](https://github.com/io-orig/System/blob/main/FileDir.md) [_src_](https://github.com/io-orig/System/blob/main/FileDir.Mod)

  **imports:** ` SYSTEM Kernel`



#### MODULE Files [_doc_](https://github.com/io-orig/System/blob/main/Files.md) [_src_](https://github.com/io-orig/System/blob/main/Files.Mod)

  **imports:** ` SYSTEM Kernel FileDir`

## The Modules Package
This package manages compiled module loading and unloading in Oberon.

includes: [Modules.Mod](Modules.Mod)  



#### MODULE Modules [_doc_](https://github.com/io-orig/System/blob/main/Modules.md) [_src_](https://github.com/io-orig/System/blob/main/Modules.Mod)

  **imports:** ` SYSTEM Files`

## The Oberon Package
This package implements the user-interaction functionality and the task loop of the system.

includes: [MenuViewers.Mod](MenuViewers.Mod) [Oberon.Mod](Oberon.Mod) [Input.Mod](Input.Mod) [Display.Mod](Display.Mod) [Viewers.Mod](Viewers.Mod)  



#### MODULE MenuViewers [_doc_](https://github.com/io-orig/System/blob/main/MenuViewers.md) [_src_](https://github.com/io-orig/System/blob/main/MenuViewers.Mod)

  **imports:** ` Input Display Viewers Oberon`



#### MODULE Oberon [_doc_](https://github.com/io-orig/System/blob/main/Oberon.md) [_src_](https://github.com/io-orig/System/blob/main/Oberon.Mod)

  **imports:** ` SYSTEM Kernel Files Modules Input Display Viewers Fonts Texts`



#### MODULE Input [_doc_](https://github.com/io-orig/System/blob/main/Input.md) [_src_](https://github.com/io-orig/System/blob/main/Input.Mod)

  **imports:** ` SYSTEM`



#### MODULE Display [_doc_](https://github.com/io-orig/System/blob/main/Display.md) [_src_](https://github.com/io-orig/System/blob/main/Display.Mod)

  **imports:** ` SYSTEM`



#### MODULE Viewers [_doc_](https://github.com/io-orig/System/blob/main/Viewers.md) [_src_](https://github.com/io-orig/System/blob/main/Viewers.Mod)

  **imports:** ` Display`

## The Edit Package
This package manages the text and font handling in Oberon.

includes: [Edit.Mod](Edit.Mod) [Fonts.Mod](Fonts.Mod) [TextFrames.Mod](TextFrames.Mod) [Texts.Mod](Texts.Mod)  



#### MODULE Edit [_doc_](https://github.com/io-orig/System/blob/main/Edit.md) [_src_](https://github.com/io-orig/System/blob/main/Edit.Mod)

  **imports:** ` Files Fonts Texts Display Viewers Oberon MenuViewers TextFrames`



#### MODULE Fonts [_doc_](https://github.com/io-orig/System/blob/main/Fonts.md) [_src_](https://github.com/io-orig/System/blob/main/Fonts.Mod)

  **imports:** ` SYSTEM Files`



#### MODULE TextFrames [_doc_](https://github.com/io-orig/System/blob/main/TextFrames.md) [_src_](https://github.com/io-orig/System/blob/main/TextFrames.Mod)

  **imports:** ` Modules Input Display Viewers Fonts Texts Oberon MenuViewers`



#### MODULE Texts [_doc_](https://github.com/io-orig/System/blob/main/Texts.md) [_src_](https://github.com/io-orig/System/blob/main/Texts.Mod)

  **imports:** ` Files Fonts`

## The Draw Package
This package provides line-oriented drawing primitives and a vector drawing tool.

includes: [Graphics.Mod](Graphics.Mod) [MacroTool.Mod](MacroTool.Mod) [Draw.Mod](Draw.Mod) [GraphicFrames.Mod](GraphicFrames.Mod) [GraphTool.Mod](GraphTool.Mod) [Rectangles.Mod](Rectangles.Mod) [Curves.Mod](Curves.Mod)  



#### MODULE Graphics [_doc_](https://github.com/io-orig/System/blob/main/Graphics.md) [_src_](https://github.com/io-orig/System/blob/main/Graphics.Mod)

  **imports:** ` SYSTEM Files Modules Fonts (*Printer*) Texts Oberon`



#### MODULE MacroTool [_doc_](https://github.com/io-orig/System/blob/main/MacroTool.md) [_src_](https://github.com/io-orig/System/blob/main/MacroTool.Mod)

  **imports:** ` Texts Oberon Graphics GraphicFrames`



#### MODULE Draw [_doc_](https://github.com/io-orig/System/blob/main/Draw.md) [_src_](https://github.com/io-orig/System/blob/main/Draw.Mod)

  **imports:** ` Files Fonts Viewers Texts Oberon


#### MODULE GraphicFrames [_doc_](https://github.com/io-orig/System/blob/main/GraphicFrames.md) [_src_](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod)

  **imports:** ` SYSTEM Display Viewers Input Fonts Texts Graphics Oberon MenuViewers`



#### MODULE GraphTool [_doc_](https://github.com/io-orig/System/blob/main/GraphTool.md) [_src_](https://github.com/io-orig/System/blob/main/GraphTool.Mod)

  **imports:** ` Files Texts Oberon`



#### MODULE Rectangles [_doc_](https://github.com/io-orig/System/blob/main/Rectangles.md) [_src_](https://github.com/io-orig/System/blob/main/Rectangles.Mod)

  **imports:** ` SYSTEM Display Files Input Texts Oberon Graphics GraphicFrames`



#### MODULE Curves [_doc_](https://github.com/io-orig/System/blob/main/Curves.md) [_src_](https://github.com/io-orig/System/blob/main/Curves.Mod)

  **imports:** ` Display Files Oberon Graphics GraphicFrames`

## The System Package
This package prepares the user interface and manages viewers for the user.

includes: [Blink.Mod](Blink.Mod) [Math.Mod](Math.Mod) [RISC.Mod](RISC.Mod) [PIO.Mod](PIO.Mod) [BootLoad.Mod](BootLoad.Mod) [System.Mod](System.Mod) [Tools.Mod](Tools.Mod) [PCLink1.Mod](PCLink1.Mod) [RS232.Mod](RS232.Mod) [Net.Mod](Net.Mod) [SCC.Mod](SCC.Mod) [Batch.Mod](Batch.Mod)  



#### MODULE Blink [_doc_](https://github.com/io-orig/System/blob/main/Blink.md) [_src_](https://github.com/io-orig/System/blob/main/Blink.Mod)

  **imports:** ` SYSTEM Oberon`



#### MODULE Math [_doc_](https://github.com/io-orig/System/blob/main/Math.md) [_src_](https://github.com/io-orig/System/blob/main/Math.Mod)



#### MODULE RISC [_doc_](https://github.com/io-orig/System/blob/main/RISC.md) [_src_](https://github.com/io-orig/System/blob/main/RISC.Mod)

  **imports:** ` SYSTEM Texts Oberon`



#### MODULE PIO [_doc_](https://github.com/io-orig/System/blob/main/PIO.md) [_src_](https://github.com/io-orig/System/blob/main/PIO.Mod)

  **imports:** ` SYSTEM`



#### MODULE BootLoad [_doc_](https://github.com/io-orig/System/blob/main/BootLoad.md) [_src_](https://github.com/io-orig/System/blob/main/BootLoad.Mod)

  **imports:** ` SYSTEM`



#### MODULE System [_doc_](https://github.com/io-orig/System/blob/main/System.md) [_src_](https://github.com/io-orig/System/blob/main/System.Mod)

  **imports:** ` SYSTEM Kernel FileDir Files Modules


#### MODULE Tools [_doc_](https://github.com/io-orig/System/blob/main/Tools.md) [_src_](https://github.com/io-orig/System/blob/main/Tools.Mod)

  **imports:** ` SYSTEM Kernel Files Modules Input Texts Viewers MenuViewers TextFrames Oberon`



#### MODULE PCLink1 [_doc_](https://github.com/io-orig/System/blob/main/PCLink1.md) [_src_](https://github.com/io-orig/System/blob/main/PCLink1.Mod)

  **imports:** ` SYSTEM Files Texts Oberon`



#### MODULE RS232 [_doc_](https://github.com/io-orig/System/blob/main/RS232.md) [_src_](https://github.com/io-orig/System/blob/main/RS232.Mod)

  **imports:** ` SYSTEM`



#### MODULE Net [_doc_](https://github.com/io-orig/System/blob/main/Net.md) [_src_](https://github.com/io-orig/System/blob/main/Net.Mod)

  **imports:** ` SYSTEM SCC Files Viewers Texts TextFrames MenuViewers Oberon`



#### MODULE SCC [_doc_](https://github.com/io-orig/System/blob/main/SCC.md) [_src_](https://github.com/io-orig/System/blob/main/SCC.Mod)

  **imports:** ` SYSTEM Kernel`



#### MODULE Batch [_doc_](https://github.com/io-orig/System/blob/main/Batch.md) [_src_](https://github.com/io-orig/System/blob/main/Batch.Mod)
Module Batch provides for automatic sequential execution of Oberon commands.


  **imports:** ` Kernel FileDir Files Display Texts TextFrames Viewers Oberon`

## The Build Package
This package provides the compiler and associated program building and debugging tools for Oberon.

includes: [ORTool.Mod](ORTool.Mod) [ORB.Mod](ORB.Mod) [ORC.Mod](ORC.Mod) [ORG.Mod](ORG.Mod) [ORP.Mod](ORP.Mod) [ORS.Mod](ORS.Mod) [ODP.Mod](ODP.Mod) [ODG.Mod](ODG.Mod) [ORL.Mod](ORL.Mod)  



#### MODULE ORTool [_doc_](https://github.com/io-orig/System/blob/main/ORTool.md) [_src_](https://github.com/io-orig/System/blob/main/ORTool.Mod)

  **imports:** ` SYSTEM Files Texts Oberon ORB`



#### MODULE ORB [_doc_](https://github.com/io-orig/System/blob/main/ORB.md) [_src_](https://github.com/io-orig/System/blob/main/ORB.Mod)

  **imports:** ` Files ORS`



#### MODULE ORC [_doc_](https://github.com/io-orig/System/blob/main/ORC.md) [_src_](https://github.com/io-orig/System/blob/main/ORC.Mod)

  **imports:** ` SYSTEM Files Texts Oberon V24`



#### MODULE ORG [_doc_](https://github.com/io-orig/System/blob/main/ORG.md) [_src_](https://github.com/io-orig/System/blob/main/ORG.Mod)

  **imports:** ` SYSTEM Files ORS ORB`



#### MODULE ORP [_doc_](https://github.com/io-orig/System/blob/main/ORP.md) [_src_](https://github.com/io-orig/System/blob/main/ORP.Mod)

  **imports:** ` Texts Oberon ORS ORB ORG`



#### MODULE ORS [_doc_](https://github.com/io-orig/System/blob/main/ORS.md) [_src_](https://github.com/io-orig/System/blob/main/ORS.Mod)

  **imports:** ` SYSTEM Texts Oberon`



#### MODULE ODP [_doc_](https://github.com/io-orig/System/blob/main/ODP.md) [_src_](https://github.com/io-orig/System/blob/main/ODP.Mod)

  **imports:** ` Texts Oberon ORS ORB ODG`



#### MODULE ODG [_doc_](https://github.com/io-orig/System/blob/main/ODG.md) [_src_](https://github.com/io-orig/System/blob/main/ODG.Mod)

  **imports:** ` SYSTEM Files ORS ORB`



#### MODULE ORL [_doc_](https://github.com/io-orig/System/blob/main/ORL.md) [_src_](https://github.com/io-orig/System/blob/main/ORL.Mod)
Module ORL links modules to create bin files that may be placed in the boot sectors of an Oberon disk image

ORL uses SYSTEM, Kernel, Files, Modules, Texts, Oberon



  **imports:** ` SYSTEM Kernel Files Modules Texts Oberon`

