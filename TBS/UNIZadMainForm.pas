unit UNIZadMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ZadFrmU, ComCtrls, Menus, StdCtrls, ExtCtrls, KopZadU, Diagrams,
  UNIZadU, r_opor, Buttons, StdZadSzukPomp, //TeEngine, Series, TeeProcs,
  {Chart,} Math, KrMath, StdZadFrmU, //RaportUniU, PodgladRaportU,
  KopDraw1, PropertyAccesserU, FormSaverU;

 type
  TUNIZadForm = class(TZadForm)
    UniMenu: TMainMenu;
    UniMenuPlik: TMenuItem;
    UNIPageControl: TPageControl;
    DaneSheet: TTabSheet;
    QwButton: TButton;
    HstButton: TButton;
    HssButton: TButton;
    ZbiornikTloRG: TRadioGroup;
    ZbiornikSsaRG: TRadioGroup;
    HssEdit: TEdit;
    HstEdit: TEdit;
    QwEdit: TEdit;
    PztEdit: TEdit;
    PzsEdit: TEdit;
    HzsEdit: TEdit;
    HztEdit: TEdit;
    TempEdit: TEdit;
    PbEdit: TEdit;
    TempLabel: TLabel;
    PbLabel: TLabel;
    PztLabel: TLabel;
    PzsLabel: TLabel;
    HzsLabel: TLabel;
    HztLabel: TLabel;
    UNIPaintB: TPaintBox;
    SsanieSheet: TTabSheet;
    TPodnoszenieSheet: TTabSheet;
    AnconaSheet: TTabSheet;
    SaveMItem: TMenuItem;
    UNISaveDialog: TSaveDialog;
    Image1: TImage;
    TempImg: TImage;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    HtLabel: TLabel;
    HsLabel: TLabel;
    HwLabel: TLabel;
    HgLabel: TLabel;
    NPSHuLabel: TLabel;
    PzsDiagFun: TDiagFunction;
    PbarDiagFun: TDiagFunction;
    PvDiagFun: TDiagFunction;
    HssDiagFun: TDiagFunction;
    HzsDiagFun: TDiagFunction;
    SsanieDiagDescr: TDiagDescr;
    PodnoszenieDiagram: TDiagram;
    HgPodDiagFun: TDiagFunction;
    HwDiagFun: TDiagFunction;
    AnconaPaintBox: TPaintBox;
    HstLabel: TLabel;
    HztLabel2: TLabel;
    PztLabel2: TLabel;
    PbLabel2: TLabel;
    HwLabel2: TLabel;
    HssLabel2: TLabel;
    HzsLabel2: TLabel;
    PzsLabel2: TLabel;
    PbLabel3: TLabel;
    HgLabel2: TLabel;
    PodnoszenieDiagDescr: TDiagDescr;
    QpodnoszDiagDescr: TDiagDescr;
    QssaniaDiagDescr: TDiagDescr;
    PompkaDiagFunction: TDiagFunction;
    SsanieLiniaDiagFunction: TDiagFunction;
    PodPompkaDiagF: TDiagFunction;
    PodLiniaDiagF: TDiagFunction;
    dfNPSHuFun: TDiagFunction;
    TabRaport: TTabSheet;
    PanelDoWst: TPanel;
    TimerNPSHu: TTimer;
    panChkSsanie: TPanel;
    SsanieDiagram: TDiagram;
    PbarCBox: TCheckBox;
    HzsCBox: TCheckBox;
    PzsCBox: TCheckBox;
    HssCBox: TCheckBox;
    NPSHuCBox: TCheckBox;
    PvCBox: TCheckBox;
    panChkPodnoszenie: TPanel;
    HgCheckB: TCheckBox;
    HwCheckB: TCheckBox;
    HwLCheckB: TCheckBox;
    
    procedure UNIPaintBPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ZbiornikSsaRGClick(Sender: TObject);
    procedure ZbiornikTloRGClick(Sender: TObject);
    procedure HzsEditExit(Sender: TObject);
    procedure SaveMItemClick(Sender: TObject);
    procedure HztEditExit(Sender: TObject);
    procedure QwEditExit(Sender: TObject);
    procedure TempEditExit(Sender: TObject);
    procedure PbEditExit(Sender: TObject);
    procedure HssEditExit(Sender: TObject);
    procedure PzsEditExit(Sender: TObject);
    procedure HstEditExit(Sender: TObject);
    procedure PztEditExit(Sender: TObject);
    procedure PztEditChange(Sender: TObject);
    procedure HzsEditChange(Sender: TObject);
    procedure HssEditChange(Sender: TObject);
    procedure HstEditChange(Sender: TObject);
    procedure HztEditChange(Sender: TObject);
    procedure PzsEditChange(Sender: TObject);
    procedure PbEditChange(Sender: TObject);
    procedure TempEditChange(Sender: TObject);
    procedure UNIPageControlChange(Sender: TObject);
    procedure HstButtonClick(Sender: TObject);
    procedure HssButtonClick(Sender: TObject);
    procedure PzsDiagFunValue(X: Double; var Y: Double);
    procedure PbarDiagFunValue(X: Double; var Y: Double);
    procedure PvDiagFunValue(X: Double; var Y: Double);
    procedure HssDiagFunValue(X: Double; var Y: Double);
    procedure HzsDiagFunValue(X: Double; var Y: Double);
    procedure PbarCBoxClick(Sender: TObject);
    procedure HzsCBoxClick(Sender: TObject);
    procedure PzsCBoxClick(Sender: TObject);
    procedure HssCBoxClick(Sender: TObject);
    procedure NPSHuCBoxClick(Sender: TObject);
    procedure HwDiagFunValue(X: Double; var Y: Double);
    procedure AnconaPaintBoxPaint(Sender: TObject);
    procedure HgCheckBClick(Sender: TObject);
    procedure HgPodDiagFunValue(X: Double; var Y: Double);
    procedure HwCheckBClick(Sender: TObject);
    procedure HwLCheckBClick(Sender: TObject);
    procedure QwEditChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure dfNPSHuFunValue(X: Double; var Y: Double);
    procedure PvCBoxClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure TimerNPSHuTimer(Sender: TObject);
  private
    { Private declarations }
    FAktualizowane :Boolean;
    FRapClosed     :Boolean;
    HNaplywu  :Real;
    HBar      :Real;
    Pv        :Real;
    DiagHss   :Real;
    DiagHst   :Real;
    ZadSzukajDlaUNI :TStdZadForm;

    function  DiagHssOdQ( Q :Real ):Real;
    function  HstOdQ( Q :Real ):Real;

    procedure pompa(x,y:integer);
    procedure ZbiornikOTW(x,y:integer);
    procedure ZbiornikZAM(x,y:integer);
    procedure Rura(x,y:integer);
    procedure RuraTlo(x,y:integer);
    procedure WymiarHzt(x,y:integer);
    procedure WymiarHzs(x,y,yp:integer);
    procedure HzRuryTlo(x,y:integer);
    procedure HzSsa(x,y,yp:integer);

    procedure InitSsanieDiagram;
    procedure InitPodnoszenieDiagram;

    function  GetZad :TUNIZad;
    procedure HzsAssign;
    procedure rysujANCONE;
    procedure pompka(xp,yp:integer);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CloseRaport;       override;
  public
    { Public declarations }

    PompkaDiagFun   : TPompkaDiagFun;
    LiniaDiagFun   : TLiniaDiagFun;

    PodPompkaDiagFun   : TPompkaDiagFun;
    PodLiniaDiagFun   : TPodLiniaDiagFun;
