unit PmpListU;

interface

uses
  SysUtils, Classes, Controls, Forms, graphics, comctrls, DB, DbTables,
  TbsClasses, WkpGlob, KR_DB, OPompa, PompySQL, Prod, GIFImage, JPeg;

type
  TPmpProc = procedure ( Pmp :TPompa ) of object;

  TPumpList = class (TList)
  public
    constructor Create;
    destructor  Destroy;                        override;
    procedure   Clear;                          override;
    procedure   AddPump( P :TPompa );           virtual;
    procedure   AddCopy( P :TPompa );           virtual;
    procedure   RemovePmp( pos :Integer );      virtual;
  private
    FAfterLoadPomp :TPmpProc;
    FListView      :TListView;
    FCtrlComponent :TComponent;
    FAutoSort: Boolean;
    function  GetPump( ind :Integer ): TPompa;
    procedure SetAutoSort(const Value: Boolean);
  protected
    procedure DoAfterLoadPomp( Pmp :TPompa );
    procedure Notification( AComponent: TComponent;
                            Operation: TOperation);    virtual;
    procedure SetListItem( Item: TListItem; Pmp :TPompa );  virtual;
    procedure SetListItemColumns( Item: TListItem; Pmp :TPompa );  virtual;
    procedure InitListViewColumns;                     virtual;
    procedure InitListViewItems;                       virtual;
    procedure ListViewData(Sender: TObject; Item: TListItem);
    procedure SetListView( lv :TListView );
  public
    procedure SaveToStream( s :TStream );
    procedure LoadFromStream( s :TStream );
    procedure SaveToFile( const FN :string );
    procedure LoadFromFile( const FN :string );
    function  BSearchWDobr( AValue :Double ) :Integer;

    property  Pumps[ ind :Integer ]: TPompa  read GetPump;
    property  AfterLoadPomp :TPmpProc read FAfterLoadPomp write FAfterLoadPomp;
    property  ListView :TListView read FListView write SetListView;
    property  AutoSort :Boolean read FAutoSort write SetAutoSort;
  end;

  TPmpDragObjectBase = class (TTbsDragObject)
  end;

  TPompaDragObject = class (TPmpDragObjectBase)
  private
    FPompa: TPompa;
    procedure SetPompa(const Value: TPompa);
  protected
    procedure ReleasePompa;
  public
    constructor Create( Pmp :TPompa; AStartCtrl :TControl );
    destructor Destroy;                 override;
    property Pompa :TPompa read FPompa write SetPompa;
  end;

var
  PmpLargeImgLst :TImageList;
  PmpSmallImgLst :TImageList;
  PmpImgListIndx :TStringList;

procedure SetPmpImgIndex( Pmp :TPompa );
function  GetPmpImgIndexBId( const ProdId, B_Id :string ) :Integer;
function  GetPmpImgIndexTId( const ProdId, T_Id :string ) :Integer;
function  GetPmpProdIconId( const ProdId :string ) :Integer;
{ws 22 listopada 2005}
procedure  LoadObrazek(var Pct : TPicture; plik :string);
{ws 22 listopada 2005}

implementation

type
  TPmpListCtrlComponent = class (TComponent)
  private
    FList :TPumpList;
  protected
    procedure Notification( AComponent: TComponent;
                            Operation: TOperation);   override;
  end;

{WS 22 listopada 2005}
procedure  LoadObrazek(var Pct : TPicture; plik :string);
var
   Pctj : TJPEGImage;
begin
 if not FileExists(plik) then exit;

 if AnsiUpperCase(ExtractFileExt (plik) )='.JPG' then
 begin
  Pctj := TJPEGImage.Create;
  Pctj.LoadFromFile(plik);
  Pct := TPicture.Create;
  Pct.Graphic := Pctj;
  Pctj.Free;
 end else if AnsiUpperCase(ExtractFileExt (plik))='.BMP' then
          begin
           Pct := TPicture.Create;
           Pct.Bitmap.LoadFromFile(Plik);
          end else if AnsiUpperCase(ExtractFileExt (plik))='.GIF' then
                   begin
                     Pct := TPicture.Create;
                     Pct.Graphic := TGIFImage.Create;
                     Pct.Graphic.LoadFromFile(plik);
                   end;
