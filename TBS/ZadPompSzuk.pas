unit ZadPompSzuk;

interface

uses
  Windows, SysUtils, Classes, DB, DBTables, Forms, Dialogs,
  KR_Class, KrMath,
  TBS_Tool, PompMath, ZadU, Prod, OPompa, PompySQL, PumpIntf, WkpGlob, Ciecze,
  PmpListU, Jezyki;

type
  TZSPState = ( zspsDane, zspsPrzygotowania, zspsSzukanie,
                zspsPauza, zspsPrzerwane, zspsWyniki );

  TFuncPumpComp = function (P1, P2 :TPompa) :Integer;

  {----------------------------------------------------------------
    KLASA :TZadSzukPomp  :Zadanie Szukania Pomp
      POCHODZI Z TZadanie

    ELEMENTY PUBLICZNE:
      constructor Create( O :TComponent ); override;
      destructor  Destroy;                 override;

      procedure WyczyscListe;
      procedure SzukajPomp;                virtual;
        Glowna procedura szukania pomp.
        jesli <WieluProd> wyszukuje dla wszystkich producentow
        w przeciwnym przypadku dla producenta zwracanego przez
        funkcje <Producent>;

      function  Producent: TProducent      virtual;
        Jesli <WieluProd> wskazuje na producenta, dla ktorego
          aktualnie jest przeprowadzane wyszukiwanie,
          jesli <WieluProd> i zadanie nie jest w stanie wyszukiwania
            zwraca NIL
        dla nie <WieluProd> zwraca producenta, ktorego dotyczy zadanie

      property  Pumps[ i :Integer ] :TPompa read GetPump;
        Znalezione pompy wg indksu od 0 do <PumpCount>-1

      property  PumpCount: Integer      read GetPumpCount;
        Ilosc znalezionych pomp

      property  WieluProd: Boolean      read GetWieluProd;
        Jesli tak wyszukuje dla
            calej listy producentow (zmienna globalna <Producenci>
        w przeciwnym wypadku dla producenta
            zwracanego przez funkcje <Producent>

      property  State    : TZSPState   read FState;
        Stan zadanie moze byc:
          zspsDane     - wprowadzanie danych (przed wyszukiwaniem)
          zspsSzukanie - szukanie (w trakcie wyszukiwania)
          zspsPauza    - wyszukiwanie chwilowo przerwane, moze byc
                         kontynuowane
          zspsWyniki   - wyniki (po wyszukiwaniu)

    PROCEDURY DOBORU:
      function  DobryProd( P :TProducent ) :Boolean; virtual;
        dla producenta <P> zwraca true, jesli przeszukiwanie
        ma byc dla niego prowadzone, false jesli nie.
        Wywolywane tylko gdy nie <WieluProd>.

      procedure SzukajPompProd( P :TProducent );     virtual;
        procedura doboru pomp dla danego producenta

      function  WarunekWst( DB :TDBPompy ) :Boolean; virtual;
        sprzwdza wstepne warunki na podstawie bazy danych
        przed stworzeniem obiektu pompy

      function  PompaOK( Pmp :TPompa ) :Boolean;     virtual;
        warunki dla obiektu pompy

  --------------------------}


  TZadSzukPomp = class (TZadanie)
  private
    FOnAddPump: TPompaDBEvent;
    procedure SetCheckTemp(const Value: Boolean);
    function GetCanceled: Boolean;
    function GetStopped: Boolean;
    procedure SetCanceled(const Value: Boolean);
    procedure SetStopped(const Value: Boolean);
    function GetWybranaPompa: TPompa;
    function t(s: string):string;
    
  protected         // odziedziczone z TZadanie
    procedure DefineProperties(Filer: TFiler);      override;
    function GetCanBeFree: Boolean;                 override;

  protected         // nowe pola i metody (do szukania)
    FState         :TZSPState;       // status zadania
    FInProcSzuk    :Boolean;
    FProd          :TProducent;
    FProds         :TList;           // lista producentow po selekcji
    FProdsPompOK   :TIntList;        // lista z liczbami zatwierdzonych pomp
                                     // dla kazdego producenta
    FCharSel       :IPumpCharSel;    // charakterystyka selekcji
    //FQw       :Double;               //  \
    //FHw       :Double;               //   domyslne parametry wywolania potomka
    //FHg       :Double;               //  /


    FAktDB         :TDBPompy;        // aktualnie przeszukiwana baza
    FTotalPomp     :Integer;         // suma liczby wszyskich pomp
                                     // dla producentow z FProds
    FCurrProdPompPrzeszuk :Integer;  // liczba pomp przeszukanych dla
                                     // aktualnego producenta;
    FPompPrzeszuk  :Integer;         // liczba pomp przeszukanych dla
                                     // wszyskich producentow
    FProdSzukInd   :Integer;         // indeks aktualnie przeszukiwanego
                                     // producenta kolejnosc wg FProds
    FNrWybranejPompy: Integer;

    FZastosowaniaList: TStrings;
    FKonstrukcjaList: TStrings;
    FKonstrukcjaList_OR: TStrings;  // specjalna lista do liczenia warunku OR

    FTemp      :Double;
    FCheckTemp :Boolean;

    FCieczPlyw :TCieczPlyw;
    FCieczRodz :TCieczRodzaj;

    procedure Read_NrWybranejPompy(Reader :TReader);
    procedure Read_State(Reader :TReader);
    procedure Write_State(Writer :TWriter);
    procedure ReadPumpList( S :TStream );
    procedure WritePumpList( S :TStream );
    function  AskWritePumpList :Boolean;           virtual;
    procedure AfterLoadPomp( Pmp :TPompa );        virtual;
    procedure SetNumerWybranejPompy(const Value: Integer);    virtual;
    function  StoredNrWybPompy :Boolean;           virtual;

    procedure DoOnAddPump( Pmp :TPompa; DB :TDBPompy );

    function  GetJestWDobr :Boolean;               virtual;

    procedure CreateCiecz;                         virtual;
    function GetCiecz: TCiecz;                     virtual;
    procedure SetTemp(const Value: Double);        virtual;
    procedure CreateCharSel;                       virtual;
    function  CreatePompaObj( DB :TDBPompy ) :TPompa;
                                                   virtual;

    procedure SetKonstrukcjaList(const Value: TStrings);
    procedure SetKonstrukcjaList_OR(const Value: TStrings);
    procedure SetZastosowaniaList(const Value: TStrings);

    procedure SetState( const Value :TZSPState );  virtual;
    procedure AddPump( Pmp :TPompa; DB :TDBPompy ); virtual;
    function  GetPump( i :Integer ) :TPompa;
    function  GetPumpCount: Integer;               virtual;
    function  GetWieluProd: Boolean;               virtual;

    function  Producent: TProducent;               virtual;
    procedure WyczyscProds;
    function  GetProds( i :Integer ) :TProducent;
    function  GetProdCount :Integer;
    procedure DodajProd( P :TProducent );
    function  GetProdsPompOK( i :Integer ) :Integer;

    function  DobryProd( P :TProducent ) :Boolean; virtual;
              // sprawdza czy producent jest dobry

    procedure LoopMessages;                        virtual;
              // wywolywana w petli szukania

    procedure SzukajPompProd( P :TProducent );     virtual;
              // Glowna procedura wyszukiwania pomp dla konkretnego producenta

    function  DataBaseOK( DB :TDBPompy ) :Boolean; virtual;
              // sprawdza czy struktura bazy jest dobra
              // standardowo sprawdza czy istnieje plik T
              // oraz czy w A jest pole <OBJ_ID>

    function  WarunekWst( DB :TDBPompy ) :Boolean; virtual;
              // Warunek wstepny - wywolywane przed stworzeniem obiektu pompy
              // tu powinny byc ujete wszystkie warunki latwe do sprawdzenia
              // na samej bazie danych.
              // Standardowo wywoluje <ObjIdOK> i <IdsOK>

    function  WarunekPost( Pmp :TPompa ) :Boolean; virtual;
              // Dodatkowe warunki po dobraniu pompy

    function  TempOKDB( DB :TDBPompy ) :Boolean;

    function  PompaOKDB( DB :TDBPompy ) :Boolean;  virtual;
    function  PompaOK( Pmp :TPompa ) :Boolean;     virtual;
              // glowna metoda sprawdzajaca obiekt pompy <Pmp>
              // standardowo jesli <CheckCharSel> wywoluje <CharSelOK>

    function  ObjIdOK( DB :TDBPompy ) :Boolean;    virtual;
              // czy pole <OBJ_ID> w bazie A OK - standardowo tak
              // wywolywane przez metode <WarunekWst>

    function  IdsOK( DB :TDBPompy ) :Boolean;      virtual;
              // czy pola <ID1..ID8> w bazie A OK - standardowo tak
              // wywolywane przez metode <WarunekWst>

    function  CheckCharSel :Boolean;               virtual;
              // czy sprawdzac charakterystyke
              // jesli tak, metoda <PompaOK> wywoluje metode <CharSelOK>
              // standardowo tak jesli <FCharSel> rozne od NIL

    function  CharSelOK( Pmp :TPompa ) :Boolean;   virtual;
    function  CharSelOK2( Pmp :TPompa; cs :IPumpCharSel ) :Boolean;

    function  KluczStrOK( const KluczID, Klucze :string ) :Boolean;
              // sprawdza czy KluczID zawiera sie w napisie Klucze
              // TAK jesli dla KluczID = AAA w Klucze znajduje sie /AAA/
              //

    function  ZastosOKDB( DB :TDBPompy ) :Boolean; virtual;

    function  SprawdzZastosDB( const Zas :string; DB :TDBPompy ) :Boolean;
                                                   virtual;
    function  KonstrOKDB( DB :TDBPompy ) :Boolean; virtual;
    function  KonstrOKDB_OR( DB :TDBPompy ) :Boolean; virtual;

    function  SprawdzKonstrDB( const K :string; DB :TDBPompy ) :Boolean;
                                                   virtual;


    procedure CharSelDestroing;                    virtual;

  public
    fDelta : real;
    fEta   : real;
    fNPSH  : real;

    //MS 05-01-05
    CzyKomunikat : boolean;
    KomunikatBledu : string;
     //MS 05-01-05
    PompaDoTestu : string;

    FPumpList   :TPumpList;  // Lista wyszukanych pomp

    constructor Create( O :TComponent ); override;
    destructor  Destroy;                 override;

    function Predkosc(d,Q:double):double; //SPRAWDZIC CZY NIE NA  PODOBNYCH

    procedure WyczyscListe;              virtual;
    procedure PrzygotujSzukanie;         virtual;
    procedure SzukajPomp;                virtual;
    procedure Pauza;                     virtual;
    procedure PrzerwijSzukanie;          virtual;
    procedure KontynSzukanie;            virtual;

    procedure ZapiszKomunikat(s:string);

    procedure SortPumpsBy( CompFunc :TFuncPumpComp);
    procedure SortujPoNazwie(ADesc :Boolean = false);
    procedure SortujPoDobroci(ADesc :Boolean = True);
    procedure ZnowObliczDobroc(ASort :Boolean = True);        virtual;

    procedure UstawWDobroci( Pmp :TPompa; cs :IPumpCharSel ); virtual;

    function  OblNPSHu( H_napl, Ppow_Pa :Double ) :Double;
              // Oblicz NPSH ukladu
              // H_napl   - Wys slupa cieczy nad pompa [m] (ssanie ze znakim "-")
              // Ppow_Pa  - Cisnienie powietrza na powierzchni wody [Pa]
              // result [m]

    property  Prods[ i :Integer ] :TProducent read GetProds;
    property  ProdCount    :Integer    read GetProdCount;
    property  TotalPomp    :Integer    read FTotalPomp;
    property  PompPrzeszuk :Integer    read FPompPrzeszuk;
    property  ProdsPompOK[i :Integer] :Integer read GetProdsPompOK;
    property  CurrProdPompPrzeszuk :Integer read FCurrProdPompPrzeszuk;
    property  ProdSzukInd   :Integer   read FProdSzukInd;

    property  AktDB :TDBPompy  read FAktDB;

    property ZastosowaniaList:TStrings read FZastosowaniaList write SetZastosowaniaList;
    property KonstrukcjaList:TStrings read FKonstrukcjaList write SetKonstrukcjaList;
    property KonstrukcjaList_OR:TStrings read FKonstrukcjaList_OR write SetKonstrukcjaList_OR;
    // ms dodatkoaw lista bo musimy zrealizowaæ operacjê (W1 or W2) and (W3 and W4)


    property  Pumps[ i :Integer ] :TPompa read GetPump;
    property  WybranaPompa :TPompa    read GetWybranaPompa;
    property  PumpCount: Integer      read GetPumpCount;
    property  WieluProd: Boolean      read GetWieluProd;
    property  State    : TZSPState    read FState;
    property  Stopped  : Boolean      read GetStopped write SetStopped;
    property  Canceled : Boolean      read GetCanceled write SetCanceled;
    property  Temp     : Double       read FTemp write SetTemp;
    property  CieczPlyw: TCieczPlyw   read FCieczPlyw;
    property  CieczRodz: TCieczRodzaj read FCieczRodz;
    property  Ciecz    : TCiecz       read GetCiecz;
    property  CheckTemp: Boolean      read FCheckTemp write SetCheckTemp;
    property  JestWDobr: Boolean      read GetJestWDobr;

    property  OnAddPump :TPompaDBEvent read FOnAddPump write FOnAddPump;

  published

    property  NumerWybranejPompy :Integer read  FNrWybranejPompy
                                          write SetNumerWybranejPompy
                                         stored StoredNrWybPompy;


  end;

  EPrzerwijSzukanie = class (EAbort)
  end;

implementation

uses LinCharU;

const
  ZSPStateTab : array [TZSPState] of string=
    (
      'zspsDane',
      'zspsPrzygotowania',
      'zspsSzukanie',
      'zspsPauza',
      'zspsPrzerwane',
      'zspsWyniki'
    );



{ TZadSzukPomp }

constructor TZadSzukPomp.Create( O :TComponent );
begin
  inherited Create( O );

  FPumpList := TPumpList.Create;
  FPumpList.AutoSort := True;
  FPumpList.AfterLoadPomp := AfterLoadPomp;
  FProds    := TList.Create;
  FZastosowaniaList := TStringList.Create;
  FKonstrukcjaList := TStringList.Create;
  FKonstrukcjaList_OR := TStringList.Create;
  FNrWybranejPompy := -1;
  if WerProdPomp then
    FProd := Producenci.ProdByName( GlobProdId );
  CreateCiecz;
  CreateCharSel;
  //MS 05-01-05
  KomunikatBledu :=t('Brak bledow');
end;


destructor  TZadSzukPomp.Destroy;
begin
  try
    if (State in [zspsSzukanie, zspsPauza]) then
    begin
      PrzerwijSzukanie;
      repeat
        sleep( 50 );
        Application.ProcessMessages;
      until not FInProcSzuk;
    end;
    try
      FPumpList.Free;
      FCharSel.Free;
      FProds.Free;
    except
    end;
  finally
    Inherited Destroy;
  end;
end;

procedure TZadSzukPomp.CreateCharSel;
begin
  FCharSel := NIL;
end;

function  TZadSzukPomp.CreatePompaObj( DB :TDBPompy ) :TPompa;
begin
  result := CreatePump( NIL, DB );
end;

procedure TZadSzukPomp.DoOnAddPump(Pmp: TPompa; DB: TDBPompy);
begin
  if Assigned(FOnAddPump) then
    FOnAddPump(Pmp, DB);
end;

{*************************************}
{ Dpdawanie wyszukanych pomp do listy }
{*************************************}
procedure TZadSzukPomp.AddPump( Pmp :TPompa; DB :TDBPompy );
begin
  if Pmp <> NIL then
    Pmp.DBCreateCopy(DB);
  FPumpList.AddPump( Pmp );
  Pmp.CharSel := FCharSel;
  DoOnAddPump( Pmp, DB );
end;


function  TZadSzukPomp.GetPump( i :Integer ) :TPompa;
begin
  result := FPumpList.Pumps[i];
end;

function  TZadSzukPomp.GetPumpCount: Integer;
begin
  result := FPumpList.Count;
end;

function  TZadSzukPomp.GetWieluProd: Boolean;
begin
  result := not WerProdPomp;
end;


function  TZadSzukPomp.Producent;
begin
  result := FProd;
end;

function  TZadSzukPomp.GetProds( i :Integer ) :TProducent;
begin
  result := TProducent(FProds.Items[i]) ;
end;

function  TZadSzukPomp.GetProdCount :Integer;
begin
  //if WieluProd then
    result := FProds.Count
  //else
    //result := 1;
end;


procedure TZadSzukPomp.DodajProd( P :TProducent );
begin
  FProds.Add( P );
end;


function  TZadSzukPomp.GetProdsPompOK( i :Integer ) :Integer;
begin
  result := FProdsPompOK.Values[i];
end;


procedure TZadSzukPomp.WyczyscListe;
begin
  FPumpList.Clear;
  FNrWybranejPompy := -1;
end;

procedure TZadSzukPomp.WyczyscProds;
begin
  FProds.Clear;
  FProdsPompOK.Free;
  FProdsPompOK := NIL;
end;



procedure TZadSzukPomp.PrzygotujSzukanie;
var
  i       :Integer;
  Pr      :TProducent;
begin
  SetState( zspsPrzygotowania );
  WyczyscProds;
  WyczyscListe;
  if WieluProd then
    begin
      for i := 0 to  (Producenci.Count-1) do
        begin
          Pr := Producenci.Prods[i];
          if Pr.Enable and Pr.BazyDost[ 'PUMPS' ] then
            if DobryProd( Pr ) then
              DodajProd( Pr );
      end;
    end
  else
    DodajProd( Producent );

  FTotalPomp := 0;
  for i := 0 to ProdCount-1 do
    FTotalPomp := FTotalPomp + Prods[i].IloscPomp;
  FPompPrzeszuk := 0;
  FProdsPompOK := TIntList.Create( 0, ProdCount-1 );
  FProdsPompOK.Fill(0);

  FPumpList.AutoSort := JestWDobr;

  UpdateForm;
end;


procedure TZadSzukPomp.SzukajPomp;
var
  i       :Integer;
  Pr      :TProducent;
begin
  KomunikatBledu := ' ' +t('Brak bledow');  //MS 2005-01-12
  if FInProcSzuk then
  begin
    EXIT;
  end;
  FInProcSzuk := true;
  if State <> zspsPrzygotowania then
    PrzygotujSzukanie;
  SetState( zspsSzukanie );
  UpdateForm;    //zle dziala wywoluje swoja proc
  for i := 0 to  (ProdCount-1) do
  begin
    FProdSzukInd := i;
    Pr := Prods[i];
    if WieluProd then
      FProd := Pr;
    try
      SzukajPompProd( Pr );
    except
      on EPrzerwijSzukanie do
      begin
        BREAK;
      end;
    end;
  end;
  SetState( zspsWyniki );
  if WieluProd then
    FProd := NIL;

  UpdateForm;
  FInProcSzuk := false;
end;


function  TZadSzukPomp.DobryProd( P :TProducent ) :Boolean;
begin
  result := true;
end;


function  TZadSzukPomp.DataBaseOK( DB :TDBPompy ) :Boolean;
begin
  result := DB.hOK and DB.tOK;
  result := result and (DB.A.FindField('OBJ_ID') <> NIL);
end;


procedure TZadSzukPomp.SzukajPompProd( P :TProducent );
var
  DB      :TDBPompy;
//  OK      :Boolean;
begin
  DB   := TDBPompy.CreateForProd( self, P );
  try
    try
    FCurrProdPompPrzeszuk := 0;
    if DataBaseOK(DB) then
    begin
      FAktDB := DB;
      while not DB.Eof do
      begin
        LoopMessages;
        try
          if PompaOKDB( DB ) then
            with FProdsPompOK do
              Values[FProdSzukInd] := Values[FProdSzukInd] +1;

          DB.Next;

          Inc(FCurrProdPompPrzeszuk);
          Inc(FPompPrzeszuk);
        except
          ShowMessageFmt(t('Blad podczas wyszukiwania %s RecNo: %d, Pompa: %s'),
                          [#13,DB.A.RecNo,
                           DB.A.FIeldByName('NAZWA').AsString] );
          DB.Next;
        end;
      end;
    end;
    except on EAccessViolation do
      ShowMessage(t('Blad podczas wyszukiwania'));
    end;
  finally
    FPompPrzeszuk := FPompPrzeszuk - FCurrProdPompPrzeszuk
                     + Producent.IloscPomp;
    db.Free;
  end;
end;

function  TZadSzukPomp.WarunekWst( DB :TDBPompy ) :Boolean;
begin
// MS wersja przed  05-01-05
//  result := (DB.A.FieldByName('ID1').AsString <> '')
//            and ObjIdOK( DB ) and IdsOK( DB ) and TempOKDB(DB)
//            and ZastosOKDB(DB) and KonstrOKDB(DB);

//MS 05-01-05
  if DB.A.FieldByName('ID1').AsString = '' then
    begin
      result := false;
      ZapiszKomunikat(t('Bark identyfikatora Id1'));
      //KomunikatBledu := ;
    end
  else
    result:= ObjIdOK( DB )
            and IdsOK( DB )
            and TempOKDB(DB)
            and ZastosOKDB(DB)
            and KonstrOKDB(DB)
            and KonstrOKDB_OR(DB);  //ms 071019 dodano warunek OR
end;

function TZadSzukPomp.WarunekPost(Pmp: TPompa): Boolean;
begin
  Result := True;
  if Result and SfpOgr
            and ((Pmp.Producent.Ident = 'SFP')
                 or (Pmp.Producent.Ident = 'WFP')) then
  begin
    Result := ((0.65*Pmp.Qn) <= Pmp.Qr) and (Pmp.Qr <= (1.3*Pmp.Qn));
  end;
end;



function TZadSzukPomp.PompaOKDB(DB: TDBPompy): Boolean;
var
  Pompa  :TPompa;
  OK     :Boolean;
begin
  //Pompa := NIL;
  //OK    := false;
  CzyKomunikat := DB.A.FieldByName('Nazwa').AsString = PompaDoTestu;
  OK := WarunekWst( DB );

  // !!! Trzeba pozniej dodac, zeby odsiewal zle warianty
  // Warianty
  if DB.SaWarianty then
  begin
    DB.NextVar;        // nastepny wariant do tego samego rekordu A
    while not DB.EOV do
    begin
      OK := OK or WarunekWst(DB);
      DB.NextVar;
    end;
  end;

  if OK then
  begin
    Pompa    := CreatePompaObj(DB);
    OK := PompaOK( Pompa );
    if OK and (Pompa <> NIL) then
      OK := WarunekPost(Pompa);
    if OK then
    begin
      AddPump( Pompa, DB );
      if DB.SaWarianty then
      begin
        // !!! Pozniej - Filtry wariantow pamietane w pompie lub DB
        //     a moze to umiescic w AddPump
      end;
    end
    else
    begin
      Pompa.Free;
    end;
  end;
  result := OK;
end;



function  TZadSzukPomp.PompaOK( Pmp :TPompa ) :Boolean;
begin
  if Pmp = NIL then
  begin
    result := false;
    EXIT;
  end;
  if CheckCharSel then
    result := CharSelOK( Pmp )
  else
    result := true;
end;

function  TZadSzukPomp.ObjIdOK( DB :TDBPompy ) :Boolean;
begin
  result := true;
end;


function  TZadSzukPomp.IdsOK( DB :TDBPompy ) :Boolean;
begin
  result := true;
end;


function  TZadSzukPomp.CheckCharSel :Boolean;
begin
  result := (FCharSel <> NIL);
end;


function  TZadSzukPomp.CharSelOK( Pmp :TPompa ) :Boolean;
begin
  if FCharSel <> NIL then
    result := CharSelOK2( Pmp, FCharSel )
  else
    result := false;
end;

function  TZadSzukPomp.CharSelOK2( Pmp :TPompa; cs :IPumpCharSel ) :Boolean;
var
  Qr, Hr :double;
  PI      :IPump;
  ChD     :TFuncCharData;
begin
  result := false;
  if Pmp.WorkPoint( cs, Qr, Hr ) then
  begin
    PI := Pmp.GetInterface;
    result := cs.Accept( Qr, Hr, PI );
    ///
    //Obliczanie funkcji dobroci
    //Hw:=cs.GetHw;
    if not Pmp.ParObliczone then
    begin
      Pmp.Qr:=Qr;
      Pmp.Hr:=Hr;
      if Pmp.GetCharData is TFuncCharData then
      begin
        ChD := TFuncCharData(Pmp.GetCharData);
        Pmp.Pr  := ChD.P(Qr);
        Pmp.NPSHr := ChD.NPSH(Qr);
        Pmp.ETAr := ChD.ETA(Qr);
        Pmp.ParObliczone := true;
      end
      else
      begin
        Pmp.Pr := Pmp.Pn;
        Pmp.NPSHr := 0;
        Pmp.ETAr := PompMath.Eta( Pmp.Qr, Pmp.Hr, Pmp.Pr );
      end;
    end;
    UstawWDobroci(Pmp, cs);
  end
  else
    ZapiszKomunikat(t('Brak punktu przeciecia charakterystyk rurociagu i pompy'));
end;

procedure TZadSzukPomp.SetKonstrukcjaList(const Value: TStrings);
begin
  FKonstrukcjaList.Assign( Value );
end;

procedure TZadSzukPomp.SetKonstrukcjaList_OR(const Value: TStrings);
begin
  FKonstrukcjaList_OR.Assign( Value );
end;

procedure TZadSzukPomp.SetZastosowaniaList(const Value: TStrings);
begin
  FZastosowaniaList.Assign( Value );
end;

function  TZadSzukPomp.ZastosOKDB( DB :TDBPompy ) :Boolean;
var
  i       :Integer;
begin
  result := true;
  if (ZastosowaniaList = NIL) or (ZastosowaniaList.Count = 0) then
    EXIT;
  i := 0;
  while result and (i < ZastosowaniaList.Count) do
  begin
    result := SprawdzZastosDB( ZastosowaniaList.Strings[i], DB );
    inc(i);
  end;
end;

function  TZadSzukPomp.SprawdzZastosDB( const Zas :string; DB :TDBPompy ) :Boolean;
begin
  if not DB.HOk then
    result := false
  else
    result := KluczStrOK(Zas, DB.T.FieldByName('KL_Zast').AsString );
end;

function TZadSzukPomp.KonstrOKDB(DB: TDBPompy): Boolean;
var
  i      :Integer;
begin
  result := true;
  if (KonstrukcjaList = NIL) or (KonstrukcjaList.Count = 0) then
    EXIT;
  i := 0;
  while result and (i < KonstrukcjaList.Count) do
  begin
    result := SprawdzKonstrDB( KonstrukcjaList.Strings[i], DB );
    inc(i);
  end;
end;

function TZadSzukPomp.KonstrOKDB_OR(DB: TDBPompy): Boolean;
var
  i      :Integer;
begin
  result := true;
  if (KonstrukcjaList_OR = NIL) or (KonstrukcjaList_OR.Count = 0) then
    EXIT;
  i := 0;
  //ms 071019 jest spe³niony kiedy jeden klucz z listy jest w bazie
  result := false;
  while (not result) and (i < KonstrukcjaList_OR.Count) do
    begin
      result := SprawdzKonstrDB( KonstrukcjaList_OR.Strings[i], DB );
      inc(i);
    end;
end;

function TZadSzukPomp.SprawdzKonstrDB(const K: string;
  DB: TDBPompy): Boolean;
begin
  if not DB.HOk then
    result := false
  else
    result := KluczStrOK(K, DB.T.FieldByName('Konstr').AsString );
end;

procedure TZadSzukPomp.SetState(const Value: TZSPState);
begin
  FState := Value;
end;

function TZadSzukPomp.KluczStrOK(const KluczID, Klucze: string): Boolean;
begin
  result := (pos( Format( '/%s/', [KluczId]), Klucze)  >  0);
end;

function TZadSzukPomp.TempOKDB(DB: TDBPompy): Boolean;
begin
  result := (not CheckTemp)
           or ((DB.T.FieldByName('T_MIN').AsFloat <= Temp)
               and (Temp <= DB.T.FieldByName('T_MAX').AsFloat));
end;

procedure TZadSzukPomp.SetCheckTemp(const Value: Boolean);
begin
  FCheckTemp := Value;
end;

function TZadSzukPomp.GetCanceled: Boolean;
begin
  result := State = zspsPrzerwane;
end;

function TZadSzukPomp.GetStopped: Boolean;
begin
  result := State = zspsPauza;
end;

procedure TZadSzukPomp.Pauza;
begin
  if State = zspsSzukanie then
    FState := zspsPauza;
end;

procedure TZadSzukPomp.PrzerwijSzukanie;
begin
  if (State = zspsSzukanie) or (State = zspsPauza) then
    FState := zspsPrzerwane;
end;

procedure TZadSzukPomp.SetCanceled(const Value: Boolean);
begin
  if Value then
    PrzerwijSzukanie;
end;

procedure TZadSzukPomp.SetStopped(const Value: Boolean);
begin
  if Value then
    Pauza
  else
    KontynSzukanie;
end;

procedure TZadSzukPomp.KontynSzukanie;
begin
  if (State = zspsPauza) then
    FState := zspsSzukanie;
end;

function TZadSzukPomp.GetCanBeFree: Boolean;
begin
  result := not FInProcSzuk;
end;

procedure TZadSzukPomp.LoopMessages;
begin
  if FShouldFree then             // jesli zadanie trzeba zwolnic
    PrzerwijSzukanie;

  repeat
    Application.ProcessMessages;
  until (not Stopped) or Canceled;

  if Canceled then
    raise EPrzerwijSzukanie.Create('');
end;

function TZadSzukPomp.GetCiecz: TCiecz;
begin
  result := FCieczPlyw;
end;

procedure TZadSzukPomp.SetTemp(const Value: Double);
begin
  FTemp := Value;
  if FCieczPlyw <> NIL then
    FCieczPlyw.T := Value;
end;

procedure TZadSzukPomp.CreateCiecz;
begin
  FCieczPlyw := TCieczPlyw.Create(self);
  //FCieczPlyw.Name := 'CieczPlyw';
  FCieczRodz := TCieczH2O.Create(self);
  //FCieczRodz.Name := 'CieczRodz';
  FCieczPlyw.Ciecz := FCieczRodz;
  FCieczPlyw.T  := Temp;
  FCieczPlyw.Q_m3h  := 0;
end;

procedure TZadSzukPomp.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty( 'NrWybranejPompy',       // Backward compatibility
                        Read_NrWybranejPompy,    // obecnie 'NumerWybranejPompy'
                        NIL,
                        false );
  Filer.DefineProperty( 'State',
                        Read_State,
                        Write_State,
                        true );
  Filer.DefineBinaryProperty( 'PumpList',
                              ReadPumpList,
                              WritePumpList,
                              AskWritePumpList );
end;

procedure TZadSzukPomp.ReadPumpList(S: TStream);
begin
  FPumpList.LoadFromStream(S);
end;

procedure TZadSzukPomp.WritePumpList(S: TStream);
begin
  FPumpList.SaveToStream(S);
end;

procedure TZadSzukPomp.AfterLoadPomp(Pmp: TPompa);
begin
  Pmp.CharSel := FCharSel;
  if FCharSel <> NIL then
    FCharSel.AddRef;
end;

procedure TZadSzukPomp.Read_NrWybranejPompy(Reader: TReader);
var
  ValNr   :Integer;
begin
  ValNr := Reader.ReadInteger;
  SetNumerWybranejPompy(ValNr);
end;

procedure TZadSzukPomp.Read_State(Reader: TReader);
var
  s       :string;
  i      :TZSPState;
begin
  s := Reader.ReadString;
  FState := zspsDane;
  for i := low(TZSPState) to high(TZSPState) do
  begin
    if s = ZSPStateTab[i] then
    begin
      FState := i;
      break;
    end;
  end;
end;

procedure TZadSzukPomp.Write_State(Writer: TWriter);
begin
  Writer.WriteString(ZSPStateTab[State]);
end;

function TZadSzukPomp.AskWritePumpList: Boolean;
begin
  result := true;
end;

procedure TZadSzukPomp.SetNumerWybranejPompy(const Value: Integer);
begin
  FNrWybranejPompy := Value;
end;

function TZadSzukPomp.StoredNrWybPompy: Boolean;
begin
  result := FNrWybranejPompy >= 0;
end;

procedure TZadSzukPomp.UstawWDobroci(Pmp: TPompa; cs :IPumpCharSel);
begin
  Pmp.WDobroci:= fDELTA*(1-abs( f_div((Pmp.Hr-cs.GetHw),cs.GetHw)))
                +fETA*Pmp.ETAr;
//                +fNPSH*(Hb+Hzs+Hgs-(Hgs+Hzs-Hs)/Qw^2*TabZestaw[i,12]^2;
//                   Hv-TabZestaw[i,16]) // czy dodac dNPSH
end;

function TZadSzukPomp.GetWybranaPompa: TPompa;
begin
  if (0 <= NumerWybranejPompy) and (NumerWybranejPompy < PumpCount) then
    result := Pumps[NumerWybranejPompy]
  else
    result := NIL;
end;

procedure TZadSzukPomp.SortPumpsBy(CompFunc: TFuncPumpComp);
var
  svWybP  :TPompa;
begin
  svWybP := WybranaPompa;
  FPumpList.Sort( TListSortCompare(CompFunc) );
  if svWybP <> NIL then
    FNrWybranejPompy := FPumpList.IndexOf(svWybP);
end;

function NazwCompare( P1, P2 :TPompa ) :Integer;
begin
  if P1.Nazwa > P2.Nazwa then
    Result := 1
  else if P1.Nazwa < P2.Nazwa then
    Result := -1
  else
    Result := 0;
end;

function NazwCompareDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := NazwCompare( P2, P1 );
end;

function DobrCompare( P1, P2 :TPompa ) :Integer;
begin
  if P1.WDobroci > P2.WDobroci then
    Result := 1
  else if P1.WDobroci < P2.WDobroci then
    Result := -1
  else
    Result := 0;
end;

function DobrCompareDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := DobrCompare( P2, P1 );
end;


procedure TZadSzukPomp.SortujPoDobroci(ADesc :Boolean);
begin
  if ADesc then
    SortPumpsBy( DobrCompareDesc )
  else
    SortPumpsBy( DobrCompare );
end;

procedure TZadSzukPomp.SortujPoNazwie(ADesc :Boolean);
begin
  if ADesc then
    SortPumpsBy( NazwCompareDesc )
  else
    SortPumpsBy( NazwCompare );
end;

procedure TZadSzukPomp.ZnowObliczDobroc(ASort :Boolean);
var
  i       :Integer;
begin
  if FCharSel <> NIL then
    for i := 0 to PumpCount-1 do
      UstawWDobroci(Pumps[i], FCharSel );
  if ASort then
    SortujPoDobroci;
end;

function TZadSzukPomp.GetJestWDobr: Boolean;
begin
  result := (fEta <> 0) or (fNPSH <> 0) or (fDelta <> 0);
end;

function TZadSzukPomp.OblNPSHu(H_napl, Ppow_Pa :Double): Double;
  // Oblicz NPSH ukladu
  // H_napl   - Wys slupa cieczy nad pompa [m] (ssanie ze znakim "-")
  // Ppow_Pa  - Cisnienie powietrza na powierzchni wody [Pa]
  // result [m]
begin
  result := H_napl + F_DIV(Ppow_Pa - CieczPlyw.Pv , CieczPlyw.Ro * G_Ziem);
  //result := H_napl + (Ppow_Pa - CieczPlyw.Pv) / (CieczPlyw.Ro * G_Ziem);
end;


procedure TZadSzukPomp.CharSelDestroing;
begin
  FCharSel := NIL;
end;

procedure TZadSzukPomp.ZapiszKomunikat(s: string);
begin
  if CzyKomunikat and (s <>'') then
     KomunikatBledu := s;
end;

function TZadSzukPomp.Predkosc(d, Q: double): double;
begin
  if d > 0
    then result := 4*Q/3600/Pi/d/d*1000*1000
    else result := 0;
end;

function TZadSzukPomp.t(s: string): string;
begin
 result:=TTlumacz.dajObiekt.ZnajdzTlumaczenie(s);
end;

end.
