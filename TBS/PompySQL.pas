unit PompySQL;

interface

uses
  SysUtils, Classes, Dialogs,
  //DB,
  DBTables, WkpGlob,
  KR_DB, KR_Sys, KR_Class, Jednost,
  Data.DB,
  MemDataSetU,
  FireDAC.Comp.Client,   // odpowiednik MemDataSetU
  FireDAC.Comp.DataSet,  // odpowiednik MemDataSetU
  Prod, PmpBaseInfoU, ZadCompU ;

type

  TDBPompy = class (TZadComponent)
  private
    fA     : TDataSet;
    fH     : TDataSet;
    fG     : TDataSet;
    fM     : TDataSet;
    fO     : TDataSet;
    fT     : TDataSet;
    fB     : TDataSet;
    fDB2   : TDBPompy;
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

    procedure InsFld(const FldName, DispName, FormatStr:string);
    procedure InsFldStr(const FldName, DispName :string; szerokosc:integer);
    function  GetDB2 :TDBPompy;
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
    procedure WarPreInit( bi :TPumpsBaseInfo);
    procedure UpdtRec;
    procedure InitWarDSet( var ds :TDataSet; var dsrc :TDataSource );

    procedure InitBases;                                 virtual;

  public
    hOK, gOK, mOK, oOK, tOK, bOK : boolean;
    Producent  : TProducent;
    BaseInfo   : TPumpsBaseInfo;

    constructor CreateFromDataSet( AOwner: TComponent;
                                   Pr: TProducent;
                                   Query: TDataSet );
    constructor CreateForProd( AOwner: TComponent; Pr: TProducent );
    constructor CreateCopy( AOwner: TComponent; Src: TDBPompy );

    destructor  Destroy; override;

    function  MakeCopy( O :TComponent ): TDBPompy;

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
    procedure ACalcFields(DataSet: TDataset);  // przeliczanie DBGrida do wyswietlania listy pomp
    property A: TDataSet   read getA;          //
    property H: TDataSet   read getH;
    property G: TDataSet   read getG;
    property M: TDataSet   read getM;
    property O: TDataSet   read getO;
    property T: TDataSet   read getT;
    property B: TDataSet   read getB;
    property WarM: TDataSet read FWarM;
    property WarG: TDataSet read FWarG;
    property DB2 :TDBPompy read getDB2;
    property ADel: boolean read fADel write fADel;
    property Field[const AName :string] :TField read GetField;
  end;

  TDBPompyCopy = class (TDBPompy)  // Kopia w pamieci
  private
    procedure SetProdId(const Value: string);
    function GetProdId: string;
    function GetMA: TMemDataSet;
    function GetMH: TMemDataSet;
    procedure SetMA(const Value: TMemDataSet);
    procedure SetMH(const Value: TMemDataSet);

    function S_GetMA: TFDmemTable;                // MS 2024.06.02 zmodyfikowane MemDataSet
    function S_GetMH: TFDMemTable;
    procedure S_SetMA(const Value: TFDMemTable);
    procedure S_SetMH(const Value: TFDMemTable);

  protected
    procedure CopyA( src :TDBPompy );
    procedure CopyH( src :TDBPompy );
    procedure CopyM( src :TDBPompy );

    procedure S_CopyA( src :TDBPompy );
    procedure S_CopyH( src :TDBPompy );
    procedure S_CopyM( src :TDBPompy );

    procedure Loaded;                               override;

    procedure InitBases;                            override;
  public
    constructor Create( O :TComponent ); override;
    constructor CreateFrom( AOwner :TComponent; src :TDBPompy );
  published
    property MA :TMemDataSet read GetMA write SetMA;       //MS 2024.06.02 nie uzywane
    property MH :TMemDataSet read GetMH write SetMH;       //MS 2024.06.02 nie uzywane
    property ProdId :string read GetProdId write SetProdId;
  end;



implementation

{ TDBPompy }

constructor TDBPompy.CreateFromDataSet( AOwner  : TComponent;
                                        Pr      : TProducent;
                                        Query   : TDataSet );
var
  bi        :TPumpsBaseInfo;
  s         :string;
  BN, TN    :string;              // BaseName, TableName
begin
  inherited Create(AOwner);

  fA := Query;
  //ProdId := pr.Ident;
  Producent := Pr;
  bi        := TPumpsBaseInfo(Pr.InfoBaz['PUMPS']);
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


