unit DBMotorsU;

interface

uses
  SysUtils, Classes, Dialogs,
  DB, DBTables,
  KR_DB, KR_Sys, Jednost, MemDataSetU,
  Prod, MotBaseInfoU, ZadCompU ;

type

  TDBMotors = class (TZadComponent)
  private
    fA     : TDataSet;
    fH     : TDataSet;
    fG     : TDataSet;
    fM     : TDataSet;
    fO     : TDataSet;
    fT     : TDataSet;
    fB     : TDataSet;
    fDB2   : TDBMotors;
    fADSrc : TDataSource;
    fGDSrc : TDataSource;
    fADel  : boolean;


    //=======================
    // WARIANTY

    // Warianty w H inaczej traktowane (do pomp regulowanych)
    FWarH  : TDataSet;
    FWarHSrc : TdataSource;

    FWarG  : TDataSet;
    FWarM  : TDataSet;
    FWarT  : TDataSet;
    FWarGSrc  : TDataSource;
    FWarMSrc  : TDataSource;
    FWarTSrc  : TDataSource;


    FNotFirstUpdtRec :Boolean;
    FSaWarianty: Boolean;
    FWarFName :string;

    FRecWarH: Boolean;
    FRecWarG: Boolean;
    FRecWarT: Boolean;
    FRecWarM: Boolean;

    //FCzySaWarianty: Boolean;
    // END: WARIANTY
    //======================

    FSvABookmark  :TBookmarkStr;
    FSleeping     :Boolean;

    procedure InsFld(const FldName, DispName :string);
    function  GetDB2 :TDBMotors;
    function GetProdID: string;
    function GetField(const AName: string): TField;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure UpdateIt( t: TDataSet );                   virtual;
    function  getA: TDataSet;
    function  getH: TDataSet;
    function  getG: TDataSet;
    function  getM: TDataSet;
    function  getO: TDataSet;
    function  getT: TDataSet;
    function  getB: TDataSet;

    procedure CreateA( const BN, TN :string );           virtual;
    procedure CreateM( const BN, TN :string );           virtual;
    procedure CreateT( const BN, TN :string );           virtual;
    procedure CreateB( const BN, TN :string );           virtual;
    {procedure CreateRelBases;                            virtual;}
    procedure GetTabNames( const TabId :string;
                           var BasName, TabName : string);  virtual;
    procedure WarPreInit( bi :TMotBaseInfo);
    procedure UpdtRec;
    procedure InitWarDSet( var ds :TDataSet; var dsrc :TDataSource );

    procedure InitBases;                                 virtual;

  public
    hOK, gOK, mOK, oOK, tOK, bOK : boolean;
    Producent  : TProducent;
    BaseInfo   : TMotBaseInfo;

    constructor CreateFromDataSet( AOwner: TComponent;
                                   Pr: TProducent;
                                   Query: TDataSet );
    constructor CreateForProd( AOwner: TComponent; Pr: TProducent );
    constructor CreateCopy( AOwner: TComponent; Src: TDBMotors );

    destructor  Destroy; override;

    function  MakeCopy( O :TComponent ): TDBMotors;

    function  CreateH( const BN, TN :string; plus :Boolean = false ):TDataSet;   virtual;
    function  CreateG( const BN, TN :string; plus :Boolean = false ):TDataSet;   virtual;
    function  OpenTable( const id :string ) :TDataSet;
    procedure Update; virtual;

    procedure Next;
    procedure Prior;
    procedure First;
    procedure Last;
    function  BOF :Boolean;
    function  EOF :Boolean;

    procedure NextVar;
    procedure PriorVar;
    procedure FirstVar;
    procedure LastVar;
    function  BOV :Boolean;
    function  EOV :Boolean;

    procedure NextH;
    procedure PriorH;
    procedure FirstH;
    procedure LastH;
    function  BOH :Boolean;
    function  EOH :Boolean;

    procedure Sleep;                           virtual;
    procedure WakeUp;                          virtual;


    property SaWarianty :Boolean   read FSaWarianty;
    property RecWarG    :Boolean   read FRecWarG;
    property RecWarM    :Boolean   read FRecWarM;
    property RecWarT    :Boolean   read FRecWarT;

    property ProdId: string read GetProdID;
    procedure ACalcFields(DataSet: TDataset);
    property A: TDataSet   read getA;
    property H: TDataSet   read getH;
    property G: TDataSet   read getG;
    property M: TDataSet   read getM;
    property O: TDataSet   read getO;
    property T: TDataSet   read getT;
    property B: TDataSet   read getB;
    property WarM: TDataSet read FWarM;
    property DB2 :TDBMotors read getDB2;
    property ADel: boolean read fADel write fADel;
    property Field[const AName :string] :TField read GetField;
  end;

  TDBMotorsCopy = class (TDBMotors)
  private
    procedure SetProdId(const Value: string);
    function GetProdId: string;
    function GetMA: TMemDataSet;
    function GetMH: TMemDataSet;
    procedure SetMA(const Value: TMemDataSet);
    procedure SetMH(const Value: TMemDataSet);
  protected
    procedure CopyA( src :TDBMotors );
    procedure CopyH( src :TDBMotors );
    procedure Loaded;                               override;

    procedure InitBases;                            override;
  public
    constructor Create( O :TComponent ); override;
    constructor CreateFrom( AOwner :TComponent; src :TDBMotors );
  published
    property MA :TMemDataSet read GetMA write SetMA;
    property MH :TMemDataSet read GetMH write SetMH;
    property ProdId :string read GetProdId write SetProdId;
  end;


