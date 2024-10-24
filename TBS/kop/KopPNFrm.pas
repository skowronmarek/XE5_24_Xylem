unit KopPNFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ElAbFrm, StdCtrls, Buttons,
  KrMath, ElemUnit, Diagrams, ExtCtrls, Ciecze,
  jezyki;

type
  TPNForm = class(TElemAbstPrzeplFrm)
    DaneGBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    QEd: TEdit;
    KEd: TEdit;
    DEd: TEdit;
    LEd: TEdit;
    WynikiGBox: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
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
    EgrEd: TEdit;
    ChrWzglEd: TEdit;
    WykresBtn: TBitBtn;
    CharPanel: TPanel;
    Diagram: TDiagram;
    Fun: TDiagFunction;
    KoniecDiagBtn: TSpeedButton;
    DiagDescr1: TDiagDescr;
    DiagDescr2: TDiagDescr;
    Nazwa: TLabel;
    NazwaEd: TEdit;
    procedure NumEdKeyPress(Sender: TObject; var Key: Char);
    procedure KEdChange(Sender: TObject);
    procedure DEdChange(Sender: TObject);
    procedure LEdChange(Sender: TObject);
    procedure FunValue(X: Double; var Y: Double);
    procedure WykresBtnClick(Sender: TObject);
    procedure KoniecDiagBtnClick(Sender: TObject);
    procedure NazwaEdChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    function  GetElem :TPNElem;
    procedure SetElem( e :TPNElem );
    procedure WartOblicz;
    procedure InitDiagram;

    property  Elem  :TPNElem  read GetElem  write SetElem;
  protected
    procedure SetElement(e :TElemAbstract);  override;
    procedure SetCiecz(c :TCieczPlyw);       override;

  public
    { Public declarations }

  end;

var
  PNForm: TPNForm;

implementation

{$R *.DFM}
uses
  Opor;


procedure TPNForm.SetElement(e :TElemAbstract);
begin
  inherited SetElement(e);

  NazwaEd.Text := Elem.Nazwa;
  KEd.Text := FormatFloat('0.00', Elem.k*1000);
  DEd.Text := FormatFloat('0.00', Elem.d*1000);
  LEd.Text := FormatFloat('0.00', Elem.L);

  WartOblicz;

end;


procedure TPNForm.SetCiecz(c :TCieczPlyw);
begin
  inherited SetCiecz(c);

  QEd.Text := FormatFloat('0.00', Ciecz.Q_m3h);

  WartOblicz;

end;

procedure TPNForm.WartOblicz;
var
  EGr     :Double;
  Rej     :Double;
  A       :Double;
  V       :Double;
begin
  if (Ciecz <> NIL) and (Elem <> NIL) then
  begin
    try
      if Elem.d > 0 then
        ChrWzglEd.Text := FormatFloat( '0.00', f_div(Elem.k,Elem.d) );
      A:=Pole_Przekroju(Elem.d);
      V:=V_przeplywu(Ciecz.Q,A);
      Rej:=Reynolds(Elem.d,v,Ciecz.ni);
      LaEd.Text := FormatFloat( '0.00000', Elem.LambdaEgr(ciecz, Egr) );
      EGrEd.Text := FormatFloat( '0.00000', Egr );
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

function  TPNForm.GetElem :TPNElem;
begin
  result := Element as TPNElem;
end;

procedure TPNForm.SetElem( e :TPNElem );
begin
  Element := e;
end;

procedure TPNForm.NumEdKeyPress(Sender: TObject; var Key: Char);
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

procedure TPNForm.KEdChange(Sender: TObject);
begin
  inherited;
  if KEd.Text <> '' then
    Elem.k := StrToFloat( KEd.Text )/1000
  else
    Elem.k := 0;
  WartOblicz;
end;

procedure TPNForm.DEdChange(Sender: TObject);
begin
  inherited;
  if DEd.Text <> '' then
    Elem.d := StrToFloat( DEd.Text ) /1000
  else
    Elem.d := 0;
  WartOblicz;
end;

procedure TPNForm.LEdChange(Sender: TObject);
begin
  inherited;
  if LEd.Text <> '' then
    Elem.L := StrToFloat( LEd.Text )
  else
    Elem.L := 0;
  WartOblicz;
end;

procedure TPNForm.FunValue(X: Double; var Y: Double);
var
  egr     :real;
begin
  inherited;

  try
    Y := PN_34034(X,Elem.d,Elem.k,1,  egr );
  except
    Y := 0;
  end;

end;

procedure TPNForm.InitDiagram;
var
  egr     :real;
begin
  Fun.CountMaxYR(PN_34034(200,Elem.d,Elem.k,1,  egr ));

end;

procedure TPNForm.WykresBtnClick(Sender: TObject);
begin
  inherited;

  InitDiagram;
  CharPanel.Show;
  CharPanel.BringToFront;
end;

procedure TPNForm.KoniecDiagBtnClick(Sender: TObject);
begin
  inherited;

  CharPanel.Hide;
end;

procedure TPNForm.NazwaEdChange(Sender: TObject);
begin
  inherited;

  Elem.Nazwa := NazwaEd.Text;
end;

procedure TPNForm.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(self);
end;

end.
