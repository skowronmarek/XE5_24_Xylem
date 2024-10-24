unit IniFrmUn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls,
  Prod, JezykTxt, TbsU,
  KR_Sys, WkpGlob, Buttons, ImgList, jpeg,
  jezyki;

type
  TInitForm = class(TForm)
    ProdListBox: TListBox;
    IlPompLabel: TLabel;
    IlPompNrLabel: TLabel;
    Label1: TLabel;
    WersjaLab: TLabel;
    WerValLab: TLabel;
    WaitCheck: TCheckBox;
    Wlasciciel: TLabel;
    WlLicLab: TLabel;
    LogoImage: TImage;
    Label2: TLabel;
    OKBtn: TSpeedButton;
    SpeedButPL: TSpeedButton;
    SpeedButENG: TSpeedButton;
    procedure OKBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpButton_OKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButPLClick(Sender: TObject);
    procedure SpeedButENGClick(Sender: TObject);
  private
    { Private declarations }
    ilPomp: LongInt;
    procedure UWMSetLang( var msg :TMessage ); message UWM_SET_LANG;
  protected
    procedure SetLang;    virtual;

  public
    { Public declarations }
    function  DodajProducenta( prod: TProducent ): integer;
    procedure Aktualizuj;
  end;

var
  InitForm: TInitForm;

implementation

{$R *.DFM}

const
  sInitWaitOK = 'InitWaitOK';

function  TInitForm.DodajProducenta( prod: TProducent ): integer;
var
  FN      :string;
begin
  if prod.Enable then
  begin
    if prod.IloscPomp > 0 then
    begin
      if WerProdPomp and (prod.Ident = GlobProdId) then
      begin
        ProdListBox.Items.Insert( 0, PadR(prod.nazwa,15,' ')
                           + PadL(IntToStr(prod.IloscPomp),5,' ')
                           + ' pomp' )
      end
      else
        ProdListBox.Items.Add( PadR(prod.nazwa,15,' ')
                             + PadL(IntToStr(prod.IloscPomp),5,' ')
                             + ' pomp' );
    end
    else
      ProdListBox.Items.Add( prod.nazwa );
    ilPomp := ilPomp + prod.IloscPomp;
    IlPompNrLabel.Caption := IntToStr(ilPomp);
  end
  else if not prod.Poprawne then
    ProdListBox.Items.Add( PadR(prod.nazwa,15,' ')
                           + 'zle dane' )
  else if not prod.Dozwolone then
    ProdListBox.Items.Add( PadR(prod.nazwa,15,' ')
                           + 'brak dostepu' )
  else
    ProdListBox.Items.Add( PadR(prod.nazwa,15,' ')
                         + PadL(IntToStr(prod.IloscPomp),5,' ')
                         + ' pomp' );
  Application.ProcessMessages;
  DodajProducenta := ProdListBox.Items.Count;
end;

procedure TInitForm.OKBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TInitForm.UWMSetLang( var msg :TMessage );
begin
  SetLang;
  msg.Result := 1;
end;

procedure TInitForm.SetLang;
begin

end;

procedure TInitForm.FormActivate(Sender: TObject);
begin
  IlPompNrLabel.Font.Color := clHighlightText;
  ProdListBox.Font.Pitch   := fpFixed;
end;

procedure TInitForm.FormCreate(Sender: TObject);
var
  FN,j    :string;
  i       :Integer;
begin
  FN := '';
  UsrReg.OpenKey('\Software\TBS\Katalog\Settings\',true);
  if UsrReg.ValueExists('Jezyk') then
     Jezyk := UsrReg.ReadString('Jezyk')
   else
     Jezyk := 'POLSKI';
  UsrReg.CloseKey;

  if Jezyk = 'POLSKI' then
     j:= ''
   else
     j := Jezyk + ' ';

  if WerProdPomp then
  begin
    FN := SciezkaWkp + j + GlobProdId+'.jpg';
    if not FileExists(FN) then
      FN := SciezkaWkp + j + GlobProdId+'.bmp';
    if not FileExists(FN) then
       FN := SciezkaWkp + GlobProdId+'.jpg';
       if not FileExists(FN) then
          FN := SciezkaWkp + j + GlobProdId+'.bmp';
  end;

  if FileExists(FN) then
  begin
    LogoImage.Picture.LoadFromFile(FN);
  end;
  WerValLab.Caption := WersjaStr;
  Wlasciciel.Visible := WerPro;
  WlLicLab.Visible  := WerPro;
  if WerPro then
    WlLicLab.Caption := WlLic;

//  SetLang;

  //ustawianie jezuka wg. Kapla
  // Przeniesione wyzej WS
  //Jezyk := WkpIni.ReadString('Opcje','Jezyk','POLSKI');

  UsrReg.OpenKey('\Software\TBS\Katalog\',true);
  if UsrReg.ValueExists( sInitWaitOK ) then
     WaitCheck.Checked := UsrReg.ReadBool( sInitWaitOK );
  Aktualizuj;
end;

procedure TInitForm.FormDestroy(Sender: TObject);
begin
  UsrReg.OpenKey('\Software\TBS\Katalog',true);
  UsrReg.WriteBool( sInitWaitOK, WaitCheck.Checked );
  UsrReg.CloseKey;
end;

procedure TInitForm.SpButton_OKClick(Sender: TObject);
begin
(*  UsrReg.OpenKey('\Software\TBS\Katalog\Settings',true);
  //WkpIni.WriteString('Opcje','Jezyk',Jezyk);
  UsrReg.WriteString('Jezyk',Jezyk);
  UsrReg.CloseKey;
*)
  Close;
end;

procedure TInitForm.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(self);
end;

procedure TInitForm.Aktualizuj;
begin
  if Jezyk = 'ANGIELSKI' then
    SpeedButENG.Down := true
  else
    SpeedButPL.Down := true;
end;

procedure TInitForm.SpeedButPLClick(Sender: TObject);
begin
  if Jezyk <> 'POLSKI' then
    Jezyk := 'POLSKI';
end;

procedure TInitForm.SpeedButENGClick(Sender: TObject);
begin
  if Jezyk <> 'ANGIELSKI' then
    Jezyk := 'ANGIELSKI';
end;

end.
