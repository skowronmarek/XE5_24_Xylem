unit LinCharU;

interface


uses
  Windows, SysUtils, Classes, Graphics, DB, DBTables,
  DGraph, Diagrams, KrMath, PompMath, PumpIntf, OPompa,
  Math;

type

  TLpkt = class
  protected
    function get_met             : string;  virtual; abstract;
    function get_n_pt            : word;    virtual; abstract;
    function getQ(pos:integer)   : Double;  virtual; abstract;
    function getH(pos:integer)   : Double;  virtual; abstract;
    function getP(pos:integer)   : Double;  virtual; abstract;
    function getNPSH(pos:integer): Double;  virtual; abstract;
    procedure SetH(pos: integer; const Value: Double);     virtual; abstract;
    procedure SetNPSH(pos: integer; const Value: Double);  virtual; abstract;
    procedure SetP(pos: integer; const Value: Double);     virtual; abstract;
    procedure SetQ(pos: integer; const Value: Double);     virtual; abstract;
  public
    property met                : string read get_met;
    property n_pt               : word   read get_n_pt;
    property Q[pos:integer]     : Double read getQ    write SetQ;
    property H[pos:integer]     : Double read getH    write SetH;
    property P[pos:integer]     : Double read getP    write SetP;
    property NPSH[pos:integer]  : Double read getNPSH write SetNPSH;
  end;

  TLpktFiz = class (TLpkt)
  private
    fMet     : string[2];
    f_n_pt   : word;
  protected
    procedure InitTables;
    function get_met             : string;  override;
    function get_n_pt            : word;    override;
    function getQ(pos:integer)   : Double;  override;
    function getH(pos:integer)   : Double;  override;
    function getP(pos:integer)   : Double;  override;
    function getNPSH(pos:integer): Double;  override;
    procedure SetH(pos: integer; const Value: Double);     override;
    procedure SetNPSH(pos: integer; const Value: Double);  override;
    procedure SetP(pos: integer; const Value: Double);     override;
    procedure SetQ(pos: integer; const Value: Double);     override;
  public
    fQ       : PFloatArray;
    fH       : PFloatArray;
    fP       : PFloatArray;
    fNPSH    : PFloatArray;
    constructor CreateFromH( HTable: TDataSet );
    constructor CreateN( aN :Integer );
    destructor  Destroy;  override;
    procedure WriteToH( HTable: TDataSet );
  end;



  TLPktCharData = class (TFuncCharData)
  private
      {FQMin       :Double;
      FQMax       :Double;}

  protected
    FLPkt        :TLPkt;
    procedure   SetHMax;                      virtual;
    procedure   SetPMax;                      virtual;
    procedure   SetNPSHMax;                   virtual;
    procedure InitCopyInstance( inst :TPompCharData );  override;
    function  LPkt :TLPktFiz;
  public
    destructor  Destroy;                      override;
    procedure ReadFromHTable( HT :TDataSet ); override;
    procedure WriteToHTable( HT :TDataSet );             override;

    procedure CreateLPktN( n :Integer );        virtual;

    function  H   ( Q :Double ) :Double;        override;
    function  P   ( Q :Double ) :Double;        override;
    function  NPSH( Q :Double ) :Double;        override;
    procedure Pomnoz( FakQ, FakH, FakP :Double );   override;
    procedure Clear;                               virtual;
    procedure SetMinMax;

    property Punkty :TLPkt read FLPkt;
  end;

  TSZCharData = class (TLPktCharData)
  private
    H0,  H1,  H2,  H3    :PFloatArray;
    P0,  P1,  P2,  P3    :PFloatArray;
    NP0, NP1, NP2, NP3   :PFloatArray;
  protected
    procedure CreateWspTabs;
    procedure ClearWspTab;
    procedure InitCopyInstance( inst :TPompCharData );  override;

  public
    destructor  Destroy;                      override;
    procedure   Clear;                        override;

    procedure InitWsp;
    procedure ObliczWsp;
    procedure ReadFromHTable( HT :TDataSet );   override;
    procedure CreateLPktN( n :Integer );        override;
    function  H   ( Q :Double ) :Double;        override;
    function  P   ( Q :Double ) :Double;        override;
    function  NPSH( Q :Double ) :Double;        override;
    procedure Pomnoz( FakQ, FakH, FakP :Double );   override;
  end;

  TSZCharDataCopy = class (TSZCharData)
  private
    FQMin, FQMax :Double;
  public
    // ustawianie parametrow be przeliczen charakterystyki
    procedure SetObrBP( Value :Double );
    procedure SetSrednBP( Value :Double );
    procedure Assign(Source: TPersistent); override;
    procedure AssignRange( AQMin, AQMax :Double;
                           Source :TFuncCharData ); 

    function  GetQMin      :Double;           override;
    function  GetQMax      :Double;           override;
  end;


  TP3CharData = class (TLPktCharData)
    protected
      procedure   SetHMax;                      override;
      procedure   SetPMax;                      override;
      procedure   SetNPSHMax;                   override;
  end;



