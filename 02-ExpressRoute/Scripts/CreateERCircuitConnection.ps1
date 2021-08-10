# Login to Azure using Service Principal credentials from Github Secrets
<#
Write-Output "Logging in to Azure with a service principal..."

$pscredential = New-Object -TypeName System.Management.Automation.PSCredential($Env:SP_CLIENT_ID, $Env:SP_CLIENT_SECRET)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $Env:SP_TENANT_ID


az login `
    --service-principal `
    --username $Env:SP_CLIENT_ID `
    --password $Env:SP_CLIENT_SECRET `
    --tenant $Env:SP_TENANT_ID

Write-Output "Done"

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

# Select Azure subscription
Set-AzContext  -Subscription $Env:AZURE_SUBSCRIPTION_ID
#>
# Create the VM configuration object
$ResourceGroupName = "rg-sharednetwork-dev01"
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