end;
{WS 22 listopada 2005}

function AddPmpImage( const ID :string; Pic :TPicture ): Integer;

var
  Def     :Boolean;
  PrName, T_Id, B_Id :string;
  pos     :Integer;
  bmp     :TBitmap;
  BkColor :TColor;

  procedure StrDraw( w, h :Integer);
  var
    fw, fh  :Double;
    bm      :TBitmap;
    x, y    :Integer;
  begin
    bmp.Width  := w;
    bmp.Height := h;
    fw := w / pic.Graphic.Width;
    fh := h / pic.Graphic.Height;

    bm := TBitmap.Create;
    try
      if fw <= fh then
      begin
        bm.Width  := round(fw * Pic.Graphic.Width);
        bm.Height := round(fw * Pic.Graphic.Height);
        x :=  0;
        y := (h - bm.Height) div 2;
      end
      else
      begin
        bm.Width  := round(fh * Pic.Graphic.Width);
        bm.Height := round(fh * Pic.Graphic.Height);
        y := 0;
        x := (w - bm.Width) div 2;
      end;
      bm.Canvas.StretchDraw( Rect( 0, 0, bm.Width-1, bm.Height-1),
                             pic.Graphic );
      BkColor := bm.Canvas.Pixels[0,0];
      with bmp.Canvas.Brush do
      begin
        Color := BkColor;
        Style := bsSolid;
      end;
      bmp.Canvas.FillRect( Rect(0,0, w, h) );
      bmp.Canvas.Draw( x, y, bm );
    finally
      bm.Free;
    end;
  end;

begin
  result := -1;
  if pic <> NIL then
  begin
    if Pic.Graphic is TIcon then
    begin
      PmpLargeImgLst.AddIcon( TIcon(Pic.Graphic) );
      PmpSmallImgLst.AddIcon( TIcon(Pic.Graphic) );
      result := PmpImgListIndx.Add( Id );
    end
    else
    begin
      bmp := TBitmap.Create;
      try
        StrDraw( PmpLargeImgLst.Width, PmpLargeImgLst.Height );
        PmpLargeImgLst.AddMasked( bmp, BkColor );
        StrDraw( PmpSmallImgLst.Width, PmpSmallImgLst.Height );
        PmpSmallImgLst.AddMasked( bmp, BkColor );
        result := PmpImgListIndx.Add( Id );
      finally
        bmp.Free;
      end;
    end;
  end;
end;

procedure SetPmpImgIndex( Pmp :TPompa );
  // Ustaw index obrazka w Pompie jesli odpowiedni obrazek jest na liscie
  // w przeciwnym wypadku wczytaj obrazek i ustaw index
var
  Def     :Boolean;
  id, PrName, T_Id, B_Id :string;
  pos     :Integer;
  pic     :TPicture;
  bmp     :TBitmap;
  BkColor :TColor;


begin
  Def := false;
  if Pmp = NIL then
    EXIT;
  if (Pmp.producent = NIL) or (Pmp.DB = NIL) then
    Def := true
  else if not Pmp.DB.tOK then
    Def := true;

  if not Def then
  begin
    PrName := Pmp.producent.Ident;
    B_Id := Pmp.DB.T.FieldByName('Zdjecie').AsString;
    Id := Format( '%s$%s', [PrName,B_Id] );
    pos := PmpImgListIndx.IndexOf( Id );
    if pos >= 0 then
    begin
      Pmp.ImageIndex := pos
    end
    else
    begin
      pic := Pmp.GetZdjecie;
      if pic <> NIL then
      try
        pos := AddPmpImage( Id, Pic );
        if pos >= 0 then
          Pmp.ImageIndex := pos
        else
          Def := true;
      finally
        pic.Free;
      end
      else
        Def := true;
    end;
  end;
  if Def then
    Pmp.ImageIndex := 0;
