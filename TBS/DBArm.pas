unit DBArm;

interface

uses
  SysUtils, Classes, Dialogs,
  DB, DBTables,
  KR_DB, KR_Sys, Jednost, PipInfoU,
  Prod;

type
  TDBArmatura = class (TComponent)
    private
      fA     : TDataSet;
      fH     : TDataSet;
      fG     : TDataSet;
      fO     : TDataSet;
      fT     : TDataSet;
      fB     : TDataSet;
      fADSrc : TDataSource;
      //fGDSrc : TDataSource;

      procedure InsFld(const FldName, DispName :string);
    protected
      //procedure UpdateIt( t: TDataSet );                   virtual;
      function  getA: TDataSet;
      function  getH: TDataSet;
      function  getG: TDataSet;
      function  getO: TDataSet;

      procedure CreateA( const BN, TN :string );           virtual;
      procedure CreateH( const BN, TN :string );           virtual;
      procedure CreateG( const BN, TN :string );           virtual;
      procedure CreateT( const BN, TN :string );           virtual;
      procedure CreateB( const BN, TN :string );           virtual;
      {procedure CreateRelBases;                            virtual;}
      procedure GetTabNames( const TabId :string;
                             var BasName, TabName : string);  virtual;
    public
      hOK, gOK, mOK, oOK, tOK, bOK : boolean;
      ProdId: string;
      Producent  : TProducent;
      BaseInfo   : TPipesBaseInfo;

      constructor CreateFromDataSet( AOwner: TComponent;
                                     Pr: TProducent;
                                     Query: TDataSet );
      constructor CreateForProd( AOwner: TComponent; Pr: TProducent );
      constructor CreateCopy( AOwner: TComponent; Src: TDBArmatura );

      destructor  Destroy; override;

      function  MakeCopy( O :TComponent ): TDBArmatura;

      procedure Update; virtual;
      procedure ACalcFields(DataSet: TDataset);
      property A: TDataSet   read fA;
      property H: TDataSet   read fH;
      property G: TDataSet   read fG;
      property O: TDataSet   read fO;
      property T: TDataSet   read fT;
      property B: TDataSet   read fB;
  end;



implementation




{-------------------------------------------------------------------------}
constructor TDBArmatura.CreateFromDataSet( AOwner: TComponent;
                                     Pr: TProducent;
                                     Query: TDataSet );
var
  bi        :TPipesBaseInfo;
  s         :string;
begin
  inherited Create(AOwner);

  fA := Query;
  fH := TTable.Create(self);
  ProdId := pr.Ident;
  Producent := Pr;
  bi        := TPipesBaseInfo(Pr.InfoBaz['PIPES']);
  BaseInfo  := bi;
  with fH as TTable do
  begin
    s := bi.GetBaseName('H');
    DatabaseName := StrLeft( ExtractFilePath(s), -2);
    TableName := ExtractFileName(s);
    IndexFieldNames := 'H_ID';
    Open;
  end;
  fG := TTable.Create(self);
  with fG as TTable do
  begin
    s := bi.GetBaseName('G');
    DatabaseName := StrLeft( ExtractFilePath(s), -2);
    TableName := ExtractFileName(s);
    IndexFieldNames := 'G_ID';
    Open;
  end;
  fT := TTable.Create(self);
  with fT as TTable do
  begin
    s := bi.GetBaseName('T');
    DatabaseName := StrLeft( ExtractFilePath(s), -2);
    TableName := ExtractFileName(s);
    IndexFieldNames := 'TYP_ID';
    Open;
  end;

  fO := TTable.Create(self);

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





{-------------------------------------------------------------------------}
constructor TDBArmatura.CreateForProd( AOwner: TComponent; Pr: TProducent );
var
  bi        :TPipesBaseInfo;

  i         :Integer;
  f         :TField;
  s         :string;
  BN, TN    :string;              // BaseName, TableName

begin
  inherited Create(AOwner);

  ProdId    := pr.Ident;
  Producent := Pr;
  bi        := TPipesBaseInfo(Pr.InfoBaz['PIPES']);
  BaseInfo  := bi;

  GetTabNames( 'A', BN, TN );
  CreateA(BN,TN);

  GetTabNames( 'H', BN, TN );
  CreateH(BN,TN);

  GetTabNames( 'G', BN, TN );
  CreateG(BN,TN);

  GetTabNames( 'T', BN, TN );
  CreateT(BN,TN);

  GetTabNames( 'B', BN, TN );
  CreateB(BN,TN);

  fO := TTable.Create(self);
  {
  with fO as TTable do
  begin
    DatabaseName := Query.DatabaseName;
    TableName := 'O_' + pr + '.DBF';
    IndexFieldNames := 'O_ID';
    Open;
  end;
  }

  //A.OnCalcFields := ACalcFields;
end;


{-------------------------------------------------------------------------}
constructor TDBArmatura.CreateCopy( AOwner: TComponent; Src: TDBArmatura );
var
  bi        :TPipesBaseInfo;

  i         :Integer;
  RN        :Longint;
  f         :TField;
  pr        :TProducent;
  AClass    :TComponentClass;
