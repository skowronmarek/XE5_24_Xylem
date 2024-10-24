unit StdZadFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ZadFrmU, ZadPompSzuk, StdZadSzukPomp,inifiles,
  CheckLst, ComCtrls, Buttons, ExtCtrls, Tabnotbk, ZakWyszF,
  StdCtrls, Diagrams, KopDraw1, PropertyAccesserU, FormSaverU,
  PmpListU,TbsU,
  jezyki;

type
  TStdZadForm = class(TZadForm)
    StatusBar: TStatusBar;
    RuraFun: TDiagFunction;
    PPracyFunction: TDiagFunction;
    ZakresFunction: TDiagFunction;
    RPanel: TPanel;
    GBoxFiltry: TGroupBox;
    CBoxFilZas: TCheckBox;
    CBoxFilKon: TCheckBox;
    StartSearchBtn: TBitBtn;
    CloseBtn: TBitBtn;
    PageControlNaPunkt: TPageControl;
    TabSheetPunkt: TTabSheet;
    TabSheetZastosowania: TTabSheet;
    TabSheetKonstrukcja: TTabSheet;
    TabSheetUstawienia: TTabSheet;
    Panel1: TPanel;
    ZastUpPanel: TPanel;
    CBoxDowolneZas: TCheckBox;
    ZastosowaniaCLBox: TCheckListBox;
    Panel2: TPanel;
    KonstrukcjaCLBox: TCheckListBox;
    KonstUpPanel: TPanel;
    CBoxDowolnaKon: TCheckBox;
    labNPSH: TLabel;
    cbSprawdzajNPSH: TCheckBox;
    cbSprawdzajTEMP: TCheckBox;
    Edit_NPSH: TEdit;
    TrackBarNPSH: TTrackBar;
    Tolerancja: TGroupBox;
    Label117: TLabel;
    Qw1Lab: TLabel;
    Label118: TLabel;
    QrLab: TLabel;
    Label119: TLabel;
    Label120: TLabel;
    Qw2Lab: TLabel;
    Label121: TLabel;
    Hw1Lab: TLabel;
    Label122: TLabel;
    Label123: TLabel;
    Label124: TLabel;
    HrLab: TLabel;
    Hw2Lab: TLabel;
    QMin: TEdit;
    QMax: TEdit;
    HMin1: TEdit;
    HMax1: TEdit;
    RadioJedQ: TRadioGroup;
    GroupBox5: TGroupBox;
    Label129: TLabel;
    Label130: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label21: TLabel;
    Label112: TLabel;
    TrackBarDELTA: TTrackBar;
    Edit_DELTA: TEdit;
    Edit_ETA: TEdit;
    TrackBarETA: TTrackBar;
    Label3: TLabel;
    gBoxSprawdz: TGroupBox;
    LabSprawdzPompa: TLabel;
    Label34: TLabel;
    LabWynikTestu: TLabel;
    OpcjeDomyslne: TButton;
    PanGora: TPanel;
    PPrRPanel: TPanel;
    QwLab: TLabel;
    HwLab: TLabel;
    HgLab: TLabel;
    LabelQwJed: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    sbtnDZezw: TSpeedButton;
    sbtnNZezw: TSpeedButton;
    QwEd: TEdit;
    HwEd: TEdit;
    HgEd: TEdit;
    PPrRDownPanel: TPanel;
    TolBtn: TButton;
    CharPanel: TPanel;
    RuraDiagram: TDiagram;
    DiagDescrH: TDiagDescr;
    DiagDescrJed: TDiagDescr;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    DiagDescr1: TDiagDescr;
    UpDownQw: TUpDown;
    UpDownHw: TUpDown;
    procedure HgEdChange(Sender: TObject);
    procedure StartSearchBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBarDELTAChange(Sender: TObject);
    procedure TrackBarETAChange(Sender: TObject);
    procedure ZastosowaniaCLBoxClickCheck(Sender: TObject);
    procedure KonstrukcjaCLBoxClickCheck(Sender: TObject);
    procedure CBoxDowolnaKonClick(Sender: TObject);
    procedure CBoxDowolneZasClick(Sender: TObject);
    procedure TolBtnClick(Sender: TObject);
    procedure QwEdChange(Sender: TObject);
    procedure HwEdChange(Sender: TObject);
    procedure RuraFunValue(X: Double; var Y: Double);
    procedure QwEdExit(Sender: TObject);
    procedure HwEdExit(Sender: TObject);
    procedure HgEdExit(Sender: TObject);
    procedure TrackBarNPSHChange(Sender: TObject);
    procedure cbSprawdzajNPSHClick(Sender: TObject);
    procedure cbSprawdzajTEMPClick(Sender: TObject);
    procedure sbtnDZezwClick(Sender: TObject);
    procedure sbtnNZezwClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PageControlNaPunktChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure TabSheetUstawieniaShow(Sender: TObject);
    procedure RadioJedQClick(Sender: TObject);
    procedure LabSprawdzPompaDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure LabSprawdzPompaDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure OpcjeDomyslneClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UpDownQwClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownHwClick(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
    FPompyZnalezFrm      :TForm;


    ListaKluczy          :TStrings;
    ListaKonstr          :TStrings;

    function  GetZadanie :TStdZadSzukPomp;
    procedure InitDiag;
    procedure WybranoDowolne(CBoxFil,CBoxDowol: TCheckBox;
                                     CLBox: TCheckListBox);
    procedure WybranoListBox(CLBox:TCheckListBox;
                                     CBoxFil,CBoxDowol:TCheckBox);
    procedure ListaZas;
    procedure ListaKon;
  protected
    procedure Notification( AComponent: TComponent;
                            Operation: TOperation); override;
  public
    { Public declarations }
    PntDiagFun   : TPntDiagFun;
    TolDiagFun   : TTolDiagFun;

    constructor Create( O :TComponent ); override;
    destructor  Destroy;                 override;
    procedure Aktualizuj;                override;
    property Zadanie :TStdZadSzukPomp read GetZadanie;


    
  end;

var
  StdZadForm: TStdZadForm;
  //ZastosowaniaList:TStrings;
  //KonstrukcjaList:TStrings;
implementation

{$R *.DFM}

uses
  PmpZnalFrm,WkpGlob;


//-------------------------------------------------------------------
procedure TStdZadForm.Notification( AComponent: TComponent;
                                    Operation: TOperation);
begin
  if (Operation = opRemove) then
  begin
    if (AComponent = FPompyZnalezFrm) then
      FPompyZnalezFrm := NIL;
  end;
end;


//-------------------------------------------------------------------
function  TStdZadForm.GetZadanie :TStdZadSzukPomp;
begin
  result := Zad as TStdZadSzukPomp;
end;

procedure TStdZadForm.Aktualizuj;
begin
  //QwEd.Text := FormatFloat( '0.00', Zadanie.Qw ); //FloatToStr(Zadanie.Qw)
  //HwEd.Text := FormatFloat( '0.00', Zadanie.Hw ); //FloatToStr(Zadanie.Hw)
  //HgEd.Text := FormatFloat( '0.00', Zadanie.Hg ); //FloatToStr(Zadanie.Hg)
  Caption := TTlumacz.dajObiekt.ZnajdzTlumaczenie('ZADANIE: Dobor pomp "na punkt"');

  LabelQwJed.Caption := CapQ;

  QwEd.Text := FloatToStr(m3hToU(Zadanie.Qw)); //WS
  HwEd.Text := FloatToStr(Zadanie.Hw);
  HgEd.Text := FloatToStr(Zadanie.Hg);

  sbtnDZezw.Down := Zadanie.RegDZezw;
  sbtnNZezw.Down := Zadanie.RegNZezw;

  cbSprawdzajNPSH.Visible:= zadanie.WlaczSprawdzanie;  // to trzeba
  cbSprawdzajTEMP.Visible:= zadanie.WlaczSprawdzanie;  // przeniesc
  TrackBarNPSH.Visible   := zadanie.WlaczSprawdzanie;
  Edit_NPSH.Visible      := zadanie.WlaczSprawdzanie;
  labNPSH.Visible        := zadanie.WlaczSprawdzanie;

  LabWynikTestu.Caption := TTlumacz.dajObiekt.ZnajdzTlumaczenie(Zadanie.KomunikatBledu); //przeniesione z tab show

  InitDiag;
  case Zadanie.State of
    zspsDane:
      begin
      StatusBar.Panels[0].Text := TTlumacz.DajObiekt.ZnajdzTlumaczenie('Wprowadzanie danych');
      StartSearchBtn.Enabled := true;
      end;
    zspsSzukanie:
      begin
      StatusBar.Panels[0].Text := TTlumacz.DajObiekt.ZnajdzTlumaczenie('Wyszukiwanie pomp');
      StartSearchBtn.Enabled := false;
      end;
    zspsWyniki:
      begin
      StatusBar.Panels[0].Text := TTlumacz.DajObiekt.ZnajdzTlumaczenie('Wyszukiwanie zakonczone');
      StartSearchBtn.Enabled := true;
      end;
  end;
  if FPompyZnalezFrm <> NIL then
    (FPompyZnalezFrm as TPompyZnalezFrm).Aktualizuj;
end;

procedure TStdZadForm.QwEdChange(Sender: TObject);
begin
  inherited;
  try
    Zadanie.Qw := UTom3h(StrToFloat( QwEd.Text ));
  except
  end;
  InitDiag;
  RuraDiagram.Invalidate;
end;

procedure TStdZadForm.HwEdChange(Sender: TObject);
begin
  inherited;
  try
    Zadanie.Hw := StrToFloat( HwEd.Text );
  except
  end;
  InitDiag;
  RuraDiagram.Invalidate;
end;
/////////
procedure TStdZadForm.HgEdChange(Sender: TObject);
begin
  inherited;
  try
    Zadanie.Hg := StrToFloat( HgEd.Text );
  except
  end;
  InitDiag;
  RuraDiagram.Invalidate;
end;


procedure TStdZadForm.StartSearchBtnClick(Sender: TObject);
var
  F       :TPompyZnalezFrm;
begin
  inherited;
  ListaZas;
  ListaKon;
  Zadanie.fEta:=TrackBarEta.Position/TrackBarEta.Max;
  Zadanie.fDELTA:=TrackBarDELTA.Position/TrackBarDELTA.Max;
  Zadanie.fNPSH:=TrackBarNPSH.Position/TrackBarNPSH.Max;
  if FPompyZnalezFrm = NIL then
  begin
    F := TPompyZnalezFrm.Create( self );
    F.Zad := Zadanie;
    FPompyZnalezFrm := F;
  end
  else
    F := FPompyZnalezFrm as TPompyZnalezFrm;
  F.AktualTimer.Enabled := true;
  F.Show;
  Zadanie.PrzygotujSzukanie;
  F.Aktualizuj;      //  czy to wywolaniw jestb potrzebne
  Zadanie.SzukajPomp;
  F.Aktualizuj;
end;

procedure TStdZadForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FPompyZnalezFrm) then
    FPompyZnalezFrm.Close;
  inherited;
