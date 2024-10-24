unit VDivDockHostU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TVDivDockHost = class(TForm)
    DownPanel: TPanel;
    Splitter: TSplitter;
    UpPanel: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VDivDockHost: TVDivDockHost;

implementation

{$R *.DFM}

procedure TVDivDockHost.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
