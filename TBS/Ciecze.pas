unit Ciecze;

interface

uses
  SysUtils, Classes, DB, FunctU,
  KrMath, ZadCompU;

type
  TCiecz = class( TZadComponent )
  private
    function GetNi_cSt: Double;
  protected
    function GetNazwa :string;       virtual; abstract;
    function GetTemp  :double;       virtual; abstract;
    function GetNi    :double;       virtual; abstract;
    function GetRo    :double;       virtual; abstract;
    function GetPv    :double;       virtual; abstract;
    function GetTMin  :double;       virtual; abstract;
    function GetTMax  :double;       virtual; abstract;

    function CreateNewCopy( O :TComponent ) :TCiecz; virtual;
    procedure SetCopyVal( Copy :TCiecz );            virtual;
  public
    function Symbol   :string;       virtual; abstract;
    function CreateCopy( O :TComponent ) :TCiecz;  virtual;

    property Nazwa    :string  read GetNazwa;
    property T        :Double  read GetTemp;
    property Ni       :Double  read GetNi;
    property Ro       :Double  read GetRo;
    property Pv       :Double  read GetPv;
    property TMin     :Double  read GetTMin;
    property TMax     :Double  read GetTMax;
    property Ni_cSt   :Double  read GetNi_cSt;
  end;

  TCieczClass = class of TCiecz;

  TCieczPlyw = class;

  TCieczRodzaj = class (TCiecz)
  private
    FCieczPlyw :TCieczPlyw;
    FOnChange: TNotifyEvent;
  protected
    procedure SetCopyVal( Copy :TCiecz );       override;
    function  GetTemp :Double;                  override;
    procedure SetTemp( Value :Double );

    function GetNi    :double;       override;
    function GetRo    :double;       override;
    function GetPv    :double;       override;
    procedure DoChange;              virtual;
  public
    property T :Double  read GetTemp write SetTemp;
    function NiOdT( AT :Real ) :Real;       virtual; abstract;
    function RoOdT( AT :Real ) :Real;       virtual; abstract;
    function PvOdT( AT :Real ) :Real;       virtual; abstract;

    procedure CzytajZBazy( DB :TDataSet );  virtual; abstract;
    property  OnChange :TNotifyEvent read FOnChange write FOnChange;
  end;

  TCieczRodzajClass = class of TCieczRodzaj;


  TCieczPlyw = class (TCiecz)
  private
    FQ        :Double;
    FTemp    :Double;
    FCiecz: TCieczRodzaj;
    FOnChange: TNotifyEvent;
    FPomocn: Boolean;
    procedure SetQm3h( v : Double );
    function  GetQm3h  :Double;

    procedure SetTemp( Value :Double ); virtual;

    procedure SetCiecz(const Value: TCieczRodzaj);

    procedure ReadCiecz( Reader :TReader );
    procedure WriteCiecz( Writer :TWriter );
    procedure SetQ(const Value: Double);
    procedure SetPomocn(const Value: Boolean);
  protected
    function GetNazwa :string;       override;
    function GetTemp  :double;       override;
    function GetNi    :double;       override;
    function GetRo    :double;       override;
    function GetPv    :double;       override;
    function GetTMin  :double;       override;
    function GetTMax  :double;       override;

    procedure SetCopyVal( Copy :TCiecz );       override;

    //procedure DefineProperties(Filer: TFiler);  override;

    function  GetZapisacCiecz :Boolean;
    procedure DoChange;              virtual;
  public
    function Symbol   :string;       override;
    property  Q_m3h :Double    read GetQm3h write SetQm3h;
    property  OnChange :TNotifyEvent read FOnChange write FOnChange;
    property  Pomocn :Boolean read FPomocn write SetPomocn;
  published
    property  Q     :Double    read FQ      write SetQ;
    property  T     write SetTemp;
    property  Ciecz :TCieczRodzaj read FCiecz write SetCiecz stored GetZapisacCiecz;
  end;

  TCieczH2O = class (TCieczRodzaj)
  private
    FNazwa    :string;
    procedure SetNazwa(const Value: string);
  protected
    function GetNazwa :string;       override;
    function GetTMin  :double;       override;
    function GetTMax  :double;       override;
  public
    function Symbol   :string;       override;
    function NiOdT( AT :Real ) :Real;       override;
    function RoOdT( AT :Real ) :Real;       override;
    function PvOdT( AT :Real ) :Real;       override;
    procedure CzytajZBazy( DB :TDataSet );  override;

  published
    property Nazwa :string read GetNazwa write SetNazwa;
  end;

  TStdDBCiecz = class (TCieczRodzaj)
  private
    FNazwa    :string;
    FSymbol   :string;
    FTMin     :Real;
    FTMax     :Real;

    procedure ReadRoFunct( S :TStream );
    procedure WriteRoFunct( S :TStream );
    procedure ReadNiFunct( S :TStream );
    procedure WriteNiFunct( S :TStream );
    procedure ReadPvFunct( S :TStream );
    procedure WritePvFunct( S :TStream );
    procedure SetNazwa(const Value: string);

  protected
    FNiFunct :TRealFunctObject;
    FRoFunct :TRealFunctObject;
    FPvFunct :TRealFunctObject;

    procedure DefineProperties( Filer :TFiler ); override;

    function GetTMin  :double;       override;
    function GetTMax  :double;       override;
    function GetNazwa :string;       override;

  public
    function Symbol   :string;       override;
    function NiOdT( AT :Real ) :Real;       override;
    function RoOdT( AT :Real ) :Real;       override;
    function PvOdT( AT :Real ) :Real;       override;
    procedure CzytajZBazy( DB :TDataSet );  override;
  published
    property Nazwa :string read GetNazwa write SetNazwa;
    property TMin;
    property TMax;
  end;

  TCieczConst = class (TCieczRodzaj)
  private
    FNi   :Double;
    FRo   :Double;
    FPv   :Double;
    procedure SetNi(const Value: Double);
    procedure SetPv(const Value: Double);
    procedure SetRo(const Value: Double);
    procedure SetNi_cSt(const Value: Double);
  protected
    function GetNazwa :string;       override;
    function GetTMin  :double;       override;
    function GetTMax  :double;       override;
  public
    function NiOdT( AT :Real ) :Real;       override;
    function RoOdT( AT :Real ) :Real;       override;
    function PvOdT( AT :Real ) :Real;       override;
    procedure CzytajZBazy( DB :TDataSet );  override;
    property Ni_cSt :Double write SetNi_cSt;
  published
    property Ni     write SetNi;
    property Ro     write SetRo;
    property Pv     write SetPv;
  end;

