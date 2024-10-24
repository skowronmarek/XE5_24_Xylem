unit OknoKoncoweU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, TbsU,
  jezyki;

type
  TOknoKoncowe = class(TForm)
    btnYes: TBitBtn;
    btnNo: TBitBtn;
    Memo: TMemo;
    labPytanie: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    function Execute :Boolean;
  end;

var
  OknoKoncowe: TOknoKoncowe;

implementation

{$R *.DFM}

function TOknoKoncowe.Execute: Boolean;
begin
  Result := ShowModal = mrYes;
end;

procedure TOknoKoncowe.FormCreate(Sender: TObject);
var
  SL      :TStringList;
  i       :Integer;
  s       :string;
begin
  Memo.Clear;// Text := '';
  SL := TStringList.Create;
  try
    ZetonFile.ReadSection( 'DOPISKI', SL );
    for i := 0 to SL.Count-1 do
    begin
      s := ZetonFile.ReadString( 'DOPISKI', SL[i], '' );
      Memo.Lines.Add( s );
    end;
  finally
    SL.Free;
  end;
end;

procedure TOknoKoncowe.FormShow(Sender: TObject);
begin
  TTlumacz.DajObiekt.Tlumacz(self);
end;

end.
