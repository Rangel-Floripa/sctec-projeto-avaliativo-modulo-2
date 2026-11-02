# Projeto Avaliativo SCTEC — Módulo II | Semana 13

**Engenharia e Análise de Dados de Contratações Públicas — Controladoria**

Projeto de tratamento, modelagem, armazenamento e visualização de dados de contratações públicas, desenvolvido com **Python, pandas, PostgreSQL, SQL e Power BI**. A solução organiza os dados em um **modelo dimensional (Star Schema)** e responde a seis perguntas de negócio relacionadas à economia estimada, aos fornecedores, às modalidades, ao tempo de contratação, à distribuição regional e ao perfil do gasto.

> **Escopo e interpretação:** os valores representam montantes **homologados**, e não necessariamente pagamentos realizados. A economia calculada é **estimada** para itens classificados como comparáveis. O projeto não constitui auditoria de regularidade ou prova de irregularidade em contratações.

## 1. Problema de negócio e objetivos

Uma Controladoria deseja transformar arquivos de contratações públicas em informações organizadas e auditáveis, capazes de apoiar a identificação de padrões de gasto, concentração e prazos.

As seis perguntas de negócio são:

1. **P1 — Economia:** qual foi a economia estimada nas contratações comparáveis?
2. **P2 — Fornecedores:** qual é a concentração financeira entre os principais fornecedores?
3. **P3 — Modalidades:** como os valores homologados e o deságio se distribuem entre as modalidades?
4. **P4 — Ciclo:** quanto tempo decorre entre a publicação e a homologação, e como esse prazo varia entre órgãos e períodos?
5. **P5 — Regional:** como os recursos homologados se distribuem entre as regiões brasileiras?
6. **P6 — Perfil do gasto:** qual é a distribuição financeira entre Bens, Serviços e Obras e engenharia?

## 2. Origem, recorte e limitações da base

A fonte governamental declarada para o material é o **Portal Nacional de Contratações Públicas (PNCP)**, no contexto dos dados abertos governamentais. Os arquivos utilizados foram **previamente extraídos e disponibilizados no kit do Projeto Avaliativo SCTEC**; o aluno não precisou consumir diretamente a API.

