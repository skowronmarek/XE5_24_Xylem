unit MemDataSetU;

{$ifndef VER100} // C++ Builder 3
{$ObjExportAll On}
{$ASSERTIONS ON}
{$endif}

interface

uses
  SysUtils,Classes,Db;

type
  EMemTableError = class(Exception);

  TRecInfo=record
    Bookmark: longint;
    RecordNo: integer;
    BookmarkFlag: TBookmarkFlag;
  end;
  PRecInfo=^TRecInfo;

{
Internal buffer layout:
+------------------------+------------------------+---------------------------+
|     RECORD DATA        |    Rec.Information     |     Calculated Fields     |
| Record length bytes    |  SizeOf(TRecInfo) bytes|    CalcFieldSize bytes    |
+------------------------+------------------------+---------------------------+
                         ^                        ^
                    StartRecInfo              StartCalculated

Blobsfields in the internal buffer are pointers to the blob data.
}

  TMemDataSetSaveFlag = (mtfSaveData, mtfSaveCalculated, mtfSaveLookup,mtfSaveNonVisible);
  TMemDataSetSaveFlags = set of TMemDataSetSaveFlag;


  TReadKindField = ( rkfUnk, rkfString, rkfInt, rkfFloat,
                     rkfDate, rkfTime, rkfDateTime, rkfBLOB, rkfBCD);

  TReadFieldInfo = record
    Name :string;
    ReadKind :TReadKindField;
  end;
  TReadFieldInfoArray = array of TReadFieldInfo;

  PkbmBlob=^TkbmBlob;
  TkbmBlob = class
  private
    FLength:cardinal;
    FBuffer:PChar;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromStream(stream:TMemoryStream);
    procedure SaveToStream(stream:TMemoryStream);
    property Length:cardinal read FLength write FLength;
    property Buffer:Pchar read FBuffer write FBuffer;
  end;

  TMemDataSet = class(TDataSet)
  private
    FIsOpen                                :Boolean;
    FRecNo                                 :integer;
    FFilterBuffer                          :PChar;
    FRecords                               :TList;
    FBufferSize                            :integer;
    FStartRecInfo                          :integer;
    FStartCalculated                       :integer;
    FRecordSize                            :integer;
    FFieldOfs                              :array [0..255] of integer;
    FFieldSize                             :array [0..255] of integer;
    FReadOnly                              :boolean;
    FPersistent                            :boolean;
    FPersistentFile                        :string;
    FBlobs                                 :boolean;
    FIndexList                             :TList;
    FCaseInsensitiveSort                   :boolean;
    FDescendingSort                        :boolean;
    FDummyStr                              :string;
    FIndexFieldNames                       :string;
    FSaveFieldDefs                         :Boolean;
    FSaveData                              :Boolean;
    FPersistData                           :TMemoryStream;
    function GetActiveRecordBuffer         :PChar;
    function FilterRecord(Buffer: PChar)   :Boolean;
    procedure _InternalAdd(Buffer:Pointer);
    procedure _InternalDelete(Pos:integer);
    procedure _InternalInsert(Pos:integer; Buffer:Pointer);
    procedure _InternalEmpty;
    procedure _InternalFirst;
    procedure _InternalLast;
    function  _InternalNext:boolean;
    function  _InternalPrior:boolean;
    procedure _InternalFreeRecord(RecPtr:Pointer);
    function _InternalMoveRecord(Source, Destination: Integer): Boolean;

    procedure BuildFieldList(List:TList; const FieldNames: string);
    procedure QuickSort(L, R: Integer);
    function  CompareRecords(FieldList:TList; Record1,Record2:PChar): Integer;
  protected
    procedure DefineProperties(Filer: TFiler); override;

    procedure ReadFieldDefs(Reader: TReader);
    procedure WriteFieldDefs(Writer: TWriter);
    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);

    procedure WriteHeader( const fset :array of Boolean;
                           Stream :TStream);
    procedure WriteRecord( const fset :array of Boolean;
                           Stream :TStream);
    procedure WriteRecState(Stream: TStream);
    procedure WriteField( Fld :TField; Stream :TStream );

    procedure ReadHeader( var fset :TReadFieldInfoArray;
                           Stream :TStream);
    procedure ReadRecord( const fset :TReadFieldInfoArray;
                           Stream :TStream);
    procedure ReadRecState(Stream: TStream);
    procedure ReadField( Fld :TField; rkf :TReadKindField; Stream :TStream );


    procedure InternalOpen; override;
    procedure InternalClose; override;
    procedure InternalFirst;override;
    procedure InternalLast;override;

    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalDelete; override;
    procedure InternalInitRecord(Buffer: PChar);
    // MS 2024.05.31 procedure InternalInitRecord(Buffer: PChar); override;
    procedure InternalPost; override;

    procedure InternalInitFieldDefs; override;
    procedure InternalSetToRecord(Buffer: PChar);
    // MS 2024.05.31  procedure InternalSetToRecord(Buffer: PChar); override;

    procedure DoBeforeClose; override;
    procedure DoAfterOpen; override;

    function IsCursorOpen: Boolean; override;
    function GetCanModify: Boolean; override;
    function GetRecordSize: Word;override;
    function GetRecordCount: integer;override;

    function AllocRecordBuffer: PChar;
    // MS 2024.05.31 function AllocRecordBuffer: PChar; override;

    procedure FreeRecordBuffer(var Buffer: PChar);
    // MS 2024.05.31 procedure FreeRecordBuffer(var Buffer: PChar); override;

    function CalcFieldSize(FieldType:TFieldType; Size:longint):longint;
    function GetFieldPointer(Buffer:PChar; Field:TField):PChar;

    procedure SetFieldData(Field: TField; Buffer: Pointer);override;
{$IFNDEF VER125}  // C++ Builder 4
 {$IFNDEF VER120} // Delphi 4
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
 {$ENDIF}
{$ENDIF}
    function GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
    // MS 2024.05.31 function GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function FindRecord(Restart, GoForward: Boolean): Boolean; override;

    function GetRecNo: integer;override;
    procedure SetRecNo(Value: integer);override;

    function GetIsIndexField(Field: TField): Boolean; override;

    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
    // MS 2024.05.31 function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
    // MS 2024.05.31 procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer);
    // MS 2024.05.31 procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer);
    // MS 2024.05.31 procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;

