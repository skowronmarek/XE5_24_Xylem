{TEditN, TMEditN, TDBEditN

 - Author   : Jose Maria Gias
 - email    : sigekom@arrakis.es
              http://www.arrakis.es/~sigecom
 - Version  : 2.3 Delphi 2-3-4
 - Date     : 04/19/1999
 - Type     : FreeWare

 Comments in file ReadENew.Txt
 }
unit EditNew;

interface

uses                                 
  {$IFDEF WIN32}Windows,{$ELSE}Winprocs,{$ENDIF}
  Messages, SysUtils, Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls;

type
  TEditTypes = (etString, etInteger, etFloat,etDate,etTime);
  TEditAlign = (etAlignRight, etAlignLeft, etAlignCenter, etAlignNone, etAlignValue);
  TInsertKeyStates = (iksInsert, iksOverWrite);
  TAcceptEvent = procedure( Sender :TObject; var Accept :Boolean ) of object;

  TEditN = class(TEdit)
  private
    { Private declarations }
    FOnEnter      : TNotifyEvent;
    FOnExit       : TNotifyEvent;
    FOnChange     : TNotifyEvent;
    FOnAccept     : TAcceptEvent;
    I_Color       : TColor;
    E_Color       : TColor;
    FI_Color      : TColor;
    FE_Color      : TColor;
    FO_Color      : TColor;
    TipoEdit      : TEditTypes;
    TipoAlign     : TEditAlign;
    KeyTab        : Char;
    LongAlign     : Integer;
    ValInteger    : Integer;
    ValFloat      : Double;
    SDecimal      : Char;
    EPrecision    : Integer;
    FUpper        : Boolean;
    FUpperList    : String;
    ValTemp       : Extended;
    TxtConvert    : String;
    FWidthOnFocus : Integer;
    iWidth        : Integer;
    TextAtEnter   : String;
    PtrToData     : Pointer;
    sDate         : Char;
    sTime         : Char;
    FSeconds      : Boolean;
    ValDate       : TDateTime;
    ValTime       : TDateTime;
    FInsertKeyState : boolean;
    FAutoDisplay: Boolean;
    FNEColor: TColor;
    ChangingValue :Boolean;
    FDigits: Integer;
    FPrecision: Integer;
    FFloatFormat: TFloatFormat;
    FRequired: Boolean;
    FAllowOverWrite: Boolean;
    procedure WMChar(var Msg: TWMKey); message WM_Char;
    procedure SetAutoDisplay(const Value: Boolean);
    procedure SetValDate(const Value: TDateTime);
    procedure SetValFloat(const Value: Double);
    procedure SetValInteger(const Value: Integer);
    procedure SetValTime(const Value: TDateTime);
    procedure SetFNEColor(const Value: TColor);
    procedure SetE_Color(const Value: TColor);
    procedure SetFE_Color(const Value: TColor);
    procedure SetFI_Color(const Value: TColor);
    procedure SetFO_Color(const Value: TColor);
    procedure SetI_Color(const Value: TColor);
    procedure SetDigits(const Value: Integer);
    procedure SetFloatFormat(const Value: TFloatFormat);
    procedure SetPrecision(const Value: Integer);
    procedure SetOnAccept(const Value: TAcceptEvent);
    procedure SetEmpty(const Value: Boolean);
    procedure SetRequired(const Value: Boolean);
    function GetEmpty: Boolean;
    procedure SetAllowOverWrite(const Value: Boolean);
  protected
    {Protected declarations}
    procedure FormatDate;
    procedure FormatTime;
    function GetInsertKeyState: TInsertKeyStates;
    procedure SetEnabled( Value :Boolean ); override;
    procedure UpdateTxtFloat;
    procedure UpdateTxtInteger;
    function  CheckUpdateFloat :Boolean;
    //procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner : TComponent); override;

    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Change; override;

    function AcceptOK :Boolean;
    procedure SetPtrToData(DataPtr:Pointer);
    procedure Update;  reintroduce;// Not declare override because make stack overflow
    procedure UpdateText;
    property InsertKeyState: TInsertKeyStates read GetInsertKeyState;
  published
    property  AllowOverWrite :Boolean read FAllowOverWrite write SetAllowOverWrite;
    property  AutoDisplay :Boolean read FAutoDisplay write SetAutoDisplay default true;
    property  OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property  OnExit : TNotifyEvent read FOnExit  write FOnExit;
    property  OnChange : TNotifyEvent read FOnChange  write FOnChange;
    property  ColorOnFocus : TColor read I_Color write SetI_Color;
    property  ColorOnNotFocus : TColor read E_Color write SetE_Color;
    property  ColorOnNotEnabled : TColor read FNEColor write SetFNEColor default clBtnFace;
    property  FontColorOnFocus : TColor read FI_Color write SetFI_Color;
    property  FontColorOnNotFocus : TColor read FE_Color write SetFE_Color;
    property  FontColorOnOverWrite : TColor read FO_Color write SetFO_Color;
    property  EditType : TEditTypes read TipoEdit write TipoEdit;
    property  EditKeyByTab : Char read KeyTab write KeyTab;
    property  EditAlign : TEditAlign read TipoAlign write TipoAlign;
    property  EditLengthAlign : Integer read LongAlign write LongAlign;
    property  EditPrecision : Integer read EPrecision write EPrecision;
    property  Required : Boolean read FRequired write SetRequired;
    property  Empty : Boolean read GetEmpty write SetEmpty;
    property  ValueFloat : Double read ValFloat write SetValFloat;
    property  ValueInteger : Integer read ValInteger write SetValInteger;
    property  ValueDate : TDateTime read ValDate write SetValDate;
    property  ValueTime : TDateTime read ValTime write SetValTime;
    property  TimeSeconds : Boolean read FSeconds write FSeconds;
    property  FirstCharUpper : Boolean read FUpper write FUpper;
    property  FirstCharUpList : String read FUpperList write FUpperList;
    property  WidthOnFocus : Integer read FWidthOnFocus write FWidthOnFocus;
    property  FloatFormat  : TFloatFormat read FFloatFormat write SetFloatFormat;
    property  Precision    : Integer read FPrecision write SetPrecision;
    property  Digits       :Integer read FDigits write SetDigits;
    property  OnAccept     :TAcceptEvent read FOnAccept write SetOnAccept;
  end;

