unit ObszCharMgrU;

interface

uses
  Classes, SysUtils, Graphics,
  DGraph, Diagrams,
  OPompa, LinCharU,
  WCharU, ObszarWCharU;

type

  TObszarCharList = class;

  TObszarFunObj = class
  public
    DiagFun  :TDiagFunction;
    CharList :TWCharList;
    ParentObszList :TObszarCharList;

    constructor Create(OBL :TObszarCharList);
    destructor  Destroy;                override;
    procedure Prepare;

    procedure AddChar( Pmp :TPompa );
  end;

  TObszarCharList = class (TComponent)
  private
    FDiag        :TDiagram;
    FScaleFun    :TDiagFunction;
    FObszList    :TList;
    function GetObszar(i: Integer): TObszarFunObj;
    function GetObszarCount: Integer;
    procedure CreateObszar(pos :Integer);
    {ws 15 lutego 2006}
    function GetMaxX: double;
    {ws 15 lutego 2006}
  public
    constructor   CreateDg( ADiag :TDiagram; AScaleFun :TDiagFunction );
    destructor    Destroy;                          override;

    procedure AddChar( Pmp :TPompa );
    procedure Clear;
    procedure Prepare;

    {ws 15 lutego 2006}
    property MaxX : double read GetMaxX;
    {ws 15 lutego 2006}
    property Obszar[i :Integer] :TObszarFunObj read GetObszar;
    property ObszarCount :Integer read GetObszarCount;

  end;


  TObszarInfo = class
  private
    FId: string;
    FProdName: string;
    FColor: TColor;
  public
    constructor Create( const AProdName :string;
                        const AId :string;
                        AColor :TColor );

    function PompaPasuje( Pmp :TPompa ) :Boolean;

    property ProdName :string read FProdName;
    property Id :string read FId;
    property Color :TColor read FColor;
  end;

  TObszInfoList = class
  private
    function GetInfo(i: Integer): TObszarInfo;
  private
    FList    :TList;
    function GetCount: Integer;
    function GetColor(i: Integer): TColor;

    property Info[i :Integer] :TObszarInfo read GetInfo;
  public
    constructor Create;
    destructor  Destroy;                      override;
    procedure Add(const ProdName :string;
                          const AId :string;
                          AColor :TColor);
    function  GetObszarIndex( Pmp :TPompa ) :Integer;
    procedure Clear;
    property Count :Integer read GetCount;
    property Color[i :Integer] :TColor read GetColor;
  end;

procedure RegisterObszar( const ProdName :string;
                          const AId :string;
                          AColor :TColor );

var
  ObszarList :TObszInfoList;

implementation


procedure RegisterObszar( const ProdName :string;
                          const AId :string;
                          AColor :TColor );
begin
  if ObszarList = NIL then
    ObszarList := TObszInfoList.Create;
  ObszarList.Add( ProdName, AId, AColor );
end;


{ TObszInfoList }

procedure TObszInfoList.Add( const ProdName: string;
                             const AId :string; AColor: TColor);
begin
  FList.Add(TObszarInfo.Create(ProdName, AId, AColor));
end;

procedure TObszInfoList.Clear;
var        
  i       :Integer;
begin
  for i := 0 to FList.Count-1 do
  begin
    TObject(FList[i]).Free;
    FList[i] := NIL;
  end;
  FList.Clear;
end;

constructor TObszInfoList.Create;
begin
  inherited;
  FList := TList.Create;
end;

destructor TObszInfoList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TObszInfoList.GetColor(i: Integer): TColor;
begin
  Result := Info[i].Color;
end;

function TObszInfoList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TObszInfoList.GetInfo(i: Integer): TObszarInfo;
begin
  Result := TObszarInfo(FList[i]);
end;

function TObszInfoList.GetObszarIndex(Pmp: TPompa): Integer;
var
  i      :Integer;
begin
  Result := -1;
  i := 0;
  while (i < Count) and (Result < 0) do
  begin
    if Info[i].PompaPasuje(Pmp) then
      Result := i;
    inc(i);
  end;
end;

{ TObszarInfo }

constructor TObszarInfo.Create(const AProdName: string;
            const AId :string; AColor: TColor);
