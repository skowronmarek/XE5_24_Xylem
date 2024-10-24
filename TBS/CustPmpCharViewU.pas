unit CustPmpCharViewU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, EditNew, Diagrams, ExtCtrls, Buttons, Printers, Math, Clipbrd,
  KR_Sys, KRMath, OPompa, TbsFormU, DGraph, Menus;

type
  TCustomPmpCharViewer = class(TTbsForm)
    ControlPanel: TPanel;
    MainPan: TPanel;
    HDiag: TDiagram;
    PDiag: TDiagram;
    NPSHDiag: TDiagram;
    EtaDiag: TDiagram;
    HDiagFun: TDiagFunction;
    PDiagFun: TDiagFunction;
    NPSHDiagFun: TDiagFunction;
    EtaDiagFun: TDiagFunction;
    CloseZoomBtn: TSpeedButton;
    Splitter1: TSplitter;
    HQDescr: TDiagDescr;
    NPSHQDescr: TDiagDescr;
    PQDescr: TDiagDescr;
    EtaQDescr: TDiagDescr;
    HDescr: TDiagDescr;
    PDescr: TDiagDescr;
    NPSHDescr: TDiagDescr;
    EtaDescr: TDiagDescr;
    PrintDialog: TPrintDialog;
    PopupMenu: TPopupMenu;
    CopyMenu: TMenuItem;
    ZoomInMenu: TMenuItem;
    ZoomOutMenu: TMenuItem;
    SaveAsMenu: TMenuItem;
    SaveMetaDialog: TSaveDialog;
    PrintBtn: TBitBtn;
    procedure MainPanResize(Sender: TObject);
    procedure DiagDblClick(Sender: TObject);
    procedure CloseZoomBtnClick(Sender: TObject);
    procedure CopyMenuClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure ZoomInMenuClick(Sender: TObject);
    procedure ZoomOutMenuClick(Sender: TObject);
    procedure SaveAsMenuClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
  private
    //FDefCloseAction: TCloseAction;
    //procedure SetDefCloseAction(const Value: TCloseAction);

  protected
    //FHDrawer    :TWPFuncDiag;
    //FPDrawer    :TWPFuncDiag;
    //FNPSHDrawer :TWPFuncDiag;
    //FEtaDrawer  :TWPFuncDiag;
    FPompa: TPompa;
    CharData: TPompCharData;
    DiagZoomed :TDiagram;
    XCells     :Integer;

    procedure TBSPrint;                             override;
    function  TBSCanPrint :Boolean;                 override;

    procedure Zoom( dg :TDiagram );

    procedure ReleasePompa;                  virtual;
    procedure InitPompa;                     virtual;
    procedure SetPompa(const Value: TPompa); virtual;
    procedure UstawMinMax;                   virtual;

    procedure DrawDiagInRect( Cnv :TCanvas; R :TRect; Dg :TDiagram );
    procedure GetDiagPrintRect( var R :TRect;
                                Prn :TPrinter;
                                All :Boolean );   virtual;
    procedure PrintOpis( prn :TPrinter; All :Boolean );    virtual;
    procedure InternalPrint( prn :TPrinter);      virtual;
    procedure InitPrinter1;                       virtual;
    procedure InitPrinter2(prn :TPrinter);        virtual;

    procedure CopyDiagToClipboard( dg :TDiagram );
    function GetDiagMetaile(dg :TDiagram) :TMetafile;
  public
    { Public declarations }
    constructor Create( Owner :TComponent );     override;
    destructor Destroy;                          override;
    procedure Aktualizuj;                        override;
    property Pompa :TPompa read FPompa write SetPompa;
  end;

var
  CustomPmpCharViewer: TCustomPmpCharViewer;

implementation

uses KatDataMU;

{$R *.DFM}

{ TCustomPmpCharViewer }

procedure TCustomPmpCharViewer.Aktualizuj;
begin
  inherited;
  UstawMinMax;
  HDiag.Invalidate;
  PDiag.Invalidate;
  NPSHDiag.Invalidate;
  EtaDiag.Invalidate;
end;

constructor TCustomPmpCharViewer.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  XCells := 5;
end;

destructor TCustomPmpCharViewer.Destroy;
begin
  ReleasePompa;
  inherited;
end;



procedure TCustomPmpCharViewer.SetPompa(const Value: TPompa);
begin
  ReleasePompa;
  FPompa := Value;

  InitPompa;
  Aktualizuj;

end;


