unit Strform;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Outline, ExtCtrls, Buttons, StdCtrls,
  DB, DBTables, ComCtrls, inifiles, ObjView, Diagrams, DGraph,
  KR_Sys, KR_Class, KR_Ctrls, KR_DB,  Math, TBS_Tool, WkpGlob,  JezykTxt,
  PrzegBrw, BInfoU, PmpBaseInfoU, Prod,
  OPompa, PmpListU, PompaReg, PompySQL,
  WCharU, WieloCharFormU, ObszarWCharU, PropertyAccesserU, FormSaverU, Menus, ToolWin, jezyki;

type
  TObszCharRec = record
    Id           :string;
    Color        :TColor;
    CharList     :TWCharList;
    DiagFun      :TDiagFunction;
    Descr        :string;
    BM           :TBookmarkStr;
  end;

  TObszCharRecArray = array of TObszCharRec;
  TPmpIconType = (pitNone, pitSmall, pitLarge);
  TStructForm = class(TForm)
    TypTable: TTable;
    TypDataSource: TDataSource;
    BinDataSource: TDataSource;
    BinTable: TTable;
    LeftPanel: TPanel;
    OutLinePanel: TPanel;
    Outline1: TOutline;
    BtnPanel: TPanel;
    CancelButton: TButton;
    WyswButton: TButton;
    SplitterVMain: TSplitter;
    RightPanel: TPanel;
    PageControl: TPageControl;
    RysSheet: TTabSheet;
    ZdjView: TObjectView;
    ImgSplitter: TSplitter;
    CharView: TObjectView;
    DiagramObsz: TDiagram;
    descrHJedn: TDiagDescr;
    DF1: TDiagFunction;
    DiagDescr1: TDiagDescr;
    descrQOpis: TDiagDescr;
    descrQJedn: TDiagDescr;
    TreeView: TTreeView;
    Saver: TFormSaver;
    Panel1: TPanel;
    ProducentLab: TLabel;
    ToolBar: TToolBar;
    tbtnRodzajIkon: TToolButton;
    pmnuDropIconType: TPopupMenu;
    mnuDuzeIkony: TMenuItem;
    mnuMaleIkony: TMenuItem;
    mnuBezIkon: TMenuItem;
    popupDiagram: TPopupMenu;
    mnuDiagTylkoObwodki: TMenuItem;
    mnuDiagPokazCharak: TMenuItem;
    panQHCurs: TPanel;
    labQNazw: TLabel;
    labHNazw: TLabel;
    labQVal: TLabel;
    labHVal: TLabel;
    Timer1: TTimer;

      procedure CancelButtonClick(Sender: TObject);

      procedure WyswButtonClick(Sender: TObject);

      procedure FormCreate(Sender: TObject);

      procedure FormResize(Sender: TObject);

      procedure Outline1DblClick(Sender: TObject);

      procedure Outline1KeyDown(Sender: TObject; var Key: Word;
            Shift: TShiftState);

      procedure Outline1Click(Sender: TObject);

      procedure FormShow(Sender: TObject);

      procedure FormDestroy(Sender: TObject);

      procedure PageControlChange(Sender: TObject);

      procedure ListPanUnDock(Sender: TObject; Client: TControl;
            NewTarget: TWinControl; var Allow: Boolean);

      procedure ListPanGetSiteInfo(Sender: TObject; DockClient: TControl;
            var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);

      procedure ListPanDockOver(Sender: TObject; Source: TDragDockObject; X,
            Y: Integer; State: TDragState; var Accept: Boolean);

      procedure ListPanDockDrop(Sender: TObject; Source: TDragDockObject; X,
            Y: Integer);

      procedure mnuDuzeIkonyClick(Sender: TObject);

      procedure mnuMaleIkonyClick(Sender: TObject);

      procedure mnuBezIkonClick(Sender: TObject);

      procedure tbtnRodzajIkonClick(Sender: TObject);

      procedure DiagramObszMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);

      procedure DiagramObszMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);

      procedure mnuDiagTylkoObwodkiClick(Sender: TObject);

      procedure mnuDiagPokazCharakClick(Sender: TObject);

      procedure CharViewResize(Sender: TObject);

      procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
        private
          FIconTypeActivated :Boolean;
          function GetSelectedNode: TTreeNode;

      procedure CleareTreeView;
          function GetIconType: TPmpIconType;

      procedure SetIconType(const Value: TPmpIconType);
          function GetObszary(i: Integer): TObszCharRec;
          function GetObszaryCount: Integer;
          function GetCharPojedyncze: Boolean;
  private
    AutomatPage    : Boolean;
    FGetQueryForm  : TGetVarProc;
    FProd          : TProducent;
    FListDocked    : Boolean;       //czy jest zadokowana lista przegladanych pomo
    //TypId          : string;
    FltA           : array [1..8] of string[10];
    FltN           : Integer;
    FQueryForm     : TPompPrzeglForm;
    FPicUpdated    : Boolean;
    //FWCharForm     : TWieloCharForm;
    FObszTmpArray  : TObszCharRecArray;
    FObszTmpCnt    : Integer;
    FObszArray     : TObszCharRecArray;
    FObszCnt       : Integer;
    FObszFldName   : string;
    FgotoBookmark  : TBookmarkStr;
    FCzyWysw       : Boolean;
    ChList         : TWCharList;  // lista wszystkich charakterystyk
    Ch1List        : TWCharList;  // lista charakterystyk pojedynczych
                                  // tj. takich, ktore nie naleza do zadnego
                                  // obszar nawet tmp
    FLastMouseObsz : Integer;     // uzywane przy przesowaniu mysza
                                  // do zaznaczania aktywnego obszaru
    FLastSelObsz   : string;      // do zaznaczania w gridzie (na razie nie uzywane)
    FLastCharInfo  : TWCharInfo;
    function getQueryForm: TPompPrzeglForm;

    procedure CreateWCharForm;

    procedure UWMSetLang( var msg :TMessage ); message UWM_SET_LANG;
    function GetObszAtXY( X, Y :Integer ) :Integer;
    function GetObszCharAtXY( X, Y :Integer ) :TWCharInfo;
    function GetChar1AtXY( X, Y :Integer ) :TWCharInfo;
    function ObszDrw( I :Integer ):TObszWCharDiagFun;
    //property SelectedNode :TOutlineNode read GetSelectedNode;
    property SelectedNode :TTreeNode read GetSelectedNode;
  protected

    procedure Notification( AComponent: TComponent;
                                Operation: TOperation); override;

    procedure setProd( pr: TProducent );

    procedure SetLang;    virtual;
    function FilterInternal(DB: TDBPompy; OLNode: TTreeNode) :Boolean;

    procedure ObszAddInternal( const AId :string; AColor :TColor;
                                   const ADescr :string;
                                   var AObszArray :TObszCharRecArray;
                                   var ACnt :Integer );

    procedure ObszAdd( const AId :string; AColor :TColor;
                           const ADescr :string );

    procedure ObszTmpAdd;

    procedure ObszInitData( ind :Integer );

    procedure ObszClear;

    procedure ObszInit(ini :TCustomIniFile);

    procedure ObszCharInit;

    procedure ObszCharClear;

    procedure ObszTmpCharClear;

    procedure ObszCharAddP( P :TPompa );
    function  GetCharColor( ol :TTreeNode ) :TColor;
    function  GetRecCharColor( DB: TDBPompy ) :TColor;
    function  GRChColor( root :TTreeNode; DB: TDBPompy ) :TColor;
    function  MayDraw( DB: TDBPompy ) :Boolean;
    function  MayDrawRec( nod :TTreeNode; DB: TDBPompy ) :Boolean;
  public
    { Public declarations }
    path: TFileName;
    ProdId: string[10];
    Root   :string;
    ListSheet :TTabSheet;
    destructor Destroy;                  override;

    procedure DockListForm;

    procedure UndockListForm;

    procedure WyswPrzegl;

    procedure FilterEv(DataSet: TDataSet; var Accept: Boolean);

    procedure SetInside;

    procedure ChangePos;

    procedure UpdatePict;

    procedure SelectPos( const Ids :array of string );
    property  PompPrzeglForm: TPompPrzeglForm read getQueryForm;
    property  OnGetQueryForm: TGetVarProc read FGetQueryForm
                                          write FGetQueryForm;
    property  Producent: TProducent read FProd write SetProd;
    property  Obszary[i :Integer] :TObszCharRec read GetObszary;
    property  ObszaryCount :Integer read GetObszaryCount;
    property  CharPojedyncze :Boolean read GetCharPojedyncze;
  published
    property IconType :TPmpIconType read GetIconType write SetIconType;
  end;