implementation

{ TDBMotors }

constructor TDBMotors.CreateFromDataSet( AOwner  : TComponent;
                                        Pr      : TProducent;
                                        Query   : TDataSet );
var
  bi        :TMotBaseInfo;
  s         :string;
  BN, TN    :string;              // BaseName, TableName
begin
  inherited Create(AOwner);

  fA := Query;
  //ProdId := pr.Ident;
  Producent := Pr;
  bi        := TMotBaseInfo(Pr.InfoBaz['MOTORS']);
  BaseInfo  := bi;

  WarPreInit( bi );

  GetTabNames( 'H', BN, TN );
  CreateH(BN,TN);

  GetTabNames( 'G', BN, TN );
  CreateG(BN,TN);

  GetTabNames( 'M', BN, TN );
  CreateM(BN,TN);

  GetTabNames( 'T', BN, TN );
  CreateT(BN,TN);

  GetTabNames( 'B', BN, TN );
  CreateB(BN,TN);

  fO := TTable.Create(self);
  UpdtRec;
  ADel := false;
  {
  with fO as TTable do
  begin
    DatabaseName := Query.DatabaseName;
    TableName := 'O_' + pr + '.DBF';
    IndexFieldNames := 'O_ID';
    Open;
  end;
  }
end;


constructor TDBMotors.CreateForProd( AOwner: TComponent; Pr: TProducent );
var
  bi        :TMotBaseInfo;

  i         :Integer;
  f         :TField;
  s         :string;
  BN, TN    :string;              // BaseName, TableName

begin
  Create(AOwner);

  //ProdId    := pr.Ident;
  Producent := Pr;

  InitBases

end;

constructor TDBMotors.CreateCopy( AOwner: TComponent; Src: TDBMotors );
var
  bi        :TMotBaseInfo;

  i         :Integer;
  RN        :Longint;
  f         :TField;
  pr        :TProducent;
  AClass    :TComponentClass;

