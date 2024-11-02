unit Prod;

interface

  { TODO 1 -oKR -cPodzial wg logiki : Podzielic na unity z kontrolkami i bez }

uses
  Classes,
  SysUtils,
  Menus,
  OutLine,
  Forms,
  IniFiles,
  Controls,
  comctrls,

  DBITYPES,    {procedury obslugi IDAPI}
  DBIPROCS,
  DBIERRS,

  DB,
  DBTables,
  TbsU,
  Graphics,
  KR_Sys,
  KR_Class,
  KR_DB,
  BledyU,
  BInfoU
  ;

type
  TProducent = class;


  TBaseInfo  = class (IBaseInfo)          // IBaseInfo - pusty abstract
  public
    procedure   Init( const fn :string );        override;
    function    TBSFName  :string;               override;
    function    GetPath   :string;
  private
    FOwner      :TProducent;
    FTBSFName   :string;

  protected

  public
    tbsf        :TIniFile;                      // plik TBS poowiazany z baza
    constructor Create;
    destructor  Destroy;                         override;

    procedure   SetOwner( o :TProducent );
    procedure   OutLineSet( ol :TOutLine );      virtual;  //??
    function    CanOutLineSet: Boolean;          virtual;
    function    GetBaseName( const id :string ): string; virtual;
    function    CreateTable( const id :string; AOwner :TComponent ): TTable;
    property    Owner    :TProducent read FOwner;
  end;

  EProdWarn = class (ePDP_Warning)
  end;

  EProdErr = class (ePDP_Exception)
  end;

  TProducenci = class;

{-----------------------------------------------------------------------------}
  TProducent = class
  public
    constructor Create( const sIdent: string );
    constructor Create2( const sIdent: string; const sPath: string );
    constructor CreateFromTBSFile( tbsf :TIniFile; const sPath :string;
                                   AOwner :TProducenci );
    destructor  Destroy; override;
  private
    theIdent         : string;
    theName          : string;
    thePelnaNazwa    : string;
    thePath          : string;
    theEnable        : Boolean;
    theCorect        : Boolean;
    thePermision     : Boolean;
    theSBaseStyle    : Boolean;
    thePompCount     : Longint;
    theOwner         : TProducenci;
    BaseList         : TStrings;
    FActualBaseType  : string;
    FIcon            : TPicture;
    FImageIndex      : Integer;
    FProdTBS: TCustomIniFile;

    function getBaseInfoT(const IdBaz: string): TBaseInfo;
    procedure SetEnabledEvent( Sender :TObject );
  protected
    function  getIdent: string;
    function  getName: string;
    function  GetPelnaNazwa: string;
    function  get_S_FName: TFileName;
    function  getBasePath: TFileName;
    function  getBazyDost   ( const IdBaz :string ): Boolean;
    function  getBazySciezka( const IdBaz :string ): string;
    function  getBaseInfo   ( const IdBaz :string ): IBaseInfo;
    procedure setEnable( enbl: Boolean );
    procedure InitTBS( tbsf :TIniFile );
    procedure InitPumps( const fn :string );

  public
    function  CreateBaseInfo( const TypId, fn :string ): IBaseInfo;
    procedure OutLineSet( ol :TOutLine; const BaseId :string );

    procedure IndexBase( const FName :string; FrstC :Char );
    procedure IndexABase( const FName :string );                     // indeksuje baze A
    procedure IndexBaseExpr( const FName, IndName,expr :string;
                                 ixStyle :TIndexOptions );

    property Owner: TProducenci read theOwner;
    property Ident: string read getIdent;
    property Nazwa: string read getName;
    property PelnaNazwa: string read GetPelnaNazwa;
    property S_Nazwa: TFileName read get_S_FName;      // S_ = starowniki
    property SciezkaDoBaz: TFileName read getBasePath;
    property IloscPomp: LongInt read thePompCount;
    property Enable: boolean read theEnable write setEnable;
    property Poprawne: boolean read theCorect;
    property Dozwolone: Boolean read thePermision;
    property ProdTBS :TCustomIniFile read FProdTBS;
    property Icon :TPicture read FIcon;
    property ImageIndex :Integer read FImageIndex;
    property BazyDost    [ const IdBaz :string ]: Boolean read getBazyDost;
    property BazySciezka [ const IdBaz :string ]: string  read getBazySciezka;
    property InfoBaz     [ const IdBaz :string ]: IBaseInfo read getBaseInfo;
    property InfoBazT    [ const IdBaz :string ]: TBaseInfo read getBaseInfoT;
  end;