var
  StructForm: TStructForm;
  PompIconType :TPmpIconType = pitLarge;

implementation

uses KatDataMU;
{$R *.DFM}

{ TStructForm }
destructor TStructForm.Destroy;
begin
  ObszCharClear;
  ObszTmpCharClear;
  inherited;
end;

procedure TStructForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;
{-----------------------------------------------------------------------------}

procedure TStructForm.UWMSetLang( var msg :TMessage );
begin
  SetLang;
  msg.Result := 1;
end;
{-----------------------------------------------------------------------------}

procedure TStructForm.SetLang;
begin
//  if PrzeglDokowane then
//    CancelButton.Caption := DajText(Zamknij_txt)
//  else
//    CancelButton.Caption := DajText(Anuluj_txt);
//  WyswButton.Caption   := DajText(WyswLab_txt);
//  Caption              := DajText(Struktura_txt);
end;
{-----------------------------------------------------------------------------}

procedure TStructForm.WyswButtonClick(Sender: TObject);
begin
  WyswPrzegl;
  FQueryForm.Show;
end;
{-----------------------------------------------------------------------------}
function  TStructForm.getQueryForm: TPompPrzeglForm;
var
  form: TPompPrzeglForm;
begin
  if FQueryForm = NIL then
  begin
    form := NIL;
    if Assigned(FGetQueryForm) then
    begin
      OnGetQueryForm(form);
      form.FreeNotification(self);
    end;
    FQueryForm := form;
  end;
  result := FQueryForm;
end;
(*
{-----------------------------------------------------------------------------}

procedure TStructForm.WyswPrzegl;
// wersja SQL
var
   i, lev: word;
   OLNode: TOutLineNode;
   id, FName: string[10];
   ids: array [1..8] of string[10];
   q: TQuery;
begin
   with OutLine1 do OLNode := Items[SelectedItem];
   lev := OLNode.Level;
   PompPrzeglForm.Producent := self.Producent;
   q := PompPrzeglForm.Query;
   q.Close;
   q.SQL.Clear;
   q.DataBaseName := path;
   q.SQL.Add('SELECT * FROM ');
   q.SQL.Add('"A_' + ProdId + '.DBF" ');
   q.SQL.Add('WHERE ID1 = :id1');
   for i := 2 to lev do
      q.SQL.Add(' and ID' +intToStr(i)+ ' = :id'+intToStr(i));
   for i := lev downto 1 do
   begin
      id := StrLeft( OLNode.Text, 8 );
      FName := 'id' + IntToStr(i);
      q.ParamByName(FName).AsString := id;
      OLNode := OLNode.Parent;
   end;
   PompPrzeglForm.TabInit(Producent);
   q.Open;
   PompPrzeglForm.Show;
end;
*)
{-----------------------------------------------------------------------------}

procedure TStructForm.WyswPrzegl;
// wersja z filtrem
var
   i     : word;
   lev   : Integer;
   //OLNode: TOutLineNode;
   OLNode: TTreeNode;
   q      :TDataSet;
begin
   BeginWaitCur;
   try
     OLNode := SelectedNode;
     {
     if OLNode <> NIL then
       lev := OLNode.Level
     else
       lev := -1;
     }
     PompPrzeglForm.Producent := Producent;
     q := PompPrzeglForm.Query;
     q.Close;
//     PompPrzeglForm.QueryDataSource.DataSet := NIL;
     //for i := lev downto 1 do
     //begin
     //  FltA[i] := StrLeft( OLNode.Text, 8 );
     //  OLNode := OLNode.Parent;
     //end;
     //FltN := lev;
     q.OnFilterRecord := FilterEv;
     q.Filtered       := True;
     q.Open;
     if FgotoBookmark <> '' then
     begin
//       q.Bookmark := FgotoBookmark;
//       FgotoBookmark := '';
     end;
//     PompPrzeglForm.QueryDataSource.DataSet := q;
   finally
     EndWaitCur;
   end;
   {PompPrzeglForm.Show;}
end;

procedure TStructForm.FilterEv(DataSet: TDataSet; var Accept: Boolean);
var
  OLNode: TTreeNode;
  //lev    :
begin
  if (Producent <> NIL) and (Producent.Ident = 'USER') then
  begin
    Accept := true;
    EXIT;
  end;
  if SelectedNode = NIL then
  begin
    Accept := false;
    EXIT;
  end;
  Accept := FilterInternal(getQueryForm.Baza, SelectedNode);
end;
(*

procedure TStructForm.WyswPrzegl;
// probna wersja z zakresami
var
   i, lev: word;
   OLNode: TOutLineNode;
   id, FName: string[10];
   ids: array [1..8] of string[10];
   FiltrStr, ind: string;
   q: TTable;
begin
   with OutLine1 do OLNode := Items[SelectedItem];
   lev := OLNode.Level;
   q := PompPrzeglForm.Query;
   q.Close;
   q.DataBaseName := path;
   q.TableName    := 'A_' + ProdId + '.DBF';
   FiltrStr := '';
   for i := lev downto 1 do
   begin
      ids[i] := StrLeft( OLNode.Text, 8 );
      id := StrLeft( OLNode.Text, 8 );
      FiltrStr := id + FiltrStr;
      OLNode := OLNode.Parent;
   end;
   PompPrzeglForm.TabInit(Producent);
   q.IndexName := 'A_ID.mdx';
   q.Open;
   i   := q.IndexFieldCount;
   {ind := q.IndexFields[0].FieldName;}
   with q do begin
     SetRangeStart;
     FieldByName('ID1').AsString := FiltrStr;
     SetRangeEnd;
     FieldByName('ID1').AsString := FiltrStr+'zzz';
   end;
   {case lev of
      1:
        q.SetRange( [ids[1]], [ids[1]] );
      2:
        q.SetRange( [ids[1], ids[2]], [ids[1], ids[2]] );
      3:
      4:
      5:
      6:
      7:
      8:
   end;}
   q.ApplyRange;
   PompPrzeglForm.Show;
end;
*)
{-----------------------------------------------------------------------------}

