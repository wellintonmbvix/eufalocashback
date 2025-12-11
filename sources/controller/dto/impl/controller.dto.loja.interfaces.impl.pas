unit controller.dto.loja.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.loja,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.loja.interfaces;

type
  TILoja = class(TInterfacedObject, ILoja)
  private
    FEntity: Tloja;
    FService: IService<Tloja>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: ILoja;

    function codigo(value: Integer): ILoja; overload;
    function codigo: Integer; overload;

    function razao(value: String): ILoja; overload;
    function razao: String; overload;

    function fantasia(value: String): ILoja; overload;
    function fantasia: String; overload;

    function cnpj(value: String): ILoja; overload;
    function cnpj: String; overload;

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

{ TILoja }

function TILoja.bairro: String;
begin
  Result := FEntity.bairro;
end;

function TILoja.bairro(value: String): ILoja;
begin
  Result := Self;
  FEntity.bairro := value;
end;

function TILoja.Build: IService<Tloja>;
begin
  Result := FService;
end;

function TILoja.cep: String;
begin
  Result := FEntity.cep;
end;

function TILoja.cep(value: String): ILoja;
begin
  Result := Self;
  FEntity.cep := value;
end;

function TILoja.cidade(value: String): ILoja;
begin
  Result := Self;
  FEntity.cidade := value;
end;

function TILoja.cidade: String;
begin
  Result := FEntity.cidade;
end;

function TILoja.cnpj(value: String): ILoja;
begin
  Result := Self;
  FEntity.cnpj := value;
end;

function TILoja.cnpj: String;
begin
  Result := FEntity.cnpj;
end;

function TILoja.codigo: Integer;
begin
  Result := FEntity.codigo;
end;

function TILoja.codigo(value: Integer): ILoja;
begin
  Result := Self;
  FEntity.codigo := value;
end;

function TILoja.complemento(value: String): ILoja;
begin
  Result := Self;
  FEntity.complemento := value;
end;

function TILoja.complemento: String;
begin
  Result := FEntity.complemento;
end;

constructor TILoja.Create;
begin
  FEntity := Tloja.Create;
  FService := TServiceORMBr<Tloja>.New(FEntity);
end;

function TILoja.dddCel(value: String): ILoja;
begin
  Result := Self;
  FEntity.dddCel := value;
end;

function TILoja.dddCel: String;
begin
  Result := FEntity.dddCel;
end;

function TILoja.dddFixo(value: String): ILoja;
begin
  Result := Self;
  FEntity.dddFixo := value;
end;

function TILoja.dddFixo: String;
begin
  Result := FEntity.dddFixo;
end;

destructor TILoja.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TILoja.estado(value: String): ILoja;
begin
  Result := Self;
  FEntity.estado := value;
end;

function TILoja.estado: String;
begin
  Result := FEntity.estado;
end;

function TILoja.fantasia(value: String): ILoja;
begin
  Result := Self;
  FEntity.fantasia := value;
end;

function TILoja.fantasia: String;
begin
  Result := FEntity.fantasia;
end;

function TILoja.foneCel(value: String): ILoja;
begin
  Result := Self;
  FEntity.foneCel := value;
end;

function TILoja.foneCel: String;
begin
  Result := FEntity.foneCel;
end;

function TILoja.foneFixo(value: String): ILoja;
begin
  Result := Self;
  FEntity.foneFixo := value;
end;

function TILoja.foneFixo: String;
begin
  Result := FEntity.fonefixo;
end;

function TILoja.logradouro: String;
begin
  Result := FEntity.logradouro;
end;

function TILoja.logradouro(value: String): ILoja;
begin
  Result := Self;
  FEntity.logradouro := value;
end;

class function TILoja.New: ILoja;
begin
  Result := Self.Create;
end;

function TILoja.numero(value: String): ILoja;
begin
  Result := Self;
  FEntity.numero := value;
end;

function TILoja.numero: String;
begin
  Result := FEntity.numero;
end;

function TILoja.razao(value: String): ILoja;
begin
  Result := Self;
  FEntity.razao := value;
end;

function TILoja.razao: String;
begin
  Result := FEntity.razao;
end;

function TILoja.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

function TILoja.sincronizado(value: TDateTime): ILoja;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

end.
