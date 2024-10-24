unit MotorObjU;

interface

uses
  Windows,
  SysUtils,
  Classes,
  graphics,
  Variants,
  jpeg,
  DB,
  DBTables,
  Forms,
  JezykTxt,
  KrMath,
  FunctU,
  Math,
  DGraph,
  DxfDraws,
  PompDXF,
  KR_Sys,
  KR_DB,
  PompMath,
  prod,
  Diagrams,
  DBMotorsU,
  ZadCompU;


type

  TMotorObject = class (TZadComponent)
  private
    FRefCount    :Integer;
    FProd: TProducent;
    FG_ID: string;
    FH_ID: string;
    FTYP_ID: string;
    FA_IDs : array [1..8] of string;
    FM_ID: string;
    FMasa: Double;
    function GetA_IDs(i: Integer): string;
  protected
    FNazwa       :string;
    FNZn: Double;
    FPZn: Double;
    procedure  LoadIds( DS :TDataSet );
  public
    constructor CreateDB(DB :TDBMotors);          virtual;
    constructor CreateQry(Q :TQuery; AProd :TProducent);   virtual;

    procedure LoadFromDB(DB :TDBMotors);          virtual;
    procedure LoadFromQuery(Q :TQuery);           virtual;

    function CreateForm( AOwner :TComponent;
                         const Par :string = '') :TForm;   virtual; abstract;

    function LocateDB( ADB :TDBMotors ) :Boolean;

    procedure AddRef;
    procedure Release;

    function CreateDxf :TDXFDrawing;

    property Producent :TProducent read FProd;
    property Nazwa    :string read FNazwa;
    property PZn      :Double read FPZn;
    property NZn      :Double read FNZn;
    property Masa     :Double read FMasa;
    property G_ID     :string read FG_ID;
    property H_ID     :string read FH_ID;
    property M_ID     :string read FM_ID;
    property TYP_ID     :string read FTYP_ID;
    property A_IDs[i :Integer] :string read GetA_IDs;
  end;

  TMotorElektr = class (TMotorObject)
  private
    FFunN: TRealFunctObject;
    FFunCosFi: TRealFunctObject;
    FFunI: TRealFunctObject;
    FMBezwl: Double;
    FFreqZn: Double;
    procedure SetFunCosFi(const Value: TRealFunctObject);
    procedure SetFunI(const Value: TRealFunctObject);
    procedure SetFunN(const Value: TRealFunctObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  protected
    FIZn: Double;
    FCosFiZn: Double;
    FUZn: Double;
    FIP: string;
    FKlasa : string;

    function GetEtaZn  :Double;                      virtual;
    procedure LoadFun( DS :TDataSet );


  public

    procedure LoadFromDB(DB :TDBMotors);             override;
    procedure LoadFromQuery(Q :TQuery);              override;

    function CreateForm( AOwner :TComponent;
                         const Par :string = '') :TForm;   override;

    class function OblEta( AP, AU, AI, ACosF :Double ) :Double; virtual;

    property CosFiZn :Double read FCosFiZn;
    property EtaZn   :Double read GetEtaZn;
    property UZn     :Double read FUZn;
    property IZn     :Double read FIZn;
    property FreqZn  :Double read FFreqZn;
    property IP      :string read FIP;
    property Klasa   :string read FKlasa;
    property MBezwl  :Double read FMBezwl;

    function I_OdP( AP_kW :Double) :Double;
    function CosFi_OdP( AP_kW :Double) :Double;
    function N_OdP( AP_kW :Double) :Double;
    function Eta_OdP( AP_kW :Double) :Double;

  published
    property FunI        :TRealFunctObject read FFunI write SetFunI;
    property FunCosFi    :TRealFunctObject read FFunCosFi write SetFunCosFi;
    property FunN        :TRealFunctObject read FFunN write SetFunN;
  end;

  TMotorElektr3F = class (TMotorElektr)
  protected
  public
    class function OblEta( AP, AU, AI, ACosF :Double ) :Double; override;
  end;

  TMotorElektr1F = class (TMotorElektr)
  protected
  public
    class function OblEta( AP, AU, AI, ACosF :Double ) :Double; override;
  end;

function CreateMotor( Q :TQuery; AProd :TProducent ):TMotorObject;

function MotNToSynchro( AN :Double; AHz :Integer = 50 ) :Integer;
function MotNToLiczPBieg( AN :Double; AHz :Integer = 50 ) :Integer;
function MotLiczPBiegToNSynchro( LPB :Integer; AHz :Integer = 50 ) :Integer;

implementation

uses
  MotorFormU;

function CreateMotor( Q :TQuery; AProd :TProducent ):TMotorObject;
begin
  Result := NIL;
  if Q.FieldByName('OBJ_ID').AsString = 'E1F' then
    Result := TMotorElektr1F.CreateQry(Q, AProd)
  else if Q.FieldByName('OBJ_ID').AsString = 'E3F' then
    Result := TMotorElektr3F.CreateQry(Q, AProd)
  else if Q.FieldByName('OBJ_ID').AsString = '' then
  begin
    if Q.FieldByName('NAP').AsFloat < 280 then
      Result := TMotorElektr1F.CreateQry(Q, AProd)
    else
      Result := TMotorElektr3F.CreateQry(Q, AProd);
  end;
end;

function MotNToSynchro( AN :Double; AHz :Integer ) :Integer;
begin
  if AHz = 50 then
  begin
    if AN > 3000 then
      Result := 0
    else if AN > 1500 then
      Result := 3000
    else if AN > 1000 then
      Result := 1500
    else if AN > 750 then
      Result := 1000
    else if AN > 600 then
      Result := 750
    else if AN > 500 then
      Result := 600
    else if AN > 300 then
      Result := 500
    else
      Result := 0;
  end;
end;

function MotNToLiczPBieg( AN :Double; AHz :Integer = 50 ) :Integer;
begin
  if AHz = 50 then
  begin
    if AN > 3000 then
      Result := 0
    else if AN > 1500 then
      Result := 2
    else if AN > 1000 then
      Result := 4
    else if AN > 750 then
      Result := 6
    else if AN > 600 then
      Result := 8
    else if AN > 500 then
      Result := 10
    else if AN > 300 then
      Result := 12
    else
      Result := 0;
  end;
end;

function MotLiczPBiegToNSynchro( LPB :Integer; AHz :Integer = 50 ) :Integer;
begin
  if AHz = 50 then
  begin
    case LPB of
      2:  Result := 3000;
      4:  Result := 1500;
      6:  Result := 1000;
      8:  Result :=  750;
      10: Result :=  600;
      12: Result :=  500;
    end;
  end;
end;

{ TMotorObject }

procedure TMotorObject.AddRef;
begin
  inc(FRefCount);
end;

constructor TMotorObject.CreateDB(DB: TDBMotors);
begin
  inherited Create(NIL);
  LoadFromDB(DB);
  FProd := DB.Producent;
end;

function TMotorObject.CreateDxf: TDXFDrawing;
var
  DB      :TDBMotors;
  FN       :string;
  sx, gmet :string;
begin
  Result := TPompDXFDrawing.Create;
  DB := TDBMotors.CreateForProd(self, Producent);
  try
    DB.A.Locate( 'NAZWA;G_ID', VarArrayOf([Nazwa,G_ID]), [] );
    gmet := DB.G.FieldByName('G_Met').AsString;
    if Pos('.',gmet) = 0 then
      sx := gmet + '.dxf'
    else
      sx := gmet;
    FN := Producent.SciezkaDoBaz + '\schematy\' + sx;
    if not FileExists(FN) then
      FN := Producent.SciezkaDoBaz + '\schematy\' + gmet;

    if FileExists(FN) then
      TPompDXFDrawing(Result).LoadWithBase( FN, DB.G );
  finally
    DB.Free;
  end;
end;

constructor TMotorObject.CreateQry(Q: TQuery; AProd :TProducent);
begin
  inherited Create(NIL);
  FProd := AProd;
  LoadFromQuery(Q);
end;

function TMotorObject.GetA_IDs(i: Integer): string;
begin
  Result := FA_IDs[i];
end;

procedure TMotorObject.LoadFromDB(DB: TDBMotors);
begin
  FNazwa := DB.Field['A.NAZWA'].AsString;
  FPZn   := DB.Field['M.M_PZN'].AsFloat;
  FNZn   := DB.Field['M.M_NZN'].AsFloat;
  FMasa  := DB.Field['M.MASA'].AsFloat;
  FG_ID  := DB.Field['G_ID'].AsString;
  FH_ID  := DB.Field['H_ID'].AsString;
  FM_ID  := DB.Field['M_ID'].AsString;
  FTYP_ID := DB.Field['TYP_ID'].AsString;
  LoadIds( DB.A );
end;

procedure TMotorObject.LoadFromQuery(Q: TQuery);
begin
  FNazwa := Q.FieldByName('Nazwa').AsString;
  FPZn   := Q.FieldByName('M_PZN').AsFloat;
  FNZn   := Q.FieldByName('M_NZN').AsFloat;
  FG_ID  := Q.FieldByName('G_ID').AsString;
  FH_ID  := Q.FieldByName('H_ID').AsString;
  FM_ID  := Q.FieldByName('M_ID').AsString;
  FMasa  := Q.FieldByName('MASA').AsFloat;
  FTYP_ID := Q.FieldByName('TYP_ID').AsString;
  LoadIds( Q );
end;

procedure TMotorObject.LoadIds( DS :TDataSet );
var
  i       :Integer;
begin
  for i := Low(FA_Ids) to High(FA_IDs) do
  begin
    FA_Ids[i] := DS.FieldByName(Format('ID%d', [i])).AsString;
  end;
end;

function TMotorObject.LocateDB(ADB: TDBMotors): Boolean;
begin
  Result := ADB.A.Locate( 'NAZWA;H_ID;M_ID;G_ID;TYP_ID;ID1;ID2;ID3;ID4;ID5;ID6;ID7;ID8',
                          VarArrayOf([NAZWA, H_ID, M_ID, G_ID, TYP_ID,
                                      A_IDs[1],A_IDs[2],A_IDs[3],A_IDs[4],
                                      A_IDs[5],A_IDs[6],A_IDs[7],A_IDs[8]]),
                          [] );
end;

procedure TMotorObject.Release;
begin
  if self = NIL then
    EXIT;
  dec(FRefCount);
  if FRefCount <= 0 then
    Destroy;
end;

{ TMotorElektr }

function TMotorElektr.CosFi_OdP(AP_kW :Double): Double;
begin
  if FFunCosFi <> NIL then
    Result := FFunCosFi.Value(AP_kW)
  else
    Result := 0;
end;

function TMotorElektr.CreateForm( AOwner :TComponent;
                                  const Par: string): TForm;
begin
  Result := TMotorForm.Create(AOwner);
  TMotorForm(Result).Motor := self;
  if Pos('/MDI', Par) > 0 then
    Result.FormStyle := fsMDIChild;
end;

function TMotorElektr.Eta_OdP(AP_kW: Double): Double;
begin
  if (FFunI <> NIL) and (FFunCosFi <> NIL) then
    Result := OblEta( AP_kW*1000, UZn, I_OdP(AP_kW), CosFi_OdP(AP_kW) )
  else
    Result := 0;
end;

function TMotorElektr.GetEtaZn: Double;
begin
  //                 kW->W
  Result := OblEta( PZn*1000, UZn, IZn, CosFiZn );
end;

function TMotorElektr.I_OdP(AP_kW:Double): Double;
begin
  if FFunI <> NIL then
    Result := FFunI.Value(AP_kW)
  else
    Result := 0;
end;

procedure TMotorElektr.LoadFromDB(DB: TDBMotors);
begin
  inherited;
  FIZn     := DB.Field['M.PRAD'].AsFloat;
  FCosFiZn := DB.Field['M.COSF'].AsFloat;
  FUZn     := DB.Field['M.NAP'].AsFloat;
  FIP      := DB.Field['M.IP'].AsString;
  FKlasa   := DB.Field['M.Klasa'].AsString;
  FMBezwl  := DB.Field['M.J'].AsFloat;
  FFreqZn  := DB.Field['M.FREK'].AsFloat;
  LoadFun( DB.H );
end;

procedure TMotorElektr.LoadFromQuery(Q: TQuery);
var
  DB      :TDBMotors;
begin
  inherited;
  FIZn     := Q.FieldByName('PRAD').AsFloat;
  FCosFiZn := Q.FieldByName('COSF').AsFloat;
  FUZn     := Q.FieldByName('NAP').AsFloat;
  FIP      := Q.FieldByName('IP').AsString;
  FKlasa   := Q.FieldByName('Klasa').AsString;
  FMBezwl  := Q.FieldByName('J').AsFloat;
  FFreqZn  := Q.FieldByName('FREK').AsFloat;

  DB := TDBMotors.CreateForProd(self, Producent);
  try
    DB.A.Locate( 'NAZWA;H_ID', VarArrayOf([Nazwa,H_ID]), [] );
    LoadFun( DB.H );
  finally
    DB.Free;
  end;

end;

procedure TMotorElektr.LoadFun(DS: TDataSet);
var
  szI, szC, szN  :TSplineFunctObj;
begin
  if (DS = NIL) or (DS.FieldByName('H_MET').AsString = '') then
  begin
    FunI     := NIL;
    FunCosFi := NIL;
    FunN     := NIL;
  end
  else if (DS.FieldByName('H_MET').AsString = 'SZ') then
  begin
    szI := TSplineFunctObj.Create(self);
    szC := TSplineFunctObj.Create(self);
    szN := TSplineFunctObj.Create(self);
    ReadSZFunctsFromHTab( DS, [szI, szC, szN] );
    FunI     := szI;
    FunCosFi := szC;
    FunN     := szN;
  end;
end;

procedure TMotorElektr.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FFunN then
      FFunN := NIL
    else if AComponent = FFunCosFi then
      FFunCosFi := NIL
    else if AComponent = FFunI then
      FFunI := NIL;
  end;
  inherited;
end;

function TMotorElektr.N_OdP(AP_kW:Double): Double;
begin
  if FFunN <> NIL then
    Result := FFunN.Value(AP_kW)
  else
    Result := 0;
end;


class function TMotorElektr.OblEta(AP, AU, AI, ACosF: Double): Double;
begin
  Result := 1;
end;

procedure TMotorElektr.SetFunCosFi(const Value: TRealFunctObject);
begin
  if Value <> FFunCosFi then
  begin
    FFunCosFi.Free;
    FFunCosFi := Value;
    if FFunCosFi <> NIL then
      FFunCosFi.Name := 'FunCosFi';
  end;
end;

procedure TMotorElektr.SetFunI(const Value: TRealFunctObject);
begin
  if Value <> FFunI then
  begin
    FFunI.Free;
    FFunI := Value;
    if FFunI <> NIL then
      FFunI.Name := 'FunI';
  end;
end;

procedure TMotorElektr.SetFunN(const Value: TRealFunctObject);
begin
  if Value <> FFunN then
  begin
    FFunN.Free;
    FFunN := Value;
    if FFunN <> NIL then
      FFunN.Name := 'FunN';
  end;
end;

{ TMotorElektr3F }

class function TMotorElektr3F.OblEta(AP, AU, AI, ACosF: Double): Double;
begin
  try
    Result := f_div( AP, sqrt(3) *AU*AI*ACosF );
  except
    on EMathError do
      Result := 0;
  end;
end;

{ TMotorElektr1F }

class function TMotorElektr1F.OblEta(AP, AU, AI, ACosF: Double): Double;
begin
  try
    Result := f_div( AP, AU*AI*ACosF );
  except
    on EMathError do
      Result := 0;
  end;
end;

end.
