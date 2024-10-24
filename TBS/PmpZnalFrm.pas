unit PmpZnalFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ZadFrmU, Grids, ExtCtrls, Math, StdCtrls, ComCtrls, Gauges, Buttons,
  DBTables,
  WkpGlob, ZadU, KatFormTools, ZadPompSzuk, OPompa, FPompy, PompySQL,
  PmpListViewFrm, PmpListU, PropertyAccesserU, FormSaverU,
  jezyki;

type
  TPompyZnalezFrm = class(TZadForm)
    Grid: TStringGrid;
    AktualTimer: TTimer;
    ProgressPanel: TPanel;
    ProgressLab: TLabel;
    ProdLab: TLabel;
    StatusBar: TStatusBar;
    TotalProgressG: TGauge;
    ProdProgressG: TGauge;
    Label1: TLabel;
    LiczZnalEdit: TEdit;
    PrzerwijBtn: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GridDrawCell(Sender: TObject; Col, Row: Longint; Rect: TRect;
      State: TGridDrawState);
    procedure AktualTimerTimer(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure FormDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SortujButtonClick(Sender: TObject);
    procedure PauzaBtnClick(Sender: TObject);
    procedure DalejBtnClick(Sender: TObject);
    procedure PrzerwijBtnClick(Sender: TObject);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure GridStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    NrProd     :Integer;
    FMoznaDrag :Boolean;
    FGridStartDragPos :TPoint;
    FBeforeDrag :Boolean;
    FDragged    :Boolean;
    svColDobrWidth :Integer;
    function GetZadanie :TZadSzukPomp;
    function GetPump( i :Integer ) :TPompa;
    procedure SetMoznaDrag(const Value: Boolean);

  protected
    FColDesc  :array of Boolean;
    FNrKolSort :Integer;

    procedure SortCol(ACol :Integer);
    procedure GridDrawDataCell( ACol, APos :Integer; ACanvas :TCanvas;
                   R :TRect; State: TGridDrawState );        virtual;
    procedure GridGetString( ACol, APos :Integer; var StrValue :string;
                   var DrawStr :Boolean; var Just :TAlignment ); virtual;

    function  GetSortFunct( ACol :Integer;
                            ADesc :Boolean ) :TFuncPumpComp;   virtual;
    function  GetColName( ACol :Integer ) :string;             virtual;
    function  GetColPosByName( const AName :string ) :Integer; virtual;
    function  GetSortFByName( const AName :string;
                              ADesc :Boolean ) :TFuncPumpComp;  virtual;
    function  GetDefColDesc( const AName :string ):Boolean;   virtual;

    procedure ZacznijDrag;
  public
    { Public declarations }
    constructor Create( O :TComponent );    override;
    constructor CreateNoMDI( O :TComponent );
    constructor CreateInstalled( O :TComponent;
                                 AParent :TWinControl );



    procedure Aktualizuj;                   override;
    procedure PokazFormPompy;

    property Zadanie :TZadSzukPomp read GetZadanie;
    property Pumps[ i :Integer ] :TPompa  read GetPump;
    property MoznaDrag :Boolean read FMoznaDrag write SetMoznaDrag;
    procedure SetGridCaptions;              virtual;
  end;


implementation

const
 lp  = 0 ;
 PROD= 1;
 Nazwa = 2;
 Qr = 3;
 Hr = 4;
 Pr = 5;
 Er = 6;
 WDobr = 7;
 e =  8;
 QN = 9;
 HN = 10;
 PN = 11;
 N  = 12;
 Masa = 13;

var
 Przygotowania_do_wyszukiwania :string = 'Przygotowania do wyszukiwania';
 Wyszukiwanie_pomp :string = 'Wyszukiwanie pomp';
 Pauza :string = 'Pauza';
 Wyszukiwanie_zakonczone :string = 'Wyszukiwanie zakonczone';
 Producent_ :string= 'Producent';
 Nazwa_ :string= 'Nazwa';
 Hr_ :string= 'Hr [m]';
 Pr_ :string= 'Pr [kW]';
 Er_ :string= 'Er [%]'; // Powinny byc procenty
 e_ :string= 'e [kWh/1000m3]';
 Qn_ :string= 'Qn ';
 Hn_ :string= 'Hn [m]';
 Pn_ :string= 'Pn [kW]';
 n_ :string= 'Obroty';
 Masa_ :string= 'Masa [kg]';
 Wdobr_ :string= 'Dobroc';
 Qr_ :string= 'Qr ';
 {$R *.DFM}

procedure RysujTrojkat(C : TCanvas; Rect:TRect; Desc :Boolean);
var
  p1, p2, p3 : TPoint;
begin
 C.Pen.Width := 1;
 if Desc then  // Porzadek malejacy
 begin
   // \/ strzalka na dol
   p1 := Point(Rect.Right-4,Rect.top+4);  //  p2\----/ p1
   p2 := Point(p1.x-10,p1.y);             //     \  /
   p3 := Point(p1.x-5,p1.y+10);           //    p3\/
   C.Brush.Color := clRed;
   C.Polygon( [p1, p2, p3] );
   C.Pen.Color := clBtnShadow;
   C.Polyline( [p1, p2, p3] );
   C.Pen.Color := clBtnHighlight;
   C.Polyline( [p1, p3] );
 end
 else
 begin
   // /\ strzalka do gory
   p1 := Point(Rect.Right-4,Rect.top+14); //      p3/\
   p2 := Point(p1.x-10,p1.y);             //       /  \
   p3 := Point(p1.x-5,p1.y-10);           //    p2/____\ p1
   C.Brush.Color := clRed;
   C.Polygon( [p1, p2, p3] );
   C.Pen.Color := clBtnShadow;
   C.Polyline( [p2, p3] );
   C.Pen.Color := clBtnHighlight;
   C.Polyline( [p2, p1, p3] );
 end;
end;


{ TPompyZnalezFrm }

constructor TPompyZnalezFrm.Create( O :TComponent );
begin
  inherited Create( O );
  MoznaDrag := true;
  FNrKolSort := -1;
end;

procedure TPompyZnalezFrm.Aktualizuj;
var
  DobrCol :Integer;
begin
  SetGridCaptions;
  LiczZnalEdit.Text := IntToStr(Zadanie.PumpCount);

  Grid.RowCount := Max(Zadanie.PumpCount +1, 2);
  Grid.Invalidate;

  DobrCol := GetColPosByName(WDOBR_);
  if not Zadanie.JestWDobr then
  begin
    if Grid.ColWidths[DobrCol] > 1 then
      svColDobrWidth := Grid.ColWidths[DobrCol];
    Grid.ColWidths[DobrCol] := 0;
  end
  else if Grid.ColWidths[DobrCol] = 0 then
    Grid.ColWidths[DobrCol] := svColDobrWidth;


  case Zadanie.State of
    zspsPrzygotowania:
      begin
      StatusBar.Panels[0].Text := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Przygotowania_do_wyszukiwania);
      //SortujButton.Enabled:=False;
      Grid.RowCount := 2;

      TotalProgressG.MinValue := 0;
      TotalProgressG.MaxValue := Zadanie.TotalPomp;

      NrProd := 0;

      if Zadanie.JestWDobr then
      begin
        FNrKolSort := DobrCol;
        FColDesc[DobrCol] := true;
      end;

      if Zadanie.ProdCount > 0 then
      begin
        ProdProgressG.MinValue := 0;
        ProdProgressG.MaxValue := Zadanie.Prods[0].IloscPomp;

        ProdLab.Caption := Zadanie.Prods[0].Ident;
      end;
      end;
    zspsSzukanie:
      begin
      StatusBar.Panels[0].Text := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Wyszukiwanie_pomp);
      //SortujButton.Enabled:=False;
      AktualTimer.Enabled := true;
      //DalejBtn.Enabled := false;
      //PauzaBtn.Enabled := true;
      PrzerwijBtn.Enabled := true;
      end;
    zspsPauza:
      begin
      StatusBar.Panels[0].Text := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Pauza);
      //SortujButton.Enabled:=True;
      //DalejBtn.Enabled := true;
      //PauzaBtn.Enabled := false;
      PrzerwijBtn.Enabled := true;
      end;
    zspsWyniki:
      begin
      StatusBar.Panels[0].Text := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Wyszukiwanie_zakonczone);
      //SortujButton.Enabled:=True;
      //DalejBtn.Enabled := false;
      //PauzaBtn.Enabled := false;
      PrzerwijBtn.Enabled := false;
      end;
  end;
