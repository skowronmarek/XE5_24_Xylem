unit OPompa;

interface



uses
  Windows,
  SysUtils,
  Classes,
  Math,
  graphics,
  jpeg,
  DB,
  DBTables,
  JezykTxt, BledyU,
  KrMath,
  DGraph,
  KR_Sys,
  KR_DB,
  PompMath,     // do tego unita jest czyste pod wzgl CONSOLE
  prod,         { TODO 1 -oKR -cPodzial wg logiki : Kontynuowac czyszczenie OPompa z kontrolek }
  Diagrams,
  PumpIntf,
  PompySQL,
  ZadCompU;

type

  TPompa = class;

  TPompaEvent = procedure(APmp :TPompa) of object;
  TPompaDBEvent = procedure(APmp :TPompa; ADB :TDBPompy) of object;

  TStylPompy = (spWBazie, spFizyczna);

  TCharDataDiagFun = class;

// charakterystyka pompy ABSTRACT
  TPompCharData = class (TComponent)
  private
    function GetCS: string;
  protected
    function GetObrotyOPompa :Double;
    function CreateCopyInstance( O :TComponent ) :TPompCharData;  virtual;
    procedure InitCopyInstance( inst :TPompCharData );    virtual; abstract;
    procedure SetObroty(const Value: Double);             virtual; abstract;
    procedure SetSrednica(const Value: Double);           virtual; abstract;
    function GetObroty: Double;                           virtual; abstract;
    function GetSrednica: Double;                         virtual; abstract;
  public
    Pompa     :TPompa;
    procedure ReadFromHTable( HT :TDataSet );             virtual; abstract;
    procedure WriteToHTable( HT :TDataSet );              virtual; abstract;
              //wywolanie charakterystyki na diagramie
    function  GetDiagFun( id :string;
                    Owner :TDiagFunction ):TCharDataDiagFun;   virtual; abstract;
    function  WorkPoint( Sel :IPumpCharSel; var Qr, Hr :Double ) :Boolean;
                                                          virtual; abstract;
    function  GetQMin  :Double;                           virtual; abstract;
    function  GetQMax  :Double;                           virtual; abstract;
    function  GetCharQMin  :Double;                       virtual; abstract;
    function  GetCharQMax  :Double;                       virtual; abstract;
    function  GetHMin  :Double;                           virtual; abstract;
    function  GetHMax  :Double;                           virtual; abstract;
    function  GetCharHMin  :Double;                       virtual; abstract;
    function  GetCharHMax  :Double;                       virtual; abstract;
    function  GetCharPMax  :Double;                       virtual; abstract; //Moc na wale P2
    //MS wstawianie charakterystyki mocy elektrycznej
    function  GetCharP1Max  :Double;                       virtual; abstract; // maksimum mocy elektrycznej
    function  GetCharNPSHMax  :Double;                    virtual; abstract;

    function  MoznaObroty :Boolean;                       virtual;
    function  MakeCopy( O :TComponent ) :TPompCharData;   virtual;
    procedure Pomnoz( FakQ, FakH, FakP :Double );         virtual; abstract;
    property Srednica :Double read GetSrednica write SetSrednica;
    property Obroty  :Double read GetObroty write SetObroty;

    property CharQMax :Double read GetCharQMax;
    property CharHMax :Double read GetCharHMax;
    property CharPMax :Double read GetCharPMax;
    property CharP1Max :Double read GetCharP1Max;
    property CharNPSHMax :Double read GetCharNPSHMax;

    // ulatwia debugowanie - nie uzywane w obliczeniach
    property XXClassName :string read GetCS;
  end;

  TPompCharDataClass = class of TPompCharData;

  TFuncCharData = class (TPompCharData)
  protected
    FObroty: Double;
    FSrednica: Double;
    procedure SetObroty(const Value: Double);       override;
    procedure SetSrednica(const Value: Double);     override;
    function GetObroty: Double;                     override;
    function GetSrednica: Double;                   override;

  public                          // w przyszlosci powinno byc protected
    FCharQMin      :Double;
    FCharQMax      :Double;
    FCharHMin      :Double;
    FCharHMax      :Double;
    FCharPMax      :Double;       // maksymalna moc na charakterystyce
    FCharNPSHMax   :Double;

  public
    procedure ReadFromHTable( HT :TDataSet );            override;
    procedure WriteToHTable( HT :TDataSet );             override;
    function  WorkPoint( Sel :IPumpCharSel; var Qr, Hr :Double ) :Boolean;
                                                         override;
    function  GetDiagFun( id :string;
                   Owner :TDiagFunction  ):TCharDataDiagFun; override;
    function  H   ( Q :Double ) :Double;        virtual; abstract;
    function  P   ( Q :Double ) :Double;        virtual; abstract;
    function  NPSH( Q :Double ) :Double;        virtual; abstract;
    function  ETA ( Q :Double ) :Double;        virtual;

    //function  Q_od_H( AH :Double ) :Double;      virtual;
    function  Q_od_H( AH :Double; var OK :Boolean ) :Double;  overload;
    function  Q_od_H( AH :Double ) :Double;                   overload;

    function  GetQMin      :Double;           override;
    function  GetQMax      :Double;           override;
    function  GetCharQMin  :Double;           override;
    function  GetCharQMax  :Double;           override;
    function  GetHMin      :Double;           override;
    function  GetHMax      :Double;           override;
    function  GetCharHMin  :Double;           override;
    function  GetCharHMax  :Double;           override;
    function  GetCharPMax  :Double;           override;
    function  GetCharP1Max :Double;           override;
    function  GetCharNPSHMax  :Double;        override;

    function  MoznaObroty :Boolean;           override;


    procedure Pomnoz( FakQ, FakH, FakP :Double );   override;

  end;

  TCharDataDiagFun = class (TDiagFunDrawer)
    private
      FData     :TPompCharData;
      FMaxYR    :Double;
    protected
      procedure SetMaxYR( v :Double );                   override;
      procedure SetHolder( v :TDiagFunction );           override;
      property  CharData   :TPompCharData  read FData     write FData;

    public
      constructor Create( O :TComponent );                 override;
      procedure DrawFPub( dt  :TSpecDrawData; bw :Boolean );
  end;


  TFuncDiagFun = class (TCharDataDiagFun)
    protected
      LegQArr   :array of Single;
      procedure DrawFun  ( dt  :TSpecDrawData; bw :Boolean );  override;
      function  GetData  :TFuncCharData;
      procedure SetData( AData :TFuncCharData );
      procedure DrawLegendItem ( X, Y :Double; dt  :TSpecDrawData;
                                 bw :Boolean );
      function  DGetCharQMin :Double;    virtual;
      function  DGetCharQMax :Double;    virtual;
      function  DGetQMin :Double;    virtual;
      function  DGetQMax :Double;    virtual;
      //function  Value( Q :Double ): Double;             virtual; abstract;
    public
      Bolded    :Boolean;
      Legend    :Boolean;
      LegText   :string;
      LegC      :Integer;
      procedure SetLegQ( const A :array of Single );
      property  Data :TFuncCharData read GetData write SetData;
  end;

  THFuncDiagFun = class (TFuncDiagFun)
    public
      function Value( Q :Double ): Double;                     override;
  end;

  TPFuncDiagFun = class (TFuncDiagFun)
    public
      function Value( Q :Double ): Double;                     override;
  end;

  TP1FuncDiagFun = class (TFuncDiagFun)
    public
      function Value( Q :Double ): Double;                     override;
  end;

  TNPSHFuncDiagFun = class (TFuncDiagFun)
    public
      function Value( Q :Double ): Double;                     override;
  end;

  TETAFuncDiagFun = class (TFuncDiagFun)
    public
      function Value( Q :Double ): Double;                     override;
  end;



  TPompWorkParam = class (TComponent)
  end;

  TPumpInterface = class (IPump)
    private
      FPump        :TPompa;
      FDestroyed   :Boolean;
    protected
      property Destroyed    :Boolean read FDestroyed   write FDestroyed;
    public
      destructor  Destroy;                                        override;

      //function  Release :Longint;                                 override;
      function  GetVersion :Integer;                              override;

      procedure GetName( AName :PChar; AMax :Integer );           override;
      function  GetQMin  :Double;                                 override;
      function  GetQMax  :Double;                                 override;
      function  GetHMin  :Double;                                 override;
      function  GetHMax  :Double;                                 override;

      function  GetQn    :Double;                                 override;
      function  GetHn    :Double;                                 override;
      function  GetPn    :Double;                                 override;

      function  WorkPoint( Char :IPumpCharSel; var Qr, Hr :Double ): Boolean;
                                                                  override;

    public
      property Pompa        :TPompa  read FPump;
  end;


  TFizPompa = class
    private
      {}
    public
      Qn     :Double;
      Hn     :Double;
      Pn     :Double;
      ETAn   :Double;
      NPSHn  :Double;
      QMin   :Double;
      QMax   :Double;

      CharQMin:  Double;
      CharQMax:  Double;

      Cena   :Double;
      Masa   :Double;
      N      :Integer;

      Nazwa: string;

      constructor Create( ADB : TDBPompy );  overload;
      constructor Create;                    overload;

  end;

  {
  -------------------------------------------------
  | KLASA: TPompa
  |
  |   Konstruktory
  |     StworzWBazie - tworzy obiekt pompy z aktualnym odwolaniem do bazy
  |                    (wartosci pol obiektu sa zalezne od aktualnych wartosci
  |                    w bazie).
  |     WczytajZBazy - Wczytuje z bazy niezalezny obiekt
  |     StworzKopie  -
  |
  |
  -------------------------------------------------
  }
  TPompa = class( TZadComponent )
  public
    constructor StworzWBazie( ADB: TDBPompy ); virtual;
    constructor WczytajZBazy( ADB: TDBPompy ); virtual;
    constructor CreateWithOwner( ADB: TDBPompy; O :TComponent );
                                               virtual;
    constructor Create( O :TComponent );       override;
    destructor  Destroy;                       override;

    procedure  Init;                           virtual; //rejestruje komponent??

    procedure AddRef;
    procedure Release;
    {
    function  CreateForm( AOwner :TComponent;
                          AMDIChild :Boolean = true ) :TForm; virtual;
    }

  private
    FDB       : TDBPompy;
    FWBazie   : Boolean;          //Czy fizyczna, czy w bazie
    FCharSel  : IPumpCharSel;
    FWorkParam: TPompWorkParam;

    FWDobroci : Double;  //Wstawka MS
    FQr       : Double;
    FHr       : Double;
    FPr       : Double;
    FNPSHr    : Double;
    FImageIndex: Integer;
    FParObliczone: Boolean;
    FETAr: Double;
    FWarM_Ustalone: Boolean;
    FIDWarM: string;
    FObszFieldName: string;

    procedure SetWorkParam(const Value: TPompWorkParam);
    function GetMoznaLepPrzel: Boolean;
    function GetMoznaRoPrzel: Boolean;
    procedure SetImageIndex(const Value: Integer);
    procedure SetName(const Value: string);
    procedure SetParObliczone(const Value: Boolean);
    procedure SetETAr(const Value: Double);
    procedure SetCharSel(const Value: IPumpCharSel);
    procedure SetIDWarM(const Value: string);
    procedure SetWarM_Ustalone(const Value: Boolean);
  protected
    FPompa    : TFizPompa;
    FIntf     : TPumpInterface;
    FCharData : TPompCharData;

    procedure Loaded;                               override;
    procedure DefineProperties(Filer :TFiler);      override;
    function  CzyWczytacKomponent( C :TComponent ): Boolean;   override;


    procedure ReadDB(strm: TStream);
    procedure WriteDB(strm: TStream);
    function  HasDB :Boolean;

    procedure LoadFromDB( ADB :TDBPompy ); virtual; // wyolywane
                                                    // przez konstruktor

    function  GetName:  string;            virtual;
    function  GetID1:   string;            virtual;
    function  GetQn:    Extended;          virtual;
    procedure SetQn(    AQ:    Extended ); virtual;
    function  GetHn:    Extended;          virtual;
    procedure SetHn(    AH:    Extended ); virtual;
    function  GetPn:    Extended;          virtual;
    procedure SetPn(    AP:    Extended ); virtual;
    function  GetETAn:    Extended;        virtual;
    procedure SetETAn(  AEta:  Extended ); virtual;
    function  GetNPSHn: Extended;          virtual;
    procedure SetNPSHn( ANpsh: Extended ); virtual;
    function  GetMinQ:    Extended;        virtual;
    procedure SetMinQ(  AQ:    Extended ); virtual;
    function  GetMaxQ:    Extended;        virtual;
    procedure SetMaxQ(  AQ:    Extended ); virtual;
    function  GetCharMinQ:    Extended;        virtual;
    procedure SetCharMinQ(  AQ:    Extended ); virtual;
    function  GetCharMaxQ:    Extended;        virtual;
    procedure SetCharMaxQ(  AQ:    Extended ); virtual;
    function  GetPrice    :Double;
    procedure SetPrice( v :Double );
    function  GetMass     :Double;
    procedure SetMass ( v :Double );
    function  GetN        :Integer;
    procedure SetN    ( v :Integer );
    function  GetMaxZast: integer;         virtual;
    function  GetLZastAt( pos: integer ): Boolean; virtual;
    function  GetSZastAt( pos: integer ): string;  virtual;
    function  GetSZastos : string;  virtual;
    function  GetSKonstr : string;  virtual;
    function  GetMoznaObroty: Boolean;
    function  GetMoznaStoczyc: Boolean;
    function  GetMoznaCieczPrzel: Boolean;
    function  GetJestEtaAgr: Boolean;              virtual;
    function  StoredIDWarM :Boolean;
    procedure UstalM;

    procedure CreateInterface;                    virtual;
  public
    Producent: TProducent;

    function  MakeCopy :TPompa;                   virtual;
    procedure AddToUserBase;

    function  IsDB     : Boolean; virtual;  //Czy fizyczna, czy w bazie
    function  IsFiz    : Boolean; virtual;  //Czy fizyczna, czy w bazie
    function  WorkPoint( Char :IPumpCharSel; var Qr, Hr :Double ): Boolean;
                                             virtual;

    function H(    Q: Extended ): Extended;
    function P(    Q: Extended ): Extended;
    function Eta(  Q: Extended ): Extended;
    function NPSH( Q: Extended ): Extended;
    // tu dodac EtaAgr
    // ty dodac P1

    function  Q_od_H( AH :Double ) :Double;                   overload;
    function  Q_od_H( AH :Double; var OK :Boolean ) :Double;  overload;

    function EtaAgr( Q: Double ): Double;
    function EtaSilNom : Double;

    procedure DBCreateCopy( ADB :TDBPompy );      virtual;
    procedure UpdateDB;                           virtual;

    procedure ExportToEpanetFile( const FN :string; const CharId :string;
                                  Cnt :Integer );


    function  GetInterface     :IPump;
    function  GetCharData      :TPompCharData;
    function  CreateCharDataDB( O :TComponent )   :TPompCharData; virtual;
    function  MoznaPrzelMet( const MetId :string ) :Boolean;

    function  GetZdjecie :TPicture;

    property DB: TDBPompy read FDB;
    property Nazwa: string   read GetName write SetName;
    property ID1: string   read GetID1;
    property CharSel   :IPumpCharSel read FCharSel write SetCharSel;


    property Qn:    Extended read GetQn    write SetQn;
    property Hn:    Extended read GetHn    write SetHn;
    property Pn:    Extended read GetPn    write SetPn;
    property ETAn:  Extended read GetEtan  write SetEtan;
    property NPSHn: Extended read GetNPSHn write SetNPSHn;
    property QMin:  Extended read GetMinQ  write SetMinQ;
    property QMax:  Extended read GetMaxQ  write SetMaxQ;

    property CharQMin  :Extended read GetCharMinQ  write SetCharMinQ;
    property CharQMax  :Extended read GetCharMaxQ  write SetCharMaxQ;
    property Cena      :Double   read GetPrice     write SetPrice;
    property Masa      :Double   read GetMass      write SetMass;
    property N         :Integer  read GetN         write SetN;


    property ZastMaxNum: integer read GetMaxZast;
    property LogZast [ pos: integer ]: Boolean read GetLZastAt;
    property StrZast [ pos: integer ]: string  read GetSZastAt;
    property StrZastos               : string  read GetSZastos;
    property StrKonstr               : string  read GetSKonstr;
    property JestWBazie :Boolean    read FWBazie write FWBazie;

    property MoznaStoczyc :Boolean read GetMoznaStoczyc;
    property MoznaObroty  :Boolean read GetMoznaObroty;
    property MoznaCieczPrzel :Boolean read GetMoznaCieczPrzel;
    property MoznaLepPrzel :Boolean read GetMoznaLepPrzel;
    property MoznaRoPrzel :Boolean read GetMoznaRoPrzel;
    property ImageIndex :Integer read FImageIndex write SetImageIndex;
    property JestEtaAgr :Boolean read GetJestEtaAgr;
    property ObszFieldName :string read FObszFieldName;

  published

    property WorkParam :TPompWorkParam read FWorkParam write SetWorkParam;
    property WDobroci : Double read FWDobroci write FWDobroci;
    property Qr       : Double read FQr       write FQr;
    property Hr       : Double read FHr       write FHr;
    property Pr       : Double read FPr       write FPr;
    property NPSHr    : Double read FNPSHr    write FNPSHr;
    property ETAr     : Double read FETAr write SetETAr;
    property ParObliczone :Boolean read FParObliczone write SetParObliczone;

    property IDWarM :string read FIDWarM write SetIDWarM stored StoredIDWarM;
    property WarM_Ustalone :Boolean read FWarM_Ustalone write SetWarM_Ustalone;
  end;

  TPompaClass = class of TPompa;