end;

procedure TStdZadForm.ListaZas;  //Lista wybranych kluczy zastosowan
var
i:integer;
begin
  Zadanie.ZastosowaniaList.Clear;
  For i:=0 To ZastosowaniaCLBox.Items.Count-1 DO
    if ZastosowaniaCLBox.Checked[I] THEN
        Zadanie.ZastosowaniaList.Add(ListaKluczy[i]);
end;

procedure TStdZadForm.ListaKon;  //Lista wybranych kluczy konstrukcji
var
i:integer;
begin
  Zadanie.KonstrukcjaList.Clear;
  For i:=0 To KonstrukcjaCLBox.Items.Count-1 DO
    if KonstrukcjaCLBox.Checked[I] THEN
        Zadanie.KonstrukcjaList.Add(ListaKonstr[i]);
end;


//**********************************************************************

procedure TStdZadForm.WybranoDowolne(CBoxFil,CBoxDowol:TCheckBox;
                                     CLBox: TCheckListBox);
var                                                                     //*
  i:integer;                                                            //*
begin                                                                   //*
  if CBoxDowol.Checked THEN
    begin
      CBoxFil.Checked:=FALSE;                                           //*
      For i:=0 To CLBox.Items.Count-1 DO                                //*
        CLBox.Checked[I]:=FALSE;
    end;                                                                //*
