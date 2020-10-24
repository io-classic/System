(* begin-module-use-description
Module Viewers introduces rectangular areas of the display that present information and 
react to user input -- 'tracks' and 'viewers'.

end-module-use-description *)
(* begin-module-develop-description

(JG 14.9.90 / NW 15.9.2013)

**Viewers** introduces the core functionality for graphical interaction in Oberon.

Tracks are vertical columns of display space and viewers are partitions of that vertical space. 

Different kinds of viewers import this module and extend its functionality in specialized 
ways, e.g. MenuViewers for simple one-line menus of commands and TextViewers for text areas 
that can scroll, be edited, receive copy and paste, etc.

This module concerns itself with operations on all tracks and viewers including opening, closing, moving, hiding and restoring them.

This module also introduces the messages understood by viewers and provides the mechanism for locating viewers and dispatching messages to viewers.
end-module-develop-description *)
MODULE Viewers; (*JG 14.9.90 / NW 15.9.2013*)

  IMPORT Display;

  CONST 
    restore* = 0; modify* = 1; suspend* = 2; (*message ids*)
    inf = 65535;

  TYPE 
    Viewer* = POINTER TO ViewerDesc;
    ViewerDesc* = RECORD (Display.FrameDesc) state*: INTEGER END;

    (*state > 1: displayed; state = 1: filler; state = 0: closed; state < 0: suspended*)

    ViewerMsg* = RECORD (Display.FrameMsg)
        id*: INTEGER;
        X*, Y*, W*, H*: INTEGER;
        state*: INTEGER
      END;

    Track = POINTER TO TrackDesc;
    TrackDesc = RECORD (ViewerDesc) under: Display.Frame END;

  VAR 
    curW*, minH*, DH: INTEGER;
    FillerTrack: Track; FillerViewer,
    backup: Viewer; (*last closed viewer*)


  (* begin-section-description
## ---------- Viewer Operations
  end-section-description *)

  (* begin-procedure-description
---
**Open** opens a viewer.
  end-procedure-description *)
  PROCEDURE Open* (V: Viewer; X, Y: INTEGER);
    VAR T, u, v: Display.Frame; M: ViewerMsg;
  BEGIN
    IF (V.state = 0) & (X < inf) THEN
      IF Y > DH THEN Y := DH END;
      T := FillerTrack.next;
      WHILE X >= T.X + T.W DO T := T.next END;
      u := T.dsc; v := u.next;
      WHILE Y > v.Y + v.H DO u := v; v := u.next END;
      IF Y < v.Y + minH THEN Y := v.Y + minH END;
      IF (v.next.Y # 0) & (Y > v.Y + v.H - minH) THEN
        V.X := T.X; V.W := T.W; V.Y := v.Y; V.H := v.H;
        M.id := suspend; M.state := 0;
        v.handle(v, M); v(Viewer).state := 0;
        V.next := v.next; u.next := V; V.state := 2
      ELSE V.X := T.X; V.W := T.W; V.Y := v.Y; V.H := Y - v.Y;
        M.id := modify; M.Y := Y; M.H := v.Y + v.H - Y;
        v.handle(v, M); v.Y := M.Y; v.H := M.H;
        V.next := v; u.next := V; V.state := 2
      END
    END
  END Open;

  (* begin-procedure-description 
---
**Change** adjusts the vertical position of the viewer.
  end-procedure-description *)
  PROCEDURE Change* (V: Viewer; Y: INTEGER);
    VAR v: Display.Frame; M: ViewerMsg;
  BEGIN
    IF V.state > 1 THEN
      IF Y > DH THEN Y := DH END;
      v := V.next;
      IF (v.next.Y # 0) & (Y > v.Y + v.H - minH) THEN Y := v.Y + v.H - minH END;
      IF Y >= V.Y + minH THEN
        M.id := modify; M.Y := Y; M.H := v.Y + v.H - Y;
        v.handle(v, M); v.Y := M.Y; v.H := M.H; V.H := Y - V.Y
      END
    END
  END Change;

  (* begin-procedure-description 
---
**RestoreTrack** brings back a track that was obscured by an expanded viewer.
  end-procedure-description *)
  PROCEDURE RestoreTrack (S: Display.Frame);
    VAR T, t, v: Display.Frame; M: ViewerMsg;
  BEGIN t := S.next;
    WHILE t.next # S DO t := t.next END;
    T := S(Track).under;
    WHILE T.next # NIL DO T := T.next END;
    t.next := S(Track).under; T.next := S.next; M.id := restore;
    REPEAT t := t.next; v := t.dsc;
      REPEAT v := v.next; v.handle(v, M); v(Viewer).state := - v(Viewer).state
      UNTIL v = t.dsc
    UNTIL t = T
  END RestoreTrack;

  (* begin-procedure-description 
---
**Close** removes a viewer from the track.
  end-procedure-description *)
  PROCEDURE Close* (V: Viewer);
    VAR T, U: Display.Frame; M: ViewerMsg;
  BEGIN
    IF V.state > 1 THEN
      U := V.next; T := FillerTrack;
      REPEAT T := T.next UNTIL V.X < T.X + T.W;
      IF (T(Track).under = NIL) OR (U.next # V) THEN
        M.id := suspend; M.state := 0;
        V.handle(V, M); V.state := 0; backup := V;
        M.id := modify; M.Y := V.Y; M.H := V.H + U.H;
        U.handle(U, M); U.Y := M.Y; U.H := M.H;
        WHILE U.next # V DO U := U.next END;
        U.next := V.next
      ELSE (*close track*)
        M.id := suspend; M.state := 0;
        V.handle(V, M); V.state := 0; backup := V;
        U.handle(U, M); U(Viewer).state := 0;
        RestoreTrack(T)
      END
    END
  END Close;

  (* begin-procedure-description 
---
**Recall** brings back a closed viewer.
  end-procedure-description *)
  PROCEDURE Recall* (VAR V: Viewer);
  BEGIN V := backup
  END Recall;

  (* begin-procedure-description 
---
**This** identifies the viewer containing the coordinates.
  end-procedure-description *)
  PROCEDURE This* (X, Y: INTEGER): Viewer;
    VAR T, V: Display.Frame;
  BEGIN
    IF (X < inf) & (Y < DH) THEN
      T := FillerTrack;
      REPEAT T := T.next UNTIL X < T.X + T.W;
      V := T.dsc;
      REPEAT V := V.next UNTIL Y < V.Y + V.H
    ELSE V := NIL
    END ;
    RETURN V(Viewer)
  END This;

  (* begin-procedure-description 
---
**Next** returns the next viewer in the global viewer list.
  end-procedure-description *)
  PROCEDURE Next* (V: Viewer): Viewer;
  BEGIN RETURN V.next(Viewer)
  END Next;

  (* begin-procedure-description 
---
**Locate** finds ??
  end-procedure-description *)
  PROCEDURE Locate* (X, H: INTEGER; VAR fil, bot, alt, max: Display.Frame);
    VAR T, V: Display.Frame;
  BEGIN
    IF X < inf THEN
      T := FillerTrack;
      REPEAT T := T.next UNTIL X < T.X + T.W;
      fil := T.dsc; bot := fil.next;
      IF bot.next # fil THEN
        alt := bot.next; V := alt.next;
        WHILE (V # fil) & (alt.H < H) DO
          IF V.H > alt.H THEN alt := V END;
          V := V.next
        END
      ELSE alt := bot
      END;
      max := T.dsc; V := max.next;
      WHILE V # fil DO
        IF V.H > max.H THEN max := V END;
        V := V.next
      END
    END
  END Locate;

  (* begin-procedure-description 
---
**InitTrack** prepares a track to accept viewers.
  end-procedure-description *)
  PROCEDURE InitTrack* (W, H: INTEGER; Filler: Viewer);
    VAR S: Display.Frame; T: Track;
  BEGIN
    IF Filler.state = 0 THEN
      Filler.X := curW; Filler.W := W; Filler.Y := 0; Filler.H := H;
      Filler.state := 1; Filler.next := Filler;
      NEW(T); T.X := curW; T.W := W; T.Y := 0; T.H := H; T.dsc := Filler; T.under := NIL;
      FillerViewer.X := curW + W; FillerViewer.W := inf - FillerViewer.X;
      FillerTrack.X := FillerViewer.X; FillerTrack.W := FillerViewer.W;
      S := FillerTrack;
      WHILE S.next # FillerTrack DO S := S.next END;
      S.next := T; T.next := FillerTrack; curW := curW + W
    END
  END InitTrack;

  (* begin-procedure-description 
---
**OpenTrack** places the track on the screen.
  end-procedure-description *)
  PROCEDURE OpenTrack* (X, W: INTEGER; Filler: Viewer);
    VAR newT: Track; S, T, t, v: Display.Frame; M: ViewerMsg; v0: Viewer;
  BEGIN
    IF (X < inf) & (Filler.state = 0) THEN
      S := FillerTrack; T := S.next;
      WHILE X >= T.X + T.W DO S := T; T := S.next END;
      WHILE X + W > T.X + T.W DO T := T.next END;
      M.id := suspend; t := S;
      REPEAT t := t.next; v := t.dsc;
        REPEAT v := v.next; M.state := -v(Viewer).state; v.handle(v, M); v(Viewer).state := M.state
        UNTIL v = t.dsc
      UNTIL t = T;
      Filler.X := S.next.X; Filler.W := T.X + T.W - S.next.X; Filler.Y := 0; Filler.H := DH;
      Filler.state := 1; Filler.next := Filler;
      NEW(newT); newT.X := Filler.X; newT.W := Filler.W; newT.Y := 0; newT.H := DH;
      newT.dsc := Filler; newT.under := S.next; S.next := newT;
      newT.next := T.next; T.next := NIL
    END
  END OpenTrack;

  (* begin-procedure-description 
---
**CloseTrack** removes the track from the screen.
  end-procedure-description *)
  PROCEDURE CloseTrack* (X: INTEGER);
    VAR T, V: Display.Frame; M: ViewerMsg;
  BEGIN
    IF X < inf THEN
      T := FillerTrack;
      REPEAT T := T.next UNTIL X < T.X + T.W;
      IF T(Track).under # NIL THEN
        M.id := suspend; M.state := 0; V := T.dsc;
        REPEAT V := V.next; V.handle(V, M); V(Viewer).state := 0 UNTIL V = T.dsc;
        RestoreTrack(T)
      END
    END
  END CloseTrack;

  (* begin-procedure-description 
---
**Broadcast** sends a message to all frames.
  end-procedure-description *)
  PROCEDURE Broadcast* (VAR M: Display.FrameMsg);
    VAR T, V: Display.Frame;
  BEGIN T := FillerTrack.next;
    WHILE T # FillerTrack DO
      V := T.dsc; 
      REPEAT V := V.next; V.handle(V, M) UNTIL V = T.dsc;
      T := T.next
    END
  END Broadcast;

  (* begin-procedure-description
---
**The initialzation code for this module** initializes empty tracks for use later by the System module and user programs.
  end-procedure-description *)
BEGIN backup := NIL; curW := 0; minH := 1; DH := Display.Height;
  NEW(FillerViewer); FillerViewer.X := 0; FillerViewer.W := inf; FillerViewer.Y := 0; FillerViewer.H := DH;
  FillerViewer.next := FillerViewer;
  NEW(FillerTrack);
  FillerTrack.X := 0; FillerTrack.W := inf; FillerTrack.Y := 0; FillerTrack.H := DH;
  FillerTrack.dsc := FillerViewer; FillerTrack.next := FillerTrack
END Viewers.