begin
  try

    inherited Create(AOwner);

    pr        := src.Producent;
    //ProdId    := pr.Ident;
    Producent := Pr;
    bi        := TMotBaseInfo(Pr.InfoBaz['MOTORS']);
    BaseInfo  := bi;
    WarPreInit(bi);
    AClass    := TComponentClass(src.A.ClassType);
    fA := (AClass.Create(self)) as TDataSet;
    if fa is TTable then with fA as TTable do
    begin
      DataBaseName := TTable(src.A).DataBaseName;
      TableName    := TTable(src.A).TableName;
      FieldDefs.Update;
      for i := 0 to FieldDefs.Count-1 do
      begin
        f := FieldDefs.Items[i].CreateField( fA );
      end;
      InsFld( 'MASA', 'Masa' );
      InsFld( 'QnJedn', 'Qn' );
      InsFld( 'HnJedn', 'Hn' );
      Open;
      GotoCurrent(TTable(src.A));
    end
    else if fa is TQuery then with fa as TQuery do
    begin
      DataBaseName := TQuery(src.A).DataBaseName;
      SQL.Add('SELECT * FROM ');
      SQL.Add('"A_' + ProdId + '.DBF" ');
      FieldDefs.Update;
      for i := 0 to FieldDefs.Count-1 do
      begin
        f := FieldDefs.Items[i].CreateField( fA );
      end;
      InsFld( 'MASA', 'Masa' );
      InsFld( 'QnJedn', 'Qn' );
      InsFld( 'HnJedn', 'Hn' );
      SQL.Assign( TQuery(src.A).SQL );
      Open;
      RN := GetRecNo( src.A as TBDEDataSet );
      SetRecNo( fA as TBDEDataSet , RN );
    end;

    fADSrc := TDataSource.Create( self );
    fADSrc.DataSet := fA;

    if src.hOK then
      CreateH(TTable(src.H).DataBaseName, TTable(src.H).TableName);
    if src.GOK then
      CreateG(TTable(src.G).DataBaseName, TTable(src.G).TableName);
    if src.MOK then
      CreateM(TTable(src.M).DataBaseName, TTable(src.M).TableName);
    if src.TOK then
      CreateT(TTable(src.T).DataBaseName, TTable(src.T).TableName);
    if src.BOK then
      CreateB(TTable(src.B).DataBaseName, TTable(src.B).TableName);


    A.OnCalcFields := ACalcFields;
    UpdtRec;
  except
    on EAccessViolation do
      ShowMessage('To tu' );
  end;

end;



destructor TDBMotors.Destroy;
begin
  {
  Nie potrzeba poniewaz sie kasuja przez 'ownera'

  fH.Free;
  fG.Free;
  fM.Free;
  fO.Free;
  if ADel then
  begin
    fA.Free;
  end;
  }

  inherited Destroy;
end;

procedure TDBMotors.InitBases;
var
  bi        :TMotBaseInfo;

  //i         :Integer;
  //f         :TField;
  //s         :string;
  BN, TN    :string;              // BaseName, TableName

begin
  bi        := TMotBaseInfo(Producent.InfoBaz['MOTORS']);
  BaseInfo  := bi;

  WarPreInit( bi );

  GetTabNames( 'A', BN, TN );
  CreateA(BN,TN);

  GetTabNames( 'H', BN, TN );
  CreateH(BN,TN);

  GetTabNames( 'G', BN, TN );
  CreateG(BN,TN);

  GetTabNames( 'M', BN, TN );
  CreateM(BN,TN);

  GetTabNames( 'T', BN, TN );
  CreateT(BN,TN);

  GetTabNames( 'B', BN, TN );
  CreateB(BN,TN);

  //GetTabNames( 'J', BN, TN );
  //CreateJ(BN,TN);

  fO := TTable.Create(self);
  ADel := false;

  A.OnCalcFields := ACalcFields;
  UpdtRec;

end;


procedure TDBMotors.CreateA( const BN, TN :string );
var
  i       :Integer;
  f       :TField;
begin
  fA := TTable.Create(self);
  with fA as TTable do
  begin
    DatabaseName := BN;
    TableName    := TN;
    FieldDefs.Update;
    for i := 0 to FieldDefs.Count-1 do
    begin
      f := FieldDefs.Items[i].CreateField( fA );
    end;
    InsFld( 'MASA', 'Masa' );
    InsFld( 'QnJedn', 'Qn' );
    InsFld( 'HnJedn', 'Hn' );
    Open;
  end;
  fADSrc := TDataSource.Create( self );
  fADSrc.DataSet := fA;
