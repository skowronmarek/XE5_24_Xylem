unit Main_Kat;

interface

uses
  SysUtils, Windows, ShellApi, CommCtrl, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, DBCtrls,
  IniFiles, DB,
  KR_Class,
  KR_Ctrls,
  TBS_Defs,
  TbsU,
  WkpGlob,
  OPompa,
  StrForm,
  PrzegBrw,
  PrzegBrwNoMDI,
  FPompy,
  JezykTxt,
  AboutFrm,
  ZadU,
  PumpIntf,
  // MS 2024.10.17 wylaczone ArmStruc,
  // MS 2024.10.17 MotStrFormU,
  FiltryGlob,
  StdZadSzukPomp,
  //ZamienStrFrm,
  VDivDockHostU,

  FPmpIBrw,
  //RaportPompyU,
  PmpListU,
  // MS 2024.10.17 PmpBuffU,
  // MS 2024.10.17 PmpBufFrm,
  // MS 2024.10.17 PPS_BiaZadU, PPS_GruZadU, //PPS_MetZadU, // przepompownie sciekow
  //PPT_GruZadU,
  //PPZ_GruZadU, //PP_UniZadU,                                // tlocznie
  //StudHVZadU,
  //ZbiorHVZadU,
  OknoKoncoweU,
  // MS 2024.10.17 StoczWFPZadU,
  // MS 2024.10.17 // MS 2024.10.17 PrzeglCharSkladU,
  // MS 2024.10.17 SiecZbZadU,
  ProgrFrmU,
  ActnList, ImgList, SpeedButtonExtU, ToolWin, ComCtrls,
  //TeEngine, TeeFunci, Series, TeeProcs, Chart,
  PropertyAccesserU,
  FormSaverU,
  Jezyki,
  // MS 2024.10.17 HtmlHlp,
  Raport_FR_00, // MS 2024.10.17
  System.Actions;

type
  TKatalogGlowneOkno = class(TForm)
    StatusLine: TPanel;
    MainMenu1: TMainMenu;
    BazaMenuItem: TMenuItem;
    PompyMenuItem: TMenuItem;
    InformacjeMenuItem: TMenuItem;
    OpcjeMenuItem: TMenuItem;
    HelpMenuItem: TMenuItem;
    OknoMenuItem: TMenuItem;
    KaskadaMenuItem: TMenuItem;
    KafleMenuItem: TMenuItem;
    PrinterSetupMenuItem: TMenuItem;
    PrinterSetupDialog1: TPrinterSetupDialog;
    OprogramieMI: TMenuItem;
    UstProgMI: TMenuItem;
    BtnSetTimer: TTimer;
    ZadaniaMenu: TMenuItem;
    ZadaniaPompyMI: TMenuItem;
    ZadaniaPunktPracyNowyMI: TMenuItem;
    OpenZadMI: TMenuItem;
    OpenZadDialog: TOpenDialog;
    ArmaturaMenuItem: TMenuItem;
    ZHRMenuItem: TMenuItem;
    UNIMenuItem: TMenuItem;
    ZadaniaArmaturaMI: TMenuItem;
    KopMI: TMenuItem;
    CO_LFP_MI: TMenuItem;
    Pomoc: TMenuItem;
    CieczeMI: TMenuItem;
    FiltryMenu: TMenuItem;
    ZamiennMenu: TMenuItem;
    LFPMI: TMenuItem;
    KatalogMenu: TMenuItem;
    Panel1: TPanel;
    ZHRHVMenuItem: TMenuItem;
    ZadaniaPrzepompMI: TMenuItem;
    PrzepompowniaMeprozetMenu: TMenuItem;
    PrzepompowniaMetalchemMenu: TMenuItem;
    PrzepompowniaUniwersalnaMenu: TMenuItem;
    NarzedziaMenu: TMenuItem;
    NakladCharMenu: TMenuItem;
    BuforPompMenuItem: TMenuItem;
    ActionList: TActionList;
    ShowBufPomp: TAction;
    BlokadaBazPompMenu: TMenuItem;
    ImageList: TImageList;
    ShowSkladChar: TAction;
    WFPStoczMenu: TMenuItem;
    PrzepompowniaBialogonMenu: TMenuItem;
    ZaawansowaneMenu: TMenuItem;
    SiecZbiorczaMenu: TMenuItem;
    LeftCoolBar: TCoolBar;
    WielecharakterystykMenu: TMenuItem;
    MotoryMenuItem: TMenuItem;
    ctrlbarGorny: TControlBar;
    tlbarPodstawowy: TToolBar;
    tlbtnPrint: TToolButton;
    actnPrint: TAction;
    actnCloseW: TAction;
    tbtnCloseWin: TToolButton;
    tlbarPro: TToolBar;
    tbtnBuforPomp: TToolButton;
    tbtnNaklChar: TToolButton;
    actnExit: TAction;
    tlbarRight: TToolBar;
    tbtnExit: TToolButton;
    tlbarProducenci: TToolBar;
    FormSaver: TFormSaver;
    StudniaZbiornikHVMenu: TMenuItem;
    StudniaZbiornikCinieniowyMenu: TMenuItem;
    StudniaZbiornikOtwartyMenu: TMenuItem;
    ZbiornikZbiornikCisnieniowyMenu: TMenuItem;
    ZbiornikZbiornikOtwartyMenu: TMenuItem;
    PrzepompowniaPOWENMenu: TMenuItem;
    PrzewodnikMI: TMenuItem;
    PrzepompowniaGruMenu: TMenuItem;
    UkladPompGruMenu: TMenuItem;
    TloczniaGruMenu: TMenuItem;
    Paport: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure ToolBarResize(Sender: TObject);
    procedure KaskadaMenuItemClick(Sender: TObject);
    procedure KafleMenuItemClick(Sender: TObject);
    procedure UstProgMenuItemClick(Sender: TObject);
    procedure PrinterSetupMenuItemClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OprogramieMIClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure BtnSetTimerTimer(Sender: TObject);
    procedure PrintButtonClick(Sender: TObject);
    procedure KopMIClick(Sender: TObject);
    procedure ZadaniaPunktPracyNowyMIClick(Sender: TObject);
    procedure OpenZadMIClick(Sender: TObject);
    procedure UniMenuItemClick(Sender: TObject);
    procedure PrzepompowniaMEPROZETClick(Sender: TObject);
    procedure PrzepompowniaMETALCHEMClick(Sender: TObject);
    procedure PomocClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CieczeMIClick(Sender: TObject);
    procedure FiltryMenuClick(Sender: TObject);
    procedure CloseWinBtnClick(Sender: TObject);
    procedure BuforPompMenuItemClick(Sender: TObject);
    procedure BuforPompBtnDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure BuforPompBtnDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure NakladCharMenuClick(Sender: TObject);
    procedure PrzepompowniaMeprozetMenuClick(Sender: TObject);
    procedure BlokadaBazPompMenuClick(Sender: TObject);
    procedure NaklCharBtnDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure WFPStoczMenuClick(Sender: TObject);
    procedure PrzepompowniaBialogonMenuClick(Sender: TObject);
    procedure SiecZbiorczaMenuClick(Sender: TObject);
    procedure LeftCoolBarDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure WielecharakterystykMenuClick(Sender: TObject);
    procedure MotoryMenuItemClick(Sender: TObject);
    procedure actnExitExecute(Sender: TObject);
    procedure ctrlbarGornyResize(Sender: TObject);
    procedure tlbarProducenciDblClick(Sender: TObject);
    procedure actnCloseWUpdate(Sender: TObject);
    procedure actnPrintUpdate(Sender: TObject);
    procedure PrzepompowniaPOWENMenuClick(Sender: TObject);
    procedure PrzewodnikMIClick(Sender: TObject);
    procedure StudniaZbiornikCinieniowyMenuClick(Sender: TObject);
    procedure StudniaZbiornikOtwartyMenuClick(Sender: TObject);
    procedure ZbiornikZbiornikCisnieniowyMenuClick(Sender: TObject);
    procedure ZbiornikZbiornikOtwartyMenuClick(Sender: TObject);
    procedure PrzepompowniaGruMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PaportClick(Sender: TObject);
  private
    {deklaracje prywatne}
    ChildZoomed       : Boolean;
    FOldClientProc,
    FNewClientProc    : TFarProc;
    FDrawDC           : hDC;
    JestTlo           : Boolean;
    PrzeglZmianaRek   : Boolean;
    function getIsStructForm: Boolean;
    function getIsQueryForm: Boolean;
    function getIsPompForm: Boolean;
    procedure CloseIt( f: TForm );
    procedure UWMSetLang( var msg :TMessage ); message UWM_SET_LANG;
    {$ifndef _DEBUG_}
    procedure ClientWndProc(var Mesg: TMessage);
    {$endif}
    procedure DrawStretched;
    procedure KatMenuClick(Sender: TObject);
    procedure PompPrzeglRecordChanged(DataSet: TDataSet);
    procedure ClosePrzeglDockForm(Sender: TObject;
      var Action: TCloseAction);
    procedure CloseAllWin;
    procedure UruchomZad( clss :TZadanieClass );
    procedure UpdateToolbarProd;
    procedure ActionChange( Sender :TObject );

  protected
    procedure SetLang;    virtual; //?? do wyciecia w ramach jezykow
    procedure CreateWnd; override;
    procedure Notification( AComponent: TComponent;
                            Operation: TOperation); override;
  public
    {deklaracje publiczne}
    StructForm      :TStructForm;
    PompPrzeglForm  :TPompPrzeglForm;
    PompForm        :TFormPompy;
    PrzeglDockForm  :TVDivDockHost;
    // MS 2024.10.17 ArmStructForm   :TArmStructForm;

    tlo:            TBitmap;
    procedure Init;
    procedure Done;

    procedure PompyMIClick(Sender: TObject);
    procedure CreateStructForm;
    procedure CreateQueryForm;
    procedure StructFormClose(Sender: TObject; var Action: TCloseAction);
    procedure QueryFormClose(Sender: TObject; var Action: TCloseAction);
    procedure StructFormActivate(Sender: TObject);
    procedure QueryFormActivate(Sender: TObject);
    procedure GetQueryFormEvent(var value);
    procedure ShowPompForm( Sender: TObject );
    procedure PompFormClose(Sender: TObject; var Action: TCloseAction);
    property  IsStructForm: Boolean read getIsStructForm;
    property  IsQueryForm:  Boolean read getIsQueryForm;
    property  IsPompForm:   Boolean read getIsPompForm;

    procedure ArmMIClick(Sender: TObject);
    procedure CreateArmStructForm;
    procedure ArmStructFormClose(Sender: TObject; var Action: TCloseAction);
    function  AppHelp( Command: Word; Data: Integer;
                       var CallHelp: Boolean): Boolean;

  end;

