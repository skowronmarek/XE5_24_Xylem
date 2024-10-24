unit KonstrFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst, Buttons, ExtCtrls;

type
  TKonstrForm = class(TForm)
    BottomPan: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    CheckList: TCheckListBox;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
    FWszystkieKonstr :TStrings;
    FWybraneKonstr   :TStrings;
    procedure SetWszystkieKonstr(const Value: TStrings);
    procedure SetWybraneKonstr(const Value: TStrings);
  public
    { Public declarations }
    constructor Create( O :TComponent );   override;
    destructor Destroy;                    override;
    property WszystkieKonstr :TStrings read FWszystkieKonstr write SetWszystkieKonstr;
    property WybraneKonstr   :TStrings read FWybraneKonstr write SetWybraneKonstr;
  end;

var
  KonstrForm: TKonstrForm;

implementation

{$R *.DFM}

uses
  WkpGlob, Prod;

var
  KonstrIds    :TStringList;
  KonstrDescr  :TStringList;

procedure Init;
var
  i       :Integer;
begin
  KonstrIds    := TStringList.Create;
  KonstrDescr  := TStringList.Create;

  KluczePompIni.ReadSection( 'Konstrukcja', KonstrIds );
  for i := 0 to KonstrIds.Count-1 do
  begin
    KonstrDescr.Add( KluczePompIni.ReadString( 'Konstrukcja',
                                            KonstrIds.Strings[i],
                                            KonstrIds.Strings[i]));
  end;
end;

{ TKonstrosForm }

constructor TKonstrForm.Create(O: TComponent);
var
  i         :Integer;
begin
  inherited Create(O);
  if KonstrIds = NIL then
    Init;
  FWszystkieKonstr := TStringList.Create;
  FWybraneKonstr   := TStringList.Create;
  WszystkieKonstr.Assign( KonstrIds );
  CheckList.Items.Assign( KonstrDescr );
end;

destructor TKonstrForm.Destroy;
begin
  FWszystkieKonstr.Free;
  FWybraneKonstr.Free;
  inherited Destroy;
end;

procedure TKonstrForm.OKBtnClick(Sender: TObject);
var
  i       :Integer;
begin
  WybraneKonstr.Clear;
  for i := 0 to WszystkieKonstr.Count-1 do
  begin
    if CheckList.Checked[i] then
      WybraneKonstr.Add( WszystkieKonstr.Strings[i] );
  end;
end;

procedure TKonstrForm.SetWszystkieKonstr(const Value: TStrings);
var
  i, pos  :Integer;
begin
  //FWszystkieKonstr.Assign( Value );
  FWszystkieKonstr.Clear;
  CheckList.Items.Clear;
  for i := 0 to Value.Count-1 do
  begin
    pos := KonstrIds.IndexOf( Value[i] );
    if Pos >= 0 then
    begin
      FWszystkieKonstr.Add( Value[i] );
      CheckList.Items.Add( KonstrDescr.Strings[pos] );
    //end
    //else
    //begin
    //  CheckList.Items.Add( Value[i] );
    end;
  end;
end;

procedure TKonstrForm.SetWybraneKonstr(const Value: TStrings);
var
  i, p    :Integer;
begin
  FWybraneKonstr.Clear;
  for i := 0 to CheckList.Items.Count-1 do
    CheckList.Checked[i] := false;
  for i := 0 to Value.Count-1 do
  begin
    p := WszystkieKonstr.IndexOf(Value.Strings[i]);
    if p >= 0 then
    begin
      CheckList.Checked[p] := true;
      FWybraneKonstr.Add(Value.Strings[i]);
    end;
  end;

end;



end.