procedure TStructForm.SetInside;
begin
end;
{-----------------------------------------------------------------------------}

procedure TStructForm.UpdatePict;
var
  s       :string;
  o       :TPumpOLInfo;
  ZOk, ChOk :Boolean;
begin

  if not (TypTable.Active and BinTable.Active) then
    EXIT; {jesli nie sa aktywne bazy B_ i T_}
  if (PageControl.ActivePage <> RysSheet) or (not Active) then
  begin
    //FPicUpdated := False;
    EXIT; {przechodzi tylko aktywna zakladka ze zdjeciem}
  end;
  if FPicUpdated then
    EXIT; {przechodzi tylko wtedy jak jest nieaktuakne zdjecie}
  o := NIL;
  if SelectedNode <> NIL then
    o := SelectedNode.Data;
  ZOk := false;
  ChOk := false;
  if o <> NIL then
  begin
    if (o.Zdj <> '') then
    begin
      if TableFind( 'ID', o.Zdj, BinTable ) then
      begin
        ObjViewFromBinBase( ZdjView, BinTable );
        ZOk := true;
      end
       {WS 20051120}
       else
        begin
         if FileExists(fprod.SciezkaDoBaz + o.zdj) then
            begin
              ZdjView.LoadFromFile(fprod.SciezkaDoBaz + o.zdj );
              ZdjView.Stretch := true;
              ZdjView.Propor := true;
              ZdjView.UpdateResizePars;
              ZOk := true;
            end;
        end;
       {WS}
    end;
    if (o.CH <> '') then
    begin
      if TableFind( 'ID', o.CH, BinTable ) then
      begin
        ObjViewFromBinBase( CharView, BinTable );
        ChOk := true;
      end;
    end;
//    Application.ProcessMessages; wylaczenie zapobiega wywalaniu sie jak na liscie
      //ta procedura kasowala "o"
    s := o.t;
    if (o.t <> '') and TableFind( 'TYP_ID', o.t, TypTable ) then
    begin
      if not ZOk then
      begin
        if TableFind( 'ID',
                      TypTable.FieldByName('ZDJECIE').AsString,
                      BinTable ) then
        begin
          ObjViewFromBinBase( ZdjView, BinTable );
          ZOk := true;
        end
         {WS cZY TO NMA ZOSTAC ?? 051216}
         else
          begin
           if FileExists(fprod.SciezkaDoBaz + o.zdj) then
              begin
                ZdjView.LoadFromFile(fprod.SciezkaDoBaz + o.zdj );
                ZOk := true;
              end;
          end;
         {WS}
      end;
      if not ChOk then
      begin
        if TableFind( 'ID',
                      TypTable.FieldByName('CHAR').AsString,
                      BinTable ) then
        begin
          ObjViewFromBinBase( CharView, BinTable );
          ChOk := true;
        end;
      end;
    end;
//    Application.ProcessMessages;
  end;
  if not ZOk then
    ZdjView.Clear;
  if not ChOk then
  begin
    CharView.Clear;
    //if FWCharForm = NIL then
    //  CreateWCharForm
    //else
    //  FWCharForm.Clear;
    //FWCharForm.Add( getQueryForm.Baza );
    ObszCharInit;
    DiagramObsz.Visible := true;
  end
  else
  begin
    DiagramObsz.Visible := false;
  end;
  FPicUpdated := true;

end;
{-----------------------------------------------------------------------------}

procedure TStructForm.FormCreate(Sender: TObject);
begin
  AutomatPage := true;
  FgotoBookmark := '';
  FCzyWysw := False;
  if PrzeglDokowane then
  begin
    WyswButton.Visible := false;
  end;
  if not FIconTypeActivated then
    IconType := pitLarge;
  SetInside;
  SetLang;    //CZy to zostaje ??
  {
  ProdId}
end;
{-----------------------------------------------------------------------------}

procedure TStructForm.FormResize(Sender: TObject);
begin
//  SetInside;
end;
{-----------------------------------------------------------------------------}

procedure TStructForm.setProd( pr: TProducent );
var
  FName   : TFileName;
  ii      : IBaseInfo;
  bi      : TPumpsBaseInfo;
  s       : string;
  OLSet   : Boolean;
begin
  BeginWaitCur;
  try
    FName := pr.S_Nazwa;
    FProd := pr;
    Path := pr.SciezkaDoBaz;
    ProdId := pr.Ident;
    {
    GetOutLineStruct( FName, OutLine1 );
    }
    ii := pr.InfoBaz['PUMPS'];
    bi := NIL;
    OLSet := false;
    if ii is TPumpsBaseInfo then
    begin
      bi := TPumpsBaseInfo(ii);
      CleareTreeView;
      TreeView.font.pitch := fpFixed;
      TreeView.Items.BeginUpdate;
      try
        if Root = 'STRUCTURE' then
          bi.AddSubTreeV( TreeView, NIL, Root, 1 )  //czyta drzewo z TBS
        else
          bi.AddSubTreeV( TreeView, NIL, Root, 0 );
      finally
        TreeView.Items.EndUpdate;
        TTlumacz.DajObiekt.Tlumacz(TreeView);
      end;
      ObszInit(bi.tbsf);
      OLSet := true;
    end;
    if not OLSet then
    begin
      //pr.OutLineSet( OutLine1, 'PUMPS' );
      EXIT;
    end;
    TypTable.Close;
    BinTable.Close;
    if bi <> NIL then
    begin
      s := bi.GetBaseName('T');
      if (s <> '') and FileExists(s) then
      begin
        with TypTable do
        begin
          DatabaseName := ExtractFileDir(s);
          TableName := ExtractFileName(s);
          //TableName := s;
          Open;
          IndexName := 'TYP_ID';
        end;
        s := bi.GetBaseName('B');
        if (s <> '') and FileExists(s) then with BinTable do
        begin
          DatabaseName := ExtractFileDir(s);
          TableName := ExtractFileName(s);
          Open;
          IndexName := 'ID';
        end;
      end;
    end;
    with TreeView do
      if (Items.Count > 0) and (Items[0].Data <> NIL)
         and (TPumpOLInfo(Items[0].Data).FldName = '_ROOT_') then
        Items[0].Expand(False);
    ProducentLab.Caption := pr.PelnaNazwa;
    ChangePos;
  finally
    EndWaitCur;
  end;
end;
{-----------------------------------------------------------------------------}

procedure TStructForm.Outline1DblClick(Sender: TObject);
begin
  //with Outline1 do
  //begin
  //  if not Items[SelectedItem].HasItems then
  //    if WyswButton.Enabled then
  //      WyswButton.Click;
  //end;
  if not SelectedNode.HasChildren then
    if WyswButton.Enabled then
      WyswButton.Click;
end;

procedure TStructForm.Outline1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ChangePos;
end;

