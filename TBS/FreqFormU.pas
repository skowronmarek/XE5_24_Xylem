unit FreqFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, EditNew;

type
  TFreqCalcForm = class(TForm)
    NominalneLab: TLabel;
    WymaganeLab: TLabel;
    CzestotliwoscLab: TLabel;
    ObrotyLab: TLabel;
    CzestNomEdit: TEditN;
    ObrNomEdit: TEditN;
    CzestWymEdit: TEditN;
    ObrWymEdit: TEditN;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure CzestNomEditAccept(Sender: TObject; var Accept: Boolean);
    procedure ObrNomEditAccept(Sender: TObject; var Accept: Boolean);
    procedure CzestWymEditAccept(Sender: TObject; var Accept: Boolean);
    procedure ObrWymEditAccept(Sender: TObject; var Accept: Boolean);
  private
    FCzestWym: Double;
    FObrNom: Double;
    FObrWym: Double;
    FCzestNom: Double;
    procedure Przelicz( FreqToN :Boolean );
    procedure SetCzestNom(const Value: Double);
    procedure SetCzestWym(const Value: Double);
    procedure SetObrNom(const Value: Double);
    procedure SetObrWym(const Value: Double);
  public
    function Execute :Boolean;
    property CzestNom :Double read FCzestNom write SetCzestNom;
    property CzestWym :Double read FCzestWym write SetCzestWym;
    property ObrNom   :Double read FObrNom write SetObrNom;
    property ObrWym   :Double read FObrWym write SetObrWym;
  end;

var
  FreqCalcForm: TFreqCalcForm;

implementation

{$R *.DFM}

{ TFreqCalcForm }

function TFreqCalcForm.Execute: Boolean;
begin
  result := ShowModal = mrOK;
end;

procedure TFreqCalcForm.Przelicz(FreqToN: Boolean);
var
  f, n    :Double;
begin
  if FreqToN then
  begin
    if CzestNom <> 0 then
      FObrWym := ObrNom * CzestWym / CzestNom
    else
      FObrWym := 0;
    ObrWymEdit.ValueFloat := FObrWym;
  end
  else
  begin
    if ObrNom <> 0 then
      FCzestWym := CzestNom * ObrWym / ObrNom
    else
      FCzestWym := 0;
    CzestWymEdit.ValueFloat := FCzestWym;
  end;
end;

procedure TFreqCalcForm.SetCzestNom(const Value: Double);
begin
  FCzestNom := Value;
  CzestNomEdit.ValueFloat := Value;
  Przelicz( true );
end;

procedure TFreqCalcForm.SetCzestWym(const Value: Double);
begin
  FCzestWym := Value;
  CzestWymEdit.ValueFloat := Value;
  Przelicz( true );
end;

procedure TFreqCalcForm.SetObrNom(const Value: Double);
begin
  FObrNom := Value;
  ObrNomEdit.ValueFloat := Value;
  Przelicz(true);
end;

procedure TFreqCalcForm.SetObrWym(const Value: Double);
begin
  FObrWym := Value;
  ObrWymEdit.ValueFloat := Value;
  Przelicz(false);
end;

procedure TFreqCalcForm.CzestNomEditAccept(Sender: TObject;
  var Accept: Boolean);
begin
  Accept := CzestNomEdit.ValueFloat > 0;
  if not Accept then
  begin
    ShowMessage('BLAD !'#13+
                'Niespelniony warunek:'#13+
                'Czestotlowosc nominalna > 0'
               );
    EXIT;
  end;
  FCzestNom := CzestNomEdit.ValueFloat;
  Przelicz( true );
end;

procedure TFreqCalcForm.ObrNomEditAccept(Sender: TObject;
  var Accept: Boolean);
begin
  Accept := ObrNomEdit.ValueFloat > 0;
  if not Accept then
  begin
    ShowMessage('BLAD !'#13+
                'Niespelniony warunek:'#13+
                'Obroty nominalne > 0'
               );
    EXIT;
  end;
  FObrNom := ObrNomEdit.ValueFloat;
  Przelicz( true );
end;

procedure TFreqCalcForm.CzestWymEditAccept(Sender: TObject;
  var Accept: Boolean);
begin
  Accept := CzestWymEdit.ValueFloat >= 0;
  if not Accept then
  begin
    ShowMessage('BLAD !'#13+
                'Niespelniony warunek:'#13+
                'Czestotlowosc wymagana >= 0'
               );
    EXIT;
  end;
  FCzestWym := CzestWymEdit.ValueFloat;
  Przelicz( true );

end;

procedure TFreqCalcForm.ObrWymEditAccept(Sender: TObject;
  var Accept: Boolean);
begin
  Accept := ObrWymEdit.ValueFloat >= 0;
  if not Accept then
  begin
    ShowMessage('BLAD !'#13+
                'Niespelniony warunek:'#13+
                'Obroty wymagane >= 0'
               );
    EXIT;
  end;
  FObrWym := ObrWymEdit.ValueFloat;
  Przelicz( false );

end;

end.