- **Fonte institucional:** [Portal Nacional de Contratações Públicas](https://pncp.gov.br/).
- **Referência à API:** `https://pncp.gov.br/api/consulta/`.
- **Recorte das publicações informado no material:** **02/01/2025 a 31/12/2025**.
- **Abrangência:** amostra didática de contratações; **não representa todas as contratações brasileiras**.
- **Datas de resultado/homologação:** podem ocorrer depois da publicação; por isso, os painéis podem apresentar homologações em **2026**, embora o recorte das publicações seja de 2025.
- **Preparação didática:** a base disponibilizada pode conter inconsistências preservadas ou introduzidas para exercitar limpeza, validação e regras de negócio. Assim, não se afirma que os três CSVs sejam uma cópia integral e inalterada das respostas originais da API.

Os arquivos `data/raw/` são preservados para rastreabilidade. A publicação de dados derivados do kit deve respeitar as condições de uso e as orientações de entrega; a disponibilidade pública de um dado não afasta automaticamente cuidados aplicáveis a identificadores pessoais.

## 3. Arquitetura e decisões técnicas

```text
CSV de origem
  compras.csv + itens.csv + resultados.csv
                       |
                       v
             Python / pandas
      limpeza + validação + regras
                       |
                       v
              data/processed/
         4 dimensões + 1 tabela fato
                       |
                       v
             PostgreSQL (public)
              Modelo Star Schema
                    /     \
                   v       v
             SQL (P1–P6)  Power BI (P1–P6)

```

**Decisões adotadas:**

- **Preservação dos dados de origem:** o tratamento ocorre nos scripts e produz saídas separadas.
- **Identificadores como texto:** tratamento de máscaras e zeros à esquerda em CPF/CNPJ, sem converter documentos em números inteiros.
- **Separação de responsabilidades:** `limpeza.py` implementa rotinas de sanitização; `montar_tabelas.py` prepara o modelo; `banco.py` encapsula operações PostgreSQL; `carregar.py` executa a carga; `config.py` centraliza configurações.
- **Modelo estrela:** uma tabela fato, com granularidade de item contratado e resultado selecionado, ligada a quatro dimensões por chaves substitutas (`sk_`).
- **Integridade referencial:** conferências de chaves primárias/estrangeiras e ausência de referências órfãs.
- **Carga completa (*full load*):** recriação controlada das estruturas e carga dos dados. **A rotina de recriação do banco é destrutiva: nunca executá-la contra um banco que deva ser preservado.**
- **Camada de apresentação:** medidas DAX e filtros por ano de homologação no Power BI, incluindo tratamento explícito da diferença entre datas de publicação e de homologação.

## 4. Ferramentas utilizadas

| Ferramenta                  | Aplicação                                                        |
| :-------------------------- | :--------------------------------------------------------------- |
| Python 3.12 / pandas        | Auditoria, limpeza, regras de negócio e geração de CSVs tratados |
| PostgreSQL 18.4 / pgAdmin 4 | Banco relacional, carga e verificações de consistência           |
| SQL                         | Estrutura do banco e respostas às perguntas de negócio           |
| Power BI Desktop            | Modelo analítico, medidas DAX e dashboards                       |
| VS Code                     | Desenvolvimento, execução e documentação                         |
| Git / GitHub                | Controle de versões e publicação dos artefatos                   |
| Trello                      | Planejamento e acompanhamento das Sprints                        |

As versões registradas são as do ambiente utilizado durante o desenvolvimento; outros ambientes podem exigir ajustes de configuração.

## 5. Estrutura do repositório

```text
sctec_projeto_final_modulo2/
├── data/
│   ├── raw/
│   │   ├── compras.csv
│   │   ├── itens.csv
│   │   └── resultados.csv
│   └── processed/
│       ├── dim_orgao.csv
│       ├── dim_fornecedor.csv
│       ├── dim_modalidade.csv
│       ├── dim_localidade.csv
│       └── fato_item_contratado.csv
├── docs/
│   └── img/
│       ├── sprints.png
│       ├── modelo_dimensional.png
│       └── historico_git.png
├── powerbi/
│   └── PNCP_Controladoria.pbix
├── reports/
├── sql/
│   ├── 01_criar_banco.sql
│   └── 02_perguntas.sql
├── src/
│   ├── __init__.py
│   ├── config.py
│   ├── banco.py
│   ├── limpeza.py
│   ├── montar_tabelas.py
│   └── carregar.py
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md

```

**Segurança:** a pasta `.venv/`, o `.env` com credenciais reais, os arquivos temporários e os backups locais não fazem parte da entrega pública. O arquivo `.env.example` é apenas um modelo de configuração sem credenciais reais.

## 6. Diagnóstico inicial e qualidade dos dados

### 6.1 Arquivos de origem e volumes

| Arquivo          | Registros brutos |
| :--------------- | ---------------: |
| `compras.csv`    |            2.042 |
| `itens.csv`      |            7.077 |
| `resultados.csv` |           15.896 |

A etapa de consolidação selecionou **6.225 itens** antes da rejeição, descartou **99 itens distintos** conforme a Regra 4 e produziu **6.126 linhas** na tabela fato.

**Conferência de identificadores:** no arquivo `compras.csv`, o campo `numero_controle_pncp` apresentou **2.042 valores distintos**, sem nulos nem duplicações na auditoria executada em 26/10/2026.

### 6.2 Dicionário de inconsistências e tratamentos

| Tema                        | Problema / risco                                                                                 | Tratamento ou decisão                                                                                        |
| :-------------------------- | :----------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------- |
| CPF, CNPJ e `ni_fornecedor` | Máscaras irregulares, perda de zeros à esquerda, tipos PF/PJ e identificadores não convencionais | Leitura como texto e higienização condicionada ao tipo, com preservação de identificadores não convencionais |
| Nulos disfarçados           | Campos vazios e marcadores textuais de ausência                                                  | Padronização controlada de valores ausentes; não confundir `NULL` com zero                                   |
| Valores monetários          | `R$`, ponto/vírgula, números em texto e formatos inconsistentes                                  | Conversão numérica e validação antes dos cálculos                                                            |
| Datas                       | Formatos divergentes e datas de resultado anteriores à publicação                                | Conversão temporal e tratamento de cronologias inválidas                                                     |
| Resultados por item         | Vários fornecedores classificados, sequenciais e cancelamentos                                   | Aplicação das regras de seleção de resultado, classificação e desempate                                      |
| Quantidades e preços        | Valores ausentes, não positivos, extremos ou sigilosos                                           | Verificações e rejeições documentadas na Regra 4                                                             |
| Texto e acentuação          | Possíveis caracteres corrompidos por problemas de codificação                                    | Auditoria específica; evitar substituições indiscriminadas e não afirmar correção universal                  |
| Perfil do gasto             | Descrições heterogêneas de bens, serviços e obras                                                | Classificação por campos existentes e expressões de busca documentadas no código                             |

### 6.3 Auditoria de valores ausentes

A auditoria de 26/10/2026 identificou **36.651 ocorrências em células** com marcadores de ausência, distribuídas da seguinte forma:

| Arquivo          | Ocorrências em células |
| :--------------- | ---------------------: |
| `compras.csv`    |                  1.325 |
| `itens.csv`      |                  7.217 |
| `resultados.csv` |                 28.109 |
| **Total**        |             **36.651** |

Esses números representam **células**, não quantidades de linhas excluídas. Exemplos de campos com ausências: datas de abertura/encerramento, `catalogo_codigo_item`, `ordem_classificacao_srp`, `porte` e `data_cancelamento`. A presença de um campo ausente não implica, isoladamente, o descarte do registro.

### 6.4 Codificação e caracteres

Nos dados brutos foram observados exemplos de caracteres corrompidos (*mojibake*), como `ContrataÃ§Ã£o` e `SÃ£o Carlos`. Uma busca inicial encontrou ocorrências suspeitas, incluindo falsos positivos. Na tabela processada, uma verificação mais específica dos padrões pesquisados em `descricao_item` não encontrou ocorrências. Isso **não comprova que todos os problemas de codificação tenham sido eliminados**.

### 6.5 Regra 4 — Registro dos 99 itens rejeitados

A auditoria identificou os motivos de rejeição abaixo. **As condições se sobrepõem**: um mesmo item pode satisfazer mais de uma regra. Por isso, a soma das ocorrências da tabela é maior do que os **99 itens distintos efetivamente rejeitados**.

| Condição auditada                                      | Ocorrências |
| :----------------------------------------------------- | ----------: |
| Quantidade não positiva                                |           1 |
| Valor unitário estimado inválido                       |          23 |
| Valor unitário homologado inválido                     |           6 |
| Item sinalizado como sigiloso                          |           0 |
| Valor total estimado inferior a R$ 1                   |          85 |
| Valor homologado superior a 1.000 vezes o estimado     |          60 |
| Valor total estimado superior a R$ 1 trilhão           |           3 |
| Valor total homologado superior a R$ 1 trilhão         |           0 |
| **Itens únicos rejeitados após combinar os critérios** |      **99** |

A contagem de rejeições é conferida na saída de diagnóstico do pipeline; as condições são aplicadas sobre a base intermediária, não sobre toda linha bruta de resultado isoladamente.

### 6.6 Regra 7 — Datas e duração do ciclo

Foram identificados **230 itens** com data de resultado/homologação anterior à publicação. Para esses casos, a data de homologação foi tratada como ausente para fins de cálculo do ciclo, **sem excluir o item da tabela fato**.

| Indicador                  |  Resultado |
| :------------------------- | ---------: |
| Itens na fato              |      6.126 |
| Ciclos calculáveis         |      5.896 |
| Itens sem ciclo calculável |        230 |
| Percentual sem ciclo       |      3,75% |
| Ciclo médio geral          | 48,09 dias |
| Ciclo máximo               |   611 dias |

**Ressalva:** o indicador de ausência de data de homologação no modelo tratado pode decorrer da regra cronológica e não comprova que a contratação esteja pendente. Da mesma forma, ciclos longos não caracterizam automaticamente irregularidades.

### 6.7 Regra 8 — Classificação do perfil do gasto

A lógica de classificação em `src/montar_tabelas.py` utiliza informações da descrição do item e do objeto da contratação, assim como indicadores de material/serviço, para organizar os resultados nos perfis **Bens**, **Serviços** e **Obras e engenharia**.

A identificação de obras/engenharia foi implementada por busca textual com expressão regular abrangendo termos como **OBRAS, CONSTRUÇÃO, CONSTRUCAO, REFORMA e ENGENHARIA**, com tratamento de maiúsculas/minúsculas no processo. **A implementação real do arquivo Python é a referência definitiva**: não se deve substituir sua expressão por `\bobra\b` sem conferir o comportamento do código.

| Perfil             |     Itens |        Valor homologado |              Participação |
| :----------------- | --------: | ----------------------: | ------------------------: |
| Obras e engenharia |       967 |     R$ 4.892.362.732,70 |                    60,82% |
| Serviços           |     1.849 |     R$ 2.940.950.885,18 |                    36,56% |
| Bens               |     3.310 |       R$ 211.185.187,86 |                     2,63% |
| **Total**          | **6.126** | **R$ 8.044.498.805,74** | **100% (sem arredondar)** |

Os percentuais publicados podem somar 100,01% pela apresentação com duas casas decimais. A classificação é analítica, baseada em regras textuais, e pode exigir revisão humana em casos ambíguos.

## 7. Modelo dimensional e integridade

O modelo do PostgreSQL utiliza **uma tabela fato e quatro dimensões**:

| Tabela                 | Chave substituta / papel                         | Registros validados |
| :--------------------- | :----------------------------------------------- | ------------------: |
| `dim_orgao`            | `sk_orgao` — identificação do órgão              |                 363 |
| `dim_fornecedor`       | `sk_fornecedor` — identificação do fornecedor    |               2.652 |
| `dim_modalidade`       | `sk_modalidade` — modalidade de contratação      |                   7 |
| `dim_localidade`       | `sk_localidade` — UF/região                      |                  27 |
| `fato_item_contratado` | Medidas, datas e referências às quatro dimensões |               6.126 |

![Modelo dimensional do projeto](docs/img/modelo_dimensional.png)

As consultas executadas no PostgreSQL confirmaram **zero referências órfãs** nas quatro chaves dimensionais da tabela fato.

## 8. Resultados das seis perguntas de negócio

### P1 — Economia estimada

- **Itens contratados:** 6.126.
- **Itens classificados como comparáveis:** 5.457.
- **Valor estimado comparável:** R$ 6.867.663.469,91.
- **Economia estimada:** **R$ 992.861.686,95**, equivalente a **14,46%** na base comparável.

A diferença entre valor estimado e homologado é um indicador de economia **estimada**, não comprovação de economia orçamentária efetiva.

### P2 — Concentração entre fornecedores

Os dez fornecedores com maior volume homologado concentram **R$ 3.332.484.029,86**, equivalentes a **41,43%** do volume da base. A concentração requer interpretação contextual; não indica, isoladamente, irregularidade.

### P3 — Modalidades de contratação

Na visão consolidada, **Concorrência — Eletrônica** lidera com aproximadamente **R$ 4,70 bilhões**, ou **58,43%** do volume homologado. O painel apresenta comparações por modalidade e o deságio onde houver base comparável. **Credenciamento** pode aparecer sem indicador de deságio por não possuir itens classificados como comparáveis nessa base; ausência do indicador não equivale a deságio de 0%.

### P4 — Ciclo entre publicação e homologação

Na visão consolidada, o ciclo médio calculável é **48,09 dias**, com máximo de **611 dias**. O painel permite examinar períodos, distinguindo a data da publicação da data de homologação. **A consulta SQL por órgão** contempla a análise do ciclo médio, incluindo recorte de órgãos com quantidade mínima de observações; a visualização mensal do Power BI é uma perspectiva complementar, não substitui a consulta por órgão.

### P5 — Distribuição regional

| Região       | Participação financeira consolidada |
| :----------- | ----------------------------------: |
| Centro-Oeste |                              44,25% |
| Nordeste     |                              23,00% |
| Sudeste      |                              13,47% |
| Sul          |                              12,70% |
| Norte        |                               6,58% |

O **Centro-Oeste** lidera em valor homologado, mas o **Sudeste** lidera em quantidade de contratações (**613** no conjunto consolidado). A região registrada no modelo não comprova onde os recursos foram efetivamente gastos ou os serviços executados.

### P6 — Perfil do gasto

Obras e engenharia lidera o volume consolidado com **60,82%**, seguida por Serviços (**36,56%**) e Bens (**2,63%**). O ticket médio geral por item é aproximadamente **R$ 1,31 milhão**.

A aplicação dos filtros por **ano de homologação** mostra uma mudança de composição: Obras e engenharia representava **49,60% em 2025** e **82,55% em 2026**. Essas participações se referem à amostra e aos filtros aplicados, não a toda contratação pública do país.

## 9. Dashboards Power BI

O arquivo [`powerbi/PNCP_Controladoria.pbix`](powerbi/PNCP_Controladoria.pbix) reúne as seis perspectivas analíticas:

- **P1 — Economia**
- **P2 — Fornecedores**
- **P3 — Modalidades**
- **P4 — Ciclo**
- **P5 — Regional**
- **P6 — Perfil**

O relatório também contém uma página de conceitos/tooltip. Os seletores de período e os indicadores de homologação foram revisados em **31/10/2026**, preservando as medidas originais quando necessário e utilizando medidas específicas de homologação para comparações anuais.

**Atenção à temporalidade:** em algumas medidas e visualizações, o ano refere-se à **data de homologação**; em outros indicadores de qualidade e séries de publicação, à **data de publicação**. O painel P4 explicita essa distinção em suas conclusões. Textos consolidados permanecem referentes ao conjunto integral, mesmo quando um ano isolado está selecionado.

Para abrir o relatório, utilize o **Power BI Desktop**. Pode ser necessário ajustar a fonte PostgreSQL e as credenciais locais em **Transformar dados / Configurações da fonte de dados** antes de atualizar as consultas.

## 10. Como reproduzir o projeto

### 10.1 Pré-requisitos

- Python 3.12 e `pip`.
- PostgreSQL instalado, em funcionamento e com usuário autorizado a criar banco/tabelas.
- Power BI Desktop para visualizar ou atualizar o `.pbix`.
- Arquivos CSV de origem presentes em `data/raw/`.

### 10.2 Preparar o ambiente no Windows / PowerShell

Abra o terminal na raiz do projeto:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt

```

Se a execução de scripts estiver bloqueada apenas nesta sessão, a ativação poderá exigir uma política de execução apropriada ao seu ambiente. Não altere políticas corporativas sem autorização.

### 10.3 Configurar a conexão

Crie o arquivo local `.env` a partir de `.env.example` e preencha **somente na máquina local** os parâmetros de conexão PostgreSQL. Não publique credenciais reais ou o `.env` no GitHub.

```powershell
Copy-Item .env.example .env

```

Confirme o nome do banco configurado (`PG_DATABASE`) antes da carga. As rotinas em `src/banco.py` e `src/carregar.py` podem **encerrar conexões, excluir e recriar o banco de destino**.

### 10.4 Executar o tratamento e a montagem das tabelas

Na raiz do projeto, com o ambiente ativado:

```powershell
python -m src.montar_tabelas

```

Os CSVs tratados são gerados em `data/processed/` e utilizados na etapa seguinte. O módulo de limpeza é utilizado pelas rotinas do projeto; seu arquivo não deve ser confundido com um script de carga isolado.

### 10.5 Criar e carregar as tabelas PostgreSQL — operação destrutiva

**Somente em banco de testes descartável e após verificar o destino.** O módulo abaixo recria o banco configurado e não deve ser executado contra um banco de produção ou contra o banco original que precise ser preservado.

```powershell
python -m src.carregar

```

O script SQL de estrutura fica em `sql/01_criar_banco.sql`; as consultas de negócio estão em `sql/02_perguntas.sql`.

### 10.6 Conferir a carga e explorar as análises

Após a execução, confira no PostgreSQL as contagens das tabelas dimensionais e fato, a integridade referencial e os totais financeiros (ver seção 11). Em seguida, execute as consultas documentadas em `sql/02_perguntas.sql`.

Abra `powerbi/PNCP_Controladoria.pbix` e ajuste a conexão local do relatório ao banco carregado, caso necessário.

## 11. Prova real e validação integrada

Em **28/10/2026**, foi executado um teste de reconstrução e carga em um banco PostgreSQL **isolado**, denominado `pncp_controladoria_teste`, sem recriar o banco principal do projeto.

**Resultados conferidos após a carga:**

| Indicador                 |           Resultado |
| :------------------------ | ------------------: |
| `dim_orgao`               |                 363 |
| `dim_fornecedor`          |               2.652 |
| `dim_modalidade`          |                   7 |
| `dim_localidade`          |                  27 |
| `fato_item_contratado`    |               6.126 |
| Contratações distintas    |               1.962 |
| Itens comparáveis         |               5.457 |
| Valor homologado          | R$ 8.044.498.805,74 |
| Economia estimada         |   R$ 992.861.686,95 |
| Ciclos calculáveis        |               5.896 |
| Ciclos não calculáveis    |                 230 |
| Chaves estrangeiras órfãs |               **0** |

O teste utilizou **configuração temporária** para direcionar a carga ao banco isolado. Não é necessário executar novamente a recriação do banco original apenas para conferir esses resultados.

## 12. Planejamento em Sprints e histórico de versões

O trabalho foi organizado no **Trello**, com planejamento por Sprints, atividades, dificuldades, critérios de conclusão e evidências.

![Sprints do projeto](docs/img/sprints.png)

**Quadro do projeto:** [SCTEC — Módulo II — Projeto Avaliativo — Semana 13](https://trello.com/b/8pQw4NST/sctec-modulo-ii-projeto-avaliativo-semana-13).

O repositório utiliza a branch `main` para a versão consolidada e referências de desenvolvimento por Sprint, com integração por commits e merges. As branches de Sprint e o histórico são evidências da organização do projeto; não devem ser interpretados como datas retroativas de execução de cada atividade.

![Histórico Git do projeto](docs/img/historico_git.png)

O histórico original foi preservado em backup privado durante a preparação da publicação. O arquivo de backup não deve ser enviado ao repositório público.

## 13. Limitações, escolhas e melhorias futuras

**Limitações e ressalvas:**

- Os CSVs representam uma **amostra didática** e podem conter anomalias intencionais.
- Os valores financeiros são **homologados**, não pagamentos efetivos.
- A classificação de perfil depende de regras textuais e pode apresentar ambiguidades.
- Os critérios de rejeição da Regra 4 se sobrepõem; a contagem de 99 refere-se a itens **distintos**.
- Itens com cronologia inválida permanecem na tabela fato, mas sem ciclo calculável.
- As datas de publicação e homologação são diferentes; indicadores filtrados por ano podem abranger conjuntos distintos.
- A leitura dos problemas de encoding foi específica e não autoriza afirmar que toda inconsistência textual foi eliminada.
- A análise temporal por órgão prevista na pergunta P4 está disponível nas consultas SQL; sua representação visual mensal atende a uma leitura complementar.

**Possíveis melhorias:**

1. Automatizar conferências de qualidade e testes de regressão para as seis perguntas.
2. Adicionar orquestração de pipeline com **Apache Airflow** e cargas incrementais.
3. Implantar ambiente em nuvem, por exemplo na **AWS**, com armazenamento, banco e observabilidade.
4. Ampliar o monitoramento de dados ausentes e divergências entre fontes e períodos.
5. Aprimorar a rastreabilidade da origem das informações e a documentação de licenças e condições de redistribuição.

## 14. Defesa técnica e entrega

A apresentação final será realizada em **vídeo de até 7 minutos**, no formato de revisão técnica do projeto, abordando problema, planejamento, dados, tratamento, modelagem, validações, indicadores, Power BI e decisões técnicas.

**Vídeo de apresentação (Google Drive):** [Assistir à defesa técnica do Projeto SCTEC](https://drive.google.com/file/d/10Zh3667KpqCjnc9jbV486RncFS_hU6EG/view?usp=sharing)

**Vídeo no repositório:** [WATCHME.mp4](docs/WATCHME.mp4)

**Repositório GitHub:** [Projeto Avaliativo SCTEC — Módulo II](https://github.com/Rangel-Floripa/sctec-projeto-avaliativo-modulo-2)

### Checklist final

- [x] Pipeline Python, consultas SQL e modelo dimensional estruturados.
- [x] Carga e contagens validadas em banco de teste isolado.
- [x] Dashboard Power BI atualizado e salvo.
- [x] Imagens do modelo dimensional, Sprints e histórico Git incluídas em `docs/img/`.
- [ ] Conferir o README final e as configurações/arquivos destinados à publicação.
- [ ] Confirmar autorização e condições de redistribuição do kit didático e conferir dados pessoais/credenciais antes de torná-lo público.
- [ ] Publicar o repositório em **modo público**, com versão final na branch `main`.
- [ ] Testar o acesso ao GitHub em uma **janela anônima**.
- [x] Disponibilizar o vídeo no Google Drive como **leitor para qualquer pessoa com o link**.
- [x] Testar o acesso ao vídeo em uma **janela anônima**.
- [ ] Enviar **os dois links** no AVA até **03/11/2026 às 22h (horário de Brasília)**.

**Após a submissão, evitar novos commits até a correção da avaliação**, conforme a orientação de entrega registrada para o projeto.