var
  KatalogGlowneOkno: TKatalogGlowneOkno;

implementation

{$R *.DFM}

uses
  KatInitU, KatFormTools,
  OptForm, prod, Jednost,
//  ZHRZadU,
//  ZHRHVZadU,
  UNIZadU,
  // MS 2024.10.17 KCMepZadU,
  //PSMetZadU,   CoLfpZadU,
  CieczeFrm,
  //PodgladRaportU, RaportPustyU,
  AktProdFrmU, //ZadTMPU,
  WieloCharFormU, KatDataMU;//, PPS_PowZadU; //, r_opor;

const
  sStructureMaximized = 'StructureMaximized';

type
  TDummyAction = class(TAction)
  public
    property OnChange;
  end;

{-----------------------------------------------------------------------------}
{-  Ustawienia okna glownego                                                 -}
{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.FormCreate(Sender: TObject);
var
  zezw    :Boolean;
begin
  Application.OnHint := ShowHint;
  SetLang;      // do wyciecia 051125 MS
  UidQ := lns;  //m3h; // globalne jednostki programu
  Tlo := TBitmap.Create;

  ZamiennMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog', 'Zamien', false );
  KatalogMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog', 'KatalWgGrup', false );
  PompyMenuItem.Visible :=
        ZetonFile.ReadBool( 'Katalog\Bazy', 'Pompy', false );
  ArmaturaMenuItem.Visible :=
        ZetonFile.ReadBool( 'Katalog\Bazy', 'Armatura', false );
  MotoryMenuItem.Visible :=
        ZetonFile.ReadBool( 'Katalog\Bazy', 'Motory', False );
  OpenZadMI.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania', 'Otworz', false );
  zezw := ZetonFile.ReadBool( 'Katalog\Zadania', 'Pompy', false );
  ZadaniaPompyMI.Visible := zezw;
  if zezw then
  begin
    ZadaniaPunktPracyNowyMI.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
                            'PunktPracyNowy' , false );
    ZHRMenuItem.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
                            'ZestawHR' , false );
    ZHRHVMenuItem.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
                            'ZHRHV' , false );
    UNIMenuItem.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
                            'Uniwersalny' , false );
    KOPMi.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
                            'KOP' , false );
    {
    if not PrzepompowniaMETALCHEM.Visible then UnRegisterClass(TPSMetZad);
    }