end;


procedure TPompyZnalezFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

function TPompyZnalezFrm.GetZadanie :TZadSzukPomp;
begin
  result := Zad as TZadSzukPomp;
end;

function TPompyZnalezFrm.GetPump( i :Integer ) :TPompa;
begin
  result := Zadanie.Pumps[i];
end;


procedure TPompyZnalezFrm.GridDrawCell(Sender: TObject; Col, Row: Longint;
  Rect: TRect; State: TGridDrawState);
var
//  p       :TPompa;
  s       :string;
begin
  inherited;
  if (Row > 0) and (Zadanie.PumpCount >= Row) then
  begin
    if Col = 0 then
      Grid.Canvas.TextRect( Rect, Rect.Left +2, Rect.Top+3, IntToStr(Row) )
    else
      GridDrawDataCell( Col, Row-1, Grid.Canvas, Rect, State );
  end
  else if (Row = 0) and (Col = FNrKolSort) then
  begin
    RysujTrojkat( Grid.Canvas, Rect, FColDesc[Col] );
  end;
end;

procedure TPompyZnalezFrm.AktualTimerTimer(Sender: TObject);
begin

  inherited;
  //if Zadanie.State = zspsSzukanie then
  if ProgressPanel.Visible then
  begin
    //TotalProgress.Position := Zadanie.PompPrzeszuk;
    TotalProgressG.Progress := Zadanie.PompPrzeszuk;

    if NrProd <> Zadanie.ProdSzukInd then
    begin
      NrProd := Zadanie.ProdSzukInd;
      //ProdProgr.Max := Zadanie.Prods[NrProd].IloscPomp;

      ProdProgressG.MaxValue := Zadanie.Prods[NrProd].IloscPomp;


      ProdLab.Caption := Zadanie.Prods[NrProd].Ident;
    end;
    //ProdProgr.Position := Zadanie.CurrProdPompPrzeszuk;
    ProdProgressG.Progress := Zadanie.CurrProdPompPrzeszuk;
  end;

  if not (Zadanie.State in [zspsSzukanie]) then
    AktualTimer.Enabled := false;
  Aktualizuj;
