UNIT PrzegBrw;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DBGrids, DB, DBTables, ExtCtrls, DBCtrls,
  Jednost,       { moduly wlasne }
  JezykTxt,
  Prod,
  OPompa, PmpListU, WkpGlob,
  PompySQL, StdCtrls, DbgEx, Jezyki;

type
  TPompPrzeglForm = class(TForm)
    QueryDataSource: TDataSource;
    G_DataSource: TDataSource;
    DBGrid1: TDBGridEx;
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Query2CalcFields(DataSet: TDataset);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGrid1StartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure DBGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DBGrid1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    {FDB          : TDataBase;
    procedure  setDB( ADB: TVDataBase );}
    FProd       :TProducent;
    FMoznaDrag :Boolean;
    FGridStartDragPos :TPoint;
    FBeforeDrag :Boolean;
    FDragged    :Boolean;

    procedure setProd( p :TProducent );
    procedure UWMSetLang( var msg :TMessage ); message UWM_SET_LANG;
    procedure SetOnRecordChange(const Value: TDataSetNotifyEvent);
    procedure SetMoznaDrag(const Value: Boolean);
  protected
    FOnRecordChange: TDataSetNotifyEvent;
    procedure SetLang;    virtual;
    procedure ZacznijDrag;
  public
    { Public declarations }
    Baza        : TDBPompy;  // baza pomp
    Query       : TDataSet;  // baza A_ do przegladania w browserze
    G_Table     : TDataSet;  // baza G_


    {destructor Destroy; override;}


    procedure ZwolnijBaze;
    function  DajPompeWBazie: TPompa;
    procedure TabInit( prod: TProducent );

    property OnRecordChange : TDataSetNotifyEvent read FOnRecordChange write SetOnRecordChange;
    property  Producent   : TProducent  read FProd write setProd;
    property MoznaDrag :Boolean read FMoznaDrag write SetMoznaDrag;
    {property  DB: TVDataBase read FDB write setDB;}
  end;

var
  PompPrzeglForm: TPompPrzeglForm;


{=========================================================================}
implementation

{$R *.DFM}

uses
  KatFormTools,
  FPompy;

{-------------------------------------------------------------------------}
{destructor TPompPrzeglForm.Destroy;
begin
  ZwolnijBaze;
  inherited Destroy;
end;
}

