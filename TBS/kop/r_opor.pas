unit r_opor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Grids, DBGrids, DB, DBTables, Buttons,Printers, Menus,
  Math, TypInfo, WkpGlob,
  //KopGlob,
  IniFiles, KR_Sys, KRMath, ZadU, ZadFrmU,
  ElemUnit, Prod, DBArm, PipInfoU, Outline, DbgEx, DGraph, Diagrams,
  KopDraw1, WykrFrm,
  //QuickRpt, QRPrntr,
  KopZadU, Ciecze, PropertyAccesserU,
  FormSaverU, ImgList,
  jezyki;

type


  TRura = class(TZadForm)
    DataSource: TDataSource;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    OpenMenu: TMenuItem;
    SaveMenu: TMenuItem;
    SaveAsMenu: TMenuItem;
    Wydrukraportu1: TMenuItem;
    ExitMenu: TMenuItem;
    SiatkaOPopUp: TPopupMenu;
    UsunPUMI: TMenuItem;
    SiatkaPopUp: TPopupMenu;
    PrzeglSiatPUMI: TMenuItem;
    DodajSiatPUMI: TMenuItem;
    N1: TMenuItem;
    WydrukRaportuMenu: TMenuItem;
    PodgladRaportuMenu: TMenuItem;
    FormulyPopup: TPopupMenu;
    DodFormuleMI: TMenuItem;
    EditPUMI: TMenuItem;
    MainPanel: TPanel;
    GroupBox4: TGroupBox;
    SiatkaO: TStringGrid;
    DiagDescrQ: TDiagDescr;
    DiagFunctionH: TDiagFunction;
    DiagDescrH: TDiagDescr;
    DiagFunPPracy: TDiagFunction;
    LeftPanel: TPanel;
    CharPanel: TPanel;
    Diag: TDiagram;
    Splitter1: TSplitter;
    SumPanel: TPanel;
    OporCalkLab: TLabel;
    SumDHEdit: TEdit;
    ElemPanel: TPanel;
    TreeOutLn: TOutline;
    Splitter2: TSplitter;
    ListPanel: TPanel;
    Siatka: TDBGridEx;
    SiatkaFormul: TStringGrid;
    Splitter4: TSplitter;
    SumDHkPaEdit: TEdit;
    Button1: TButton;
    ImageList1: TImageList;
    PanLeftTop: TPanel;
    Splitter3: TSplitter;
    CieczGBox: TGroupBox;
    Label16: TLabel;
    LabQJed: TLabel;
    TempImg: TImage;
    TLab: TLabel;
    GestImg: TImage;
    GestLab: TLabel;
    LepImg: TImage;
    LepLab: TLabel;
    LTemp: TLabel;
    L_gestosc: TLabel;
    L_Lep: TLabel;
    L_preznosc: TLabel;
    Image1: TImage;
    Label2: TLabel;
    CieczCombo: TComboBox;
    QEdit: TEdit;
    TempEdit: TEdit;
    GestEd: TEdit;
    LepEd: TEdit;
    PvEdit: TEdit;
    procedure CieczComboClick(Sender: TObject);
    {procedure ComboBox2Click(Sender: TObject);}
    procedure SiatkaDblClick(Sender: TObject);
    procedure SiatkaOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure QEditExit(Sender: TObject);
    procedure SiatkaKeyPress(Sender: TObject; var Key: Char);
    procedure ObliczeniaBtnClick(Sender: TObject);
    procedure ZapiszJakoButtonClick(Sender: TObject);
    procedure OtworzBtnClick(Sender: TObject);
    procedure ExitBtClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabelaProdFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure TreeOutLnClick(Sender: TObject);
    procedure SiatkaODragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SiatkaDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SiatkaODrawCell(Sender: TObject; Col, Row: Longint;
      Rect: TRect; State: TGridDrawState);
    procedure SiatkaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SiatkaODragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DiagFunctionHValue(X: Double; var Y: Double);
    procedure DiagDblClick(Sender: TObject);
    procedure TempEditExit(Sender: TObject);
    procedure UsunPUMIClick(Sender: TObject);
    procedure SiatkaOPopUpPopup(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure PrzeglSiatPUMIClick(Sender: TObject);
    procedure SiatkaPopUpPopup(Sender: TObject);
    procedure PodgladRaportuMenuClick(Sender: TObject);
    procedure WydrukRaportuMenuClick(Sender: TObject);
    procedure QEditKeyPress(Sender: TObject; var Key: Char);
    procedure SiatkaFormulDblClick(Sender: TObject);
    procedure DodFormuleMIClick(Sender: TObject);
    procedure SiatkaFormulMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditPUMIClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SiatkaFormulStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure SaverLoadProperty(Sender: TObject; var APath: String;
      var Value: Variant; TypeKind: TTypeKind; var Allow: Boolean);
    procedure GestEdExit(Sender: TObject);
    procedure LepEdExit(Sender: TObject);
    procedure PvEditExit(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SiatkaODblClick(Sender: TObject);
    procedure SiatkaFormulClick(Sender: TObject);
    procedure SiatkaOClick(Sender: TObject);
    procedure SiatkaDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure SiatkaCellClick(Column: TColumn);
    procedure SiatkaFormulDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SiatkaOMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SiatkaFormulMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SiatkaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    plik : TextFile;
    Text,s,Text1 : String;
    i    : Integer;
    inited        :Boolean;
    Dir,FileName : String;
    NiePierwszy   :Boolean;
    ListaFormul   :TList;
    KopReportForm :TForm;
    FCiecz        :TCieczPlyw;
    FEdycjaCieczy: Boolean;
    FEdycjaParamCieczy: Boolean;

    function  getNi :Double;
    procedure setNi( v :Double );
    function  getRo :Double;
    procedure setRo( v :Double );
    function  getT  :Double;
    procedure setT ( v :Double );
    function  getQ  :Double;
    procedure setQ ( v :Double );
    function  getQm3h  :Double;
    procedure setQm3h ( v :Double );

    function  getListPos :Integer;
    function  GetListCnt :Integer;
    procedure AktualForm;
    procedure DodajElement;
    procedure DodajFormule;
    procedure UsunAktualnyElement;
    procedure SetMaxDiag( Diag :TDiagram; Fun :TDiagFun );
    function GetZad: TKopZad;
    function GetElList: TElemList;
    procedure AktualCieczEdits;
    procedure SetEdycjaCieczy(const Value: Boolean);
    procedure SetEdycjaParamCieczy(const Value: Boolean);

  protected
    FLockedComp :TComponent;
    procedure SetZad( Z :TZadanie );             override;
    procedure SetCiecz(const Value: TCieczPlyw); virtual;
    function  DoAktNazwaCieczy :Boolean;         virtual;
  public
    { Public declarations }
    Demo          :Boolean;
    DoSave        :Boolean;
    WlascLic      :string;
    pozycja      : Integer;
    Re,d,delH,la : Real;
    DB           : TDBArmatura;
    DBProd       : TDBArmatura;
    DBStd        : TDBArmatura;
    BInfo        : TPipesBaseInfo;
    BIProd       : TPipesBaseInfo;
    BIStd        : TPipesBaseInfo;
    FilterAt2    : string;
    PntDiagFun   : TPntDiagFun;
    Tabela       : TTable;
    TabelaStd    : TTable;
    TabelaProd   : TTable;
    DocFileName  : string;
    RapTitle     : string;

    constructor Create( O :TComponent );  override;
    destructor Destroy;       override;
    procedure  SaveForm;

    procedure  OpenDoc;
    procedure  SaveDoc;
    procedure  SaveDocAs;
    procedure  Aktualizuj;                override;

    procedure  Init;                      virtual;
    procedure  DodajElem( el :TElemAbstract );
    procedure  UsunElem( pos :Integer );
    procedure  PrzeglEl;

    property   Zadanie  :TKopZad   read GetZad;

    property   ElList   :TElemList read GetElList;

    property   Ciecz   : TCieczPlyw read FCiecz write SetCiecz; //Zawiera Q w m3/h

    property   EdycjaCieczy :Boolean read FEdycjaCieczy write SetEdycjaCieczy;
    property   EdycjaParamCieczy :Boolean read FEdycjaParamCieczy write SetEdycjaParamCieczy;

    property   ListPos:  Integer  read GetListPos;
    property   ListCnt:  Integer  read GetListCnt;

    property  ni  :Double  read getNi    write setNi;
    property  ro  :Double  read getRo    write setRo;
    property  t   :Double  read getT     write setT;
                                                         //w KOP
    property  Q   :Double  read getQ     write setQ;     //Obliczeniowe natezenie przeplywu m3/s
    property  Qm3h:Double  read GetQm3h  write SetQm3h;  //Obliczeniowe natezenie przeplywu m3/h
  published
    property Visible;
  end;


function  WodaPv(temp:real):Double;
function  WodaNi(temp:real):Double;
function  WodaRo(temp:real):Double;
Const
  N=100;

  GruKolorTla   : TColor = $874C07;
  GruKolorPusty : TColor = $B49924;

var
  Rura: TRura;

implementation
{$R *.DFM}
Uses
    ElAbFrm,
    Opor,
    ArmElFrm,
    //KopRaport, QRPre,
  //   UNIZadMainForm,UNIZadU,
    TbsU;

{------------------------ Paramarty wody -------------------------------}
function  WodaPv(temp:real):Double;
{cisnienie preznosci wody W Pa}
begin
  WodaPv := 610.8*EXP(17.174-f_div(4053.06, 236+temp)+6e-5*temp*sin(3.14*temp/100));
end;

function  WodaNi(temp:real):Double;
begin
  WodaNi := 1.791e-6*EXP(f_div(468,temp+118.6)-3.948);
end;

function  WodaRo(temp:real):Double;
begin
  WodaRo := f_div(1000,
                  4.074e-6*(temp-1)*(temp-1)-0.0101/3.14*cos(3.14*(temp-4)/104)+1.0033);
end;

procedure DemoMsg;
begin
  ShowMessage('Wersja demonstracyjna, opcja zablokowana');
end;

//---------------------------------------------------------------------------
function  TRura.getNi :Double;
begin
  result := ciecz.Ni;
end;

//---------------------------------------------------------------------------
procedure TRura.setNi( v :Double );
begin
  //Ciecz.Ni := v;
end;

//---------------------------------------------------------------------------
function  TRura.getRo :Double;
begin
  result := ciecz.ro;
end;

//---------------------------------------------------------------------------
procedure TRura.setRo( v :Double );
begin
  //Ciecz.ro := v;
end;

//---------------------------------------------------------------------------
function  TRura.getT  :Double;
begin
  result := ciecz.T;
end;

//---------------------------------------------------------------------------
procedure TRura.setT ( v :Double );
begin
  Ciecz.T := v;
end;

//---------------------------------------------------------------------------
function  TRura.getQ  :Double;
begin
  if ciecz <> NIL then
    result := ciecz.Q
  else
    result := 0;
end;

//---------------------------------------------------------------------------
procedure TRura.setQ ( v :Double );
begin
  if ciecz <> NIL then
    Ciecz.Q := v;
end;

//---------------------------------------------------------------------------
function  TRura.getQm3h  :Double;
begin
  if ciecz <> NIL then
    result := ciecz.Q * 3600
  else
    result := 0;
end;

//---------------------------------------------------------------------------
procedure TRura.setQm3h ( v :Double );
begin
  if ciecz <> NIL then
    ciecz.Q := v / 3600;
end;




{-------------------------Wczytanie parametrow cieczy-------------------}
procedure TRura.CieczComboClick(Sender: TObject);
var
  o       :TCiecz;
begin
  {
  with CieczCombo do
    o := TCiecz(Items.Objects[ItemIndex]);
  t := o.t;
  Ciecz.Nazwa := o.Nazwa;
  TempEdit.Text := FormatFloat('0.0',t);
  ni := o.ni;
  LepEd.Text := FormatFloat('0.00', ni*1000000);
  ro := o.ro;
  GestEd.Text := FormatFloat('0.00', ro);
  if Ciecz.Nazwa = 'Woda' then
    TempEditExit(TempEdit);
  AktualForm;
  }
end;


//---------------------------------------------------------------------------
{    Filtrowanie bazy danych po nacisnieciu dabliclica      }
//---------------------------------------------------------------------------
procedure TRura.SiatkaDblClick(Sender: TObject);
begin
  Siatka.EndDrag(false);
  DodajElement;
  Siatka.EndDrag(false);
end;


//---------------------------------------------------------------------------
procedure TRura.Init;
var
  i       :Integer;
  o       :TCiecz;
  //d       :Double;
  bi      :TPipesBaseInfo;


begin

  Screen.Cursor := crHourGlass;
  { Tabela Standardowa }
  for i := 0 to Producenci.Count-1 do
  begin
    if Producenci.Prods[i].BazyDost['PIPES'] then
    begin
      bi := Producenci.Prods[i].InfoBaz['PIPES'] as TPipesBaseInfo;
      bi.OutLineSet( TreeOutLn );
    end;
  end;

  if Ciecz <> NIL then
    QEdit.Text := FormatFloat( '0.0', m3hToU( q*3600 ));
  pozycja:=0;
  delH:=0;

  Screen.Cursor := crDefault;
  Inited := true;

end;


{----------------------------------------------------------------------------}
procedure TRura.SetMaxDiag( Diag :TDiagram; Fun :TDiagFun );
//----------------------------------
//   Ustaw zakresy wykresu
//
//------------
var
  Qm, Hm  :Double;
  svQ     :Double;

begin
  if (Diag = NIL) or (Ciecz = NIL) then
    EXIT;

  if Q = 0 then
    Qm := 20
  else
    Qm := 1.5 * Qm3h;

  Diag.CountMaxXR(Qm);

  if ElList.Count = 0 then
    Hm := 15
  else
  begin
    Zadanie.LockChange;
    try
      svQ := Q;
      Qm3h := Diag.MaxXR;
      Hm := ElList.dH(Ciecz);
      Q := svQ;
    finally
      Zadanie.UnlockChange;
    end;
  end;
  Diag.CountMaxYR(Hm);

  Fun.CountMaxYR(Hm);

  Diag.Invalidate;
end;


{----------------------------------------------------------------------------}
procedure TRura.DiagFunctionHValue(X: Double; var Y: Double);
var
  svQ     :Double;
begin
  if (ElList = NIL) or (Ciecz = NIL) then
    EXIT;
  try
    LockAktual;
    Zadanie.LockChange;
    try
      svQ := Q;
      Qm3h := X;              //przestawia ciecz na Q w m3/h
      Y := ElList.dH(ciecz);
      Q   := svQ;
    finally
      UnlockAktual;
      Zadanie.UnlockChange;
    end;
  except
    on EAccessViolation do
      Y := 0;
  end;
end;




//---------------------------------------------------------------------------
destructor TRura.Destroy;
begin
  //ciecz.Free;
  inherited Destroy;
end;

//---------------------------------------------------------------------------
procedure  TRura.SaveForm;
var
  s        :string;
begin
  //str( Q: 12: 6, s );
  //Ini.WriteString( 'CIECZ', 'Q', s );
  //Ini.WriteString( 'CIECZ', 'Nazwa', ciecz.Nazwa );
end;

{===Procedura obslugi klawiszy w siatce ELEMENTY=======================}
//---------------------------------------------------------------------------
procedure TRura.SiatkaKeyPress(Sender: TObject; var Key: Char);
begin
  If (Key=#13) then
  begin
    Key:=#0;
    DodajElement;
  end;
end;

{===============Procedura obslugi klawiszy przez siatke OPORY===========}
//---------------------------------------------------------------------------
procedure TRura.SiatkaOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {---------Poczatek klawisza deleta----------}
  if Key = VK_delete then
  begin
    Key:=0;
    UsunAktualnyElement;
  end; {-----Koniec klawisza Delete---------}
end;


//---------------------------------------------------------------------------
procedure TRura.QEditExit(Sender: TObject);
begin
  if QEdit.Modified then
  begin
    try
      s:=QEdit.Text;
      if s='' then s:='0';
      Q := UTom3h(StrToFloat(s))/3600;
    except
      MessageDlg('Zle wprowadzone dane!! ',mterror,[mbOK],0);
      Q:=0;
      QEdit.Text:='';
    end;
    FLockedComp := QEdit;
    Aktualizuj;
    QEdit.Modified := false;
  end;
end;



//---------------------------------------------------------------------------
procedure TRura.ObliczeniaBtnClick(Sender: TObject);
begin
  if Ciecz = NIL then
    EXIT;
  delH   := ElList.dH(ciecz);
  PntDiagFun.H := delH;
  str(Q:7:5,s);
  SumDHEdit.Text := FormatFloat( '0.000', delH );
  SumDHkPaEdit.Text := FormatFloat( '0.00', delH * ciecz.Ro * 9.81 / 1000 );
end;

//---------------------------------------------------------------------------
procedure TRura.ZapiszJakoButtonClick(Sender: TObject);
begin
  SaveDocAs;
end;

//---------------------------------------------------------------------------
procedure TRura.OtworzBtnClick(Sender: TObject);
begin
  OpenDoc;
end;


//---------------------------------------------------------------------------
procedure TRura.ExitBtClick(Sender: TObject);
begin
  Close;
end;

//---------------------------------------------------------------------------
procedure TRura.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := DefaultCloseAction;
  Tag:=0;
  inherited;
end;

//---------------------------------------------------------------------------
procedure TRura.AktualForm;
begin
  if not inited then
    EXIT;
  AktualCieczEdits;
  SiatkaO.Invalidate;
  ObliczeniaBtnClick( NIL );
  SetMaxDiag(Diag, DiagFunctionH);
  Zadanie.DoChange;
  TTlumacz.DajObiekt.Tlumacz(SiatkaO);   
  //if Addr((Zad as TKopZad).OnChange) <> NIL then
    //(Zad as TKopZad).OnChange(self);
end;

//---------------------------------------------------------------------------
procedure  TRura.DodajElem( el :TElemAbstract );
begin
  ElList.Add( el );
  Aktualizuj;
end;

//---------------------------------------------------------------------------
procedure  TRura.UsunElem( pos :Integer );
begin
  ElList.DeleteFree( pos );
  Aktualizuj;
end;


//---------------------------------------------------------------------------
function  TRura.getListPos :Integer;
begin
  result := SiatkaO.Row-1;
end;

//---------------------------------------------------------------------------
function  TRura.GetListCnt :Integer;
begin
  result := ElList.Count;
end;





//---------------------------------------------------------------------------
procedure TRura.TabelaProdFilterRecord(DataSet: TDataSet; var Accept: Boolean);
var
  f1, f2       :TField;
begin
  if DataSet.Active then
  begin
    f1 := DataSet.FindField('At1');
    f2 := DataSet.FindField('At2');
    if (f1 <> NIL) and (f2 <> NIL) then
      Accept := (f2.AsString = FilterAt2)
            and (not StrIsInt(f1.AsString));
  end;
end;

//---------------------------------------------------------------------------
procedure TRura.TreeOutLnClick(Sender: TObject);
var
  o       :TObject;
begin
  if Tabela <> NIL then
    Tabela.Close;
  o := TreeOutLn.Items[TreeOutLn.SelectedItem].Data;
  if (o <> NIL) and (o is TPipeTreeNodeObj) then
  begin
    SiatkaFormul.Hide;
    Siatka.Show;
    with TPipeTreeNodeObj(o) do
    begin
      FilterAt2 := S;
      if BaseInfo <> BInfo then
      begin
        DB.Free;
        BInfo := BaseInfo;
        DB := TDBArmatura.CreateForProd( self, BInfo.Owner );
        Tabela := DB.A as TTable;
        Tabela.OnFilterRecord := TabelaProdFilterRecord;
        Tabela.Filtered := true;
      end
    end;
    DataSource.DataSet := Tabela;
  end
  else if TreeOutLn.SelectedItem = 1 then
  begin
    DB.Free;
    DB := NIL;
    Tabela := NIL;
    BInfo := NIL;
    SiatkaFormul.Show;
    Siatka.Hide;
  end;

  if Tabela <> NIL then
  begin
    //Tabela.Filtered := true;
    Tabela.Open;
    Tabela.Refresh;
  end;
  if Siatka.Visible then
     TTlumacz.DajObiekt.Tlumacz(siatka);   
end;

//---------------------------------------------------------------------------
procedure TRura.DodajElement;
Var
   S,Text,Text1      : String;
   NowyObj           : TElemAbstract;
   DodajElemForm     : TElemAbstPrzeplFrm;
begin

  NowyObj := NIL;
  if Tabela = NIL then
    EXIT;

  if demo and (Siatka.Row > 2) then
  begin
    DemoMsg;
    EXIT;
  end;

  With Tabela do
  begin
    S:=FieldByName('At2').AsString;
    Text:=FieldByName('At1').AsString;
    Text1:=FieldByName('Mat').AsString;
  end;

  DodajElemForm := NIL;

  NowyObj := CreateElemFromDB( DB );
  if NowyObj <> NIL then
  begin
    DodajElemForm := TElemAbstPrzeplFrm(NowyObj.DajOkno( '+Ed' ));
    if DodajElemForm <> NIL then
    begin
      DodajElemForm.Ciecz := Ciecz;
      //DodajElemForm.ViewBtn.OnClick := PrzeglSiatPUMIClick;
      DodajElemForm.ShowModal;
      if DodajElemForm.ModalResult = mrOK then
       begin
         NowyObj.Nazwa := TTlumacz.DajObiekt.ZnajdzTlumaczenie( NowyObj.Nazwa);
         DodajElem(NowyObj)
       end
      else
        NowyObj.Free;
    end
    else     // nie ma okna
      NowyObj.Free;
  end;

  {
  if (Text = 'E') then
  try
    DodajElemForm := TDodajElemForm.Create(self);
    DodajElemForm.Ciecz := Ciecz;
    DodajElemForm.ViewBtn.OnClick := PrzeglSiatPUMIClick;
    DodajElemForm.ShowModal;
    if DodajElemForm.ModalResult = mrOK then
    begin
      NowyObj := DodajElemForm.Obj;
      DodajElemForm.Obj  := NIL;
    end
  finally
    DodajElemForm.Free;
  end
  else if (Text = 'F') then
  begin

    If Text1='Norma76' Then
    begin
      PN.Ciecz := Ciecz;
      PN.ShowModal;
      if PN.ModalResult = mrOK then
      begin
        NowyObj := PN.Obj;
        PN.Obj  := NIL;
      end
    end;

    If Text1='NIKURADSE' Then
    begin
      Nikuradze.Ciecz := Ciecz;
      Nikuradze.ShowModal;
      if Nikuradze.ModalResult = mrOK then
      begin
       NowyObj := Nikuradze.Obj;
       Nikuradze.Obj  := NIL;
      end
    end;

    If Text1='MANI' Then
    begin
      Maning.Ciecz := Ciecz;
      Maning.ShowModal;
      if Maning.ModalResult = mrOK then
      begin
        NowyObj := Maning.Obj;
        Maning.Obj  := NIL;
      end
    end;

    If Text1='ALT_SUL' Then
    begin
      AltS.Ciecz := Ciecz;
      AltS.ShowModal;
      if AltS.ModalResult = mrOK then
      begin
        NowyObj := AltS.Obj;
        AltS.Obj  := NIL;
      end
    end;

    If Text1='WILIAMS' Then
    begin
      Wil_Haz.Ciecz := Ciecz;
      Wil_Haz.ShowModal;
      if Wil_Haz.ModalResult = mrOK then
      begin
        NowyObj := Wil_Haz.Obj;
        Wil_Haz.Obj  := NIL;
      end
    end;

    If Text1='C_W' Then
    begin
      C_W.Ciecz := Ciecz;
      C_W.ShowModal;
      if C_W.ModalResult = mrOK then
      begin
        NowyObj := C_W.Obj;
        C_W.Obj  := NIL;
      end
    end;
  End; // od IF -a

  if NowyObj <> NIL then
  begin
    DodajElem(NowyObj);
  end;
  }
end;


//---------------------------------------------------------------------------
procedure TRura.SiatkaODragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if Source = Siatka then
    DodajElement
  else if Source = SiatkaFormul then
    DodajFormule;
end;

//---------------------------------------------------------------------------
procedure TRura.SiatkaDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if (Source = Siatka) or (Source = SiatkaFormul) then
    Accept := true;
end;

//---------------------------------------------------------------------------
procedure TRura.SiatkaODrawCell(Sender: TObject; Col, Row: Longint;
  Rect: TRect; State: TGridDrawState);
var
  o        :TElemAbstract;
  d        :Double;
  pos      :Integer;
  brak     :Boolean;
begin
  if Zadanie = NIL then
    EXIT;
//  if SiatkaO.Objects[ 0, Row-1 ] is TElemAbstract then
  begin
    brak := false;
    o    := NIL;
    if Row = 0 then
    begin
      case Col of
        4:
        begin
          SumDHEdit.Left := Rect.Left;
          SumDHEdit.Width := Rect.Right - Rect.Left;
          OporCalkLab.Left := Rect.Left - OporCalkLab.Width - 4;
        end;

        5:
        begin
          SumDHkPaEdit.Left := Rect.Left;
          SumDHkPaEdit.Width := Rect.Right - Rect.Left;
        end;
      end;
    end;
    Pos  := Row-1;
    if (Pos >= 0) and (Pos < ElList.Count) then
      o := ElList[ Row-1 ];
    if o <> NIL then with SiatkaO.Canvas do
    begin
      with Rect do
      begin
        Left    := Left   +2;
        Right   := Right  -2;
        Top     := Top    +2;
      end;
      case Col of
        0  :DrawText( Handle, PChar(IntToStr(Row)), -1, Rect,
                      DT_RIGHT or DT_VCENTER );
        1  :DrawText( Handle, PChar(o.Nazwa), -1, Rect,
                      DT_LEFT or DT_VCENTER );
        2  :
          begin
          if eisLength in o.GetInfoState then
            DrawText( Handle, PChar( FormatFloat('0.0',o.L)), -1, Rect,
                      DT_RIGHT or DT_VCENTER )
          else
            brak := true;
          end;

        3  :
          begin
          if eisDiam in o.GetInfoState then
            DrawText( Handle, PChar( FormatFloat('0.0',
                                     o.d*1000)), -1, Rect,  // m -> mm
                      DT_RIGHT or DT_VCENTER )
          else
            brak := true;
          end;

        4  :
          begin
          if eisDH in o.GetInfoState then
            try
              DrawText( Handle, PChar( FormatFloat('0.000',o.dH(Ciecz))),
                        -1, Rect,
                        DT_RIGHT or DT_VCENTER );
            except
              on EMathError do
                brak := true;
              on EAccessViolation do
                brak := true;
            end
          else
            brak := true;
          end;

        5  : // cisnienie kPa
          begin
          if eisDH in o.GetInfoState then
            try
              d := o.dH_Pa(Ciecz) /1000;
              DrawText( Handle, PChar( FormatFloat('0.00',d)),
                        -1, Rect,
                        DT_RIGHT or DT_VCENTER );
            except
              on EMathError do
                brak := true;
              on EAccessViolation do
                brak := true;
            end

          else
            brak := true;
          end;

        6  :
          begin
            if eisDiam in o.GetInfoState then
              try
                DrawText( Handle, PChar( FormatFloat('0.00',
                                         f_div(Q, Pi*sqr(o.d)/4) )),
                          -1, Rect,
                          DT_RIGHT or DT_VCENTER );
              except
                on EMathError do
                  brak := true;
                on EAccessViolation do
                  brak := true;
              end
            else
              brak := true;
          end;

        8 : ImageList1.Draw(SiatkaO.Canvas,Rect.Left,Rect.top-1,0,true);

        7  :
          begin
            if eisDiam in o.GetInfoState then
              try
                DrawText( Handle, PChar( FormatFloat('0.00',
                                       Reynolds( o.d,
                                       f_div(Q, Pi*sqr(o.d)/4),
                                       ni))),
                          -1, Rect,
                          DT_RIGHT or DT_VCENTER );
              except
                on EMathError do
                  brak := true;
                on EAccessViolation do
                  brak := true;
              end
            else
              brak := true;
          end;

      end;

      if brak then
      begin
        DrawText( Handle, PChar(TTlumacz.DajObiekt.ZnajdzTlumaczenie('brak')),
                  -1, Rect,
                  DT_RIGHT or DT_VCENTER );
      end;
    end;
  end;
end;



//---------------------------------------------------------------------------
procedure TRura.SiatkaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  GC     :TGridCoord;
begin
   GC := Siatka.MouseCoord( X, Y );
   if (GC.Y > 0) and (ssLeft in Shift) and (not (ssDouble in Shift)) then
     Siatka.BeginDrag( false );
end;

//---------------------------------------------------------------------------
procedure TRura.SiatkaODragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Source = Siatka then
    Accept := true;
end;



//---------------------------------------------------------------------------
procedure TRura.DiagDblClick(Sender: TObject);
var
  df      :TDiagForm;
  //pdf     :TPntDiagFun;
begin
  df := TDiagForm.Create( self );
  df.DiagFunctionH.OnValue := DiagFunctionHValue;
  SetMaxDiag( df.Diag, df.DiagFunctionH );
  df.Q := Qm3h;
  df.H := delH;
  df.ShowModal;
  df.Free;
end;


//---------------------------------------------------------------------------
procedure TRura.TempEditExit(Sender: TObject);
var
  aT      :Double;
begin
   if TempEdit.Modified then
   begin
     aT := StrToFloat(TempEdit.text);
     if (Ciecz.TMin <= aT) and (aT <= Ciecz.TMax) then
     begin
       t := aT;
       FLockedComp := TempEdit;
       Aktualizuj;
       TempEdit.Modified := false;
     end
     else
     begin
       ShowMessageFmt( 'Dopuszczalny zakres %.0f - %.0f', [Ciecz.TMin, Ciecz.TMax]);
     end;
   end;
end;


procedure TRura.UsunPUMIClick(Sender: TObject);
begin
  UsunAktualnyElement;
end;

procedure TRura.UsunAktualnyElement;
begin
  if (ListPos>=0) and (ElList.Count > 0) then
  begin
    if Application.MessageBox(
                     PChar(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Czy na pewno usunac element')),
                     PChar(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Potwierdz')),
                   MB_ICONQUESTION or MB_YESNO ) = IDYES then
    begin
      UsunElem( ListPos );
    end;
  end;
end;

procedure TRura.SiatkaOPopUpPopup(Sender: TObject);
begin
  if (ListPos<0) or (ElList.Count <= 0) then
  begin
    UsunPUMI.Enabled := false;
    EditPUMI.Enabled := false;
  end
  else
  begin
    UsunPUMI.Enabled := true;
    EditPUMI.Enabled := true;
  end
end;



procedure TRura.OpenDoc;
var
  FN      :string;
begin
  if OpenDialog.Execute then
  try

  except

  end;
end;


procedure  TRura.SaveDoc;
begin
end;



procedure  TRura.SaveDocAs;
begin
end;


procedure TRura.SaveMenuClick(Sender: TObject);
begin
  SaveDoc;
end;

procedure TRura.PrzeglEl;
var
  S,Text,Text1      : string;
  NowyObj           : TElemAbstract;
  ElemForm          : TElemAbstPrzeplFrm;
  modal             : Boolean;
begin

  NowyObj := NIL;
  if Tabela = NIL then
    EXIT;

  ElemForm := NIL;

  NowyObj := CreateElemFromDB( DB );
  if NowyObj <> NIL then
  begin
    modal := FormStyle <> fsMDIChild;
    NowyObj.L := 1;
    ElemForm := TElemAbstPrzeplFrm(NowyObj.DajOkno( 'V' ));
    if ElemForm <> NIL then
    begin
      ElemForm.Ciecz := Ciecz;
      ElemForm.DestroyElOnFree := true;
      if modal then
      begin
        if ElemForm.FormStyle = fsMDIChild then
        begin
          ElemForm.Hide;
          ElemForm.FormStyle := fsNormal;
        end;
      end;
      //ElemForm.FormStyle := fsNormal;
      //ElemForm.Hide;
      if Modal then
        ElemForm.ShowModal
      else
        ElemForm.Show;
    end;
    //NowyObj.Free;
  end;

end;



procedure TRura.PrzeglSiatPUMIClick(Sender: TObject);
begin
  PrzeglEl;
end;



procedure TRura.SiatkaPopUpPopup(Sender: TObject);
var
  rn, rc  :Longint;
  Enb     :Boolean;
begin
  if (Tabela = NIL) or (not Tabela.Active) then
  begin
    Enb := false;
  end
  else
  begin
    rc  := Tabela.RecordCount;
    if rc > 0 then
      Enb := true
    else
      Enb := false;
  end;

  if Enb then
  begin
    PrzeglSiatPUMI.Enabled  := true;
    DodajSiatPUMI.Enabled := true;
  end
  else
  begin
    PrzeglSiatPUMI.Enabled  := false;
    DodajSiatPUMI.Enabled := false;
  end;

end;


procedure TRura.PodgladRaportuMenuClick(Sender: TObject);
var
  pf      :TForm;
begin
  if ElList.Count = 0 then
  begin
    ShowMessage(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Nie ma zadnego elementu'));
    EXIT;
  end;
//  pf := TPrevForm.Create(KopReportForm);
//  with (KopReportForm as TKopReportForm) do
//  begin
//    PrevForm := pf;
//    QRep.PreviewModeless;
//    pf.ShowModal;
//    pf.Free;
//    PrevForm := NIL;
//  end;
end;


procedure TRura.WydrukRaportuMenuClick(Sender: TObject);
begin
  if ElList.Count = 0 then
  begin
    ShowMessage(TTlumacz.DajObiekt.ZnajdzTlumaczenie('Nie ma zadnego elementu'));
    EXIT;
  end;
//  (KopReportForm as TKopReportForm).QRep.ReportTitle := RapTitle;
//  (KopReportForm as TKopReportForm).QRep.Print;
end;

procedure TRura.QEditKeyPress(Sender: TObject; var Key: Char);
var
  ExitProc :TNotifyEvent;
  a : TFormatSettings;

begin
  if (Key = '.') or (Key = ',') then
    // Key := DecimalSeparator;
    Key := a.DecimalSeparator;

  // if (Key >= ' ') and (not (Key in ['0'..'9', DecimalSeparator])) then
  if (Key >= ' ') and (not (Key in ['0'..'9', a.DecimalSeparator])) then

    Key := #0;
  if (Sender is TEdit) then
  begin
    if Key = #13 then
    begin
      if Addr(TEdit(Sender).OnExit) <> NIL then
        TEdit(Sender).OnExit(Sender);
      //TempEditExit( TempEdit );
      Key := #0;
    end;
  end;
end;

procedure TRura.SiatkaFormulDblClick(Sender: TObject);
begin
  DodajFormule;
end;


procedure TRura.DodajFormule;
var
  p       :pointer;
  NowyObj :TElemAbstract;
  DodajElemForm     : TElemAbstPrzeplFrm;

begin
  p := ListaFormul.Items[SiatkaFormul.Row-1];
  if (p <> NIL) then
  begin
    NowyObj := TElemAbstractClass(p).Create1;
    NowyObj.l := 1;
    if NowyObj <> NIL then
    begin
      NowyObj.Nazwa := SiatkaFormul.Cells[1, SiatkaFormul.Row ];
      DodajElemForm := TElemAbstPrzeplFrm(NowyObj.DajOkno( '+Ed' ));
      if DodajElemForm <> NIL then
      begin
        DodajElemForm.FreeOnClose := true;
        DodajElemForm.Ciecz := Ciecz;
        //DodajElemForm.ViewBtn.OnClick := PrzeglSiatPUMIClick;
        DodajElemForm.ShowModal;
        if (DodajElemForm.ModalResult = mrOK) and (not Demo) and (NowyObj.d > 0) then
          DodajElem(NowyObj)
        else
          NowyObj.Free;
        if Demo then
          DemoMsg;
      end
      else     // nie ma okna
        NowyObj.Free;
    end;
  end;
end;

procedure TRura.DodFormuleMIClick(Sender: TObject);
begin
  DodajFormule;
end;

procedure TRura.SiatkaFormulMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  GC      :TGridCoord;
begin
   //GC := SiatkaFormul.MouseCoord( X, Y );
   if {(GC.Y > 0) and} (ssLeft in Shift) and (not (ssDouble in Shift)) then
     SiatkaFormul.BeginDrag( false );
end;

procedure TRura.EditPUMIClick(Sender: TObject);
var
  F       :TElemAbstPrzeplFrm;
begin
  F := ElList.List[ListPos].DajOkno( '+Ed' ) as TElemAbstPrzeplFrm;
  if F <> NIL then
  begin
    F.Ciecz := Ciecz;
    F.ShowModal;
    Aktualizuj;
  end;
  F.Free;
end;

procedure TRura.Aktualizuj;
begin
  LabQJed.Caption := CapQ;
  if (Zadanie = NIL) or AktualLocked then
    EXIT;
  LockAktual;
  try
    if Inited then
    begin
      SiatkaO.RowCount := Max(ListCnt+1, 2);
      AktualForm;
      PntDiagFun.Q := Qm3h;
    end;
    FLockedComp := NIL;
  finally
    UnlockAktual;
  end;
end;

function TRura.GetZad: TKopZad;
begin
  result := Zad as TKopZad;
end;

function TRura.GetElList: TElemList;
begin
  if Zadanie <> NIL then
    result := Zadanie.ElList
  else
    result := NIL;
end;

constructor TRura.Create(O: TComponent);
begin
  inherited Create(O);
  ListaFormul :=TList.Create;

  demo := ZetonFile.ReadBool( 'KOP', 'demo', true );
  {
  if not Demo then
  begin
    WlascLic := ZetonFile.ReadString( 'LICENCJA KOP', 'Wlasciciel', '');
    if WlascLic = '' then
      Demo := true;
  end;
  }

  with SiatkaFormul do
  begin
    RowCount := 6;
    Cells[ 1, 0] := 'Nazwa Formuly';

    Cells[ 1, 1] := 'Polska Norma';
    ListaFormul.Add( TElemAbstractClass(TPNElem) );

    Cells[ 1, 2] := 'Opor miejscowy';
    ListaFormul.Add( TElemAbstractClass(TOporMiejscowyFormula) );

    Cells[ 1, 3] := 'Nikuradze';
    ListaFormul.Add( TElemAbstractClass(TNikElem) );

    Cells[ 1, 4] := 'Colebrooka i White''a';
    ListaFormul.Add( TElemAbstractClass(TColWElem) );

    Cells[ 1, 5] := 'Altsul';
    ListaFormul.Add( TElemAbstractClass(TAltsulElem) );

  end;

  PntDiagFun := TPntDiagFun.Create(self);
  DiagFunPPracy.Drawer := PntDiagFun;

  SiatkaO.Cells[0,0] := 'L.p.';
  SiatkaO.Cells[1,0] := 'Nazwa elementu';
  SiatkaO.Cells[2,0] := 'Dlugosc/Sztuk';
  SiatkaO.Cells[3,0] := 'Srednica [mm]';
  SiatkaO.Cells[4,0] := 'Opor [m]';
  SiatkaO.Cells[5,0] := 'Opor [kPa]';
  SiatkaO.Cells[6,0] := 'V przepl [m/s]';
  SiatkaO.Cells[7,0] := 'Re';

  //KopReportForm := TKopReportForm.Create(self);
  //(KopReportForm as TKopReportForm).rura := self;
  DefaultCloseAction := caHide;
end;

procedure TRura.FormCreate(Sender: TObject);
begin
  inherited;
  Hide;
  RapTitle := Caption;
  Color := GruKolorPusty;
end;

procedure TRura.SetCiecz(const Value: TCieczPlyw);
begin
  if FCiecz <> Value then
  begin
    FCiecz := Value;
    if Inited then
      Aktualizuj
    else
      AktualCieczEdits;
  end;   
end;

procedure TRura.AktualCieczEdits;
begin
  if Ciecz = NIL then
    EXIT;
  if DoAktNazwaCieczy then
    CieczCombo.Text := Ciecz.Nazwa;
  if FLockedComp <> QEdit then
    QEdit.Text := FormatFloat('0.00', m3hToU(Qm3h));
  if FLockedComp <> TempEdit then
    TempEdit.Text := FormatFloat('0.00', FCiecz.T);
  if FLockedComp <> GestEd then
    GestEd.Text := FormatFloat('0.00', FCiecz.Ro);
  if FLockedComp <> LepEd then
    LepEd.Text := FormatFloat('0.00', FCiecz.Ni_cSt);
  if FLockedComp <> PvEdit then
    PvEdit.Text := FormatFloat('0.00', FCiecz.Pv);
  QEdit.Modified := false;
  TempEdit.Modified := false;
  GestEd.Modified := false;
  LepEd.Modified := false;
  PvEdit.Modified := false;
end;


procedure TRura.SetEdycjaCieczy(const Value: Boolean);
var
  AColor   :TColor;
begin
  FEdycjaCieczy := Value;
  CieczGBox.Enabled := Value;
  QEdit.ReadOnly := not Value;
  TempEdit.ReadOnly := not Value;
  if Value then
    AColor := clYellow
  else
    AColor := clAqua;
  CieczGBox.TabStop := Value;
  QEdit.TabStop     := Value;
  TempEdit.TabStop  := Value;

  CieczCombo.Color := AColor;
  QEdit.Color := AColor;
  QEdit.Color := AColor;
  if not Value then
    EdycjaParamCieczy := false;
end;

procedure TRura.SetEdycjaParamCieczy(const Value: Boolean);
var
  AColor   :TColor;
begin
  FEdycjaParamCieczy := Value;
  if Value then
    AColor := clYellow
  else
    AColor := clAqua;
  GestEd.ReadOnly := not Value;
  LepEd.ReadOnly := not Value;
  PvEdit.ReadOnly := not Value;
  GestEd.TabStop := Value;
  LepEd.TabStop := Value;
  PvEdit.TabStop := Value;
  GestEd.Color := AColor;
  LepEd.Color := AColor;
  PvEdit.Color := AColor;

end;


procedure TRura.SiatkaFormulStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  inherited;
  DragObject := NIL;
end;

procedure TRura.SetZad(Z: TZadanie);
begin
  LockAktual;
  try
    inherited;
    if Zadanie = NIL then
      EXIT;
    if Zadanie.Ciecz <> NIL then
      Ciecz := Zadanie.Ciecz;
    EdycjaCieczy := Zadanie.EdycjaCieczy;
    //2024.10.17(KopReportForm as TKopReportForm).Zadanie := Zadanie;
  finally
    UnlockAktual;
  end;
  Aktualizuj;
end;

procedure TRura.SaverLoadProperty(Sender: TObject; var APath: String;
  var Value: Variant; TypeKind: TTypeKind; var Allow: Boolean);
begin
  inherited;
  if (CompareText(APath, 'LeftPanel.Width') = 0)
     or (CompareText(APath, 'ElemPanel.Height') = 0)
     or (CompareText(APath, 'CharPanel.Height') = 0) then
    if Value = 0 then
      Value := 1;
end;


procedure TRura.GestEdExit(Sender: TObject);
begin
  if GestEd.ReadOnly or (not GestEd.Modified) then
    EXIT;
  if Zadanie.CieczRodz is TCieczConst then
  begin
    TCieczConst(Zadanie.CieczRodz).Ro := StrToFloat(GestEd.Text);
    FLockedComp := GestEd;
    Aktualizuj;
    GestEd.Modified := false;
  end;
end;

procedure TRura.LepEdExit(Sender: TObject);
begin
  if LepEd.ReadOnly or (not LepEd.Modified) then
    EXIT;
  if Zadanie.CieczRodz is TCieczConst then
  begin
    TCieczConst(Zadanie.CieczRodz).Ni_cSt := StrToFloat(LepEd.Text);
    FLockedComp := LepEd;
    Aktualizuj;
    LepEd.Modified := false;
  end;
end;

procedure TRura.PvEditExit(Sender: TObject);
begin
  if PvEdit.ReadOnly or (not PvEdit.Modified) then
    EXIT;
  if Zadanie.CieczRodz is TCieczConst then
  begin
    TCieczConst(Zadanie.CieczRodz).Pv := StrToFloat(PvEdit.Text);
    FLockedComp := PvEdit;
    Aktualizuj;
    PvEdit.Modified := false;
  end;
end;

function TRura.DoAktNazwaCieczy: Boolean;
begin
  result := true;
end;

procedure TRura.FormDestroy(Sender: TObject);
begin
  inherited;
  if DoSave then
    Saver.Save;
end;

procedure TRura.Button1Click(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TRura.SiatkaODblClick(Sender: TObject);
begin
  inherited;
  EditPUMIClick(self);
end;

procedure TRura.SiatkaFormulClick(Sender: TObject);
begin
  if SiatkaFormul.Selection.Right = 2 then
  begin
    DodajFormule;
    SiatkaFormul.BeginDrag( false );
  end;
end;

procedure TRura.SiatkaOClick(Sender: TObject);
begin
  if SiatkaO.Selection.Right = 8 then
    UsunAktualnyElement;
end;

procedure TRura.SiatkaDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
 Value  : string;
 Format : UINT;
 r      : TRect;
begin
  if DataCol = 0 then
    begin
     Value := TTlumacz.DajObiekt.ZnajdzTlumaczenie(column.Field.DisplayText);
     r.Left := Rect.Left+2;
     r.Top  := Rect.Top +1;
     r.Right := Rect.Right;
     r.Bottom := Rect.Bottom;
     Format := DT_VCENTER;
     case column.Alignment of
       taCenter       : Format := Format And DT_CENTER;
       taRightJustify : Format := Format And DT_RIGHT;
       taLeftJustify  : Format := Format And DT_LEFT;
     end;
     Siatka.Canvas.FillRect(rect);
     DrawText(siatka.Canvas.Handle, PChar(Value), length(Value), r, Format);
    end
    else
   if DataCol < 5 then
      siatka.DefaultDrawColumnCell(Rect,DataCol,Column,State)
   else
     if Assigned(Tabela) then
        if tabela.RecordCount>0 then
           begin
             Siatka.Canvas.FillRect(rect);
             ImageList1.Draw(Siatka.Canvas,Rect.Left,Rect.top-1,1,true)
           end
         else
           Siatka.Canvas.FillRect(rect);
end;

procedure TRura.SiatkaCellClick(Column: TColumn);
begin
  inherited;
  if Column.Index = 5 then
  begin
    Siatka.BeginDrag(false);
    SiatkaDblClick(nil);
  end;
end;

procedure TRura.SiatkaFormulDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
 if ACol = 2 then
    if ARow >0 then
       ImageList1.Draw(SiatkaFormul.Canvas,Rect.Left,Rect.top-1,1,true)
end;

procedure TRura.SiatkaOMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var gc : TGridCoord;
begin
 gc := SiatkaO.MouseCoord(x,y);
 if (gc.X = 8)and(ElList.Count > 0) then
 begin
   SiatkaO.Hint := TTlumacz.dajObiekt.ZnajdzTlumaczenie('Usuwanie elementu listy');
   SiatkaO.ShowHint := true;
 end
  else begin
         SiatkaO.Hint := '';
         SiatkaO.ShowHint := false;
       end;

end;

procedure TRura.SiatkaFormulMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var gc : TGridCoord;
begin
 with SiatkaFormul do
 begin
   gc := MouseCoord(x,y);
   if (gc.X = 2) then
   begin
     Hint := TTlumacz.dajObiekt.ZnajdzTlumaczenie('Dodaj do rurociagu');
     ShowHint := true;
   end
    else begin
           Hint := '';
           ShowHint := false;
         end;
 end;

end;

procedure TRura.SiatkaMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var gc : TGridCoord;
begin
 with Siatka do
 begin
   gc := MouseCoord(x,y);
   if (gc.X = 6) and (tabela.RecordCount>0) then
   begin
     Hint := TTlumacz.dajObiekt.ZnajdzTlumaczenie('Dodaj do rurociagu');
     ShowHint := true;
   end
    else begin
           Hint := '';
           ShowHint := false;
         end;
 end;

end;

procedure TRura.FormShow(Sender: TObject);
var
    i : Integer;
begin
  TTlumacz.dajObiekt.Tlumacz(self);
  RapTitle := Caption;
  for i := 0 to siatka.Columns.Count - 1 do
   with siatka.Columns[i].Title do
        Caption := TTlumacz.DajObiekt.ZnajdzTlumaczenie(Caption);
end;

end.