var
  i        :Integer;
begin
  inherited Create;
  FProdName := AProdName;
  FColor    := AColor;
  FId       := AId;
end;

function TObszarInfo.PompaPasuje(Pmp: TPompa): Boolean;
begin
  Result := (Pmp.Producent.Ident = ProdName)
            and (Pmp.DB.A.FieldByName(Pmp.ObszFieldName).AsString = Id);
end;

{ TObszarCharList }

procedure TObszarCharList.AddChar(Pmp: TPompa);
var
  pos     :Integer;
begin
  pos := ObszarList.GetObszarIndex(Pmp);
  if pos >= 0 then
  begin
    if Obszar[pos] = NIL then
      CreateObszar(pos);
    Obszar[pos].AddChar(Pmp);
    if Pmp.GetCharData <> NIL then
    begin
      if Pmp.GetCharData.GetCharQMax > FDiag.MaxXR then
        FDiag.CountMaxXR(Pmp.GetCharData.GetCharQMax);
      if Pmp.GetCharData.GetCharHMax > FScaleFun.MaxYR then
        FScaleFun.CountMaxYR(Pmp.GetCharData.GetCharHMax)
    end;
  end;
end;

procedure TObszarCharList.Clear;
var
  i       :Integer;
begin
  FDiag.MaxXR := 0.1;
  FScaleFun.MaxYR := 0.1;
  for i := 0 to ObszarCount-1 do
  begin
    Obszar[i].Free;
    FObszList[i] := NIL;
  end;
end;

constructor TObszarCharList.CreateDg(ADiag: TDiagram; AScaleFun :TDiagFunction);
begin
  inherited Create(ADiag);
  FDiag := ADiag;
  FScaleFun := AScaleFun;
  FObszList := TList.Create;
  FObszList.Count := ObszarList.Count;
end;

procedure TObszarCharList.CreateObszar(pos: Integer);
begin
  FObszList[pos] := TObszarFunObj.Create(Self);
  Obszar[pos].DiagFun.Color := ObszarList.Color[pos];
end;

destructor TObszarCharList.Destroy;
begin
  Clear;
  FObszList.Free;
  inherited;
end;

{ws 15 luty 2006}
function TObszarCharList.GetMaxX: double;
var i : integer;
begin
  result := FDiag.MaxXR;
end;
{ws 15 luty 2006}

function TObszarCharList.GetObszar(i: Integer): TObszarFunObj;
begin
  Result := TObszarFunObj(FObszList[i]);
end;

function TObszarCharList.GetObszarCount: Integer;
begin
  Result := FObszList.Count;
end;

procedure TObszarCharList.Prepare;
var
  i       :Integer;
begin
  for i := 0 to ObszarCount-1 do
  begin
    Obszar[i].Prepare;
  end;
end;

{ TObszarFunObj }

procedure TObszarFunObj.AddChar(Pmp: TPompa);
var
  cd      :TPompCharData;
begin
  cd := Pmp.GetCharData;
  if (cd = NIL) or not (cd is TFuncCharData) then
    EXIT;
  CharList.AddInfo( cd, ParentObszList.FDiag );
  with CharList do
  begin
    Info[Count-1].HFun.IsOn := False;
    Info[Count-1].HFun.FunScale := ParentObszList.FScaleFun;
  end;
end;

constructor TObszarFunObj.Create(OBL :TObszarCharList);
begin
  inherited Create;
  CharList := TWCharList.Create;
  ParentObszList := OBL;
  DiagFun := TDiagFunction.Create(ParentObszList.FDiag);
  DiagFun.Diagram := ParentObszList.FDiag;
  DiagFun.Drawer := TObszWCharDiagFun.Create(DiagFun);
  DiagFun.FunScale := ParentObszList.FScaleFun;
end;

destructor TObszarFunObj.Destroy;
begin
  CharList.Free;
  DiagFun.Free;
  inherited;
end;

procedure TObszarFunObj.Prepare;
begin
  if Self = NIL then
    EXIT;
  TObszWCharDiagFun(DiagFun.Drawer).CharList := CharList;
end;

initialization
  if ObszarList = NIL then
    ObszarList := TObszInfoList.Create;

end.