end;


function TDBMotors.CreateH( const BN, TN :string; plus :Boolean = false ) :TDataSet;
var
  AH      :TTable;
begin
  AH := TTable.Create(self);
  with AH as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'H_ID';
      if not plus then
      begin
        if not SaWarianty then
        begin
          MasterSource := fADSrc;
          MasterFields  := 'H_ID';
        end
        else
        begin
          InitWarDSet( FWarH, FWarHSrc );
        end;
        hOK := true;
      end;
      Open;
    except
      on EDatabaseError do
      begin
        AH.Free;
        AH := NIL;
        hOK := false;
      end;
    end;
  end;
  if not plus then
    fH := AH;
  result := AH;
end;


function TDBMotors.CreateG( const BN, TN :string; plus :Boolean = false ) :TDataSet;
var
  AG      :TTable;
begin
  AG := TTable.Create(self);
  with AG as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'G_ID';
      if not plus then
      begin
        if not SaWarianty then
        begin
          MasterSource := fADSrc;
          MasterFields  := 'G_ID';
        end
        else
        begin
          InitWarDSet( FWarG, FWarGSrc );
        end;
        gOK := true;
      end;
      Open;
    except
      on EDatabaseError do
      begin
        AG.Free;
        AG := NIL;
        gOK := false;
      end;
    end;
  end;
  if not plus then
  begin
    fG := AG;
  end;
  result := AG;
end;


procedure TDBMotors.CreateM( const BN, TN :string );
begin
  fM := TTable.Create(self);
  with fM as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'M_ID';
      if not SaWarianty then
      begin
        MasterSource    := fADSrc;
        MasterFields    := 'M_ID';
      end
      else
      begin
        InitWarDSet( FWarM, FWarMSrc );
      end;
      Open;
      mOK := true;
    except
      on EDatabaseError do
      begin
        fM.Free;
        fM := NIL;
        mOK := false;
      end;
    end;
  end;
end;

procedure TDBMotors.CreateT( const BN, TN :string );
begin
  fT := TTable.Create(self);
  with fT as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'TYP_ID';
      if not SaWarianty then
      begin
        MasterSource    := fADSrc;
        MasterFields    := 'TYP_ID';
      end
      else
      begin
        InitWarDSet( FWarT, FWarTSrc );
      end;
      Open;
      tOK := true;
    except
      on EDatabaseError do
      begin
        fT.Free;
        fT := NIL;
        tOK := false;
      end;
    end;
  end;
end;

procedure TDBMotors.CreateB( const BN, TN :string );
begin
  fB := TTable.Create(self);
  with fB as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'ID';
      Open;
      bOK := true;
    except
      on EDatabaseError do
      begin
        fB.Free;
        fB := NIL;
        bOK := false;
      end;
    end;
  end;
end;




{-------------------------------------------------------------------------}
//procedure TDBMotors.CreateRelBases;


procedure TDBMotors.GetTabNames( const TabId :string;
                             var BasName, TabName : string);
var
  s       :string;
begin
  s          := BaseInfo.GetBaseName(TabId);
  BasName    := StrLeft( ExtractFilePath(s), -2);
  TabName    := ExtractFileName(s);
end;


procedure TDBMotors.InsFld(const FldName, DispName :string);
var
  Fld     :TFloatField;
begin
  try
    Fld := TFloatField.Create(fA);
    Fld.Calculated   := true;
    Fld.FieldName    := FldName;
    Fld.DisplayLabel := DispName;
    Fld.DataSet      := fA;
    if (FldName = 'QnJedn') or (FldName = 'HnJedn') then
      Fld.EditFormat := '0.000'
    else
      Fld.EditFormat := '0.0';
  except
    on e: Exception do
      ShowMessage( e.Message );
  end;
end;



function  TDBMotors.MakeCopy( O :TComponent ): TDBMotors;
begin
  result := TDBMotorsCopy.CreateFrom( O, self );
