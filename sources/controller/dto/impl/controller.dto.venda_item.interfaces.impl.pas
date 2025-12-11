unit controller.dto.venda_item.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.vendas_itens,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.venda_item.interfaces;

type
  TIVendaItem = class(TInterfacedObject, IVendaItem)
  private
    FEntity: Tvenda_item;
    FService: IService<Tvenda_item>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IVendaItem;

    function dataVenda(value: TDateTime): IVendaItem; overload;
    function dataVenda: TDateTime; overload;

    function cupom(value: Integer): IVendaItem; overload;
    function cupom: Integer; overload;

    function cliente(value: Integer): IVendaItem; overload;
    function cliente: Integer; overload;

    function cpf(value: String): IVendaItem; overload;
    function cpf: String; overload;

    function item(value: Integer): IVendaItem; overload;
    function item: Integer; overload;

    function produto(value: String): IVendaItem; overload;
    function produto: String; overload;

    function qtde(value: Double): IVendaItem; overload;
    function qtde: Double; overload;

    function valorLiquido(value: Double): IVendaItem; overload;
    function valorLiquido: Double; overload;

    function desconto(value: Double): IVendaItem; overload;
    function desconto: Double; overload;

    function comissao(value: Double): IVendaItem; overload;
    function comissao: Double; overload;

    function Build: IService<Tvenda_item>;
  end;

implementation

{ TIVendaItem }

function TIVendaItem.Build: IService<Tvenda_item>;
begin
  Result := FService;
end;

function TIVendaItem.cliente: Integer;
begin
  Result := FEntity.cliente;
end;

function TIVendaItem.cliente(value: Integer): IVendaItem;
begin
  Result := Self;
  FEntity.cliente := value;
end;

function TIVendaItem.comissao: Double;
begin
  Result := FEntity.comissao;
end;

function TIVendaItem.comissao(value: Double): IVendaItem;
begin
  Result := Self;
  FEntity.comissao := value;
end;

function TIVendaItem.cpf: String;
begin
  Result := FEntity.cpf;
end;

function TIVendaItem.cpf(value: String): IVendaItem;
begin
  Result := Self;
  FEntity.cpf := value;
end;

constructor TIVendaItem.Create;
begin
  FEntity := Tvenda_item.Create;
  FService := TServiceORMBr<Tvenda_item>.New(FEntity);
end;

function TIVendaItem.cupom(value: Integer): IVendaItem;
begin
  Result := Self;
  FEntity.cupom := value;
end;

function TIVendaItem.cupom: Integer;
begin
  Result := FEntity.cupom;
end;

function TIVendaItem.dataVenda(value: TDateTime): IVendaItem;
begin
  Result := Self;
  FEntity.dataVenda := value;
end;

function TIVendaItem.dataVenda: TDateTime;
begin
  Result := FEntity.dataVenda;
end;

function TIVendaItem.desconto: Double;
begin
  Result := FEntity.desconto;
end;

function TIVendaItem.desconto(value: Double): IVendaItem;
begin
  Result := Self;
  FEntity.desconto := value;
end;

destructor TIVendaItem.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIVendaItem.item(value: Integer): IVendaItem;
begin
  Result := Self;
  FEntity.item := value;
end;

function TIVendaItem.item: Integer;
begin
  Result := FEntity.item;
end;

class function TIVendaItem.New: IVendaItem;
begin
  Result := Self.Create;
end;

function TIVendaItem.produto: String;
begin
  Result := FEntity.produto;
end;

function TIVendaItem.produto(value: String): IVendaItem;
begin
  Result := Self;
  FEntity.produto := value;
end;

function TIVendaItem.qtde(value: Double): IVendaItem;
begin
  Result := Self;
  FEntity.qtde := value;
end;

function TIVendaItem.qtde: Double;
begin
  Result := FEntity.qtde;
end;

function TIVendaItem.valorLiquido(value: Double): IVendaItem;
begin
  Result := Self;
  FEntity.valorLiquido := value;
end;

function TIVendaItem.valorLiquido: Double;
begin
  Result := FEntity.valorLiquido;
end;

end.
