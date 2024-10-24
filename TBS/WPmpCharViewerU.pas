unit WPmpCharViewerU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CustPmpCharViewU, Diagrams, Buttons, ExtCtrls, StdCtrls, EditNew, WieloPompaU,
  OPompa, Menus;

type
  TWPmpCharViewer = class(TCustomPmpCharViewer)
    RownLab: TLabel;
    RownEdit: TEditN;
    SzerLab: TLabel;
    SzerEdit: TEditN;
    WyswParGroup: TGroupBox;
    WyswHLab: TLabel;
    WyswHRLab: TLabel;
    WyswHSLab: TLabel;
    WyswPLab: TLabel;
    WyswPRLab: TLabel;
    WyswPSLab: TLabel;
    WyswNPSHLab: TLabel;
    WyswNPSRrLab: TLabel;
    WyswETALab: TLabel;
    WyswETARLab: TLabel;
    WyswHREdit: TEditN;
    WyswHSEdit: TEditN;
    WyswPREdit: TEditN;
    WyswPSEdit: TEditN;
    WyswNPSHREdit: TEditN;
    WyswETAREdit: TEditN;
    procedure RownEditAccept(Sender: TObject; var Accept: Boolean);
    procedure SzerEditAccept(Sender: TObject; var Accept: Boolean);
    procedure WyswHREditAccept(Sender: TObject; var Accept: Boolean);
    procedure WyswHSEditAccept(Sender: TObject; var Accept: Boolean);
    procedure WyswPREditAccept(Sender: TObject; var Accept: Boolean);
    procedure WyswPSEditAccept(Sender: TObject; var Accept: Boolean);
    procedure WyswNPSHREditAccept(Sender: TObject; var Accept: Boolean);
    procedure PrintBtnClick(Sender: TObject);
  private
    WPompa: TWieloPompa;
    FRAccepting :Boolean;
    FSAccepting :Boolean;
    procedure SetRownolegle(const Value: Integer);
    procedure SetSzeregowo(const Value: Integer);
    function GetRownolegle: Integer;
    function GetSzeregowo: Integer;
    function GetWCharData: TWieloPompaFuncCharData;
  protected
    HDrawer    :TWPFuncDiag;
    PDrawer    :TWPFuncDiag;
    NPSHDrawer :TWPFuncDiag;
    EtaDrawer  :TWPFuncDiag;
    procedure InitPompa;                       override;
    procedure UstawMinMax;                     override;

    property  WCharData: TWieloPompaFuncCharData  read GetWCharData;
  public
    constructor Create( Owner :TComponent );   override;
    property Rownolegle :Integer read GetRownolegle write SetRownolegle;
    property Szeregowo :Integer read GetSzeregowo write SetSzeregowo;
  end;

var
  WPmpCharViewer: TWPmpCharViewer;

implementation

{$R *.DFM}

{ TWPmpCharViewer }

constructor TWPmpCharViewer.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  WPompa := TWieloPompa.Create(self);
end;

function TWPmpCharViewer.GetRownolegle: Integer;
begin
  result := WPompa.Rownolegle;
end;

function TWPmpCharViewer.GetSzeregowo: Integer;
begin
  result := WPompa.Szeregowo;
end;

function TWPmpCharViewer.GetWCharData: TWieloPompaFuncCharData;
begin
  result := CharData as TWieloPompaFuncCharData;
end;

procedure TWPmpCharViewer.InitPompa;
begin
  WPompa.PompaBazowa := FPompa;
  if FPompa <> NIL then
  begin
    FPompa.AddRef;
    CharData := WPompa.WCharData;
    WCharData.GetDiagFun( 'H', HDiagFun );
    WCharData.GetDiagFun( 'P', PDiagFun );
    WCharData.GetDiagFun( 'NPSH', NPSHDiagFun );
    WCharData.GetDiagFun( 'ETA', EtaDiagFun );
    HDrawer    := (HDiagFun.Drawer as TWPFuncDiag);
    PDrawer    := (PDiagFun.Drawer as TWPFuncDiag);
    NPSHDrawer := (NPSHDiagFun.Drawer as TWPFuncDiag);
    EtaDrawer  := (EtaDiagFun.Drawer as TWPFuncDiag);
  end
  else
  begin
    CharData := NIL;
  end;