const
  Decimalseparator = '.';

implementation

{$R EdNew32.res}

constructor TEditN.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  ColorOnFocus         := clWindow;
  ColorOnNotFocus      := clWindow;
  FNEColor             := clBtnFace;
  FontColorOnFocus     := clWindowText;
  FontColorOnNotFocus  := clWindowText;
  FontColorOnOverWrite := clWindowText;
  TipoEdit             := etString;
  TipoAlign            := etAlignNone;
  LongAlign            := 0;
  KeyTab               := #9;        // #13 for Return by Tab
  ValInteger           := 0;
  ValFloat             := 0;
  EPrecision           := 0;
  SDecimal             := DecimalSeparator;
  FUpper               := False;
  FUpperList           := ' (';
  FWidthOnFocus        := 0;
  TextAtEnter          := '';
  PtrToData            := nil;
  sDate                := '-';// DateSeparator;   // Windows Default
  sTime                := ':';//TimeSeparator;   // Windows Default
  FSeconds             := False;           // etTime with seconds
  ValDate              := Date;
  ValTime              := Time;
  FAutoDisplay         := true;
end;

procedure TEditN.SetPtrToData(DataPtr:Pointer);
begin
 PtrToData := DataPtr;
 Update;
end;

procedure TEditN.Update;
begin
  if Assigned(PtrToData) then begin
    if EditType = etString  then Text := string(PtrToData^);
    if EditType = etInteger then Text := IntToStr(Integer(PtrToData^));
    if EditType = etFloat   then Text := FloatToStrF(Double(PtrToData^),ffgeneral,15,4);
    if EditType = etDate    then Text := DateToStr(TDateTime(PtrToData^));
    if EditType = etTime    then Text := TimeToStr(TDateTime(PtrToData^));
  end;
  Refresh;
  inherited Update;
