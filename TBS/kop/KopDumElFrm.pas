unit KopDumElFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ElAbFrm, StdCtrls, Buttons, ElemUnit, Ciecze;

type
  TDodajDummyElemForm = class(TElemAbstPrzeplFrm)
    NazwLab: TLabel;
    NazwaEd: TEdit;
    IlLab: TLabel;
    IloscEd: TEdit;
    procedure IloscEdKeyPress(Sender: TObject; var Key: Char);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
    procedure  InitFields;

  protected
    procedure SetElement(e :TElemAbstract);  override;
    procedure SetCiecz(c :TCieczPlyw);       override;

  public
    { Public declarations }
  end;

var
  DodajDummyElemForm: TDodajDummyElemForm;

implementation

{$R *.DFM}

procedure TDodajDummyElemForm.IloscEdKeyPress(Sender: TObject;
  var Key: Char);
var a : TFormatSettings;
begin
  inherited;
  if (Key = '.') or (Key = ',') then
    //Key := DecimalSeparator;
    Key := a.DecimalSeparator;

  //if (Key >= ' ') and (not (Key in ['0'..'9', DecimalSeparator])) then
  if (Key >= ' ') and (not (Key in ['0'..'9', a.DecimalSeparator])) then

    Key := #0;
end;

procedure TDodajDummyElemForm.InitFields;
var
   A, v, Rej : Double;
begin
  IloscEd.Text := FormatFloat( '0.0', Element.L );
  NazwaEd.Text := Element.Nazwa;
end;


procedure TDodajDummyElemForm.SetElement(e :TElemAbstract);
begin
  inherited SetElement(e);
  InitFields;
end;

procedure TDodajDummyElemForm.SetCiecz(c :TCieczPlyw);
begin
  inherited SetCiecz(c);
  //InitFields;
end;


procedure TDodajDummyElemForm.OKBtnClick(Sender: TObject);
begin
  inherited;

  try
    Element.L := StrToFloat( IloscEd.Text );
  except
    on EConvertError do
    begin
      MessageDlg('Zle wprowadzone dane!! ',mterror,[mbOK],0);
    end;
  end;
end;

end.