end;                                                                    //*
//**********************************************************************

procedure TStdZadForm.WybranoListBox(CLBox:TCheckListBox;
                                     CBoxFil,CBoxDowol:TCheckBox);
var
  i    : integer;
  JestKlucz : boolean;
begin
  inherited;
  JestKlucz:=False;
  For i:=0 To CLBox.Items.Count-1 DO
    if  CLBox.Checked[I]
      then JestKlucz := TRUE;
  if JestKlucz then
                 begin
                   CBoxDowol.Checked:=FALSE;
                   CBoxFil.Checked:=TRUE;
                 end
               else
                 begin
                   CBoxDowol.Checked:=TRUE ;
                   CBoxFil.Checked:=False ;
                 end;
end;

{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}

{----------------------------------------------------------------------------}
procedure TStdZadForm.InitDiag;
var
  fun       :TDiagFun;
  fs        :integer;
  MiejscZer :integer;
  v,Hm         :Double;
begin
//  Compute;
  with RuraDiagram do
    begin
      MinXR  :=   0;
      //wstawka na skalowanie jednostek Q
      DiagDescrJed.Text := 'Q '+CapQ;
      XJednostki := 1/UTom3h(1);
      CountMaxXRAuto(Zadanie.Qw*1.4);
      //wstawka na skalowanie jednostek Q
      //CountMaxXR( zadanie.Qw*1.4 ); // wycofane bo nie skaluje po przecinku
      MinYR  :=   0;
      MaxYR  :=   200;
      if (zadanie.Hw > 0) and (zadanie.Hg < zadanie.Hw) then
        begin
          Hm := Zadanie.CharSel.dH(MaxXR );
          if Hm = 0 then
            Hm := 10;
        end
      else
        begin
          if (zadanie.Hg > zadanie.Hw) then
            Hm := 1.5*zadanie.Hg
          else
            Hm := 10;
          end;
    ruraFun.CountMaxYR(Hm);
  end;
  PntDiagFun.Q := zadanie.Qw;
  PntDiagFun.H := zadanie.Hw;

  TolDiagFun.Q := zadanie.Qw;
  TolDiagFun.H := zadanie.Hw;
  TolDiagFun.QMinTol := zadanie.QMinTol;
  TolDiagFun.QMaxTol := zadanie.QMaxTol;
  TolDiagFun.HMinTol := zadanie.HMinTol;
  TolDiagFun.HMaxTol := zadanie.HMaxTol;
