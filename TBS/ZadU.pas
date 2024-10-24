unit ZadU;

interface

uses
  SysUtils, Classes, Forms, extctrls, TbsU, KR_Class, TBS_Tool, ZadCompU;

type
  TZadanie = class (TZadComponent)
  private
    FOpis           :string;
    FFileName       :string;
    FFreeWithForm   :Boolean;               // czy zwalniac przy zamykaniu okna
    FCloseTimer     :TTimer;
    FChngLockCnt    :Integer;
    procedure CloseTimerAction( Sender :TObject );
  protected
    FMainForm :TForm;
    FChanged  :Boolean;
    FShouldFree :Boolean;
    procedure CreateMainForm;                        virtual;
    procedure Notification( AComponent: TComponent;
                            Operation: TOperation);  override;
    function GetCanBeFree: Boolean;                  virtual;
    procedure SetVal( var Prop :Double; Value :Double );   overload;
    procedure SetVal( var Prop :Integer; Value :Integer ); overload;
  public
    constructor Create( O :TComponent );        override;
    destructor Destroy;                         override;
    procedure FreeSoon;
    procedure Save;
    procedure SaveToFile  ( const FN :string );
    function  GetMainForm    :TForm;
    procedure UpdateForm;

    procedure DoChange;                              virtual;
    procedure LockChange;
    procedure UnlockChange;
    function  ChangeLocked :Boolean;


    class function LoadFromFile( const FN :string ): TZadanie; overload;
    class function LoadFromFile( const FN :string;
                                 AProgrProc :TKRProgressEvent ): TZadanie; overload;
    class function LoadFromStream( strm :TStream ): TZadanie;

    procedure LoadThisFromFile( const FN :string );
    procedure ChangeEvent( Sender :TObject );

    property Changed :Boolean    read FChanged;
    property FileName :string    read FFileName;
    property FreeWithForm :Boolean read FFreeWithForm write FFreeWithForm;
    property CanBeFree :Boolean read GetCanBeFree;

  published
    property Opis  :string       read FOpis write FOpis;
  end;

  TZadanieClass = class of TZadanie;
var
  ccZadCnt :Integer = 0;

const //Globalne stale obliczenniowe
  CmaleH     = 0.01;    // [m]
  CmalutkieH = 0.00001; // [m]
  CduzeH     = 10000;   // [m]
  CWielkieH  = 1000000; // [m]
  CmaleQ     = 0.01;    // [m3/h]
  CmalutkieQ = 0.00001; // [m3/h]
  CduzeQ     = 10000;   // [m3/h]
  CWielkieQ  = 1000000; // [m3/h]

implementation

uses
  ZadFrmU;


{ TZadanie }

procedure TZadanie.ChangeEvent(Sender: TObject);
begin
  DoChange;
end;

function TZadanie.ChangeLocked: Boolean;
begin
  result := FChngLockCnt > 0;
end;

procedure TZadanie.CloseTimerAction(Sender: TObject);
begin
  try
    if CanBeFree then
    begin
      if sender <> NIL then
        TTimer(Sender).Enabled := false;
      if not (csDestroying in ComponentState) then
        Free;
    end;
  except
    on EAccessViolation do
      try
        if sender <> NIL then
          TTimer(Sender).Enabled := false;
      except
      end;
  end;
end;

constructor TZadanie.Create(O: TComponent);
begin
  inherited Create(O);
  FreeWithForm := true;
  FCloseTimer := TTimer.Create(self);
  FCloseTimer.Enabled := false;
  FCloseTimer.Interval := 100;
  FCloseTimer.OnTimer := CloseTimerAction;
  inc(ccZadCnt)
end;

procedure TZadanie.CreateMainForm;
begin
end;


destructor TZadanie.Destroy;
begin
  inherited;
  dec(ccZadCnt);
end;

procedure TZadanie.DoChange;
begin
  if not ChangeLocked then
  begin
    FChanged := true;
    UpdateForm;
  end;
