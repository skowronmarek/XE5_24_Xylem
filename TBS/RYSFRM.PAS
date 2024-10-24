unit RysFrm;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons,
  DGraph, KrMath, {WkpGlob,}
  DXFDraws, ActnList, Menus,
  jezyki;

type
  TRysForm = class(TForm)
    ToolBar: TPanel;
    ScrollBox: TScrollBox;
    RysPanel: TPanel;
    RysBox: TPaintBox;
    ZoomInBtn: TSpeedButton;
    ZoomOutBtn: TSpeedButton;
    ZoomWinBtn: TSpeedButton;
    SaveDialog: TSaveDialog;
    ActionList1: TActionList;
    SaveAsAct: TAction;
    Popup: TPopupMenu;
    SaveAsMI: TMenuItem;
    MoveWinBtn: TSpeedButton;
    procedure RysBoxPaint(Sender: TObject);
    procedure ZoomInBtnClick(Sender: TObject);
    procedure ZoomOutBtnClick(Sender: TObject);
    procedure RysBoxZoomMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RysBoxZoomMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RysBoxZoomMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZoomWinBtnClick(Sender: TObject);
    procedure SaveAsActExecute(Sender: TObject);
    procedure MoveWinBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    ZoomRect  :TRect;
    MovePoint :TPoint;
    IsZoom    :Boolean;
    Moving    :Boolean;
    Drawing   :Boolean;
    FNazwa: string;
    procedure  ZoomBegin;
    procedure  ZoomEnd;
    procedure  ZoomByRect( R :TRect );
    procedure  MoveBegin;
    procedure  MoveEnd;
    procedure SetNazwa(const Value: string);
    procedure RysBoxMoveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RysBoxMoveMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RysBoxMoveMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
    { Public declarations }
    DXFDraw :TDXFDrawing;
    property Nazwa   :string read FNazwa write SetNazwa;

    procedure  InitInner;
  end;

var
  RysForm: TRysForm;

implementation

uses CursorsDM;

{$R *.DFM}

const
  PicFactor = 3/4;               // wysokosc / szerokosc rysunku
  MaxPicW   = $7F00;

{-----------------------------------------------------------------------------}
procedure TRysForm.RysBoxPaint(Sender: TObject);
var
  R       :TRect;
  R2      :TRealRectRec;
  dd      :TSpecDrawData;
  f, fr   :Double;
begin
  if Drawing then
    EXIT;
  Drawing := true;
  R.Top    := round(0.03*RysBox.Height);
  R.Left   := round(0.03*RysBox.Width);
  R.Right  := round(0.97*RysBox.Width);
  R.Bottom := round(0.97*RysBox.Height);
  R2.Top   := DXFDraw.Top;
  R2.Left  := DXFDraw.Left;
  R2.Right := DXFDraw.Right;
  R2.Bottom:= DXFDraw.Bottom;
  f := RysBox.Width / RysBox.Height;
  fr := (R2.Right - R2.Left) / (R2.Bottom - R2.Top);
  if abs(fr) > f then
    R2.Bottom := R2.Top + ((R2.Bottom - R2.Top) * abs(fr)/f)
  else
    R2.Right := R2.Left + ((R2.Right - R2.Left) * f/abs(fr));
  dd := TSpecDrawData.Create;
  dd.Canvas := RysBox.Canvas;
  dd.Construct2RectRI( R2, R );
  DXFDraw.DrawOnSpec( dd );
  dd.Free;
  drawing := false;
end;

{-----------------------------------------------------------------------------}
procedure TRysForm.ZoomInBtnClick(Sender: TObject);
var
  W       :Longint;
begin
  W := 2*RysPanel.Width;
  if W = 0 then
    W := 4;
  if W < MaxPicW then
  begin
    RysPanel.Width  := W;
    RysPanel.Height := round( PicFactor * W);
    with ScrollBox.HorzScrollBar do
      Position := 2 * Position;
    with ScrollBox.VertScrollBar do
      Position := 2 * Position;
    ZoomOutBtn.Enabled := true;
  end
  else
    ZoomInBtn.Enabled := false;
