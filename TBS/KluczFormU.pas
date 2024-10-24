unit KluczFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons,
  TbsU, KluczSZU, Kr_Sys, KatalogKluczConstU,
  WkpGlob;
type
  TKluczForm = class(TForm)
    EditWyjscie: TEdit;
    EditWejscie: TEdit;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    LicLab: TLabel;
    WlascLicEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Info: TStaticText;
  private
    FChodziODate: Boolean;
    procedure SetChodziODate(const Value: Boolean);
    function  SToDat( const s :string ) :TDateTime;
    function  DatToS( d :TDateTime ) :string;
  private
    procedure ERO( E :TEdit; setRO :Boolean );
    property  ChodziODate :Boolean read FChodziODate write SetChodziODate;
    function  WerOK(c :char) :Boolean; 
  public
    { Public declarations }
    function Wyswietl(const Sekcja :string) :Boolean;
  end;

var
  KluczForm: TKluczForm;

implementation

{$R *.DFM}

{ TKluczForm }

function TKluczForm.DatToS(d: TDateTime): string;
var
  y, m, day :Word;
begin
  DecodeDate( d, y, m, day );
  result := Format( '%.4d%.2d%.2d', [y, m, day] );
end;

procedure TKluczForm.ERO(E: TEdit; setRO: Boolean);
begin
  E.ReadOnly := setRO;
  E.TabStop  := not setRO;
  E.Ctl3D    := not setRO;
  if setRO then
  begin
    E.Color := clAqua;
    E.Font.Color := clBlack;
  end
  else
  begin
    E.Color      := clWindow;
    E.Font.Color := clWindowText;
  end;
end;

procedure TKluczForm.SetChodziODate(const Value: Boolean);
begin
  FChodziODate := Value;
  if Value then
  begin
    Info.Caption := 'Minela data waznosci twojej licencji'+#13#10+
                    'Skontaktuj sie z producentem';
  end
  else
  begin
    Info.Caption := 'Nieaktualny kod komputera';
                    //'Aby uzyskac kod odblokowujacy'+#13#10+
                    //'Skontaktuj sie z producentem';

  end;
end;

function TKluczForm.SToDat(const s: string): TDateTime;
var
  y, m, day :Word;
begin
  y := StrToInt( copy( s, 1, 4 ) );
  m := StrToInt( copy( s, 5, 2 ) );
  day := StrToInt( copy( s, 7, 2 ) );
  result := EncodeDate( y, m, day);
end;

function TKluczForm.WerOK(c: char): Boolean;
var
  v1, v2, v3, v4  :word;
  av1, av2        :word;
begin
  GetFileVersion( v1, v2, v3, v4 );
  av1 := byte(c) div 16;
  av2 := byte(c) mod 16;
  result := (av1 > v1) or ((av1 = v1) and (av2 >= v2));
end;

function TKluczForm.Wyswietl(const Sekcja :string) :Boolean;

  function ReadS( const sItem :string ) :string;
  begin
    result := ZetonFile.ReadString( Sekcja, sItem, '' );
  end;

  procedure WriteS( const sItem, sVal :string );
  begin
    ZetonFile.WriteString( Sekcja, sItem, sVal );
  end;

const
  cWlasc  = 'Wlasciciel';
  cData   = 'DataWazn';
  cNrKomp = 'NrKomp';
  cWer    = 'Wersja';
  cFlagi  = 'FlagiDostepu';

var
  Koniec  :Boolean;
  Zapisz  :Boolean;
  ZapW    :Boolean;
  d       :TDateTime;
  sd      :string;
  sDskId  :string;
  DskId   :Longint;
  sWlasc  :string;
  sKodP   :string;
  ch      :char;
  flagi   :byte;
  sFlagi  :string;

begin
  if not WerPro then
  begin
    Result := True;
    EXIT;
  end;
  Zapisz := false;
  Koniec := false;

  (*
  result := false;
  ChodziODate := false;
  sWlasc := ReadS( 'Wlasciciel' );
  ZapW := sWlasc = '';
  ERO( WlascLicEdit, not ZapW );
  if not ZapW then
    WlascLicEdit.Text := sWlasc;
  sDskId := ReadS( 'NrKomp' );
  if (sDskId <> '') then
    DskId := StrToInt( '$'+sDskId );

  if (sDskId <> '') and (sWlasc <> '') then
  begin
    if DskId = DyskId then
      begin
        sd := ReadS( 'DataWazn' );
        if sd <> '' then
        begin
          d := SToDat( sd );
          if d >= Date then
          begin
            try
              //byte(ch) := StrToInt( '$'+ReadS(cWer));
              byte(ch) := byte(StrToInt( '$'+ReadS(cWer)));

              if WerOK(ch) then
              begin
                sFlagi := ReadS( cFlagi );
                if sFlagi <> '' then
                  flagi := StrToInt(  '$'+ sFlagi )
                else
                  flagi := $01;
                SiecZezw := (flagi and KK_SIEC_ZB) <> 0;

                result := true;
                EXIT;
              end;
            except on EConvertError do
              begin
                // Jesli nic nie bylo wpicane w zeton
              end;
            end;
          end
          else
            ChodziODate := true;
        end;
      end
    else
    begin
      Koniec := false;
      //ShowMessage('Klucz z innego komputera');
    end;

  end;
  *)

  //if Koniec then
  if not Koniec then
  begin
    Application.Terminate;
    result := false;
    EXIT;
  end;

  EditWyjscie.Text := DajKompId;
  if ShowModal <> mrOK then
    Koniec := true
  else if not KodOK(EditWejscie.Text,sKodP) then
  begin
    Koniec := true;
    ShowMessage('Kod niewlasciwy');
  end
  else
  begin
    if (sKodP[1] <> 'K') then
    begin
      Koniec := true;
      ShowMessage('Klucz niewlasciwy');
    end
    else if not WerOK(sKodP[4]) then
    begin
      Koniec := true;
      ShowMessage('Klucz przeznaczony do nizszej wersji');
    end
    else
      Zapisz := true;
  end;

  if Zapisz then
  begin
    if ZapW then
    begin
      sWlasc := WlascLicEdit.Text;
      WlLic  := sWlasc;
      if sWlasc <> '' then
        WriteS( cWlasc, sWlasc )
      else
      begin
        result := false;
        Koniec := true;
        ShowMessage(  'Nie podano nazwy wlasciciela licencji'+#13
                     +'program nie moze zostac uruchomiony');
      end;
    end;

    if not Koniec then
    begin
      WriteS( cNrKomp, Format( '%x', [DyskId] ) );
      WriteS( cData, DatToS(WeDajDate(EditWejscie.Text)) );
      WriteS( cWer,  Format( '%x', [byte(sKodP[4])] ));
      flagi := byte(sKodP[2]);
      WriteS( cFlagi, Format( '%x', [flagi] ) );
      SiecZezw := (flagi and KK_SIEC_ZB) <> 0;
      result := true;
      ZetonSave;
      //ZetonFile.UpdateFile;
    end;

  end;

  if Koniec then
    //Halt(2);
    Application.Terminate;

end;

end.