{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.UWMSetLang( var msg :TMessage );
begin
  SetLang;
  msg.Result := 1;
end;


{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.SetLang;
begin
//  Caption                  := DajText(PrzeglBazy_txt);
//{  QueryNazwa.DisplayLabel  := DajText(Nazwa_txt);
//  QueryCena.DisplayLabel   := DajText(Cena_txt);
//  QueryMasa.DisplayLabel   := DajText(Masa_txt);}
//
end;



{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.FormResize(Sender: TObject);
begin
  //left:=0;
  //DBGrid1.Top     := 0;
  //DBGrid1.Left    := 0;
  //DBGrid1.Width  := ClientWidth;
  //DBGrid1.Height := ClientHeight - DBGrid1.Top;
end;

{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.FormActivate(Sender: TObject);
begin
  //FormResize(self);
end;
(*
{-------------------------------------------------------------------------}
procedure  TPompPrzeglForm.setDB( ADB: TDataSet );
begin
  FDB := ADB;
  {DBGrid1.DataSet := ADB;}
end;
*)

{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.Query2CalcFields(DataSet: TDataset);
var
  nazwa: string;
  g_id: string;
  m: Extended;
begin
{  with query do
  begin
    nazwa := FieldByName('nazwa').AsString;
    FieldByName('QnJedn').AsFloat :=
        JednQ.StdToUser(FieldByName('Qn').AsFloat);
    FieldByName('HnJedn').AsFloat :=
        JednH.StdToUser(FieldByName('Hn').AsFloat);
    g_id := FieldByName('G_ID').AsString;
    if G_Table.FieldByName('G_ID').AsString <> g_id then
    begin
      G_Table.SetKey;
      G_Table.FieldByName('G_ID').AsString := g_id;
      G_Table.GotoKey;
      G_Table.CheckBrowseMode;
      if G_Table.FieldByName('G_ID').AsString = g_id then
        m := G_Table.FieldByName('MASA').AsFloat
      else
        m := 0;
    end
    else
       m := G_Table.FieldByName('MASA').AsFloat;
    FieldByName('MASA').AsFloat := m;
  end;
  }
end;

{-------------------------------------------------------------------------}
function TPompPrzeglForm.DajPompeWBazie: TPompa;
var
  p: TPompa;
begin
  p := UtworzPompe(Baza, spWBazie);
  p.Producent := self.Producent;
  result := p;
end;

{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.setProd( p :TProducent );
begin
  if Self = NIL then
    EXIT;
  if FProd <> p then
    TabInit( p );
end;


{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.TabInit( prod: TProducent );
begin
  //?? ustawia bazy do przegladaia w browserze??

  if (baza <> NIL) and (baza.Owner = self) then
    ZwolnijBaze;
  baza := TDBPompy.CreateForProd( self, prod );
  FProd := prod;
  G_Table   := baza.G;
  Query     := baza.A;
  if @FOnRecordChange <> NIL then
    Query.AfterScroll := FOnRecordChange;
  G_DataSource.DataSet    := G_Table;
  QueryDataSource.DataSet := Query; // podstawienie tabeli do wyswietlania
end;


{-------------------------------------------------------------------------}
procedure TPompPrzeglForm.ZwolnijBaze;
begin

  if Assigned( Baza ) then
  begin
    Baza.Free;
    Baza := NIL;
    G_Table := NIL;
    Query   := NIL;
  end;
  {if Assigned( FDB ) then
  begin
    DB.Free;
    DB := NIL;
  end;}

end;




procedure TPompPrzeglForm.DBGrid1KeyPress(Sender: TObject; var Key: Char);
var
  odc     :TNotifyEvent;
begin
  case Key of
    #13:                          // dzialanie z DoubleClick
    begin
      odc := DBGrid1.OnDblClick;
      if Assigned(odc)  then
        odc( self );
    end;
    #27: Close
  end;
end;

procedure TPompPrzeglForm.FormCreate(Sender: TObject);
begin
  SetLang;
  FormShow(nil);
end;

procedure TPompPrzeglForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPompPrzeglForm.DBGrid1DblClick(Sender: TObject);
var
  Pompa : TPompa;
  F     : TForm;
begin
  Pompa := CreatePump(self, Baza);
  Pompa.DBCreateCopy( Baza );
  //ChildZoomed := (PompPrzeglForm.WindowState = wsMaximized);
  //TFormPompy.StworzDlaPompy( self, Pompa).Show;
  //F := Pompa.CreateForm( self );
  F := FormDlaPompy(Pompa, Self, True);
end;

procedure TPompPrzeglForm.SetOnRecordChange( const Value: TDataSetNotifyEvent);
begin
  FOnRecordChange := Value;
  if Query <> NIL then
    Query.AfterScroll := Value;
end;

procedure TPompPrzeglForm.DBGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
// 2005-01-10 Tymczasowo do mechanizmu testowania odrzucen
//  if not WerPro then
//    EXIT;
  if (Button = mbLeft) and (not (ssDouble in Shift)) then
  begin
    FGridStartDragPos := Point(X,Y);
    FBeforeDrag := true;
  end;
end;

procedure TPompPrzeglForm.DBGrid1StartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
  Pompa    :TPompa;
begin
  Pompa := CreatePump(NIL, Baza);
  Pompa.DBCreateCopy( Baza );
  DragObject := TPompaDragObject.Create( Pompa, DBGrid1 );
end;

procedure TPompPrzeglForm.SetMoznaDrag(const Value: Boolean);
begin
  FMoznaDrag := Value;
end;

procedure TPompPrzeglForm.DBGrid1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FBeforeDrag then
    FBeforeDrag := false;
end;

procedure TPompPrzeglForm.DBGrid1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
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

procedure TPompPrzeglForm.ZacznijDrag;
begin
  DBGrid1.BeginDrag( true );
  FDragged := true;
  FBeforeDrag := false;
end;

procedure TPompPrzeglForm.DBGrid1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := false;
  if Source is TDragObject then
    TDragObject(Source).ShowDragImage;
end;

procedure TPompPrzeglForm.FormShow(Sender: TObject);
var i : integer;
begin
 for i := 0 to DBGrid1.Columns.Count - 1  do
   DBGrid1.Columns[i].Title.Caption := TTlumacz.dajObiekt.ZnajdzTlumaczenie(DBGrid1.Columns[i].Title.Caption);
 DBGrid1.Tag := 1;
end;

end.
