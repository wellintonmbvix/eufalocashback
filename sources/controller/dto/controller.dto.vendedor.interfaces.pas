unit controller.dto.vendedor.interfaces;

interface

uses
  model.vendedor,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IVendedor = interface
    ['{B938EFCF-28F7-4BD5-AA93-08F5382BA9A3}']

    function codigo(value: Integer): IVendedor; overload;
    function codigo: Integer; overload;

    function nome(value: String): IVendedor; overload;
    function nome: String; overload;

    function ativo(value: Boolean): IVendedor; overload;
    function ativo: Boolean; overload;

    function sincronizado(value: TDateTime): IVendedor; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tvendedor>;
  end;

implementation

end.