end;

procedure TStdZadForm.RuraFunValue(X: Double; var Y: Double);
begin
  inherited;
  Y := zadanie.charSel.dH(X);
end;

procedure TStdZadForm.TrackBarDELTAChange(Sender: TObject);
begin
  inherited;
  Edit_DELTA.Text:=IntToStr(TrackBarDELTA.Position);
  Zadanie.fDelta:=TrackBarDELTA.Position/TrackBarDELTA.Max;
end;

procedure TStdZadForm.TrackBarETAChange(Sender: TObject);
begin
  inherited;
  Edit_ETA.Text:=IntToStr(TrackBarETA.Position);
  Zadanie.fEta:=TrackBarEta.Position/TrackBarEta.Max;
end;
procedure TStdZadForm.TrackBarNPSHChange(Sender: TObject);
begin
  inherited;
  Edit_NPSH.Text:=IntToStr(TrackBarNPSH.Position);
  Zadanie.fNPSH:=TrackBarNPSH.Position/TrackBarNPSH.Max;
end;
procedure TStdZadForm.ZastosowaniaCLBoxClickCheck(Sender: TObject);
begin
  inherited;
  WybranoListBox(ZastosowaniaCLBox,CBoxFilZas,CBoxDowolneZas);
end;

procedure TStdZadForm.KonstrukcjaCLBoxClickCheck(Sender: TObject);
begin
  inherited;
  WybranoListBox(KonstrukcjaCLBox,CBoxFilKon,CBoxDowolnaKon);