procedure TCustomPmpCharViewer.UstawMinMax;
begin
  HDiag.CountMaxXRAuto(CharData.CharQMax, 6);
  XCells := HDiag.XCells;
  PDiag.CountMaxXRAuto(CharData.CharQMax, 6);
  NPSHDiag.CountMaxXRAuto(CharData.CharQMax, 6);
  EtaDiag.CountMaxXRAuto(CharData.CharQMax, 6);
  HDiagFun.CountMaxYR(CharData.CharHMax);
  PDiagFun.CountMaxYR(CharData.CharPMax);
  NPSHDiagFun.CountMaxYR(CharData.CharNPSHMax);
end;

procedure TCustomPmpCharViewer.MainPanResize(Sender: TObject);
var
  //w, h    :Integer;
  w2, h2  :Integer;
begin
  with CloseZoomBtn do
  begin
    Top     :=  1;
    Left    := MainPan.ClientWidth - 23;
    Width   := 22;
    Height  := 22;
  end;

  if DiagZoomed <> NIL then
    EXIT;
  w2 := MainPan.Width div 2;
  h2 := MainPan.Height div 2;

  HDiag.SetBounds( 2, 2, w2-3, h2-3 );
  PDiag.SetBounds( 2, h2+1, w2-3, h2-3 );
  NPSHDiag.SetBounds( w2+1, 2, w2-3, h2-3 );
  EtaDiag.SetBounds( w2+1, h2+1, w2-3, h2-3 );

end;

procedure TCustomPmpCharViewer.DiagDblClick(Sender: TObject);
begin
  Zoom( Sender as TDiagram );
end;

procedure TCustomPmpCharViewer.CloseZoomBtnClick(Sender: TObject);
begin
  Zoom(NIL);
end;

procedure TCustomPmpCharViewer.ReleasePompa;
begin
  if FPompa <> NIL then
  begin
    FPompa.Release;
    FPompa := NIL;
    CharData := NIL;
  end;
end;

procedure TCustomPmpCharViewer.InitPompa;
begin
  if FPompa <> NIL then
  begin
    FPompa.AddRef;
    Caption := Format( 'Podglad charakterystyk [%s]', [FPompa.Nazwa] );
    CharData := FPompa.GetCharData;
    CharData.GetDiagFun( 'H', HDiagFun );
    CharData.GetDiagFun( 'P', PDiagFun );
    CharData.GetDiagFun( 'NPSH', NPSHDiagFun );
    CharData.GetDiagFun( 'ETA', EtaDiagFun );
  end
  else
  begin
    Caption := 'Podglad charakterystyk';
  end;
end;

procedure TCustomPmpCharViewer.GetDiagPrintRect(var R: TRect;
  Prn: TPrinter; All: Boolean);
var
  w, h    :Integer;
  t, l    :Integer;
begin
  if Prn.Orientation = poLandscape then
  begin
    t := round(CnvPixYPerInch(Prn.Canvas) * 0.7 / 2.54);
    h := Prn.PageHeight - (t+2);
    w := min(round(1.3 *Prn.PageHeight), Prn.PageWidth);
    l := (Prn.PageWidth - w) div 2;
  end
  else
  begin
    w := Prn.PageWidth;
    h := w;
    t := (Prn.PageHeight - h) div 2;
    l := 0;
  end;
  with R do
  begin
    Left := l;
    Top  := t;
    Right := l + w-1;
    Bottom := t + h-1;
  end;
end;

procedure TCustomPmpCharViewer.DrawDiagInRect( Cnv: TCanvas;
                                               R: TRect;
                                               Dg :TDiagram);
begin
  Dg.DrawIt( Cnv, R, false, true );
end;

procedure TCustomPmpCharViewer.PrintOpis( prn :TPrinter; All :Boolean );
var
  R       :TRect;
  C       :TCanvas;
begin
  C := prn.Canvas;
  C.Font.Name := 'Arial';
  C.Font.Size := 14;
  GetDiagPrintRect( R, Prn, All );
  C.TextOut( R.Left, 0, FPompa.Nazwa );
end;

procedure TCustomPmpCharViewer.InternalPrint(prn: TPrinter);
var
  All     :Boolean;
  R       :TRect;
  h2, w2  :Integer;
  mmh2, mmw2 :Integer;
begin
  All := DiagZoomed = NIL;
  PrintOpis( prn, All );
  GetDiagPrintRect( R, Prn, All );
  if All then
  begin
    h2 := round( Lin( 0.5, 0, 1, R.Top, R.Bottom ) );
    w2 := round( Lin( 0.5, 0, 1, R.Left, R.Right ) );
    mmh2 := round((0.05 / 2.54) * CnvPixYPerInch(prn.Canvas));
    mmw2 := round((0.05 / 2.54) * CnvPixXPerInch(prn.Canvas));
    DrawDiagInRect( prn.Canvas, Rect( R.Left, R.Top, w2-mmw2, h2-mmh2 ),
                    HDiag);
    DrawDiagInRect( prn.Canvas, Rect( R.Left, h2+mmh2, w2-mmw2, R.Bottom ),
                    PDiag);
    DrawDiagInRect( prn.Canvas, Rect( w2+mmw2, R.Top, R.Right, h2-mmh2 ),
                    NPSHDiag);
    DrawDiagInRect( prn.Canvas, Rect( w2+mmw2, h2+mmh2, R.Right, R.Bottom ),
                    EtaDiag);
  end
  else
  begin
    DrawDiagInRect( prn.Canvas, R, DiagZoomed );
  end;
