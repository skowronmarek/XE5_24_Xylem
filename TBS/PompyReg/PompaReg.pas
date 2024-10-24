unit PompaReg;

interface

uses
  SysUtils, Classes, DB, Math,
  Diagrams, KrMath, DGraph,
  OPompa, PompySQL,PumpIntf, LinCharU, B4CharU, FunctU, RegTools;

type
  TRegCharData = class;

  TPompaReg = class (TPompa)
  protected
    function  CreateCDInner( O :TComponent ) :TRegCharData;  virtual; abstract;
    function GetRegId: string;                               virtual;
  public
    function  CreateCharDataDB( O :TComponent )   :TPompCharData; override;
    {
    function  CreateForm( AOwner :TComponent;
                          AMDIChild :Boolean = true ) :TForm;     override;
    }
    property  RegId :string read GetRegId;
  end;


  TRegCharData = class(TPompCharData)
  private
    FCharQMin      :Double;
    FCharQMax      :Double;
    FCharHMin      :Double;
    FCharHMax      :Double;
    FCharPMax      :Double;
    FCharNPSHMax   :Double;
    FParamUstawiony: Boolean;
    FParam: Double;
    FParamNextNom: Double;
    function GetCharL(i: Integer): TFuncCharData;
    function GetLicznikChar: Integer;
    procedure SetParam(const Value: Double);
    procedure SetParamUstawiony(const Value: Boolean);
    function GetListWczytana: Boolean;
    function GetPMaxUst: Double;
  protected
    procedure InitCopyInstance( inst :TPompCharData );    override;
    procedure SetObroty(const Value: Double);             override;
    procedure SetSrednica(const Value: Double);           override;
    function GetObroty: Double;                           override;
    function GetSrednica: Double;                         override;

  public
    procedure ReadFromHTable( HT :TDataSet );             override;
    //procedure WriteToHTable( HT :TDataSet );              virtual; abstract;
              //wywolanie charakterystyki na diagramie
    function  GetDiagFun( id :string;
                    Owner :TDiagFunction ):TCharDataDiagFun;   override;
    function  WorkPoint( Sel :IPumpCharSel; var Qr, Hr :Double ) :Boolean;
                                                          override;
    function  GetQMin  :Double;                           override;
    function  GetQMax  :Double;                           override;
    function  GetCharQMin  :Double;                       override;
    function  GetCharQMax  :Double;                       override;
    function  GetHMin  :Double;                           override;
    function  GetHMax  :Double;                           override;
    function  GetCharHMin  :Double;                       override;
    function  GetCharHMax  :Double;                       override;
    function  GetCharPMax  :Double;                       override;
    function  GetCharNPSHMax  :Double;                    override;

    //procedure Pomnoz( FakQ, FakH, FakP :Double );         override;

  protected
    FB4Char   :TB4Data;
    FCharUst  :TFuncCharData;
    FCharList :TList;
    FParLst   :array of Double;
    hid       :string;
    function SCompare(X, Y: Double): Double;             virtual;
    function GetParId :string;                           virtual; abstract;
    function GetParH( AH :TDataSet ) :Double;            virtual;
    function GetParLegendText( const rid    :string; APar :Double) :string;
                                                         virtual;
             // opis parametru na diagramie

    //function FuncPar( par0, parDocel, Q0, H0, P0, NPSH0 :Double;
    //                   var Qc, Hc, Pc, NPSHc :Double ) :Boolean;   virtual; abstract;
    function FuncParOdw( par0 :Double; var parDocel :Double; Q0, H0,
                         QDocel, HDocel :Double ) :Boolean;     virtual; abstract;
    function PrzeliczP( P0, Par0, ParCel :Double ) :Double;     virtual; abstract;
    function PrzeliczNPSH( NPSH0, Par0, ParCel :Double ) :Double; virtual; abstract;
    function GetFunctHodQ( Q0, H0 :Double ) :TRealFunctObject;  virtual; abstract;
    procedure StworzCharWP( i1, i2 :Integer;
                            Qr, Hr, Qr1, Hr1,
                            Qr2, Hr2 :Double);                  virtual;
    procedure CharWPInne( cdCel :TSZCharDataCopy;
                          cd1, cd2 :TFuncCharData; APar :Double); virtual; abstract;
    procedure Oblicz;                                           virtual;
    procedure QSort( L, R :Integer );
  public
    destructor  Destroy;                                 override;

    procedure FreeList;
    procedure Wczytaj( DB :TDBPompy );
    procedure WczytajOtoczke(DB :TDBPompy);
    procedure WczytajListe(DB :TDBPompy);
    procedure Sort;

    property CharList [i :Integer]: TFuncCharData read GetCharL;
    property LicznikChar :Integer read GetLicznikChar;
    property Param :Double read FParam write SetParam;
    property ParamNextNom :Double read FParamNextNom;
    property ParamUstawiony :Boolean read FParamUstawiony write SetParamUstawiony;
    property ListaWczytana :Boolean read GetListWczytana;
    property PMaxUst :Double read GetPMaxUst;
  end;

  TPompFunDiagList = class (TCharDataDiagFun)
  private
    FList :TList;
    FLegend: Boolean;
    FAllChars: Boolean;
    function GetCount: Integer;
    function GetDiagFun(i: Integer): TCharDataDiagFun;
    procedure SetLegend(const Value: Boolean);
    procedure SetAllChars(const Value: Boolean);
  protected
    procedure DrawFun  ( dt  :TSpecDrawData; bw :Boolean );  override;
    procedure SetHolder( v :TDiagFunction );             override;
  public
    constructor Create( AOwner :TComponent );            override;
    destructor  Destroy;                                 override;


    procedure Add( df :TCharDataDiagFun );
    procedure Clear;

    property Legend :Boolean read FLegend write SetLegend;
    property AllChars :Boolean read FAllChars write SetAllChars;
    property Count :Integer read GetCount;
    property DiagFun[ i :Integer ] :TCharDataDiagFun read GetDiagFun;
  end;

