unit KopOporMiejscEdFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ElAbFrm, StdCtrls, Buttons, EditNew,
  KrMath, Ciecze, ElemUnit,
  jezyki;

type
  TOporMiejscEdForm = class(TElemAbstPrzeplFrm)
    labWspolcz: TLabel;
    labLamda: TLabel;
    edLamda: TEditN;
    labSredn: TLabel;
    labD: TLabel;
    edD: TEditN;
    labIlosc: TLabel;
    edIlosc: TEditN;
    labDUnit: TLabel;
    labPrzepl: TLabel;
    labQ: TLabel;
    labOpor: TLabel;
    labDH: TLabel;
    edQ: TEditN;
    edDH: TEditN;
    labNazwa: TLabel;
    edNazwa: TEdit;
    procedure edLamdaChange(Sender: TObject);
    procedure edDAccept(Sender: TObject; var Accept: Boolean);
    procedure edIloscAccept(Sender: TObject; var Accept: Boolean);
    procedure OKBtnClick(Sender: TObject);
    procedure edNazwaChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function GetEl: TOporMiejscowyFormula;
    procedure SetEl(const Value: TOporMiejscowyFormula);
  protected
    function  GetCanEditQ  :Boolean;         override;
    function  GetCanEdCiecz:Boolean;         override;
    procedure SetElement(e :TElemAbstract);  override;
    procedure SetCiecz(c :TCieczPlyw);       override;

    procedure Oblicz;
  public
    property El :TOporMiejscowyFormula read GetEl write SetEl;
  end;

var
  OporMiejscEdForm: TOporMiejscEdForm;

implementation

{$R *.DFM}

{ TOporMiejscEdForm }

function TOporMiejscEdForm.GetCanEdCiecz: Boolean;
begin
  Result := false;
end;

function TOporMiejscEdForm.GetCanEditQ: Boolean;
begin
  Result := false;
end;

function TOporMiejscEdForm.GetEl: TOporMiejscowyFormula;
begin
  Result := Element as TOporMiejscowyFormula;
end;

procedure TOporMiejscEdForm.Oblicz;
begin
  if (El = NIL) or (Ciecz = NIL) then
    EXIT;
  if IsZero(El.d) then
    edDH.ValueFloat := 0
  else
    edDH.ValueFloat := El.dH(Ciecz);
end;

procedure TOporMiejscEdForm.SetCiecz(c: TCieczPlyw);
begin
  inherited;
  if c <> NIL then
    edQ.ValueFloat := c.Q_m3h;
  Oblicz;
end;

procedure TOporMiejscEdForm.SetEl(const Value: TOporMiejscowyFormula);
begin
  Element := Value;
end;

procedure TOporMiejscEdForm.SetElement(e: TElemAbstract);
begin
  inherited;
  if El = NIL then
    EXIT;
  edNazwa.Text       := El.Nazwa;                         
  edLamda.ValueFloat := El.LambdaVal;
  edD.ValueFloat     := El.d*1000;
  edIlosc.ValueFloat := El.l;
end;

procedure TOporMiejscEdForm.edLamdaChange(Sender: TObject);
begin
  inherited;
  if El = NIL then
    EXIT;
  El.LambdaVal := edLamda.ValueFloat;
  Oblicz;
end;

procedure TOporMiejscEdForm.edDAccept(Sender: TObject;
  var Accept: Boolean);
begin
  inherited;
  if El = NIL then
    EXIT;
  El.d := edD.ValueFloat/1000;
  Oblicz;

end;

procedure TOporMiejscEdForm.edIloscAccept(Sender: TObject;
  var Accept: Boolean);
begin
  inherited;
  if El = NIL then
    EXIT;
  El.l := edIlosc.ValueFloat;
  Oblicz;
end;

procedure TOporMiejscEdForm.OKBtnClick(Sender: TObject);
var
  Accept  :Boolean;
begin
  inherited;
  if ActiveControl is TEditN then with TEditN(ActiveControl) do
  begin
    if Addr(OnAccept) <> NIL then
      OnAccept(ActiveControl, Accept)
  end;

end;

procedure TOporMiejscEdForm.edNazwaChange(Sender: TObject);
begin
  inherited;
  El.Nazwa := edNazwa.Text;
end;

procedure TOporMiejscEdForm.FormShow(Sender: TObject);
begin
  TTlumacz.dajobiekt.Tlumacz(self);
end;

end.