end;

procedure TPompyZnalezFrm.GridDblClick(Sender: TObject);
var
  PT      :TPoint;
begin
  inherited;
  PT := Mouse.CursorPos;
  PT := Grid.ScreenToClient(PT);
  Grid.MouseToCell(PT.X, PT.Y, PT.X, PT.Y);
  if PT.Y > 0 then
    PokazFormPompy
  else
    SortCol(PT.X);
end;

procedure TPompyZnalezFrm.FormDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  inherited;

  Accept := true;
end;

procedure TPompyZnalezFrm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;

  if Zadanie.State = zspsSzukanie then
  begin
    CanClose := false;
  end
end;
///////////
function comp( Item1, Item2: Pointer): Integer;
var
  r1,r2 : TPompa;
begin
  r1:=TPompa(Item1);
  r2:=TPompa(Item2);

  if r1.wDobroci<r2.wDobroci then
     result:=1
  else
    if r1.wDobroci>r2.wDobroci then
      result:=-1
    else
      result:=0;
end;
//////////

procedure TPompyZnalezFrm.SortujButtonClick(Sender: TObject);
var
  i       :Integer;
begin
  inherited;
  for i := 1 to Length(FColDesc)-1 do
  begin
    if GetColName(i) = 'WDOBR' then
    begin
      SortCol(i);
      EXIT;
    end;
  end;
end;

constructor TPompyZnalezFrm.CreateNoMDI(O: TComponent);
begin
  FormStyle := fsNormal;
  Visible   := false;
  Create(O);
end;

procedure TPompyZnalezFrm.PauzaBtnClick(Sender: TObject);
begin
  inherited;
  Zadanie.Pauza;