IMPLEMENTATION


{ TLPktFiz }

constructor TLpktFiz.CreateN(aN: Integer);
begin
  inherited Create;
  f_n_pt := aN;
  InitTables;
end;


constructor TLPktFiz.CreateFromH( HTable: TDataSet );
var
  nPt0 : word;
  i    : word;
  wsp0, wsp1, wsp2 : Double;
begin
  inherited Create;
  with HTable do
  begin
    fMet := UpperCase(FieldByName('h_met').AsString);
    if fMet = 'LR' then
    begin
      {LPkt := array(4,n_pt)
        Lpkt[1,1]:=h_Qmin
        Lpkt[1,n_pt]:=h_Qmax
        for i=2 to n_pt-1
           Lpkt[1,i]:=h_Qmin+(h_Qmax-h_Qmin)/(n_pt-2)*(0.5+i-2) //Q-wydajnosci
        next
        for i=1 to n_pt
           Lpkt[2,i]:=FieldGet(npt0+i)
           Lpkt[3,i]:=FieldGet(npt0+i+n_pt)
           Lpkt[4,i]:=FieldGet(npt0+i+2*n_pt)
        next}
    end
    else if (met = 'SZ') or (met = 'LZ') then
    begin
      nPt0 := FieldByName('PT1').Index - 1;
      f_n_pt := FieldByName('n_pt').AsInteger;
      InitTables;
      for i := 1 to n_pt do
      begin
        fQ^[i]     := Fields[npt0+i].AsFloat;             { Q }
        fH^[i]     := Fields[npt0+i+n_pt].AsFloat;        { H }
        fP^[i]     := Fields[npt0+i+2*n_pt].AsFloat;      { P }
        fNPSH^[i]  := Fields[npt0+i+3*n_pt].AsFloat;      { NPSH }
      end;
    end
    else if met = 'P3' then
    begin
      f_n_pt  := 3;
      InitTables;

      fQ^[1]  := 0;
      fQ^[2]  := 0;
      fQ^[3]  := 0;

      W3DajWsp( FieldByName('H_Qmin').AsFloat,
                FieldByName('PT1').AsFloat,
                FieldByName('H_Qmax').AsFloat,
                FieldByName('PT2').AsFloat,
                FieldByName('PT3').AsFloat,
                FieldByName('PT4').AsFloat,
                wsp0, wsp1, wsp2);
      fH^[1] := wsp0;
      fH^[2] := wsp1;
      fH^[3] := wsp2;

      W3DajWsp( FieldByName('H_Qmin').AsFloat,
                FieldByName('PT1').AsFloat,
                FieldByName('H_Qmax').AsFloat,
                FieldByName('PT5').AsFloat,
                FieldByName('PT6').AsFloat,
                FieldByName('PT7').AsFloat,
                wsp0, wsp1, wsp2);
      fP^[1] := wsp0;
      fP^[2] := wsp1;
      fP^[3] := wsp2;

      W3DajWsp( FieldByName('H_Qmin').AsFloat,
                FieldByName('PT1').AsFloat,
                FieldByName('H_Qmax').AsFloat,
                FieldByName('PT8').AsFloat,
                FieldByName('PT9').AsFloat,
                FieldByName('PT10').AsFloat,
                wsp0, wsp1, wsp2);
      fNPSH^[1] := wsp0;
      fNPSH^[2] := wsp1;
      fNPSH^[3] := wsp2;

    end;
  end

