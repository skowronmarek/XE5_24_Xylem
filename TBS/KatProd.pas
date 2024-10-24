unit KatProd;

interface

uses
  Classes,
  SysUtils,
  Menus,
  OutLine,
  Forms,
  IniFiles,
  Controls,

  DBITYPES,    {procedury obslugi IDAPI}
  DBIPROCS,
  DBIERRS,

  DB,
  DBTables,
  TbsU,
  Graphics,
  KR_Sys,
  KR_Class,
  KR_DB,
  BInfoU,
  WkpGlob,
  prod;


function InitDefProd( const SciezkaBaz: string ): TProducenci;


implementation

uses
  IniFrmUn;         { Init Form Unit }


{-----------------------------------------------------------------------------}
function InitDefProd( const SciezkaBaz: string ): TProducenci;
var
  res      :TProducenci;   // Lista producentow
  FName    :string;
  Wild     :string;
  Katalog  :string;
  id       :string;

  BaseType :string;        // MS 2024.10.22 dodana wersja nbazy

  i, KatOK :integer;
  sr, KatSr:TSearchRec;
  produc   :TProducent;   // pojedynczy producent
  F        :TextFile;
  IniF     :TIniFile;
  bi       :TBaseInfo;
begin
  res := Producenci;                                              // Producenci o objekt z okna glownego
  Katalog := SciezkaBaz + '\*.*';
  KatOK := FindFirst( Katalog, faDirectory, KatSr );
  try
    while KatOK = 0 do  // przeszukiwanie katalogow w celu wykrycia baz
    begin
      if (KatSr.Attr and faDirectory) <> 0 then
      begin
        Katalog := SciezkaBaz +'\'+ KatSr.Name;
        Wild := Katalog + '\*.tbs';
        i := FindFirst( Wild, Integer(faArchive) or Integer(faReadOnly), sr );
        while i = 0 do
        begin
          FName := Katalog+'\'+sr.Name;
          AssignFile( F, FName );
          Reset(F);
          ReadLn( F, id );
          CloseFile(F);
          if IsPrefix( ';TECHNICAL BASE STANDARD FILE', Id ) then
          begin
            IniF := TIniFile.Create(FName);
            id := IniF.ReadString('MAIN', 'Type', '' );

            if Upper(id) = 'PRODUCER' then                             // jezeli zadeklarowano producenta w TBS
            begin
              id := copy( sr.Name, 3, pos( '.', sr.Name)-3 );          // po co to Id MS 2024.10.22 ???

              produc := TProducent.CreateFromTBSFile( IniF,
                                                      ExtractFilePath(FName),
                                                      res);                         // robi liste baz dla producenta na podstawie TBS

              BaseType := IniF.ReadString('MAIN', 'BaseType', '' );

              if WerProdPomp and (produc.Ident = GlobProdId) then
              begin
                SciezkaZasob := produc.SciezkaDoBaz+'\';
              end;
              InitForm.DodajProducenta( produc );
              res.AddProd( produc );
              if WerProdPomp then
                if produc.Ident = GlobProdId then
                begin
                  bi := produc.InfoBazT['PUMPS'];
                  if bi <> NIL then
                    KluczePompIni := bi.tbsf;
                end;
            end;
          end;
          Application.ProcessMessages;
          i := FindNext(sr);
        end;

        FindClose(sr);
        Application.ProcessMessages;
      end;
      KatOK := FindNext( KatSr );
    end;     { while KatOK = 0}
  finally
    FindClose( KatSr );
  end;

  InitDefProd := res;
end;



end.