end;

procedure TPompyZnalezFrm.DalejBtnClick(Sender: TObject);
begin
  inherited;
  Zadanie.KontynSzukanie;
  Aktualizuj;
end;

procedure TPompyZnalezFrm.PrzerwijBtnClick(Sender: TObject);
begin
  inherited;
  Zadanie.PrzerwijSzukanie;
end;

procedure TPompyZnalezFrm.GridKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #13 then
  begin
    PokazFormPompy;
    Key := #0;
  end;
end;

procedure TPompyZnalezFrm.PokazFormPompy;
var
  F       :TForm;
  i       :Integer;
begin
  if {(Zadanie.State = zspsWyniki)
     and} (Grid.Row >0) and (Grid.Row <= Zadanie.PumpCount) then
  begin
    i := Grid.Row-1;
    //F := TFormPompy.StworzDlaPompy( self, Zadanie.Pumps[i] );
    //F := Zadanie.Pumps[i].CreateForm( self );
    F := FormDlaPompy( Zadanie.Pumps[i], Self, True );
    F.Show;
  end;
end;

procedure TPompyZnalezFrm.GridStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
  Pmp     :TPompa;
  pos     :Integer;
begin
  inherited;
  pos := Grid.Row-1;
  if (0 <= pos) and (pos < Zadanie.PumpCount) then
  begin
    Pmp := Zadanie.Pumps[pos];
    DragObject := TPompaDragObject.Create( Pmp, Grid );
    //DragObject.ShowDragImage;
  end;
end;

procedure TPompyZnalezFrm.GridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pos     :Integer;
begin
  inherited;
  if not WerPro then
    EXIT;
  pos := Grid.Row-1;
  if (Button = mbLeft) and (not (ssDouble in Shift)) and MoznaDrag
      and (0 <= pos) and (pos < Zadanie.PumpCount) then
  begin
    FGridStartDragPos := Point(X,Y);
    FBeforeDrag := true;
  end;
end;

procedure TPompyZnalezFrm.SetGridCaptions;
begin
  with Grid do // To jest wyswietlane
  begin
    Cells[ prod, 0 ] := Producent_;
    Cells[ Nazwa, 0 ] := Nazwa_;
    Cells[ Hr, 0 ] := Hr_;
    Cells[ Pr, 0 ] := Pr_;
    Cells[ Er, 0 ] := Er_;
    Cells[ e, 0 ] := e_;
    Cells[ Qn, 0 ] := Qn_ + CapQ;
    Cells[ Hn, 0 ] := Hn_;
    Cells[ Pn, 0 ] := Pn_;
    Cells[ n, 0 ] :=  n_;
    //Cells[ 7, 0 ] := 'Cena';
    Cells[ Masa, 0 ] := Masa_;
    Cells[ Wdobr, 0 ] := WDobr_;
    Cells[ Qr, 0 ] := Qr_+CapQ;
  end;
end;

procedure TPompyZnalezFrm.FormCreate(Sender: TObject);
var
  i       :Integer;
const
  GruKolorTla   : TColor = $874C07;
  GruKolorPusty : TColor = $B49924;
begin
  //WS tlumaczenia
  Nazwa_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Nazwa_);
  Hr_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Hr_);
  Pr_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Pr_);
  Er_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Er_);
  e_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(e_);
  Qn_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Qn_);
  Hn_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Hn_);
  Pn_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Pn_);
  n_ :=  TTlumacz.DajObiekt.ZnajdzTlumaczenie(n_);
  Masa_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Masa_);
  Wdobr_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(WDobr_);
  Qr_ := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Qr_);
  //WS
  //MS 060110 Wstawki dla Grundfosa
  ProgressPanel.Color := GruKolorPusty;
  inherited;
  //SetGridCaptions; przeniesione do aktualizuj
  SetLength(FColDesc, Grid.ColCount);
  for i := 0 to Length(FColDesc)-1 do
    FColDesc[i] := GetDefColDesc( GetColName(i));
  if WerProdPomp then
  begin
    i := GetColPosByName( Producent_ );
    Grid.Cells[ i, 0 ] := '';
    Grid.ColWidths[i] := 0;
  end;
  i := GetColPosByName( 'WDOBR' );
  svColDobrWidth := Grid.ColWidths[i]; //Dobroc
