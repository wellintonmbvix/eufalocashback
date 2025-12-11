unit model.service.categoria.interfaces;

interface

uses
  System.JSON;

type
  ICategoriaService = interface
    ['{DAE2245C-3560-4441-A069-02497A9839FC}']
    function Save(categorias: TJSONArray; out msgError: String)
      : ICategoriaService;
  end;

implementation

end.
