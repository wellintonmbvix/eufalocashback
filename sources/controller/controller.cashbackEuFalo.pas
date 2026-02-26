unit controller.cashbackEuFalo;

interface

uses
  System.JSON,
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.DateUtils,
  System.UITypes,
  System.Generics.Collections,
  System.IOUtils,

  routines,

  model.tokens,
  model.loja,
  model.cliente,
  model.clienteJuridico,
  model.vendedor,
  model.categoria,
  model.produtos,

  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.Imaging.pngimage,
  Vcl.Buttons,

  Winapi.Windows,

  IdHTTP,
  REST.JSON,
  REST.Client,
  REST.Types;

const
  _URLv2 = 'https://api.eufalo.com/api/v2';
  _URL = 'https://api.eufalo.com';

type
  TMessageType = (mtInformation, mtWarning, mtError);

  TControllerEuFalo = class
  public
    class procedure ShowTemporaryMessageForm(const AMensagem: String;
      const TempoEmSegundos: Integer; const Tipo: TMessageType);
    class procedure PostOnEuFalo;

    class function GetToken(userId, accesskey: String; out msgError: String): String;
    class function CreateOrUpdateCustomer(customerArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function CreateOrUpdateJuridicCustomer(customerObject: TJSONObject; token: String; out msgError: String): Boolean;
    class function CreateOrUpdateSeller(sellerArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function CreateOrUpdateStore(storeArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function CreateOrUpdateProduct(productObject: TJSONArray; token: String; out msgError: String): Boolean;
    class function CreateOrUpdateCategory(categoryArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function CreateOrUpdateManufacture(manufactureArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function CreateOrUpdatePaymentMethod(paymentMethodArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function CreateOrUpdateSales(salesArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function DeleteSales(salesArray: TJSONArray; token: String; out msgError: String): Boolean;
    class function GetCashBackSnapshot(cashBack: TJSONObject; token: String; out retorno: String): Boolean;
    class function RescueCashBackSnapShot(cashBack: TJSONObject; token: String; out retorno: String): Boolean;
    class function GetCashBackList(token: String; out retorno: String): Boolean;
    class function ConfirmReceiptCashback(token: String; out retorno: String): Boolean;
    class function GetCashBackByCpf(body: TJSONObject; token: String; out retorno: String): Boolean;
    class function RescueCashBack(cashBack: TJSONArray; token: String; out retorno: String): Boolean;
    class function CancelUsagedCashback(cashBacks: TJSONArray; token: String; out retorno: String): Boolean;
  end;

type
  TTemporaryMessageForm = class(TForm)
  private
    FTimer: TTimer;
    FBtnClose: TSpeedButton;
    PanelBtnClose: TPanel;
    procedure OnTimerEvent(Sender: TObject);
    procedure OnBtnCloseClickEvent(Sender: TObject);
    procedure OnBtnCloseMouseEnterEvent(Sender: TObject);
    procedure OnBtnCloseMouseLeaverEvent(Sender: TObject);
    procedure LoadIconFromResource(const ResName: string; Image: TImage);
    procedure CreateWnd; override;
  public
    constructor CreateTemporary(const AMensage: String; SecondsTime: Integer;
      Tipo: TMessageType);
  end;

implementation

uses
  model.service.token.interfaces,
  model.service.categoria.interfaces,
  model.service.produto.interfaces,
  model.service.loja.interfaces,
  model.service.cliente.interfaces,
  model.service.vendedor.interfaces,
  model.service.vendas.interfaces,
  model.service.formaPagto.interfaces,
  model.service.cashback.interfaces,
  model.service.fabricante.interfaces,

  model.service.token.interfaces.impl,
  model.service.categoria.interfaces.impl,
  model.service.produto.interfaces.impl,
  model.service.loja.interfaces.impl,
  model.service.cliente.interfaces.impl,
  model.service.vendedor.interfaces.impl,
  model.service.vendas.interfaces.impl,
  model.service.formaPagto.interfaces.impl,
  model.service.cashback.interfaces.impl,
  model.service.fabricante.interfaces.impl,

  controller.dto.token.interfaces,
  controller.dto.loja.interfaces,
  controller.dto.cliente.interfaces,
  controller.dto.clienteJuridico.interfaces,
  controller.dto.vendedor.interfaces,
  controller.dto.categoria.interfaces,
  controller.dto.produto.interfaces,

  controller.dto.token.interfaces.impl,
  controller.dto.loja.interfaces.impl,
  controller.dto.cliente.interfaces.impl,
  controller.dto.clienteJuridico.interfaces.impl,
  controller.dto.vendedor.interfaces.impl,
  controller.dto.categoria.interfaces.impl,
  controller.dto.produto.interfaces.impl;

{ TControllerEuFalo }


class procedure TControllerEuFalo.PostOnEuFalo;
function ConvertToISO8601(const DataBR: string): string;
var
  D: TDateTime;
begin
  D := StrToDate(DataBR);
  Result := FormatDateTime('yyyy"-"mm"-"dd"T00:00:00.000"Z"', D);
end;

var
  arqReq, arqResp: TextFile;
  sLista: TStringList;
  userId, accesskey, linha: String;
  sToken: String;
  // mapas e arrays principais
  mapVendas   : TDictionary<string, TJSONObject>;
  mapItens    : TDictionary<string, TJSONArray>;
  mapPagtos   : TDictionary<string, TJSONArray>;
  aVendedor   : TJSONArray;
  aCategoria  : TJSONArray;
  aProduto    : TJSONArray;
  aCliente    : TJSONArray;
  aFormaPagto : TJSONArray;
  aVenda      : TJSONArray;
  aVendaCanc  : TJSONArray;
  aCashBack   : TJSONArray;
  aLoja       : TJSONArray;
  aFabricante : TJSONArray;

  // variáveis temporárias usadas dentro do loop
  oVendedor        : TJSONObject;
  oCliente         : TJSONObject;
  oClienteJuridico : TJSONObject;
  oEndereco        : TJSONObject;
  aTelefone        : TJSONArray;
  oTelefone        : TJSONObject;
  oCategoria       : TJSONObject;
  oProduto         : TJSONObject;
  oFormaPagto      : TJSONObject;
  oVenda           : TJSONObject;
  aVendaItem       : TJSONArray;
  aVendaPagto      : TJSONArray;
  oVendaItem       : TJSONObject;
  oVendaPagto      : TJSONObject;
  oCashBack        : TJSONObject;
  oLoja            : TJSONObject;
  oFabricante      : TJSONObject;

  msg: String;
  idVenda: string;

  procedure WriteResponse(const code, status, text: string);
  var
    Dir, TempFile, FinalFile: string;
    Content: TStringList;
  begin
    Dir := 'C:\CSSISTEMAS';
    TempFile := Dir + '\resp.tmp';
    FinalFile := Dir + '\resp.001';

    ForceDirectories(Dir);

    Content := TStringList.Create;
    try
      Content.Text := code + '|' + status + '|' + text;
      Content.SaveToFile(TempFile, TEncoding.UTF8);

      // ReplaceFile é atômico no Windows
      ReplaceFile(PChar(FinalFile), PChar(TempFile), nil, 0, 0, 0);
    finally
      Content.Free;
    end;
  end;

begin
  if not FileExists('C:\CSSISTEMAS\req.001') then
  begin
    Application.Terminate;
    Exit;
  end;

  sLista      := nil;
  mapVendas   := nil;
  mapItens    := nil;
  mapPagtos   := nil;
  aVendedor   := nil;
  aCategoria  := nil;
  aProduto    := nil;
  aCliente    := nil;
  aFormaPagto := nil;
  aVenda      := nil;
  aVendaCanc  := nil;
  aCashBack   := nil;
  aLoja       := nil;
  aFabricante := nil;

  try
    sLista    := TStringList.Create;
    mapVendas := TDictionary<string, TJSONObject>.Create;
    mapItens  := TDictionary<string, TJSONArray>.Create;
    mapPagtos := TDictionary<string, TJSONArray>.Create;

    aVendedor   := TJSONArray.Create;
    aCategoria  := TJSONArray.Create;
    aProduto    := TJSONArray.Create;
    aCliente    := TJSONArray.Create;
    aFormaPagto := TJSONArray.Create;
    aVenda      := TJSONArray.Create;
    aVendaCanc  := TJSONArray.Create;
    aCashBack   := TJSONArray.Create;
    aLoja       := TJSONArray.Create;
    aFabricante := TJSONArray.Create;

    sLista.Delimiter := '|';
    sLista.StrictDelimiter := True;

    AssignFile(arqReq, 'C:\CSSISTEMAS\req.001');
    Reset(arqReq);
    try
      while not Eof(arqReq) do
      begin
        ReadLn(arqReq, linha);
        sLista.DelimitedText := linha;

        case sLista[0].ToInteger of
          0: // Credenciais para login
            begin
              userId := sLista[1];
              accesskey := sLista[2];
              sToken := GetToken(userId, accesskey, msg);
              if sToken.Length = 0 then
              begin
                WriteResponse('0', 'Error', 'Falha ao logar usuário, motivo: ' + msg);
                Break;
              end;
            end;

          1: // Cadastro Loja (sem implementação)
            begin
              oloja := TJSONObject.Create;
              try
                oLoja.AddPair('filialCI', sLista[1]);
                oLoja.AddPair('razaoSocial', sLista[2]);
                oLoja.AddPair('nomeFantasia', sLista[3]);
                oLoja.AddPair('cnpj', sLista[4]);
                oLoja.AddPair('logradouro', sLista[5]);
                oLoja.AddPair('numero', sLista[6]);
                oLoja.AddPair('complemento', sLista[7]);
                oLoja.AddPair('bairro', sLista[8]);
                oLoja.AddPair('cidade', sLista[9]);
                oLoja.AddPair('estado', sLista[10]);
                oLoja.AddPair('cep', sLista[11]);
                oLoja.AddPair('ddiTelefone', '');
                oLoja.AddPair('dddTelefone', sLista[12]);
                oLoja.AddPair('numeroTelefone', sLista[13]);
                oLoja.AddPair('ddiWhatsApp', '');
                oLoja.AddPair('dddWhatsApp', sLista[14]);
                oLoja.AddPair('numeroWhatsApp', sLista[15]);
                aLoja.AddElement(oLoja);
              except
                oLoja.Free;
                raise;
              end;
            end;

          2: // Cadastro de Vendedor
            begin
              oVendedor := TJSONObject.Create;
              try
                oVendedor.AddPair('vendedorId', sLista[1].ToInteger);
                oVendedor.AddPair('vendedorCI', sLista[1]);
                oVendedor.AddPair('nomeVendedor', sLista[2]);
                oVendedor.AddPair('ativo', IfThen(sLista[3].ToLower = 'true', '1', '0'));
                aVendedor.AddElement(oVendedor); // posse transferida para aVendedor
              except
                oVendedor.Free;
                raise;
              end;
            end;

          3: // Cadastro Cliente Físico
            begin
              oCliente := TJSONObject.Create;
              try
                // endereco
                oEndereco := TJSONObject.Create;
                try
                  oEndereco.AddPair('enderecoCI', EmptyStr);
                  oEndereco.AddPair('logradouro', sLista[9]);
                  oEndereco.AddPair('numero', sLista[10]);
                  oEndereco.AddPair('complemento', sLista[11]);
                  oEndereco.AddPair('bairro', sLista[12]);
                  oEndereco.AddPair('cidade', sLista[13]);
                  oEndereco.AddPair('siglaEstado', sLista[14]);
                  oEndereco.AddPair('cep', sLista[15]);
                  oEndereco.AddPair('pais', sLista[16]);

                  oCliente.AddPair('endereco', oEndereco); // posse do oEndereco transferida
                except
                  oEndereco.Free;
                  raise;
                end;

                // telefones
                aTelefone := TJSONArray.Create;
                try
                  if sLista[17].Length > 2 then
                  begin
                    oTelefone := TJSONObject.Create;
                    oTelefone.AddPair('telefoneCI', EmptyStr);
                    oTelefone.AddPair('tipoTelefone', IfThen(sLista[17].Length = 11,'2','1'));
                    oTelefone.AddPair('ddi', EmptyStr);
                    oTelefone.AddPair('ddd', sLista[17].Substring(0,2));
                    oTelefone.AddPair('numero', sLista[17].Substring(2, Length(sLista[17])));
                    aTelefone.AddElement(oTelefone);
                  end;
                  if sLista[18].Length > 2 then
                  begin
                    oTelefone := TJSONObject.Create;
                    oTelefone.AddPair('telefoneCI', EmptyStr);
                    oTelefone.AddPair('tipoTelefone', IfThen(sLista[18].Length = 11,'2','1'));
                    oTelefone.AddPair('ddi', EmptyStr);
                    oTelefone.AddPair('ddd', sLista[18].Substring(0,2));
                    oTelefone.AddPair('numero', sLista[18].Substring(2, Length(sLista[18])));
                    aTelefone.AddElement(oTelefone);
                  end;
                  if sLista[19].Length > 2 then
                  begin
                    oTelefone := TJSONObject.Create;
                    oTelefone.AddPair('telefoneCI', EmptyStr);
                    oTelefone.AddPair('tipoTelefone', IfThen(sLista[19].Length = 11,'2','1'));
                    oTelefone.AddPair('ddi', EmptyStr);
                    oTelefone.AddPair('ddd', sLista[19].Substring(0,2));
                    oTelefone.AddPair('numero', sLista[19].Substring(2, Length(sLista[19])));
                    aTelefone.AddElement(oTelefone);
                  end;

                  oCliente.AddPair('telefone', aTelefone); // posse transferida
                except
                  aTelefone.Free;
                  raise;
                end;

                // demais campos
                oCliente.AddPair('camposPersonalizado', TJSONArray.Create.Add(''));
                oCliente.AddPair('contatoCI', sLista[1]);
                oCliente.AddPair('nome', sLista[2]);
                oCliente.AddPair('sexo', IfThen(sLista[3].ToLower = 'masculino', 'M', 'F'));
                oCliente.AddPair('dataNascimento', IfThen(sLista[4].Length > 0, ConvertToISO8601(sLista[4]), EmptyStr));
                oCliente.AddPair('dataCadastro', IfThen(sLista[5].Length > 0, ConvertToISO8601(sLista[5]), EmptyStr));
                oCliente.AddPair('cpf', sLista[6]);
                oCliente.AddPair('email', sLista[7]);
                oCliente.AddPair('filialCI', sLista[8]);

                aCliente.AddElement(oCliente); // posse transferida
              except
                oCliente.Free;
                raise;
              end;
            end;

          4: // Cliente Jurídico
            begin
              oClienteJuridico := TJSONObject.Create;
              try
                oClienteJuridico.AddPair('empresaCI', sLista[1]);
                oClienteJuridico.AddPair('razaoSocial', sLista[2]);
                oClienteJuridico.AddPair('nomeFantasia', sLista[3]);
                oClienteJuridico.AddPair('cnpj', sLista[4]);
                oClienteJuridico.AddPair('filialCI', sLista[5]);
                oClienteJuridico.AddPair('site', sLista[6]);
                oClienteJuridico.AddPair('facebook', sLista[7]);
                oClienteJuridico.AddPair('instagram', sLista[8]);

                oEndereco := TJSONObject.Create;
                try
                  oEndereco.AddPair('enderecoCI', EmptyStr);
                  oEndereco.AddPair('logradouro', sLista[9]);
                  oEndereco.AddPair('numero', sLista[10]);
                  oEndereco.AddPair('complemento', sLista[11]);
                  oEndereco.AddPair('bairro', sLista[12]);
                  oEndereco.AddPair('cidade', sLista[13]);
                  oEndereco.AddPair('estado', sLista[14]);
                  oEndereco.AddPair('cep', sLista[15]);
                  oEndereco.AddPair('pais', sLista[16]);
                  oClienteJuridico.AddPair('endereco', oEndereco); // posse transferida
                except
                  oEndereco.Free;
                  raise;
                end;

                aTelefone := TJSONArray.Create;
                try
                  if sLista[17].Length > 2 then
                  begin
                    oTelefone := TJSONObject.Create;
                    oTelefone.AddPair('telefoneCI', EmptyStr);
                    oTelefone.AddPair('tipoTelefone', IfThen(sLista[17].Length = 11,'2','1'));
                    oTelefone.AddPair('ddi', EmptyStr);
                    oTelefone.AddPair('ddd', sLista[17].Substring(0,2));
                    oTelefone.AddPair('numero', sLista[17].Substring(2, Length(sLista[17])));
                    aTelefone.AddElement(oTelefone);
                  end;
                  if sLista[18].Length > 2 then
                  begin
                    oTelefone := TJSONObject.Create;
                    oTelefone.AddPair('telefoneCI', EmptyStr);
                    oTelefone.AddPair('tipoTelefone', IfThen(sLista[18].Length = 11,'2','1'));
                    oTelefone.AddPair('ddi', EmptyStr);
                    oTelefone.AddPair('ddd', sLista[18].Substring(0,2));
                    oTelefone.AddPair('numero', sLista[18].Substring(2, Length(sLista[18])));
                    aTelefone.AddElement(oTelefone);
                  end;
                  if sLista[19].Length > 2 then
                  begin
                    oTelefone := TJSONObject.Create;
                    oTelefone.AddPair('telefoneCI', EmptyStr);
                    oTelefone.AddPair('tipoTelefone', IfThen(sLista[19].Length = 11,'2','1'));
                    oTelefone.AddPair('ddi', EmptyStr);
                    oTelefone.AddPair('ddd', sLista[19].Substring(0,2));
                    oTelefone.AddPair('numero', sLista[19].Substring(2, Length(sLista[19])));
                    aTelefone.AddElement(oTelefone);
                  end;

                  oClienteJuridico.AddPair('telefone', aTelefone); // posse transferida
                except
                  aTelefone.Free;
                  raise;
                end;

                oClienteJuridico.AddPair('cpfContatoPrincipal', sLista[20]);
                oClienteJuridico.AddPair('email', sLista[21]);

                // chama API e escreve resposta
                if not CreateOrUpdateJuridicCustomer(oClienteJuridico, sToken, msg) then
                  WriteResponse('4', 'Error', 'Falha durante a gravação de cliente jurídico, motivo: ' + msg)
                else
                  WriteResponse('4', 'Success', 'Cadastro/Atualização de cliente jurídico realizado com sucesso!');
              finally
                oClienteJuridico.Free; // liberamos aqui pois NÃO adicionamos ao array
              end;
            end;

          5: // Categoria
            begin
              oCategoria := TJSONObject.Create;
              try
                oCategoria.AddPair('produtoCategoriaCI', sLista[1]);
                oCategoria.AddPair('nomeProdutoCategoria', sLista[2]);
                oCategoria.AddPair('produtoCategoriaPaiCI', IfThen(sLista[3].Trim.Length > 0, sLista[3], '0'));
                aCategoria.AddElement(oCategoria);
              except
                oCategoria.Free;
                raise;
              end;
            end;

          6: // Fabricante
            begin
              oFabricante := TJSONObject.Create;
              try
                oFabricante.AddPair('fabricanteId', sLista[1]);
                oFabricante.AddPair('fabricanteCI', sLista[1]);
                oFabricante.AddPair('nomeFabricante', sLista[2]);
                aFabricante.AddElement(oFabricante);
              except
                raise;
              end;
            end;

          7: // Produto
            begin
              oProduto := TJSONObject.Create;
              try
                oProduto.AddPair('produtoCI', sLista[1]);
                oProduto.AddPair('ean', sLista[2]);
                oProduto.AddPair('nomeProduto', sLista[3]);
                oProduto.AddPair('descricao', sLista[4]);
                oProduto.AddPair('link', sLista[5]);
                oProduto.AddPair('LinkImagem', sLista[6]);
                oProduto.AddPair('preco', sLista[7]);
                oProduto.AddPair('precoPromocional', sLista[8]);
                oProduto.AddPair('estoque', sLista[9]);
                oProduto.AddPair('ativo', sLista[10].ToLower);
                oProduto.AddPair('fabricanteCI', sLista[11]);
                oProduto.AddPair('categoriaProdutoCI', sLista[12]);
                oProduto.AddPair('produtoUnidadeMedida', sLista[13]);
                oProduto.AddPair('unidadeMedida', sLista[14]);
                aProduto.AddElement(oProduto);
              except
                oProduto.Free;
                raise;
              end;
            end;

          8: // Forma de pagamento
            begin
              oFormaPagto := TJSONObject.Create;
              try
                oFormaPagto.AddPair('formaPagamentoCI', sLista[1]);
                oFormaPagto.AddPair('nomeFormaPagamento', sLista[2]);
                oFormaPagto.AddPair('ativo', sLista[3].ToLower);
                aFormaPagto.AddElement(oFormaPagto);
              except
                oFormaPagto.Free;
                raise;
              end;
            end;

          9: // Venda (cabeçalho)
            begin
              idVenda :=
                FormatFloat('00', StrToInt(sLista[2])) +
                FormatDateTime('ddmmyyyy', StrToDate(sLista[1])) +
                FormatFloat('000000', StrToInt(sLista[4]));

              oVenda := TJSONObject.Create;
              try
                oVenda.AddPair('contatoCI', sLista[5]);
                oVenda.AddPair('vendaContatoCI', idVenda);
                oVenda.AddPair('contatoCPF', sLista[6]);
                oVenda.AddPair('contarPontos', 1); // 1 - Sim, 0 - Não
                oVenda.AddPair('resgateAutomatico', TJSONBool.Create(true));
                oVenda.AddPair('dataVenda', ConvertToISO8601(sLista[1]));
                oVenda.AddPair('numero', sLista[4]);
                oVenda.AddPair('valor', sLista[7].Replace(',','.'));
                oVenda.AddPair('desconto', sLista[8].Replace(',','.'));
                oVenda.AddPair('comissao', sLista[9].Replace(',','.'));
                oVenda.AddPair('vendedorCI', sLista[10]);
                oVenda.AddPair('nomeVendedor', sLista[11]);
                oVenda.AddPair('formaPagamentoCI', sLista[12]);
                oVenda.AddPair('nomeFormaPagamento', sLista[13]);
                oVenda.AddPair('filialCI', sLista[2]);
                oVenda.AddPair('filialNomeFantasia', sLista[3]);
                oVenda.AddPair('formaEnvioCI', sLista[14]);
                oVenda.AddPair('nomeFormaEnvio', sLista[15]);
                oVenda.AddPair('valorFrete', sLista[16]);

                aVendaItem := TJSONArray.Create;
                oVenda.AddPair('item', aVendaItem); // posse transferida

                aVendaPagto := TJSONArray.Create;
                oVenda.AddPair('formasPagamento', aVendaPagto); // posse transferida

                mapVendas.Add(idVenda, oVenda);
                mapItens.Add(idVenda, aVendaItem);
                mapPagtos.Add(idVenda, aVendaPagto);

                oVenda.AddPair('indicadorCI', sLista[17]);

                aVenda.AddElement(oVenda); // posse transferida para aVenda
              except
                oVenda.Free;
                raise;
              end;
            end;

          10: // Item de venda (detalhe)
            begin
              idVenda :=
                FormatFloat('00', StrToInt(sLista[2])) +
                FormatDateTime('ddmmyyyy', StrToDate(sLista[1])) +
                FormatFloat('000000', StrToInt(sLista[4]));

              if not mapItens.TryGetValue(idVenda, aVendaItem) then
                raise Exception.Create('Item encontrado sem venda correspondente: ' + idVenda);

              oVendaItem := TJSONObject.Create;
              try
                oVendaItem.AddPair('vendaContatoItemCI', sLista[5]);
                oVendaItem.AddPair('produtoCI', sLista[6]);
                oVendaItem.AddPair('quantidade', sLista[7]);
                oVendaItem.AddPair('valor', sLista[8].Replace(',','.'));
                oVendaItem.AddPair('desconto', sLista[9].Replace(',','.'));
                oVendaItem.AddPair('comissao', sLista[10].Replace(',','.'));
                aVendaItem.AddElement(oVendaItem); // posse transferida para aVendaItem
              except
                oVendaItem.Free;
                raise;
              end;
            end;

          11: // Pagamento da venda (detalhe)
            begin
              idVenda :=
                FormatFloat('00', StrToInt(sLista[2])) +
                FormatDateTime('ddmmyyyy', StrToDate(sLista[1])) +
                FormatFloat('000000', StrToInt(sLista[4]));

              if not mapPagtos.TryGetValue(idVenda, aVendaPagto) then
                raise Exception.Create('Pagamento encontrado sem venda correspondente: ' + idVenda);

              oVendaPagto := TJSONObject.Create;
              try
                try
                  oVendaPagto.AddPair('formaPagamentoCI', sLista[5]);
                  oVendaPagto.AddPair('nomeFormaPagamento', sLista[6]);
                  oVendaPagto.AddPair('valor', sLista[7].Replace(',','.'));
                  aVendaPagto.AddElement(oVendaPagto); // posse transferida
                except
                  raise;
                end;
              finally
                oVendaPagto.Free;
              end;
            end;

          12: // Cancelamento / exclusão de venda
            begin
              idVenda :=
                FormatFloat('00', StrToInt(sLista[2])) +
                FormatDateTime('ddmmyyyy', StrToDate(sLista[1])) +
                FormatFloat('000000', StrToInt(sLista[4]));

              aVendaCanc.Add(idVenda); // string adicionada
            end;

          13: // Consulta cashback instântaneo por CPF
            begin
              oCashBack := TJSONObject.Create;

              try
                try
                  oCashBack.AddPair('cpf', sLista[1]);
                  oCashBack.AddPair('valorCompra', sLista[2]);
                  if not GetCashBackSnapshot(oCashBack, sToken, msg) then
                    WriteResponse('13', 'Error', msg)
                  else
                    WriteResponse('13', 'Success', msg);
                except
                  raise;
                end;
              finally
                oCashBack.Free;
              end;
            end;

          14: // Resgatar cashback instântaneo
            begin
              oCashBack := TJSONObject.Create;

              try
                try
                  oCashBack.AddPair('cpf', sLista[1]);
                  oCashBack.AddPair('dataResgate', ConvertToISO8601(DateToStr(Now())));
                  oCashBack.AddPair('valorCompra', sLista[2]);
                  if not RescueCashBackSnapShot(oCashBack, sToken, msg) then
                    WriteResponse('14', 'Error', msg)
                  else
                    WriteResponse('14', 'Success', msg);
                except
                  raise;
                end;
              finally
                oCashBack.Free;
              end;
            end;

          15: // Lista de cashback's por meta disponíveis
            begin
              if not GetCashBackList(sToken, msg) then
                WriteResponse('15', 'Error', msg);
            end;

          16: // Confirma a importação dos cashbacks retornados no método "15"
            begin
              if not ConfirmReceiptCashback(sToken, msg) then
                WriteResponse('16', 'Error', msg)
              else
                WriteResponse('16', 'Success', '');
            end;

          17: // Consulta cashback de meta por cpf
            begin
              oCashBack := TJSONObject.Create;

              try
                try
                  oCashBack.AddPair('cpf', sLista[1]);
                  if not GetCashBackByCpf(oCashBack, sToken, msg) then
                    WriteResponse('17', 'Error', msg);
                except
                  raise;
                end;
              finally
                oCashBack.Free;
              end;
            end;

          18: // Baixar cashback
            begin
              oCashBack := TJSONObject.Create;

              idVenda :=
                FormatFloat('00', StrToInt(sLista[2])) +
                FormatDateTime('ddmmyyyy', StrToDate(sLista[1])) +
                FormatFloat('000000', StrToInt(sLista[4]));

              oCashBack.AddPair('numeroVoucher', sLista[6]);
              oCashBack.AddPair('dataBaixa', ConvertToISO8601(sLista[1]));
              oCashBack.AddPair('cpf', sLista[5]);
              oCashBack.AddPair('vendaContatoCI', idVenda);
              aCashBack.AddElement(oCashBack);

            end;

          19: // Cancelar utilização do cashback
            begin
              var arr := TICashBackService.New.ReturnUsed(StrToDate(sLista[1]),
                sLista[4].ToInteger,sLista[2].ToInteger);

              if arr.Count > 0 then
                begin
                  try
                    if not CancelUsagedCashback(arr, sToken, msg) then
                      WriteResponse('19', 'Error', msg)
                    else
                      WriteResponse('19', 'Success', '');
                  finally
                    arr.Free;
                  end;
                end
              else
                WriteResponse('19', 'Error', 'Nenhum "Voucher" encontrado para venda'
                + sLista[4] + ' do dia ' + sLista[1] + ' da loja ' + sLista[2]);
            end;
        end; // case
      end; // while

      // Processa envios por tipo — cada função recebe a posse do JSONArray quando é o caso,
      // mas aqui esperamos que as funções não liberem o array (ou que elas não lancem exceção sem tratar).
      if aLoja.Count > 0 then
      begin
        if not CreateOrUpdateStore(aLoja, sToken, msg) then
          WriteResponse('1', 'Error', msg)
        else
          WriteResponse('1', 'Success', '');
      end;

      if aVendedor.Count > 0 then
      begin
        if not CreateOrUpdateSeller(aVendedor, sToken, msg) then
          WriteResponse('2', 'Error', msg)
        else
          WriteResponse('2', 'Success', '');
        // aVendedor será liberado abaixo
      end;

      if aCliente.Count > 0 then
      begin
        if not CreateOrUpdateCustomer(aCliente, sToken, msg) then
          WriteResponse('3', 'Error', 'Falha durante a gravação de cliente, motivo: ' + msg)
        else
          WriteResponse('3', 'Success', 'Cadastro/Atualização de cliente realizado com sucesso!');
      end;

      if aCategoria.Count > 0 then
      begin
        if not CreateOrUpdateCategory(aCategoria, sToken, msg) then
          WriteResponse('5', 'Error', msg)
        else
          WriteResponse('5', 'Success', '');
      end;

      if aFabricante.Count > 0 then
      begin
        if not CreateOrUpdateManufacture(aFabricante, sToken, msg) then
          WriteResponse('', 'Error', msg)
        else
          WriteResponse('', 'Success', '');
      end;

      if aProduto.Count > 0 then
      begin
        if not CreateOrUpdateProduct(aProduto, sToken, msg) then
          WriteResponse('6', 'Error', msg)
        else
          WriteResponse('6', 'Success', '');
      end;

      if aFormaPagto.Count > 0 then
      begin
        if not CreateOrUpdatePaymentMethod(aFormaPagto, sToken, msg) then
          WriteResponse('7', 'Error', msg)
        else
          WriteResponse('7', 'Success', '');
      end;

      if aVendaCanc.Count > 0 then
      begin
        if not DeleteSales(aVendaCanc, sToken, msg) then
          WriteResponse('12', 'Error', msg)
        else
          WriteResponse('12', 'Success', '');
      end;

      if aVenda.Count > 0 then
      begin
        if not CreateOrUpdateSales(aVenda, sToken, msg) then
          WriteResponse('8', 'Error', msg)
        else
          WriteResponse('8', 'Success', '');
      end;

      if aCashBack.Count > 0 then
      begin
        if not RescueCashBack(aCashBack, sToken, msg) then
          WriteResponse('18', 'Error', msg)
        else
          WriteResponse('18', 'Success', '');
      end;

    finally
      // sempre fechar o arquivo req
      CloseFile(arqReq);
      // apaga arquivo de entrada apenas depois de fechar
      if FileExists('C:\CSSISTEMAS\req.001') then
        DeleteFile('C:\CSSISTEMAS\req.001');
    end;

  except
    on E: Exception do
    begin
      TRoutines.GenerateLogs(tpError, 'Erro inesperado: ' + E.Message);
      ShowTemporaryMessageForm('Erro inesperado: ' + E.Message, 3, mtError);
      // não re-raise -- finalizadores cuidam da limpeza
    end;
  end;

  // FINALIZAÇÃO: liberar containers principais.
  // Observação: objetos que foram adicionados aos arrays (ex: oVenda em aVenda)
  // serão liberados automaticamente ao liberar o respectivo array.
  try
    mapVendas.Free;
    mapItens.Free;
    mapPagtos.Free;

    FreeAndNil(aLoja);
    FreeAndNil(aVendedor);
    FreeAndNil(aCategoria);
    FreeAndNil(aProduto);
    FreeAndNil(aCliente);
    FreeAndNil(aFormaPagto);
    FreeAndNil(aVenda);
    FreeAndNil(aVendaCanc);
    FreeAndNil(aCashBack);
    FreeAndNil(aFabricante);

    FreeAndNil(sLista);
  except
    // nada a fazer, apenas evitar exceptions na finalização
  end;

  Application.Terminate;
end;

class procedure TControllerEuFalo.ShowTemporaryMessageForm(const AMensagem
  : String; const TempoEmSegundos: Integer; const Tipo: TMessageType);
var
  Form: TTemporaryMessageForm;
begin
  Form := TTemporaryMessageForm.CreateTemporary(AMensagem,
    TempoEmSegundos, Tipo);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

class function TControllerEuFalo.GetToken(userId: String;
  accesskey: String; out msgError: String): String;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  oJson: TJSONObject;
  tokenObj: Ttoken;
  tokens: TObjectList<Ttoken>;
  respObject: TJSONObject;

  filter: string;
  needRequest: Boolean;
  FS: TFormatSettings;
  jv: TJSONValue;
begin
  Result := '';
  msgError := '';
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  oJson := nil;
  tokens := nil;
  respObject := nil;

  // monta JSON
  oJson := TJSONObject.Create;
  try
    oJson.AddPair('userID', userId);
    oJson.AddPair('accessKey', accesskey);
    oJson.AddPair('revendaId', TJSONNumber.Create(10)); // Valor default 10

    // prepara ORM e lista de tokens
    var ITokenService := TITokenService.New;
    try
      tokenObj := Ttoken.Create;
      ITokenService.GetModelToken(userId,tokenObj, msgError);
    except
      on E: Exception do
      begin
        msgError := 'Erro ao consultar tokens locais: ' + E.Message;
        Exit('');
      end;
    end;

    // decide se precisa chamar o endpoint (se não existir token local ou expirado)
    needRequest := True;
    if Assigned(tokenObj) and (tokenObj.expiration.Value > Now()) then
    begin
      Result := tokenObj.token.Value;
      needRequest := False;
    end;
    FreeAndNil(tokenObj);

    if not needRequest then
      Exit;

    // cria componentes REST
    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URL;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 12000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := '/Login/GetToken';
      restRequest.Params.Clear;
      restRequest.AddParameter('Accept', '*/*',
        TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);

      // envia body com content-type correto
      restRequest.AddBody(oJson.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação ao obter token: ' + E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit('');
        end;
      end;

      // checa HTTP status
      if restResponse.StatusCode <> 200 then
      begin
        msgError := Format('HTTP %d - %s', [restResponse.StatusCode,
          restResponse.Content]);
        TRoutines.GenerateLogs(tpError, msgError);
        ShowTemporaryMessageForm(msgError, 3, mtError);
        Exit;
      end;

      // parse da resposta
      if (restResponse.Content <> '') then
      begin
        respObject := TJSONObject.ParseJSONValue(restResponse.Content) as TJSONObject;
        try
          if not Assigned(respObject) then
          begin
            msgError := 'Resposta inválida ao autenticar (JSON nulo)';
            Exit;
          end;

          // Verifica campo "authenticated" corretamente
          if respObject.TryGetValue('authenticated', jv) then
          begin
            // jv pode ser booleano (TJSONTrue/TJSONFalse) ou string; tratar ambos
            if (jv is TJSONTrue) or SameText(jv.Value, 'true') then
            begin
              // obtem accessToken
              if respObject.TryGetValue('accessToken', jv) then
              begin
                // prepara formatos de data
                FS := TFormatSettings.Create;
                FS.DateSeparator := '-';
                FS.TimeSeparator := ':';
                FS.ShortDateFormat := 'yyyy-mm-dd';
                FS.LongTimeFormat := 'hh:nn:ss';

                var tokenJSONArray: TJSONArray;
                var tokenJSONObject: TJSONObject;

                tokenJSONArray := TJSONArray.Create;
                tokenJSONObject := TJSONObject.Create;
                tokenJSONObject.AddPair('userID', userId);
                tokenJSONObject.AddPair('accessToken',
                  respObject.GetValue('accessToken').Value);
                tokenJSONObject.AddPair('expiration',
                  respObject.GetValue('expiration').Value);
                if respObject.TryGetValue('expiration', jv) then
                    tokenJSONObject.AddPair('expiration',
                    StrToDateTime(jv.Value, FS))
                  else
                    tokenJSONObject.AddPair('expiration', Now + 1);

                tokenJSONArray.AddElement(tokenJSONObject);

                ITokenService.Save(tokenJSONArray, msgError);

                while tokenJSONArray.Count > 0 do
                  begin
                    tokenJSONArray.Items[0].Free;
                    tokenJSONArray.Remove(0);
                  end;

                  FreeAndNil(tokenJSONArray);

                Result := respObject.GetValue('accessToken').Value;
              end
              else
              begin
                msgError := 'Resposta sem accessToken';
                TRoutines.GenerateLogs(tpError, msgError);
                ShowTemporaryMessageForm(msgError, 3, mtError);
              end;
            end
            else
            begin
              // authenticated = false
              if respObject.TryGetValue('message', jv) then
              begin
                msgError := jv.Value;
                TRoutines.GenerateLogs(tpError, msgError);
                ShowTemporaryMessageForm('Error: 403 - ' + msgError, 3, mtError);
              end
              else
              begin
                msgError := 'Autenticação negada pela API';
                TRoutines.GenerateLogs(tpError, msgError);
                ShowTemporaryMessageForm('Error: 403 - ' + msgError, 3, mtError);
              end;
            end;
          end
          else
          begin
            msgError := 'Campo "authenticated" ausente na resposta';
            TRoutines.GenerateLogs(tpError, msgError);
            ShowTemporaryMessageForm(msgError, 3, mtError);
          end;
        finally
          respObject.Free;
          respObject := nil;
        end;
      end
      else
      begin
        msgError := 'Resposta vazia do servidor';
        TRoutines.GenerateLogs(tpError, msgError);
        ShowTemporaryMessageForm(msgError, 3, mtError);
      end;

    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;
  finally
    if Assigned(oJson) then
      oJson.Free;
    if Assigned(tokens) then
      FreeAndNil(tokens);
  end;
end;

class function TControllerEuFalo.CreateOrUpdateCustomer(customerArray: TJSONArray;
  token: String; out msgError: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var IClienteService := TIClienteService.New;

  try
    try
      IClienteService.Save(customerArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

    // preparo e envio da requisição REST
    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URLv2;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 4000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := IfThen(customerArray.Count > 1,
        '/contato/salvar/lista', '/contato/salvar/item');
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      if customerArray.Count > 1 then
        begin
          // Envia o array completo
          jsonBody := customerArray.ToJSON;
        end
      else if customerArray.Count = 1 then
        begin
          // Converte o único item do array para JSON de objeto
          singleObj := customerArray.Items[0] as TJSONObject;
          jsonBody := singleObj.ToJSON;
        end
      else
        begin
          // Caso não exista item (opcional)
          // jsonBody := 'null';
          jsonBody := '[]';  // ou escolha outra forma
        end;

      // usa o JSON passado - não criamos cópia de TJSONArray/TJSONObject aqui
      restRequest.AddBody(jsonBody,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              msgError := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          500:
            begin
              msgError := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end
          else
            begin
              msgError := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
      end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar categoria local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.CreateOrUpdateJuridicCustomer(customerObject: TJSONObject;
  token: String; out msgError: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  clientesJuridico: TObjectList<TclienteJuridico>;
  clienteJuridico: TclienteJuridico;
  TelefonesArray: TJSONArray;
  Tel1, Tel2, Tel3: string;
begin
  Result := False;
  clientesJuridico := nil;
  clienteJuridico := nil;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';
  Tel1 := '';
  Tel2 := '';
  Tel3 := '';

  try
    var IClienteJuridico := TIClienteJuridico.New;

    // build filter e obter lista (ListAll pode instanciar "clientes")
    try
      var filter := 'cnpj = ' + QuotedStr(customerObject.GetValue<String>('cnpj'));
      IClienteJuridico.Build.ListAll(filter, clientesJuridico, '');
    except
      on E: Exception do
      begin
        msgError := 'Erro ao consultar cliente local: ' + E.Message;
        Result := False;
        Exit;
      end;
    end;

    TelefonesArray := customerObject.GetValue<TJSONArray>('telefone');
    if Assigned(TelefonesArray) then
    begin
      if TelefonesArray.Count > 0 then
        Tel1 := TelefonesArray.Items[0].GetValue<string>('numero');

      if TelefonesArray.Count > 1 then
        Tel2 := TelefonesArray.Items[1].GetValue<string>('numero');

      if TelefonesArray.Count > 2 then
        Tel3 := TelefonesArray.Items[2].GetValue<string>('numero');
    end;

    if Assigned(clientesJuridico) and (clientesJuridico.Count > 0) then
      begin
        clienteJuridico := IClienteJuridico.Build.ListById('codigo',
          clientesJuridico.Last.codigo, clienteJuridico).This;

        IClienteJuridico.Build.Modify(clienteJuridico);
        with clienteJuridico do
          begin
            razao := customerObject.GetValue<String>('razaoSocial');
            fantasia := customerObject.GetValue<String>('nomeFantasia');
            cnpj := customerObject.GetValue<String>('cnpj');
            loja := customerObject.GetValue<Integer>('filialCI');
            site := customerObject.GetValue<String>('site');
            facebook := customerObject.GetValue<String>('facebook');
            instagram := customerObject.GetValue<String>('instagram');
            logradouro := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('logradouro');
            numero := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('numero');
            complemento := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('complemento');
            bairro := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('bairro');
            cidade := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('cidade');
            estado := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('estado');
            cep := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('cep');
            pais := customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('pais');
            cpfResponsavel := customerObject.GetValue<String>('cpfContatoPrincipal');
            email := customerObject.GetValue<String>('email');
            sincronizado := Now();
          end;
        IClienteJuridico.Build.Update;
      end
    else
      begin
        IClienteJuridico
          .codigo(customerObject.GetValue<Integer>('empresaCI'))
          .razao(customerObject.GetValue<String>('razaoSocial'))
          .fantasia(customerObject.GetValue<String>('nomeFantasia'))
          .cnpj(customerObject.GetValue<String>('cnpj'))
          .loja(customerObject.GetValue<Integer>('filialCI'))
          .site(customerObject.GetValue<String>('site'))
          .facebook(customerObject.GetValue<String>('facebook'))
          .instagram(customerObject.GetValue<String>('instagram'))
          .logradouro(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('logradouro'))
          .numero(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('numero'))
          .complemento(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('complemento'))
          .bairro(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('bairro'))
          .cidade(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('cidade'))
          .estado(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('estado'))
          .cep(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('cep'))
          .pais(customerObject.GetValue<TJSONObject>('endereco')
              .GetValue<string>('pais'))
          .cpfResponsavel(customerObject.GetValue<String>('cpfContatoPrincipal'))
          .email(customerObject.GetValue<String>('email'))
          .sincronizado(Now())
          .Build.Insert;
      end;

    var P: TJSONPair;
    P := customerObject.RemovePair('empresaCI');
    if Assigned(P) then
      P.Free;
    customerObject.AddPair('empresaCI', TJSONNull.Create);

    var saida := customerObject.ToString;

    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URL;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 4000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := '/api/empresa/Cadastro/salvar/item';
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      // usa o JSON passado - não criamos cópia de TJSONArray/TJSONObject aqui
      restRequest.AddBody(customerObject.ToJSON,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              msgError := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          500:
            begin
              msgError := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end
          else
            begin
              msgError := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
      end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  finally
    if Assigned(clientesJuridico) then
      FreeAndNil(clientesJuridico);

    if Assigned(clienteJuridico) then
      FreeAndNil(clienteJuridico);
  End;
end;

class function TControllerEuFalo.CreateOrUpdateProduct(
  productObject: TJSONArray; token: String; out msgError: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var IProdutoService := TIProdutoService.New;

  Try
    try
      IProdutoService.Save(productObject, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

    // preparo e envio da requisição REST
    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);

    try
      restClient.BaseURL := _URLv2;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 8000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := IfThen(productObject.Count = 1,
        '/produto/salvar/item','/produto/salvar/lista');
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      if productObject.Count > 1 then
        begin
          // Envia o array completo
          jsonBody := productObject.ToJSON;
        end
      else if productObject.Count = 1 then
        begin
          // Converte o único item do array para JSON de objeto
          singleObj := productObject.Items[0] as TJSONObject;
          jsonBody := singleObj.ToJSON;
        end
      else
        begin
          // Caso não exista item (opcional)
          // jsonBody := 'null';
          jsonBody := '[]';  // ou escolha outra forma
        end;

      // usa o JSON passado - não criamos cópia de TJSONArray/TJSONObject aqui
      restRequest.AddBody(jsonBody,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              msgError := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          500:
            begin
              msgError := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end
          else
            begin
              msgError := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
      end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  Except
    on E: Exception do
    begin
      ShowTemporaryMessageForm('Erro de comunicação: ' + E.Message,
        3, mtError);
      Application.Terminate;
    end;
  End;
end;

class function TControllerEuFalo.CreateOrUpdateSeller(sellerArray: TJSONArray;
  token: String; out msgError: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var IVendedorService := TIVendedorService.New;

  Try
    try
      IVendedorService.Save(sellerArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

  if sellerArray.Count > 0 then
    begin
      Result := True; // assume OK, só muda se falhar

      for var i := 0 to sellerArray.Count - 1 do
      begin
        // preparo e envio da requisição REST
        restClient := TRESTClient.Create(nil);
        restResponse := TRESTResponse.Create(nil);
        restRequest := TRESTRequest.Create(nil);

        try
          restClient.BaseURL := _URL;
          restRequest.Client := restClient;
          restRequest.Response := restResponse;
          restRequest.Timeout := 8000;

          restRequest.Method := TRESTRequestMethod.rmPOST;
          restRequest.Resource := '/api/Vendedor';
          restRequest.Params.Clear;

          restRequest.AddParameter('Content-Type', 'application/json',
            pkHTTPHEADER, [poDoNotEncode]);
          restRequest.AddParameter('Accept', 'application/json',
            pkHTTPHEADER, [poDoNotEncode]);
          restRequest.AddParameter('Authorization', 'Bearer ' + token,
            pkHTTPHEADER, [poDoNotEncode]);

          singleObj := sellerArray.Items[i] as TJSONObject;

          restRequest.AddBody(singleObj.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

          try
            restRequest.Execute;

            case restResponse.StatusCode of
              200:
                ; // OK – nada a fazer
              401:
                begin
                  Result := False;
                  msgError := 'Erro: 401 - Unauthorized';
                  TRoutines.GenerateLogs(tpError, msgError);
                  ShowTemporaryMessageForm(msgError, 3, mtError);
                end;
              500:
                begin
                  Result := False;
                  msgError := 'Erro: 500 - Internal Server Error';
                  TRoutines.GenerateLogs(tpError, msgError);
                  ShowTemporaryMessageForm(msgError, 3, mtError);
                end;
            else
              begin
                Result := False;
                msgError := 'Erro não especificado (HTTP ' +
                  restResponse.StatusCode.ToString + ')';
                TRoutines.GenerateLogs(tpError, msgError);
                ShowTemporaryMessageForm(msgError, 3, mtError);
              end;
            end;

            // interrompe caso erro
            if not Result then
              Break;

          except
            on E: Exception do
            begin
              Result := False;
              msgError := 'Erro de comunicação: ' + E.Message;
              ShowTemporaryMessageForm(msgError, 3, mtError);
              Break;
            end;
          end;
        finally
          restRequest.Free;
          restResponse.Free;
          restClient.Free;
        end;
      end;
    end
    else
    begin
      Result := False;
      msgError := 'Nenhum vendedor para enviar.';
      TRoutines.GenerateLogs(tpWarning, msgError);
      ShowTemporaryMessageForm(msgError, 3, mtWarning);
    end;

  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar categoria local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.CreateOrUpdatePaymentMethod(paymentMethodArray:
TJSONArray; token: string; out msgError: string): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var IFormaPagtoService := TIFormaPagtoService.New;

  Try
    try
      IFormaPagtoService.Save(paymentMethodArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

  if paymentMethodArray.Count > 0 then
    begin
      Result := True; // assume OK, só muda se falhar

      for var i := 0 to paymentMethodArray.Count - 1 do
      begin
        // preparo e envio da requisição REST
        restClient := TRESTClient.Create(nil);
        restResponse := TRESTResponse.Create(nil);
        restRequest := TRESTRequest.Create(nil);

        try
          restClient.BaseURL := _URL;
          restRequest.Client := restClient;
          restRequest.Response := restResponse;
          restRequest.Timeout := 8000;

          restRequest.Method := TRESTRequestMethod.rmPOST;
          restRequest.Resource := '/api/FormaPagamento';
          restRequest.Params.Clear;

          restRequest.AddParameter('Content-Type', 'application/json',
            pkHTTPHEADER, [poDoNotEncode]);
          restRequest.AddParameter('Accept', 'application/json',
            pkHTTPHEADER, [poDoNotEncode]);
          restRequest.AddParameter('Authorization', 'Bearer ' + token,
            pkHTTPHEADER, [poDoNotEncode]);

          singleObj := paymentMethodArray.Items[i] as TJSONObject;

          restRequest.AddBody(singleObj.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

          try
            restRequest.Execute;

            case restResponse.StatusCode of
              200:
                ; // OK – nada a fazer
              401:
                begin
                  Result := False;
                  msgError := 'Erro: 401 - Unauthorized';
                  TRoutines.GenerateLogs(tpError, msgError);
                  ShowTemporaryMessageForm(msgError, 3, mtError);
                end;
              500:
                begin
                  Result := False;
                  msgError := 'Erro: 500 - Internal Server Error';
                  TRoutines.GenerateLogs(tpError, msgError);
                  ShowTemporaryMessageForm(msgError, 3, mtError);
                end;
            else
              begin
                Result := False;
                msgError := 'Erro não especificado (HTTP ' +
                  restResponse.StatusCode.ToString + ')';
                TRoutines.GenerateLogs(tpError, msgError);
                ShowTemporaryMessageForm(msgError, 3, mtError);
              end;
            end;

            // interrompe caso erro
            if not Result then
              Break;

          except
            on E: Exception do
            begin
              Result := False;
              msgError := 'Erro de comunicação: ' + E.Message;
              ShowTemporaryMessageForm(msgError, 3, mtError);
              Break;
            end;
          end;
        finally
          restRequest.Free;
          restResponse.Free;
          restClient.Free;
        end;
      end;
    end
    else
    begin
      Result := False;
      msgError := 'Nenhuma forma de pagamento para enviar.';
      TRoutines.GenerateLogs(tpWarning, msgError);
      ShowTemporaryMessageForm(msgError, 3, mtWarning);
    end;

  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar categoria local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.CreateOrUpdateStore(storeArray: TJSONArray;
  token: String; out msgError: string): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var ILojaService := TILojaService.New;

  try
    try
      ILojaService.Save(storeArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

    // preparo e envio da requisição REST
    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URLv2;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 8000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := IfThen(storeArray.Count > 1,
        '/filial/salvar/lista', '/filial/salvar/item');
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      if storeArray.Count > 1 then
        begin
          // Envia o array completo
          jsonBody := storeArray.ToJSON;
        end
      else if storeArray.Count = 1 then
        begin
          // Converte o único item do array para JSON de objeto
          singleObj := storeArray.Items[0] as TJSONObject;
          jsonBody := singleObj.ToJSON;
        end
      else
        begin
          // Caso não exista item (opcional)
          // jsonBody := 'null';
          jsonBody := '[]';  // ou escolha outra forma
        end;

      // usa o JSON passado - não criamos cópia de TJSONArray/TJSONObject aqui
      restRequest.AddBody(jsonBody,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              msgError := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          500:
            begin
              msgError := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end
          else
            begin
              msgError := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
      end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;
  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar loja local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.CreateOrUpdateCategory(categoryArray: TJSONArray;
  token: String; out msgError: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var ICategoriaService := TICategoriaService.New;

  try
    try
      ICategoriaService.Save(categoryArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

    // preparo e envio da requisição REST
    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URLv2;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 8000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := IfThen(categoryArray.Count > 1,
        '/produtocategoria/salvar/lista', '/produtocategoria/salvar/item');
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      if categoryArray.Count > 1 then
        begin
          // Envia o array completo
          jsonBody := categoryArray.ToJSON;
        end
      else if categoryArray.Count = 1 then
        begin
          // Converte o único item do array para JSON de objeto
          singleObj := categoryArray.Items[0] as TJSONObject;
          jsonBody := singleObj.ToJSON;
        end
      else
        begin
          // Caso não exista item (opcional)
          // jsonBody := 'null';
          jsonBody := '[]';  // ou escolha outra forma
        end;

      // usa o JSON passado - não criamos cópia de TJSONArray/TJSONObject aqui
      restRequest.AddBody(jsonBody,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              msgError := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          500:
            begin
              msgError := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end
          else
            begin
              msgError := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
      end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar categoria local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.CreateOrUpdateManufacture(manufactureArray: TJSONArray;
  token: String; out msgError: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var IFabricanteService := TIFabricanteService.New;

  try
    try
      IFabricanteService.Save(manufactureArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

    // preparo e envio da requisição REST
    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URL;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 8000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := '/api/Fabricante/Salvar';
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      if (manufactureArray.Count > 0) then
        begin
          for var i := 0 to manufactureArray.Count -1 do
            begin
              singleObj := manufactureArray.Items[i] as TJSONObject;
              jsonBody := singleObj.ToJSON;

              restRequest.AddBody(jsonBody,
                TRESTContentType.ctAPPLICATION_JSON);

              try
                restRequest.Execute;
                case restResponse.StatusCode of
                  200: Result := True;
                  401:
                    begin
                      msgError := 'Erro: 401 - Unauthorized';
                      TRoutines.GenerateLogs(tpError, msgError);
                      ShowTemporaryMessageForm(msgError, 3, mtError);
                    end;
                  500:
                    begin
                      msgError := 'Erro: 500 - Internal Server Error';
                      TRoutines.GenerateLogs(tpError, msgError);
                      ShowTemporaryMessageForm(msgError, 3, mtError);
                    end
                  else
                    begin
                      msgError := 'Erro não especificado (HTTP ' +
                        restResponse.StatusCode.ToString + ')';
                      TRoutines.GenerateLogs(tpError, msgError);
                      ShowTemporaryMessageForm(msgError, 3, mtError);
                    end;
                end;
              except
                on E: Exception do
                begin
                  msgError := 'Erro de comunicação: ' + E.Message;
                  ShowTemporaryMessageForm(msgError, 3, mtError);
                end;
              end;
            end;
        end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar venda local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.CreateOrUpdateSales(salesArray: TJSONArray;
  token: string; out msgError: string): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var IVendaService := TIVendaService.New;

  try
    try
      IVendaService.Save(salesArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

    // preparo e envio da requisição REST
    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URLv2;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 8000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := IfThen(salesArray.Count > 1,
        '/vendacontato/salvar/lista', '/vendacontato/salvar/item');
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      if salesArray.Count > 1 then
        begin
          // Envia o array completo
          jsonBody := salesArray.ToJSON;
        end
      else if salesArray.Count = 1 then
        begin
          // Converte o único item do array para JSON de objeto
          singleObj := salesArray.Items[0] as TJSONObject;
          jsonBody := singleObj.ToJSON;
        end
      else
        begin
          // Caso não exista item (opcional)
          // jsonBody := 'null';
          jsonBody := '[]';  // ou escolha outra forma
        end;

      // usa o JSON passado - não criamos cópia de TJSONArray/TJSONObject aqui
      restRequest.AddBody(jsonBody,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              msgError := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          500:
            begin
              msgError := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end
          else
            begin
              msgError := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
      end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar venda local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.DeleteSales(salesArray: TJSONArray;
  token: string; out msgError: string): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result := False;
  restClient := nil;
  restResponse := nil;
  restRequest := nil;
  msgError := '';

  var IVendaService := TIVendaService.New;

  try
    try
      IVendaService.Delete(salesArray, msgError);
      if msgError.Length > 0 then
        begin
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
    except
      on E: Exception do
        begin
          msgError := E.Message;
          TRoutines.GenerateLogs(tpError, msgError);
          ShowTemporaryMessageForm(msgError, 3, mtError);
          Exit;
        end;
    end;

    restClient := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URLv2;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 8000;
      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Params.Clear;

      // Cabeçalhos
      restRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token, pkHTTPHEADER, [poDoNotEncode]);

      // Configuração da URL e do body
      case salesArray.Count of
        0:
          begin
            // Nenhum item -> envia array vazio
            restRequest.Resource := '/vendacontato/excluir/lista';
            restRequest.AddBody('[]', TRESTContentType.ctAPPLICATION_JSON);
          end;

        1:
          begin
            // Único item -> passar vendaContatoCI na query string
            var vendaContatoCI := (salesArray.Items[0] as TJSONString).Value;
            restRequest.Resource := '/vendacontato/excluir/item?vendaContatoCI=' + vendaContatoCI;
          end;

      else
        begin
          // Mais de um item -> enviar array completo no body
          restRequest.Resource := '/vendacontato/excluir/lista';
          jsonBody := salesArray.ToJSON;
          restRequest.AddBody(jsonBody, TRESTContentType.ctAPPLICATION_JSON);
        end;
      end;

      // Executa requisição
      try
        restRequest.Execute;

        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              msgError := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          500:
            begin
              msgError := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
          else
            begin
              msgError := 'Erro não especificado (HTTP ' + restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, msgError);
              ShowTemporaryMessageForm(msgError, 3, mtError);
            end;
        end;

      except
        on E: Exception do
        begin
          msgError := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(msgError, 3, mtError);
        end;
      end;

    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  except
    on E: Exception do
    begin
      msgError := 'Erro ao consultar venda local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.GetCashBackSnapshot(cashBack: TJSONObject;
  token: string; out retorno: string): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonObj, item: TJSONObject;
  arr: TJSONArray;
  saldo: String;
begin
  Result       := False;
  restClient   := nil;
  restResponse := nil;
  restRequest  := nil;
  retorno      := '';

  try
    restClient   := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest  := TRESTRequest.Create(nil);
    try
      restClient.BaseURL   := _URL;
      restRequest.Client   := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout  := 8000;
      restRequest.Method   := TRESTRequestMethod.rmGet;
      restRequest.Params.Clear;

      // Cabeçalhos
      restRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token, pkHTTPHEADER, [poDoNotEncode]);

      var cpf := cashBack.GetValue<String>('cpf');
      var valorCompra := cashBack.GetValue<String>('valorCompra');

      restRequest.Resource :=
        '/api/programafidelidade/consultarSaldoCashbackInstantaneo?cpf=' + cpf
        + '&valorCompra=' + valorCompra.Replace(',','.');

      // Executa requisição
      try
        restRequest.Execute;

        jsonObj := TJSONObject.ParseJSONValue(restResponse.Content) as TJSONObject;

        if Assigned(JsonObj) then
          try
            arr := JsonObj.GetValue<TJSONArray>('success');
            if Assigned(Arr) and (Arr.Count > 0) then
            begin
              item := Arr.Items[0] as TJSONObject;
              saldo := Item.GetValue<string>('saldo');
              retorno := saldo;
            end;

            arr := JsonObj.GetValue<TJSONArray>('errors');
            if Assigned(Arr) and (Arr.Count > 0) then
            begin
              item := Arr.Items[0] as TJSONObject;

              // Caso a propriedade "mensagem" seja array
              if item.GetValue('mensagem') is TJSONArray then
                retorno := (Item.GetValue('mensagem') as TJSONArray).ToString
              else
                retorno := Item.GetValue<string>('mensagem');
            end;

          finally
            jsonObj.Free;
          end;

        case restResponse.StatusCode of
          200: Result := True;
          401:
            begin
              // retorno := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
          500:
            begin
              // retorno := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
          else
            begin
              // retorno := 'Erro não especificado (HTTP ' + restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
        end;

      except
        on E: Exception do
        begin
          retorno := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(retorno, 3, mtError);
        end;
      end;

    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  except
    on E: Exception do
    begin
      retorno := 'Erro ao consultar cash bach: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.RescueCashBackSnapShot(cashBack: TJSONObject;
  token: string; out retorno: string): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonObj, item: TJSONObject;
  arr: TJSONArray;
  saldo: String;
begin
  Result       := False;
  restClient   := nil;
  restResponse := nil;
  restRequest  := nil;
  retorno      := '';

  try
    restClient   := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest  := TRESTRequest.Create(nil);
    try
      restClient.BaseURL   := _URL;
      restRequest.Client   := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout  := 8000;
      restRequest.Method   := TRESTRequestMethod.rmPOST;
      restRequest.Params.Clear;

      // Cabeçalhos
      restRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token, pkHTTPHEADER, [poDoNotEncode]);
      restRequest.Resource := '/api/programafidelidade/baixarvoucherCashbackInstantaneo/item';

      restRequest.AddBody(cashBack.ToString,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;

        jsonObj := TJSONObject.ParseJSONValue(restResponse.Content) as TJSONObject;

        if Assigned(JsonObj) then
          try
            arr := JsonObj.GetValue<TJSONArray>('success');
            if Assigned(Arr) and (Arr.Count > 0) then
            begin
              item := Arr.Items[0] as TJSONObject;

              // Caso a propriedade "mensagem" seja array
              if item.GetValue('mensagem') is TJSONArray then
                retorno := ((Item.GetValue('mensagem') as TJSONArray)[0]).ToString
              else
                retorno := Item.GetValue<string>('mensagem');

              Result := True;
            end;

            arr := JsonObj.GetValue<TJSONArray>('errors');
            if Assigned(Arr) and (Arr.Count > 0) then
            begin
              item := Arr.Items[0] as TJSONObject;

              // Caso a propriedade "mensagem" seja array
              if item.GetValue('mensagem') is TJSONArray then
                retorno := ((Item.GetValue('mensagem') as TJSONArray)[0]).ToString
              else
                retorno := Item.GetValue<string>('mensagem');
            end;

          finally
            jsonObj.Free;
          end;

        case restResponse.StatusCode of
          // Removido o case do retorno 200 pois é o código de retorno
          // mesmo quando não houver saldo de cashback
          // 200: Result := True;
          401:
            begin
              // retorno := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
          500:
            begin
              // retorno := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
          else
            begin
              // retorno := 'Erro não especificado (HTTP ' + restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          retorno := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(retorno, 3, mtError);
        end;
      end;
    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;
  except
    on E: Exception do
    begin
      retorno := 'Erro ao consultar cash bach: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.GetCashBackList(token: String;
  out retorno: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonRoot: TJSONValue;
  arr: TJSONArray;
  item: TJSONValue;
  jsonObj: TJSONObject;
  arqResp: TextFile;
  SL: TStringList;
begin
  Result  := False;
  retorno := '';
  jsonRoot := nil;

  restClient   := TRESTClient.Create(nil);
  restResponse := TRESTResponse.Create(nil);
  restRequest  := TRESTRequest.Create(nil);
  try
    restClient.BaseURL   := _URL;
    restRequest.Client   := restClient;
    restRequest.Response := restResponse;
    restRequest.Method   := TRESTRequestMethod.rmGET;
    restRequest.Timeout  := 8000;

    restRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
    restRequest.AddParameter('Accept', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
    restRequest.AddParameter('Authorization', 'Bearer ' + token, pkHTTPHEADER, [poDoNotEncode]);
    restRequest.Resource := '/api/programafidelidade/resgatecashback/listar';

    restRequest.Execute;

    if restResponse.StatusCode = 200 then
    begin
      jsonRoot := TJSONObject.ParseJSONValue(restResponse.Content);

      if not (jsonRoot is TJSONArray) then
      begin
        TRoutines.GenerateLogs(tpError, retorno);
        ShowTemporaryMessageForm(retorno, 3, mtError);

        ForceDirectories('C:\CSSISTEMAS');

        TFile.WriteAllText(
          'C:\CSSISTEMAS\resp.tmp',
          '15|Error|' + retorno,
          TEncoding.UTF8
        );

        if TFile.Exists('C:\CSSISTEMAS\resp.001') then
          TFile.Delete('C:\CSSISTEMAS\resp.001');

        TFile.Move(
          'C:\CSSISTEMAS\resp.tmp',
          'C:\CSSISTEMAS\resp.001'
        );

        Abort;
      end;

      arr := jsonRoot as TJSONArray;

      TICashbackService.New.Save(arr, retorno);

      ForceDirectories('C:\CSSISTEMAS');
      SL := TStringList.Create;
      try
        for item in arr do
        begin
          if item is TJSONObject then
          begin
            jsonObj := item as TJSONObject;

            SL.Add(
              '15|Success|' +
              jsonObj.GetValue<string>('chave', '') + ';' +
              jsonObj.GetValue<string>('contatoCI', '') + ';' +
              jsonObj.GetValue<string>('numeroVoucher', '') + ';' +
              jsonObj.GetValue<string>('cpf', '') + ';' +
              jsonObj.GetValue<string>('data', '') + ';' +
              jsonObj.GetValue<string>('prazoEntrega', '') + ';' +
              jsonObj.GetValue<string>('premio', '') + ';' +
              jsonObj.GetValue<string>('valor', '')
            );
          end;
        end;

        SL.SaveToFile('C:\CSSISTEMAS\resp.tmp', TEncoding.UTF8);

        TFile.Move(
          'C:\CSSISTEMAS\resp.tmp',
          'C:\CSSISTEMAS\resp.001'
        );
      finally
        SL.Free;
      end;

      Result := True;
    end;

    case restResponse.StatusCode of
      200: Result := True;
      401:
      begin
        // retorno := 'Erro: 401 - Unauthorized';
        TRoutines.GenerateLogs(tpError, retorno);
        ShowTemporaryMessageForm(retorno, 3, mtError);
      end;
      500:
      begin
        // retorno := 'Erro: 500 - Internal Server Error';
        TRoutines.GenerateLogs(tpError, retorno);
        ShowTemporaryMessageForm(retorno, 3, mtError);
      end;
      else
      begin
        // retorno := 'Erro não especificado (HTTP ' + restResponse.StatusCode.ToString + ')';
        TRoutines.GenerateLogs(tpError, retorno);
        ShowTemporaryMessageForm(retorno, 3, mtError);
      end;
    end;

  finally
    jsonRoot.Free;
    restRequest.Free;
    restResponse.Free;
    restClient.Free;
  end;
end;

class function TControllerEuFalo.ConfirmReceiptCashback(token: String;
  out retorno: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  arr: TJSONArray;
  jsonBody: string;
  singleObj: TJSONObject;
begin
  Result  := False;
  retorno := '';

  try
    arr := TICashBackService.New.GetNotSynced;

    restClient   := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest  := TRESTRequest.Create(nil);
    try
      restClient.BaseURL := _URL;
      restRequest.Client := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout := 8000;

      restRequest.Method := TRESTRequestMethod.rmPOST;
      restRequest.Resource := IfThen(arr.Count > 1,
        '/api/programafidelidade/resgatecashback/confirmar/lista',
          '/api/programafidelidade/resgatecashback/confirmar/item');
      restRequest.Params.Clear;
      restRequest.AddParameter('Content-Type', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json',
        pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token,
        pkHTTPHEADER, [poDoNotEncode]);

      if arr.Count > 1 then
        begin
          // Envia o array completo
          jsonBody := arr.ToJSON;
        end
      else if arr.Count = 1 then
        begin
          // Converte o único item do array para JSON de objeto
          singleObj := arr.Items[0] as TJSONObject;
          jsonBody := singleObj.ToJSON;
        end
      else
        begin
          // Caso não exista item (opcional)
          // jsonBody := 'null';
          jsonBody := '[]';  // ou escolha outra forma
        end;

      // usa o JSON passado - não criamos cópia de TJSONArray/TJSONObject aqui
      restRequest.AddBody(jsonBody,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;

        case restResponse.StatusCode of
          200:
            begin
              try
                TICashBackService.New.Synchronize(arr, retorno);
                Result := True;
              except
                TRoutines.GenerateLogs(tpError, retorno);
                ShowTemporaryMessageForm(retorno, 3, mtError);
                raise;
              end;
            end;
          401:
            begin
              retorno := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
          500:
            begin
              retorno := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end
          else
            begin
              retorno := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          retorno := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(retorno, 3, mtError);
        end;
      end;
    finally
      arr.Free;
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;

  except
    on E: Exception do
    begin
      retorno := 'Erro ao consultar venda local: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.GetCashBackByCpf(body: TJSONObject;
  token: String; out retorno: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonRoot: TJSONValue;
  arr: TJSONArray;
  item: TJSONValue;
  jsonObj: TJSONObject;
  arqResp: TextFile;
   SL: TStringList;
begin
  Result  := False;
  retorno := '';
  jsonRoot := nil;

  restClient   := TRESTClient.Create(nil);
  restResponse := TRESTResponse.Create(nil);
  restRequest  := TRESTRequest.Create(nil);
  try
    restClient.BaseURL   := _URL;
    restRequest.Client   := restClient;
    restRequest.Response := restResponse;
    restRequest.Method   := TRESTRequestMethod.rmPOST;
    restRequest.Timeout  := 8000;

    restRequest.AddParameter('Content-Type', 'application/json',
      pkHTTPHEADER, [poDoNotEncode]);
    restRequest.AddParameter('Accept', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
    restRequest.AddParameter('Authorization', 'Bearer ' + token, pkHTTPHEADER, [poDoNotEncode]);
    restRequest.Resource := '/api/programafidelidade/resgatecashback/listarPorCpf';

          restRequest.AddBody(body.ToString,
        TRESTContentType.ctAPPLICATION_JSON);

    restRequest.Execute;

    case restResponse.StatusCode of
      200:
        begin
          jsonRoot := TJSONObject.ParseJSONValue(restResponse.Content);

          if not (jsonRoot is TJSONArray) then
            begin
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);

              ForceDirectories('C:\CSSISTEMAS');

              TFile.WriteAllText(
                'C:\CSSISTEMAS\resp.tmp',
                '17|Error|' + retorno,
                TEncoding.UTF8
              );

              if TFile.Exists('C:\CSSISTEMAS\resp.001') then
                TFile.Delete('C:\CSSISTEMAS\resp.001');

              TFile.Move(
                'C:\CSSISTEMAS\resp.tmp',
                'C:\CSSISTEMAS\resp.001'
              );

              Abort;
            end;

          arr := jsonRoot as TJSONArray;

          TICashbackService.New.Save(arr, retorno);

          ForceDirectories('C:\CSSISTEMAS');
          SL := TStringList.Create;
          try
            for item in arr do
            begin
              if item is TJSONObject then
              begin
                jsonObj := item as TJSONObject;

                SL.Add(
                  '17|Success|' +
                  jsonObj.GetValue<string>('chave', '') + ';' +
                  jsonObj.GetValue<string>('contatoCI', '') + ';' +
                  jsonObj.GetValue<string>('numeroVoucher', '') + ';' +
                  jsonObj.GetValue<string>('cpf', '') + ';' +
                  jsonObj.GetValue<string>('data', '') + ';' +
                  jsonObj.GetValue<string>('prazoEntrega', '') + ';' +
                  jsonObj.GetValue<string>('premio', '') + ';' +
                  jsonObj.GetValue<string>('valor', '')
                );
              end;
            end;

            SL.SaveToFile('C:\CSSISTEMAS\resp.tmp', TEncoding.UTF8);

           TFile.Move(
                'C:\CSSISTEMAS\resp.tmp',
                'C:\CSSISTEMAS\resp.001'
              );
          finally
            SL.Free;
          end;

          Result := True;
        end;
      401:
      begin
        retorno := 'Erro: 401 - Unauthorized';
        TRoutines.GenerateLogs(tpError, retorno);
        ShowTemporaryMessageForm(retorno, 3, mtError);
      end;
      500:
      begin
        retorno := 'Erro: 500 - Internal Server Error';
        TRoutines.GenerateLogs(tpError, retorno);
        ShowTemporaryMessageForm(retorno, 3, mtError);
      end;
      else
      begin
        retorno := 'Erro não especificado (HTTP ' + restResponse.StatusCode.ToString + ')';
        TRoutines.GenerateLogs(tpError, retorno);
        ShowTemporaryMessageForm(retorno, 3, mtError);
      end;
    end;

  finally
    jsonRoot.Free;
    restRequest.Free;
    restResponse.Free;
    restClient.Free;
  end;
end;

class function TControllerEuFalo.RescueCashBack(cashBack: TJSONArray;
  token: String; out retorno: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  singleObj, item: TJSONObject;
  jsonBody: String;
  arr: TJSONArray;
begin
  Result       := False;
  restClient   := nil;
  restResponse := nil;
  restRequest  := nil;
  retorno      := '';

  try
    restClient   := TRESTClient.Create(nil);
    restResponse := TRESTResponse.Create(nil);
    restRequest  := TRESTRequest.Create(nil);
    try
      restClient.BaseURL   := _URL;
      restRequest.Client   := restClient;
      restRequest.Response := restResponse;
      restRequest.Timeout  := 8000;
      restRequest.Method   := TRESTRequestMethod.rmPOST;
      restRequest.Params.Clear;

      // Cabeçalhos
      restRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Accept', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
      restRequest.AddParameter('Authorization', 'Bearer ' + token, pkHTTPHEADER, [poDoNotEncode]);
      restRequest.Resource := IfThen(cashBack.Count > 1,
        '/api/programafidelidade/baixarvoucher/lista',
        '/api/programafidelidade/baixarvoucher/item');

      if cashBack.Count > 1 then
        begin
          // Envia o array completo
          jsonBody := cashBack.ToJSON;
        end
      else if cashBack.Count = 1 then
        begin
          // Converte o único item do array para JSON de objeto
          singleObj := cashBack.Items[0] as TJSONObject;
          jsonBody := singleObj.ToJSON;
        end
      else
        begin
          // Caso não exista item (opcional)
          // jsonBody := 'null';
          jsonBody := '[]';  // ou escolha outra forma
        end;

      restRequest.AddBody(jsonBody,
        TRESTContentType.ctAPPLICATION_JSON);

      try
        restRequest.Execute;
        case restResponse.StatusCode of
          200:
            begin
              Result := True;
              TICashbackService.New.Use(cashBack, retorno);
            end;
          401:
            begin
              retorno := 'Erro: 401 - Unauthorized';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
          500:
            begin
              retorno := 'Erro: 500 - Internal Server Error';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end
          else
            begin
              retorno := 'Erro não especificado (HTTP ' +
                restResponse.StatusCode.ToString + ')';
              TRoutines.GenerateLogs(tpError, retorno);
              ShowTemporaryMessageForm(retorno, 3, mtError);
            end;
        end;
      except
        on E: Exception do
        begin
          retorno := 'Erro de comunicação: ' + E.Message;
          ShowTemporaryMessageForm(retorno, 3, mtError);
        end;
      end;

    finally
      restRequest.Free;
      restResponse.Free;
      restClient.Free;
    end;
  except
    on E: Exception do
    begin
      retorno := 'Erro ao consultar cash bach: ' + E.Message;
      Result := False;
      Exit;
    end;
  end;
end;

class function TControllerEuFalo.CancelUsagedCashback(
  cashBacks: TJSONArray; token: String; out retorno: String): Boolean;
var
  restClient: TRESTClient;
  restResponse: TRESTResponse;
  restRequest: TRESTRequest;
  jsonObj, item: TJSONObject;
  arr: TJSONArray;
  i: Integer;
  voucher, mensagem, prefixoErro: string;
  sucessoTotal, sucessoItem: Boolean;
  errorCount: Integer;

  procedure AddErro(const Msg: string);
  begin
    Inc(errorCount);

    if errorCount >= 2 then
      prefixoErro := '19|Error|'
    else
      prefixoErro := '';

    retorno := retorno + prefixoErro + Msg + sLineBreak;
  end;

begin
  Result       := False;
  sucessoTotal := True;
  retorno      := '';
  errorCount   := 0;

  restClient   := TRESTClient.Create(nil);
  restResponse := TRESTResponse.Create(nil);
  restRequest  := TRESTRequest.Create(nil);

  try
    restClient.BaseURL   := _URL;
    restRequest.Client   := restClient;
    restRequest.Response := restResponse;
    restRequest.Timeout  := 8000;
    restRequest.Method   := TRESTRequestMethod.rmPOST;

    restRequest.Params.Clear;
    restRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
    restRequest.AddParameter('Accept', 'application/json', pkHTTPHEADER, [poDoNotEncode]);
    restRequest.AddParameter('Authorization', 'Bearer ' + token, pkHTTPHEADER, [poDoNotEncode]);

    for i := 0 to cashBacks.Count - 1 do
    begin
      sucessoItem := False;

      item := cashBacks.Items[i] as TJSONObject;
      voucher := item.GetValue<string>('numeroVoucher');

      restRequest.Resource :=
        '/api/programafidelidade/cancelarbaixavoucher/item?codigoMovimento=' + voucher;

      try
        restRequest.Execute;

        jsonObj := TJSONObject.ParseJSONValue(restResponse.Content) as TJSONObject;
        if not Assigned(jsonObj) then
          raise Exception.Create('Resposta inválida da API');

        try
          // SUCCESS
          arr := jsonObj.GetValue<TJSONArray>('success');
          if Assigned(arr) and (arr.Count > 0) then
          begin
            sucessoItem := True;

            if (arr.Items[0] is TJSONObject) and
               TJSONObject(arr.Items[0]).TryGetValue<string>('mensagem', mensagem) then
              retorno := retorno + Format(
                'Voucher %s baixado com sucesso. Mensagem: %s%s',
                [voucher, mensagem, sLineBreak]
              );
          end;

          // ERRORS
          arr := jsonObj.GetValue<TJSONArray>('errors');
          if Assigned(arr) and (arr.Count > 0) then
          begin
            sucessoItem := False;

            if arr.Items[0] is TJSONObject then
            begin
              item := arr.Items[0] as TJSONObject;

              if item.GetValue('mensagem') is TJSONArray then
                AddErro(
                  Format(
                    'Voucher %s - Erro: %s',
                    [
                      voucher,
                      (item.GetValue('mensagem') as TJSONArray).ToString
                    ]
                  )
                )
              else
                AddErro(
                  Format(
                    'Voucher %s - Erro: %s',
                    [
                      voucher,
                      item.GetValue<string>('mensagem')
                    ]
                  )
                );
            end;
          end;

          if not sucessoItem then
            sucessoTotal := False;

        finally
          jsonObj.Free;
        end;

      except
        on E: Exception do
        begin
          sucessoTotal := False;
          AddErro(
            Format(
              'Voucher %s - Erro de comunicação: %s',
              [voucher, E.Message]
            )
          );
        end;
      end;
    end;

    Result := sucessoTotal;

  finally
    restRequest.Free;
    restResponse.Free;
    restClient.Free;
  end;
end;

{$R Icons.res}

{ TTemporaryMessageForm }

constructor TTemporaryMessageForm.CreateTemporary(const AMensage: String;
  SecondsTime: Integer; Tipo: TMessageType);
var
  Panel, PanelTitle, PanelContext: TPanel;
  Img: TImage;
  MsgLabel: TLabel;
  IconName: string;
begin
  inherited CreateNew(nil);

  // Form config
  BorderStyle := bsNone;
  Position := poScreenCenter;
  Width := 600;
  Height := 100;
  Color := clWhite;
  DoubleBuffered := True;

  // Painel principal
  Panel := TPanel.Create(Self);
  Panel.Parent := Self;
  Panel.Align := alClient;
  Panel.Caption := '';
  Panel.ParentBackground := False;
  Panel.BevelOuter := bvNone;
  Panel.Padding.SetBounds(0, 0, 0, 0);

  // Painel titulo
  PanelTitle := TPanel.Create(Self);
  PanelTitle.Parent := Panel;
  PanelTitle.Align := alTop;
  PanelTitle.Caption := 'CashBack EuFalo';
  PanelTitle.Height := 24;
  PanelTitle.ParentBackground := False;
  PanelTitle.BevelOuter := bvNone;
  PanelTitle.Padding.SetBounds(0, 0, 1, 0);
  PanelTitle.Font.Color := clWhite;
  PanelTitle.Font.Style := [fsBold];

  // Painel contexto
  PanelContext := TPanel.Create(Self);
  PanelContext.Parent := Panel;
  PanelContext.Align := alClient;
  PanelContext.Caption := '';
  PanelContext.ParentBackground := False;
  PanelContext.BevelOuter := bvNone;
  PanelContext.Padding.SetBounds(3, 3, 3, 3);

  // Painel botão fechar
  PanelBtnClose := TPanel.Create(Self);
  PanelBtnClose.Parent := PanelTitle;
  PanelBtnClose.Align := alRight;
  PanelBtnClose.Caption := '';
  PanelBtnClose.ParentBackground := False;
  PanelBtnClose.BevelOuter := bvNone;
  PanelBtnClose.Color := clRed;
  PanelBtnClose.Width := 24;

  // Image
  Img := TImage.Create(Self);
  Img.Parent := PanelContext;
  Img.Align := alLeft;
  Img.Width := 64;
  // Img.Margins.Right := 16;
  Img.Stretch := True;
  Img.Proportional := True;
  Img.Margins.SetBounds(16, 3, 3, 3);

  // Mensagem
  MsgLabel := TLabel.Create(Self);
  MsgLabel.Parent := PanelContext;
  MsgLabel.Align := alClient;
  MsgLabel.WordWrap := True;
  MsgLabel.Layout := tlCenter;
  MsgLabel.Font.Size := 12;
  MsgLabel.Font.Style := [fsBold];
  MsgLabel.Transparent := True;
  MsgLabel.Caption := '   ' + AMensage;

  FBtnClose := TSpeedButton.Create(Self);
  FBtnClose.Parent := PanelBtnClose;
  FBtnClose.Align := alClient;
  FBtnClose.Flat := True;
  FBtnClose.StyleElements := [seBorder];
  FBtnClose.Caption := 'X';
  FBtnClose.Font.Size := 12;
  FBtnClose.Font.Color := clWhite;
  FBtnClose.Font.Name := 'Roboto';
  FBtnClose.Font.Quality := fqAntialiased;
  FBtnClose.Font.Style := [fsBold];
  FBtnClose.Cursor := crHandPoint;
  FBtnClose.OnClick := OnBtnCloseClickEvent;
  FBtnClose.OnMouseEnter := OnBtnCloseMouseEnterEvent;
  FBtnClose.OnMouseLeave := OnBtnCloseMouseLeaverEvent;

  // Define aparência e imagem
  case Tipo of
    mtInformation:
      begin
        PanelContext.Color := $FFE5CC;
        PanelTitle.Color := $854000;
        MsgLabel.Font.Color := $854000;
        IconName := 'INFO_ICON';
      end;
    mtWarning:
      begin
        PanelContext.Color := $CDF3FF;
        PanelTitle.Color := $0464A3;
        MsgLabel.Font.Color := $0464A3;
        IconName := 'WARNING_ICON';
      end;
    mtError:
      begin
        PanelContext.Color := $DAD7F8;
        PanelTitle.Color := $241C97;
        MsgLabel.Font.Color := $241C97;
        IconName := 'ERROR_ICON';
      end;
  end;

  LoadIconFromResource(IconName, Img);

  // Timer
  FTimer := TTimer.Create(Self);
  FTimer.Interval := SecondsTime * 1000;
  FTimer.OnTimer := OnTimerEvent;
  FTimer.Enabled := True;
end;

procedure TTemporaryMessageForm.CreateWnd;
var
  Rgn: HRGN;
  Radius: Integer;
begin
  inherited CreateWnd;

  // Arredondar cantos
  Radius := 20;
  Rgn := CreateRoundRectRgn(0, 0, Width, Height, Radius, Radius);
  SetWindowRgn(Handle, Rgn, True);

  // Sombra (disponível em temas Windows)
  SetClassLongPtr(Handle, GCL_STYLE, GetClassLongPtr(Handle, GCL_STYLE) or
    CS_DROPSHADOW);
end;

procedure TTemporaryMessageForm.LoadIconFromResource(const ResName: string;
  Image: TImage);
var
  ResStream: TResourceStream;
  Png: TPngImage;
begin
  ResStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  try
    Png := TPngImage.Create;
    try
      Png.LoadFromStream(ResStream);
      Image.Picture.Assign(Png);
    finally
      Png.Free;
    end;
  finally
    ResStream.Free;
  end;
end;

procedure TTemporaryMessageForm.OnBtnCloseClickEvent(Sender: TObject);
begin
  Close;
end;

procedure TTemporaryMessageForm.OnBtnCloseMouseEnterEvent(Sender: TObject);
begin
  PanelBtnClose.Color := $241C97;
end;

procedure TTemporaryMessageForm.OnBtnCloseMouseLeaverEvent(Sender: TObject);
begin
  PanelBtnClose.Color := clRed;
end;

procedure TTemporaryMessageForm.OnTimerEvent(Sender: TObject);
begin
  FTimer.Enabled := False;
  Close;
end;

end.
