unit FPompy;
{-------------------------------------------------------------------------
| Formularz pompy - parametry, wykresy, rysunek, ...
|
\-------------------------------------------------------------------------}

interface

uses
  Windows, ShellApi, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, TabNotBk, Tabs, ExtCtrls, DBTables, DB,
  DBCtrls, StdCtrls, Buttons, Strform, SpeedButtonExtU,
  Printers, Grids, DBGrids, Clipbrd,
  Diagrams, ObjView, EditNew,
  Math,
  KR_Sys, KrMath,
  //PodgladRaportU, RaportPustyU,
  JezykTxt, TBS_Defs,
  Prod,
  DGraph,
  WkpGlob,
  CursorsDM,
  PompMath,
  PmpBaseInfoU,
  KR_Ctrls,
  KR_DB,
  TBS_Tool,
  TbsU,
  Ciecze, jezyki,
  CieczPrzelU, FreqFormU,
  OPompa, LinCharU, B4CharU, RysFrm, DXFDraws, MotorsU, DXFDrawer,
  PompDXF, ComCtrls, IniFiles, CieczeFrm, KopDraw1,
  CustPmpCharViewU ,WPmpCharViewerU, RegTools,
  SavePmpAsFrmU, MotorObjU, PompMotU, PompaCharNaturU, Menus, OleCtrls,
  //PdfLib_TLB, AcroPDFLib_TLB,
  AbstractFormPompyU, frxClass, frxCrypt;


type
  TPntNominalFun = class;

  TFunCheckRec = record
    DiagFun :TDiagFunction;
    ChkB    :TCheckBox;
    Id      :string;
  end;

  // do przeniesienia do innego pliku
  TMoveFunType = (mftNone, mftMove, mftScaleUp, mftScaleDown);

  TFormPompy = class(TAbstractFormPompy)
    PakietPompy: TPageControl;
    TabParametry: TTabSheet;
    TabCharakterystyka: TTabSheet;
    TabRysunek: TTabSheet;
    TabSilnik: TTabSheet;
    TabOpis: TTabSheet;
    PompyDataSource: TDataSource;
    ZamknijBtn: TBitBtn;
    M_DataSource: TDataSource;
    TypSilnika: TLabel;
    MocSilnika: TLabel;
    PradZnamionowy: TLabel;
    Obroty: TLabel;
    NapiecieZnamionowe: TLabel;
    CosinusFi: TLabel;
    Sprawnosc: TLabel;
    SprawLab: TLabel;
    TypDBText: TDBText;
    ObrDBText: TDBText;
    MocDBText: TDBText;
    NapDBText: TDBText;
    PradDBText: TDBText;
    CosDBText: TDBText;
    OpisLab: TLabel;
    CharPanel: TPanel;
    RysLabel: TLabel;
    OpisView: TObjectView;
    G_DataSource: TDataSource;
    Diagram: TDiagram;
    HFun: TDiagFunction;
    PFun: TDiagFunction;
    NPSHFun: TDiagFunction;
    ETAFun: TDiagFunction;
    HDescr: TDiagDescr;
    NPSHDescr: TDiagDescr;
    PDescr: TDiagDescr;
    ETADescr: TDiagDescr;
    CharSelFun: TDiagFunction;
    PunktNomFun: TDiagFunction;
    QJednDescr: TDiagDescr;
    TabRaport: TTabSheet;
    PanelDoWst: TPanel;
    LabMoc: TLabel;
    LabObroty: TLabel;
    LabPrad: TLabel;
    LabCos: TLabel;
    labSprawJedn: TLabel;
    LabSilnik: TLabel;
    DiagDescrNazwa: TDiagDescr;
    TabPrzeliczenia: TTabSheet;
    GBoxPompa: TGroupBox;
    GBoxCiecz: TGroupBox;
    PrzeliczDiag: TDiagram;
    PrzHFun: TDiagFunction;
    PrzPFun: TDiagFunction;
    PrzHFunOrg: TDiagFunction;
    PrzPFunOrg: TDiagFunction;
    PrzEtaFun: TDiagFunction;
    PrzEtaFunOrg: TDiagFunction;
    StopOchrLab: TLabel;
    KlIzolLab: TLabel;
    StopOchrText: TDBText;
    KlIzolText: TDBText;
    RysSaveDialog: TSaveDialog;
    CharSaveDlg: TSaveDialog;
    PrzelObrPan: TPanel;
    PrzelObrNomLab: TLabel;
    PrzObrWymEd: TEditN;
    PrzelSrednPan: TPanel;
    PrzSredWymEd: TEditN;
    PrzSredNomLab: TLabel;
    PrzelObrLab: TLabel;
    PrzelObrJednLab: TLabel;
    PrzelObrNomTxtLab: TLabel;
    PrzelSrednLab: TLabel;
    PrzelSrednJednLab: TLabel;
    PrzelSrednNomLab: TLabel;
    PrzelSrednZakTxtLab: TLabel;
    PrzelSrednZakrLab: TLabel;
    PrzelCieczeCombo: TComboBox;
    PrzCieczTempEd: TEditN;
    PrzCieczTempLab: TLabel;
    PrzelCieczRoPan: TPanel;
    PrzGestEd: TEditN;
    PrzCieczGestLab: TLabel;
    PrzCieczNiPan: TPanel;
    PrzLepEd: TEditN;
    PrzCieczLepLab: TLabel;
    CharPrzelGBox: TGroupBox;
    HPrzelChk: TCheckBox;
    PPrzelChk: TCheckBox;
    EtaPrzelChk: TCheckBox;
    CharOrygGBox: TGroupBox;
    HOrygChk: TCheckBox;
    POrygChk: TCheckBox;
    EtaOrygChk: TCheckBox;
    PrzRoJednLab: TLabel;
    PrzNiJednLab: TLabel;
    MotorObrFun: TDiagFunction;
    MotorPradFun: TDiagFunction;
    MotorCosFFun: TDiagFunction;
    MotorEtaFun: TDiagFunction;
    LepkMetodaCombo: TComboBox;
    PrzelKomunikMemo: TMemo;
    WarMDataSrc: TDataSource;
    PanelWariantow: TPanel;
    WarSplitter: TSplitter;
    ParametryScrollBox: TScrollBox;
    CenaDataBox: TGroupBox;
    CenaLab: TLabel;
    DataLab: TLabel;
    CenaDBText: TDBText;
    DataDBText: TDBText;
    LabCena: TLabel;
    gbRzeczywiste: TGroupBox;
    LabQR: TLabel;
    labWyso: TLabel;
    labMocr: TLabel;
    labSpraw: TLabel;
    labQrVal: TLabel;
    labHrVal: TLabel;
    labPrVal: TLabel;
    labETArVal: TLabel;
    labNPSH: TLabel;
    labNPSHrVal: TLabel;
    labQrJedn: TLabel;
    labHrJedn: TLabel;
    labPrJedn: TLabel;
    labEtarJedn: TLabel;
    labNPSHrJedn: TLabel;
    labOdchylQ: TLabel;
    labOdchylH: TLabel;
    LabQrProcent: TLabel;
    LabHrProcent: TLabel;
    gbWymagane: TGroupBox;
    LabQw: TLabel;
    LabWys: TLabel;
    labQWym: TLabel;
    labHwym: TLabel;
    lab_m3_h: TLabel;
    lab_m: TLabel;
    ParSilnGrBox: TGroupBox;
    TypSilnLab: TLabel;
    MocSilnLab: TLabel;
    ObrSilnLab: TLabel;
    NapSilnLab: TLabel;
    TypSilnText: TDBText;
    MocSilnText: TDBText;
    N_SilnText: TDBText;
    USilnLab: TDBText;
    LabMocS: TLabel;
    LabObrS: TLabel;
    ParNomBox: TGroupBox;
    WydTytLabel: TLabel;
    QnDBText: TDBText;
    PodnText: TDBText;
    PodnTytLabel: TLabel;
    MocTytLabel: TLabel;
    ObrTytLabel: TLabel;
    MocText: TDBText;
    ObrText: TDBText;
    MasaText: TDBText;
    MasaTytLabel: TLabel;
    LabQJed: TLabel;
    LabH: TLabel;
    LabkW: TLabel;
    LabObr: TLabel;
    LabM: TLabel;
    WarMGrid: TStringGrid;
    PrzelHDescr: TDiagDescr;
    PrzelPDescr: TDiagDescr;
    PrzelEtaDescr: TDiagDescr;
    PrzelQDescr: TDiagDescr;
    SaveToUserBtn: TSpeedButton;
    CharCtrlScroll: TScrollBox;
    CalcPanel: TPanel;
    CalcQLab: TLabel;
    CalcHLab: TLabel;
    CalcPLab: TLabel;
    CalcNPSHLab: TLabel;
    CalcEtaLab: TLabel;
    CalcQEd: TEditN;
    CalcHEd: TEditN;
    CalcPEd: TEditN;
    CalcNPSHEd: TEditN;
    CalcEtaEd: TEditN;
    cbPunktNom: TCheckBox;
    cbCharSel: TCheckBox;
    cbEta: TCheckBox;
    cbNPSH: TCheckBox;
    cbP: TCheckBox;
    cbH: TCheckBox;
    cbP_Mot: TCheckBox;
    PrzP_MotFun: TDiagFunction;
    P_MotFun: TDiagFunction;
    ZastKonstrZakladki: TPageControl;
    ZastosowaniaSheet: TTabSheet;
    ZastListBox: TListBox;
    KonstrukcjeSheet: TTabSheet;
    KonstrukcjeListBox: TListBox;
    TMaxTytLabel: TLabel;
    TminTytLabel: TLabel;
    T_DataSource: TDataSource;
    TMinText: TDBText;
    TMaxText: TDBText;
    LabTMin: TLabel;
    LabTMax: TLabel;
    cbEtaAgr: TCheckBox;
    EtaAgrFun: TDiagFunction;
    FreqCalcBtn: TSpeedButton;
    OpisRPanel: TPanel;
    HTML_Btn: TBitBtn;
    RysTabs: TTabControl;
    RysPanel: TPanel;
    Rysunek: TPaintBox;
    RysRPanel: TPanel;
    CopyRysBtn: TSpeedButton;
    ZoomBtn: TSpeedButton;
    RysSaveAsBtn: TBitBtn;
    TabCharNaturalna: TTabSheet;
    panCharNatPrawy: TPanel;
    panCharNatMain: TPanel;
    diagCharNat: TDiagram;
    dfunHNat: TDiagFunction;
    dfunPNat: TDiagFunction;
    dfunHNatOrg: TDiagFunction;
    dfunPNatOrg: TDiagFunction;
    dfunPNatElektr: TDiagFunction;
    dfunNNat: TDiagFunction;
    dfunEtaNatOrg: TDiagFunction;
    dfunEtaNatElektr: TDiagFunction;
    ddscCharNat: TDiagDescr;
    grpbCharNat: TGroupBox;
    chkHNat: TCheckBox;
    chkPNat: TCheckBox;
    chkPNatElektr: TCheckBox;
    chkEtaNatAgr: TCheckBox;
    chkNNat: TCheckBox;
    grpbNatNConst: TGroupBox;
    chkHNatOrg: TCheckBox;
    chkPNatOrg: TCheckBox;
    chkEtaNatOrg: TCheckBox;
    ddscHNat: TDiagDescr;
    ddscNNat: TDiagDescr;
    ddscPNat: TDiagDescr;
    ddscEtaNat: TDiagDescr;
    ddscQNat: TDiagDescr;
    ColorDialog: TColorDialog;
    labCharPrzelDopasuj: TLabel;
    labCharPrzelDopasQ: TLabel;
    edCharPrzelDopasQ: TEditN;
    labCharPrzelDopasH: TLabel;
    edCharPrzelDopasH: TEditN;
    sbtnPrzelObrDopas: TSpeedButton;
    sbtnPrzelSrednDopas: TSpeedButton;
    PrzHFunPktDop: TDiagFunction;
    pmnuDiagram: TPopupMenu;
    mnuDiagCopy: TMenuItem;
    mnuDiagSaveAs: TMenuItem;
    mnuDiag4Pola: TMenuItem;
    mnuDiagPolacz: TMenuItem;
    mnuDiagDiv1: TMenuItem;
    mnuDiagOpisyCharakterystyk: TMenuItem;
    bbtnProdSiln: TBitBtn;
    pmnuDiagUsunDz: TMenuItem;
    pmnuDiagDodajDz: TMenuItem;
    pmnuPrzeliczDiagram: TPopupMenu;
    pmnuPrzelDiagCopy: TMenuItem;
    mnuDiagEksport: TMenuItem;
    mnuDiagEksportH: TMenuItem;
    EpanetCharSaveDlg: TSaveDialog;
    mnuDiagEksportETA: TMenuItem;
    dgdscrTypCharakterystyki: TDiagDescr;
    sbtnRysInfo: TSpeedButton;
    TabPDF: TTabSheet;
    Button1: TButton;
    DBTextPDF: TDBText;
    EditSciezkaPdf: TEdit;
    LabPel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LabQnKopia: TLabel;
    Label1: TLabel;
    Label7: TLabel;
    DBTextDt: TDBText;
    Label8: TLabel;
    Label9: TLabel;
    LabZiarno: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    LabPelr: TLabel;
    Label13: TLabel;
    GroupBoxIndex: TGroupBox;
    LabIndex: TLabel;
    LabTypPompy: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    DBText1: TDBText;
    DiagFunP1: TDiagFunction;
    cbP1: TCheckBox;
    PanelDoAcrobata: TPanel;
    Button2: TButton;
    frxCrypt1: TfrxCrypt;
    frxReport1: TfrxReport;
    procedure ZamknijBtnClick(Sender: TObject);
    procedure RysunekPaint(Sender: TObject);
    procedure cbHClick(Sender: TObject);
    procedure cbPClick(Sender: TObject);
    procedure cbNPSHClick(Sender: TObject);
    procedure cbEtaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
    procedure CopyCharBtnClick(Sender: TObject);
    procedure CopyRysBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbCharSelClick(Sender: TObject);
    procedure cbPunktNomClick(Sender: TObject);
    procedure PakietPompyChange(Sender: TObject);
    procedure CalcQEdChange(Sender: TObject);
    procedure RysSaveAsBtnClick(Sender: TObject);
    procedure CharSaveAsBtnClick(Sender: TObject);
    procedure PrzelCieczeComboChange(Sender: TObject);
    procedure PrzCieczTempEdAccept(Sender: TObject; var Accept: Boolean);
    procedure PrzObrWymEdAccept(Sender: TObject; var Accept: Boolean);
    procedure PrzSredWymEdAccept(Sender: TObject; var Accept: Boolean);
    procedure PrzGestEdAccept(Sender: TObject; var Accept: Boolean);
    procedure HPrzelChkClick(Sender: TObject);
    procedure PPrzelChkClick(Sender: TObject);
    procedure EtaPrzelChkClick(Sender: TObject);
    procedure HOrygChkClick(Sender: TObject);
    procedure POrygChkClick(Sender: TObject);
    procedure EtaOrygChkClick(Sender: TObject);
    procedure PrzLepEdAccept(Sender: TObject; var Accept: Boolean);
    procedure SilnikDXFCreateDrawing(Sender: TObject;
      var ADrawing: TDXFDrawing);
    procedure MotorObrFunValue(X: Double; var Y: Double);
    procedure MotorPradFunValue(X: Double; var Y: Double);
    procedure MotorCosFFunValue(X: Double; var Y: Double);
    procedure MotorEtaFunValue(X: Double; var Y: Double);
    procedure LepkMetodaComboChange(Sender: TObject);
    procedure HTML_BtnClick(Sender: TObject);
    procedure WarMDBGridCellClick(Column: TColumn);
    procedure PakietPompyResize(Sender: TObject);
    procedure WarMGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DiagramDblClick(Sender: TObject);
    procedure SaveToUserBtnClick(Sender: TObject);
    procedure CharCalcPolBtnClick(Sender: TObject);
    procedure PrzP_MotFunValue(X: Double; var Y: Double);
    procedure cbP_MotClick(Sender: TObject);
    procedure TabPrzeliczeniaShow(Sender: TObject);
    procedure EtaAgrFunValue(X: Double; var Y: Double);
    procedure cbEtaAgrClick(Sender: TObject);
    procedure FreqCalcBtnClick(Sender: TObject);
    procedure Char4BtnClick(Sender: TObject);
    procedure WarMGridDblClick(Sender: TObject);
    procedure TypDBTextDblClick(Sender: TObject);
    procedure RysTabsChange(Sender: TObject);
    procedure dfunPNatElektrValue(X: Double; var Y: Double);
    procedure dfunNNatValue(X: Double; var Y: Double);
    procedure dfunEtaNatElektrValue(X: Double; var Y: Double);
    procedure chkCharClick(Sender: TObject);
    procedure chkCharMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabCharNaturalnaShow(Sender: TObject);
    procedure edCharPrzelDopasQChange(Sender: TObject);
    procedure edCharPrzelDopasHChange(Sender: TObject);
    procedure sbtnPrzelObrDopasClick(Sender: TObject);
    procedure sbtnPrzelSrednDopasClick(Sender: TObject);
    procedure mnuDiagOpisyCharakterystykClick(Sender: TObject);
    procedure sbtnDiagKonfPlusClick(Sender: TObject);
    procedure sbtnDiagKonfMinusClick(Sender: TObject);
    procedure DiagramMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DiagramMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DiagramMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pmnuPrzelDiagCopyClick(Sender: TObject);
    procedure mnuDiagEksportHClick(Sender: TObject);
    procedure pmnuDiagramPopup(Sender: TObject);
    procedure mnuDiagEksportETAClick(Sender: TObject);
    procedure sbtnRysInfoClick(Sender: TObject);
    procedure TabPDFShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TabCharakterystykaShow(Sender: TObject);
    procedure DiagFunP1Value(X: Double; var Y: Double);
    procedure cbP1Click(Sender: TObject);
    procedure cbP1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PanelDoAcrobataResize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FCharViewer   :TWPmpCharViewer;
    F4CharViewer  :TCustomPmpCharViewer;
    PrzelCharData :TFuncCharData;
    PrzelCieczCharData  :TPompCieczCharData;
    FPrzelPunktDFun     :TPntDiagFun;
    FPrzelCieczPlyw     :TCieczPlyw;
    FPrzelCieczRodzaj   :TCieczRodzaj;
    CharNatur           :TSZCharDataCopy; //charakterystyka naturalna do przeliczen
    CieczeForm          :TCieczeForm;
    FFunChkArray        : array of TFunCheckRec;
    //FrmPrev       : TPodgladRaport;
    //Rap           : TRaportPusty;
    FRapClosed    : Boolean;
    IsMemo        : Boolean;

    PrzelInited :Boolean;
    MoznaPrzelCiecz :Boolean;
    MotorGTable :TTable;
    MotorChar   :TMotorCharOdP;
    FMotObj     :TMotorObject;
    MBMList     :array of TBookmarkStr;
    FDiagEdit   :Boolean;
    FMovedFun   :TDiagFunction;
    FMvFunVal   :Double;
    FMvFunSkok  :Double;
    FMvFunType  :TMoveFunType;
    //LPkt     : TLpktFiz;
    {RysMF    : TDrawMetaFile;}

    //pdf : TPDF;
    PDFView :  TOleControl;

    procedure AddFunChk( AFun :TDiagFunction;
                         AChkB :TCheckBox;
                         const AId :string ); // Identyfikator do zapisywania
              // dodaj powiazanie funkcja_na_wykresie <-> CheckBox

    procedure SetFunChkColor( AChkB :TCheckBox; AColor :TColor );
    procedure FunChkClick( AChkB :TCheckBox );
    procedure SetCheckColor( AChkB :TCheckBox; bc :TColor );

    procedure SetParRzecz;
    procedure SetInner;
    procedure InitZastList;
    procedure InitKonstrList;
    procedure InitDiagr;
    procedure InitRys;
    function  OblEta: Double;

    procedure UWMSetLang( var msg :TMessage );    message UWM_SET_LANG;
    procedure TBSM_Print( var msg :TMessage );    message TBSM_PRINT;
    procedure TBSM_CanPrint( var msg :TMessage ); message TBSM_CAN_PRINT;
    procedure TBSM_Unit( var msg :TMessage ); message TBSM_UNIT;

    procedure PrzelInit;
    procedure PrzelDiagrMinMax;
    procedure InitDiagrPrzel;
    procedure InitMWarTab;
    procedure InitCharNat( mo :TMotorElektr );
    procedure Przelicz;
    procedure SetDopasEnabled;
    function  KopiaPompyPrzeliczonej :TPompa;
    procedure PrzelWyswParCieczy;
    function GetRysMetaFile: TMetafile;
    function GetCharMetaFile: TMetafile;
    procedure SetPrzelCieczPlyw(const Value: TCieczPlyw);
    procedure SetPrzelCieczRodzaj(const Value: TCieczRodzaj);

    property PrzelCieczRodzaj :TCieczRodzaj read FPrzelCieczRodzaj write SetPrzelCieczRodzaj;
    property PrzelCieczPlyw   :TCieczPlyw read FPrzelCieczPlyw write SetPrzelCieczPlyw;
    function GetNazwaPompyFN: string;
    procedure CreateRap;
    function  CreateMotObj :TMotorObject;
    procedure ShowProdM;
    procedure UpdateCharAgr;
    function GetDXFDraw: TPompDXFDrawing;
    procedure ClearDxfs;
    procedure EnableHTMLBtn;
    procedure UtworzPDF(s :string);
  protected
    procedure SetLang;    virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CloseRap;

  protected
    FDxfs     :array of TPompDXFDrawing;
    FWarGBM   :TStringList;
    IsWarG    :Boolean;
    CharData  :TPompCharData;
    procedure WypelnijRzeczywiste;                      virtual;
    procedure InitCharNatFrst;                          virtual;

  public
    { Public declarations }
    PntNominalnyFun   : TPntNominalFun;

    constructor StworzDlaPompy( AOwner: TComponent; APompa: TPompa;
                                AMDIChild :Boolean = true );   override;
    destructor  Destroy;  override;
    // Co to za funkcje??
    procedure   CharH( q: double; var h: double );
    procedure   CharP( q: double; var p: double );
    procedure   CharNPSH( q: double; var np: double );
    procedure   CharETA( q: double; var AEta: double );
    function    P_AgrOdQ( q :Double ) :Double;
    procedure   PrintEv( Sender: TObject );
    procedure   UpdateM;
    procedure   ShowCharViewer;
    procedure   Show4CharViewer;

    property NazwaPompyFN :string read GetNazwaPompyFN;
    property EtaSiln :Double      read OblEta;
    property DXFDraw  : TPompDXFDrawing read GetDXFDraw;
  end;

  TFormPompyClass = class of TFormPompy;

  TPntNominalFun = class (TDiagFunDrawer)
    private
      FQ, FH :Double;
    protected
      procedure DrawFun( dt :TSpecDrawData; bw :Boolean );   override;
    public
      property Q: Double   read FQ  write FQ;
      property H: Double   read FH  write FH;
  end;



