unit KopDraw1;

interface

uses
  DGraph, Diagrams, Graphics, Classes;

type
   TPodLiniaDiagFun = class (TDiagFunDrawer)
    private
      FQ, FH :Double;
    protected
      procedure DrawFun( dt :TSpecDrawData; bw :Boolean );   override;
    public
      property Q: Double   read FQ  write FQ;
      property H: Double   read FH  write FH;
  end;
  TLiniaDiagFun = class (TDiagFunDrawer)
    private
      FQ, FH :Double;
    protected
      procedure DrawFun( dt :TSpecDrawData; bw :Boolean );   override;
    public
      property Q: Double   read FQ  write FQ;
      property H: Double   read FH  write FH;
  end;
  TPompkaDiagFun = class (TDiagFunDrawer)
    private
      FQ, FH :Double;
    protected
      procedure DrawFun( dt :TSpecDrawData; bw :Boolean );   override;
    public
      property Q: Double   read FQ  write FQ;
      property H: Double   read FH  write FH;
  end;

  TPntDiagFun = class (TDiagFunDrawer)
    private
      FQ, FH :Double;
      procedure SetQ ( v :Double );
      procedure SetH ( v :Double );
    protected
      procedure DrawFun( dt :TSpecDrawData; bw :Boolean );   override;
    public
      property Q: Double   read FQ  write SetQ;
      property H: Double   read FH  write SetH;
  end;

  TTolDiagFun = class (TDiagFunDrawer)
    private
      FQ, FH :Double;
      FQMinTol : Double;
      FQMaxTol : Double;
      FHMinTol : Double;
      FHMaxTol : Double;
      procedure SetQ ( v :Double );
      procedure SetH ( v :Double );
      procedure SetQMinTol ( v :Double );
      procedure SetQMaxTol ( v :Double );
      procedure SetHMinTol ( v :Double );
      procedure SetHMaxTol ( v :Double );
    protected
      procedure DrawFun( dt :TSpecDrawData; bw :Boolean );   override;
    public
      property Q: Double   read FQ  write SetQ;
      property H: Double   read FH  write SetH;
      property QMinTol : Double   read FQMinTol  write SetQMinTol;
      property QMaxTol : Double   read FQMaxTol  write SetQMaxTol;
      property HMinTol : Double   read FHMinTol  write SetHMinTol;
      property HMaxTol : Double   read FHMaxTol  write SetHMaxTol;
  end;


implementation

procedure TPntDiagFun.DrawFun( dt :TSpecDrawData; bw :Boolean );
var
  X, Y    :TCanvCoord;
begin
  dt.ConvPointRPar( Q, H, X, Y );
  dt.Canvas.Brush.Color := dt.Canvas.Pen.Color;
  dt.Canvas.Brush.Style := bsSolid;
  dt.Canvas.Ellipse( X-3, Y-3, X+3, Y+3 );
end;

procedure TPompkaDiagFun.DrawFun( dt :TSpecDrawData; bw :Boolean );
var
  X, Y    :TCanvCoord;
begin
  dt.ConvPointRPar( Q, H, X, Y );
  with dt.Canvas do
    begin
      Pen.Color := clBlack;
      Pen.Width:=1;
      Brush.Color := clWhite;
      Brush.Style := bsSolid;
      Ellipse(x-7,y-7,x+7,y+7);
      Brush.Color := clBlue;
      Polygon([Point(x-5,y+2), Point(x+5,y+2),Point(x,y-6)]);
    end;
end;
procedure TLiniaDiagFun.DrawFun( dt :TSpecDrawData; bw :Boolean );
var
  X, Y, X1, Y1   :TCanvCoord;
begin
  dt.ConvPointRPar( Q, H, X, Y );
  dt.ConvPointRPar( Q, 0, X1, Y1 );
  with dt.Canvas do
    begin
      Pen.Color := clRed;
      Pen.Width:=3;
      MoveTo(X,Y+7);  LineTo(X1,Y1);
    end;
end;

procedure TPodLiniaDiagFun.DrawFun( dt :TSpecDrawData; bw :Boolean );
var
  X, Y, X1, Y1   :TCanvCoord;
begin
  dt.ConvPointRPar( Q, H, X, Y );
  dt.ConvPointRPar( Q, 0, X1, Y1 );
  with dt.Canvas do
    begin
      Pen.Color := clRed;
      Brush.Color := clRed;
      Pen.Width:=1;
      Ellipse( X-3, Y-3, X+3, Y+3 );
      Pen.Width:=3;
      MoveTo(X,Y);  LineTo(X1,Y1-7);
    end;
end;
procedure TPntDiagFun.SetQ ( v :Double );
begin
  FQ := v;
  //Invalidate;
end;

procedure TPntDiagFun.SetH ( v :Double );
begin
  FH := v;
  //Invalidate;
end;


//+++++++++++ T O L E R A N C J A ++++++++++++++++++++++++++++++++++++++++++++
procedure TTolDiagFun.SetQ ( v :Double );
begin
  FQ := v;
  //Invalidate;
end;

procedure TTolDiagFun.SetH ( v :Double );
begin
  FH := v;
  //Invalidate;
end;

procedure TTolDiagFun.DrawFun( dt :TSpecDrawData; bw :Boolean );
var
  X, Y    :TCanvCoord;
  X1,Y1,X2,Y2,X3,Y3,X4,Y4 :TCanvCoord;
begin
  dt.ConvPointRPar( Q, H, X, Y );
  dt.ConvPointRPar( Q*QminTol, H*HminTol, X1, Y1 );
  dt.ConvPointRPar( Q*QmaxTol, H*HminTol, X2, Y2 );
  dt.ConvPointRPar( Q*QmaxTol, H*HmaxTol, X3, Y3 );
  dt.ConvPointRPar( Q*QminTol, H*HmaxTol, X4, Y4 );
  with dt.Canvas do
    begin
      Brush.Color := dt.Canvas.Pen.Color;
      //dt.Canvas.Brush.Style := bsSolid;
      MoveTo( X1, Y1);
      LineTo( X2, Y2);
      LineTo( X3, Y3);
      LineTo( X4, Y4);
      LineTo( X1, Y1);
    end;
end;

procedure TTolDiagFun.SetQMinTol ( v :Double );
begin
  FQMinTol := v;
end;
procedure TTolDiagFun.SetQMaxTol ( v :Double );
begin
  FQMaxTol := v;
end;

procedure TTolDiagFun.SetHMinTol ( v :Double );
begin
  FHMinTol := v;
end;

procedure TTolDiagFun.SetHMaxTol ( v :Double );
begin
  FHMaxTol := v;
end;
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++


end.