//    CO_LFP_MI.Visible :=
//        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
//                            'CO_LFP' , false );

//    if not CO_LFP_MI.Visible then UnRegisterClass(TCoLfpZad);

    WFPStoczMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
                            'Dopas' , false );

    StudniaZbiornikHVMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompy',
                            'StudZbiorHV' , false );

  end;

  zezw := ZetonFile.ReadBool( 'Katalog\Zadania', 'Pompownie', false );
  ZadaniaPrzepompMI.Visible := zezw;
  if zezw then
  begin
    PrzepompowniaMeprozetMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompownie',
                            'POMW_MEP' , false );
    //if not PrzepompowniaMEPROZET.Visible then UnRegisterClass(TKCMepZad);

    PrzepompowniaMetalchemMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompownie',
                            'POMW_MET' , false );
    PrzepompowniaUniwersalnaMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompownie',
                            'POMW_UNI', false );
    PrzepompowniaBialogonMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompownie',
                            'POMW_BIA', false );
    PrzepompowniaPOWENMenu.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania\Pompownie',
                            'POMW_POW', false );
  end;

  zezw := ZetonFile.ReadBool( 'Katalog\Zadania', 'Zaawansowane', false );
  ZaawansowaneMenu.Visible := zezw;
  if zezw then
  begin
  // KR: 2002-05-24
  // $MEMO$ "Siec" trzeba zmienic na flagi z klucza lub dodac (jedno i drugie)
  // $MEMO$ chyba zrobione - do zatwierdzenia
    SiecZbiorczaMenu.Visible :=
            WerPro and SiecZezw and
            ZetonFile.ReadBool( 'Katalog\Zadania\Zaawansowane',
                                'SiecZb', false );
  end;
   // Jak ustawic w Zetonie zalaczanie sieci ??
   // MS20051024 na razie wymusilem recznie
    SiecZbiorczaMenu.Visible := true;
    SiecZezw := true;


  ShowBufPomp.Visible := WerPro;
  ShowSkladChar.Visible := WerPro;
  NarzedziaMenu.Visible := WerPro;
  tlbarPro.Visible      := WerPro;

  CieczeMI.Visible :=
        ZetonFile.ReadBool( 'Katalog\Bazy', 'Ciecze', false );
  ZadaniaArmaturaMI.Visible :=
        ZetonFile.ReadBool( 'Katalog\Zadania', 'Armatura', false );
  FiltryMenu.Visible := FiltryZezw;

  OpenZadDialog.InitialDir := SciezkaWkpArchiwum;
  tlbarProducenci.Visible := not WerProdPomp;

  {$ifndef _DEBUG_}
  Panel1.Visible := false;
  BtnSetTimer.Enabled := false;
  {$else}
  Panel1.Visible := true;
  BtnSetTimer.Enabled := true;
  {$endif}

  //TDummyAction(actnCloseW).OnChange := ActionChange;
  if Mouse <> NIL then
    Mouse.DragImmediate := false;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.CreateWnd;
begin
  inherited CreateWnd;

  {$ifndef _DEBUG_}
  { Przeksztalc ClientWndProc w regularna procedure okna }
  FNewClientProc := MakeObjectInstance(ClientWndProc);

  { Pobierz wskaznik do oryginalnej procedury okna }
  FOldClientProc := Pointer(GetWindowLong(ClientHandle, GWL_WNDPROC));

  { Uczyn ClientWndProc biezaca procedura okna }
  SetWindowLong(ClientHandle, GWL_WNDPROC, LongInt(FNewClientProc));
  {$endif}
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.UWMSetLang( var msg :TMessage );
begin
  SetLang;
  msg.Result := 1;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.SetLang;
begin

end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.ShowHint(Sender: TObject);
begin
  StatusLine.Caption := Application.Hint;
end;



