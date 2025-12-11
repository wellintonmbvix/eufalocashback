unit model.vendas_itens;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,

  // ormbr
  ormbr.types.blob,
  ormbr.types.lazy,
  ormbr.objects.helper,
  dbcbr.types.mapping,
  ormbr.types.nullable,
  dbcbr.mapping.Classes,
  dbcbr.mapping.register,
  dbcbr.mapping.attributes;

type

  [Entity]
  [Table('vendas_itens', '')]
  [PrimaryKey('dataVenda;cupom;cliente;cpf;item', TAutoIncType.NotInc,
                                                  TGeneratorType.NoneInc,
                                                  TSortingOrder.NoSort,
                                                  True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('dataVenda;cupom;cliente;cpf;item')]
  Tvenda_item = class
  private
    FdataVenda: TDateTime;
    Fcupom: Integer;
    Fcliente: Integer;
    Fcpf: String;
    Fitem: Integer;
    Fproduto: String;
    Fqtde: Double;
    FvalorLiquido: Double;
    Fdesconto: Double;
    Fcomissao: Double;
  public
    constructor Create;
    destructor Destroy; override;

    [Column('dataVenda', ftDateTime)]
    [Dictionary('dataVenda', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property dataVenda: TDateTime read FdataVenda write FdataVenda;

    [Column('cupom', ftInteger)]
    [Dictionary('cupom', 'Mensagem de validação', '', '', '', taRightJustify)]
    property cupom: Integer read Fcupom write Fcupom;

    [Column('cliente', ftInteger)]
    [Dictionary('cliente', 'Mensagem de validação', '', '', '', taRightJustify)]
    property cliente: Integer read Fcliente write Fcliente;

    [Column('cpf', ftString, 14)]
    [Dictionary('cpf', 'Mensagem de validação', '', '', '', taRightJustify)]
    property cpf: String read Fcpf write Fcpf;

    [Column('item', ftInteger)]
    [Dictionary('item', 'Mensagem de validação', '', '', '', taCenter)]
    property item: Integer read Fitem write Fitem;

    [Column('produto', ftString, 20)]
    [Dictionary('produto', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property produto: String read Fproduto write Fproduto;

    [Column('qtde', ftBCD)]
    [Dictionary('qtde', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property qtde: Double read Fqtde write Fqtde;

    [Column('valorLiquido', ftBCD)]
    [Dictionary('valorLiquido', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property valorLiquido: Double read FvalorLiquido write FvalorLiquido;

    [Column('desconto', ftBCD)]
    [Dictionary('desconto', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property desconto: Double read Fdesconto write Fdesconto;

    [Column('comissao', ftBCD)]
    [Dictionary('comissao', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property comissao: Double read Fcomissao write Fcomissao;
  end;

implementation

{ Tvendas_itens }

constructor Tvenda_item.Create;
begin
  //
end;

destructor Tvenda_item.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tvenda_item)

end.
