# Script para Classificação do Bioma Caatinga -------------------------------------------------------------------------------------------------------------
# Classificação por Região de Mapeamento (RM) -------------------------------------------------------------------------------------------------------------
# Região de mapeamento: xxx -------------------------------------------------------------------------------------------------------------------------------
# Tiles: xxx ----------------------------------------------------------------------------------------------------------------------------------------------
# Bandas e índices: xxx -----------------------------------------------------------------------------------------------------------------------------------

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

## Salvar cubo 

# Ler arquivo .shp com amostras por classes ---------------------------------------------------------------------------------------------------------------


# Adicionar amostras ao cubo de dados criado --------------------------------------------------------------------------------------------------------------

## Salvar cubo com amostras

# Visualizar padrões de séries temporais por classe -------------------------------------------------------------------------------------------------------

## Gráfico

# Balanceamento de amostras -------------------------------------------------------------------------------------------------------------------------------


# Análise SOM ---------------------------------------------------------------------------------------------------------------------------------------------


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


# Adicionar máscara com Reclassificação do SITS -----------------------------------------------------------------------------------------------------------