implementation

{
uses
  PompaRegFormU;
}

procedure ShowMessage( const sMsg :string );
begin
  // pozniej sie cos wymysli
end;


{ TPompaReg }

function TPompaReg.CreateCharDataDB(O: TComponent): TPompCharData;
var
  cd     :TRegCharData;
begin
  result := NIL;
  if IsDB then
  begin
    cd := CreateCDInner(O);
    cd.Pompa := self;
    cd.Wczytaj(DB);

    FPompa.CharQMin := cd.FCharQMin;
    FPompa.CharQMax := cd.CharQMax;
    result := cd;
  end;
end;

{
function TPompaReg.CreateForm(AOwner: TComponent;
  AMDIChild: Boolean): TForm;
var
  F      :TPompaRegForm;
begin
  F := TPompaRegForm.StworzDlaPompy( AOwner, self, AMDIChild );
  result := F;
end;
}

function TPompaReg.GetRegId: string;
begin
  result := '';
end;

{ TRegCharData }

destructor TRegCharData.Destroy;
begin
  FreeList;
  inherited;
end;

procedure TRegCharData.FreeList;
var
  i       :Integer;
begin
  if not ListaWczytana then
    EXIT;
  for i := 0 to LicznikChar-1 do
    CharList[i].Free;
  FCharList.Free;
end;

function TRegCharData.GetCharHMax: Double;
begin
  if FB4Char <> NIL then
    Result := FB4Char.GetCharHMax
  else if LicznikChar > 0 then
    result := Max( CharList[0].GetCharHMax,
                   CharList[LicznikChar-1].GetCharHMax )
  else
    Result := 0;
end;

function TRegCharData.GetCharHMin: Double;
begin
  if FB4Char <> NIL then
    result := FB4Char.GetCharHMin
  else if LicznikChar > 0 then
    result := Min( CharList[0].GetCharHMin,
                   CharList[LicznikChar-1].GetCharHMin )
  else
    Result := 0;
end;

function TRegCharData.GetCharL(i: Integer): TFuncCharData;
begin
  result := TFuncCharData(FCharList.Items[i]);
end;

function TRegCharData.GetCharNPSHMax: Double;
begin
  if LicznikChar > 0 then
    result := Max( CharList[0].GetCharNPSHMax,
                   CharList[LicznikChar-1].GetCharNPSHMax )
  else
    Result := 0;
end;

function TRegCharData.GetCharPMax: Double;
begin
  if LicznikChar > 0 then
    result := Max( CharList[0].GetCharPMax,
                   CharList[LicznikChar-1].GetCharPMax )
  else
    Result := 0;
end;

function TRegCharData.GetCharQMax: Double;
begin
  if ListaWczytana and (LicznikChar > 0) then
    result := CharList[LicznikChar-1].GetCharQMax
  else if FB4Char <> NIL then
    result := FB4Char.GetCharQMax
  else
    result := 0;
