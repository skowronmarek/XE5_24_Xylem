unit PmpBaseInfoU;

interface

uses
  Classes,
  SysUtils,
  Menus,
  OutLine,
  Forms,
  IniFiles,
  Controls,
  comctrls,

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

  TPumpOLInfo = class
  public
    T          :string;
    G          :string;
    CH         :string;
    Zdj        :string;
    Filtr      :Boolean;
    Obszar     :Boolean;
    CharColor  :TColor;
    StopChldOb :Boolean;
    FldName    :string;
    Value      :Variant;
  end;


  TPumpsBaseInfo = class (TBaseInfo)                            // specyficzne info dla pomp
  private
    FObszFieldName: string;
    procedure InitGrupy( const BFName :string);
    procedure InitObszary;
  public
    procedure   Init( const fn :string );        override;
    function    TypeId    :string;               override;

  public

    procedure   OutLineSet( ol :TOutLine );      override;
    function    CanOutLineSet: Boolean;          override;
    procedure   AddSubTree( ol :TOutLine; APos: Integer; const title: string;
                            IdNo :Integer = 0);
    procedure   AddSubTreeV( TV :TTreeView; TN :TTreeNode; const ATitle: string;
                            IdNo :Integer = 0);
    property    ObszFieldName :string read FObszFieldName;
  end;


implementation

uses
  PmpListU, ObszCharMgrU,
  FiltryGlob;

function CreatePumpInfo :IBaseInfo;
begin
  result := TPumpsBaseInfo.Create;
end;

{==============================================================================
-------------------------------------------------------------------------------
|  Klasa: TPumpsBaseInfo
|
|
|
-------------------------------------------------------------------------------
}



{----------------------------------------------------------------------------}
procedure TPumpsBaseInfo.Init( const fn :string );
var
  list    :TStringList;           // Lista plikow w bazie
  i       :Integer;
  s, s1   :string;
  BFName  :string;                { BaseFileName - nazwa pliku bazy }

begin
  try
    inherited Init( fn );                    // podpina plik TBS itp
    list      := TStringList.Create;
    tbsf.ReadSection( 'FILES', list );       // czyta A, G, H ...
    with list do
    begin
      for i := 0 to Count-1 do
      begin
        s1 := Strings[i];                         // zaczyna od "A"
        s  := tbsf.ReadString( 'FILES', s1, '' ); // czyta nazwy plikow dla A, G, H ...
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
                self.Owner.IndexABase( BFName );                                      // indeksuje baze "A"
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

    InitObszary;

  finally
    list.Free;
  end;

end;

{----------------------------------------------------------------------------}
function  TPumpsBaseInfo.TypeId :string;
begin
  result := 'PUMPS';
end;

{----------------------------------------------------------------------------}
function    TPumpsBaseInfo.CanOutLineSet: Boolean;
begin
  result := true;
end;



{---------------------------------------------------------}
procedure TPumpsBaseInfo.AddSubTree( ol :TOutLine; APos :Integer; const title :string;
                                     IdNo :Integer = 0 );
var
  s, ident, coment :string;
  s1, s2, s3       :string;
  PosS      :Integer;
  i, j      :LongInt;
  PosNew    :Integer;
  list      :TStringList;
  c         :char;
  o         :TPumpOLInfo;
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
      o      := TPumpOLInfo.Create;
      o.T    := StrParseStr( s2, 'T', '' );    // Typ_Id   - identyfikator w bazie T
      o.Zdj  := StrParseStr( s2, 'ZDJ', '' );  // Zdjecie - identyfikator zdjecia w BIN
      o.G    := StrParseStr( s2, 'G', '' );
      o.CH   := StrParseStr( s2, 'CH', '' );   // char  - identyfikator charakterystyki w BIN
      o.Obszar := Boolean(StrParseInt( s2, 'OB', 0 ));
      o.StopChldOb := Boolean(StrParseInt( s2, 'STOP', 0 ));
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
procedure   TPumpsBaseInfo.OutLineSet( ol :TOutLine );


begin              { TPumpsBaseInfo.OutLineSet( ol :TOutLine ); }
  ClearStrings( ol.Lines );
  ol.font.pitch := fpFixed;
  AddSubTree( ol, 0, 'STRUCTURE', 1 );
end;

procedure TPumpsBaseInfo.InitGrupy( const BFName :string);
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



procedure TPumpsBaseInfo.AddSubTreeV(TV: TTreeView; TN: TTreeNode;
  const ATitle: string; IdNo: Integer);
var
  s, ident, coment :string;
  s1, s2, s3       :string;
  PosS      :Integer;
  i, j      :LongInt;
  PosNew    :Integer;
  list      :TStringList;
  c         :char;
  o         :TPumpOLInfo;
  NxtIdNo   :Integer;
  NxtTitle  :string;
  vTitle    :string;
  Title     :string;
  TN1       :TTreeNode;
  TNChld    :TTreeNode;
  ImIn      :Integer;
  IsRoot    :Boolean;

