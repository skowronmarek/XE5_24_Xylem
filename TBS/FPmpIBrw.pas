unit FPmpIBrw;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VDivDockHostU, ExtCtrls, TBS_Defs;

type
  TFPompyIBrwPomp = class(TVDivDockHost)
  private
    { Private declarations }
    procedure MsgTBSM_Print( var msg :TMessage );    message TBSM_PRINT;
    procedure MsgTBSM_CanPrint( var msg :TMessage ); message TBSM_CAN_PRINT;
  public
    { Public declarations }
  end;

var
  FPompyIBrwPomp: TFPompyIBrwPomp;

implementation

{$R *.DFM}

{ TFPompyIBrwPomp }

procedure TFPompyIBrwPomp.MsgTBSM_CanPrint(var msg: TMessage);
begin
  if (UpPanel.ControlCount > 0) and (UpPanel.Controls[0] is TForm) then
    msg.result := SendMessage( (UpPanel.Controls[0] as TWinControl).Handle,
                               TBSM_CAN_PRINT, msg.WParam, msg.LParam )
  else
    msg.result := 0;
end;

procedure TFPompyIBrwPomp.MsgTBSM_Print(var msg: TMessage);
begin
  if (UpPanel.ControlCount > 0) and (UpPanel.Controls[0] is TForm) then
    msg.result := SendMessage( (UpPanel.Controls[0] as TWinControl).Handle,
                               TBSM_PRINT, msg.WParam, msg.LParam );
end;

end.
