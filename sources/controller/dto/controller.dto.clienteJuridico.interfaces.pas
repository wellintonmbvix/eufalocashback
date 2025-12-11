unit controller.dto.clienteJuridico.interfaces;

interface

uses
  model.clienteJuridico,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IClienteJuridico = interface
    ['{E739E4E1-2FB3-4444-82E7-8C711866EEAA}']

    function codigo(value: Integer): IClienteJuridico; overload;
    function codigo: Integer; overload;

    function razao(value: String): IClienteJuridico; overload;
    function razao: String; overload;

    function fantasia(value: String): IClienteJuridico; overload;
    function fantasia: String; overload;

    function cnpj(value: String): IClienteJuridico; overload;
    function cnpj: String; overload;

    function loja(value: Integer): IClienteJuridico; overload;
    function loja: Integer; overload;

    function site(value: String): IClienteJuridico; overload;
    function site: String; overload;

    function facebook(value: String): IClienteJuridico; overload;
    function facebook: String; overload;

    function instagram(value: String): IClienteJuridico; overload;
    function instagram: String; overload;

    function logradouro(value: String): IClienteJuridico; overload;
    function logradouro: String; overload;

    function numero(value: String): IClienteJuridico; overload;
    function numero: String; overload;

    function complemento(value: String): IClienteJuridico; overload;
    function complemento: String; overload;

    function bairro(value: String): IClienteJuridico; overload;
    function bairro: String; overload;

    function cidade(value: String): IClienteJuridico; overload;
    function cidade: String; overload;

    function estado(value: String): IClienteJuridico; overload;
    function estado: String; overload;

    function cep(value: String): IClienteJuridico; overload;
    function  cep: String; overload;

    function pais(value: String): IClienteJuridico; overload;
    function pais: String; overload;

    function cpfResponsavel(value: String): IClienteJuridico; overload;
    function cpfResponsavel: String; overload;

    function email(value: String): IClienteJuridico; overload;
    function email: String; overload;

    function sincronizado(value: TDateTime): IClienteJuridico; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<TclienteJuridico>;
  end;

implementation

end.