{---------------------------------------------------------------------------}
function UtworzPompe( DB: TDBPompy; styl: TStylPompy ): TPompa;


{---------------------------------------------------------------------------}
procedure RegisterCharData( const id :string; ClassRef :TPompCharDataClass );
function  CreateCharData( const id :string; owner :TComponent ) :TPompCharData;

procedure RegisterPompClass( const id :string; ClassRef :TPompaClass );
function  CreatePump( Owner :TComponent;
                      DB :TDBPompy ) :TPompa;

//const
var
  CLiczbaPomp    :Integer = 0;


{=============================================================================}
implementation

uses
  FPompy;


var
  CharClassList :TStringList;
  PompClassList :TStringList;
//const
//  CLiczbaPomp    :Integer = 0;

function UtworzPompe( DB: TDBPompy; styl: TStylPompy ): TPompa;
begin
  case styl of
    spWBazie:
      UtworzPompe := TPompa.StworzWBazie( DB );
    spFizyczna:
      UtworzPompe := TPompa.WczytajZBazy( DB );
  else
    {ERROR}
    UtworzPompe := NIL;
  end;
end;

procedure InitPompClassList;
begin
  if PompClassList = NIL then
    PompClassList := TStringList.Create;
end;


procedure RegisterPompClass( const id :string; ClassRef :TPompaClass );
begin
  InitPompClassList;
  PompClassList.AddObject( id, TObject(ClassRef) );