function CreateH2OPlyw( O :TComponent; Qm3h, T :Double ): TCieczPlyw;
function CreateCieczFromDB( DB :TDataSet; Owner :TComponent ) :TCieczRodzaj;

procedure RejestrujCiecz( const AObjId :string; AClassRef :TCieczRodzajClass );

implementation

var
  RodzajeCieczy :TStringList;

{ TCiecz }

function TCiecz.CreateCopy(O: TComponent): TCiecz;
begin
  result := CreateNewCopy(O);
  SetCopyVal(result);
end;

function TCiecz.CreateNewCopy(O: TComponent): TCiecz;
begin
  result := TCieczClass(ClassType).Create(O);
end;

function TCiecz.GetNi_cSt: Double;
begin
  result := Ni * 1000000;
end;

procedure TCiecz.SetCopyVal(Copy: TCiecz);
begin

end;

{ TCieczPlyw }
{
procedure TCieczPlyw.DefineProperties(Filer: TFiler);
begin
  Filer.DefineProperty( 'Ciecz', ReadCiecz, WriteCiecz, true );
end;
}
function TCieczPlyw.GetNazwa: string;
begin
  result := Ciecz.Nazwa;
end;

function TCieczPlyw.GetNi: double;
begin
  result := Ciecz.Ni;
end;

function TCieczPlyw.GetPv: double;
begin
  result := Ciecz.Pv;
end;

function TCieczPlyw.GetQm3h: Double;
begin
  result := Q * 3600;
end;

function TCieczPlyw.GetRo: double;
begin
  result := Ciecz.Ro;
end;

procedure TCieczPlyw.ReadCiecz(Reader: TReader);
begin
  FCiecz := Reader.ReadComponent( NIL ) as TCieczRodzaj;
end;

procedure TCieczPlyw.SetCiecz(const Value: TCieczRodzaj);
begin
  FCiecz := Value;
  if not Pomocn then
  begin
    FCiecz.FCieczPlyw := self;
    DoChange;
  end;
end;

procedure TCieczPlyw.SetCopyVal(Copy: TCiecz);
begin
  (Copy as TCieczPlyw).Ciecz := Ciecz.CreateCopy(Copy) as TCieczRodzaj;
  (Copy as TCieczPlyw).Ciecz.Name := 'Ciecz';
  (Copy as TCieczPlyw).Q := Q;
  (Copy as TCieczPlyw).T := T;
end;

procedure TCieczPlyw.SetQm3h(v: Double);
begin
  Q := v / 3600;
end;

function TCieczPlyw.Symbol: string;
begin
  result := 'CieczPlyw';
end;

procedure TCieczPlyw.WriteCiecz(Writer: TWriter);
begin
  Writer.WriteComponent(FCiecz);
end;

function TCieczPlyw.GetTemp: double;
begin
  result := FTemp;
end;

procedure TCieczPlyw.SetTemp(Value: Double);
begin
  FTemp := Value;
  DoChange;
