unit CieczeFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Diagrams, Grids, DBGrids, DbgEx, Ciecze, TbsU, StdCtrls,
  Buttons, ExtCtrls, Math;

type
  TCieczeForm = class(TForm)
    CieczeDataSrc: TDataSource;
    CieczeTab: TTable;
    DBGridEx1: TDBGridEx;
    Diagram: TDiagram;
    RoFun: TDiagFunction;
    NiFun: TDiagFunction;
    PvFun: TDiagFunction;
    RoDiagDescr: TDiagDescr;
    NiDiagDescr: TDiagDescr;
    DiagDescr1: TDiagDescr;
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    Splitter1: TSplitter;
    procedure RoFunValue(X: Double; var Y: Double);
    procedure NiFunValue(X: Double; var Y: Double);
    procedure PvFunValue(X: Double; var Y: Double);
    procedure FormCreate(Sender: TObject);
    procedure CieczeTabFilterRecord(DataSet: TDataSet;
      var Accept: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure CieczeTabAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    NiPrzel   :Double;
    PvPrzel   :Double;
    procedure Aktualizuj;
  public
    { Public declarations }
    Ciecz :TCieczRodzaj;

    function CreateCiecz( O :TComponent ) :TCieczRodzaj;
    function Execute :Boolean;
  end;

var
  CieczeForm: TCieczeForm;

implementation

{$R *.DFM}

procedure TCieczeForm.RoFunValue(X: Double; var Y: Double);
begin
  if Ciecz <> NIL then
    Y := Ciecz.RoOdT(X);
end;

procedure TCieczeForm.NiFunValue(X: Double; var Y: Double);
begin
  if Ciecz <> NIL then
    Y := Ciecz.NiOdT(X)*NiPrzel;

end;

procedure TCieczeForm.PvFunValue(X: Double; var Y: Double);
begin
  if Ciecz <> NIL then
    Y := Ciecz.PvOdT(X)*PvPrzel;
end;

procedure TCieczeForm.FormCreate(Sender: TObject);
var
  p       :string;
begin
  if FileExists( SciezkaBaz + '\ciecze.dbf' ) then
    p := SciezkaBaz
  else
    p := ExePath;
  NiPrzel := 1000000;
  PvPrzel := 0.001;
  CieczeTab.DatabaseName := p;
  CieczeTab.TableName := 'ciecze.dbf';
  CieczeTab.Open;
end;

function TCieczeForm.CreateCiecz(O: TComponent): TCieczRodzaj;
begin
  result := CreateCieczFromDB( CieczeTab, O );
end;

procedure TCieczeForm.Aktualizuj;
begin
  if Ciecz <> NIL then
  begin
    Ciecz.Free;
  end;
  Ciecz := NIL;
  try
    Ciecz := CreateCiecz(self);
  except
  end;

  if (Ciecz.TMax >0) then
  begin
    if (Ciecz.TMin >= 0) then
    begin
      Diagram.MinXR := 0;
      Diagram.CountMaxXR( Ciecz.TMax )
    end
    else
    begin
      Diagram.CountMaxXR( Max( -Ciecz.TMin, Ciecz.TMax ) );
      Diagram.MinXR := - Diagram.MaxXR;
    end;
  end
  else
  begin
    Diagram.CountMaxXR( -Ciecz.TMin );
    Diagram.MinXR := - Diagram.MaxXR;
    Diagram.MaxXR := 0;
  end;
  RoFun.MinXRDraw := Ciecz.TMin;
  RoFun.MaxXRDraw := Ciecz.TMax;
  NiFun.MinXRDraw := Ciecz.TMin;
  NiFun.MaxXRDraw := Ciecz.TMax;
  PvFun.MinXRDraw := Ciecz.TMin;
  PvFun.MaxXRDraw := Ciecz.TMax;

  RoFun.CountMaxYR( Ciecz.RoOdT( Ciecz.TMin ));
  NiFun.CountMaxYR( Ciecz.NiOdT( Ciecz.TMin )*NiPrzel);
  PvFun.CountMaxYR( Ciecz.PvOdT( Ciecz.TMax )*PvPrzel);

  Diagram.Invalidate;

end;

function TCieczeForm.Execute: Boolean;
begin
  ShowModal;
  result := ModalResult = mrOK;
end;

procedure TCieczeForm.CieczeTabFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  try
    Accept := DataSet.FieldByName('H_MET').AsString <> '';
  except
    Accept := false;
  end;
end;

procedure TCieczeForm.FormDestroy(Sender: TObject);
begin
  CIeczeTab.Filtered := false;
  CieczeTab.Close;
end;

procedure TCieczeForm.CieczeTabAfterScroll(DataSet: TDataSet);
begin
  Aktualizuj;
end;

end.
