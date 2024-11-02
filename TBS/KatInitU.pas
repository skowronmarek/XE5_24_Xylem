unit KatInitU;

interface

uses
  SysUtils, Forms, Controls;

procedure WkpInit;
procedure WkpDone;


implementation

uses
  TbsU,
  WkpGlob,
  IniFrmUn,
  Jednost,
  Prod,
  KatProd,
  Dialogs,
  JezykTxt,
  FiltryGlob
  , IniFiles;

procedure SetCursor( f: TForm; c: TCursor );
begin
  Screen.Cursor := c;
end;


procedure WkpInit;

begin
  try
    setCursor( InitForm, crHourGlass );

    InitForm.OKBtn.Enabled := false;
    InitForm.Show;

    
    // oba mechanizmy poniuzej do wyciecia
    UstawJezyk( WkpIni.ReadString('Opcje','Jezyk','PL') );
    JednostkiInit( WkpIni );

    //Application.HelpFile := SciezkaWkp+'hlp\Katalog.chm';
    //Application.HelpFile := SciezkaWkp+'hlp\Katalog.HLP';
    //plication.HelpFile := SciezkaWkp+'hlp\Siec.HLP';


    Application.ProcessMessages;
    DozwBazy := '/PUMPS/PIPES/MOTORS/TANKS/PRESS/';  // 2024.10.13 MS dodany nowy typ baz
    //DozwBazy := '/PUMPS/SQL_PUMPS/PIPES/MOTORS/TANKS/PRESS/';  // 2024.10.13 MS dodany nowy typ baz

    InitDefProd( SciezkaBaz );  // Wywolanie KatProd / tworzy liste Producentow dla (SciezkaBaz) - zwykle katalog programu

    // 2024.10.18 FiltryPomp.Init;
    if Producenci.Komunikaty.CzySaOstrzerzenia then
      ShowMessage(Producenci.Komunikaty.DajOstrzerzenia);
    InitForm.OKBtn.Enabled := true;
    if not InitForm.WaitCheck.Checked then
      InitForm.Close;

    setCursor( InitForm, crDefault );

    while InitForm.Active do Application.ProcessMessages;


  except
    on exc: IniException do
    begin
      ShowMessage('Aplikacja zle zainstalowana');
      Application.Terminate;
    end
    else
    begin
      InitForm.Close;
    end;
  end;

end;


procedure WkpDone;
begin
//  WkpIni.WriteString('Opcje','Jezyk',ZwrocJezyk );
end;




end.