//    RapForm            :TPodgladRaport;
//    Raport             :TRaportUNI;

    constructor Create( O :TComponent );        override;
    procedure Aktualizuj;                       override;
    property  Zadanie  :TUNIZad  read GetZad;
  end;

var
  UNIZadForm: TUNIZadForm;

implementation

uses PmpZnalFrm ;
{$R *.DFM}

constructor TUNIZadForm.Create( O :TComponent );
begin
  inherited Create( O );
  PompkaDiagFun := TPompkaDiagFun.Create(self);
  PompkaDiagFunction.Drawer := PompkaDiagFun;
  LiniaDiagFun := TLiniaDiagFun.Create(self);
  SSanieLiniaDiagFunction.Drawer := LiniaDiagFun;

  PodPompkaDiagFun := TPompkaDiagFun.Create(self);
  PodPompkaDiagF.Drawer := PodPompkaDiagFun;
  PodLiniaDiagFun := TPodLiniaDiagFun.Create(self);
  PodLiniaDiagF.Drawer := PodLiniaDiagFun;

end;

procedure TUNIZadForm.UNIPaintBPaint(Sender: TObject);
var
  xPompy : integer;
  yPompy : integer;
  Ygeo   : integer;
  Ywym   : integer;
begin
  xPompy:= 250;
  yPompy:= 200;

  if Zadanie.Hzs = 0 then
      begin
        Ygeo := 25;
        Ywym := 0;
      end
    else
      if Zadanie.Hzs > 0 then
          begin
            Ygeo := -30;
            Ywym := -20;
          end
        else
          begin
            Ygeo := 80;
            Ywym := 40;
          end;

  case ZbiornikSsaRG.ItemIndex of
    0: begin
         ZbiornikOTW(120,yPompy+Ygeo);
         HzSsa(120,yPompy+Ygeo,yPompy);
         PzsEdit.Visible:=False;
         PzsLabel.Visible:=False;
         WymiarHzs(xPompy,yPompy+Ygeo-10,yPompy);
         HzsEdit.Top:=yPompy+Ywym;
         HzsLabel.Top:=yPompy+Ywym-15;
       end;
    1: begin
         ZbiornikZAM(120,yPompy+Ygeo);
         HzSsa(120,yPompy+Ygeo,yPompy);
         PzsEdit.Top:=yPompy+Ygeo-47;
         PzsLabel.Top:=yPompy+Ygeo-62;
         PzsEdit.Visible:=True;
         PzsLabel.Visible:=True;
         WymiarHzs(xPompy,yPompy+Ygeo-10,yPompy);
         HzsEdit.Top:=yPompy+Ywym;
         HzsLabel.Top:=yPompy+Ywym-15;
       end;
    2: begin
         Rura(120,yPompy+Ygeo-10);
         HzSsa(120,yPompy+Ygeo-10,yPompy);
         PzsEdit.Top:=yPompy+Ygeo-47;
         PzsLabel.Top:=yPompy+Ygeo-62;
         PzsEdit.Visible:=True;
         PzsLabel.Visible:=True;
         WymiarHzs(xPompy,yPompy+Ygeo-10,yPompy);
         HzsEdit.Top:=yPompy+Ywym;
         HzsLabel.Top:=yPompy+Ywym-15;
       end;
  end;
  case ZbiornikTloRG.ItemIndex of
    0: begin
         ZbiornikOTW(540,60);
         WymiarHzt(540,50);
         PztEdit.Visible:=False;
         PztLabel.Visible:=False;
       end;
    1: begin
         ZbiornikZAM(540,60);
         WymiarHzt(540,50);
         PztEdit.Visible:=True;
         PztLabel.Visible:=True;
       end;
    2: begin
         RuraTlo(540,60);
         HzRuryTlo(540,60);
         PztEdit.Visible:=True;
         PztLabel.Visible:=True;
       end;
  end;
  pompa(xPompy,yPompy);
end;

