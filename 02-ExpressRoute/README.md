# Express Route Circuit & Peerings
An azure express route circuit for private connectivity between your on-premise and Azure Cloud can be designed using one of the many connectivity models.For this lab, I used the conventional setup through a **Cloud Exchange Co-location**. You can refer to the following article to understand the differences between the various models and identify the one that would suit your requirement [Azure ExpressRoute Connectivity Models](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-connectivity-models)  

## High Level Network diagram (from the MS docs)
![image](https://user-images.githubusercontent.com/13979783/134936489-0eafa367-4338-45eb-9c62-ca90557682f1.png)
**Note**: This lab setup will require only the private peering for the first set of scenarios. 

## Detailed Network Architecture Diagram
![AzureNetworkingConcepts - ExpressRouteSetup](https://user-images.githubusercontent.com/13979783/134937224-283c8f5e-6aa5-4262-9684-bf4846914864.png)

## Component Details
| Components                                                      | Details                                                            |
|-----------------------------------------------------------------|--------------------------------------------------------------------|
| On-Premise Address space                                        | 172.31.255.0/24                                                    |
| Azure Address space                                             | 10.0.0.0/16 (hub network)                                          |
| Subnet of Primary ER Circuit connection                         | 169.254.255.1/30                                                   |
| Subnet of Secondary ER Circuit connection                       | 169.254.255.4/30                                                   |
| Primary & Secondary addresses of BGP router at customer edge    | 169.254.255.1 & 169.254.255.4 (first IP address from every subnet) |
| Primary & Secondary addresses of BGP router at Microsoft's edge | 169.254.255.2 & 169.254.255.5 (first IP address from every subnet) |
| VLAN ID                                                         | 28                                                                 |
| Express Route/ Gateway Subnet                                   | 10.0.2.0/26                                                        |
| Workload subnet                                                 | 10.0.5.0/26                                                        |
| Provider                                                        | Equinix                                                            |
| Peering Location                                                | Singapore                                                          |
| Bandwidth                                                       | 100 Mbps                                                           |
| SKU                                                             | Standard                                                           |
| Billing Model                                                   | Metered                                                            |
| Peer ASN                                                        | 65501                                                              |
| Azure Edge Router BGP ASN                                       | 12076 (official azure asn)                                         |

## Post-deployment automation

### Express Route Circuit to Gateway Connection
Connection from the express route gateway to the circuit can either be created through an ARM template or using PS. In this lab, we will be using a powershell script to establish the connection with the circuit after the deployment of the gateway is done.  
```
$circuit = Get-AzExpressRouteCircuit -Name $circuitName -ResourceGroupName $CoreNetworkRGName
$gw = Get-AzVirtualNetworkGateway -Name $vnetGatewayName -ResourceGroupName $ResourceGroupName
$connection = New-AzVirtualNetworkGatewayConnection -Name "ERConnection" `
 -ResourceGroupName $ResourceGroupName -Location $location -VirtualNetworkGateway1 $gw `
  -PeerId $circuit.Id -ConnectionType ExpressRoute
 ```
 
 ### Virtual Network Peering between the Hub&Spoke Networks
 When peering the Hub and the spoke networks, we would want the remote gateway transit feature enabled in the Hub so that the spoke networks can use the express route gateway to reach the On-Premise Network. So the virtual network peering with the "AllowGatewayTransit" and "UseRemoteGateways" cannot be enabled until the express route gateway is installed.
 ```
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
```
