unit controller.dto.venda_item.interfaces;

interface

uses
  model.vendas_itens,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IVendaItem = interface
    ['{0285131F-BB9D-4600-A8F3-223356EC4888}']

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

end.
