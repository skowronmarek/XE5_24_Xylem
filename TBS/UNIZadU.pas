unit UNIZadU;

interface

uses
  SysUtils, Classes, Graphics, Forms, Controls,
  KRMath, DGraph, Diagrams, TbsU,
  PompySQL, PumpIntf, OPompa,
  ZadPompSzuk, KopZadU, Ciecze,
  StdZadSzukPomp;

type

  TUNIZad = class (TStdZadSzukPomp)  //glowny obiekt zadania
  private
    //wartosci fizyczne
    FHzs      :Double;    //geometryczna wysokosc ssania
    FHzt      :Double;    //geometryczna wysokosc tloczenia
    FPzs      :Double;    //cisnienie z zbiorniku ssawnym
    FPzt      :Double;    //cisnienie z zbiorniku tlocznym
    FTemp     :Double;    //temperatura cieczy (wody)
    FPbar     :Double;    //cisnienie barometryczne hPa
    FHss      :Double;
    FHst      :Double;
    FZ1Hst    : double;
    FZ1Hss    : double;
    FHt       :Double;
    FHs       :Double;
 //   FNPSHu    :Double;
 //   FNPSHr    :Double;      //czy to ma zostac
    FSsaIndex :integer;
    FTloIndex :integer;
    FKopS     :TKopZad;
    FKopT     :TKopZad;
    FdNPSH     :Double;       // zapas na pogode
    FCiecz    :TCieczPlyw;
    function GetHss:double;
    function GetHst:double;
    procedure SetHss(const Value: double);
    procedure SetHst(const Value: double);
    function GetKopS: TKopZad;
    function GetKopT: TKopZad;
    procedure SetKopS(const Value: TKopZad);
    procedure SetKopT(const Value: TKopZad);
    function GetCiecz: TCieczPlyw;
    procedure SetCiecz(const Value: TCieczPlyw);
    procedure SetTemp(const Value: Double);

  protected
    procedure CreateMainForm;          override;
    function  PompaOK( Pmp :TPompa ) :Boolean;     override;
    function  WarunekWst( DB :TDBPompy ) :Boolean; override;
    procedure CreateKopS;
    procedure CreateKopT;
    function  AskWritePumpList :Boolean;           override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
                                                   override;

  public
    function JestKopS : boolean;
    function JestKopT : boolean;
    constructor Create( O :TComponent );           override;
    destructor Destroy;                            override;
    function TemperaturaOK(Tmin,Tmax:real):boolean;
    //property  Ciecz      :TCieczPlyw write SetCiecz;

  published
    property  Hzs        :Double  read FHzs   write FHzs;
    property  Hzt        :Double  read FHzt   write FHzt;
    property  Pzs        :Double  read FPzs   write FPzs;
    property  Pzt        :Double  read FPzt   write FPzt;
    property  Temp       :Double  read FTemp  write SetTemp;
    property  Pbar       :Double  read FPbar  write FPbar;
    property  Hss        :Double  read GetHss write SetHss;
    property  Z1Hss      :double  read FZ1Hss write FZ1Hss  ;   //wspol. wysokosc strat cisnienia na tloczeniu
    property  Hst        :Double  read GetHst write SetHst;
    property  Z1Hst      :double  read FZ1Hst write FZ1Hst  ;   //wspol. wysokosc strat cisnienia na tloczeniu

    property  Ht         :Double  read FHt    write FHt;
    property  Hs         :Double  read FHs    write FHs;
    property  dNPSH      :Double  read FdNPSH write FdNPSH;
    property  SsaIndex   :integer read FSsaIndex write FSsaIndex;
    property  TloIndex   :integer read FTloIndex write FTloIndex;
    property  KopS       :TKopZad read GetKopS write SetKopS
                                  stored JestKopS;
    property  KopT       :TKopZad read GetKopT write SetKopT
                                  stored JestKopT;
  end;


implementation

uses
  ZadFrmU, StdZadFrmU, UNIZadMainForm;

{-------------------------------------------------------------------------}
procedure TUNIZad.CreateMainForm;
var
  F       :TUNIZadForm;
begin
  F := TUNIZadForm.Create(self);
  F.Zad := self;
  FMainForm := F;
end;

constructor TUNIZad.Create( O :TComponent );
begin
  inherited Create( O );
  //FreeWithForm := true;
  Qw := 10;       //Domyslne parametry UNI
  Hst:= 10;
  Hzt := 0;
  Temp:= 20;
  Pbar:= 1013;
  //CreateKopS;
  //CreateKopT;
  QMinTol := 0.9;
  QMaxTol := 1.1;
  HMinTol := 0.9;
  HMaxTol := 1.1;
  WlaczSprawdzanie := TRUE;
  SprawdzajNPSH := TRUE;
  SprawdzajTEMP := TRUE;
  dNPSH:=0.5;
  //FCiecz := CreateH2OPlyw(self, 10, Temp);
  //FCiecz.Name := 'Ciecz';
  if FMainForm <> NIL then
    (FMainForm as TZadForm).Aktualizuj;
end;

function TUNIZad.GetHss:double;
begin
  if JestKopS then
   begin
     if Ciecz <> NIL then      // na wszelki wypadek
       Result := KopS.dH(Qw)
     else
       Result := KopS.Hstrat;
     if Qw<>0 then
       fZ1Hss := f_DIV( KopS.Hstrat, Qw*Qw )
     else
       fZ1Hss := 0.0
   end
 else if Qw <> 0 then
   Result := fZ1Hss*Qw*Qw;