end;

function  TDBMotors.GetDB2 :TDBMotors;
begin
  if fDB2 = NIL then
  begin
    fDB2 := TDBMotors.CreateForProd( self, Producent );
  end;
  result := fDB2;
end;


procedure TDBMotors.ACalcFields(DataSet: TDataset);
var
  nazwa   : string;
  m       : Extended;
begin
  {Update;}
  with A do
  begin
    nazwa := FieldByName('nazwa').AsString;
    //FieldByName('QnJedn').AsFloat :=
    //    JednQ.StdToUser(FieldByName('Qn').AsFloat);
    //FieldByName('HnJedn').AsFloat :=
    //    JednH.StdToUser(FieldByName('Hn').AsFloat);
    if GOK then
      m := G.FieldByName('MASA').AsFloat
    else
      m := 0;
    FieldByName('MASA').AsFloat := m;
  end;
end;




{-------------------------------------------------------------------------}
procedure TDBMotors.Update;
begin
//  UpdateIt(fH);
//  UpdateIt(fG);
//  UpdateIt(fM);
//  UpdateIt(fO);
end;




{-------------------------------------------------------------------------}
procedure TDBMotors.UpdateIt( t: TDataSet );
var
  id: string;

procedure DoIt( const pole: string; tab: TDataSet; var ok: boolean );
begin
  id := fA.FieldByName(pole).AsString;
  if    tab.FieldByName(pole).AsString <> id then
  begin
    with tab as TTable do
    begin
      SetKey;
      FieldByName(pole).AsString := id;
      OK := GoToKey;
    end;
  end;
end;

begin

  if fA.Active then
  begin
    if t = fH then
    begin
     // DoIt( 'H_ID', t, hOK );
    end
    {else if t = fG then
    begin
      DoIt( 'G_ID', t, gOK );
    end}
    else if t = fM then
    begin
      //DoIt( 'M_ID', t, mOK );
    end
    else if t = fO then
    begin
    end;
  end;

end;

{
procedure TDBMotors.M_CalcFields(DataSet: TDataset);
begin
end;
}


function TDBMotors.getA: TDataSet;
begin
  WakeUp;
  getA := fA;
end;

function TDBMotors.getH: TDataSet;
begin
  WakeUp;
  getH := fH;
end;

function TDBMotors.getG: TDataSet;
begin
  WakeUp;
  getG := fG;
end;

function TDBMotors.getM: TDataSet;
begin
  WakeUp;
  getM := fM;
end;

function TDBMotors.getO: TDataSet;
begin
  WakeUp;
  getO := fO;
end;

function TDBMotors.getT: TDataSet;
begin
  WakeUp;
  result := fT;
end;

function TDBMotors.getB: TDataSet;
begin
  WakeUp;
  result := fB;
end;

function TDBMotors.GetProdID: string;
begin
  if Producent <> NIL then
    result := Producent.Ident
  else
    result := '';
end;



function TDBMotors.OpenTable(const id: string): TDataSet;
var
  BN, TN :string;
  tab    :TTable;
begin
  GetTabNames( id, BN, TN );
  if id = 'H' then
  begin
    result := CreateH( BN, TN, true );
  end
  else if id = 'G' then
  begin
    result := CreateG( BN, TN, true );
  end
  else
  begin
    tab := TTable.Create(NIL);
    try
      tab.DatabaseName := BN;
      tab.TableName    := TN;
      tab.Open;
    except
      tab.Free;
      tab := NIL;
    end;
    result := tab;
  end;
end;

function TDBMotors.BOF: Boolean;
begin
  result := A.Bof;
end;

function TDBMotors.EOF: Boolean;
begin
  result := A.Eof;
end;

procedure TDBMotors.First;
begin
  A.First;
end;

procedure TDBMotors.Last;
begin
  A.Last;
end;

procedure TDBMotors.Next;
begin
  A.Next;
end;

procedure TDBMotors.Prior;
begin
  A.Prior;
end;

