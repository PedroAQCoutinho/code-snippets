library(logger)

# Configurando o logger para salvar logs em um arquivo
log_appender(appender_file("logging_r/log"))

# Exemplo de logs em diferentes níveis
log_info("Este é um log de nível INFO")
log_debug("Este é um log de nível DEBUG")
log_warn("Este é um log de nível WARNING")
log_error("Este é um log de nível ERROR")

# Usando variáveis nos logs
a <- 1
b <- 2
log_info("Somando a e b: {a} + {b} = {a + b}")
