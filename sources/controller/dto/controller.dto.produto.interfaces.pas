unit controller.dto.produto.interfaces;

interface

uses
  model.produtos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IProduto = interface
    ['{200A9469-92F9-4F98-8F32-2158967B683B}']

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

end.
