unit JezykTxt;

interface

uses
   SysUtils, Classes, WinProcs, WinTypes, Messages,
   TBS_Defs;

function  DajText( TextNum: word ): string;
procedure JezykStrings(res: TStrings);

procedure UstawJezyk( jezyk: string );
procedure ComponentSetLang( comp: TComponent );
function  ZwrocJezyk: string;

const
   UWM_SET_LANG   =     TBSM_SET_LANG;

   Plik_txt       =     1;
   Otworz_txt     =     2;
   Zapisz_txt     =     3;
   ZapiszJako_txt =     4;
   Zakoncz_txt    =     5;
   Drukuj_txt     =     6;

   Tak_txt        =     7;
   Nie_txt        =     8;
   OK_txt         =     9;
   Anuluj_txt     =    10;
   Zamknij_txt    =    11;

   Zadania_txt    =    20;

   Baza_txt       =    30;
   Wyszuk_txt     =    31;
   Przegl_txt     =    32;

   HelpLab_txt    =    50;
   AboutLab_txt   =    51;


   OknoLab_txt       = 70;
   CascadeLab_txt    = 71;
   TileLab_txt       = 72;


   KatalogPomp_txt   = 102;
   BazyDanychLab_txt = 103;
   InformacjeLab_txt = 104;
   OpcjeLab_txt      = 105;
   PompyLab_txt      = 110;
   UstDrukLab_txt    = 115;
   UstProg_txt       = 116;
   WyjscieDescr_txt  = 126;
   QuitQuery_txt     = 127;
   Confirm_txt       = 128;

   Opcje_txt      =   150;
   Glowne_txt     =   151;
   Jednostki_txt  =   152;
   Jezyk_txt      =   153;
   JezykLab_txt   =   154;

   IniFormTit_txt =   210;
   IniFormBazy_txt=   212;
   LiczbaPomp_txt =   211;

   Struktura_txt  =   220;
   WyswLab_txt    =   221;

   About_txt      =   225;
   KatPompFullName_txt = 226;
   Wersja_txt     =   227;
   Producent_txt  =   228;
   Autorzy_txt    =   229;

   PrzeglBazy_txt =   230;
   Nazwa_txt      =   231;
   Cena_txt       =   232;
   Data_txt       =   233;



   Wydajn_txt     =   250;
   WysPodn_txt    =   251;
   Temperatura_txt=   252;
   Masa_txt       =   253;
   Napiecie_txt   =   254;
   NapZnam_txt    =   255;
   Moc_txt                 = 256;
   MocZnam_txt             = 257;
   Obroty_txt              = 258;
   Prad_txt                = 259;
   PradZnam_txt            = 260;
   Cos_fi_txt              = 261;
   Sprawn_txt              = 262;

   Parametry_txt           = 301;
   Charakterystyki_txt     = 302;
   Rysunek_txt             = 303;
   Silnik_txt              = 304;
   Opis_txt                = 305;
   ParamNominalnePompy_txt = 310;
   ObrotyPompy_txt         = 311;
   ParametrySilnika_txt    = 312;
   ObrotySilnika_txt       = 313;
   TypSilnika_txt          = 314;
   OpisPompy_txt           = 315;
   Pompa_txt               = 316;


   Zast_txt      =  2500;

type
   PPCharTab = ^PCharTab;
   PCharTab = array [0..1] of PChar;

   TTextTable = class
      private
         tab: PPCharTab;
         tabLen: word;
         function  getText( num: word ): string;
         procedure setText( num: word; txt: string );
      public
         constructor create;
         destructor  destroy;              override;
         procedure Wczytaj( plik: string );
         property tekst[ num: word ]:string read getText write setText;
   end;

{============================================================================}
implementation

var
   textTable: TTextTable;
   lang: string;


{---------------------------------------------------------------------------}
constructor TTextTable.create;
begin
   inherited create;
   tabLen := $8000;
   GetMem( tab, tabLen );
   fillChar( tab^, tabLen, 0 );
end;

{---------------------------------------------------------------------------}
destructor  TTextTable.destroy;
var
   i: word;
begin
   for i := 1 to tabLen do
      if tab^[i] <> NIL then
         StrDispose( tab^[i] );
   FreeMem( tab, tabLen );
   inherited destroy;
end;

{---------------------------------------------------------------------------}
procedure TTextTable.Wczytaj( plik: string );
var
   f: TextFile;
   n: word;
   s: string;
   c: char;
begin
   AssignFile(f, plik);
   Reset(f);
   while not eof(f) do
   begin
      while SeekEoln(f) and (not eof(f)) do
         readln(f);
      if not eof(f) then
      begin
         read( f, c );
         if c = ':' then
         begin
            read( f, n );
            repeat
               read( f, c );
            until c = ';';
            readln( f, s );
            textTable.tekst[n] := s;
         end
         else if c = '#' then
            readln(f)
         else
         begin
            {ERROR}

         end;
      end;
   end;
   CloseFile(f);
end;


