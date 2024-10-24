unit PompMotU;

interface

uses
  SysUtils, DB, DBTables,
  OPompa, MotBaseInfoU, MotorObjU, Prod;

function CreateMotObjFromPmp( Pompa :TPompa ) :TMotorObject;
function CreateMotObjFromPmp_M( M_ :TDataSet ) :TMotorObject;

implementation

function CreateMotObjFromPmp( Pompa :TPompa ) :TMotorObject;
begin
  Result := CreateMotObjFromPmp_M( Pompa.DB.M )
end;

function CreateMotObjFromPmp_M( M_ :TDataSet ) :TMotorObject;
var
  mbi     :TMotBaseInfo;
  mo      :TMotorObject;
  sql     :string;
  pr      :TProducent;
  fld     :TField;
  q       :TQuery;
  mid     :string;
begin
  Result := NIL;
  mo := NIL;
  if M_ = NIL then
    EXIT;
  fld := M_.FindField('PROD');
  if fld = NIL then
    EXIT;

  pr := Producenci.ProdByName(fld.AsString);
  if pr = NIL then
    EXIT;

  try
    mbi := pr.InfoBazT['MOTORS'] as TMotBaseInfo;
  except on EInvalidCast do
    EXIT;
  end;
  if mbi = NIL then
    EXIT;
  mid := '';
  if M_.FindField('ID_NAZWA') <> NIL then
    mid := M_.FieldByName('ID_NAZWA').AsString;

  if mid = '' then
    //mid := M_.FieldByName('M_ID').AsString;
    EXIT;

  sql := mbi.GenerSQLText( Format( 'A.NAZWA = "%s"',
                                   [mid]));
  q := TQuery.Create(NIL);
  try
    q.DatabaseName := mbi.GetPath;
    q.SQL.Text := sql;
    q.Open;
  
    if q.FieldByName('NAZWA').AsString = mid then
    try
      mo := CreateMotor( q, Pr );
    finally
      q.Close;
    end;
  finally
    q.Free;
  end;
  Result := mo;
end;

end.