{$IFNDEF VER150}
    function BCDToCurr(BCD: Pointer; var Curr: Currency): Boolean;
    // MS 2024.05.31 function BCDToCurr(BCD: Pointer; var Curr: Currency): Boolean; override;
    function CurrToBCD(const Curr: Currency; BCD: Pointer; Precision, Decimals: Integer): Boolean;
    // MS 2024.05.31 function CurrToBCD(const Curr: Currency; BCD: Pointer; Precision, Decimals: Integer): Boolean; override;
{$ENDIF}

    procedure InternalHandleException; override;

    procedure SetCommaText(AString: String);
    function GetCommaText: String;

    function MoveCurRec(Destination:Longint):Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
{$IFDEF VER125} // C++ Builder 4
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
{$ENDIF}
{$IFDEF VER120} // Delphi 4
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
{$ENDIF}
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;

    procedure CreateTable;
    procedure CreateTableAs(Source:TDataSet);
    procedure DeleteTable;

    function  CopyRecords(Source,Destination:TDataSet; Count:longint):longint;
    procedure CopyRecord(Source,Destination:TDataSet);
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string; flags:TMemDataSetSaveFlags);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream; flags:TMemDataSetSaveFlags);
    procedure LoadDataFromStream(Stream: TStream);
    procedure SaveDataToStream(Stream: TStream);
    procedure LoadFromDataSet(Source:TDataSet);
    procedure SaveToDataSet(Destination:TDataSet);
    procedure EmptyTable;
    property CommaText:string read GetCommaText write SetCommaText;
    procedure Sort;
    function IsSequenced:Boolean; override;

    property IndexFields:string read FIndexFieldNames write FIndexFieldNames;
    property CaseInsensitiveSort:boolean read FCaseInsensitiveSort write FCaseInsensitiveSort;
    property DescendingSort:boolean read FDescendingSort write FDescendingSort;
  published
    property Active;
    property Filtered;
    property ReadOnly:boolean read FReadOnly write FReadOnly default false;
    property PersistentFile:string read FPersistentFile write FPersistentFile;
    property Persistent:boolean read FPersistent write FPersistent default false;
    property Filter:string read FDummyStr;
    property SaveFieldDefs :Boolean read FSaveFieldDefs write fSaveFieldDefs;
    property SaveData :Boolean read FSaveData write FSaveData;

    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

  TkbmBlobStream = class(TMemoryStream)
  private
    FField: TBlobField;
    FDataSet: TMemDataSet;
    FMode:TBlobStreamMode;
    FPBlob: PkbmBlob;
    FFieldNo: Integer;
    FModified: Boolean;
    procedure ReadBlobData;
    procedure WriteBlobData;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure Truncate;
  end;

implementation

uses
  TypInfo, {Dialogs, Windows, Forms, Controls, }IniFiles;

const
  TkbmSupportedFieldTypes=[ftString,ftSmallint,ftInteger,ftWord,ftBoolean,ftFloat,ftCurrency,
                          ftDate,ftTime,ftDateTime,ftAutoInc,ftBCD,ftBlob,ftMemo,ftGraphic,ftFmtMemo,
                          ftParadoxOle,ftDBaseOle,ftTypedBinary];
  TkbmBlobTypes=[ftBlob,ftMemo,ftGraphic,ftFmtMemo,ftParadoxOle,ftDBaseOle,ftTypedBinary];


procedure WriteStr( const s :string; strm :TStream );
var
  l      :Longint;
begin
  l := Length(s);
  strm.Write(l,SizeOf(l));
  strm.Write(s[1], l);
end;

function ReadStr( strm :TStream ) :string;
var
  l      :Longint;
begin
  strm.Read( l, SizeOf(l));
  SetLength(result, l);
  strm.Read( result[1], l );
end;

const
  ftarr :array [TFieldType] of string =
                       ('ftUnknown',
                        'ftString',
                        'ftSmallint',
                        'ftInteger',
                        'ftWord',
                        'ftBoolean',
                        'ftFloat',
                        'ftCurrency',
                        'ftBCD',
                        'ftDate',
                        'ftTime',
                        'ftDateTime',
                        'ftBytes',
                        'ftVarBytes',
                        'ftAutoInc',
                        'ftBlob',
                        'ftMemo',
                        'ftGraphic',
                        'ftFmtMemo',
                        'ftParadoxOle',
                        'ftDBaseOle',
                        'ftTypedBinary',
                        'ftCursor',
                        'ftFixedChar',
                        'ftWideString',
                        'ftLargeint',
                        'ftADT',
                        'ftArray',
                        'ftReference',
                        'ftDataSet',
                        'ftOraBlob',
                        'ftOraClob',
                        'ftVariant',
                        'ftInterface',
                        'ftIDispatch',
                        'ftGuid',
                        'ftTimeStamp',
                        'ftFMTBcd',
                        'ftFixedWideChar',
                      'ftWideMemo',
                      'ftOraTimeStamp',
                      'ftOraInterval',
                      'ftLongWord',
                      'ftShortint',
                      'ftByte',
                      'ftExtended',
                      'ftConnection',
                      'ftParams',
                      'ftStream',
                      'ftTimeStampOffset',
                      'ftObject',
                      'ftSingle'
                        );
                           //MA 2024.05.31 Dodane stale
function FieldType2S( const ft :TFieldType) :string;
begin
  result := ftarr[ft];
end;

function S2FieldType( const Id :string ) :TFieldType;
var
  i      :TFieldType;
begin
  result := ftUnknown;
  for i := low(result) to high(result) do
  begin
    if id = ftarr[i] then
    begin
      result := i;
      break;
    end;
  end;
end;


// Compare two fields.
function CompareFields(p1,p2:pointer; FieldType: TFieldType; CaseInsensitive: Boolean):Integer;
begin
     Result := 0;
     case FieldType of
       ftString:
          if CaseInsensitive then
             Result:=AnsiCompareText(PChar(p1), PChar(p2))
          else
              Result:=AnsiCompareStr(PChar(p1), PChar(p2));

       ftSmallint:
          Result:=SmallInt(p1^)-SmallInt(p2^);

       ftInteger,
       ftDate,
       ftTime,
       ftAutoInc:
          Result:=Longint(p1^)-Longint(p2^);

       ftWord:
          Result:=Word(p1^)-Word(p2^);

       ftBoolean:
          if WordBool(p1^)>WordBool(p2^) then Result:=1
          else if WordBool(p1^)<WordBool(p2^) then Result:=-1;

       ftFloat,
       ftCurrency:
          if Double(p1^)>Double(p2^) then Result:=1
          else if Double(p1^)<Double(p2^) then Result:=-1;

       ftDateTime:
          if TDateTime(p1^)>TDateTime(p2^) then Result:=1
          else if TDateTime(p1^)<TDateTime(p2^) then Result:=-1;
     end;
end;

// Compare two records.
function TMemDataSet.CompareRecords(FieldList:TList; Record1,Record2:PChar): Integer;
var
   p1,p2:PChar;
   fld:TField;
   i:integer;
begin
     Result:=0;

     // Loop through all indexfields, left to right.
     for i:=0 to FieldList.Count-1 do
     begin
          fld:=TField(FieldList[i]);

          // Get data for specified field for the two records.
          p1:=GetFieldPointer(Record1,fld);
          p2:=GetFieldPointer(Record2,fld);

          // Check if both not null.
          if Boolean(p1[0]) and Boolean(p2[0]) then
          begin
               // Skip null flag.
               inc(p1);
               inc(p2);

               // Compare the fields.
               Result:=CompareFields(p1,p2,fld.DataType,FCaseInsensitiveSort);
          end
          else if Boolean(p1[0]) then Result:=1
          else if Boolean(p2[0]) then Result:=-1;
          if Result<>0 then break;
     end;

     // Couldnt sort them according to fieldcontents, will now sort according to recnum.
     if Result=0 then
        Result:=PRecInfo(Record1+FStartRecInfo)^.RecordNo - PRecInfo(Record2+FStartRecInfo)^.RecordNo;

     // If descending sort, invert result.
     if FDescendingSort then Result:=-Result;
end;

constructor TMemDataSet.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FRecords:=TList.Create;
     FPersistent:=false;
     FIndexList:=TList.Create
end;

destructor TMemDataSet.Destroy;
begin
     _InternalEmpty;
     inherited Destroy;

     // Delete allocated records.
     FIndexList.free;
     FIndexList:=nil;
     FRecords.free;
     FRecords:=nil;
end;