end;

procedure TWPmpCharViewer.RownEditAccept(Sender: TObject;
  var Accept: Boolean);
var
  v   :Integer;
begin
  v := RownEdit.ValueInteger;
  Accept := (v > 0);
  if Accept then
  begin
    FRAccepting := true;
    Rownolegle := v;
    FRAccepting := false;
  end;
end;

procedure TWPmpCharViewer.SetRownolegle(const Value: Integer);
begin
  WPompa.Rownolegle := Value;
  if not FRAccepting then
    RownEdit.ValueInteger := Value;
  Aktualizuj;
end;

procedure TWPmpCharViewer.SetSzeregowo(const Value: Integer);
begin
  WPompa.Szeregowo := Value;
  if not FSAccepting then
    SzerEdit.ValueInteger := Value;
  Aktualizuj;
end;

procedure TWPmpCharViewer.SzerEditAccept(Sender: TObject;
  var Accept: Boolean);
var
  v   :Integer;
begin
  v := SzerEdit.ValueInteger;
  Accept := (v > 0);
  if Accept then
  begin
    FSAccepting := true;
    Szeregowo := v;
    FSAccepting := false;
  end;
end;

procedure TWPmpCharViewer.UstawMinMax;
begin
  HDiag.CountMaxXR(WCharData.GetCharQMax);
  PDiag.CountMaxXR(WCharData.GetCharQMax);
  NPSHDiag.CountMaxXR(WCharData.GetCharQMax);
  EtaDiag.CountMaxXR(WCharData.GetCharQMax);
  HDiagFun.CountMaxYR(WCharData.GetCharHMax);
  PDiagFun.CountMaxYR(WCharData.CharPMax);
  NPSHDiagFun.CountMaxYR(WCharData.CharNPSHMax);
end;

procedure TWPmpCharViewer.WyswHREditAccept(Sender: TObject;
  var Accept: Boolean);
var
  v   :Integer;
begin
  v := WyswHREdit.ValueInteger;
  Accept := (0 < v) and (v <= Rownolegle);
  if Accept then
  begin
    HDrawer.MinRown := v;
  end;
end;

procedure TWPmpCharViewer.WyswHSEditAccept(Sender: TObject;
  var Accept: Boolean);
var
  v   :Integer;
begin
  v := WyswHSEdit.ValueInteger;
  Accept := (0 < v) and (v <= Szeregowo);
  if Accept then
  begin
    HDrawer.MinSzer := v;
  end;
end;

procedure TWPmpCharViewer.WyswNPSHREditAccept(Sender: TObject;
  var Accept: Boolean);
var
  v   :Integer;
begin
  v := WyswNPSHREdit.ValueInteger;
  Accept := (0 < v) and (v <= Rownolegle);
  if Accept then
  begin
    NPSHDrawer.MinRown := v;
  end;
end;

procedure TWPmpCharViewer.WyswPREditAccept(Sender: TObject;
  var Accept: Boolean);
var
  v   :Integer;
begin
  v := WyswPREdit.ValueInteger;
  Accept := (0 < v) and (v <= Rownolegle);
  if Accept then
  begin
    PDrawer.MinRown := v;
  end;
end;

procedure TWPmpCharViewer.WyswPSEditAccept(Sender: TObject;
  var Accept: Boolean);
var
  v   :Integer;
begin
  v := WyswPSEdit.ValueInteger;
  Accept := (0 < v) and (v <= Szeregowo);
  if Accept then
  begin
    PDrawer.MinSzer := v;
  end;
end;

procedure TWPmpCharViewer.PrintBtnClick(Sender: TObject);
begin
  inherited;
  TBSPrint;
end;

end.
 