end;

function TRegCharData.GetCharQMin: Double;
begin
  if ListaWczytana and (LicznikChar > 0) then
    result := CharList[0].GetCharQMin
  else if FB4Char <> NIL then
    result := FB4Char.GetCharQMin
  else
    result := 0;
end;


function TRegCharData.GetDiagFun(id: string;
  Owner: TDiagFunction): TCharDataDiagFun;
var
  dfl    :TPompFunDiagList;
  df     :TCharDataDiagFun;
  i      :Integer;
  rid    :string;
  legPos :Integer;
  AMax   :Double;

  procedure AddLegend( df :TCharDataDiagFun; APar :Double );
  begin
    if (df is TFuncDiagFun) then
      with TFuncDiagFun(df) do
    begin
      if (id = 'H') then
      begin
        Legend := True;
        SetLegQ( [legPos / (LicznikChar+2)] );
        inc(legPos);
        //LegText := Format( '%s = %.0f', [rid, APar] );
        LegText := GetParLegendText(rid, APar);
      end
      else
        Legend := False;
    end;

  end;

begin
  rid := TPompaReg(Pompa).GetRegId;
  dfl := TPompFunDiagList.Create( Owner );
  dfl.CharData := self;
  legPOs := 1;

  if FB4Char <> NIL then
  begin
    df := FB4Char.GetDiagFun( id, Owner );
    if df <> NIL then
      dfl.Add(df);
  end;

  if FCharUst <> NIL then
  begin
    df := FCharUst.GetDiagFun( id, Owner );
    if df <> NIL then
    begin
      dfl.Add(df);
      df.MinXRDraw := FCharUst.GetCharQMin;
      df.MaxXRDraw := FCharUst.GetCharQMax;
      df.Tag := 1;
      AddLegend( df, Param );
      //df.CountMaxYR(FCharUst.GetCharQMax);
    end;
  end;

  if not ListaWczytana then
    WczytajListe( Pompa.DB );

  for i := 0 to LicznikChar-1 do
  begin
    df := CharList[i].GetDiagFun( id, Owner );
    AddLegend( df, FParLst[i] );
    if df <> NIL then
      dfl.Add(df);
  end;

  if dfl.Count > 0 then
  begin
    for i := 0 to dfl.Count-1 do
    begin
      //dfl.DiagFun[i].Holder := Owner;
      if dfl.DiagFun[i] is TFuncDiagFun then
      begin
        with TFuncDiagFun(dfl.DiagFun[i]) do
        begin
          Bolded := false;
          //Legend := false;
        end;
      end;
    end;
  end
  else
  begin
    dfl.Free;
    dfl := NIL;
  end;
  Owner.Drawer := dfl;
  result := dfl;
end;

function TRegCharData.GetHMax: Double;
begin
  if FB4Char <> NIL then
    result := FB4Char.GetHMax
  else if ListaWczytana and (LicznikChar > 0) then
    result := CharList[LicznikChar-1].GetHMax
  else
    result := 0;
end;

function TRegCharData.GetHMin: Double;
begin
  if FB4Char <> NIL then
    result := FB4Char.GetHMin
  else if ListaWczytana and (LicznikChar > 0) then
    result := CharList[0].GetCharHMin
  else
    result := 0;
end;

function TRegCharData.GetLicznikChar: Integer;
begin
  if FCharList <> NIL then
    result := FCharList.Count
  else
    result := 0;
end;

function TRegCharData.GetListWczytana: Boolean;
begin
  result := FCharList <> NIL;
end;

function TRegCharData.GetObroty: Double;
begin
  if FCharUst <> NIL then
    Result := FCharUst.Obroty
  else if (LicznikChar > 0) then
    Result := CharList[0].Obroty;
end;

function TRegCharData.GetParH(AH: TDataSet): Double;
begin
  Result := AH.FieldByName(GetParId).AsFloat;
end;

function TRegCharData.GetParLegendText( const rid    :string;
                                        APar :Double): string;
begin
  Result := Format( '%s = %.0f', [rid, APar] );
end;

function TRegCharData.GetPMaxUst: Double;
begin
  if FCharUst <> NIL then
    Result := FCharUst.CharPMax
  else
    Result := 0;
end;

