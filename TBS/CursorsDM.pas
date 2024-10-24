unit CursorsDM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CursorObjU;

type
  TCursorsData = class(TDataModule)
    HandCur: TCursorObj;
    ZoomCur: TCursorObj;
    ZoomOutCur: TCursorObj;
    NowyWezCur: TCursorObj;
    ArrowUpCur: TCursorObj;
    ArrowDownCur: TCursorObj;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CursorsData: TCursorsData;

implementation

{$R *.DFM}

end.