end;

function TCieczPlyw.GetTMax: double;
begin
  result := FCiecz.TMax;
end;

function TCieczPlyw.GetTMin: double;
begin
  result := FCiecz.TMin;
end;

function TCieczPlyw.GetZapisacCiecz: Boolean;
begin
  result := (Ciecz <> NIL) and
            ( (Ciecz.Owner = self) or (Ciecz.Owner = self.Owner) );

end;


{ TCieczH2O }

procedure TCieczH2O.CzytajZBazy(DB: TDataSet);
begin
  FNazwa := DB.FieldByName('NAZWA').AsString;
end;

function TCieczH2O.GetNazwa: string;
begin
  result := FNazwa;
end;

function TCieczH2O.GetTMax: double;
begin
  result := 100;
end;

function TCieczH2O.GetTMin: double;
begin
  result := 0;
end;

function TCieczH2O.NiOdT(AT: Real): Real;
begin
  result := 1.791e-6*EXP(F_DIV(468, AT+118.6)-3.948);
end;

function TCieczH2O.PvOdT(AT: Real): Real;
begin
  result := 610.8*EXP(17.174-F_DIV(4053.06, 236+AT) + 6e-5*AT*sin(3.14*AT/100));
end;

function TCieczH2O.RoOdT(AT: Real): Real;
begin
  result := F_DIV(1000 ,  4.074e-6*sqr(AT-1)
                          - 0.0101/PI * cos(PI*(AT-4)/104)
                          + 1.0033);
end;

procedure TCieczH2O.SetNazwa(const Value: string);
begin
  FNazwa := Value;
  DoChange;
end;

function TCieczH2O.Symbol: string;
begin
  result := 'H2O';
end;

function CreateH2OPlyw( O :TComponent; Qm3h, T :Double ): TCieczPlyw;
var
  H2O    :TCieczH2O;
begin
  result := TCieczPlyw.Create(O);
  H2O    := TCieczH2O.Create(NIL);
//  H2O.Name := ;
  result.Ciecz := H2O;
  result.T  := T;
  result.Q_m3h  := Qm3h;
end;


{ TCieczRodzaj }

procedure TCieczRodzaj.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(self);
end;

function TCieczRodzaj.GetNi: double;
begin
  result := NiOdT(T);
end;

function TCieczRodzaj.GetPv: double;
begin
  result := PvOdT(T);
end;

function TCieczRodzaj.GetRo: double;
begin
  result := RoOdT(T);
end;

function TCieczRodzaj.GetTemp: Double;
begin
  result := FCieczPlyw.T;
end;

procedure TCieczRodzaj.SetCopyVal(Copy: TCiecz);
begin
  inherited SetCopyVal(Copy);
end;

procedure TCieczRodzaj.SetTemp(Value: Double);
begin
  FCieczPlyw.T := Value;
end;





{ TStdDBCiecz }

procedure TStdDBCiecz.CzytajZBazy(DB: TDataSet);
var
  ATemp   :array of Double;
  A       :array of Double;
  N       :Integer;
  i       :Integer;
  pt1     :Integer;
  szF     :TSplineFunctObj;
begin
  FNazwa := DB.FieldByName('NAZWA').AsString;
  FSymbol := DB.FieldByName('Symbol').AsString;
  if DB.FieldByName('H_MET').AsString = 'SZ' then
  begin
    N := DB.FieldByName('N_PT').AsInteger;
    pt1 := DB.FieldByName('PT1').Index;

    SetLength(ATemp, N);
    for i := 0 to N-1 do
    begin
      ATemp[i] := DB.Fields[pt1+i].AsFloat;
    end;
    FTMin := ATemp[0];
    FTMax := ATemp[N-1];

    SetLength(A, N);
    for i := 0 to N-1 do
    begin
      A[i] := DB.Fields[pt1+N+i].AsFloat;
    end;
    szF := TSplineFunctObj.Create(self);
    FRoFunct := szF;
    szF.Init( ATemp, A, N );

    for i := 0 to N-1 do
    begin
      A[i] := DB.Fields[pt1+2*N+i].AsFloat/1000000;
    end;
    szF := TSplineFunctObj.Create(self);
    FNiFunct := szF;
    szF.Init( ATemp, A, N );

    for i := 0 to N-1 do
    begin
      A[i] := DB.Fields[pt1+3*N+i].AsFloat;
    end;
    szF := TSplineFunctObj.Create(self);
    FPvFunct := szF;
    szF.Init( ATemp, A, N );
  end;
end;

procedure TStdDBCiecz.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty( 'RoFunct', ReadRoFunct, WriteRoFunct, true );
  Filer.DefineBinaryProperty( 'NiFunct', ReadNiFunct, WriteNiFunct, true );
  Filer.DefineBinaryProperty( 'PvFunct', ReadPvFunct, WritePvFunct, true );