function TRegCharData.GetQMax: Double;
begin
  if Pompa <> NIL then
    result := Pompa.QMax
  else if FB4Char <> NIL then
    result := FB4Char.GetQMax
  else if ListaWczytana and (LicznikChar > 0) then
    result := CharList[LicznikChar-1].GetQMax
  else
    result := 0;
end;

function TRegCharData.GetQMin: Double;
begin
  if Pompa <> NIL then
    result := Pompa.QMin
  else if FB4Char <> NIL then
    result := FB4Char.GetQMin
  else if ListaWczytana and (LicznikChar > 0) then
    result := CharList[0].GetQMin
  else
    result := 0;
end;

function TRegCharData.GetSrednica: Double;
begin
  if FCharUst <> NIL then
    Result := FCharUst.Srednica
  else if (LicznikChar > 0) then
    Result := CharList[0].Srednica;
end;

procedure TRegCharData.InitCopyInstance(inst: TPompCharData);
begin

end;

procedure TRegCharData.Oblicz;
begin
  // chyba to trzeba skasowac
end;

procedure TRegCharData.QSort(L, R: Integer);
var
  I, J: Integer;
  P, T: Double;
  Pt  : Pointer;

begin
  repeat
    I := L;
    J := R;
    P := FParLst[(L + R) shr 1];
    repeat
      while SCompare(FParLst[I], P) < 0 do Inc(I);
      while SCompare(FParLst[J], P) > 0 do Dec(J);
      if I <= J then
      begin
        T  := FParLst[I];
        Pt := FCharList[I];
        FParLst[I] := FParLst[J];
        FCharList[I] := FCharList[J];
        FParLst[J] := T;
        FCharList[J] := Pt;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QSort(L, J);
    L := I;
  until I >= R;
end;

procedure TRegCharData.ReadFromHTable(HT: TDataSet);
begin
  // NIC
end;

function TRegCharData.SCompare( X, Y :Double ): Double;
begin
  result := X-Y;
end;

procedure TRegCharData.SetObroty(const Value: Double);
begin

end;

procedure TRegCharData.SetParam(const Value: Double);
begin
  FParam := Value;
end;

procedure TRegCharData.SetParamUstawiony(const Value: Boolean);
begin
  FParamUstawiony := Value;
end;

procedure TRegCharData.SetSrednica(const Value: Double);
begin

end;

procedure TRegCharData.Sort;
begin
  if LicznikChar > 0 then
    QSort(0,LicznikChar-1)
end;

procedure TRegCharData.StworzCharWP( i1, i2 :Integer;
                                     Qr, Hr,
                                     Qr1, Hr1,
                                     Qr2, Hr2 :Double);


var
  par1, par2  :Double;
  par     :Double;
  fq, fH  :Double;
  odl1, odl2 :Double;
  cd       :TSZCharDataCopy;
  cd1, cd2 :TFuncCharData;
  i, n     :Integer;
  q1, h1   :Double;
  qn, hn   :Double;
  qrt1, hrt1 :Double;
  qrt2, hrt2 :Double;
  cs       :TPmpRegCharSelPomoc;
  ok       :Boolean;

  function Srednia( v1, v2 :Double ) :Double;
  begin
    result  := f_div(v1*odl2 ,(odl1+odl2)) +
               f_div(v2*odl1 ,(odl1+odl2));
  end;

  procedure ObliczQH;
  var
    q, h    :Double;
    p       :Double;
    npsh    :Double;
    x1, x2  :Double;
  begin
    q := Lin( fQ, 0, 1, Qrt1, Qrt2 );
    if abs(qrt1 - qrt2) >= 0.001 then
      h := cs.dH(q)
    else
      h := Lin( fH, 0, 1, Hrt1, Hrt2 );

    x1 := PrzeliczP( CharList[i1].P(qrt1), Par1, Par );
    x2 := PrzeliczP( CharList[i2].P(qrt2), Par2, Par );
    p := Srednia(x1, x2);

    x1 := PrzeliczNPSH( CharList[i1].NPSH(qrt1), Par1, Par );
    x2 := PrzeliczNPSH( CharList[i2].NPSH(qrt2), Par2, Par );
    npsh := Srednia(x1, x2);

    cd.Punkty.Q[i]     := q;
    cd.Punkty.H[i]     := h;
    cd.Punkty.P[i]     := p;
    cd.Punkty.NPSH[i]  := npsh;
  end;

