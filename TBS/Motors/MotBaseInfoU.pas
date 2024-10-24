unit MotBaseInfoU;


interface

uses
  Classes,
  SysUtils,
  Menus,
  OutLine,
  Forms,
  IniFiles,
  Controls,

  DB,
  DBTables,
  TbsU,
  Graphics,
  KR_Sys,
  KR_Class,
  KR_DB,
  BInfoU,
  Prod
  ;

type

  TMotOLInfo = class
  public
    T          :string;
    G          :string;
    CH         :string;
    Zdj        :string;
    Filtr      :Boolean;
    Obszar     :Boolean;
    CharColor  :TColor;
    FldName    :string;
    Value      :Variant;
  end;


  TMotBaseInfo = class (TBaseInfo)
  private
    procedure InitGrupy( const BFName :string);
  public
    procedure   Init( const fn :string );        override;
    function    TypeId    :string;               override;

  public

    procedure   OutLineSet( ol :TOutLine );      override;
    function    CanOutLineSet: Boolean;          override;
    procedure   AddSubTree( ol :TOutLine; APos: Integer; const title: string;
                            IdNo :Integer = 0);
    function    GenerSQLText( const WhereClause :string;
                              const Columns :string = '*' ) :string;  overload;
    function    GenerSQLText( const WhereClause :TStrings;
                              const Columns :string = '*' ) :string;  overload;
  end;


implementation

uses
  FiltryGlob;

function CreateMotInfo :IBaseInfo;
begin
  result := TMotBaseInfo.Create;
end;

{==============================================================================
-------------------------------------------------------------------------------
|  Klasa: TMotBaseInfo
|
|
|
-------------------------------------------------------------------------------
}



{----------------------------------------------------------------------------}
procedure TMotBaseInfo.Init( const fn :string );
var
  list    :TStringList;
  i       :Integer;
  s, s1   :string;
  BFName  :string;                { BaseFileName - nazwa pliku bazy }

begin
  try
    inherited Init( fn );
    list      := TStringList.Create;
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
          begin
            if (s1[1] in ['H','G','M']) then
              self.Owner.IndexBase( BFName, s1[1] )
            else if (s1 = 'B') then
              self.Owner.IndexBaseExpr( BFName, 'ID', 'ID', [ixUnique] )
            else if s1 = 'T' then
            begin
              self.Owner.IndexBaseExpr( BFName, 'TYP_ID','TYP_ID',[ixUnique]);
              InitGrupy( BFName );
            end
            else if s1[1] = 'A' then
              self.Owner.IndexABase( BFName );
          end
          else
          begin
            s1 := Upper(s1);
            if s1 = 'LINKS' then
            begin
              self.Owner.IndexBaseExpr( BFName, 'IDS',
                                        'ID1+ID2+ID2+ID4+ID5+ID6+ID7+ID8',
                                        [ixExpression] );
            end
            else if (s1 = 'WAR') then
            begin
              self.Owner.IndexBaseExpr( BFName, 'ID', 'ID', [] )
            end;
          end;
        end;
      end;
    end;

  finally
    list.Free;
  end;

end;

{----------------------------------------------------------------------------}
function  TMotBaseInfo.TypeId :string;
begin
  result := 'PUMPS';
end;

{----------------------------------------------------------------------------}
function    TMotBaseInfo.CanOutLineSet: Boolean;
begin
  result := true;
end;



{---------------------------------------------------------}
procedure TMotBaseInfo.AddSubTree( ol :TOutLine; APos :Integer; const title :string;
                                     IdNo :Integer = 0 );
var
  s, ident, coment :string;
  s1, s2, s3       :string;
  PosS      :Integer;
  i, j      :LongInt;
  PosNew    :Integer;
  list      :TStringList;
  c         :char;
  o         :TMotOLInfo;
  NxtIdNo   :Integer;
  NxtTitle  :string;
  vTitle    :string;

