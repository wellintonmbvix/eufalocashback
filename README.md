# Cashback EuFalo.com

O **CashBackEuFalo** é uma aplicação desenvolvida em Delphi 11.3 que serve como ponte entre aplicativos locais e a API da EuFalo.com, com o objetivo de realizar o controle de cashback em vendas de forma automatizada e flexível.

---

## Objetivo

Integrar sistemas de frente de loja com a API da Nummus, possibilitando:

- Cadastrar:
  - Matriz/Filiais
  - Vendedores
  - Categorias
  - Fabricantes
  - Produtos
  - Clientes
- Consulta de cashback disponível para um cliente.
- Registro de vendas para geração de cashback.
- Cancelamento de vendas.

---

## Tecnologias Utilizadas

- **Linguagem:** Pascal
- **IDE:** Delphi 11.3

---

## Funcionamento

### Arquivo de Configuração `C:\CSSISTEMAS\config.ini`

A aplicação utiliza também um arquivo de configuração chamado `config.ini`, responsável por armazenar informações essenciais para o funcionamento correto da integração.

#### Estrutura do arquivo `config.ini`

```ini
[Dados]
SS1=
SS6=
```

**Significado dos campos:**
- **SS1**: Nome do sistema que está utilizando a integração.
- **SS6**: Caminho completo até o arquivo `DB.FDB` utilizado pela aplicação.


A aplicação é executada por linha de comando e utiliza dois arquivos de troca:

- `req.001`: arquivo de requisição, contendo os dados necessários para a operação.
- `resp.001`: arquivo de resposta gerado após o processamento.

### Local dos arquivos

Os arquivos devem estar localizados na pasta:

```text
C:\CSSISTEMAS\
```

### Parâmetros obrigatórios da linha de comando:

- `--cashbackeufalo`: **(obrigatório)** ativa o modo de operação com a API da EuFalo.com.

---

## Layout do Arquivo `req.001`

```text
0|{usesID}|{accessKey}
1|{codigo_loja}|{razao_social}|{nome_fantasia}|{cnpj}|{logradouro}|{numero}|{bairro}|{cidade}|{uf}|{cep}|{ddd}|{fixo}|{ddd}|{celular}
2|{codigo_vendedor}|{nome_vendedor}|{ativo (true/false)}
3|{codigo_cliente_pf}|{nome_cliente}|{sexo (Masculino/Feminino)}|{data_nascimento}|{data_cadastro}|{cpf}|{email}|{codigo_loja_cadastro}|{logradouro}|{numero}|{complemento}|{bairro}|{cidade}|{uf}|{cep}|{pais}|{ddd_fone1}|{ddd_fone2}|{ddd_fone3}
4|{codigo_cliente_pj}|{razao_social}|{nome_fantasia}|{cnpj}|{codigo_loja_cadastro}|{site}|{facebook}|{instagram|{logradouro}|{numero}|{complemento}|{bairro}|{cidade}|{uf}|{cep}|{brasil}|{ddd_fone1}|{ddd_fone2}|{ddd_fone3|{cpf_responsavel}|{email}
5|{codigo_categoria}|{codigo_categoria_pai}
6|{codigo_fabricnate}|{nome_fabricante}
7|{codigo_produto}|{ean}|{nome_produto}|{descricao}|{url_completa_produto}|{url_completa_imagem}|{preco_produto}|{preco_promocional}|{estoque}|{ativo (true/false)}|{codigo_interno_fab}|{codigo_categoria}|{unidade (Kg,g,l,ml,un,Cx)}|{valor_unidade}
8|{codigo_forma_pagto}|{forma_pagto}
9|{data_venda}|{codigo_loja_cadastro}|{nome_fantasia_loja}|{codigo_unico_da_venda}|{codigo_cliente}|{cpf_cliente}|{valor_total_liquido}|{desconto}|{comissao}|{codigo_vendedor}|{nome_vendedor}|{codigo_forma_pagto}*|{forma_pagto}*|{codigo_forma_envio}*|{forma_envio}*|{frete}|{indicador}*
10|{data_venda}|{codigo_loja_cadastro}|{nome_fantasia_loja}|{codigo_unico_da_venda}|{numero_item}|{codigo_produto}|{quantidade}|{valor_liquido_produto}**|{desconto}|{comissao}
11|{data_venda}|{codigo_loja_cadastro}|{nome_fantasia_loja}|{codigo_unico_da_venda}|{codigo_forma_pagto}|{forma_pagto}|{valor}
12|{data_venda}|{codigo_loja_cadastro}|{nome_fantasia_loja}|{codigo_unico_da_venda}
13|{cpf}|{valor_da_compra}*
14|{cpf}|{valor_da_compra}
```
- `*`: Campos que podem estar vazios.
- `**`: Valor total já multiplicado pela quantidade com e com o abastimento do desconto.

### Significado de cada linha do arquivo `req.001`

Cada linha do arquivo `req.001` inicia com um identificador numérico (0 a 13). Esse identificador determina o tipo de operação ou cadastro que está sendo enviado à aplicação:

| Linha | Descrição |
|-------|-----------|
| **0** | Credenciais de acesso do usuário à plataforma. |
| **1** | Cadastro ou atualização de Empresa (matriz ou filial). |
| **2** | Cadastro ou atualização de Vendedor(es). |
| **3** | Cadastro ou atualização de Pessoa Física. |
| **4** | Cadastro ou atualização de Pessoa Jurídica. |
| **5** | Cadastro ou atualização de Categoria(s). |
| **6** | Cadastro ou atualização de Fabricantes(s). |
| **7** | Cadastro ou atualização de Produto(s). |
| **8** | Cadastro ou atualização de Forma(s) de Pagamento. |
| **9** | Inclusão de Venda. |
| **10** | Inclusão dos Item(ns) da Venda. |
| **11** | Inclusão da(s) Forma(s) de Pagamento da Venda. |
| **12** | Cancelamento de Venda. |
| **13** | Consulta de Cashback por CPF. |
| **14** | Solicitação de Resgate de Cashback por CPF. |

---

## Layout do Arquivo `resp.001`

```text
1|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
2|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
3|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
4|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
5|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
6|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
7|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
8|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
9|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
12|{status (Success/Error)}|{mensagem (vazio caso de "Success")}
13|{status (Success/Error)}|{saldo)
14|{status (Success/Error)}|{mensagem}
```

---

## Exemplos de Uso

```bash
CashBackEuFalo.exe --cashbackeufalo
```

---

## Autor

- **Nome:** Wellinton Mattos Brozeghini  
- **GitHub:** wellintonmbvix  
- **E-mail:** wellinton.m.b.vix@gmail.com

---

## Observações

Este projeto não possui uma licença definida no momento. Caso tenha interesse em contribuir, entre em contato por e-mail.

