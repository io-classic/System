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


## Package Overview:
The Kernel package abstracts the hardware of the computing platform for the rest of Oberon.

The current Kernel package contains two modules:
* Kernel - core abstractions
* Disk - a device driver for SPI flash storage

## Package Use:

USAGE:
```
Kernel.Collect 
```

## Modules in this package:

#### MODULE Kernel [_doc_](https://github.com/io-orig/System/blob/main/Kernel.md) [_src_](https://github.com/io-orig/System/blob/main/Kernel.Mod)
Module Kernel provides hardware abstraction for Oberon.


  **imports:** ` SYSTEM`

## The Files Package
This package handles persistent storage and the file and directory interface of Oberon.

includes: [FileDir.Mod](FileDir.Mod) [Files.Mod](Files.Mod)  


## Overview
The Files package provides:

* Directory operations
* File i/o

## Examples

USAGE:
```
F := Files.New("newfile.txt")
```

## Modules

#### MODULE FileDir [_doc_](https://github.com/io-orig/System/blob/main/FileDir.md) [_src_](https://github.com/io-orig/System/blob/main/FileDir.Mod)
Module FileDir manages the on-disk representation if directories.

Regular programs do not use FileDir but instead use the api presented by Files which uses FileDir on their behalf.


  **imports:** ` SYSTEM Kernel`



#### MODULE Files [_doc_](https://github.com/io-orig/System/blob/main/Files.md) [_src_](https://github.com/io-orig/System/blob/main/Files.Mod)
Module Files manages the on-disk representation of files and the file api presented to Oberon programs.


  **imports:** ` SYSTEM Kernel FileDir`

## The Modules Package
This package manages compiled module loading and unloading in Oberon.

includes: [Modules.Mod](Modules.Mod)  


The Modules package manages the module heap, the loading and unloading of packages, etc.


#### MODULE Modules [_doc_](https://github.com/io-orig/System/blob/main/Modules.md) [_src_](https://github.com/io-orig/System/blob/main/Modules.Mod)
Module Modules is the heart of how separately compiled Oberon programs are loaded and linked.


  **imports:** ` SYSTEM Files`

## The Oberon Package
This package implements the user-interaction functionality and the task loop of the system.

includes: [MenuViewers.Mod](MenuViewers.Mod) [Oberon.Mod](Oberon.Mod) [Input.Mod](Input.Mod) [Display.Mod](Display.Mod) [Viewers.Mod](Viewers.Mod)  



#### MODULE MenuViewers [_doc_](https://github.com/io-orig/System/blob/main/MenuViewers.md) [_src_](https://github.com/io-orig/System/blob/main/MenuViewers.Mod)
Module MenuViewers implements the top-of-pane 'menu' functionality of the Oberon user interface. 

MenuViewers uses Input, Display, Viewers, Oberon



  **imports:** ` Input Display Viewers Oberon`



#### MODULE Oberon [_doc_](https://github.com/io-orig/System/blob/main/Oberon.md) [_src_](https://github.com/io-orig/System/blob/main/Oberon.Mod)
Module Oberon establishes the messaging and callback system for implementing the extensible user interface of Oberon.

Oberon uses SYSTEM, Kernel, Files, Modules, Input, Display, Viewers, Fonts, Texts



  **imports:** ` SYSTEM Kernel Files Modules Input Display Viewers Fonts Texts`



#### MODULE Input [_doc_](https://github.com/io-orig/System/blob/main/Input.md) [_src_](https://github.com/io-orig/System/blob/main/Input.Mod)
Module Input reads keyboard and mouse raw data and returns ASCII values and mouse state to Oberon.

Input uses SYSTEM



  **imports:** ` SYSTEM`



#### MODULE Display [_doc_](https://github.com/io-orig/System/blob/main/Display.md) [_src_](https://github.com/io-orig/System/blob/main/Display.Mod)
Module Display implements the drawing primitives for the frame buffer device in Oberon.

A pattern is an array of bytes; the first is its width (< 32), the second its height, the rest the raster data.


  **imports:** ` SYSTEM`



#### MODULE Viewers [_doc_](https://github.com/io-orig/System/blob/main/Viewers.md) [_src_](https://github.com/io-orig/System/blob/main/Viewers.Mod)
Module Viewers implements base functionaltiy which may be extended for interacting with a pane or 'Viewer' in Oberon.


  **imports:** ` Display`

## The Edit Package
This package manages the text and font handling in Oberon.

includes: [Edit.Mod](Edit.Mod) [Fonts.Mod](Fonts.Mod) [TextFrames.Mod](TextFrames.Mod) [Texts.Mod](Texts.Mod)  


## Package Overview:
The Edit package provides:

* The 'text' abstraction for manipulating textual content
* TextFrames for interacting with text via the GUI
* The Edit tool for interacting with documents
* The font mechanism in Oberon

