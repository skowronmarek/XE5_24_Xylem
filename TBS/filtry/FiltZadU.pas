unit FiltZadU;

interface

uses
  SysUtils, Classes, DB, Forms, DBTables,
  KR_Sys, KR_Class, Prod, PompySQL, OPompa, ZadU, PmpListU,
  WkpGlob, ZadPompSzuk,
  StdZadSzukPomp;

type
  TFiltrPompZad = class (TStdZadSzukPomp)
  private
    FGrupa :string;
    FPumpCount     :Integer;
    FTMax: Double;
    FTMin: Double;
    FPierwszy :Boolean;
    FZastDost :TStringList;
    FKonstrDost :TStringList;
    FTypyDost   :TStringList;
    FTypyDozw   :TStringList;
    FPamietajObiekty: Boolean;
    FSzukajWLiscie: Boolean;
    FBMList :TList;
    FListaDoSzuk :TList;
    FQMax: Double;
    FQMin: Double;
    FPompaDoCreat :TPompa;
    FPompaZListy  :Boolean;
    FSaObiekty :Boolean;
    FSprawdzajPPracy: Boolean;
    FSprQ: Boolean;
    FParamStr: string;
    FCaption: string;

    procedure SetGrupa(const Value: string);
    procedure SetPamietajObiekty(const Value: Boolean);
    procedure SetSzukajWLiscie(const Value: Boolean);
    procedure SetSprawdzajPPracy(const Value: Boolean);
    procedure SetSprQ(const Value: Boolean);
    procedure SetTypyDozw(const Value: TStringList);
    procedure SetCaption(const Value: string);
    procedure SetParamStr(const Value: string);
  protected
    procedure CreateMainForm;                      override;
    procedure CreateCharSel;                       override;

    procedure UstawZakrDB(DB :TDBPompy);
    procedure ClearListaDoSzuk;

    function  IdsOK( DB :TDBPompy ) :Boolean;      override;
    function  GetPumpCount: Integer;               override;
    function  DataBaseOK( DB :TDBPompy ) :Boolean; override;
    function  WarunekWst( DB :TDBPompy ) :Boolean; override;
    function  WarunekPost( Pmp :TPompa ) :Boolean; override;
    function  CreatePompaObj( DB :TDBPompy ) :TPompa; override;
    procedure AddPump( Pmp :TPompa; DB :TDBPompy ); override;
    function  PompaOK( Pmp :TPompa ) :Boolean;     override;
    function  PompaOKDB( DB :TDBPompy ) :Boolean;     override;
  public
    constructor Create( O :TComponent );           override;
    destructor  Destroy;                           override;
    procedure PrzygotujSzukanie;                   override;
    procedure SzukajPomp;                          override;

    function  DajPompe( APos :Integer ) :TPompa;

    property  TMin :Double read FTMin;
    property  TMax :Double read FTMax;
    property  QMin :Double read FQMin;
    property  QMax :Double read FQMax;
    property  ZastDost :TStringList read FZastDost;
    property  KonstrDost :TStringList read FKonstrDost;
    property  TypyDost :TStringList read FTypyDost;
    property  TypyDozw :TStringList read FTypyDozw write SetTypyDozw;
    property  SprawdzajPPracy :Boolean read FSprawdzajPPracy write SetSprawdzajPPracy;
    property  Caption :string read FCaption write SetCaption;
    property  ParamStr :string read FParamStr write SetParamStr;
    property  SaObiekty :Boolean read FSaObiekty;

  published
    property Grupa :string read FGrupa write SetGrupa;
    property Temp;
    property CheckTemp;
    property SprQ :Boolean read FSprQ write SetSprQ;
    property SzukajWLiscie :Boolean read FSzukajWLiscie write SetSzukajWLiscie;
    property PamietajObiekty :Boolean read FPamietajObiekty write SetPamietajObiekty;
  end;

var
  t1, t2, t3  :TTickCounter;

implementation

uses
  FiltZadFrmU;

