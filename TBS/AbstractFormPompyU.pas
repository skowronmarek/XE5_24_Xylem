
unit AbstractFormPompyU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JezykTxt,
  OPompa;

type
  TAbstractFormPompy = class(TForm)
  protected
    FPompa        :TPompa;
    FNazwaPompy   :string[40];
    FMDIChild     : Boolean;
    function  GetPumpName :string;
    procedure SetPumpName( v :string );
  public
    constructor StworzDlaPompy( AOwner: TComponent; APompa: TPompa;
                                AMDIChild :Boolean = true );   virtual;
    property Pompa: TPompa       read FPompa;
    property NazwaPompy :string  read GetPumpName write SetPumpName;
  end;

  TAbstractFormPompyClass = class of TAbstractFormPompy;

implementation

{$R *.dfm}

{ TAbstractFormPompy }

constructor TAbstractFormPompy.StworzDlaPompy(AOwner: TComponent;
  APompa: TPompa; AMDIChild: Boolean);
begin
  OldCreateOrder := false;
  FMDIChild := AMDIChild;
  inherited Create( AOwner );
end;

function TAbstractFormPompy.GetPumpName: string;
begin
  result := FNazwaPompy;
end;

procedure TAbstractFormPompy.SetPumpName(v: string);
begin
  FNazwaPompy := v;
  Caption := DajText(Pompa_txt) + ': ' + NazwaPompy;
end;



end.