end;

function  CreatePump( Owner :TComponent;
                      DB :TDBPompy ) :TPompa;
var
  id      :string;
  ref     :TPompaClass;
  pos     :Integer;
begin
  result := NIL;
  DB.Update;
  id := DB.A.FieldByName('Obj_Id').AsString;
  pos := PompClassList.IndexOf( id );
  if pos >= 0 then
  begin
    ref := TPompaClass(PompClassList.Objects[pos]);
    result := ref.CreateWithOwner( DB, Owner );
  end
  else
  begin
    if id = '' then
      result := TPompa.CreateWithOwner( DB, Owner );
  end;
end;

procedure InitCharClassList;
begin
  if CharClassList = NIL then
    CharClassList := TStringList.Create;
end;


procedure RegisterCharData( const id :string; ClassRef :TPompCharDataClass );
begin
  InitCharClassList;
  CharClassList.AddObject( id, TObject(ClassRef) );
end;

function  CreateCharData( const id :string; owner :TComponent ) :TPompCharData;
var
  ref     :TPompCharDataClass;
  pos     :Integer;
begin

  result := NIL;
  pos := CharClassList.IndexOf( id );
  if pos >= 0 then
  begin
    ref := TPompCharDataClass(CharClassList.Objects[pos]);
    result := ref.Create( owner );
  end;
end;




{ TPompa }

constructor TPompa.StworzWBazie( ADB: TDBPompy );
begin
  inherited Create( ADB );
  Init;
  FDB := ADB;
  Producent := ADB.Producent;
  FWBazie := true;
end;


constructor TPompa.WczytajZBazy( ADB: TDBPompy );
begin
  inherited Create( NIL );
  Init;
  FPompa := TFizPompa.Create( ADB );

  FCharData := CreateCharData( ADB.H.FieldByName('H_MET').AsString,
                               self );
  if FCharData <> NIL then
  begin
    FCharData.ReadFromHTable(ADB.H);
    FCHarData.Pompa := self;
  end;
  {za duzo czasu zajmuje ta instrukcja}
  {FDB   := ADB.MakeCopy( self );}

  // Jesli pompa ma zostac, a przechodzimy do innego rekordu
  // trzeba zrobic kopie bazy
  FDB := ADB;

  Producent := ADB.Producent;
  FWBazie := false;
end;


constructor TPompa.CreateWithOwner( ADB: TDBPompy;
                                    O :TComponent );
begin
  inherited Create( O );
  Init;
  Producent := ADB.Producent;
  LoadFromDB( ADB );
  FWBazie := false;
end;

constructor TPompa.Create(O: TComponent);
begin
  inherited;
  Init;
end;


destructor  TPompa.Destroy;
begin
  dec(CLiczbaPomp);
  FPompa.Free;
  if FIntf <> NIL then
    if {(FIntf.FRefCount <= 0) and} (not FIntf.Destroyed) then
    begin
      FIntf.FPump := NIL;
      FIntf.Free;
    end;
  CharSel.Free;

  inherited Destroy;
end;

procedure TPompa.LoadFromDB( ADB :TDBPompy );
begin
  FObszFieldName := ADB.BaseInfo.ObszFieldName;
  if FPompa = NIL then
    FPompa := TFizPompa.Create( ADB );

  FDB   := ADB;
  FCharData := CreateCharDataDB( self );
  if FCharData <> NIL then
  begin
    FCharData.ReadFromHTable(ADB.H);  //wylaczyc ???
    FCHarData.Pompa := self;
  end;
end;


procedure TPompa.DBCreateCopy( ADB :TDBPompy );
begin
  FDB   := ADB.MakeCopy( self );

  // Czy to ma tak byc
  FDB.Name := 'DB';

  FWBazie := false;
end;


function    TPompa.IsDB: Boolean;
begin
  IsDB := (FDB <> NIL) {and (FIsDB)};
end;


function  TPompa.IsFiz    : Boolean;
begin
  result := FPompa <> NIL;
end;


function  TPompa.GetName:  string;
begin
  if not IsFiz then
    result := FDB.A.FieldByName('NAZWA').AsString
  else
    result := FPompa.Nazwa;
end;

procedure TPompa.SetName(const Value: string);
begin
  if not IsFiz then
    FDB.A.FieldByName('NAZWA').AsString := Value
  else
    FPompa.Nazwa := Value;
end;



function  TPompa.GetQn:    Extended;
begin
  if not IsFiz then
    GetQn := FDB.A.FieldByName('Qn').AsFloat
  else
    GetQn := FPompa.Qn;
end;

