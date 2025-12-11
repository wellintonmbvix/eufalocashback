unit controller.dto.venda.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.vendas,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.venda.interfaces;

type
  TIVenda = class(TInterfacedObject, IVenda)
  private
    FEntity: Tvendas;
    FService: IService<Tvendas>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IVenda;

    function dataVenda(value: TDateTime): IVenda; overload;
    function dataVenda: TDateTime; overload;

    function cupom(value: Integer): IVenda; overload;
    function cupom: Integer; overload;

    function cliente(value: Integer): IVenda; overload;
    function cliente: Integer; overload;

    function cpf(value: String): IVenda; overload;
    function cpf: String; overload;

    function valor(value: Double): IVenda; overload;
    function valor: Double; overload;

    function desconto(value: Double): IVenda; overload;
    function desconto: Double; overload;

    function comissao(value: Double): IVenda; overload;
    function comissao: Double; overload;

    function formaPagto(value: String): IVenda; overload;
    function formaPagto: String; overload;

    function loja(value: Integer): IVenda; overload;
    function loja: Integer; overload;

    function frete(value: Double): IVenda; overload;
    function frete: Double; overload;

    function vendedor(value: Integer): IVenda; overload;
    function vendedor: Integer; overload;

    function sincronizado(value: TDateTime): IVenda; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tvendas>;
  end;

implementation

{ TIVenda }

function TIVenda.Build: IService<Tvendas>;
begin
  Result := FService;
end;

function TIVenda.cliente: Integer;
begin
  Result := FEntity.cliente;
end;

function TIVenda.cliente(value: Integer): IVenda;
begin
  Result := Self;
  FEntity.cliente := value;
end;

function TIVenda.comissao: Double;
begin
  Result := FEntity.comissao;
end;

function TIVenda.comissao(value: Double): IVenda;
begin
  Result := Self;
  FEntity.comissao := value;
end;

function TIVenda.cpf: String;
begin
  Result := FEntity.cpf;
end;

function TIVenda.cpf(value: String): IVenda;
begin
  Result := Self;
  FEntity.cpf := value;
end;

constructor TIVenda.Create;
begin
  FEntity := Tvendas.Create;
  FService := TServiceORMBr<Tvendas>.New(FEntity);
end;

function TIVenda.cupom(value: Integer): IVenda;
begin
  Result := Self;
  FEntity.cupom := value;
end;

function TIVenda.cupom: Integer;
begin
  Result := FEntity.cupom;
end;

function TIVenda.dataVenda: TDateTime;
begin
  Result := FEntity.dataVenda;
end;

function TIVenda.dataVenda(value: TDateTime): IVenda;
begin
  Result := Self;
  FEntity.dataVenda := value;
end;

function TIVenda.desconto: Double;
begin
  Result := FEntity.desconto;
end;

function TIVenda.desconto(value: Double): IVenda;
begin
  Result := Self;
  FEntity.desconto := value;
end;

destructor TIVenda.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIVenda.formaPagto: String;
begin
  Result := FEntity.formaPagto;
end;

function TIVenda.formaPagto(value: String): IVenda;
begin
  Result := Self;
  FEntity.formaPagto := value;
end;

function TIVenda.frete: Double;
begin
  Result := FEntity.frete;
end;

function TIVenda.frete(value: Double): IVenda;
begin
  Result := Self;
  FEntity.frete := value;
end;

function TIVenda.loja: Integer;
begin
  Result := FEntity.loja;
end;

function TIVenda.loja(value: Integer): IVenda;
begin
  Result := Self;
  FEntity.loja := value;
end;

class function TIVenda.New: IVenda;
begin
  Result := Self.Create;
end;

function TIVenda.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

function TIVenda.sincronizado(value: TDateTime): IVenda;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

function TIVenda.valor(value: Double): IVenda;
begin
  Result := Self;
  FEntity.valor := value;
end;

function TIVenda.valor: Double;
begin
  Result := FEntity.valor;
end;

function TIVenda.vendedor(value: Integer): IVenda;
begin
  Result := Self;
  FEntity.vendedor := value;
end;

function TIVenda.vendedor: Integer;
begin
  Result := FEntity.vendedor;
end;

end.
