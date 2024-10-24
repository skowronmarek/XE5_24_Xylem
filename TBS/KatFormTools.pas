unit KatFormTools;

interface

uses
  SysUtils, Classes, OPompa, AbstractFormPompyU, FPompy;

procedure RegisterPompForm( const PmpClass :TPompaClass;
                            const FrmClass :TAbstractFormPompyClass );

function FormDlaPompy( const APompa :TPompa;
                       AOwner :TComponent;
                       AMdiChild   : Boolean ) :TAbstractFormPompy;

implementation

var
  FFormPompList : TStringList;

procedure RegisterPompForm( const PmpClass :TPompaClass;
                            const FrmClass :TAbstractFormPompyClass );
begin
  if FFormPompList = NIL then
  begin
    FFormPompList := TStringList.Create;
    FFormPompList.Sorted := True;
  end;
  FFormPompList.AddObject(PmpClass.ClassName, TObject(FrmClass));
end;

function FormDlaPompy( const APompa :TPompa;
                       AOwner :TComponent;
                       AMdiChild   : Boolean ) :TAbstractFormPompy;
var
  pos     :Integer;
  aClass  :TClass;
begin
  Result := NIL;
  aClass := APompa.ClassType;
  repeat
    pos := FFormPompList.IndexOf(aClass.ClassName);
    aClass := aClass.ClassParent;
  until (pos >= 0) or not (aClass.InheritsFrom(TPompa));
  if pos >= 0 then
    Result := TAbstractFormPompyClass(FFormPompList.Objects[pos]).StworzDlaPompy(AOwner,
                          APompa, AMdiChild    );
end;


end.
