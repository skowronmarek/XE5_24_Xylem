unit ElemUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Grids, DBGrids, DB, DBTables, Buttons, IniFiles,
  KR_Class, KrMath, Opor, DBArm, Ciecze;

type
  TKPFile = class (TIniFile)
    procedure WriteFloat( const sect, item :string; value :Double );
    function  ReadFloat( const sect, item :string;  Def :Double ):Double;
  end;


  TFormulaProc = function ( Rej, d, k, v :Real ): Real;

  TElemInfoState = ( eisLength, eisDiam, eisK, eisLambda,
                     eisLambdaOdRe, eisWspZast, eisDH );

  TElemInfoStates = set of TElemInfoState;


  TElemAbstract = class (TComponent)
  private
    FNazwa     :string;
    Fd         :Double;
    Fl         :Double;

  public
    constructor Create1;
    constructor Create(O :TComponent);               override;

    function  GetInfoState :TElemInfoStates;         virtual;

    procedure LoadFromDB( ADB :TDBArmatura );        virtual; abstract;
    function  lambda( ciecz :TCieczPlyw )  :Double;  virtual; abstract;
    function  WspZast( ciecz :TCieczPlyw ) :Double;  virtual; abstract;
    function  dH( ciecz :TCieczPlyw )      :Double;  virtual;
    function  dH_Pa( ciecz :TCieczPlyw )   :Double;
    procedure Save( numer :Integer; plik :TKPFile ); virtual;
    procedure Load( numer :Integer; plik :TKPFile ); virtual;
    function  Ident :string;                         virtual; abstract;
    function  DajOkno( const rodzaj :string ): TForm;      virtual;
  published
    property Nazwa     :string    read FNazwa  write FNazwa;
    property d         :Double    read Fd      write Fd;
    property l         :Double    read Fl      write Fl;
  end;

  TElemAbstractClass = class of TElemAbstract;

  TFormula = class (TElemAbstract)
  private
    Fk      :Double;
  public
    function  GetInfoState :TElemInfoStates;              override;
    function  LambdaOdRe( ciecz :TCieczPlyw; Re :Double ) :Double; virtual; //abstract;
    function  lambda( ciecz :TCieczPlyw )  :Double;       override;
    function  WspZast( ciecz :TCieczPlyw ) :Double;       override;
    procedure FormulaProc( var f :TFormulaProc );         virtual;  //abstract;
    function  Formula( LRej, d, k, v :Double ) :Double;   virtual;
    procedure Save( numer :Integer; plik :TKPFile );      override;
    procedure Load( numer :Integer; plik :TKPFile );      override;
    procedure LoadFromDB( ADB :TDBArmatura );             override;
    function  DajOkno( const rodzaj :string ): TForm;     override;
  published
    property  k   :Double read Fk  write Fk; //chropowatosc
  end;

  TElement = class (TFormula)
  protected
    FFormProc   :TFormulaProc;
    FLambda     :Double;
    FIsFormula  :Boolean;
    function  NotIsFormula :Boolean;
  public
    Baza        :TDBArmatura;

    destructor Destroy;                              override;

    function  GetInfoState :TElemInfoStates;         override;
    function  lambda( ciecz :TCieczPlyw )  :Double;  override;
    function  WspZast( ciecz :TCieczPlyw ) :Double;  override;
    procedure Save( numer :Integer; plik :TKPFile ); override;
    procedure Load( numer :Integer; plik :TKPFile ); override;
    procedure LoadFromDB( ADB :TDBArmatura );        override;
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
    function  DajOkno( const rodzaj :string ): TForm;      override;
  published
    property  IsFormula  :Boolean  read FIsFormula write FIsFormula;
    property  LambdaVal  :Double   read FLambda    write FLambda
                                   stored NotIsFormula;
  end;

  TStdElem = class (TElement)
  public

    destructor Destroy;                              override;

    function  GetInfoState :TElemInfoStates;         override;
    function  lambda( ciecz :TCieczPlyw )  :Double;  override;
    function  WspZast( ciecz :TCieczPlyw ) :Double;  override;
    procedure LoadFromDB( ADB :TDBArmatura );        override;
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
    function  DajOkno( const rodzaj :string ): TForm;      override;
  end;

  TOporMiejscowyFormula = class(TStdElem)
  public
    function  DajOkno( const rodzaj :string ): TForm;      override;
  end;

  TPNElem = class (TFormula)
    function  LambdaOdRe(ciecz :TCieczPlyw; Re :Double ) :Double;      override;
    function  LambdaEgr( ciecz :TCieczPlyw; var Egr :Double )  :Double;
    function  lambda( ciecz :TCieczPlyw )  :Double;  override;
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
    function  DajOkno( const rodzaj :string ): TForm;      override;
  end;

  TNikElem = class (TFormula)
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
  end;

  TColWElem = class (TFormula)
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
  end;

  TAltSulElem = class (TFormula)
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
  end;

  TManiElem = class (TFormula)
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
  end;

  THazenElem = class (TFormula)
    function  LambdaOdRe(ciecz :TCieczPlyw; Re :Double ) :Double;      override;
    function  lambda( ciecz :TCieczPlyw )  :Double;  override;
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
  end;

  TElemList = class (TElemAbstract)
  public
    function  GetInfoState :TElemInfoStates;         override;

    function  lambda( ciecz :TCieczPlyw )  :Double;  override;
    function  WspZast( ciecz :TCieczPlyw ) :Double;  override;
    function  dH( ciecz :TCieczPlyw )      :Double;  override;
    procedure Save( numer :Integer; plik :TKPFile ); override;
    procedure Load( numer :Integer; plik :TKPFile ); override;
    function  Ident :string;                         override;
  private
    FList     :TComponentStreamableList;
    function  GetElem( pos :Integer ): TElemAbstract;
    function  GetCount :Integer;
    procedure ReadList( Stream :TStream );
    procedure WriteList( Stream :TStream );
  protected
    procedure DefineProperties( Filer :TFiler );     override;
  public
    constructor Create( O :TComponent );             override;
    destructor  Destroy;                             override;

    procedure Add( E :TElemAbstract );
    procedure Insert( pos :Integer; E :TElemAbstract );
    procedure RemoveAt( pos :Integer );
    procedure DeleteFree( pos :Integer );
    procedure Clear;
    property  Count    :Integer                     read GetCount;
    property  List [ pos :Integer ] :TElemAbstract  read GetElem;   default;
  published
    property CompList  :TComponentStreamableList  read FList write FList;
  end;


  TDummyElem = class (TElement)
    function  GetInfoState :TElemInfoStates;         override;
    function  lambda( ciecz :TCieczPlyw )  :Double;  override;
    function  WspZast( ciecz :TCieczPlyw ) :Double;  override;
    procedure Save( numer :Integer; plik :TKPFile ); override;
    procedure Load( numer :Integer; plik :TKPFile ); override;
    procedure LoadFromDB( ADB :TDBArmatura );        override;
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;
    function  dH( ciecz :TCieczPlyw )      :Double;  override;
    function  DajOkno( const rodzaj :string ): TForm;      override;
  end;


  TElemConstDH = class (TElement)
  protected
    FdH       :Double;
  public

    // atrapy
    function  lambda( ciecz :TCieczPlyw )  :Double;  override;
    function  WspZast( ciecz :TCieczPlyw ) :Double;  override;
    procedure Save( numer :Integer; plik :TKPFile ); override;
    procedure Load( numer :Integer; plik :TKPFile ); override;
    function  Ident :string;                         override;
    procedure FormulaProc( var f :TFormulaProc );    override;

    function  GetInfoState :TElemInfoStates;              override;
    procedure LoadFromDB( ADB :TDBArmatura );             override;
    function  dH( ciecz :TCieczPlyw )      :Double;       override;
    function  DajOkno( const rodzaj :string ): TForm;     override;
  published
    property DHValue :Double read FdH write FdH;
  end;

