unit Jednost;

interface

uses
  Classes,
  SysUtils,
  IniFiles,
  Dialogs,
  KR_Sys,
  KR_Class;

type
  TJednostka = class
    private
      FWielkFiz: String;         {Symbol Wielkosci Fizycznej}
      FNazwaJednUzytk: String;
    protected
    public
      constructor Create2( const AWielkFiz, ANazwaJedn: string );
      function  StdToUser( std: Extended ): Extended; virtual; abstract;
      function  UserToStd( user: Extended ): Extended; virtual; abstract;
      property  NazwaJedn: string
                    read FNazwaJednUzytk;
      property  WielkFiz: String read FWielkFiz;
  end;


procedure GetJednStrings( const WielkFiz :string; strings: TStrings );
procedure JednostkiInit( IniFile: TCustomIniFile );
procedure UstawJednostke( const WielkFiz: string; const SymbJedn: string );


type
  TMnozJedn = class( TJednostka )
  private
    FFactor: Extended;
  protected
  public
    constructor Create3( const AWielkFiz, ANazwaJedn: string;
                         AFactor: Extended );
    function  StdToUser( std: Extended ): Extended; override;
    function  UserToStd( user: Extended ): Extended; override;
  end;

  TMnozPlusJedn = class( TMnozJedn )
  private
    FShift: Extended;
  public
    constructor Create4( const AWielkFiz, ANazwaJedn: string;
                         AFactor, AShift: Extended );
    function  StdToUser( std: Extended ): Extended; override;
    function  UserToStd( user: Extended ): Extended; override;
  end;



var
  JednH,
  JednQ,
  JednT: TJednostka;

  SI_H,
  SI_Q,
  SI_T: TJednostka;


{=============================================================================}
implementation

{uses
  WkpGlob;}

type
  PJednostka = ^TJednostka;

  TJednPair = class
    User    :TJednostka;
    SI      :TJednostka;
  end;

var
  IniFileName : TFileName;
  JednList    : TStringList;


{---------------------------------------------------------------------------}
procedure GetJednStrings( const WielkFiz: string; strings: TStrings );
var
  IniFile: TIniFile;
begin
  try
    IniFile := TIniFile.Create( IniFileName );
    IniFile.ReadSection( 'Jednostki '+WielkFiz, strings);
  finally
    IniFile.Free;
  end;

end;

{---------------------------------------------------------------------------}
function DajAdresJednostki( const WielkFiz: string ): PJednostka;
var
  r: PJednostka;
begin
  if WielkFiz = 'Q' then
    r := @JednQ
  else if WielkFiz = 'H' then
    r := @JednH
  else if WielkFiz = 'T' then
    r := @JednT
  else
  begin
  end;
  result := r;
end;



{---------------------------------------------------------------------------}
function JednCreate( const WielkFiz: string;
                     const SymbJedn: string;
                     IniFile: TCustomIniFile ): TJednostka;
{
+---------------------------------------------------------------
| Utworz egzemplarz jednostki na podstawie danych zapisanych
|   w <IniFile>.
| Procedurea dba o utworzenie obiektu o wlasciwym typie.
+---------------------------------------------------------------
}
var
  s, prefix, sufix: string;
  r: TJednostka;
  fact, sh: Extended;
begin
  s := IniFile.ReadString( 'Jednostki '+WielkFiz, SymbJedn, '*,1' );
  prefix := AllTrim(StrBefore( ',', s ));
  sufix :=  AllTrim(StrBehinde( ',', s ));
  if prefix = '*' then
  begin
    fact := StrToFloat(sufix);
    r  := TMnozJedn.Create3( WielkFiz, SymbJedn, fact );
  end
  else if prefix = '*+' then
  begin
    prefix := AllTrim(StrBefore( ',', sufix ));
    sufix  := AllTrim(StrBehinde( ',', sufix ));
    fact := StrToFloat(prefix);
    sh := StrToFloat(sufix);
    r  := TMnozPlusJedn.Create4( WielkFiz, SymbJedn, fact, sh );
  end;
  JednCreate := r;
end;



{---------------------------------------------------------------------------}
procedure SetUnit( const WielkFiz: string;
                   const SymbJedn: string;
                   IniFile: TCustomIniFile );
var
  pjedn: PJednostka;
begin
  pjedn := DajAdresJednostki( WielkFiz );
  if assigned(pjedn^) then
    pjedn^.Free;
  pjedn^ := JednCreate( WielkFiz, SymbJedn, IniFile );
  IniFile.WriteString( 'Jednostki', WielkFiz, SymbJedn );
end;


{---------------------------------------------------------------------------}
procedure JednostkiInit( IniFile: TCustomIniFile );
begin
  IniFileName := IniFile.FileName;

  SetUnit( 'Q', IniFile.ReadString( 'Jednostki', 'Q', 'm3/h' ), IniFile);
  SetUnit( 'H', IniFile.ReadString( 'Jednostki', 'H', 'm' ), IniFile);
  SetUnit( 'T', IniFile.ReadString( 'Jednostki', 'T', '°C' ), IniFile);
end;


{---------------------------------------------------------------------------}
procedure UstawJednostke( const WielkFiz: string; const SymbJedn: string );
var
  IniFile: TIniFile;
  pjedn: PJednostka;
begin
  try
    IniFile := TIniFile.Create( IniFileName );
    SetUnit( WielkFiz, SymbJedn, IniFile );
  finally
    IniFile.Free;
  end;
end;


{---------------------------------------------------------------------------}
constructor TJednostka.Create2( const AWielkFiz, ANazwaJedn: string );
begin
  FWielkFiz := AWielkFiz;
  FNazwaJednUzytk := ANazwaJedn;
end;


{---------------------------------------------------------------------------}
constructor TMnozJedn.Create3( const AWielkFiz, ANazwaJedn: string;
                               AFactor: Extended );
begin
  inherited Create2( AWielkFiz, ANazwaJedn );
  FFactor := AFactor;
end;


{---------------------------------------------------------------------------}
function  TMnozJedn.StdToUser( std: Extended ): Extended;
begin
  StdToUser := std * FFactor;
end;


{---------------------------------------------------------------------------}
function  TMnozJedn.UserToStd( user: Extended ): Extended;
begin
  UserToStd := user / FFactor;
end;


{---------------------------------------------------------------------------}
constructor TMnozPlusJedn.Create4( const AWielkFiz, ANazwaJedn: string;
                         AFactor, AShift: Extended );
begin
  inherited Create3( AWielkFiz, ANazwaJedn, AFactor );
  FShift := AShift;
end;

{---------------------------------------------------------------------------}
function  TMnozPlusJedn.StdToUser( std: Extended ): Extended;
begin
  StdToUser := std * FFactor + FShift;
end;

{---------------------------------------------------------------------------}
function  TMnozPlusJedn.UserToStd( user: Extended ): Extended;
begin
  UserToStd := (user-FShift) / FFactor;
end;



initialization
  JednList := TStringList.Create;


finalization
  JednList.Free;

end.