constructor TDBPompy.CreateForProd( AOwner: TComponent; Pr: TProducent );
var
  bi        :TPumpsBaseInfo;

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

constructor TDBPompy.CreateCopy( AOwner: TComponent; Src: TDBPompy );
var
  bi        :TPumpsBaseInfo;

  i         :Integer;
  RN        :Longint;
  f         :TField;
  pr        :TProducent;
  AClass    :TComponentClass;

begin
  // ten construktor chyba nie dziala MS
  try

    inherited Create(AOwner);

    pr        := src.Producent;
    //ProdId    := pr.Ident;
    Producent := Pr;
    bi        := TPumpsBaseInfo(Pr.InfoBaz['PUMPS']);
    BaseInfo  := bi;
    WarPreInit(bi);
    AClass    := TComponentClass(src.A.ClassType);
    fA := (AClass.Create(self)) as TDataSet;
    if fa is TTable then
    with fA as TTable do
    begin
      DataBaseName := TTable(src.A).DataBaseName;
      TableName    := TTable(src.A).TableName;
      FieldDefs.Update;
      for i := 0 to FieldDefs.Count-1 do
      begin
        f := FieldDefs.Items[i].CreateField( fA );
      end;
      InsFld( 'MASA', 'Masa' ,'0.00');
      InsFld( 'QnJedn', 'Qn1','0.00');
      InsFld( 'HnJedn', 'Hn1','0.00');

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
      InsFld( 'MASA', 'Masa','0.00' );
      InsFld( 'QnJedn', 'Qn1','0.00' );
      InsFld( 'HnJedn', 'Hn1','0.00' );
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


    A.OnCalcFields := ACalcFields; //Przeliczanie Qn na inne jednostki
    UpdtRec;
  except
    on EAccessViolation do
      ShowMessage('To tu' );
  end;

end;



destructor TDBPompy.Destroy;
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

procedure TDBPompy.InitBases;
var
  bi        :TPumpsBaseInfo;

  //i         :Integer;
  //f         :TField;
  //s         :string;
  BN, TN    :string;              // BaseName, TableName

begin

  bi        := TPumpsBaseInfo(Producent.InfoBaz['PUMPS']);
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

  // 2024.10.18 GetTabNames( 'B', BN, TN );
  // 2024.10.18 CreateB(BN,TN);

  //GetTabNames( 'J', BN, TN );
  //CreateJ(BN,TN);

  fO := TTable.Create(self);
  ADel := false;

  A.OnCalcFields := ACalcFields;
  UpdtRec;

end;


procedure TDBPompy.CreateA( const BN, TN :string );
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
    for i := 0 to FieldDefs.Count-1 do //Przepisuje pola z tablicy A_ 33 pola
    begin
      f := FieldDefs.Items[i].CreateField( fA );
    end;
    InsFld( 'MASA', 'Masa','0.00');          //Dodawanie nowych pol
    InsFld( 'QnJedn', 'Qn','0.00' );
    InsFld( 'HnJedn', 'Hn','0.00' );
    InsFld( 'Przel','Przel','0');
    InsFld( 'WYL', 'WYL','0.00' );            //Wylot pompy
    InsFldStr('PRZYL','PRZYL',20);            // Dodane dla LFP 2015.05.02
    InsFld( 'P1','P1','0.00');
    InsFld( 'P2','P2','0.00');
    InsFld( 'U','U','0');
    InsFld( 'I','I','0.00');
    InsFldStr('WIR','WIR',20);
    InsFldStr('MONT','MONT',33);
    Open;
  end;
  // moze tu dodac dopisywanie
  fADSrc := TDataSource.Create( self ); //Do czego to DataSurce ??
  fADSrc.DataSet := fA;
end;


function TDBPompy.CreateH( const BN, TN :string; plus :Boolean = false ) :TDataSet;
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


function TDBPompy.CreateG( const BN, TN :string; plus :Boolean = false ) :TDataSet;
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


procedure TDBPompy.CreateM( const BN, TN :string );
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

procedure TDBPompy.CreateT( const BN, TN :string );
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

procedure TDBPompy.CreateB( const BN, TN :string );
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
//procedure TDBPompy.CreateRelBases;


procedure TDBPompy.GetTabNames( const TabId :string;
                             var BasName, TabName : string);
var
  s       :string;
