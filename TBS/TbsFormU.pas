unit TbsFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Tbs_Defs;

type
  TTbsForm = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDefaultCloseAction: TCloseAction;
    procedure SetDefaultCloseAction(const Value: TCloseAction);
    procedure TBSM_Print( var msg :TMessage );    message TBSM_PRINT;
    procedure TBSM_CanPrint( var msg :TMessage ); message TBSM_CAN_PRINT;
  protected
    procedure VisibleChanging; override;
    procedure TBSPrint;                             virtual;
    function  TBSCanPrint :Boolean;                 virtual;
  public
    constructor Create( Owner :TComponent );        override;
    procedure Aktualizuj;                           virtual;
  published
    property DefaultCloseAction :TCloseAction read FDefaultCloseAction write SetDefaultCloseAction;
  end;

var
  TbsForm: TTbsForm;

implementation

{$R *.DFM}

{ TTbsForm }

procedure TTbsForm.Aktualizuj;
begin

end;

procedure TTbsForm.SetDefaultCloseAction(const Value: TCloseAction);
begin
  FDefaultCloseAction := Value;
end;

procedure TTbsForm.VisibleChanging;
begin
  if not ((FormStyle = fsMDIChild) and Visible) then
    inherited VisibleChanging;
end;

procedure TTbsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := DefaultCloseAction;
end;

constructor TTbsForm.Create(Owner: TComponent);
begin
  inherited;
  DefaultCloseAction := caFree;
end;

function TTbsForm.TBSCanPrint: Boolean;
begin
  result := false;
end;

procedure TTbsForm.TBSM_CanPrint(var msg: TMessage);
begin
  if TBSCanPrint then
    msg.Result := 1
  else
    msg.Result := 0;
end;

procedure TTbsForm.TBSM_Print(var msg: TMessage);
begin
  TBSPrint;
end;

procedure TTbsForm.TBSPrint;
begin
  // DoNothing
end;

end.