{-----------------------------------------------------------------------------}
  TProdMenuItem = class( TMenuItem )
  private
  public
    prod: TProducent;
  end;

  TProdToolButton = class (TToolButton)
  private
    FProducent: TProducent;
    procedure SetProducent(const Value: TProducent);
  public
    constructor Create( AOwner :TComponent );                         override;
    procedure UpdateUpDown;
    property Producent :TProducent read FProducent write SetProducent;
  end;

{-----------------------------------------------------------------------------}
  TProducenci = class( TStringList )
  private
    FSmallImages :TImageList;
    FLargeImages :TImageList;
    FKomunikaty :TBledy;
    function  GetProd( ind :Integer ) :TProducent;
  public
    constructor Create;
    destructor  Destroy;            override;

    procedure InitEnabledToolBar( tb :TToolBar; const BazId :string );
    procedure SubMenu( menu: TMenuItem );
    procedure SubMenuEvent( menu: TMenuItem; ClickEv: TNotifyEvent;
                            const BazId :string  );
    procedure AddProd( prod: TProducent );
    procedure AddProdIni( prod: TProducent );
    function  ProdExists( ProdId :String ) :Boolean;
    function  ProdByName( ProdId :String ) :TProducent;
    procedure RegisterType( const BazId :string; CPAddr :TBICreateFunc );
    function  Registered(  const BazId :string ): Boolean;
    function  CreateBInfo( const BazId :string ): IBaseInfo;

    procedure Komunikat(const aText :string);     //overload;
    procedure KomFmt(const AFmt :string; const Args: array of const);

    property  Prods[ ind :Integer ] :TProducent read GetProd;
    property Komunikaty :TBledy read FKomunikaty;
  private
    BaseTypeList :TBICreatorList;
  end;

procedure GetOutLineStruct( FName: TFileName; ol: TOutLine );

procedure RegisterBaseType( const BazId :string; CPAddr :TBICreateFunc );

resourcestring
  sPrKomBladInitBazy
    = 'B³¹d inicjowania bazy %s producenta %s.';
  sPrKomBladInitBazyExcept
    = 'B³¹d inicjowania bazy %s producenta %s. "%s: %s"';
  sPrKomBladIndexExcept
    = 'B³¹d inc\deksowania bazy %s producenta %s. "%s: %s"';


var
  Producenci :TProducenci;



{=============================================================================}
{=============================================================================}
IMPLEMENTATION




function Str2NewPChar( s: string ): PChar;
var
  p: PChar;
begin
  GetMem( p, length(s)+1 );
  StrPCopy( p, s );
  Str2NewPChar := p;
end;

{ TProducent }

constructor TProducent.Create( const sIdent: string );
begin
  inherited Create;
end;


constructor TProducent.Create2( const sIdent: string; const sPath: string );
begin
  inherited Create;
  theIdent := sIdent;
  thePath  := sPath;
  theName  := '';
  theCorect := true;
  thePermision := (not ProdBlok) or (pos( '/'+sIdent, DozwProducenci) > 0);
  Enable := true;
  FImageIndex := -1;
end;


constructor TProducent.CreateFromTBSFile( tbsf :TIniFile; const sPath :string;
                                          AOwner :TProducenci );
var
  s         :string;
  path      :string;
begin
  FProdTBS := tbsf;                                      // przypisanie pliku TBS do producenta
  s := tbsf.ReadString( 'Producer Data', 'Ident', '' );  // czyta identyfikator np. LFP, XYLEM itp
  if s <> '' then
  begin
    if sPath[length(sPath)] = '\' then
      path := copy( sPath, 1, length(sPath)-1 )
    else
      path := sPath;
    Create2( s, Path );                                   // Sprawdza ProdBloc z Zetona
    theOwner := AOwner;
    theSBaseStyle := false;                               // jezeli jest nazwa ???
    theName := tbsf.ReadString( 'Producer Data', 'ShortName', s );
    thePelnaNazwa := tbsf.ReadString( 'Producer Data', 'FullName', theName );

    { tymczasowo }
    InitTBS(tbsf);  // robi liste baz producena

  end
  else
    theCorect := false;
end;


destructor  TProducent.destroy;
var
  i         :integer;
begin
  if BaseList <> NIL then
  begin
    for i := 0 to BaseList.Count-1 do
      BaseList.Objects[i].Free;
    BaseList.Free;
  end;
  FIcon.Free;
  FProdTBS.Free;
end;