function TMemDataSet.CalcFieldSize(FieldType:TFieldType; Size:longint):longint;
begin
  case FieldType of
    ftString:             Result := Size+1;
    ftSmallInt:           Result := SizeOf(SmallInt);
    ftInteger:            Result := SizeOf(Integer);
    ftWord:               Result := SizeOf(Word);
    ftBoolean:            Result := SizeOf(WordBool);
    ftFloat:              Result := SizeOf(Double);
    ftCurrency:           Result := SizeOf(Double);
    ftDate:               Result := SizeOf(Integer);
    ftTime:               Result := SizeOf(Integer);
    ftDateTime:           Result := SizeOf(Double);
    ftAutoInc:            Result := SizeOf(Integer);
    ftBlob:               Result := SizeOf(PkbmBlob);
    ftMemo:               Result := SizeOf(PkbmBlob);
    ftGraphic:            Result := SizeOf(PkbmBlob);
    ftFmtMemo:            Result := SizeOf(PkbmBlob);
    ftParadoxOle:         Result := SizeOf(PkbmBlob);
    ftDBaseOle:           Result := SizeOf(PkbmBlob);
    ftTypedBinary:        Result := SizeOf(PkbmBlob);
    ftBCD:                Result := 34;
  else
    Result:=0;
  end;
end;

function TMemDataSet.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TkbmBlobStream.Create(Field as TBlobField, Mode);
end;

procedure TMemDataSet.CreateTable;
var
  i:Integer;
begin
  CheckInactive;

  // If no fielddefs existing, use the previously defined fields.
  if FieldDefs.Count = 0 then
    for i:=0 to FieldCount-1 do
      with Fields[i] do
        if FieldKind = fkData then
          FieldDefs.Add(FieldName, DataType, Size, Required);

  // Remove previously defined fields and create new from fielddefs.
  DestroyFields;
  CreateFields;
end;

// Create memory table as another dataset.
procedure TMemDataSet.CreateTableAs(Source:TDataSet);
var
  i:integer;
begin
  CheckInactive;

  if Source = nil then
    EXIT;

  // Add fields as they are defined in the other dataset.
  Source.FieldDefs.Update;
  FieldDefs.Assign(Source.FieldDefs);

  // Remove non supported fieldsdefs.
  for i:=FieldDefs.Count-1 downto 0 do
    if not (FieldDefs.Items[i].DataType in TkbmSupportedFieldTypes) then
      FieldDefs.Items[i].free;

  // Create fields from fielddefs.
  DestroyFields;
  CreateFields;
end;

// Delete table.
procedure TMemDataSet.DeleteTable;
begin
  CheckInactive;
  DestroyFields;
end;

procedure TMemDataSet._InternalAdd(Buffer:Pointer);
begin
  FRecords.Add(Buffer);
end;

procedure TMemDataSet._InternalInsert(Pos:integer; Buffer:Pointer);
var
  i:integer;
  b:PChar;
begin
  if Pos<0 then
    Pos:=0;
  if (Pos = FRecords.Count) or(Pos = -1) then
    FRecords.Add(Buffer)
  else
    FRecords.Insert(Pos,Buffer);

  for i:=Pos+1 to FRecords.Count-1 do
  begin
    b:=FRecords.Items[i];
    inc(PRecInfo(b+FStartRecInfo).RecordNo);
  end;
end;

procedure TMemDataSet._InternalFreeRecord(RecPtr:Pointer);
var
  i:integer;
  pblob:PkbmBlob;
begin
  if FBlobs and (not IsEmpty) then
  begin
    // Browse fields to delete blobs.
    for i:=0 to FieldCount-1 do
    begin
      if Fields[i].DataType in TkbmBlobTypes then
      begin
        pBlob := PkbmBlob(GetFieldPointer(RecPtr,Fields[i]));
        if pBlob^<>nil then
        begin
          pBlob^.free;
          pBlob^:=nil;
        end;
      end;
    end;
  end;
  FreeMem(RecPtr);
end;

procedure TMemDataSet._InternalDelete(Pos:integer);
var
  i:integer;
  b:PChar;
begin
  _InternalFreeRecord(FRecords.Items[Pos]);
  FRecords.Delete(Pos);

  for i:=Pos to FRecords.Count-1 do
  begin
    b:=FRecords.Items[i];
    dec(PRecInfo(b+FStartRecInfo)^.RecordNo);
  end;
end;

// Purge all records.
procedure TMemDataSet._InternalEmpty;
var
  i:integer;
begin
  for i:=0 to FRecords.Count-1 do _InternalFreeRecord(FRecords[i]);
  FRecords.Clear;
end;

procedure TMemDataSet.InternalOpen;
var
   i  : integer;
   sz : integer;
begin
  if FieldDefs.Count = 0 then
    InternalInitFieldDefs
  else
  begin
    DestroyFields;
    CreateFields;
  end;

  // Calculate field offsets into the record.
  FRecordSize := 0;
  FBlobs      := false;             // Know of no blobs in the definition yet.
  for i:=0 to FieldDefs.Count - 1 do
    with FieldDefs[i] do
    begin
      FFieldOfs[i]:=FRecordSize;

      // Check if a blob.
      if (not FBlobs) and (DataType in TkbmBlobTypes) then
        FBlobs:=true;

      // Look for fieldsize.
      sz:=CalcFieldSize(DataType,Size);
      FFieldSize[i] := sz;
      inc(sz);   // 1.st byte is boolean flag for Null or not.
      inc(FRecordSize,sz);
    end;

  BindFields(True);
  FRecNo := -1;
  BookmarkSize := sizeof(longint);
  FStartRecInfo := FRecordSize;
  FStartCalculated := FStartRecInfo+SizeOf(TRecInfo);
  FBufferSize := FRecordSize+Sizeof(TRecInfo)+CalcFieldsSize;
  FIsOpen := True;
end;

procedure TMemDataSet.InternalClose;
begin
  _InternalEmpty;
  FIsOpen:=False;
  BindFields(False);
end;

procedure TMemDataSet.InternalInitFieldDefs;
var
  i:integer;
begin
  if FieldCount > 0 then
  begin
    FieldDefs.clear;
    for i:=0 to Fieldcount-1 do
    begin
      FieldDefs.Add(Fields[i].FieldName,Fields[i].DataType,Fields[i].Size,Fields[i].Required);
    end;
  end;
end;

function TMemDataSet.GetActiveRecordBuffer:  PChar;
begin
     case State of
          dsBrowse:        if IsEmpty then
                              Result := nil
                           else
                              Result := PChar(ActiveBuffer);
                              // MS 2024.05.31 Result := ActiveBuffer;
          dsCalcFields:    Result := PChar(CalcBuffer);
                           // MS 2024.05.31 Result := CalcBuffer;
          dsFilter:        Result:=FFilterBuffer;
          dsEdit,dsInsert: Result:= PChar(ActiveBuffer);
                           // MS 2024.05.31 Result:=ActiveBuffer;
     else
          Result:=nil;
     end;
end;

function TMemDataSet.GetFieldPointer(Buffer:PChar; Field:TField):PChar;
begin
     Result:=Buffer;
     if Buffer=nil then exit;
     if (Field.FieldKind=fkCalculated) or (Field.FieldKind=fkLookup) then
        inc(Result,FStartCalculated+Field.Offset)
     else
        inc(Result,FFieldOfs[Field.FieldNo-1]);
end;

// Result is data in the buffer and a boolean return (true=not null, false=is null).
function TMemDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  SourceBuffer: PChar;
begin
  Result:=False;
  if not FIsOpen then exit;
  SourceBuffer:=GetFieldPointer(GetActiveRecordBuffer,Field);
  if SourceBuffer=nil then
    EXIT;

  if Assigned(Buffer) and (Field.DataType in TkbmSupportedFieldTypes) then
    Move(SourceBuffer[1], Buffer^, CalcFieldSize(Field.DataType,Field.DataSize));

  Result:=boolean(SourceBuffer[0]);