begin
  s          := BaseInfo.GetBaseName(TabId);
  BasName    := StrLeft( ExtractFilePath(s), -2);
  TabName    := ExtractFileName(s);
end;


procedure TDBPompy.InsFld(const FldName, DispName, FormatStr :string);
var
  Fld     :TFloatField;
begin
  try
    Fld := TFloatField.Create(fA);
    Fld.Calculated   := true;
    Fld.FieldName    := FldName;
    Fld.DisplayLabel := DispName;
    Fld.DataSet      := fA;
    Fld.EditFormat   := FormatStr; //Nie dziala ???

//    if (FldName = 'QnJedn') or (FldName = 'HnJedn') then
//      Fld.EditFormat := '0.000'
//    else
//      Fld.EditFormat := '0.0';
  except
    on e: Exception do
      ShowMessage( e.Message );
  end;
end;

procedure TDBPompy.InsFldStr(const FldName, DispName: string; szerokosc:integer);
var
  Fld     :TStringField;
begin
  try
    Fld := TStringField.Create(fA);
    Fld.Calculated   := true;
    Fld.FieldName    := FldName;
    Fld.DisplayLabel := DispName;
    Fld.DataSet      := fA;
    Fld.Size         := szerokosc;
  except
    on e: Exception do
      ShowMessage( e.Message );
  end;
end;

function  TDBPompy.MakeCopy( O :TComponent ): TDBPompy;
begin
  UpdtRec;
  result := TDBPompyCopy.CreateFrom( O, self );
end;

function  TDBPompy.GetDB2 :TDBPompy;
begin
  if fDB2 = NIL then
  begin
    fDB2 := TDBPompy.CreateForProd( self, Producent );
  end;
  result := fDB2;
end;


procedure TDBPompy.ACalcFields(DataSet: TDataset);
var
  nazwa   : string;
  mm      : Extended;
  s :string;
  st:string;
  fI  : double;
  fU  : double;
  fCos: double;
  P1el: double;
  StrKonstr : String;
  kon       : String;
  i,idol,igor:integer;
  montazID  : String;
begin
  {Update;}
  with A do
  begin
    nazwa := FieldByName('nazwa').AsString;
//    FieldByName('QnJedn').AsFloat :=
//        JednQ.StdToUser(FieldByName('Qn').AsFloat);

