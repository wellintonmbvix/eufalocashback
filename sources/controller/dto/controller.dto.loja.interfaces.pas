unit controller.dto.loja.interfaces;

interface

uses
  model.loja,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  ILoja = interface
    ['{1D543BFF-3B81-4D98-BC26-DC63B83406B9}']

    function codigo(value: Integer): ILoja; overload;
    function codigo: Integer; overload;

    function razao(value: String): ILoja; overload;
    function razao: String; overload;

    function fantasia(value: String): ILoja; overload;
    function fantasia: String; overload;

    function cnpj(value: String): ILoja; overload;
    function cnpj: String ; overload;

    function logradouro(value: String): ILoja; overload;
    function logradouro: String; overload;

    function numero(value: String): ILoja; overload;
    function numero: String; overload;

    function complemento(value: String): ILoja; overload;
    function complemento: String; overload;

    function bairro(value: String): ILoja; overload;
    function bairro: String; overload;

    function cidade(value: String): ILoja; overload;
    function cidade: String; overload;

    function estado(value: String): ILoja; overload;
    function estado: String; overload;

    function cep(value: String): ILoja; overload;
    function cep: String; overload;

    function dddFixo(value: String): ILoja; overload;
    function dddFixo: String; overload;

    function foneFixo(value: String): ILoja; overload;
    function foneFixo: String; overload;

    function dddCel(value: String): ILoja; overload;
    function dddCel: String; overload;

    function foneCel(value: String): ILoja; overload;
    function foneCel: String; overload;

    function sincronizado(value: TDateTime): ILoja; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tloja>;
  end;

implementation

end.
