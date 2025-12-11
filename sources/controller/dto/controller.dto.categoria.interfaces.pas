unit controller.dto.categoria.interfaces;

interface

uses
  model.categoria,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  ICategoria = interface
    ['{14B0618F-237A-482C-98A9-02B21B0F80CD}']

    function codigo(value: Integer): ICategoria; overload;
    function codigo: Integer; overload;

    function nomeCategoria(value: String): ICategoria; overload;
    function nomeCategoria: String; overload;

    function categoriaPai(value: Integer): ICategoria; overload;
    function categoriaPai: Integer; overload;

    function sincronizado(value: TDateTime): ICategoria; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tcategoria>;
  end;

implementation

end.
