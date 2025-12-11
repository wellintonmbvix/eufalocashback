unit controller.dto.forma_pagto.interfaces;

interface

uses
  model.forma_pagto,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IFormaPagto = interface
    ['{9C6F515C-D76D-425E-82ED-A82C02351CBA}']

    function codigo(value: Integer): IFormaPagto; overload;
    function codigo: Integer; overload;

    function descricao(value: String): IFormaPagto; overload;
    function descricao: String; overload;

    function ativo(value: Boolean): IFormaPagto; overload;
    function ativo: Boolean; overload;

    function sincronizado(value: TDateTime): IFormaPagto; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tforma_pagto>;
  end;

implementation

end.
