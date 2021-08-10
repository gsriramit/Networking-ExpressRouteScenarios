# Login to Azure using Service Principal credentials from Github Secrets
Write-Output "Logging in to Azure with a service principal..."
az login `
    --service-principal `
    --username $Env:SP_CLIENT_ID `
    --password $Env:SP_CLIENT_SECRET `
    --tenant $Env:SP_TENANT_ID
Write-Output "Done"

# Select Azure subscription
az account set `
    --subscription $Env:AZURE_SUBSCRIPTION_NAME

# Create the VM configuration object
$ResourceGroupName = $Env:ResourceGroupName
$circuitName = "er-primary-sg-dev01"
$vnetGatewayName = "ergw-primary-seasia-dev01"
$location= "Southeast Asia"

# Create a VM in Azure
Write-Output "Creating Connection of the gateway with the circuit..."

$circuit = Get-AzExpressRouteCircuit -Name $circuitName -ResourceGroupName $ResourceGroupName
$gw = Get-AzVirtualNetworkGateway -Name $vnetGatewayName -ResourceGroupName $ResourceGroupName
$connection = New-AzVirtualNetworkGatewayConnection -Name "ERConnection" `
 -ResourceGroupName $ResourceGroupName -Location $location -VirtualNetworkGateway1 $gw `
  -PeerId $circuit.Id -ConnectionType ExpressRoute