end;


destructor TLPktFiz.Destroy;
begin
  if Assigned(fQ) then
  begin
    FreeFloatArray( fQ, n_pt )
  end;
  if Assigned(fH) then
  begin
    FreeFloatArray( fH, n_pt )
  end;
  if Assigned(fP) then
  begin
    FreeFloatArray( fP, n_pt )
  end;
  if Assigned(fNPSH) then
  begin
    FreeFloatArray( fNPSH, n_pt )
  end;
end;

procedure TLpktFiz.SetH(pos: integer; const Value: Double);
begin
  fH^[pos] := Value;
end;

procedure TLpktFiz.SetNPSH(pos: integer; const Value: Double);
begin
  fNPSH^[pos] := Value;
end;

procedure TLpktFiz.SetP(pos: integer; const Value: Double);
begin
  fP^[pos] := Value;
end;

procedure TLpktFiz.SetQ(pos: integer; const Value: Double);
begin
  fQ^[pos] := Value;
end;



procedure TLpktFiz.WriteToH(HTable: TDataSet);
var
  nPt0 : word;
  i    : word;
begin
  with HTable do
  begin
    FieldByName('h_met').AsString := fMet;
    if Met = 'LR' then
    begin
      // obecnie nie uzywane
    end
    else if (met = 'SZ') or (met = 'LZ') then
    begin
      nPt0 := FieldByName('PT1').Index - 1;
      FieldByName('n_pt').AsInteger := f_n_pt;
      for i := 1 to n_pt do
      begin
        Fields[npt0+i].AsFloat         := fQ^[i];        { Q }
        Fields[npt0+i+n_pt].AsFloat    := fH^[i];        { H }
        Fields[npt0+i+2*n_pt].AsFloat  := fP^[i];        { P }
        Fields[npt0+i+3*n_pt].AsFloat  := fNPSH^[i];     { NPSH }
      end;
    end
    else if met = 'P3' then
    begin
      // tez juz nie uzywane
    end;
  end


end;



procedure TLpktFiz.InitTables;
begin
  fQ     := NewFloatArray( n_pt );
  fH     := NewFloatArray( n_pt );
  fP     := NewFloatArray( n_pt );
  fNPSH  := NewFloatArray( n_pt );
end;



function TLPktFiz.get_met             : string;
begin
  get_met := fMet;
end;

function TLPktFiz.get_n_pt            : word;
begin
  get_n_pt := f_n_pt;
end;

function TLPktFiz.getQ(pos:integer)   : Double;
begin
  getQ := fQ^[pos];
end;

function TLPktFiz.getH(pos:integer)   : Double;
begin
  getH := fH^[pos];
end;

function TLPktFiz.getP(pos:integer)   : Double;
begin
  getP := fP^[pos];
end;

function TLPktFiz.getNPSH(pos:integer): Double;
begin
  getNPSH := fNPSH^[pos];
end;



{ TLPktCharData }

destructor  TLPktCharData.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TLPktCharData.Clear;
begin
  FLPkt.Free;
  FLPkt := NIL;
end;

procedure TLPktCharData.CreateLPktN(n: Integer);
begin
  FLPkt := TLpktFiz.CreateN( n );
end;

procedure TLPktCharData.SetMinMax;
begin
  FCharQMin := Punkty.Q[1];
  FCharQMax := Punkty.Q[Punkty.n_pt];
  SetHMax;
  SetPMax;
  SetNPSHMax;
end;

procedure TLPktCharData.Pomnoz(FakQ, FakH, FakP: Double);
var
  i       :Integer;
begin
  inherited Pomnoz(FakQ, FakH, FakP);
  for i := 1 to Punkty.n_pt do
  begin
    Punkty.Q[i] := Punkty.Q[i] * FakQ;
    Punkty.H[i] := Punkty.H[i] * FakH;
    Punkty.P[i] := Punkty.P[i] * FakP;
  end;
end;