var
  FormPompy: TFormPompy;

implementation

{$R *.DFM}

uses
  StdZadSzukPomp,
  //RaportPompyU, RapPompyBiaU,
  MotBaseInfoU, KatDataMU, KatFormTools, ActiveX;//, ComObj;

resourcestring
 NieMaAcrobata1 = 'Nie zainstalowany Adobe Acrobat Reader lub zla wersja';
 NieMaAcrobata2 = 'ZAINSTALUJ ADOBE ACROBAT READER Z PLYTY INSTALACYJNEJ';
 Blad = 'Blad';


{----------------------------------------------------------------------------}
constructor TFormPompy.StworzDlaPompy( AOwner: TComponent;
                                       APompa: TPompa; AMDIChild :Boolean = true );
var
  fld             :TField;
  bi              :TPumpsBaseInfo;
  ziarno          : double ; //dla grundfosa
  tmp             : ANSiString;
begin
  // OldCreateOrder := false;
  // FMDIChild := AMDIChild;
  inherited; //Create( AOwner );
  NazwaPompy := APompa.DB.A.FieldByName('Nazwa').AsString;
  if APompa.JestWBazie then
  begin
    FPompa := CreatePump( NIL, APompa.DB );
    FPompa.DBCreateCopy( APompa.DB );
  end
  else
  begin
    FPompa := APompa;
    FPompa.FreeNotification(self);
  end;
  FPompa.AddRef;
  bi := FPompa.DB.BaseInfo;
  if Pompa.DB.A.FieldByName('ID2').AsString = 'MEMO' then
  begin
    TabParametry.TabVisible := false;
    TabCharakterystyka.TabVisible := false;
    TabRysunek.TabVisible := false;
    TabSilnik.TabVisible := false;
    TabRaport.TabVisible := false;
    TabPrzeliczenia.TabVisible := false;
    IsMemo := true;
  end;
  PompyDataSource.DataSet := Pompa.DB.A;
  if (not Pompa.DB.mOK) or (Pompa.DB.M.FindField('prad') = NIL) then
    PradDBText.DataField := '';
  if (not Pompa.DB.mOK) or (Pompa.DB.M.FindField('CosF') = NIL) then
    CosDBText.DataField := '';

  cbEtaAgr.Visible := bi.tbsf.ReadBool( 'OPTIONS', 'FormPompy_cbEtaAgr', true );
  cbP_Mot.Visible := bi.tbsf.ReadBool( 'OPTIONS', 'FormPompy_cbP_Mot', true );
  cbPunktNom.Visible := bi.tbsf.ReadBool( 'OPTIONS', 'FormPompy_cbPunktNom', true );
  cbP1.Visible := bi.tbsf.ReadBool( 'OPTIONS', 'FormPompy_cbP1', true );

  T_DataSource.DataSet := FPompa.DB.T;
  M_DataSource.DataSet := FPompa.DB.M;
  if Pompa.DB.SaWarianty and Pompa.DB.RecWarM then
  begin
    WarMDataSrc.DataSet := Pompa.DB.WarM;
    TabSilnik.TabVisible := false;
    InitMWarTab;
  end
  else
  begin
    PanelWariantow.Visible := false;
    WarSplitter.Visible := false;
    //WarMDBGrid.Visible := false;
  end;

  G_DataSource.DataSet := FPompa.DB.G;
  RysLabel.Caption := NazwaPompy;
  LabTypPompy.Caption := ' '+ NazwaPompy;
  if ZetonFile.ReadBool( 'Katalog\Pompy', 'Index', false ) then
    begin
      ZastKonstrZakladki.Top := 56;
      GroupBoxIndex.Height := 49;
      LabIndex.Visible := true;
      LabIndex.Caption := ' Nr katalogowy: ' + APompa.DB.A.FieldByName('PRODUCTNO').AsString;
    end
  else
    begin
      LabIndex.Visible := false;
      GroupBoxIndex.Height := 32;
      ZastKonstrZakladki.Top := 39;
      LabIndex.Caption := '';
    end;

  InitZastList;
  InitKonstrList;

  if not PmpSchowki and not WerPro then
  begin
    mnuDiagDiv1.Visible := false;
    mnuDiagCopy.Visible := false;
    mnuDiagSaveAs.Visible := false;
    mnuDiag4Pola.Visible := CHar4PolaZezw;
    mnuDiagPolacz.Visible := false;
    CopyRysBtn.Visible := false;
    RysSaveAsBtn.Visible := false;
  end;

  if not PmpCharSkaner then
    CalcPanel.Visible := false;

  with Pompa.DB do
  begin
    if tOK and bOK then
    begin
      if Jezyk <> 'POLSKI' then
        fld := T.FindField( Jezyk )
       else
        fld := T.FindField( 'OPIS' );
      if fld <> NIL then
        with B as TTable do
        begin
          SetKey;
          FieldByName('ID').AsString := fld.AsString;
          if GotoKey then
          begin
            ObjViewFromBinBase( OpisView, B );
            /////////////////////////////////
            if OpisView.Obj is TRichEdit then
            begin
              //PodstawTeksty(TRichEdit(OpisView.Obj).Lines,['pomp'],['wsSSSSSSSSS']);
            end;
            /////////////////////////////////
          end;
        end;
    end;
  end;

  CharData := Pompa.GetCharData;
  if CharData = NIL then
    CharData := Pompa.CreateCharDataDB(self);

  //wstawka p nominalny
  PntNominalnyFun := TPntNominalFun.Create(self);
  PunktNomFun.Drawer := PntNominalnyFun;
  //
  //Wstawione dla grundfosa
  LabQnKopia.Caption := FormatFloat('0.0',m3hToU(StrToFloat(QnDBText.Caption)));
  LabQJed.Caption := CapQ;
  lab_m3_h.Caption := CapQ;
  labQrJedn.Caption := CapQ;

  ziarno := Pompa.DB.H.FieldByName('ZIARNO').AsFloat;
  LabZiarno.Caption := FormatFloat('0.0',ziarno);


  InitDiagr;
  InitCharNatFrst;
  UpdateM;
  EnableHTMLBtn;
  SetParRzecz;
  InitRys;
  PrzelInit;
  SetInner;
end;

{----------------------------------------------------------------------------}
procedure TFormPompy.InitRys;
var
  FN       : string;
  gmet, sx : string;
  c        : Integer;

  procedure SetFN;
  // ustaw zmienna "FN"
  begin
    if Pos('.',gmet) = 0 then
      sx := gmet + '.dxf'
    else
      sx := gmet;
    FN := Pompa.Producent.SciezkaDoBaz + '\schematy\' + sx;
    if not FileExists(FN) then
      FN := Pompa.Producent.SciezkaDoBaz + '\schematy\' + gmet;

    if not FileExists(FN) then
    begin
      FN := Pompa.Producent.SciezkaDoBaz + '\schematy\r_';
      FN := FN + Pompa.Producent.Ident + '.';
      FN := FN + gmet;
    end;
  end;

  function LdDxf :Boolean;
  // wczytaj dxf'a
  begin
    Result := FileExists(FN);
    if Result then
    begin
      if Length(FDxfs) <= c then
        SetLength(FDxfs, c+1);
      if FDxfs[c] = NIL then
        FDxfs[c] := TPompDXFDrawing.Create
      else
        FDxfs[c].Clear;
      TPompDXFDrawing(FDxfs[c]).LoadWithBase(FN,Pompa.DB.G);
      inc(c);
    end;
  end;

var
  jestAgr   :Boolean;
  jestOpis  :Boolean;
  opis      :string;
