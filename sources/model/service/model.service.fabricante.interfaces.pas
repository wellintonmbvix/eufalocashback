unit model.service.fabricante.interfaces;

interface

uses
  System.JSON;

type
  IFabricanteService = interface
    ['{A06929EE-993A-4723-852A-D4542F636907}']
    function Save(fabricantes: TJSONArray; out msgError: String): IFabricanteService;
  end;

implementation

end.