begin
  FuncParOdw( FParLst[i1], par1, Qr1, Hr1, Qr, Hr );
  FuncParOdw( FParLst[i2], par2, Qr2, Hr2, Qr, Hr );

  FParamNextNom := FParLst[i1];
  fq := f_div((Qr-Qr1) , (Qr2-Qr1));
  fh := f_div((Hr-Hr1) , (Hr2-Hr1));

  // Tu wyliczyc srednia wazona
  odl1 := Hypot( Qr1-Qr, Hr1-Hr );
  odl2 := Hypot( Qr2-Qr, Hr2-Hr );
  par := f_div(par1*odl2,(odl1+odl2))
         + f_div(par2*odl1,(odl1+odl2));

  n := 11;
  cd := TSZCharDataCopy.Create(self);
  cd.CreateLPktN(n);
  cs := TPmpRegCharSelPomoc.Create;
  try
    q1 := CharList[i1].GetCharQMin;
    h1 := CharList[i1].H(q1);
    cs.Func := GetFunctHodQ( q1, h1 );
    ok := CharList[i2].WorkPoint( cs, qrt2, hrt2 );
    if ok then
    begin
      qrt1 := q1;
      hrt1 := h1;
      if (q1 = 0) and (abs(qrt2) < 0.001) then
      begin
        qrt2 := 0;
        hrt2 := CharList[i2].H(0);
      end;

    end
    else
    begin
      qrt2 := CharList[i2].GetCharQMin;
      hrt2 := CharList[i2].H(qrt2);
      cs.Func := GetFunctHodQ(qrt2, hrt2);
      ok := CharList[i1].WorkPoint( cs, qrt1, hrt1 );
      if not ok then
        ShowMessage( 'Cus nie tak!!!' );
      q1 := qrt1;
      h1 := hrt1;
    end;
    i := 1;
    ObliczQH;

    qn := CharList[i1].GetCharQMax;
    hn := CharList[i1].H(qn);
    cs.Func := GetFunctHodQ( qn, hn );
    ok := CharList[i2].WorkPoint( cs, qrt2, hrt2 );
    if ok then
    begin
      qrt1 := qn;
      hrt1 := hn;
    end
    else
    begin
      qrt2 := CharList[i2].GetCharQMax;
      hrt2 := CharList[i2].H(qrt2);
      cs.Func := GetFunctHodQ(qrt2, hrt2);
      ok := CharList[i1].WorkPoint( cs, qrt1, hrt1 );
      if not ok then
        ShowMessage( 'Cus nie tak!!!' );
      qn := qrt1;
      hn := hrt1;
    end;
    i := n;
    ObliczQH;

    i := 2;
    while i < n do
    begin
      qrt1 := Lin( i, 1, n, q1, qn );
      hrt1 := CharList[i1].H(qrt1);
      cs.Func := GetFunctHodQ( qrt1, hrt1 );
      ok := CharList[i2].WorkPoint( cs, qrt2, hrt2 );
      if not ok then
        ShowMessage( 'Cus nie tak!!!' );
      ObliczQH;

      inc(i);
    end;
    cd.InitWsp;
    cd.SetMinMax;
    CharWPInne( cd, CharList[i1], CharList[i2], par );
    FCharUst := cd;
    FParam   := par;
    ParamUstawiony := true;
    Pompa.Qr := Qr;
    Pompa.Hr := Hr;
    Pompa.Pr := cd.P(Qr);
    Pompa.NPSHr := cd.NPSH(Qr);
    Pompa.ETAr := cd.ETA(Qr);
    Pompa.ParObliczone := true;
  finally
    cs.Free;
  end;
end;

procedure TRegCharData.Wczytaj( DB :TDBPompy );
begin
  WczytajOtoczke(DB);
  if FB4Char = NIL then
    WczytajListe(DB);
end;

procedure TRegCharData.WczytajListe(DB :TDBPompy);
var
  cd      :TPompCharData;
  i       :Integer;
begin
  SetLength( FParLst, 10 );
  if ListaWczytana then
    FreeList;
  FCharList := TList.Create;
  DB.FirstH;
  while (not DB.EOH) do
  begin
    if (DB.H.FieldByName('H_MET').AsString = 'SZ') then
    begin
      cd := CreateCharData( 'SZ', self );
      cd.ReadFromHTable( DB.H );
      cd.Pompa := self.Pompa;
      i := LicznikChar;
      FCharList.Add(cd);
      if Length(FParLst) < i then
        SetLength( FParLst, i+10 );
      if GetParId <> '' then
        FParLst[i] := GetParH(DB.H);
    end;
    DB.NextH;
  end;
  Sort;
