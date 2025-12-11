unit model.service.vendas.interfaces;

interface

uses
  System.JSON;

type
  IVendaService = interface
    ['{FA5F00AE-2BC1-4A66-B531-1192A60C957E}']
    function Save(vendas: TJSONArray; out msgError: String): IVendaService;
    function Delete(vendas: TJSONArray; out msgError: String): IVendaService;
  end;

implementation

end.
