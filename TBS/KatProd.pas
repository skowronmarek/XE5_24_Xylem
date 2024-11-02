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
{ szuka plikow TBS (zwykle w katalogu programu)                               }
{ tworzy liste producentow                                                    }
{-----------------------------------------------------------------------------}
function InitDefProd( const SciezkaBaz: string ): TProducenci;
var
  ListaProd :TProducenci;
  FName     :string;
  Wild      :string;
  Katalog   :string;
  id        :string;

  BaseType  :string;        // MS 2024.10.22 dodana wersja nbazy

  i, KatOK  :integer;
  sr, KatSr :TSearchRec;
  Producent :TProducent;   // pojedynczy producent
  F         :TextFile;
  IniF      :TIniFile;
  bi        :TBaseInfo;
begin
  ListaProd := Producenci;                                              // Producenci o objekt z okna glownego
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

              Producent := TProducent.CreateFromTBSFile( IniF,
                                                      ExtractFilePath(FName),
                                                      ListaProd);                         // robi liste baz dla producenta na podstawie TBS

              // MS 2024 BaseType := IniF.ReadString('MAIN', 'BaseType', '' );

              if WerProdPomp and (Producent.Ident = GlobProdId) then
              begin
                SciezkaZasob := Producent.SciezkaDoBaz+'\';
              end;
              InitForm.DodajProducenta( Producent );
              ListaProd.AddProd( Producent );
              if WerProdPomp then
                if Producent.Ident = GlobProdId then
                begin
                  bi := Producent.InfoBazT['PUMPS'];
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

  InitDefProd := ListaProd;
end;



end.