type
  TProdBookmark = class
    Prod        :TProducent;
    Bookmark    :TBookmarkStr;
  end;

{ TFiltrPompZad }

procedure TFiltrPompZad.AddPump(Pmp: TPompa; DB :TDBPompy);
var
  bm      :TProdBookmark;
begin
  if PamietajObiekty then
    if FPompaZListy then
    begin
      FPumpList.AddPump( Pmp );
      Pmp.CharSel := FCharSel;
      FPompaZListy := false;
      DoOnAddPump(Pmp, DB);
    end
    else
      inherited AddPump(Pmp, DB)
  else
  begin
    bm := TProdBookmark.Create;
    bm.Prod := DB.Producent;
    //bm.Bookmark := DB.A.Bookmark;
    bm.Bookmark := TBookmarkStr(DB.A.Bookmark);

    FBMList.Add( bm );
    DoOnAddPump(Pmp, DB);
    Pmp.Free;
  end;
  inc(FPumpCount);
end;

procedure TFiltrPompZad.ClearListaDoSzuk;
var
  i       :Integer;
begin
  if FListaDoSzuk is TPumpList then
    FListaDoSzuk.Free
  else if FListaDoSzuk <> NIL then
  begin
    for i := 0 to FListaDoSzuk.Count-1 do
    begin
      TObject(FListaDoSzuk.Items[i]).Free;
      FListaDoSzuk.Items[i] := NIL;
    end;
    FListaDoSzuk.Free;
  end;
  FListaDoSzuk := NIL;
end;

constructor TFiltrPompZad.Create(O: TComponent);
begin
  inherited Create(O);

  FZastDost := TStringList.Create;
  FZastDost.Sorted := true;
  FZastDost.Duplicates := dupIgnore;

  FKonstrDost := TStringList.Create;
  FKonstrDost.Sorted := true;
  FKonstrDost.Duplicates := dupIgnore;

  FTypyDost := TStringList.Create;
  FTypyDost.Sorted := true;
  FTypyDost.Duplicates := dupIgnore;

  FTypyDozw := TStringList.Create;
end;

procedure TFiltrPompZad.CreateCharSel;
begin
  if SprawdzajPPracy then
    inherited CreateCharSel
  else
    FCharSel := NIL;
end;

procedure TFiltrPompZad.CreateMainForm;
var
  F       :TFiltrPompForm;
  Bin     :TTable;

begin
  F := TFiltrPompForm.Create(self);
  FMainForm := F;

  F.Zad := self;
end;

function TFiltrPompZad.CreatePompaObj(DB: TDBPompy): TPompa;
begin
  if FPompaDoCreat = NIL then
  begin
    if PamietajObiekty or SprawdzajPPracy then
      result := inherited CreatePompaObj(DB)
    else
      result := NIL
  end
  else
  begin
    result := FPompaDoCreat;
    FPompaDoCreat := NIL;
    FPompaZListy  := true;
  end;
end;

function TFiltrPompZad.DajPompe(APos: Integer): TPompa;
var
  pbm    :TProdBookmark;
  ADB    :TDBPompy;
  APr    :TProducent;
begin
  if PamietajObiekty then
    Result := Pumps[APos]
  else
  begin
    pbm := FBMList.Items[APos];
    APr := pbm.Prod;
    ADB := TDBPompy.CreateForProd( self, APr );
    try
      //ADB.A.Bookmark := pbm.Bookmark;
      ADB.A.Bookmark := TBookmark(pbm.Bookmark);

      ADB.Update;
      Result := CreatePump( NIL, ADB );
      Result.DBCreateCopy(ADB);
    finally
      ADB.Free;
    end;
  end;
end;

function TFiltrPompZad.DataBaseOK(DB: TDBPompy): Boolean;
begin
  result := inherited DataBaseOK(DB) and (DB.T.FindField('GRUPA') <> NIL);
end;

