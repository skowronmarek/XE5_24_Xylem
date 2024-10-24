 unit KatDataMU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, PropertyAccesserU, FormSaverU;

type
  TKatalDataModule = class(TDataModule)
    ActnImageList: TImageList;
    FormSaver: TFormSaver;
    Saver: TFormSaver;
    SettingsSvr: TFormSaver;
  private
    function GetSfpOgr: Boolean;
    procedure SetSfpOgr(const Value: Boolean);
    { Private declarations }
  public
  published
    property SfpOgr :Boolean read GetSfpOgr write SetSfpOgr;
  end;

var
  KatalDataModule: TKatalDataModule;

implementation

{$R *.DFM}

uses
  WkpGlob;

{ TKatalDataModule }

function TKatalDataModule.GetSfpOgr: Boolean;
begin
  Result := WkpGlob.SfpOgr;
end;

procedure TKatalDataModule.SetSfpOgr(const Value: Boolean);
begin
  WkpGlob.SfpOgr := Value;
end;

end.