begin
  if not Pompa.DB.gOK then
    EXIT;
  c := 0;
  //DXFDraw.ThicnessDraw := true;
  ClearDxfs;
  // KR: 2002.10.07 - do uporzadkowania najprawdopodobniej w wersji D.7
  if Pompa.DB.SaWarianty and Pompa.DB.RecWarG then
  begin
    SetLength(FDxfs, 1);
    IsWarG := True;
    if FWarGBM = NIL then
      FWarGBM := TStringList.Create
    else
      FWarGBM.Clear;
    RysTabs.Tabs.Clear;
    Pompa.DB.WarG.First;
    while not Pompa.DB.WarG.Eof do
    begin
      jestAgr := (Pompa.DB.G.FindField('G_AGR') <> NIL)
                 and (Pompa.DB.G.FindField('G_AGR').AsString <> '');
      jestOpis := (Pompa.DB.WarG.FindField('OPIS') <> NIL)
                 and (Pompa.DB.WarG.FindField('OPIS').AsString <> '');
      if jestOpis then
        opis := Pompa.DB.WarG.FindField('OPIS').AsString;
      gmet := Pompa.DB.G.FieldByName('G_Met').AsString;
      SetFN;
      if LdDxf then
      begin
        //FWarGBM.Add( Pompa.DB.WarG.Bookmark );
        FWarGBM.Add(TBookmarkStr( Pompa.DB.WarG.Bookmark )); //MS 2024.06.30
        if not jestOpis then
          RysTabs.Tabs.Add( 'Pompa' )
        else if jestAgr then
          RysTabs.Tabs.Add( Format( '%s - pompa', [opis] ) )
        else
          RysTabs.Tabs.Add( opis );
      end;
      if jestAgr then
      begin
        gmet := Pompa.DB.G.FindField('G_AGR').AsString;
        SetFN;
        if LdDxf then
        begin
          //FWarGBM.Add( Pompa.DB.WarG.Bookmark );
          FWarGBM.Add(TBookmarkStr( Pompa.DB.WarG.Bookmark )); //MS 2024.06.30
          if jestOpis then
            RysTabs.Tabs.Add( Format( '%s - agregat', [opis] ) )
          else
            RysTabs.Tabs.Add( 'Agregat' );
        end;
      end;
      Pompa.DB.WarG.Next;
    end;
  end
  else
  begin
    IsWarG := False;
    FWarGBM.Free;
    SetLength(FDxfs, 2);
    FDxfs[0] := NIL;
    FDxfs[1] := NIL;
    FDxfs[0] := TPompDXFDrawing.Create;
    gmet := Pompa.DB.G.FieldByName('G_Met').AsString;
    SetFN;
    LdDxf;
    if Pompa.DB.G.FindField('G_AGR') <> NIL then
    begin
      gmet := Pompa.DB.G.FindField('G_AGR').AsString;
      SetFN;
      LdDxf;
    end;
    if c = 2 then
      with RysTabs.Tabs do
      begin
        if Count <> 2 then
        begin
          Clear;
          Add('Pompa');
          Add('Agregat');
        end;
      end
    else
    begin
      if RysTabs.Tabs.Count > 0 then
        RysTabs.Tabs.Clear;
    end;
  end;
end;

{----------------------------------------------------------------------------}
destructor TFormPompy.Destroy;
begin
  //DXFDraw.Free;
  if (FPompa <> NIL) and (not (csDestroying in FPompa.ComponentState)) then
    FPompa.Release;
  FMotObj.Release;
  ClearDxfs;
  inherited Destroy;
end;


{----------------------------------------------------------------------------}
procedure TFormPompy.UWMSetLang( var msg :TMessage );
begin
  SetLang;
  msg.Result := 1;
end;



procedure TFormPompy.SetLang;
begin

//  PakietPompy.Pages[0].Caption := DajText(Parametry_txt);
//  PakietPompy.Pages[1].Caption := DajText(Charakterystyki_txt);
//  PakietPompy.Pages[2].Caption := DajText(Rysunek_txt);
//  PakietPompy.Pages[3].Caption := DajText(Silnik_txt);
//  PakietPompy.Pages[4].Caption := DajText(Opis_txt);
//
//  Caption := DajText(Pompa_txt) + ': ' + NazwaPompy;
//  ParNomBox.Caption            := DajText(ParamNominalnePompy_txt);
//  WydTytLabel.Caption          := DajText(Wydajn_txt);
//  PodnTytLabel.Caption         := DajText(WysPodn_txt);
//  MocTytLabel.Caption          := DajText(Moc_txt);
//  ObrTytLabel.Caption          := DajText(Obroty_txt);
//  MasaTytLabel.Caption         := DajText(Masa_txt);
//  ZamknijBtn.Caption           := DajText(Zamknij_txt);
//  ParSilnGrBox.Caption         := DajText(ParametrySilnika_txt);
//  TypSilnLab.Caption           := DajText(TypSilnika_txt);
//  TypSilnika.Caption           := DajText(TypSilnika_txt);
//  MocSilnika.Caption           := DajText(MocZnam_txt);
//  PradZnamionowy.Caption       := DajText(PradZnam_txt);
//  Obroty.Caption               := DajText(Obroty_txt);
//  NapiecieZnamionowe.Caption   := DajText(NapZnam_txt);
//  CosinusFi.Caption            := DajText(Cos_fi_txt);
//  Sprawnosc.Caption            := DajText(Sprawn_txt);
//  ObrSilnLab.Caption              := DajText(ObrotySilnika_txt);
//  NapSilnLab.Caption           := DajText(Napiecie_txt);
//  MocSilnLab.Caption           := DajText(MocZnam_txt);
//  OpisLab.Caption              := DajText(OpisPompy_txt);
//  InitZastList;
end;


{----------------------------------------------------------------------------}
procedure TFormPompy.TBSM_Print( var msg :TMessage );
begin
  PrintEv(self);
end;

{----------------------------------------------------------------------------}
procedure TFormPompy.TBSM_CanPrint( var msg :TMessage );
begin
  if (PakietPompy.ActivePage = TabCharakterystyka)
     or (PakietPompy.ActivePage = TabRysunek)
     or (PakietPompy.ActivePage = TabOpis)
     or (PakietPompy.ActivePage = TabRaport) then
    msg.Result := 1
  else
    msg.Result := 0;

  if (PakietPompy.ActivePage = TabPrzeliczenia) then
  begin
    msg.Result := ord(PmpSchowki);
  end;
end;

procedure TFormPompy.InitKonstrList;
var
  i            : integer;
  idol,igor    : integer;
  zas, s       : string;
  MojIni       : TCustomIniFile;
begin
  KonstrukcjeListBox.Clear;
  if Pompa <> NIL then
  begin
    MojIni := KluczePompIni;
    i:=1;
    idol:=1;
    while i< (length(Pompa.StrKonstr)+1) do
    begin
      if copy(Pompa.StrKonstr,i,1)='/' then
      begin
        igor:=i;
        if igor>idol then
        begin
          zas:=copy(Pompa.StrKonstr,idol+1,(igor-idol-1));
          s := MojIni.ReadString('Konstrukcja',zas, '??');
          if s <> '??' then
            KonstrukcjeListBox.Items.Add(s);
          idol:=igor;
        end;
      end;
      inc(i);
    end;
  end;
end;



procedure  TFormPompy.InitZastList;
var
  i            : integer;
  idol,igor    : integer;
  zas, s       : string;
  MojIni       : TCustomIniFile;

begin
  ZastListBox.Clear;
  if Pompa <> NIL then
  begin
    MojIni := KluczePompIni;
    i:=1;
    idol:=1;
    while i< (length(Pompa.StrZastos)+1) do
    begin
      if copy(Pompa.StrZastos,i,1)='/' then
      begin
        igor:=i;
        if igor>idol then
        begin
          zas:=copy(Pompa.StrZastos,idol+1,(igor-idol-1));
          s := MojIni.ReadString('Zastosowania',zas, '??');
          if s <> '??' then
            ZastListBox.Items.Add(s);
          idol:=igor;
        end;
      end;
      inc(i);

    end;
  end;
end;



{----------------------------------------------------------------------------}
procedure  TFormPompy.InitDiagr;

  procedure InitFun( Fun :TDiagFunction; CBox :TCheckBox;
                     UseDrawer :Boolean = true);
  begin
    if UseDrawer then
      Fun.IsOn := Fun.Drawer <> NIL;
    if CBox <> NIL then
    begin
      CBox.Enabled := Fun.IsOn;
      CBox.Checked := Fun.IsOn;
    end;
    AddFunChk( Fun, CBox, Fun.Name );
  end;

var
  aPznMot   :Double; // moc znamionowa motora (P2)
  aP1max    :Double; // maksymalna moc elektryczna
  aP2max    :Double; // maksymalna moc na wale
begin

  //przeniesione z tabshow bo sie nie odswierzalo w raporcie ???
  QJednDescr.Text := 'Q '+CapQ;
  Diagram.XJednostki := 1/UTom3h(1);
  Diagram.CountMaxXRAuto(Pompa.CharQMax);
  //przeniesione z tabshow


  DiagDescrNazwa.Text := NazwaPompy;
  if CharData = NIL then
  begin
    cbH.Checked := false;
    cbH.Enabled := false;
    cbP.Checked := false;
    cbP.Enabled := false;
    cbNPSH.Checked := false;
    cbNPSH.Enabled := false;
    cbEta.Checked := false;
    cbEta.Enabled := false;
    cbP_Mot.Checked := false;
    cbP_Mot.Enabled := false;
    cbEtaAgr.Checked := false;
    cbEtaAgr.Enabled := false;
    cbP1.Checked := false;
    cbP1.Enabled := false;
    CalcPanel.Hide;
    EXIT;
  end;

  if not (CharData is TFuncCharData) then
    CalcPanel.Hide;

  with Diagram do
  begin
    MinXR  :=   0;
    CountMaxXRAuto( Pompa.CharQMax );
    MinYR  :=   0;
    MaxYR  :=   20;
  end;
  diagCharNat.CountMaxXRAuto( Pompa.CharQMax );

  CharData.GetDiagFun( 'H',    HFun );
  CharData.GetDiagFun( 'P',    PFun );
  CharData.GetDiagFun( 'P1',   DiagFunP1);
  CharData.GetDiagFun( 'NPSH', NPSHFun );
  CharData.GetDiagFun( 'ETA',  EtaFun );


  if Pompa.CharSel <> NIL then    // wywolanie charakterystyki rury
  begin
    Pompa.CharSel.GetDiagFun( CharSelFun );
  end;

  EtaAgrFun.IsOn := Pompa.JestEtaAgr and cbEtaAgr.Visible;
  // charakterystyka P1 podpieta pod przycisk
  DiagFunP1.IsOn := Pompa.JestEtaAgr and cbP1.Visible;

  if Pompa.JestEtaAgr then
  begin
    EtaAgrFun.MinXRDraw := CharData.GetCharQMin;
    EtaAgrFun.MaxXRDraw := CharData.GetCharQMax;

//    DiagFunP1.MinXRDraw := CharData.GetCharQMin;
//    DiagFunP1.MaxXRDraw := CharData.GetCharQMax;
  end;

  {if Pompa.DB.Field['H.H_TYP_N'] = NIL then
    dgdscrTypCharakterystyki.Text := ''
  else if Pompa.DB.Field['H.H_TYP_N'].AsString = 'SO' then
    dgdscrTypCharakterystyki.Text := 'Charakterystyka staloobrotowa'
  else if Pompa.DB.Field['H.H_TYP_N'].AsString = 'ZO' then
    dgdscrTypCharakterystyki.Text := 'Charakterystyka zmiennoobrotowa'
  else}
    dgdscrTypCharakterystyki.Text := '';

  InitFun( HFun, cbH );
  InitFun( PFun, cbP );
  InitFun( NPSHFun, cbNPSH );
  InitFun( ETAFun, cbEta );
  InitFun( EtaAgrFun, cbEtaAgr, false );
//  InitFun( DiagFunP1, cbP1, false ); // po co ta iniocjacja??
  InitFun( DiagFunP1, cbP1 );

// Skalowanie krzywych mocy na poczatku
// Jeszcze poprawia w UpDateM
  if Pompa.DB.mOK and cbP_Mot.Visible then
    begin
      aPznMot := Pompa.DB.M.FieldByName('M_PZN').AsFloat;
    end
  else
    begin
      cbP_Mot.Checked := false;
      cbP_Mot.Enabled := false;
      aPznMot := 0;
    end;
  if cbP1.Visible then
    begin
      aP1max  := CharData.GetCharP1Max;
    end
  else
    begin
      cbP1.Checked := false;
      cbP1.Enabled := false;
      aP1max  := 0;
    end;
  if aP2max < max(aPznMot,aP1max) then
        PFun.CountMaxYR(max(aPznMot,aP1max));

  // wsatawka p nominalny
  { PunktOpt }
  if PunktNomFun.Drawer <> NIL then
  begin
    PunktNomFun.IsOn   := true;
    PntNominalnyFun .Q := pompa.Qn;
    PntNominalnyFun .H := pompa.Hn;
    AddFunChk( PunktNomFun, cbPunktNom, 'PktNom' );
  end;

  InitFun( CharSelFun, cbCharSel );

end;

procedure TFormPompy.PrzelDiagrMinMax;
var
  QMax    :Double;
  HMax    :Double;
  PMax    :Double;
  ChD      :TPompCharData;
begin
  {   // oryginal 441 na dzien 2002.06.04
  if PrzelCieczCharData = NIL then
    EXIT;

  QMax := Max( PrzelCieczCharData.GetCharQMax,
               CharData.GetCharQMax );
  PrzeliczDiag.CountMaxXRAuto( QMax );

  HMax := Max( PrzelCieczCharData.GetCharHMax,
               CharData.GetCharHMax );
  PrzHFun.CountMaxYR(HMax);

  PMax := Max( PrzelCieczCharData.GetCharPMax,
               CharData.GetCharPMax );
  }

  // KR 2002.06.04
  // <433hv>
  if MoznaPrzelCiecz then
    ChD := PrzelCieczCharData
  else
    ChD := PrzelCharData;
  if ChD = NIL then
  begin
    EXIT;
  end;

  QMax := Max( ChD.GetCharQMax,
               CharData.GetCharQMax );
  PrzeliczDiag.CountMaxXR( QMax );

  HMax := Max( ChD.GetCharHMax,
               CharData.GetCharHMax );
  PrzHFun.CountMaxYR(HMax);

  PMax := Max( ChD.GetCharPMax,
               CharData.GetCharPMax );
  // </433hv>

  if Pompa.DB.mOK then
    PMax := Max( PMax, Pompa.DB.M.FieldByName('M_PZN').AsFloat );
  PrzPFun.CountMaxYR(PMax);

end;



procedure  TFormPompy.InitDiagrPrzel;

var
  ChD      :TPompCharData;

  procedure InitFun( Fun :TDiagFunction; CBox :TCheckBox);
  begin
    Fun.IsOn := Fun.Drawer <> NIL;
    if CBox <> NIL then
    begin
      CBox.Enabled := Fun.IsOn;
      CBox.Checked := Fun.IsOn;
    end;
    AddFunChk( Fun, CBox, Fun.Name );
  end;