procedure TStructForm.Outline1Click(Sender: TObject);
begin
  ChangePos;
end;

procedure TStructForm.FormShow(Sender: TObject);
begin
//  ChangePos;
  TTlumacz.dajObiekt.Tlumacz(self);
end;

procedure TStructForm.FormDestroy(Sender: TObject);
begin
  //ClearStrings(OutLine1.Lines)
  CleareTreeView;
end;

procedure TStructForm.ChangePos;
begin
  // zabezpiczenie gdy nie ma producenta praeniesione z 442 czy to wlaczyc ??
  if not Assigned(Producent) then
    EXIT;
  BeginWaitCur;
  try
    try
      WyswButton.Enabled := (TreeView.Items.Count=0)
                            or (SelectedNode <> NIL)
                               and (SelectedNode.Data <> NIL)
                               and TPumpOLInfo(SelectedNode.Data).Filtr;
      if AutomatPage and ((Producent.Ident = 'USER') or (SelectedNode <> NIL)) then
        begin
          if (Producent.Ident <> 'USER') and (SelectedNode.HasChildren) then
            begin
              PageControl.ActivePage := RysSheet;    //nie wywoluje ChangePage
              WyswPrzegl;                            //przegladanie tabeli pomp
              mnuDiagPokazCharak.Enabled := False;
            end
          else
            begin  //wejscie do przegladania listy
              PageControl.ActivePage := ListSheet;   //nie wywoluje ChangePage
              if not FListDocked then
                begin
                  DockListForm;
                  WyswPrzegl;
                end
              else
                WyswPrzegl;
              getQueryForm.Show;  //ustawia index zakladki
              mnuDiagPokazCharak.Enabled := True;
            end;
        end
      else
        begin //pierwsze wejscie w przegladanie
          getQueryForm.Producent := Producent;
          if PageControl.ActivePage = ListSheet then
            WyswPrzegl;
        end;
      //if FQueryForm <> NIL then
      //begin
        //WyswPrzegl;
      //end;
    except
      WyswButton.Enabled := false;
    end;
    FPicUpdated := False;
    UpdatePict;
  finally
    EndWaitCur;
  end;
end;

//procedure TStructForm.ChangePos;
//begin
//  try
//    WyswButton.Enabled := (Outline1.Lines.Count=0)
//                          or (SelectedNode <> NIL)
//                             and (SelectedNode.Data <> NIL)
//                             and TPumpOLInfo(SelectedNode.Data).Filtr;
//    if AutomatPage and ((Producent.Ident = 'USER') or (SelectedNode <> NIL)) then
//      if (Producent.Ident <> 'USER')
//         and (SelectedNode.HasItems) then
//      begin
//        PageControl.ActivePage := RysSheet;
//        WyswPrzegl;
//      end
//      else
//      begin
//        PageControl.ActivePage := ListSheet;
//        if not FListDocked then
//        begin
//          DockListForm;
//          WyswPrzegl;
//        end
//        else
//          WyswPrzegl;
//        getQueryForm.Show;
//      end;
//    //if FQueryForm <> NIL then
//    //begin
//      //WyswPrzegl;
//    //end;
//  except
//    WyswButton.Enabled := false;
//  end;
//  FPicUpdated := False;
//  UpdatePict;
//end;

function TStructForm.GetSelectedNode: TTreeNode;
begin
  //with Outline1 do
  //  result := Items[SelectedItem];
  Result := TreeView.Selected;
end;

procedure TStructForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FQueryForm then
    begin
      FQueryForm := NIL;
      FListDocked := false;
    end
    else if AComponent = ListSheet then
    begin
      ListSheet := NIL;
      FListDocked := false;     //?? to sano co na gorze
    end
  end;
  inherited Notification( AComponent, Operation );
end;

procedure TStructForm.DockListForm;
begin
  //GetQueryForm.FormStyle := fsNormal;
  //GetQueryForm.ManualDock( ListPan, NIL, alClient );
  if self = NIL then
    EXIT;
  if FListDocked then
    EXIT;
  GetQueryForm.ManualDock( PageControl, NIL, alClient );
  ListSheet := PageControl.Pages[1];
  FListDocked := true;
end;

procedure TStructForm.PageControlChange(Sender: TObject);
begin
  //Dlaczego jest wywolywana ta procedura przy zamykaniu?? 051220
  //W 442 nie byla wywolywana
  if PageControl.ActivePage = ListSheet then //zakladka listy pomp
    begin
      if not FListDocked then
        DockListForm;
      WyswPrzegl;
      try
        getQueryForm.Show;
      except
      end;
    end
  else
    begin
      if PageControl.ActivePage = RysSheet then  // zakladka ze zdjeciem
        begin
          UpdatePict;
        end;
    end;
end;

procedure TStructForm.ListPanUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
  if (Client = FQueryForm) then
  begin
    Allow := false;
    FListDocked := false;
    //FQueryForm.FormStyle := fsMDIChild;
  end;
end;

procedure TStructForm.ListPanGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  if DockClient = FQueryForm then
  begin
    CanDock := true;
    inc(InfluenceRect.Left, 10);
    inc(InfluenceRect.Top, 10);
    dec(InfluenceRect.Right, 10);
    dec(InfluenceRect.Bottom, 10);
  end;
end;

procedure TStructForm.ListPanDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := (Source.Control = FQueryForm);
end;

procedure TStructForm.ListPanDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  //if Source.Control is TForm then
    //TForm(Source.Control).FormStyle := fsNormal;
end;

procedure TStructForm.UndockListForm;
begin
  if FListDocked then
  begin
    FQueryForm.ManualFloat( FQueryForm.ClientRect );
    FListDocked := false;
    ListSheet := NIL;
  end;
end;

procedure TStructForm.CreateWCharForm;
begin
//  FWCharForm := TWieloCharForm.Create(self);
//  FWCharForm.FormStyle := fsNormal;
//  FWCharForm.Hide;
//  FWCharForm.BorderStyle := bsNone;
//  FWCharForm.Caption := '';
//  FWCharForm.Parent  := CharView;
//  FWCharForm.Align   := alClient;
end;

procedure TStructForm.ObszAddInternal( const AId :string; AColor :TColor;
  const ADescr :string;
  var AObszArray: TObszCharRecArray; var ACnt: Integer);
var
  i       :Integer;
begin
  if Length( AObszArray ) <= ACnt then
  begin
    SetLength(AObszArray, ACnt+10);
    for i := ACnt to Length(AObszArray)-1 do with AObszArray[ACnt] do
    begin
      CharList := NIL;
      DiagFun := NIL;
    end;
  end;
  AObszArray[ACnt].Id := AId;
  AObszArray[ACnt].Color := AColor;
  AObszArray[ACnt].Descr := ADescr;
  inc(ACnt);
end;

procedure TStructForm.ObszAdd( const AId :string; AColor :TColor;
                               const ADescr :string );
begin
  ObszAddInternal( AId, AColor, ADescr, FObszArray, FObszCnt );
end;

procedure TStructForm.ObszTmpAdd;
var
  Drw     :TObszWCharDiagFun;