end;

procedure TMemDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
  DestinationBuffer: PChar;
begin
  if not FIsOpen then
    exit;
  DestinationBuffer := GetFieldPointer(GetActiveRecordBuffer,Field);
  if DestinationBuffer=nil then
    Exit;

  // MS 2024.06.01 Boolean(DestinationBuffer[0]):= (Buffer<>nil) ;
  DestinationBuffer[0] := Char(Buffer<>nil) ;

  if Assigned(Buffer) and (Field.DataType in TkbmSupportedFieldTypes) then
    Move(Buffer^,DestinationBuffer[1],CalcFieldSize(Field.DataType,Field.DataSize));

  DataEvent (deFieldChange, Longint(Field));
end;

{$IFNDEF VER150}
function TMemDataSet.BCDToCurr(BCD: Pointer; var Curr: Currency): Boolean;
begin
     Move(BCD^, Curr, SizeOf(Currency));
     Result := True;
end;

function TMemDataSet.CurrToBCD(const Curr: Currency; BCD: Pointer; Precision, Decimals: Integer): Boolean;
begin
  Move(Curr, BCD^, SizeOf(Currency));
  Result := True;
end;
{$ENDIF}

function TMemDataSet.IsCursorOpen: Boolean;
begin
  Result:=FIsOpen;
end;

function TMemDataSet.GetCanModify: Boolean;
begin
  Result:=not FReadOnly;
end;

function TMemDataSet.GetRecordSize: Word;
begin
  Result:=FRecordSize;
end;

function TMemDataSet.AllocRecordBuffer: PChar;
begin
  GetMem(Result,FBufferSize);
  FillChar(Result^,FBufferSize,0);
end;

procedure TMemDataSet.FreeRecordBuffer(var Buffer: PChar);
begin
  FreeMem(Buffer);
end;

procedure TMemDataSet.InternalFirst;
begin
  _InternalFirst;
end;

procedure TMemDataSet.InternalLast;
begin
  _InternalLast;
end;

procedure TMemDataSet._InternalFirst;
begin
  FRecNo:=-1;
end;

procedure TMemDataSet._InternalLast;
begin
  FRecNo:=FRecords.Count;
end;

function TMemDataSet._InternalNext:boolean;
begin
  if FrecNo<FRecords.Count-1 then
  begin
    Inc(FRecNo);
    Result:=true;
  end
  else
    Result:=false;
end;

function TMemDataSet._InternalPrior:boolean;
begin
  if FrecNo>0 then
  begin
    Dec(FRecNo);
    Result:=true;
  end
    else Result:=false;
end;

function TMemDataSet.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  Acceptable: Boolean;
begin
  Result:=grOK;
  Acceptable:=False;
  repeat
    begin
      case GetMode of
        gmCurrent:
        begin
          if FRecNo>=FRecords.Count then
            Result := grEOF
          else if FRecNo<0 then
            Result := grBOF
          else
            Result := grOk;
        end;

        gmNext:
          begin
            if _InternalNext then
              Result:=grOK
            else
              Result:=grEOF;
          end;

        gmPrior:
          begin
            if _InternalPrior then
              Result:=grOK
            else
              Result:=grBOF;
          end;
      end;

      if Result=grOk then
      begin
        //fill TARrecord part of buffer
        Move(FRecords.Items[FRecNo]^,Buffer^,FBufferSize);

        //fill information part of buffer
        with PRecInfo(Buffer+FStartRecInfo)^ do
        begin
          RecordNo:=FRecNo;
          BookmarkFlag:=bfCurrent;
          Bookmark := FRecNo;        //KR
        end;

        //fill calc fields part of buffer
        ClearCalcFields(PByte(Buffer));
        // MS 2024.06.01 ClearCalcFields(Buffer);
        GetCalcFields(PByte(Buffer));
        // MS 2024.06.01 GetCalcFields(Buffer);
        Acceptable:=FilterRecord(Buffer);
        if (GetMode=gmCurrent) and not Acceptable then
          Result:=grError;
      end
    end;

  until (Result<>grOk) or Acceptable;
end;

function TMemDataSet.FindRecord(Restart, GoForward: Boolean): Boolean;
var
   Status:boolean;
begin
     CheckBrowseMode;
     DoBeforeScroll;
     SetFound(False);
     UpdateCursorPos;
     CursorPosChanged;

     if GoForward then
     begin
          if Restart then _InternalFirst;
          Status := _InternalNext;
     end else
     begin
          if Restart then _InternalLast;
          Status := _InternalPrior;
     end;

     if Status then
     begin
          Resync([rmExact, rmCenter]);
          SetFound(True);
     end;
     Result := Found;
     if Result then DoAfterScroll;
end;

function TMemDataSet.FilterRecord(Buffer: PChar): Boolean;
var
  SaveState: TDatasetState;
begin
  Result:=True;
  if not Filtered or not Assigned(OnFilterRecord) then Exit;
  SaveState:=SetTempState(dsFilter);
  FFilterBuffer:=Buffer;
  OnFilterRecord(self,Result);
  RestoreState(SaveState);
end;

procedure TMemDataSet.InternalSetToRecord(Buffer: PChar);
begin
  FRecNo:=PRecInfo(Buffer+FStartRecInfo).RecordNo;
end;

function TMemDataSet.GetRecordCount: integer;
var
   SaveState: TDataSetState;
   SavePosition: integer;
   TempBuffer: PChar;
begin
     if not Filtered then Result:=FRecords.Count
     else
     begin
          Result:=0;
          SaveState:=SetTempState(dsBrowse);
          SavePosition:=FRecNo;
          try
             TempBuffer:=AllocRecordBuffer;
             InternalFirst;
             while GetRecord(TempBuffer,gmNext,True)=grOk do Inc(Result);
          finally
             RestoreState(SaveState);
             FRecNo:=SavePosition;
             FreeRecordBuffer(TempBuffer);
          end;
     end;
end;

function TMemDataSet.GetRecNo: integer;
var
   SaveState: TDataSetState;
   SavePosition: integer;
   TempBuffer: PChar;
begin
     if not Filtered then Result:=FRecNo
     else
     begin
          Result:=0;
          SaveState:=SetTempState(dsBrowse);
          SavePosition:=FRecNo;
          try
             TempBuffer:=AllocRecordBuffer;
             InternalFirst;
             while PRecInfo(TempBuffer+FStartRecInfo).RecordNo<>SavePosition do
               if GetRecord(TempBuffer,gmNext,True)=grOk then Inc(Result);
          finally
             RestoreState(SaveState);
             FRecNo:=SavePosition;
             FreeRecordBuffer(TempBuffer);
          end;
     end;
end;

procedure TMemDataSet.SetRecNo(Value: Integer);
var
   SaveState: TDataSetState;
   SavePosition: integer;
   TempBuffer: PChar;
begin
     if not Filtered then FRecNo:=Value
     else
     begin
          SaveState:=SetTempState(dsBrowse);
          SavePosition:=FRecNo;
          try
             TempBuffer:=AllocRecordBuffer;
             InternalFirst;
             repeat
                   begin
                        if GetRecord(TempBuffer,gmNext,True)=grOk then Dec(Value)
                        else
                        begin
                             FRecNo:=SavePosition;
                             break;
                        end;
                   end;
             until Value=0;
          finally
             RestoreState(SaveState);
             FreeRecordBuffer(TempBuffer);
          end;
     end;

     // refresh the position of the dataset
     Resync([rmCenter,rmExact]);