begin
  //DiagDescrNazwa.Text := NazwaPompy;
  //if PrzelCieczCharData = NIL then
  //begin
  //  EXIT;
  //end;
  if MoznaPrzelCiecz then
    ChD := PrzelCieczCharData
  else
    ChD := PrzelCharData;
  if ChD = NIL then
  begin
    EXIT;
  end;

  with PrzeliczDiag do
  begin

    MinXR  :=   0;
    //CountMaxXRAuto( PrzelCieczCharData.GetCharQMax );
    CountMaxXRAuto( ChD.GetCharQMax );
    MinYR  :=   0;
    MaxYR  :=   20;

    CharData.GetDiagFun( 'H', PrzHFunOrg );
    CharData.GetDiagFun( 'P', PrzPFunOrg );
    CharData.GetDiagFun( 'ETA', PrzEtaFunOrg );
    ChD.GetDiagFun( 'H',    PrzHFun );
    (PrzHFun.Drawer as TFuncDiagFun).Bolded := false;
    ChD.GetDiagFun( 'P',    PrzPFun );
    (PrzPFun.Drawer as TFuncDiagFun).Bolded := false;
    ChD.GetDiagFun( 'ETA',    PrzEtaFun );
    (PrzEtaFun.Drawer as TFuncDiagFun).Bolded := false;
    InitFun( PrzHFun, HPrzelChk );
    InitFun( PrzPFun, PPrzelChk );
    InitFun( PrzEtaFun, EtaPrzelChk );
    InitFun( PrzHFunOrg, HOrygChk );
    InitFun( PrzPFunOrg, POrygChk );
    InitFun( PrzEtaFunOrg, EtaOrygChk );
    FPrzelPunktDFun := TPntDiagFun.Create(PrzeliczDiag);
    PrzHFunPktDop.Drawer := FPrzelPunktDFun;
  end;
end;



{----------------------------------------------------------------------------}
procedure   TFormPompy.CharH( q: double; var h: double );
begin
  h := Pompa.CharSel.dH(q);
end;

{----------------------------------------------------------------------------}
procedure   TFormPompy.CharP( q: double; var p: double );
begin
end;

{----------------------------------------------------------------------------}
procedure   TFormPompy.CharNPSH( q: double; var np: double );
begin
end;


{----------------------------------------------------------------------------}
procedure   TFormPompy.CharETA( q: double; var AEta: double );
begin
end;


{----------------------------------------------------------------------------}
procedure   TFormPompy.PrintEv( Sender: TObject );
var
  R         :TRect;
  R2        :TRealRectRec;
  svCr      :TCursor;
  pd        :TPrintDialog;
  dd        :TSpecDrawData;
  w, h      :Integer;
  dg        :TDiagram;
  bpp       :Integer;
begin
  if (PakietPompy.ActivePage = TabCharakterystyka)
     or (PakietPompy.ActivePage = TabPrzeliczenia) then
  begin
    pd := TPrintDialog.Create(self);
    try
      if pd.Execute then
      begin
        BeginWaitCur;
        try
          if PakietPompy.ActivePage = TabCharakterystyka then
            dg := Diagram
          else
            dg := PrzeliczDiag;
          Printer.Title := Format( 'Charakterystyka: %s', [Pompa.Nazwa] );
          Printer.BeginDoc;
          try
            R      := Printer.Canvas.ClipRect;
            w := R.Right - R.Left;
            h := R.Bottom - R.Top;
            if w < h then
              R.Bottom := R.Top + w
            else
              R.Right := R.Left + h;
            bpp := GetDeviceCaps(Printer.Canvas.Handle, BITSPIXEL );
            dg.DrawIt( Printer.Canvas, R, bpp=1, true );
          finally
            Printer.EndDoc;
          end;
        finally
          EndWaitCur;
        end;
      end;
    finally
      pd.Free;
    end;
  end
  else if PakietPompy.ActivePage = TabRysunek then
  begin
    pd := TPrintDialog.Create(self);
    try
      if pd.Execute then
      begin
        Printer.Title := Format( 'Rysunek wymiarowy: %s', [Pompa.Nazwa] );
        Printer.Orientation := poLandscape;
        Printer.BeginDoc;
        R        := Printer.Canvas.ClipRect;
        { 2000.10.16 - KR
        R2.Top   := 480;
        R2.Left  := 0;
        R2.Right := 640;
        R2.Bottom:= 0;
        }  // mieniono na
        R2.Top   := DXFDraw.Top;
        R2.Left  := DXFDraw.Left;
        R2.Right := DXFDraw.Right;
        R2.Bottom:= DXFDraw.Bottom;

        // To bylo
        with Printer.Canvas do
        begin
          Font.Color := clBlack;
          Font.Size := 12;
          Font.Name := 'Arial';
          TextOut( round( 0.05 * R.Right ), round( 0.95 * R.Bottom ),
                   Pompa.Nazwa );
        end;
        // Zmiana C.D. - dodane
        R.Left   := round(Lin( 0.07, 0, 1, R.Left, R.Right));
        R.Right  := round(Lin( 0.07, 0, 1, R.Right, R.Left));
        R.Top    := round(Lin( 0.07, 0, 1, R.Top, R.Bottom));
        R.Bottom := round(Lin( 0.07, 0, 1, R.Bottom, R.Top));
        ScaleRect( R, R2 );
        // Koniec zmiany KR
        dd := TSpecDrawData.Create;
        dd.Canvas := Printer.Canvas;
        dd.Construct2RectRI( R2, R );
        DXFDraw.DrawOnSpec( dd );
        dd.Free;
        Printer.EndDoc;
      end;
    finally
      pd.Free;
    end;
  end
  else if PakietPompy.ActivePage =  TabOpis then
  begin
    if OpisView.ObjId = '.RTF' then
      (OpisView.Obj as TRichEdit).Print( 'Wydruk opisu' );
  end
  else if PakietPompy.ActivePage =  TabRaport then
  begin
    //Rap.Print; MS 2024.06.30
  end
  else
  begin
  end;

end;


{----------------------------------------------------------------------------}
procedure TFormPompy.ZamknijBtnClick(Sender: TObject);
begin
  Close;
end;



{----------------------------------------------------------------------------}
procedure TFormPompy.RysunekPaint(Sender: TObject);
var
  R :TRect;
  R2 :TRealRectRec;
  dd :TSpecDrawData;
  f  :Double;
  fr :Double;
begin
  if DXFDraw = NIL then
    EXIT;
  R.Top    := round(0.03*Rysunek.Height);
  R.Left   := round(0.03*Rysunek.Width);
  R.Right  := round(0.97*Rysunek.Width);
  R.Bottom := round(0.97*Rysunek.Height);
  R2.Top   := DXFDraw.Top;
  R2.Left  := DXFDraw.Left;
  R2.Right := DXFDraw.Right;
  R2.Bottom:= DXFDraw.Bottom;
  try
    f := F_DIV(Rysunek.Width, Rysunek.Height);
    fr := F_DIV(R2.Right - R2.Left, R2.Bottom - R2.Top);
    if abs(fr) > f then
      R2.Bottom := R2.Top + ((R2.Bottom - R2.Top) * F_DIV(abs(fr),f))
    else
      R2.Right := R2.Left + ((R2.Right - R2.Left) * F_DIV(f,abs(fr)));
  except
    on EMathError do
    begin
      EXIT;
    end;
  end;

  dd := TSpecDrawData.Create;
  dd.Canvas := Rysunek.Canvas;
  dd.Construct2RectRI( R2, R );
  DXFDraw.DrawOnSpec( dd );
  dd.Free;

end;



procedure TFormPompy.SetInner;
const
  MinW = 625;
  MinH = 375;
var
  w, h  :Integer;
  cw, ch  :Integer;
begin

  w := PakietPompy.Width;
  //if w < MinW then
    //w := MinW;

  h := PakietPompy.Height;
  //if h < MinH then
    //h := MinH;
  if PakietPompy.ActivePage <> NIL then
  begin
    cw := PakietPompy.ActivePage.ClientWidth;
    ch := PakietPompy.ActivePage.ClientHeight;
  end
  else
  begin
    cw := PakietPompy.ClientWidth;
    ch := PakietPompy.ClientHeight;
  end;

  with ZamknijBtn do
  begin
    Top  := Min(h,self.ClientHeight) - Height - 20;
    Left := Min(w,self.ClientWidth) - Width  - 20;
  end;

  with CharCtrlScroll do
  begin
    Left := cw - Width - 1;
    Height := ZamknijBtn.Top - Top - 3 - PakietPompy.ActivePage.Top;
  end;

  with Diagram do
  begin
    Width   := cw  - Left - CharCtrlScroll.Width -3;
    Height  := ch - Top  - 20;
  end;


  {
  with RysPanel do
  begin
    Height  := h - Top  - 40;
    Width   := round( 640 /480 * Height );
    if Width > w - Left - 40 - ZamknijBtn.Width then
    begin
      Width  := w - Left - 40 - ZamknijBtn.Width;
      Height := round( 480/640 * Width );
    end;
  end;


  with ZoomBtn do
  begin
    top   := RysPanel.Top;
    left  := RysPanel.Left+RysPanel.Width+10;
  end;


  with CopyRysBtn do
  begin
    top   := ZoomBtn.Top + ZoomBtn.Height + 4;
    left  := ZoomBtn.Left;
  end;
  with RysSaveAsBtn do
  begin
    top   := CopyRysBtn.Top + CopyRysBtn.Height + 4;
    left  := CopyRysBtn.Left;
  end;
  }

  //with OpisView do
  //begin
  //  Top    := 0;
  //  Left   := 0;
  //  Height := ch;
  //  Width  := w - Left - 40 - ZamknijBtn.Width;;
  //end;
  //HTML_Btn.Top := OpisView.Top;
  //HTML_Btn.Left := OpisView.Left + OpisView.Width + 5;

  GBoxPompa.Left := w - GBoxPompa.Width - 10;
  GBoxCiecz.Left := GBoxPompa.Left;
  //GBoxCieczy.Left := GBoxCiecz.Left - GBoxCieczy.Width - 4;
  //GBoxCieczy.Top := h - GBoxCieczy.Height - 34;
  CharPrzelGBox.Top := h - CharPrzelGBox.Height - 32;
  CharOrygGBox.Top := CharPrzelGBox.Top;
  PrzeliczDiag.Width := GBoxPompa.Left - PrzeliczDiag.Left - 4;
  PrzeliczDiag.Height := CharPrzelGBox.Top - PrzeliczDiag.Top - 4;

  PrzelKomunikMemo.Left := CharOrygGBox.Left + CharOrygGBox.Width +3;
  PrzelKomunikMemo.Top := max( CharOrygGBox.Top,
                               GBoxCiecz.Top+ GBoxCiecz.Height +2);
  PrzelKomunikMemo.Width := ZamknijBtn.Left - PrzelKomunikMemo.Left-7;
  PrzelKomunikMemo.Height := CharOrygGBox.Height + CharOrygGBox.Top
                             - PrzelKomunikMemo.Top;

end;

procedure TFormPompy.cbHClick(Sender: TObject);
begin
  if HFun <> NIL then
    HFun.IsOn := cbH.Checked;
  CloseRap;
end;

procedure TFormPompy.cbPClick(Sender: TObject);
begin
  if PFun <> NIL then
    PFun.IsOn := cbP.Checked;
  CloseRap;
end;

procedure TFormPompy.cbNPSHClick(Sender: TObject);
begin
  if NPSHFun <> NIL then
    NPSHFun.IsOn := cbNPSH.Checked;
  CloseRap;
end;

procedure TFormPompy.cbEtaClick(Sender: TObject);
begin
  if ETAFun <> NIL then
    ETAFun.IsOn := cbEta.Checked;
  CloseRap;
end;

procedure TFormPompy.cbCharSelClick(Sender: TObject);
begin
  if CharSelFun <> NIL then
    CharSelFun.IsOn := cbCharSel.Checked;
  CloseRap;
end;

procedure TFormPompy.cbPunktNomClick(Sender: TObject);
begin
  PunktNomFun.IsOn := cbPunktNom.Checked;
  CloseRap;
end;

procedure TFormPompy.cbP_MotClick(Sender: TObject);
begin
  P_MotFun.IsOn := cbP_Mot.Checked;
  CloseRap;
end;

procedure TFormPompy.cbEtaAgrClick(Sender: TObject);
begin
  EtaAgrFun.IsOn := cbEtaAgr.Checked;
  CloseRap;
end;

procedure TFormPompy.FormCreate(Sender: TObject);
begin
  if TabParametry.TabVisible then
    PakietPompy.ActivePage := TabParametry
  else
    PakietPompy.ActivePage := TabOpis;
  if FMDIChild then
    FormStyle := fsMDIChild;
  SetLang;
  {
  CopyRysBtn.Visible :=
        ZetonFile.ReadBool( 'Katalog','Schowki' , false );
  RysSaveAsBtn.Visible :=
        ZetonFile.ReadBool( 'Katalog','Schowki' , false );
  CopyCharBtn.Visible :=
        ZetonFile.ReadBool( 'Katalog','Schowki' , false );
  CharSaveAsBtn.Visible :=
        ZetonFile.ReadBool( 'Katalog','Schowki' , false );
  }
end;

procedure TFormPompy.ZoomBtnClick(Sender: TObject);
var
  RForm   :TRysForm;
begin
  RForm   := TRysForm.Create(self);
  RForm.DXFDraw := DXFDraw;
  RForm.Nazwa := Pompa.Nazwa;
  RForm.Show;
  RForm.InitInner;
end;

function TFormPompy.GetCharMetaFile: TMetafile;
var
  R       :TRect;
  MyMetafile : TMetafile;         // kopiowanie do schowka
  mfc        : TMetafileCanvas;
begin
  MyMetafile := TMetafile.Create;
  MyMetafile.Width:=640;
  MyMetafile.Height:=480;
  R := Rect( 0, 0,MyMetafile.Width, MyMetafile.Height );
  mfc:=TMetafileCanvas.Create(MyMetafile, 0);
  try
    Diagram.DrawIt(mfc, R,  false, true);
  finally
    mfc.Free;
  end;
  result := MyMetafile;
end;


procedure TFormPompy.CopyCharBtnClick(Sender: TObject);
begin
  Clipboard.Assign(Diagram);
end;

function TFormPompy.GetRysMetaFile: TMetafile;
var
  R       :TRect;
  R2      :TRealRectRec;
  c       :TMetafileCanvas;
  mf      :TMetaFile;
  dd      :TSpecDrawData;
  f       :Double;
begin
  r2.Left := DXFDraw.Left;
  r2.Top  := DXFDraw.Bottom;
  r2.Right := DXFDraw.Right;
  r2.Bottom := DXFDraw.Top;
  f := abs(r2.Top-r2.Bottom) / abs(r2.Right - r2.Left);
  mf := TMetafile.Create;
  mf.Width  := 640;
  mf.Height := round(f * mf.Width);
  R := Rect( 0, mf.Height, mf.Width, 0 );
  c := TMetafileCanvas.Create( mf, 0 );

  dd := TSpecDrawData.Create;
  dd.Canvas := c;
  dd.Construct2RectRI( R2, R );
  DXFDraw.DrawOnSpec( dd );
  dd.Free;
  c.Free;
  result := mf;
end;

procedure TFormPompy.CopyRysBtnClick(Sender: TObject);
var
  mf      :TMetaFile;
  cboard     : TClipboard;
begin
  mf := GetRysMetaFile;
  //cboard := TClipboard.Create;
  cboard := Clipboard;
  cboard.open;
  cboard.clear;
  cboard.Assign(mf);
  cboard.close;
  mf.Free;
  //cboard.free;
end;


procedure TFormPompy.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseRap;
  if Assigned(PDFView)  then PDFView.Free;
  Action := caFree;
end;



procedure TFormPompy.PakietPompyChange(Sender: TObject);
begin
  if PakietPompy.ActivePage = TabRaport then
  begin
