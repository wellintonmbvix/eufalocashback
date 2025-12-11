unit model.service.produto.interfaces;

interface

uses
  System.JSON;

type
  IProdutoService = interface
    ['{0D16CB5C-BA8E-44F0-85F7-1B2694050640}']
    function Save(produtos: TJSONArray; out msgError: String)
      : IProdutoService;
  end;

implementation

end.