end;

procedure TRegCharData.WczytajOtoczke(DB :TDBPompy);
var
  jestB4  :Boolean;
begin
  DB.FirstH;
  jestB4 := DB.H.FieldByName('H_MET').AsString = 'B4';
  while (not DB.EOH) and (not jestB4) do
  begin
    DB.NextH;
    jestB4 := DB.H.FieldByName('H_MET').AsString = 'B4';
  end;
  if jestB4 then
  begin
    FB4Char := CreateCharData( 'B4', self ) as TB4Data;
    FB4Char.ReadFromHTable( DB.H );
    FB4Char.Pompa := self.Pompa;
  end;
end;

function TRegCharData.WorkPoint(Sel: IPumpCharSel; var Qr,
  Hr: Double): Boolean;
var
  qr1, hr1  :Double;
  qr2, hr2  :Double;
  i, i2     :Integer;
  cs        :TPmpRegCharSelPomoc;

begin
  result := true;
  if FB4Char <> NIL then
    result := FB4Char.WorkPoint(Sel, Qr, Hr)
  else
  begin
    result :=     (GetQMin <= Sel.GetQw)
              and (Sel.GetQw <= GetQMax)
              and (GetHMin <= Sel.GetHw)
              and (Sel.GetHw <= GetHMax);
    if result then
    begin
      Qr := Sel.GetQw;
      Hr := Sel.GetHw;
    end;
  end;

  if not result then
    EXIT;

  // OK
  if not ListaWczytana then
    WczytajListe( Pompa.DB );

  cs := TPmpRegCharSelPomoc.Create;
  try
    cs.Qw := Qr;
    cs.Hw := Hr;
    cs.Func := GetFunctHodQ( Qr, Hr );
    try
      i2 := -1 ;
      i := 0;
      while i < LicznikChar do
      begin
        if CharList[i].WorkPoint( cs, Qr1, Hr1 ) then
        begin
          if Qr1 > Qr then
          begin
            BREAK;
          end
          else
          begin
            i2 := i;
            Qr2 := Qr1;
            Hr2 := Hr1;
          end;
        end;

        inc(i);
      end;
    finally
      cs.FreeFunc;
    end;
    if (i2 = -1) or (i = LicznikChar) then
      result := false
    else
      StworzCharWP( i, i2, Qr, Hr, Qr1, Hr1, Qr2, Hr2 );
  finally
    cs.Free;
  end;

end;



{ TPompFunDiagList }

procedure TPompFunDiagList.Add(df: TCharDataDiagFun);
begin
  FList.Add(df);
  df.Holder := self.Holder;  
end;

procedure TPompFunDiagList.Clear;
var
  i       :Integer;
begin
  for i :=0 to Count-1 do
  begin
    //DiagFun[i].Free;
    FList[i] := NIL;
  end;
  FList.Clear;
end;

constructor TPompFunDiagList.Create(AOwner: TComponent);
begin
  inherited;
  FList :=TList.Create;
  FLegend := True;
  FAllChars := True;
end;

destructor TPompFunDiagList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TPompFunDiagList.DrawFun(dt: TSpecDrawData; bw: Boolean);
var
  i       :Integer;
begin
  for i := 0 to Count-1 do
    if AllChars or (DiagFun[i].Tag <> 0) then
      DiagFun[i].DrawFPub(dt, bw or (DiagFun[i].Tag <> 0));
end;

function TPompFunDiagList.GetCount: Integer;
begin
  result := FList.Count;
end;

function TPompFunDiagList.GetDiagFun(i: Integer): TCharDataDiagFun;
begin
  result := TCharDataDiagFun(FList[i]);
end;

procedure TPompFunDiagList.SetAllChars(const Value: Boolean);
begin
  FAllChars := Value;
  //Invalidate;
end;

procedure TPompFunDiagList.SetHolder(v: TDiagFunction);
var
  i       :Integer;
begin
  inherited;
  for i := 0 to Count-1 do
  begin
    DiagFun[i].Holder := v;
  end;
end;

procedure TPompFunDiagList.SetLegend(const Value: Boolean);
var
  i       :Integer;
begin
  FLegend := Value;
  for i := 0 to Count-1 do
  begin
    if DiagFun[i] is TFuncDiagFun then
      TFuncDiagFun(DiagFun[i]).Legend := Value; 
  end;
end;

end.
