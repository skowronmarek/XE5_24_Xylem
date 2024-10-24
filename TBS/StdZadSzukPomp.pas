unit StdZadSzukPomp;

interface

uses
  SysUtils, Classes, Graphics,
  KRMath, DGraph, Diagrams,
  PompySQL, PumpIntf, OPompa, ZadPompSzuk, jezyki;

type
  TStdPompCharSel = class;

  TStdZadSzukPomp = class (TZadSzukPomp)
  private
    FQw       :Double;
    FHw       :Double;
    FHg       :Double;
    FQMinTol   :Double;
    FQMaxTol   :Double;
    FHMinTol   :Double;
    FHMaxTol   :Double;
    FNPSHu     :Double;
    FWlaczSprawdzanie :Boolean;
    FSprawdzajNPSH :Boolean;
    FRegNZezw: Boolean;
    FRegDZezw: Boolean;
    function  GetCharSel :TStdPompCharSel;
    procedure SetQw( v :Double );
    procedure SetHw( v :Double );
    procedure SetHg( v :Double );

    procedure SetQMinTol( v :Double );
    procedure SetQMaxTol( v :Double );
    procedure SetHMinTol( v :Double );
    procedure SetHMaxTol( v :Double );
    procedure SetSprawdzajTEMP(const Value: Boolean);
    function GetSprawdzajTEMP: Boolean;
    procedure SetRegDZezw(const Value: Boolean);
    procedure SetRegNZezw(const Value: Boolean);

  protected
    procedure CreateCharSel;                       override;
    procedure CharSelDestroing;                    override;
    function  WarunekWst( DB :TDBPompy ) :Boolean; override;
    function  PompaOK( Pmp :TPompa ) :Boolean;     override;
    procedure CreateMainForm;                      override;

  public
    constructor Create( O :TComponent );           override;
    property  CharSel :TStdPompCharSel  read GetCharSel;

  published
    property Qw    :Double    read FQw     write SetQw;
    property Hw    :Double    read FHw     write SetHw;
    property Hg    :Double    read FHg     write SetHg;
    property NPSHu :Double    read FNPSHu  write FNPSHu;

    property  WlaczSprawdzanie :Boolean read  FWlaczSprawdzanie
                                        write FWlaczSprawdzanie;
    property  SprawdzajNPSH :Boolean    read  FSprawdzajNPSH
                                        write FSprawdzajNPSH;
    property  SprawdzajTEMP :Boolean    read  GetSprawdzajTEMP
                                        write SetSprawdzajTEMP;
    property  QMinTol :Double  read FQMinTol  write SetQMinTol;
    property  QMaxTol :Double  read FQMaxTol  write SetQMaxTol;
    property  HMinTol :Double  read FHMinTol  write SetHMinTol;
    property  HMaxTol :Double  read FHMaxTol  write SetHMaxTol;

    //
    property  RegDZezw :Boolean read FRegDZezw write SetRegDZezw;
    property  RegNZezw :Boolean read FRegNZezw write SetRegNZezw;
  end;


  TStdPompCharSel = class (IPumpCharSel)
    public
      function dH( Q :Double ) :Double;      override;
      function GetQw    :Double;             override;
      function GetHw    :Double;             override;
      function GetNPSHu    :Double;             override;
      function RngQIntsect( AQMin, AQMax :Double ) :Boolean;   override;
      function KluczOK( KluczeWPlikuT:string;
                               Klucze:TStrings ) :Boolean;     override;

      function Accept( Qr, Hr :Double; Pump :IPump ): Boolean; override;
      function GetDiagFun( Owner :TDiagFunction ) :TDiagFunDrawer; override;


    private

    //protected
      A0, A1, A2  :Double;
      Zad         :TStdZadSzukPomp;

      procedure Compute;

    public
      QMin, QMax  :Double;
      HMin, HMax  :Double;
      constructor Create( Z :TStdZadSzukPomp );
      destructor  Destroy;                           override;

  end;

  TStdZadDiagFun = class (TDiagFunDrawer)
  private
    FQMin: Double;
    FQw: Double;
    FHw: Double;
    FQMax: Double;
    FHMin: Double;
    FHMax: Double;
    FHg: Double;
    A0, A1, A2 :Double;

    procedure Compute;
    procedure SetHg(const Value: Double);
    procedure SetHMax(const Value: Double);
    procedure SetHMin(const Value: Double);
    procedure SetHw(const Value: Double);
    procedure SetQMax(const Value: Double);
    procedure SetQMin(const Value: Double);
    procedure SetQw(const Value: Double);

  protected
    procedure DrawChar(dt: TSpecDrawData; bw: Boolean);
    procedure DrawPunkt(dt: TSpecDrawData; bw: Boolean);
    procedure DrawZakres(dt: TSpecDrawData; bw: Boolean);

    procedure DrawFun( dt :TSpecDrawData; bw :Boolean );   override;

  public
    CharSel        :TStdPompCharSel;
    function  Value( X :Double ): Double;                  override;
    property Qw    :Double read FQw write SetQw;
    property Hw    :Double read FHw write SetHw;
    property Hg    :Double read FHg write SetHg;
    property HMin  :Double read FHMin write SetHMin;
    property HMax  :Double read FHMax write SetHMax;
    property QMin  :Double read FQMin write SetQMin;
    property QMax  :Double read FQMax write SetQMax;
  end;

