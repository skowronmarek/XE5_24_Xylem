unit ZadFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TypInfo, PropertyAccesserU, FormSaverU,
  WkpGlob, TbsFormU, ZadU, Jezyki;

type
  TZadForm = class(TTbsForm)
    Saver: TFormSaver;
    SaveZadDialog: TSaveDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaverLoadProperty(Sender: TObject; var APath: String;
      var Value: Variant; TypeKind: TTypeKind; var Allow: Boolean);
    procedure SaverSaveProperty(Sender: TObject; var APath: String;
      var Value: Variant; TypeKind: TTypeKind; var Allow: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FZad      :TZadanie;
    FAktLockCnt :Integer;
  protected
    JestZmianaGlob:boolean;  // globalna do zapisu
    procedure SetZad( v :TZadanie );     virtual;
    procedure CloseRaport;               virtual;
  public
    { Public declarations }
    property Zad :TZadanie read FZad write SetZad;
    procedure LockAktual;
    procedure UnlockAktual;
    function  AktualLocked :Boolean;
    function  SaveQuery(var CanClose :Boolean) :Boolean;
  published
    property Visible  nodefault;
    property FormStyle  nodefault;
  end;

var
  ZadForm: TZadForm;

implementation

uses KatDataMU;

{$R *.DFM}

//-----------------------------------------------------------------------------
procedure TZadForm.SetZad( v :TZadanie );
begin
  FZad := v;
  if not AktualLocked then
    Aktualizuj;
end;


procedure TZadForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Action = caFree) and (Zad <> NIL)
     and (self = Zad.GetMainForm) and (Zad.FreeWithForm) then
  begin
    //if Zad.CanBeFree then
    //  Zad.Free
    //else
      Zad.FreeSoon;
    Action := caNone;
  end;
end;

//var
  //v :Boolean;


procedure TZadForm.SaverLoadProperty(Sender: TObject; var APath: String;
  var Value: Variant; TypeKind: TTypeKind; var Allow: Boolean);
begin
  if WindowState = wsMaximized then
    if pos( Format('$%s$', [UpperCase(APath)]), '$TOP$LEFT$WIDTH$HEIGHT$') > 0 then
      Allow := false;

end;

procedure TZadForm.SaverSaveProperty(Sender: TObject; var APath: String;
  var Value: Variant; TypeKind: TTypeKind; var Allow: Boolean);
begin
  if WindowState = wsMaximized then
    if pos( Format('$%s$', [UpperCase(APath)]), '$TOP$LEFT$WIDTH$HEIGHT$') > 0 then
      Allow := false;
end;

function TZadForm.AktualLocked: Boolean;
begin
  result := FAktLockCnt > 0;
end;

procedure TZadForm.LockAktual;
begin
  inc(FAktLockCnt);
end;

procedure TZadForm.UnlockAktual;
begin
  dec(FAktLockCnt);
end;

function TZadForm.SaveQuery(var CanClose: Boolean): Boolean;
var
  odp    :Integer;
begin
  odp := MessageBox( Handle, PCHar(TTlumacz.dajObiekt.ZnajdzTlumaczenie('Zachowac zmiany')),
                     PChar(Zad.FileName),
                     MB_YESNOCANCEL or MB_ICONQUESTION );
  case odp of
    IDCANCEL:
    begin
      CanClose := false;
      result   := false;
    end;

    IDYES:
    begin
      if Zad.FileName = '' then
      begin
        if SaveZadDialog.Execute then
        begin
          Zad.SaveToFile(SaveZadDialog.FileName);
          CanClose := true;
          result := true;
        end
        else
        begin
          CanClose := false;
          result := false;
        end;
      end
      else
      begin
        Zad.Save;
        CanClose := true;
        result := true;
      end;
    end;

    IDNO:
    begin
      CanClose := true;
      result := false;
    end;
  end;

end;

procedure TZadForm.FormCreate(Sender: TObject);
begin
  inherited;
  SaveZadDialog.InitialDir := SciezkaWkpArchiwum;
end;

procedure TZadForm.CloseRaport;
begin
  // NIC
end;

end.