procedure TPompa.SetQn(    AQ:    Extended );
begin
  if not IsFiz then
    FDB.A.FieldByName('Qn').AsFloat := AQ
  else
    FPompa.Qn := AQ;
end;

function  TPompa.GetHn:    Extended;
begin
  if not IsFiz then
    GetHn := FDB.A.FieldByName('Hn').AsFloat
  else
    GetHn := FPompa.Hn;
end;

procedure TPompa.SetHn(    AH:    Extended );
begin
  if not IsFiz then
    FDB.A.FieldByName('Hn').AsFloat := AH
  else
    FPompa.Hn := AH;
end;

function  TPompa.GetPn:    Extended;
begin
  if not IsFiz then
    GetPn := FDB.A.FieldByName('Pn').AsFloat
  else
    GetPn := FPompa.Pn;
end;

procedure TPompa.SetPn(    AP:    Extended );
begin
  if not IsFiz then
    FDB.A.FieldByName('Pn').AsFloat := AP
  else
    FPompa.Pn := AP;
end;

function  TPompa.GetETAn:    Extended;
begin
  if not IsFiz then  //Tego chyba nie ma
    GetETAn := FDB.A.FieldByName('ETAn').AsFloat
  else
    GetETAn := FPompa.ETAn;
end;

procedure TPompa.SetETAn(  AEta:  Extended );
begin
  if not IsFiz then
    FDB.A.FieldByName('ETAn').AsFloat := AETA
  else
    FPompa.ETAn := AEta;
end;

function  TPompa.GetNPSHn: Extended;
begin
  if not IsFiz then
    GetNPSHn := FDB.A.FieldByName('NPSHn').AsFloat
  else
    GetNPSHn := FPompa.NPSHn;
end;

procedure TPompa.SetNPSHn( ANpsh: Extended );
begin
  if not IsFiz then
    FDB.A.FieldByName('NPSHn').AsFloat := ANpsh
  else
    FPompa.NPSHn := ANpsh;
end;

function  TPompa.GetMinQ:    Extended;
begin
  if not IsFiz then
    result := FDB.A.FieldByName('QMin').AsFloat
  else
    result := FPompa.QMin;
end;


procedure TPompa.SetMinQ(  AQ:    Extended );
begin
  if not IsFiz then
    FDB.A.FieldByName('QMin').AsFloat := AQ
  else
    FPompa.QMin := AQ;
end;


function  TPompa.GetMaxQ:    Extended;
begin
  if not IsFiz then
    result := FDB.A.FieldByName('QMax').AsFloat
  else
    result := FPompa.QMax;
end;


procedure TPompa.SetMaxQ(  AQ:    Extended );
begin
  if not IsFiz then
    FDB.A.FieldByName('QMax').AsFloat := AQ
  else
    FPompa.QMax := AQ;
end;

function  TPompa.GetCharMinQ:    Extended;
begin
  if not IsFiz then
    result := FDB.H.FieldByName('H_QMin').AsFloat
  else
    result := FPompa.CharQMin;
end;


procedure TPompa.SetCharMinQ(  AQ:    Extended );
begin
  if not IsFiz then
    FDB.H.FieldByName('H_QMin').AsFloat := AQ
  else
    FPompa.CharQMin := AQ;
end;


function  TPompa.GetCharMaxQ:    Extended;
begin
  if not IsFiz then
    result := FDB.H.FieldByName('H_QMax').AsFloat
  else
    result := FPompa.CharQMax;
end;


procedure TPompa.SetCharMaxQ(  AQ:    Extended );
begin
  if not IsFiz then
    FDB.H.FieldByName('H_QMax').AsFloat := AQ
  else
    FPompa.CharQMax := AQ;
end;

function  TPompa.GetPrice    :Double;
begin
  if not IsFiz then
    result := FDB.A.FieldByName('CENA').AsFloat
  else
    result := FPompa.Cena;
end;

procedure TPompa.SetPrice( v :Double );
begin
  if not IsFiz then
    FDB.A.FieldByName('CENA').AsFloat := v
  else
    FPompa.Cena := v;
end;

function  TPompa.GetMass     :Double;
begin
  if not IsFiz then
    result := FDB.G.FieldByName('MASA').AsFloat
  else
    result := FPompa.Masa;
end;

procedure TPompa.SetMass ( v :Double );
begin
  if not IsFiz then
    FDB.A.FieldByName('MASA').AsFloat := v
  else
    FPompa.Masa := v;
end;

function  TPompa.GetN     :Integer;
begin
  if not IsFiz then
    result := FDB.A.FieldByName('N').AsInteger
  else
    result := FPompa.N;
end;

procedure TPompa.SetN ( v :Integer );
begin
  if not IsFiz then
    FDB.A.FieldByName('N').AsInteger := v
  else
    FPompa.N := v;
end;

function  TPompa.WorkPoint( Char :IPumpCharSel;
                                    var Qr, Hr :Double ): Boolean;
var
  cd      :TPompCharData;
  Created :Boolean;
begin
  cd := GetCharData;
  Created := (cd = NIL);
  if Created then
  begin
    cd    := CreateCharDataDB(self);
    if cd <> NIL then
      cd.Pompa := self;
  end;
  if cd <> NIL then
    result := cd.WorkPoint( Char, Qr, Hr )
  else
    result := false;
  if Created then
    cd.Free;
end;



procedure TPompa.CreateInterface;
begin
  FIntf := TPumpInterface.Create;
  FIntf.FPump := self;
end;

function  TPompa.GetInterface;
begin
  if not JestWBazie then
  begin
    if FIntf = NIL then
      CreateInterface;
    {FIntf.AddRef;}
  end;

  result := FIntf;
end;

function  TPompa.GetCharData      :TPompCharData;
begin
  result := FCharData;
end;

var
  cHRecNo :Integer;
  cHID    :string;

function  TPompa.CreateCharDataDB( O :TComponent ) :TPompCharData;
begin
  result := NIL;
  if IsDB then
  begin
    cHID := DB.H.FieldByName('H_ID').AsString;
    cHRecNo := DB.H.RecNo;
    result := CreateCharData( DB.H.FieldByName('H_MET').AsString, o );
    if result <> NIL then
      result.ReadFromHTable(DB.H);
  end;
end;

function TPompa.Q_od_H(AH: Double): Double;
begin
  if FCharData is TFuncCharData then
    result := TFuncCharData(FCharData).Q_od_H(AH)
  else
    result := 0;
end;

function TPompa.Q_od_H(AH: Double; var OK: Boolean): Double;
begin
  if FCharData is TFuncCharData then
    result := TFuncCharData(FCharData).Q_od_H(AH,OK)
  else
  begin
    result := 0;
    OK := false;
  end;

end;


function TPompa.H(    Q: Extended ): Extended;
begin
  if FCharData is TFuncCharData then
    result := TFuncCharData(FCharData).H(Q)
  else
    result := 0;
end;

function TPompa.P(    Q: Extended ): Extended;
begin
  if FCharData is TFuncCharData then
    result := TFuncCharData(FCharData).P(Q)
  else
    result := 0;
end;

function TPompa.Eta(  Q: Extended ): Extended;
begin
  if FCharData is TFuncCharData then
    result := TFuncCharData(FCharData).Eta(Q)
  else
    result := 0;
end;

function TPompa.NPSH( Q: Extended ): Extended;
begin
  if FCharData is TFuncCharData then
    result := TFuncCharData(FCharData).NPSH(Q)
  else
    result := 0;
end;


function  TPompa.GetMaxZast: integer;
begin
  GetMaxZast := 50;
end;


function  TPompa.GetLZastAt( pos: integer ): Boolean;
var
  flKlucz    : Extended;
  cmKlucz    : Comp;
  setKlucz   : set of 1..50 absolute cmKlucz;
  arrKlucz   : array [0..sizeOf(cmKlucz)-1] of byte absolute cmKlucz;