destructor TFiltrPompZad.Destroy;
begin
  FZastDost.Free;
  FKonstrDost.Free;
  FTypyDost.Free;
  FTypyDozw.Free;
  ClearListaDoSzuk;
  inherited Destroy;
end;

function TFiltrPompZad.GetPumpCount: Integer;
begin
  result := FPumpCount;
end;

function TFiltrPompZad.IdsOK(DB: TDBPompy): Boolean;
var
  i      :Integer;
  s      :string;
begin
  result := inherited IdsOK(DB);
  if result and (TypyDozw.Count > 0) then
  begin
    result := false;
    i := 0;
    s := DB.A.FieldByName('ID1').AsString;
    if not WerProdPomp then
      s := Format( '%s  /%s', [s,DB.Producent.Ident] );
    while (i < TypyDozw.Count) and (not result) do
    begin
      result := (TypyDozw[i] = s);
      inc(i);
    end;
  end;
end;

function TFiltrPompZad.PompaOK(Pmp: TPompa): Boolean;
begin
  if SprawdzajPPracy then
    result := inherited PompaOK(Pmp)
  else
    result := true;
end;


function TFiltrPompZad.PompaOKDB(DB: TDBPompy): Boolean;
begin
  result := inherited PompaOKDB(DB);
  if result then
    UstawZakrDB(DB);
end;

procedure TFiltrPompZad.PrzygotujSzukanie;
var
  i       :Integer;
begin
  ClearListaDoSzuk;
  if not SzukajWLiscie then
  begin
    if FSaObiekty then
    begin
      FListaDoSzuk := FPumpList;
      FPumpList := TPumpList.Create;
    end
    else
    begin
      FListaDoSzuk := FBMList;
    end;
    ClearListaDoSzuk;
    inherited PrzygotujSzukanie;
    FPompaDoCreat := NIL;
  end
  else
  begin
    SetState( zspsPrzygotowania );
    WyczyscProds;
    if FSaObiekty then
    begin
      FListaDoSzuk := FPumpList;
      FPumpList := TPumpList.Create;
    end
    else
    begin
      FListaDoSzuk := FBMList;
    end;
    FTotalPomp := FListaDoSzuk.Count;
    FPompPrzeszuk := 0;
  end;
  if not PamietajObiekty then
    FBMList := TList.Create;
  FPumpCount := 0;
  FZastDost.Clear;
  FKonstrDost.Clear;
  FTypyDost.Clear;
  FPierwszy  := true;
end;

procedure TFiltrPompZad.SetCaption(const Value: string);
begin
  FCaption := Value;
  if FMainForm <> NIL then
  begin
    FMainForm.Caption := Value;
  end;
end;

procedure TFiltrPompZad.SetGrupa(const Value: string);
begin
  FGrupa := Value;
end;

procedure TFiltrPompZad.SetPamietajObiekty(const Value: Boolean);
begin
  FPamietajObiekty := Value;
end;

procedure TFiltrPompZad.SetParamStr(const Value: string);
begin
  FParamStr := Value;
end;

procedure TFiltrPompZad.SetSprawdzajPPracy(const Value: Boolean);
begin
  FSprawdzajPPracy := Value;
end;

procedure TFiltrPompZad.SetSprQ(const Value: Boolean);
begin
  if FSprQ = Value then
    EXIT;
  FSprQ := Value;
  if Value then
    inherited CreateCharSel
  else
  begin
    FCharSel.Free;
    FCharSel := NIL;
  end;
end;

procedure TFiltrPompZad.SetSzukajWLiscie(const Value: Boolean);
begin
  FSzukajWLiscie := Value;
end;

procedure TFiltrPompZad.SetTypyDozw(const Value: TStringList);
begin
  FTypyDozw.Assign(Value);
end;

procedure TFiltrPompZad.SzukajPomp;
var
  i       :Integer;
  Pr      :TProducent;
  DB      :TDBPompy;
  Pmp     :TPompa;
  bm      :TBookmark;
  pbm     :TProdBookmark;