end;

procedure TPompyZnalezFrm.GridDrawDataCell(ACol, APos: Integer;
  ACanvas: TCanvas; R: TRect; State: TGridDrawState);
var
  DrawStr :Boolean;
  StrVal  :string;
  sl      :Integer;
  Just    :TAlignment;
  x, y    :Integer;
begin
  DrawStr := false;
  Just := taLeftJustify;
  GridGetString( ACol, APos, StrVal, DrawStr, Just );
  if DrawStr then
  begin
    y := R.Top+3;
    if Just = taLeftJustify then
    begin
      x := R.Left+2;
    end
    else
    begin
      sl := ACanvas.TextWidth( StrVal );
      if Just = taCenter then
        x := (R.Right - sl) div 2
      else
        x := (R.Right - sl) - 2;
    end;
    ACanvas.TextRect( R, x, y, StrVal );
  end;
end;

procedure TPompyZnalezFrm.GridGetString(ACol, APos: Integer;
  var StrValue: string; var DrawStr: Boolean; var Just: TAlignment);
var
  P       :TPompa;
begin
  try
    P := Pumps[APos];
  except
    DrawStr := false;
    EXIT;
  end;

  DrawStr := true;
  if ACol in [3,4,5,6,7,8,9,10,11,12,13] then
    Just := taRightJustify;

  //Ty sa podstawiane wartosci do grida zanlezionych pomp
  case ACol of
    prod: StrValue := P.Producent.Nazwa;
    Nazwa: StrValue := P.Nazwa;
    Qn: StrValue := FormatFloat( '0.00', m3hToU(P.Qn));
    Hn: StrValue := FormatFloat( '0.00', P.Hn );
    Pn: StrValue := FormatFloat( '0.00', P.Pn );
    n: StrValue := FormatFloat( '0', P.N );
    // 7 bylo cena
    Masa: StrValue := FormatFloat( '0.0', P.Masa );
    WDobr: StrValue := FormatFloat( '0.000', P.WDobroci );
    //
    Qr: StrValue := FormatFloat( '0.00', m3hToU(P.Qr));
    Hr: StrValue := FormatFloat( '0.00', P.Hr);
    Pr: StrValue := FormatFloat( '0.000', P.Pr);
    Er: StrValue := FormatFloat( '0.000', P.ETAr * 100);
    e : if P.Qr > 0 then
//         StrValue := FormatFloat( '0.00', P.Pr/P.Qr*1000)
         StrValue := FormatFloat( '0.00', P.Hr*1000*9.81/P.EtaAgr(P.Qr)*1000/1000/3600)
       else
         StrValue := '-';
    else
      DrawStr := false;
  end;
end;

constructor TPompyZnalezFrm.CreateInstalled(O: TComponent;
  AParent: TWinControl);
begin
  CreateNoMDI(O);
  Caption := '';
  BorderStyle := bsNone;
  Parent := AParent;
  Align := alClient;
  Visible := true;
end;

procedure TPompyZnalezFrm.SetMoznaDrag(const Value: Boolean);
begin
  FMoznaDrag := Value;
end;

procedure TPompyZnalezFrm.ZacznijDrag;
begin
  Grid.BeginDrag( true );
  FDragged := true;
  FBeforeDrag := false;
end;

procedure TPompyZnalezFrm.GridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FBeforeDrag then
    if ssLeft in Shift then
    begin
      if (abs(X - FGridStartDragPos.X) >= Mouse.DragThreshold)
          or (abs(Y - FGridStartDragPos.Y) >= Mouse.DragThreshold) then
      begin
        ZacznijDrag;
      end;
    end
    else
    begin
      FBeforeDrag := false;
    end;
end;

procedure TPompyZnalezFrm.GridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FBeforeDrag then
    FBeforeDrag := false;
end;


function CompareProd( P1, P2 :TPompa ) :Integer;
var
  i1, i2 :string;
