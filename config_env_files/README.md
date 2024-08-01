
# Config Files e .env File em R

Este repositório foi criado para demonstrar o uso de arquivos de configuração (`config.json`) e arquivos `.env` em scripts R. 

## Estrutura do Repositório

O exemplo encontra-se dentro de uma pasta, mas o ideal é que isso seja replicado na raiz do repositório. Para que esse exemplo funcione execute:

```r
setwd('~/config_env_files')
```

- `config.json`: Arquivo JSON contendo as configurações do ambiente, como paths e parâmetros auxiliares.
- `.env`: Arquivo contendo variáveis de ambiente sensíveis, como credenciais para acesso ao banco de dados.
- `run.R`: Script R que demonstra como carregar as configurações e variáveis de ambiente e usá-las no código.


## Dependências

Para executar o script, certifique-se de que as seguintes bibliotecas R estejam instaladas:

- `jsonlite`
- `dotenv`

Você pode instalar estas dependências com o seguinte comando:

```r
install.packages(c("jsonlite", "dotenv""))
```

## Como Executar

1. **Configuração do Arquivo `config.json`:**

   No arquivo `config.json`, configure os paths e parâmetros necessários para o funcionamento do script. Um exemplo de estrutura para o `config.json` é:

   ```json
   {
     "paths": {
       "ckan_utils_path": "path/para/ckan_utils.R",
       "biblioteca_path": "path/para/biblioteca.R",
       "dados_path": "path/para/dados"
     },
     "ckan_recursos": {},
     "salvar_dados": {},
     "auxiliares": {
       "num_nucleos": 4
     },
     "arquivos": {
       "malha": "nome_do_arquivo_raster"
     }
   }
   ```

2. **Configuração do Arquivo `.env`:**

   No arquivo `.env`, adicione as variáveis de ambiente relacionadas ao banco de dados e CKAN. Exemplo:

   ```env
   DB_NAME=seu_database_name
   DB_PASSWORD=sua_senha
   DB_PORT=5432
   DB_USER=seu_usuario
   DB_HOST=localhost
   CKAN_KEY=sua_ckan_key
   ```

3. **Execução do Script:**

   Com todas as configurações definidas, você pode executar o script R:

   ```r
   source("run.R")
   ```

## Considerações Finais

Este repositório serve como um exemplo básico de como organizar e gerenciar configurações em scripts R, separando variáveis sensíveis em arquivos `.env` e utilizando arquivos de configuração JSON para parâmetros gerais. 