procedure TDBMotors.UpdtRec;

  procedure Ustaw( war :Boolean; ds, wds :TDataSet;
                   wdsrc :TDataSource; const id :string);
  var
    t ,wt   :TTable;
    sr      :TDataSource;
    s       :string;
  begin
    if (ds = NIL) or (not (ds is TTable)) then
      EXIT;
    t := ds as TTable;
    wt := wds as TTable;
    if not war then
    begin

      sr := fADSrc;                 // normalnie odniesienie do A
      s := A.FieldByName(id).AsString;
      if (Length(s) > 1) and (s[1] = '$') then
        case s[2] of
          'M': sr := FWarMSrc;
          'T': sr := FWarTSrc;
          'G': sr := FWarGSrc;
        end;
      t.MasterFields := id;
      t.MasterSource := sr;
      wt.MasterFields := '';
      wt.MasterSource := NIL;
    end
    else
    begin
      t.MasterFields := id;
      t.MasterSource := wdsrc;
      wt.MasterFields := id;
      wt.MasterSource := fADSrc;
    end;
  end;

  function ChkWar( f :string ): Boolean;
  var
    v      :string;
  begin
    v := A.FieldByName(f).AsString;
    result := (Length(v) > 0) and (v[1] = '@');
  end;


var
  VH, VG, VM, VT :Boolean;   // Czy sie zmienilo od poprzedniego rekordu
  RH, RG, RM, RT :Boolean;   // Czy polaczenie przez warianty
begin
  if SaWarianty then
  begin
    RH := ChkWar('H_ID');
    RG := ChkWar('G_ID');
    RM := ChkWar('M_ID');
    RT := ChkWar('TYP_ID');

    FRecWarH := RH;
    Ustaw( RH, FH, FWarH, FWarHSrc, 'H_ID' );

    FRecWarG := RG;
    Ustaw( RG, FG, FWarG, FWarGSrc, 'G_ID' );

    FRecWarM := RM;
    Ustaw( RM, FM, FWarM, FWarMSrc, 'M_ID' );

    FRecWarT := RT;
    Ustaw( RT, FT, FWarT, FWarTSrc, 'TYP_ID' );

  end;
  FNotFirstUpdtRec := true
end;

procedure TDBMotors.InitWarDSet(var ds: TDataSet; var dsrc: TDataSource);
begin
  ds := TTable.Create(self);
  dsrc := TDataSource.Create(self);
  TTable(ds).IndexFieldNames := 'ID';
  TableSetNames( FWarFName, TTable(ds) );
  dsrc.DataSet := ds;
  ds.Open;
end;

procedure TDBMotors.WarPreInit( bi :TMotBaseInfo);
begin
  FSaWarianty := bi.tbsf.ReadBool( 'MAIN', 'Warianty', false );
  if FSaWarianty then
  begin
    FWarFName := bi.GetBaseName('WAR');
    if FWarFName = '' then
    begin
      FSaWarianty := false;
    end;
  end;
end;

function TDBMotors.BOV: Boolean;
begin
  result := true;
  if RecWarM then
    result := result and FWarM.Bof;
  if RecWarT then
    result := result and FWarT.Bof;
  if RecWarG then
    result := result and FWarG.Bof;
end;

function TDBMotors.EOV: Boolean;
begin
  result := true;
  if RecWarM then
    result := result and FWarM.Eof;
  if RecWarT then
    result := result and FWarT.Eof;
  if RecWarG then
    result := result and FWarG.Eof;
end;

procedure TDBMotors.FirstVar;
begin
  if RecWarM then
    FWarM.First;
  if RecWarT then
    FWarT.First;
  if RecWarG then
    FWarG.First;
end;

procedure TDBMotors.LastVar;
begin
  if RecWarM then
    FWarM.Last;
  if RecWarT then
    FWarT.Last;
  if RecWarG then
    FWarG.Last;
end;

procedure TDBMotors.NextVar;
begin
  if RecWarM and (not FWarM.Eof) then
    FWarM.Next
  else if RecWarT and (not FWarT.Eof) then
    FWarT.Next
  else if RecWarG and (not FWarG.Eof) then
    FWarG.Next;