begin
  list := TStringList.Create;
  try
    tbsf.ReadSection( title, list );
    for i := 0 to list.Count-1 do
    begin
      vTitle := title;
      ident  := list.Strings[i];

      if ident[1] = '^' then
      begin
        s := StrBehinde( '<', ident );
        vTitle := StrBefore( '>', s );
        s := StrBehinde( '>', s );
        ident := StrBehinde( '.', s );
        if vTitle = 'STRUCTURE' then
          IdNo := 1;
      end;

      s := tbsf.ReadString( vTitle, ident, '' );
      coment := StrBefore( '|', s );
      s2     := StrBehinde( '|', s );
      PosS   := pos( '/T=', s2 );
      o      := TMotOLInfo.Create;
      o.T    := StrParseStr( s2, 'T', '' );    // Typ_Id   - identyfikator w bazie T
      o.Zdj  := StrParseStr( s2, 'ZDJ', '' );  // Zdjecie - identyfikator zdjecia w BIN
      o.G    := StrParseStr( s2, 'G', '' );
      o.CH   := StrParseStr( s2, 'CH', '' );   // char  - identyfikator charakterystyki w BIN
      o.Obszar := Boolean(StrParseInt( s2, 'OB', 0 ));
      o.CharColor := StrParseInt( s2, 'COLOR', -1 );
      o.FldName := StrParseStr( s2, 'FLDNAME', '' );

      if (vTitle = 'STRUCTURE') or (vTitle = 'GRUPY') then
        c := ':'
      else
        c := '\';

      if ident[1] = '\' then
      begin
        ident := StrButFirst( ident, 1 );
        NxtTitle := ident;
      end
      else
      begin
        NxtTitle := Format( '%s%s%s', [vTitle, c, ident] );
      end;
      ident := StrParseStr( s2, 'VALUE', ident );
      o.Value := ident;

      if IsPrefix( 'STRUCTURE', vTitle ) then
      begin
        s1     := Format( '%-8s %s', [ident, coment] );
        if (IdNo > 0) and (o.FldName = '') then
        begin
          o.Filtr := true;
          o.FldName := Format( 'ID%d', [IdNo] );
        end;
      end
      else
      begin
        s1 := coment;
      end;
      o.Filtr := o.FldName <> '';

      if IdNo > 0 then
        NxtIdNo := IdNo+1
      else
        NxtIdNo := IdNo;
      PosNew := ol.AddChildObject( APos, s1, o );
      AddSubTree( ol, PosNew, NxtTitle, NxtIdNo );
    end;
  finally
    list.Free;
  end;
end;     { AddSubTree }
{---------------------------------------------------------}


{----------------------------------------------------------------------------}
procedure   TMotBaseInfo.OutLineSet( ol :TOutLine );


begin              { TMotBaseInfo.OutLineSet( ol :TOutLine ); }
  ClearStrings( ol.Lines );
  ol.font.pitch := fpFixed;
  AddSubTree( ol, 0, 'STRUCTURE', 1 );
end;

procedure TMotBaseInfo.InitGrupy( const BFName :string);
var
  Tab     :TTable;
  s, s1, s2 :string;
  i       :Integer;
begin
  Tab := NIL;
  try
    Tab := TTable.Create(NIL);
    Tab.DatabaseName := GetPath;
    Tab.TableName := ExtractFileName( BFName );
    try
      Tab.Open;
      if Tab.FindField('GRUPA') = NIL then
        EXIT;
      while not Tab.Eof do
      begin
        s := Tab.FieldByName('GRUPA').AsString;
        while s <> '' do
        begin
          s := StrBehinde( '/', s );
          s1 := StrBefore( '/', s );
          i := FiltryPomp.Pozycja( s1 );
          if i >= 0 then
            FiltryPomp.Dostepny[i] := true;
        end;
        Tab.Next;
      end;
    finally
      Tab.Close;
    end;
  finally
    Tab.Free;
  end;
end;



function TMotBaseInfo.GenerSQLText(const WhereClause,
  Columns: string): string;
var
  sSQL   :TStringList;
  PrId   :string;

  function sEmpty( const s :string ) :Boolean;
  var
    i      :Integer;
  begin
    Result := true;
    i := 1;
    while (i <= Length(s)) and Result do
    begin
      Result := s[i] in [' ', #13, #10, #09];
      inc(i);
    end;
  end;

  procedure AddF( const fmt :string; const args :array of const );
  begin
    sSQL.Add(Format( fmt, args ));
  end;

  procedure AddS( const s :string );
  begin
    sSQL.Add(s);
  end;

begin
  sSQL := TStringList.Create;
  try
    AddF( 'SELECT %s', [Columns] );
    AddF( 'FROM "A_%s.DBF" A, "M_%0:s.DBF" M', [Owner.Ident] );
          //'  LEFT JOIN "H_%0:s.DBF" H'+
          //'    ON (A.H_ID = H.H_ID) ',
          // [Owner.Ident]);
    AddS( 'WHERE  A.M_ID = M.M_ID' );
    if not sEmpty(WhereClause) then
      AddF( 'AND %s', [WhereClause] );
    Result := sSQL.Text;
  finally
    sSQL.Free;
  end;
end;

function TMotBaseInfo.GenerSQLText(const WhereClause: TStrings;
  const Columns: string): string;
begin
  Result := GenerSQLText( WhereClause.Text, Columns );
end;

initialization
  RegisterBaseType( 'MOTORS', CreateMotInfo );

end.
