unit controller.dto.produto.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.produtos,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.produto.interfaces;

type
  TIProduto = class(TInterfacedObject, IProduto)
  private
    FEntity: Tproduto;
    FService: IService<Tproduto>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IProduto;

    function produto(value: String): IProduto; overload;
    function produto: String; overload;

    function ean(value: String): IProduto; overload;
    function ean: String; overload;

    function nomeProduto(value: String): IProduto; overload;
    function nomeProduto: String; overload;

    function descricao(value: String): IProduto; overload;
    function descricao: String; overload;

    function preco(value: Currency): IProduto; overload;
    function preco: Currency; overload;

    function precoPromocao(value: Currency): IProduto; overload;
    function precoPromocao: Currency; overload;

    function estoque(value: Currency): IProduto; overload;
    function estoque: Currency; overload;

    function ativo(value: Boolean): IProduto; overload;
    function ativo: Boolean; overload;

    function codFabricante(value: String): IProduto; overload;
    function codFabricante: String; overload;

    function codCategoria(value: Integer): IProduto; overload;
    function codCategoria: Integer; overload;

    function unidade(value: String): IProduto; overload;
    function unidade: String; overload;

    function unidadeValor(value: Currency): IProduto; overload;
    function unidadeValor: Currency; overload;

    function sincronizado(value: TDateTime): IProduto; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tproduto>;
  end;

implementation

{ TIProduto }

function TIProduto.ativo: Boolean;
begin
  Result := FEntity.ativo;
end;

function TIProduto.ativo(value: Boolean): IProduto;
begin
  Result := Self;
  FEntity.ativo := value;
end;

function TIProduto.Build: IService<Tproduto>;
begin
  Result := FService;
end;

function TIProduto.codCategoria: Integer;
begin
  Result := FEntity.codCategoria;
end;

function TIProduto.codCategoria(value: Integer): IProduto;
begin
  Result := Self;
  FEntity.codCategoria := value;
end;

function TIProduto.codFabricante(value: String): IProduto;
begin
  Result := Self;
  FEntity.codFabricante := value;
end;

function TIProduto.codFabricante: String;
begin
  Result := FEntity.codFabricante;
end;

constructor TIProduto.Create;
begin
  FEntity := Tproduto.Create;
  FService := TServiceORMBr<Tproduto>.New(FEntity);
end;

function TIProduto.descricao: String;
begin
  Result := FEntity.descricao;
end;

destructor TIProduto.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIProduto.descricao(value: String): IProduto;
begin
  Result := Self;
  FEntity.descricao := value;
end;

function TIProduto.ean(value: String): IProduto;
begin
  Result := Self;
  FEntity.ean := value;
end;

function TIProduto.ean: String;
begin
  Result := FEntity.ean;
end;

function TIProduto.estoque: Currency;
begin
  Result := FEntity.estoque;
end;

function TIProduto.estoque(value: Currency): IProduto;
begin
  Result := Self;
  FEntity.estoque := value;
end;

class function TIProduto.New: IProduto;
begin
  Result := Self.Create
end;

function TIProduto.nomeProduto: String;
begin
  Result := FEntity.nomeProduto;
end;

function TIProduto.nomeProduto(value: String): IProduto;
begin
  Result := Self;
  FEntity.nomeProduto := value;
end;

function TIProduto.preco(value: Currency): IProduto;
begin
  Result := Self;
  FEntity.preco := value;
end;

function TIProduto.preco: Currency;
begin
  Result := FEntity.preco;
end;

function TIProduto.precoPromocao: Currency;
begin
  Result := FEntity.precoPromocao;
end;

function TIProduto.precoPromocao(value: Currency): IProduto;
begin
  Result := Self;
  FEntity.precoPromocao := value;
end;

function TIProduto.produto(value: String): IProduto;
begin
  Result := Self;
  FEntity.produto := value;
end;

function TIProduto.produto: String;
begin
  Result := FEntity.produto;
end;

function TIProduto.sincronizado(value: TDateTime): IProduto;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

function TIProduto.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

function TIProduto.unidade: String;
begin
  Result := FEntity.unidade;
end;

function TIProduto.unidadeValor: Currency;
begin
  Result := FEntity.unidadeValor;
end;

function TIProduto.unidadeValor(value: Currency): IProduto;
begin
  Result := Self;
  FEntity.unidadeValor := value;
end;

function TIProduto.unidade(value: String): IProduto;
begin
  Result := Self;
  FEntity.unidade := value;
end;

end.
