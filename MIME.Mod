(* begin-module-use-description
Module MIME registers file or stream types and provides handlers.

end-module-use-description *)
(* begin-module-use-description
Module MIME registers file or stream types and provides handlers.

end-module-use-description *)
MODULE MIME;
  IMPORT SYSTEM;

  CONST

  TYPE
    Type* = POINTER TO TypeDesc;
    TypeDesc* = RECORD
	hash*: INTEGER;
        ext*: ARRAY 32 OF CHAR;
        next: Type
      END;

  VAR

  (* begin-procedure-description
---
**register** makes the mime type, its description, and its filename extension visible to the system.
  end-procedure-description *)
  PROCEDURE register( i:INTEGER; a, b, c: ARRAY OF CHAR);
  BEGIN 

  END register;


BEGIN   (* hash is first 32-bits of sha256 hash of "mime/type" *)
(*register(02FFAD8B9H,"aac","AAC audio","audio/aac");
  register(0FBD3B0B5H,"abw","AbiWord document","application/x-abiword");
  register(09A3438F8H,"arc","Archive document (multiple files embedded)","application/x-freearc");
  register(024D5F113H,"avi","AVI: Audio Video Interleave","video/x-msvideo");
  register(04DC98A89H,"azw","Amazon Kindle eBook format","application/vnd.amazon.ebook");          *)
  register(01E86D1BCH,"bin","Any kind of binary data","application/octet-stream");
(*register(0E31CC302H,"bmp","Windows OS/2 Bitmap Graphics","image/bmp");
  register(071D14950H,"bz","BZip archive","application/x-bzip");
  register(0FF54208AH,"bz2","BZip2 archive","application/x-bzip2");
  register(0B82CD285H,"csh","C-Shell script","application/x-csh");
  register(09D5584AFH,"css","Cascading Style Sheets (CSS)","text/css");                            *)
  register(05C9DAD24H,"csv","Comma-separated values (CSV)","text/csv");
(*register(0C4B6ABB2H,"doc","Microsoft Word","application/msword");
  register(097F77E8DH,"docx","Microsoft Word (OpenXML)","application/vnd.openxmlformats-officedocument.wordprocessingml.document");
  register(0051C75F1H,"eot","MS Embedded OpenType fonts","application/vnd.ms-fontobject");
  register(0E468E350H,"epub","Electronic publication (EPUB)","application/epub+zip");
  register(0E5040C0BH,"gz","GZip Compressed Archive","application/gzip");
  register(08ECC7C8AH,"gif","Graphics Interchange Format (GIF)","image/gif");
  register(0BB4770FFH,"htm","HyperText Markup Language (HTML)","text/html");
  register(0BB4770FFH,"html","HyperText Markup Language (HTML)","text/html");
  register(045B948FBH,"ico","Icon format","image/vnd.microsoft.icon");
  register(0E5B6F221H,"ics","iCalendar format","text/calendar");
  register(087821BB2H,"jar","Java Archive (JAR)","application/java-archive");
  register(0FD824FCEH,"jpeg","JPEG images","image/jpeg");
  register(0FD824FCEH,"jpg","JPEG images","image/jpeg");
  register(0A350D680H,"js","JavaScript","application/javascript");
  register(09620F374H,"Job","Batch Script","application/x-batch");
  register(0C1368464H,"Mod","Oberon Module","application/oberon");
  register(0BACB769BH,"json","JSON format","application/json");
  register(0CE807C5BH,"jsonld","JSON-LD format","application/ld+json");
  register(0C366452DH,"mid","Musical Instrument Digital Interface (MIDI)","audio/midi audio/x-midi");
  register(090676DB9H,"midi","Musical Instrument Digital Interface (MIDI)","audio/midi audio/x-midi");
  register(0C366452DH,"mjs","JavaScript module","application/javascript");
  register(090676DB9H,"mp3","MP3 audio","audio/mpeg");
  register(0A350D680H,"cda","CD audio","application/x-cdf");
  register(013B145D6H,"mp4","MP4 audio","video/mp4");
  register(021B7D849H,"mpeg","MPEG Video","video/mpeg");
  register(0F81CFBC7H,"mpkg","Apple Installer Package","application/vnd.apple.installer+xml");
  register(02DAE101CH,"odp","OpenDocument presentation document","application/vnd.oasis.opendocument.presentation");
  register(07C6E814CH,"ods","OpenDocument spreadsheet document","application/vnd.oasis.opendocument.spreadsheet");
  register(03C03C9C6H,"odt","OpenDocument text document","application/vnd.oasis.opendocument.text");
  register(0252A8B94H,"oga","OGG audio","audio/ogg");
  register(0714DBE37H,"ogv","OGG video","video/ogg");
  register(00B4E1B77H,"ogx","OGG","application/ogg");
  register(054C5C8CDH,"opus","Opus audio","audio/opus");
  register(08D603052H,"otf","OpenType font","font/otf");
  register(077CB52CAH,"png","Portable Network Graphics","image/png");
  register(003140723H,"pdf","Adobe Portable Document Format (PDF)","application/pdf");
  register(096485ABCH,"php","Hypertext Preprocessor (Personal Home Page)","application/x-httpd-php");
  register(091ED0F7CH,"ppt","Microsoft PowerPoint","application/vnd.ms-powerpoint");
  register(0A9E420DAH,"pptx","Microsoft PowerPoint (OpenXML)","application/vnd.openxmlformats-officedocument.presentationml.presentation");
  register(0AB3635ABH,"rar","RAR archive","application/vnd.rar");
  register(085EEE700H,"rtf","Rich Text Format (RTF)","application/rtf");
  register(0126E1140H,"sh","Bourne shell script","application/x-sh");                        *)
  register(0A5E57BB5H,"ssv","Space-separated values (SSV)","text/ssv");
