functionName=services-etl
timeStamp=`date "+%Y%m%d%H%M%S"`
region=uksouth
currentRepoPath=`git rev-parse --show-toplevel`
currentOrg=`git remote get-url origin | cut -f4 -d"/"`
currentRepo=`git remote get-url origin | cut -f5 -d"/" | cut -f1 -d'.'`
currentBranch=`git rev-parse --abbrev-ref HEAD`
currentBranchSanitised=`echo $currentBranch | sed 's/\//_/g'`

resourceGroup=${currentOrg}.${currentRepo}.${currentBranchSanitised}.`whoami`

if [ "`az group exists --name $resourceGroup`" != "true" ]
then
  echo "Creating resource group $resourceGroup in location $region" 
	az group create \
		--name $resourceGroup \
		--location $region \
		--tags org=$currentOrg repo=$currentRepo branch=$currentBranch
fi

echo "Provisioning infrastructure for branch ${currentOrg}/${currentRepo}/${currentBranch}" 

az group deployment create \
  --name "scripted-deployment-${timeStamp}" \
  --resource-group $resourceGroup \
  --template-file ./template.json \
  --parameters "{ \"org\": { \"value\": \"$currentOrg\" }, \"repo\": { \"value\": \"$currentRepo\" } , \"branch\": { \"value\": \"$currentBranch\" } }"

storageAccountName=`az storage account list --resource-group ${resourceGroup} --output list --query '[].name'`
storageAccountConnectionString=`az storage account show-connection-string --resource-group ${resourceGroup} --name ${storageAccountName} --query 'connectionString'`

az storage container create --name ods-input --connection-string=${storageAccountConnectionString}
az storage container create --name ods-split --connection-string=${storageAccountConnectionString}
