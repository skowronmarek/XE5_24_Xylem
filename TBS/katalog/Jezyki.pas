{******************************************************************************
  Unit jezykowy umozliwiajazy tlumaczenie dowolnych komponentow i rekurencyjnie
  ich podkomponentow a takze zwyklych napisow.
  Aby Unit dzialal potrzebny jest plik unitu <b>Jezyki.pas</b> oraz plik z
  tlumaczeniami (domyslnie <b>Tlumaczenia.DBF</b>).

  Unit umozliwia tlumaczenie zarowno w wersji Delphi 4.0 jak i 7.0.

  Klasa jest tak zaprojektowana zeby mogl istniec tylko jeden obiekt tlumacza
  (singleton). Obiektu TTlumacz nie nalezy tworzyc poprzez instrukcje <b>Create</b>
  tylko odwolywac sie poprzez instrukcje <b>DajObiekt</b>.
  Na przyklad:
  <code>Tlumacz := TTlumacz.DajObiekt;</code>
  Wtedy tlumaczenie moze odbywac sie nastepujaco:
  <code>Tlumacz.Tlumacz(Objekt);</code>
  Wygodnie tez jest wywolywac tlumaczenie bez przypisania do zmiennej:
  <code>TTlumacz.DajObiekt.Tlumacz(Obiekt);</code><br>

  Przyklad tlumaczenia Formy i wszystkich jej komponentow:<code>
  procedure TForm1.Button1Click(Sender: TObject);
  begin
    TTlumacz.DajObiekt.Tlumacz(self);
  end;
  </code><br>

  Przyklad tlumaczenia calej aplikacji:<code>
  procedure TForm1.Button1Click(Sender: TObject);
  begin
    TTlumacz.DajObiekt.Tlumacz;
  end;
  </code>

  Zeby przetlumaczyc caly raport <i>"Quick Report"</i> nalezy wykonac dwie rzecy:
  <li>Zeby przetlumaczyc wszystkie pola na bandach w raporcie w zdarzeniu
  <i>NeedData</i> dodac: <code>TTlumacz.DajObiekt.Tlumacz(self);</code>
  <li>Zeby przetlumaczyc nazwe raportu trzeba ja zmienic przy tworzeniu, wiec nalzy
  nadpisac konstruktor:<code>
  constructor TQuickReport1.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    TTlumacz.DajObiekt.Tlumacz(self);
  end;
  </code>

  Zmiany:
  ------------------------------------------------------------------------------
  25.05.2006
    + Umozliwienie blokowania tlumaczenia ze wzgledu na wartosc tagu w TComponent
      - *Nowe pola "TagTlumaczenia" i "TlumaczycWgTagu" okreslajace czy mozna tlumaczyc ze wzgledu na wartosc tagu w TComponent
      - *Nowa procedura "UstawTlumaczenieWgTagu" ustawiajaca wartosc "TlumaczycWgTagu"
      - Zmiany w procedurach "ZnajdzTlumaczenie" i "Tlumacz", zeby uwzglednialy wartosc tagu
    + Poprawa bledu za dlugiego stringu wejsciowego poprzez obcinanie jego dlugosci przed wyszukiwaniem
      - * nowa wartosc domyslna MAKSYMALNA_DLUGOSC_STRINGU wg ktorej sie obcina tlumaczone napisy
      - Zmodyfikowane funkcje "ZnajdzTlumaczenie"
  26.05.2006
    + Dodane tlumaczenie QuickReports
      - Poszerzono funkcje "Tlumacz" o nowe obiekty

  @Author   Kapel
  @Version  0.96
  @Todo     Uproscic: wywalic tlumaczenie grupowe, wywalic tlumaczenie ze wzgledu na grupe
  ------------------------------------------------------------------------------
  08.09.2008
   + Tlumaczenia Menu, PageControl
  30.09.2008
*******************************************************************************}
unit Jezyki;

interface

uses
  Classes, Windows, Forms, Menus, StdCtrls, ExtCtrls, Controls, DBTables, SysUtils, DB,
  Buttons, Grids, CheckLst, ComCtrls, ToolWin, {QuickRpt, QRCtrls,}
  WkpGlob
  // WS
  ,Diagrams, Outline, Graphics, ImgList, DbgEx, DBGrids ,Variants
  //WS
  {$IFDEF VER150}
  ,Variants
  {$ENDIF}
  ;

Type
  TTrybNieprzetlumaczony = (tNieZmieniaj, tZmieniaj);           /// Wyliczenie trybow zachowania kiedy nie znaleziono danego ciagu
  TTrybTlumaczenia = (tRekurencyjny, tPojedynczy);              /// Wyliczenie trybow tlumaczenia
  TTrybWyszukiwania = (tNapis, tNapisNazwa, tNapisNazwaKlasa);  /// Wyliczenie uszczegolowienia wyszukiwania

Const
  IDRosyjski = 1049;

Type
  {*****************************************************
    Klasa tlumacza. <i>Moze istniec tylko jeden obiekt
    tej klasy</i>
  *****************************************************}
  TTlumacz = class
  private
    TrybTlumaczenia         :TTrybTlumaczenia;				/// Tryby tlumaczenia: <br><b>tRekurencyjny</b>  - tlymacz komponent i wszystkie podkomponenty<br> <b>tPojedynczy</b>  - tlumacz tylko wybrany komponent. Nie zmieniaj podkomponentow.
    TrybWyszukiwania        :TTrybWyszukiwania;				/// Tryby uszczegolowienia wyszukiwania: <br><b>tNapis</b> - szukaj tylko napisu do przetlumaczenia<br> <b>tNapisNazwa</b> - szukaj wg napisu i nazwy obiektu<br> <b>tNapisNazwaKlasa</b> - szukaj wg napisu, nazwy i klasy obiektu
    TrybNieprzetlumaczony   :TTrybNieprzetlumaczony;	/// Tryby pracy: <br><b>tNieZmieniaj</b>  - pozostaw napis unikalny<br> <b>tZmieniaj</b>  - wstaw standoardowy napis
    TlumaczycHinty          :boolean;									/// Tryb tlumaczenia hintow
    TlumaczycGrupowo        :boolean;									/// Tryb mowiacy czy szukac wedlug grupy
    TlumaczycWgTagu         :boolean;
    TworzycLog              :boolean;									/// Czy tworzyc log

    NapisNieprzetlumaczony  :string;									/// Napis wstawiany kiedy nie ma tlumaczenia a <code>TrybNieprzetlumaczony = tZmieniaj</code>
    TagTlumaczenia          :Longint;                 /// Wartosc obiektu TComponent przy ktorej jest pozwolenie na tlumaczenie
    Grupa                   :string;                  /// Napis okreslajacy grupe
    Tabela                  :TTable;                  /// Referencja do tabeli na dysku
    PlikLog                 :TextFile;                /// Plik do logowania
    OtwartyLog              :boolean;                 /// Zmienna informujaca czy plik logu jest otwarty
    CzyRosyjskiWindows      :boolean;

