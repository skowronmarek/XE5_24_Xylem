unit FiltryRes;

interface

resourcestring
  SQPanelHint        = 'Q wymagane|Wymagana wydajnosc pompy';
  SHPanelHint        = 'H wymagane|Wymagana wysokosc podnoszenia pompy';
  STempPanelHint     = 'Temp. cieczy|Temperatura czynnika tlocznego';

  SZastPanelHint     =
         '|Przewidywane zastosowania pompy'#13#10+
         'Przy wybraniu wiecej niz jednego zastosowania'#13#10+
         'filtr ogranicza liste do pomp spelniajacych wszystkie wymagania';

  SKonstrPanelHint   =
         '|Pozadany typ konstrukcyjny pompy'#13#10+
         'Przy wybraniu wiecej niz jednego typu'#13#10+
         'filtr ogranicza liste do pomp spelniajacych wszystkie wymagania';

  STypPanelHint      =
         '|Pozadany typoszereg pompy'#13#10+
         'Przy wybraniu wiecej niz jednego typoszeregu'#13#10+
         'filtr dopuszcza pompy nalezace dowolnego z wybranych typoszeregow';

implementation

end.