end;

procedure DoFreeZad( var ADone :Boolean; P :Pointer );
var
  Z       :TZadanie;
begin
  Z := P;
  ADone := false;
  if Z.CanBeFree then
  begin
    ADone := true;
    try
      Z.Free;
    except
      on E :Exception do
      begin
        //ADone := false;
        {$ifdef _DEBUG_}
        Application.ShowException(E);
        {$endif}
      end;
    end;
  end;
end;


procedure TZadanie.FreeSoon;
begin
  {
  FShouldFree := true;
  FCloseTimer.Enabled := true;
  }
  if (self <> NIL) and (not FShouldFree) then
  begin
    FShouldFree := true;
    ApplicationIdle.AddAskActionPointerPar( @DoFreeZad, self, false );
  end;
end;

function TZadanie.GetCanBeFree: Boolean;
begin
  result := true;
end;

function  TZadanie.GetMainForm    :TForm;
begin
  if FMainForm = NIL then
    CreateMainForm;
  result := FMainForm;
end;

class function TZadanie.LoadFromFile( const FN :string ): TZadanie;
var
  FS      :TFileStream;
begin
  FS := TFileStream.Create( FN, fmOpenRead );
  try
    result := FS.readComponent( NIL ) as TZadanie;
    result.FChanged := false;
    if result.FileName <> FN then
      result.FFileName := FN;
  finally
    FS.Free;
  end;
end;


class function TZadanie.LoadFromFile(const FN: string;
  AProgrProc: TKRProgressEvent): TZadanie;
var
  FS      :TFileStream;
  SA      :TStreamProgressAdapter;
begin
  FS := TFileStream.Create( FN, fmOpenRead );
  try
    SA := TStreamProgressAdapter.Create( FS );
    try
      SA.OnRead := AProgrProc;
      result := SA.readComponent( NIL ) as TZadanie;
      result.FChanged := false;
      if result.FileName <> FN then
        result.FFileName := FN;
    finally
      SA.Free;
    end;
  finally
    FS.Free;
  end;
end;

class function TZadanie.LoadFromStream(strm: TStream): TZadanie;
begin
  result := strm.readComponent( NIL ) as TZadanie;
  result.FChanged := false;
end;

procedure TZadanie.LoadThisFromFile(const FN: string);
var
  FS      :TFileStream;
begin
  FS := TFileStream.Create( FN, fmOpenRead );
  try
    FS.readComponent( self );
    FChanged := false;
    if FileName <> FN then
      FFileName := FN;
  finally
    FS.Free;
  end;
end;

procedure TZadanie.LockChange;
begin
  inc(FChngLockCnt);
end;

procedure TZadanie.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (AComponent = FMainForm) and (Operation = opRemove) then
  begin
    FMainForm := NIL;
  end;
  inherited Notification( AComponent, Operation );
end;

procedure TZadanie.Save;
begin
  if FileName <> '' then
    SaveToFile( FileName );
end;

procedure TZadanie.SaveToFile  ( const FN :string );
var
  FS      :TFileStream;
begin
  FS := TFileStream.Create( FN, fmCreate );
  FS.WriteComponent( self );
  FS.Free;
  FChanged := false;
  if FileName <> FN then
    FFileName := FN;
end;

procedure TZadanie.SetVal(var Prop: Double; Value: Double);
begin
  if Prop <> Value then
  begin
    Prop := Value;
    FChanged := true;
  end;
end;

procedure TZadanie.SetVal(var Prop: Integer; Value: Integer);
begin
  if Prop <> Value then
  begin
    Prop := Value;
    FChanged := true;
  end;
end;

procedure TZadanie.UnlockChange;
begin
  dec(FChngLockCnt);
end;

procedure TZadanie.UpdateForm;
begin
  if (FMainForm <> NIL) and (FMainForm is TZadForm) then
    (FMainForm as TZadForm).Aktualizuj;
end;



initialization
  RegisterClass(TZadanie);

end.