begin
  ObszAddInternal( '', 0, '', FObszTmpArray, FObszTmpCnt );
  with FObszTmpArray[FObszTmpCnt-1] do
  begin
    DiagFun := TDiagFunction.Create(self);
    DiagFun.Diagram := DiagramObsz;
    //DiagFun.Color := TPumpOLInfo(OLNode.Data).CharColor;
    DiagFun.FunScale := DF1;
    Drw := TObszWCharDiagFun.Create(self);
    Drw.DrawInterior := not mnuDiagTylkoObwodki.Checked;
    Drw.DrawBorder := mnuDiagTylkoObwodki.Checked;
    DiagFun.Drawer := Drw;
    CharList := TWCharList.Create;
  end;
end;

procedure TStructForm.ObszInitData(ind: Integer);
var
  Drw     :TObszWCharDiagFun;
begin
  with FObszArray[ind] do
  begin
    DiagFun := TDiagFunction.Create(self);
    DiagFun.Diagram := DiagramObsz;
    DiagFun.Color := Color;
    DiagFun.FunScale := DF1;
    Drw := TObszWCharDiagFun.Create(self);
    DiagFun.Drawer := Drw;
    Drw.DrawInterior := not mnuDiagTylkoObwodki.Checked;
    Drw.DrawBorder := mnuDiagTylkoObwodki.Checked;
    Drw.BorderColor := Drw.Color;
    CharList := TWCharList.Create;
  end;
end;

procedure TStructForm.ObszClear;
var
  i       :Integer;
begin
  //for i := 0 to FObszCnt-1 do with FObszArray[i] do
  //begin
  //  DiagFun.Drawer.Free;
  //  DiagFun.Free;
  //  CharList.Free;
  //end;
  FObszCnt := 0;
end;
function TStructForm.GetCharColor(ol: TTreeNode): TColor;
var
  o      :TPumpOLInfo;
begin
  if ol = NIL then
  begin
    Result := clBlack;
    EXIT;
  end;
  o := ol.Data;
  if (o = NIL) or (o.CharColor < 0) then
    Result := GetCharColor(ol.Parent)
  else
    Result := o.CharColor;
end;

procedure TStructForm.ObszInit(ini :TCustomIniFile);
var
  SL      :TStringList;
  i       :Integer;
  s       :string;
  id      :string;
  Clr     :TColor;
  Dscr    :string;
begin
  ObszClear;
  SL := TStringList.Create;
  try
    ini.ReadSection( 'OBSZARY', SL );
    // i = 0 : Field=<nazwa pola>
    for i := 0 to SL.Count-1 do
    begin
      id := SL[i];
      s  := ini.ReadString( 'OBSZARY', id, '' );
      if CompareText( 'Field', Id ) = 0 then
        FObszFldName := s
      else
      begin
        Clr  := StrParseInt( s, 'COLOR', clBlack );   // Kolor
        Dscr := StrParseStr( s, 'DESCR', '' );        // Opis
        ObszAdd( id, Clr, Dscr );
      end;
    end;
  finally
    SL.Free;
  end;
end;

procedure TStructForm.ObszCharClear;
var
  i       :Integer;
begin
  for i := 0 to Length(FObszArray)-1 do with FObszArray[i] do
  begin
    if DiagFun <> NIL then
    begin
      DiagFun.Drawer.Free;
      DiagFun.Free;
      DiagFun := NIL;
    end;
    CharList.Free;
    CharList := NIL;
  end;
end;

procedure TStructForm.ObszTmpCharClear;
var
  i       :Integer;
begin
  for i := 0 to Length(FObszTmpArray)-1 do with FObszTmpArray[i] do
  begin
    if DiagFun <> NIL then
    begin
      DiagFun.Drawer.Free;
      DiagFun.Free;
      DiagFun := NIL;
    end;
    CharList.Free;
    CharList := NIL;
  end;
  FObszTmpCnt := 0;
end;
var
  csATId :string;
  csTTId :string;
function TStructForm.FilterInternal(DB: TDBPompy;
         OLNode: TTreeNode) :Boolean;
var
  o      :TPumpOLInfo;
begin
  Result := true;
  if OLNode = NIL then
  begin
    Result := false;
    EXIT;
  end;
  o := OLNode.Data;
  if (o = NIL) or (not o.Filtr) then
    Result := false;
  //lev := OLNode.Level;
  if Result then
    Result := DB.Field['A.ID1'].AsString <> '';
  while (Result) and (OLNode <> NIL) and (OLNode.Level >= 0) do
  begin
    o := OLNode.Data;
    if (o = NIL) then
    begin
      Result := false;
      BREAK;
    end;
    if not o.Filtr then
      BREAK;
    if pos( '.', o.FldName ) = 0 then
    begin
      if (o.FldName <> '_ROOT_') and (o.Value <> DB.A.FieldValues[ o.FldName ]) then
        Result := false;
    end
    else
    begin
      if StrInSet( o.FldName, '/T.GRUPA/T.KL_ZAST/T.KOSTR/' ) then
      begin
        if  DB.T.FieldByName('TYP_ID').AsString <> DB.A.FieldByName('TYP_ID').AsString then
          DB.T.Locate('TYP_ID', DB.A['TYP_ID'], [] );
        //csATId := DB.T.FieldByName('TYP_ID').AsString;
        Result := StrInSet( o.Value, DB.Field[o.FldName].AsString );
      end;
    end;
    OLNode := OLNode.Parent;
  end;
end;

var
  GociI :Integer;
  GociNazwa :string;

procedure TStructForm.ObszCharInit;
var
  //svBmk   :TBookmarkStr;
  OP      :TPompa;
  DB      :TDBPompy;
  i       :Integer;
  Tx      : string;
begin
  ObszCharClear;
  ObszTmpCharClear;
  for i := 0 to FObszCnt-1 do
  begin
    ObszInitData(i);
  end;
  if ChList <> NIL then
    ChList.Clear;
  if Ch1List <> NIL then
    Ch1List.Clear;
  FLastMouseObsz := -1;
  FLastCharInfo  := NIL;
  DiagramObsz.Hint := '';
  DiagramObsz.MaxXR := 0.01;
  DF1.MaxYR         := 0.01;
  DB := getQueryForm.Baza;
  DB.A.Filtered := false;
  //svBmk := DB.A.Bookmark;
  try
    DB.Last;
    while not DB.BOF do
    begin
      if MayDraw( DB ) then
      begin
        OP := CreatePump( NIL, DB );
        if OP <> NIL then
        begin
          OP.AddRef;
          try
            ObszCharAddP(OP);
          finally
            OP.Release;
          end;
        end;
      end;
      DB.Prior;
    end;
  finally
    //DB.A.Bookmark := svBmk;
    DB.A.Filtered := true;
  end;
  for i := 0 to FObszCnt - 1 do with FObszArray[i] do
    if DiagFun <> NIL then
      TObszWCharDiagFun(DiagFun.Drawer).CharList := CharList;
  for i := 0 to FObszTmpCnt - 1 do with FObszTmpArray[i] do
  begin
    GociI := i;
    GociNazwa := Descr;
    if DiagFun <> NIL then 
      TObszWCharDiagFun(DiagFun.Drawer).CharList := CharList;
  end;
  //ObszFun.CharList := List;
  //DF1.Drawer := ObszFun;
