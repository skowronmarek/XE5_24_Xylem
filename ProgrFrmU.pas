unit ProgrFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, jezyki;

type
  TProgressForm = class(TForm)
    OpisLab: TLabel;
    ProgressBar: TProgressBar;
    procedure FormShow(Sender: TObject);
  private
    function GetOpis: string;
    function GetProgress: Integer;
    function GetTotal: Integer;
    procedure SetOpis(const Value: string);
    procedure SetProgress(const Value: Integer);
    procedure SetTotal(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
    procedure ProgressProc( Sender :TObject; ACurrent, ATotal :Integer );
    property Opis :string read GetOpis write SetOpis;
    property Progress :Integer read GetProgress write SetProgress;
    property Total    :Integer read GetTotal write SetTotal;
  end;

var
  ProgressForm: TProgressForm;

implementation

{$R *.DFM}

{ TProgressForm }

function TProgressForm.GetOpis: string;
begin
  result := OpisLab.Caption;
end;

function TProgressForm.GetProgress: Integer;
begin
  result := ProgressBar.Position;
end;

function TProgressForm.GetTotal: Integer;
begin
  result := ProgressBar.Max;
end;

procedure TProgressForm.ProgressProc(Sender: TObject; ACurrent,
  ATotal: Integer);
begin
  Progress := ACurrent;
  Total := ATotal;
end;

procedure TProgressForm.SetOpis(const Value: string);
begin
  OpisLab.Caption := Value;
end;

procedure TProgressForm.SetProgress(const Value: Integer);
begin
  ProgressBar.Position := Value;
end;

procedure TProgressForm.SetTotal(const Value: Integer);
begin
  ProgressBar.Max := Value;
end;

procedure TProgressForm.FormShow(Sender: TObject);
begin
 TTlumacz.DajObiekt.Tlumacz(self); 
end;

end.
