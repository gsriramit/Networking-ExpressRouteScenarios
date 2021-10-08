## Implementation Reference
This scenario demonstrates a method of enabling two On-Premise sites communicate with each other while not being connected directly. Azure Route Server has the abilities to peer with Azure VPN Gateway and Azure Express Route Gateway through **iBGP**. A simple setting **AllowBranchToBranchTraffic** needs to be enabled in the route server settings. This will enable the route server to learn routes from its BGP peers and advertise the same to the other peers.  
Refer to this article in the documentation for more information. This can also be deployed using a SDWAN appliance in the place of the VPN Gateway. Only difference is that the appliance needs to be explicitly peered (or added as an eBGP peer of Route Server) while Azure VPN Gateway and ER Gateways need not be.
https://docs.microsoft.com/en-us/azure/route-server/expressroute-vpn-support

## Target State Architecture
![AzureNetworkingConcepts - Vpn-ER-RouteServer](https://user-images.githubusercontent.com/13979783/136538587-df9fc17f-7599-4428-b003-664a3252e672.png)

### Key Highlights from the Architecture




### Post-Deployment Script
Branch to Branch routing can be enabled from within the same ARM template that deploys the Route Server or through a post-deployment powershell script.
```
# Update the Azure Route sever object to allow branch to branch traffic
Update-AzRouteServer -RouteServerName $routeServerName -ResourceGroupName $ResourceGroupName -AllowBranchToBranchTraffic
```

