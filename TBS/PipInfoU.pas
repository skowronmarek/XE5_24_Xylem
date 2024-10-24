unit PipInfoU;

interface

uses
  SysUtils, Classes, WinProcs, WinTypes, OutLine, DBTables,
  BInfoU, KR_Sys, KR_Class, Prod, Forms, DB;

type
  TOutLineSym = class (TStringList)
  private
    FLevels     :array of Cardinal;
    function GetLevel(i: Integer): Cardinal;
  public
    constructor Create;
    destructor  Destroy;           override;

    function  AddChildObject( Index: LongInt; const Text: string;
                    const Data: Pointer): LongInt;

    property  Levels[ i :Integer ]:Cardinal read GetLevel;
  end;

  TPipesBaseInfo = class (TBaseInfo)
    public        { IBaseInfo - Interface }
      procedure   Init( const FN :string );        override;
      function    TypeId    :string;               override;

    public        { TBaseInfo }
      procedure   OutLineSet( ol :TOutLine );      override;
      function    CanOutLineSet: Boolean;          override;

    private
      FOutLine    :TOutLineSym;
      procedure   OutLineSet1( ol :TOutLineSym );      
    public
      constructor Create;
      destructor  Destroy;                         override;
  end;

function CreatePipeInfo :IBaseInfo;

type
  TPipeTreeNodeObj = class( TStringObj )
  public
    BaseInfo       :TPipesBaseInfo;
    constructor Create( const s :string; bi :TPipesBaseInfo );
  end;

implementation


{----------------------------------------------------------------------------}
function CreatePipeInfo :IBaseInfo;
begin
  result := TPipesbaseInfo.Create;
end;


{----------------------------------------------------------------------------}
constructor TPipesBaseInfo.Create;
begin
  inherited Create;
end;

{----------------------------------------------------------------------------}
destructor  TPipesBaseInfo.Destroy;
begin

  inherited Destroy;
end;

{----------------------------------------------------------------------------}
procedure   TPipesBaseInfo.Init( const FN :string );
var
  list    :TStringList;
  i       :Integer;
  s, s1   :string;
  BFName  :string;                { BaseFileName - nazwa pliku bazy }

begin
  list      := TStringList.Create;
  try
    inherited Init( fn );

    tbsf.ReadSection( 'FILES', list );
    with list do
    begin
      for i := 0 to Count-1 do
      begin
        s1 := Strings[i];
        s  := tbsf.ReadString( 'FILES', s1, '' );
        if s <> '' then
        begin
          BFName := ExtractFilePath(fn) + s;
          if (Length(s1) = 1) then
            if (s1[1] in ['H','G','M']) then
              self.Owner.IndexBase( BFName, s1[1] )
            else if s1 = 'B' then
              self.Owner.IndexBaseExpr( BFName, 'ID', 'ID', [ixUnique] )
            else if s1 = 'T' then
              self.Owner.IndexBaseExpr( BFName, 'TYP_ID','TYP_ID',[ixUnique])
            {else if s1[1] = 'A' then
              self.Owner.IndexABase( BFName )};
        end;
      end;
    end;

  finally
    list.Free;
  end;

  FOutLine := TOutLineSym.Create;
  OutLineSet1( FOutLine );

end;

{----------------------------------------------------------------------------}
function  TPipesBaseInfo.TypeId :string;
begin
  result := 'PIPES';
end;

{----------------------------------------------------------------------------}
procedure   TPipesBaseInfo.OutLineSet1( ol :TOutLineSym );
var
  DBaseName :string;
  tab       :TTable;
  Positions :array of Integer;
  PosSize   :Integer;

procedure SetPSize( NewSize :Integer );
var
  i       :Integer;
begin
  SetLength( Positions, NewSize );
  for i := PosSize to NewSize-1 do
    Positions[i] := -1;
  PosSize := NewSize;
end;


{---------------------------------------------------------}
procedure AddSubTree( pos, filter :Integer  );
var
  s, ident, coment: string;
  i, j      :LongInt;
  PosNew    :Integer;
  PPos      :Integer;
  list      :TStringList;
  c         :char;
  at1,at2   :string;
  iat1, iat2:Integer;