end;

procedure TStructForm.ObszCharAddP(P: TPompa);
var
  i, j    :Integer;
  Accept  :Boolean;
  acd     :TPompCharData;
  Rozszerzyc :Boolean;
  ParNom  :Double;
  TmpObsz :Boolean;
  
function AddCD( cd :TPompCharData) :Boolean;
  var
    j       :Integer;
  begin
    cd.Pompa := P;
    Result := ChList.AddInfo(cd, DiagramObsz);
    if Result then
    begin
      with ChList.Info[ChList.Count-1] do
      begin
        //HFun.Diagram := DiagramObsz;
        DF1.MaxYR := Max( DF1.MaxYR, HFun.MaxYR );
        HFun.FunScale := DF1;
        if Char.CharQMax > DiagramObsz.MaxXR then
          DiagramObsz.CountMaxXRAuto(Char.CharQMax);
        HFun.IsOn := (not Accept) and (not Rozszerzyc)
                     and (not (P is TPompaReg));
        HFun.Color := GetRecCharColor( P.DB );
        HFun.LineWidth := DF1.LineWidth;
      end;
      with ChList do
        if Info[Count-1].HFun.IsOn then
        begin
          Ch1List.Add(Info[Count-1]);
          Info[Count-1].Color := Info[Count-1].HFun.Color;
        end;
      if Accept then
      begin
        if FObszArray[i].CharList = NIL then
          ObszInitData(i);
        FObszArray[i].CharList.AddInfo(cd, DiagramObsz);
        with FObszArray[i].CharList do with Info[Count-1] do
        begin
          //HFun.Diagram := DiagramObsz;
          HFun.FunScale := DF1;
          with mnuDiagPokazCharak do
            HFun.IsOn := Checked and Enabled;
          HFun.LineWidth := DF1.LineWidth;
        end;
      end;
      if Rozszerzyc then
      begin
        ObszTmpAdd;
        with FObszTmpArray[FObszTmpCnt-1] do
        begin
          DiagFun.Color := GetRecCharColor( P.DB );
          TObszWCharDiagFun(DiagFun.Drawer).BorderColor := DiagFun.Color;
          Descr := P.DB.Field['A.NAZWA'].AsString;
          CharList.AddInfo(cd, DiagramObsz);
          BM := TBookmarkStr(P.DB.A.Bookmark);
        end;
        with P.DB.A do
        begin
          if FindField('POLE_TYP').AsString = 'D' then
          begin
            ParNom := cd.Srednica;
            cd.Srednica := ParNom * FindField('POLE_Min').AsFloat;
            FObszTmpArray[FObszTmpCnt-1].CharList.AddInfo(cd, DiagramObsz);
            cd.Srednica := ParNom * FindField('POLE_Max').AsFloat;
            FObszTmpArray[FObszTmpCnt-1].CharList.AddInfo(cd, DiagramObsz);
          end
          else if FindField('POLE_TYP').AsString = 'N' then
          begin
            ParNom := cd.Obroty;
            cd.Obroty := ParNom * FindField('POLE_Min').AsFloat;
            FObszTmpArray[FObszTmpCnt-1].CharList.AddInfo(cd, DiagramObsz);
            cd.Obroty := ParNom * FindField('POLE_Max').AsFloat;
            FObszTmpArray[FObszTmpCnt-1].CharList.AddInfo(cd, DiagramObsz);
          end;
        end;
        for j := 0 to FObszTmpArray[FObszTmpCnt-1].CharList.Count-1 do
          with FObszTmpArray[FObszTmpCnt-1].CharList.Info[j] do
          begin
            //HFun.Diagram := DiagramObsz;
            HFun.FunScale := DF1;
            HFun.IsOn := false;
          end;
      end
      else if TmpObsz and (not Accept) then
      begin
        FObszTmpArray[FObszTmpCnt-1].CharList.AddInfo(cd, DiagramObsz);
      end;
    end;
  end;
begin
  // Znajdz obszar z listy
  i := 0;
  Accept := false;
  while i < FObszCnt do
  begin
    //Accept := FilterInternal( P.DB, FObszArray[i].OLNode );
    Accept := P.DB.A.FieldByName( FObszFldName ).AsString = FObszArray[i].Id;
    if Accept then
      BREAK
    else
      inc(i);
  end;
  if ChList = NIL then
    ChList := TWCharList.Create;
  if Ch1List = NIL then
  begin
    Ch1List := TWCharList.Create;
    Ch1List.ShldFreeItems := False;
  end;
  Rozszerzyc := (not Accept)
                and (P.DB.A.FindField('POLE_TYP') <> NIL)
                and (P.DB.A.FindField('POLE_TYP').AsString <> '');
  acd := P.CreateCharDataDB(NIL); //(self);
  if acd <> NIL then
  try
    TmpObsz := false;
    if acd is TRegCharData then
    begin
      if (not Accept) and (TRegCharData(acd).LicznikChar > 1) then
      begin
        TmpObsz := true;
        ObszTmpAdd;
        with FObszTmpArray[FObszTmpCnt-1] do
        begin
          DiagFun.Color := GetRecCharColor( P.DB );
          TObszWCharDiagFun(DiagFun.Drawer).BorderColor := DiagFun.Color;
          Descr := P.Nazwa;
          BM := TBookmarkStr(P.DB.A.Bookmark);
        end;
      end;
      for j := 0 to TRegCharData(acd).LicznikChar-1 do
      begin
        AddCD( TRegCharData(acd).CharList[j] );
      end;
      if TmpObsz then
        for j := 0 to FObszTmpArray[FObszTmpCnt-1].CharList.Count-1 do
          with FObszTmpArray[FObszTmpCnt-1].CharList.Info[j] do
          begin
            //HFun.Diagram := DiagramObsz;
            HFun.FunScale := DF1;
            HFun.IsOn := false;
          end;
    end
    else
      AddCD(acd);
  finally
    acd.Free;
  end;    // if Accept
end;
function TStructForm.GetRecCharColor( DB: TDBPompy): TColor;
begin
  Result := GRChColor( SelectedNode, DB );
end;
function TStructForm.GRChColor(root: TTreeNode; DB: TDBPompy): TColor;
var
  ind    :Integer;
  chld   :TTreeNode;
begin
  result := GetCharColor(root);
  for ind := 0 to root.Count-1 do
  begin
    chld := root.Item[ind];
    if FilterInternal(DB, chld) then
    begin
      result := GRChColor(chld,DB);
      BREAK;
    end;
  end;
end;
function TStructForm.MayDraw(DB: TDBPompy): Boolean;
var
  NotStoped     :Boolean;
begin
  Result := FilterInternal(DB, SelectedNode);
  if Result then
  begin
    NotStoped := MayDrawRec( SelectedNode, DB);
    Result := Result and NotStoped;
  end;
end;
function TStructForm.MayDrawRec(nod: TTreeNode; DB: TDBPompy): Boolean;
var
  ind    :Integer;
  chld   :TTreeNode;
  o      :TPumpOLInfo;
begin
  Result := true;
  for ind := 0 to nod.Count-1 do
  begin
    chld := nod.Item[ind];
    if FilterInternal(DB, chld) then
    begin
      o := chld.Data;
      if o.StopChldOb then
        Result := false
      else
        Result := MayDrawRec(chld, DB);
      BREAK;
    end;
  end;