begin
  if IsDB then
  begin
    flKlucz := FDB.A.FieldByName('KLUCZ').AsFloat;
    cmKlucz := flKlucz;
  end
  else
  begin

  end;

  GetLZastAt := (pos-1) in setKlucz;

end;


function  TPompa.GetSZastAt( pos: integer ): string;
begin
  GetSZastAt := DajText( Zast_txt+pos );
end;

function TPompa.GetSKonstr: string;
begin
  result := DB.T.FieldByName('KONSTR').AsString;
end;

function  TPompa.GetSZastos: string;
begin
  GetSZastos := DB.T.FieldByName('Kl_ZAST').AsString;
end;


procedure TPompa.SetWorkParam(const Value: TPompWorkParam);
begin
  FWorkParam.Free;
  FWorkParam := Value;
  if FWorkParam <> NIL then
    FWorkParam.Name := 'WorkParam';
end;

function TPompa.GetMoznaObroty: Boolean;
begin
  result := MoznaPrzelMet('n')
            and (FCharData <> NIL) and (FCharData.MoznaObroty);
end;

function TPompa.GetMoznaStoczyc: Boolean;
begin
  result := MoznaPrzelMet('d2')
            and (FCharData <> NIL)
             and (FCharData.Srednica > 0);
end;

function TPompa.GetMoznaCieczPrzel: Boolean;
begin
  result := MoznaLepPrzel or MoznaRoPrzel;
end;

procedure TPompa.Loaded;
begin
  inherited;
  if WarM_Ustalone then
    UstalM;
end;


procedure TPompa.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty( 'DB', ReadDB, WriteDB, HasDB );
end;

function TPompa.HasDB: Boolean;
begin
  result := (DB <> NIL) and (DB is TDBPompyCopy);
end;

procedure TPompa.ReadDB(strm: TStream);
var
  Comp    :TComponent;
begin
  Comp := strm.ReadComponent(NIL);
  FDB := Comp as TDBPompy;
  Producent := FDB.Producent;
  if FDB <> NIL then
    LoadFromDB(FDB);
end;

procedure TPompa.WriteDB(strm: TStream);
begin
  strm.WriteComponent(DB);
end;

procedure TPompa.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
end;

procedure TPompa.Init;
begin
  FImageIndex := -1;
  inc(CLiczbaPomp);
end;

function TPompa.GetZdjecie: TPicture;
var
  cn     :string;
  strm   :TStream;
begin
  result := NIL;
  if (DB = NIL) or (not DB.tOK) or (not DB.bOK) then
    EXIT;
  if DB.B.Locate( 'ID', DB.T.FieldValues['ZDJECIE'], [] ) then
  begin
    cn := DB.B.FieldByName('CLASSNAME').AsString;
    if (cn = '.BMP') or (cn = '.JPG') then
    begin
      result := TPicture.Create;
      strm := TBlobStream.Create( DB.B.FieldByName('DATA') as TBlobField,
                                  bmRead );
      if cn = '.BMP' then
      begin
        result.Bitmap.LoadFromStream(strm);
      end
      else if cn = '.JPG' then
      begin
        result.Graphic := TJPEGImage.Create;
        result.Graphic.LoadFromStream(strm);
      end;
    end;
  end;
end;

function TPompa.MakeCopy: TPompa;
begin
  result := CreatePump( NIL, DB );
  result.DBCreateCopy(DB);
end;

procedure TPompa.AddRef;
begin
  GetInterface.AddRef;
end;

procedure TPompa.Release;
begin
  GetInterface.Release;
end;

procedure TPompa.UpdateDB;
begin
  if not IsDB then
    EXIT;
  if (FCharData <> NIL) and (DB.hOK) then
    FCharData.WriteToHTable(DB.H);
  if FPompa <> NIL then with FPompa do
  begin
    DB.A.FieldByName('Nazwa').AsString := Nazwa;
    DB.A.FieldByName('Qn').AsFloat    := Qn;
    DB.A.FieldByName('Hn').AsFloat    := Hn;

    DB.A.FieldByName('Pn').AsFloat    := Pn;

    DB.A.FieldByName('Qmin').AsFloat  := QMin;
    DB.A.FieldByName('Qmax').AsFloat  := QMax;
    DB.A.FieldByName('Cena').AsFloat  := Cena;
    //if DB.gOK then
    //  DB.G.FieldByName('Masa').AsFloat  := Masa;
    DB.A.FieldByName('N').AsInteger     := N;
  end;

end;



procedure TPompa.AddToUserBase;
var
  usrp    :TProducent;
  udb     :TDBPompy;
  tId     :string;
begin
  UpdateDB;    // to jest lokalna kopia rekordu bazy dlatego moge
  usrp := Producenci.ProdByName('USER');
  if usrp = NIL then
    raise Exception.Create('Brak bazy uzytkownika');
  if not usrp.BazyDost['PUMPS'] then
    raise Exception.Create('Brak bazy uzytkownika');

  udb := TDBPompy.CreateForProd( self, usrp );
  try
    if udb.A.Locate( 'NAZWA', Nazwa, [] ) then
      raise EDBNameDuplError.CreateFmt( 'W bazie isntieje pompa o nazwie %s',
                                        [Nazwa] );
    CopyRecord( DB.A, udb.A );
    tId := DB.A.FieldByName('TYP_ID').AsString;
    if (pos( '~', 'tId' ) = 0) and (producent <> usrp) then
      tId := Format( '%s~%s', [Producent.Ident, tId] );
    udb.A.Edit;
    udb.A.FieldByName('TYP_ID').AsString := tId;
    udb.A.FieldByName('H_ID').AsString := Nazwa;
    if DB.tOk and udb.tOk and (not udb.T.Locate('TYP_ID', tId, [])) then
    begin
      udb.T.Append;
      udb.T.FieldByName('TYP_ID').AsString := tId;
      udb.T.Post;
      CopyRecordExc( DB.T, udb.T, false, 'TYP_ID' );
    end;
    udb.H.Append;
    udb.H.FieldByName('H_ID').AsString := Nazwa;
    udb.H.Post;
    CopyRecordExc( DB.H, udb.H, false, 'H_ID' );
    //udb.H.Post;
    udb.A.Post;
  finally
    udb.Free;
  end;

end;

procedure TPompa.SetParObliczone(const Value: Boolean);
begin
  FParObliczone := Value;
end;

procedure TPompa.SetETAr(const Value: Double);
begin
  FETAr := Value;
end;

//================================//
//  Nominalna sprawnosc silnika   //
//================================//
function TPompa.EtaSilNom: Double;

  function Fld(const AName :string) :Double;
  begin
    result := DB.M.FieldByName(AName).AsFloat;
  end;

begin
  try  //!! do polaczenia w jedna procedure
    if Fld('NAP')<300
      then result := F_DIV( Fld('M_PZn')*1000, Fld('NAP')*Fld('PRAD')*Fld('CosF') )
      else result := F_DIV( Fld('M_PZn')*1000, sqrt(3)*Fld('NAP')*Fld('PRAD')*Fld('CosF') );
  except
    on EMathError do
      result := 0;
  end;
end;

function TPompa.EtaAgr(Q: Double): Double;
begin
  if (DB.H.FieldByName('P_MET') <> nil) and
     (DB.H.FieldByName('P_MET').AsString = 'P1') then
    result := Eta(Q)* EtaSilNom
  else
    result := Eta(Q);
end;

function TPompa.GetJestEtaAgr: Boolean;
  function Fld(const AName :string) :Double;
  begin
    result := DB.M.FieldByName(AName).AsFloat;
  end;

begin
  result := (FCharData is TFuncCharData)
            and DB.mOK
            and (DB.M.FieldByName('M_ID').AsString <> '');
  if result then
  begin
    result := (Fld('PRAD') > 0)
              and (Fld('NAP') > 0)
              and (Fld('CosF') <> 0)

  end;

end;





function TPompa.CzyWczytacKomponent(C: TComponent): Boolean;
begin
  if C = FDB then
    result := false     // Wczytywane w DefineProperties
  else
    result := inherited CzyWczytacKomponent(C);