end;

procedure TMemDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
var
   b:Pointer;
begin
     // Allocate room for buffer in list.
     GetMem(b,FBufferSize);
     Move(Buffer^, b^, FBufferSize);
     if Append then
        _InternalAdd(b)
     else
         _InternalInsert(FRecNo,b);
end;

procedure TMemDataSet.InternalDelete;
begin
     _InternalDelete(FRecNo);
end;

procedure TMemDataSet.InternalInitRecord(Buffer: PChar);
begin
     FillChar(Buffer^,FBufferSize,0);
     PRecInfo(Buffer+FStartRecInfo)^.RecordNo:=FRecNo;
end;

procedure TMemDataSet.InternalPost;
var
   a:TRecBuf;  //WS
   b:pointer;
   n:integer;
begin
     n:=PRecInfo(ActiveBuffer+FStartRecInfo)^.RecordNo;
     if State = dsEdit then
     begin
        a := (ActiveBuffer); //WS
        Move(a, FRecords.Items[n]^ , FBufferSize)
        //MS 2024.06.01 Move(ActiveBuffer^, FRecords.Items[n]^, FBufferSize)
     end
     else
     begin
          GetMem(b,FBufferSize);
          a := (ActiveBuffer);  //WS
          Move(a, b^, FBufferSize);
          // 2024.06.01 Move(ActiveBuffer^, b^, FBufferSize);
          if GetBookmarkFlag(b) = bfEOF then
             _InternalAdd(b)
          else
             _InternalInsert(n,b);
     end;
end;

procedure TMemDataSet.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
     PRecInfo(Buffer + FStartRecInfo).BookmarkFlag := Value;
end;

function TMemDataSet.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
     Result:=PRecInfo(Buffer+FStartRecInfo).BookmarkFlag;
end;

procedure TMemDataSet.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
     PInteger(Data)^ := PRecInfo(Buffer + FStartRecInfo).Bookmark;
end;

procedure TMemDataSet.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
     PRecInfo(Buffer + FStartRecInfo).Bookmark := PInteger(Data)^;
end;

procedure TMemDataSet.InternalGotoBookmark (Bookmark: Pointer);
var
  ReqBookmark: Integer;
begin
     ReqBookmark := PInteger (Bookmark)^;
     if (ReqBookmark >= 0) and (ReqBookmark < RecordCount) then
        FRecNo := ReqBookmark
     else
        raise eMemTableError.Create('Bookmark ' + IntToStr(ReqBookmark) + ' not found');
end;

procedure TMemDataSet.InternalHandleException;
begin
     //Application.HandleException(Self);
end;

procedure TMemDataSet.SaveToFile(const FileName: string; flags:TMemDataSetSaveFlags);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream,flags);
  finally
    Stream.Free;
  end;
end;

procedure TMemDataSet.SaveDataToStream(Stream: TStream);
var
  i       :integer;
  bm      :TBookmark;
  nf      :integer;
  s,a     :string;
  l       :integer;
  fset    :array of Boolean;
  Ods,Oms :char;
  p       :Pointer;
begin
  bm:=GetBookmark;
  fset:=nil;
  try
    DisableControls;

    // Setup flags for fields to save.
    nf:=Fieldcount;
    SetLength(fset, nf );
    for i:=0 to nf-1 do
    begin
      fset[i]:=false;
      if (Fields[i] is TBlobField)
         or (not (Fields[i].DataType in TkbmBlobTypes)) then
        case Fields[i].FieldKind of
          fkData:
            fset[i]:=true;
          {
          fkCalculated:
            fset[i]:=false;
          fkLookup:
            fset[i]:=false;
          else
            fset[i]:=false;
          }
        end;
    end;

    WriteHeader( fset, Stream );

    first;
    while not EOF do
    begin
      // Write current record.
      //f:=fset;
      WriteRecord( fset, Stream );
      // Next record.
      next;
    end;
  finally
    GotoBookmark(bm);
    EnableControls;
    FreeBookmark(bm);
    //if fset<>nil then FreeMem(fset);
  end;
end;

procedure TMemDataSet.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TMemDataSet.LoadDataFromStream(Stream: TStream);
const
  BUFSIZE=8192;
var
  i:integer;
  bm:TBookmark;
  nf:integer;
  s:string;
  buf,bufptr:PChar;
  remaining_in_buf:integer;
  Line:string;
  lptr,elptr:PChar;
  null:boolean;

  fset :TReadFieldInfoArray;

begin
  // Setup standard layout for data.

  if Active then
  begin
    bm:=GetBookmark;

    try
      DisableControls;

      ReadHeader( fset, Stream );

      // Read all lines in CSV format.
      while (Stream.Position < Stream.Size) do
      begin
        append;
        ReadRecord( fset, Stream );
        post;
      end;
    finally
      GotoBookmark(bm);
      EnableControls;
      FreeBookmark(bm);
    end;
  end;
end;

procedure TMemDataSet.EmptyTable;
begin
  _InternalEmpty;
end;

procedure TMemDataSet.SetCommaText(AString: String);
var
  stream :TMemoryStream;
begin
  EmptyTable;
  stream:=TMemoryStream.Create;
  try
    stream.Write(Pointer(AString)^,length(AString));
    stream.Seek(0,soFromBeginning);
    LoadFromStream(stream);
  finally
    stream.free;
  end;
end;

function TMemDataSet.GetCommaText: String;
var
   stream:TMemoryStream;
   sz:integer;
   p:PChar;
begin
     Result:='';
     stream:=TMemoryStream.Create;
     try
        SaveToStream(stream,[mtfSaveData]);
        stream.Seek(0,soFromBeginning);
        sz:=stream.Size;
        p:=stream.Memory;
        setstring(Result,p,sz);
     finally
        stream.free;
     end;
end;

// Sneak in before the table is closed.
procedure TMemDataSet.DoBeforeClose;
begin
  inherited;

  // If persistent, save info to file.
  if FPersistent and (FPersistentFile <> '') then
  begin
    try
      SysUtils.DeleteFile(FPersistentFile);
    finally
      SaveToFile(FPersistentFile,[mtfSaveData,mtfSaveNonVisible]);
    end;
  end
  else if SaveData then
  begin
    if FPersistData <> NIL then
      FPersistData.Clear
    else
      FPersistData := TMemoryStream.Create;
    SaveDataToStream(FPersistData);
  end;
end;

// Sneak in after the table is opened.
procedure TMemDataSet.DoAfterOpen;
begin
  // If persistent, read info from file.
  if FPersistent and (FPersistentFile <> '') and FileExists(FPersistentFile) then
  begin
    LoadFromFile(FPersistentFile);
    first;
  end
  else if SaveData and (FPersistData <> NIL) then
  begin
    LoadDataFromStream( FPersistData );
    First;
  end;
  inherited;
end;

// Copy records from source to destinations.
// Handles different fieldorder between the two datasets.
// Returns the number of records copied.
function TMemDataSet.CopyRecords(Source,Destination:TDataSet;Count:longint):longint;
var
  i:integer;
  fc:integer;
  f:TField;
  fi:array [0..255] of integer;
