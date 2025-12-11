unit controller.dto.cliente.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.cliente,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.cliente.interfaces;

type
  TICliente = class(TInterfacedObject, ICliente)
  private
    FEntity: Tcliente;
    FService: IService<Tcliente>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: ICliente;

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

{ TICliente }

function TICliente.bairro(value: String): ICliente;
begin
  Result := Self;
  FEntity.bairro := value;
end;

function TICliente.bairro: String;
begin
  Result := FEntity.bairro;
end;

function TICliente.Build: IService<Tcliente>;
begin
  Result := FService
end;

function TICliente.cep(value: String): ICliente;
begin
  Result := Self;
  FEntity.cep := value;
end;

function TICliente.cep: String;
begin
  Result := FEntity.cep;
end;

function TICliente.cidade(value: String): ICliente;
begin
  Result := Self;
  FEntity.cidade := value;
end;

function TICliente.cidade: String;
begin
  Result := FEntity.cidade;
end;

function TICliente.codigo: Integer;
begin
  Result := FEntity.codigo;
end;

function TICliente.codigo(value: Integer): ICliente;
begin
  Result := Self;
  FEntity.codigo := value;
end;

function TICliente.complemento: String;
begin
  Result := FEntity.complemento;
end;

function TICliente.complemento(value: String): ICliente;
begin
  Result := Self;
  FEntity.complemento := value;
end;

function TICliente.cpf(value: String): ICliente;
begin
  Result := Self;
  FEntity.cpf := value;
end;

function TICliente.cpf: String;
begin
  Result := FEntity.cpf;
end;

constructor TICliente.Create;
begin
  FEntity := Tcliente.Create;
  FService := TServiceORMBr<Tcliente>.New(FEntity);
end;

function TICliente.dataNascimento(value: String): ICliente;
begin
  Result := Self;
  FEntity.dataNascimento := value;
end;

function TICliente.dataNascimento: String;
begin
  Result := FEntity.dataNascimento;
end;

destructor TICliente.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TICliente.email(value: String): ICliente;
begin
  Result := Self;
  FEntity.email := value;
end;

function TICliente.email: String;
begin
  Result := FEntity.email;
end;

function TICliente.lgoradouro: String;
begin
  Result := FEntity.logradouro;
end;

function TICliente.logradouro(value: String): ICliente;
begin
  Result := Self;
  FEntity.logradouro := value;
end;

function TICliente.loja(value: Integer): ICliente;
begin
  Result := Self;
  FEntity.loja := value;
end;

function TICliente.loja: Integer;
begin
  Result := FEntity.loja;
end;

class function TICliente.New: ICliente;
begin
  Result := Self.Create;
end;

function TICliente.nome: String;
begin
  Result := FEntity.nome;
end;

function TICliente.nome(value: String): ICliente;
begin
  Result := Self;
  FEntity.nome := value;
end;

function TICliente.numero(value: String): ICliente;
begin
  Result := Self;
  FEntity.numero := value;
end;

function TICliente.numero: String;
begin
  Result := FEntity.numero;
end;

function TICliente.pais(value: String): ICliente;
begin
  Result := Self;
  FEntity.pais := value;
end;

function TICliente.pais: String;
begin
  Result := FEntity.pais;
end;

function TICliente.sexo: String;
begin
  Result := FEntity.sexo;
end;

function TICliente.sexo(value: String): ICliente;
begin
  Result := Self;
  FEntity.sexo := value;
end;

function TICliente.siglaEstado(value: String): ICliente;
begin
  Result := Self;
  FEntity.siglaEstado := value;
end;

function TICliente.siglaEstado: String;
begin
  Result := FEntity.siglaEstado;
end;

function TICliente.sincronizado(value: TDateTime): ICliente;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

function TICliente.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

function TICliente.telefone1: String;
begin
  Result := FEntity.telefone1;
end;

function TICliente.telefone1(value: String): ICliente;
begin
  Result := Self;
  FEntity.telefone1 := value;
end;

function TICliente.telefone2(value: String): ICliente;
begin
  Result := Self;
  FEntity.telefone2 := value;
end;

function TICliente.telefone2: String;
begin
  Result := FEntity.telefone2;
end;

function TICliente.telefone3: String;
begin
  Result := FEntity.telefone3;
end;

function TICliente.telefone3(value: String): ICliente;
begin
  Result := Self;
  FEntity.telefone3 := value;
end;

end.
