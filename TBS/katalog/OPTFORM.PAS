unit Optform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, TabNotBk,
  JezykTxt, WkpGlob, IniFrmUn,
  KR_Sys, ComCtrls,
  Jezyki, ExtCtrls, Buttons, shlobj;

type
  TOptionsForm = class(TForm)
    OKButton: TButton;
    CancelButton: TButton;
    PageControl: TPageControl;
    tabGlowne: TTabSheet;
    chkInitWaitOK: TCheckBox;
    chkSfpOgr: TCheckBox;
    RadioJedQ: TRadioGroup;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    eImieNazwisko: TEdit;
    TabDirectory: TTabSheet;
    EPathArchiwum: TEdit;
    Label2: TLabel;
    sbPathName: TSpeedButton;
    EditFirma1: TEdit;
    EditFirma2: TEdit;
    EditFirma3: TEdit;
    LabFirma: TLabel;
    procedure OptionsFormActivate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure RadioJedQClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbPathNameClick(Sender: TObject);
  private
    { Private declarations }
  protected
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.DFM}

uses
   Jednost, Main_Kat;

var lg_StartFolder: String;

function BrowseForFolderCallBack(Wnd: HWND; uMsg: UINT;
        lParam, lpData: LPARAM): Integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
    SendMessage(Wnd,BFFM_SETSELECTION,1,Integer(@lg_StartFolder[1]));
  result := 0;
end;

function BrowseForFolder(const browseTitle: String;
        const initialFolder: String =''): String;
var
  browse_info: TBrowseInfo;
  folder: array[0..MAX_PATH] of char;
  find_context: PItemIDList;
begin
  FillChar(browse_info,SizeOf(browse_info),#0);
  lg_StartFolder := initialFolder;
  browse_info.pszDisplayName := @folder[0];
  browse_info.lpszTitle := PChar(browseTitle);
  browse_info.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
  browse_info.hwndOwner := Application.Handle;
  if initialFolder <> '' then
    browse_info.lpfn := BrowseForFolderCallBack;
  find_context := SHBrowseForFolder(browse_info);
  if Assigned(find_context) then
  begin
    if SHGetPathFromIDList(find_context,folder) then
      result := folder
    else
      result := '';
    GlobalFreePtr(find_context);
  end
  else
    result := '';
end;


procedure TOptionsForm.OptionsFormActivate(Sender: TObject);

var
  cr: TCursor;
begin
  cr := cursor;
  cursor := crHourglass;

  chkInitWaitOK.Checked := InitForm.WaitCheck.Checked;
  chkSfpOgr.Checked     := SfpOgr;

  EditFirma1.Text    := WkpGlob.Firm1;
  EditFirma2.Text    := WkpGlob.Firm2;
  EditFirma3.Text    := WkpGlob.Firm3;
  //eImieNazwisko.Text := WkpGlob.WkpIni.ReadString('Opcje','ImieNazwisko','');
  eImieNazwisko.Text := WkpGlob.Projektant;
  
  cursor := cr;

end;


procedure TOptionsForm.OKButtonClick(Sender: TObject);
begin
   InitForm.WaitCheck.Checked := chkInitWaitOK.Checked;
   SfpOgr := chkSfpOgr.Checked;
   WkpGlob.Firm1 := EditFirma1.Text;
   UsrReg.OpenKey( '\Software\TBS\Katalog', true );
   UsrReg.WriteString('KatalogFirma1',EditFirma1.Text);
   WkpGlob.Firm2 := EditFirma2.Text;
   UsrReg.WriteString('KatalogFirma2',EditFirma2.Text);
   WkpGlob.Firm3 := EditFirma3.Text;
   UsrReg.WriteString('KatalogFirma3',EditFirma3.Text);
   WkpGlob.Projektant := eImieNazwisko.Text;
   UsrReg.WriteString('KatalogProjektant',eImieNazwisko.Text);
   UsrReg.CloseKey;
   Close;
end;

procedure TOptionsForm.CancelButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TOptionsForm.RadioJedQClick(Sender: TObject);
begin
  case RadioJedQ.ItemIndex of
    0: UidQ := m3h;
    1: UidQ := lns;
    2: UidQ := lnm;
    3: UidQ := m3m;
    4: UidQ := m3s;
  end;
  // dorobic komunikacje z otwartymi oknami
end;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
  case UidQ of
    m3h:RadioJedQ.ItemIndex := 0 ;
    lns:RadioJedQ.ItemIndex := 1 ;
    lnm:RadioJedQ.ItemIndex := 2 ;
    m3m:RadioJedQ.ItemIndex := 3 ;
    m3s:RadioJedQ.ItemIndex := 4 ;
  end;
  EPathArchiwum.Text := SciezkaWkpArchiwum;
  TTlumacz.DajObiekt.Tlumacz(self);
  Width := 540;
  Height:= 250;
end;

procedure TOptionsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  // przeniesione do rejestru MS 2014.03.05
  // WkpGlob.WkpIni.WriteString('Opcje','ImieNazwisko', eImieNazwisko.Text);
end;

procedure TOptionsForm.sbPathNameClick(Sender: TObject);
var s : String;
begin
 s := BrowseForFolder('', EPathArchiwum.Text);
 if s <> EPathArchiwum.Text then
 begin
   EPathArchiwum.Text := s;
   SciezkaWkpArchiwum := s;
   ZapamietajKatalogZapisu(EPathArchiwum.Text)
   //UsrReg.WriteString('KatalogArchiwum',EPathArchiwum.Text)
 end;
end;

end.
