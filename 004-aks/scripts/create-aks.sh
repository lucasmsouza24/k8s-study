#!/bin/bash
set -e

RG="aks-study-1"
CLUSTER="aks-study"
LOCATION="eastus"
NODE_SIZE="Standard_B2s"

if [ -z "$SUBSCRIPTION" ]; then
  echo "Erro: variável SUBSCRIPTION não definida"
  exit 1
fi

echo "Definindo subscription..."
az account set --subscription $SUBSCRIPTION

echo "Criando Resource Group..."
az group create --name $RG --location $LOCATION

echo "Criando AKS..."
az aks create \
  --resource-group $RG \
  --name $CLUSTER \
  --location $LOCATION \
  --node-count 1 \
  --node-vm-size $NODE_SIZE \
  --enable-managed-identity \
  --tier free \
  --auto-upgrade-channel none \
  --node-os-upgrade-channel None \
  --generate-ssh-keys

echo "Obtendo credenciais..."
az aks get-credentials \
  --resource-group $RG \
  --name $CLUSTER \
  --overwrite-existing

echo "Cluster pronto!"