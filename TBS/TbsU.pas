unit TbsU;

interface

uses
  Windows, SysUtils, Classes, IniFiles, Dialogs, Forms,
  KR_Sys, CryptU, DynStructur;

var
  ZetonFile         :TCustomIniFile;
  ProdBlok         : Boolean;     // Blokada producentow
                                  // false => mozliwosc odczytania
                                  // wszystkich producentow
  DozwProducenci   : string;      // lista dozwolonych producentow
                                  // jako string np: '/LFP/BIALOG'
  DozwBazy         : string;      //

  SciezkaBaz       : string;
  ExePath          : string;              

type
  TProcNoParams = procedure;
  TProcPointerPar = procedure( P :Pointer );
  TProcObj = procedure of object;

  TAskProcNoParams = procedure( var ADone :Boolean );
  TAskProcPointerPar = procedure( var ADone :Boolean; P :Pointer );
  TAskProcObj = procedure( var ADone :Boolean ) of object;

  TApplicationIdle = class (TComponent)
  private
    FList          :TLList;
  public
    constructor Create(Owner :TComponent);     override;
    destructor  Destroy;                       override;

    procedure Idle(Sender: TObject; var Done: Boolean);

    function AddActionNoPars( proc :TProcNoParams;
                              Times :Integer ) :Pointer;
    function AddActionPointerPar( proc :TProcPointerPar;
                                  Ptr  :Pointer;
                                  Times :Integer ) :Pointer;
    function AddObjAction( proc :TProcObj; Times :Integer ) :Pointer;

    function AddAskActionNoPars( proc :TAskProcNoParams;
                              DefDone :Boolean = true ) :Pointer;
    function AddAskActionPointerPar( proc :TAskProcPointerPar;
                                  Ptr  :Pointer;
                                  DefDone :Boolean = true ) :Pointer;
    function AddAskObjAction( proc :TAskProcObj;
                              DefDone :Boolean = true ) :Pointer;
  end;

var
  ApplicationIdle :TApplicationIdle;

procedure InitIdle;
procedure FreeSoon( ob :TObject );
procedure ZetonSave;

implementation

var
  F, FCrypt   :Integer;
  FN, FCN     :string;

procedure ZetonSave;
var
  b       :byte;
begin
  ZetonFile.UpdateFile;
  F := FileOpen( FN, fmOpenRead or fmShareDenyWrite );
  FileClose(FCrypt);
  if not FileExists(FCN) then
  begin
    FCrypt := FileCreate(FCN);
    FileClose(FCrypt);
  end;
  FCrypt := FileOpen( FCN, fmOpenReadWrite or fmShareDenyWrite );
  CryptSeed := TbsInitCryptValue;
  while FileRead( F, b, 1 ) = 1 do
  begin
    b := b xor CryptRandom( 256 );
    FileWrite( FCrypt, b, 1 );
  end;
  FileClose(F);
  DeleteFile(FN);
end;

procedure ZetonDecr;
var
  b       :byte;
begin
  CryptSeed := TbsInitCryptValue;
  while FileRead( FCrypt, b, 1 ) = 1 do
  begin
    b := b xor CryptRandom( 256 );
    FileWrite( F, b, 1 );
  end;
  FileClose(F);
  F := FileOpen( FN, fmOpenRead or fmShareDenyWrite );
end;



procedure InitZeton;
var
  s          :string;
  i          :Integer;
  pszFN, pszPath      :array[0..Max_Path] of char;
begin

  // FN := Nazwa pliku EXE z rozszerzeniem '.ZET'
  s := ParamStr(0);
  i := length(s);
  while (i>0) and (s[i]<>'.') do
    dec(i);
  s := StrLeft( s, i ) + 'ZET';
  FCN := s;

  if not FileExists(s) then
  begin
    ShowMessage('Brak plikow konfiguracyjnych');
    Halt(1);
  end;

  GetTempPath( sizeOf(pszPath), pszPath );
  i := GetTempFileName( pszPath, 'tbs', 0, pszFN );
  if i = 0 then
    raise Exception.Create('Nie mozna utworzyc pliku tymczasowego');

  FN := pszFN;


(*  F      := FileOpen( FN, fmOpenReadWrite or fmShareDenyWrite );
  FCrypt := FileOpen( s,  fmOpenReadWrite or fmShareDenyWrite );
*)
  F      := FileOpen( FN, fmOpenReadWrite or fmShareDenyNone);
  FCrypt := FileOpen( s,  fmOpenReadWrite or fmShareDenyNone );

  ZetonDecr;
  ZetonFile := TMemIniFile.Create( FN );
  FileClose(F);
  DeleteFile(FN);


end;

procedure DoneZeton;
begin
  ZetonFile.Free;
  //FileClose( F );
  FileClose( FCrypt );
  //SysUtils.DeleteFile( FN );
end;


procedure InitIdle;
begin
  ApplicationIdle := TApplicationIdle.Create(Application);
  Application.OnIdle := ApplicationIdle.Idle;
end;


procedure DoFreeObj( P :Pointer );
begin
  try
    TObject(P).Free;
  except on EAccessViolation do
    begin

    end;
  end;
end;

procedure FreeSoon( ob :TObject );
begin
  ApplicationIdle.AddActionPointerPar( @DoFreeObj, ob, 1 );
end;