end;

procedure TPompa.SetCharSel(const Value: IPumpCharSel);
begin
  if FCharSel <> Value then
  begin
    if FCharSel <> NIL then
      FCharSel.Release;
    FCharSel := Value;
    if FCharSel <> NIL then
      FCharSel.AddRef;
  end;
end;

{
function TPompa.CreateForm(AOwner: TComponent; AMDIChild: Boolean): TForm;
var
  F      :TFormPompy;
begin
  F := TFormPompy.StworzDlaPompy( AOwner, self, AMDIChild );
  result := F;
end;
}


procedure TPompa.SetIDWarM(const Value: string);
begin
  FIDWarM := Value;
  if (([csLoading, csReading] * ComponentState) = []) then
    UstalM;
end;

procedure TPompa.SetWarM_Ustalone(const Value: Boolean);
begin
  FWarM_Ustalone := Value;
  if (([csLoading, csReading] * ComponentState) = []) then
    UstalM;
end;

function TPompa.StoredIDWarM: Boolean;
begin
  Result := (DB is TDBPompyCopy)
            and DB.SaWarianty and DB.RecWarM
            and WarM_Ustalone;

end;

procedure TPompa.UstalM;
begin
  if (IDWarM <> '') and (WarM_Ustalone) then
  begin
    DB.M.Filter := Format('M_ID = ''%s''', [IDWarM] );
    DB.M.Filtered := true;
  end
  else
  begin
    DB.M.Filter := '';
    DB.M.Filtered := false;
  end;
end;

procedure TPompa.ExportToEpanetFile(const FN, CharId: string;
  Cnt: Integer);
var
  F       :TextFile;
  i       :Integer;
  aq       :Double;
begin
  AssignFile( F, FN );
  Rewrite( F );
  try
    Writeln( F, 'EPANET Curve Data' );
    Writeln( F, 'PUMP' );
    if CharId = 'H' then
      Writeln( F, Format( 'Charakterystyka przeplywu pompy "%s"', [Nazwa]) )
    else if CharId = 'ETA' then
      Writeln( F, Format( 'Charakterystyka sprawnosci pompy "%s"', [Nazwa]) )
    else
      Writeln( F );

    for i := 0 to Cnt-1 do
    begin
      aq := Lin( i, 0, Cnt-1, CharQMin, CharQMax );
      Write( F, aq : 0 : 3, '  ' );
      if CharId = 'H' then
        Writeln( F, H(aq) : 0 : 3 )
      else if CharId = 'ETA' then
        Writeln( F, Eta(aq) : 0 : 3 )
    end;
  finally
    CloseFile(F);
  end;
end;


function TPompa.GetID1: string;
begin
  try
    result := FDB.A.FieldByName('ID1').AsString;
  except
    raise ePDP_BladPliku.Create('B³¹d odczytu identyfikatora pompy');
  end;
end;

{ TFizPompa }

constructor TFizPompa.Create( ADB: TDBPompy );
begin
  inherited Create;
  Nazwa := ADB.A.FieldByName('Nazwa').AsString;
  Qn    := ADB.A.FieldByName('Qn').AsFloat;
  Hn    := ADB.A.FieldByName('Hn').AsFloat;

  Pn    := ADB.A.FieldByName('Pn').AsFloat;
  {ETAn  := ADB.A.FieldByName('Qn').AsFloat;}
  {NPSHn: Extended;}
  QMin  := ADB.A.FieldByName('Qmin').AsFloat;
  QMax  := ADB.A.FieldByName('Qmax').AsFloat;
  CharQMin  := ADB.H.FieldByName('H_Qmin').AsFloat;
  CharQMax  := ADB.H.FieldByName('H_Qmax').AsFloat;
  Cena  := ADB.A.FieldByName('Cena').AsFloat;
  if ADB.gOK then
    Masa  := ADB.G.FieldByName('Masa').AsFloat;
  N     := ADB.A.FieldByName('N').AsInteger;
end;

constructor TFizPompa.Create;
begin
  inherited;
end;





{============================================================================
  CLASS TPumpInterface (inherite from IPump)
---------------------------------------}

{ TPumpInterface }

destructor TPumpInterface.Destroy;
begin
  Destroyed := true;
  if (FPump <> NIL) and (FPump.Owner = NIL) then
    FPump.Free;
  inherited Destroy;
end;

(*
{---------------------------------------------------------------------------}
function TPumpInterface.Release :Longint;
begin
  Dec(FRefCount);
  if FRefCount < 1 then
  begin
    Destroy;
  end;
end;
*)


function  TPumpInterface.GetVersion :Integer;
begin
  result := $04040000;
end;

procedure TPumpInterface.GetName( AName :PChar; AMax :Integer );
begin
  { DO POPRAWY: wprowadzic ograniczenie dlugosci }
  StrPCopy( AName, FPump.Nazwa );
end;

function  TPumpInterface.GetQMin  :Double;
begin
  result := FPump.QMin;
end;

function  TPumpInterface.GetQMax  :Double;
begin
  result := FPump.QMax;
end;

function  TPumpInterface.GetHMin  :Double;
begin
  result := 0;
end;

function  TPumpInterface.GetHMax  :Double;
begin
  result := 0;
end;


function  TPumpInterface.GetQn    :Double;
begin
  result := FPump.Qn;
end;

function  TPumpInterface.GetHn    :Double;
begin
  result := FPump.Hn;
end;

function  TPumpInterface.GetPn    :Double;
begin
  result := FPump.Pn;
end;


function  TPumpInterface.WorkPoint( Char :IPumpCharSel;
                                    var Qr, Hr :Double ): Boolean;
var
  cd      :TPompCharData;
begin
  cd     := FPump.GetCharData;
  if cd <> NIL then
    result := cd.WorkPoint( Char, Qr, Hr )
  else
    result := false;
end;



{ TCharDataDiagFun }

constructor TCharDataDiagFun.Create( O :TComponent );
begin
  inherited Create( O );
end;

procedure TCharDataDiagFun.SetMaxYR( v :Double );
begin
  FMaxYR := v;
  inherited SetMaxYR(v);
end;

procedure TCharDataDiagFun.SetHolder( v :TDiagFunction );
begin
  inherited SetHolder(v);
  inherited SetMaxYR(FMaxYR);
end;


procedure TCharDataDiagFun.DrawFPub(dt: TSpecDrawData; bw: Boolean);
begin
  DrawFun( dt, bw );
end;

{ TPompCharData }

function TPompCharData.CreateCopyInstance( O :TComponent ) : TPompCharData;
var
  cc     :TPompCharDataClass;
begin
  cc := TPompCharDataClass(self.ClassType);
  result := cc.Create(O);
end;

function TPompCharData.GetCS: string;
begin
  result := ClassName;
end;

function TPompCharData.GetObrotyOPompa: Double;
begin
  if Pompa <> NIL then
    result := Pompa.N
  else
    result := 0;
end;

function TPompCharData.MakeCopy( O :TComponent ) :TPompCharData;
begin
  result := CreateCopyInstance(O);
  InitCopyInstance(result);
end;

function TPompa.MoznaPrzelMet(const MetId: string): Boolean;
begin
  result := false;
  if DB.tOK then
  try
    result := StrInSet( MetId, DB.T.FieldByName('PRZELICZ').AsString );
  except on EDatabaseError do
    result := false;
  end;
end;

function TPompa.GetMoznaLepPrzel: Boolean;
begin
  result := MoznaPrzelMet('NY') or MoznaPrzelMet('SK');
end;

function TPompa.GetMoznaRoPrzel: Boolean;
begin
  result := MoznaPrzelMet('ro');
end;



function TPompCharData.MoznaObroty: Boolean;
begin
  result := false;
end;


{ TFuncCharData }

{===========================================================================
|  CLASS TFuncCharData
|
|  Dane funkcyjnej charakterystyki pompy
|    tzn. takiej, ze istnieje funkcja H(Q)
|    oraz opcjonalnie P(Q), NPSH(Q), ETA(Q)
============================================================================}