begin
  i1 := P1.Producent.Ident;
  i2 := P2.Producent.Ident;
  if i1 > i2 then
    Result := 1
  else if i1 < i2 then
    Result := -1
  else
    Result := 0;
end;

function CompareProdDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareProd( P2, P1 );
end;


function CompareNazw( P1, P2 :TPompa ) :Integer;
begin
  if P1.Nazwa > P2.Nazwa then
    Result := 1
  else if P1.Nazwa < P2.Nazwa then
    Result := -1
  else
    Result := 0;
end;

function CompareNazwDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareNazw( P2, P1 );
end;

function CompareDobr( P1, P2 :TPompa ) :Integer;
begin
  if P1.WDobroci > P2.WDobroci then
    Result := 1
  else if P1.WDobroci < P2.WDobroci then
    Result := -1
  else
    Result := 0;
end;

function CompareDobrDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareDobr( P2, P1 );
end;

function CompareQn( P1, P2 :TPompa ) :Integer;
begin
  if P1.Qn > P2.Qn then
    Result := 1
  else if P1.Qn < P2.Qn then
    Result := -1
  else
    Result := 0;
end;

function CompareQr( P1, P2 :TPompa ) :Integer;
begin
  if P1.Qr > P2.Qr then
    Result := 1
  else if P1.Qr < P2.Qr then
    Result := -1
  else
    Result := 0;
end;

function CompareHr( P1, P2 :TPompa ) :Integer;
begin
  if P1.Hr > P2.Hr then
    Result := 1
  else if P1.Hr < P2.Hr then
    Result := -1
  else
    Result := 0;
end;

function ComparePr( P1, P2 :TPompa ) :Integer;
begin
  if P1.Pr > P2.Pr then
    Result := 1
  else if P1.Pr < P2.Pr then
    Result := -1
  else
    Result := 0;
end;

function CompareEr( P1, P2 :TPompa ) :Integer;
begin
  if P1.ETAr > P2.ETAr then
    Result := 1
  else if P1.ETAr < P2.ETAr then
    Result := -1
  else
    Result := 0;
end;

function Comparee( P1, P2 :TPompa ) :Integer;
var e1, e2 : double;
begin
 Result := 0;
 if (P1.Qr <= 0) then
   if (P2.Qr <= 0) then result := 0 else result := -1
  else if (P2.Qr <= 0) then result := 1  
 else
 begin
  e1 := P1.Pr/P1.Qr*1000;
  e2 := P2.Pr/P2.Qr*1000;
  if e1 > e2 then
    Result := 1
  else if e1 < e2 then
    Result := -1
  else
    Result := 0;
 end;
end;

function CompareeDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := Comparee( P2, P1 );
end;

function CompareQrDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareQr( P2, P1 );
end;

function CompareHrDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareHr( P2, P1 );
end;

function ComparePrDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := ComparePr( P2, P1 );
end;

function CompareErDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareEr( P2, P1 );
end;

function CompareQnDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareQn( P2, P1 );
end;

function CompareHn( P1, P2 :TPompa ) :Integer;
begin
  if P1.Hn > P2.Hn then
    Result := 1
  else if P1.Hn < P2.Hn then
    Result := -1
  else
    Result := 0;
end;

function CompareHnDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareHn( P2, P1 );
end;

function ComparePn( P1, P2 :TPompa ) :Integer;
begin
  if P1.Pn > P2.Pn then
    Result := 1
  else if P1.Pn < P2.Pn then
    Result := -1
  else
    Result := 0;
end;

function ComparePnDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := ComparePn( P2, P1 );
end;

function CompareN( P1, P2 :TPompa ) :Integer;
begin
  if P1.N > P2.N then
    Result := 1
  else if P1.N < P2.N then
    Result := -1
  else
    Result := 0;
end;

function CompareNDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareN( P2, P1 );
end;


function CompareMasa( P1, P2 :TPompa ) :Integer;
begin
  if P1.Masa > P2.Masa then
    Result := 1
  else if P1.Masa < P2.Masa then
    Result := -1
  else
    Result := 0;
end;