//    JezykTlumaczenia: string; /// Napis okreslajacy jezyk

    Constructor Create(NazwaTabeli: string); overload;
    Constructor Create(Sciezka: string; NazwaTabeli: string); overload;
    Destructor  Destroy;

    function    CzyMoznaTlumaczyc(Nazwa :string; Typ :string):boolean; overload;
    function    CzyMoznaTlumaczyc(Nazwa :string):boolean; overload;
    function    ZnajdzTlumaczenie(Napis :string; Objekt :TComponent):String; overload;
    //WS
    function    IsNumeric(s : string):boolean;
    function    GetOwnerDraw : boolean;
    //WS
  public
    class function  DajObiekt: TTlumacz;
    class procedure Zamknij;

    property  UstawTrybTlumaczenia      :tTrybTlumaczenia       write TrybTlumaczenia;
    property  UstawTrybWyszukiwania     :tTrybWyszukiwania      write TrybWyszukiwania;
    property  UstawTrybNieprztlumaczony :TTrybNieprzetlumaczony write TrybNieprzetlumaczony;
    property  UstawTlumaczenieHintow    :boolean                write TlumaczycHinty;
    property  UstawTlumaczenieGrupowe   :boolean                write TlumaczycGrupowo;
    property  UstawTlumaczenieWgTagu    :boolean                write TlumaczycWgTagu;
    property  UstawGrupe                :string                 write Grupa;
    procedure UstawLogowanie(Sciezka :string); overload;
    procedure UstawLogowanie(Tryb :boolean); overload;
    procedure ZakonczLogowanie;
    procedure DoLogu(napis :string);

    function  JezykTlumaczenia: string;
    function  ZnajdzTlumaczenie(Napis :string):String; overload;
    function  ZnajdzTlumaczenie(Napis :string; Grupa: String):String; overload;
    function  ZnajdzTlumaczenie(Napis :string; Jezyk: string; Grupa :String):String; overload;
    function  ZnajdzTlumaczenieDlaJezyka(Napis :string; Jezyk :string):String; overload;
    procedure Tlumacz(Objekt :TComponent); overload;
    procedure Tlumacz(Aplikacja :TApplication); overload;
    procedure Tlumacz; overload;
    //WS 30092008
    Function    GetCharSet : TFontCharset;
    function    GetFontName  : String;
    //WS 30092008
   protected
    procedure DoMasureMenuItem( Sender: TObject; ACanvas: TCanvas;
                                var Width, Height: Integer);
    procedure DoDrawMenuItem(Sender: TObject; ACanvas: TCanvas;
                      ARect: TRect; Selected: Boolean);
    procedure Maluj(Sender: TObject);
    procedure pcDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
  end;

  TDummyMenuItem = class(TMenuItem)
  public
    procedure DoDrawText(ACanvas: TCanvas; const ACaption: string;
      var Rect: TRect; Selected: Boolean; Flags: Longint);

  end;


implementation

uses Math, StrUtils;

const

  // Ustawienie poczatkowe programu
  DOMYSLNA_NAZWA_TABELI             = 'Tlumaczenia';
  DOMYSLNY_JEZYK_TLUMACZENIA        = 'ANGIELSKI';
  DOMYSLNY_NAPIS_NIEPRZETLUMACZONY  = '*?*';
  DOMYSLNY_TRYB_NIEPRZETLUMACZONY   = tNieZmieniaj;
//  DOMYSLNY_TRYB_NIEPRZETLUMACZONY   = tZmieniaj;
  DOMYSLNY_TRYB_TLUMACZENIA         = tRekurencyjny;
//  DOMYSLNY_TRYB_TLUMACZENIA         = tPojedynczy;
  DOMYSLNY_TRYB_WYSZUKIWANIA        = tNapis;
//  DOMYSLNY_TRYB_WYSZUKIWANIA        = tNapisNazwa;
//  DOMYSLNY_TRYB_WYSZUKIWANIA        = tNapisNazwaKlasa;
  DOMYSLNIE_TLUMACZYC_HINTY         = true;
  DOMYSLNE_TLUMACZENIE_GRUPOWE      = false;
  DOMYSLNY_PLIK_LOGOWANIA           = 'C:\Tlumacz.log';
  DOMYSLNIE_TWORZYC_LOG             = DOMYSLNY_TRYB_NIEPRZETLUMACZONY = tZmieniaj;
  DOMYSLNIE_TLUMACZYC_WG_TAGU       = true;

  // Ustawienia programu
  MAKSYMALNA_DLUGOSC_STRINGU        = 75;                 // Maksymalna dlugosc stringu wg jakiego jest wyszukiwane dlumaczenie (nie moze miec wiecej niz dlugosc kolumny "UNIKALNY" w bazie)
  TAG_TLUMACZENIA                   = 0;                  // Wartosc tagu ktora zezwala na tlumaczenie

var
  Objekt: TTlumacz;

{*****************************************************
    Konstruktor ustawiajacy polaczenie z tabela i
    inicjujacy wartosci domysle/

    @param  Sciezka       Sciezka do pliku z tlumaczeniami
    @param  NazwaTabeli   Nazwa tabeli zawierajace tlumaczenia
******************************************************}
constructor TTlumacz.Create(Sciezka: string; NazwaTabeli: string);
begin
  if FileExists(Sciezka+NazwaTabeli+'.DBF') then
  begin
    Tabela := TTable.Create(Application);
    with Tabela do
    begin
      Active := false;
      //DatabaseName := ExtractFileDir(ParamStr(0));
      // jednolite odwolanie do programu
      DatabaseName := Sciezka;
      TableType := ttDBase;
      TableName := NazwaTabeli;
      Active:= true;
      Open;
    end;

//    self.JezykTlumaczenia := DOMYSLNY_JEZYK_TLUMACZENIA;
//    JezykTlumaczenia := Jezyk;
    self.TrybNieprzetlumaczony  := DOMYSLNY_TRYB_NIEPRZETLUMACZONY;
    self.NapisNieprzetlumaczony := DOMYSLNY_NAPIS_NIEPRZETLUMACZONY;
    self.TrybTlumaczenia        := DOMYSLNY_TRYB_TLUMACZENIA;
    self.TrybWyszukiwania       := DOMYSLNY_TRYB_WYSZUKIWANIA;
    self.TlumaczycHinty         := DOMYSLNIE_TLUMACZYC_HINTY;
    self.TlumaczycGrupowo       := DOMYSLNE_TLUMACZENIE_GRUPOWE;
    self.TlumaczycWgTagu        := DOMYSLNIE_TLUMACZYC_WG_TAGU;
    self.TworzycLog             := DOMYSLNIE_TWORZYC_LOG;
    self.OtwartyLog             := false;

    self.UstawLogowanie(DOMYSLNIE_TWORZYC_LOG);
  end
  else
    Application.MessageBox('Nie ma pliku z tlumaczeniami','Blad',0);
  CzyRosyjskiWindows := GetSystemDefaultLangID = IDRosyjski;
end;

{*****************************************************
    Konstruktor ustawiajacy polaczenie z tabela i
    inicjujacy wartosci domysle/

    @param  NazwaTabeli   Nazwa tabeli zawierajace tlumaczenia
******************************************************}
constructor TTlumacz.Create(NazwaTabeli: string);
begin
//  self.Create(ExtractFilePath(ParamStr(0)), NazwaTabeli);
  self.Create(SciezkaWkp, NazwaTabeli);
