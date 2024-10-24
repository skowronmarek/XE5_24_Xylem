unit PmpListViewFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Buttons, ExtCtrls, KatFormTools, TbsFormU, PmpListU, OPompa, FPompy,
  Menus, ActnList;

type
  TPmpListViewForm = class(TTbsForm)
    ListView: TListView;
    ToolBar: TPanel;
    ViewIconBtn: TSpeedButton;
    ViewSmallBtn: TSpeedButton;
    ViewListBtn: TSpeedButton;
    ViewRepBtn: TSpeedButton;
    ListViewPopup: TPopupMenu;
    DeleteMI: TMenuItem;
    WyswietlMI: TMenuItem;
    ActionList: TActionList;
    DeleteAction: TAction;
    DisplayAction: TAction;
    OpenAction: TAction;
    SaveAction: TAction;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ViewIconBtnClick(Sender: TObject);
    procedure ViewSmallBtnClick(Sender: TObject);
    procedure ViewListBtnClick(Sender: TObject);
    procedure ViewRepBtnClick(Sender: TObject);
    procedure ListViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListViewStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure ListViewDblClick(Sender: TObject);
    procedure ListViewKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewPopupPopup(Sender: TObject);
    procedure DisplayActionExecute(Sender: TObject);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeleteActionExecute(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
  private
    FPmpList: TPumpList;
    procedure SetPmpList(const Value: TPumpList);
    { Private declarations }
  public
    { Public declarations }
    procedure OpenPmp;                   virtual;
    procedure DeletePmp;                 virtual;
    property PmpList  :TPumpList read FPmpList write SetPmpList;
  end;

var
  PmpListViewForm: TPmpListViewForm;

implementation

uses KatDataMU;


{$R *.DFM}

procedure TPmpListViewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPmpListViewForm.ViewIconBtnClick(Sender: TObject);
begin
  ListView.ViewStyle := vsIcon;
end;

procedure TPmpListViewForm.ViewSmallBtnClick(Sender: TObject);
begin
  ListView.ViewStyle := vsSmallIcon;
end;

procedure TPmpListViewForm.ViewListBtnClick(Sender: TObject);
begin
  ListView.ViewStyle := vsList;
end;

procedure TPmpListViewForm.ViewRepBtnClick(Sender: TObject);
begin
  ListView.ViewStyle := vsReport;
end;

procedure TPmpListViewForm.ListViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);

begin
  Accept := Source is TPmpDragObjectBase;

end;

procedure TPmpListViewForm.ListViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  dob     :TPmpDragObjectBase;
begin
  dob := Source as TPmpDragObjectBase;
  if dob.StartDragControl = ListView then
    with ListView.Selected do
    begin
      Left := X - 16;
      Top  := Y - 16;
    end;
  //dob.Free;
end;

procedure TPmpListViewForm.ListViewStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
  P        :TPompa;
  bm       :TBitmap;
begin
  DragObject := TPompaDragObject.Create(ListView.Selected.Data, ListView );
end;

procedure TPmpListViewForm.SetPmpList(const Value: TPumpList);
begin
  FPmpList := Value;
  Value.ListView := ListView;
end;

procedure TPmpListViewForm.OpenPmp;
var
  P       :TPompa;
  F       :TForm;
begin
  if ListView.Selected = NIL then
    EXIT;
  P := ListView.Selected.Data;
  //F := TFormPompy.StworzDlaPompy( P, P );
  //F := P.CreateForm( P );
  F := FormDlaPompy( P, P, True );
  F.Show;
end;

procedure TPmpListViewForm.ListViewDblClick(Sender: TObject);
begin
  OpenPmp;
end;

procedure TPmpListViewForm.ListViewKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    OpenPmp;
    Key := #0;
  end;
end;

procedure TPmpListViewForm.ListViewPopupPopup(Sender: TObject);
var
  sel     :Boolean;
begin
  sel := ListView.Selected <> NIL;
  DeleteAction.Enabled := sel;
  DisplayAction.Enabled := sel;
end;

procedure TPmpListViewForm.DisplayActionExecute(Sender: TObject);
begin
  OpenPmp;
end;

procedure TPmpListViewForm.DeletePmp;
var
  pos     :Integer;
begin
  if ListView.Selected = NIL then
    EXIT;
  pos := ListView.Selected.Index;
  FPmpList.RemovePmp(pos);
end;


procedure TPmpListViewForm.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DELETE: DeletePmp;
  end;
end;

procedure TPmpListViewForm.DeleteActionExecute(Sender: TObject);
begin
  DeletePmp;
end;

procedure TPmpListViewForm.OpenActionExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
    PmpList.LoadFromFile(OpenDialog.FileName);
end;

procedure TPmpListViewForm.SaveActionExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
    PmpList.SaveToFile(SaveDialog.FileName);
end;

end.
