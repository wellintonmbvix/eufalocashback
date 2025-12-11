unit controller.dto.venda.interfaces;

interface

uses
  model.vendas,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IVenda = interface
    ['{B4750912-DDC9-4A84-81F9-91CB4F43DF82}']

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

end.
