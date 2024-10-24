unit ZakWyszF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TRangeSearchForm = class(TForm)
    QMinEd: TEdit;
    Label1: TLabel;
    Qw1Lab: TLabel;
    Label2: TLabel;
    QrLab: TLabel;
    Label3: TLabel;
    QMaxEd: TEdit;
    HMinEd: TEdit;
    Label4: TLabel;
    Qw2Lab: TLabel;
    Label5: TLabel;
    Hw1Lab: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    HrLab: TLabel;
    Hw2Lab: TLabel;
    HMaxEd: TEdit;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure QMinEdKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    function  GetQMinTol :Double ;
    function  GetQMaxTol :Double ;
    function  GetHMinTol :Double ;
    function  GetHMaxTol :Double ;

    procedure SetQMinTol( v :Double );
    procedure SetQMaxTol( v :Double );
    procedure SetHMinTol( v :Double );
    procedure SetHMaxTol( v :Double );
  public
    { Public declarations }
    function Execute :Boolean;
    property QMinTol :Double   read GetQMinTol  write setQMinTol;
    property QMaxTol :Double   read GetQMaxTol  write setQMaxTol;
    property HMinTol :Double   read GetHMinTol  write setHMinTol;
    property HMaxTol :Double   read GetHMaxTol  write setHMaxTol;
  end;

var
  RangeSearchForm: TRangeSearchForm;

implementation

{$R *.DFM}

{-----------------------------------------------------------------------------}
function TRangeSearchForm.Execute :Boolean;
begin
  ShowModal;
  result := (ModalResult = mrOK);
end;


{-----------------------------------------------------------------------------}
function  TRangeSearchForm.GetQMinTol :Double ;
begin
  result := StrToFloat(QMinEd.Text);
end;
{-----------------------------------------------------------------------------}
function  TRangeSearchForm.GetQMaxTol :Double ;
begin
  result := StrToFloat(QMaxEd.Text);
end;
{-----------------------------------------------------------------------------}
function  TRangeSearchForm.GetHMinTol :Double ;
begin
  result := StrToFloat(HMinEd.Text);
end;
{-----------------------------------------------------------------------------}
function  TRangeSearchForm.GetHMaxTol :Double ;
begin
  result := StrToFloat(HMaxEd.Text);
end;



{-----------------------------------------------------------------------------}
procedure TRangeSearchForm.SetQMinTol( v :Double );
begin
  QMinEd.Text := FormatFloat( '0.00', v);
end;
{-----------------------------------------------------------------------------}
procedure TRangeSearchForm.SetQMaxTol( v :Double );
begin
  QMaxEd.Text := FormatFloat( '0.00', v);
end;
{-----------------------------------------------------------------------------}
procedure TRangeSearchForm.SetHMinTol( v :Double );
begin
  HMinEd.Text := FormatFloat( '0.00', v);
end;
{-----------------------------------------------------------------------------}
procedure TRangeSearchForm.SetHMaxTol( v :Double );
begin
  HMaxEd.Text := FormatFloat( '0.00', v);
end;

procedure TRangeSearchForm.QMinEdKeyPress(Sender: TObject; var Key: Char);
var
  a: TFormatSettings;
begin
  if Key in [ #32..#127 ]
            - ( [ '0'..'9','-', '.', ',' ]
               +[ a.DecimalSeparator ] )then
  begin
    Key := #0;
  end
  else
  begin
    case Key of
      '.',',' :
        Key := a.DecimalSeparator;
    end;
  end;

end;

end.
