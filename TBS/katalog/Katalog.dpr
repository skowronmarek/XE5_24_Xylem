program Katalog;

uses
  Vcl.Forms,
  Raport_FR_00 in '..\raporty\Raport_FR_00.pas' {Form1},
  AbstractFormPompyU in '..\AbstractFormPompyU.pas' {AbstractFormPompy},
  OPompa in '..\OPompa.pas',
  JezykTxt in '..\JezykTxt.pas',
  Tbs_defs in '..\Tbs_defs.pas',
  BledyU in 'BledyU.pas',
  PompMath in '..\PompMath.pas',
  Prod in '..\Prod.pas',
  TbsU in '..\TbsU.pas',
  CryptU in '..\..\CryptU.pas',
  BInfoU in '..\BInfoU.pas',
  PumpIntf in '..\PumpIntf.pas',
  PompySQL in '..\PompySQL.pas',
  WKPGLOB in '..\WKPGLOB.PAS',
  Jednost in '..\Jednost.pas',
  MemDataSetU in '..\..\MemDataSetU.pas',
  PmpBaseInfoU in '..\PmpBaseInfoU.pas',
  FiltryGlob in '..\filtry\FiltryGlob.pas',
  PmpListU in '..\PmpListU.pas',
  TbsClasses in '..\TbsClasses.pas',
  ZadCompU in '..\ZadCompU.pas',
  TBS_Tool in '..\TBS_Tool.pas',
  fpompy in '..\fpompy.pas' {FormPompy},
  STRFORM in 'STRFORM.PAS' {StructForm},
  przegbrw in '..\przegbrw.pas' {PompPrzeglForm},
  Jezyki in 'Jezyki.pas',
  KatFormTools in '..\KatFormTools.pas',
  PompaReg in '..\PompyReg\PompaReg.pas',
  LinCharU in '..\LinCharU.PAS',
  B4charU in '..\B4charU.pas',
  FunctU in '..\FunctU.pas',
  RegTools in '..\PompyReg\RegTools.pas',
  WCharU in '..\WCharU.pas',
  TbsFormU in '..\TbsFormU.pas' {TbsForm},
  WieloCharFormU in '..\WieloCharFormU.pas' {WieloCharForm},
  ObszarWCharU in '..\ObszarWCharU.pas',
  KatDataMU in '..\KatDataMU.pas' {KatalDataModule: TDataModule},
  EditNew in '..\..\EditNew.pas',
  CursorsDM in '..\CursorsDM.pas' {CursorsData: TDataModule},
  Ciecze in '..\Ciecze.pas',
  CieczPrzelU in '..\CieczPrzelU.pas',
  FreqFormU in '..\FreqFormU.pas' {FreqCalcForm},
  RYSFRM in '..\RYSFRM.PAS' {RysForm},
  MotorsU in '..\MotorsU.pas',
  PompDXF in '..\PompDXF.pas',
  CieczeFrm in '..\CieczeFrm.pas' {CieczeForm},
  KopDraw1 in '..\kop\KopDraw1.pas',
  CustPmpCharViewU in '..\CustPmpCharViewU.pas' {CustomPmpCharViewer},
  WPmpCharViewerU in '..\WPmpCharViewerU.pas' {WPmpCharViewer},
  WieloPompaU in '..\WieloPompaU.pas',
  SavePmpAsFrmU in '..\SavePmpAsFrmU.pas' {SavePmpAsToUserFrm},
  MotorObjU in '..\Motors\MotorObjU.pas',
  DBMotorsU in '..\Motors\DBMotorsU.pas',
  MotBaseInfoU in '..\Motors\MotBaseInfoU.pas',
  FiltZadU in '..\filtry\FiltZadU.pas',
  ZadU in '..\ZadU.pas',
  ZadFrmU in '..\ZadFrmU.pas' {ZadForm},
  ZadPompSzuk in '..\ZadPompSzuk.pas',
  StdZadSzukPomp in '..\StdZadSzukPomp.pas',
  StdZadFrmU in '..\StdZadFrmU.pas' {StdZadForm},
  ZakWyszF in 'ZakWyszF.pas' {RangeSearchForm},
  PmpZnalFrm in '..\PmpZnalFrm.pas' {PompyZnalezFrm},
  MotorFormU in '..\Motors\MotorFormU.pas' {MotorForm},
  PompMotU in '..\PompMotU.pas',
  PompaCharNaturU in '..\PompaCharNaturU.pas',
  PmpListViewFrm in '..\PmpListViewFrm.pas' {PmpListViewForm},
  FiltZadFrmU in '..\filtry\FiltZadFrmU.pas' {FiltrPompForm},
  ZastFrm in '..\ZastFrm.pas' {ZastosForm},
  KonstrFrm in '..\KonstrFrm.pas' {KonstrForm},
  TypyListFrm in 'TypyListFrm.pas' {TypyForm},
  FiltryRes in '..\filtry\FiltryRes.pas',
  ObszCharMgrU in '..\ObszCharMgrU.pas',
  FiltOptFormU in '..\filtry\FiltOptFormU.pas' {FiltOptForm},
  INIFRMUN in 'INIFRMUN.PAS' {InitForm},
  MAIN_KAT in 'MAIN_KAT.PAS' {KatalogGlowneOkno},
  PrzegBrwNoMDI in '..\PrzegBrwNoMDI.pas' {PompPrzeglFormNoMDI},
  ABOUTFRM in 'ABOUTFRM.PAS' {AboutBox},
  OknoKoncoweU in 'OknoKoncoweU.pas' {OknoKoncowe},
  KatInitU in '..\KatInitU.pas',
  KatProd in '..\KatProd.pas',
  OPTFORM in 'OPTFORM.PAS' {OptionsForm},
  AktProdFrmU in '..\AktProdFrmU.pas' {AktProdPompForm},
  FPmpIBrw in '..\FPmpIBrw.pas',
  VDivDockHostU in '..\VDivDockHostU.pas' {VDivDockHost},
  ProgrFrmU in '..\..\ProgrFrmU.pas' {ProgressForm},
  UNIZadU in '..\UNIZadU.pas',
  KopZadU in '..\kop\KopZadU.pas',
  ElemUnit in '..\kop\ElemUnit.pas',
  Opor in '..\kop\Opor.pas',
  DBArm in '..\DBArm.pas',
  PipInfoU in '..\PipInfoU.pas',
  ElAbFrm in '..\kop\ElAbFrm.pas' {ElemAbstPrzeplFrm},
  KopDodElFrm in '..\kop\KopDodElFrm.pas' {DodajElemForm},
  ArmElFrm in '..\ArmElFrm.pas' {ArmElemForm},
  KopFormFrm in '..\kop\KopFormFrm.pas' {DodajFormulaElemForm},
  KopPNFrm in '..\kop\KopPNFrm.pas' {PNForm},
  KopDumElFrm in '..\kop\KopDumElFrm.pas' {DodajDummyElemForm},
  KopOporMiejscEdFormU in '..\kop\KopOporMiejscEdFormU.pas' {OporMiejscEdForm},
  r_opor in '..\kop\r_opor.pas' {Rura},
  WykrFrm in '..\kop\WykrFrm.pas' {DiagForm},
  UNIZadMainForm in '..\UNIZadMainForm.pas' {UNIZadForm},
  KluczFormU in '..\KluczFormU.pas' {KluczForm},
  KluczSZU in '..\KluczSZU.pas',
  KatalogKluczConstU in 'KatalogKluczConstU.pas';

{$R *.res}

begin
  Application.Initialize;                                        // systemowy / Uruchamia WKPGlob.AutoInit / ustawia VerPro
  Application.MainFormOnTaskbar := True;                         // systemowy
  Application.CreateForm(TCursorsData, CursorsData);             // ustawia kursor
  Application.CreateForm(TKatalDataModule, KatalDataModule);     // ustawia saver'y
  Application.CreateForm(TKatalogGlowneOkno, KatalogGlowneOkno); // czyta ustawienia z zetonu / ustawia glowne okno
  Application.CreateForm(TInitForm, InitForm);                   // ustawia wer producencka na podstawie rejstrow ???
  Application.CreateForm(TAboutBox, AboutBox);                   // info o programia
  Application.CreateForm(TKluczForm, KluczForm);
  if KluczForm.Wyswietl('LICENCJA katalogPRO1') then             // Wyswietla okno klucza
    KatalogGlowneOkno.Init;                                      // I-sze czytanie baz / wypelnianie okna INIT

  Application.CreateForm(TFormPompy, FormPompy);
  Application.CreateForm(TFreqCalcForm, FreqCalcForm);
  Application.CreateForm(TRysForm, RysForm);

  Application.CreateForm(TForm1, Form1);

  Application.Run;
end.
