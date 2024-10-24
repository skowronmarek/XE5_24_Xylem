unit ZadCompU;

interface

uses
  SysUtils, Classes, Forms, extctrls, TbsU, KR_Class, TBS_Tool;

type
  // Podstawowa klasa komponentow obliczeniowych
  TZadComponent = class (TComponent)
  private
    function GetXXClassName: string;   // tylko do debagowania
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent);  override;

    procedure ValidateRename( AComponent: TComponent;                     // nie uzywane
                              const CurName, NewName: string); override;

    function  CzyWczytacKomponent( C :TComponent ): Boolean;   virtual;   // wyklucza czytanie Form

  public
    constructor Create( AOwner :TComponent );                  override;  // tylko do debagowania

    property XXClassName :string read GetXXClassName;                     // tylko do debagowania
  end;

var
  ssClassNameDummy :string;   // Makieta klasy - nie uzywane

implementation


{ TZadComponent }

constructor TZadComponent.Create(AOwner: TComponent);
begin
  inherited;
  ssClassNameDummy := XXClassName;  // nie uzywane do obliczen
end;

function TZadComponent.CzyWczytacKomponent(C: TComponent): Boolean;
//Wczytuje komponenty ktore maja nazwe
begin
  result := (not (C is TForm))
            and (C.Name <> '');
end;

procedure TZadComponent.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
  //if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      if not OwnedComponent.HasParent and CzyWczytacKomponent(OwnedComponent)
         then Proc(OwnedComponent);
    end;
end;

function TZadComponent.GetXXClassName: string;
begin
  result := ClassName;
end;

procedure TZadComponent.ValidateRename(AComponent: TComponent; const CurName,
  NewName: string);
var
  C        :TComponent;
begin
  if csLoading in ComponentState then
  begin
    C := FindComponent( NewName );
    if (C <> NIL) and (AComponent <> C) then
      C.Name := '';
  end
  else
    inherited ValidateRename( AComponent, CurName, NewName );
end;


end.