function  TFuncCharData.WorkPoint( Sel :IPumpCharSel;
                                   var Qr, Hr :Double ) :Boolean;

function DelH( Q :Double ) :Double;
begin
  result := Sel.dH(Q) - self.H(Q);
end;

var
  min, max :Double;
  vQ, vH   :Double;
  vHMin    :Double;
  vHMax    :Double;

begin

  Qr := 0;
  Hr := 0;

  min := GetCharQMin;
  max := GetCharQMax;

  vQ  := (max + min) / 2;
  vHMin := DelH( min );
  vHMax := DelH( max );

  while ((vHMin*vHMax) < 0) and ((max-min) > 0.001) do
  begin
    vQ  := (max + min) / 2;
    vH  := DelH(vQ);
    if (vH*vHMin) > 0 then
    begin
      min   := vQ;
      vHMin := vH;
    end
    else
    begin
      max   := vQ;
      vHMax := vH;
    end;
  end;

  if ((vHMin*vHMax) < 0) then
  begin
    Qr := vQ;
    Hr := H(vQ);
    result := true;
  end
  else
    result := false;

end;


function  TFuncCharData.GetDiagFun( id :string;
                     Owner :TDiagFunction ):TCharDataDiagFun;
var
  r         :TFuncDiagFun;        // result
begin
  r := NIL;
  if id = 'H' then
  begin
    r := THFuncDiagFun.Create(Owner);
    Owner.Drawer := r;
    r.Bolded := true;
    r.CountMaxYR( CharHMax );
    r.Legend := true;
    r.LegText := 'H';
    r.SetLegQ([0.2]);
  end
  else if id = 'P' then
  begin
// zamiana charakterstyk jak do bazy jest wpisania P1 zamiast P2
    if (Pompa.DB.H.FieldByName('P_MET') <> nil) and
       (Pompa.DB.H.FieldByName('P_MET').AsString = 'P1') then
      r := TP1FuncDiagFun.Create(Owner)
    else
      r := TPFuncDiagFun.Create(Owner);

    r.LegText := 'P2';
    Owner.Drawer := r;
    r.Bolded := true;
    r.CountMaxYR( CharPMax );
    r.Legend := true;
    r.SetLegQ([1]);
  end
  else if (id = 'NPSH') and (FCharNPSHMax > 0) then
  begin
    r := TNPSHFuncDiagFun.Create(Owner);
    Owner.Drawer := r;
    r.Bolded := false;
    r.CountMaxYR( CharNPSHMax );
    r.Legend := true;
    r.LegText := 'NPSH';
    r.SetLegQ([0.4]);
  end
  else if id = 'ETA' then
  begin
    r := TETAFuncDiagFun.Create(Owner);
    Owner.Drawer := r;
    r.Bolded := false;
    r.MaxYR  := 1;
    r.Legend := true;
    r.LegText := 'ETA';
    r.SetLegQ([0.6]);
  end
  // MS 060323 dodana charakterystyka mocy agregatu
  else if id = 'P1' then
  begin
    if (Pompa.DB.H.FieldByName('P_MET')<>nil) and
       (Pompa.DB.H.FieldByName('P_MET').AsString = 'P1') then
      r := TPFuncDiagFun.Create(Owner)
    else
      r := TP1FuncDiagFun.Create(Owner);

    r.LegText := 'P1';
    Owner.Drawer := r;
    r.Bolded := true;
    r.CountMaxYR( CharP1Max );
    r.Legend := true;
    r.SetLegQ([0.8]);
  end;
  if r <> NIL then
    r.Data := self;
  result := r;
end;


function  TFuncCharData.ETA ( Q :Double ) :Double;
begin
  // na wypadek jak w bazie jest wpisanie P1
  if (Pompa.DB.H.FieldByName('P_MET') <> nil) and
     (Pompa.DB.H.FieldByName('P_MET').AsString = 'P1') then
    result := PompMath.Eta( Q, H(Q), P(Q)*Pompa.EtaSilNom )
  else
    result := PompMath.Eta( Q, H(Q), P(Q) );
end;

function  TFuncCharData.GetQMin  :Double;
begin
  if Pompa <> NIL then
  begin
    result := Pompa.QMin;
  end
  else
  begin
    result := GetCharQMin;
  end;
end;

function  TFuncCharData.GetQMax  :Double;
begin
  if Pompa <> NIL then
  begin
    result := Pompa.QMax;
  end
  else
  begin
    result := GetCharQMax;
  end;
end;


function  TFuncCharData.GetCharQMin  :Double;
begin
  result := FCharQMin;
end;


function  TFuncCharData.GetCharQMax  :Double;
begin
  result := FCharQMax;
end;

function  TFuncCharData.GetHMin  :Double;
begin
  result := 0;
end;

function  TFuncCharData.GetHMax  :Double;
begin
  result := FCharHMax;
end;

function  TFuncCharData.GetCharHMin  :Double;
begin
  result := FCharHMin;
end;

function  TFuncCharData.GetCharHMax  :Double;
begin
  result := FCharHMax;
end;

function TFuncCharData.GetCharNPSHMax: Double;
begin
  result := FCharNPSHMax;
end;

function TFuncCharData.GetCharPMax: Double;
begin
  result := FCharPMax;
end;

function TFuncCharData.GetCharP1Max: Double;
begin
  if (Pompa <> nil) and (Pompa.EtaSilNom <> 0) then
    result := FCharPMax/Pompa.EtaSilNom
  else
    result := FCharPMax;
end;

procedure TFuncCharData.Pomnoz(FakQ, FakH, FakP: Double);
begin                       // do czego ta funkcja
  FCharQMin := FakQ * FCharQMin;
  FCharQMax := FakQ * FCharQMax;
  FCharHMin := FakH * FCharHMin;
  FCharHMax := FakH * FCharHMax;
  FCharPMax := FakP * FCharPMax;
  if Pompa <> NIL then
  begin
    Pompa.Qn := FakQ * Pompa.Qn;
    Pompa.Hn := FakH * Pompa.Hn;
    // Pn ???
    Pompa.QMin := FakQ * Pompa.QMin;
    Pompa.QMax := FakQ * Pompa.QMax;
  end;

end;



procedure TFuncCharData.SetObroty(const Value: Double);
var
  FakQ, FakH, FakP :Double;
begin
  FakQ := (Value/FObroty);
  FakH := FakQ*FakQ;
  FakP := FakQ*FakQ*FakQ;
  FObroty := Value;
  Pomnoz(FakQ, FakH, FakP);
end;

procedure TFuncCharData.SetSrednica(const Value: Double);
var
  FakQ, FakH, FakP :Double;
begin
  FakQ := (Value/FSrednica);
  FakQ := FakQ*FakQ;
  FakH := FakQ;
  FakP := FakQ*FakQ;
  Pomnoz(FakQ, FakH, FakP);
  FSrednica := Value;
end;

function TFuncCharData.GetObroty: Double;
begin
  if FObroty > 0 then
    result := FObroty;
end;

function TFuncCharData.GetSrednica: Double;
begin
  result := FSrednica;
end;

procedure TFuncCharData.ReadFromHTable(HT: TDataSet);
begin
  FSrednica := HT.FieldByName( 'H_D2' ).AsFloat;
  FObroty   := HT.FieldByName( 'H_N' ).AsFloat;
end;

procedure TFuncCharData.WriteToHTable(HT: TDataSet);
begin
  HT.FieldByName( 'H_D2' ).AsFloat := FSrednica;
  HT.FieldByName( 'H_N' ).AsFloat  := FObroty;
end;


function TFuncCharData.MoznaObroty: Boolean;
begin
  result := FObroty <> 0;
end;

function TFuncCharData.Q_od_H(AH: Double): Double;
var
  ok     :Boolean;
begin
  Result := Q_od_H(AH, ok);
end;


function TFuncCharData.Q_od_H( AH :Double; var OK :Boolean ) :Double;