{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.Init;
var
  Zoomed : Boolean;
  FN     : string;
  i      : Integer;
  mis    : TMenuItemWithString;
  FormLeft, FormTop, FormWidth, FormHeight : integer;

begin
  // Tu startujeny
  WkpInit;                    // Tworzy listê producentow
  InitIdle;
  SiecZbiorczaMenu.Visible := SiecZezw;
  // MS 2024.10.17 if not SiecZezw then
  // MS 2024.10.17 begin
    // MS 2024.10.17 UnRegisterClass( TSiecZbZad );
    // MS 2024.10.17 FN := SciezkaZasob+'tapeta.bmp';
  // MS 2024.10.17 end
  // MS 2024.10.17 else
    FN := SciezkaZasob+'siec_tapeta.bmp';

  if not FileExists(FN) then
    FN := SciezkaWkp+'tlo.bmp';
  if FileExists(FN) then
  begin
    tlo.LoadFromFile(FN);
    JestTlo := true;
  end;

  Producenci.SubMenuEvent( PompyMenuItem, PompyMIClick, 'PUMPS' );
  Producenci.SubMenuEvent( KatalogMenu, KatMenuClick, 'PUMPS' );
  Producenci.SubMenuEvent( ArmaturaMenuItem, ArmMIClick, 'PIPES' );
  Producenci.SubMenuEvent( MotoryMenuItem, MotoryMenuItemClick, 'MOTORS' );
  if not WerProdPomp then
    Producenci.InitEnabledToolBar( tlbarProducenci, 'PUMPS' );

  if FiltryZezw then
    for i := 0 to FiltryPomp.Liczba-1 do
    begin
      if FiltryPomp.Dostepny[i] then
      begin
        mis := TMenuItemWithString.Create(self);
        mis.Caption := FiltryPomp.Nazwy[i];
        mis.s       := FiltryPomp.Ident[i];
        mis.OnClick := FiltryMenuClick;
        FiltryMenu.Add(mis);
      end;
    end;

  UsrReg.OpenKey('\Software\TBS\Katalog\Forms\KatalogGlowneOkno',true);
  if UsrReg.ValueExists('Zoomed') then
     Zoomed := UsrReg.ReadBool('Zoomed')
   else
     Zoomed := true;
     //Zoomed := WkpIni.ReadBool('KatalogGlowneOkno','Zoomed', true );

  if Zoomed then
  begin
    WindowState := wsMaximized;
  end
  else
  begin
    WindowState := wsNormal;
    if UsrReg.ValueExists('left') then
      FormLeft := UsrReg.ReadInteger('left')
    else
      FormLeft := 50;
    if UsrReg.ValueExists('top') then
      FormTop := UsrReg.ReadInteger('top')
    else
      FormTop := 50;
    if UsrReg.ValueExists('width') then
      FormWidth := UsrReg.ReadInteger('width')
    else
      FormWidth := 500;
    if UsrReg.ValueExists('height') then
      FormHeight := UsrReg.ReadInteger('height')
    else
      FormHeight := 500;

    { MS 2019.08.09 - wiesza sie jak nie ma dostepu do zmiennej
    SetBounds(
      UsrReg.ReadInteger('left'),
      UsrReg.ReadInteger('top'),
      UsrReg.ReadInteger('width'),
      UsrReg.ReadInteger('height')
      //WkpIni.ReadInteger( 'KatalogGlowneOkno', 'left', left),
      //WkpIni.ReadInteger( 'KatalogGlowneOkno', 'top', top),
      //WkpIni.ReadInteger( 'KatalogGlowneOkno', 'width', width),
      //WkpIni.ReadInteger( 'KatalogGlowneOkno', 'height', height)
      );
     }
    SetBounds( FormLeft, FormTop, FormWidth, FormHeight );

  end;
  UsrReg.CloseKey;

  FormSaver.Load;
  with tlbarProducenci do
    if ClientWidth > 4 then
      ClientWidth := ButtonCount * ButtonWidth +3;
end;


{-----------------------------------------------------------------------------}
{$ifndef _DEBUG_}
procedure TKatalogGlowneOkno.ClientWndProc(var Mesg: TMessage);
begin
  with Mesg do
    case Msg of

      // Przechwycenie komunikatu WM_ERASEBKGND i rysowanie
      //  w oknie klienta
      WM_ERASEBKGND:
        begin
          CallWindowProc(FOldClientProc, ClientHandle, Msg,
                        wParam, lParam);
          FDrawDC := TWMEraseBkGnd(Mesg).DC;
            DrawStretched;
          Result := 1;
        end;

      // Przechwycenie komunikatow przewijajacych i upewnienie sie,
      // ze obszar klienta zostal odswiezony; odswiezania dokonuje
      // procedura InvalidateRect
      WM_VSCROLL, WM_HSCROLL:
        begin
          Result := CallWindowProc(FOldClientProc, ClientHandle,
                 Msg, wParam, lParam);
          InvalidateRect(ClientHandle, nil, True);
        end;
      else

      // Wywolaj oryginalna procedure okna
      Result := CallWindowProc(FOldClientProc, ClientHandle,
               Msg, wParam, lParam);
    end;
end;
{$endif}

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.DrawStretched;
{ Ta procedura dokonuje rozciagniecia grafiki w obszarze klienta }
var
  CR: TRect;
begin
  if JestTlo then
  begin
    GetWindowRect(ClientHandle, CR);
    StretchBlt(FDrawDC, 0, 0, CR.Right-CR.Left, CR.Bottom-CR.top,
               tlo.Canvas.Handle, 0, 0,
               tlo.Width, tlo.Height, SRCCOPY);
  end;
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.Done;
begin
  //CloseAllWin;
  if WindowState = wsMaximized then
  begin
    UsrReg.OpenKey('\Software\TBS\Katalog\Forms\KatalogGlowneOkno',true);
    UsrReg.WriteBool('Zoomed',true);
    UsrReg.CloseKey;
  end
    //WkpIni.WriteBool( 'KatalogGlowneOkno', 'Zoomed', true )
  else
  begin
    UsrReg.OpenKey('\Software\TBS\Katalog\Forms\KatalogGlowneOkno',true);
    //WkpIni.WriteBool( 'KatalogGlowneOkno', 'Zoomed', false );
    UsrReg.WriteBool('Zoomed',false);
    if WindowState = wsNormal then
    begin
      UsrReg.WriteInteger('top',top);
      UsrReg.WriteInteger('left',left);
      UsrReg.WriteInteger('height',height);
      UsrReg.WriteInteger('width',width);
      //WkpIni.WriteInteger( 'KatalogGlowneOkno', 'top', top);
      //WkpIni.WriteInteger( 'KatalogGlowneOkno', 'left', left);
      //WkpIni.WriteInteger( 'KatalogGlowneOkno', 'height', height);
      //WkpIni.WriteInteger( 'KatalogGlowneOkno', 'width', width);
    end;
    UsrReg.CloseKey;
  end;
  FormSaver.Save;
  WkpDone;
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.CloseIt( f: TForm );
begin
  if Assigned(f) then
    f.Close;
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.PompyMIClick(Sender: TObject);
var
   pr: TProducent;
begin
   pr := TProdMenuItem(Sender).prod;
   CreateStructForm;
   StructForm.Show;
   StructForm.Root := 'STRUCTURE';
   StructForm.Producent := pr;

end;

procedure TKatalogGlowneOkno.KatMenuClick(Sender: TObject);
var
   pr: TProducent;
begin
   CreateStructForm;
   StructForm.Show;
   pr := TProdMenuItem(Sender).prod;
   StructForm.Root := 'GRUPY';
   StructForm.Producent := pr
end;



{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.CreateStructForm;
begin
   if not IsStructForm then
   begin
      StructForm := TStructForm.Create(self);
      with StructForm do
      begin
        { obsluga zdarzen }
        OnClose := StructFormClose;
        OnActivate := StructFormActivate;
        OnGetQueryForm := GetQueryFormEvent;

        { wymiary }
        if not ((self.ActiveMDIChild <> NIL)
                and (self.ActiveMDIChild.WindowState = wsMaximized)) then
        begin
          if (not UsrReg.ValueExists(sStructureMaximized))
             or (not UsrReg.ReadBool(sStructureMaximized)) then
          begin
            Top := 0;
            Left := 0;
            height := self.ClientHeight-70;
            width := self.ClientWidth-5;
          end
          else
          begin
            WindowState := wsMaximized;
          end;
        end;
        DockListForm;
      end;
   end;
end;


{----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.CreateQueryForm;
{--------------------------------------------
| Utworz okno tabeli do przegladania pomp
|
\--------------------------------------------}
begin
   if not IsQueryForm then
   begin
      PompPrzeglForm := TPompPrzeglFormNoMDI.Create(self);
      with PompPrzeglForm do
      begin
        { obsluga podstawowych zdarzen }
        OnClose := QueryFormClose;
        OnActivate := QueryFormActivate;
        //if PrzeglDokowane then
          //OnRecordChange := PompPrzeglRecordChanged
        //else
          DBGrid1.OnDblClick := ShowPompForm;

        { wymiary okna }
        top     := 22;
        left    :=  3;
        height := self.ClientHeight-90;
        width := self.ClientWidth-9;


      end;
   end;
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.GetQueryFormEvent(var value);
begin
   CreateQueryForm;
   TPompPrzeglForm(value) := PompPrzeglForm;
end;



{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.StructFormClose(Sender: TObject;
                                             var Action: TCloseAction);
begin
  UsrReg.OpenKey( '\Software\TBS\Katalog', true );
  UsrReg.WriteBool( sStructureMaximized, StructForm.WindowState = wsMaximized);
  UsrReg.CloseKey;
  StructForm.WindowState := wsMinimized;
  StructForm := NIL;
  CloseIt(PompPrzeglForm);
  Action := caFree;
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.QueryFormClose(Sender: TObject;
                                             var Action: TCloseAction);
{---------------------------------------
| Obsluga zdarzenia zamkniecia okna tabeli do przegladania pomp
|
----------------------------------------}
begin
   PompPrzeglForm := NIL;
   CloseIt(PompForm);
   Action := caFree;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.StructFormActivate(Sender: TObject);
begin
  CloseIt(PompForm);
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.QueryFormActivate(Sender: TObject);
begin
  //CloseIt(PompForm);
end;



{-----------------------------------------------------------------------------}
function  TKatalogGlowneOkno.getIsStructForm: Boolean;
begin
   getIsStructForm := Assigned(StructForm);
end;


{-----------------------------------------------------------------------------}
function  TKatalogGlowneOkno.getIsQueryForm: Boolean;
begin
   getIsQueryForm := Assigned(PompPrzeglForm);
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.ArmMIClick(Sender: TObject);
var
   pr: TProducent;
begin
   CreateArmStructForm;
   // MS 2024.10.17 ArmStructForm.Show;
   pr := TProdMenuItem(Sender).prod;
   // MS 2024.10.17 ArmStructForm.Producent := pr
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.CreateArmStructForm;
begin
   (*
   // MS 2024.10.17
   if ArmStructForm = NIL then
   begin
      ArmStructForm := TArmStructForm.Create(self);
      with ArmStructForm do
      begin
        { obsluga zdarzen }
        OnClose := ArmStructFormClose;

        { wymiary }
        Top := 0;
        Left := 0;
        height := self.ClientHeight-70;
        width := self.ClientWidth-5;
      end;
   end;
   *)
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.ArmStructFormClose(Sender: TObject;
                                             var Action: TCloseAction);
begin
   // MS 2024.10.17 ArmStructForm := NIL;
   if IsQueryForm then
     PompPrzeglForm.Close;
   Action := caFree;
end;



{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.ExitButtonClick(Sender: TObject);
begin
   Close;
end;


procedure TKatalogGlowneOkno.ToolBarResize(Sender: TObject);
begin
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.KaskadaMenuItemClick(Sender: TObject);
begin
   Cascade;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.KafleMenuItemClick(Sender: TObject);
begin
   Tile;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.UstProgMenuItemClick(Sender: TObject);
begin
   OptionsForm.ShowModal;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.PrinterSetupMenuItemClick(Sender: TObject);
begin
   PrinterSetupDialog1.Execute;
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  BtnSetTimer.Enabled := false;
  //CloseAllWin;
  //if Action = caFree then
  Done;
end;


{-----------------------------------------------------------------------------}
function  TKatalogGlowneOkno.getIsPompForm: Boolean;
begin
  getIsPompForm := Assigned(PompForm);
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.ShowPompForm( Sender: TObject );
var
  Pompa         : TPompa;
  svNrZakl      : Integer;
  svCursor      : TCursor;
begin
  svCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  PrzeglZmianaRek := true;
  svNrZakl := -1;
  if IsPompForm then
  begin
    svNrZakl := PompForm.PakietPompy.ActivePage.PageIndex;
    PompForm.Free;
  end;
  PrzeglZmianaRek := false;
  //Pompa := PompPrzeglForm.DajPompeWBazie;
  Pompa := CreatePump(NIL, PompPrzeglForm.Baza);
  Pompa.DBCreateCopy( PompPrzeglForm.Baza );
  ChildZoomed := (PompPrzeglForm.WindowState = wsMaximized);
  if PrzeglDokowane then
  begin
    ChildZoomed := (ActiveMDIChild.WindowState = wsMaximized);
    if PrzeglDockForm = NIL then
    begin
      PrzeglDockForm := TFPompyIBrwPomp.Create(self);
      PrzeglDockForm.FormStyle := fsMDIChild;
      PrzeglDockForm.WindowState := wsMaximized;
      PrzeglDockForm.OnClose := ClosePrzeglDockForm;
      StructForm.UndockListForm;
      PompPrzeglForm.Hide;
      PompPrzeglForm.Align := alClient;
      PompPrzeglForm.BorderStyle := bsNone;
      PompPrzeglForm.Parent := PrzeglDockForm.DownPanel;
      PompPrzeglForm.Show;
      PompPrzeglForm.OnRecordChange := PompPrzeglRecordChanged;
    end;
    //PompForm.ManualDock( PrzeglDockForm.UpPanel, NIL, alClient );
    //PompForm := TFormPompy.StworzDlaPompy( PrzeglDockForm, Pompa, false);
    //PompForm := Pompa.CreateForm( PrzeglDockForm, False ) as TFormPompy;
    PompForm := FormDlaPompy(Pompa, PrzeglDockForm, False) as TFormPompy;
    FreeNotification(PompForm);
    PompForm.BorderStyle := bsNone;
    PompForm.Align := alClient;
    PompForm.Parent := PrzeglDockForm.UpPanel;
    PompForm.AutoScroll := true;
    PrzeglDockForm.Caption := PompForm.Caption;
    if svNrZakl > -1 then
    try
      PompForm.Show;
      //SendMessage(PompForm.PakietPompy.Handle, TCM_SETCURSEL, svNrZakl, 0);
      PompForm.PakietPompy.ActivePage := PompForm.PakietPompy.Pages[svNrZakl];
      PompForm.PakietPompyChange(PompForm.PakietPompy);
    except
      //PompForm.PakietPompy.
    end;
  end
  else
  begin
    ChildZoomed := (PompPrzeglForm.WindowState = wsMaximized);
    //PompForm := TFormPompy.StworzDlaPompy( self, Pompa);
    //PompForm := Pompa.CreateForm( PrzeglDockForm ) as TFormPompy;
    PompForm := FormDlaPompy( Pompa, PrzeglDockForm, True ) as TFormPompy;
    PompForm.WindowState := wsMaximized;
  end;
  PompForm.OnClose := PompFormClose;
  //PompForm.FormStyle := fsMDIChild;
  PompForm.Show;
  Screen.Cursor := svCursor;
end;


{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.PompFormClose(Sender: TObject;
                                             var Action: TCloseAction);
begin
  if not PrzeglZmianaRek then
  begin
    if PrzeglDockForm <> NIL then
    begin
      StructForm.DockListForm;
      PompPrzeglForm.OnRecordChange := NIL;
      if not ChildZoomed then
        PrzeglDockForm.WindowState := wsNormal;
      PrzeglDockForm.Release;
    end
    else
    begin
      if not ChildZoomed then
        PompForm.WindowState := wsNormal;
    end;
  end
  else
  begin

  end;
  //PompForm := NIL;
  Action := caFree;
end;


procedure TKatalogGlowneOkno.ClosePrzeglDockForm(Sender: TObject;
                                             var Action: TCloseAction);
begin
  //PompPrzeglForm.ManualDock( StructForm.PageControl, nil, alClient );
  if not ChildZoomed then
    PrzeglDockForm.WindowState := wsNormal;
  StructForm.DockListForm;
  PompPrzeglForm.OnRecordChange := NIL;
  Action := caFree;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  with TOknoKoncowe.Create(self) do
  try
    CanClose := Execute;
  finally
    Free;
  end;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.OprogramieMIClick(Sender: TObject);
var
  About   : TAboutBox;
begin
  About := TAboutBox.Create(self);
  About.ShowModal;
  About.Free;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.FormPaint(Sender: TObject);
var
  dc      :HDC;
begin
  {}
  dc := GetDC( ClientHandle );
  if dc <> 0 then
     StretchBlt( dc, 0, 0, ClientWidth, ClientHeight,
                 tlo.Handle,  0, 0, tlo.Width, tlo.Height, SrcCopy);
  ReleaseDC( ClientHandle, dc );
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.BtnSetTimerTimer(Sender: TObject);
begin
  try
    Panel1.Caption := Format( 'P:%d, Z:%d, PR:%d, R:%d, RS:%d',
                              [CLiczbaPomp, ccZadCnt {,
                               ccPodglRCnt, ccRapCnt, ccRapStan}]);
    //Panel1.Caption := IntToStr(ccRapPompy);
  except
    on EAccessViolation do
      try
        TTimer(Sender).Enabled := false
      except
      end;
  end;
end;

{-----------------------------------------------------------------------------}
procedure TKatalogGlowneOkno.PrintButtonClick(Sender: TObject);
var
  ch      :TForm;
begin
  ch := ActiveMDIChild;
  if ch <> NIL then
  begin
    SendMessage( ActiveMDIChild.Handle, TBSM_PRINT, 0, 0);
  end;
end;

procedure TKatalogGlowneOkno.KopMIClick(Sender: TObject);
begin
  //Rura.Show;
end;


procedure TKatalogGlowneOkno.ZadaniaPunktPracyNowyMIClick(Sender: TObject);
var
  F       :TForm;
  Zad     :TStdZadSzukPomp;
begin
  Zad := TStdZadSzukPomp.Create(self);
  Zad.Qw := UTom3h(10);               // Parametry wywolania
  Zad.Hw := 10;
  Zad.Hg := 0;
  Zad.SprawdzajNPSH := FALSE;
  F := Zad.GetMainForm;
  F.Show;
end;



procedure TKatalogGlowneOkno.OpenZadMIClick(Sender: TObject);
var
  FN      :string;
  Z       :TZadanie;
//  FS      :TFileStream;
//  SA      :TStreamProgressAdapter;
  PF      :TProgressForm;
  F       :TForm;
  svC     :TCursor;
begin
  Z := NIL;
  OpenZadDialog.InitialDir := SciezkaWkpArchiwum;
  if OpenZadDialog.Execute then
  try
    svC := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    Application.ProcessMessages;
    FN := OpenZadDialog.FileName;
    PF := TProgressForm.Create(self);
    try
      PF.Opis := Format( '%s.%s%s %s',
                         [ TTlumacz.DajObiekt.ZnajdzTlumaczenie('Prosze czekac'), #13,
                           TTlumacz.DajObiekt.ZnajdzTlumaczenie('Trwa wczytywanie pliku'), FN ] );
      PF.Show;
      Z := TZadanie.LoadFromFile( FN, PF.ProgressProc );
      if Z <> NIL then
      begin
        // !!! B.WAZNE - pomoglo przy zamykaniu aplikacji przy
        //      otwartym zadaniu
        InsertComponent(Z);
        F := Z.GetMainForm;
        if F <> NIL then
          F.Show
        else
          Z.Free;
      end;
    finally
      PF.Free;
      Screen.Cursor := svC;
    end;
  except
    {$ifdef _DEBUG_}
    ShowMessage('Blad otwarcia pliku');
    {$endif}
    Z.Free;
    raise;
  end;
end;

procedure TKatalogGlowneOkno.UNIMenuItemClick(Sender: TObject);
var
  Z       :TUNIZad;
  F       :TForm;
begin
  Z := TUNIZad.Create(self);
  F := Z.GetMainForm;
  F.Show;
end;


procedure TKatalogGlowneOkno.PrzepompowniaMEPROZETClick(Sender: TObject);
//var
  //Z       :TKCMepZad;
  //F       :TForm;
begin
  //Z := TKCMepZad.Create(self);
  //F := Z.GetMainForm;
  //F.Show;
end;

procedure TKatalogGlowneOkno.PrzepompowniaMETALCHEMClick(Sender: TObject);
//var
//  Z       :TPSMetZad;
//  F       :TForm;
begin
{  Z := TPSMetZad.Create(self);
  F := Z.GetMainForm;
  F.Show;}
end;

procedure TKatalogGlowneOkno.PaportClick(Sender: TObject);
begin
  Form1.Show;
end;

procedure TKatalogGlowneOkno.PomocClick(Sender: TObject);
var
  C : Integer;
  plik : string;
begin
  plik := SciezkaWkp+'hlp\' + TTlumacz.DajObiekt.ZnajdzTlumaczenie('Katalog.chm');

  if assigned(ActiveMDIChild) then
  begin
    c := ActiveMDIChild.HelpContext;
    // 2024.10.17 HtmlHlp.HtmlHelp(Handle,PChar( plik ),HH_HELP_CONTEXT ,c );
  end
   else
    // 2024.10.17 HtmlHlp.HtmlHelp(Handle,PChar( plik ),HH_DISPLAY_TOPIC ,0 );
end;


procedure TKatalogGlowneOkno.FormResize(Sender: TObject);
begin
 InvalidateRect(ClientHandle, nil, True);
end;

procedure TKatalogGlowneOkno.CieczeMIClick(Sender: TObject);
begin
  CieczeForm.ShowModal;
end;

procedure TKatalogGlowneOkno.FiltryMenuClick(Sender: TObject);
var
  mi      :TMenuItemWithString;
begin
  try
    mi := Sender as TMenuItemWithString;
    FiltryPomp.UruchomZad( mi.s );
  except on EInvalidCast do
    if (Sender <> FiltryMenu) then
    begin
      ShowMessage( 'Bledne menu' );  // nie powinno wystapic
    end;
  end;
end;

procedure TKatalogGlowneOkno.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = PrzeglDockForm then
      PrzeglDockForm := NIL
    else if AComponent = PompForm then
      PompForm := NIL;
  end;
  inherited Notification(AComponent, Operation);
end;

procedure TKatalogGlowneOkno.PompPrzeglRecordChanged(DataSet: TDataSet);
begin
  ShowPompForm( NIL );
end;

procedure TKatalogGlowneOkno.CloseWinBtnClick(Sender: TObject);
var
  F       :TCustomForm;
begin
  F := Screen.ActiveCustomForm;
  if (F <> NIL) and (F <> self) then
    F.Close;
end;

procedure TKatalogGlowneOkno.BuforPompMenuItemClick(Sender: TObject);
begin
  // 2024.10.17 if BuforPomp.ListView = NIL then
  // 2024.10.17   PmpBuforForm.PmpList := BuforPomp;
  // 2024.10.17 PmpBuforForm.Show;
end;

procedure TKatalogGlowneOkno.BuforPompBtnDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  dob     :TPmpDragObjectBase;
begin
  Accept := (Source is TPmpDragObjectBase);
  if not Accept then
    EXIT;
  dob := Source as TPmpDragObjectBase;
  // 2024.10.17 Accept := dob.StartDragControl <> PmpBuforForm.ListView;
end;

procedure TKatalogGlowneOkno.BuforPompBtnDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  dob     :TPompaDragObject;
begin
  dob := Source as TPompaDragObject;
  // 2024.10.17 BuforPomp.AddCopy( dob.Pompa );
end;

procedure TKatalogGlowneOkno.NakladCharMenuClick(Sender: TObject);
var
  F       :TForm;
begin
  // 2024.10.17 F := TPrzeglCharSklad.Create(self);
  // 2024.10.17 F.Show;
end;

procedure TKatalogGlowneOkno.PrzepompowniaMeprozetMenuClick(
  Sender: TObject);
var
  Z       :TZadanie;
  F       :TForm;
begin
  // 2024.10.17 Z := TPPS_MepZad.Create(self);
  // 2024.10.17 F := Z.GetMainForm;
  // 2024.10.17 F.Show;
end;

procedure TKatalogGlowneOkno.BlokadaBazPompMenuClick(Sender: TObject);
begin
  with AktProdPompForm do
  begin
    LoadValues;
    if Execute then
    begin
      StoreValues;
      if tlbarProducenci.Visible then
        UpdateToolbarProd;
    end;
  end;
end;

procedure TKatalogGlowneOkno.NaklCharBtnDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
{var
  dob     :TPmpDragObjectBase;}
begin
  {Accept := (Source is TPmpDragObjectBase);
  if not Accept then
    EXIT;
  dob := Source as TPmpDragObjectBase;
  }
  //Accept := dob.StartDragControl <> PmpBuforForm.ListView;
end;

procedure TKatalogGlowneOkno.WFPStoczMenuClick(Sender: TObject);
//var
  //Z       :TStoczWFPZad;
  //F       :TForm;
begin
  //Z := TStoczWFPZad.Create(self);

  //// gdy ustawione, zadanie zmienia sie w maszynke
  ////   do wpisywania QMin, QMax
  ////Z.masz := true;
  //F := Z.GetMainForm;
  //F.Show;
  // 2024.10.17 UruchomZad(TStoczWFPZad);
end;

procedure TKatalogGlowneOkno.PrzepompowniaBialogonMenuClick(
  Sender: TObject);
var
  Z       :TZadanie;
  F       :TForm;
begin
  // 2024.10.17 Z := TPPS_BiaZad.Create( self );
  // 2024.10.17 F := Z.GetMainForm;
  // 2024.10.17 F.Show;
end;

procedure TKatalogGlowneOkno.PrzepompowniaPOWENMenuClick(Sender: TObject);
begin
  //UruchomZad( TPPS_PowZad );
end;

procedure TKatalogGlowneOkno.SiecZbiorczaMenuClick(Sender: TObject);
var
  // 2024.10.17 Z       :TSiecZbZad;
  F       :TForm;
begin
 // 2024.10.17  Z := TSiecZbZad.Create(self);
 // 2024.10.17  F := Z.GetMainForm;
 // 2024.10.17  F.Show;
end;

procedure TKatalogGlowneOkno.CloseAllWin;
var
  i       :Integer;
begin
  //while (ActiveMDIChild <> NIL) do
  //begin
  //  ActiveMDIChild.Close;
  //  Application.ProcessMessages;
  //end;
  for i := MDIChildCount-1 downto 0 do
    if MDIChildren[i] <> NIL then
      MDIChildren[i].Close;
end;

procedure TKatalogGlowneOkno.LeftCoolBarDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect       :TRect;
begin
  Accept := Source.Control is TToolBar;
  if Accept then
  begin
    ARect.TopLeft := LeftCoolBar.ClientToScreen(LeftCoolBar.ClientRect.TopLeft);
    ARect.BottomRight := LeftCoolBar.ClientToScreen(LeftCoolBar.ClientRect.BottomRight);
    Source.DockRect := ARect;
  end;
end;

procedure TKatalogGlowneOkno.UruchomZad(clss: TZadanieClass);
var
  Z       :TZadanie;
  F       :TForm;
begin
  Z := clss.Create(self);
  F := Z.GetMainForm;

//  TTlumacz.DajObiekt.Tlumacz(F);

  F.Show;
end;

procedure TKatalogGlowneOkno.WielecharakterystykMenuClick(Sender: TObject);
begin
  WieloCharForm.Show;
end;

procedure TKatalogGlowneOkno.MotoryMenuItemClick(Sender: TObject);
// 2024.10.17 var
  // 2024.10.17 F       :TMotStructForm;
begin
  // 2024.10.17 F := TMotStructForm.Create(self);
  // 2024.10.17 F.Root := 'STRUCTURE';
  // 2024.10.17 F.Producent := TProdMenuItem(Sender).prod;
end;

procedure TKatalogGlowneOkno.actnExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TKatalogGlowneOkno.ctrlbarGornyResize(Sender: TObject);
begin
  if tlbarRight.Parent = ctrlbarGorny then
  begin
    tlbarRight.Left := ctrlbarGorny.ClientWidth - tlbarRight.Width;
  end;
end;

procedure TKatalogGlowneOkno.tlbarProducenciDblClick(Sender: TObject);
begin
  if Sender is TToolBar then with TToolBar(Sender) do
  begin
    if ClientWidth < ButtonWidth then
      ClientWidth := ButtonCount * ButtonWidth +3
    else
      ClientWidth := 3;
  end;
end;

procedure TKatalogGlowneOkno.UpdateToolbarProd;
var
  i       :Integer;
begin
  for i := 0 to tlbarProducenci.ButtonCount-1 do
  begin
    TProdToolButton( tlbarProducenci.Buttons[i] ).UpdateUpDown;
  end;

end;

procedure TKatalogGlowneOkno.ActionChange(Sender: TObject);
  // KR: cos chcialem wysledzic, obecnie nie uzywane
var
  s       :string;
begin
  s := 'ActionChange';
  if Sender is TComponent then
    s := s + ' Name: ' + TComponent(Sender).Name;

  ShowMessage(s);
end;

procedure TKatalogGlowneOkno.actnCloseWUpdate(Sender: TObject);
var
  f       :TCustomForm;
begin
  F := Screen.ActiveCustomForm;
  actnCloseW.Enabled := (F <> NIL) and (F <> self);
end;

procedure TKatalogGlowneOkno.actnPrintUpdate(Sender: TObject);
var
  ch      :TForm;
begin
  ch := ActiveMDIChild;
  if ch <> NIL then
    actnPrint.Enabled := (SendMessage( ch.Handle,
                                       TBSM_CAN_PRINT, 0, 0) <> 0)
  else
    actnPrint.Enabled := false;

end;

procedure TKatalogGlowneOkno.PrzewodnikMIClick(Sender: TObject);
begin
  //ShellExecute( Handle, 'open', PChar( SciezkaWkp+'hlp\Przewodnik.HLP' ),
  //              '', '', SW_SHOWDEFAULT );
  WinHelp( Handle, PChar( SciezkaWkp+'hlp\Przewodnik.HLP' ), HELP_CONTENTS, 0 );
end;

procedure TKatalogGlowneOkno.StudniaZbiornikCinieniowyMenuClick(
  Sender: TObject);
begin
  //UruchomZad(TStud_ZbCisnHVZad);
end;

procedure TKatalogGlowneOkno.StudniaZbiornikOtwartyMenuClick(
  Sender: TObject);
begin
  //UruchomZad(TStud_ZbOtwHVZad);
end;

procedure TKatalogGlowneOkno.ZbiornikZbiornikCisnieniowyMenuClick(
  Sender: TObject);
begin
  //UruchomZad(TZbiorHVCisnZad);
end;

procedure TKatalogGlowneOkno.ZbiornikZbiornikOtwartyMenuClick(
  Sender: TObject);
begin
  //UruchomZad(TZbiorHVOtwZad);
end;

function TKatalogGlowneOkno.AppHelp(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
var
  dd     :Integer;           // dwie znaczace cyfry dziesietne
  AHelpFile :string;
  Hnd       :THandle;
begin
 Result := False;
 {WS}
  // 2024.10.17 HtmlHlp.HtmlHelp(Handle,PChar( SciezkaWkp+'hlp\' + TTlumacz.DajObiekt.ZnajdzTlumaczenie('Katalog.chm')),HH_HELP_CONTEXT , Data );
  Result := True;
 {WS}
 exit;

  Result := False;
  if WerPro and (Command in [HELP_CONTEXT, HELP_CONTEXTPOPUP]) then
  begin
    CallHelp := False;
    dd := Data;
    while dd >= 100 do       // pobierz dwie znaczace cyfry dziesietne
      dd := dd div 10;
    case dd of
      50..59: AHelpFile := 'KatalogLFP.hlp';             // CO
      60:     AHelpFile := 'KatalogLFP.hlp';             // ZHR

      // Patrz uwaga nad "68:"
      66:     AHelpFile := 'KatalogPowen.hlp';           // PPS_Pow
      67:     AHelpFile := 'KatalogMeprozet.hlp';        // KcMep

      // KR: 2002.06.17
      // U W A G A !!! - konflikt Metalchem i Bialogon maja numery 68*
      // wg papierow (teczka "KATALOG") Bialogon powinien miec 66*
      // 66* ma Powen
      68:     AHelpFile := 'KatalogMetalchem.hlp';       // PPS_Met

      //69:                                                // WAVIN
      81:     AHelpFile := 'Siec.hlp';                   // SiecZb

      // Zadania HV nie maja helpow ani kontektow
      else
        CallHelp := True;
    end;
    if not CallHelp then
    begin
      AHelpFile := SciezkaWkp+'hlp\'+AHelpFile;
      with Screen do
      begin
        if Assigned(ActiveForm) and ActiveForm.HandleAllocated
           and (ActiveForm.HelpFile <> '') then
          Hnd := ActiveForm.Handle
        else
          Hnd := Self.Handle;
      end;
      Result := WinHelp( Hnd, PChar(AHelpFile), Command, Data );
    end;
  end;

end;

procedure TKatalogGlowneOkno.PrzepompowniaGruMenuClick(Sender: TObject);
begin
  // 2024.10.17 UruchomZad( TPPS_GruZad ); //Przepompownia sciekow Grundfosa
end;

procedure TKatalogGlowneOkno.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(Self);
end;

end.
