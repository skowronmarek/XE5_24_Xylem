unit KopZadU;

interface

uses
  SysUtils, Classes, ZadU, ElemUnit, Ciecze, ZadFrmU;

type

  TKopZad = class (TZadanie)
  protected
    procedure CreateMainForm;                        override;
    procedure DefineProperties( Filer :TFiler );     override;
    function  CzyWczytacKomponent( C :TComponent ): Boolean;   override;
  private
    FElList    :TElemList;
    FS        :string;
    FCiecz        :TCieczPlyw;
    FCieczRodz    :TCieczRodzaj;
    FOnChange :TNotifyEvent;
    FEdycjaCieczy: Boolean;
    FZapisacCiecz: Boolean;
    FZapisacCieczRodz: Boolean;
    procedure ReadList( Stream :TStream );
    procedure WriteList( Stream :TStream );

    procedure SetQ(const Value: real);
    function  GetQ :Real;
    function GetCieczRodz: TCieczRodzaj;
    function GetQ_m3h: Real;
    procedure SetQ_m3h(const Value: Real);
    function GetHStrat: Double;

  protected

    procedure SetCiecz(const Value: TCieczPlyw);       virtual;
    procedure SetCieczRodz(const Value: TCieczRodzaj); virtual;
    procedure SetEdycjaCieczy(const Value: Boolean);
    function  GetZapisacCiecz: Boolean;
    function  GetZapisacCieczRodz: Boolean;
    procedure SetZapisacCiecz(const Value: Boolean);
    procedure SetZapisacCieczRodz(const Value: Boolean);

  public
    fQ:real;
    property Hstrat :Double read GetHStrat;

    constructor Create( O :TComponent );             override;
    destructor  Destroy;                             override;

    procedure DoChange;                              override;

    procedure SetMainForm( F :TZadForm );

    function  dH( Q :Double ): Double; //Co to jest

    property Q:real  read GetQ   write SetQ  ;
    property Q_m3h :Real read GetQ_m3h write SetQ_m3h;
    property OnChange :TNotifyEvent read FOnChange write FOnChange;
    property ElList  :TElemList read  FElList;
    property ZapisacCiecz :Boolean read GetZapisacCiecz write SetZapisacCiecz;
    property ZapisacCieczRodz :Boolean read GetZapisacCieczRodz
                                       write SetZapisacCieczRodz;
  published
    property EdycjaCieczy :Boolean read FEdycjaCieczy write SetEdycjaCieczy;
    property Ciecz :TCieczPlyw read FCiecz write SetCiecz  stored GetZapisacCiecz;
    property CieczRodz :TCieczRodzaj read GetCieczRodz write SetCieczRodz
                                     stored GetZapisacCieczRodz;
  end;

implementation

uses
  r_opor;

{ TKopZad }

constructor TKopZad.Create(O: TComponent);
begin
  inherited Create(O);

  FElList := TElemList.Create1;    //!!!!
  FEdycjaCieczy := true;
end;

procedure TKopZad.CreateMainForm;
var
  F       :TRura;
begin
  F := TRura.Create(self);
  F.Zad := self;
  FMainForm := F;
  F.Init;
  F.Aktualizuj;
end;

function TKopZad.CzyWczytacKomponent(C: TComponent): Boolean;
begin
  if C = Ciecz then
    result := ZapisacCiecz and inherited CzyWczytacKomponent(C)
  else if C = CieczRodz then
    result := ZapisacCieczRodz and inherited CzyWczytacKomponent(C)
  else
    result := inherited CzyWczytacKomponent(C);
end;

procedure TKopZad.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty( 'ElList', ReadList, WriteList, true );

end;

destructor TKopZad.Destroy;    //czy to ma zostac
begin
  inherited Destroy;
end;

function TKopZad.dH(Q: Double): Double;
var
  svQ    :Double;
begin
  LockChange;
  try
    svQ := Ciecz.Q;
    Ciecz.Q_m3h := Q;
    try
      result := ElList.dH( Ciecz );
    finally
      Ciecz.Q := svQ;
    end;
  finally
    UnlockChange;
  end;
end;

// KR: 2001.03.13
// poprzednia wersja - w 431 juz dawno zmienione
//begin
//  Ciecz.Q_m3h := Q;
//  result := ElList.dH( Ciecz );
//end;

function TKopZad.GetCieczRodz: TCieczRodzaj;
begin
  result := Ciecz.Ciecz;
end;

function TKopZad.GetHStrat: Double;
begin
  if (ElList <> NIL) and (FCiecz <> NIL) and (FCiecz.Ciecz <> NIL) then
    result := ElList.dH(FCiecz)
  else
    result := 0;

end;

function TKopZad.GetQ_m3h: Real;
begin
  result := Q * 3600
end;

function TKopZad.GetZapisacCiecz: Boolean;
begin
  result := FZapisacCiecz;
end;

function TKopZad.GetZapisacCieczRodz: Boolean;
begin
  result := FZapisacCieczRodz;
end;



procedure TKopZad.ReadList(Stream: TStream);
begin
  ElList.Free;
  FElList := Stream.ReadComponent(nil) as TElemList;
end;

procedure TKopZad.SetCiecz(const Value: TCieczPlyw);
begin
  if FCiecz <> Value then
  begin
    FCiecz := Value;
    if FCiecz.Owner = self then
    begin
      FCiecz.Name := 'Ciecz';
      FCiecz.OnChange := ChangeEvent;
    end;
    DoChange;
  end;
end;

procedure TKopZad.SetCieczRodz(const Value: TCieczRodzaj);
begin
  if FCieczRodz <> Value then
  begin
    if (FCieczRodz <> NIL) then
      if (FCieczRodz.Owner = self) or (FCieczRodz.Owner = Ciecz) then
        FCieczRodz.Free;
    FCieczRodz := Value;
    if FCieczRodz.Owner = self then
    begin
      FCieczRodz.Name := 'CieczRodz';
      FCieczRodz.OnChange := ChangeEvent;
    end;
    if Ciecz <> NIL then
      Ciecz.Ciecz := Value;
    DoChange;
  end;
end;

procedure TKopZad.SetEdycjaCieczy(const Value: Boolean);
begin
  FEdycjaCieczy := Value;
  if FMainForm <> NIL then
    TRura(FMainForm).EdycjaCieczy := Value;
end;

procedure TKopZad.SetMainForm(F: TZadForm);
begin
  FMainForm := F;
end;

function TKopZad.GetQ: Real;
begin
  if Ciecz <> NIL then
    result := Ciecz.Q
  else
    result := FQ;
end;



procedure TKopZad.SetQ(const Value: real);
begin
  if Value <> Q then
    if Ciecz <> NIL then
    begin
      Ciecz.Q := Value;
      DoChange;
    end;
  FQ := Value;
end;

procedure TKopZad.SetQ_m3h(const Value: Real);
begin
  Q := Value / 3600;
end;

procedure TKopZad.SetZapisacCiecz(const Value: Boolean);
begin
  FZapisacCiecz := Value;
end;

procedure TKopZad.SetZapisacCieczRodz(const Value: Boolean);
begin
  FZapisacCieczRodz := Value;
end;

procedure TKopZad.WriteList(Stream: TStream);
begin
  Stream.WriteComponent(FElList);
end;

procedure TKopZad.DoChange;
begin
  inherited;
  if (not ChangeLocked) and Assigned(FOnChange) then
    FOnChange(self);
end;

initialization
  RegisterClass(TKopZad);


end.
