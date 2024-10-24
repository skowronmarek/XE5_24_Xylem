unit Aboutfrm;

interface

uses WinTypes, WinProcs, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Messages, JezykTxt, WkpGlob, ShellRunLabelU,
  jezyki;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    OKButton: TBitBtn;
    ProgramIcon: TImage;
    ProductName: TLabel;
    VersionLab: TLabel;
    ProducentLab: TLabel;
    Autorzy: TLabel;
    Autor1: TLabel;
    Autor2: TLabel;
    VerNumLab: TLabel;
    ProdName: TLabel;
    Wlasciciel: TLabel;
    WlLicLab: TLabel;
    ShellRunLabSKOWRONSKI: TShellRunLabel;
    Autor3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure UWMSetLang( var msg :TMessage ); message UWM_SET_LANG;
  protected
    procedure SetLang; virtual;
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  SetLang;
  VerNumLab.Caption := WersjaStr;
  Wlasciciel.Visible := WerPro;
  WlLicLab.Visible  := WerPro;
  if WerPro then
    WlLicLab.Caption := WlLic;
end;

procedure TAboutBox.UWMSetLang( var msg: TMessage );
begin
  SetLang;
  msg.Result := 1;
end;

procedure TAboutBox.SetLang;
begin
//  Caption := DajText(About_txt);
//  ProductName.Caption := DajText(KatPompFullName_txt);
//  VersionLab.Caption  := DajText(Wersja_txt);
//  ProducentLab.Caption:= DajText(Producent_txt);
//  Autorzy.Caption     := DajText(Autorzy_txt);
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(Self);
end;

end.