begin
  Result:=0;

  // Did we get valid parameters.
  if (Source=nil) or (Destination=nil) or (Source=Destination) then
    EXIT;

  // Build name index relations between destination and source dataset.
  fc := Destination.FieldCount-1;
  for i := 0 to fc do
  begin
    // Check if not a datafield or not a supported field, dont copy it.
    if (Destination.Fields[i].FieldKind<>fkData) or
       (not (Destination.Fields[i].DataType in TkbmSupportedFieldTypes)) then
    begin
      fi[i] := -1;
      continue;
    end;

    // Find matching fieldnames on both sides. If fieldname not found, dont copy it.
    f := Source.FindField(Destination.Fields[i].FieldName);
    if f = nil then
    begin
      fi[i]:=-1;
      continue;
    end;

    fi[i]:=f.Index;
  end;

  // Copy data.
  Source.First;
  while not Source.EOF do
  begin
    Destination.Append;
    for i:=0 to fc do
    begin
      if fi[i]>=0 then
        try
          Destination.Fields[i].Value:=Source.Fields[fi[i]].Value;
        except
          Destination.Fields[i].Clear;
        end
      else
        Destination.Fields[i].Clear;
    end;
    Destination.post;
    Source.next;
    inc(Result);
    if (Count>0) and (Result>Count) then
      break;
  end;
end;

procedure TMemDataSet.CopyRecord(Source, Destination: TDataSet);
var
   i:integer;
   fc:integer;
   f:TField;
   fi:array [0..255] of integer;
begin
  // Did we get valid parameters.
  if (Source=nil) or (Destination=nil) or (Source=Destination) then exit;

  // Build name index relations between destination and source dataset.
  fc:=Destination.FieldCount-1;
  for i:=0 to fc do
  begin
    // Check if not a datafield or not a supported field, dont copy it.
    if (Destination.Fields[i].FieldKind<>fkData) or
       (not (Destination.Fields[i].DataType in TkbmSupportedFieldTypes)) then
    begin
      fi[i]:=-1;
      continue;
    end;

    // Find matching fieldnames on both sides. If fieldname not found, dont copy it.
    f:=Source.FindField(Destination.Fields[i].FieldName);
    if f = nil then
    begin
      fi[i]:=-1;
      continue;
    end;

    fi[i]:=f.Index;
  end;

  // Copy data.
  Destination.Append;
  for i:=0 to fc do
  begin
    if fi[i]>=0 then
      try
        Destination.Fields[i].Value := Source.Fields[fi[i]].Value
      except
        Destination.Fields[i].Clear;
      end
    else
      Destination.Fields[i].Clear;
  end;
  Destination.post;
end;



// Fill the memorytable with data from another dataset.
procedure TMemDataSet.LoadFromDataSet(Source:TDataSet);
var
   SourceActive:boolean;
   SourceDisabled:boolean;
   SelfActive:boolean;
begin
     if Source=self then exit;

     // Close this table.
     SelfActive:=Active;
     Close;

     // Remember state of source.
     SourceActive:=Source.Active;
     SourceDisabled:=Source.ControlsDisabled;

     // Dont update controls while scrolling through source.
     Source.DisableControls;

     try
        DisableControls;
        try

           // Dont want to check filtering while copying.
           Filtered := False;

           // Open source.
           Source.Open;
           Source.CheckBrowseMode;
           Source.UpdateCursorPos;

           // Create this memorytable as a copy of the other one.
           CreateTableAs(Source);
           Open;
           CheckBrowseMode;

           // Move to first record in source.
           Source.First;
           CopyRecords(Source,self,-1);
        finally
           First;
        end;
     finally
        EnableControls;
        if not SourceActive then Source.Close;
        if not SourceDisabled then Source.EnableControls;
        UpdateCursorPos;
        CursorPosChanged;
     end;
end;

// Append the data in this memory table to another dataset.
procedure TMemDataSet.SaveToDataSet(Destination:TDataSet);
var
   DestActive:boolean;
   DestDisabled:boolean;
   SelfActive:boolean;
begin
     if Destination=self then exit;

     // Close this table.
     SelfActive:=Active;
     Close;

     // Remember state of destination.
     DestActive:=Destination.Active;
     DestDisabled:=Destination.ControlsDisabled;

     // Dont update controls while appending to destination
     Destination.DisableControls;

     try
        DisableControls;
        try
           // Open destination
           Destination.Open;
           Destination.CheckBrowseMode;
           Destination.UpdateCursorPos;

           // Open this if not opened.
           Open;
           CheckBrowseMode;

           // Move to first record in this.
           First;
           CopyRecords(self,Destination,-1);
        finally
           Destination.First;
        end;
     finally
        EnableControls;
        if not DestActive then Destination.Close;
        if not DestDisabled then Destination.EnableControls;
        Active:=SelfActive;
     end;
end;

function TMemDataSet.IsSequenced: Boolean;
begin
     Result:=not Filtered;
end;

// Record rearranging.

function TMemDataSet._InternalMoveRecord(Source, Destination: Integer): Boolean;
var
   p:Pointer;
begin
     Result := False;
     if (Source <> Destination) and (Source > -1) and (Source < FRecords.Count)
        and (Destination > -1) and (Destination < FRecords.Count) then
     begin
          p := FRecords[Source];
          FRecords[Source] := FRecords[Destination];
          FRecords[Destination] := p;
          RecNo := Destination;
     end;
end;

// Move record to the specified destination.
function TMemDataSet.MoveCurRec(Destination: Integer): Boolean;
begin
     Result := _InternalMoveRecord(RecNo,RecNo + Destination);
end;

// Sorting.

// Quick sort algorithm for our purpose.
procedure TMemDataSet.QuickSort(L, R: Integer);
var
   I, J: Integer;
   P, T: Pointer;
begin
  repeat
    I := L;
    J := R;
    P := FRecords.List[(L + R) shr 1];
    // MS 2024.06.01 P := FRecords.List^[(L + R) shr 1];
    repeat
      while CompareRecords(FIndexList,FRecords.List[I], P) < 0 do Inc(I);
      while CompareRecords(FIndexList,FRecords.List[J], P) > 0 do Dec(J);
      // MS 2024.06.01 while CompareRecords(FIndexList,FRecords.List^[I], P) < 0 do Inc(I);
      // MS 2024.06.01 while CompareRecords(FIndexList,FRecords.List^[J], P) > 0 do Dec(J);
      if I <= J then
      begin
        T := FRecords.List[I];
        FRecords.List[I] := FRecords.List[J];
        FRecords.List[J] := T;
        // MS 2024.06.01 T := FRecords.List^[I];
        // MS 2024.06.01 FRecords.List^[I] := FRecords.List^[J];
        // MS 2024.06.01 FRecords.List^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J);
    L := I;
  until I >= R;
end;

// Callback function for TDataset to know if specified field is an index.
function TMemDataSet.GetIsIndexField(Field:TField):Boolean;
begin
     Result:=FIndexList.IndexOf(Field)>=0;
end;

// Build field list from list of fieldnames.
procedure TMemDataSet.BuildFieldList(List:TList; const FieldNames: string);
var
   p:integer;
   fld:TField;
begin
     List.Clear;
     p:=1;
     while p<=length(FieldNames) do
     begin
          fld:=FieldByName(ExtractFieldName(FieldNames,p));
          if (fld.FieldKind=fkData) and (fld.DataType in (TkbmSupportedFieldTypes-TkbmBlobTypes)) then
             List.Add(fld)
          else
              DatabaseErrorFmt('Cant index on field %s',[fld.DisplayName]);
     end;
end;

// Do sort on specified indexfields.
procedure TMemDataSet.Sort;
var
   Pos: TBookmark;

   // MS 2024.06.01 Pos: TBookmarkStr;
