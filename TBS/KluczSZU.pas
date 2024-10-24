unit KluczSZU;

interface

uses
  Windows, SysUtils;

function DajKompId :string;
function DyskId :Longint;
function KodOK( s :string; var KodProg :string ) :Boolean;
function DniToDate( ADni :Integer ) :TDateTime;
function DateToDni( ADate :TDateTime ) :Integer;
function WeDajDate( const kod :string ) :TDateTime;

function KluczSzyfruj( s :string ) :string;

function KluczDeszyfruj( s :string ) :string;

function KBezZbednych( s :string ) :string;
function KDziel( s :string ) :string;

function DataToHex( l :Integer; p :Pointer ) :string;
procedure HexToData( hex :string; p :Pointer );

type
  TKluczWyjscie = packed record
    DiscId :Longint;
    Data   :Word;
  end;

  TKluczWejscie = packed record
    Data   :Word;
    DiscId :Longint;
    Kod    :array[0..3] of char;
  end;

implementation


var
  CryptSeed :Longword;

const
  KInitCryptValue = 785384;


function KCryptRandom( range :Longint ) :Longword;
const
  MULTIPLIER  =    $019a4e37;
  INCREMENT   =    1;

begin
  CryptSeed := Int64(MULTIPLIER) * CryptSeed + INCREMENT;
  result := ((CryptSeed shr 16) and $7fff) mod range;
end;

function KCrypt( b :byte ) :byte;
begin
  result := b xor KCryptRandom( 256 );
  CryptSeed := CryptSeed xor result;
end;

function KDeCrypt( b :byte ) :byte;
begin
  result := b xor KCryptRandom( 256 );
  CryptSeed := CryptSeed xor b;
end;

procedure ISzyfruj( l :Integer; p :Pointer );
var
  b       :^Byte;
  i       :Integer;
begin
  CryptSeed := KInitCryptValue;
  b := p;
  for i := 1 to l do
  begin
    b^ := KCrypt(b^);
    inc(b);
  end;
end;

procedure IDeSzyfruj( l :Integer; p :Pointer );
var
  b       :^Byte;
  i       :Integer;
begin
  CryptSeed := KInitCryptValue;
  b := p;
  for i := 1 to l do
  begin
    b^ := KDeCrypt(b^);
    inc(b);
  end;
end;

function KluczSzyfruj( s :string ) :string;
var
  p      :Pointer;
  l      :Integer;
begin
  l := Length(s) div 2 +1;
  GetMem( p, l );
  try
    HexToData( s, p );
    ISzyfruj( l, p );
    result := DataToHex( l, p );
    if Length(result) > Length(s) then
      SetLength(result, Length(s));
  finally
    FreeMem( p );
  end;
end;

function KluczDeszyfruj( s :string ) :string;
var
  p      :Pointer;
  l      :Integer;
begin
  l := Length(s) div 2 +1;
  GetMem( p, l );
  try
    HexToData( s, p );
    IDeSzyfruj( l, p );
    result := DataToHex( l, p );
    if Length(result) > Length(s) then
      SetLength(result, Length(s));
  finally
    FreeMem( p );
  end;
end;

function KBezZbednych( s :string ) :string;
var
  i, j   :Integer;
begin
  SetLength(result, Length(s));
  j := 1;
  for i := 1 to Length(s) do
  begin
    if s[i] in ['0'..'9', 'a'..'f', 'A'..'F'] then
    begin
      result[j] := s[i];
      inc(j);
    end
    else if not (s[i] in ['-', ' ', '_']) then
      raise EConvertError.Create('W kluczu wystepuja niedozwolone znaki');
  end;
  SetLength(result, j-1);
end;

function KDziel( s :string ) :string;
var
  i      :Integer;
begin
  result := '';
  for i := 1 to Length(s) do
  begin
    result := result + s[i];
    if ((i mod 5) = 0) and (i < Length(s)) then
      result := result + '-';
  end;
end;

function DataToHex( l :Integer; p :Pointer ) :string;
const
  a : array[0..$F] of char = ('0','1','2','3','4','5','6','7',
                              '8','9','A','B','C','D','E','F');
var
  i        :Integer;
  b        :^Byte;
begin
  SetLength(result, 2*l);
  b := p;
  for i := 0 to l-1 do
  begin
    result[2*i+1] := a[b^ mod 16];
    result[2*i+2] := a[b^ div 16];
    inc(b);
  end;
end;

procedure HexToData( hex :string; p :Pointer );
var
  i        :Integer;
  b        :^Byte;
  lo       :Boolean;
  v        :Byte;
begin
  b := p;
  lo := true;
  for i := 1 to Length(hex) do
  begin
    case hex[i] of
      '0'..'9':
        v := ord(hex[i]) - ord('0');
      'a'..'f':
        v := ord(hex[i]) - ord('a') + 10;
      'A'..'F':
        v := ord(hex[i]) - ord('A') + 10;
    end;
    if lo then
    begin
      b^ := 0;
      b^ := b^ or v;
    end
    else
    begin
      b^ := b^ or (v shl 4);
      inc(b);
    end;
    lo := not lo;
  end;
end;

function Dni :Integer;
var
  d1, d2 :TDateTime;
begin
  d1 := EncodeDate( 1980, 01, 01 );
  d2 := Date();
  result := trunc(d2 - d1);
end;

function DniToDate( ADni :Integer ) :TDateTime;
begin
  result := EncodeDate( 1980, 01, 01 ) + ADni;
end;

function DateToDni( ADate :TDateTime ) :Integer;
var
  d1, d2 :TDateTime;
begin
  d1 := EncodeDate( 1980, 01, 01 );
  d2 := ADate;
  result := trunc(d2 - d1);
end;

function DyskId :Longint;
var
  serial, x1, x2 :DWORD;
  s1, s2         :array [0..512] of char;
begin
  GetVolumeInformation( 'c:\', s1, 511,
                        @serial, x1, x2,
                        s2, 511 );
  result := serial;
end;

function DajKompId :string;
var
  Wy     :TKluczWyjscie;
begin
  Wy.DiscId := DyskId;
  Wy.Data   := Dni;
  result := KDziel('0'+KluczSzyfruj(DataToHex( SizeOf(Wy), @Wy )));
end;

function KodOK( s :string; var KodProg :string ) :Boolean;
var
  We     :TKluczWejscie;
begin
  s := KBezZbednych(s);
  s := KluczDeszyfruj(s);
  HexToData( s, @We );
  SetLength(KodProg, 4);
  KodProg[1] := We.Kod[0];
  KodProg[2] := We.Kod[1];
  KodProg[3] := We.Kod[2];
  KodProg[4] := We.Kod[3];
  result := (We.DiscId = DyskId) and (We.Data >= Dni)
end;

function WeDajDate( const kod :string ) :TDateTime;
var
  We     :TKluczWejscie;
  s      :string;
begin
  s := KluczDeszyfruj(kod);
  HexToData( s, @We );

  result := DniToDate(We.Data);
end;

end.