## Package Use:

USAGE:
```
Edit.Open example.txt
```

## Modules in this package:

#### MODULE Edit [_doc_](https://github.com/io-orig/System/blob/main/Edit.md) [_src_](https://github.com/io-orig/System/blob/main/Edit.Mod)
Module Edit provides document editing capability.


  **imports:** ` Files Fonts Texts Display Viewers Oberon MenuViewers TextFrames`



#### MODULE Fonts [_doc_](https://github.com/io-orig/System/blob/main/Fonts.md) [_src_](https://github.com/io-orig/System/blob/main/Fonts.Mod)
Module Fonts provides the glyphs used by the Text system and the Graphics system to represent characters.


  **imports:** ` SYSTEM Files`



#### MODULE TextFrames [_doc_](https://github.com/io-orig/System/blob/main/TextFrames.md) [_src_](https://github.com/io-orig/System/blob/main/TextFrames.Mod)
Module TextFrames defines the messages and default handlers for text operations in panes in the Oberon user interface.


  **imports:** ` Modules Input Display Viewers Fonts Texts Oberon MenuViewers`



#### MODULE Texts [_doc_](https://github.com/io-orig/System/blob/main/Texts.md) [_src_](https://github.com/io-orig/System/blob/main/Texts.Mod)
Module Texts defines the 'text' abstract data type used pervasively in the Oberon system.


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
Module Math provides standard math functions in Oberon.




#### MODULE RISC [_doc_](https://github.com/io-orig/System/blob/main/RISC.md) [_src_](https://github.com/io-orig/System/blob/main/RISC.Mod)

  **imports:** ` SYSTEM Texts Oberon`



#### MODULE PIO [_doc_](https://github.com/io-orig/System/blob/main/PIO.md) [_src_](https://github.com/io-orig/System/blob/main/PIO.Mod)
Module PIO implements PIC input/output for RISC Oberon.


  **imports:** ` SYSTEM`



#### MODULE BootLoad [_doc_](https://github.com/io-orig/System/blob/main/BootLoad.md) [_src_](https://github.com/io-orig/System/blob/main/BootLoad.Mod)
Module BootLoad compiles to a binary to be placed in the firmware of a system that will boot to Oberon.


  **imports:** ` SYSTEM`


The System package collects the expected set of modules and tools that allows the Oberon user to perform typical computing tasks.


