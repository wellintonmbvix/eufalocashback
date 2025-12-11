unit model.produtos;

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
  [Table('produtos', '')]
  [PrimaryKey('codigo', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('produto')]
  Tproduto = class
  private
    Fproduto: String;
    Fean: nullable<String>;
    Fdescricao: nullable<String>;
    Fpreco: Currency;
    FprecoPromocao: Currency;
    Fativo: Boolean;
    FcodFabricante: nullable<String>;
    FcodCategoria: Integer;
    Funidade: String;
    Fsincronizado: nullable<TDateTime>;
    Festoque: Currency;
    FnomeProduto: nullable<String>;
    FunidadeValor: Currency;
  public
    constructor Create;
    destructor Destroy; override;

    [Column('produto', ftString, 20)]
    [Dictionary('codigo', 'Mensagem de validação', '', '', '', taCenter)]
    property produto: String read Fproduto write Fproduto;

    [Column('ean', ftString, 14)]
    [Dictionary('ean', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property ean: nullable<String> read Fean write Fean;

    [Column('nomeProduto', ftString, 60)]
    [Dictionary('nomeProduto', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property nomeProduto: nullable<String> read FnomeProduto write FnomeProduto;

    [Column('descricao', ftString, 60)]
    [Dictionary('descricao', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property descricao: nullable<String> read Fdescricao write Fdescricao;

    [Column('preco', ftBCD)]
    [Dictionary('preco', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property preco: Currency read Fpreco write Fpreco;

    [Column('precoPromocao', ftBCD)]
    [Dictionary('precoPromocao', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property precoPromocao: Currency read FprecoPromocao write FprecoPromocao;

    [Column('estoque', ftBCD)]
    [Dictionary('estoque', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property estoque: Currency read Festoque write Festoque;

    [Column('ativo', ftBoolean)]
    [Dictionary('ativo', 'Mensagem de validação', '0', '', '', taCenter)]
    property ativo: Boolean read Fativo write Fativo;

    [Column('codFabricante', ftString, 20)]
    [Dictionary('codFabricante', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property codFabricante: nullable<String> read FcodFabricante write FcodFabricante;

    [Column('codCategoria', ftInteger)]
    [Dictionary('codCategoria', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property codCategoria: Integer read FcodCategoria write FcodCategoria;

    [Column('unidade', ftString, 8)]
    [Dictionary('unidade', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property unidade: String read Funidade write Funidade;

    [Colum('unidadeValor', ftBCD)]
    [Dictionary('unidadeValor', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property unidadeValor: Currency read FunidadeValor write FunidadeValor;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado write Fsincronizado;
  end;

implementation

{ Tproduto }

constructor Tproduto.Create;
begin
  //
end;

destructor Tproduto.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tproduto)

end.