function    TProducent.CreateBaseInfo( const TypId, fn :string ): IBaseInfo;
var
  bi        :IBaseInfo;
  tbsf      :TIniFile;
  DrvId     :string;              { DriverIdentifier - identyfikator sterownika}
begin
  tbsf  := TIniFile.Create(fn);
  DrvId := tbsf.ReadString( 'MAIN', 'DriverId', TypId );
  FActualBaseType := tbsf.ReadString( 'MAIN', 'Type', '' );
  bi := Owner.CreateBInfo( DrvId );                           // robi interfejs dla listy TProducenci
  if bi is TBaseInfo then
    TBaseInfo(bi).SetOwner(self);                             // zmiana wlasciciela - baze z TProducenci na TProducent
  result := bi;
  if bi <> NIL then
    bi.Init(fn)                                               // Robi indeksy dla plikow w bazie
end;

{------------------------------------------------}
{ czyta bazy (pliki TBS) podpiete pod producenta }
{ tworzy liste baz                               }
{------------------------------------------------}
procedure   TProducent.InitTBS( tbsf :TIniFile );
var
  i         :Integer;
  bi        :IBaseInfo;
  s         :string;
  FN        :string;
begin
  FIcon := TPicture.Create;
  s := tbsf.ReadString( 'Producer Data', 'ICON', '' );
  FN := SciezkaDoBaz + '\' + s;
  FIcon.LoadFromFile(FN);


  BaseList := TStringList.Create;
  tbsf.ReadSection( 'BASES', BaseList );                                    // Czyta liste plkiow z TBS
  with BaseList do
  begin
    for i := 0 to Count-1 do
    if StrInSet(Strings[i], DozwBazy ) then        // Sprawdza czy dozwolona  PUMPS/SQL_PUMPS/TANKS ...
      begin
        try
          s  := tbsf.ReadString( 'BASES', Strings[i], '' );
          //if (s <> '') and (copy(s,0,3)<> 'SQL' )  then
          if s <> '' then
          begin
            bi := CreateBaseInfo(Strings[i], SciezkaDoBaz + '\' + s);
            if bi <> NIL then
              begin
                Objects[i] := bi;
              end
            else
              Producenci.KomFmt(sPrKomBladInitBazy, [s, Nazwa]);
          end;
        except
          on E :Exception do
            Producenci.KomFmt(sPrKomBladInitBazy, [s, Nazwa, E.ClassName, E.Message]);
      end;
    end;
  end;
end;


procedure TProducent.InitPumps( const fn :string );

var
  tbsf    :TIniFile;
  list    :TStringList;
  i       :Integer;
  s       :string;

begin
  try
    tbsf    := TIniFile.Create( fn );
    list    := TStringList.Create;

    tbsf.ReadSection( 'FILES', list );
    with list do
    begin
      for i := 0 to Count-1 do
      begin
        s := tbsf.ReadString( 'FILES', Strings[i], '' );
        if s <> '' then
        begin
        end;
      end;
    end;

  finally
    list.Free;
    tbsf.Free;
  end;

end;


procedure TProducent.IndexABase( const FName :string );
var
  Table     :TTable;
  OnlyFileN :string;
  IndFName  :string;
  svCursor  :TCursor;
begin
  OnlyFileN := StrBefore('.', ExtractFileName(FName));
  IndFName :=  ExtractFilePath(FName)+'\'+ OnlyFileN + '.MDX';
  if not FileExists(IndFName) then
  begin
    ClearMDXSign( FName );
  end;
  try
    svCursor := Screen.Cursor;
    Table := TTable.Create(NIL);
    Table.TableName := FName;
    if not FileExists(IndFName) then
    begin
      Table.AddIndex( 'A_ID',
                      'ID1+ID2+ID3+ID4+ID5+ID6+ID7+ID8',
                      [ixExpression] );
      Table.AddIndex( 'NAZWA',
                      'NAZWA',
                      [] );
      Table.Open;
    end
    else
    begin
      //Table.Exclusive := True;
      Table.Open;
      Screen.Cursor := crHourGlass;
      DBIRegenIndexes(Table.Handle);
    end;
    if FActualBaseType = 'PUMPS' then
      thePompCount := Table.RecordCoun
      t;  // zwraca liczbe pomp elementow podstawowych
  finally
    Table.Close;
    Table.Free;
    Screen.Cursor := svCursor;
  end;
end;


procedure TProducent.IndexBase( const FName :string; FrstC :Char );
begin
  IndexBaseExpr( FName, FrstC+'_ID', FrstC+'_ID', [] );
end;


procedure TProducent.IndexBaseExpr( const FName, IndName,expr :string;
                                   ixStyle :TIndexOptions );
var
  Table     :TTable;
  OnlyFileN :string;
  IndFName  :string;
begin
  try
    OnlyFileN := StrBefore('.', ExtractFileName(FName));
    IndFName :=  ExtractFilePath(FName)+{'\'+} OnlyFileN + '.MDX';
    if not FileExists(IndFName) then
    begin
      ClearMDXSign( FName );
    end;
    try
      Table := TTable.Create(NIL);
      Table.TableName := FName;
      if not FileExists(IndFName) then
      begin
        Table.AddIndex( IndName, expr, ixStyle );
      end
      else
      begin
        //Table.Exclusive := True;
        Table.Open;
        DBIRegenIndexes(Table.Handle);
      end;
    finally
      Table.Close;
      Table.Free;
    end;
  except
    on E :Exception do
    begin
      Producenci.KomFmt(sPrKomBladIndexExcept, [OnlyFileN, Nazwa,
        E.ClassName, E.Message]);
    end;
  end;
end;



function  TProducent.getIdent: string;
begin
  Result := theIdent;
end;

function  TProducent.getName: string;
begin
  Result := theName;
end;

function TProducent.GetPelnaNazwa: string;
begin
  Result := thePelnaNazwa;
end;

function  TProducent.get_S_FName: TFileName;
begin
  if theSBaseStyle then                         // jezeli nie ma nazwy producenta - domyslna
    result := thePath + '\s_' + Ident + '.dbf'  // starowniki
  else
    result := '';
end;

function  TProducent.getBasePath: TFileName;
begin
  if theSBaseStyle then
    result := thePath + '\' + Ident
  else
    result := thePath;
end;


function  TProducent.getBazyDost   ( const IdBaz :string ): Boolean;
begin
  result := (BaseList.IndexOf( IdBaz ) >= 0);
end;


function  TProducent.getBazySciezka( const IdBaz :string ): string;
var
  i       :Integer;
  fn      :string;
begin
  i  := BaseList.IndexOf( IdBaz );
  if i >= 0 then
  begin
    fn     := IBaseInfo(BaseList.Objects[i]).TBSFName;
    fn     := ExtractFilePath( fn );
    fn     := copy( fn, 1, length(fn)-1 );
    result := fn;
  end
  else
    result := '';
end;


function  TProducent.getBaseInfo   ( const IdBaz :string ): IBaseInfo;
var
  i       :Integer;
begin
  i  := BaseList.IndexOf( IdBaz );
  if i >= 0 then
  begin
    result := IBaseInfo(BaseList.Objects[i]);
  end
  else
    result := NIL;

end;

function TProducent.getBaseInfoT(const IdBaz: string): TBaseInfo;
var
  ib     :IBaseInfo;
begin
  ib := getBaseInfo(IdBaz);
  if ib is TBaseInfo then
    result := TBaseInfo(ib)
  else
    result := NIL;
end;



procedure TProducent.setEnable( enbl: Boolean );
begin
  if enbl and theCorect and thePermision then
     theEnable := true
  else
     theEnable := false;
end;

procedure TProducent.SetEnabledEvent(Sender: TObject);
begin
  if Sender is TToolButton then
    Enable := TToolButton(Sender).Down;
end;



procedure TProducent.OutLineSet( ol :TOutLine; const BaseId :string );
var
  i       :Integer;
  bi      :IBaseInfo;
begin
  if theSBaseStyle then
  begin
    if (BaseId = 'PUMPS') then
      GetOutLineStruct( S_Nazwa, ol );
  end
  else
  begin
    bi := InfoBaz[BaseId];
    if bi <> NIL then
      if (bi is TBaseInfo) then
        if TBaseInfo(bi).CanOutLineSet then
          TBaseInfo(bi).OutLineSet(ol);
  end;
end;

{ TProducenci }

constructor TProducenci.Create;
begin
  inherited Create;
  FKomunikaty := TBledy.Create;
  BaseTypeList := TBICreatorList.Create;
  FSmallImages := TImageList.Create(NIL);
  FLargeImages := TImageList.CreateSize(32,32);
end;

destructor  TProducenci.Destroy;
begin
  BaseTypeList.Free;
end;

procedure TProducenci.InitEnabledToolBar( tb: TToolBar;
                                          const BazId :string );
var
  i       : integer;
  tbtn    :TProdToolButton;
begin
  tb.Images := FSmallImages;
  for i := 0 to count-1 do
  begin
    if Prods[i].BazyDost[BazId] then
    begin
      tbtn := TProdToolButton.Create(tb);
      tbtn.Producent := Prods[i];
    end;
  end;
  if tb.ClientWidth > 4 then
    tb.ClientWidth := tb.ButtonCount * tb.ButtonWidth +3;
end;

procedure TProducenci.SubMenu( menu: TMenuItem );
var
  i       : integer;
  mi      : TProdMenuItem;
begin
  for i := 0 to count-1 do
  begin
    mi := TProdMenuItem.Create(menu.Owner);
    mi.Caption := TProducent(objects[i]).Nazwa;
    mi.prod := TProducent(objects[i]);
    mi.Enabled := mi.prod.Dozwolone;
    menu.Add(mi);
  end;
end;

procedure TProducenci.SubMenuEvent( menu: TMenuItem;
                                    ClickEv: TNotifyEvent;
                                    const BazId :string );
  {-----------------------------------------
  | Dodaj do <menu> submenu z producentami, ktorzy maja baze produktow okreslonych
  | identyfikatorem <BazId>, i przypisz do zdarzenia <OnClick>
  | akcje opisana przez <ClickEv>.
  |
  | Elementy submenu sa to obiekty klasy <TProdMenuItem>.
   -----------------------------------------
  }
var
  i: integer;
  mi: TProdMenuItem;
begin
  for i := 0 to count-1 do
  begin
    if (objects[i] as TProducent).BazyDost[BazId] then
    begin
      mi := TProdMenuItem.Create(menu.Owner);
      mi.Caption := TProducent(objects[i]).PelnaNazwa;
      mi.prod := TProducent(objects[i]);
      mi.OnClick := ClickEv;
      mi.Enabled := mi.prod.Dozwolone;
      if mi.prod.ImageIndex >= 0 then
      begin
        FSmallImages.GetBitmap( mi.prod.ImageIndex, mi.Bitmap );
      end;
      menu.Add(mi);
    end;
  end;
end;


procedure TProducenci.AddProd( prod: TProducent );
var
  bm      :TBitmap;
begin
  AddObject( prod.Ident, prod );
  if prod.FIcon.Graphic is TIcon then
  begin
    prod.FImageIndex := FSmallImages.AddIcon( TIcon(prod.FIcon.Graphic) );
    FLargeImages.AddIcon( TIcon(prod.FIcon.Graphic) );
  end
  else if prod.FIcon.Graphic is TBitmap then
  begin
    bm := TBitmap(prod.FIcon.Graphic);
    prod.FImageIndex := FSmallImages.AddMasked( bm, bm.Canvas.Pixels[0,0] );
    FLargeImages.AddMasked( bm, bm.Canvas.Pixels[0,0] );
  end;
  prod.theOwner := self;
end;

procedure TProducenci.AddProdIni( prod: TProducent );
begin
  AddObject( prod.Ident, prod );
  prod.theOwner := self;
end;


function  TProducenci.ProdExists( ProdId :String ) :Boolean;
begin
  result := (IndexOf( ProdId ) >= 0);
end;

function  TProducenci.GetProd( ind :Integer ) :TProducent;
begin
  result := (Objects[ind] as TProducent);

end;

function TProducenci.ProdByName(ProdId: String): TProducent;
var
  i      :Integer;
begin
  i := IndexOf(ProdId);
  if i >= 0 then
  begin
    result := Prods[i];
  end
  else
  begin
    result := NIL;
  end;
end;



procedure TProducenci.RegisterType( const BazId :string; CPAddr :TBICreateFunc );
begin
  if not Registered( BazId ) then
    BaseTypeList.AddCreator( BazId, CPAddr );
end;

function  TProducenci.Registered( const BazId :string ): Boolean;
begin
  result := BaseTypeList.Member( BazId );
end;

function  TProducenci.CreateBInfo( const BazId :string ): IBaseInfo;
begin
  result := BaseTypeList.CreateBInfo( BazId );
end;


procedure RegisterBaseType( const BazId :string; CPAddr :TBICreateFunc );
begin
  Producenci.RegisterType( BazId, CPAddr );
end;

// Do wywalenia pliki typu S_xxx.dbf
procedure StructAddSubTree( FName: TFileName; ol: TOutLine; pos: LongInt;
                            WPos: Integer );
var
   db:       TTable;
   s, ident, coment: string;
   i:        LongInt;
   x, ox, wx, kx: string[10];
begin
   try
      db := TTable.Create(ol);
      db.TableName := FName;
      db.Open;
      x := IntToStr(WPos);
      ox := 'O' + x;
      wx := 'W' + x;
      kx := 'K' + x;
      ident := padr(db.FieldByName(ox).AsString,8, ' ');
      while (not db.EOF) and (AllTrim(ident) <> '') do
      begin
         coment := VFieldStr( db, kx, '');
         i := ol.AddChildObject( pos, ident + ' ' + coment, NIL );
         if db.FieldByName(wx).AsString <> '' then
         begin
            WPos := db.FieldByName(wx).AsInteger;
            StructAddSubTree( FName, ol, i, WPos );
         end;
         db.MoveBy(1);
         ident := padr(db.FieldByName(ox).AsString,8, ' ');
      end;
   finally
      db.Close;
      db.Free;
   end;
end;


procedure GetOutLineStruct( FName: TFileName; ol: TOutLine );
var
  db:       TTable;
  s, ident, coment: string;
  i:        LongInt;
  WPos:     integer;
begin
  try
    db := TTable.Create(ol);
    db.TableName := FName;
    db.Open;
    ol.Clear;
    ol.font.pitch := fpFixed;
    ident := padr(db.FieldByName('OTYP').AsString,8, ' ');
    while (not db.EOF) and (AllTrim(ident) <> '') do
    begin
      coment := VFieldStr(db,'KOMENT','');
      i := ol.AddChild( 0, ident + ' ' + coment );
      if db.FieldByName('WTYP').AsString <> '' then
      begin
        WPos := db.FieldByName('WTYP').AsInteger;
        StructAddSubTree( FName, ol, i, WPos );
      end;
      db.next;
      ident := padr(db.FieldByName('OTYP').AsString,8, ' ');
    end;
  finally
    db.Close;
    db.Free;
  end;
end;


procedure TProducenci.KomFmt(const AFmt: string;
  const Args: array of const);
begin
  Komunikat(Format(AFmt, Args));
end;

procedure TProducenci.Komunikat(const aText: string);
begin
  FKomunikaty.DodajOstrzerzenie(EProdWarn, aText);
end;

{ TBaseInfo }


constructor TBaseInfo.Create;
begin
  Inherited Create;
end;

destructor TBaseInfo.Destroy;
begin
  tbsf.Free;
  Inherited Destroy;
end;

procedure   TBaseInfo.SetOwner( o :TProducent );
begin
  FOwner := o;
end;

function    TBaseInfo.TBSFName  :string;
begin
  result := FTBSFName;
end;

procedure   TBaseInfo.Init( const fn :string );
begin
  FTBSFName := fn;
  tbsf      := TIniFile.Create(fn);
end;


procedure   TBaseInfo.OutLineSet( ol :TOutLine );
begin
end;

function    TBaseInfo.CanOutLineSet: Boolean;
begin
  result := false;
end;

function    TBaseInfo.GetBaseName( const id :string ): string;
begin
  result := ExtractFilePath(TBSFName) + tbsf.ReadString( 'FILES', id, '' );
end;



function TBaseInfo.GetPath: string;
begin
  result := StrButLast( ExtractFilePath(FTBSFName), 1 );
end;

function TBaseInfo.CreateTable(const id: string; AOwner :TComponent): TTable;
var
  TN     :string;
begin
  Result := NIL;
  TN := GetBaseName(id);
  if FileExists(TN) then
  begin
    Result := TTable.Create(AOwner);
    TableSetNames(TN, Result);
  end;
end;


{ TProdToolButton }

constructor TProdToolButton.Create(AOwner: TComponent);
begin
  inherited;
  if AOwner is TToolBar then
    SetToolBar( TToolBar(AOwner) );
  Style := tbsCheck;
end;

procedure TProdToolButton.SetProducent(const Value: TProducent);
begin
  FProducent := Value;
  if Value <> NIL then
  begin
    OnClick     := FProducent.SetEnabledEvent;
    Caption     := FProducent.Nazwa;
    Hint        := Format( '%s|%s', [FProducent.Nazwa,
                                     FProducent.PelnaNazwa]);
    ImageIndex  := FProducent.ImageIndex;
    Down        := FProducent.Enable;
  end;
end;

procedure TProdToolButton.UpdateUpDown;
begin
  Down := Producent.Enable;
end;

initialization
  Producenci := TProducenci.Create;

finalization
  Producenci.Free;
END.
