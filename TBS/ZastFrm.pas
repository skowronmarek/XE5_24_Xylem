unit ZastFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WkpGlob, StdCtrls, CheckLst, Buttons, ExtCtrls;

type
  TZastosForm = class(TForm)
    BottomPan: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    CheckList: TCheckListBox;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
    FWszystkieZast :TStrings;
    FWybraneZast   :TStrings;
    procedure SetWszystkieZast(const Value: TStrings);
    procedure SetWybraneZast(const Value: TStrings);
  public
    { Public declarations }
    constructor Create( O :TComponent );   override;
    destructor Destroy;                    override;
    property WszystkieZast :TStrings read FWszystkieZast write SetWszystkieZast;
    property WybraneZast   :TStrings read FWybraneZast write SetWybraneZast;
  end;

var
  ZastosForm: TZastosForm;

implementation

{$R *.DFM}

uses
  Prod;

var
  ZastIds    :TStringList;
  ZastDescr  :TStringList;

procedure Init;
var
  i       :Integer;
begin
  ZastIds    := TStringList.Create;
  ZastDescr  := TStringList.Create;


  KluczePompIni.ReadSection( 'Zastosowania', ZastIds );
  for i := 0 to ZastIds.Count-1 do
  begin
    ZastDescr.Add( KluczePompIni.ReadString( 'Zastosowania',
                                            ZastIds.Strings[i],
                                            ZastIds.Strings[i]));
  end;

end;

{ TZastosForm }

constructor TZastosForm.Create(O: TComponent);
var
  i         :Integer;
begin
  inherited Create(O);
  if ZastIds = NIL then
    Init;
  FWszystkieZast := TStringList.Create;
  FWybraneZast   := TStringList.Create;
  WszystkieZast.Assign( ZastIds );
  CheckList.Items.Assign( ZastDescr );
end;

destructor TZastosForm.Destroy;
begin
  FWszystkieZast.Free;
  FWybraneZast.Free;
  inherited Destroy;
end;

procedure TZastosForm.OKBtnClick(Sender: TObject);
var
  i       :Integer;
begin
  WybraneZast.Clear;
  for i := 0 to WszystkieZast.Count-1 do
  begin
    if CheckList.Checked[i] then
      WybraneZast.Add( WszystkieZast.Strings[i] );
  end;
end;

procedure TZastosForm.SetWszystkieZast(const Value: TStrings);
var
  i, pos  :Integer;
begin
  FWszystkieZast.Clear;
  CheckList.Items.Clear;
  for i := 0 to Value.Count-1 do
  begin
    pos := ZastIds.IndexOf( Value[i] );
    if Pos >= 0 then
    begin
      FWszystkieZast.Add(Value[i]);
      CheckList.Items.Add( ZastDescr.Strings[pos] );

    //end
    //else
    //begin
    //  CheckList.Items.Add( Value[i] );
    end;
  end;
end;

procedure TZastosForm.SetWybraneZast(const Value: TStrings);
var
  i, p    :Integer;
begin
  FWybraneZast.Clear;
  for i := 0 to CheckList.Items.Count-1 do
    CheckList.Checked[i] := false;
  for i := 0 to Value.Count-1 do
  begin
    p := WszystkieZast.IndexOf(Value.Strings[i]);
    if p >= 0 then
    begin
      CheckList.Checked[p] := true;
      FWybraneZast.Add(Value.Strings[i]);
    end;
  end;

end;


end.