begin
  if not SzukajWLiscie then
    inherited SzukajPomp
  else
  begin
    if FInProcSzuk then
    begin
      EXIT;
    end;
    FInProcSzuk := true;
    if State <> zspsPrzygotowania then
      PrzygotujSzukanie;
    SetState( zspsSzukanie );
    UpdateForm;
    Pr := NIL;
    DB := NIL;
    for i := 0 to FListaDoSzuk.Count-1 do
    begin
      try
        LoopMessages;
      except on EPrzerwijSzukanie do
        BREAK;
      end;
      if FSaObiekty then
      begin
        Pmp := (FListaDoSzuk as TPumpList).Pumps[i];
        FPompaDoCreat := Pmp;
        if not PamietajObiekty then
          DB := Pmp.DB.MakeCopy(Self)
        else
          DB := Pmp.DB;
      end
      else
      begin
        pbm := FListaDoSzuk.Items[i];
        if (Pr = NIL) or (Pr <> pbm.Prod) or (DB = NIL) then
        begin
          Pr := pbm.Prod;
          DB.Free;
          DB := TDBPompy.CreateForProd( self, Pr );
        end;
        //DB.A.Bookmark := pbm.Bookmark;
        DB.A.Bookmark := TBookmark(pbm.Bookmark);

        pbm.Free;
        FListaDoSzuk.Items[i] := NIL;;
      end;
      PompaOKDB( DB );
      if FSaObiekty and not PamietajObiekty then
        DB.Free;
      inc(FPompPrzeszuk);
    end;
    ClearListaDoSzuk;
    SetState( zspsWyniki );
    FInProcSzuk := false;
  end;
  FSaObiekty := PamietajObiekty;
  SzukajWLiscie := true;
  UpdateForm;
end;

procedure TFiltrPompZad.UstawZakrDB(DB :TDBPompy);
var
  d       :Double;
  s, s1, s2 :string;
  i       :Integer;
begin
  if FPierwszy then
  begin
    FPierwszy := false;
    FQMin := DB.A.FieldByName('QMin').AsFloat;
    FQMax := DB.A.FieldByName('QMax').AsFloat;
    FTMin := DB.T.FieldByName('T_Min').AsFloat;
    FTMax := DB.T.FieldByName('T_Max').AsFloat;
  end
  else
  begin
    d := DB.A.FieldByName('QMin').AsFloat;
    if d < FQMin then
      FQMin := d;
    d := DB.A.FieldByName('QMax').AsFloat;
    if d > FQMax then
      FQMax := d;

    d := DB.T.FieldByName('T_Min').AsFloat;
    if d < FTMin then
      FTMin := d;
    d := DB.T.FieldByName('T_Max').AsFloat;
    if FTMax < d then
      FTMax := d;
  end;

  s     := StrBehinde( '/', DB.T.FieldByName('KL_ZAST').AsString );
  while s <> '' do
  begin
    s1 := StrBefore( '/', s );
    s  := StrBehinde( '/', s );
    if (s1 <> '') and (s1[1] <> '#') then
      ZastDost.Add(s1);
  end;

  s     := StrBehinde( '/', DB.T.FieldByName('KONSTR').AsString );
  while s <> '' do
  begin
    s1 := StrBefore( '/', s );
    s  := StrBehinde( '/', s );
    KonstrDost.Add(s1);
  end;

  s := DB.A.FieldByName('ID1').AsString;
  if s <> '' then
    if WerProdPomp then
      FTypyDost.Add(s)
    else
      FTypyDost.Add( Format( '%s  /%s', [s,DB.Producent.Ident] ));
end;

function TFiltrPompZad.WarunekPost(Pmp: TPompa): Boolean;
begin
  if SprawdzajPPracy then
    Result := inherited WarunekPost(Pmp)
  else
    Result := True;
end;

function TFiltrPompZad.WarunekWst(DB: TDBPompy): Boolean;
begin
  result := KluczStrOK( Grupa, DB.T.FieldByName('GRUPA').AsString )
            and inherited WarunekWst(DB);
end;

end.
