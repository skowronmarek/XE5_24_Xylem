unit ArmElFrm;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB, DBTables, DBCtrls, Buttons, TabNotBk, ExtCtrls,
  Printers,
  Clipbrd,
  KrMath, JezykTxt,
  DGraph,
  PompMath,
  TBS_Tool,
  KR_DB, Prod, DBArm, ElAbFrm,
  {OPompa, B4Char,} RysFrm,
  PompDXF, ElemUnit, KR_Class, ComCtrls, Diagrams, ObjView, Ciecze;


type
  TArmElemForm = class(TElemAbstPrzeplFrm)
    CloseBtn: TBitBtn;
    DataSource: TDataSource;
    Pakiet: TPageControl;
    DataPage: TTabSheet;
    NazwaLab: TLabel;
    NazwaDBText: TDBText;
    CharPage: TTabSheet;
    CharPanel: TPanel;
    RysPage: TTabSheet;
    RysPanel: TPanel;
    Rysunek: TPaintBox;
    ZoomBtn: TSpeedButton;
    Diag: TDiagram;
    FunDH: TDiagFunction;
    Sred1: TLabel;
    SrednText: TDBText;
    DiagDescr1: TDiagDescr;
    DiagDescr2: TDiagDescr;
    OpisPage: TTabSheet;
    OpisView: TObjectView;
    procedure RysunekPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
    procedure CharH( q: double; var h: double );
  private
    { Private declarations }
    //Ciecz    : TCieczPlyw;
    DXFDraw  : TPompDXFDrawing;
    procedure SetInner;
    procedure InitDiagr;
    procedure InitRys;

    function  GetElem  :TElement;
    procedure SetElem( e  :TElement );

    procedure UWMSetLang( var msg :TMessage ); message UWM_SET_LANG;

    property  Elem     : TElement  read GetElem   write SetElem;
  protected
    procedure SetLang;    virtual;
    procedure SetElement(e :TElemAbstract);  override;
    procedure SetCiecz(c :TCieczPlyw);       override;
  public
    { Public declarations }
    Producent   :TProducent;
    Baza        :TDBArmatura;

    constructor Create( AOwner :TComponent );    override;
    destructor  Destroy;                         override;

    procedure   Init;
    procedure   InitNoCreat;
    procedure   PrintEv( Sender: TObject );

  end;

var
  ArmElemForm: TArmElemForm;

implementation

{$R *.DFM}

{----------------------------------------------------------------------------}
constructor TArmElemForm.Create( AOwner :TComponent );
var
  mf        :TForm;
begin
  inherited Create( AOwner );
  mf := Application.MainForm;
  if (mf <> NIL) and (mf.FormStyle = fsMDIForm) then
    FormStyle := fsMDIChild
  else
    FormStyle := fsNormal;

end;

{----------------------------------------------------------------------------}
destructor  TArmElemForm.Destroy;
begin

  inherited Destroy;
end;

{----------------------------------------------------------------------------}
procedure   TArmElemForm.Init;
var
  h2o       :TCieczH2O;
begin
  Elem  := CreateElemFromDB( Baza ) as TElement;
  if Elem <> NIL then
    Elem.L := 1;
  Ciecz := TCieczPlyw.Create(self);
  h2o   := TCieczH2O.Create(Ciecz);
  h2o.T := 20;
  Ciecz.Ciecz := h2o;
  //Baza.Update;
  InitNoCreat
end;


{----------------------------------------------------------------------------}
procedure   TArmElemForm.InitNoCreat;
var
  fld       :TField;
begin
  InitRys;
  InitDiagr;
  with Baza do
  if tOK and bOK then
  begin
    fld := T.FindField( 'OPIS' );
    if fld <> NIL then with B as TTable do
    begin
      SetKey;
      FieldByName('ID').AsString := fld.AsString;
      if GotoKey then
      begin
        ObjViewFromBinBase( OpisView, B );
      end;
    end;
  end;
end;

{----------------------------------------------------------------------------}
procedure TArmElemForm.SetElement(e :TElemAbstract);
begin
  Baza.Free;
  inherited SetElement(e);
  try
    with e as TElement do
      self.Baza := Baza;
    if Baza <> NIL then
    begin
      self.Producent := Baza.Producent;
      DataSource.DataSet := Baza.A;
    end;
  except
    on EInvalidCast do
      self.Baza := NIL;
  end;
  InitNoCreat;
end;

{----------------------------------------------------------------------------}
procedure TArmElemForm.SetCiecz(c :TCieczPlyw);
begin
  inherited SetCiecz(c);
  InitDiagr;
end;



{----------------------------------------------------------------------------}
procedure TArmElemForm.SetInner;
const
  MinW = 400;
  MinH = 250;
var
  w, h, t :Integer;
