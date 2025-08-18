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

## Verificar proporção e nº de amostras balanceadas e não balanceadas

summary(cubo_amostras) # Nº de amostras não balanceadas
summary(cubo_amostras_bal) # Nº amostras balanceadas

# Análise SOM ---------------------------------------------------------------------------------------------------------------------------------------------

## Definir cores das classes

sits_colors_set(tibble(
  name = c("supressao", "veg_natural", "", "","", "", "", ""),
  color = c("#bf812d", "#01665e", "", "", "", "", "", "")))

## Com balanceamento

som_cluster <- sits_som_map(
  data = cubo_amostras_bal, # SOM feito com grupo de amostras balanceadas (VERIFICAR!)
  grid_xdim = 10, # Grade eixo x. Aqui é 10 x 10 para gerar 100 neurônios
  grid_ydim = 10, # Grade eixo y
  distance = "dtw", # Método de calcular a distância,
  mode = "pbatch", # Gera o mesmo mapa SOM a cada run
  rlen = 20) # Número de iterações (quantidade de vezes que o mapa é gerado)

## Visualizar mapa SOM

windows(width = 9, height = 7)
plot(som_cluster, band = "DBSI") 
plot(som_cluster, band = "NDII")
plot(som_cluster, band = "B11")

# Seleção de neurônios no SOM -----------------------------------------------------------------------------------------------------------------------------

amostras_filt_neuro <- som_cluster$data[som_cluster$data$id_neuron == 25, ]
view(amostras_filt_neuro)

amostras_filt_neuro1 <- som_cluster$data[som_cluster$data$id_neuron == 2, ]
view(amostras_filt_neuro1)

amostras_filt_neuro2 <- som_cluster$data[som_cluster$data$id_neuron == 45, ]
view(amostras_filt_neuro2)

# Detectar ruídos das amostras ----------------------------------------------------------------------------------------------------------------------------

all_samples <- sits_som_clean_samples(som_map = som_cluster, 
                                      keep = c("clean", "analyze", "remove"))

## Visualizar gráfico

plot(all_samples)
summary(all_samples) # Número de amostras (mesma quantidade das originais ou balanceadas)

# Remover amostras ruidosas -------------------------------------------------------------------------------------------------------------------------------

samples_clean <- sits_som_clean_samples(som_cluster,
                                        keep = c("clean", "analyze"))

## Visualizar gráfico

plot(samples_clean)
summary(samples_clean) # Número de amostras após filtro

# Ver diferenças na quantidade de amostras antes e após filtragem -----------------------------------------------------------------------------------------

summary(all_samples)
summary(samples_clean) 

# Gerar SOM dos dados sem ruídos --------------------------------------------------------------------------------------------------------------------------

som_cluster_limpo <- sits_som_map(
  data = samples_clean, # SOM feito com o nosso grupo de amostras 
  grid_xdim = 10, # Aqui é 10 x 10 para gerar 100 neurônios
  grid_ydim = 10,
  mode = "pbatch", # Gera o mesmo mapa SOM a cada run
  distance = "dtw", # Método para calcular a distância
  rlen = 20) # Número de iterações

## Visualizar mapa SOM limpo

windows(width = 9, height = 7)
plot(som_cluster_limpo, band = "DBSI")
plot(som_cluster_limpo, band = "NDVI")
plot(som_cluster_limpo, band = "B11")

# Avaliar matriz de confusão das amostras antes e após filtragem ------------------------------------------------------------------------------------------

## Função de avaliação

avaliacao_som <- sits_som_evaluate_cluster(som_cluster)
avaliacao_som_limpo <- sits_som_evaluate_cluster(som_cluster_limpo)

## Gráficos

plot(avaliacao_som)
plot(avaliacao_som_limpo)

## Resultados das avaliações

avaliacao_som 
avaliacao_som_limpo

# Classificações ------------------------------------------------------------------------------------------------------------------------------------------


# Treinar modelo Random Forest ----------------------------------------------------------------------------------------------------------------------------


# Validação do modelo Random Forest -----------------------------------------------------------------------------------------------------------------------


# Produzir mapas de probabilidades por classes ------------------------------------------------------------------------------------------------------------


# Unir tiles com sits_mosaic() ----------------------------------------------------------------------------------------------------------------------------


# Suavização dos mapas de probabilidades ------------------------------------------------------------------------------------------------------------------


# Rotulando o cubo de probabilidades - Classificação do mapa final ----------------------------------------------------------------------------------------


# Mapa de incerteza ---------------------------------------------------------------------------------------------------------------------------------------


# Adicionar máscara com reclassificação do SITS -----------------------------------------------------------------------------------------------------------