procedure TLPktCharData.ReadFromHTable( HT :TDataSet );
begin
  inherited ReadFromHTable( HT );
  FLPkt := TLPktFiz.CreateFromH( HT );
  FCharQMin := HT.FieldByName( 'H_QMin' ).AsFloat;
  FCharQMax := HT.FieldByName( 'H_QMax' ).AsFloat;
  SetHMax;
  SetPMax;
  SetNPSHMax;
end;

procedure TLPktCharData.WriteToHTable(HT: TDataSet);
begin
  inherited;
  HT.FieldByName( 'H_QMin' ).AsFloat := FCharQMin;
  HT.FieldByName( 'H_QMax' ).AsFloat := FCharQMax;
  LPkt.WriteToH(HT);
end;



procedure TLPktCharData.InitCopyInstance(inst: TPompCharData);
var
  lpi     :TLPktCharData;
  i       :Integer;
begin
  lpi := inst as TLPktCharData;
  lpi.FLPkt := TLpktFiz.Create;
  lpi.LPkt.fMet := self.LPkt.Met;
  lpi.LPkt.f_n_pt := self.LPkt.n_pt;
  lpi.LPkt.InitTables;
  with lpi.LPkt do
  begin
    for i := 1 to n_pt do
    begin
      fQ^[i] := self.LPkt.Q[i];
      fH^[i] := self.LPkt.H[i];
      fP^[i] := self.LPkt.P[i];
      fNPSH^[i] := self.LPkt.NPSH[i];
    end;
  end;

  lpi.FObroty := Obroty;
  lpi.FSrednica := Srednica;
  lpi.FCharQMin := GetCharQMin;
  lpi.FCharQMax := GetCharQMax;
  lpi.FCharHMin := GetCharHMin;
  lpi.FCharHMax := GetCharHMax;
  lpi.FCharPMax := FCharPMax;
  lpi.FCharNPSHMax := FCharNPSHMax;
end;

function TLPktCharData.LPkt: TLPktFiz;
begin
  result := FLPkt as TLPktFiz;
end;



procedure   TLPktCharData.SetHMax;
var
  i         :Longint;
begin
  FCharHMin := LPkt.H[1];
  FCharHMax := LPkt.H[1];
  for i := 2 to LPkt.n_pt do
  begin
    if LPkt.H[i] > FCharHMax then
      FCharHMax := LPkt.H[i];
    if LPkt.H[i] < FCharHMin then
      FCharHMin := LPkt.H[i];
  end;

end;

procedure   TLPktCharData.SetPMax;
var
  i         :Longint;
begin
  FCharPMax := 0;
  for i := 1 to LPkt.n_pt do
  begin
    if LPkt.P[i] > FCharPMax then
      FCharPMax := LPkt.P[i];
  end;
end;

procedure   TLPktCharData.SetNPSHMax;
var
  i         :Longint;
begin
  FCharNPSHMax := 0;
  for i := 1 to LPkt.n_pt do
  begin
    if LPkt.NPSH[i] > FCharNPSHMax then
      FCharNPSHMax := LPkt.NPSH[i];
  end;
end;




function  TLpktCharData.H   ( Q :Double ) :Double;
begin
  if LPkt <> NIL then
    result := WartTab( q, LPkt.fQ^, LPkt.fH^, LPkt.n_pt, LPkt.met )
  else
    result := 0;
end;

function  TLpktCharData.P   ( Q :Double ) :Double;
begin
  if LPkt <> NIL then
    result := WartTab( q, LPkt.fQ^, LPkt.fP^, LPkt.n_pt, LPkt.met )
  else
    result := 0;
end;

function  TLpktCharData.NPSH( Q :Double ) :Double;
begin
  if LPkt <> NIL then
    result := WartTab( q, LPkt.fQ^, LPkt.fNPSH^, LPkt.n_pt, LPkt.met )
  else
    result := 0;
end;




{ TSZCharData }

  //----------------------------------------------------------------------------
  // Dane charakterystyki pompy typu Spline (identyfikator SZ)

destructor TSZCharData.Destroy;
begin
  inherited Destroy;
end;

procedure TSZCharData.Clear;
begin
  ClearWspTab;
  inherited;
end;