begin
  while not tab.EOF do
  begin
    at1 := tab.FieldByName('At1').AsString;
    at2 := tab.FieldByName('At2').AsString;
    if (StrIsInt(at1)) then
    begin
      iat2 := StrToInt(At2);
      iat1 := StrToInt(At1);
      if (iat2 <> filter) then
      begin
        if (Positions[iat2] >= 0) then
        begin
          filter := iat2;
          pos    := Positions[iat2];
        end;
      end;

      begin
        s  := tab.FieldByName('Element').AsString;
        PosNew := ol.AddChildObject( pos, s,
                  TPipeTreeNodeObj.Create(at1, self) );
        for i := 0 to PosSize-1 do
        begin
          if Positions[i] >= PosNew then
            inc( Positions[i] );
        end;
        if iat1 >= PosSize then
          SetPSize( iat1+10 );
        Positions[iat1] := PosNew;
        //AddSubTree( PosNew, StrToInt(at1) );
      end
    end;
    Application.ProcessMessages;
    tab.Next;
  end;
end;     { AddSubTree }
{---------------------------------------------------------}

var
  FN        :string;
  PosNew :Integer;
begin              { TPumpsBaseInfo.OutLineSet( ol :TOutLine ); }
  //ClearStrings(ol.Lines);
  DBaseName := StrLeft( ExtractFilePath(TBSFName), -2 );
  {ol.font.pitch := fpFixed;}
  PosNew := ol.AddChildObject( 0, Owner.Nazwa, TPipeTreeNodeObj.Create('0', self) );

  tab := TTable.Create(NIL);
  try
    tab.DataBaseName := DBaseName;
    FN := TBSF.ReadString( 'FILES', 'A', '' );
    {FN := ExtractFileName(TBSFName);}
    tab.TableNAme := FN;
    //tab.SQL.Add( Format('SELECT * FROM %s ', [FN]{[StrBefore('.',FN)]} ) );
    {tab.SQL.Add( FN );}
    //tab.SQL.Add( Format( 'WHERE AT2 = "%d" ', [filter] ) );
    tab.Open;

    PosSize := 0;
    SetPSize( 20 );
    Positions[0] := 0;

    AddSubTree( PosNew, 0 );
  finally
    tab.Free;
  end;
end;

{----------------------------------------------------------------------------}
procedure TPipesBaseInfo.OutLineSet(ol: TOutLine);
var
  i       :Integer;
  oln     :TOutLineNode;

procedure Recur( level, Pos :Integer);
var
  o       :TPipeTreeNodeObj;
  PosNew,l  :Integer;
  s       :string;
begin
  PosNew := Pos;
  repeat
    inc(i);
    if i < FOutLine.Count then
    try
      s := FOutLine.Strings[i];
      l := FOutLine.Levels[i];
      if {FOutLine.Levels[i]}l > level then
      begin
        //PosNew := ol.AddChildObject( PosNew, {FOutLine.Strings[i]}s,
        //                             FOutLine.Objects[i] );
        dec(i);
        Recur( FOutLine.Levels[i+1], PosNew );
      end
      else if l = level then
      begin
        PosNew := ol.AddChildObject( Pos, FOutLine.Strings[i],
                                     FOutLine.Objects[i] );
      end
      else
        dec(i);
    except
      on EOutlineError do
        EXIT;
    end
  until (i >= FOutLine.Count) or (l < level);
end;


begin
  i := -1;
  //PosNew := 0;
  Recur( 0, 0 );
end;


{----------------------------------------------------------------------------}
function    TPipesBaseInfo.CanOutLineSet: Boolean;
begin
  result := true;
end;

{----------------------------------------------------------------------------}
constructor TPipeTreeNodeObj.Create( const s :string; bi :TPipesBaseInfo );
begin
  inherited Create( s );
  BaseInfo := bi;
end;


{ TOutLineSym }

function TOutLineSym.AddChildObject(Index: Integer; const Text: string;
  const Data: Pointer): LongInt;
var
  i, j   :Integer;
  l      :Integer;
begin
  if (Index = 0) and (Count = 0) then
  begin
    InsertObject( Index, Text, TObject(Data) );
    result := Index;
    FLevels[Index] := 0;
  end
  else
  begin
    i := Index+1;
    l := FLevels[Index];
    while (i < Count) and (FLevels[i] > l) do
      inc(i);
    if (Count >= Length(FLevels)) then
      SetLength(FLevels, Count+10);
    for j := Count-1 downto i do
      FLevels[j+1] := FLevels[j];
    InsertObject( i, Text, TObject(Data) );
    FLevels[i] := l+1;
    result := i;
  end;
end;

constructor TOutLineSym.Create;
begin
  SetLength( FLevels, 5 );
  //Insert( 0, '' );
end;

destructor TOutLineSym.Destroy;
begin
  inherited Destroy;
end;

function TOutLineSym.GetLevel(i: Integer): Cardinal;
begin
  result := FLevels[i];
end;

initialization
  RegisterBaseType( 'PIPES', CreatePipeInfo );

end.