end;

{*****************************************************
    Destruktor obiektu tlumacza
******************************************************}
destructor TTlumacz.Destroy;
begin
  with Tabela do
  begin
    Active := false;
    Close;
    Destroy;
  end;
end;

{*****************************************************
    Funkcja wzorca projektowego "Singleton" zwracajaca
    referencje do jedynego obiektu oraz tworzaca go
    jezeli nie istnieje.

    @return             Obiekt tlumacza
******************************************************}
class function TTlumacz.DajObiekt: TTlumacz;
begin
  if Objekt = nil then
    Objekt := TTlumacz.Create(DOMYSLNA_NAZWA_TABELI);
  DajObiekt := Objekt;
end;

{*****************************************************
    prodcedura konczaca dzialanie
*****************************************************}
class procedure TTlumacz.Zamknij;
begin
  if Objekt <> nil then
  begin
    Objekt.ZakonczLogowanie;
    Objekt.Destroy;
  end;
end;

function TTlumacz.JezykTlumaczenia: string;
begin
  result := Jezyk; //przepisanie z globalnej
//  result := 'ANGIELSKI';
end;

{*****************************************************
    Wlaczenie zapisywania do logu

    @param  Sciezka     Sciezka do pliku w ktorym ma byc zapisywany log
******************************************************}
procedure TTlumacz.UstawLogowanie(Sciezka: string);
begin
//  if TworzycLog then
//    CloseFile(PlikLog);   Na tym sie wywala

  AssignFile(PlikLog, Sciezka);
  Rewrite(PlikLog);
  self.TworzycLog := true;
  self.OtwartyLog := true;

  self.DoLogu('*** LOG TLUMACZENIA JEZYKOW, '+DateTimeToStr(Now)+', '+Sciezka+' ***');
  self.DoLogu('***');
end;


{*****************************************************
    Ustawienie czy zapisywac do logu

    @param  Tryb      Czy logi maja byc zapisywane.
    Jezeli nie ustawiono sciezki zostaje przydzielona domyslna
******************************************************}
procedure TTlumacz.UstawLogowanie(Tryb: boolean);
var
  Sciezka: string;
begin
  if (Tryb and not self.OtwartyLog) then
      self.UstawLogowanie(DOMYSLNY_PLIK_LOGOWANIA);

  self.TworzycLog := Tryb;
end;


{*****************************************************
    Zakonczenie wpisywania do logu i zamkniecie pliku
******************************************************}
procedure TTlumacz.ZakonczLogowanie;
begin
  if self.TworzycLog then
    CloseFile(PlikLog);
  self.TworzycLog := false;
  self.OtwartyLog := false;
end;


{*****************************************************
    Procedura zapisujaca napis do logu

    @param  Napis       Napis do zapisania
******************************************************}
procedure TTlumacz.DoLogu(Napis: string);
begin
  if self.TworzycLog then
    Writeln(PlikLog, Napis);
end;


{*****************************************************
    Funkcja tlumaczaca dany Napis na jego lokalna
    wersje z bazy danych

    @param  Napis       Uniwersalna wersja jezykowa
    @return             Przetlumaczona wersja jezykowa
******************************************************}
function TTlumacz.ZnajdzTlumaczenie(Napis: string):String;
begin
  if Napis = '' then
    Result := ''
   else
    Result := self.ZnajdzTlumaczenie(Napis, self.JezykTlumaczenia, self.Grupa);
end;


{*****************************************************
    Funkcja tlumaczaca dany Napis na jego lokalna
    wersje z bazy danych

    @param  Napis       Uniwersalna wersja jezykowa
    @param  Jezyk       Kod Jezyka    
    @return             Przetlumaczona wersja jezykowa
******************************************************}
function TTlumacz.ZnajdzTlumaczenie(Napis: string; Grupa: string):String;
begin
  ZnajdzTlumaczenie:= self.ZnajdzTlumaczenie(Napis, self.JezykTlumaczenia, Grupa);
end;


{*****************************************************
    Funkcja tlumaczaca dany Napis na jego lokalna
    wersje z bazy danych

    @param  Napis       Uniwersalna wersja jezykowa
    @param  Jezyk       Kod Jezyka
    @return             Przetlumaczona wersja jezykowa
******************************************************}
function TTlumacz.ZnajdzTlumaczenieDlaJezyka(Napis: string; Jezyk: string):String;
begin
  ZnajdzTlumaczenieDlaJezyka:= self.ZnajdzTlumaczenie(Napis, Jezyk, self.Grupa);
end;


{*****************************************************
    Funkcja tlumaczaca dany Napis na jego lokalna
    wersje z bazy danych

    @param  Napis       Uniwersalna wersja jezykowa
    @param  Jezyk       Kod Jezyka
    @param  Grupa       Nazwa Grupy
    @return             Przetlumaczona wersja jezykowa
******************************************************}
function TTlumacz.ZnajdzTlumaczenie(Napis: string; Jezyk: string; Grupa: String):String;
var
  Wynik     :Boolean;
  WynikStr  :string;
  NapisOgr  :string;
begin
  WynikStr := '';

  NapisOgr := LeftStr(Napis, MAKSYMALNA_DLUGOSC_STRINGU);

  if NapisOgr = '' then
	begin
		result := '';
		exit;
	end;

  if self.TlumaczycGrupowo then
    Wynik := Tabela.Locate('TLUMACZYC;UNIKALNY;GRUPA', VarArrayOf([true, NapisOgr, Grupa]), [loPartialKey])
  else
    //Wynik := Tabela.Locate('TLUMACZYC;UNIKALNY', VarArrayOf([true, NapisOgr]), [loPartialKey]);
    Wynik := Tabela.Locate('TLUMACZYC;UNIKALNY', VarArrayOf([true, NapisOgr]), []);

  if Wynik then
    WynikStr := Tabela.FieldByName(Jezyk).AsString
  else
    if (TrybNieprzetlumaczony = tNieZmieniaj) then
      WynikStr := NapisOgr
    else
      begin
        WynikStr := NapisNieprzetlumaczony;
        DoLogu(NapisOgr);
      end;
//  if self.TworzycLog and not wynik then
//    self.DoLogu(' * ' + 'Grupa: ' + Grupa + ', Jezyk: ' + Jezyk + ' | ' + Napis + ' -> ' + WynikStr);
//    DoLogu(NapisOgr);



{
  AssignFile(PlikLog, 'c:\tlum.log');
  Append(PlikLog);
  Writeln(PlikLog, ' * ' + 'Grupa: ' + Grupa + ', Jezyk: ' + Jezyk + ' | ' + Napis + ' -> ' + WynikStr);
  CloseFile(PlikLog);
 }

  ZnajdzTlumaczenie := WynikStr;

end;


