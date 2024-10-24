unit KopDodElFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ElAbFrm, StdCtrls, Buttons, ExtCtrls, ElemUnit, Ciecze,
  jezyki;

type
  TDodajElemForm = class(TElemAbstPrzeplFrm)
    Opis2: TLabel;
    Opis1: TLabel;
    Opis3: TLabel;
    Opis4: TLabel;
    Opis5: TLabel;
    ViewBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    VEdit: TEdit;
    Label7: TLabel;
    ReEdit: TEdit;
    Label8: TLabel;
    Edit8: TEdit;
    Label9: TLabel;
    LenEdit: TEdit;
    procedure LenEditChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ViewBtnClick(Sender: TObject);
    procedure LenEditKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    function   GetTmpLen :Double;
    procedure  InitFields;

  protected
    procedure SetElement(e :TElemAbstract);  override;
    procedure SetCiecz(c :TCieczPlyw);       override;


  public
    { Public declarations }
    L :Double;
    property TmpLen :Double read GetTmpLen;
  end;

var
  DodajElemForm: TDodajElemForm;

implementation

uses
  Opor;

{$R *.DFM}

procedure TDodajElemForm.InitFields;
var
   A, v, Rej : Double;
begin
  { wstawienie danych do okienka }
  Edit1.Text := Element.Nazwa;
  //Edit2.Text := Rura.Tabela.FieldByName('Mat').AsString;
  Edit3.Text := FormatFloat( '0.0' ,Element.d * 1000 );
  //Edit4.Text := Rura.Tabela.FieldByName('Cisnienie').AsString;

  //Edit5.Text := Rura.Tabela.FieldByName('W_oporu').AsString;
  //Edit8.Text := Rura.Tabela.FieldByName('Cena').AsString;
  if Element.L = 0 then
  begin
    L := 1;
    LenEdit.Text := '1';
  end
  else
  begin
    L := Element.l;
    LenEdit.Text := FloatToStr( L );
  end;




{==============================================================}
  // Obliczenia  podstawowych wielkosci
  A := Pole_przekroju(Element.d);
  if Ciecz <> NIL then
  begin
    try
      v := V_przeplywu(Ciecz.Q, A);
    except
      on EMathError do
        v := 0;
    end;
    try
      Rej:=Reynolds( Element.d, V, Ciecz.Ni);
    except
      on EMathError do
        Rej := 0;
    end;
    VEdit.Text  := FormatFloat( '0.00', V );
    ReEdit.Text := FormatFloat( '0.0', Rej );
  end;
end;


procedure TDodajElemForm.SetElement(e :TElemAbstract);
begin
  inherited SetElement(e);
  InitFields;
end;

procedure TDodajElemForm.SetCiecz(c :TCieczPlyw);
begin
  inherited SetCiecz(c);
  InitFields;
end;


procedure TDodajElemForm.LenEditChange(Sender: TObject);
var
  s       :string;
begin
  inherited;
  try
    S := LenEdit.Text;
    if s='' then s:='1';
    L := StrToFloat(s);
  except
    on EConvertError do
    begin
      MessageDlg('Zle wprowadzone dane!! ',mterror,[mbOK],0);
      L:=1;
      LenEdit.Text:='';
    end
  end;

end;

procedure TDodajElemForm.OKBtnClick(Sender: TObject);
begin
  inherited;
  Element.L := TmpLen;

end;

procedure TDodajElemForm.FormActivate(Sender: TObject);
begin
  inherited;
  ActiveControl := LenEdit;

end;

function  TDodajElemForm.GetTmpLen :Double;
begin
  try
    result := StrToFloat( LenEdit.Text );
  except
    on EConvertError do
    begin
      MessageDlg('Zle wprowadzone dane!! ',mterror,[mbOK],0);
      L:=1;
      LenEdit.Text:='';
      result := 0;
    end
  end;
end;



procedure TDodajElemForm.ViewBtnClick(Sender: TObject);
var
  F       :TElemAbstPrzeplFrm;
  svLen   :Double;
begin
  inherited;

  F := Element.DajOkno('V') as TElemAbstPrzeplFrm;
  if F <> NIL then
  begin
    svLen := Element.L;
    Element.L := TmpLen;
    if Element.L = 0 then
      Element.L := 1;
    F.Ciecz := Ciecz;
    F.FormStyle := fsNormal;
    F.Hide;
    F.ShowModal;
    F.Free;
    Element.L := svLen;
  end;
end;

procedure TDodajElemForm.LenEditKeyPress(Sender: TObject; var Key: Char);
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

procedure TDodajElemForm.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(Self);
end;

end.