function CompareMasaDesc( P1, P2 :TPompa ) :Integer;
begin
  Result := CompareMasa( P2, P1 );
end;



function TPompyZnalezFrm.GetSortFunct( ACol: Integer;
                              ADesc :Boolean): TFuncPumpComp;
begin
  Result := GetSortFByName( GetColName(ACol), ADesc );
end;

function TPompyZnalezFrm.GetSortFByName( const AName: string;
                              ADesc :Boolean): TFuncPumpComp;
begin
  Result := NIL;
  if ADesc then
  begin
    if (AName = 'PROD') and (not WerProdPomp) then
      Result := CompareProdDesc
    else if AName = NAZWA_ then
      Result := CompareNazwDesc
    else if AName = QN_ then
      Result := CompareQnDesc
    else if AName = HN_ then
      Result := CompareHnDesc
    else if AName = PN_ then
      Result := ComparePnDesc
    else if AName = N_ then
      Result := CompareNDesc
    else if AName = MASA_ then
      Result := CompareMasaDesc
    else if AName = WDOBR_ then
      Result := CompareDobrDesc
    else if AName = Qr_ then
      Result := CompareQrDesc
    else if AName = Hr_ then
      Result := CompareHrDesc
    else if AName = Pr_ then
      Result := ComparePrDesc
    else if AName = Er_ then
      Result := CompareErDesc
    else if AName = e_ then
      Result := CompareeDesc
  end
  else
  begin
    if (AName = 'PROD') and (not WerProdPomp) then
      Result := CompareProd
    else if AName = NAZWA_ then
      Result := CompareNazw
    else if AName = QN_ then
      Result := CompareQn
    else if AName = HN_ then
      Result := CompareHn
    else if AName = PN_ then
      Result := ComparePn
    else if AName = N_ then
      Result := CompareN
    else if AName = MASA_ then
      Result := CompareMasa
    else if AName = WDOBR_ then
      Result := CompareDobr
    else if AName = Qr_ then
      Result := CompareQr
    else if AName = Hr_ then
      Result := CompareHr
    else if AName = Pr_ then
      Result := ComparePr
    else if AName = Er_ then
      Result := CompareEr
    else if AName = e_ then
      Result := Comparee;
  end;
end;

function TPompyZnalezFrm.GetColName(ACol: Integer): string;
begin
  Result := '';
  case ACol of  //?? po co te nazwy? Do sortowania?
    lp : Result := 'LP';
    prod : Result := Producent_;
    Nazwa : Result :=  NAZWA_;
    Qn : Result := QN_;
    Hn : Result := HN_;
    Pn : Result := PN_;
    n : Result := N_;
    Masa : Result := MASA_;
    Wdobr : Result := WDOBR_;
    Qr : Result := Qr_;
    Hr : Result := Hr_;
    Pr : Result := Pr_;
    Er : Result := Er_;
    e  : Result := e_ ;
  end;
  //result := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Result);
end;

function TPompyZnalezFrm.GetColPosByName(const AName: string): Integer;
var
  i      :Integer;
begin
  Result := -1;
  i := 0;
  while (Result < 0) and (i < Grid.ColCount) do
  begin
    if GetColName(i) = AName then
      Result := i;
    inc(i);
  end;
end;

function TPompyZnalezFrm.GetDefColDesc(const AName: string): Boolean;
begin
  Result := False;
  if AName = WDOBR_ then
    Result := True;       // Funkcja dobroci malejaco
end;

procedure TPompyZnalezFrm.SortCol(ACol: Integer);
var
  fun     :TFuncPumpComp;

begin
  if (0 > ACol) or (ACol >= Grid.ColCount) then
    EXIT;
  if ACol = FNrKolSort then
    FColDesc[ACol] := not FColDesc[ACol];
  fun := GetSortFunct( ACol, FColDesc[ACol] );
  if Assigned(fun) then
  begin
    Zadanie.SortPumpsBy( fun );
    FNrKolSort := ACol;
  end;
  Grid.Invalidate;
end;

procedure TPompyZnalezFrm.FormShow(Sender: TObject);
begin
 TTlumacz.DajObiekt.Tlumacz(self);
end;

end.
