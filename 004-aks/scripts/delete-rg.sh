#!/bin/bash
set -e

RG="aks-study-1"

echo "Deletando Resource Group: $RG ..."
az group delete --name $RG --yes --no-wait
echo "Remoção iniciada."
