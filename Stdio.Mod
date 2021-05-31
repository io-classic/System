(* begin-module-use-description
Module Stdio adapts streaming io to the Oberon text and viewers model.

end-module-use-description *)
(* begin-module-use-description
Module Stdio adapts streaming io to the Oberon text and viewers model.

end-module-use-description *)
MODULE Stdio;
  IMPORT Texts, Viewers, Oberon, TextFrames, MenuViewers, System, Edit;

  CONST

  TYPE
    Consumer* = PROCEDURE (T: Texts.Text; op: INTEGER; beg, end: LONGINT);
    Stream* = RECORD (* (Texts.Text)  *)
      consume*: Consumer;
      limit*: INTEGER;
    END;

    Flow* = POINTER TO FlowDesc;
    FlowDesc* = RECORD
      T*: Texts.Text;
      V*: Viewers.Viewer;
      X*, Y*: INTEGER;
      user*: BOOLEAN
    END;

  VAR


  PROCEDURE Open*(VAR F: Flow);
  BEGIN 
      IF F.user THEN
        Oberon.AllocateUserViewer(0, F.X, F.Y);
      ELSE
        Oberon.AllocateSystemViewer(0, F.X, F.Y);
      END;
      F.V := MenuViewers.New(
        TextFrames.NewMenu("MenuTitle", "System.Close System.Copy System.Grow Edit.Search Edit.Store"),
        TextFrames.NewText(TextFrames.Text("Title"), 0),
        TextFrames.menuH, F.X, F.Y)
  END Open;


BEGIN
END Stdio.