begin
     if (not Active) or (FRecords.Count<=0) then exit;

     BuildFieldList(FIndexList,FIndexFieldNames);
     if FIndexList.Count<=0 then exit;
     
     // Remember our position.
     Pos:=Bookmark;
     try
        QuickSort(0,FRecords.Count-1);
        SetBufListSize(0);
        try
           SetBufListSize(BufferCount + 1);
        except
           SetState(dsInactive);
           CloseCursor;
           raise;
        end;
     finally
        // Reposition.
        Bookmark:=Pos;
     end;
     Resync([]);
end;

// TkbmBlob.

constructor TkbmBlob.Create;
begin
     inherited;
     FLength:=0;
     FBuffer:=nil;
end;

destructor TkbmBlob.Destroy;
begin
     if FBuffer<>nil then FreeMem(FBuffer);
     inherited;
end;

procedure TkbmBlob.LoadFromStream(stream:TMemoryStream);
begin
     FLength:=stream.Size;
     FBuffer:=Allocmem(FLength);
     stream.Seek(0,soFromBeginning);
     stream.Read(FBuffer^,FLength);
end;

procedure TkbmBlob.SaveToStream(stream:TMemoryStream);
begin
     stream.SetSize(FLength);
     stream.Seek(0,soFromBeginning);
     stream.Write(FBuffer^,FLength);
     stream.Seek(0,soFromBeginning);
end;

// TkbmBlobStream

// On create, make a stream access to the specified blobfield in the current record.
constructor TkbmBlobStream.Create(Field:TBlobField;Mode:TBlobStreamMode);
begin
     FField:=Field;
     FFieldNo:=FField.FieldNo;
     FDataSet:=FField.DataSet as TMemDataSet;
     FMode:=Mode;
     FPBlob:=PkbmBlob(FDataSet.GetFieldPointer(FDataSet.GetActiveRecordBuffer,Field));
     if FPBlob=nil then Exit;
     if Mode<>bmRead then
     begin
          if FField.ReadOnly then DatabaseErrorFmt('Field %s is readonly.',[FField.DisplayName]);
          if not (FDataSet.State in [dsEdit, dsInsert]) then DatabaseError('Dataset is not in edit mode.');
     end;
     if Mode=bmWrite then
        Truncate
     else
        ReadBlobData;
end;

// On destroy, update the blobfield in the current record if the blob has changed.
destructor TkbmBlobStream.Destroy;
begin
     if FModified then
     try
        WriteBlobData;
        FField.Modified:=true;
        FDataSet.DataEvent(deFieldChange,Longint(FField));
     except
        //Application.HandleException(Self);
     end;
     inherited Destroy;
end;

procedure TkbmBlobStream.WriteBlobData;
var
   blob:TkbmBlob;
begin
     // Get old allocation if any, and free it.
     if FPBlob^<>nil then
     begin
          FPBlob^.free;
          FPBlob^:=nil;
     end;

     // Make new blob with data and enter it into the field
     blob:=TkbmBlob.Create;
     blob.LoadFromStream(self);
     FPBlob^:=blob;
end;

procedure TkbmBlobStream.ReadBlobData;
var
   blob:TkbmBlob;
begin
     // Get allocation.
     blob:=FPBlob^;
     if blob=nil then exit;

     // Copy the data to the stream.
     blob.SaveToStream(self);
end;

function TkbmBlobStream.Write(const Buffer;Count:Longint): Longint;
begin
     Result:=inherited Write(Buffer,Count);
     if FMode=bmWrite then FModified:=true;
end;

procedure TkbmBlobStream.Truncate;
var
   blob:pointer;
begin
     Clear;

     // If blob allocated, remove allocation.
     if FPBlob^<>nil then
     begin
          FPBlob^.free;
          FPBlob^:=nil;
     end;

     FModified:=true;
end;


procedure TMemDataSet.DefineProperties(Filer: TFiler);
begin
  inherited; 
  Filer.DefineProperty( 'FieldDefs',
                        ReadFieldDefs,
                        WriteFieldDefs,
                        SaveFieldDefs );
  Filer.DefineBinaryProperty( 'Data',
                              ReadData,
                              WriteData,
                              SaveData );
end;

procedure TMemDataSet.ReadFieldDefs(Reader: TReader);
var
  l       :Longint;
  i       :Integer;
  fd      :TFieldDef;
begin
  FieldDefs.Clear;
  l := Reader.ReadInteger;
  for i := 0 to l-1 do
  begin
    Reader.ReadListBegin;
    fd := FieldDefs.AddFieldDef;
    fd.Name := Reader.ReadString;
    fd.DataType := S2FieldType(Reader.ReadString);
    fd.Size := Reader.ReadInteger;
    Reader.ReadListEnd;
  end;
end;

procedure TMemDataSet.WriteFieldDefs(Writer: TWriter);
var
  l       :Longint;
  i       :Integer;
  fd      :TFieldDef;
begin
  l := FieldDefs.Count;
  Writer.WriteInteger(l);
  for i := 0 to l-1 do
  begin
    Writer.WriteListBegin;
    fd := FieldDefs.Items[i];
    Writer.WriteString(fd.Name);
    Writer.WriteString(FieldType2S(fd.DataType));
    Writer.WriteInteger(fd.Size);
    Writer.WriteListEnd;
  end;
end;

procedure TMemDataSet.ReadData(Stream: TStream);
begin
  if FPersistData <> NIL then
    FPersistData.Clear
  else
    FPersistData := TMemoryStream.Create;
  FPersistData.CopyFrom( Stream, 0 );
  FPersistData.Position := 0;
  //LoadDataFromStream(Stream);
end;

procedure TMemDataSet.WriteData(Stream: TStream);
begin
  if Active then
    SaveDataToStream(Stream)
  else if FPersistData <> NIL then
    Stream.CopyFrom(FPersistData,0);
end;

procedure TMemDataSet.LoadFromStream(Stream: TStream);
begin
  Stream.ReadComponent( self );
end;

procedure TMemDataSet.SaveToStream(Stream: TStream;
  flags: TMemDataSetSaveFlags);
begin
  Stream.WriteComponent(self);
end;

procedure TMemDataSet.WriteField( Fld: TField; Stream :TStream );
var
  strm    :TMemoryStream;
  l       :Longint;
  s       :string;
  d       :double;
  b       :byte;
  bool    :Boolean;

  yy,mm,dd :Word;
  hh,min,ss,ms :Word;
begin
  case Fld.DataType of
    ftString:
    begin
      s := Fld.AsString;
      WriteStr(s,Stream);
    end;

    ftSmallInt, ftInteger,ftAutoInc:
    begin
      l := Fld.AsInteger;
      Stream.Write(l, SizeOf(l));
    end;

    ftFloat,ftCurrency:
    begin
      d := Fld.AsFloat;
      Stream.Write(d, SizeOf(d));
    end;

    ftBoolean:
    begin
      bool := Fld.AsBoolean;
      if bool then
        b := 1
      else
        b := 0;
      Stream.Write(b,SizeOf(b));
    end;

    ftDate:
    begin
      DecodeDate( Fld.AsDateTime, yy, mm, dd );
      s := Format('%.4d%.2d%.2d', [yy,mm,dd] );
      Stream.Write(s[1], Length(s) );
    end;

    ftTime:
    begin
      DecodeTime( Fld.AsDateTime, hh, min, ss, ms );
      s := Format('%.2d%.2d%.2d%.2d', [hh,min,ss,ms] );
      Stream.Write(s[1], Length(s) );
    end;

    ftDateTime:
    begin
      DecodeDate( Fld.AsDateTime, yy, mm, dd );
      DecodeTime( Fld.AsDateTime, hh, min, ss, ms );
      s := Format('%.4d%.2d%.2d%.2d%.2d%.2d%.2d', [yy,mm,dd,hh,min,ss,ms] );
      Stream.Write(s[1], Length(s) );
    end;

    ftBlob,
    ftMemo,
    ftGraphic,
    ftFmtMemo,
    ftParadoxOle,
    ftDBaseOle,
    ftTypedBinary:
    begin
      if Fld is TBlobField then
      begin
        strm := TMemoryStream.Create;
        try
          TBlobField(Fld).SaveToStream(strm);
          l := strm.Size;
          Stream.Write(l,SizeOf(l));
          Stream.Write(strm.Memory^,l);
        finally
          strm.Free;
        end;
      end;
    end;

    //ftBCD:                Result:=34;
  //else
    //Result:=0;
  end;

