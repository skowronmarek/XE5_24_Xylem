unit TypyListFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WkpGlob, StdCtrls, CheckLst, Buttons, ExtCtrls, IniFiles,
  Kr_Sys, Prod;

type
  TTypyForm = class(TForm)
    BottomPan: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    CheckList: TCheckListBox;
    procedure OKBtnClick(Sender: TObject);
    procedure CheckListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    FWszystkieTypy :TStrings;
    FWybraneTypy   :TStrings;
    procedure SetWszystkieTypy(const Value: TStrings);
    procedure SetWybraneTypy(const Value: TStrings);
  public
    { Public declarations }
    constructor Create( O :TComponent );   override;
    destructor Destroy;                    override;
    procedure  Init( const FN, Section :string ); overload;
    procedure  Init( const Section :string );  overload;
    property WszystkieTypy :TStrings read FWszystkieTypy write SetWszystkieTypy;
    property WybraneTypy   :TStrings read FWybraneTypy write SetWybraneTypy;
  end;

var
  TypyForm: TTypyForm;

implementation

{$R *.DFM}

var
  TypyIds    :TStringList;
  TypyDescr  :TStringList;

//  const
  cInited :Boolean = false;


{ TTypyosForm }

constructor TTypyForm.Create(O: TComponent);
begin
  inherited Create(O);
  FWszystkieTypy := TStringList.Create;
  FWybraneTypy   := TStringList.Create;

  if TypyIds = NIL then
    TypyIds    := TStringList.Create;
  if TypyDescr = NIL then
    TypyDescr  := TStringList.Create;

end;

destructor TTypyForm.Destroy;
begin
  FWszystkieTypy.Free;
  FWybraneTypy.Free;
  inherited Destroy;
end;

//const
//  cInited :Boolean = false;

procedure TTypyForm.Init(const FN, Section: string);
var
  i      :Integer;
  Ini    :TIniFile;
  s      :string;
begin
  if not cInited then
  begin
    Ini := TIniFile.Create(FN);
    try
      Ini.ReadSection( Section, TypyIds ); //Czyta wszystkie identyfikatory
      for i := 0 to TypyIds.Count-1 do
      begin
        s := Ini.ReadString( Section, TypyIds.Strings[i],
                                      TypyIds.Strings[i]);
        s := StrBefore( '|', s );
        //s := Format( '%-8s%s%s', [ TypyIds.Strings[i],#8, s] );
        TypyDescr.Add(s);
      end;
    finally
      Ini.Free;
    end;
    cInited := true;
  end;

  WszystkieTypy.Assign( TypyIds );
  CheckList.Items.Assign( TypyDescr );
end;

procedure  TTypyForm.Init( const Section :string );
var
  i, iProd      :Integer;
  Ini    :TCustomIniFile;
  prodId :string;
  bi     :TBaseInfo;
  sl     :TStringList;
  s      :string;
begin
  if not cInited then
  begin
    sl := TStringList.Create;
    try
      for iProd := 0 to Producenci.Count-1 do
      begin
        bi := Producenci.Prods[iProd].InfoBazT['PUMPS'];
        if bi = NIL then
          CONTINUE;
        ini := bi.tbsf;
        prodId := Producenci.Prods[iProd].Ident;

        Ini.ReadSection( Section, sl );
        //TypyIds.AddStrings(sl);
        for i := 0 to sl.Count-1 do
        begin
          s := Ini.ReadString( Section, sl[i],
                                        '');
          s := StrBefore( '|', s );
          //s := Format( '%-8s%s%s', [ TypyIds.Strings[i],#8, s] );
          TypyIds.Add( Format( '%s  /%s', [sl[i], prodId] ) );
          TypyDescr.Add(s);
        end;
      end;
    finally
      sl.Free;
    end;
    cInited := true;
  end;
  WszystkieTypy.Assign( TypyIds );
  CheckList.Items.Assign( TypyDescr );

end;


procedure TTypyForm.OKBtnClick(Sender: TObject);
var
  i       :Integer;
begin
  WybraneTypy.Clear;
  for i := 0 to WszystkieTypy.Count-1 do
  begin
    if CheckList.Checked[i] then
      WybraneTypy.Add( WszystkieTypy.Strings[i] );
  end;
end;

procedure TTypyForm.SetWszystkieTypy(const Value: TStrings);
var
  i, pos  :Integer;
begin
  FWszystkieTypy.Assign( Value );
  CheckList.Items.Clear;
  for i := 0 to Value.Count-1 do
  begin
    pos := TypyIds.IndexOf( WszystkieTypy.Strings[i] );
    if Pos >= 0 then
    begin
      CheckList.Items.Add( TypyDescr.Strings[pos] );
    end
    else
    begin
      CheckList.Items.Add( '-' );
    end;
  end;
end;


procedure TTypyForm.SetWybraneTypy(const Value: TStrings);
var
  i, p    :Integer;
begin
  FWybraneTypy.Clear;
  for i := 0 to CheckList.Items.Count-1 do
    CheckList.Checked[i] := false;
  for i := 0 to Value.Count-1 do
  begin
    p := WszystkieTypy.IndexOf(Value.Strings[i]);
    if p >= 0 then
    begin
      CheckList.Checked[p] := true;
      FWybraneTypy.Add(Value.Strings[i]);
    end;
  end;

end;


procedure TTypyForm.CheckListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  w      :Integer;
  R1, R2 :TRect;
begin
  if WerProdPomp then
    w := CheckList.Canvas.TextWidth( '000000000' )
  else
    w := CheckList.Canvas.TextWidth( '00000000000000' );
  R1 := Rect;
  R1.Right := R1.Left+w+2;
  R2 := Rect;
  R2.Left := R1.Right+2;
  CheckList.Canvas.TextRect( R1, R1.Left+2, R1.Top+1, WszystkieTypy[Index] );
  CheckList.Canvas.TextRect( R2, R2.Left+2, R2.Top+1, CheckList.Items[Index] );
end;

end.