end;

procedure TStdZadForm.CBoxDowolnaKonClick(Sender: TObject);
begin
  inherited;
  WybranoDowolne(CBoxFilKon,CBoxDowolnaKon,KonstrukcjaCLBox);
end;

procedure TStdZadForm.CBoxDowolneZasClick(Sender: TObject);
begin
  inherited;
  WybranoDowolne(CBoxFilZas,CBoxDowolneZas,ZastosowaniaCLBox);
end;

procedure TStdZadForm.TolBtnClick(Sender: TObject);
var
  d       :TRangeSearchForm;
begin
  inherited;
  d := TRangeSearchForm.Create(self);
  d.QMinTol := Zadanie.QMinTol;
  d.QMaxTol := Zadanie.QMaxTol;
  d.HMinTol := Zadanie.HMinTol;
  d.HMaxTol := Zadanie.HMaxTol;
  if d.Execute then
  begin
    Zadanie.QMinTol := d.QMinTol;
    Zadanie.QMaxTol := d.QMaxTol;
    Zadanie.HMinTol := d.HMinTol;
    Zadanie.HMaxTol := d.HMaxTol;
    InitDiag;
    RuraDiagram.Invalidate;
  end;
  d.Free;
end;

procedure TStdZadForm.QwEdExit(Sender: TObject);
begin
  inherited;
  try
    Zadanie.Qw := UTom3h(StrToFloat( QwEd.Text ));  //?? dlaczego jest tej na on change
  except
  end;
  InitDiag;
  RuraDiagram.Invalidate;
  Aktualizuj;
end;

procedure TStdZadForm.HwEdExit(Sender: TObject);
begin
  inherited;
   try
    Zadanie.Hw := StrToFloat( HwEd.Text );
  except
  end;
  //InitDiag;
  RuraDiagram.Invalidate;
  Aktualizuj;
end;

procedure TStdZadForm.HgEdExit(Sender: TObject);
begin
  inherited;
   try
    Zadanie.Hg := StrToFloat( HgEd.Text );
  except
  end;
  InitDiag;
  RuraDiagram.Invalidate;
  Aktualizuj;
end;

constructor TStdZadForm.Create(O: TComponent);
var
  MojIni    :TCustomIniFile;
  i         :Integer;
  StrTmp    :TStringList;
begin
  inherited Create( O );

  PntDiagFun := TPntDiagFun.Create(self);
  PPracyFunction.Drawer := PntDiagFun;

  TolDiagFun := TTolDiagFun.Create(self);
  ZakresFunction.Drawer := TolDiagFun;

  ListaKluczy := TStringList.create;
  ListaKonstr := TStringList.create;
  StrTmp      := TStringList.create;

  try
    MojIni := KluczePompIni;
    MojIni.ReadSection('Zastosowania',StrTmp);
    For i:=0 To StrTmp.Count-1 DO  // Lista komentarzy do kluczy zastosowan
    begin
      if StrTmp[i][1] <> '#' then
      begin
        ListaKluczy.Add(StrTmp[i]);
        ZastosowaniaCLBox.items.add(MojIni.ReadString('Zastosowania',StrTmp[i], '??'));
      end;
    end;

    MojIni.ReadSection('Konstrukcja',ListaKonstr);
    For i:=0 To ListaKonstr.Count-1 DO  // Lista komentarzy do kluczy konstrukcji
      KonstrukcjaCLBox.items.add(MojIni.ReadString('Konstrukcja',ListaKonstr[i],'??'));
    TTlumacz.DajObiekt.Tlumacz(KonstrukcjaCLBox);
    TTlumacz.DajObiekt.Tlumacz(ZastosowaniaCLBox);