end;

procedure TDBMotors.PriorVar;
begin
  if RecWarG and (not FWarG.Bof) then
    FWarG.Prior
  else if RecWarT and (not FWarT.Bof) then
    FWarT.Prior
  else if RecWarM and (not FWarM.Bof) then
    FWarM.Prior;
end;

function TDBMotors.BOH: Boolean;
begin
  if FRecWarH then
    result := FWarH.Bof
  else
    result := H.Bof;
end;

function TDBMotors.EOH: Boolean;
begin
  if FRecWarH then
    result := FWarH.Eof
  else
    result := H.Eof;
end;

procedure TDBMotors.FirstH;
begin
  if FRecWarH then
    FWarH.First
  else
    H.First;
end;

procedure TDBMotors.LastH;
begin
  if FRecWarH then
    FWarH.Last
  else
    H.Last;
end;

procedure TDBMotors.NextH;
begin
  if FRecWarH then
    FWarH.Next
  else
    H.Next;
end;

procedure TDBMotors.PriorH;
begin
  if FRecWarH then
    FWarH.Prior
  else
    H.Prior;
end;

function TDBMotors.GetField(const AName: string): TField;
var
  ds        :TDataSet;
  dsName    :string;
  FldName   :string;
begin
  result := NIL;
  ds := NIL;
  dsName   := UpperCase(strBefore( '.', AName ));
  FldName  := strBehinde( '.', AName );
  if dsName = 'A' then
    ds := A
  else if dsName = 'B' then
    ds := B
  else if dsName = 'G' then
    ds := G
  else if dsName = 'H' then
    ds := H
  else if dsName = 'M' then
    ds := M
  else if dsName = 'T' then
    ds := T;
  if ds <> NIL then
  begin
    result := ds.FindField(FldName);
  end;
end;

procedure TDBMotors.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = fA then
      fA := NIL
    else if AComponent = fH then
      fH := NIL
    else if AComponent = fG then
      fG := NIL
    else if AComponent = fM then
      fM := NIL
    else if AComponent = fT then
      fT := NIL
    else if AComponent = fB then
      fB := NIL
    else if AComponent = fDB2 then
      fDB2 := NIL
    else if AComponent = fADSrc then
      fADSrc := NIL
    else if AComponent = fGDSrc then
      fGDSrc := NIL
    else if AComponent = FWarG then
      FWarG := NIL
    else if AComponent = FWarM then
      FWarM := NIL
    else if AComponent = FWarT then
      FWarT := NIL
    else if AComponent = FWarGSrc then
      FWarGSrc := NIL
    else if AComponent = FWarMSrc then
      FWarMSrc := NIL
    else if AComponent = FWarTSrc then
      FWarTSrc := NIL
  end;
  inherited;

end;

procedure TDBMotors.Sleep;
begin
  if FSleeping then
    EXIT;
  FSleeping := true;
  FSvABookmark := TBookmarkStr(fA.Bookmark);
  FWarTSrc.Free;
  FWarT.Free;
  FWarMSrc.Free;
  FWarM.Free;
  FWarGSrc.Free;
  FWarG.Free;
  fGDSrc.Free;
  fADSrc.Free;
  fDB2.Free;
  fB.Free;
  fT.Free;
  fM.Free;
  fG.Free;
  fH.Free;
  fA.Free;
end;

procedure TDBMotors.WakeUp;
begin
  if not FSleeping then
    EXIT;
  InitBases;
  FSleeping := false;
  A.Bookmark := TBookmark(FSvABookmark);
  UpdtRec;
end;



{ TDBMotorsCopy }

procedure TDBMotorsCopy.CopyA(src: TDBMotors);
var
  aMA      :TMemDataSet;