//    if Rap = NIL then
//      CreateRap;
//    FrmPrev.Aktualizuj;
  end;
end;

procedure TFormPompy.SetParRzecz;
begin
  if Pompa.CharSel <> NIL then    // wywolanie charakterystyki rury
    begin
      WypelnijRzeczywiste;
      ParNomBox.Top := 4+49;
      ParSilnGrBox.Top := ParNomBox.Top + ParNomBox.Height + 4;//  168+49;
      gbWymagane.Top := 4;
    end
  else
    begin
      gbRzeczywiste.Visible := false;
      gbWymagane.Visible := false;
      ParNomBox.Top := 4;
      ParSilnGrBox.Top := ParNomBox.Top + ParNomBox.Height + 4;
      gbWymagane.Top := 240;
    end;
end;

{ TPntNominalFun }

procedure TPntNominalFun.DrawFun( dt :TSpecDrawData; bw :Boolean );
var
  sdu     :TScalableDrawUnit;
  X, Y    :TCanvCoord;
  V1, V2, w  :TCanvCoord;
begin

  with dt.Canvas do
  begin
    Brush.Color := dt.Canvas.Pen.Color;
    Brush.Style := bsClear;
  end;

  dt.ConvPointRPar( Q, H, X, Y );
  sdu := TScalableDrawUnit.Create;
  with sdu do
  begin
    CheckMin := true;
    Min      := 1;
    MinUnit  := duPixel;
    CheckMax := true;
    Max      := 1;
    MaxUnit  := duMM;
    DefaultVal := 0.5;
    DefUnit  := duPart;
  end;
  w := dt.ParentData.SDUnitToPixels(sdu);
  dt.Canvas.Pen.Width := w;

  with sdu do
  begin
    Min := 2;
    Max := 1.5;
    DefaultVal := 1;
  end;
  V1 := dt.ParentData.SDUnitToPixels(sdu);
  dt.Canvas.Ellipse( X-V1, Y-V1, X+V1, Y+V1 );

  with sdu do
  begin
    Min := 1;
    Max := 1.5;
    DefaultVal := 1;
  end;
  w := dt.ParentData.SDUnitToPixels(sdu);
  dt.Canvas.Pen.Width := w;

  with sdu do
  begin
    Min := 3;
    Max := 10;
    DefaultVal := 3.5;
  end;
  V2 := dt.ParentData.SDUnitToPixels(sdu);

  with dt.Canvas do
  begin
    MoveTo(X,Y+V1);  LineTo(X,Y+V1+V2);
    MoveTo(X-V1,Y);  LineTo(X-V1-V2,Y);
  end;
  sdu.Free;
end;



procedure TFormPompy.CalcQEdChange(Sender: TObject);
var
  cd      :TFuncCharData;
  q       :Double;
begin
  if (CharData = NIL) or (not (CharData is TFuncCharData)) then
    EXIT;
  cd := CharData as TFuncCharData;
  q := UTom3h(CalcQEd.ValueFloat);
  CalcHEd.ValueFloat := cd.H(q);
  CalcPEd.ValueFloat := cd.P(q);
  CalcNPSHEd.ValueFloat := cd.NPSH(q);
  CalcEtaEd.ValueFloat := 100*cd.ETA(q);
end;

procedure TFormPompy.PrzelInit;
begin
  MoznaPrzelCiecz := (Pompa.MoznaLepPrzel and Pompa.MoznaRoPrzel);
  if not (CharData is TFuncCharData) or
     not (Pompa.MoznaLepPrzel or Pompa.MoznaRoPrzel
          or Pompa.MoznaObroty or Pompa.MoznaStoczyc) then
  begin
    TabPrzeliczenia.Enabled := false;
    TabPrzeliczenia.TabVisible := false;
    //TabPrzeliczenia.Hide;
    EXIT;
  end;
  LepkMetodaCombo.ItemIndex := 0;
  PrzelCharData := CharData.MakeCopy(self) as TFuncCharData;

  if MoznaPrzelCiecz then
    PrzelCieczCharData := TPompCieczCharData.Create3( self, NIL, PrzelCharData );

  PrzSredNomLab.Caption := FormatFloat( '0', CharData.Srednica );
  if Pompa.MoznaObroty then
  begin
    PrzelObrNomLab.Caption := FormatFloat( '0', CharData.Obroty );
    PrzObrWymEd.ValueFloat := CharData.Obroty;
  end
  else
  begin
    PrzObrWymEd.Enabled := false;
    sbtnPrzelObrDopas.Enabled := false;
  end;

  if Pompa.MoznaStoczyc then
  begin
    PrzSredNomLab.Caption := FormatFloat( '0', CharData.Srednica );
    PrzelSrednZakrLab.Caption := Format('(%d - %d)',
                    [Pompa.DB.H.FieldByName('H_DD2').AsInteger,
                     Pompa.DB.H.FieldByName('H_D2').AsInteger] );
    PrzSredWymEd.ValueFloat := CharData.Srednica;
  end
  else
  begin
    PrzSredWymEd.Enabled := false;
    sbtnPrzelSrednDopas.Enabled := False;
  end;
  InitDiagrPrzel;

  if Pompa.MoznaLepPrzel and Pompa.MoznaRoPrzel then
  begin
    CieczeForm := TCieczeForm.Create(self);

    PrzelCieczeCombo.ItemIndex := 1;
    PrzelCieczPlyw := CreateH2OPlyw( self, 10, 10 );
    PrzelCieczRodzaj := PrzelCieczPlyw.Ciecz;
    PrzelCieczeComboChange(PrzelCieczeCombo);
  end
  else
  begin
    PrzelCieczeCombo.Enabled := false;
    PrzCieczTempEd.Enabled := false;
    PrzGestEd.Enabled := false;
    PrzLepEd.Enabled := false;
    LepkMetodaCombo.Enabled := false;
  end;
  PrzelInited := true;

end;

procedure TFormPompy.Przelicz;
begin
  if PrzObrWymEd.ValueFloat > 0 then
    PrzelCharData.Obroty := PrzObrWymEd.ValueFloat;
  if PrzSredWymEd.ValueFloat > 0 then
    PrzelCharData.Srednica := PrzSredWymEd.ValueFloat;
  PrzelCieczCharData.QOpt := Pompa.Qn;
  PrzelCieczCharData.HOpt := Pompa.Hn;
  if PrzelCieczPlyw <> NIL then
  begin
    PrzelCieczPlyw.T := PrzCieczTempEd.ValueFloat;
    if PrzelCieczeCombo.ItemIndex = 0 then with PrzelCieczRodzaj as TCieczConst do
    begin
      Ni := PrzLepEd.ValueFloat / 1000000;
      Ro := PrzGestEd.ValueFloat;
    end
    else
    begin
      PrzelWyswParCieczy;
    end;
  end;
  case LepkMetodaCombo.ItemIndex of
    0: PrzelCieczCharData.Metoda := pclmNewYork;
    1: PrzelCieczCharData.Metoda := pclmSkowronski;
  end;
  PrzelCieczCharData.Przelicz;
  PrzelKomunikMemo.Text := PrzelCieczCharData.Komunik;

  PrzelDiagrMinMax;
  PrzeliczDiag.Invalidate;

end;

procedure TFormPompy.PrzelWyswParCieczy;
begin
  PrzGestEd.ValueFloat := PrzelCieczRodzaj.Ro;
  PrzLepEd.ValueFloat  := PrzelCieczRodzaj.Ni * 1000000;
end;

procedure TFormPompy.RysSaveAsBtnClick(Sender: TObject);
var
  FN      :string;
  ext     :string;
  mf      :TMetafile;
begin
  RysSaveDialog.FileName := NazwaPompyFN;
  if RysSaveDialog.Execute then
  begin
    FN := RysSaveDialog.FileName;
    ext := UpperCase(ExtractFileExt(FN));
    if ext = '.DXF' then
      DXFDraw.SaveToFile(FN)
    else if (ext = '.EMF') or (ext = '.WMF') then
    begin
      mf := GetRysMetaFile;
      mf.SaveToFile(FN);
      mf.Free;
    end;

  end
end;

procedure TFormPompy.CharSaveAsBtnClick(Sender: TObject);
var
  mf      :TMetafile;
begin
  CharSaveDlg.FileName := NazwaPompyFN;
  if CharSaveDlg.Execute then
  begin
    mf := GetCharMetaFile;
    mf.SaveToFile(CharSaveDlg.FileName);
    mf.Free;
  end;
end;

procedure TFormPompy.SetPrzelCieczPlyw(const Value: TCieczPlyw);
begin
  FPrzelCieczPlyw := Value;
  if Value <> NIL then
    PrzCieczTempEd.ValueFloat := Value.T;
end;

procedure TFormPompy.SetPrzelCieczRodzaj(const Value: TCieczRodzaj);
begin
  if FPrzelCieczRodzaj <> Value then
  begin
    if PrzelCieczPlyw = NIL then
      PrzelCieczPlyw := TCieczPlyw.Create(self);
    if FPrzelCieczRodzaj <> NIL then
      FPrzelCieczRodzaj.Free;
    FPrzelCieczRodzaj := Value;
    PrzelCieczPlyw.Ciecz := PrzelCieczRodzaj;
    if Value is TCieczConst then with Value as TCieczConst do
    begin
      Ro := PrzGestEd.ValueFloat;
      Ni := PrzLepEd.ValueFloat / 1000000;
    end
    else
    begin
      if PrzCieczTempEd.ValueFloat < PrzelCieczPlyw.TMin then
      begin
        PrzCieczTempEd.ValueFloat := PrzelCieczPlyw.TMin;
        PrzelCieczPlyw.T := PrzelCieczPlyw.TMin;
      end
      else if PrzCieczTempEd.ValueFloat > PrzelCieczPlyw.TMax then
      begin
        PrzCieczTempEd.ValueFloat := PrzelCieczPlyw.TMax;
        PrzelCieczPlyw.T := PrzelCieczPlyw.TMax;
      end
      else
      begin
        PrzelCieczPlyw.T := PrzCieczTempEd.ValueFloat;
      end;
    end;
    PrzelCieczCharData.Ciecz := PrzelCieczRodzaj;
    PrzelWyswParCieczy;
  end;
end;

procedure TFormPompy.PrzelCieczeComboChange(Sender: TObject);
var
  ch      :Boolean;
begin
  ch := PrzelCieczeCombo.ItemIndex = 0;
  //GBoxCiecz.Enabled := ch;
  PrzGestEd.Enabled := ch;
  PrzLepEd.Enabled := ch;
  PrzCieczTempEd.Enabled := not ch;

  case PrzelCieczeCombo.ItemIndex of
    0:
    begin
      PrzelCieczRodzaj := TCieczConst.Create(self);
    end;

    1:
    begin
      if CieczeForm.CieczeTab.locate( 'NAZWA',
                                      PrzelCieczeCombo.Items[1], [] ) then
        PrzelCieczRodzaj := CieczeForm.CreateCiecz(self);
    end;

    2:
    begin
      if CieczeForm.Execute then
      begin
        PrzelCieczRodzaj := CieczeForm.CreateCiecz(self);
        PrzelCieczeCombo.Items[1] := PrzelCieczRodzaj.Nazwa;
        PrzelCieczeCombo.ItemIndex := 1;
      end;
    end;

  end;
  Przelicz;
end;

procedure TFormPompy.PrzCieczTempEdAccept(Sender: TObject;
  var Accept: Boolean);
var
  min, max    :Double;
begin
  min := PrzelCieczRodzaj.TMin;
  max := PrzelCieczRodzaj.TMax;
  Accept := (min <= PrzCieczTempEd.ValueFloat)
            and (PrzCieczTempEd.ValueFloat <= max);
  if not Accept then
    ShowMessageFmt( 'Dopuszczalny zakres temperatur %0.0f - %0.0f °C',
                         [min, max] )
  else
  begin
    Przelicz;
    PrzelWyswParCieczy;
  end;
end;

procedure TFormPompy.PrzObrWymEdAccept(Sender: TObject;
  var Accept: Boolean);
begin
  Przelicz;
end;

procedure TFormPompy.PrzSredWymEdAccept(Sender: TObject;
  var Accept: Boolean);
var
  v           :Double;
  h           :TDataSet;
begin
  v := PrzSredWymEd.ValueFloat;
  h := Pompa.DB.H;
  Accept := (h.FieldByName('H_DD2').AsFloat <= v)
            and (v <= h.FieldByName('H_D2').AsFloat);
  if Accept then
    Przelicz
  else
    ShowMessageFmt( 'Dopuszczalna srednica %.1d - %.1d',
                    [h.FieldByName('H_DD2').AsInteger,
                     h.FieldByName('H_D2').AsInteger ] );
end;

procedure TFormPompy.PrzGestEdAccept(Sender: TObject; var Accept: Boolean);
begin
  Przelicz;
end;

procedure TFormPompy.HPrzelChkClick(Sender: TObject);
begin
  PrzHFun.IsOn := HPrzelChk.Checked;
end;

procedure TFormPompy.PPrzelChkClick(Sender: TObject);
begin
  PrzPFun.IsOn := PPrzelChk.Checked;
end;

procedure TFormPompy.EtaPrzelChkClick(Sender: TObject);
begin
  PrzEtaFun.IsOn := EtaPrzelChk.Checked;
end;

procedure TFormPompy.HOrygChkClick(Sender: TObject);
begin
  PrzHFunOrg.IsOn := HOrygChk.Checked;
end;

procedure TFormPompy.POrygChkClick(Sender: TObject);
begin
  PrzPFunOrg.IsOn := POrygChk.Checked;
end;

procedure TFormPompy.EtaOrygChkClick(Sender: TObject);
begin
  PrzEtaFunOrg.IsOn := EtaOrygChk.Checked;
end;

procedure TFormPompy.PrzLepEdAccept(Sender: TObject; var Accept: Boolean);
begin
  Przelicz;
end;

procedure TFormPompy.SilnikDXFCreateDrawing(Sender: TObject;
  var ADrawing: TDXFDrawing);
var
  p   :TPompDXFDrawing;
begin
  p := TPompDXFDrawing.Create;
  ADrawing := p;
  p.DB := MotorGTable;
end;

procedure TFormPompy.MotorObrFunValue(X: Double; var Y: Double);
begin
  Y := MotorChar.Obroty(X);
end;

procedure TFormPompy.MotorPradFunValue(X: Double; var Y: Double);
begin
  Y := MotorChar.Prad(X);
end;

procedure TFormPompy.MotorCosFFunValue(X: Double; var Y: Double);
begin
  Y := MotorChar.CosF(X);
end;

procedure TFormPompy.MotorEtaFunValue(X: Double; var Y: Double);
begin
  Y := MotorChar.Eta(X);
end;

procedure TFormPompy.LepkMetodaComboChange(Sender: TObject);
begin
  Przelicz;
end;

procedure TFormPompy.HTML_BtnClick(Sender: TObject);
var
  bi           :TBaseInfo;
  Tab          :TTable;
  TN           :string;
  CD           :string;
  HtmlPath     :string;
  HtmlPumps    :string;
  param        :string;
