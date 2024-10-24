unit ElAbFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ElemUnit, Ciecze, jezyki;

type
  TElemAbstPrzeplFrm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FElement    :TElemAbstract;
    FCiecz      :TCieczPlyw;
    FDestroyElOnFree :Boolean;
    FFreeOnClose: Boolean;
    procedure SetFreeOnClose(const Value: Boolean);
  protected
    procedure VisibleChanging; override;
    function  GetCanEditQ  :Boolean;         virtual;   abstract;
    function  GetCanEdCiecz:Boolean;         virtual;   abstract;

    procedure SetElement(e :TElemAbstract);  virtual;
    procedure SetCiecz(c :TCieczPlyw);       virtual;
  public
    { Public declarations }
    destructor Destroy;                      override;
    property Element     :TElemAbstract  read FElement write SetElement;
    property Ciecz       :TCieczPlyw     read FCiecz   write SetCiecz;
    property CanEditQ    :Boolean        read GetCanEditQ;
    property CanEdCiecz  :Boolean        read GetCanEdCiecz;
    property DestroyElOnFree :Boolean    read FDestroyElOnFree
                                         write FDestroyElOnFree;
    property FreeOnClose :Boolean read FFreeOnClose write SetFreeOnClose;
  end;

var
  ElemAbstPrzeplFrm: TElemAbstPrzeplFrm;

implementation

{$R *.DFM}


procedure TElemAbstPrzeplFrm.SetElement(e :TElemAbstract);
begin
  FElement := e;
end;

procedure TElemAbstPrzeplFrm.SetCiecz(c :TCieczPlyw);
begin
  FCiecz := c;
end;

destructor TElemAbstPrzeplFrm.Destroy;
begin
  if DestroyElOnFree then
    Element.Free;
  inherited Destroy;
end;

procedure TElemAbstPrzeplFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FreeOnClose then
    Action := caFree;
end;

procedure TElemAbstPrzeplFrm.SetFreeOnClose(const Value: Boolean);
begin
  FFreeOnClose := Value;
end;

procedure TElemAbstPrzeplFrm.VisibleChanging;
begin
  if not ((FormStyle = fsMDIChild) and Visible) then
    inherited VisibleChanging;
end;

procedure TElemAbstPrzeplFrm.FormShow(Sender: TObject);
begin
 TTlumacz.DajObiekt.Tlumacz(self); 
end;

end.