end;

function TCustomPmpCharViewer.TBSCanPrint: Boolean;
begin
  result := true;
end;

procedure TCustomPmpCharViewer.TBSPrint;
begin
  InitPrinter1;
  if PrintDialog.Execute then
  begin
    InitPrinter2(Printer);
    Printer.BeginDoc;
    InternalPrint(Printer);
    Printer.EndDoc;
  end;
end;

procedure TCustomPmpCharViewer.InitPrinter1;
begin

end;

procedure TCustomPmpCharViewer.InitPrinter2(prn: TPrinter);
begin

end;

procedure TCustomPmpCharViewer.CopyDiagToClipboard(dg: TDiagram);
begin
  Clipboard.Assign(dg);
end;

function TCustomPmpCharViewer.GetDiagMetaile(dg :TDiagram): TMetafile;
var
  mf     :TMetafile;
  mfc    :TMetafileCanvas;
  R      :TRect;
begin
  mf := TMetafile.Create;
  mf.Width  := 500;
  mf.Height := 500;

  //mf.MMWidth := 100;
  //mf.MMHeight := 100;

  R := Rect( 0, 0, mf.Width, mf.Height );
  mfc := TMetafileCanvas.Create(mf, 0);
  try
    dg.DrawIt( mfc, R, false, true );
  finally
    mfc.Free;
  end;
  result := mf;
end;

procedure TCustomPmpCharViewer.CopyMenuClick(Sender: TObject);
begin
  if PopupMenu.PopupComponent is TDiagram then
  begin
    CopyDiagToClipboard( TDiagram(PopupMenu.PopupComponent) );
  end;
end;

procedure TCustomPmpCharViewer.PopupMenuPopup(Sender: TObject);
begin
  CopyMenu.Enabled :=
        (PopupMenu.PopupComponent is TDiagram);
  SaveAsMenu.Enabled := CopyMenu.Enabled;
  ZoomInMenu.Visible  := DiagZoomed = NIL;
  ZoomOutMenu.Visible := not ZoomInMenu.Visible;
  if ZoomInMenu.Visible then
    ZoomInMenu.Enabled := (PopupMenu.PopupComponent is TDiagram);
end;

procedure TCustomPmpCharViewer.ZoomInMenuClick(Sender: TObject);
begin
  if PopupMenu.PopupComponent is TDiagram then
    Zoom(TDiagram(PopupMenu.PopupComponent));
end;

procedure TCustomPmpCharViewer.Zoom(dg: TDiagram);

  procedure DHide( d :TDiagram );
  begin
    if d <> DiagZoomed then
      d.Hide;
  end;

begin
  if dg <> NIL then
  begin
    DiagZoomed := dg;
    DHide(HDiag);
    DHide(PDiag);
    DHide(NPSHDiag);
    DHide(EtaDiag);
    DiagZoomed.XCells := 2*XCells;
    DiagZoomed.YCells := 10;
    DiagZoomed.Align := alClient;
    CloseZoomBtn.Show;
  end
  else
  begin
    if DiagZoomed = NIL then
      EXIT;
    DiagZoomed.Align := alNone;
    DiagZoomed.XCells := XCells;
    DiagZoomed.YCells := 5;
    DiagZoomed := NIL;
    MainPanResize(MainPan);
    HDiag.Show;
    PDiag.Show;
    NPSHDiag.Show;
    EtaDiag.Show;
    CloseZoomBtn.Hide;
  end;
end;

procedure TCustomPmpCharViewer.ZoomOutMenuClick(Sender: TObject);
begin
  Zoom(NIL);
end;

procedure TCustomPmpCharViewer.SaveAsMenuClick(Sender: TObject);
var
  mf      :TMetafile;
begin
  inherited;
  if PopupMenu.PopupComponent is TDiagram then
  begin
    mf := GetDiagMetaile(TDiagram(PopupMenu.PopupComponent));
    try
      if SaveMetaDialog.Execute then
        mf.SaveToFile(SaveMetaDialog.FileName);
    finally
      mf.Free;
    end;
  end;
end;

procedure TCustomPmpCharViewer.PrintBtnClick(Sender: TObject);
begin
  inherited;
  TBSPrint;
end;

end.
