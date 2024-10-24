unit AktProdFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TbsFormU, StdCtrls, CheckLst, Prod, Buttons, ExtCtrls;

type
  TAktProdPompForm = class(TTbsForm)
    CheckList: TCheckListBox;
    ButtonPanel: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    FProds    :TList;
  public
    constructor Create(AOwner :TComponent);     override;
    destructor  Destroy;                        override;
    procedure Init;
    procedure LoadValues;
    procedure StoreValues;
    function Execute :Boolean;
  end;

var
  AktProdPompForm: TAktProdPompForm;

implementation

//uses SysInit;

{$R *.DFM}

constructor TAktProdPompForm.Create(AOwner: TComponent);
begin
  inherited;
  FProds := TList.Create;
  DefaultCloseAction := caHide;
end;

destructor TAktProdPompForm.Destroy;
begin
  FProds.Free;
  inherited;
end;

function TAktProdPompForm.Execute: Boolean;
begin
  ShowModal;
  result := ModalResult = mrOK;
end;

procedure TAktProdPompForm.Init;
var
  i       :Integer;
  P       :TProducent;
begin
  for i := 0 to Producenci.Count-1 do
  begin
    P := Producenci.Prods[i];
    if P.BazyDost['PUMPS'] and P.Dozwolone then
    begin
      FProds.Add(P);
      CheckList.Items.Add(P.Nazwa);
    end;
  end;
end;

procedure TAktProdPompForm.LoadValues;
var
  i       :Integer;
  P       :TProducent;
begin
  for i := 0 to FProds.Count-1 do
  begin
    P := FProds[i];
    CheckList.Checked[i] := P.Enable;
  end;
end;

procedure TAktProdPompForm.StoreValues;
var
  i       :Integer;
  P       :TProducent;
begin
  for i := 0 to FProds.Count-1 do
  begin                                   
    P := FProds[i];
    P.Enable := CheckList.Checked[i];
  end;
end;

end.