end;

procedure TMemDataSet.WriteHeader(const fset: array of Boolean;
  Stream: TStream);
var
  cnt     :Longint;
  i       :Integer;
  Fld     :TField;
begin
  cnt := 0;
  for i := low(fset) to high(fset) do
  begin
    if fset[i] then
      inc(cnt);
  end;

  Stream.Write( cnt, SizeOf(cnt) );
  for i := low(fset) to high(fset) do
  begin
    if fset[i] then
    begin
      Fld := Fields[i];
      WriteStr( Fld.FieldName, Stream );
      case Fld.DataType of
        ftString:
        begin
          WriteStr( 'STRING', Stream );
        end;

        ftSmallInt, ftInteger,ftAutoInc:
        begin
          WriteStr( 'INT', Stream );
        end;

        ftFloat,ftCurrency:
        begin
          WriteStr( 'FLOAT', Stream );
        end;

        ftBoolean:
        begin
          WriteStr( 'BOOL', Stream );
        end;

        ftDate:
        begin
          WriteStr( 'DATE', Stream );
        end;

        ftTime:
        begin
          WriteStr( 'TIME', Stream );
        end;

        ftDateTime:
        begin
          WriteStr( 'DATETIME', Stream );
        end;

        ftBlob,
        ftMemo,
        ftGraphic,
        ftFmtMemo,
        ftParadoxOle,
        ftDBaseOle,
        ftTypedBinary:
        begin
          if Fld is TBlobField then
            WriteStr( 'BLOB', Stream )
          else
            WriteStr( 'UNK', Stream );
        end;

        ftBCD:
        begin
          WriteStr( 'BCD', Stream );
        end;
      else
          WriteStr( 'UNK', Stream );
      end;
    end;
  end;
end;

procedure TMemDataSet.WriteRecord(const fset: array of Boolean;
  Stream: TStream);
var
  i       :Integer;
begin
  WriteRecState(Stream);
  for i := low(fset) to high(fset) do
  begin
    if fset[i] then
      WriteField( Fields[i], Stream );
  end;
end;

procedure TMemDataSet.WriteRecState(Stream: TStream);
var
  l       :Longint;
begin
  // mo¿e coœ póŸniej wejdŸie
  l := 0;
  Stream.Write(l,SizeOf(l));
end;

procedure TMemDataSet.ReadHeader(var fset: TReadFieldInfoArray;
  Stream: TStream);
var
  l       :Longint;
  i       :Integer;
  s       :string;
begin
  Stream.Read(l,SizeOf(l));
  SetLength(fset,l);
  for i := low(fset) to high(fset) do
  begin
    fset[i].Name := ReadStr(Stream);
    s := ReadStr(stream);
    if s = 'STRING' then
      fset[i].ReadKind := rkfString
    else if s = 'INT' then
      fset[i].ReadKind := rkfInt
    else if s = 'FLOAT' then
      fset[i].ReadKind := rkfFloat
    else if s = 'DATE' then
      fset[i].ReadKind := rkfDate
    else if s = 'TIME' then
      fset[i].ReadKind := rkfTime
    else if s = 'DATETIME' then
      fset[i].ReadKind := rkfDateTime
    else if s = 'BLOB' then
      fset[i].ReadKind := rkfBLOB
    else if s = 'BCD' then
      fset[i].ReadKind := rkfBCD
    else if s = 'UNK' then
      fset[i].ReadKind := rkfUnk;
  end;
end;

procedure TMemDataSet.ReadRecord(const fset: TReadFieldInfoArray;
  Stream: TStream);
var
  i       :Integer;
  f       :TField;
begin
  ReadRecState(Stream);
  for i := low(fset) to high(fset) do
  begin
    f := FindField( fset[i].Name );
    if f <> NIL then
      ReadField( f, fset[i].ReadKind, Stream );
  end;
end;

procedure TMemDataSet.ReadRecState(Stream: TStream);
var
  l       :Longint;
begin
  Stream.Read(l,SizeOf(l));
end;

procedure TMemDataSet.ReadField(Fld: TField; rkf: TReadKindField;
  Stream: TStream);
var
  strm    :TMemoryStream;
  l       :Longint;
  s       :string;
  d       :double;
  b       :byte;
  bool    :Boolean;
  dt      :TDateTime;

  yy,mm,dd :Word;
  hh,min,ss,ms :Word;

begin
  case rkf of
    rkfUnk:
    begin

    end;

    rkfString:
    begin
      Fld.AsString := ReadStr( Stream );
    end;

    rkfInt:
    begin
      Stream.Read( l, SizeOf(l));
      Fld.AsInteger := l;
    end;

    rkfFloat:
    begin
      Stream.Read(d, SizeOf(d));
      Fld.AsFloat := d;
    end;

    rkfDate:
    begin
      SetLength( s, 8);
      Stream.Read( s[1], 8);
      yy := StrToInt( copy(s,1,4) );
      mm := StrToInt( copy(s,5,2) );
      dd := StrToInt( copy(s,7,2) );
      Fld.AsDateTime := EncodeDate( yy, mm, dd );
    end;

    rkfTime:
    begin
      SetLength( s, 8);
      Stream.Read( s[1], 8);
      hh := StrToInt( copy(s,1,2) );
      min := StrToInt( copy(s,3,2) );
      ss := StrToInt( copy(s,5,2) );
      ms := StrToInt( copy(s,7,2) );
      Fld.AsDateTime := EncodeTime( hh, min, ss, ms );
    end;

    rkfDateTime:
    begin
      SetLength( s, 8);
      Stream.Read( s[1], 8);
      yy := StrToInt( copy(s,1,4) );
      mm := StrToInt( copy(s,5,2) );
      dd := StrToInt( copy(s,7,2) );
      dt := EncodeDate( yy, mm, dd );
      SetLength( s, 8);
      Stream.Read( s[1], 8);
      hh := StrToInt( copy(s,1,2) );
      min := StrToInt( copy(s,3,2) );
      ss := StrToInt( copy(s,5,2) );
      ms := StrToInt( copy(s,7,2) );
      Fld.AsDateTime := dt + EncodeTime( hh, min, ss, ms );
    end;

    rkfBLOB:
    begin
      Stream.Read(l, SizeOf(l));
      strm := TMemoryStream.Create;
      try
        strm.Size := l;
        Stream.Read( strm.Memory^, l );
        if Fld is TBlobField then
          TBlobField(Fld).LoadFromStream(strm);
      finally
        strm.Free;
      end;
    end;

    rkfBCD:
    begin

    end;
  end;

end;

initialization
  Classes.RegisterClass( TMemDataSet );

end.