{---------------------------------------------------------------------------}
function  TTextTable.getText( num: word ): string;
var
   p: PChar;
begin
   {$ifopt R+}
     {$define _R_PLUS_}
     {$RANGECHECKS OFF}
   {$endif}
   p := tab^[num];
   if (p = NIL) or (num = 0) then
      getText := ''
   else
      getText := StrPas( tab^[num] );
   {$ifdef _R_PLUS_}
     {$RANGECHECKS ON}
     {$undef _R_PLUS_}
   {$endif}
end;

{---------------------------------------------------------------------------}
procedure TTextTable.setText( num: word; txt: string );
var
   p: PChar;
begin
   {$ifopt R+}
     {$define _R_PLUS_}
     {$RANGECHECKS OFF}
   {$endif}
   if num = 0 then
   else if txt <> '' then
   begin
      GetMem( p, length(txt)+1 );
      StrPcopy( p, txt );
      tab^[num] := p;
   end
   else if tab^[num] <> NIL then
   begin
      StrDispose( Tab^[num] );
      tab^[num] := NIL;
   end;
   {$ifdef _R_PLUS_}
     {$RANGECHECKS ON}
     {$undef _R_PLUS_}
   {$endif}
end;



{---------------------------------------------------------------------------}
function  DajText( TextNum: word ): string;
begin
   DajText := textTable.tekst[TextNum];
end;


{---------------------------------------------------------------------------}
procedure ComponentSetLang( comp: TComponent );
var
   num    : word;
   i, max : integer;
   txt    : string;
   done   : Boolean;

begin
  { //
  num := comp.tag;
  done := false;
  txt := DajText(num);
  if comp is TForm then
  begin
    if SendMessage( TForm(comp).Handle, UWM_SET_LANG, 0, 0 ) = 0 then
    begin
      if num <> 0 then
        TForm(comp).caption := txt;
    end
    else
      done := true;
  end
  else if (num = 0) or (txt = '') then
  begin
  end
  else if comp is TBitBtn then
  begin
    TBitBtn(comp).caption := txt;
  end
  else if comp is TButton then
  begin
    TButton(comp).caption := txt;
  end
  else if comp is TCheckBox then
  begin
    TCheckBox(comp).caption := txt;
  end
  else if comp is TDBCheckBox then
  begin
    TDBCheckBox(comp).caption := txt;
  end
  else if comp is TDBRadioGroup then
  begin
    TDBRadioGroup(comp).caption := txt;
  end
  else if comp is TGroupBox then
  begin
    TGroupBox(comp).caption := txt;
  end
  else if comp is TLabel then
  begin
    TLabel(comp).caption := txt;
  end
  else if comp is TMenuItem then
  begin
    TMenuItem(comp).caption := txt;
  end
  else if comp is TPanel then
  begin
    TPanel(comp).caption := txt;
  end
  else if comp is TRadioButton then
  begin
    TRadioButton(comp).caption := txt;
  end
  else if comp is TSpeedButton then
  begin
    TSpeedButton(comp).caption := txt;
  end;

  //if not done then
  begin
    max := comp.ComponentCount-1;
    for i := 0 to max do
       ComponentSetLang( comp.Components[i] );
  end;
  }
end;

{---------------------------------------------------------------------------}
procedure UstawJezyk( jezyk: string );
var
  FileName: string;
begin
  FileName := ExtractFilePath(ParamStr(0)) + jezyk + '.lng';
  lang := UpperCase(jezyk);
  if FileExists(FileName) then
  begin
    textTable.wczytaj(FileName);
  end;
  //ComponentSetLang(Application);
end;


{---------------------------------------------------------------------------}
function  ZwrocJezyk: string;
begin
  ZwrocJezyk := lang;
end;


{---------------------------------------------------------------------------}
procedure JezykStrings(res: TStrings);
var
  FName:       string;
  Wild:        string;
  id:          string;
  i:           integer;
  sr:          TSearchRec;
  s:           string;
  NazwaJez:    string;
  f:           TextFile;

begin
  res.Clear;

  //Wild := SciezkaWkp + '\*.lng';
  i := FindFirst( Wild, faArchive or faReadOnly, sr );
  while i = 0 do
  begin
    //FName := SciezkaWkp + '\' + sr.Name;
    id := copy( sr.Name, 1, pos( '.', sr.Name)-1 );
    AssignFile( f, FName );
    Reset(f);
    Readln( f, s );
    if (copy( s, 1, 12) = '#[.lng file]') {identyfikator} then
    begin
      s := copy( s, 13, 250);         {czesc po identyfikatorze}
      s := copy( s, pos('[',s)+1, 250 );
      s := copy( s, 1, pos(']',s)-1 );
    end
    else
      s := '';
    NazwaJez := id + ' ' + s;
    res.Add(NazwaJez);
    CloseFile(f);
    i := FindNext(sr);
  end;
  SysUtils.FindClose(sr);

end;


BEGIN
  textTable := TTextTable.Create;
END.
