# listing nodepools:

az aks nodepool list \
  --resource-group aks-study-1 \
  --cluster-name aks-study \
  -o table

# show nodepool details:

az aks nodepool show \
  --resource-group aks-study-1 \
  --cluster-name aks-study \
  --name nodepool1 > nodepool.json

# creating new nodepool based on last one

az aks nodepool add \
  --resource-group aks-study-1 \
  --cluster-name aks-study \
  --name nodepool2 \
  --node-count 1 \
  --node-vm-size Standard_D2s_v3 \
  --mode User