end;

function GetPmpZdj(B :TDataSet; const B_ID :string ): TPicture;
var
  cn     :string;
  strm   :TStream;
begin
  result := NIL;
  if B.Locate( 'ID', B_ID, [] ) then
  begin
    cn := B.FieldByName('CLASSNAME').AsString;
    if (cn = '.BMP') or (cn = '.JPG') or (cn = '.GIF') then
    begin
      result := TPicture.Create;
      strm := TBlobStream.Create( B.FieldByName('DATA') as TBlobField,
                                  bmRead );
      if cn = '.BMP' then
      begin
        result.Bitmap.LoadFromStream(strm);
      end
      else
      begin
        if cn = '.JPG' then
          result.Graphic := TJPEGImage.Create
        else if cn = '.GIF' then
          Result.Graphic := TGIFImage.Create;
        result.Graphic.LoadFromStream(strm);
      end;
    end;
  end;
end;

function  GetPmpImgIndexBId( const ProdId, B_Id :string ) :Integer;
var
  P       :TProducent;
  B       :TTable;
  TN      :string;
  bi      :TBaseInfo;
  Id      :string;
  Pct     :TPicture;
  {ws} Pctj : TGraphic;    {WS}

begin
  Id := Format( '%s$%s', [ProdId, B_Id] );
  Result := PmpImgListIndx.IndexOf( Id );;
  if Result > -1 then
    EXIT;
  P := Producenci.ProdByName(ProdId);
  if P = NIL then
    EXIT;
  bi := P.InfoBazT['PUMPS'];
  if bi = NIL then
    EXIT;
  B := bi.CreateTable('B',NIL);
  if B = NIL then
    EXIT;
  try
    B.Open;
    Pct := GetPmpZdj(B, B_Id);
    if Pct <> NIL then
    try
      Result := AddPmpImage( Id, Pct );
    finally
      Pct.Free;
    end
    {ws}
      else
       begin
         LoadObrazek(Pct,P.InfoBazT['PUMPS'].GetPath + B_Id);
         try
           Result := AddPmpImage( Id, Pct );
         finally
           Pct.Free;
         end;
       end;
    {ws}
  finally
    B.Free;
  end;
end;

function  GetPmpImgIndexTId( const ProdId, T_Id :string ) :Integer;
var
  P       :TProducent;
  T       :TTable;
  TN      :string;
  bi      :TBaseInfo;
begin
  Result := -1;
  P := Producenci.ProdByName(ProdId);
  if P = NIL then
    EXIT;
  bi := P.InfoBazT['PUMPS'];
  if bi = NIL then
    EXIT;
  T := bi.CreateTable('T',NIL);
  if T = NIL then
    EXIT;
  try
    T.Open;
    if T.Locate( 'TYP_ID', T_Id, [] ) then
      Result := GetPmpImgIndexBId( ProdId, T.FieldByName('Zdjecie').AsString );
  finally
    T.Free;
  end;
end;

function  GetPmpProdIconId( const ProdId :string ) :Integer;
var
  P       :TProducent;
  Id      :string;
begin
  Id := Format( '%s$_PROD_ICON_', [ProdId] );
  Result := PmpImgListIndx.IndexOf( Id );;
  if Result > -1 then
    EXIT;
  P := Producenci.ProdByName(ProdId);
  if P = NIL then
    EXIT;
  if P.Icon.Graphic = NIL then
    EXIT;
  Result := AddPmpImage( Id, P.Icon );
end;

procedure InitLists;
var
  FN      :string;
  Pic     :TPicture;

begin
  PmpLargeImgLst := TImageList.Create(Application);
  PmpLargeImgLst.Width  := 32;
  PmpLargeImgLst.Height := 32;

  PmpSmallImgLst := TImageList.Create(Application);
  PmpSmallImgLst.Width  := 16;
  PmpSmallImgLst.Height := 16;

  PmpImgListIndx := TStringList.Create;

  FN := Format( '%sbmp\PmpDefImg.bmp', [SciezkaWkp] );
  if FileExists(FN) then
  begin
    Pic := TPicture.Create;
    try
      Pic.LoadFromFile(FN);
      AddPmpImage( 'PmpDefImg', Pic );
    finally
      Pic.Free;
    end;
  end;