#### MODULE System [_doc_](https://github.com/io-orig/System/blob/main/System.md) [_src_](https://github.com/io-orig/System/blob/main/System.Mod)
Module System presents the Oberon user with tools and commands for interacting Displays and Tracks and Files and other miscelaneous features.


  **imports:** ` SYSTEM Kernel FileDir Files Modules


#### MODULE Tools [_doc_](https://github.com/io-orig/System/blob/main/Tools.md) [_src_](https://github.com/io-orig/System/blob/main/Tools.Mod)
Module Tools provides commands for inspecting memory, disk, etc.


  **imports:** ` SYSTEM Kernel Files Modules Input Texts Viewers MenuViewers TextFrames Oberon`



#### MODULE PCLink1 [_doc_](https://github.com/io-orig/System/blob/main/PCLink1.md) [_src_](https://github.com/io-orig/System/blob/main/PCLink1.Mod)
Module PCLink1 provides for serial connection between Oberon machines or Oberon and a host computer.


  **imports:** ` SYSTEM Files Texts Oberon`



#### MODULE RS232 [_doc_](https://github.com/io-orig/System/blob/main/RS232.md) [_src_](https://github.com/io-orig/System/blob/main/RS232.Mod)
Module RS232 provides for serial communications in RISC Oberon.


  **imports:** ` SYSTEM`



#### MODULE Net [_doc_](https://github.com/io-orig/System/blob/main/Net.md) [_src_](https://github.com/io-orig/System/blob/main/Net.Mod)
Module Net provides for client-server communication in Oberon.


  **imports:** ` SYSTEM SCC Files Viewers Texts TextFrames MenuViewers Oberon`



#### MODULE SCC [_doc_](https://github.com/io-orig/System/blob/main/SCC.md) [_src_](https://github.com/io-orig/System/blob/main/SCC.Mod)
Module SCC provides for wireless communication in RISC Oberon.


  **imports:** ` SYSTEM Kernel`



#### MODULE Batch [_doc_](https://github.com/io-orig/System/blob/main/Batch.md) [_src_](https://github.com/io-orig/System/blob/main/Batch.Mod)
Module Batch provides for automatic sequential execution of Oberon commands.

Module Batch provides for automatic sequential execution of Oberon commands.


  **imports:** ` Kernel FileDir Files Display Texts TextFrames Viewers Oberon`

## The Build Package
This package provides the compiler and associated program building and debugging tools for Oberon.

includes: [ORTool.Mod](ORTool.Mod) [ORB.Mod](ORB.Mod) [ORC.Mod](ORC.Mod) [ORG.Mod](ORG.Mod) [ORP.Mod](ORP.Mod) [ORS.Mod](ORS.Mod) [ODP.Mod](ODP.Mod) [ODG.Mod](ODG.Mod) [ORL.Mod](ORL.Mod)  



#### MODULE ORTool [_doc_](https://github.com/io-orig/System/blob/main/ORTool.md) [_src_](https://github.com/io-orig/System/blob/main/ORTool.Mod)
Module ORTool provides symbol file, module file, and loaded module reporting tools.

ORTool uses SYSTEM, Files, Modules, Texts, Oberon, ORB



  **imports:** ` SYSTEM Files Texts Oberon ORB`



#### MODULE ORB [_doc_](https://github.com/io-orig/System/blob/main/ORB.md) [_src_](https://github.com/io-orig/System/blob/main/ORB.Mod)
Module ORB manages the symbol table for the Oberon compiler and reads and writes 'smb' files

ORB uses Files, ORS



  **imports:** ` Files ORS`



#### MODULE ORC [_doc_](https://github.com/io-orig/System/blob/main/ORC.md) [_src_](https://github.com/io-orig/System/blob/main/ORC.Mod)

  **imports:** ` SYSTEM Files Texts Oberon V24`



#### MODULE ORG [_doc_](https://github.com/io-orig/System/blob/main/ORG.md) [_src_](https://github.com/io-orig/System/blob/main/ORG.Mod)
Module ORG generates the processor-specific instructions for executing an Oberon program. 

ORG uses SYSTEM, Files, ORS, ORB



  **imports:** ` SYSTEM Files ORS ORB`


## Package Overview:
Integrated Oberon uses a one-pass compiler with four parts, each depending on the next for functionaltiy:

 * A recursive-descent parser of the Oberon-2i language, ORP
 * A generator of target-specific opcodes (RISC5), ORG
 * A symbol table and frame tracker, ORB
 * A scanner and tokenizer, ORS

In addition, several tools link and examine the binary modules produced by the compiler:

 * A linker and loader, ORL
 * A binary modifier, ORX
 * A tool for examining modules, ORTool

## Package Use:

To compile the inner core:
```
ORP.Compile Kernel.Mod/s, Filedir.Mod/s, Files.Mod/s, Modules.Mod/s ~
```
To link the inner core modules into a bootable binary:
```
ORL.Link Modules ~
```
To Install the binary into the boot region of the current disk image:
```
ORL.Load Modules.bin ~
```
To compile an example module:
```
ORP.Compile Sierpinski.Mod ~
```
To examine the symbol file of the compiled example:
```
ORTool.DecSym Sierpinski.smb
```
To Examine the binary of the compiled example:
```
ORTool.DecObj Sierpinski.rsc
```

## Modules in this package:

#### MODULE ORP [_doc_](https://github.com/io-orig/System/blob/main/ORP.md) [_src_](https://github.com/io-orig/System/blob/main/ORP.Mod)

Module ORP reads the source code of an Oberon program and produces an executable binary module.


  **imports:** ` Texts Oberon ORS ORB ORG`



#### MODULE ORS [_doc_](https://github.com/io-orig/System/blob/main/ORS.md) [_src_](https://github.com/io-orig/System/blob/main/ORS.Mod)
Module ORS does lexical analysis of the Oberon source code and defines symbols and operations

ORS uses SYSTEM, Texts, Oberon



  **imports:** ` SYSTEM Texts Oberon`



#### MODULE ODP [_doc_](https://github.com/io-orig/System/blob/main/ODP.md) [_src_](https://github.com/io-orig/System/blob/main/ODP.Mod)

  **imports:** ` Texts Oberon ORS ORB ODG`



#### MODULE ODG [_doc_](https://github.com/io-orig/System/blob/main/ODG.md) [_src_](https://github.com/io-orig/System/blob/main/ODG.Mod)

  **imports:** ` SYSTEM Files ORS ORB`



#### MODULE ORL [_doc_](https://github.com/io-orig/System/blob/main/ORL.md) [_src_](https://github.com/io-orig/System/blob/main/ORL.Mod)
Module ORL links modules to create bin files that may be placed in the boot sectors of an Oberon disk image

ORL uses SYSTEM, Kernel, Disk, Files, Modules, Texts, Oberon


Module ORL links modules to create bin files that may be placed in the boot sectors of an Oberon disk image

ORL uses SYSTEM, Kernel, Files, Modules, Texts, Oberon



  **imports:** ` SYSTEM Kernel Files Modules Texts Oberon`

