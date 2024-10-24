unit WieloCharFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB,
  TbsFormU, Diagrams, KR_Class,
  LinCharU, OPompa, PompySQL, PmpListU, Math, WCharU, ObszarWCharU;

type

  TWieloCharForm = class(TTbsForm)
    Diagram: TDiagram;
    DF1: TDiagFunction;
    descrQOpis: TDiagDescr;
    descrQJedn: TDiagDescr;
    descrHJedn: TDiagDescr;
    descrHOpis: TDiagDescr;
    procedure DiagramDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DiagramDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    List :TWCharList;
    ObszFun :TObszWCharDiagFun;
  public
    constructor Create( AOwner :TComponent );              override;
    destructor Destroy;                                    override;

    procedure Clear;
    procedure Add( P :TPompa );                            overload;
    procedure Add( DB :TDBPompy );                         overload;
  end;

var
  WieloCharForm: TWieloCharForm;

implementation

{$R *.DFM}

{ TWieloCharForm }

procedure TWieloCharForm.Add(P: TPompa);
var
  cd      :TPompCharData;
begin
  cd := P.CreateCharDataDB(self);
  try
    cd.Pompa := P;
    List.AddInfo(cd, Diagram);
  finally
    cd.Free;
  end;
  with List.Info[List.Count-1] do
  begin
    HFun.Diagram := Diagram;
    DF1.MaxYR := Max( DF1.MaxYR, HFun.MaxYR );
    HFun.FunScale := DF1;
    if Char.CharQMax > Diagram.MaxXR then
      Diagram.CountMaxXR(Char.CharQMax);
    HFun.IsOn := false;
  end;
end;

constructor TWieloCharForm.Create(AOwner: TComponent);
begin
  inherited;
  List := TWCharList.Create;
  ObszFun := TObszWCharDiagFun.Create(self);
end;

destructor TWieloCharForm.Destroy;
begin
  List.Free;
  inherited;
end;

procedure TWieloCharForm.DiagramDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TPmpDragObjectBase);
  if not Accept then
    EXIT;
end;

procedure TWieloCharForm.DiagramDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  dob     :TPompaDragObject;
begin
  dob := Source as TPompaDragObject;
  Add( dob.Pompa );
end;

procedure TWieloCharForm.Add(DB: TDBPompy);
var
  svBmk   :TBookmarkStr;
  OP      :TPompa;
begin
  svBmk := TBookmarkStr(DB.A.Bookmark);
  try
    DB.First;
    while not DB.EOF do
    begin
      OP := CreatePump( NIL, DB );
      OP.AddRef;
      try
        Add(OP);
      finally
        OP.Release;
      end;
      DB.Next;
    end;
  finally
    DB.A.Bookmark := TBookmark(svBmk);
  end;
  ObszFun.CharList := List;
  DF1.Drawer := ObszFun;
end;

procedure TWieloCharForm.Clear;
begin
  List.Clear;
  Diagram.MaxXR := 0.1;
  DF1.MaxYR     := 0.1;
end;

end.