{*****************************************************
    Funkcja tlumaczaca dany Napis na jego lokalna
    wersje z bazy danych w zaleznosci od trybu
    wyszukiwania. Wersja jezykowa zalezy od parametru
    obiektu <b>TrybWyszukiwania</b>

    @param  Napis       Uniwersalna wersja jezykowa
    @param  Objekt      Obiekt w ktorym znajduje sie napis
    @return             Przetlumaczona wersja jezykowa
******************************************************}
function TTlumacz.ZnajdzTlumaczenie(Napis: string; Objekt: TComponent):String;
var
  Znaleziono  :Boolean;
  WynikStr    :string;
  NapisOgr    :string;
begin
  WynikStr := '';

  if Napis = '' then
    begin
      result := '';
      exit;
    end;

  NapisOgr := LeftStr(Napis, MAKSYMALNA_DLUGOSC_STRINGU);

  Znaleziono := false;
  case self.TrybWyszukiwania of
  tNapis:
//    Znaleziono := Tabela.Locate('TLUMACZYC;UNIKALNY', VarArrayOf([true, Napis]), [loPartialKey]);
    Znaleziono := Tabela.Locate('TLUMACZYC;UNIKALNY', VarArrayOf([true, NapisOgr]), [loCaseInsensitive]);

  tNapisNazwa:
    Znaleziono := Tabela.Locate('TLUMACZYC;UNIKALNY;OBJ_NAZWA', VarArrayOf([true, NapisOgr, Objekt.Name]), [loPartialKey]);
  tNapisNazwaKlasa:
    Znaleziono := Tabela.Locate('TLUMACZYC;UNIKALNY;OBJ_NAZWA;OBJ_CLASS', VarArrayOf([true, NapisOgr, Objekt.Name, Objekt.ClassName]), [loPartialKey]);
  end;

  if self.TlumaczycGrupowo then
    if Tabela.FieldByName('GRUPA').AsString <> self.Grupa then
      Znaleziono:= false;

  if Znaleziono then
    WynikStr := Tabela.FieldByName(self.JezykTlumaczenia).AsString
  else
    if (TrybNieprzetlumaczony = tNieZmieniaj) then
      WynikStr := Napis
    else
      begin
        WynikStr := NapisNieprzetlumaczony;
        DoLogu(NapisOgr);
      end;

//  if self.TworzycLog then
    //self.DoLogu(' * ' + Objekt.ClassName + ':' + Objekt.Name + ' | ' + Napis + ' -> ' + WynikStr);
//    DoLogu(Napis);


{
  AssignFile(PlikLog, 'c:\tlum.log');
  Append(PlikLog);
  Writeln(PlikLog, ' * ' + Objekt.Owner.Name + ' - ' + Objekt.ClassName + ':' + Objekt.Name + ' | ' + Napis + ' -> ' + WynikStr);
  CloseFile(PlikLog);
 }

  ZnajdzTlumaczenie := WynikStr;
end;


{*****************************************************
    Funkcja sprawdzajaca w bazie danych czy mozna
    tlumaczyc nazwe danego obiektu.

    @param  Nazwa       Nazwa obiektu/komponentu
    @param  Typ         Typ obiektu/komponentu
    @return             Czy mozna tlumaczyc dany obiekt
*****************************************************}
function TTlumacz.CzyMoznaTlumaczyc(Nazwa: string; Typ:string):boolean;
begin
  if Tabela.Locate('TLUMACZYC;OBJ_CLASS;OBJ_NAZWA', VarArrayOf([false, Typ, Nazwa]), [loPartialKey]) then
    CzyMoznaTlumaczyc := false
  else
    CzyMoznaTlumaczyc := true;
end;


{*****************************************************
    Funkcja sprawdzajaca w bazie danych czy mozna
    tlumaczyc nazwe danego obiektu.

    @param  Nazwa       Nazwa obiektu/komponentu
    @return             Czy mozna tlumaczyc dany obiekt
*****************************************************}
function TTlumacz.CzyMoznaTlumaczyc(Nazwa: string):boolean;
begin
  if Tabela.Locate('TLUMACZYC;OBJ_NAZWA', VarArrayOf([false, Nazwa]), [loPartialKey]) then
    CzyMoznaTlumaczyc := false
  else
    CzyMoznaTlumaczyc := true;
end;


{*****************************************************
    Glowna rekurencyjna procedura tlumaczenia komponentow
    w danym obiekcie. Najpierw nastepuje sprawdzenie czy
    mozna tlumaczyc dany obiekt a potem nastepuje rekurencyjne
    przegladanie wszystkich obiektow i tlumaczenie ich tekstow

    @param  Objekt      Komponent do tlumaczenia
*****************************************************}
procedure TTlumacz.Tlumacz(Objekt: TComponent);
var
  Form              :TForm;
  MainMenu          :TMainMenu;
  PopupMenu         :TPopupMenu;
  Memo              :TMemo;
  ListBox           :TListBox;
  ComboBox          :TComboBox;
  RadioGroup        :TRadioGroup;
  StringGrid        :TStringGrid;
  CheckListBox      :TCheckListBox;
  PageControl       :TPageControl;
  RichEdit          :TRichEdit;
  TreeView          :TTreeView;
  StatusBar         :TStatusBar;
  HeaderControl     :THeaderControl;
  CoolBar           :TCoolBar;
//  QuickRep          :TQuickRep;
//  QRBand            :TQRBand;
//  QRChildBand       :TQRChildBand;
//  QRLabel           :TQRLabel;
//  QRMemo            :TQRMemo;
  //WS
  Diagram           :TDiagram;
  Outline           :TOutline;
  //WS

  // Dla Delphi 4.0
  {$IFDEF VER150}
  Frame         :TFrame;
  ComboBoxEx    :TComboBoxEx;
  {$ENDIF}

  i,j     :Integer;
  Itmp    :Integer;
  StrLog  :string;
  temps   :string;
begin
{
  if self.TworzycLog then
    self.DoLogu(' > ' + Objekt.ClassName + ':' + Objekt.Name + ' > START');
 }
{
  AssignFile(PlikLog, 'c:\tlum.log');
  Append(PlikLog);
  Writeln(PlikLog, ' > ' + Objekt.ClassName + ':' + Objekt.Name + ' > START');
  CloseFile(PlikLog);

 }

  // Sprawdzenie czy mozna tlumaczyc dany obiekt
  if self.TlumaczycWgTagu then
    if Objekt.Tag <> self.TagTlumaczenia then
      exit;

  if self.TrybWyszukiwania = tNapisNazwa then
    if not self.CzyMoznaTlumaczyc(Objekt.Name) then
      exit;

  if self.TrybWyszukiwania = tNapisNazwaKlasa then
    if not self.CzyMoznaTlumaczyc(Objekt.Name, Objekt.ClassName) then
      exit;

  if ((Objekt is TControl) and self.TlumaczycHinty) then
    TControl(Objekt).Hint := self.ZnajdzTlumaczenie(TControl(Objekt).Hint);

