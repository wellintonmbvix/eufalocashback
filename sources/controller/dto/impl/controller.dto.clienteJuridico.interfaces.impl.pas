unit controller.dto.clienteJuridico.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.clienteJuridico,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.clienteJuridico.interfaces;

type
  TIClienteJuridico = class(TInterfacedObject, IClienteJuridico)
    private
      FEntity: TclienteJuridico;
      FService: IService<TclienteJuridico>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IClienteJuridico;

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
    function cep: String; overload;

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

{ TIClienteJuridico }

function TIClienteJuridico.bairro(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.bairro := value;
end;

function TIClienteJuridico.bairro: String;
begin
  Result := FEntity.bairro;
end;

function TIClienteJuridico.Build: IService<TclienteJuridico>;
begin
  Result := FService;
end;

function TIClienteJuridico.cep: String;
begin
  Result := FEntity.cep;
end;

function TIClienteJuridico.cep(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.cep := value;
end;

function TIClienteJuridico.cidade: String;
begin
  Result := FEntity.cidade;
end;

function TIClienteJuridico.cidade(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.cidade := value;
end;

function TIClienteJuridico.cnpj: String;
begin
  Result := FEntity.cnpj;
end;

function TIClienteJuridico.cnpj(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.cnpj := value;
end;

function TIClienteJuridico.codigo: Integer;
begin
  Result := FEntity.codigo;
end;

function TIClienteJuridico.codigo(value: Integer): IClienteJuridico;
begin
  Result := Self;
  FEntity.codigo := value;
end;

function TIClienteJuridico.complemento: String;
begin
  Result := FEntity.complemento;
end;

function TIClienteJuridico.complemento(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.complemento := value;
end;

function TIClienteJuridico.cpfResponsavel: String;
begin
  Result := FEntity.cpfResponsavel;
end;

function TIClienteJuridico.cpfResponsavel(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.cpfResponsavel := value;
end;

constructor TIClienteJuridico.Create;
begin
  FEntity := TclienteJuridico.Create;
  FService := TServiceORMBr<TclienteJuridico>.New(FEntity);
end;

destructor TIClienteJuridico.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIClienteJuridico.estado(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.estado := value;
end;

function TIClienteJuridico.email: String;
begin
  Result := FEntity.email;
end;

function TIClienteJuridico.email(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.email := value;
end;

function TIClienteJuridico.estado: String;
begin
  Result := FEntity.estado;
end;

function TIClienteJuridico.facebook: String;
begin
  Result := FEntity.facebook;
end;

function TIClienteJuridico.facebook(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.facebook := value;
end;

function TIClienteJuridico.fantasia(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.fantasia := value;
end;

function TIClienteJuridico.fantasia: String;
begin
  Result := FEntity.fantasia;
end;

function TIClienteJuridico.instagram(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.instagram := value;
end;

function TIClienteJuridico.instagram: String;
begin
  Result := FEntity.instagram;
end;

function TIClienteJuridico.logradouro: String;
begin
  Result := FEntity.logradouro;
end;

function TIClienteJuridico.logradouro(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.logradouro := value;
end;

function TIClienteJuridico.loja(value: Integer): IClienteJuridico;
begin
  Result := Self;
  FEntity.loja := value;
end;

function TIClienteJuridico.loja: Integer;
begin
  Result := FEntity.loja;
end;

class function TIClienteJuridico.New: IClienteJuridico;
begin
  Result := Self.Create;
end;

function TIClienteJuridico.numero: String;
begin
  Result := FEntity.numero;
end;

function TIClienteJuridico.numero(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.numero := value;
end;

function TIClienteJuridico.pais(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.pais := value;
end;

function TIClienteJuridico.pais: String;
begin
  Result := FEntity.pais;
end;

function TIClienteJuridico.razao: String;
begin
  Result := FEntity.razao;
end;

function TIClienteJuridico.razao(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.razao := value;
end;

function TIClienteJuridico.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

function TIClienteJuridico.sincronizado(value: TDateTime): IClienteJuridico;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

function TIClienteJuridico.site: String;
begin
  Result := FEntity.site;
end;

function TIClienteJuridico.site(value: String): IClienteJuridico;
begin
  Result := Self;
  FEntity.site := value;
end;

end.