// Przeliczanie tabeli przegladania na aktualne jednostki i obcinanie bazy
    FieldByName('QnJedn').AsFloat :=
        round(m3hToU(FieldByName('Qn').AsFloat)*100)/100;

    FieldByName('HnJedn').AsFloat :=
        JednH.StdToUser(FieldByName('Hn').AsFloat);
{ //wlaczone pobieranie z T
    montazID := FieldByName('ID6').AsString;
    if montazID = '1' then
      FieldByName('MONT').AsString := 'Mokry, autozlacze' else
    if montazID = '2' then
      FieldByName('MONT').AsString := 'Mokry, autozlacze z wynurzeniem' else
    if montazID = '3' then
      FieldByName('MONT').AsString := 'Suchy, pionowy z podstawa' else
    if montazID = '4' then
      FieldByName('MONT').AsString := 'Mokry, przenosny' else
    if montazID = '5' then
      FieldByName('MONT').AsString := 'Mokry, przenosnu z wynurzeniem' else
    if montazID = '6' then
      FieldByName('MONT').AsString := 'Suchy, poziomy z podstawa' else
    if montazID = '7' then
      FieldByName('MONT').AsString := 'Pionowy w kolumnie' else
    if montazID = 'X' then
      FieldByName('MONT').AsString := 'Dowolny'
    else
      FieldByName('MONT').AsString := '-';
}
    //czytanie z CHARAKTERYSTYKI
    if hOK then
      begin
        s := FieldByName('H_ID').AsString;
        if H.Locate( 'H_ID', S ,  [] ) then
           FieldByName('Przel').AsFloat := H.FieldByName('ZIARNO').AsFloat;
      end
    else
      FieldByName('Przel').AsFloat := 0;

    //czytanie z GEOMETRII
    if gOK then
      begin
        G.First;
        s := FieldByName('G_ID').AsString;
        if G.Locate( 'G_ID', (S) ,  [] ) then
        begin
           mm := G.FieldByName('MASA').AsFloat;
           FieldByName('MASA').AsFloat := mm;
           FieldByName('WYL').AsFloat := G.FieldByName('WYLOT').AsFloat;
           //FieldByName('PRZYL').AsString := G.FieldByName('T1').AsString;   // Dodane dla LFP 2015.05.02
        end
        else begin
               FieldByName('MASA').AsFloat := 0;
               FieldByName('WYL').AsFloat  := 0;
             end;
      end
    else
      begin
        FieldByName('MASA').AsFloat := 0;
        FieldByName('WYL').AsFloat  := 0;
      end;

     //czytanie z MOTORA
     // czy mozna tu przejsc na wyswietlanie parametrow pompy
     if mOK then
      begin
        s := FieldByName('M_ID').AsString;
        if M.Locate( 'M_ID', S ,  [] ) then
        begin
          FieldByName('P2').AsFloat := M.FieldByName('M_PZN').AsFloat;
          fU := M.FieldByName('NAP').AsFloat;
          fI := M.FieldByName('PRAD').AsFloat;
          fCos := M.FieldByName('COSF').AsFloat;

          FieldByName('U').AsFloat := fU;
          FieldByName('I').AsFloat := fI;
          if fU<300
            then P1el := round(fU*fI*fcos/1000*100)/100
            else P1el := round(sqrt(3)*fU*fI*fCos/1000*100)/100;
          FieldByName('P1').AsFloat := P1el;
        end;
      end
    else
      begin
        FieldByName('P1').AsFloat := 0;
        FieldByName('P2').AsFloat := 0;
        FieldByName('U').AsFloat := 0;
        FieldByName('I').AsFloat := 0;
      end;

     //czytanie z TYPU
    if tOK then
      begin
        s := FieldByName('TYP_ID').AsString;
        if T.Locate( 'TYP_ID', S ,  [] ) then
        begin
          StrKonstr := T.FieldByName('KONSTR').AsString;
          //Poczatak czytania wirnika
          i:=1;
          idol:=1;
          while i< (length(StrKonstr)+1) do
            begin
              if copy(StrKonstr,i,1)='/' then
                begin
                  igor:=i;
                  if igor>idol then
                    begin
                      kon:=copy(StrKonstr,idol+1,(igor-idol-1));
                      if copy(kon,1,2)='w_' then
                        begin
                          st := KluczePompIni.ReadString('Konstrukcja',kon, '??');
                          FieldByName('WIR').AsString := st
                        end;
                      if copy(kon,1,2)='m_' then
                        begin
                          st := KluczePompIni.ReadString('Konstrukcja',kon, '??');
                          FieldByName('MONT').AsString := st;
                        end;
                      idol:=igor;
                  end;
                end;
              inc(i);
            end;
        end;
        //koniec czytanaia wirnika
      end
    else
      begin
        FieldByName('WIR').AsString  := '-';
        FieldByName('MONT').AsString  := '-'
      end;
  end;
end;




{-------------------------------------------------------------------------}
procedure TDBPompy.Update;
begin
  UpdtRec;
//  UpdateIt(fH);
//  UpdateIt(fG);
//  UpdateIt(fM);
//  UpdateIt(fO);
end;




{-------------------------------------------------------------------------}
procedure TDBPompy.UpdateIt( t: TDataSet );
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
      DoIt( 'H_ID', t, hOK );
    end
    else if t = fG then
    begin
      DoIt( 'G_ID', t, gOK );
    end
    else if t = fM then
    begin
      DoIt( 'M_ID', t, mOK );
    end
    else if t = fO then
    begin
    end;
  end;

end;

{
procedure TDBPompy.M_CalcFields(DataSet: TDataset);
begin
end;
}


function TDBPompy.getA: TDataSet;
begin
  WakeUp;
  getA := fA;
end;

function TDBPompy.getH: TDataSet;
begin
  WakeUp;
  getH := fH;
end;

function TDBPompy.getG: TDataSet;
begin
  WakeUp;
  getG := fG;
end;

function TDBPompy.getM: TDataSet;
begin
  WakeUp;
  getM := fM;
end;

function TDBPompy.getO: TDataSet;
begin
  WakeUp;
  getO := fO;
end;

function TDBPompy.getT: TDataSet;
begin
  WakeUp;
  result := fT;
end;

function TDBPompy.getB: TDataSet;
begin
  WakeUp;
  result := fB;
end;