procedure TUNIZadForm.pompa(x,y:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clBlack;
      Pen.width:=2;
      Brush.Color := clAqua;
      Ellipse(x,y,x+30,y+30); //pompa
      MoveTo(x+30,y+15);      LineTo(x+30,y-140);
      LineTo(x+240,y-140);
      MoveTo(x+15,y+15);      LineTo(x-75,y+15);
      Brush.Color := clWhite;
      Pen.width:=1;
      Ellipse(x+20,y-40,x+40,y-60);   {rozbior}
      Arc(x+7,y-40,x+27,y-60,
          x+29,y-40,x+29,y-60);
      Arc(x+33,y-40,x+53,y-60,
          x+31,y-60,x+31,y-40);
      //linia odniesienia
      Pen.color:=clYellow;
      Pen.width:=1;
      MoveTo(x-200,y+15);     LineTo(x-80,y+15);
      MoveTo(x+35,y+15);     LineTo(x+320,y+15);
     end;
end;

procedure TUNIZadForm.ZbiornikOTW(x,y:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clBlack;
      Pen.width:=2;
      Brush.Color := clAqua;
      MoveTo(x,y-25);      LineTo(x,y+25);
      LineTo(x-50,y+25);
      LineTo(x-50,y-25);
      Pen.width:=1;
      Polygon([Point(x-1,y+24),Point(x-50,y+24),
               Point(x-50,y-10),Point(x-1,y-10)]);
    end;
end;

procedure TUNIZadForm.ZbiornikZAM(x,y:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clBlack;
      Pen.width:=2;
      Brush.Color := clWhite;
      Ellipse(x,y-25,x-50,y+25);
      Pen.width:=1;
      MoveTo(x-3,y-10);  LineTo(x-48,y-10); //poziom
      Brush.Color := clAqua;
      FloodFill(x-25,y,clBlack,fsBorder);
      //Manometr
      MoveTo(x-25,y-25);  LineTo(x-25,y-36);
      Brush.Color := clWhite;
      Ellipse(x-15,y-35,x-35,y-55);

      MoveTo(x-30,y-41); LineTo(x-20,y-51); //strzalka
      Brush.Color := clBlack;
      Polygon([Point(x-20,y-51),Point(x-27,y-47),
               Point(x-24,y-44)]);
    end;
end;

procedure TUNIZadForm.Rura(x,y:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clBlack;
      Pen.width:=2;
      Brush.Color := clAqua;
      Ellipse(x+5,y+10,x-5,y-10);
      arc(x-55,y+10,x-45,y-10,x-50,y-10,x-50,y+10);
      MoveTo(x,y-10);  LineTo(x-50,y-10);
      MoveTo(x,y+10);  LineTo(x-50,y+10);
       //Manometr
      Pen.width:=1;
      MoveTo(x-25,y-10);  LineTo(x-25,y-21);
      Brush.Color := clWhite;
      Ellipse(x-15,y-20,x-35,y-40);
      MoveTo(x-30,y-26); LineTo(x-20,y-36); //strzalka
      Brush.Color := clBlack;
      Polygon([Point(x-20,y-36),Point(x-27,y-32),
               Point(x-24,y-29)]);
    end;
end;

procedure TUNIZadForm.RuraTlo(x,y:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clBlack;
      Pen.width:=2;
      Brush.Color := clAqua;
      Ellipse(x-45,y+10,x-55,y-10);
      arc(x-5,y+10,x+5,y-10,x,y+10,x,y-10);
      MoveTo(x,y-10);  LineTo(x-50,y-10);
      MoveTo(x,y+10);  LineTo(x-50,y+10);
       //Manometr
      Pen.width:=1;
      MoveTo(x-25,y-10);  LineTo(x-25,y-21);
      Brush.Color := clWhite;
      Ellipse(x-15,y-20,x-35,y-40);
      MoveTo(x-30,y-26); LineTo(x-20,y-36); //strzalka
      Brush.Color := clBlack;
      Polygon([Point(x-20,y-36),Point(x-27,y-32),
               Point(x-24,y-29)]);
    end;
end;

procedure TUNIZadForm.WymiarHzt(x,y:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clYellow;
      Pen.width:=1;
      Brush.Color := clYellow;
      MoveTo(x,y);     LineTo(x+30,y);
      MoveTo(x+25,y);  LineTo(x+25,y+165);
      Polygon([Point(x+25,y),Point(x+23,y+6),
               Point(x+27,y+6)]);
      Polygon([Point(x+25,y+165),Point(x+23,y+159),
               Point(x+27,y+159)]);
    end;
end;

procedure TUNIZadForm.HzRuryTlo(x,y:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clYellow;
      Pen.width:=1;
      Brush.Color := clYellow;
      MoveTo(x,y);     LineTo(x+30,y);
      MoveTo(x+25,y);  LineTo(x+25,y+155);
      Polygon([Point(x+25,y),Point(x+23,y+6),
               Point(x+27,y+6)]);
      Polygon([Point(x+25,y+155),Point(x+23,y+149),
               Point(x+27,y+149)]);
    end;
end;

procedure TUNIZadForm.WymiarHzs(x,y,yp:integer);
begin
  With UNIPaintB.canvas do
    begin
      Pen.color:=clYellow;
      Pen.width:=1;
      Brush.Color := clYellow;
      MoveTo(x-180,y);     LineTo(x-200,y);
      MoveTo(x-195,y);  LineTo(x-195,yp+15);
      Polygon([Point(x-195,yp+15),Point(x-193,yp+21),
               Point(x-197,yp+21)]);
      Polygon([Point(x-195,y),Point(x-193,y-6),
               Point(x-197,y-6)]);
    end;
end;

procedure TUNIZadForm.HzSsa( x,y,yp:integer);
begin
  with UNIPaintB.canvas do
  begin
    Pen.color:=clBlack;
    Pen.width:=2;
    MoveTo(x,y);  LineTo(x+45,y);
    LineTo(x+55,yp+15);
  end;
end;

procedure TUNIZadForm.Aktualizuj;
begin
  if FAktualizowane then
    EXIT;
  FAktualizowane := true;
  if UNIPageControl.ActivePage <> TabRaport then
    CloseRaport;
  inherited Aktualizuj;
  Caption := 'ZADANIE: Uniwersalny uklad pompowy, PROJEKT: ';
  if zadanie.FileName <> '' then
     Caption := Caption + ExtractFileName(zadanie.FileName)
   else Caption := Caption + 'Bez nazwy';
   if Zadanie.NPSHu <= 0 then TimerNPSHu.Enabled := True;
  // aktualizowanie ZADANIA
  with zadanie do
    begin
      Hg:=Hzt-Hzs+(Pzt-Pzs)*1e6/1000/9.81;
      Ht:=Pzt*1e6/1000/9.81+Hzt+Hst;
      Hs:=Pzs*1e6/1000/9.81+Hzs-Hss;
      Hw:=Ht-Hs;
      NPSHu:=(Pbar*100+Pzs*1e6-WodaPv(Temp))/1000/9.81+Hzs-Hss-dNPSH;
      HtLabel.Caption:=FormatFloat('0.00',Ht);
      HsLabel.Caption:=FormatFloat('0.00',Hs);
      HwLabel.Caption:=FormatFloat('0.00',Hw);
      HgLabel.Caption:=FormatFloat('0.00',Hg);
      NPSHuLabel.Caption:=FormatFloat('0.00',NPSHu);
      if JestKopS then KopS.Q:=Qw/3600;
      if JestKopT then KopT.Q:=Qw/3600;
    end;

  if ActiveControl <> HzsEdit then
    HzsEdit.Text   := FormatFloat( '0.00', Zadanie.Hzs );
  if ActiveControl <> HztEdit then
    HztEdit.Text   := FormatFloat( '0.00', Zadanie.Hzt );
  if ActiveControl <> TempEdit then
    TempEdit.Text  := FormatFloat( '0.00', Zadanie.Temp);
  if ActiveControl <> PbEdit then
    PbEdit.Text    := FormatFloat( '0.00', Zadanie.Pbar);
  if ActiveControl <> QwEdit then
    QwEdit.Text    := FormatFloat( '0.00', Zadanie.Qw);
  //  TempEdit.Text  := FormatFloat( '0.00', Zadanie.Temp);
  //PbEdit.Text    := FormatFloat( '0.00', Zadanie.Pbar);
  if ActiveControl <> HssEdit then
    HssEdit.Text   := FormatFloat( '0.00', Zadanie.Hss);
  if ActiveControl <> HstEdit then
    HstEdit.Text   := FormatFloat( '0.00', Zadanie.Hst);
  if ActiveControl <> PzsEdit then
    PzsEdit.Text   := FormatFloat( '0.000', Zadanie.Pzs);
  if ActiveControl <> PztEdit then
    PztEdit.Text   := FormatFloat( '0.000', Zadanie.Pzt);
  ZbiornikTloRG.ItemIndex := Zadanie.TloIndex;
  ZbiornikSsaRG.ItemIndex := Zadanie.SsaIndex;

  UNIPaintB.Invalidate;
  FAktualizowane := false;
end;



procedure TUNIZadForm.HzsAssign;
begin
  try
    Zadanie.Hzs := StrToFloat( HzsEdit.Text );
    UNIPaintB.Invalidate;
  except
    on EConvertError do
    begin
    end;
  end;
end;

procedure TUNIZadForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned( ZadSzukajDlaUNI ) then
    ZadSzukajDlaUNI.Close;
  inherited;
end;

procedure TUNIZadForm.ZbiornikSsaRGClick(Sender: TObject);
begin
  if ZbiornikSsaRG.ItemIndex=0 then
    Zadanie.Pzs:=0;
  Zadanie.SsaIndex:=ZbiornikSsaRG.ItemIndex;
  Aktualizuj;
end;


procedure TUNIZadForm.ZbiornikTloRGClick(Sender: TObject);
begin
  if ZbiornikTloRG.ItemIndex=0 then
    Zadanie.Pzt:=0;
  Zadanie.TloIndex:=ZbiornikTloRG.ItemIndex;
  Aktualizuj;
end;
//-----------------------------------------------------------------------------
function  TUNIZadForm.GetZad :TUNIZad;
begin
  result := Zad as TUNIZad;
end;

procedure TUNIZadForm.HzsEditExit(Sender: TObject);
begin
  inherited;
  HzsAssign;
  Aktualizuj;
end;

procedure TUNIZadForm.SaveMItemClick(Sender: TObject);
begin
  inherited;
  if UNISaveDialog.Execute then
  begin
    Zadanie.SaveToFile( UNISaveDialog.FileName );
  end;
end;

procedure TUNIZadForm.HztEditExit(Sender: TObject);
begin
   try
    Zadanie.Hzt := StrToFloat( HztEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.QwEditExit(Sender: TObject);
begin
  inherited;
  try
    if StrToFloat( QwEdit.Text )>0
      then  Zadanie.Qw := StrToFloat( QwEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.QwEditChange(Sender: TObject);
begin
  inherited;
{  try
    if StrToFloat( QwEdit.Text )>0
      then Zadanie.Qw := StrToFloat( QwEdit.Text );
  except
  end;
  Aktualizuj;}
end;

procedure TUNIZadForm.TempEditExit(Sender: TObject);
begin
  try
    Zadanie.Temp := StrToFloat( TempEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.PbEditExit(Sender: TObject);
begin
  try
    Zadanie.Pbar := StrToFloat( PbEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.HssEditExit(Sender: TObject);
begin
  try
    Zadanie.Hss := StrToFloat( HssEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.PzsEditExit(Sender: TObject);
begin
  try
    Zadanie.Pzs := StrToFloat( PzsEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.HstEditExit(Sender: TObject);
begin
  try
    Zadanie.Hst := StrToFloat( HstEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.PztEditExit(Sender: TObject);
begin
  try
    Zadanie.Pzt := StrToFloat( PztEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.PztEditChange(Sender: TObject);
begin
  try
    Zadanie.Pzt := StrToFloat( PztEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.HzsEditChange(Sender: TObject);
begin
  HzsAssign;
  Aktualizuj;
end;

procedure TUNIZadForm.HssEditChange(Sender: TObject);
begin
 if ActiveControl = HssEdit then
  try
    Zadanie.Hss := StrToFloat( HssEdit.Text );
  except
  end;
  Aktualizuj;    
end;

procedure TUNIZadForm.HstEditChange(Sender: TObject);
begin
 if ActiveControl = HstEdit then
  try
    Zadanie.Hst := StrToFloat( HstEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.HztEditChange(Sender: TObject);
begin
  try
    Zadanie.Hzt := StrToFloat( HztEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.PzsEditChange(Sender: TObject);
begin
  try
    Zadanie.Pzs := StrToFloat( PzsEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.PbEditChange(Sender: TObject);
begin
  try
    Zadanie.Pbar := StrToFloat( PbEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.TempEditChange(Sender: TObject);
begin
  try
    Zadanie.Temp := StrToFloat( TempEdit.Text );
  except
  end;
  Aktualizuj;
end;

procedure TUNIZadForm.UNIPageControlChange(Sender: TObject);
var
  F       :TForm;
//  ff      :TPodgladRaport;
//  r       :TRaportUni;
begin
  TimerNPSHu.Enabled := UNIPageControl.activePage = DaneSheet;
  case UNIPageControl.activePage.tabindex of
   1: InitSsanieDiagram;
   2: InitPodnoszenieDiagram;
   3: rysujANCONE;
   4: begin
       if zadanie.NPSHu<0
        then ShowMessage('UWAGA !   Uklad nie moze byc zrealizowany - Zapas antykawitacyjny ukladu NPSHu < 0')
        else if zadanie.NPSHu<2
          then ShowMessage('UWAGA !   Zapas antykawitacyjny ukladu NPSHu < 2');

      if ZadSzukajDlaUNI = NIL then
        ZadSzukajDlaUNI := TStdZadForm.Create(self);
      ZadSzukajDlaUNI.QwEd.Enabled := FALSE;
      ZadSzukajDlaUNI.HwEd.Enabled := FALSE;
      ZadSzukajDlaUNI.HgEd.Enabled := FALSE;
      {
      }
      ZadSzukajDlaUNI.Zad:=Zadanie;
      ZadSzukajDlaUNI.Show;
      end;
  5 : begin
        InitPodnoszenieDiagram;
        InitSsanieDiagram;
        rysujANCONE;
//        if Raport = NIL then
//        begin
//          Raport := TRaportUni.create(self);
//          FRapClosed := false;
//          OsadzRaport( self, Raport, PanelDoWst, RapForm );
//        end;
//        Raport.PreviewModeless;
        //RapForm.QRPreview1.UpdateImage;
      end
  else
    begin
      ///Zad.destroy;
    end;
  end ;// case
end;

procedure TUNIZadForm.HstButtonClick(Sender: TObject);
begin
  if zadanie.Qw>0 then
    begin
      Zadanie.KopT.Q:=zadanie.Qw/3600;
      //Zadanie.KopT.GetMainForm.FormStyle := fsMDIChild;
      Zadanie.KopT.GetMainForm.ShowModal;
      Aktualizuj;
    end;
end;

procedure TUNIZadForm.HssButtonClick(Sender: TObject);
begin
  if zadanie.Qw>0 then
    begin
      Zadanie.KopS.Q:=zadanie.Qw/3600;
      //Zadanie.KopS.GetMainForm.FormStyle := fsMDIChild;
      Zadanie.KopS.GetMainForm.ShowModal;
      Aktualizuj;
    end;
end;

procedure TUNIZadForm.InitSsanieDiagram;
begin
  SsanieDiagram.MinXR  :=   0;
  SsanieDiagram.CountMaxXR( zadanie.Qw*1.3 );

  Hnaplywu := Zadanie.Hzs+Zadanie.Pzs*1000000/1000/9.81;
  Hbar := zadanie.Pbar*100/1000/9.81;
  Pv   := Zadanie.Ciecz.Pv;
  DiagHss := Zadanie.Hss;

  if Hnaplywu>0 then
      PzsDiagFun.CountMaxYR(Hbar+Hnaplywu)
    else
      PzsDiagFun.CountMaxYR(Hbar);
  PompkaDiagFun.Q := zadanie.Qw;
  PompkaDiagFun.H := zadanie.NPSHu;
  LiniaDiagFun.Q :=  zadanie.Qw;
  LiniaDiagFun.H :=  zadanie.NPSHu;
end;

procedure TUNIZadForm.InitPodnoszenieDiagram;
begin
  DiagHst := Zadanie.Hst;
  PodnoszenieDiagram.MinXR  :=   0;
  PodnoszenieDiagram.CountMaxXR( zadanie.Qw );
  HwDiagFun.CountMaxYR(Zadanie.Hw);
  PodPompkaDiagFun.Q := zadanie.Qw;
  PodPompkaDiagFun.H := 0;
  PodLiniaDiagFun.Q := zadanie.Qw;
  PodLiniaDiagFun.H := zadanie.Hw;

end;


procedure TUNIZadForm.PzsDiagFunValue(X: Double; var Y: Double);
begin
  inherited;
  Y:=Hnaplywu+Hbar;
end;

procedure TUNIZadForm.PbarDiagFunValue(X: Double; var Y: Double);
begin
  inherited;
  Y:=zadanie.Pbar*100/1000/9.81;
end;

procedure TUNIZadForm.PvDiagFunValue(X: Double; var Y: Double);
begin
  inherited;
  //Y:=Hnaplywu+Hbar-Zadanie.Hss/Zadanie.Qw/Zadanie.Qw*
  //   X*X - WodaPv(zadanie.Temp)/1000/9.81;
  Y := Hnaplywu+Hbar-DiagHssOdQ(X) - Pv/1000/9.81;
  //Y := Zadanie.KopS.dH(X);
end;

procedure TUNIZadForm.HssDiagFunValue(X: Double; var Y: Double);
begin
  inherited;
  //Y:=Hnaplywu+Hbar-DiagHss/Zadanie.Qw/Zadanie.Qw*
  //   X*X;
  Y := HNaplywu+HBar-DiagHssOdQ(X);
end;

var
  aa:Double;

procedure TUNIZadForm.dfNPSHuFunValue(X: Double; var Y: Double);
begin
  inherited;
  Y:=Hnaplywu+Hbar-DiagHssOdQ(X) - Pv/1000/9.81-zadanie.dNPSH;
  aa := Y;
end;

procedure TUNIZadForm.PvCBoxClick(Sender: TObject);
begin
  inherited;
  PvDiagFun.IsOn := PvCBox.Checked;
end;

procedure TUNIZadForm.HzsDiagFunValue(X: Double; var Y: Double);
begin
  inherited;
  Y:=zadanie.Pbar*100/1000/9.81 + Zadanie.Hzs;
end;

procedure TUNIZadForm.PbarCBoxClick(Sender: TObject);
begin
    PbarDiagFun.IsOn := PbarCBox.Checked;
end;

procedure TUNIZadForm.HzsCBoxClick(Sender: TObject);
begin
  HzsDiagFun.IsOn := HzsCBox.Checked;
end;

procedure TUNIZadForm.PzsCBoxClick(Sender: TObject);
begin
  PzsDiagFun.IsOn := PzsCBox.Checked;
end;

procedure TUNIZadForm.HssCBoxClick(Sender: TObject);
begin
  HssDiagFun.IsOn := HssCBox.Checked;
end;

procedure TUNIZadForm.NPSHuCBoxClick(Sender: TObject);
begin
  dfNPSHuFun.IsOn := NPSHuCBox.Checked;
  PompkaDiagFunction.IsOn := NPSHuCBox.Checked;
  SsanieLiniaDiagFunction.IsOn := NPSHuCBox.Checked;
end;

procedure TUNIZadForm.HwDiagFunValue(X: Double; var Y: Double);
begin
  if IsZero(Zadanie.Qw) then
    Y := 0
  else
    Y := Zadanie.Hg+(Zadanie.Hw-Zadanie.Hg)/Zadanie.Qw/Zadanie.Qw*
         X*X;
end;

FUNCTION    SkalaZmienna( Zakres :Double; var n : integer) :double;
//;
 //                    var MiejscaZer :integer ): Double;
var
  cecha ,miejscaZer      :integer;
  mantysa     :Double;
 // DzialkaMax  :Double;
  LogZakres   :Double;
  MantysaZakresu : Double;
  dzialka     :Double;

begin
  if Zakres = 0 then
    Zakres := 0.1;         {zabezpieczenie na wypadek zlych danych}

  LogZakres := log10(Zakres);
  IF LogZakres>=0 then
    begin
      miejscaZer := 0;
      cecha      := round(int(LogZakres));
      mantysa    := frac(LogZakres);
    end
  ELSE
    begin
      miejscaZer :=  1 - round(int(LogZakres));
      cecha      := -1 + round(int(LogZakres));
      mantysa    :=  1 + LogZakres-int(LogZakres);
    end;
  MantysaZakresu := Power(10,mantysa);
  if MantysaZakresu >=9 then
    begin
      n:=10;
      dzialka := Power(10,cecha);
    end
  else if MantysaZakresu >=8 then
    begin
      n:=9;
      dzialka := Power(10,cecha);
    end
  else if MantysaZakresu >=7 then
    begin
      n:=8;
      dzialka := Power(10,cecha);
    end
  else if MantysaZakresu >=6 then
    begin
      n:=7;
      dzialka := Power(10,cecha);
    end
  else if MantysaZakresu >=5 then
    begin
      n:=6;
      dzialka := Power(10,cecha);
    end
  else if MantysaZakresu >=4.5 then
    begin
      n:=10;
      dzialka := 0.5*Power(10,cecha);
    end
  else if MantysaZakresu >=4 then
    begin
      n:=9;
      dzialka := 0.5*Power(10,cecha);
    end
  else if MantysaZakresu >=3.5 then
    begin
      n:=8;
      dzialka := 0.5*Power(10,cecha);
    end
  else if MantysaZakresu >=3 then
    begin
      n:=7;
      dzialka := 0.5*Power(10,cecha);
    end
  else if MantysaZakresu >=2.5 then
    begin
      n:=6;
      dzialka := 0.5*Power(10,cecha);
    end
  else if MantysaZakresu >=2 then
    begin
      n:=7;
      dzialka := 0.4*Power(10,cecha);
    end
  else if MantysaZakresu >=1.8 then
    begin
      n:=10;
      dzialka := 0.2*Power(10,cecha);
    end
  else if MantysaZakresu >=1.6 then
    begin
      n:=9;
      dzialka := 0.2*Power(10,cecha);
    end
  else if MantysaZakresu >=1.4 then
    begin
      n:=8;
      dzialka := 0.2*Power(10,cecha);
    end
  else if MantysaZakresu >=1.2 then
    begin
      n:=7;
      dzialka := 0.2*Power(10,cecha);
    end
  else if MantysaZakresu >=1 then
    begin
      n:=6;
      dzialka := 0.2*Power(10,cecha);
    end ;
  result := dzialka
end;

procedure TUNIZadForm.AnconaPaintBoxPaint(Sender: TObject);
begin
  rysujANCONE;
end;

procedure TUNIZadForm.rysujANCONE;
var
  i: integer;
  AMaxY: integer;  // wysokosc rysunku
  ATopM: integer;  // margines gorny

  AQmax: double;   // maksymalna wydajnosc na wykresie
  AHmax: double;   // maksymalna wysokosc na wykresie
  DzQ  : double;   // dzialka wydajnosci
  DzH  : double;   // dzialka wysokosci
  mzQ  : integer;  // miejsca zerowe wydajnosci
  nH   : integer;  // liczba dzialek na osi H
  APbar: integer;  // wysokosc Pbar na rysunku
  APzs,APzt : integer; // wysokosc Pz na rysunku
  AHzs,AHzt : integer; // wysokosc Hz na rysunku
  ADzH      : double;
  WspHss,WspHst: Double;  // Wspolczynnik strat i skala
  AQw       :  integer; // polozenie Qw w pikslach
  DTmp      :  Double;
begin

  AMaxY:=250;
  ATopM:=10;
  DzQ:=Dzialka(zadanie.Qw,8,mzQ);   // 8 dzialek
  AQmax:=DzQ*8;
  AHmax:= zadanie.Pbar*100/1000/9.81 + zadanie.Hzt+
          zadanie.Pzt*1000000/1000/9.81+
          F_DIV(zadanie.Hst, sqr(zadanie.Qw))*AQmax*AQmax;
  DzH:=SkalaZmienna(AHmax,nH);
  DTmp := F_DIV( AmaxY, DzH*nH );
  APbar:= round(zadanie.Pbar*100/1000/9.81* DTmp);
  APzs:= round(zadanie.Pzs*1000000/1000/9.81* DTmp);
  Apzt:= round(zadanie.Pzt*1000000/1000/9.81* DTmp);
  AHzs:= round(zadanie.Hzs * DTmp);
  AHzt:= round(zadanie.Hzt * DTmp);
  ADzH:= F_DIV(AmaxY,nH);


  With ANCONAPaintBox.canvas do
    begin
      Pen.color:=clBlack;
      Pen.width:=1;
//      Brush.Color := clBtnFace;
      SetBkMode(handle,Transparent);
      font.color:= clWindowText;
      {ramka}
      MoveTo(50,AMaxY+ATopM);  LineTo(450,AMaxY+ATopM);
      MoveTo(50,AMaxY+ATopM);  LineTo(50,ATopM);
      MoveTo(150,AMaxY+ATopM);  LineTo(150,ATopM);
      MoveTo(350,AMaxY+ATopM);  LineTo(350,ATopM);
      MoveTo(450,AMaxY+ATopM);  LineTo(450,ATopM);
      TextOut(70,2,'SSANIE');
      TextOut(215,2,'PODNOSZENIE');
      TextOut(367,2,'TLOCZENIE');
      {skala H}
      for i:=0 to nH+1 do
        begin
          MoveTo(45,AMaxY+ATopM-round(ADzH*i));  LineTo(55,AMaxY+ATopM-round(ADzH*i));
          MoveTo(445,AMaxY+ATopM-round(ADzH*i));  LineTo(455,AMaxY+ATopM-round(ADzH*i));
          TextOut(20,AMaxY+ATopM-round(ADzH*i)-5,FloatToStr(Dzh*i));
        end;
      TextOut(0,2,'H');
      TextOut(0,12,'[m]');
      {skala Q}
      for i:=0 to 8 do
        begin
          MoveTo(150+25*i,AMaxY+ATopM-5);  LineTo(150+25*i,AMaxY+ATopM+5);
          TextOut(140+25*i,AMaxY+ATopM+5,FloatToStr(DzQ*i));
        end;
      TextOut(360,AMaxY+ATopM+5,'Q [m3/h]');
      {Pbar Ssanie}
      Pen.color   := clNavy;
      Brush.Color := clNavy;
      Rectangle(70,AMaxY+ATopM,100,AMaxY+ATopM-APbar);
      Rectangle(400,AMaxY+ATopM,430,AMaxY+ATopM-APbar);
      Font.color   := clWhite;
      if APbar>11 then
        begin
          TextOut(77,AMaxY+ATopM-Round(APbar/2)-6,'Pb');
          TextOut(407,AMaxY+ATopM-Round(APbar/2)-6,'Pb');
        end;
      {Pzs}
      Pen.color   := clBlue;
      Brush.Color := clBlue;
      Rectangle(70,AMaxY+ATopM-APbar,100,AMaxY+ATopM-APbar-APzs);
      Font.color   := clWhite;
      if APzs>11 then
          TextOut(77,AMaxY+ATopM-APbar-Round(APzs/2)-6,'Pzs');
      {Pzt}
      Pen.Color   := clTeal;
      Brush.Color := clTeal;
      Rectangle(400,AMaxY+ATopM-APbar,430,AMaxY+ATopM-APbar-APzt);
      Font.color   := clWhite;
      if APzt>11 then
          TextOut(407,AMaxY+ATopM-APbar-Round(APzt/2)-6,'Pzt');
      {Hzs}
      Pen.Color   := clAqua;
      Brush.Color := clAqua;
      Rectangle(110,AMaxY+ATopM-APbar-APzs,140,AMaxY+ATopM-APbar-APzs-AHzs);
      Font.color   := clBlack;
      if Abs(AHzs)>11 then
          TextOut(117,AMaxY+ATopM-APbar-APzs-Round(AHzs/2)-6,'Hzs');
      {Hzt}
      Pen.Color   := clGreen;
      Brush.Color := clGreen;
      Rectangle(360,AMaxY+ATopM-APbar-APzt,390,AMaxY+ATopM-APbar-APzt-AHzt);
      Font.color   := clWhite;
      if Abs(AHzt)>11 then
          TextOut(367,AMaxY+ATopM-APbar-APzt-Round(AHzt/2)-6,'Hzt');
      {odnosniki}
      Pen.Color   := clBlack;
      MoveTo(70,AMaxY+ATopM-APbar-APzs);  LineTo(140,AMaxY+ATopM-APbar-APzs);
      MoveTo(110,AMaxY+ATopM-APbar-APzs-AHzs);
      LineTo(350,AMaxY+ATopM-APbar-APzs-AHzs);
      MoveTo(360,AMaxY+ATopM-APbar-APzt);  LineTo(430,AMaxY+ATopM-APbar-APzt);
      MoveTo(150,AMaxY+ATopM-APbar-APzt-AHzt);
      LineTo(390,AMaxY+ATopM-APbar-APzt-AHzt);

      {Opory ssania}
      Pen.Color:= clBlack;
      MoveTo(150,AMaxY+ATopM-APbar-APzs-AHzs);
      WspHss := F_DIV(AMaxY,DzH*nH) * F_DIV(Zadanie.Hss, sqr(Zadanie.Qw)) *
              DzQ*DzQ/25/25;
      for i:=1 to 199 do
        LineTo(150+i,AMaxY+ATopM-APbar-APzs-AHzs+Round(WspHss*i*i));
      {Opory tloczenia}
      Pen.Color:= clBlack;
      MoveTo(150,AMaxY+ATopM-APbar-APzt-AHzt);
      WspHst:=AMaxY/DzH/nH * Zadanie.Hst/Zadanie.Qw/Zadanie.Qw *
              DzQ*DzQ/25/25;
      for i:=1 to 199 do
        LineTo(150+i,AMaxY+ATopM-APbar-APzt-AHzt-Round(WspHst*i*i));

      {Hg}
      Pen.Color   := clYellow;
      Brush.Color := clYellow;
      AQw:=round(Zadanie.Qw/DzQ*25);
      Rectangle(160,AMaxY+ATopM-APbar-APzs-AHzs,
                190,AMaxY+ATopM-APbar-APzt-AHzt+1);
      Font.color   := clBlack;
      if Abs(APzt+AHzt-APzs-AHzs)>11 then
      TextOut(167,AMaxY+ATopM-APbar-APzs-AHzs-Round((APzt+AHzt-APzs-AHzs)/2)-6,'Hg');
      {Hss}
      Pen.Color   := clBlack;
      Brush.Color := clBlack;
      Rectangle(160,AMaxY+ATopM-APbar-APzs-AHzs+Round(WspHss*AQw*AQw),
                190,AMaxY+ATopM-APbar-APzs-AHzs);
      Font.color   := clWhite;
      if Abs(WspHss*AQw*AQw)>11 then
      TextOut(167,AMaxY+ATopM-APbar-APzs-AHzs+Round(WspHss*AQw*AQw/2)-6,'Hss');
      {Hst}
      Pen.Color   := clBlack;
      Brush.Color := clBlack;
      Rectangle(160,AMaxY+ATopM-APbar-APzt-AHzt-Round(WspHst*AQw*AQw),
                190,AMaxY+ATopM-APbar-APzt-AHzt);
      Font.color   := clWhite;
      if Abs(WspHst*AQw*AQw)>11 then
      TextOut(167,AMaxY+ATopM-APbar-APzt-AHzt-Round(WspHst*AQw*AQw/2)-6,'Hst');

      {Pompka}
      pompka(150+AQw,AMaxY+ATopM-APbar-APzs-AHzs+Round(WspHss*AQw*AQw));
      Pen.Color:= clRed;
      Pen.width:=3;
      Brush.Color := clRed;
      MoveTo(150+AQw,AMaxY+ATopM-APbar-APzs-AHzs+Round(WspHss*AQw*AQw)-6);
      LineTo(150+AQw,AMaxY+ATopM-APbar-APzt-AHzt-Round(WspHst*AQw*AQw)+3);
      Pen.width:=1;
      Ellipse(150+AQw-3,AMaxY+ATopM-APbar-APzt-AHzt-Round(WspHst*AQw*AQw)-3,
              150+AQw+3,AMaxY+ATopM-APbar-APzt-AHzt-Round(WspHst*AQw*AQw)+3);
    end;
end;

procedure TUNIZadForm.pompka(xp,yp:integer);
begin
  With ANCONAPaintBox.canvas do
    begin
      Pen.Color   := clBlack;
      Brush.Color := clWhite;
      Ellipse(xp-7,yp-7,xp+7,yp+7);
      Brush.Color := clBlue;
      Polygon([Point(xp-5,yp+2), Point(xp+5,yp+2),Point(xp,yp-6)]);
    end;
end;

procedure TUNIZadForm.HgCheckBClick(Sender: TObject);
begin
  inherited;
  HgPodDiagFun.IsOn := HgCheckB.Checked;
end;

procedure TUNIZadForm.HgPodDiagFunValue(X: Double; var Y: Double);
begin
  inherited;
  Y:=zadanie.Hg;
end;

procedure TUNIZadForm.HwCheckBClick(Sender: TObject);
begin
  inherited;
  HwDiagFun.IsOn := HwCheckB.Checked;
end;

procedure TUNIZadForm.HwLCheckBClick(Sender: TObject);
begin
  inherited;
  PodPompkaDiagF.IsOn := HwLCheckB.Checked;
  PodLiniaDiagF .IsOn := HwLCheckB.Checked;
end;


procedure TUNIZadForm.FormActivate(Sender: TObject);
begin
//  KatalogGlowneOkno.caption:='Zadanie przepompownia sciekow Typ Meprozet';
 if zadanie<>nil then
    Aktualizuj;
end;

procedure TUNIZadForm.FormKeyPress(Sender: TObject; var Key: Char);
var a : TFormatSettings;

begin
 if Key in [ #32..#127 ]
            - ( [ '0'..'9','-', '.', ',' ]
               //+[ DecimalSeparator ] )then
               +[ a.DecimalSeparator ] )then

  begin
    Key := #0;
  end
  else
  begin
    case Key of
      '.',',' :
//        Key := DecimalSeparator;
        Key := a.DecimalSeparator;

      #13     :
      begin
        Perform(WM_NEXTDLGCTL,0,0);
        Key := #0;
      end;
    end;
  end;
end;

procedure TUNIZadForm.TimerNPSHuTimer(Sender: TObject);
//const
var
  w : Boolean ;
begin
  w := true;
  inherited;
  if zadanie <> nil then
  begin
   if Zadanie.NPSHu <= 0 then
    begin
     if w then
     begin
      Label10.font.Color := clRed;
      Label5.font.Color := clRed;
      NPSHuLabel.font.Color := clRed;
     end else begin
               Label10.font.Color := clYellow;
               Label5.font.Color := clYellow;
               NPSHuLabel.font.Color := clYellow;
              end
    end else begin
              Label10.font.Color := clWindowText;
              Label5.font.Color := clWindowText;
              NPSHuLabel.font.Color := clWindowText;
              TimerNPSHu.Enabled := False;
             end;
  end;
  w := Not w;
end;

function TUNIZadForm.DiagHssOdQ(Q: Real): Real;
begin
  if Zadanie.JestKopS then
    result := Zadanie.KopS.dH(Q)
  else
    result := DiagHss/sqr(Zadanie.Qw) * sqr(Q);
end;

function TUNIZadForm.HstOdQ(Q: Real): Real;
begin
  if Zadanie.JestKopS then
    result := Zadanie.KopT.dH(Q)
  else
    result := DiagHst/sqr(Zadanie.Qw) * sqr(Q);
end;

procedure TUNIZadForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = ZadSzukajDlaUNI then
      ZadSzukajDlaUNI := NIL
//    else if AComponent = Raport then
//      Raport := NIL
//    else if AComponent = RapForm then
//      RapForm := NIL;
  end;
end;

procedure TUNIZadForm.CloseRaport;
begin
//  if (Raport <> NIL) and (not FRapClosed) then
//  begin
//    FRapClosed := true;
//    RapForm.ClosePreview;
//    RapForm.Free;
//    Raport.Free;
//  end;
end;

end.
