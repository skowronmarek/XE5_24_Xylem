unit PrzegBrwNoMDI;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  przegbrw, Db, Grids, DBGrids, DbgEx, ExtCtrls,
  WkpGlob, TbsU, jezyki;

type
  TPompPrzeglFormNoMDI = class(TPompPrzeglForm)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PompPrzeglFormNoMDI: TPompPrzeglFormNoMDI;

implementation

uses PompySQL, IniFiles;

{$R *.DFM}


procedure TPompPrzeglFormNoMDI.FormCreate(Sender: TObject);
begin
  inherited;
  DBGrid1.Columns[1].Title.Caption := 'Qn '+CapQ;
  //index
  DBGrid1.Columns[6].Visible := ZetonFile.ReadBool( 'Katalog\Pompy', 'Index', false );
end;

procedure TPompPrzeglFormNoMDI.FormShow(Sender: TObject);
var i : integer;
begin
 TTlumacz.DajObiekt.Tlumacz(self);
 for i := 1 to DBGrid1.Columns.Count - 1  do
   DBGrid1.Columns[i].Title.Caption := TTlumacz.dajObiekt.ZnajdzTlumaczenie(DBGrid1.Columns[i].Title.Caption);
 DBGrid1.Tag := 1;
end;

end.
