unit WkpGlob;
{----------------------------------------------------------------------
|  Modul zawierajacy zmienne globalne oraz procedury do ich obslugi    |
|  Zarzadzanie aplikacja na podstawie ZETON'a                          |
 ----------------------------------------------------------------------}

interface

uses
  Controls,
  SysUtils,
  IniFiles,
  Registry,
  Kr_Sys,
  TbsU,
  Dialogs
  ;

type
  TUidQ = (lns, m3h, lnm, m3m, m3s);

var
  SciezkaWkp       : string;
  SciezkaWkpArchiwum : string;
  //SciezkaBaz       : string;   // w TbsU.pas
  SciezkaZasob     : string;
  SciezkaBmp       : string;
  WkpIniFileName   : string;
  WkpIni           : TCustomIniFile;
  UsrReg           : TRegistry;

  Firm1      : string;
  Firm2      : string;
  Firm3      : string;
  Projektant : string;

  UidQ             : TUidQ;
                   //  : string;   // identyfikator jednostek Q <domyslne - m3/h>
                               // 'lns'  [l/s]
                               // 'm3h'  [m3/h]
                               // 'lnm'  [l/min]
                               // 'm3m'  [m3/min]

  Jezyk             : string; // Jezyk programu

(************************************)
(* Flagi do ustawiania w zetonie    *)
(************************************)
  FiltryZezw       : Boolean;     // Zezwolenie na filtry
  PmpSchowki       : Boolean;     // Kopiuj , Zapisz jako
  PmpCharSkaner    : Boolean;     // Skaner charakterystyk
  TesterZezw       : Boolean;
  CHar4PolaZezw    : Boolean;
  ExportEpanet     : Boolean;     // eksportowanie krzywych do Epaneta

  SiecZezw         : Boolean;


  WerProdPomp      : Boolean;     //true - wersja producencka
                                  //false - wersja Z wieloma prod ?? jaka jest relacja do PRO
  GlobProdId       : string;
  KluczePompIni    : TCustomIniFile;
  PrzeglDokowane   : Boolean;
  WerPro           : Boolean;
  WersjaStr        : string;
  WlLic            : string;
  Lic              : array [1..4] of string;

  SfpOgr           : Boolean = true;



type
  IniException = class(Exception);

function m3hToU(val:double):double;
function CapQ:string;
function UTom3h(val:double):double;
procedure ZapamietajKatalogZapisu(katalog: string);

implementation

function m3hToU(val:double):double;
begin
  case UidQ of
    lns : result := val*1000/3600; //zamienia m3/h na l/s
    lnm : result := val*1000/60;   //zamienia m3/h na l/min
    m3h : result := val;
    m3m : result := val/60;        //zamienia m3/h na m3/min
    m3s : result := val/3600;      //zamienia m3/h na m3/s
    else
      result := val;
  end;
end;

function UTom3h(val:double):double;
begin
  case UidQ of
    lns : result := val/1000*3600;  //zamienia l/s    na m3/h
    lnm : result := val/1000*60;    //zamienia l/min  na m3/h
    m3h : result := val;
    m3m : result := val*60;         //zamienia m3/min na m3/h
    m3s : result := val*3600;       //zamienia m3/h na m3/s
    else
      result := val;
  end;
end;

function CapQ:string;
begin
  case UidQ of
    lns : result := '[l/s]';
    lnm : result := '[l/min]';
    m3h : result := '[m3/h]';
    m3m : result := '[m3/min]';
    m3s : result := '[m3/s]';
    else
      result := '[m3/h]';
  end;
end;

procedure Done;
begin
//  WkpIni.UpdateFile;
  WkpIni.Free;
  UsrReg.CloseKey;
  UsrReg.Free;
end;

procedure AutoInit;
var
  v1, v2, v3, v4 :Word;
  s1, s2 :string;
  i      :Integer;
