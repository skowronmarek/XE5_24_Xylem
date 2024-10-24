unit FiltZadFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ZadFrmU, StdCtrls, EditNew, FiltZadU, Buttons, ComCtrls, ExtCtrls, Gauges,
  Grids, DB, DBTables, Math,
  Prod, ZadU, ZadPompSzuk,
  ZastFrm,
  KonstrFrm, TypyListFrm, PmpZnalFrm,
  KR_Class, KR_Sys, ObjView, KR_DB,
  WkpGlob, Tbs_Tool, TBS_defs, PompySQL, OPompa, FiltryRes,
  PropertyAccesserU, FormSaverU, Diagrams, ObszCharMgrU, FiltOptFormU;

type
  TFiltrPompForm = class(TZadForm)
    StatusPanel: TPanel;
    GaugePanel: TPanel;
    Postep: TGauge;
    Timer: TTimer;
    MsgPanel: TPanel;
    HintPanel: TPanel;
    HintMemo: TMemo;
    MainPanel: TPanel;
    RightPanel: TPanel;
    dfunObszScale: TDiagFunction;
    LeftPanel: TPanel;
    PokazBtn: TSpeedButton;
    Label1: TLabel;
    LicznikLab: TLabel;
    LiczbaPompLab: TLabel;
    QPanel: TPanel;
    ZakrQLab: TLabel;
    QLab: TLabel;
    Q_Edit: TEditN;
    HPanel: TPanel;
    HLab: TLabel;
    H_Edit: TEditN;
    TempPanel: TPanel;
    ZakrTempLab: TLabel;
    TempLab: TLabel;
    TempEdit: TEditN;
    ZastPanel: TPanel;
    ZastBtn: TSpeedButton;
    ZastLab: TLabel;
    KonstrPanel: TPanel;
    KonstrBtn: TSpeedButton;
    KonstrLab: TLabel;
    TypPanel: TPanel;
    TypLab: TLabel;
    TypyBtn: TSpeedButton;
    PageControl: TPageControl;
    TabZdjecie: TTabSheet;
    Rys: TObjectView;
    TabObszar: TTabSheet;
    diagObszary: TDiagram;
    sbtnZakres: TSpeedButton;
    dgdscrQ: TDiagDescr;
    dgdscrH: TDiagDescr;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerTimer(Sender: TObject);
    procedure ZastBtnClick(Sender: TObject);
    procedure KonstrBtnClick(Sender: TObject);
    procedure PokazBtnClick(Sender: TObject);
    procedure TypyBtnClick(Sender: TObject);
    procedure Q_EditAccept(Sender: TObject; var Accept: Boolean);
    procedure H_EditAccept(Sender: TObject; var Accept: Boolean);
    procedure TempEditAccept(Sender: TObject; var Accept: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnZakresClick(Sender: TObject);
    procedure TabObszarResize(Sender: TObject);
  private
    ZastFrm  :TZastosForm;
    KonstrFrm:TKonstrForm;
    TypyForm :TTypyForm;
    FPompyZnalezFrm :TPompyZnalezFrm;
    svHint :TNotifyEvent;
    svShowHint :TShowHintEvent;
    fActivHint :Boolean;
    FOldSzukanie :Boolean;
    FObszList  :TObszarCharList;
    FOptForm   :TFiltOptForm;

    FHintControl :TControl;
    function GetZadanie: TFiltrPompZad;
    procedure SetMsg(const Value: string);
    function GetMsg: string;
    procedure SzukanieControlsEnabled( v :Boolean );
    procedure HintDeactiv;
    procedure ShowHint( Sender :TObject );
    procedure UstawObszary;
    procedure AddPumpEv( APmp :TPompa; ADB :TDBPompy );

  protected
    procedure SetZad( v :TZadanie );         override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure EditAccSetColor( E :TEditN );
    {ws 15 luty 2006}
    procedure TBSM_Unit( var msg :TMessage ); message TBSM_UNIT;
    {ws 15 luty 2006}
  public
    { Public declarations }
    constructor Create( O :TComponent );     override;
    destructor Destroy;                      override;
    procedure Aktualizuj;                    override;
    procedure Szukaj;
    property Zadanie :TFiltrPompZad read GetZadanie;
    property Msg     :string read GetMsg write SetMsg;
  end;

var
  FiltrPompForm: TFiltrPompForm;


implementation

{$R *.DFM}

function TFiltrPompForm.GetZadanie: TFiltrPompZad;
begin
  result := Zad as TFiltrPompZad;
end;

procedure TFiltrPompForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  inherited;

end;

procedure TFiltrPompForm.TimerTimer(Sender: TObject);
begin
  inherited;
  Postep.Progress     := Zadanie.PompPrzeszuk;
  LicznikLab.Caption  := IntToStr( Zadanie.PumpCount );
  ZakrQLab.Caption := Format( '(%f..%f) '+CapQ, [m3hToU(Zadanie.QMin), m3hToU(Zadanie.QMax)] );
  ZakrTempLab.Caption := Format( '(%f..%f) °C', [Zadanie.TMin, Zadanie.TMax] );
end;

constructor TFiltrPompForm.Create(O: TComponent);
begin
  inherited Create(O);
  ZastFrm   := TZastosForm.Create(self);
  KonstrFrm := TKonstrForm.Create(self);
  TypyForm  := TTypyForm.Create(self);
  FOptForm  := TFiltOptForm.Create(self);
  if WerProdPomp then
  begin
    TypyForm.Init( Producenci.ProdByName(GlobProdId).InfoBaz['PUMPS'].TBSFName,
                 'STRUCTURE' );
  end
  else
  begin
    TypyForm.Init( 'STRUCTURE' );
  end;
end;

destructor TFiltrPompForm.Destroy;
begin
  FObszList.Free;
  inherited Destroy;
end;

procedure TFiltrPompForm.ZastBtnClick(Sender: TObject);
var
  s       :string;
  i       :Integer;
  WLiscie :Boolean;
  n, c    :Integer;
  a : TFormatSettings;

begin
  inherited;
  ZastFrm.WszystkieZast := Zadanie.ZastDost;
  ZastFrm.WybraneZast := Zadanie.ZastosowaniaList;
  ZastFrm.ShowModal;
  if ZastFrm.ModalResult = mrOK then
  begin
    WLiscie := StringsContains( Zadanie.ZastosowaniaList,
                                ZastFrm.WybraneZast );
    Zadanie.ZastosowaniaList := ZastFrm.WybraneZast;
    s := '';

    c := 0;
    if Zadanie.ZastosowaniaList.Count > 3 then
      n := ceil(Zadanie.ZastosowaniaList.Count / 3)
    else
      n := 1;

    for i := 0 to ZastFrm.CheckList.Items.Count-1 do
      if ZastFrm.CheckList.Checked[i] then
      begin
        s := s + ZastFrm.CheckList.Items[i];
        inc(c);
        if c < ZastFrm.CheckList.Items.Count then
        begin
          if (c mod n) = 0 then
            s := s + #13
          else
            s := s + a.ListSeparator + '  ';

        end;
      end;
    if s <> '' then
      ZastBtn.Caption := s
    else
      ZastBtn.Caption := '...';
    if not WLiscie then
      Zadanie.SzukajWLiscie := false;
    Szukaj;
  end;
end;

procedure TFiltrPompForm.KonstrBtnClick(Sender: TObject);
var
  s       :string;
  i       :Integer;
  WLiscie :Boolean;
  n, c    :Integer;
  a : TFormatSettings;

begin
  inherited;
  KonstrFrm.WszystkieKonstr := Zadanie.KonstrDost;
  KonstrFrm.WybraneKonstr := Zadanie.KonstrukcjaList;
  KonstrFrm.ShowModal;
  if KonstrFrm.ModalResult = mrOK then
  begin
    WLiscie := StringsContains( Zadanie.KonstrukcjaList,
                                KonstrFrm.WybraneKonstr );
    Zadanie.KonstrukcjaList := KonstrFrm.WybraneKonstr;
    s := '';

    c := 0;
    if Zadanie.KonstrukcjaList.Count > 3 then
      n := ceil(Zadanie.KonstrukcjaList.Count/3)
    else
      n := 1;

    for i := 0 to KonstrFrm.CheckList.Items.Count-1 do
      if KonstrFrm.CheckList.Checked[i] then
      begin
        s := s + KonstrFrm.CheckList.Items[i];
        inc(c);
        if c < KonstrFrm.CheckList.Items.Count then
        begin
          if (c mod n) = 0 then
            s := s + #13
          else
            //s := s + ListSeparator + '  ';
            s := s + a.ListSeparator + '  ';

        end;
      end;

    if s <> '' then
      KonstrBtn.Caption := s
    else
      KonstrBtn.Caption := '...';
    if not WLiscie then
      Zadanie.SzukajWLiscie := false;
    Szukaj;
  end;
end;

procedure TFiltrPompForm.TypyBtnClick(Sender: TObject);
var
  s       :string;
  i       :Integer;
  WLiscie :Boolean;
  n, c    :Integer;
  a : TFormatSettings;


begin
  inherited;
  TypyForm.WszystkieTypy := Zadanie.TypyDost;
  TypyForm.WybraneTypy := Zadanie.TypyDozw;
  if TypyForm.ShowModal = mrOK then
  begin
    WLiscie := StringsContains( Zadanie.TypyDozw, TypyForm.WybraneTypy );
    Zadanie.TypyDozw.Assign( TypyForm.WybraneTypy );
    s := '';

    c := 0;
    if Zadanie.TypyDozw.Count > 3 then
      n := ceil(Zadanie.TypyDozw.Count / 3)
    else
      n := 1;

    for i := 0 to TypyForm.WybraneTypy.Count-1 do
    begin
      s := s + TypyForm.WybraneTypy[i];
      inc(c);
      if c < TypyForm.WybraneTypy.Count then
      begin
        if (c mod n) = 0 then
          s := s + #13
        else
          //s := s + ListSeparator + '  ';
          s := s + a.ListSeparator + '  ';

      end;
    end;
    if s <> '' then
      TypyBtn.Caption := s
    else
      TypyBtn.Caption := '...';
    if not WLiscie then
      Zadanie.SzukajWLiscie := false;
    Szukaj;
  end;
end;

procedure TFiltrPompForm.SetZad(v: TZadanie);
var
  sZdj    :string;
  FN      :string;
  tab     :TTable;
  sTab    :string;
  bi      :TBaseInfo;
begin
  inherited SetZad(v);

  tab := NIL;

  if Zadanie.Caption <> '' then
    Caption := Zadanie.Caption;

  sZdj := StrParseStr( Zadanie.ParamStr, 'ZDJ', '' );
   {ws 15 luty 2006}
  if (sZdj <> '') and FileExists (Producenci.ProdByName(GlobProdId).SciezkaDoBaz + sZdj) then
  begin
    rys.LoadFromFile(Producenci.ProdByName(GlobProdId).SciezkaDoBaz + szdj);
    rys.Stretch := true;
    rys.Propor := true;
    rys.UpdateResizePars;
  end else
  {ws 15 luty 2006}
  if sZdj <> '' then
  begin
    if WerProdPomp then
    begin
      try
        bi := Producenci.ProdByName( GlobProdId ).InfoBaz['PUMPS']
              as TBaseInfo;
      except
      on EInvalidCast do
        bi := NIL;
      end;
      if bi <> NIL then
      begin
        sTab := bi.GetBaseName('B');
        if FileExists(sTab) then
        begin
          tab := TTable.Create(self);
          TableSetNames( sTab, tab );
          tab.Open;
          try
            if tab.Locate( 'ID', sZdj, [] ) then
              ObjViewFromBinBase( Rys, tab );
          finally
            tab.Free;
          end;
        end;
      end;
    end
    else
    begin
      FN := SciezkaBmp + sZdj;
      if FileExists(FN) then
        Rys.LoadFromFile( FN, '/STRETCH /PROPOR /CENTER' );
    end;
  end;
  Zadanie.OnAddPump := AddPumpEv;
  Msg := 'Przeszukiwanie wstepne';
  Szukaj;
end;

procedure TFiltrPompForm.SetMsg(const Value: string);
begin
  MsgPanel.Caption := Value;
end;

function TFiltrPompForm.GetMsg: string;
begin
  result := MsgPanel.Caption;
end;

procedure TFiltrPompForm.Aktualizuj;
var
  szuk    :Boolean;
begin
  inherited Aktualizuj;
  szuk := Zadanie.State = zspsSzukanie;
  if FOldSzukanie <> szuk then
  begin
    if szuk then
      FObszList.Clear
    else
      UstawObszary;
    FOldSzukanie := szuk;
  end;
  SzukanieControlsEnabled( not szuk );
end;

procedure TFiltrPompForm.SzukanieControlsEnabled(v: Boolean);
begin
  Q_Edit.Enabled := v;
  H_Edit.Enabled := v and (not Q_Edit.Empty);
  TempEdit.Enabled := v;

  ZastBtn.Enabled := v;
  KonstrBtn.Enabled := v;
  TypyBtn.Enabled := v;
end;

procedure TFiltrPompForm.PokazBtnClick(Sender: TObject);
var
  F       :TPompyZnalezFrm;
begin
  inherited;
  Zadanie.PamietajObiekty := true;
  if FPompyZnalezFrm = NIL then
  begin
    F := TPompyZnalezFrm.Create( self );
    F.Zad := Zadanie;
    F.ProgressPanel.Hide;
    FPompyZnalezFrm := F;
  end
  else
    F := FPompyZnalezFrm;
  if not Zadanie.SaObiekty then
    Szukaj;
  F.Aktualizuj;
end;

procedure TFiltrPompForm.Szukaj;
var
  WLiscie  :Boolean;
begin
  cursor := crHourGlass;
  WLiscie := Zadanie.SzukajWLiscie;
  if Zadanie.SprQ and (Q_Edit.Empty or Q_Edit.Modified) then
    WLiscie := false;
  Q_Edit.Modified := false;
  Zadanie.SprQ := not Q_Edit.Empty;

  {ws 15 luty 2006}
  if Zadanie.SprQ then
    Zadanie.Qw := UTom3h(Q_Edit.ValueFloat);
  {ws 15 luty 2006}

  if Zadanie.SprawdzajPPracy      // byl sprawdzany punkt pracy
     and ( (not (Zadanie.SprQ and (not H_Edit.Empty))) // ... a teraz nie bedzie
           or H_Edit.Modified )                         //   lub Hw sie zmienilo
        then
    WLiscie := false;
  H_Edit.Modified := false;

  Zadanie.SprawdzajPPracy := Zadanie.SprQ and (not H_Edit.Empty);
  if Zadanie.SprawdzajPPracy then
    Zadanie.Hw := H_Edit.ValueFloat;
  if Zadanie.CheckTemp and (TempEdit.Empty or TempEdit.Modified) then
    WLiscie := false;
  TempEdit.Modified := false;

  Zadanie.CheckTemp := not TempEdit.Empty;
  if Zadanie.CheckTemp then
    Zadanie.Temp      := TempEdit.ValueFloat;

  Zadanie.SzukajWLiscie := WLiscie;
  if not WLiscie and (FPompyZnalezFrm <> NIL) then
  begin
    FPompyZnalezFrm.Free;
    FPompyZnalezFrm := NIL;
  end;
  Zadanie.PamietajObiekty := (FPompyZnalezFrm <> NIL) or
                             (Zadanie.SprawdzajPPracy);

  Zadanie.PrzygotujSzukanie;
  if FPompyZnalezFrm <> NIL then
  begin
    FPompyZnalezFrm.AktualTimer.Enabled := true;
    FPompyZnalezFrm.Show;
  end;
  Postep.MaxValue := Zadanie.TotalPomp;
  if Zadanie.SzukajWLiscie then
    Msg := 'Zaciesnianie kryterium'
  else
    Msg := 'Przeszukiwanie calej bazy';
  Timer.Enabled   := true;
  Zadanie.SzukajPomp;
  PokazBtn.Enabled := (0 < Zadanie.PumpCount)
                      and (Zadanie.PumpCount <= 100);
  Timer.Enabled   := false;
  TimerTimer(Timer);
  Msg := '';
  cursor := crDefault;
end;

procedure TFiltrPompForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FPompyZnalezFrm then
      FPompyZnalezFrm := NIL;
  end;
  inherited Notification( AComponent, Operation );
end;

procedure TFiltrPompForm.Q_EditAccept(Sender: TObject;
  var Accept: Boolean);
var
  aMod        :Boolean;
begin
  inherited;
  aMod := Q_Edit.Modified;
  //Q_Edit.Modified := false;
  if not Q_Edit.Empty then
  {ws 15 luty 2006}
    Accept := (Zadanie.QMin <= UTom3h(Q_Edit.ValueFloat))
              and (UTom3h(Q_Edit.ValueFloat) <= Zadanie.QMax);
  {ws 15 luty 2006}
  H_Edit.Enabled := not Q_Edit.Empty;
  EditAccSetColor( Q_Edit );
  if Accept then
  begin
    if aMod then
      Szukaj;
  end
  else
    ShowMessageFmt( 'Dopuszczalna wydajnosc %.1f - %.1f',
                    [ m3hToU(Zadanie.QMin), m3hToU(Zadanie.QMax) ] );

end;

procedure TFiltrPompForm.H_EditAccept(Sender: TObject;
  var Accept: Boolean);
var
  aMod        :Boolean;
begin
  inherited;
  aMod := H_Edit.Modified;
  //H_Edit.Modified := false;
  EditAccSetColor( H_Edit );
  if aMod then
    Szukaj;
end;

procedure TFiltrPompForm.EditAccSetColor(E: TEditN);
begin
  if E.Empty then
  begin
    E.ColorOnNotFocus := clWindow;
    E.FontColorOnNotFocus := clWindowText;
  end
  else
  begin
    E.ColorOnNotFocus := clWindow;
    E.FontColorOnNotFocus := clWindowText;
  end;
end;

procedure TFiltrPompForm.TempEditAccept(Sender: TObject;
  var Accept: Boolean);
var
  aMod        :Boolean;
begin
  inherited;
  aMod := TempEdit.Modified;
  //TempEdit.Modified := false;
  EditAccSetColor( TempEdit );
  if not TempEdit.Empty then
    Accept := (Zadanie.TMin <= TempEdit.ValueFloat)
              and (TempEdit.ValueFloat <= Zadanie.TMax);
  if Accept then
  begin
    if aMod then
      Szukaj
  end
  else
    ShowMessageFmt( 'Dopuszczalna temperatura %.1f - %.1f',
                    [ Zadanie.TMin, Zadanie.TMax ] );
end;

procedure TFiltrPompForm.FormActivate(Sender: TObject);
begin
  inherited;
  svHint := Application.OnHint;
  Application.OnHint := ShowHint;
  //svShowHint := Application.OnShowHint;
  //Application.OnShowHint := SShowHint;
  fActivHint := true;
end;


procedure TFiltrPompForm.ShowHint(Sender: TObject);
var
  h       :string;
  HintControl :TControl;
begin
  HintControl := FindVCLWindow( Mouse.CursorPos );
  if HintControl <> NIL then
    if (HintControl = self) or (HintControl.Owner = self) then
    begin
      h := Application.Hint;
      h := GetLongHint(h);
      HintMemo.Text := h;
    end
    else if @svHint <> NIL then
      svHint(Sender);
  FHintControl := NIL;
end;

procedure TFiltrPompForm.FormDeactivate(Sender: TObject);
begin
  inherited;
  HintDeactiv;
end;

procedure TFiltrPompForm.HintDeactiv;
begin
  if fActivHint then
  begin
    Application.OnHint := svHint;
    svHint := NIL;
    //Application.OnShowHint := svShowHint;
    //svShowHint := NIL;
    fActivHint := false;
  end;
end;

procedure TFiltrPompForm.FormDestroy(Sender: TObject);
begin
  inherited;
  HintDeactiv;
end;


procedure TFiltrPompForm.FormCreate(Sender: TObject);
begin
  inherited;
  QPanel.Hint    := SQPanelHint;
  HPanel.Hint    := SHPanelHint;
  TempPanel.Hint := STempPanelHint;
  ZastPanel.Hint   := SZastPanelHint;
  KonstrPanel.Hint := SKonstrPanelHint;
  TypPanel.Hint    := STypPanelHint;
  FObszList := TObszarCharList.CreateDg( diagObszary, dfunObszScale );
end;

procedure TFiltrPompForm.UstawObszary;
begin
  FObszList.Prepare;
  {ws 15 lutego 2006}
  diagObszary.XJednostki := m3hToU(1);
  diagObszary.CountMaxXR(FObszList.MaxX);
  dgdscrQ.Text := CapQ;
  {ws 15 lutego 2006}
  diagObszary.Invalidate;
end;

procedure TFiltrPompForm.AddPumpEv(APmp: TPompa; ADB: TDBPompy);
var
  P       :TPompa;
begin
  if APmp <> NIL then
    P := APmp
  else
    P := CreatePump( NIL, ADB );
  P.AddRef;
  FObszList.AddChar(P);
  P.Release;
end;

procedure TFiltrPompForm.sbtnZakresClick(Sender: TObject);
begin
  inherited;
  with FOptForm do
  begin
    QMinFak := Zadanie.QMinTol;
    QMaxFak := Zadanie.QMaxTol;
    HMinFak := Zadanie.HMinTol;
    HMaxFak := Zadanie.HMaxTol;
    Modified := False;
    if Execute and Modified then
    begin
      Zadanie.QMinTol := QMinFak;
      Zadanie.QMaxTol := QMaxFak;
      Zadanie.HMinTol := HMinFak;
      Zadanie.HMaxTol := HMaxFak;
      if not (Q_Edit.Empty or H_Edit.Empty) then
      begin
        Zadanie.SzukajWLiscie := False;
        Szukaj;
      end;
    end;
  end;
end;

procedure TFiltrPompForm.TabObszarResize(Sender: TObject);
begin
//  inherited;
//  diagObszary.XJednostki := 1/UTom3h(1);
//  dgdscrQ.Text := CapQ;
end;

procedure TFiltrPompForm.TBSM_Unit(var msg: TMessage);
begin
  TimerTimer(nil);
  diagObszary.XJednostki := m3hToU(1);
  diagObszary.CountMaxXR(diagObszary.MaxXR);
  dgdscrQ.Text := CapQ;
  diagObszary.Invalidate;
end;

end.