begin
  TN1 := NIL;
  list := TStringList.Create;
  try
    IsRoot := False;
    Title := ATitle;
    if (TN = NIL) and (title = 'STRUCTURE') then
    begin
      tbsf.ReadSection( 'STRUCT_ROOT', list );
      IsRoot := list.Count > 0;
      if IsRoot then
        Title := 'STRUCT_ROOT';
    end;

    if list.Count = 0 then
      tbsf.ReadSection( title, list );

    for i := 0 to list.Count-1 do
    begin
      vTitle := title;
      ident  := list.Strings[i];

      // odsylacz z GRUPY
      if ident[1] = '^' then
      begin
        s := StrBehinde( '<', ident );
        vTitle := StrBefore( '>', s );
        s := StrBehinde( '>', s );
        ident := StrBehinde( '.', s );
        if vTitle = 'STRUCTURE' then
          IdNo := 1;
      end;

      // wczytaj parametry
      s := tbsf.ReadString( vTitle, ident, '' );
      coment := StrBefore( '|', s );
      s2     := StrBehinde( '|', s );
      PosS   := pos( '/T=', s2 );
      o      := TPumpOLInfo.Create;
      o.T    := StrParseStr( s2, 'T', '' );    // Typ_Id   - identyfikator w bazie T
      o.Zdj  := StrParseStr( s2, 'ZDJ', '' );  // Zdjecie - identyfikator zdjecia w BIN
      o.G    := StrParseStr( s2, 'G', '' );
      o.CH   := StrParseStr( s2, 'CH', '' );   // char  - identyfikator charakterystyki w BIN
      o.Obszar := Boolean(StrParseInt( s2, 'OB', 0 ));
                  // czy na tym poziomie definiowany jest obszar
      o.StopChldOb := Boolean(StrParseInt( s2, 'STOP', 0 ));
      o.CharColor := StrParseInt( s2, 'COLOR', -1 ); // kolor charakterystyki
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
      else if ident = '_ROOT_' then
      begin
        NxtTitle := 'STRUCTURE';
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
      s1 := Trim(s1);
      o.Filtr := o.FldName <> '';

      if (IdNo > 0) and (o.FldName <> '_ROOT_') then
        NxtIdNo := IdNo+1
      else
        NxtIdNo := IdNo;
      if TN1 = NIL then
      begin
        if TN = NIL then
          TN1 := TV.Items.AddObject( NIL, s1, o )
        else
          TN1 := TV.Items.AddChildObject( TN, s1, o );
        TNChld := TN1;
      end
      else
      begin
        TNChld := TV.Items.AddObject( TN1, s1, o );
      end;
      //TNChld.ImageIndex := 27;
      //TNChld.SelectedIndex := 26;
      ImIn := 0;
      if o.FldName = '_ROOT_' then
        ImIn := GetPmpProdIconId( Owner.Ident )
      else if o.Zdj <> '' then
        ImIn := GetPmpImgIndexBId( Owner.Ident, o.Zdj )
      else if o.T <> '' then
        ImIn := GetPmpImgIndexTId( Owner.Ident, o.T );
      TNChld.ImageIndex    := ImIn;
      TNChld.SelectedIndex := ImIn;
      if TN = NIL then
      begin
        //TV.Invalidate;
        //Application.ProcessMessages;
      end
      else
        AddSubTreeV( TV, TNChld, NxtTitle, NxtIdNo );
    end;

    if TN = NIL then
    begin
      Application.ProcessMessages;
      TNChld := NIL;
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
        {
        s2     := StrBehinde( '|', s );
        PosS   := pos( '/T=', s2 );
        o      := TPumpOLInfo.Create;
        o.T    := StrParseStr( s2, 'T', '' );    // Typ_Id   - identyfikator w bazie T
        o.Zdj  := StrParseStr( s2, 'ZDJ', '' );  // Zdjecie - identyfikator zdjecia w BIN
        o.G    := StrParseStr( s2, 'G', '' );
        o.CH   := StrParseStr( s2, 'CH', '' );   // char  - identyfikator charakterystyki w BIN
        o.Obszar := Boolean(StrParseInt( s2, 'OB', 0 ));
        o.CharColor := StrParseInt( s2, 'COLOR', -1 );
        o.FldName := StrParseStr( s2, 'FLDNAME', '' );
        }

        if (vTitle = 'STRUCTURE') or (vTitle = 'GRUPY') then
          c := ':'
        else
          c := '\';

        if ident[1] = '\' then
        begin
          ident := StrButFirst( ident, 1 );
          NxtTitle := ident;
        end
        else if ident = '_ROOT_' then
        begin
          NxtTitle := 'STRUCTURE';
        end
        else
        begin
          NxtTitle := Format( '%s%s%s', [vTitle, c, ident] );
        end;
        ident := StrParseStr( s2, 'VALUE', ident );

        if IsPrefix( 'STRUCTURE', vTitle ) then
        begin
          s1     := Format( '%-8s %s', [ident, coment] );
        end
        else
        begin
          s1 := coment;
        end;
        s1 := Trim(s1);

        if (IdNo > 0) and (o.FldName <> '_ROOT_') then
          NxtIdNo := IdNo+1
        else
          NxtIdNo := IdNo;
        if TNChld = NIL then
        begin
          TNChld := TV.Items[0];
        end
        else
        begin
          TNChld := TNChld.getNextSibling;
          //TV.Items.AddObject( TN1, s1, o );
        end;
        AddSubTreeV( TV, TNChld, NxtTitle, NxtIdNo );
        //TV.Invalidate;
        //Application.ProcessMessages;
      end;
    end;
  finally
    list.Free;
  end;
end;

procedure TPumpsBaseInfo.InitObszary;
var
  SL      :TStringList;
  i       :Integer;
  s, id   :string;
  cl      :TColor;
begin
  SL := TStringList.Create;
  try
    tbsf.ReadSection( 'OBSZARY', SL );
    for i := 0 to SL.Count-1 do
    begin
      id := SL[i];
      s := tbsf.ReadString('OBSZARY', id, '');
      if CompareText(id, 'Field') = 0 then
        FObszFieldName := s
      else
      begin
        cl := StrParseInt( s, 'COLOR', clBlack );
        RegisterObszar( Owner.Ident, id, cl );
      end;
    end;
  finally
    SL.Free;
  end;
end;


initialization
  RegisterBaseType( 'PUMPS', CreatePumpInfo );

end.