end;


{ TPumpList }

constructor TPumpList.Create;
begin
  inherited Create;
  FCtrlComponent := TPmpListCtrlComponent.Create(NIL);
  TPmpListCtrlComponent(FCtrlComponent).FList := self;
end;


destructor  TPumpList.Destroy;
begin

  Clear;
  FCtrlComponent.Free;
  inherited Destroy;
end;

procedure TPumpList.Clear;
var
  i       :Integer;
begin
  for i := 0 to Count-1 do
  try
    if Pumps[i] <> NIL then
    begin
      Pumps[i].Release;
      Items[i] := NIL;
    end;
  except
  end;
  inherited Clear;
end;

procedure   TPumpList.AddPump( P :TPompa );
var
//  IP        :IPump;
  pos       :Integer;
begin
  if AutoSort then
  begin
    pos := BSearchWDobr(P.WDobroci);
    inherited Insert(pos, P);
  end
  else
    inherited Add( P );
  P.AddRef;
  if FListView <> NIL then
  begin
    if AutoSort then
      SetListItem( FListView.Items.Insert(pos), P )
    else
      SetListItem( FListView.Items.Add, P );
  end;
end;

procedure TPumpList.AddCopy(P: TPompa);
var
  CopyP   :TPompa;
begin
  CopyP := P.MakeCopy;
  AddPump(CopyP);
end;



procedure TPumpList.LoadFromStream(s: TStream);
var
  C       :Longint;
  i       :Integer;
  Comp    :TComponent;
  DB      :TDBPompy;
  Pmp     :TPompa;
begin
  Clear;
  s.Read( C, SizeOf(C) );
  //Count := C;
  for i := 0 to C-1 do
  begin
    Comp := s.ReadComponent( NIL );
    //DB := Comp as TDBPompy;
    Pmp := Comp as TPompa;
    //Pmp.InsertComponent(DB);
    DoAfterLoadPomp(Pmp);
    AddPump(Pmp);
  end;
end;

procedure TPumpList.SaveToStream(s: TStream);
var
  C       :Longint;
  i       :Integer;
begin
  C := Count;
  s.Write( C, SizeOf(C) );
  for i := 0 to C-1 do
  begin
    s.WriteComponent( Pumps[i] );
  end;
end;

procedure TPumpList.DoAfterLoadPomp(Pmp: TPompa);
begin
  if Assigned(FAfterLoadPomp) then
    FAfterLoadPomp(Pmp);
end;


function  TPumpList.GetPump( ind :Integer ): TPompa;
begin
  result := Items[ ind ];
end;

procedure TPumpList.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FListView then
      FListView := NIL;
  end;
end;



procedure TPumpList.SetListView(lv: TListView);
begin
  FListView := lv;
  if lv = NIL then
    EXIT;

  FCtrlComponent.FreeNotification(lv);
  lv.Columns.Clear;
  lv.Items.Clear;
  lv.LargeImages := PmpLargeImgLst;
  lv.SmallImages := PmpSmallImgLst;
  lv.OnData := ListViewData;
  InitListViewColumns;
  InitListViewItems;
end;

procedure TPumpList.InitListViewColumns;
var
  lv      :TListView;
  c       :TListColumn;
begin
  lv := FListView;
  if lv = NIL then
    EXIT;

  c := lv.Columns.Add;
  c.Caption := 'Nazwa';
  c.Width := -1;
  c := lv.Columns.Add;
  c.Caption := 'Qn [m3/h]';
  c.Alignment := taRightJustify;

  c := lv.Columns.Add;
  c.Caption := 'Hn [m]';
  c.Alignment := taRightJustify;
end;

procedure TPumpList.InitListViewItems;
var
  lv      :TListView;
  it      :TListItem;
  i       :Integer;