end;

procedure TStructForm.CleareTreeView;
  
procedure ClrN(N :TTreeNode);
  var
    i       :Integer;
  begin
    TObject(N.Data).Free;
    N.Data := NIL;
    for i := 0 to N.Count-1 do
    begin
      ClrN(N.Item[i]);
      Application.ProcessMessages;
    end;
  end;
var
  N       :TTreeNode;
begin
  N := TreeView.TopItem;
  while N <> NIL do
  begin
    ClrN(N);
    N := N.getNextSibling;
  end;
  TreeView.Items.Clear;
end;
{
var
  i       :Integer;
begin
  BeginWaitCur;
  Application.ProcessMessages;
  try
    for i := 0 to TreeView.Items.Count-1 do
    begin
      TObject(TreeView.Items[i].Data).Free;
      TreeView.Items[i].Data := NIL;
      Application.ProcessMessages;
    end;
    TreeView.Items.Clear;
  finally
    EndWaitCur;
  end;
end;
}
function TStructForm.GetIconType: TPmpIconType;
begin
  Result := PompIconType;
end;

procedure TStructForm.SetIconType(const Value: TPmpIconType);
begin
  PompIconType := Value;
  case Value of
    pitNone :
      begin
      TreeView.Images := NIL;
      TreeView.Indent := 19;
      tbtnRodzajIkon.MenuItem := mnuBezIkon;
      end;
    pitSmall:
      begin
      TreeView.Images := PmpSmallImgLst;
      TreeView.Indent := 19;
      tbtnRodzajIkon.MenuItem := mnuMaleIkony;
      end;
    pitLarge:
      begin
      TreeView.Images := PmpLargeImgLst;
      tbtnRodzajIkon.MenuItem := mnuDuzeIkony;
      end;
  end;
  FIconTypeActivated := true;
end;

procedure TStructForm.mnuDuzeIkonyClick(Sender: TObject);
begin
  IconType := pitLarge;
end;

procedure TStructForm.mnuMaleIkonyClick(Sender: TObject);
begin
  IconType := pitSmall;
end;

procedure TStructForm.mnuBezIkonClick(Sender: TObject);
begin
  IconType := pitNone;
end;

procedure TStructForm.tbtnRodzajIkonClick(Sender: TObject);
var
  P       :TPoint;
begin
  P := Point(0,tbtnRodzajIkon.Height);
  P := tbtnRodzajIkon.ClientToScreen(P);
  pmnuDropIconType.Popup( P.x, P.y );
end;

procedure TStructForm.DiagramObszMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  rx, ry  :Double;
  res     :Boolean;
  i       :Integer;
  svBM    :TBookmarkStr;
  BM      :TBookmarkStr;
  ds      :TDataSet;
  A       :array of string;
  CharInfo :TWCharInfo;
  found   :Boolean;
begin
  if Button = mbLeft then
  begin
    BeginWaitCur;
    try
      CharInfo := NIL;
      if CharPojedyncze then
        CharInfo := GetObszCharAtXY( X, Y );
      if CharInfo = NIL then
        CharInfo := GetChar1AtXY(X, Y);
      if CharInfo = NIL then
        i := GetObszAtXY( X, Y )
      else
        i := -1;
      res := (i > -1) or (CharInfo<> NIL);
      if res and (PompPrzeglForm <> NIL) then
      begin
        ds := PompPrzeglForm.Baza.A;
        ds.DisableControls;
        try
          svBM := TBookmarkStr(ds.Bookmark);
          if CharInfo<> NIL then
          begin
            BM := CharInfo.BM;
            found := Length(BM) > 0;
            ds.Bookmark := TBookmark(BM);
          end
          else if i < FObszCnt then
          begin
            found := ds.Locate( FObszFldName, Obszary[i].Id, [] );
            if found then
            begin
              BM := TBookmarkStr(ds.Bookmark);
            end;
          end
          else
          begin
            BM := Obszary[i].BM;
            found := Length(BM) > 0;
            ds.Bookmark := TBookmark(BM);
          end;
          if found then
          begin
            SetLength( A, 8 );
            for i := 1 to 8 do
              A[i-1] := ds.FieldByName(Format('ID%d', [i])).AsString;
            ds.Bookmark := TBookmark(svBM);
          end;
        finally
          ds.EnableControls;
        end;
        if found then
        begin
          //TreeView.FullCollapse;
          SelectPos( A );
          FgotoBookmark := BM;
          FCzyWysw := False;
          Timer1.Enabled := True;
          // ChangePos;
          //ds.Bookmark := BM;
          //PompPrzeglForm.gotoBookMark := BM;
        end;
      end;
    finally
      EndWaitCur;
    end;
  end;
end;

procedure TStructForm.SelectPos(const Ids: array of string);
var
  i       :Integer;
  N, Nx   :TTreeNode;
begin
  i := 0;
  Nx := TreeView.Items[0];
  if (Nx <> NIL) and (TPumpOLInfo(Nx.Data).FldName = '_ROOT_') then
    Nx := Nx.getFirstChild
  else if (Nx <> NIL) and (TPumpOLInfo(Nx.Data).FldName <> 'ID1') then
  begin
    N := SelectedNode;
    Nx := N;
    while (N <> NIL) and (TPumpOLInfo(Nx.Data).FldName <> 'ID1') do
    begin
      Nx := N;
      N := Nx.Parent;
    end;
  end;
  N     := NIL;
  while (i < Length(Ids)) and (Nx <> NIL) do
  begin
    while Nx <> NIL do
    begin
      if TPumpOLInfo(Nx.Data).Value = Ids[i] then
      begin
        N := Nx;
        Nx := Nx.getFirstChild;
        BREAK;
      end
      else
      begin
        Nx := Nx.getNextSibling;
      end;
    end;
    inc(i);
  end;
  if N <> NIL then
  begin
    N.Selected := True;
    ChangePos;
  end;
end;

procedure TStructForm.DiagramObszMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  CharInfo :TWCharInfo;
  iObsz    :Integer;
  MousMsg  :TWMMouse;
  CancHint :Boolean;
  sHint    :string;
  rx, ry   :Double;
