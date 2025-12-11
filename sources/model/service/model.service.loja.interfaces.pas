unit model.service.loja.interfaces;

interface

uses
  System.JSON;

type
  ILojaService = interface
    ['{F17803C9-2B3B-4EF3-86B2-99A3363FAE04}']
    function Save(lojas: TJSONArray; out msgError: String): ILojaService;
  end;

implementation

end.