procedure TSZCharData.ClearWspTab;
begin
  FreeFloatArray( H0 );
  FreeFloatArray( H1 );
  FreeFloatArray( H2 );
  FreeFloatArray( H3 );

  FreeFloatArray( P0 );
  FreeFloatArray( P1 );
  FreeFloatArray( P2 );
  FreeFloatArray( P3 );

  FreeFloatArray( NP0 );
  FreeFloatArray( NP1 );
  FreeFloatArray( NP2 );
  FreeFloatArray( NP3 );

  H0 := NIL;
  H1 := NIL;
  H2 := NIL;
  H3 := NIL;

  P0 := NIL;
  P1 := NIL;
  P2 := NIL;
  P3 := NIL;


  NP0 := NIL;
  NP1 := NIL;
  NP2 := NIL;
  NP3 := NIL;

end;

procedure TSZCharData.CreateLPktN(n: Integer);
begin
  inherited;
  TLpktFiz(FLPkt).fMet := 'SZ'
end;


procedure TSZCharData.ReadFromHTable( HT :TDataSet );
begin
  inherited ReadFromHTable( HT );
  InitWsp;

end;

procedure TSZCharData.InitWsp;
begin
  CreateWspTabs;
  ObliczWsp;
end;

procedure TSZCharData.CreateWspTabs;
begin
  H0 := NewFloatArray( LPkt.n_pt );
  H1 := NewFloatArray( LPkt.n_pt );
  H2 := NewFloatArray( LPkt.n_pt );
  H3 := NewFloatArray( LPkt.n_pt );

  P0 := NewFloatArray( LPkt.n_pt );
  P1 := NewFloatArray( LPkt.n_pt );
  P2 := NewFloatArray( LPkt.n_pt );
  P3 := NewFloatArray( LPkt.n_pt );

  NP0 := NewFloatArray( LPkt.n_pt );
  NP1 := NewFloatArray( LPkt.n_pt );
  NP2 := NewFloatArray( LPkt.n_pt );
  NP3 := NewFloatArray( LPkt.n_pt );
end;


procedure TSZCharData.ObliczWsp;
var
  d1, d2  :PFloatArray;
begin
  d1 := NewFloatArray( LPkt.n_pt );
  d2 := NewFloatArray( LPkt.n_pt );

  try
    Spline( LPkt.n_pt, LPkt.fQ^, LPkt.fH^, d1^, d2^ );
    PolySpline( LPkt.n_pt, LPkt.fQ^, LPkt.fH^, d1^, d2^, H0^, H1^, H2^, H3^ );

    Spline( LPkt.n_pt, LPkt.fQ^, LPkt.fP^, d1^, d2^ );
    PolySpline( LPkt.n_pt, LPkt.fQ^, LPkt.fP^, d1^, d2^, P0^, P1^, P2^, P3^ );

    Spline( LPkt.n_pt, LPkt.fQ^, LPkt.fNPSH^, d1^, d2^ );
    PolySpline( LPkt.n_pt, LPkt.fQ^, LPkt.fNPSH^, d1^, d2^, NP0^, NP1^, NP2^, NP3^ );
  finally
    FreeFloatArray( d1, LPkt.n_pt );
    FreeFloatArray( d2, LPkt.n_pt );
  end;
end;

function  TSZCharData.H   ( Q :Double ) :Double;
begin
  if LPkt <> NIL then
    result := SplineValue( LPkt.n_pt, q, LPkt.fQ^, H0^, H1^, H2^, H3^ )
  else
    result := 0;
end;

function  TSZCharData.P   ( Q :Double ) :Double;
begin
  if LPkt <> NIL then
    result := SplineValue( LPkt.n_pt, q, LPkt.fQ^, P0^, P1^, P2^, P3^ )
  else
    result := 0;
end;

function  TSZCharData.NPSH( Q :Double ) :Double;
begin
  if LPkt <> NIL then
    result := SplineValue( LPkt.n_pt, q, LPkt.fQ^, NP0^, NP1^, NP2^, NP3^ )
  else
    result := 0;
end;

procedure TSZCharData.InitCopyInstance(inst: TPompCharData);
begin
  inherited InitCopyInstance(inst);
  (inst as TSZCharData).InitWsp;