//    TTlumacz.DajObiekt.Tlumacz(RuraDiagram);
  finally
    StrTmp.Free;
  end;
end;

destructor TStdZadForm.Destroy;
begin
  ListaKluczy.Free;
  ListaKonstr.Free;
  inherited Destroy;
end;

procedure TStdZadForm.cbSprawdzajNPSHClick(Sender: TObject);
begin
  inherited;
  zadanie.SprawdzajNPSH:=cbSprawdzajNPSH.Checked;
  IF cbSprawdzajNPSH.Checked
    THEN
      begin
        TrackBarNPSH.Enabled:=True;
        Edit_NPSH.Enabled:=True;
        Edit_NPSH.Color:=clWindow;
      end
    ELSE
      begin
        TrackBarNPSH.Enabled:=False;
        Edit_NPSH.Enabled:=False;
        Edit_NPSH.Color:=clInactiveCaptionText;
      end;
end;

procedure TStdZadForm.cbSprawdzajTEMPClick(Sender: TObject);
begin
  inherited;
  zadanie.SprawdzajTEMP:=cbSprawdzajTEMP.Checked;
end;

procedure TStdZadForm.sbtnDZezwClick(Sender: TObject);
begin
  inherited;
  Zadanie.RegDZezw := sbtnDZezw.Down;
end;

procedure TStdZadForm.sbtnNZezwClick(Sender: TObject);
begin
  inherited;
  Zadanie.RegNZezw := sbtnNZezw.Down;
end;

procedure TStdZadForm.FormCreate(Sender: TObject);
var
  vis     :Boolean;
const
  GruKolorTla   : TColor = $874C07;
  GruKolorPusty : TColor = $B49924;
begin
  inherited;
  Self.Color  := GruKolorPusty;
  RPanel.Color := GruKolorPusty;
  PPrRPanel.Color := GruKolorPusty;
  PPrRDownPanel.Color := GruKolorPusty;
//  PageControlNaPunkt.
  vis := ZetonFile.ReadBool( 'Katalog\Zadania\Pompy', 'PPracyDNZezw', False);
  sbtnDZezw.Visible := vis;
  sbtnNZezw.Visible := vis;
  PageControlNaPunkt.ActivePage := TabSheetPunkt;
  UpDownQw.Visible := ZetonFile.ReadBool( 'Katalog\Zadania\Pompy', 'GuzikTolerancji', False);
  UpDownHw.Visible := ZetonFile.ReadBool( 'Katalog\Zadania\Pompy', 'GuzikTolerancji', False);
end;

procedure TStdZadForm.PageControlNaPunktChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange:=True;
  if PageControlNaPunkt.ActivePage = TabSheetUstawienia then
    begin
      Zadanie.QMaxTol := StrToFloat(QMax.Text);
      Zadanie.QMinTol := StrToFloat(QMin.Text);
      Zadanie.HMaxTol := StrToFloat(HMax1.Text);
      Zadanie.HMinTol := StrToFloat(HMin1.Text);
      with Zadanie do if (QMaxTol<=0.0) or (QMinTol<=0.0) or
	  		(HMaxTol<=0.0) or (HMinTol<=0.0) then AllowChange := False;
      Aktualizuj;  
    end;
end;

procedure TStdZadForm.TabSheetUstawieniaShow(Sender: TObject);
begin
  inherited;
  QMax.Text:=FormatFloat('0.00',Zadanie.QMaxTol);
  QMin.Text:=FormatFloat('0.00',Zadanie.QMinTol);
  HMax1.Text:=FormatFloat('0.00',Zadanie.HMaxTol);
  HMin1.Text:=FormatFloat('0.00',Zadanie.HMinTol);
  TrackBarDELTA.Position := round(Zadanie.fDelta * TrackBarDELTA.Max);
  TrackBarETA.Position   := round(Zadanie.fEta   * TrackBarETA.Max);
  //LabWynikTestu.Caption := Zadanie.KomunikatBledu; jest w aktualizuj
  case UidQ of 
    m3h:RadioJedQ.ItemIndex := 0 ;
    lns:RadioJedQ.ItemIndex := 1 ;
    lnm:RadioJedQ.ItemIndex := 2 ;
    m3m:RadioJedQ.ItemIndex := 3 ;
    m3s:RadioJedQ.ItemIndex := 4 ;
  end;