end;

{-----------------------------------------------------------------------------}
procedure TRysForm.ZoomOutBtnClick(Sender: TObject);
var
  W       :Longint;
begin
  W := RysPanel.Width  div 2;
  if W > 2 then
  begin
    RysPanel.Width  := W;
    RysPanel.Height := round( PicFactor * W );
    with ScrollBox.HorzScrollBar do
      Position := Position div 2;
    with ScrollBox.VertScrollBar do
      Position := Position div 2;
    ZoomInBtn.Enabled := true;
  end
  else
    ZoomOutBtn.Enabled := false;
end;

{-----------------------------------------------------------------------------}
procedure  TRysForm.InitInner;
begin
  WindowState := wsMaximized;
  RysPanel.Width  := ClientWidth - ToolBar.Width;
  RysPanel.Height := ClientHeight;
end;

{-----------------------------------------------------------------------------}
procedure  TRysForm.ZoomBegin;
begin
  RysBox.Cursor := CursorsData.ZoomCur.Cursor;
  RysBox.OnMouseDown := RysBoxZoomMouseDown;
end;

{-----------------------------------------------------------------------------}
procedure  TRysForm.ZoomEnd;
begin
  RysBox.Cursor := crDefault;
  RysBox.OnMouseDown := NIL;
end;

{-----------------------------------------------------------------------------}
procedure  TRysForm.ZoomByRect( R :TRect );
var
  X1, Y1, X2, Y2 :LongInt;
  ZF, HZF, VZF   :Double;         // ZoomFactor, Horizontal, Vertical
  W, H           :Longint;        // Width, Height
begin
  X1 := MinInt( R.Left, R.Right );
  X2 := MaxInt( R.Left, R.Right );
  Y1 := MinInt( R.Top,  R.Bottom );
  Y2 := MaxInt( R.Top,  R.Bottom );


  HZF := ScrollBox.Width  / (X2-X1+1);
  VZF := ScrollBox.Height / (Y2-Y1+1);

  ZF  := MinFloat( HZF, VZF );

  W   := round(RysBox.Width * ZF);
  H   := round(W * PicFactor);

  if W > MaxPicW then
  begin
    ZF := ZF * (MaxPicW / W);
    W   := round(RysBox.Width * ZF);
    H   := round(W * PicFactor);
  end;

  RysPanel.Width  := W;
  RysPanel.Height := H;
  ScrollBox.HorzScrollBar.Position := round(X1 * ZF);
  ScrollBox.VertScrollBar.Position := round(Y1 * ZF);
end;


{-----------------------------------------------------------------------------}
procedure TRysForm.RysBoxZoomMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ZoomRect := Rect(X,Y,X,Y);
    RysBox.Canvas.Brush.Style := bsClear;
    with RysBox.Canvas.Pen do
    begin
      Style := psDot;
      Mode  := pmXor;
      Color := clWhite;
    end;
    RysBox.OnMouseMove := RysBoxZoomMouseMove;
    RysBox.OnMouseUp   := RysBoxZoomMouseUp;
  end;
end;

{-----------------------------------------------------------------------------}
procedure TRysForm.RysBoxZoomMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if not (ssLeft in Shift) then
  begin
    ZoomEnd;
  end
  else
  begin
    with RysBox.Canvas do
    begin
      with ZoomRect do
      begin
        if IsZoom then
          Rectangle( Left, Top, Right, Bottom );
        IsZoom := true;
        Right  := X;
        Bottom := Y;
        Rectangle( Left, Top, Right, Bottom );
      end;
    end;
  end;
end;