end;

procedure TUNIZad.SetHss(const Value: double);
begin
 fHss:=Value;
 if (qw<>0) then Z1Hss := F_DIV( fHss, Qw*Qw)
            else Z1Hss := 0;
end;

function TUNIZad.GetHst:double;
begin
 if JestKopT then
   begin
     if Ciecz <> NIL then   // na wszelki wypadek
       Result := KopT.dH(Qw)
     else
       Result := KopT.Hstrat;
     if Qw<>0 then fZ1Hst := F_DIV(KopT.Hstrat, Qw*Qw)
              else fZ1Hst := 0.0
   end
 else
   Result := fZ1Hst*Qw*Qw;
end;

procedure TUNIZad.SetHst(const Value: double);
begin
 fHst:=Value;
 if (qw<>0) then Z1Hst := f_div( fHst, Qw*Qw)
            else Z1Hst := 0;
end;


destructor TUNIZad.Destroy;
begin
  inherited Destroy;
end;

function TUNIZad.TemperaturaOK(Tmin,Tmax:real):Boolean;
begin
  if (Temp>=Tmin) and (Temp<=Tmax)
    then result:= True
    else result:= False;
end;

function  TUNIZad.WarunekWst( DB :TDBPompy ) :Boolean;
begin
  if SprawdzajTEMP
    then result := (inherited WarunekWst(DB) )
            and TemperaturaOK(DB.T.FieldByName('T_MIN').AsFloat,
                              DB.T.FieldByName('T_MAX').AsFloat)
    else result := inherited WarunekWst(DB);
end;

function TUNIZad.PompaOK(Pmp: TPompa): Boolean;
var
  NPSHukladu : real;
begin
 if inherited pompaOK(Pmp) then
    begin
      if SprawdzajNPSH
        then
          begin
            NPSHukladu := NPSHu+Hss
                          - F_DIV( Hss, Qw*Qw) *pmp.Qr*pmp.Qr - dNPSH;
            if NPSHukladu>Pmp.NPSHr
              then
                begin
                  pmp.WDobroci:=pmp.WDobroci
                     +fNPSH*(NPSHukladu-Pmp.NPSHr)/10;
                  result := True
                end
              else result := False
          end
        else result := True;
    end
   else result:=False;
end;

function TUNIZad.GetKopS: TKopZad;
begin
  if FKopS = NIL then
    CreateKopS;
  Result := FKopS;
end;

function TUNIZad.GetKopT: TKopZad;
begin
  if FKopT = NIL then
    CreateKopT;
  Result := FKopT;
end;

procedure TUNIZad.CreateKopS;
begin
  FKopS := TKopZad.Create(self);
  FKopS.Name := 'KopS';
  FKopS.Ciecz := CieczPlyw;
  FKopS.EdycjaCieczy := false;
  FKopS.FreeWithForm := false;

end;

procedure TUNIZad.CreateKopT;
begin
  FKopT := TKopZad.Create(self);
  FKopT.Name := 'KopT';
  FKopT.Ciecz := CieczPlyw;
  FKopT.EdycjaCieczy := false;
  FKopT.FreeWithForm := false;
end;

function TUNIZad.JestKopS: boolean;
begin
  result := FKopS <> NIL;
end;

function TUNIZad.JestKopT: boolean;
begin
  result := FKopT <> NIL;
end;

procedure TUNIZad.SetKopS(const Value: TKopZad);
begin
  if Value <> FKopS then
  begin
    FKopS.Free;
    FKopS := Value;
    FKopS.Name := 'KopS';
    FKopS.FreeWithForm := false;
    FKopS.Ciecz := CieczPlyw;
  end;
end;

procedure TUNIZad.SetKopT(const Value: TKopZad);
begin
  if Value <> FKopT then
  begin
    FKopT.Free;
    FKopT := Value;
    FKopT.Name := 'KopT';
    FKopT.FreeWithForm := false;
    FKopT.Ciecz := CieczPlyw;
  end;
end;


procedure TUNIZad.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FKopS then
      FKopS := NIL
    else if AComponent = FKopT then
      FKopT := NIL
    else if AComponent = Ciecz then
      FCieczPlyw := NIL;
  end;
  inherited Notification( AComponent, Operation );
end;


function TUNIZad.GetCiecz: TCieczPlyw;
begin
  result := FCiecz;
end;

procedure TUNIZad.SetCiecz(const Value: TCieczPlyw);
begin
  if Value <> FCiecz then
  begin
    FCiecz.Free;
    FCiecz := Value;
    if Value <> NIL then
      //Ciecz.T := FTemp;
    if JestKopS then
      KopS.Ciecz := Value;
    if JestKopT then
      KopT.Ciecz := Value;
  end;
end;

procedure TUNIZad.SetTemp(const Value: Double);
begin
  FTemp := Value;
  if Ciecz <> NIL then
    FCieczPlyw.T := Value;
end;

function TUNIZad.AskWritePumpList: Boolean;
begin
  result := false;
end;

initialization
  if ZetonFile.ReadBool('Katalog\Zadania\Pompy', 'Uniwersalny', false ) then
    RegisterClass(TUNIZad);


end.