function  CreateArmElem( const AObjId :string ) :TElemAbstract;

function  CreateElemFromDB( Baza: TDBArmatura ) :TElemAbstract;

procedure RegisterArmElemClass( AObjId :string; AClassRef :TElemAbstractClass );



{============================================================================}
implementation

uses
  ElAbFrm, KopDodElFrm, ArmElFrm, KopFormFrm, KopPNFrm, KopDumElFrm,
  KopOporMiejscEdFormU;

var
  DefFormProc    :TFormulaProc;
  ElemClassList  :TStringList;


{---------------------------------------------------------------------------}
procedure TKPFile.WriteFloat( const sect, item :string; value :Double );
var
  s       :string;
begin
  str( value: 16:12, s );
  WriteString( sect, item, s );
end;

{---------------------------------------------------------------------------}
function  TKPFile.ReadFloat( const sect, item :string;  Def :Double ):Double;
var
  s       :string;
  e       :Integer;
begin
  s := ReadString(sect,item, '');
  if s = '' then result := Def
  else
  begin
    val( s, Result, e );
    if e > 0 then result := Def;
  end;
end;



{---------------------------------------------------------------------------}
constructor TElemAbstract.Create( O :TComponent);
begin
  inherited Create(O);
end;

{---------------------------------------------------------------------------}
constructor TElemAbstract.Create1;
begin
  Create(NIL);