type
  TIdleProcNode = class (TNode)
  private
    procedure Work;    virtual;  abstract;
  end;


  TIdleTimesProcNode = class (TIdleProcNode)
  private
    Times      :Integer;
  end;

  TProcNPNode = class (TIdleTimesProcNode)
  private
    proc      :TProcNoParams;
    procedure Work;    override;
  end;

  TProcPtrNode = class (TIdleTimesProcNode)
  private
    proc      :TProcPointerPar;
    Ptr       :Pointer;
    procedure Work;    override;
  end;

  TProcObjNode = class (TIdleTimesProcNode)
  private
    proc      :TProcObj;
    procedure Work;    override;
  end;

  TIdleAskProcNode = class (TIdleProcNode)
  private
    Done  :Boolean;
    DefDone :Boolean;
    procedure Work;    override;
  end;

  TAskProcNPNode = class (TIdleAskProcNode)
  private
    proc      :TAskProcNoParams;
    procedure Work;    override;
  end;

  TAskProcPtrNode = class (TIdleAskProcNode)
  private
    proc      :TAskProcPointerPar;
    Ptr       :Pointer;
    procedure Work;    override;
  end;

  TAskProcObjNode = class (TIdleAskProcNode)
  private
    proc      :TAskProcObj;
    procedure Work;    override;
  end;

{ TApplicationIdle }

function TApplicationIdle.AddActionNoPars(proc: TProcNoParams;
         Times: Integer): Pointer;
var
  N      :TProcNPNode;
begin
  N := TProcNPNode.Create;
  N.Times := Times;
  N.proc := proc;
  FList.Append(N);
  result := N;
end;

function TApplicationIdle.AddActionPointerPar(proc: TProcPointerPar;
         Ptr  :Pointer; Times: Integer): Pointer;
var
  N      :TProcPtrNode;
begin
  N := TProcPtrNode.Create;
  N.Times := Times;
  N.Ptr := Ptr;
  N.proc := proc;
  FList.Append(N);
  result := N;
end;

function TApplicationIdle.AddAskActionNoPars(proc: TAskProcNoParams;
  DefDone: Boolean): Pointer;
var
  N      :TAskProcNPNode;
begin
  N := TAskProcNPNode.Create;
  N.DefDone := DefDone;
  N.proc := proc;
  FList.Append(N);
  result := N;
end;

function TApplicationIdle.AddAskActionPointerPar(proc: TAskProcPointerPar;
  Ptr: Pointer; DefDone: Boolean): Pointer;
var
  N      :TAskProcPtrNode;
begin
  N := TAskProcPtrNode.Create;
  N.DefDone := DefDone;
  N.Ptr := Ptr;
  N.proc := proc;
  FList.Append(N);
  result := N;
end;

function TApplicationIdle.AddAskObjAction(proc: TAskProcObj;
  DefDone: Boolean): Pointer;
var
  N      :TAskProcObjNode;
begin
  N := TAskProcObjNode.Create;
  N.DefDone := DefDone;
  N.proc := proc;
  FList.Append(N);
  result := N;
end;

function TApplicationIdle.AddObjAction(proc: TProcObj;
  Times: Integer): Pointer;
var
  N      :TProcObjNode;
begin
  N := TProcObjNode.Create;
  N.Times := Times;
  N.proc := proc;
  FList.Append(N);
  result := N;
end;

constructor TApplicationIdle.Create(Owner: TComponent);
begin
  inherited;
  FList := TLList.Create;
end;

destructor TApplicationIdle.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TApplicationIdle.Idle(Sender: TObject; var Done: Boolean);
var
  N, NP, nx  :TIdleProcNode;
  TNP        :TIdleTimesProcNode;
  ANP        :TIdleAskProcNode;
begin
  N := FList.First;
  while (N <> NIL) do
  begin
    Nx := FList.Next(N);
    try
      N.Work;
    except
      FList.Remove(N);
      N.Free;
      N := Nx;
      CONTINUE;
    end;
    NP := N;
    N := Nx;
    if (NP is TIdleTimesProcNode) then
    begin
      TNP := TIdleTimesProcNode(NP);
      if TNP.Times > 0 then
      begin
        dec(TNP.Times);
        if TNP.Times = 0 then
        begin
          FList.Remove(TNP);
          TNP.Free;
        end;
      end;
    end
    else if (NP is TIdleAskProcNode) then
    begin
      ANP := TIdleAskProcNode(NP);
      if ANP.Done then
      begin
        FList.Remove(ANP);
        ANP.Free;
      end;
    end;
  end;
end;

{ TProcNPNode }

procedure TProcNPNode.Work;
begin
  proc;
end;

{ TProcPtrNode }

procedure TProcPtrNode.Work;
begin
  proc(Ptr);
end;

{ TProcObjNode }

procedure TProcObjNode.Work;
begin
  proc;
end;

{ TIdleAskProcNode }

procedure TIdleAskProcNode.Work;
begin
  Done := DefDone;
end;

{ TAskProcNPNode }

procedure TAskProcNPNode.Work;
begin
  inherited;
  proc( Done );
end;

{ TAskProcPtrNode }

procedure TAskProcPtrNode.Work;
begin
  inherited;
  Proc( Done, Ptr );
end;

{ TAskProcObjNode }

procedure TAskProcObjNode.Work;
begin
  inherited;
  Proc( Done );
end;

initialization
  ExePath := ExtractFilePath(ParamStr(0));
  InitZeton;

finalization
  DoneZeton;


end.