implementation

uses
  ZadFrmU, StdZadFrmU;

{ TStdZadSzukPomp }

constructor TStdZadSzukPomp.Create( O :TComponent );
begin
  inherited Create( O );
    Qw := 36;
    Hw := 10;
    Hg :=  0;
    QMinTol := 0.9;
    QMaxTol := 1.1;
    HMinTol := 0.9;
    HMaxTol := 1.1;
    fDelta := 0.5;  //Waga odchylenia
    fEta   := 0.5;  //Waga Sprawnosci
    fNPSH  := 0.5;  //Waga NPSH
  WlaczSprawdzanie := FALSE;
  SprawdzajNPSH := FALSE;
  SprawdzajTEMP := FALSE;
  RegDZezw := True;
  RegNZezw := False;
  if FMainForm <> NIL then
    (FMainForm as TZadForm).Aktualizuj;
end;


function  TStdZadSzukPomp.WarunekWst( DB :TDBPompy ) :Boolean;
begin
//MS 2005-01-11
//  result := (inherited WarunekWst(DB) );

//  if result and (FCharSel <> NIL) then
//    result := FCharSel.RngQIntsect( DB.A.FieldByName('QMin').AsFloat ,
//                                    DB.A.FieldByName('QMax').AsFloat  )
//              and (RegDZezw or (DB.A.FieldByName('OBJ_ID').AsString <> 'REG_D'))
//              and (RegNZezw or (DB.A.FieldByName('OBJ_ID').AsString <> 'REG_N'));


  if not (inherited WarunekWst(DB) )
    then
      result := false
    else
  if (FCharSel = NIL)
    then
      begin
        // KR: 2005-08-09 Usuwanie bledow, Dobor aktywny nie dziala
        //result := false;
        //ZapiszKomunikat('Nie okreslone parametry wyszukiwania');
      end
    else
      begin