begin
  CancHint := False;
  CharInfo := NIL;
  DF1.ScrToReal( X, Y, rx, ry );
  labQVal.Caption := FormatFloat( '0.00', m3hToU(rx) )+ CapQ;
  labHVal.Caption := FormatFloat( '0.00', ry )        + '[m]';
  if CharPojedyncze then
    CharInfo := GetObszCharAtXY(X, Y);
  if CharInfo = NIL then
    CharInfo := GetChar1AtXY(X, Y);
  if CharInfo = NIL then
    iObsz := GetObszAtXY(X, Y)
  else
    iObsz := -1;
  sHint := '';
  if CharInfo <> FLastCharInfo then
  begin
    Application.CancelHint;
    CancHint := True;
    if FLastCharInfo <> NIL then
    begin
      FLastCharInfo.HFun.Color := FLastCharInfo.Color;
      FLastCharInfo.HFun.LineWidth := DF1.LineWidth;
    end;
    if CharInfo <> NIL then
    begin
      CharInfo.HFun.Color := clRed;
      sHint := CharInfo.NazwaPompy;
      with CharInfo.HFun.LineWidth do
        DefaultVal := DefaultVal*2;
    end;
    FLastCharInfo := CharInfo;
  end;
  if iObsz <> FLastMouseObsz then
  begin
    Application.CancelHint;
    CancHint := True;
    if FLastMouseObsz > -1 then with ObszDrw(FLastMouseObsz) do
    begin
      DrawBorder := mnuDiagTylkoObwodki.Checked;
      BorderColor := Color;
      LineWidth.DefaultVal := 0.5;
    end;
    if iObsz > -1 then with ObszDrw(iObsz) do
    begin
      DrawBorder := True;
      BorderColor := clBlack;
      LineWidth.DefaultVal := 1;
      DiagramObsz.Cursor := crHandPoint;
      sHint := Obszary[iObsz].Descr;
    end
    else
    begin
      DiagramObsz.Cursor := crDefault;
    end;
    FLastMouseObsz := iObsz;
    DiagramObsz.Invalidate;
  end;
  if CancHint then
    DiagramObsz.Hint := sHint;
end;
function TStructForm.GetObszAtXY(X, Y: Integer): Integer;
var
  rx, ry  :Double;
  RRct    :TRealRectRec;
  res     :Boolean;
  i       :Integer;
begin
  DF1.ScrToReal( X+2, Y+2, rx, ry );
  RRct.Bottom := ry;
  RRct.Right  := rx;
  DF1.ScrToReal( X-2, Y-2, rx, ry );
  RRct.Top := ry;
  RRct.Left  := rx;
  DF1.ScrToReal( X, Y, rx, ry );
  res := False;
  // szukaj w obszarach tymczasowych
  i := FObszTmpCnt-1;
  while not res and (i >= 0) do
  begin
    res := TObszWCharDiagFun(FObszTmpArray[i].DiagFun.Drawer).CheckHit(rx, ry, RRct);
    if not res then
      dec(i)
  end;
  if res then
  begin
    Result := i + FObszCnt;
  end
  else
  begin
    // szukaj w obszarach stalych
    i := FObszCnt-1;
    while not res and (i >= 0) do
    begin
      res := false;
      if Assigned(FObszArray[i].DiagFun)
              and Assigned(FObszArray[i].DiagFun.Drawer) then
        res := TObszWCharDiagFun(FObszArray[i].DiagFun.Drawer).CheckHit(rx, ry,RRct);
      if not res then
        dec(i)
    end;
    if res then
      Result := i
    else
      Result := -1;
  end;
end;
function TStructForm.GetObszCharAtXY(X, Y: Integer): TWCharInfo;
var
  rx, ry  :Double;
  RRct    :TRealRectRec;
  res     :Boolean;
  i       :Integer;
begin
  DF1.ScrToReal( X+2, Y+2, rx, ry );
  RRct.Bottom := ry;
  RRct.Right  := rx;
  DF1.ScrToReal( X-2, Y-2, rx, ry );
  RRct.Top := ry;
  RRct.Left  := rx;
  DF1.ScrToReal( X, Y, rx, ry );
  Result := NIL;
  i := FObszCnt;
  while (Result = NIL) and (i > 0) do
  begin
    dec(i);
    Result := TObszWCharDiagFun(FObszArray[i].DiagFun.Drawer).FindCharXY(rx, ry,RRct);
  end;
end;

procedure TStructForm.mnuDiagTylkoObwodkiClick(Sender: TObject);
var
  i       :Integer;
begin
  with mnuDiagTylkoObwodki do
    Checked := not Checked;
  if mnuDiagTylkoObwodki.Checked then
    for i := 0 to ObszaryCount-1 do with ObszDrw(i) do
    begin
      DrawBorder := True;
      DrawInterior := False;
      BorderColor := Color;
    end
  else
    for i := 0 to ObszaryCount-1 do with ObszDrw(i) do
    begin
      DrawBorder := False;
      DrawInterior := True;
    end;
  DiagramObsz.Invalidate;
end;
function TStructForm.ObszDrw(I: Integer): TObszWCharDiagFun;
begin
  Result := Obszary[I].DiagFun.Drawer as TObszWCharDiagFun;
end;

procedure TStructForm.mnuDiagPokazCharakClick(Sender: TObject);
var
  i ,j    :Integer;
begin
  with mnuDiagPokazCharak do
  begin
    Checked := not Checked;
    for i := 0 to FObszCnt-1 do
    begin
      for j := 0 to ObszDrw(i).CharList.Count-1 do
        ObszDrw(i).CharList.Info[j].HFun.IsOn := Checked;
    end;
  end;
end;
function TStructForm.GetObszary(i: Integer): TObszCharRec;
begin
  if i >= FObszCnt then
    Result := FObszTmpArray[i - FObszCnt]
  else
    Result := FObszArray[i];
end;
function TStructForm.GetObszaryCount: Integer;
begin
  Result := FObszCnt + FObszTmpCnt;
end;
function TStructForm.GetCharPojedyncze: Boolean;
begin
  with mnuDiagPokazCharak do
    Result := Checked and Enabled;
end;
function TStructForm.GetChar1AtXY(X, Y: Integer): TWCharInfo;
var
  i      :Integer;
  R      :TRealRectRec;
  rx, ry :Double;
begin
  DF1.ScrToReal( X+2, Y+2, rx, ry );
  R.Bottom := ry;
  R.Right  := rx;
  DF1.ScrToReal( X-2, Y-2, rx, ry );
  R.Top := ry;
  R.Left  := rx;
  Result := NIL;
  Result := NIL;
  if Ch1List = NIL then
    EXIT;

  i := Ch1List.Count;

  while (Result = NIL) and (i > 0) do

  begin

    dec(i);

    if Ch1List.Info[i].CheckHit(R) then

      Result := Ch1List.Info[i]

  end;

end;


procedure TStructForm.CharViewResize(Sender: TObject);

begin

 DiagramObsz.XJednostki := 1/UTom3h(1);
 DescrQJedn.Text := CapQ;
end;

procedure TStructForm.Timer1Timer(Sender: TObject);
var
  q :TDataSet;
begin
  // a kind of magic - ale z grubsza dzia³a
  // protezka ktora ma na celu odswiezenie grida z polami pbliczanymi
  if (PageControl.ActivePage = ListSheet) and (not FCzyWysw) then
    begin
      WyswPrzegl;
      FCzyWysw := True;
      if FgotoBookmark = '' then
        Timer1.Enabled := false;
    end
  else if FgotoBookmark <> ''  then
  begin
    //PompPrzeglForm.Query.Bookmark := FgotoBookmark;
    q := PompPrzeglForm.Query;
    while (not q.Eof) and (q.Bookmark <> TBookmark(FgotoBookmark)) do
      PompPrzeglForm.Query.Next;
    FgotoBookmark := '';
    Timer1.Enabled := false;
  end;
end;

procedure TStructForm.FormActivate(Sender: TObject);
begin
  //WkpGlob_RysujRure := True; //2024.06.30 MS na razie
end;

end.