end;

procedure TStdZadForm.RadioJedQClick(Sender: TObject);
begin
  case RadioJedQ.ItemIndex of
    0: UidQ := m3h;
    1: UidQ := lns;
    2: UidQ := lnm;
    3: UidQ := m3m;
    4: UidQ := m3s;
  end;
  Aktualizuj;
end;

procedure TStdZadForm.LabSprawdzPompaDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  dob     :TPompaDragObject;
begin
  dob := Source as TPompaDragObject;
  Zadanie.PompaDoTestu := dob.Pompa.Nazwa;
  LabSprawdzPompa.Caption := Zadanie.PompaDoTestu;  //dob.Pompa.Nazwa;
  LabWynikTestu.Caption   := TTlumacz.dajObiekt.ZnajdzTlumaczenie('Nacisnij <Szukaj>');
end;

procedure TStdZadForm.LabSprawdzPompaDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited;
  Accept := Source is TPmpDragObjectBase;
end;

procedure TStdZadForm.OpcjeDomyslneClick(Sender: TObject);
begin
  QMax.Text:=Formatfloat('0.00',1.1);
  QMin.Text:=Formatfloat('0.00',0.9);
  HMax1.Text:=Formatfloat('0.00',1.1);
  HMin1.Text:=Formatfloat('0.00',0.9);
  UidQ := lns;
end;

procedure TStdZadForm.FormShow(Sender: TObject);
begin
  TTlumacz.dajObiekt.Tlumacz(self);
end;

procedure TStdZadForm.UpDownQwClick(Sender: TObject; Button: TUDBtnType);
begin
  inherited;
  if Zadanie = nil then exit;
  Zadanie.QMaxTol := StrToFloat(QMax.Text);
  Zadanie.QMinTol := StrToFloat(QMin.Text);
  if Button = btNext then
  begin
    if (zadanie.QMaxTol -0.00001)<= 1.8   then zadanie.QMaxTol := zadanie.QMaxTol + 0.1;
    if zadanie.QMinTol > 0.2 then zadanie.QMinTol := zadanie.QMinTol - 0.1;
  end else
       begin
         if zadanie.QMaxTol > 1 then zadanie.QMaxTol := zadanie.QMaxTol - 0.1;
         if zadanie.QMinTol < 1   then zadanie.QMinTol := zadanie.QMinTol + 0.1;
       end;
  QMax.Text:=FormatFloat('0.00',Zadanie.QMaxTol);
  QMin.Text:=FormatFloat('0.00',Zadanie.QMinTol);
end;

procedure TStdZadForm.UpDownHwClick(Sender: TObject; Button: TUDBtnType);
begin
  inherited;
  if Zadanie = nil then exit;
  Zadanie.HMaxTol := StrToFloat(HMax1.Text);
  Zadanie.HMinTol := StrToFloat(HMin1.Text);
  if Button = btNext then
  begin
    if (zadanie.HMaxTol -0.00001)<= 1.8 then zadanie.HMaxTol := zadanie.HMaxTol + 0.1;
    if zadanie.HMinTol > 0.2 then zadanie.HMinTol := zadanie.HMinTol - 0.1;
  end else
       begin
         if zadanie.HMaxTol > 1 then zadanie.HMaxTol := zadanie.HMaxTol - 0.1;
         if zadanie.HMinTol < 1   then zadanie.HMinTol := zadanie.HMinTol + 0.1;
       end;
  HMax1.Text:=FormatFloat('0.00',Zadanie.HMaxTol);
  HMin1.Text:=FormatFloat('0.00',Zadanie.HMinTol);

end;

end.