begin
  lv := FListView;
  if lv = NIL then
    EXIT;
  for i := 0 to Count-1 do
  begin
    it := lv.Items.Add;
    SetListItem( it, Pumps[i] );
  end;
end;

procedure TPumpList.ListViewData(Sender: TObject; Item: TListItem);
var
  pmp     :TPompa;
begin
  pmp := Item.Data;
  if pmp = NIL then
    pmp := Pumps[Item.Index];
    //EXIT;
  SetListItem(Item,Pmp);
end;

procedure TPumpList.RemovePmp(pos: Integer);
var
  P       :TPompa;
  it      :TListItem;
begin
  P := Pumps[pos];
  inherited Delete(pos);
  if FListView <> NIL then
  begin
    it := FListView.FindData( 0, P, true, false );
    if it <> NIL then
      FListView.Items.Delete(it.Index);
  end;
  P.Release;
end;

procedure TPumpList.SetListItem(Item: TListItem; Pmp: TPompa);
begin
  with Item do
  begin
    if Pmp.ImageIndex < 0 then
      SetPmpImgIndex(Pmp);
    ImageIndex := Pmp.ImageIndex;
    Data := Pmp;
    SetListItemColumns( Item, Pmp );
  end;
end;



procedure TPumpList.SetListItemColumns(Item: TListItem; Pmp: TPompa);
begin
  Item.Caption := Pmp.Nazwa;
  Item.SubItems.Add( FormatFloat( '0.000', Pmp.Qn ));
  Item.SubItems.Add( FormatFloat( '0.000', Pmp.Hn ));
end;

procedure TPumpList.LoadFromFile(const FN: string);
var
  FS      :TFileStream;
begin
  FS := TFileStream.Create( FN, fmOpenRead );
  try
    LoadFromStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TPumpList.SaveToFile(const FN: string);
var
  FS      :TFileStream;
begin
  FS := TFileStream.Create( FN, fmCreate );
  try
    SaveToStream(FS);
  finally
    FS.Free;
  end;
end;

function TPumpList.BSearchWDobr(AValue: Double): Integer;
var
  AMin, AMax :Integer;
  med        :Integer;
begin
  AMin := 0;
  AMax := Count;
  //Result := 0;
  //med := 0;
  while ((AMax-AMin) > 0) {and (med < Count)} do
  begin
    med := AMin + (AMax-AMin) div 2;
    if Pumps[med].WDobroci < AValue then
      AMax := med
    else
      AMin := med+1;
  end;
  Result := AMax;
end;

procedure TPumpList.SetAutoSort(const Value: Boolean);
begin
  FAutoSort := Value;
end;

{ TPmpListCtrlComponent }

procedure TPmpListCtrlComponent.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  FList.Notification( AComponent, Operation );
  inherited;
end;

{ TPompaDragObject }

constructor TPompaDragObject.Create(Pmp: TPompa; AStartCtrl: TControl);
var
  bm        :TBitmap;
begin
  inherited Create( AStartCtrl );
  Pompa := Pmp;
  if Pmp <> NIL then
  begin
    bm := TBitmap.Create;
    try
      if Pmp.ImageIndex < 0 then
        SetPmpImgIndex( Pmp );
      PmpLargeImgLst.GetBitmap( Pmp.ImageIndex, bm );
      SetDragImageMasked( bm, 16, 16, bm.Canvas.Pixels[0,0] );
    finally
      bm.Free;
    end;
  end;
end;

destructor TPompaDragObject.Destroy;
begin
  ReleasePompa;
  inherited;
end;

procedure TPompaDragObject.ReleasePompa;
begin
  if FPompa <> NIL then
    FPompa.Release;
end;

procedure TPompaDragObject.SetPompa(const Value: TPompa);
begin
  ReleasePompa;
  FPompa := Value;
  if FPompa <> NIL then
    FPompa.AddRef;
end;

initialization
  InitLists;

finalization
  PmpImgListIndx.Free;

end.