end;

procedure TEditN.KeyDown(var Key: Word; Shift: TShiftState);
begin
 if Key <> 0 then
   inherited KeyDown(Key,Shift);
end;

procedure TEditN.KeyPress(var Key: Char);
var
 {$IFDEF VER80}
  FEditTemp : TForm;       {For Delphi 1}
 {$ENDIF}

 {$IFDEF VER90}
  FEditTemp : TForm;       {For Delphi 2}
 {$ENDIF}

 {$IFDEF VER100}
  FEditTemp : TCustomForm; {For Delphi 3}
 {$ENDIF}

 {$IFDEF VER120}
  FEditTemp : TCustomForm; {For Delphi 4}
 {$ENDIF}
 {$IFDEF VER130}
  FEditTemp : TCustomForm; {For Delphi 5}
 {$ENDIF}
 {$IFDEF VER140}
  FEditTemp : TCustomForm; {For Delphi 6}
 {$ENDIF}
 {$IFDEF VER150}
  FEditTemp : TCustomForm; {For Delphi 7}
 {$ELSE}
  FEditTemp : TCustomForm; {For Delphi 7}
 {$ENDIF}

  C         : String;
begin

  if (Key = EditKeyByTab) or (Key = #13) then
  begin
    if AcceptOK and (Key = EditKeyByTab) then
    begin
      FEditTemp := GetParentForm(Self);
      if FEditTemp <> NIL then
        SendMessage(FEditTemp.Handle, WM_NEXTDLGCTL, 0, 0);
    end;
    Key := #0;
  end
  else
  begin

    // If ESC is pressed during edit, all changes are cancelled
    // Si se ha pulsado escape, se anulan los cambios
    if Key = #27 then
    begin
      Text := TextAtEnter;
      Key  := #15;
    end;

    if InsertKeyState = iksOverWrite then// New in Version 2.3
      Font.Color := FontColorOnOverWrite
    else
      Font.Color := FontColorOnFocus;

    //Permitted characters in function of type
    // Caracteres permitidos en función del tipo
    case EditType of
      etString :
      begin
        if FUpper then
        begin // Capital letter  - Maýusculas
          if (Length(Text) = 0) or
             (SelText = Text) or
             (Pos(Text[Length(Text)],FUpperList) > 0) then
          begin
            C   := AnsiUpperCase(Key);
            Key := C[1];
          end;
        end;
      end;

      etInteger :
      begin
        if ((Pos('-',Text) > 0) or (Key = '-'))
           and (MaxLength = 0) then
          MaxLength := 11;

        if (not (Key in ['0'..'9','-',#8,#13,#35,#36,#37,#39])) or
           (Key = #32) or // To eliminate the introduction from spaces
           ((Key = '-') and (Pos('-',Text) > 0) and (SelLength <> Length(Text)))
           then// To verify that alone is introduce a negative sign.
          Key := #15;
      end;

      etFloat :
      begin
        if (not (Key in ['0'..'9',',','.','-',#8,#13,#35,#36,#37,#39])) or
           (Key = #32) or // To eliminate the spaces introduction
           ((Key = '-') and (Pos('-',Text) > 0) and (SelLength <> Length(Text)))
           then// To verify that alone is introduce a negative sign.
          Key := #15;

        if (Key = ',') or (Key = '.') then
          if (Pos(',',Text) > 0) or (Pos('.',Text) > 0) then
            Key := #15
          else
            Key := ',';//DecimalSeparator;
      end;

      etDate, etTime :
        if not (Key in ['0'..'9',#8,#13,#35,#36,#37,#39]) then
          Key := #15;

    end; // Case EditType of
  end;  // if Key <> EditKeyByTab

  if Key <> #0 then
    inherited KeyPress(Key);

end;

procedure TEditN.DoEnter;
begin
  // To assign the Color upon receiving the focus
  if (EditType = etFloat) and (MaxLength = 0) then
    MaxLength := 16;
  Color       := ColorOnFocus;
  if InsertKeyState = iksOverwrite then
    Font.Color := FontColorOnOverWrite
  else
    Font.Color  := FontColorOnFocus;
  TextAtEnter := Text;

  if WidthOnFocus > 0 then begin
    iWidth := Width;
    Width  := FWidthOnFocus;
  end;

  // If a connection to a variable exists, Update the contents of the field with
  // the contents of the connected variable in case the variable has changed.
  if Assigned(PtrToData) then
    Update;

  if EditType = etDate then
    MaxLength := 10;

  if EditType = etTime then
    if TimeSeconds then
      MaxLength := 8
    else
      MaxLength := 5;

  if Assigned(FOnEnter) then
    FOnEnter(Self);
end;

procedure TEditN.DoExit;
var
  k : Integer;
  s : String;
begin
  if not AcceptOK then
    raise EAbort.Create('');

  // To return the color of the fund upon leaving and losing the focus
  Color      := ColorOnNotFocus;
  Font.Color := FontColorOnNotFocus;

  if WidthOnFocus > 0 then
    Width := iWidth;

  if (EditType = etString) and (Length(Text) > 0) then
  begin
    if FUpper then
    begin
      if Length(Text) = 1 then
        Text := AnsiUpperCase(Text);
      if Length(Text) > 1 then
        Text := AnsiUpperCase(Text[1]) + Copy(Text,2,Length(Text)-1);
    end;

    if (EditAlign <> etAlignNone) and (EditLengthAlign > 0) then
    begin // With Alignment

      // The length of the chain is < that that of Align.
      if (EditLengthAlign > Length(Text)) then
      begin
        case EditAlign of
          etAlignLeft  :
          begin
            while Text[1] = ' ' do
              Text := Copy(Text,2,Length(Text)-1);
            for k := 1 to EditLengthAlign - Length(Text) do
              Text := Text + ' ';
          end;

          etAlignRight :
          begin
            for k := 1 to EditLengthAlign - Length(Text) do
              Text := ' ' + Text;
          end;

          etAlignCenter:
          begin
            for k := 1 to Round((EditLengthAlign - Length(Text))/2) do
              Text := ' ' + Text;
            for k := Length(Text) to EditLengthAlign do
              Text := Text + ' ';
          end;

        end; // Case EditAlign
      end; // if (EditLengthAlign > Length(Text))
    end; // if (EditAlign <> etAlignNone) and (EditLengthAlign > 0)
  end;   // if (EditType = etString) and (Length(Text) > 0)

  // To align a string Integer, filling with zeroes, if it has been indicated.
  // The negative sign if exists, counts it as a digit but
  if (EditType = etInteger) and
      (EditAlign = etAlignValue) and
      (EditLengthAlign > 0) and
      ((Length(Text) > 0) or Required) then
    if Length(Text) < EditLengthAlign then
      for k := Length(Text) to EditLengthAlign - 1 do
        Text := '0' + Text;

  // To put the negative sign to the beginning of the chain. It has been designed
  // so that the negative sign could be introduced in any place, and here we happen
  // it to the beginning
  //if ((EditType = etInteger) or (EditType = etFloat)) and (Pos('-',Text) > 1) then
  //  if Length(Text) = Pos('-',Text) then
  //    Text := '-' + Copy(Text,1,Pos('-',Text)-1)
  //  else
  //    Text := '-' + Copy(Text,1,Pos('-',Text)-1)
  //                + Copy(Text,Pos('-',Text) + 1,Length(Text) - Pos('-',Text));

   // If it has been defined precision, gives format  to the string
  if (EditType = etFloat)
      and ((not Empty) or Required) then
  begin
    UpdateText;
  end;

  if EditType = etDate then FormatDate;

  if EditType = etTime then FormatTime;

   // Update the connected variable with the current value
  if Assigned(PtrToData) then
  begin
    if EditType = etInteger then Move(ValueInteger, PtrToData^, Sizeof(ValueInteger));
    if EditType = etFloat   then Move(ValueFloat,   PtrToData^, Sizeof(ValueFloat));
    if EditType = etDate    then Move(ValueDate,    PtrToData^, Sizeof(ValueDate));
    if EditType = etTime    then Move(ValueTime,    PtrToData^, Sizeof(ValueTime));
    if EditType = etString  then
    begin
      s := Text;
      Move(s, PtrToData^, Sizeof(s));
    end;
  end;

  if Assigned(FOnExit) then
    FOnExit(Self);
end;


procedure TEditN.Change;
var
  i : Integer;
  C : String;
begin
  if (ComponentState * [csLoading, csReading]) <> [] then
    EXIT;
  if not ChangingValue then
  begin
    // To convert the chain if it is numerical,to return a value
    if ((EditType = etInteger) or (EditType = etFloat)) and
       (Length(Text) > 0) then
    begin

      if EditType = etInteger then
      begin
        for i := 1 to Length(Text) do
        begin
          if Text[i] in ['0'..'9','-','+'] then
            C := C + Text[i]
        end;
        Text := C;
      end;

      if EditType = etFloat then
      begin
        for i := 1 to Length(Text) do
        begin
          if Text[i] in ['0'..'9',',','.', DecimalSeparator,
                         '-','+', 'e', 'E'] then
          begin
            if Text[i] in [',','.'] then
              C := C + DecimalSeparator
            else
              C := C + Text[i]
          end;
        end;
        Text := C;
      end;

      if Length(Text) = 0 then
      begin
        ValFloat   := 0;
        ValInteger := 0;
        if Assigned(FOnChange) then
          FOnChange(Self);
        Exit;
      end;

      try
        ValFloat   := 0;
        ValInteger := 0;

        // Eliminar caracteres no permitidos y cambiar el signo - al comienzo para
        //  que no de error de conversión
        i := 1;
        while i <= Length(Text) do
          if not (Text[i] in ['0'..'9',',','.',DecimalSeparator,'-']) then
            Text := Copy(Text,1,i-1) + Copy(Text,i+1,Length(Text)-i)
          else
            i := i + 1;

        // Si solo tenemos el signo negativo, daría error
        if (Pos('-',Text) = 1) and (Length(Text) = 1) then
          Exit;

        // Temporary variable to accomplish the conversion
        TxtConvert := Text;

        // To put the negative sign to the beginning
        //if (EditType <> etString) and (Pos('-',TxtConvert) > 1) then
        //  if Length(TxtConvert) = Pos('-',TxtConvert) then
        //    TxtConvert := '-' + Copy(TxtConvert,1,Pos('-',TxtConvert)-1)
        //  else
        //    TxtConvert := '-' +
        //                  Copy(TxtConvert,1,Pos('-',TxtConvert)-1) +
        //                  Copy(TxtConvert,Pos('-',TxtConvert) + 1,Length(TxtConvert) - Pos('-',TxtConvert));

        if EditType = etInteger then
        begin
          // Range control of Integer
          ValTemp := StrToFloat(TxtConvert);
          if (ValTemp > 2147483647) or (ValTemp < -2147483647) then
          begin
            ShowMessage('Range Max. : -2147483647 <-> 2147483647');
            ValInteger := 0;
          end
          else
          begin
            ValInteger := StrToInt(TxtConvert);
            ValFloat   := ValInteger;
          end;
        end;

        // El tipo Float - Double, permite valores hasta 5.0 * 10e-324 .. 1.7 * 10e308
        // con 15-16 digitos significativos, por lo que solamente controlamos que el total
        // no pase de 16 digitos. Hasta la fecha no he experimentado con valores Float tan
        // altos, por lo que no me atrevo a condicionar algo que no conozco con exactitud.}
        if EditType = etFloat then
        begin
          ValFloat   := StrToFloat(TxtConvert);
          ValInteger := Trunc(ValueFloat);
        end;

      except
        on EConvertError do
        begin
          ShowMessage('Range Max. :' + #13 +
                      ' - Integer : -2147483647 <-> 2147483647' + #13 +
                      ' - Float   : 5.0e-324 <-> 1.7e+308');
          ValueInteger := 0;
          ValueFloat   := 0;
        end;
      end;
    end
    else
    begin

    end;
  end;    // if not ChangingValue
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TEditN.FormatDate;
var
  Temp,vDate,vMonth,vYear : String;
  dDate   : TDateTime;
  ilength : Integer;

begin
  // Decode the Date
  Temp    := '';
  vDate   := FormatDateTime('dd' + sDate + 'mm' + sDate + 'yyyy',Date);
  vMonth  := Copy(vDate,4,2);
  vYear   := Copy(vDate,7,4);

  // Quitar separador de fecha si existe
  if Length(Text) > 0 then
    for iLength := 1 to Length(Text) do
      if Text[iLength] in ['0'..'9'] then
        Temp := Temp + Text[iLength];

  // Completar la fecha con separadores
  iLength := Length(Temp);
  Case iLength of
    0 : Temp := vDate;
    1 : Temp := '0' + Temp[1] + sDate + vMonth + sDate + vYear;
    2 : Temp := Temp + sDate + vMonth + sDate + vYear;
    3 : Temp := Copy(Temp,1,2) + sDate + '0' + Temp[3] + sDate + vYear;
    4 : Temp := Copy(Temp,1,2) + sDate + Copy(Temp,3,2) + sDate + vYear;
    5 : Temp := Copy(Temp,1,2) + sDate + Copy(Temp,3,2) + sDate + Copy(vYear,1,3) + Temp[5];
    6 : Temp := Copy(Temp,1,2) + sDate + Copy(Temp,3,2) + sDate + Copy(vYear,1,2) + Copy(Temp,5,2);
    7 : Temp := Copy(Temp,1,2) + sDate + Copy(Temp,3,2) + sDate + vYear[1] + Copy(Temp,5,3);
    8,9,10 : Temp := Copy(Temp,1,2) + sDate + Copy(Temp,3,2) + sDate + Copy(Temp,5,4);
  end;

  // Test of correct Date
  try
    dDate := StrToDate(Temp);
  except
    ShowMessage('Date incorrect');
    // On error, the Date is actually for default
    ValueDate    := Date;
    ValueFloat   := Date; // TDateTime : Double;
    ValueInteger := Trunc(Date);
    Exit;
  end;

  // The Date is correct. Assign value
  Text         := Temp;
  ValueDate    := StrToDate(Temp);
  ValueFloat   := ValueDate; // TDateTime : Double;
  ValueInteger := Trunc(ValueDate);
end;


procedure TEditN.FormatTime;
var
  Temp,vTime,vMin,vSec,MskTime : String;
  iLength : Integer;
  tTime   : TDateTime;
begin
  Temp    := '';
  MskTime := '00' + sTime + '00' + sTime + '00';
  vTime   := FormatDateTime('hh:mm:ss',Time);
  vMin    := Copy(vTime,4,2);
  vSec    := Copy(vTime,7,2);

 // Quitar separadores si los hay
  if Length(Text) > 0 then
    for iLength := 1 to Length(Text) do
      if Text[iLength] in ['0'..'9'] then
        Temp := Temp + Text[iLength];

  // Formatear el tiempo
  iLength := Length(Temp);
  if TimeSeconds then
  begin // Con segundos
    Case iLength of
      0 : Temp := vTime;
      1 : Temp := '0' + Temp[1] + Copy(MskTime,3,6);
      2 : Temp := Temp + Copy(MskTime,3,6);
      3 : Temp := Copy(Temp,1,2) + sTime + '0' + Temp[3] + Copy(MskTime,6,3);
      4 : Temp := Copy(Temp,1,2) + sTime  + Copy(Temp,3,2) + Copy(MskTime,6,3);
      5 : Temp := Copy(Temp,1,2) + sTime  + Copy(Temp,3,2) + sTime + '0' + Temp[5];
      6,7,8 : Temp := Copy(Temp,1,2) + sTime  + Copy(Temp,3,2) + sTime + Copy(Temp,5,2);
    end;
  end
  else
  begin // Sin segundos
    Case iLength of
      0 : Temp := vTime;
      1 : Temp := '0' + Temp[1] + Copy(MskTime,3,3);
      2 : Temp := Temp + Copy(MskTime,3,3);
      3 : Temp := Copy(Temp,1,2) + sTime + '0' + Temp[3];
      4,5 : Temp := Copy(Temp,1,2) + sTime  + Copy(Temp,3,2);
    end;
  end;

  // Test of string-time
  try
    tTime := StrToTime(Temp);
  except
    ShowMessage('Time incorrect');
    if TimeSeconds then
      Text := vTime
    else
      Text := Copy(vTime,1,5);
    ValueTime  := Time;
    ValueFloat := ValueTime;
    Exit;
  end;
  // The time is correct
  Text       := Temp;
  ValueTime  := StrToTime(Temp);
  ValueFloat := ValueTime;
end;

// Add for José R. Caamaño
function TEditN.GetInsertKeyState: TInsertKeyStates;
begin
  if (GetKeyState(VK_INSERT) = 0) or (not AllowOverWrite) then
    Result := iksInsert
  else
    Result := iksOverWrite;
end;

// Add for José R. Caamaño
procedure TEditN.WMChar(var Msg: TWMKey);
begin
  // if Overwrite state and user select nothing
  if (InsertKeyState = iksOverWrite) and (SelLength = 0) and (SelStart < GetTextLen)
    then SelLength := 1;
  inherited;
end;

// Add for José R. Caamaño
//{$ifdef ___Win32}
//procedure TEditN.WndProc(var Message: TMessage);
//begin
//  { solve problem of the IME wouldn't appear in browse mode }
//  if (Message.Msg = WM_SETFOCUS) or (Message.Msg = WM_MOUSEACTIVATE)
//   then SendMessage(Handle, EM_SETREADONLY, 0, 0);
//  inherited WndProc(Message);
//end;
//{$endif}

procedure TEditN.SetFNEColor(const Value: TColor);
begin
  FNEColor := Value;
  if not Enabled then
    Color := Value;
end;



procedure TEditN.SetAutoDisplay(const Value: Boolean);
begin
  FAutoDisplay := Value;
  if Value then
    case EditType of
      etInteger : SetValInteger( ValInteger );
      etFloat   : SetValFloat( ValFloat );
      etDate    : SetValDate( ValDate );
    end;

end;

procedure TEditN.SetValDate(const Value: TDateTime);
begin
  ValDate := Value;
  if AutoDisplay and (EditType = etDate)then
  begin
    ChangingValue := true;
    ValFloat := Value;
    Text := DateToStr( Value );
    ChangingValue := false;
  end;
end;

procedure TEditN.SetValFloat(const Value: Double);
begin
  ValFloat := Value;
  if AutoDisplay and (EditType = etFloat) then
  begin
    ChangingValue := true;
    //ValInteger := round(int(Value));
    if CheckUpdateFloat then
      UpdateText;
    ChangingValue := false;
  end;
end;

procedure TEditN.SetValInteger(const Value: Integer);
begin
  ValInteger := Value;
  ValFloat   := Value;
  if AutoDisplay and (EditType = etInteger) then
  begin
    ChangingValue := true;
    if (Value <> 0) or (Required) or (not Empty) then
      Text := IntToStr( Value );
    ChangingValue := false;
  end;
end;

procedure TEditN.SetValTime(const Value: TDateTime);
begin
  ValTime := Value;
  if AutoDisplay and (EditType = etTime) then
  begin
    ChangingValue := true;
    Text := TimeToStr( Value );
    ChangingValue := false;
  end;
end;


procedure TEditN.SetEnabled(Value: Boolean);
//var
//  F       :TCustomForm;
begin
  inherited SetEnabled(Value);
  if Value then
  begin
    if Screen.ActiveControl = self then
    begin
      Color := ColorOnFocus;
      if not Focused then
      begin
        Windows.SetFocus(Handle);
      end;
    end
    else
      Color := ColorOnNotFocus;
  end
  else
    Color := ColorOnNotEnabled;
end;




procedure TEditN.SetE_Color(const Value: TColor);
begin
  E_Color := Value;
  if not Focused then
    Color := Value;
end;

procedure TEditN.SetFE_Color(const Value: TColor);
begin
  FE_Color := Value;
  if not Focused then
    Font.Color := Value;
end;

procedure TEditN.SetFI_Color(const Value: TColor);
begin
  FI_Color := Value;
  if Focused and (InsertKeyState = iksInsert) then
    Font.Color := Value;
end;

procedure TEditN.SetFO_Color(const Value: TColor);
begin
  FO_Color := Value;
  if Focused and (InsertKeyState = iksOverwrite) then
    Font.Color := Value;
end;

procedure TEditN.SetI_Color(const Value: TColor);
begin
  I_Color := Value;
  if Focused and (InsertKeyState = iksInsert) then
    Color := Value;
end;

procedure TEditN.SetDigits(const Value: Integer);
begin
  FDigits := Value;
  if (EditType = etFloat) and CheckUpdateFloat then
    UpdateText;
end;

procedure TEditN.SetFloatFormat(const Value: TFloatFormat);
begin
  FFloatFormat := Value;
  if (EditType = etFloat) and AutoDisplay and CheckUpdateFloat then
    UpdateText;
end;

procedure TEditN.SetPrecision(const Value: Integer);
begin
  FPrecision := Value;
  if (EditType = etFloat) and AutoDisplay and CheckUpdateFloat then
    UpdateText;
end;


function TEditN.AcceptOK: Boolean;
begin
  result := true;
  if Assigned(FOnAccept) then
    FOnAccept( self, result );
end;

procedure TEditN.SetOnAccept(const Value: TAcceptEvent);
begin
  FOnAccept := Value;
end;

procedure TEditN.SetEmpty(const Value: Boolean);
begin
  if Value then
    Text := '';
end;

procedure TEditN.SetRequired(const Value: Boolean);
begin
  FRequired := Value;
end;



function TEditN.GetEmpty: Boolean;
begin
  result := Text = '';
end;

procedure TEditN.UpdateTxtFloat;
begin
  Text := FloatToStrF(ValFloat, FloatFormat, Precision, Digits);
end;

procedure TEditN.UpdateText;
var
  svCh    :Boolean;
begin
  svCh := ChangingValue;
  try
    case EditType of
      etFloat     : UpdateTxtFloat;
      etInteger   : UpdateTxtInteger;
    end;
  finally
    ChangingValue := svCh;
  end;

end;

procedure TEditN.UpdateTxtInteger;
begin
  Text := IntToStr( ValInteger );
end;

function TEditN.CheckUpdateFloat: Boolean;
begin
  result := (ValFloat <> 0) or Required or (not Empty);
end;

procedure TEditN.SetAllowOverWrite(const Value: Boolean);
begin
  FAllowOverWrite := Value;
end;

end.
