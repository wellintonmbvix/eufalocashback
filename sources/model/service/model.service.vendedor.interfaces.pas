unit model.service.vendedor.interfaces;

interface

uses
  System.JSON;

type
  IVendedorService = interface
    ['{9C5E1CAA-878E-4261-AD7B-248111889B25}']
    function Save(vendedores: TJSONArray; out msgError: String): IVendedorService;
  end;

implementation

end.
