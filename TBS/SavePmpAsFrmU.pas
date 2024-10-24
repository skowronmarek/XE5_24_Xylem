unit SavePmpAsFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TSavePmpAsToUserFrm = class(TForm)
    PompNameEdit: TEdit;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    CancelBtn: TBitBtn;
  private
    function GetNazwaPompywrite: string;
    procedure SetNazwaPompy(const Value: string);
  public
    function  Execute :Boolean;
    property  NazwaPompy :string read GetNazwaPompywrite write SetNazwaPompy;
  end;

var
  SavePmpAsToUserFrm: TSavePmpAsToUserFrm;

implementation

{$R *.DFM}

{ TSavePmpAsToUserFrm }

function TSavePmpAsToUserFrm.Execute: Boolean;
begin
  ShowModal;
  result := ModalResult = mrOk;
end;

function TSavePmpAsToUserFrm.GetNazwaPompywrite: string;
begin
  result := PompNameEdit.Text;
end;

procedure TSavePmpAsToUserFrm.SetNazwaPompy(const Value: string);
begin
  PompNameEdit.Text := Value;
end;

end.