begin
  w := Width - 8;
  if w < MinW then
    w := MinW;
  Pakiet.Width := w;

  h := Height - 30;
  if h < MinH then
    h := MinH;
  Pakiet.Height := h;

  with CloseBtn do
  begin
    Top  := h - Height - 20;
    Left := w - Width  - 20;
  end;


  with CharPanel do
  begin
    Height  := h - Top  - 40;
    Width   := w - Left - 40 - CloseBtn.Width;
    t       := Width - 100;
  end;
  {cbH.Left     := t;
  cbP.Left     := t;
  cbNPSH.Left  := t;
  cbETA.Left   := t;}
  t := CharPanel.Width;

  with OpisView do
  begin
    Height  := CharPanel.Height;
    Width   := CharPanel.Width;
  end;

  {
  with CopyCharBtn do
  begin
    top   := CharPanel.Top;
    left  := CharPanel.Left+CharPanel.Width+30;
  end;
  }

  with RysPanel do
  begin
    Height  := h - Top  - 40;
    Width   := round( 640 /480 * Height );
    if Width > w - Left - 40 - CloseBtn.Width then
    begin
      Width  := w - Left - 40 - CloseBtn.Width;
      Height := round( 480/640 * Width );
    end;
  end;


  with ZoomBtn do
  begin
    top   := RysPanel.Top;
    left  := RysPanel.Left+RysPanel.Width+30;
  end;

  {
  with CopyRysBtn do
  begin
    top   := RysPanel.Top;
    left  := RysPanel.Left+RysPanel.Width+30 +25;
  end;
  }

end;


{----------------------------------------------------------------------------}
procedure TArmElemForm.InitDiagr;
var
  fs        :integer;
  MiejscZer :integer;
  QMax, v   :Double;
  svQ       :Double;
begin

  with Diag do
  begin

    if Elem <> NIL then
    begin
                     // m/s -> m/h
      QMax      :=   (20*3600) * Pi*sqr(Elem.d)/4;
      // Q[m^3/h] = v[m/h] * PolePrzekroju[m^2]
      MaxXR  :=   Dzialka( QMax, XCells, MiejscZer )*XCells;
      DecXScale := MiejscZer;
    end;

    { H }
    if (Elem <> NIL) and (Ciecz <> NIL) then with funDH do
    begin

      svQ := Ciecz.Q_m3h;
      Ciecz.Q_m3h := MaxXR;
      MaxYR := Dzialka( Elem.dH( Ciecz ), YCells, MiejscZer ) * YCells;

      MinXRDraw := 0;
      MaxXRDraw := MaxXR;

      DecYScale := MiejscZer;

      Ciecz.Q_m3h := svQ;
    end;


  end;

end;



{----------------------------------------------------------------------------}
function  TArmElemForm.GetElem  :TElement;
begin
  result := Element as TElement;
end;


{----------------------------------------------------------------------------}
procedure TArmElemForm.SetElem( e  :TElement );
begin
  Element := e;
end;



{----------------------------------------------------------------------------}
procedure TArmElemForm.UWMSetLang( var msg :TMessage );
begin
end;

{----------------------------------------------------------------------------}
procedure TArmElemForm.SetLang;
begin
end;



{----------------------------------------------------------------------------}
procedure   TArmElemForm.InitRys;
var
  h       : word;
  FN      : string;
begin
  DXFDraw := TPompDXFDrawing.Create;
  if Baza.gOK then
  begin
    //FN := Producent.BazySciezka['PIPES'] + '\schematy\';
    FN := Producent.BazySciezka['PIPES'] + '\schematy\r_';
    FN := FN + Producent.Ident + '.';
    FN := FN + Baza.G.FieldByName('G_Met').AsString;
    if FileExists(FN) then
      TPompDXFDrawing(DXFDraw).LoadWithBase(FN,Baza.G);
  end;
end;


{----------------------------------------------------------------------------}
procedure TArmElemForm.RysunekPaint(Sender: TObject);
var
  R, R2:TRect;
  dd :TSpecDrawData;
begin
  R.Top    := 0;
  R.Left   := 0;
  R.Right  := Rysunek.Width;
  R.Bottom := Rysunek.Height;
  R2.Top   := 480;
  R2.Left  := 0;
  R2.Right := 640;
  R2.Bottom:= 0;
  dd := TSpecDrawData.Create;
  dd.Canvas := Rysunek.Canvas;
  dd.Construct2Rect( R2, R );
  DXFDraw.DrawOnSpec( dd );
  dd.Free;
end;

{----------------------------------------------------------------------------}
procedure   TArmElemForm.CharH( q: double; var h: double );
var
  svQ       :Double;
begin
  try
    svQ := Ciecz.Q_m3h;
    Ciecz.Q_m3h := q;
    h       := Elem.dH( Ciecz );
    Ciecz.Q_m3h := svQ;
  except
    on EAccessViolation do
      h := 0;
  end;
end;

{----------------------------------------------------------------------------}
procedure   TArmElemForm.PrintEv( Sender: TObject );
begin
end;



procedure TArmElemForm.FormResize(Sender: TObject);
begin
  SetInner;
end;

procedure TArmElemForm.ZoomBtnClick(Sender: TObject);
var
  RForm   :TRysForm;
begin
  RForm   := TRysForm.Create(self);
  RForm.DXFDraw := DXFDraw;
  RForm.Show;
  RForm.InitInner;
end;

end.
  