{-----------------------------------------------------------------------------}
procedure TRysForm.RysBoxZoomMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with RysBox.Canvas.Pen do
  begin
    Style := psSolid;
    Mode  := pmCopy;
    Color := clBlack;
  end;
  RysBox.Canvas.Brush.Style := bsSolid;
  with RysBox do
  begin
    OnMouseMove := NIL;
    OnMouseUp   := NIL;
    IsZoom      := false;
    ZoomByRect( ZoomRect );
    Invalidate;
  end;
end;


{-----------------------------------------------------------------------------}
procedure TRysForm.ZoomWinBtnClick(Sender: TObject);
begin
  if ZoomWinBtn.Down then
    ZoomBegin
  else
    ZoomEnd;
end;

procedure TRysForm.SaveAsActExecute(Sender: TObject);
begin
  SaveDialog.FileName := Format( '%s.dxf', [Nazwa] );
  if SaveDialog.Execute then
    DXFDraw.SaveToFile(SaveDialog.FileName);
end;

procedure TRysForm.SetNazwa(const Value: string);
begin
  FNazwa := Value;
  Caption := Format( 'Rysunek: %s', [FNazwa] );
end;

procedure TRysForm.RysBoxMoveMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    MovePoint := Point(X,Y);
    RysBox.OnMouseMove := RysBoxMoveMouseMove;
    RysBox.OnMouseUp   := RysBoxMoveMouseUp;
  end;
end;

procedure TRysForm.RysBoxMoveMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  dx, dy :Integer;
  nx, ny :Integer;
  smsg   :TWMScroll;
  msg    :TMessage absolute smsg;
begin
  if Moving or Drawing then
    EXIT;
  Moving := true;
  dx := MovePoint.x - X;
  dy := MovePoint.y - Y;
  nx := ScrollBox.HorzScrollBar.Position + dx;
  ny := ScrollBox.VertScrollBar.Position + dy;
  if nx < 0 then
    nx := 0
  else if nx > (ScrollBox.HorzScrollBar.Range - ScrollBox.ClientWidth) then
    nx := ScrollBox.HorzScrollBar.Range - ScrollBox.ClientWidth;
  if ny < 0 then
    ny := 0
  else if ny > (ScrollBox.VertScrollBar.Range - ScrollBox.ClientHeight) then
    ny := ScrollBox.VertScrollBar.Range - ScrollBox.ClientHeight;

  with smsg do
  begin
    Msg := WM_HSCROLL;
    ScrollCode := SB_THUMBTRACK; { SB_xxxx }
    Pos := nx;
    ScrollBar := 0;
    Result := 0;
  end;
  PostMessage( ScrollBox.Handle, msg.Msg, msg.WParam, msg.LParam );
  //ScrollBox.HorzScrollBar.Position := nx;
  with smsg do
  begin
    Msg := WM_VSCROLL;
    ScrollCode := SB_THUMBTRACK; { SB_xxxx }
    Pos := ny;
    ScrollBar := 0;
    Result := 0;
  end;
  PostMessage( ScrollBox.Handle, msg.Msg, msg.WParam, msg.LParam );
  //ScrollBox.Dispatch(msg);
  //ScrollBox.VertScrollBar.Position := ny;
  //MovePoint := Point(X,Y);
  Moving := false;
end;

procedure TRysForm.RysBoxMoveMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  RysBox.OnMouseMove := NIL;
  RysBox.OnMouseUp   := NIL;
end;

procedure TRysForm.MoveBegin;
begin
  RysBox.Cursor := CursorsData.HandCur.Cursor;
  RysBox.OnMouseDown := RysBoxMoveMouseDown;
end;

procedure TRysForm.MoveEnd;
begin
  RysBox.Cursor := crDefault;
  RysBox.OnMouseDown := NIL;
end;

procedure TRysForm.MoveWinBtnClick(Sender: TObject);
begin
  if MoveWinBtn.Down then
    MoveBegin
  else
    MoveEnd;
end;

procedure TRysForm.FormShow(Sender: TObject);
begin
  TTlumacz.dajObiekt.Tlumacz(self);
end;

end.
