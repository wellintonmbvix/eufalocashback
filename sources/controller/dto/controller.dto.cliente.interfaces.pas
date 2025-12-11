unit controller.dto.cliente.interfaces;

interface

uses
  model.cliente,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  ICliente = interface
    ['{EA39D321-7B34-4E6A-8B07-8E13A1437316}']

    function codigo(value: Integer): ICliente; overload;
    function codigo: Integer; overload;

    function nome(value: String): ICliente; overload;
    function nome: String; overload;

    function sexo(value: String): ICliente; overload;
    function sexo: String; overload;

    function dataNascimento(value: String): ICliente; overload;
    function dataNascimento: String; overload;

    function cpf(value: String): ICliente; overload;
    function cpf: String; overload;

    function email(value: String): ICliente; overload;
    function email: String; overload;

    function loja(value: Integer): ICliente; overload;
    function loja: Integer; overload;

    function logradouro(value: String): ICliente; overload;
    function lgoradouro: String; overload;

    function numero(value: String): ICliente; overload;
    function numero: String; overload;

    function complemento(value: String): ICliente; overload;
    function complemento: String; overload;

    function bairro(value: String): ICliente; overload;
    function bairro: String; overload;

    function cidade(value: String): ICliente; overload;
    function cidade: String; overload;

    function siglaEstado(value: String): ICliente; overload;
    function siglaEstado: String; overload;

    function cep(value: String): ICliente; overload;
    function cep: String; overload;

    function pais(value: String): ICliente; overload;
    function pais: String; overload;

    function telefone1(value: String): ICliente; overload;
    function telefone1: String; overload;

    function telefone2(value: String): ICliente; overload;
    function telefone2: String; overload;

    function telefone3(value: String): ICliente; overload;
    function telefone3: String; overload;

    function sincronizado(value: TDateTime): ICliente; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tcliente>;
  end;

implementation

end.
