unit KopFormFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ElAbFrm, Diagrams, Buttons, ExtCtrls, StdCtrls, ElemUnit, Ciecze, KrMath,
  jezyki;

type
  TDodajFormulaElemForm = class(TElemAbstPrzeplFrm)
    DaneGBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Nazwa: TLabel;
    QEd: TEdit;
    KEd: TEdit;
    DEd: TEdit;
    LEd: TEdit;
    NazwaEd: TEdit;
    WynikiGBox: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    DelHEd: TEdit;
    La_dEd: TEdit;
    LaEd: TEdit;
    VEd: TEdit;
    ReEd: TEdit;
    ChrWzglEd: TEdit;
    WykresBtn: TBitBtn;
    CharPanel: TPanel;
    Diagram: TDiagram;
    KoniecDiagBtn: TSpeedButton;
    DiagDescr1: TDiagDescr;
    Fun: TDiagFunction;
    DiagDescr2: TDiagDescr;
    procedure NumEdKeyPress(Sender: TObject; var Key: Char);
    procedure KEdChange(Sender: TObject);
    procedure DEdChange(Sender: TObject);
    procedure LEdChange(Sender: TObject);
    procedure WykresBtnClick(Sender: TObject);
    procedure KoniecDiagBtnClick(Sender: TObject);
    procedure NazwaEdChange(Sender: TObject);
    procedure FunValue(X: Double; var Y: Double);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    function  GetElem :TFormula;
    procedure SetElem( e :TFormula );
    procedure WartOblicz;
    procedure InitDiagram;

    property  Elem  :TFormula  read GetElem  write SetElem;
  protected
    procedure SetElement(e :TElemAbstract);  override;
    procedure SetCiecz(c :TCieczPlyw);       override;

  public
    { Public declarations }
  end;

var
  DodajFormulaElemForm: TDodajFormulaElemForm;

implementation

{$R *.DFM}

uses
  Opor;


procedure TDodajFormulaElemForm.SetElement(e :TElemAbstract);
begin
  inherited SetElement(e);

  NazwaEd.Text := Elem.Nazwa;
  KEd.Text := FormatFloat('0.00', Elem.k*1000);
  DEd.Text := FormatFloat('0.00', Elem.d*1000);
  LEd.Text := FormatFloat('0.00', Elem.L);

  WartOblicz;

end;


procedure TDodajFormulaElemForm.SetCiecz(c :TCieczPlyw);
begin
  inherited SetCiecz(c);

  QEd.Text := FormatFloat('0.00', Ciecz.Q_m3h);

  WartOblicz;

end;

procedure TDodajFormulaElemForm.WartOblicz;
var
  EGr     :Double;
  Rej     :Double;
  A       :Double;
  V       :Double;
begin
  if (Ciecz <> NIL) and (Elem <> NIL) then
  begin
    try
      ChrWzglEd.Text := FormatFloat( '0.00', Elem.k/Elem.d );
      A:=Pole_Przekroju(Elem.d);
      V:=V_przeplywu(Ciecz.Q,A);
      Rej:=Reynolds(Elem.d,v,Ciecz.ni);
      LaEd.Text := FormatFloat( '0.00000', Elem.Lambda(ciecz) );
      ReEd.Text := FormatFloat( '0.0', Rej );
      VEd.Text := FormatFloat( '0.00', v );
      La_dEd.Text := FormatFloat( '0.00', Elem.WspZast(ciecz) );
      DelHEd.Text := FormatFloat( '0.00', Elem.dH(ciecz) );
    Except on EMathError do
      begin
      end;
    end;
  end;
end;

function  TDodajFormulaElemForm.GetElem :TFormula;
begin
  result := Element as TFormula;
end;

procedure TDodajFormulaElemForm.SetElem( e :TFormula );
begin
  Element := e;
end;



procedure TDodajFormulaElemForm.NumEdKeyPress(Sender: TObject;
  var Key: Char);
var a : TFormatSettings;

begin
  inherited;
  if (Key = '.') or (Key = ',') then
    // Key := DecimalSeparator;
      Key := a.DecimalSeparator;

  //if (Key >= ' ') and (not (Key in ['0'..'9', DecimalSeparator])) then
  if (Key >= ' ') and (not (Key in ['0'..'9', a.DecimalSeparator])) then
    Key := #0;

end;

procedure TDodajFormulaElemForm.KEdChange(Sender: TObject);
begin
  inherited;

  Elem.k := StrToFloat( KEd.Text )/1000;
  WartOblicz;
end;

procedure TDodajFormulaElemForm.DEdChange(Sender: TObject);
begin
  inherited;

  Elem.d := StrToFloat( DEd.Text ) /1000;
  WartOblicz;
end;

procedure TDodajFormulaElemForm.LEdChange(Sender: TObject);
begin
  inherited;

  Elem.L := StrToFloat( LEd.Text );
  WartOblicz;
end;

procedure TDodajFormulaElemForm.InitDiagram;
var
  egr     :real;
begin
  Fun.CountMaxYR( Elem.Formula( 200,Elem.d,Elem.k,
                                f_div( Ciecz.Q ,
                                     //----------
                                       Pi*sqr(Elem.d/2)
                                      )
                              ));

end;



procedure TDodajFormulaElemForm.WykresBtnClick(Sender: TObject);
begin
  inherited;
  InitDiagram;
  CharPanel.Show;
  CharPanel.BringToFront;
end;

procedure TDodajFormulaElemForm.KoniecDiagBtnClick(Sender: TObject);
begin
  inherited;
  CharPanel.Hide;
end;

procedure TDodajFormulaElemForm.NazwaEdChange(Sender: TObject);
begin
  inherited;
  Elem.Nazwa := NazwaEd.Text;
end;

procedure TDodajFormulaElemForm.FunValue(X: Double; var Y: Double);
begin
  inherited;
  try
    Y := Elem.Formula( X, Elem.d, Elem.k,
                       f_div(Ciecz.Q , (Pi*sqr(Elem.d/2) ))
                     );
  except
    Y := 0;
  end;

end;

procedure TDodajFormulaElemForm.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(self);
end;

end.
