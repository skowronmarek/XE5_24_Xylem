unit CryptU;

interface

function CryptRandom( range :Longword ) :Longword;

var
  CryptSeed :Longword;

const
  TbsInitCryptValue = 785385;

implementation

function CryptRandom( range :Longword ) :Longword;
const
  MULTIPLIER  =    $015a4e37;
  INCREMENT   =    1;
  
var
  tmp         : Int64;
begin
  tmp       := Int64(MULTIPLIER) * CryptSeed + INCREMENT;
  CryptSeed := tmp and $FFFFFFFF;
  result := ((CryptSeed shr 16) and $7fff) mod range;
end;



end.
