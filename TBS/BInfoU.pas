unit BInfoU;

interface

uses
  SysUtils, classes;

type


  IBaseInfo  = class
    public
      procedure   Init( const ATBSFName :string ); virtual; abstract;
      function    TypeId    :string;               virtual; abstract;
      function    TBSFName  :string;               virtual; abstract;
  end;

  TBICreateFunc = function :IBaseInfo;


  TBICreatorList = class (TStringList)
    procedure AddCreator( const BazId :string; CPAddr :TBICreateFunc );
    function  Member( const BazId :string ): Boolean;
    function  CreateBInfo( BazId :string ): IBaseInfo;
  end;


{=============================================================================}
implementation

type


{=============================================================================}
  TBInfoCreator = class
      constructor Create( const BazId :string; ACreateProcAddr :TBICreateFunc );

    private
      FCreateProcAddr :TBICreateFunc;
      FBaseId         :string;

    public
      function   CreateBInfo :IBaseInfo;
      property   BaseId      :string    read FBaseId;
  end;



{----------------------------------------------------------------------------}
constructor TBInfoCreator.Create( const BazId :string;
                                  ACreateProcAddr :TBICreateFunc );
begin
  FBaseId := BazId;
  FCreateProcAddr := ACreateProcAddr;
end;


{----------------------------------------------------------------------------}
function TBInfoCreator.CreateBInfo :IBaseInfo;
begin
  if @FCreateProcAddr <> NIL then
    result := FCreateProcAddr
  else
    result := NIL;
end;


{=============================================================================
| Klasa : TBICreatorList
|
|
------------------------------------------------------------------------------}

{----------------------------------------------------------------------------}
procedure TBICreatorList.AddCreator( const BazId :string;
                                     CPAddr :TBICreateFunc );
var
  bic     :TBInfoCreator;
begin
  bic     := TBInfoCreator.Create( BazId, CPAddr );
  AddObject( BazId, bic );
end;

{----------------------------------------------------------------------------}
function  TBICreatorList.Member( const BazId :string ): Boolean;
begin
  result  := (IndexOf( BazId ) >= 0);
end;


{----------------------------------------------------------------------------}
function  TBICreatorList.CreateBInfo( BazId :string ): IBaseInfo;
var
  i       :Integer;
  bic     :TBInfoCreator;
begin
  i       := IndexOf(BazId);
  if i >= 0 then
  begin
    bic     := TBInfoCreator(Objects[i]);
    if bic is TBInfoCreator then
      result := bic.CreateBInfo
    else
      result := NIL;
  end
  else
    result := NIL;
end;



end.