end;

procedure TSZCharData.Pomnoz(FakQ, FakH, FakP: Double);
begin
  inherited Pomnoz(FakQ, FakH, FakP);
  ObliczWsp;
end;



{ TP3CharData }

procedure   TP3CharData.SetHMax;
var
  i         :Longint;
  vQ, vH    :Double;
begin
  FCharHMax := 0;
  for i := 0 to 10 do
  begin
    vQ := Lin( i, 0, 10, GetCharQMin, GetCharQMax );
    vH := H(vQ);
    if vH > FCharHMax then
      FCharHMax := vH;
  end;
end;

procedure   TP3CharData.SetPMax;
var
  i         :Longint;
  vQ, vP    :Double;
begin
  FCharPMax := 0;
  for i := 0 to 10 do
  begin
    vQ := Lin( i, 0, 10, GetCharQMin, GetCharQMax );
    vP := P(vQ);
    if vP > FCharPMax then
      FCharPMax := vP;
  end;
end;


procedure   TP3CharData.SetNPSHMax;
var
  i         :Longint;
  vQ, vNPSH    :Double;
begin
  FCharNPSHMax := 0;
  for i := 0 to 10 do
  begin
    vQ := Lin( i, 0, 10, GetCharQMin, GetCharQMax );
    vNPSH := NPSH(vQ);
    if vNPSH > FCharNPSHMax then
      FCharNPSHMax := vNPSH;
  end;
end;







{ TSZCharDataCopy }

procedure TSZCharDataCopy.Assign(Source: TPersistent);
var
  sfunc   :TFuncCharData;
  sz      :TSZCharData;
  aq       :Double;
  i        :Integer;
begin
  if Source is TFuncCharData then
  begin
    Clear;
    sfunc := TFuncCharData(Source);
    if Source is TSZCharData then
    begin
      TSZCharData(sfunc).InitCopyInstance(self);
    end
    else
    begin
      if FLPkt <> NIL then
      begin
        FLPkt.Free;
        FLPkt := NIL;
      end;
      CreateLPktN(15);
      for i := 1 to 15 do
      begin
        aq := Lin( i, 1, 15, sfunc.GetCharQMin, sfunc.GetCharQMax );
        LPkt.Q[i] := aq;
        LPkt.H[i] := sfunc.H( aq );
        LPkt.P[i] := sfunc.P( aq );
        LPkt.NPSH[i] := sfunc.NPSH( aq );
      end;
      SetMinMax;
      InitWsp;
    end;
    FQMin := max(sfunc.GetQMin, sfunc.GetCharQMin);
    FQMax := min(sfunc.GetQMax, sfunc.GetCharQMax);
  end
  else
    inherited;
end;

procedure TSZCharDataCopy.AssignRange(AQMin, AQMax: Double;
  Source: TFuncCharData);
var
  i       :Integer;
  aq      :Double;
begin
  Clear;
  if FLPkt <> NIL then
  begin
    FLPkt.Free;
    FLPkt := NIL;
  end;
  CreateLPktN(15);
  for i := 1 to 15 do
  begin
    aq := Lin( i, 1, 15, AQMin, AQMax );
    LPkt.Q[i] := aq;
    LPkt.H[i] := Source.H( aq );
    LPkt.P[i] := Source.P( aq );
    LPkt.NPSH[i] := Source.NPSH( aq );
  end;
  SetMinMax;
  InitWsp;
  FQMin := max(Source.GetQMin, Source.GetCharQMin);
  FQMax := min(Source.GetQMax, Source.GetCharQMax);

end;

function TSZCharDataCopy.GetQMax: Double;
begin
  result := FQMax;
end;

function TSZCharDataCopy.GetQMin: Double;
begin
  result := FQMin;
end;

procedure TSZCharDataCopy.SetObrBP(Value: Double);
begin
  FObroty := Value;
end;

procedure TSZCharDataCopy.SetSrednBP(Value: Double);
begin
  FSrednica := Value;
end;

BEGIN
  RegisterCharData( 'SZ', TSZCharData );
  RegisterCharData( 'P3', TP3CharData );
  RegisterCharData( 'LZ', TLPktCharData );
END.