function DelH( q :Double ) :Double;
begin
  result := AH - H(Q);
end;

var
  min, qMax :Double;
  vQ, vH   :Double;
  vHMin    :Double;
  vHMax    :Double;
  eps      :Double;
  i : integer;
begin


  min := GetCharQMin;
  qMax := GetCharQMax;

  vQ  := (qMax + min) / 2;
  vHMin := DelH( min );
  vHMax := DelH( qMax );
  eps := 0.001;
  vH := 1;                  // do pierwszego podstawienie w pêtli

  while ((vHMin*vHMax) < 0) and (abs(vH) > eps) and ((qMax-min) > abs(qMax*0.00000001)) do
  begin
    vQ  := (qMax + min) / 2;
    vH  := DelH(vQ);
    if (vH*vHMin) > 0 then
    begin
      min   := vQ;
      vHMin := vH;
    end
    else
    begin
      qMax   := vQ;
      vHMax := vH;
    end;
    //#KR: 2013-12 Pompy sta³ej mocy
    eps := max (0.001, AH*0.0000001);

  end;

  OK := false;
  if ((vHMin*vHMax) < 0) then
    begin
      result := vQ;
      OK := true;
    end
  else if abs(vHMin) < 0.002 then    // <KR:2002.06.06>
    Result := min                    // sprawdzic czy juz gdzies
  else if abs(vHMax) < 0.002 then    // nie bylo to rozwiazane
    Result := qMax
  else if vHMin < 0 then             // </KR:2002.06.06>
    result := GetCharQMax  //MS 2000-12-08
  else                     //zamiana 0 i GetCharQMax
    result := 0;

end;


{ TFuncDiagFun }

function  TFuncDiagFun.GetData  :TFuncCharData;
begin
  result  := (CharData as TFuncCharData);
end;

procedure TFuncDiagFun.SetData( AData :TFuncCharData );
begin
  CharData := AData;
end;

function TFuncDiagFun.DGetCharQMax: Double;
begin
  result := Data.GetCharQMax;
end;

function TFuncDiagFun.DGetCharQMin: Double;
begin
  result := Data.GetCharQMin;
end;

function TFuncDiagFun.DGetQMin: Double;
begin
  result := Data.GetQMin;
end;

function TFuncDiagFun.DGetQMax: Double;
begin
  result := Data.GetQMax;
end;



procedure TFuncDiagFun.DrawFun  ( dt  :TSpecDrawData; bw :Boolean );
var
  svWidth :Integer;
  xr, yr  :Double;
  bold    :Boolean;
  min, max :Double;

procedure SetBold( switch :Boolean );
var
  c       :TCanvas;
begin
  c := dt.Canvas;
  if switch then
  begin
    c.Pen.Width := 2*svWidth;
    Bold := true;
  end
  else
  begin
    c.Pen.Width := svWidth;
    Bold := false;
  end;
end;

var
  i        :Integer;

begin
  if IsOn then
  begin
    min  := DGetCharQMin;
    max  := DGetCharQMax;

    svWidth := dt.Canvas.Pen.Width;
    if Tag <> 0 then
      dt.Canvas.Pen.Color := clBlack
    else
      dt.Canvas.Pen.Color := Self.Color;
    SetBold(false);
    xr := min;
    yr := Value(xr);
    dt.MoveTo( xr, yr );
    while xr <= max do
    begin
      xr := xr + dt.DX;
      yr := Value(xr);
      if Bolded then
      begin
        if (Bold and (xr > DGetQMax)) then
          SetBold(false)
        else if ((not Bold) and ((xr > DGetQMin)
                             and (xr < DGetQMax))) then
          SetBold(true);
      end;
      dt.LineTo( xr, yr );
    end;
    if Bold then
      SetBold(false);
    if Legend then
    begin
      for i := Low(LegQArr) to High(LegQArr) do
      begin
        xr := Lin( LegQArr[i], 0, 1, min, max );
        yr := Value(xr);
        DrawLegendItem( xr, yr, dt, bw );
      end;
    end;
  end;


end;

procedure TFuncDiagFun.DrawLegendItem(X, Y: Double; dt: TSpecDrawData;
  bw: Boolean);
var
  x1, y1, x2, y2 :Integer;
  s :TSize;
  sx, sy : TCanvCoord;
  rs :TRealPointRec;
  ps :TPoint;
  svBrush :TBrush;
  svH     :Integer;
begin
  svH := dt.Canvas.Font.Height;
  dt.Canvas.Font.Height :=  round(dt.Canvas.Font.Height * 0.65);
  s := dt.Canvas.TextExtent( LegText );
  if s.cx < s.cy then
    s.cx := s.cy;
  dt.ConvPointRPar( x, y, sx, sy );
  x1 := round(sx - s.cx*0.7);
  x2 := round(sx + s.cx*0.7);
  y1 := round(sy - s.cy*0.7);
  y2 := round(sy + s.cy*0.7);
  //svBrush := TBrush.Create;
  //svBrush.Assign( dt.Canvas.Brush );
  //dt.Canvas.Brush.Color := clWhite;
  //dt.Canvas.Brush.Style := bsSolid;
  dt.Canvas.Ellipse( x1, y1, x2, y2 );
  //dt.Canvas.Brush := svBrush;
  //svBrush.Free;

  dt.TextOut( X, Y, LegText, tjCenter, tvpCenter, 0 );
  dt.Canvas.Font.Height := svH
end;

procedure TFuncDiagFun.SetLegQ(const A: array of Single);
var
  i       :Integer;
begin
  SetLength( LegQArr, Length(A) );
  for i := Low(A) to High(A) do
    LegQArr[i] := A[i];
end;


{ THFuncDiagFun }

function THFuncDiagFun.Value( Q :Double ): Double;
begin
  result := Data.H(Q);
end;

{ TPFuncDiagFun }

function TPFuncDiagFun.Value( Q :Double ): Double;
begin
  if (Data.Pompa <> nil) and (Data.Pompa.EtaSilNom <> 0) then
    begin
      if (data.Pompa.DB.H.FieldByName('P_MET') <> nil) and
         (data.Pompa.DB.H.FieldByName('P_MET').AsString = 'P1') then
        //result := Data.P(Q)*Data.Pompa.EtaSilNom
        result := Data.P(Q)
      else
        result := Data.P(Q)/Data.Pompa.EtaSilNom;
    end
  else
    result := Data.P(Q);
end;

{ TP1FuncDiagFun }

function TP1FuncDiagFun.Value(Q: Double): Double;
begin  //MS 060323
  if (Data.Pompa <> nil) and (Data.Pompa.EtaSilNom <> 0) then
    begin
      if (data.Pompa.DB.H.FieldByName('P_MET') <> nil) and
         (data.Pompa.DB.H.FieldByName('P_MET').AsString = 'P1') then
        result := Data.P(Q)*Data.Pompa.EtaSilNom   
        //result := Data.P(Q)
      else
        result := Data.P(Q);
    end
  else
    result := Data.P(Q);
end;

{ TNPSHFuncDiagFun }

function TNPSHFuncDiagFun.Value( Q :Double ): Double;
begin
  result := Data.NPSH(Q);
end;

{ TETAFuncDiagFun }

function TETAFuncDiagFun.Value( Q :Double ): Double;
begin
 { if (Data.Pompa <> nil) and (Data.Pompa.EtaSilNom <> 0) then
    begin
      if (data.Pompa.DB.H.FieldByName('P_MET') <> nil) and
         (data.Pompa.DB.H.FieldByName('P_MET').AsString = 'P1') then
        result := Data.P(Q) //*Data.Pompa.EtaSilNom   // poprawka na p1 MS070922
        //result := Data.ETA(Q)/Data.Pompa.EtaSilNom
      else
        result := Data.ETA(Q);
    end
  else}
    result := Data.ETA(Q);
end;

initialization
  RegisterClass( TPompa );
  InitCharClassList;
  InitPompClassList;

finalization
  CharClassList.Free;
  PompClassList.Free;

END.