function TDBPompy.GetProdID: string;
begin
  if Producent <> NIL then
    result := Producent.Ident
  else
    result := '';
end;



function TDBPompy.OpenTable(const id: string): TDataSet;
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

function TDBPompy.BOF: Boolean;
begin
  result := A.Bof;
end;

function TDBPompy.EOF: Boolean;
begin
  result := A.Eof;
end;

procedure TDBPompy.First;
begin
  A.First;
end;

procedure TDBPompy.Last;
begin
  A.Last;
end;

procedure TDBPompy.Next;
begin
  A.Next;
end;

procedure TDBPompy.Prior;
begin
  A.Prior;
end;

procedure TDBPompy.UpdtRec;

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
      sr := fADSrc;                 // normalnie odniesienie do A
      s := A.FieldByName(id).AsString;
      if (Length(s) > 2) and (s[2] = '@') then
        case s[3] of
          'M': sr := FWarMSrc;
          'T': sr := FWarTSrc;
          'G': sr := FWarGSrc;
        end;

      t.MasterFields := id;
      t.MasterSource := wdsrc;
      wt.MasterFields := id;
      wt.MasterSource := sr;
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

procedure TDBPompy.InitWarDSet(var ds: TDataSet; var dsrc: TDataSource);
begin
  ds := TTable.Create(self);
  dsrc := TDataSource.Create(self);
  TTable(ds).IndexFieldNames := 'ID';
  TableSetNames( FWarFName, TTable(ds) );
  dsrc.DataSet := ds;
  ds.Open;
end;

procedure TDBPompy.WarPreInit( bi :TPumpsBaseInfo);
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

function TDBPompy.BOV: Boolean;
begin
  result := true;
  if RecWarM then
    result := result and FWarM.Bof;
  if RecWarT then
    result := result and FWarT.Bof;
  if RecWarG then
    result := result and FWarG.Bof;
end;

function TDBPompy.EOV: Boolean;
begin
  result := true;
  if RecWarM then
    result := result and FWarM.Eof;
  if RecWarT then
    result := result and FWarT.Eof;
  if RecWarG then
    result := result and FWarG.Eof;
end;

procedure TDBPompy.FirstVar;
begin
  if RecWarM then
    FWarM.First;
  if RecWarT then
    FWarT.First;
  if RecWarG then
    FWarG.First;
end;

procedure TDBPompy.LastVar;
begin
  if RecWarM then
    FWarM.Last;
  if RecWarT then
    FWarT.Last;
  if RecWarG then
    FWarG.Last;
end;

procedure TDBPompy.NextVar;
begin
  if RecWarM and (not FWarM.Eof) then
    FWarM.Next
  else if RecWarT and (not FWarT.Eof) then
    FWarT.Next
  else if RecWarG and (not FWarG.Eof) then
    FWarG.Next;
end;

procedure TDBPompy.PriorVar;
begin
  if RecWarG and (not FWarG.Bof) then
    FWarG.Prior
  else if RecWarT and (not FWarT.Bof) then
    FWarT.Prior
  else if RecWarM and (not FWarM.Bof) then
    FWarM.Prior;
end;

function TDBPompy.BOH: Boolean;
begin
  if FRecWarH then
    result := FWarH.Bof
  else
    result := H.Bof;
end;

function TDBPompy.EOH: Boolean;
begin
  if FRecWarH then
    result := FWarH.Eof
  else
    result := H.Eof;
end;

procedure TDBPompy.FirstH;
begin
  if FRecWarH then
    FWarH.First
  else
    H.First;
end;

procedure TDBPompy.LastH;
begin
  if FRecWarH then
    FWarH.Last
  else
    H.Last;
end;

procedure TDBPompy.NextH;
begin
  if FRecWarH then
    FWarH.Next
  else
    H.Next;
end;

procedure TDBPompy.PriorH;
begin
  if FRecWarH then
    FWarH.Prior
  else
    H.Prior;
end;

function TDBPompy.GetField(const AName: string): TField;
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

