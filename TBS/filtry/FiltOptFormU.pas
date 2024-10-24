unit FiltOptFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, EditNew, ZadFrmU;

type
  TFiltOptForm = class(TForm)
    Tolerancja: TGroupBox;
    Label7: TLabel;
    Qw1Lab: TLabel;
    Label9: TLabel;
    QrLab: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Qw2Lab: TLabel;
    Label12: TLabel;
    Hw1Lab: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    HrLab: TLabel;
    Hw2Lab: TLabel;
    edQMin: TEditN;
    edQMax: TEditN;
    edHMin: TEditN;
    edHMax: TEditN;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
  private
    function GetHMaxFak: Double;
    function GetHMinFak: Double;
    function GetQMaxFak: Double;
    function GetQMinFak: Double;
    procedure SetHMaxFak(const Value: Double);
    procedure SetHMinFak(const Value: Double);
    procedure SetQMaxFak(const Value: Double);
    procedure SetQMinFak(const Value: Double);
    function GetModified: Boolean;
    procedure SetModified(const Value: Boolean);
    { Private declarations }
  public
    function Execute :Boolean;
    property QMinFak :Double read GetQMinFak write SetQMinFak;
    property QMaxFak :Double read GetQMaxFak write SetQMaxFak;
    property HMinFak :Double read GetHMinFak write SetHMinFak;
    property HMaxFak :Double read GetHMaxFak write SetHMaxFak;
    property Modified :Boolean read GetModified write SetModified;

  end;

var
  FiltOptForm: TFiltOptForm;

implementation

{$R *.DFM}

{ TFiltOptForm }

function TFiltOptForm.Execute: Boolean;
begin
  Result := ShowModal = mrOK;
end;

function TFiltOptForm.GetHMaxFak: Double;
begin
  Result := edHMax.ValueFloat;
end;

function TFiltOptForm.GetHMinFak: Double;
begin
  Result := edHMin.ValueFloat;
end;

function TFiltOptForm.GetModified: Boolean;
begin
  Result := edQMin.Modified or edQMax.Modified
            or edHMin.Modified or edHMax.Modified;
end;

function TFiltOptForm.GetQMaxFak: Double;
begin
  Result := edQMax.ValueFloat;
end;

function TFiltOptForm.GetQMinFak: Double;
begin
  Result := edQMin.ValueFloat;
end;

procedure TFiltOptForm.SetHMaxFak(const Value: Double);
begin
  edHMax.ValueFloat := Value;
end;

procedure TFiltOptForm.SetHMinFak(const Value: Double);
begin
  edHMin.ValueFloat := Value;
end;

procedure TFiltOptForm.SetModified(const Value: Boolean);
begin
  if not Value then
  begin
    edQmin.Modified := False;
    edQMax.Modified := False;
    edHMin.Modified := False;
    edHMax.Modified := False;
  end;
end;

procedure TFiltOptForm.SetQMaxFak(const Value: Double);
begin
  edQMax.ValueFloat := Value;
end;

procedure TFiltOptForm.SetQMinFak(const Value: Double);
begin
  edQMin.ValueFloat := Value;
end;

end.
