unit model.vendas;

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
  [Table('vendas', '')]
  [PrimaryKey('dataVenda;cupom;cliente;cpf', TAutoIncType.NotInc,
                                             TGeneratorType.NoneInc,
                                             TSortingOrder.NoSort,
                                             True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('dataVenda;cupom;cliente;cpf')]
  Tvendas = class
  private
    FdataVenda: TDateTime;
    Fcupom: Integer;
    Fcliente: Integer;
    Fcpf: String;
    Fvalor: Double;
    Fdesconto: Double;
    Fcomissao: Double;
    FformaPagto: nullable<String>;
    Floja: Integer;
    Ffrete: Double;
    Fvendedor: Integer;
    Fsincronizado: nullable<TDateTime>;
  public
    constructor Create;
    destructor Destroy; override;

    [Column('dataVenda', ftDateTime)]
    [Dictionary('dataVenda', 'Mensagem de validação', '', '', '', taLeftJustify)]
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

    [Column('valor', ftBCD)]
    [Dictionary('valor', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property valor: Double read Fvalor write Fvalor;

    [Column('desconto', ftBCD)]
    [Dictionary('desconto', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property desconto: Double read Fdesconto write Fdesconto;

    [Column('comissao', ftBCD)]
    [Dictionary('comissao', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property comissao: Double read Fcomissao write Fcomissao;

    [Column('formaPagto', ftString, 50)]
    [Dictionary('formaPagto', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property formaPagto: nullable<String> read FformaPagto write FformaPagto;

    [Column('loja', ftInteger)]
    [Dictionary('loja', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property loja: Integer read Floja write Floja;

    [Column('frete', ftBCD)]
    [Dictionary('frete', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property frete: Double read Ffrete write Ffrete;

    [Column('vendedor', ftInteger)]
    [Dictionary('vendedor', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property vendedor: Integer read Fvendedor write Fvendedor;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado write Fsincronizado;
  end;

implementation

{ Tvendas }

constructor Tvendas.Create;
begin
  //
end;

destructor Tvendas.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tvendas)

end.
