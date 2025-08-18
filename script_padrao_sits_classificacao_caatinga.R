# Script para Classificação do Bioma Caatinga -------------------------------------------------------------------------------------------------------------
# Classificação por Região de Mapeamento (RM) -------------------------------------------------------------------------------------------------------------
# Região de mapeamento: xxx -------------------------------------------------------------------------------------------------------------------------------
# Tiles: xxx ----------------------------------------------------------------------------------------------------------------------------------------------
# Bandas e índices: xxx -----------------------------------------------------------------------------------------------------------------------------------
# Classes: xxx --------------------------------------------------------------------------------------------------------------------------------------------
# Número total de amostras: xxx ---------------------------------------------------------------------------------------------------------------------------

# Carregar pacotes ----------------------------------------------------------------------------------------------------------------------------------------

library(tibble) # Pacote para visualizar tabelas
library(sits) # Pacote para análises de séries temporais de imagens de satélite
library(sitsdata) # Pacote para obter conjunto de dados de amostras do sits
library(kohonen) # Pacote para plotar o mapa SOM
library(randomForestExplainer) # Pacote para treinar modelo de classificação
library(luz) # Pacote para facilitar criação, treino e avaliação de modelos no Torch
library(torch) # Pacote para criar modelos deep learning e treinar redes neurais
torch::install_torch()
library(tidyverse) # Pacote para manipulação de tabelas e gráficos
library(terra) # Pacote para manipular dados espaciais (imagens raster, dados de satélite)
library(raster) # Pacote mais antigo para manipulação de dados raster
library(sf) # Pacote para manipulação de dados vetoriais (pontos, linhas, polígonos)

# Criar e ler cubo de dados -------------------------------------------------------------------------------------------------------------------------------

cubo <- sits_cube(
  source     = "BDC", # Fonte dos cubos de dados
  collection = "SENTINEL-2-16D", # Coleção de imagens
  tiles      = c("", "", ""), # Tiles/Regiões de ineteresse
  start_date = "", # Data inicial 
  end_date   = "") # Data final 

## Verificar bandas, tempos e outras informações do cubo 

sits_bands(cubo)
sits_timeline(cubo)
view(cubo)
view(cubo$file_info)

## Salvar e ler cubo criado

saveRDS(cubo, file = "cubo.rds") 
cubo <- readRDS("cubo.rds")

# Calcular índices e adicionar ao cubo --------------------------------------------------------------------------------------------------------------------

## Cubo com exemplos dos índices DBSI e NDII

cubo_indice_dbsi <- sits_apply(cubo,
                                                DBSI = ((B11 - 1) - B03) / ((B11 - 1) + B03) - NDVI,
                                                normalized = FALSE,
                                                output_dir = tempdir_r,
                                                progress = TRUE
)

## Caso necessário calcular outros índices, o objeto "cubo_indice_dbsi" acima deve
## ser adicionado ao novo sits_apply para calcular o novo índice. Após calcular todos os
## índices, o cubo final com todos os índices deve ser salvo em formato .rds.

cubo_indice_dbsi_ndii <- sits_apply(cubo_indice_dbsi,
                                           NDII = (B08 - B11) / (B08 + B11),
                                           normalized = FALSE,
                                           output_dir = tempdir_r,
                                           progress = TRUE
)

## Salvar e ler cubo final criado com os índices e bandas

saveRDS(cubo_indice_dbsi_ndii, file = "cubo_indices_bandas.rds") 
cubo_indices_bandas <- readRDS("cubo_indices_bandas.rds")

# Ler arquivo .shp com amostras por classes ---------------------------------------------------------------------------------------------------------------

amostras_classes <- sf::read_sf("amostras_classes.shp")

# Adicionar amostras ao cubo de dados criado --------------------------------------------------------------------------------------------------------------

cubo_amostras <- sits_get_data(
  cubo_tile034018_entorno_g4_2b, # Cubo geral com bandas e índices
  samples = "amostras_classes.shp", # Arquivo shapefile do tile 034018
  label_attr = "", # Coluna que indica as classes das amostras (pontos)
  bands = c("", "", "", ""), 
  memsize = 8, # consumo de memória
  multicores = 2, # Número de núcleos a serem usados. Quanto maior, mais rápido o processamento
  progress = TRUE) # Acompanhar carregamento

## Verificar informações do cubo com amostras

view(cubo_amostras)
sits_bands(cubo_amostras)
sits_labels(cubo_amostras)

## Salvar e ler cubo com amostras

saveRDS(cubo_amostras, file = "cubo_amostras.rds") 
cubo_amostras <- readRDS("cubo_amostras.rds")

# Visualizar padrões de séries temporais por classe -------------------------------------------------------------------------------------------------------

padroes_tempo_amostras <- sits_patterns(cubo_amostras) # Média harmônica das séries temporais 
view(padroes_tempo_amostras$time_series[[1]])

## Gráfico

plot(padroes_tempo_amostras)

# Balanceamento de amostras -------------------------------------------------------------------------------------------------------------------------------

cubo_amostras_bal <- sits_reduce_imbalance(
  cubo_amostras,
  n_samples_over = 100, 
  n_samples_under = 100) 

## Número de amostras não balanceadas e balanceadas

summary(cubo_amostras) # Nº de amostras não balanceadas
summary(cubo_amostras_bal) # Nº amostras balanceadas

# Análise SOM ---------------------------------------------------------------------------------------------------------------------------------------------

## Definir cores das classes

sits_colors_set(tibble(
  name = c("supressao", "veg_natural", "", "","", "", ""),
  color = c("#bf812d", "#01665e", "", "", "", "", "")))


# Seleção de neurônios no SOM -----------------------------------------------------------------------------------------------------------------------------


# Detectar ruídos das amostras ----------------------------------------------------------------------------------------------------------------------------


# Remover amostras ruidosas -------------------------------------------------------------------------------------------------------------------------------


# Ver diferenças na quantidade de amostras antes e após filtragem -----------------------------------------------------------------------------------------


# Gerar SOM dos dados sem ruídos --------------------------------------------------------------------------------------------------------------------------


# Avaliar matriz de confusão das amostras antes e após filtragem ------------------------------------------------------------------------------------------


# Classificações ------------------------------------------------------------------------------------------------------------------------------------------


# Treinar modelo Random Forest ----------------------------------------------------------------------------------------------------------------------------


# Validação do modelo Random Forest -----------------------------------------------------------------------------------------------------------------------


# Produzir mapas de probabilidades por classes ------------------------------------------------------------------------------------------------------------


# Unir tiles com sits_mosaic() ----------------------------------------------------------------------------------------------------------------------------


# Suavização dos mapas de probabilidades ------------------------------------------------------------------------------------------------------------------


# Rotulando o cubo de probabilidades - Classificação do mapa final ----------------------------------------------------------------------------------------


# Mapa de incerteza ---------------------------------------------------------------------------------------------------------------------------------------


# Adicionar máscara com reclassificação do SITS -----------------------------------------------------------------------------------------------------------