begin
  aMA := TMemDataSet.Create(self);
  fA := aMA;
  aMA.Name := 'A';
  aMA.SaveFieldDefs := true;
  aMA.SaveData := true;
  aMA.CreateTableAs(src.A);
  aMA.Open;
  aMA.CopyRecord(src.A, aMA);
  aMA.Edit;
  aMA.FieldByName('H_ID').AsString := '';
  aMA.Post;
  fADSrc.DataSet := fA;
end;

procedure TDBMotorsCopy.CopyH(src: TDBMotors);
var
  aMH      :TMemDataSet;
  svBM     :TBookmarkStr;
  hid      :string;
begin
  aMH := TMemDataSet.Create(self);
  fH := aMH;
  aMH.Name := 'H';
  hid := src.A.FieldByName('H_ID').AsString;
  aMH.CreateTableAs(src.H);
  aMH.SaveFieldDefs := true;
  aMH.SaveData := true;
  aMH.Open;
  // !! Pozniej mozna poprawic
  if src.FRecWarH then
  begin
    svBM:= TBookmarkStr(src.FWarH.Bookmark);
    src.FWarH.First;
    while (not src.FWarH.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin
      aMH.CopyRecord(src.H, aMH);
      src.FWarH.Next;
    end;
    src.FWarH.Bookmark := TBookmark(svBM);
  end
  else
  begin
    svBM:= TBookmarkStr(src.H.Bookmark);
    src.H.First;
    while (not src.H.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin
      aMH.CopyRecord(src.H, aMH);
      src.H.Next;
    end;
    src.H.Bookmark := TBookmark(svBM);
  end;
  hOK := true;
end;

constructor TDBMotorsCopy.Create(O: TComponent);
begin
  inherited Create(O);
  fADSrc := TDataSource.Create( self );
end;

constructor TDBMotorsCopy.CreateFrom(AOwner: TComponent; src: TDBMotors);
begin
  inherited Create(AOwner);
  fADSrc := TDataSource.Create( self );
  CopyA(src);
  CopyH(src);
  ProdId := src.Producent.Ident;
  UpdtRec;
end;

function TDBMotorsCopy.GetMA: TMemDataSet;
begin
  result := fA as TMemDataSet;
end;

function TDBMotorsCopy.GetMH: TMemDataSet;
begin
  result := fH as TMemDataSet;
end;

function TDBMotorsCopy.GetProdId: string;
begin
  result := inherited GetProdId;
end;

procedure TDBMotorsCopy.InitBases;
var
  BN, TN  :string;
begin
  BaseInfo  := TMotBaseInfo(Producent.InfoBaz['MOTORS']);
  WarPreInit( BaseInfo );

  GetTabNames( 'G', BN, TN );
  CreateG(BN,TN);

  GetTabNames( 'M', BN, TN );
  CreateM(BN,TN);

  GetTabNames( 'T', BN, TN );
  CreateT(BN,TN);

  GetTabNames( 'B', BN, TN );
  CreateB(BN,TN);

end;

procedure TDBMotorsCopy.Loaded;
begin
  inherited;
  UpdtRec; 
end;

procedure TDBMotorsCopy.SetMA(const Value: TMemDataSet);
begin
  if fA <> NIL then
    fA.Free;
  fA := Value;
  fADSrc.DataSet := fA;
  fA.Open;
end;

procedure TDBMotorsCopy.SetMH(const Value: TMemDataSet);
begin
  if fH <> NIL then
    fH.Free;
  fH := Value;
  fH.Open;
end;

procedure TDBMotorsCopy.SetProdId(const Value: string);
var
  BN, TN  :string;
begin
  Producent := Producenci.ProdByName(Value);
  BaseInfo  := TMotBaseInfo(Producent.InfoBaz['MOTORS']);
  WarPreInit( BaseInfo );

  GetTabNames( 'G', BN, TN );
  CreateG(BN,TN);

  GetTabNames( 'M', BN, TN );
  CreateM(BN,TN);

  GetTabNames( 'T', BN, TN );
  CreateT(BN,TN);

  GetTabNames( 'B', BN, TN );
  CreateB(BN,TN);
end;


initialization
  Classes.RegisterClass( TDBMotorsCopy );

end.