begin
  bi := Pompa.Producent.InfoBaz['PUMPS'] as TBaseInfo;
  TN := bi.GetBaseName('Links');
  if TN <> '' then
  begin
    Tab := TTable.Create(self);
    try
      TableSetNames( TN, Tab );
      Tab.Open;
      if MultiIdFindBest( Pompa.DB.A, Tab, 4 ) then
      begin
        CD := FindKatalCD;
        HtmlPath := bi.tbsf.ReadString( 'PATHS', 'HtmlPath', '' );
        HtmlPumps := bi.tbsf.ReadString( 'PATHS', 'HtmlPumps', '' );
        param := StrAssignPar( Tab.FieldByName('LINK').AsString,
                               [ 'CD_KATAL', 'HtmlPath', 'HtmlPumps' ],
                               [ CD, HtmlPath, HtmlPumps ] );

        if FileExists( Param ) then
          ShellExecute(0, Nil, PChar(Param), Nil, Nil, SW_NORMAL)
        else
          ShowMessageFmt( 'Nie ma pliku %s.%s'+
                          'Brak plyty CD lub niewlasciwa plyta',
                          [ Param, #13 ] );
      end;
      //else
        //Panel1.Caption := 'Nie znaleziono';
    finally
      Tab.Free;
    end;
  end;
end;

procedure TFormPompy.EnableHTMLBtn;
var
  bi           :TBaseInfo;
  Tab          :TTable;
  TN           :string;
  enable       :Boolean;
begin
  bi := Pompa.Producent.InfoBaz['PUMPS'] as TBaseInfo;
  TN := bi.GetBaseName('Links');
  if (TN <> '') and (strRight(TN,1) <> '\') then
  begin
    enable := False;
    Tab := TTable.Create(self);
    try
      TableSetNames( TN, Tab );
      Tab.Open;
      enable := MultiIdFindBest( Pompa.DB.A, Tab, 4 );
    finally
      Tab.Free;
    end;
    HTML_Btn.Enabled := enable;
  end
  else
    HTML_Btn.Visible := False;

end;

procedure TFormPompy.UpdateM;
var
//  eta             :Double;
  FN              :string;
  s               :string;
  Tab             :TTable;
  svCur           :TCursor;
  OldCharAgrOn    :Boolean;
  lProd           :TProducent;
  Pel             :Double;   // moc pobierana z sieci

  aPznMot   :Double; // moc znamionowa motora (P2)
  aP1max    :Double; // maksymalna moc elektryczna
  aP2max    :Double; // maksymalna moc na wale
begin
  if IsMemo then
    EXIT;

  svCur := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    with Pompa.DB do
    begin
  //    if VFieldFloat(M,'M_Nzn',0)<5 then
  //    ObrDBText.DataField := 'brak danych';
  //    eta := OblEta;
  //    eta := Pompa.EtaSilNom;
      if mOK then
      begin
        // Ustawianie skali mocy
        // Trzeba to polaczyc ze skalowaniem w inicie
//        if CharData <> NIL then
//          PFun.CountMaxYR(
//                 Max( Pompa.DB.M.FieldByName('M_PZN').AsFloat,
//                      CharData.GetCharPMax));
//////////////////////////////
// nowe ustawianie skali
        if CharData <> NIL then
          begin
            if cbP_Mot.Visible then
              aPznMot := Pompa.DB.M.FieldByName('M_PZN').AsFloat
            else
              aPznMot := 0;
            if cbP1.Visible then
              aP1max  := CharData.GetCharP1Max
            else
              aP1max  := 0;
            aP2max := CharData.GetCharPMax;
            if aP2max < max(aPznMot,aP1max) then
              PFun.CountMaxYR(max(aPznMot, aP1max));
          end;
//////////////////////////////////
        OldCharAgrOn := not ( (Field['M.PROD'] <> NIL)
                              and (Field['M.ID_NAZWA'] <> NIL)
                              and (Field['M.PROD'].AsString <> '')
                              and (Field['M.ID_NAZWA'].AsString <> '') );

        if not OldCharAgrOn then
        begin
          lProd := Producenci.ProdByName(Field['M.PROD'].AsString);
          if lProd <> NIL then
            bbtnProdSiln.Caption := lProd.Nazwa
          else
            OldCharAgrOn := True;
        end;

        bbtnProdSiln.Visible := not OldCharAgrOn;
        if Pompa.JestEtaAgr and cbEtaAgr.Visible then
        begin
          cbEtaAgr.Enabled := OldCharAgrOn;
          EtaAgrFun.IsOn :=   cbEtaAgr.Checked and OldCharAgrOn;
        end;
      end;
    end;
    FMotObj.Release;
    FMotObj := NIL;
    try
      if Pompa.EtaSilNom>0 then
        begin
          // Do sprawdzenia jak moc silnika jest liczona gdy sa warianty i baza motorow
          SprawLab.Caption := FormatFloat('0.0',pompa.EtaSilNom*100);
          // Na razie wstawiane jest to co sie wyswietla
          Pel := StrToFloat(MocDBText.Caption)/pompa.EtaSilNom;
          LabPel.Caption := FormatFloat('0.00',Pel);
        end
      else
        SprawLab.Caption := 'brak danych';
    except
      SprawLab.Caption :='brak danych';
    end;

    if (Pompa.DB.A.FieldByName('G_ID').AsString = '$M')
       or (Pompa.DB.A.FieldByName('G_ID').AsString = '@@M') then
    begin
      InitRys;
      Rysunek.Invalidate;
    end;

    CloseRap;
    // Obsluga poszczegolnych zakladek
    if PakietPompy.ActivePage = TabCharakterystyka then
      Diagram.Invalidate
    else if PakietPompy.ActivePage = TabRaport then
      PakietPompyChange( TabRaport )
    else if PakietPompy.ActivePage = TabPrzeliczenia then
      PrzelDiagrMinMax
    else if PakietPompy.ActivePage = TabCharNaturalna then
      UpdateCharAgr;
  finally
    Screen.Cursor := svCur;
  end;
end;

procedure TFormPompy.WarMDBGridCellClick(Column: TColumn);
begin
  UpdateM;
end;

procedure TFormPompy.PakietPompyResize(Sender: TObject);
begin
  SetInner;
end;

procedure TFormPompy.InitMWarTab;
var
  i       :Integer;
  bm      :TBookmarkStr;
begin
  with Pompa.DB.WarM do
  begin
    //bm := Bookmark;
    bm := TBookmarkStr(Bookmark); //MS 2024.06.30
    First;
    i := 0;
    while not eof do
    begin
      next;
      inc(i);
    end;
    SetLength(MBMList, i);
    WarMGrid.RowCount := i+1;

    WarMGrid.Cells[1,0] := 'Silnik';
    WarMGrid.Cells[2,0] := 'Napiecie zn';
    WarMGrid.Cells[3,0] := 'Moc zn';
    WarMGrid.Cells[4,0] := 'Obroty';
    WarMGrid.Cells[5,0] := 'Prad';
    WarMGrid.Cells[6,0] := 'Cos(fi)';
    WarMGrid.Cells[7,0] := 'Sprawnosc';
    WarMGrid.Cells[8,0] := 'Stopien ochrony';
    WarMGrid.Cells[9,0] := 'Klasa izolacji';

    i := 0;
    First;
    while not eof do
    begin
      //MBMList[i] := Bookmark;
      MBMList[i] := TBookmarkStr(Bookmark);  //MS 2024.06.30

      inc(i);

      WarMGrid.Cells[1,i] := Pompa.DB.M.FieldByName('M_ID').AsString;
      WarMGrid.Cells[2,i] := Pompa.DB.M.FieldByName('M_TYP').AsString;
      WarMGrid.Cells[3,i] := Pompa.DB.M.FieldByName('M_Pzn').AsString;
      WarMGrid.Cells[4,i] := Pompa.DB.M.FieldByName('M_Nzn').AsString;
      WarMGrid.Cells[5,i] := Pompa.DB.M.FieldByName('Prad').AsString;
      WarMGrid.Cells[6,i] := Pompa.DB.M.FieldByName('Cosf').AsString;
      WarMGrid.Cells[7,i] := FormatFloat( '0.000', OblEta );
      WarMGrid.Cells[8,i] := Pompa.DB.M.FieldByName('IP').AsString;
      WarMGrid.Cells[9,i] := Pompa.DB.M.FieldByName('klasa').AsString;

      next;
    end;
    //Bookmark := bm;
    Bookmark := TBookmark(bm);  //MS 2024.06.30

  end;

end;

procedure TFormPompy.WarMGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if ARow <> WarMGrid.Row then
  begin
    //Pompa.DB.WarM.Bookmark := MBMList[ARow-1];
    Pompa.DB.WarM.Bookmark := TBookmark(MBMList[ARow-1]);  //MS 2024.06.30

    UpdateM;
  end;
end;

function TFormPompy.OblEta: Double;
//Do przeniesienia do narzedzi + wuodrebnienie obliczania Pel
var
  I,U,cFI,moc,eta :Double;

begin
  if not Pompa.DB.mOK then
  begin
    result := 0;
    EXIT;
  end;
  with Pompa.DB do
  begin
    I   := VFieldFloat(M,'prad',0);;
    U   := VFieldFloat(M,'NAP',0);
    cFi := VFieldFloat(M,'cosF',0);
    moc := VFieldFloat(M,'M_Pzn',0);
    try
      if U<300
        then eta := f_div( moc*1000, U*I*cFi )  // MS 001012
        else eta := f_div( moc*1000, sqrt(3) *U*I*cFi );
    except
      eta := 0;
    end;
  end;
  result := eta;
end;

procedure TFormPompy.DiagramDblClick(Sender: TObject);
begin
  if WerPro then
    ShowCharViewer
  else if CHar4PolaZezw then
    Show4CharViewer;
end;

procedure TFormPompy.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FCharViewer then
      FCharViewer := NIL
    else if AComponent = FPompa then
    begin
      FPompa := NIL;
      if not (csDestroying in ComponentState) then
        Close;
    end
//    else if AComponent = Rap then
//      Rap := NIL
//    else if AComponent = FrmPrev then
//      FrmPrev := NIL
    else if AComponent = FMotObj then
      FMotObj := NIL;
  end;      
  inherited;
end;

function TFormPompy.KopiaPompyPrzeliczonej: TPompa;
var
  P      :TPompa;
begin
  //P := NIL;
  result:= NIL;

  if PrzelCharData = NIL then
    EXIT;
  P := Pompa.MakeCopy;
  if P = NIL then
    EXIT;
  try
    if Pompa.MoznaStoczyc then
      P.GetCharData.Srednica := PrzelCharData.Srednica;
    if Pompa.MoznaObroty then
      P.GetCharData.Obroty := PrzelCharData.Obroty;
    P.UpdateDB;
  except
    P.Free;
    raise;
  end;

  result := P;
end;

procedure TFormPompy.SaveToUserBtnClick(Sender: TObject);
var
  P       :TPompa;
  done    :Boolean;
  F       :TSavePmpAsToUserFrm;
begin
  P := KopiaPompyPrzeliczonej;
  if P = NIL then
  begin
    ShowMessage( 'Nie mozna stworzyc kopii pompy' );
    EXIT;
  end;
  P.AddRef;
  try
    done := true;
    F := TSavePmpAsToUserFrm.Create(self);
    try
      repeat
        F.NazwaPompy := P.Nazwa;
        if F.Execute then
        begin
          P.Nazwa := F.NazwaPompy;
          try
            P.AddToUserBase;
          except
            on EDBNameDuplError do
            begin
              if MessageBox( Handle,
                      'Istnieje juz pompa o tej nazwie'#13 +
                      'W bazie uzytkownika pompy musza miec nazwy unikalne'#13+
                      'Czy chcesz zmienic nazwe?',
                      'UWAGA', MB_YESNO or MB_ICONQUESTION) = IDYES then
                done := false;
            end;
          end;
        end;
      until done;
    finally
      F.Free;
    end;
  finally
    P.Release;
  end;
end;

function TFormPompy.GetNazwaPompyFN: string;
var
  i      :Integer;
  s      :string;
begin
  s := NazwaPompy;
  for i := 1 to Length(s) do
  begin
    if s[i] in ['.',',','/','\','<','>','?','*','''','"'] then
      s[i] := '_';
  end;
  result := s;
end;

procedure TFormPompy.ShowCharViewer;
begin
  if not (CharData is TFuncCharData) then
    EXIT;
  if FCharViewer = NIL then
  begin
    FCharViewer := TWPmpCharViewer.Create(self);
    FCharViewer.Pompa := self.Pompa;
    FCharViewer.DefaultCloseAction := caHide;
  end;
  FCharViewer.Show;
end;

procedure TFormPompy.Show4CharViewer;
begin
  if F4CharViewer = NIL then
  begin
    F4CharViewer := TCustomPmpCharViewer.Create(self);
    F4CharViewer.Pompa := self.Pompa;
    F4CharViewer.DefaultCloseAction := caHide;
  end;
  F4CharViewer.Show;
end;

procedure TFormPompy.CharCalcPolBtnClick(Sender: TObject);
begin
  ShowCharViewer;
end;

procedure TFormPompy.PrzP_MotFunValue(X: Double; var Y: Double);
begin
  if Pompa.DB.mOK then
  begin
    Y := Pompa.DB.M.FieldByName('M_PZN').AsFloat;
  end
  else
    Y := 0;

end;

procedure TFormPompy.TabPrzeliczeniaShow(Sender: TObject);
begin
  if not PrzelInited then
    PrzelInit;
  PrzelDiagrMinMax;
  SetDopasEnabled;
end;

procedure TFormPompy.EtaAgrFunValue(X: Double; var Y: Double);
begin
  Y := Pompa.EtaAgr(X);
end;

procedure TFormPompy.FreqCalcBtnClick(Sender: TObject);
var
  F       :TFreqCalcForm;
begin
  if (CharData = NIL) or (CharData.Obroty=0) then
    EXIT;
  F := TFreqCalcForm.Create(self);
  try
    F.ObrNom   := CharData.Obroty;
    F.CzestNom := 50;
    F.ObrWym   := PrzObrWymEd.ValueFloat;
    if F.Execute then
    begin
      PrzObrWymEd.ValueFloat := F.ObrWym;
      Przelicz;
    end;
  finally
    F.Free;
  end;

end;

procedure TFormPompy.Char4BtnClick(Sender: TObject);
begin
  Show4CharViewer;
end;

procedure TFormPompy.CloseRap;
begin
//  if (Rap <> NIL) and (not FRapClosed) then
//  begin
//    FRapClosed := true;
//    FrmPrev.ClosePreview;
//    FrmPrev.Free;
//    Rap.Free;
//  end;
end;

procedure TFormPompy.CreateRap;
begin
//  if Rap = NIL then
//  begin
//    if Pompa.Producent.Ident = 'BIALOG' then
//      Rap := TRaportPompyBialog.Create(self)
//    else
//      Rap := TRaportPompy.Create(self);
//    Rap.ReportTitle := Format( 'Pompa: %s', [Pompa.Nazwa] );
//    Rap.Align := alNone;
//    FRapClosed := false;
//    OsadzRaport( self, Rap, PanelDoWst, FrmPrev);
//  end;
end;

function TFormPompy.CreateMotObj: TMotorObject;
begin
  Result := CreateMotObjFromPmp(Pompa);
end;
{
var
  mbi     :TMotBaseInfo;
  mo      :TMotorObject;
  sql     :string;
  pr      :TProducent;
  fld     :TField;
  q       :TQuery;
begin
  Result := NIL;
  mo := NIL;
  fld := Pompa.DB.M.FindField('PROD');
  if fld = NIL then
    EXIT;

  pr := Producenci.ProdByName(fld.AsString);
  if pr = NIL then
    EXIT;

  try
    mbi := pr.InfoBazT['MOTORS'] as TMotBaseInfo;
  except on EInvalidCast do
    EXIT;
  end;
  if mbi = NIL then
    EXIT;


  sql := mbi.GenerSQLText( Format( 'A.NAZWA = "%s"',
                                   [Pompa.DB.M.FieldByName('M_ID').AsString]));
  q := TQuery.Create(self);
  try
    q.DatabaseName := mbi.GetPath;
    q.SQL.Text := sql;
    q.Open;
    if q.FieldByName('NAZWA').AsString = Pompa.DB.M.FieldByName('M_ID').AsString then
    try
      mo := CreateMotor( q, Pr );
    finally
      q.Close;
    end;
  finally
    q.Free;
  end;
  Result := mo;
end;
}

procedure TFormPompy.ShowProdM;
var
  mo      :TMotorObject;
  F       :TForm;
begin
  mo := CreateMotObj;
  if mo <> NIL then
  begin
    F := mo.CreateForm(self, '/MDI');
    F.Show;
  end;
end;

procedure TFormPompy.WarMGridDblClick(Sender: TObject);
begin
  ShowProdM;
end;

procedure TFormPompy.TypDBTextDblClick(Sender: TObject);
begin
  ShowProdM;
end;

procedure TFormPompy.RysTabsChange(Sender: TObject);
begin
  // co tu sie dzieje
  Rysunek.Invalidate;
  if IsWarG then
    //Pompa.DB.WarG.Bookmark := FWarGBM[ RysTabs.TabIndex ];
    Pompa.DB.WarG.Bookmark := TBookmark(FWarGBM[ RysTabs.TabIndex ]);    //MS 2024.06.30

  with Pompa.DB do
    sbtnRysInfo.Visible := gOK and (Field['G.PDF'] <> NIL)
                           and (Field['G.PDF'].AsString <> '');
  CloseRap;
end;

function TFormPompy.GetDXFDraw: TPompDXFDrawing;
begin
  if RysTabs.TabIndex > 0 then
    result := FDxfs[RysTabs.TabIndex]
  else
    result := FDxfs[0];
end;

procedure TFormPompy.InitCharNatFrst;
begin
  if (CharData = NIL) or (not Pompa.DB.hOK)
     or (Pompa.DB.Field['H.H_N'].AsFloat = 0)
     or not FPompa.DB.BaseInfo.tbsf.ReadBool('OPTIONS',
                    'FormPompy_CharAgr', True )
     or ( (Pompa.DB.Field['H.H_TYP_N'] <> NIL)
           and (Pompa.DB.Field['H.H_TYP_N'].AsString = 'ZO') )
     then
  begin
    TabCharNaturalna.TabVisible := False;
    EXIT;
  end;
  CharData.GetDiagFun( 'H', dfunHNatOrg );
  CharData.GetDiagFun( 'P', dfunPNatOrg );
  CharData.GetDiagFun( 'ETA', dfunEtaNatOrg );

  AddFunChk( dfunHNatOrg,   chkHNatOrg,   'HNatOrg' );
  AddFunChk( dfunPNatOrg,   chkPNatOrg,   'PNatOrg' );
  AddFunChk( dfunEtaNatOrg, chkEtaNatOrg, 'EtaNatOrg' );

  AddFunChk( dfunHNat,         chkHNat,       'HNat' );
  AddFunChk( dfunPNat,         chkPNat,       'PNat' );
  AddFunChk( dfunPNatElektr,   chkPNatElektr, 'PNatElektr' );
  AddFunChk( dfunEtaNatElektr, chkEtaNatAgr,  'EtaNatElektr' );
  AddFunChk( dfunNNat,         chkNNat,       'NNat' );

end;

procedure TFormPompy.InitCharNat(mo: TMotorElektr);
begin
  if CharNatur = NIL then
    CharNatur := TSZCharDataCopy.Create(self);
  CharNatur.Clear;
  if (CharData is TFuncCharData) and (mo <> NIL) then
  begin
    diagCharNat.Visible   := True;
    panCharNatMain.Caption := '';
    chkHNat.Enabled       := True;
    chkPNat.Enabled       := True;
    chkPNatElektr.Enabled := True;
    chkEtaNatAgr.Enabled  := True;
    chkNNat.Enabled       := True;

    ObliczCharNatur( CharNatur, TFuncCharData(CharData), mo );
    CharNatur.GetDiagFun( 'H', dfunHNat );
    CharNatur.GetDiagFun( 'P', dfunPNat );
    dfunPNatElektr.MinXRDraw := CharNatur.FCharQMin;
    dfunPNatElektr.MaxXRDraw := CharNatur.FCharQMax;
    dfunNNat.CountMaxYR( TMotorElektr(FMotObj).FunN.YMax );
    dfunNNat.MinXRDraw := CharNatur.FCharQMin;
    dfunNNat.MaxXRDraw := CharNatur.FCharQMax;
    dfunEtaNatElektr.MinXRDraw := CharNatur.FCharQMin;
    dfunEtaNatElektr.MaxXRDraw := CharNatur.FCharQMax;
    if Pompa.JestEtaAgr and cbEtaAgr.Visible then
    begin
      cbEtaAgr.Enabled := False;
      EtaAgrFun.IsOn := False;
    end;

  end
  else
  begin
    diagCharNat.Visible   := False;
    chkHNat.Enabled       := False;
    chkPNat.Enabled       := False;
    chkPNatElektr.Enabled := False;
    chkEtaNatAgr.Enabled  := False;
    chkNNat.Enabled       := False;

    dfunHNat.Drawer.Free;
    dfunPNat.Drawer.Free;
    if Pompa.JestEtaAgr and cbEtaAgr.Visible then
    begin
      cbEtaAgr.Enabled := True;
      EtaAgrFun.IsOn := cbEtaAgr.Checked;
    end;
  end;
end;

procedure TFormPompy.dfunPNatElektrValue(X: Double; var Y: Double);
begin
  Y := P_AgrOdQ(X);
end;

function TFormPompy.P_AgrOdQ(q: Double): Double;
var
  pnat   :Double;
begin
  if not (FMotObj is TMotorElektr) then
  begin
    Result := 0;
    EXIT;
  end;
  pnat := CharNatur.P(q);
  Result := F_DIV(pnat, TMotorElektr(FMotObj).Eta_OdP(pnat));
end;

procedure TFormPompy.dfunNNatValue(X: Double; var Y: Double);
begin
  if not (FMotObj is TMotorElektr) then
  begin
    Y := 0;
    EXIT;
  end;
  Y := TMotorElektr(FMotObj).N_OdP(CharNatur.P(X));

end;

procedure TFormPompy.dfunEtaNatElektrValue(X: Double; var Y: Double);
begin
  if not (FMotObj is TMotorElektr) then
  begin
    Y := 0;
    EXIT;
  end;
  Y := CharNatur.Eta(X) * TMotorElektr(FMotObj).Eta_OdP(CharNatur.P(X));
end;

procedure TFormPompy.AddFunChk(AFun: TDiagFunction; AChkB: TCheckBox;
  const AId: string);
var
  pos   :Integer;
begin
  pos := Length(FFunChkArray);
  SetLength( FFunChkArray, pos+1 );
  with FFunChkArray[pos] do
  begin
    DiagFun := AFun;
    ChkB    := AChkB;
    Id      := AId;
  end;
  SetCheckColor(AChkB, AFun.Color);

end;

procedure TFormPompy.SetFunChkColor(AChkB: TCheckBox; AColor: TColor);
var
  i       :Integer;
begin
  SetCheckColor( AChkB, AColor );
  for i := Low( FFunChkArray ) to High( FFunChkArray ) do
  begin
    if AChkB = FFunChkArray[i].ChkB then
    begin
      FFunChkArray[i].DiagFun.Color := AColor;
    end;
  end;
end;

procedure TFormPompy.FunChkClick(AChkB: TCheckBox);
var
  i       :Integer;
begin
  for i := Low( FFunChkArray ) to High( FFunChkArray ) do
    if AChkB = FFunChkArray[i].ChkB then
      FFunChkArray[i].DiagFun.IsOn := AChkB.Checked;
end;

procedure TFormPompy.chkCharClick(Sender: TObject);
begin
  FunChkClick(TCheckBox(Sender));
end;

procedure TFormPompy.SetCheckColor(AChkB: TCheckBox; bc: TColor);
begin
  AChkB.Color := bc;
  if (Integer(ColorGetB(bc)) + ColorGetG(bc)) < $FF then
    AChkB.Font.Color := clWhite
  else
    AChkB.Font.Color := clBlack;
end;

procedure TFormPompy.chkCharMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    if Sender is TCheckBox then
    begin
      ColorDialog.Color := TCheckBox(Sender).Color;
      if ColorDialog.Execute then
        SetFunChkColor( TCheckBox(Sender), ColorDialog.Color );
    end;
  end;
end;

procedure TFormPompy.UpdateCharAgr;
var
  mo      :TMotorObject;

begin
  if FMotObj <> NIL then
  begin
    FMotObj.Release;
    FMotObj := NIL;
  end;
  try
    mo := CreateMotObj;
    if mo = NIL then
    begin
      InitCharNat( NIL ); //Robi charakterystyke naturalna
      panCharNatMain.Caption := 'Brak charakterystyk silnika';
    end
    else if not (mo is TMotorElektr) then
    begin
      mo.Free;
      InitCharNat( NIL );
      panCharNatMain.Caption := 'Nieobslugiwany typ silnika';
    end
    else if abs(mo.NZn-CharData.Obroty) > (0.15*CharData.Obroty) then
    begin
      InitCharNat( NIL );
      panCharNatMain.Caption := 'Zbyt duza roznica obrotow silnika i pompy';
    end
    else   // OK
    begin
      mo.AddRef;
      FMotObj := mo;
      //FMotObj.FreeNotification(mo);
      InitCharNat( TMotorElektr(mo) );
    end;
  except
    InitCharNat( NIL );
    panCharNatMain.Caption := 'Blad podczas obliczen';
  end;

end;

procedure TFormPompy.TabCharNaturalnaShow(Sender: TObject);
begin
  if FMotObj = NIL then
    UpdateCharAgr;
end;

procedure TFormPompy.WypelnijRzeczywiste;
var
  TmpPelr : double;
begin
  if Pompa.CharSel is TStdPompCharSel then with Pompa.CharSel as TStdPompCharSel do
  begin
    labQWym.Caption := FormatFloat( '0.00', m3hToU(GetQw ));
    labHWym.Caption := FormatFloat( '0.00', GetHw );

    labQrVal.Caption := FormatFloat( '0.00', m3hToU(Pompa.Qr));
    labHrVal.Caption := FormatFloat( '0.00', Pompa.Hr );

    edCharPrzelDopasQ.ValueFloat := GetQw;
    edCharPrzelDopasH.ValueFloat := GetHw;
    SetDopasEnabled;

    if not IsZero(GetQw) then
      labOdchylQ.Caption := FormatFloat( '0.0', (Pompa.Qr-GetQw)/GetQw * 100 );
    if not IsZero(GetHw) then
      labOdchylH.Caption := FormatFloat( '0.0', (Pompa.Hr-GetHw)/GetHw * 100 );

    if Pompa.ParObliczone then
    begin
      labETArVal.Caption := FormatFloat( '0.0', Pompa.ETAr * 100 );

      if Pompa.DB.H.FieldByName('P_MET').AsString = 'P1' then
        begin
          LabPelr.Caption := FormatFloat( '0.000', Pompa.Pr );         //Pr2
          labPrVal.Caption := FormatFloat( '0.000', Pompa.Pr*Pompa.EtaSilNom ); // Pr1
        end
      else
        begin
          labPrVal.Caption := FormatFloat( '0.000', Pompa.Pr ); //Pr2
          if pompa.EtaSilNom > 0 then
            TmpPelr := Pompa.Pr/Pompa.EtaSilNom;
          LabPelr.Caption := FormatFloat( '0.000', TmpPelr );   // Pr1
        end;

      labNPSHrVal.Caption := FormatFloat( '0.00', Pompa.NPSHr );
    end
    // dla zgodnoci z poprzednimi wersjami
    else if CharData is TFuncCharData then with CharData as TFuncCharData do
    begin
      labETArVal.Caption := FormatFloat( '0.000', Eta(Pompa.Qr) );
      labPrVal.Caption := FormatFloat( '0.000', Pompa.Pr );
      labNPSHrVal.Caption := FormatFloat( '0.00', NPSH(Pompa.Qr) );
    end
    else
    begin
      labPrVal.Visible := false;
      labETArVal.Visible := false;
      labNPSHrVal.Visible := false;
      labNPSH.Visible := false;
      labMocR.Visible := false;
      labSpraw.Visible := false;
      labPrJedn.Visible := false;
      labETArJedn.Visible := false;
      labNPSHrJedn.Visible := false;
    end;
  end
  else if Pompa.ParObliczone then with Pompa.CharSel do
  // MS 2012.01.30 modyfikacja do wyswietlania danych DLA GRU
  //else if Pompa.Qr>0 then with Pompa.CharSel do
  begin
    labQWym.Caption := FormatFloat( '0.00', m3hToU(GetQw));
    labHWym.Caption := FormatFloat( '0.00', GetHw );

    labQrVal.Caption := FormatFloat( '0.00', m3hToU(Pompa.Qr));
    labHrVal.Caption := FormatFloat( '0.00', Pompa.Hr );

    edCharPrzelDopasQ.ValueFloat := GetQw;
    edCharPrzelDopasH.ValueFloat := GetHw;
    SetDopasEnabled;

    if not IsZero(GetQw) then
      labOdchylQ.Caption := FormatFloat( '0.0', (Pompa.Qr-GetQw)/GetQw * 100 );
    if not IsZero(GetHw) then
      labOdchylH.Caption := FormatFloat( '0.0', (Pompa.Hr-GetHw)/GetHw * 100 );

    labETArVal.Caption  := FormatFloat( '0.000', Pompa.ETAr );
    labPrVal.Caption    := FormatFloat( '0.000', Pompa.Pr );
    labNPSHrVal.Caption := FormatFloat( '0.00',  Pompa.NPSHr );
  end
  else
  begin
    gbRzeczywiste.Visible := false;
    gbWymagane.Visible := false;
  end;
end;

procedure TFormPompy.edCharPrzelDopasQChange(Sender: TObject);
begin
  SetDopasEnabled;
end;

procedure TFormPompy.edCharPrzelDopasHChange(Sender: TObject);
begin
  SetDopasEnabled;
end;

procedure TFormPompy.SetDopasEnabled;
var
  enb     :Boolean;
begin
  enb := (edCharPrzelDopasQ.ValueFloat > 0)
         and (edCharPrzelDopasH.ValueFloat > 0)
         and edCharPrzelDopasQ.Enabled
         and edCharPrzelDopasH.Enabled;
  sbtnPrzelObrDopas.Enabled := enb and Pompa.MoznaObroty;
  sbtnPrzelSrednDopas.Enabled := enb and Pompa.MoznaStoczyc;
  PrzHFunPktDop.IsOn := enb;
  if enb and (FPrzelPunktDFun <> NIL) then
  begin
    FPrzelPunktDFun.Q := edCharPrzelDopasQ.ValueFloat;
    FPrzelPunktDFun.H := edCharPrzelDopasH.ValueFloat;
  end;
end;

procedure TFormPompy.sbtnPrzelObrDopasClick(Sender: TObject);
var
  cs      :TPmpRegCharSelPomoc;
  qr, hr  :Double;
  q1, h1  :Double;
  N0, N1  :Double;
begin
  if PrzelCieczCharData = NIL then
    EXIT;
  cs := TPmpRegCharSelPomoc.Create;
  try
    q1 := edCharPrzelDopasQ.ValueFloat;
    h1 := edCharPrzelDopasH.ValueFloat;
    cs.Func := TRegNFunct.CreateQH( q1, h1 );
    if PrzelCieczCharData.WorkPoint( cs, qr, hr ) then
    begin
      N0 := PrzelCharData.Obroty;
      N1 := 0;
      try
        //N1 := sqrt(N0*N0 * F_DIV(q1, qr))
        N1 := N0 * F_DIV(q1, qr);
      except
        on EMathError do
        begin
          N1 := N0*f_div(h1 , hr);
        end;
      end;
      if N1 <> 0 then
      begin
        PrzObrWymEd.ValueFloat := N1;
        Przelicz;
      end;
    end;
  finally
    cs.Free;
  end;
end;

procedure TFormPompy.sbtnPrzelSrednDopasClick(Sender: TObject);
var
  cs      :TPmpRegCharSelPomoc;
  qr, hr  :Double;
  q1, h1  :Double;
  D0, D1   :Double;
begin
  if PrzelCieczCharData = NIL then
    EXIT;
  cs := TPmpRegCharSelPomoc.Create;
  try
    q1 := edCharPrzelDopasQ.ValueFloat;
    h1 := edCharPrzelDopasH.ValueFloat;
    cs.Func := TRegDFunct.CreateQH( q1, h1 );
    if PrzelCieczCharData.WorkPoint( cs, qr, hr ) then
    begin
      D0 := PrzelCharData.Srednica;
      D1 := 0;
      try
        //N1 := sqrt(N0*N0 * F_DIV(q1, qr))
        D1 := sqrt(D0*D0 * F_DIV(q1, qr));
      except
        on EMathError do
        begin
          D1 := sqrt(D0*D0 * F_DIV(h1, hr));
        end;
      end;
      if D1 <> 0 then
      begin
        PrzSredWymEd.ValueFloat := D1;
        Przelicz;
      end;
    end;
  finally
    cs.Free;
  end;
end;

procedure TFormPompy.mnuDiagOpisyCharakterystykClick(Sender: TObject);
begin
  with mnuDiagOpisyCharakterystyk do
  begin
    Checked := not Checked;
    if HFun.Drawer is TFuncDiagFun then with TFuncDiagFun(HFun.Drawer) do
      Legend := Checked;
    if PFun.Drawer is TFuncDiagFun then with TFuncDiagFun(PFun.Drawer) do
      Legend := Checked;
    if NPSHFun.Drawer is TFuncDiagFun then with TFuncDiagFun(NPSHFun.Drawer) do
      Legend := Checked;
    if ETAFun.Drawer is TFuncDiagFun then with TFuncDiagFun(ETAFun.Drawer) do
      Legend := Checked;
    Diagram.Invalidate;
  end;
end;

procedure TFormPompy.sbtnDiagKonfMinusClick(Sender: TObject);

  function getD(df :TDiagFunction) :Double;
  begin
    Result := (df.MaxYR - df.MinYR) / Diagram.YCells;
  end;
  procedure Zmien( df :TDiagFunction; d :Double );
  begin
    df.MaxYR := df.MaxYR - d;
  end;
var
  dH, dP, dNPSH, dEta :Double;
begin
  dH := getD(HFun);
  dP := getD(PFun);
  dNPSH := getD(NPSHFun);
  dEta := getD(EtaFun);

  Diagram.YCells := Diagram.YCells -1;

  Zmien( HFun, dH );
  Zmien( PFun, dP );
  Zmien( NPSHFun, dNPSH );
  Zmien( EtaFun, dEta );

  with Diagram do
    if YCells < 6 then
      YCells := YCells * 2;

end;

procedure TFormPompy.sbtnDiagKonfPlusClick(Sender: TObject);

  function getD(df :TDiagFunction) :Double;
  begin
    Result := (df.MaxYR - df.MinYR) / Diagram.YCells;
  end;
  procedure Zmien( df :TDiagFunction; d :Double );
  begin
    df.MaxYR := df.MaxYR + d;
  end;
var
  dH, dP, dNPSH, dEta :Double;
begin
  dH := getD(HFun);
  dP := getD(PFun);
  dNPSH := getD(NPSHFun);
  dEta := getD(EtaFun);

  Diagram.YCells := Diagram.YCells +1;

  Zmien( HFun, dH );
  Zmien( PFun, dP );
  Zmien( NPSHFun, dNPSH );
  Zmien( EtaFun, dEta );

  with Diagram do
    if (YCells > 11) and not odd(YCells) then
      YCells := YCells div 2;
end;

procedure TFormPompy.DiagramMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  rx, ry  :Double;
  AHit    :Boolean;

  function OblZakr( x, x1, a, b :Double ) :Double;
  begin
    //   (b-a) * (x-a)
    //   ------------- + a
    //      x1 - a
    Result := (b-a) * (x-a) / (x1-a) + a;
  end;

  procedure DoMove;
  var
    n       :Integer;
    i       :Integer;
    dy      :Double;
  begin
    FMovedFun.ScrToReal( X, Y, rx, ry );
    dy := Round((FMvFunVal - ry) / FMvFunSkok) * FMvFunSkok;
    if dy <> 0 then
    begin
      FMovedFun.SetMinMaxYR( FMovedFun.MinYR + dy, FMovedFun.MaxYR + dy);
    end;
  end;

  procedure DoScaleUp;
  var
    RTop    :Double;
    RDz     :Double;
    NMax    :Double;
  begin
    FMovedFun.ScrToReal( X, Y, rx, ry );
    if ry < Lin( 1, 0, 10, FMovedFun.MinYR, FMovedFun.MaxYR ) then
      EXIT;
    RTop := OblZakr( FMvFunVal, ry, FMovedFun.MinYR, FMovedFun.MaxYR );
    RDz  := (RTop - FMovedFun.MinYR) / Diagram.YCells;
    RDz  := RoundX( RDz, 2 );
    FMovedFun.MaxYR := FMovedFun.MinYR + Diagram.YCells*RDz;
  end;

  procedure DoScaleDown;
  var
    Z       :Double;
    Dz     :Double;
    NMax    :Double;
  begin
    FMovedFun.ScrToReal( X, Y, rx, ry );
    if ry > Lin( 1, 0, 10, FMovedFun.MaxYR, FMovedFun.MinYR ) then
      EXIT;
    Z    := OblZakr( FMvFunVal, ry, FMovedFun.MaxYR, FMovedFun.MinYR );
    Dz  := (FMovedFun.MaxYR - Z) / Diagram.YCells;
    Dz  := RoundX( Dz, 2 );
    FMovedFun.MinYR := FMovedFun.MaxYR - Diagram.YCells*Dz;
  end;


begin
  if FMovedFun = NIL then
  begin
    if Diagram.ScaleYPosTest( X, Y, HFun ) then
      AHit := True
    else if Diagram.ScaleYPosTest( X, Y, PFun ) then
      AHit := True
    else if Diagram.ScaleYPosTest( X, Y, EtaFun ) then
      AHit := True
    else if cbNPSH.Visible and cbNPSH.Enabled
          and Diagram.ScaleYPosTest( X, Y, NPSHFun ) then
      AHit := True
    else
      AHit := False;
    if not AHit then
      Diagram.Cursor := crDefault
    else if not (ssCtrl	in Shift) then
      Diagram.Cursor := crSizeNS
    else with Diagram do
    begin
      Cursor := CursorsData.ArrowUpCur.Cursor
    end;
  end
  else
  begin
    if FMvFunType = mftMove then
      DoMove
    else if FMvFunType = mftScaleUp then
      DoScaleUp
    else if FMvFunType = mftScaleDown then
      DoScaleDown;
  end;
end;

procedure TFormPompy.DiagramMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  rx, ry  :Double;

  procedure ObliczSkok;
  var
    n       :Integer;
    i       :Integer;
    rzad    :Double;
    d       :Double;
  begin
    FMovedFun.ScrToReal( X, Y, rx, ry );
    if FMovedFun.DecYScale > 0 then
      rzad := IntPower( 10, -FMovedFun.DecYScale )
    else
    begin
      rzad := RzadWielkosci10wDol( FMovedFun.Podzialka );
      d := FMovedFun.Podzialka / rzad;
      if abs(d - Round(d)) > 0.099 then
        rzad := rzad / 10;
      n := trunc(log10(rzad));
      for i := n-1 downto 0 do
        if GetDigit10( FMovedFun.MinYR, i ) <> 0 then
          rzad := IntPower( 10, i );
    end;
    FMvFunSkok := rzad;
  end;

begin
  if Button = mbLeft then
  begin
    if Diagram.ScaleYPosTest( X, Y, HFun ) then
      FMovedFun := HFun
    else if Diagram.ScaleYPosTest( X, Y, PFun ) then
      FMovedFun := PFun
    else if Diagram.ScaleYPosTest( X, Y, EtaFun ) then
      FMovedFun := ETAFun
    else if cbNPSH.Visible and cbNPSH.Enabled
          and Diagram.ScaleYPosTest( X, Y, NPSHFun ) then
      FMovedFun := NPSHFun
    else
      FMovedFun := NIL;

    if FMovedFun <> NIL then
    begin
      FMovedFun.ScrToReal( X, Y, rx, ry );
      FMvFunVal := ry;

      if not (ssCtrl in Shift) then
      begin
        FMvFunType := mftMove;
        ObliczSkok;
      end
      else with Diagram do
      begin
        FMvFunType := mftScaleUp
      end;
    end;
  end;
end;

procedure TFormPompy.DiagramMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FMovedFun <> NIL) then
    FMovedFun := NIL;
end;

procedure TFormPompy.pmnuPrzelDiagCopyClick(Sender: TObject);
begin
  Clipboard.Assign(PrzeliczDiag);
end;

procedure TFormPompy.pmnuDiagramPopup(Sender: TObject);
begin
  mnuDiagEksport.Visible := (CharData is TFuncCharData) and ExportEpanet ;
end;

procedure TFormPompy.mnuDiagEksportHClick(Sender: TObject);
begin
  with EpanetCharSaveDlg do
  begin
    FileName := NazwaPompyFN+' (H)';
    if Execute then
    begin
      Pompa.ExportToEpanetFile(FileName, 'H', 20);
    end;
  end;
end;

procedure TFormPompy.mnuDiagEksportETAClick(Sender: TObject);
begin
  with EpanetCharSaveDlg do
  begin
    FileName := NazwaPompyFN+' (Eta)';
    if Execute then
    begin
      Pompa.ExportToEpanetFile(FileName, 'ETA', 20);
    end;
  end;

end;

procedure TFormPompy.ClearDxfs;
var
  i       :Integer;
begin
  for i := Low(FDxfs) to High(FDxfs) do
  begin
    FDxfs[i].Free;
    FDxfs[i] := NIL;
  end;

end;

procedure TFormPompy.sbtnRysInfoClick(Sender: TObject);
var
  FN      :string;
begin
  FN := Pompa.Producent.BazySciezka['PUMPS'] +
        '\pdf\' + Pompa.DB.Field['G.PDF'].AsString + '.pdf';
  if FileExists(FN) then
    ShellExecute( 0, NIL, PChar(FN), NIL, NIL, SW_NORMAL );
end;

procedure TFormPompy.TabPDFShow(Sender: TObject);
var
  bi  :TBaseInfo;
  s, TN   :string;
begin
//  s := 'H:\RysGru\' + DBTextPDF.Caption;
//  s := FindKatalCD + '\Draw\' + DBTextPDF.Caption;
{  try
   PDFView.Visible := true;
  except
   PDFView.Visible := False;
   exit;
  end;
}
  s := SciezkaBaz + '\Gru\PDF\' + DBTextPDF.Caption;
  if FileExists(s) then
     UtworzPDF(s)
  else
    begin
      s := FindKatalCD + '\Draw\' + DBTextPDF.Caption;
      if FileExists(s) then
         UtworzPDF(s)
    end;

  EditSciezkaPdf.Text := SciezkaZasob;   //to usunac
end;

procedure TFormPompy.Button1Click(Sender: TObject);
begin
//  ShellExecute( 0 , nil , 'Sciezka ' , nil , nil , SW_SHOWNORMAL );
  ShellExecute( 0 , nil , Pchar(EditSciezkaPdf.Text+DBTextPDF.Caption) , nil , nil , SW_SHOWNORMAL );
end;

procedure TFormPompy.Button2Click(Sender: TObject);
begin
  inherited;
  frxReport1.ShowReport();
end;

procedure TFormPompy.TabCharakterystykaShow(Sender: TObject);
begin
// QJednDescr.Text := 'Q '+CapQ;
// Diagram.XJednostki := 1/UTom3h(1);
// Diagram.CountMaxXRAuto(Pompa.CharQMax);
end;

procedure TFormPompy.TBSM_Unit(var msg: TMessage);
begin
  if pakietPompy.ActivePage = TabCharakterystyka then TabCharakterystykaShow(nil);
end;

procedure TFormPompy.DiagFunP1Value(X: Double; var Y: Double);
begin
  if etasiln > 0 then
    //Y := Pompa.P(X)*etasiln // powinno byc  Y := Pompa.P(X)/etasiln
                              // tak zostanie puki nie przeliczymy bazy
    Y := Pompa.P(X)
  else
    Y := 0;
end;

procedure TFormPompy.cbP1Click(Sender: TObject);
begin
  if DiagFunP1 <> nil then
    DiagFunP1.IsOn := cbP1.Checked;
  CloseRap;
end;

procedure TFormPompy.cbP1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    if Sender is TCheckBox then
    begin
      ColorDialog.Color := TCheckBox(Sender).Color;
      if ColorDialog.Execute then
        SetFunChkColor( TCheckBox(Sender), ColorDialog.Color );
    end;
  end;
end;

procedure TFormPompy.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(Self);
end;

procedure TFormPompy.FormKeyPress(Sender: TObject; var Key: Char);
begin
 // NIE DZIALA
 if TControl(Sender).name = 'ZoomEd' then
   if key = #13 then TControl(sender).Perform(WM_NEXTDLGCTL,0,0);
end;

procedure TFormPompy.UtworzPDF(s: string);
begin
{ if not Assigned(PDFView) then
 try
   PDFView := TAcroPDF.Create(PanelDoAcrobata);
   PDFView.Parent := PanelDoAcrobata;
   PDFView.Align := alClient;
   TAcroPDF(PDFView).src := s;
  except
     Application.MessageBox(PChar(TTlumacz.DajObiekt.ZnajdzTlumaczenie(NieMaAcrobata1)+#10+
                                  TTlumacz.DajObiekt.ZnajdzTlumaczenie(NieMaAcrobata2)),
                            PChar(TTlumacz.DajObiekt.ZnajdzTlumaczenie(blad)),MB_OK + MB_ICONWARNING	);
 end
 else
 begin
   if Assigned(PDFView)  then TAcroPDF(PDFView).src  := s;
 end;}
end;

procedure TFormPompy.PanelDoAcrobataResize(Sender: TObject);
begin
 PanelDoAcrobata.SetFocus;
 if Assigned(PDFView)  then PDFView.SetFocus;
end;



initialization
  CoInitialize(nil);
  RegisterPompForm(TPompa, TFormPompy);

finalization

end.