end;

function TStdDBCiecz.GetNazwa: string;
begin
  result := FNazwa;
end;

function TStdDBCiecz.GetTMax: double;
begin
  result := FTMax;
end;

function TStdDBCiecz.GetTMin: double;
begin
  result := FTMin;
end;

function TStdDBCiecz.NiOdT(AT: Real): Real;
begin
  result := FNiFunct.Value(AT);
end;

function TStdDBCiecz.PvOdT(AT: Real): Real;
begin
  result := FPvFunct.Value(AT)*1000;  // w bazie jest w kPa
end;

procedure TStdDBCiecz.ReadNiFunct(S: TStream);
begin
  FNiFunct := S.ReadComponent( NIL ) as TRealFunctObject;
  InsertComponent(FNiFunct);
end;

procedure TStdDBCiecz.ReadPvFunct(S: TStream);
begin
  FPvFunct:= S.ReadComponent( NIL ) as TRealFunctObject;
  InsertComponent(FPvFunct);
end;

procedure TStdDBCiecz.ReadRoFunct(S: TStream);
begin
  FRoFunct:= S.ReadComponent( NIL ) as TRealFunctObject;
  InsertComponent(FRoFunct);
  if FRoFunct is TPointListFunctObject then
  begin
    FTMin := TPointListFunctObject(FRoFunct).XMin;
    FTMax := TPointListFunctObject(FRoFunct).XMax;
  end;
end;

function TStdDBCiecz.RoOdT(AT: Real): Real;
begin
  result := FRoFunct.Value(AT);
end;

procedure TStdDBCiecz.SetNazwa(const Value: string);
begin
  FNazwa := Value;
  DoChange;
end;

function TStdDBCiecz.Symbol: string;
begin
  result := FSymbol;
end;

procedure RejestrujCiecz( const AObjId :string; AClassRef :TCieczRodzajClass );
begin
  RodzajeCieczy.AddObject( AObjId, TObject(AClassRef) );
end;

function CreateCieczFromDB( DB :TDataSet; Owner :TComponent ) :TCieczRodzaj;
var
  ObjId  :string;
  ClRef  :TCieczRodzajClass;
  i      :Integer;
begin
  ObjId := db.FieldByName('OBJ_ID').AsString;
  i := RodzajeCieczy.IndexOf( ObjId );
  if i >= 0 then
  begin
    ClRef := pointer( RodzajeCieczy.Objects[i] );
    result := ClRef.Create(Owner);
  end
  else
  begin
    result := TStdDBCiecz.Create(Owner);
  end;
  result.CzytajZBazy(DB);
end;



procedure TStdDBCiecz.WriteNiFunct(S: TStream);
begin
  S.WriteComponent(FNiFunct);
end;

procedure TStdDBCiecz.WritePvFunct(S: TStream);
begin
  S.WriteComponent(FPvFunct);
end;

procedure TStdDBCiecz.WriteRoFunct(S: TStream);
begin
  S.WriteComponent(FRoFunct);
end;

{ TCieczConst }

procedure TCieczConst.CzytajZBazy( DB :TDataSet );
begin
  // Zeby nie bylo abstrakcyjne
end;

function TCieczConst.GetNazwa: string;
begin
  result := '';
end;

function TCieczConst.GetTMax: double;
begin
  result := 100000;
end;

function TCieczConst.GetTMin: double;
begin
  result := -270;
end;

function TCieczConst.NiOdT(AT: Real): Real;
begin
  result := FNi;
end;

function TCieczConst.PvOdT(AT: Real): Real;
begin
  result := FPv;
end;

function TCieczConst.RoOdT(AT: Real): Real;
begin
  result := FRo;
end;

procedure TCieczConst.SetNi(const Value: Double);
begin
  FNi := Value;
  DoChange;
end;

procedure TCieczConst.SetNi_cSt(const Value: Double);
begin
  Ni := Value/1000000;
end;

procedure TCieczConst.SetPv(const Value: Double);
begin
  FPv := Value;
  DoChange;
end;

procedure TCieczConst.SetRo(const Value: Double);
begin
  FRo := Value;
  DoChange;
end;

procedure TCieczPlyw.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(self);
end;

procedure TCieczPlyw.SetQ(const Value: Double);
begin
  if FQ <> Value then
  begin
    FQ := Value;
    DoChange;
  end;
end;

procedure TCieczPlyw.SetPomocn(const Value: Boolean);
begin
  FPomocn := Value;
end;

initialization
  RodzajeCieczy := TStringList.Create;

  RegisterClasses( [ TCieczPlyw, TCieczH2O, TStdDBCiecz, TCieczConst] );
  RejestrujCiecz( 'H2O', TCieczH2O );


finalization
  RodzajeCieczy.Free;

end.
