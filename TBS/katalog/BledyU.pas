unit BledyU;

interface

uses
  Classes,
  SysUtils,
  Contnrs,
  Windows;

type
  { Deklaracje naszych wyjatkow }


    /// <summary>
    /// Podstawowa klasa naszych wyj¹tków
    /// </summary>
    ePDP_Exception = class(Exception);
    ePDP_ExceptionClass = class of ePDP_Exception;


    ePDP_BladPliku           = class(ePDP_Exception);
    ePDP_NieMoznaCzytac      = class(ePDP_Exception);

    // Sprawdzanie projektu
    ePDP_NielegPolZawDoZb    = class(ePDP_Exception); // 219 Nielgalne podlaczenie zaworu do zbiornika
    ePDP_NielegPolZawDoZaw   = class(ePDP_Exception); // 220 Nielgalne podlaczenie zaworu do zaworu
    ePDP_ZaMaloWezlow        = class(ePDP_Exception); // 223 mniej niz dwa nody w projekcie
    ePDP_NieMaZbiornika      = class(ePDP_Exception); // 224 nie ma ani rez ani zbiornika w projekcie
    ePDP_NiePodlWezel        = class(ePDP_Exception); // 233 nie podlaczony wezel do sieci
    //ePDP_NiePodlWezelTerm    = class(ePDP_Exception); // 233 nie podlaczony wezel do sieci obl. cieplnych
    ePDP_ZerowaSrednicaZaw   = class(ePDP_Exception);
    ePDP_ZerowaDlugoscZaw    = class(ePDP_Exception);
    ePDP_ZerowaSrednicaRury  = class(ePDP_Exception);
    ePDP_ZerowaDlugoscRury   = class(ePDP_Exception);
    ePDP_ZerowaSrednicaPompy = class(ePDP_Exception);
    ePDP_ZerowaDlugoscPompy  = class(ePDP_Exception); // ?? czy to jest istotne
    ePDP_PodwojnyLinkTerm    = class(ePDP_Exception); // podwojny link w obliczeniach termicznych



    ePDP_Warning = class
    private
      message: string;
    public
      constructor Create(s: string);
    end;

    ePDP_WarningClass = class of ePDP_Warning;

    // Ostrze¿enia

    wPDP_OdlaczonyNod      = class( ePDP_Warning );
    wPDP_UjemneCis         = class( ePDP_Warning ); // WARN06 ujemne cisnienie w wezle
    wPDP_UjemnaTemp        = class( ePDP_Warning );
    wPDP_UjemnaRoznicaTemp = class( ePDP_Warning );
    wPDP_RoznicaPoziomow   = class( ePDP_Warning );
    wPDP_SredZewMala       = class( ePDP_Warning );
    wPDP_PumpZaDuzeQ       = class( ePDP_Warning );
    wPDP_PumpZaMaleH       = class( ePDP_Warning );
  	wPDP_UjemnyWspWypl     = class( ePDP_Warning );
    wPDP_UjemnyPoziom      = class( ePDP_Warning );
    wPDP_UjemnyPrzeplyw    = class( ePDP_Warning );
    wPDP_NiePodlWezelTerm  = class( ePDP_Warning );  // 233 nie podlaczony wezel do sieci obl. cieplnych

  TBledy = class (TPersistent)
  private
    lista : TObjectList;//<ePDP_Warning>;
  protected
    procedure AssignTo(Dest :TPersistent); override;
  public
    constructor Create;
    destructor Destroy;

    procedure DodajBlad(eType: ePDP_ExceptionClass; s: string);
    procedure DodajOstrzerzenie(wType: ePDP_WarningClass; s: string); overload;
    procedure DodajOstrzerzenie(wType: ePDP_Warning); overload;


    function CzySaOstrzerzenia : boolean;
    function DajOstrzerzenia : string;

    procedure Wyczysc;

  end;


var
  Bledy : TBledy;

implementation



{ TBledy }

procedure TBledy.AssignTo(Dest: TPersistent);
var
  i :Integer;
  sDst :TStrings;
begin
  if Dest is TStrings then
  begin
    sDst := TStrings(Dest);
    sDst.Clear;
    for i := 0 to lista.Count-1 do
      if lista[i] is Exception then
        sDst.AddObject(Exception(lista[i]).Message, lista[i])
      else if lista[i] is ePDP_Warning then
        sDst.AddObject(ePDP_Warning(lista[i]).Message, lista[i])
  end
  else
    inherited;

end;

constructor TBledy.Create;
begin
  lista := TObjectList.Create;
end;

function TBledy.CzySaOstrzerzenia: boolean;
begin
  if lista.Count > 0 then result := true else result := false;

end;

function TBledy.DajOstrzerzenia: string;
var
  warn : ePDP_Warning;
  i : integer;
begin
  for i:= 0 to lista.Count-1 do
    result := result + ePDP_Warning(lista[i]).message + sLineBreak;
end;

destructor TBledy.Destroy;
begin
  lista.Destroy;
end;

procedure TBledy.DodajBlad(eType: ePDP_ExceptionClass; s: string);
var
  exc: ePDP_Exception;
begin
  exc := eType.Create(s);
//  lista.Add(exc);
  raise exc;
end;

procedure TBledy.DodajOstrzerzenie(wType: ePDP_WarningClass; s: string);
var
  warn: ePDP_Warning;
begin
  warn := wType.Create(s);
  lista.Add(warn);

end;

procedure TBledy.DodajOstrzerzenie(wType: ePDP_Warning);
begin
  lista.Add(wType);
end;

procedure TBledy.Wyczysc;
begin
  lista.Clear;
end;

{ ePDP_Warning }

constructor ePDP_Warning.Create(s: string);
begin
  message := s;
end;

end.

