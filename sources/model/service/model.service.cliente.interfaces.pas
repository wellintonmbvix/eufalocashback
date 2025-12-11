unit model.service.cliente.interfaces;

interface

uses
  System.JSON;

type
  IClienteService = interface
    ['{14200A3D-80C0-46FC-95C6-EB5F5B39CBD5}']
    function Save(clientes: TJSONArray; out msgError: String): IClienteService;
  end;

implementation

end.
