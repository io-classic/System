# Packages

| Package |          |
| ------- | -------- |
| [Kernel](README.md#the-Kernel-package) | handles basic os functionality including startup |
|   | [Kernel.Mod](README.md#KernelMod-doc-src) [BootLoad.Mod](README.md#BootLoadMod-doc-src)  |
| [Files](README.md#the-Files-package) | handles persistent storage and the file and directory interface of Oberon. |
|   | [FileDir.Mod](README.md#FileDirMod-doc-src) [Files.Mod](README.md#FilesMod-doc-src)  |
| [Modules](README.md#the-Modules-package) | manages compiled module loading and unloading in Oberon. |
|   | [Modules.Mod](README.md#ModulesMod-doc-src)  |
| [Oberon](README.md#the-Oberon-package) | implements the user-interaction functionality and the task loop of the system. |
|   | [Oberon.Mod](README.md#OberonMod-doc-src) [MenuViewers.Mod](README.md#MenuViewersMod-doc-src) [Viewers.Mod](README.md#ViewersMod-doc-src) [Input.Mod](README.md#InputMod-doc-src) [Display.Mod](README.md#DisplayMod-doc-src)  |
| [Edit](README.md#the-Edit-package) | manages the text and font handling in Oberon. |
|   | [Edit.Mod](README.md#EditMod-doc-src) [Fonts.Mod](README.md#FontsMod-doc-src) [TextFrames.Mod](README.md#TextFramesMod-doc-src) [Texts.Mod](README.md#TextsMod-doc-src)  |
| [Draw](README.md#the-Draw-package) | provides line-oriented drawing primitives and a vector drawing tool. |
|   | [Draw.Mod](README.md#DrawMod-doc-src) [Graphics.Mod](README.md#GraphicsMod-doc-src) [MacroTool.Mod](README.md#MacroToolMod-doc-src) [GraphicFrames.Mod](README.md#GraphicFramesMod-doc-src) [GraphTool.Mod](README.md#GraphToolMod-doc-src) [Rectangles.Mod](README.md#RectanglesMod-doc-src) [Curves.Mod](README.md#CurvesMod-doc-src)  |
| [System](README.md#the-System-package) | prepares the user interface and manages viewers for the user. |
|   | [System.Mod](README.md#SystemMod-doc-src) [PIO.Mod](README.md#PIOMod-doc-src) [Tools.Mod](README.md#ToolsMod-doc-src) [PCLink1.Mod](README.md#PCLink1Mod-doc-src) [RS232.Mod](README.md#RS232Mod-doc-src) [Net.Mod](README.md#NetMod-doc-src) [SCC.Mod](README.md#SCCMod-doc-src) [Batch.Mod](README.md#BatchMod-doc-src)  |
| [Build](README.md#the-Build-package) | provides the compiler and associated program building and debugging tools for Oberon. |
|   | [ORP.Mod](README.md#ORPMod-doc-src) [ORG.Mod](README.md#ORGMod-doc-src) [ORB.Mod](README.md#ORBMod-doc-src) [ORS.Mod](README.md#ORSMod-doc-src) [ORTool.Mod](README.md#ORToolMod-doc-src) [ORC.Mod](README.md#ORCMod-doc-src) [ODP.Mod](README.md#ODPMod-doc-src) [ODG.Mod](README.md#ODGMod-doc-src) [ORL.Mod](README.md#ORLMod-doc-src)  |
| [Extras](README.md#the-Extras-package) | contains extra modules demonstrating Oberon. |
|   | [Blink.Mod](README.md#BlinkMod-doc-src) [Math.Mod](README.md#MathMod-doc-src) [RISC.Mod](README.md#RISCMod-doc-src) [Sierpinski.Mod](README.md#SierpinskiMod-doc-src) [Hilbert.Mod](README.md#HilbertMod-doc-src) [Checkers.Mod](README.md#CheckersMod-doc-src)  |

---
## The Kernel Package
includes: [Kernel.Mod](README.md#KernelMod-doc-src) [BootLoad.Mod](README.md#BootLoadMod-doc-src)  

### _Package Overview:_
The Kernel package abstracts the hardware of the computing platform for the rest of Oberon.


### _Package Use:_

USAGE:
```
Kernel.Collect 
```

### _Modules in this package:_

#### Kernel.Mod [_doc_](https://github.com/io-orig/System/blob/main/Kernel.md) [_src_](https://github.com/io-orig/System/blob/main/Kernel.Mod)
Module Kernel provides hardware abstraction for Oberon.


  **imports:** ` SYSTEM`



#### BootLoad.Mod [_doc_](https://github.com/io-orig/System/blob/main/BootLoad.md) [_src_](https://github.com/io-orig/System/blob/main/BootLoad.Mod)
Module BootLoad is the firmware for the RISC Oberon platform.

    ORP.Compile BootLoad.Mod ~
    ORF.WriteFile BootLoad.rsc prom.mem ~                      


  **imports:** ` SYSTEM`

---
## The Files Package
includes: [FileDir.Mod](README.md#FileDirMod-doc-src) [Files.Mod](README.md#FilesMod-doc-src)  

### _Package Overview:_
The Files package provides:

* Directory operations
* File i/o

### _Package Use:_

USAGE:
```
F := Files.New("newfile.txt")
```

### _Modules in this package:_

#### FileDir.Mod [_doc_](https://github.com/io-orig/System/blob/main/FileDir.md) [_src_](https://github.com/io-orig/System/blob/main/FileDir.Mod)
Module FileDir manages the on-disk representation if directories.

Regular programs do not use FileDir but instead use the api presented by Files which uses FileDir on their behalf.


  **imports:** ` SYSTEM Kernel`



#### Files.Mod [_doc_](https://github.com/io-orig/System/blob/main/Files.md) [_src_](https://github.com/io-orig/System/blob/main/Files.Mod)
Module Files manages the on-disk representation of files and the file api presented to Oberon programs.


  **imports:** ` SYSTEM Kernel FileDir`

---
## The Modules Package
includes: [Modules.Mod](README.md#ModulesMod-doc-src)  

### _Package Overview:_
The Modules package manages the module heap, the loading and unloading of packages, etc.


### _Package Use:_

USAGE:
```
Modules.Load("something",M)
```

### _Modules in this package:_

#### Modules.Mod [_doc_](https://github.com/io-orig/System/blob/main/Modules.md) [_src_](https://github.com/io-orig/System/blob/main/Modules.Mod)
Module Modules is the heart of how separately compiled Oberon programs are loaded and linked.


  **imports:** ` SYSTEM Files`

---
## The Oberon Package
includes: [Oberon.Mod](README.md#OberonMod-doc-src) [MenuViewers.Mod](README.md#MenuViewersMod-doc-src) [Viewers.Mod](README.md#ViewersMod-doc-src) [Input.Mod](README.md#InputMod-doc-src) [Display.Mod](README.md#DisplayMod-doc-src)  


#### Oberon.Mod [_doc_](https://github.com/io-orig/System/blob/main/Oberon.md) [_src_](https://github.com/io-orig/System/blob/main/Oberon.Mod)
### _Package Overview:_
Module Oberon establishes the messaging and callback system for implementing the extensible user interface of Oberon.

### _Package Use:_

### _Modules in this package:_

  **imports:** ` SYSTEM Kernel Files Modules Input Display Viewers Fonts Texts`



#### MenuViewers.Mod [_doc_](https://github.com/io-orig/System/blob/main/MenuViewers.md) [_src_](https://github.com/io-orig/System/blob/main/MenuViewers.Mod)
Module MenuViewers implements the top-of-pane 'menu' functionality of the Oberon user interface. 

MenuViewers uses Input, Display, Viewers, Oberon



  **imports:** ` Input Display Viewers Oberon`



#### Viewers.Mod [_doc_](https://github.com/io-orig/System/blob/main/Viewers.md) [_src_](https://github.com/io-orig/System/blob/main/Viewers.Mod)
Module Viewers implements base functionaltiy which may be extended for interacting with a pane or 'Viewer' in Oberon.


  **imports:** ` Display`



#### Input.Mod [_doc_](https://github.com/io-orig/System/blob/main/Input.md) [_src_](https://github.com/io-orig/System/blob/main/Input.Mod)
Module Input reads keyboard and mouse raw data and returns ASCII values and mouse state to Oberon.

Input uses SYSTEM



  **imports:** ` SYSTEM`



#### Display.Mod [_doc_](https://github.com/io-orig/System/blob/main/Display.md) [_src_](https://github.com/io-orig/System/blob/main/Display.Mod)
Module Display implements the drawing primitives for the frame buffer device in Oberon.

A pattern is an array of bytes; the first is its width (< 32), the second its height, the rest the raster data.


  **imports:** ` SYSTEM`

---
## The Edit Package
includes: [Edit.Mod](README.md#EditMod-doc-src) [Fonts.Mod](README.md#FontsMod-doc-src) [TextFrames.Mod](README.md#TextFramesMod-doc-src) [Texts.Mod](README.md#TextsMod-doc-src)  

### _Package Overview:_
The Edit package provides:

* The 'text' abstraction for manipulating textual content
* TextFrames for interacting with text via the GUI
* The Edit tool for interacting with documents
* The font mechanism in Oberon

### _Package Use:_

USAGE:
```
Edit.Open example.txt
```

### _Modules in this package:_

#### Edit.Mod [_doc_](https://github.com/io-orig/System/blob/main/Edit.md) [_src_](https://github.com/io-orig/System/blob/main/Edit.Mod)
Module Edit provides document editing capability.


  **imports:** ` Files Fonts Texts Display Viewers Oberon MenuViewers TextFrames`



#### Fonts.Mod [_doc_](https://github.com/io-orig/System/blob/main/Fonts.md) [_src_](https://github.com/io-orig/System/blob/main/Fonts.Mod)
Module Fonts provides the glyphs used by the Text system and the Graphics system to represent characters.


  **imports:** ` SYSTEM Files`



#### TextFrames.Mod [_doc_](https://github.com/io-orig/System/blob/main/TextFrames.md) [_src_](https://github.com/io-orig/System/blob/main/TextFrames.Mod)
Module TextFrames defines the messages and default handlers for text operations in panes in the Oberon user interface.


  **imports:** ` Modules Input Display Viewers Fonts Texts Oberon MenuViewers`



#### Texts.Mod [_doc_](https://github.com/io-orig/System/blob/main/Texts.md) [_src_](https://github.com/io-orig/System/blob/main/Texts.Mod)
Module Texts defines the 'text' abstract data type used pervasively in the Oberon system.


  **imports:** ` Files Fonts`

---
## The Draw Package
includes: [Draw.Mod](README.md#DrawMod-doc-src) [Graphics.Mod](README.md#GraphicsMod-doc-src) [MacroTool.Mod](README.md#MacroToolMod-doc-src) [GraphicFrames.Mod](README.md#GraphicFramesMod-doc-src) [GraphTool.Mod](README.md#GraphToolMod-doc-src) [Rectangles.Mod](README.md#RectanglesMod-doc-src) [Curves.Mod](README.md#CurvesMod-doc-src)  

### _Package Overview:_
The Draw package provides:


### _Package Use:_

USAGE:
```
Draw.Open example.x
```

### _Modules in this package:_

#### Draw.Mod [_doc_](https://github.com/io-orig/System/blob/main/Draw.md) [_src_](https://github.com/io-orig/System/blob/main/Draw.Mod)
Module Edit provides document editing capability.


  **imports:** ` Files Fonts Viewers Texts Oberon


#### Graphics.Mod [_doc_](https://github.com/io-orig/System/blob/main/Graphics.md) [_src_](https://github.com/io-orig/System/blob/main/Graphics.Mod)

  **imports:** ` SYSTEM Files Modules Fonts (*Printer*) Texts Oberon`



#### MacroTool.Mod [_doc_](https://github.com/io-orig/System/blob/main/MacroTool.md) [_src_](https://github.com/io-orig/System/blob/main/MacroTool.Mod)

  **imports:** ` Texts Oberon Graphics GraphicFrames`



#### GraphicFrames.Mod [_doc_](https://github.com/io-orig/System/blob/main/GraphicFrames.md) [_src_](https://github.com/io-orig/System/blob/main/GraphicFrames.Mod)

  **imports:** ` SYSTEM Display Viewers Input Fonts Texts Graphics Oberon MenuViewers`



#### GraphTool.Mod [_doc_](https://github.com/io-orig/System/blob/main/GraphTool.md) [_src_](https://github.com/io-orig/System/blob/main/GraphTool.Mod)

  **imports:** ` Files Texts Oberon`



#### Rectangles.Mod [_doc_](https://github.com/io-orig/System/blob/main/Rectangles.md) [_src_](https://github.com/io-orig/System/blob/main/Rectangles.Mod)

  **imports:** ` SYSTEM Display Files Input Texts Oberon Graphics GraphicFrames`



#### Curves.Mod [_doc_](https://github.com/io-orig/System/blob/main/Curves.md) [_src_](https://github.com/io-orig/System/blob/main/Curves.Mod)

  **imports:** ` Display Files Oberon Graphics GraphicFrames`

---
## The System Package
includes: [System.Mod](README.md#SystemMod-doc-src) [PIO.Mod](README.md#PIOMod-doc-src) [Tools.Mod](README.md#ToolsMod-doc-src) [PCLink1.Mod](README.md#PCLink1Mod-doc-src) [RS232.Mod](README.md#RS232Mod-doc-src) [Net.Mod](README.md#NetMod-doc-src) [SCC.Mod](README.md#SCCMod-doc-src) [Batch.Mod](README.md#BatchMod-doc-src)  

### _Package Overview:_
The System package collects the expected set of modules and tools that allows the Oberon user to perform typical computing tasks.

### _Package Use:_

### _Modules in this package:_

#### System.Mod [_doc_](https://github.com/io-orig/System/blob/main/System.md) [_src_](https://github.com/io-orig/System/blob/main/System.Mod)
Module System presents the Oberon user with tools and commands for interacting Displays and Tracks and Files and other miscelaneous features.


  **imports:** ` SYSTEM Kernel FileDir Files Modules


#### PIO.Mod [_doc_](https://github.com/io-orig/System/blob/main/PIO.md) [_src_](https://github.com/io-orig/System/blob/main/PIO.Mod)
Module PIO implements PIC input/output for RISC Oberon.


  **imports:** ` SYSTEM`



#### Tools.Mod [_doc_](https://github.com/io-orig/System/blob/main/Tools.md) [_src_](https://github.com/io-orig/System/blob/main/Tools.Mod)
Module Tools provides commands for inspecting memory, disk, etc.


  **imports:** ` SYSTEM Kernel Files Modules Input Texts Viewers MenuViewers TextFrames Oberon`



#### PCLink1.Mod [_doc_](https://github.com/io-orig/System/blob/main/PCLink1.md) [_src_](https://github.com/io-orig/System/blob/main/PCLink1.Mod)
Module PCLink1 provides for serial connection between Oberon machines or Oberon and a host computer.


  **imports:** ` SYSTEM Files Texts Oberon`



#### RS232.Mod [_doc_](https://github.com/io-orig/System/blob/main/RS232.md) [_src_](https://github.com/io-orig/System/blob/main/RS232.Mod)
Module RS232 provides for serial communications in RISC Oberon.


  **imports:** ` SYSTEM`



#### Net.Mod [_doc_](https://github.com/io-orig/System/blob/main/Net.md) [_src_](https://github.com/io-orig/System/blob/main/Net.Mod)
Module Net provides for client-server communication in Oberon.


  **imports:** ` SYSTEM SCC Files Viewers Texts TextFrames MenuViewers Oberon`



#### SCC.Mod [_doc_](https://github.com/io-orig/System/blob/main/SCC.md) [_src_](https://github.com/io-orig/System/blob/main/SCC.Mod)
Module SCC provides for wireless communication in RISC Oberon.


  **imports:** ` SYSTEM Kernel`



#### Batch.Mod [_doc_](https://github.com/io-orig/System/blob/main/Batch.md) [_src_](https://github.com/io-orig/System/blob/main/Batch.Mod)
Module Batch provides for automatic sequential execution of Oberon commands.

Module Batch provides for automatic sequential execution of Oberon commands.


  **imports:** ` Kernel FileDir Files Display Texts TextFrames Viewers Oberon`

---
## The Build Package
includes: [ORP.Mod](README.md#ORPMod-doc-src) [ORG.Mod](README.md#ORGMod-doc-src) [ORB.Mod](README.md#ORBMod-doc-src) [ORS.Mod](README.md#ORSMod-doc-src) [ORTool.Mod](README.md#ORToolMod-doc-src) [ORC.Mod](README.md#ORCMod-doc-src) [ODP.Mod](README.md#ODPMod-doc-src) [ODG.Mod](README.md#ODGMod-doc-src) [ORL.Mod](README.md#ORLMod-doc-src)  

### _Package Overview:_
Integrated Oberon uses a one-pass compiler with four parts, each depending on the next for functionaltiy:

 * A recursive-descent parser of the Oberon language, ORP
 * A generator of target-specific opcodes (RISC5), ORG
 * A symbol table and frame tracker, ORB
 * A scanner and tokenizer, ORS

In addition, several tools link and examine the binary modules produced by the compiler:

 * A linker and loader, ORL
 * A bootload firmware generator, ORF
 * A tool for examining modules, ORTool

### _Package Use:_

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

### _Modules in this package:_

#### ORP.Mod [_doc_](https://github.com/io-orig/System/blob/main/ORP.md) [_src_](https://github.com/io-orig/System/blob/main/ORP.Mod)

Module ORP reads the source code of an Oberon program and produces an executable binary module.


  **imports:** ` Texts Oberon ORS ORB ORG`



#### ORG.Mod [_doc_](https://github.com/io-orig/System/blob/main/ORG.md) [_src_](https://github.com/io-orig/System/blob/main/ORG.Mod)
Module ORG generates the processor-specific instructions for executing an Oberon program. 

ORG uses SYSTEM, Files, ORS, ORB



  **imports:** ` SYSTEM Files ORS ORB`



#### ORB.Mod [_doc_](https://github.com/io-orig/System/blob/main/ORB.md) [_src_](https://github.com/io-orig/System/blob/main/ORB.Mod)
Module ORB manages the symbol table for the Oberon compiler and reads and writes 'smb' files

ORB uses Files, ORS



  **imports:** ` Files ORS`



#### ORS.Mod [_doc_](https://github.com/io-orig/System/blob/main/ORS.md) [_src_](https://github.com/io-orig/System/blob/main/ORS.Mod)
Module ORS does lexical analysis of the Oberon source code and defines symbols and operations

ORS uses SYSTEM, Texts, Oberon



  **imports:** ` SYSTEM Texts Oberon`



#### ORTool.Mod [_doc_](https://github.com/io-orig/System/blob/main/ORTool.md) [_src_](https://github.com/io-orig/System/blob/main/ORTool.Mod)
Module ORTool provides symbol file, module file, and loaded module reporting tools.

ORTool uses SYSTEM, Files, Modules, Texts, Oberon, ORB



  **imports:** ` SYSTEM Files Texts Oberon ORB`



#### ORC.Mod [_doc_](https://github.com/io-orig/System/blob/main/ORC.md) [_src_](https://github.com/io-orig/System/blob/main/ORC.Mod)

  **imports:** ` SYSTEM Files Texts Oberon V24`



#### ODP.Mod [_doc_](https://github.com/io-orig/System/blob/main/ODP.md) [_src_](https://github.com/io-orig/System/blob/main/ODP.Mod)

  **imports:** ` Texts Oberon ORS ORB ODG`



#### ODG.Mod [_doc_](https://github.com/io-orig/System/blob/main/ODG.md) [_src_](https://github.com/io-orig/System/blob/main/ODG.Mod)

  **imports:** ` SYSTEM Files ORS ORB`



#### ORL.Mod [_doc_](https://github.com/io-orig/System/blob/main/ORL.md) [_src_](https://github.com/io-orig/System/blob/main/ORL.Mod)
Module ORL links modules to create bin files that may be placed in the boot sectors of an Oberon disk image

ORL uses SYSTEM, Kernel, Disk, Files, Modules, Texts, Oberon


Module ORL links modules to create bin files that may be placed in the boot sectors of an Oberon disk image

ORL uses SYSTEM, Kernel, Files, Modules, Texts, Oberon



  **imports:** ` SYSTEM Kernel Files Modules Texts Oberon`

---
## The Extras Package
includes: [Blink.Mod](README.md#BlinkMod-doc-src) [Math.Mod](README.md#MathMod-doc-src) [RISC.Mod](README.md#RISCMod-doc-src) [Sierpinski.Mod](README.md#SierpinskiMod-doc-src) [Hilbert.Mod](README.md#HilbertMod-doc-src) [Checkers.Mod](README.md#CheckersMod-doc-src)  

### _Package Overview:_
The Extras package provides:

Example modules demonstrating the use of Oberon.

### _Package Use:_

USAGE:
```
Blink.Run
```

### _Modules in this package:_

#### Blink.Mod [_doc_](https://github.com/io-orig/System/blob/main/Blink.md) [_src_](https://github.com/io-orig/System/blob/main/Blink.Mod)
Module Edit provides document editing capability.


  **imports:** ` SYSTEM Oberon`



#### Math.Mod [_doc_](https://github.com/io-orig/System/blob/main/Math.md) [_src_](https://github.com/io-orig/System/blob/main/Math.Mod)
Module Math provides standard math functions in Oberon.




#### RISC.Mod [_doc_](https://github.com/io-orig/System/blob/main/RISC.md) [_src_](https://github.com/io-orig/System/blob/main/RISC.Mod)

  **imports:** ` SYSTEM Texts Oberon`



#### Sierpinski.Mod [_doc_](https://github.com/io-orig/System/blob/main/Sierpinski.md) [_src_](https://github.com/io-orig/System/blob/main/Sierpinski.Mod)

  **imports:** ` Display Viewers Oberon MenuViewers TextFrames`



#### Hilbert.Mod [_doc_](https://github.com/io-orig/System/blob/main/Hilbert.md) [_src_](https://github.com/io-orig/System/blob/main/Hilbert.Mod)

  **imports:** ` Display Viewers Texts Oberon MenuViewers TextFrames`



#### Checkers.Mod [_doc_](https://github.com/io-orig/System/blob/main/Checkers.md) [_src_](https://github.com/io-orig/System/blob/main/Checkers.Mod)

  **imports:** ` SYSTEM Display Viewers Oberon MenuViewers TextFrames`