// wylaczone MS
//  if self.TworzycLog then
//    self.DoLogu(' > ' + Objekt.ClassName + ':' + Objekt.Name + ' > MOZNA TLUMACZYC');

  {***************************************************
    STANDARD CONTROL
  ****************************************************}
  // TForm
  if Objekt is TForm then
  begin
    Form := TForm(Objekt);
    if GetOwnerDraw then
       form.OnPaint := Maluj;
    Form.Caption := self.ZnajdzTlumaczenie(Form.Caption, Objekt);
    Form.Font.Charset := GetCharSet;  //MS 080819
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to Form.ComponentCount-1 do
        self.Tlumacz(Form.Components[i]);
  end;

  // TMainMenu
  temps:= Objekt.ClassName;
  if Objekt.ClassName = 'TMainMenu' then
  begin
    temps:= temps + 's';
    MainMenu := TMainMenu(Objekt);
    MainMenu.OwnerDraw := GetOwnerDraw;
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to MainMenu.ComponentCount-1 do
        self.Tlumacz(MainMenu.Components[i]);
  end;

  //TPopupMenu
  if Objekt.ClassName = 'TPopupMenu' then
  begin
    PopupMenu := TPopupMenu(Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to PopupMenu.ComponentCount-1 do
        self.Tlumacz(PopupMenu.Components[i]);
  end;

  // TLabel
  if Objekt.ClassName = 'TLabel' then
    begin
      TLabel(Objekt).Caption := self.ZnajdzTlumaczenie(TLabel(Objekt).Caption, Objekt);
      TLabel(Objekt).Font.Charset := GetCharSet;  //MS 080819
    end;

  //TEdit
  if Objekt.ClassName = 'TEdit' then
     if (not IsNumeric(TEdit(Objekt).Text))and(TEdit(Objekt).Text<>'') then
        TEdit(Objekt).Text := self.ZnajdzTlumaczenie(TEdit(Objekt).Text, Objekt);


  //TMemo
  if Objekt.ClassName = 'TMemo' then
  begin
    Memo := TMemo(Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to Memo.Lines.Count-1 do
        Memo.Lines.Strings[i] := self.ZnajdzTlumaczenie(Memo.Lines.Strings[i], Objekt);
  end;

  // TButton
  if Objekt.ClassName = 'TButton' then
    begin
      TButton(Objekt).Caption := self.ZnajdzTlumaczenie(TButton(Objekt).Caption, Objekt);
      TButton(Objekt).Font.Name := GetFontName;
      TButton(Objekt).Font.Charset := GetCharSet;  //MS 080819
    end;

  // TCheckBox
//  if Objekt is TCheckBox then
  if Objekt.ClassName = 'TCheckBox' then
    begin
      TCheckBox(Objekt).Caption := self.ZnajdzTlumaczenie(TCheckBox(Objekt).Caption, Objekt);
      TCheckBox(Objekt).Font.Name    := GetFontName;
      TCheckBox(Objekt).Font.Charset := GetCharSet;  //MS 080819
    end;
  // TRadioButton
  if Objekt.ClassName = 'TRadioButton' then
    begin
      TRadioButton(Objekt).Caption := self.ZnajdzTlumaczenie(TRadioButton(Objekt).Caption, Objekt);
      TRadioButton(Objekt).Font.Name    := GetFontName;
      TRadioButton(Objekt).Font.Charset := GetCharSet;  //MS 080819
    end;

  // TListBox
  if Objekt.ClassName = 'TListBox' then
  begin
    ListBox := TListBox(Objekt);
    ListBox.Font.Name    := GetFontName;
    ListBox.Font.Charset := GetCharSet;  //MS 080819
    if GetOwnerDraw then
       ListBox.Style := lbOwnerDrawFixed
     else
       ListBox.Style := lbStandard;
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to ListBox.Items.Count-1 do
        ListBox.Items[i] := self.ZnajdzTlumaczenie(ListBox.Items[i], Objekt);
  end;

  // TListBox
  if Objekt.ClassName = 'TComboBox' then
  begin
    ComboBox := TComboBox(Objekt);
    Itmp := ComboBox.ItemIndex;
    ComboBox.Font.Charset := GetCharSet;  //MS 080819
    ComboBox.Text := self.ZnajdzTlumaczenie(ComboBox.Text, Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      // tu przelacza itemIndex na -1 ???? MS 090303
      for i:=0 to ComboBox.Items.Count-1 do
        ComboBox.Items[i] := self.ZnajdzTlumaczenie(ComboBox.Items[i], Objekt);
    ComboBox.ItemIndex := Itmp;   // przywracanie wybranej wartosci
  end;

  // TGroupBox
  if Objekt.ClassName = 'TGroupBox' then
    begin
      TGroupBox(Objekt).Caption := self.ZnajdzTlumaczenie(TGroupBox(Objekt).Caption, Objekt);
      TGroupBox(Objekt).Font.Name := GetFontName;
      TGroupBox(Objekt).Font.Charset := GetCharSet;  //MS 080819
      //ws 300908
      if self.TrybTlumaczenia = tRekurencyjny then
        for i:=0 to TGroupBox(Objekt).ComponentCount - 1 do
            self.Tlumacz(TGroupBox(Objekt).Components[i]);
      //ws 300908
    end;

  // TRadioGroup
  if Objekt.ClassName = 'TRadioGroup' then
  begin
    RadioGroup := TRadioGroup(Objekt);
    RadioGroup.Caption := self.ZnajdzTlumaczenie(RadioGroup.Caption, Objekt);
    RadioGroup.Font.Charset := GetCharSet;  //MS 080819
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to RadioGroup.Items.Count-1 do
        RadioGroup.Items[i] := self.ZnajdzTlumaczenie(RadioGroup.Items[i], Objekt);
  end;

  // TPanel
  if Objekt.ClassName = 'TPanel' then
    begin
      TPanel(Objekt).Caption := self.ZnajdzTlumaczenie(TPanel(Objekt).Caption, Objekt);
      TPanel(Objekt).Font.Charset := GetCharSet;  //MS 080819
    end;

  // TMenuItem
  if Objekt.ClassName = 'TMenuItem' then
  begin
    TMenuItem(Objekt).Caption := self.ZnajdzTlumaczenie(TMenuItem(Objekt).Caption, Objekt);
    if GetCharSet = RUSSIAN_CHARSET then
    begin
      TMenuItem(Objekt).OnDrawItem := DoDrawMenuItem;
      TMenuItem(Objekt).OnMeasureItem := DoMasureMenuItem;
    end;
    if TMenuItem(Objekt).Count > 0  then
       for i:= 0 to TMenuItem(Objekt).Count -1 do self.Tlumacz(TMenuItem(Objekt).Items[i] );
  end;


  {***************************************************
    ADDITIONAL CONTROL
  ****************************************************}

  // TBitBtn
  if Objekt.ClassName = 'TBitBtn' then
  begin
    TBitBtn(Objekt).Font.Name := GetFontName;
    TBitBtn(Objekt).Font.Charset := GetCharSet;
    TBitBtn(Objekt).Caption := self.ZnajdzTlumaczenie(TBitBtn(Objekt).Caption, Objekt);
  end;

  // TSpeedButton
  if Objekt.ClassName = 'TSpeedButton' then
  begin
    TSpeedButton(Objekt).Font.Name := GetFontName;
    TSpeedButton(Objekt).Font.Charset := GetCharSet;
    TSpeedButton(Objekt).Caption := self.ZnajdzTlumaczenie(TSpeedButton(Objekt).Caption, Objekt);
  end;

  // TStringGrid
  //if Objekt.ClassName = 'TCustomGrid' then    // Zmienil WS 01102008
  if Objekt.ClassName = 'TStringGrid' then
  begin
    StringGrid := TStringGrid(Objekt);
    if GetCharSet = RUSSIAN_CHARSET then
       StringGrid.Font.Name := GetFontName;
    StringGrid.Font.Charset := GetCharSet;
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to StringGrid.ColCount-1 do
        for j:= 0 to StringGrid.RowCount-1 do
          StringGrid.Cells[i, j] := self.ZnajdzTlumaczenie(StringGrid.Cells[i, j]);
  end;

  if Objekt is TDBGrid then
  begin
    for i:=0 to TDBGrid(Objekt).Columns.Count - 1 do
    begin
        TDBGrid(Objekt).Columns[i].Title.Caption := self.ZnajdzTlumaczenie(TDBGrid(Objekt).Columns[i].Title.Caption);
        if GetCharSet = RUSSIAN_CHARSET then
        begin
          TDBGrid(Objekt).Columns[i].Title.Font.Name    := GetFontName;
          TDBGrid(Objekt).Columns[i].Title.Font.Charset := GetCharSet;
       end;
    end;
  end;

  // TCheckListBox
  if Objekt.ClassName = 'TCheckListBox' then
  begin
    CheckListBox := TCheckListBox(Objekt);
    CheckListBox.Font.Charset := GetCharSet;
    CheckListBox.Font.Name := GetFontName;
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to CheckListBox.Items.Count-1 do
        CheckListBox.Items[i] := self.ZnajdzTlumaczenie(CheckListBox.Items[i], Objekt);
  end;

  // TStaticText
  if Objekt.ClassName = 'TStaticText' then
    TStaticText(Objekt).Caption := self.ZnajdzTlumaczenie(TStaticText(Objekt).Caption, Objekt);

  {***************************************************
    WIN32 CONTROL
  ****************************************************}
  // TPageControl
  if Objekt.ClassName = 'TPageControl' then
  begin
    PageControl := TPageControl(Objekt);
    PageControl.Font.Charset := GetCharSet;
    PageControl.OwnerDraw := GetOwnerDraw;
    if PageControl.OwnerDraw then PageControl.OnDrawTab := pcDrawTab;
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to PageControl.PageCount-1 do
      begin
         PageControl.Pages[i].Font.Charset := GetCharSet;
         PageControl.Pages[i].Caption := self.ZnajdzTlumaczenie(PageControl.Pages[i].Caption, PageControl.Pages[i]);
         self.Tlumacz(PageControl.Pages[i]);
      end;
  end;

  // TRichEdit
  if Objekt.ClassName = 'TRichEdit' then
  begin
    RichEdit := TRichEdit(Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to RichEdit.Lines.Count-1 do
        RichEdit.Lines[i] := self.ZnajdzTlumaczenie(RichEdit.Lines[i], Objekt);
  end;

  // TOutline
  if Objekt.ClassName = 'TOutline' then
  begin
    Outline := TOutline(Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=1 to Outline.ItemCount do
        Outline.Items[i].Text := self.ZnajdzTlumaczenie(Outline.Items[i].Text, Objekt);
  end;

  if Objekt.ClassName = 'TTreeView' then
  begin
    TreeView := TTreeView(Objekt);
    if GetCharSet = RUSSIAN_CHARSET then
    TreeView.Font.Name := GetFontName;
    TreeView.Font.Charset := GetCharSet;
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to TreeView.Items.Count-1 do
        TreeView.Items.Item[i].Text := self.ZnajdzTlumaczenie(TreeView.Items.Item[i].Text, Objekt);
  end;

  // THeaderControl
  if Objekt.ClassName = 'THeaderControl' then
  begin
    HeaderControl := THeaderControl(Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to HeaderControl.Sections.Count-1 do
        HeaderControl.Sections.Items[i].Text := self.ZnajdzTlumaczenie(HeaderControl.Sections.Items[i].Text, Objekt);
  end;

  // TStatusBar
  If Objekt.ClassName = 'TStatusBar' then
  begin
    StatusBar := TStatusBar(Objekt);
    StatusBar.Font.Name    := GetFontName;
    StatusBar.Font.Charset := GetCharSet;
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to StatusBar.Panels.Count-1 do
        StatusBar.Panels.Items[i].Text := self.ZnajdzTlumaczenie(StatusBar.Panels.Items[i].Text, Objekt);
  end;

  // TCoolBar
  If Objekt.ClassName = 'TCoolBar' then
  begin
    CoolBar := TCoolBar(Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to CoolBar.Bands.Count-1 do
        CoolBar.Bands.Items[i].Text := self.ZnajdzTlumaczenie(CoolBar.Bands.Items[i].Text, Objekt);
  end;

  {***************************************************
    TYLKO DLA DELPHI 7.0
  ****************************************************}

  {$IFDEF VER150}
  // TFrame
  if Objekt is TFrame then
//  if Objekt.ClassName = 'TFrame' then
  begin
    Frame := TFrame(Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to Frame.ComponentCount-1 do
        self.Tlumacz(Frame.Components[i]);
  end;

  // TLabeledEdit
//  if Objekt is TLabeledEdit then
  if Objekt.ClassName = 'TLabeledEdit' then
    with TLabeledEdit(Objekt) do
    begin
      Text := self.ZnajdzTlumaczenie(Text, Objekt);
      EditLabel.Caption := self.ZnajdzTlumaczenie(EditLabel.Caption, Objekt);
    end;

  // TComboBoxEx
//  if Objekt is TComboBoxEx then
  if Objekt.ClassName = 'TComboBoxEx' then
  begin
    ComboBoxEx := TComboBoxEx(Objekt);
    Itmp := ComboBoxEx.ItemIndex;
    ComboBoxEx.Text := self.ZnajdzTlumaczenie(ComboBoxEx.Text, Objekt);
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to ComboBoxEx.ItemsEx.Count-1 do
        ComboBoxEx.ItemsEx.Items[i].Caption := self.ZnajdzTlumaczenie(ComboBoxEx.ItemsEx.Items[i].Caption, Objekt);
    ComboBoxEx.ItemIndex := Itmp; // przywracanie wybranej wartosci
  end;
  {$ENDIF}

  {***************************************************
    QUICK REPORTS
  ****************************************************}

  // TQuickRep
//  if Objekt is TQuickRep then
//  begin
//    QuickRep := TQuickRep(Objekt);
//    QuickRep.ReportTitle := self.ZnajdzTlumaczenie(QuickRep.ReportTitle, Objekt);
//    if self.TrybTlumaczenia = tRekurencyjny then
//      for i:=0 to QuickRep.BandList.Count-1 do
//        self.Tlumacz(TQRBand(QuickRep.BandList[i]));
//  end;

  // TQRBand
//  if Objekt.ClassName = 'TQRBand' then
//  begin
//    QRBand := TQRBand(Objekt);
//    if self.TrybTlumaczenia = tRekurencyjny then
//      for i:=0 to QRBand.ControlCount-1 do
//        self.Tlumacz(QRBand.Controls[i]);
//  end;

  // TQRChildBand
//  if Objekt.ClassName = 'TQRChildBand' then
//  begin
//    QRChildBand := TQRChildBand(Objekt);
//    if self.TrybTlumaczenia = tRekurencyjny then
//      for i:=0 to QRChildBand.ControlCount-1 do
//        self.Tlumacz(QRChildBand.Controls[i]);
//  end;

  // TQRLabel
//  if Objekt.ClassName = 'TQRLabel' then
//  begin
//    QRLabel := TQRLabel(Objekt);
//    if self.TrybTlumaczenia = tRekurencyjny then
//    begin
//      QRLabel.Caption := self.ZnajdzTlumaczenie(QRLabel.Caption, Objekt);
//      QRLabel.Font.Charset := GetCharSet;
//    end;
//  end;

  // TQRMemo
//  if Objekt.ClassName = 'TQRMemo' then
//  begin
//    QRMemo := TQRMemo(Objekt);
//    QRMemo.Font.Name    := GetFontName;
//    QRMemo.Font.Charset := GetCharSet;
//    if self.TrybTlumaczenia = tRekurencyjny then
//      for i:=0 to QRMemo.Lines.Count-1 do
//        QRMemo.Lines[i] := self.ZnajdzTlumaczenie(trim(QRMemo.Lines[i]), Objekt);
//  end;

  // TDiagram
  // Dopisal WS
  if Objekt.ClassName = 'TDiagram' then
  begin
    Diagram := TDiagram(Objekt);
    Diagram.Font.Charset := GetCharSet;  
    if self.TrybTlumaczenia = tRekurencyjny then
      for i:=0 to Diagram.FunCount - 1 do
        if (Diagram.Items[i].ClassName = 'TDiagDescr')and (Diagram.Items[i].Tag = 0) then
           TDiagDescr(Diagram.Items[i]).Text := self.ZnajdzTlumaczenie(TDiagDescr(Diagram.Items[i]).Text, Objekt);
  end;
  //WS

// wylaczone MS
//  if self.TworzycLog then
//    self.DoLogu(' > ' + Objekt.ClassName + ':' + Objekt.Name + ' > PRZETLUMACZONO');

end;


{*****************************************************
    Funkcja tlumaczaca aplikacje ze wszystkimi jej
    komponentami

    @param  Aplikacja   Aplikacja do tlumaczenia
*****************************************************}
procedure TTlumacz.Tlumacz(Aplikacja: TApplication);
var
  i: Integer;
begin
  If self.TrybTlumaczenia = tRekurencyjny then
    for i:=0 to Aplikacja.ComponentCount-1 do
      Self.Tlumacz(Aplikacja.Components[i]);
end;


{*****************************************************
    Funkcja tlumaczaca aplikacje ze wszystkimi jej
    komponentami
*****************************************************}
procedure TTlumacz.Tlumacz;
begin
  self.Tlumacz(Application);
end;



function TTlumacz.IsNumeric(s: string): boolean;
var v : double;
    i : Integer;
begin
  Val(s,v,i);
  result := i = 0;
end;

function TTlumacz.GetCharSet: TFontCharset;
begin
 if JezykTlumaczenia = 'ROSYJSKI' then
    result := RUSSIAN_CHARSET
 else
    result := DEFAULT_CHARSET;
end;

procedure TTlumacz.DoDrawMenuItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);

  procedure DoDrawText(ACanvas: TCanvas; const ACaption: string;
      var Rect: TRect; Selected: Boolean; Flags: Longint);
  begin
    TDummyMenuItem(Sender).DoDrawText(ACanvas, ACaption, Rect, Selected, Flags );
  end;

const
  Alignments: array[TPopupAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
  EdgeStyle: array[Boolean] of Longint = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
var
  TopLevel: Boolean;
  ImageList: TCustomImageList;
  ParentMenu: TMenu;
  Alignment: TPopupAlignment;
  DrawImage, DrawGlyph: Boolean;
  GlyphRect, SaveRect: TRect;
  DrawStyle: Longint;
  Glyph: TBitmap;
  OldBrushColor: TColor;

begin
  if not (Sender is TMenuItem) then
    EXIT;
  with TMenuItem(Sender) do
  begin
    ParentMenu := GetParentMenu;
    TopLevel := GetParentComponent is TMainMenu;
    with ACanvas do
    begin
      Font.name := GetFontName;
      Font.Charset := RUSSIAN_CHARSET;
      ImageList := ParentMenu.Images;
      if not Selected then FillRect(ARect);
      if ParentMenu is TMenu then
        Alignment := paLeft
      else if ParentMenu is TPopupMenu then
        Alignment := TPopupMenu(ParentMenu).Alignment
      else
        Alignment := paLeft;
      GlyphRect.Left := ARect.Left + 1;
      GlyphRect.Top := ARect.Top + 1;
      if Caption = '-' then
      begin
        FillRect(ARect);
        GlyphRect.Left := 0;
        GlyphRect.Right := -4;
        DrawGlyph := False;
      end
      else
      begin
        DrawImage := (ImageList <> nil) and ((ImageIndex > -1) and
          (ImageIndex < ImageList.Count) or Checked and ((Bitmap = nil) or
          Bitmap.Empty));
        if DrawImage or Assigned(Bitmap) and not Bitmap.Empty then
        begin
          DrawGlyph := True;

          if DrawImage then
          begin
            GlyphRect.Right := GlyphRect.Left + ImageList.Width;
            GlyphRect.Bottom := GlyphRect.Top + ImageList.Height;
          end
          else
          begin
            { Need to add BitmapWidth/Height properties for TMenuItem if we're to
              support them.  Right now let's hardcode them to 16x16. }
            GlyphRect.Right := GlyphRect.Left + 16;
            GlyphRect.Bottom := GlyphRect.Top + 16;
          end;

          { Draw background pattern brush if selected }
          if Checked then
          begin
            Inc(GlyphRect.Right);
            Inc(GlyphRect.Bottom);
            OldBrushColor := Brush.Color;
            if not Selected then
            begin
              OldBrushColor := Brush.Color;
              Brush.Bitmap := AllocPatternBitmap(clBtnFace, clBtnHighlight);
              FillRect(GlyphRect);
            end
            else
            begin
              Brush.Color := clBtnFace;
              FillRect(GlyphRect);
            end;
            Brush.Color := OldBrushColor;
            Inc(GlyphRect.Left);
            Inc(GlyphRect.Top);
          end;

          if DrawImage then
          begin
            if (ImageIndex > -1) and (ImageIndex < ImageList.Count) then
              ImageList.Draw(ACanvas, GlyphRect.Left, GlyphRect.Top, ImageIndex,
                Enabled)
            else
            begin
              { Draw a menu check }
              Glyph := TBitmap.Create;
              try
                Glyph.Transparent := True;
                Glyph.Handle := LoadBitmap(0, PChar(OBM_CHECK));
                OldBrushColor := Font.Color;
                Font.Color := clBtnText;
                Draw(GlyphRect.Left + (GlyphRect.Right - GlyphRect.Left - Glyph.Width) div 2 + 1,
                  GlyphRect.Top + (GlyphRect.Bottom - GlyphRect.Top - Glyph.Height) div 2 + 1, Glyph);
                Font.Color := OldBrushColor;
              finally
                Glyph.Free;
              end;
            end;
          end
          else
          begin
            SaveRect := GlyphRect;
            { Make sure image is within glyph bounds }
            if Bitmap.Width < GlyphRect.Right - GlyphRect.Left then
              with GlyphRect do
              begin
                Left := Left + ((Right - Left) - Bitmap.Width) div 2 + 1;
                Right := Left + Bitmap.Width;
              end;
            if Bitmap.Height < GlyphRect.Bottom - GlyphRect.Top then
              with GlyphRect do
              begin
                Top := Top + ((Bottom - Top) - Bitmap.Height) div 2 + 1;
                Bottom := Top + Bitmap.Height;
              end;
            StretchDraw(GlyphRect, Bitmap);
            GlyphRect := SaveRect;
          end;

          if Checked then
          begin
            Dec(GlyphRect.Right);
            Dec(GlyphRect.Bottom);
          end;
        end
        else
        begin
          if (ImageList <> nil) and not TopLevel then
          begin
            GlyphRect.Right := GlyphRect.Left + ImageList.Width;
            GlyphRect.Bottom := GlyphRect.Top + ImageList.Height;
          end
          else
          begin
            GlyphRect.Right := GlyphRect.Left;
            GlyphRect.Bottom := GlyphRect.Top;
          end;
          DrawGlyph := False;
        end;
      end;
      with GlyphRect do
      begin
        Dec(Left);
        Dec(Top);
        Inc(Right, 2);
        Inc(Bottom, 2);
      end;

      if Checked or Selected and DrawGlyph then
        DrawEdge(Handle, GlyphRect, EdgeStyle[Checked], BF_RECT);

      if Selected then
      begin
        if DrawGlyph then ARect.Left := GlyphRect.Right + 1;
        Brush.Color := clHighlight;
        FillRect(ARect);
      end;
      if not Selected or not DrawGlyph then
        ARect.Left := GlyphRect.Right + 1;
      Inc(ARect.Left, 2);
      Dec(ARect.Right, 1);

      DrawStyle := DT_EXPANDTABS or DT_SINGLELINE or Alignments[Alignment];
      { Calculate vertical layout }
      SaveRect := ARect;
      DoDrawText(ACanvas, Caption, ARect, Selected,
                                 DrawStyle or DT_CALCRECT or DT_NOCLIP);
      OffsetRect(ARect, 0, ((SaveRect.Bottom - SaveRect.Top) - (ARect.Bottom - ARect.Top)) div 2);
      DoDrawText(ACanvas, Caption, ARect, Selected, DrawStyle);
      if (ShortCut <> 0) and not TopLevel then
      begin
        ARect.Left := ARect.Right;
        ARect.Right := SaveRect.Right - 10;
        DoDrawText(ACanvas, ShortCutToText(ShortCut), ARect, Selected, DT_RIGHT);
      end;
    end;

  end;
end;

procedure TTlumacz.DoMasureMenuItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
begin
  if not (Sender is TMenuItem) then
    EXIT;

  with TMenuItem(Sender) do
  begin
    ACanvas.Font.name := GetFontName;
    ACanvas.Font.Charset := RUSSIAN_CHARSET;
    Width := ACanvas.TextWidth(Caption) + 3;
    if (Parent <> NIL) and (Parent.Parent <> NIL) then
    begin
      //inc(Width, 16);
      if Count > 0 then
        inc(Width, 16);
      if ShortCut <> 0 then
        inc(Width, 10 + ACanvas.TextWidth(ShortCutToText(ShortCut)));
    end;

  end;

end;

procedure TTlumacz.Maluj(Sender: TObject);
var
  LogFont: TLogFont;
  tmpCanvas: TCanvas;
  ACanvas: TCanvas;

  { ******* niedziala
  function SzukajFormy(S : TObject): HWND;
  var b : TObject;
  begin
   b := S;
   while true do
   begin
     if b= nil then result := 0
        else if b is TForm then
                            begin
                              result := TForm(s).Handle;
                              exit
                            end
                     else
                         b:= Tcomponent(b).owner;
   end;
  end;               }

begin
  tmpCanvas := TCanvas.Create;
  tmpCanvas.Handle := GetWindowDc(0);
  GetObject(tmpCanvas.Font.Handle, SizeOf(LogFont), @LogFont);


  ACanvas := TCanvas.Create;
  try
    ACanvas.Handle := GetWindowDC(TForm(Sender).Handle);
    with ACanvas do
    begin
      Brush.Style := bsClear;
      Font.Name := GetFontName;
      Font.Size := -LogFont.lfHeight;
      Font.Color := GetSysColor(COLOR_CAPTIONTEXT);
      Font.Style := [fsBold];
      Font.Charset := TForm(Sender).Font.Charset;
      FillRect(Rect(0,0,TForm(Sender).Width,GetSystemMetrics(SM_CYCAPTION)));
      SetBkMode(ACanvas.Handle,OPAQUE);
      SetBkColor(ACanvas.Handle,GetSysColor(COLOR_ACTIVECAPTION));
      TextOut(GetSystemMetrics(SM_CYMENU) + GetSystemMetrics(SM_CXBORDER)+5,
        Round((GetSystemMetrics(SM_CYCAPTION) - Abs(Font.Height)) / 2-3) + 5, TForm(Sender).Caption );
    end;
  finally
    ReleaseDC(TForm(Sender).Handle, ACanvas.Handle);
    ACanvas.Free;
  end;
  tmpCanvas.Free;
end;

{ TDummyMenuItem }

procedure TDummyMenuItem.DoDrawText(ACanvas: TCanvas;
  const ACaption: string; var Rect: TRect; Selected: Boolean;
  Flags: Integer);
begin
  inherited;
end;

procedure TTlumacz.pcDrawTab(Control: TCustomTabControl; TabIndex: Integer;
  const Rect: TRect; Active: Boolean);
var aRect : TRect;
begin
 aRect:=Rect;
// Control.Canvas.Brush.Color :=  TPageControl(Secder).Canvas.Brush.Color;
 OffsetRect(aRect,2,2);
 Control.Canvas.FillRect(aRect);
 DrawText(Control.Canvas.Handle,PChar(TPageControl(Control).Pages[TabIndex].Caption),
         -1,aRect,DT_LEFT or DT_SINGLELINE or DT_CALCRECT);
 if aRect.Right > rect.Right then
  Control.Canvas.Font.Size := Control.Canvas.Font.Size -1;
  DrawText(Control.Canvas.Handle,PChar(TPageControl(Control).Pages[TabIndex].Caption),
         -1,aRect,DT_LEFT or DT_SINGLELINE );
end;

function TTlumacz.GetOwnerDraw: boolean;
begin
 result := (GetCharSet = RUSSIAN_CHARSET) and (not CzyRosyjskiWindows);
end;

function TTlumacz.GetFontName: String;
begin
 if GetOwnerDraw then
    result := 'Arial'
  else
    result := 'MS Sans Serif';
end;

end.