end;

{---------------------------------------------------------------------------}
function  TElemAbstract.GetInfoState :TElemInfoStates;
begin
  result := [];
end;


function  TElemAbstract.dH( ciecz :TCieczPlyw )      :Double;
begin
  result := f_div( WspZast(ciecz)*l * 8*sqr(ciecz.Q) ,
                 //------------------
                   9.81*pi*pi*d*d*d*d ) ;
end;

function TElemAbstract.dH_Pa(ciecz: TCieczPlyw): Double;
begin
  result := dH(ciecz) * ciecz.Ro * 9.81; 
end;

procedure TElemAbstract.Save( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  sekcja := Format( 'Element/%d', [numer] );
  with plik do
  begin
    WriteString( sekcja, 'Ident', Ident );
    WriteString( sekcja, 'Nazwa', Nazwa );
    WriteFloat( sekcja, 'd', d );
    WriteFloat( sekcja, 'l', l );
  end;
end;

procedure TElemAbstract.Load( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  sekcja := Format( 'Element/%d', [numer] );
  with plik do
  begin
    Nazwa := ReadString( sekcja, 'Nazwa', '' );
    d     := ReadFloat( sekcja, 'd', 1 );
    l     := ReadFloat( sekcja, 'l', 1 );
  end;
end;


{---------------------------------------------------------------------------}
function  TElemAbstract.DajOkno( const rodzaj :string ): TForm;
begin
  result := NIL;
end;



{---------------------------------------------------------------------------}
destructor TElement.Destroy;
begin
  Baza.Free;
  inherited Destroy;
end;


{---------------------------------------------------------------------------}
function  TElement.GetInfoState :TElemInfoStates;
begin
  result := [eisLength, eisDiam, eisK,
             eisLambda, eisLambdaOdRe, eisWspZast, eisDH];
end;



{---------------------------------------------------------------------------}
procedure TElement.Save( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  inherited Save( numer, plik );
  sekcja := Format( 'Element/%d', [numer] );
  plik.WriteFloat( sekcja, 'lambda', FLambda );
  plik.WriteBool( sekcja, 'IsFormula', IsFormula );
end;


{---------------------------------------------------------------------------}
procedure TElement.Load( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  inherited Load( numer, plik );
  sekcja := Format( 'Element/%d', [numer] );
  with plik do
  begin
    FLambda := ReadFloat( sekcja, 'lambda', 1 );
    IsFormula  := ReadBool( sekcja, 'IsFormula', IsFormula );
  end;
end;

{---------------------------------------------------------------------------}
function TElement.Lambda( ciecz :TCieczPlyw ) :Double;
begin
  if not IsFormula then
    result := FLambda
  else
    result := inherited Lambda( ciecz );
end;

{---------------------------------------------------------------------------}
function TElement.WspZast( ciecz :TCieczPlyw ) :Double;
begin
  if not IsFormula then
    result := lambda(ciecz)
  else
    result := inherited WspZast( ciecz );
end;


{---------------------------------------------------------------------------}
function TElement.Ident :string;
begin
  result := 'ELEMENT';
end;

{---------------------------------------------------------------------------}
procedure TElement.FormulaProc( var f :TFormulaProc );
begin
  f := NIL;
end;


{---------------------------------------------------------------------------}
procedure TElement.LoadFromDB( ADB :TDBArmatura );
begin

  ADB.Update;
  IsFormula := false;
  if (ADB.tOK) then
  begin
    try
      k := ADB.T.FieldByName('K').AsFloat / 1000;
      if k > 0 then
        IsFormula := true;
    except
      on EDataBaseError do
        IsFormula := false;
    end;
  end;
  if not IsFormula then
  begin
    FLambda   := ADB.A.FieldByName('W_OPORU').AsFloat;
  end;
  Nazwa := ADB.A.FieldByName('ELEMENT').AsString;
  d     := ADB.A.FieldByName('SREDNICA').AsFloat / 1000;

  Baza := ADB.MakeCopy( NIL );
end;


{---------------------------------------------------------------------------}
function  TElement.DajOkno( const rodzaj :string ): TForm;
var
  R       :string;
  F       :TElemAbstPrzeplFrm;
begin
  R := UpperCase(rodzaj);
  result := NIL;
  if R = '+ED' then
  begin
    F := TDodajElemForm.Create( NIL );
  end
  else if R = 'V' then
  begin
    if Baza = NIL then
      F := NIL
    else
      F := TArmElemForm.Create( NIL );
  end
  else
    F := inherited DajOkno( rodzaj ) as TElemAbstPrzeplFrm;

  if F <> NIL then
  begin
    F.Element := self;
    result := F;
  end;

end;

function TElement.NotIsFormula: Boolean;
begin
  result := not IsFormula;
end;




{---------------------------------------------------------------------------}

destructor TStdElem.Destroy;
begin
  inherited Destroy;
end;


{---------------------------------------------------------------------------}

function  TStdElem.GetInfoState :TElemInfoStates;
begin
  result := [eisLength, eisDiam, eisLambda, eisWspZast, eisDH];
end;



{---------------------------------------------------------------------------}

function TStdElem.Lambda( ciecz :TCieczPlyw ) :Double;
begin
  result := FLambda;
end;

{---------------------------------------------------------------------------}

function TStdElem.WspZast( ciecz :TCieczPlyw ) :Double;
begin
  result := lambda(ciecz)
end;


{---------------------------------------------------------------------------}

function TStdElem.Ident :string;
begin
  result := 'STDELEM';
end;

{---------------------------------------------------------------------------}

procedure TStdElem.FormulaProc( var f :TFormulaProc );
begin
  f := NIL;
end;


{---------------------------------------------------------------------------}

procedure TStdElem.LoadFromDB( ADB :TDBArmatura );
begin

  ADB.Update;

  FLambda   := ADB.A.FieldByName('W_OPORU').AsFloat;
  FIsFormula := false;
  Nazwa := ADB.A.FieldByName('ELEMENT').AsString;
  d     := ADB.A.FieldByName('SREDNICA').AsFloat / 1000;
  Baza := ADB.MakeCopy( NIL );
end;


{---------------------------------------------------------------------------}

function  TStdElem.DajOkno( const rodzaj :string ): TForm;
var
  R       :string;
  F       :TElemAbstPrzeplFrm;
begin
  R := UpperCase(rodzaj);
  result := NIL;
  if R = '+ED' then
  begin
    F := TDodajElemForm.Create( NIL );
  end
  else if R = 'V' then
  begin
    F := NIL;
  end
  else
    F := inherited DajOkno( rodzaj ) as TElemAbstPrzeplFrm;

  if F <> NIL then
  begin
    F.Element := self;
    result := F;
  end;

end;




{---------------------------------------------------------------------------}

function  TFormula.GetInfoState :TElemInfoStates;
begin
  result := [ eisLength, eisDiam, eisK,
              eisLambda, eisLambdaOdRe, eisWspZast, eisDH];
end;



function  TFormula.LambdaOdRe(ciecz :TCieczPlyw; Re :Double ) :Double;
var
  V            :Double;
  f            :TFormulaProc;
begin
  V := 1;
  // FormulaProc( f );
  result := Formula(Re,d,k,v);
end;


function TFormula.Lambda( ciecz :TCieczPlyw)  :Double;
var
  A, V, Rej :Double;
  F         :TFormulaProc;
begin
  A := Pole_Przekroju(d);
  V := V_przeplywu( Ciecz.Q, A);
  Rej:=Reynolds( d, v, Ciecz.ni);
  // FormulaProc( f );
  try
    result := Formula(Rej,d,k,v);
  except
    on EMathError do
      result := 0;
  end;
end;


function TFormula.WspZast( ciecz :TCieczPlyw ) :Double;
begin
  result := f_div(lambda(ciecz) ,d);
end;


procedure TFormula.FormulaProc( var f :TFormulaProc );
begin
  f := NIL;
end;


function  TFormula.Formula( LRej, d, k, v :Double ) :Double;
var
  F         :TFormulaProc;
  egr       :Real;
begin
  FormulaProc( F );
  if @F <> NIL then
  try
    result := F( LRej, d, k, v );
  except
    on EMathError do
      result := 0;
  end
  else
  try
    result := PN_34034( LRej, d, k, v, egr );
  except
    on EMathError do
      result := 0;
  end;
end;


procedure TFormula.Save( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  inherited Save( numer, plik );
  sekcja := Format( 'Element/%d', [numer] );

  with plik do
  begin
    WriteFloat( sekcja, 'k', k );
  end;
end;

procedure TFormula.Load( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  inherited Load( numer, plik );
  sekcja := Format( 'Element/%d', [numer] );
  with plik do
  begin
    ReadFloat( sekcja, 'k', k );
  end;
end;


procedure TFormula.LoadFromDB( ADB :TDBArmatura );
begin
  // DO NOTHING
end;


{---------------------------------------------------------------------------}
function  TFormula.DajOkno( const rodzaj :string ): TForm;
var
  R       :string;
  F       :TElemAbstPrzeplFrm;
begin
  R := UpperCase(rodzaj);
  result := NIL;
  if R = '+ED' then
  begin
    F := TDodajFormulaElemForm.Create( NIL );
  end
  else if R = 'V' then
  begin
    F := NIL;
  end
  else
    F := inherited DajOkno( rodzaj ) as TElemAbstPrzeplFrm;

  if F <> NIL then
  begin
    F.Element := self;
    result := F;
  end;

end;




{--------------------------------------------------------------------
| KLASA : TPNElem
|
|
+-----------------------------------
}

function TPNElem.LambdaOdRe(ciecz :TCieczPlyw; Re :Double ) :Double;
var
  V            :Double;
  egrr         :Real;
begin
  V := 1;
  result := Pn_34034(Re,d,k,v,egrr);
end;


function TPNElem.LambdaEgr( ciecz :TCieczPlyw; var Egr :Double )  :Double;
var
  A, V, Rej    :Double;
  egrr         :Real;
begin
  A := Pole_Przekroju(d);
  V := V_przeplywu( Ciecz.Q, A);
  Rej:=Reynolds( d, v, Ciecz.ni);
  result :=Pn_34034(Rej,d,k,v,egrr);
  Egr    := Egrr;
end;

procedure TPNElem.FormulaProc( var f :TFormulaProc );
begin
  f := NIL;
end;

function TPNElem.Lambda( ciecz :TCieczPlyw ) :Double;
var
  egr          :Double;
begin
  result := LambdaEgr( ciecz, Egr );
end;



function TPNElem.Ident :string;
begin
  result := 'PN';
end;




{---------------------------------------------------------------------------}
function  TPNElem.DajOkno( const rodzaj :string ): TForm;
var
  R       :string;
  F       :TElemAbstPrzeplFrm;
begin
  R := UpperCase(rodzaj);
  result := NIL;
  if R = '+ED' then
  begin
    F := TPNForm.Create( NIL );
  end
  else
    F := inherited DajOkno( rodzaj ) as TElemAbstPrzeplFrm;

  if F <> NIL then
  begin
    F.Element := self;
    result := F;
  end;

end;








procedure TNikElem.FormulaProc( var f :TFormulaProc );
begin
  f := @Nikur;
end;


function TNikElem.Ident :string;
begin
  result := 'Nikuradse';
end;



procedure TColWElem.FormulaProc( var f :TFormulaProc );
begin
  f := @Coleb;
end;


function TColWElem.Ident :string;
begin
  result := 'Colebrooke';
end;

procedure TAltsulElem.FormulaProc( var f :TFormulaProc );
begin
  f := @Altsul;
end;


function TAltsulElem.Ident :string;
begin
  result := 'Altsul';
end;


function THazenElem.LambdaOdRe(ciecz :TCieczPlyw; Re :Double ) :Double;
Var
   V  : Double;
begin
  //result :=Hazen(Re,d,k,v,Ciecz.Ro,Ciecz.Ni);
end;


procedure THazenElem.FormulaProc( var f :TFormulaProc );
begin
end;

function THazenElem.Lambda( ciecz :TCieczPlyw ) :Double;
Var
 A, V, Rej    :Double;
begin
  A := Pole_Przekroju(d);
  V := V_przeplywu( Ciecz.Q, A);
  Rej:=Reynolds( d, v, Ciecz.ni);
  //result :=Hazen(Rej,d,k,v,Ciecz.Ro,Ciecz.Ni);
end;


function THazenElem.Ident :string;
begin
  result := 'Hazen';
end;

procedure TManiElem.FormulaProc( var f :TFormulaProc );
begin
  f := @Manning;
end;


function TManiElem.Ident :string;
begin
  result := 'Manning';
end;




{---------------------------------------------------------------------------}
function  TDummyElem.GetInfoState :TElemInfoStates;
begin
  result := [eisLength];
end;



{---------------------------------------------------------------------------}
procedure TDummyElem.Save( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  {
  inherited Save( numer, plik );
  sekcja := Format( 'Element/%d', [numer] );
  plik.WriteFloat( sekcja, 'lambda', FLambda );
  plik.WriteBool( sekcja, 'IsFormula', IsFormula );
  }
end;


{---------------------------------------------------------------------------}
procedure TDummyElem.Load( numer :Integer; plik :TKPFile );
var
  sekcja  :string;
begin
  {
  inherited Load( numer, plik );
  sekcja := Format( 'Element/%d', [numer] );
  with plik do
  begin
    FLambda := ReadFloat( sekcja, 'lambda', 1 );
    IsFormula  := ReadBool( sekcja, 'IsFormula', IsFormula );
  end;
  }
end;

{---------------------------------------------------------------------------}
function  TDummyElem.dH( ciecz :TCieczPlyw )      :Double;
begin
  result := 0;
end;

{---------------------------------------------------------------------------}
function TDummyElem.Lambda( ciecz :TCieczPlyw ) :Double;
begin
  result := 0;
end;

{---------------------------------------------------------------------------}
function TDummyElem.WspZast( ciecz :TCieczPlyw ) :Double;
begin
  result := 0;
end;


{---------------------------------------------------------------------------}
function TDummyElem.Ident :string;
begin
  result := 'DUMMYELEM';
end;

{---------------------------------------------------------------------------}
procedure TDummyElem.FormulaProc( var f :TFormulaProc );
begin
  f := NIL;
end;


{---------------------------------------------------------------------------}
procedure TDummyElem.LoadFromDB( ADB :TDBArmatura );
begin

  ADB.Update;
  IsFormula := false;
  Nazwa := ADB.A.FieldByName('ELEMENT').AsString;

  Baza := ADB.MakeCopy( NIL );
end;


{---------------------------------------------------------------------------}
function  TDummyElem.DajOkno( const rodzaj :string ): TForm;
var
  R       :string;
  F       :TElemAbstPrzeplFrm;
begin
  R := UpperCase(rodzaj);
  result := NIL;
  if R = '+ED' then
  begin
    F := TDodajDummyElemForm.Create( NIL );
  end
  else if R = 'V' then
  begin
    F := TArmElemForm.Create( NIL );
  end
  else
    F := inherited DajOkno( rodzaj ) as TElemAbstPrzeplFrm;

  if F <> NIL then
  begin
    F.Element := self;
    result := F;
  end;

end;






{---------------------------------------------------------------------------}
constructor TElemList.Create(O :TComponent);
begin
  inherited Create(O);
  FList := TComponentStreamableList.Create;
end;

{---------------------------------------------------------------------------}
destructor  TElemList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

{---------------------------------------------------------------------------}
function  TElemList.GetInfoState :TElemInfoStates;
begin
  result := [eisDH];
end;



{---------------------------------------------------------------------------}
procedure TElemList.Add( E :TElemAbstract );
begin
  FList.Add( E );
end;

procedure TElemList.Insert(pos: Integer; E: TElemAbstract);
begin
  FList.Insert(pos, E);
end;


{---------------------------------------------------------------------------}
procedure TElemList.RemoveAt( pos :Integer );
begin
  FList.Delete( pos );
  FList.Pack;
end;

{---------------------------------------------------------------------------}
procedure TElemList.DeleteFree( pos :Integer );
var
  e       :TElemAbstract;
begin
  e := List[pos];
  RemoveAt(pos);
  e.Free;
end;

{---------------------------------------------------------------------------}
procedure TElemList.Clear;
var
  e       :TElemAbstract;
  i       :Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    e := FList.Items[i] as TElemAbstract;
    // FList.Delete( i );
    e.Free;
    FList.Items[i] := NIL;
  end;
  FList.Clear;
end;


{---------------------------------------------------------------------------}
function  TElemList.GetElem( pos :Integer ): TElemAbstract;
begin
  result := FList.Items[pos] as TElemAbstract;
end;

{---------------------------------------------------------------------------}
function  TElemList.GetCount :Integer;
begin
  result := FList.Count;
end;



{---------------------------------------------------------------------------}
function  TElemList.lambda( ciecz :TCieczPlyw )  :Double;
begin
  result := 0;
end;

{---------------------------------------------------------------------------}
function  TElemList.WspZast( ciecz :TCieczPlyw ) :Double;
begin
  result := 0;
end;

{---------------------------------------------------------------------------}
function  TElemList.dH( ciecz :TCieczPlyw )      :Double;
var
  sum     :Extended;
  i       :Integer;
begin
  sum := 0;
  for i := 0 to Count-1 do
  begin
    if eisDH in List[i].GetInfoState then
    try
      sum := sum + List[i].dH(ciecz);
    except on EMathError do
      begin
      end;
    end;
  end;
  result := sum;
end;

{---------------------------------------------------------------------------}
procedure TElemList.Save( numer :Integer; plik :TKPFile );
begin
end;

{---------------------------------------------------------------------------}
procedure TElemList.Load( numer :Integer; plik :TKPFile );
begin
end;

{---------------------------------------------------------------------------}
function  TElemList.Ident :string;
begin
  result := '';
end;




{---------------------------------------------------------------------------}
procedure RegisterArmElemClass( AObjId :string; AClassRef :TElemAbstractClass );
begin
  ElemClassList.AddObject( AObjId, TObject(AClassRef) );
end;

{---------------------------------------------------------------------------}
function  CreateArmElem( const AObjId :string ) :TElemAbstract;
var
  Pos       :Integer;
  ClassRef  :TElemAbstractClass;
begin

  result := NIL;
  Pos := ElemClassList.IndexOf( AObjId );
  if Pos >= 0 then
  begin
    ClassRef := TElemAbstractClass(ElemClassList.Objects[Pos]);
    result   := ClassRef.Create(NIL);
  end;

end;

{---------------------------------------------------------------------------}
function  CreateElemFromDB( Baza: TDBArmatura ) :TElemAbstract;
begin

  result := NIL;
  try
    result := CreateArmElem( Baza.A.FieldByName('Obj_Id').AsString );
  except
    on EDataBaseError do
      result := NIL;
    on EAccessViolation do
      result := NIL;
  end;

  if result <> NIL then
  begin
    result.LoadFromDB( Baza );
  end;

end;



procedure TElemList.DefineProperties(Filer: TFiler);
begin
  Filer.DefineBinaryProperty( 'List', ReadList, WriteList, true );

end;

procedure TElemList.ReadList(Stream: TStream);
begin
  FList.LoadFromStream( Stream );
end;

procedure TElemList.WriteList(Stream: TStream);
begin
  FList.SaveToStream( Stream );
end;

{ TElemConstDH }

function TElemConstDH.DajOkno(const rodzaj: string): TForm;
begin
  result := inherited DajOkno(rodzaj);
end;

function TElemConstDH.dH(ciecz: TCieczPlyw): Double;
begin
  result := FdH;
end;

procedure TElemConstDH.FormulaProc(var f: TFormulaProc);
begin
  f := NIL;
end;

function TElemConstDH.GetInfoState: TElemInfoStates;
begin
  //result := [ eisLength, eisDiam, eisK,
  //            eisLambda, eisLambdaOdRe, eisWspZast, eisDH];
  result := [ eisLength, eisDH];
end;

function TElemConstDH.Ident: string;
begin
  result := 'CONSTDH';
end;

function TElemConstDH.lambda(ciecz: TCieczPlyw): Double;
begin
  result := 0;
end;

procedure TElemConstDH.Load(numer: Integer; plik: TKPFile);
begin

end;

procedure TElemConstDH.LoadFromDB(ADB: TDBArmatura);
begin
  ADB.Update;
  FdH := ADB.A.FieldByName('W_OPORU').AsFloat;

  FIsFormula := false;
  Nazwa := ADB.A.FieldByName('ELEMENT').AsString;
  //d     := ADB.A.FieldByName('SREDNICA').AsFloat / 1000;
  Baza := ADB.MakeCopy( NIL );

end;

procedure TElemConstDH.Save(numer: Integer; plik: TKPFile);
begin

end;

function TElemConstDH.WspZast(ciecz: TCieczPlyw): Double;
begin
  result := 0;
end;

{ TOporMiejscowyFormula }

function TOporMiejscowyFormula.DajOkno(const rodzaj: string): TForm;
var
  R       :string;
  F       :TElemAbstPrzeplFrm;
begin
  R := UpperCase(rodzaj);
  result := NIL;
  if R = '+ED' then
  begin
    F := TOporMiejscEdForm.Create( NIL );
  end
  else
    F := inherited DajOkno( rodzaj ) as TElemAbstPrzeplFrm;

  if F <> NIL then
  begin
    F.Element := self;
    result := F;
  end;
end;

initialization
  ElemClassList := TStringList.Create;
  // Cisnieniowe
  RegisterArmElemClass( 'R-C',    TElement );
  RegisterArmElemClass( 'K-C',    TElement );
  RegisterArmElemClass( 'RED-C',  TElement );

  RegisterArmElemClass( 'CDH',    TElemConstDH );

  // Baza standardowa
  RegisterArmElemClass( 'STD',    TStdElem );

  // Nie obliczane
  RegisterArmElemClass( 'R',       TDummyElem );
  RegisterArmElemClass( 'NIELICZ', TDummyElem );
  RegisterArmElemClass( 'T-C',     TDummyElem );
  RegisterArmElemClass( 'T',       TDummyElem );
  RegisterArmElemClass( 'K',       TDummyElem );

  RegisterClass( TAltsulElem );
  RegisterClass( TElement );
  RegisterClass( TPNElem );
  RegisterClass( TColWElem );
  RegisterClass( THazenElem );
  RegisterClass( TManiElem );
  RegisterClass( TNikElem );
  RegisterClass( TStdElem );
  RegisterClass( TDummyElem );
  RegisterClass( TElemConstDH );
  RegisterClass( TOporMiejscowyFormula );
  RegisterClass( TElemList );


finalization
  ElemClassList.Free;

end.