begin
  inherited Create(AOwner);

  pr        := src.Producent;
  ProdId    := pr.Ident;
  Producent := Pr;
  bi        := TPipesBaseInfo(Pr.InfoBaz['PIPES']);
  BaseInfo  := bi;

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
    RN := GetRecNo( src.A as TBDEDataset);
    SetRecNo( fA as TBDEDataSet, RN );
  end;

  fADSrc := TDataSource.Create( self );
  fADSrc.DataSet := fA;

  if src.hOK then
    CreateH(TTable(src.H).DataBaseName, TTable(src.H).TableName);
  if src.GOK then
    CreateG(TTable(src.G).DataBaseName, TTable(src.G).TableName);
  if src.TOK then
    CreateT(TTable(src.T).DataBaseName, TTable(src.T).TableName);
  if src.BOK then
    CreateB(TTable(src.B).DataBaseName, TTable(src.B).TableName);


  //A.OnCalcFields := ACalcFields;
end;



{-------------------------------------------------------------------------}
destructor TDBArmatura.Destroy;
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


{-------------------------------------------------------------------------}
procedure TDBArmatura.CreateA( const BN, TN :string );
var
  i       :Integer;
  f       :TField;
begin
  fA := TTable.Create(self);
  with fA as TTable do
  begin
    DatabaseName := BN;
    TableName    := TN;
    {FieldDefs.Update;
    for i := 0 to FieldDefs.Count-1 do
    begin
      f := FieldDefs.Items[i].CreateField( fA );
    end;
    InsFld( 'MASA', 'Masa' );
    InsFld( 'QnJedn', 'Qn' );
    InsFld( 'HnJedn', 'Hn' );
    }
    Open;
  end;
  fADSrc := TDataSource.Create( self );
  fADSrc.DataSet := fA;
end;


{-------------------------------------------------------------------------}
procedure TDBArmatura.CreateH( const BN, TN :string );
begin
  fH := TTable.Create(self);
  with fH as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'H_ID';
      MasterSource := fADSrc;
      MasterFields  := 'H_ID';
      Open;
      hOK := true;
    except
      on EDatabaseError do
      begin
        fH.Free;
        fH := NIL;
        hOK := false;
      end;
    end;
  end;
end;


{-------------------------------------------------------------------------}
procedure TDBArmatura.CreateG( const BN, TN :string );
begin
  fG := TTable.Create(self);
  with fG as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'G_ID';
      MasterSource := fADSrc;
      MasterFields  := 'G_ID';
      Open;
      gOK := true;
    except
      on EDatabaseError do
      begin
        fG.Free;
        fG := NIL;
        gOK := false;
      end;
    end;
  end;
end;


{-------------------------------------------------------------------------}
procedure TDBArmatura.CreateT( const BN, TN :string );
begin
  fT := TTable.Create(self);
  with fT as TTable do
  begin
    try
      DatabaseName := BN;
      TableName    := TN;
      IndexFieldNames := 'TYP_ID';
      MasterSource    := fADSrc;
      MasterFields    := 'TYP_ID';
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

{-------------------------------------------------------------------------}
procedure TDBArmatura.CreateB( const BN, TN :string );
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
//procedure TDBArmatura.CreateRelBases;


{-------------------------------------------------------------------------}
procedure TDBArmatura.GetTabNames( const TabId :string;
                             var BasName, TabName : string);
var
  s       :string;
begin
  s          := BaseInfo.GetBaseName(TabId);
  BasName    := StrLeft( ExtractFilePath(s), -2);
  TabName    := ExtractFileName(s);
end;


procedure TDBArmatura.InsFld(const FldName, DispName :string);
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



{-------------------------------------------------------------------------}
function  TDBArmatura.MakeCopy( O :TComponent ): TDBArmatura;
var
  bm      :TBookMark;
  RecNo   :Longint;
begin
  result := TDBArmatura.CreateCopy( O, self );

  {Zsynchronizowac pozycje}
  { DO POPRAWY: uniezaleznic od typu A }
  {TTable(result.fA).GotoCurrent( TTable(self.fA) );}

  { Tez nie dziala }
  {bm := self.A.GetBookMark;
  result.A.GoToBookMark( bm );
  self.A.FreeBookMark( bm );}

  {}
  {RecNo := GetRecNo( self.A );
  SetRecNo( result.A, RecNo );}

  {result.Update;}
end;


{-------------------------------------------------------------------------}
procedure TDBArmatura.ACalcFields(DataSet: TDataset);
var
  nazwa   : string;
  m       : Extended;
begin
  {Update;}
  with A do
  begin
    nazwa := FieldByName('nazwa').AsString;
    FieldByName('QnJedn').AsFloat :=
        JednQ.StdToUser(FieldByName('Qn').AsFloat);
    FieldByName('HnJedn').AsFloat :=
        JednH.StdToUser(FieldByName('Hn').AsFloat);
    if GOK then
      m := G.FieldByName('MASA').AsFloat
    else
      m := 0;
    FieldByName('MASA').AsFloat := m;
  end;
end;




{-------------------------------------------------------------------------}
procedure TDBArmatura.Update;
begin
//  UpdateIt(fH);
//  UpdateIt(fG);
//  UpdateIt(fM);
//  UpdateIt(fO);
end;



(*
{-------------------------------------------------------------------------}
procedure TDBArmatura.UpdateIt( t: TDataSet );
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
      DoIt( 'M_ID', t, mOK );
    end
    else if t = fO then
    begin
    end;
  end;

end;
*)

{
procedure TDBArmatura.M_CalcFields(DataSet: TDataset);
begin
end;
}


function TDBArmatura.getA: TDataSet;
begin
  getA := fA;
end;

function TDBArmatura.getH: TDataSet;
begin
  //UpdateIt(fH);
  getH := fH;
end;

function TDBArmatura.getG: TDataSet;
begin
  //UpdateIt(fG);
  getG := fG;
end;

function TDBArmatura.getO: TDataSet;
begin
  //UpdateIt(fO);
  getO := fO;
end;





end.
