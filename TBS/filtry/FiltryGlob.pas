unit FiltryGlob;

interface

uses
  SysUtils, Classes, Forms, KR_Sys;

type
  TFiltrPompyItem = class
  private
    Nazwa    :String;
    Dost     :Boolean;
    ParamStr :string;
  end;

  TFiltryPomp = class
  private
    FIdList :TStringList;
    function GetDostepny(i: Integer): Boolean;
    function GetIdent(i: Integer): string;
    function GetLiczba: Integer;
    function GetNazwy(i: Integer): string;
    procedure SetDostepny(i: Integer; const Value: Boolean);
    function GetItems(i: Integer): TFiltrPompyItem;
  public
    constructor Create;
    destructor Destroy;              override;
    procedure Init;
    procedure UruchomZad( const FiltId : string );
    function Pozycja( const Id :string ) :Integer;
    property Ident[ i :Integer ] :string read GetIdent;
    property Nazwy[ i :Integer ] :string read GetNazwy;
    property Dostepny[ i :Integer ] : Boolean read GetDostepny write SetDostepny;
    property Liczba :Integer  read GetLiczba;
    property Items[ i :Integer ] :TFiltrPompyItem read GetItems;
  end;

var
  FiltryPomp :TFiltryPomp;

implementation

uses
  WkpGlob, FiltZadU;

{ TFiltryPomp }

constructor TFiltryPomp.Create;
begin
  inherited Create;
  FIdList := TStringList.Create;
end;

destructor TFiltryPomp.Destroy;
begin
  FIdList.Free;
  inherited Destroy;
end;

function TFiltryPomp.GetDostepny(i: Integer): Boolean;
begin
  result := (FIdList.Objects[i] as TFiltrPompyItem).Dost;
end;

function TFiltryPomp.GetIdent(i: Integer): string;
begin
  result := FIdList.Strings[i]
end;

function TFiltryPomp.GetItems(i: Integer): TFiltrPompyItem;
begin
  result := FIdList.Objects[i] as TFiltrPompyItem;
end;

function TFiltryPomp.GetLiczba: Integer;
begin
  result := FIdList.Count;
end;

function TFiltryPomp.GetNazwy(i: Integer): string;
begin
  result := (FIdList.Objects[i] as TFiltrPompyItem).Nazwa;
end;

procedure TFiltryPomp.Init;
var
  i       :Integer;
  o       :TFiltrPompyItem;
  s       :string;
begin
  KluczePompIni.ReadSection( 'Grupy', FIdList );
  for i := 0 to Liczba-1 do
  begin
    o := TFiltrPompyItem.Create;
    FIdList.Objects[i] := o;
    s := KluczePompIni.ReadString( 'Grupy', FIdList.Strings[i],
                                   FIdList.Strings[i] );
    o.Nazwa := strBefore( '|', s );
    o.Dost := true;
    o.ParamStr := StrBehinde( '|', s );
  end;
end;

function TFiltryPomp.Pozycja(const Id: string): Integer;
begin
  result := FIdList.IndexOf( Id );
end;

procedure TFiltryPomp.SetDostepny(i: Integer; const Value: Boolean);
begin
  (FIdList.Objects[i] as TFiltrPompyItem).Dost := Value;
end;



procedure TFiltryPomp.UruchomZad(const FiltId: string);
var
  Z       :TFiltrPompZad;
  F       :TForm;
  pos     :Integer;
begin
  Z := TFiltrPompZad.Create(NIL);
  Z.Grupa := FiltId;
  pos := Pozycja( FiltId );
  Z.Caption := Nazwy[pos];
  Z.ParamStr := Items[pos].ParamStr;
  F := Z.GetMainForm;
  F.Show;
end;

initialization
  FiltryPomp := TFiltryPomp.Create;


finalization
  FiltryPomp.Free;

end.