procedure TDBPompy.Notification(AComponent: TComponent;
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

procedure TDBPompy.Sleep;
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

procedure TDBPompy.WakeUp;
begin
  if not FSleeping then
    EXIT;
  InitBases;
  FSleeping := false;
  A.Bookmark := TBookmark(FSvABookmark);
  UpdtRec;
end;





{ TDBPompyCopy }

procedure TDBPompyCopy.CopyA(src: TDBPompy);
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
  // KR: 2002.06.13 - dodalem if
  if aMA.FieldByName('OBJ_ID').AsString <> 'ZHR' then
    aMA.FieldByName('H_ID').AsString := '';
  aMA.Post;
  fADSrc.DataSet := fA;
end;

procedure TDBPompyCopy.CopyH(src: TDBPompy);
var
  aMH      :TMemDataSet;
  svBM     :TBookmark;
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
    svBM:= src.FWarH.Bookmark;
    src.FWarH.First;
    while (not src.FWarH.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin
      aMH.CopyRecord(src.H, aMH);
      src.FWarH.Next;
    end;
    src.FWarH.Bookmark := TBookmark( svBM )
  end
  else
  begin
    svBM:= src.H.Bookmark;
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
(***************************************************)
(* Kopia bazy M_                                   *)
(***************************************************)
procedure TDBPompyCopy.CopyM(src: TDBPompy);
var
  aMemM      :TMemDataSet; //Data set dla bazy Motorow
  svBM     :TBookmark;
  hid      :string;
begin
  aMemM := TMemDataSet.Create(self);
  fM := aMemM;
  aMemM.Name := 'M';
  hid := src.A.FieldByName('M_ID').AsString;
  aMemM.CreateTableAs(src.M);
  aMemM.SaveFieldDefs := true;
  aMemM.SaveData := true;
  aMemM.Open;
  // !! Pozniej mozna poprawic
  if src.FRecWarM then
  begin
    svBM:= src.FWarM.Bookmark;
    src.FWarM.First;
    while (not src.FWarM.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin
      aMemM.CopyRecord(src.M, aMemM);
      src.FWarM.Next;
    end;
    src.FWarM.Bookmark := TBookmark(svBM);
  end
  else
  begin
    svBM:= src.M.Bookmark;
    src.M.First;
    while (not src.M.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin
      aMemM.CopyRecord(src.M, aMemM);
      src.M.Next;
    end;
    src.M.Bookmark := TBookmark(svBM);
  end;
  hOK := true;
end;

constructor TDBPompyCopy.Create(O: TComponent);
begin
  inherited Create(O);
  fADSrc := TDataSource.Create( self );
end;

constructor TDBPompyCopy.CreateFrom(AOwner: TComponent; src: TDBPompy);
begin
  inherited Create(AOwner);
  fADSrc := TDataSource.Create( self );
  //MS 2024.06.03 CopyA(src);
  //MS 2024.06.03 CopyH(src);
  //MS 2024.06.03 CopyM(src);

  S_CopyA(src);
  S_CopyH(src);
  S_CopyM(src);

  ProdId := src.Producent.Ident;
  UpdtRec;
end;

function TDBPompyCopy.GetMA: TMemDataSet;
begin
  result := fA as TMemDataSet;
end;

function TDBPompyCopy.GetMH: TMemDataSet;
begin
  result := fH as TMemDataSet;
end;

function TDBPompyCopy.GetProdId: string;
begin
  result := inherited GetProdId;
end;

procedure TDBPompyCopy.InitBases;
var
  BN, TN  :string;
begin
  BaseInfo  := TPumpsBaseInfo(Producent.InfoBaz['PUMPS']);
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

procedure TDBPompyCopy.Loaded;
begin
  inherited;
  UpdtRec; 
end;

procedure TDBPompyCopy.SetMA(const Value: TMemDataSet);
begin
  if fA <> NIL then
    fA.Free;
  fA := Value;
  fADSrc.DataSet := fA;
  fA.Open;
end;

procedure TDBPompyCopy.SetMH(const Value: TMemDataSet);
begin
  if fH <> NIL then
    fH.Free;
  fH := Value;
  fH.Open;
end;

procedure TDBPompyCopy.SetProdId(const Value: string);
var
  BN, TN  :string;
begin
  Producent := Producenci.ProdByName(Value);
  BaseInfo  := TPumpsBaseInfo(Producent.InfoBaz['PUMPS']);
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


procedure TDBPompyCopy.S_CopyA(src: TDBPompy);
var
  aMA      :TFDMemTable;
begin
  aMA := TFDMemTable.Create(self);
  fA := aMA;
  aMA.Name := 'A';

  //MS 2024.06.02 aMA.SaveFieldDefs := true;
  //MS 2024.06.02 aMA.SaveData := true;
  //MS 2024.06.02 aMA.CreateTableAs(src.A);

  try
    aMA.CopyDataSet(src.A, [coStructure, coRestart]); //, coAppend]);
  except
    aMA.Free;
    raise;
  end;

  /////
  aMA.Open;
  aMA.Edit;
  aMA.CopyRecord(src.A);
  //MS 2024.06.02 aMA.CopyRecord(src.A, aMA);
  aMA.Edit;
  // KR: 2002.06.13 - dodalem if
  if aMA.FieldByName('OBJ_ID').AsString <> 'ZHR' then
    aMA.FieldByName('H_ID').AsString := '';
  aMA.Post;
  fADSrc.DataSet := fA;
end;

procedure TDBPompyCopy.S_CopyH(src: TDBPompy);
var
  aMH      :TFDMemTable;
  svBM     :TBookmark;
  hid      :string;
begin
  aMH := TFDMemTable.Create(self);
  fH := aMH;
  aMH.Name := 'H';
  hid := src.A.FieldByName('H_ID').AsString;

  try
    aMH.CopyDataSet(src.H, [coStructure, coRestart]); //, coAppend]);
  except
    aMH.Free;
    raise;
  end;

  aMH.Open;
  aMH.Edit;  //MS 2024.06.10
  // !! Pozniej mozna poprawic
  if src.FRecWarH then
  begin
    svBM:= src.FWarH.Bookmark;
    src.FWarH.First;
    while (not src.FWarH.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin
      aMH.CopyRecord(src.H);
      //MS 2024.06.02 aMH.CopyRecord(src.H, aMH);
      src.FWarH.Next;
    end;
    src.FWarH.Bookmark := TBookmark( svBM )
  end
  else
  begin
    svBM:= src.H.Bookmark;
    src.H.First;
    while (not src.H.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin

      aMH.CopyRecord(src.H);
      //MS 2024.06.02 aMH.CopyRecord(src.H, aMH);
      src.H.Next;
    end;
    src.H.Bookmark := TBookmark(svBM);
  end;
  hOK := true;
end;

procedure TDBPompyCopy.S_CopyM(src: TDBPompy);
var
  aMemM      :TFDMemTable; //Data set dla bazy Motorow
  svBM     :TBookmark;
  hid      :string;
begin
  aMemM := TFDMemTable.Create(self);
  fM := aMemM;
  aMemM.Name := 'M';
  hid := src.A.FieldByName('M_ID').AsString;
  try
    aMemM.CopyDataSet(src.M, [coStructure, coRestart]); //, coAppend]);
  except
    aMemM.Free;
    raise;
  end;

  aMemM.Open;
  aMemM.Edit;  //MS 2024.06.10
  // !! Pozniej mozna poprawic
  if src.FRecWarM then
  begin
    svBM:= src.FWarM.Bookmark;
    src.FWarM.First;
    while (not src.FWarM.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin
      aMemM.CopyRecord(src.M);
      //MS 2024.06.02 aMemM.CopyRecord(src.M, aMemM);
      src.FWarM.Next;
    end;
    src.FWarM.Bookmark := TBookmark(svBM);
  end
  else
  begin
    svBM:= src.M.Bookmark;
    src.M.First;
    while (not src.M.Eof) do
            //and (src.H.FieldByName('H_ID').AsString = hid) do
    begin


      aMemM.CopyRecord(src.M);
      //MS 2024.06.02 aMemM.CopyRecord(src.M, aMemM);
      src.M.Next;
    end;
    src.M.Bookmark := TBookmark(svBM);
  end;
  hOK := true;
end;

function TDBPompyCopy.S_GetMA: TFDmemTable;
begin
  result := fA as TFDMemTable;
end;

function TDBPompyCopy.S_GetMH: TFDMemTable;
begin
  result := fH as TFDMemTable;
end;

procedure TDBPompyCopy.S_SetMA(const Value: TFDMemTable);
begin
  if fA <> NIL then
    fA.Free;
  fA := Value;
  fADSrc.DataSet := fA;
  fA.Open;
end;

procedure TDBPompyCopy.S_SetMH(const Value: TFDMemTable);
begin
  if fH <> NIL then
    fH.Free;
  fH := Value;
  fH.Open;
end;

initialization
  Classes.RegisterClass( TDBPompyCopy );

end.
