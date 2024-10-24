unit WykrFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DGraph, KrCtrlGraph, Diagrams, StdCtrls, Buttons, ComCtrls, KrMath, KopDraw1;

type
  TDiagForm = class(TForm)
    Diag: TDiagram;
    DiagFunctionH: TDiagFunction;
    DiagDescrQ: TDiagDescr;
    DiagDescrH: TDiagDescr;
    DiagDescrTitle: TDiagDescr;
    OKBtn: TBitBtn;
    DiagFunPPracy: TDiagFunction;
    Suwak: TTrackBar;
    QEd: TEdit;
    QLab: TLabel;
    HLab: TLabel;
    HValLab: TLabel;
    procedure FormResize(Sender: TObject);
    procedure SuwakChange(Sender: TObject);
    procedure QEdKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    pdf      :TPntDiagFun;
    suwChanged :Boolean;
    EdChanged  :Boolean;

    function  GetQ :Double;
    procedure SetQ( v :Double );
    function  GetH :Double;
    procedure SetH( v :Double );
  public
    { Public declarations }

    constructor Create( o :TComponent ); override;

    property Q :Double  read GetQ write SetQ;
    property H :Double  read GetH write SetH;
  end;

var
  DiagForm: TDiagForm;

implementation

{$R *.DFM}

constructor TDiagForm.Create( o :TComponent );
begin
  inherited Create( o );
  pdf := TPntDiagFun.Create( self );
  DiagFunPPracy.Drawer := pdf;
end;

function  TDiagForm.GetQ :Double;
begin
  result := pdf.Q;
end;

procedure TDiagForm.SetQ( v :Double );
var
  Y       :Double;
begin
  pdf.Q := v;

  if not SuwChanged then
    Suwak.Position := round( Lin( Q, Diag.MinXR, Diag.MaxXR, 0, 100 ) );

  if not EdChanged then
    QEd.Text := FormatFloat( '0.00', v );

  DiagFunctionH.OnValue( v, Y );
  H := Y;

  Diag.RedrawFuns;

end;

function  TDiagForm.GetH :Double;
begin
  result := pdf.H;
end;

procedure TDiagForm.SetH( v :Double );
begin
  pdf.H := v;
  HValLab.Caption := FormatFloat( '0.00', v );
end;



procedure TDiagForm.FormResize(Sender: TObject);
begin
  Diag.Width  := ClientWidth - 100;
  Diag.Height := ClientHeight - 40;
  OKBtn.Left := Diag.Left + Diag.Width + 10;
  Suwak.Top  := Diag.Top + Diag.Height;
  Suwak.Left := round( Lin( Diag.GridLeft, 0, 100,
                            Diag.Left, Diag.Left+Diag.Width ) - 15 );
  Suwak.Width := round( Lin( Diag.GridRight, 0, 100,
                            Diag.Left, Diag.Left+Diag.Width ) + 15 ) - Suwak.Left;
  QLab.Left    := CtrlRight( Diag );
  QEd.Left     := QLab.Left + 25;
  QLab.Top     := CtrlBottom( Diag ) - 70;
  QEd.Top      := QLab.Top;

  HLab.Left    := QLab.Left;
  HValLab.Left := QEd.Left;
  HLab.Top     := QLab.Top + 30;
  HValLab.Top  := HLab.Top;
end;


procedure TDiagForm.SuwakChange(Sender: TObject);
begin
  SuwChanged := true;
  Q := Lin( Suwak.Position, 0, 100, Diag.MinXR, Diag.MaxXR );
  SuwChanged := false;
end;

procedure TDiagForm.QEdKeyPress(Sender: TObject; var Key: Char);
var a : TFormatSettings;

begin
  if Key in [ #32..#127 ]
            - ( [ '0'..'9','-', '.', ',' ]
               +[ a.DecimalSeparator ] )then
               //+[ DecimalSeparator ] )then
  begin
    Key := #0;
  end
  else
  begin
    case Key of
      '.',',' :
        Key := a.DecimalSeparator;
        //Key := DecimalSeparator;
      #13     :
      begin
        EdChanged := true;
        Q := StrToFloat( QEd.Text );
        EdChanged := false;
        Key := #0;
      end;
    end;
  end;
end;

end.
