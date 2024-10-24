unit PompDXF;

interface

uses
  SysUtils, DB, {PompySQL,} DXFDraws;

type

  {-----------------------------------------------------------------------}
  TPompDXFDrawing = class (TDXFDrawing)
    private
      FDB         :TDataSet;
    protected
      function   Read1Entitie( var F :TextFile;
                               const s:string;
                               var ent: TDXFItem ):Boolean; override;

    public
      procedure LoadWithBase( const FN :string; ADB :TDataSet );
      property  DB :TDataSet read FDB write FDB;
  end;


  {-----------------------------------------------------------------------}
  TPompDXFText = class (TDXFText)
    protected
      procedure  setString( code: Integer; const v: string); override;

  end;


{=============================================================================}
implementation



{-----------------------------------------------------------------------------}
procedure TPompDXFDrawing.LoadWithBase( const FN :string; ADB :TDataSet );
begin
  FDB := ADB;
  LoadFromFile( fn );
  FDB := NIL;
end;



{-----------------------------------------------------------------------------}
function   TPompDXFDrawing.Read1Entitie( var F :TextFile;
                                         const s :string;
                                         var ent: TDXFItem ):Boolean;
begin
  if (s = 'TEXT') then
  begin
    ent := TPompDXFText.Create(self);
    ent.ReadIt(F);
    result := true;
  end
  else
    result := inherited Read1Entitie( F, s, ent );
end;


{-----------------------------------------------------------------------------}
procedure  TPompDXFText.setString( code: Integer; const v: string);
var
  s        :string;
  done     :Boolean;
  fld      :TField;
  {DB       :TDBPompy;}
  Tab      :TDataSet;
begin
  done := false;
  {DB   := TPompDXFDrawing(Drawing).FDB;}
  Tab   := TPompDXFDrawing(Drawing).FDB;
  case code of
    1:
    begin
      if Assigned(Tab) and (Length(v) > 0) and (v[1] = '#') then
      begin
        s := Copy( v, 2, Length(v)-1 );
        fld := Tab.FindField(s);
        if Assigned(fld) then
        begin
          try
            Text := fld.AsString;
          except
            on Exception do Text := '';
          end;
          done := true;
        end;
      end;
    end;
  end;
  if not done then
    inherited setString( code, v );
end;


end.