(*register(07994679BH,"svg","Scalable Vector Graphics (SVG)","image/svg+xml");
  register(02757A93DH,"swf","Small web format (SWF) or Adobe Flash document","application/x-shockwave-flash");
  register(02EC1D238H,"tar","Tape Archive (TAR)","application/x-tar");
  register(091FBE07BH,"tif","Tagged Image File Format (TIFF)","image/tiff");
  register(0D790974CH,"tiff","Tagged Image File Format (TIFF)","image/tiff");
  register(064E75831H,"ts","MPEG transport stream","video/mp2t");                              *)
  register(064E75831H,"tsv","Tab-separated values (TSV)","text/tsv");
(*register(003FC7E49H,"ttf","TrueType Font","font/ttf");                                       *)
  register(05BBA5A11H,"txt","(generally ASCII or ISO 8859-n)","text/plain");
  register(09DDE7821H,"Text","Oberon Rich Text","text/oberon");
(*register(0DC239330H,"vsd","Microsoft Visio","application/vnd.visio");
  register(056E46C09H,"wav","Waveform Audio Format","audio/wav");
  register(0D16D6AE6H,"weba","WEBM audio","audio/webm");
  register(07FC478ABH,"webm","WEBM video","video/webm");
  register(0D1D124ADH,"webp","WEBP image","image/webp");
  register(0B560D0F4H,"woff","Web Open Font Format (WOFF)","font/woff");
  register(0EC142C80H,"woff2","Web Open Font Format (WOFF)","font/woff2");
  register(032FBA835H,"xhtml","XHTML","application/xhtml+xml");
  register(0B9D9F8A1H,"xls","Microsoft Excel","application/vnd.ms-excel");
  register(052F35A12H,"xlsx","Microsoft Excel (OpenXML)","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
  register(0DAEB1D6DH,"xml","XML","application/xml");
  register(06A9D557CH,"xml","XML","text/xml");
  register(0E77B9F33H,"xul","XUL","application/vnd.mozilla.xul+xml");
  register(01042EA9AH,"zip","ZIP archive","application/zip");
  register(0C6C0461EH,"3gp","3GPP audio/video container","video/3gpp");
  register(0960E0831H,"3gp","3GPP audio container","audio/3gpp");
  register(07EC022B2H,"3g2","3GPP2 audio/video container","video/3gpp2");
  register(09A1F3C6FH,"3gp","3GPP2 audio container","audio/3gpp2");
  register(015919828H,"7z","7-zip archive","application/x-7z-compressed");                        *)
END MIME.