begin
  UsrReg := TRegistry.Create;
  UsrReg.OpenKey( '\Software\TBS\Katalog', true );
  ProdBlok := ZetonFile.ReadBool( 'Katalog', 'ProdBlok', true );
  if ProdBlok then
    DozwProducenci := UpperCase(
                          ZetonFile.ReadString( 'Katalog',
                                                'DozwProducenci', ''
                                              ));
  WerProdPomp := ZetonFile.ReadBool( 'Katalog',
                                     'KatPompProd',
                                     false );
  WerPro := ZetonFile.ReadBool( 'Katalog', 'Pro', false );
  if WerPro then
  begin
    WlLic := ZetonFile.ReadString('Licencja KatalogPRO1', 'Wlasciciel', '??');
    //if WlLic = '??' then
    //begin
    //  ShowMessage('Brak licencji');
    //  Halt(1);
    //end;
    for i := 1 to 4 do
      Lic[i] := ZetonFile.ReadString( 'Licencja KatalogPRO1',
                                      IntToStr(i), '');
  end;

  PrzeglDokowane := ZetonFile.ReadBool( 'Katalog\Pompy',
                                        'PrzeglDokowane',
                                        false );

  SciezkaWkp := ExtractFilePath(ParamStr(0));       // Sciezka do naz w katalogu programu - domyslna jezeli nie ma innej w WKP_Glog

  SciezkaBmp := Format( '%sbmp/', [SciezkaWkp] );

  WkpIniFileName := SciezkaWkp + 'WKP.INI';
  if not FileExists( WkpIniFileName ) then
  begin
    {ERROR: Program nie zainstalowany}
     raise IniException.Create('');
  end;
  WkpIni := TMemIniFile.Create(WkpIniFileName);

  if WerProdPomp then
  begin
    GlobProdId := ZetonFile.ReadString( 'Katalog', 'ProducentPomp', '' );
  end
  else
  begin
    KluczePompIni := WkpIni;
    SciezkaZasob := SciezkaWkp;
  end;

  SciezkaBaz := WkpIni.ReadString( 'Producenci', 'DefaultPath', '??' );
  if not UsrReg.ValueExists('KatalogArchiwum') then
     SciezkaWkpArchiwum := SciezkaWkp + 'Archiwum'
   else
     SciezkaWkpArchiwum := UsrReg.ReadString('KatalogArchiwum');

  if SciezkaBaz = '??' then
  begin
    {ERROR: Program nie zainstalowany}
    {raise IniException.Create('');}
    SciezkaBaz := SciezkaWkp;
  end;
  if StrRight( SciezkaBaz, 1 ) = '\' then
  begin
    SciezkaBaz := StrButLast(SciezkaBaz,1);
  end;

  if UsrReg.ValueExists('KatalogFirma1') then
    Firm1 := UsrReg.ReadString('KatalogFirma1')
  else
    Firm1 := 'Grundfos Pompy Sp. z o.o.';
  if UsrReg.ValueExists('KatalogFirma2') then
    Firm2 := UsrReg.ReadString('KatalogFirma2')
  else
    Firm2 := 'ul. Klonowa 23, Baranowo k.Poznania';
  if UsrReg.ValueExists('KatalogFirma3') then
    Firm3 := UsrReg.ReadString('KatalogFirma3')
  else
    Firm3 := '62-081 Przeümierowo';
  if UsrReg.ValueExists('KatalogProjektant') then
    Projektant := UsrReg.ReadString('KatalogProjektant')
  else
    Projektant := '. . . . . .';


  FiltryZezw    := ZetonFile.ReadBool( 'Katalog', 'Filtry', false );
  PmpSchowki    := ZetonFile.ReadBool( 'Katalog\Pompy', 'Schowki', false );
  PmpCharSkaner := ZetonFile.ReadBool( 'Katalog\Pompy', 'skaner', false );
  TesterZezw    := ZetonFile.ReadBool( 'Katalog\Pompy', 'Tester', false );
  CHar4PolaZezw := ZetonFile.ReadBool( 'Katalog\Pompy', 'CHar4Pola', false );
  ExportEpanet  := ZetonFile.ReadBool( 'Katalog\Pompy', 'ExportEpa', false );

  GetFileVersion( v1, v2, v3, v4 );
  if WerProdPomp then
    s1 := GlobProdId
  else
    s1 := '';
  if WerPro then
    s2 := 'Pro'
  else
    s2 := '';

  WersjaStr := Format( '%d.%d.%d %s %s  (kompilacja %d)',
                       [v1, v2, v3, s1, s2, v4]);

end;

procedure ZapamietajKatalogZapisu(katalog: string);
begin
 UsrReg.OpenKey('\Software\TBS\Katalog',True);
 UsrReg.WriteString('KatalogArchiwum',katalog);
 UsrReg.CloseKey;
end;

initialization
  AutoInit;


finalization
  Done;

end.
