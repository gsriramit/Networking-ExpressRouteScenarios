
# Declare the variables
$CoreNetworkRGName = "rg-sharednetwork-dev01"
$ResourceGroupName = "rg-networking-dev01" 
$circuitName = "er-primary-sg-dev01"
$vnetGatewayName = "ergw-primary-seasia-dev01"
$location= "Southeast Asia"
$hubToSpokePeering = "HubToSpoke1Peering"
$spokeToHubPeering = "Spoke1ToHubPeering"
$hubVnetName = "hub-vnet"
$spokeVnetName = "spoke-vnet"

# Connect the express route gateway to the circuit
Write-Output "Creating Connection of the gateway with the circuit..."

$circuit = Get-AzExpressRouteCircuit -Name $circuitName -ResourceGroupName $CoreNetworkRGName
$gw = Get-AzVirtualNetworkGateway -Name $vnetGatewayName -ResourceGroupName $ResourceGroupName
$connection = New-AzVirtualNetworkGatewayConnection -Name "ERConnection" `
 -ResourceGroupName $ResourceGroupName -Location $location -VirtualNetworkGateway1 $gw `
  -PeerId $circuit.Id -ConnectionType ExpressRoute

# Enable Gateway transit on the Hub side of the peering
# Get the virtual network peering
$hubtospokePeeringObj = Get-AzVirtualNetworkPeering -VirtualNetworkName $hubVnetName -ResourceGroupName $ResourceGroupName -Name $hubToSpokePeering
# Change AllowGatewayTransit property
$hubtospokePeeringObj.AllowGatewayTransit = $True
# Update the virtual network peering
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $hubtospokePeeringObj

# Use Remote Gateway  for transit on the Peer side of the peering
  # Get the virtual network peering 
$spokeToHubPeeringObj = Get-AzVirtualNetworkPeering -VirtualNetworkName $spokeVnetName -ResourceGroupName $ResourceGroupName -Name $spokeToHubPeering
# Change the UseRemoteGateways property
$spokeToHubPeeringObj.UseRemoteGateways = $True
# Update the virtual network peering
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $spokeToHubPeeringObj