//        result := FCharSel.RngQIntsect( DB.A.FieldByName('QMin').AsFloat ,
//                                    DB.A.FieldByName('QMax').AsFloat  )
//              and (RegDZezw or (DB.A.FieldByName('OBJ_ID').AsString <> 'REG_D'))
//              and (RegNZezw or (DB.A.FieldByName('OBJ_ID').AsString <> 'REG_N'));
//
//        if not Result then
//          ZapiszKomunikat('');

        // KR: 2005-01-07
        result := FCharSel.RngQIntsect( DB.A.FieldByName('QMin').AsFloat ,
                                    DB.A.FieldByName('QMax').AsFloat  );
        if Result then
        begin
          Result := (RegDZezw or (DB.A.FieldByName('OBJ_ID').AsString <> 'REG_D'));
          if not Result then
          begin
            ZapiszKomunikat(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Niedopuszczalna pompa regulowana srednica'));
            EXIT
          end;
        end;

        if Result then
        begin
          Result := (RegNZezw or (DB.A.FieldByName('OBJ_ID').AsString <> 'REG_N'));
          if not Result then
          begin
            ZapiszKomunikat(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Niedopuszczalna pompa regulowana obrotami'));
          end;
        end;

        if not Result then
          ZapiszKomunikat('');
      end;
end;


function  TStdZadSzukPomp.PompaOK( Pmp :TPompa )     :Boolean;
begin
  result := CharSelOK( Pmp );
end;

procedure TStdZadSzukPomp.CreateMainForm;
var
  F       :TStdZadForm;
begin
  F := TStdZadForm.Create(self);
  F.Zad := self;
  FMainForm := F;
  F.Aktualizuj;
end;


function  TStdZadSzukPomp.GetCharSel :TStdPompCharSel;
begin
  result := FCharSel as TStdPompCharSel;
end;


procedure TStdZadSzukPomp.CreateCharSel;
begin
  FCharSel := TStdPompCharSel.Create(self);
  FCharSel.AddRef;
  CharSel.Compute;
end;


procedure TStdZadSzukPomp.SetQw( v :Double );
begin
  FQw := v;
  CharSel.Compute;
end;

procedure TStdZadSzukPomp.SetHw( v :Double );
begin
  FHw := v;
  CharSel.Compute;
end;


procedure TStdZadSzukPomp.SetHg( v :Double );
begin
  FHg := v;
  CharSel.Compute;
end;


procedure TStdZadSzukPomp.SetQMinTol( v :Double );
begin
  FQMinTol := v;
  CharSel.Compute;
end;

procedure TStdZadSzukPomp.SetQMaxTol( v :Double );
begin
  FQMaxTol := v;
  CharSel.Compute;
end;

procedure TStdZadSzukPomp.SetHMinTol( v :Double );
begin
  FHMinTol := v;
  CharSel.Compute;
end;

procedure TStdZadSzukPomp.SetHMaxTol( v :Double );
begin
  FHMaxTol := v;
  CharSel.Compute;
end;

procedure TStdZadSzukPomp.SetSprawdzajTEMP(const Value: Boolean);
begin
  CheckTemp := Value;
end;

function TStdZadSzukPomp.GetSprawdzajTEMP: Boolean;
begin
  result := CheckTemp;
end;



procedure TStdZadSzukPomp.CharSelDestroing;
begin
  inherited;
end;

procedure TStdZadSzukPomp.SetRegDZezw(const Value: Boolean);
begin
  FRegDZezw := Value;
end;

procedure TStdZadSzukPomp.SetRegNZezw(const Value: Boolean);
begin
  FRegNZezw := Value;
end;

{ TStdPompCharSel }

constructor TStdPompCharSel.Create( Z :TStdZadSzukPomp );
begin
  inherited Create;
  Zad := Z;
end;

function TStdPompCharSel.dH( Q :Double ) :Double;
begin
  result := A0 + Q*(A1 + (Q*A2));
end;

function TStdPompCharSel.GetQw    :Double;
begin
  result := Zad.Qw;
end;

function TStdPompCharSel.GetHw    :Double;
begin
  result := Zad.Hw;
end;

{-- Wstawka MS ----------------------------------------------------------------}
function TStdPompCharSel.GetNPSHu    :Double;
begin
  result := Zad.Hw;
end;



function TStdPompCharSel.RngQIntsect( AQMin, AQMax :Double ) :Boolean;
begin
//  result := (AQMax > QMin) and (AQMin < QMax);
  if AQMax > QMin          //MS 2005-01-13
    then
      if AQMin < QMax
        then result := true
        else
          begin
            result := false;
            Zad.ZapiszKomunikat(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Q maksymalna wymagana ukladu < Q minimalna dopuszczalna pompy') +
                     ' ' +FormatFloat('0.00',QMax)+' < '+FormatFloat('0.00',AQMin)) ;
          end
    else
      begin
        result := false;
        Zad.ZapiszKomunikat(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Q minimalna wymagana ukladu > Q maksymalna dopuszczalna pompy') +
                   ' '  +FormatFloat('0.00',QMin)+' > '+FormatFloat('0.00',AQMax)) ;
      end;
end;

function TStdPompCharSel.KluczOK(KluczeWPlikuT:String;
                                        Klucze:TStrings) :Boolean;
VAR
  i   :integer;
begin
  result := TRUE;
  i := 0;
  if klucze<>nil
    then
      begin
        while (i < Klucze.Count) and result do
          begin
            result := Pos('/'+Klucze[i]+'/',KluczeWPlikuT)>0;
            inc(i);
          end;
        if not result
          then Zad.ZapiszKomunikat(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Pompa nie ma przypisanego klucza')+' /'+Klucze[i-1]+'/');
      end
    else
      begin
        result := false;
        Zad.ZapiszKomunikat(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Nie okreslony klucz selekcji'));
      end;
end;

                                        //wstawka NPSHr
function TStdPompCharSel.Accept( Qr, Hr :Double; Pump :IPump ): Boolean;
type
  TBoolStr = record
    Warunek :Boolean;
    Komunikat :string;
  end;

  function BS( AWarunek :Boolean; const AKomun :string ) : TBoolStr;
    //: Zwraca rekord TBoolStr z podstawionymi wartosciami
  begin
    with Result do
    begin
      Warunek := AWarunek;
      Komunikat := AKomun;
    end;
  end;

  function SprawdzanieWewnetrzne( const A :array of TBoolStr ) :Boolean;
  //: Sprawdza po kolei kazdy z warunkow na liscie - jesli false podstawia
  //   komunikat i powraca zwracajac FALSE
  var
    i :Integer;
  begin
    Result := True;
    for i := Low(A) to High(A) do
    begin
      if not A[i].Warunek then
      begin
        Zad.ZapiszKomunikat(A[i].Komunikat);
        Result := False;
        EXIT;
      end;
    end;
  end;
begin
//  result := (Qr >= QMin) and (Qr <= QMax)
//        and (Hr >= HMin) and (Hr <= HMax)
//        and (Qr >= Pump.GetQMin) and (Qr <= Pump.GetQMax);
  Result := SprawdzanieWewnetrzne(
              [BS(Qr >= QMin, Format(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Przekroczenie zakresu')+' Qr = %.2f < Qmin = %.2f', [Qr, QMin])),
               BS(Qr <= QMax, Format(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Przekroczenie zakresu')+' Qr = %.2f > Qmax = %.2f', [Qr, QMax])),
               BS(Hr >= HMin, Format(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Przekroczenie zakresu')+' Hr = %.2f < Hmin = %.2f', [Hr, Hmin])),
               BS(Hr <= HMax, Format(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Przekroczenie zakresu')+' Hr = %.2f > Hmax = %.2f', [Hr, HMax])),
               BS(Qr >= Pump.GetQMin, Format(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Ponizej dopuszczalnej wydajnosci')+' Qr = %.2f < Qmin '+TTlumacz.DajObiekt.ZnajdzTlumaczenie('pompy')+' = %.2f', [Qr, Pump.GetQMin])),
               BS(Qr <= Pump.GetQMax, Format(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Powyzej dopuszczalnej wydajnosci')+' Qr = %.2f > Qmax '+TTlumacz.DajObiekt.ZnajdzTlumaczenie('pompy')+' = %.2f', [Qr, Pump.GetQMax]))
              ]);
end;

procedure TStdPompCharSel.Compute;
begin
  if self = NIL then
    EXIT;

  if not W3DajWspE( -Zad.Qw, 0, Zad.Qw, Zad.Hw, Zad.Hg, GetHw, A0, A1, A2 ) then
  begin
    A0 := Zad.Hg;
    A1 := 0;
    A2 := 0;
  end;

  QMin := Zad.QMinTol * Zad.Qw;
  QMax := Zad.QMaxTol * Zad.Qw;
  HMin := Zad.HMinTol * Zad.Hw;
  HMax := Zad.HMaxTol * Zad.Hw;

end;

function TStdPompCharSel.GetDiagFun(Owner: TDiagFunction): TDiagFunDrawer;
var
  df     :TStdZadDiagFun;
begin
  df :=  TStdZadDiagFun.Create(Owner);
  Owner.Drawer := df;
  df.Qw := Zad.Qw;
  df.Hw := Zad.Hw;
  df.Hg := Zad.Hg;
  df.HMin := HMin;
  df.HMax := HMax;
  df.QMin := QMin;
  df.QMax := QMax;
  result := df;
end;




destructor TStdPompCharSel.Destroy;
begin
  if Zad <> NIL then
    Zad.CharSelDestroing;
end;

{ TStdZadDiagFun }

procedure TStdZadDiagFun.Compute;
begin
  if not W3DajWspE( -Qw, 0, Qw, Hw, Hg, Hw, A0, A1, A2 ) then
  begin
    A0 := Hg;
    A1 := 0;
    A2 := 0;
  end;

end;

procedure TStdZadDiagFun.DrawChar(dt: TSpecDrawData; bw: Boolean);
var
  xr, yr  :Double;
  min, max :Double;
  InBox, OldInBox :Boolean;
begin
  if IsOn then
  begin
    Compute;
    min  := MinXR;
    max  := MaxXR;

    xr := min;
    yr := Value(xr);
    dt.MoveTo( xr, yr );
    OldInBox := CheckInBox(xr, yr);
    while xr <= max do
    begin
      xr := xr + dt.DX;
      yr := Value(xr);
      InBox := CheckInBox(xr, yr);
      if InBox then
        if OldInBox then
          dt.LineTo(xr, yr)
        else
          dt.MoveTo(xr, yr);
      OldInBox := InBox;
    end;
  end;
end;

procedure TStdZadDiagFun.DrawFun(dt: TSpecDrawData; bw: Boolean);
begin
  DrawChar( dt, bw );
  DrawZakres( dt, bw );
  DrawPunkt( dt, bw );
end;

procedure TStdZadDiagFun.DrawPunkt(dt: TSpecDrawData; bw: Boolean);
var
  X, Y    :TCanvCoord;
  svStyle :TBrushStyle;

begin
  dt.ConvPointRPar( Qw, Hw, X, Y );
  dt.Canvas.Brush.Color := dt.Canvas.Pen.Color;
  svStyle := dt.Canvas.Brush.Style;
  dt.Canvas.Brush.Style := bsSolid;
  dt.Canvas.Ellipse( X-3, Y-3, X+3, Y+3 );
  dt.Canvas.Brush.Style := svStyle;
end;


procedure TStdZadDiagFun.DrawZakres(dt: TSpecDrawData; bw: Boolean);
var
  svStyle :TBrushStyle;
begin
  svStyle := dt.Canvas.Brush.Style;
  dt.Canvas.Brush.Style := bsClear;
  dt.Rectangle( QMin, HMin, QMax, HMax );
  dt.Canvas.Brush.Style := svStyle;
end;


procedure TStdZadDiagFun.SetHg(const Value: Double);
begin
  FHg := Value;
end;

procedure TStdZadDiagFun.SetHMax(const Value: Double);
begin
  FHMax := Value;
end;

procedure TStdZadDiagFun.SetHMin(const Value: Double);
begin
  FHMin := Value;
end;

procedure TStdZadDiagFun.SetHw(const Value: Double);
begin
  FHw := Value;
end;

procedure TStdZadDiagFun.SetQMax(const Value: Double);
begin
  FQMax := Value;
end;

procedure TStdZadDiagFun.SetQMin(const Value: Double);
begin
  FQMin := Value;
end;

procedure TStdZadDiagFun.SetQw(const Value: Double);
begin
  FQw := Value;
end;

function TStdZadDiagFun.Value(X: Double): Double;
begin
  result := A0 + (x * (A1 + (x*A2)));
end;



initialization
  RegisterClass( TStdZadSzukPomp );

end.
