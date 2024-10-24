unit MotorFormU;

interface


uses
  Windows, ShellApi, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, Variants,
  ExtCtrls, DBTables, StdCtrls, EditNew, ComCtrls,
  TbsFormU,
  DxfDraws, Diagrams, ObjView, KR_Sys, KR_DB,
  Tbs_Tool, BInfoU, Prod,
//  PodgladRaportU, RaportPustyU,
  MotorObjU, DBMotorsU;

type
  TMotorForm = class(TTbsForm)
    Zakladki: TPageControl;
    TabDane: TTabSheet;
    LabSilnik: TLabel;
    labTypSilnika: TLabel;
    labNapiecieZnamionowe: TLabel;
    labMocSilnika: TLabel;
    labPradZnamionowy: TLabel;
    labSprawnosc: TLabel;
    labStopOchr: TLabel;
    labKlIzol: TLabel;
    labObroty: TLabel;
    labCosinusFi: TLabel;
    edTypSilnika: TEditN;
    edNapZnam: TEditN;
    edMocZnam: TEditN;
    edObroty: TEditN;
    edPradZnam: TEditN;
    edCosFi: TEditN;
    edSprawn: TEditN;
    edIP: TEditN;
    edKlasaIzol: TEditN;
    TabCharakterystyki: TTabSheet;
    TabRysunek: TTabSheet;
    panRysBtns: TPanel;
    panRysunek: TPanel;
    paintRysunek: TPaintBox;
    panDiagBtns: TPanel;
    Diagram: TDiagram;
    funI: TDiagFunction;
    funCosFi: TDiagFunction;
    funN: TDiagFunction;
    descrI: TDiagDescr;
    descrCosFi: TDiagDescr;
    descrN: TDiagDescr;
    funEta: TDiagFunction;
    descrEta: TDiagDescr;
    descrP: TDiagDescr;
    TabOpis: TTabSheet;
    panOpisBtns: TPanel;
    obvOpis: TObjectView;
    TabRaport: TTabSheet;
    PanelDoWst: TPanel;
    btnInfo: TBitBtn;
    ZoomBtn: TSpeedButton;
    edMomentBezwl: TEditN;
    edMasa: TEditN;
    LabMotMasa: TLabel;
    LabMotBezwlad: TLabel;
    labMotFreq: TLabel;
    edFreq: TEditN;
    procedure paintRysunekPaint(Sender: TObject);
    procedure funIValue(X: Double; var Y: Double);
    procedure funCosFiValue(X: Double; var Y: Double);
    procedure funNValue(X: Double; var Y: Double);
    procedure funEtaValue(X: Double; var Y: Double);
    procedure FormCreate(Sender: TObject);
    procedure TabRaportShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnInfoClick(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
  private
    FMotor : TMotorElektr;
    FDxf   : TDXFDrawing;
//    FrmPrev       : TPodgladRaport;
//    Rap           : TRaportPusty;
    FRapClosed    : Boolean;
    FCaptionSzablon: string;

    procedure CreateRap;
    procedure CloseRap;
    procedure EnableBtnInfo;
    procedure SetMotor(const Value: TMotorElektr);
    procedure Init;
    procedure InitOpis;
    procedure InitTitle;
    procedure SetCaptionSzablon(const Value: string);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create( AOwner :TComponent );            override;
    destructor Destroy;                                  override;

    property Motor :TMotorElektr read FMotor write SetMotor;
    property Dxf   :TDXFDrawing  read FDxf;
  published
    property CaptionSzablon :string read FCaptionSzablon write SetCaptionSzablon;
  end;

var
  MotorForm: TMotorForm;

implementation

uses
  {MotRapU,} RysFrm;

{$R *.DFM}

{ TMotorForm }

procedure TMotorForm.Init;
begin
  if FMotor <> NIL then
  begin
    InitTitle;
    edTypSilnika.Text := Motor.Nazwa;
    edNapZnam.ValueFloat   := Motor.UZn;
    edMocZnam.ValueFloat   := Motor.PZn;
    edObroty.ValueFloat    := Motor.NZn;
    edPradZnam.ValueFloat  := Motor.IZn;
    edCosFi.ValueFloat     := Motor.CosFiZn;
    edSprawn.ValueFloat    := Motor.EtaZn;
    edIP.Text              := Motor.IP;
    edKlasaIzol.Text       := Motor.Klasa;
    edMomentBezwl.ValueFloat := Motor.MBezwl;
    edMasa.ValueFloat      := Motor.Masa;
    edFreq.ValueFloat      := Motor.FreqZn;
    if Motor.FunI <> NIL then
    begin
      Diagram.CountMaxXR(Motor.FunI.XMax);
      funI.CountMaxYR(Motor.FunI.YMax);
      funI.MinXRDraw := Motor.FunI.XMin;
      funI.MaxXRDraw := Motor.FunI.XMax;
      funEta.MinXRDraw := Motor.FunI.XMin;
      funEta.MaxXRDraw := Motor.FunI.XMax;
    end;
    if Motor.FunCosFi <> NIL then
    begin
      //funCosFi.CountMaxYR(Motor.FunCosFi.YMax);
      funCosFi.MinXRDraw := Motor.FunCosFi.XMin;
      funCosFi.MaxXRDraw := Motor.FunCosFi.XMax;
    end;
    if Motor.FunN <> NIL then
    begin
      funN.CountMaxYR(Motor.FunN.YMax);
      funN.MinXRDraw := Motor.FunN.XMin;
      funN.MaxXRDraw := Motor.FunN.XMax;
    end;
    FDxf := Motor.CreateDxf;
    InitOpis;
    EnableBtnInfo;
  end;

end;

procedure TMotorForm.SetMotor(const Value: TMotorElektr);
begin
  if FMotor <> NIL then
    FMotor.Release;
  FMotor := Value;
  if FMotor <> NIL then
    FMotor.AddRef;
  Init;
end;

procedure TMotorForm.paintRysunekPaint(Sender: TObject);
begin
  if FDxf = NIL then
    EXIT;
  with paintRysunek do
    FDxf.DrawStrech(Canvas, ClientRect );
end;

procedure TMotorForm.funIValue(X: Double; var Y: Double);
begin
  inherited;
  if (Motor <> NIL) and (Motor.FunI <> NIL) then
    Y := Motor.I_OdP(X)
  else
    Y := 0;
end;

procedure TMotorForm.funCosFiValue(X: Double; var Y: Double);
begin
  inherited;
  if (Motor <> NIL) and (Motor.FunCosFi <> NIL) then
    Y := Motor.CosFi_OdP(X)
  else
    Y := 0;
end;

procedure TMotorForm.funNValue(X: Double; var Y: Double);
begin
  inherited;
  if (Motor <> NIL) and (Motor.FunN <> NIL) then
    Y := Motor.N_OdP(X)
  else
    Y := 0;
end;

procedure TMotorForm.funEtaValue(X: Double; var Y: Double);
begin
  inherited;
  if Motor <> NIL then
    Y := Motor.Eta_OdP(X)
  else
    Y := 0;
end;

procedure TMotorForm.InitOpis;
var
  DB      :TDBMotors;
begin
  DB := TDBMotors.CreateForProd( self, Motor.Producent );
  try
    if DB.A.Locate( 'NAZWA;TYP_ID', VarArrayOf([Motor.Nazwa, Motor.TYP_ID]),[])then
    begin
      if DB.B.Locate( 'ID', DB.T['OPIS'], [] ) then
        ObjViewFromBinBase(obvOpis, DB.B);
    end;
  finally
    DB.Free;
  end;
end;

procedure TMotorForm.FormCreate(Sender: TObject);
begin
  inherited;
  Zakladki.ActivePage := TabDane;
end;

procedure TMotorForm.CloseRap;
begin
//  if (Rap <> NIL) and (not FRapClosed) then
//  begin
//    FRapClosed := true;
//    FrmPrev.ClosePreview;
//    FrmPrev.Free;
//    Rap.Free;
//  end;
end;

procedure TMotorForm.CreateRap;
begin
//  if (Rap = NIL) and (Motor <> NIL) then
//  begin
//    Rap := TRaportMotoru.Create(self);
//    Rap.ReportTitle := Format( 'Silnik: %s', [Motor.Nazwa] );
//    with TRaportMotoru(Rap) do
//    begin
//      Motor := self.Motor;
//      MForm := self;
//    end;
//    FRapClosed := false;
//    OsadzRaport( self, Rap, PanelDoWst, FrmPrev);
//  end;
end;

procedure TMotorForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
  begin
//    if AComponent = FrmPrev then
//      FrmPrev := NIL
//    else if AComponent = Rap then
//      Rap := NIL;
  end;
  inherited;
end;

procedure TMotorForm.TabRaportShow(Sender: TObject);
begin
  inherited;
  CreateRap;
end;

procedure TMotorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseRap;
  inherited;
end;

procedure TMotorForm.btnInfoClick(Sender: TObject);
var
  bi           :TBaseInfo;
  Tab          :TTable;
  TN           :string;
  CD           :string;
  CDs          :string;
  HtmlPath     :string;
  HtmlMot      :string;
  param        :string;
  ADB          :TDBMotors;
  found        :Boolean;
begin
  bi := Motor.Producent.InfoBazT['MOTORS'];
  TN := bi.GetBaseName('Links');
  if TN <> '' then
  begin
    ADB := TDBMotors.CreateForProd( self, Motor.Producent );
    if Motor.LocateDB(ADB) then
    try
      Tab := TTable.Create(self);
      try
        TableSetNames( TN, Tab );
        Tab.Open;
        if MultiIdFindBest( ADB.A, Tab, 5 ) then
        begin
          found := False;
          CDs  := GetCDRomDrives;
          repeat
            CD := StrBefore(';', CDs);
            CDs := StrBehinde(';', CDs);
            HtmlPath := bi.tbsf.ReadString( 'PATHS', 'HtmlPath', '' );
            HtmlMot := bi.tbsf.ReadString( 'PATHS', 'HtmlMot', '' );
            param := StrAssignPar( Tab.FieldByName('LINK').AsString,
                                   [ 'CD_KATAL', 'HtmlPath', 'HtmlMot' ],
                                   [ CD, HtmlPath, HtmlMot ] );

            if FileExists( Param ) then
            begin
              ShellExecute(0, Nil, PChar(Param), Nil, Nil, SW_NORMAL);
              found := True;
            end;
          until found or (Length(CDs) = 0);
          if not found then
            ShowMessageFmt( 'Nie ma pliku %s.%s'+
                            'Brak plyty CD lub niewlasciwa plyta',
                            [ Param, #13 ] );
        end;
        //else
          //Panel1.Caption := 'Nie znaleziono';
      finally
        Tab.Free;
      end;
    finally
      ADB.Free;
    end;
  end;
end;

procedure TMotorForm.ZoomBtnClick(Sender: TObject);
var
  RForm   :TRysForm;
begin
  RForm   := TRysForm.Create(self);
  RForm.DXFDraw := FDxf;
  RForm.Nazwa := Motor.Nazwa;
  RForm.Show;
  RForm.InitInner;
end;

procedure TMotorForm.SetCaptionSzablon(const Value: string);
begin
  FCaptionSzablon := Value;
  if Motor <> NIL then
    InitTitle;
end;

procedure TMotorForm.InitTitle;
begin
  Caption := Format( CaptionSzablon, [Motor.Producent.Nazwa, Motor.Nazwa] );
end;

constructor TMotorForm.Create(AOwner: TComponent);
begin
  inherited;
  FCaptionSzablon := '[%s] Silnik: %s';
end;

destructor TMotorForm.Destroy;
begin
  FMotor.Release;
  inherited;
end;

procedure TMotorForm.EnableBtnInfo;
var
  ADB          :TDBMotors;
  bi           :TBaseInfo;
  Tab          :TTable;
  TN           :string;
  enable       :Boolean;
begin
  bi := Motor.Producent.InfoBazT['MOTORS'];
  TN := bi.GetBaseName('Links');
  if TN <> '' then
  begin
    enable := False;
    ADB := TDBMotors.CreateForProd( self, Motor.Producent );
    if Motor.LocateDB(ADB) then
    try
      Tab := TTable.Create(self);
      try
        TableSetNames( TN, Tab );
        Tab.Open;
        enable := MultiIdFindBest( ADB.A, Tab, 4 );
      finally
        Tab.Free;
      end;
    finally
      ADB.Free;
    end;
    btnInfo.Enabled := enable;
  end
  else
    btnInfo.Visible := False;
end;

end.
