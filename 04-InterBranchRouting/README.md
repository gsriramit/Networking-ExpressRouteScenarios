## Implementation Reference
This scenario demonstrates a method of enabling two On-Premise sites communicate with each other while not being connected directly. Azure Route Server has the abilities to peer with Azure VPN Gateway and Azure Express Route Gateway through **iBGP**. A simple setting **AllowBranchToBranchTraffic** needs to be enabled in the route server settings. This will enable the route server to learn routes from its BGP peers and advertise the same to the other peers.  
Refer to this article in the documentation for more information. This can also be deployed using a SDWAN appliance in the place of the VPN Gateway. Only difference is that the appliance needs to be explicitly peered (or added as an eBGP peer of Route Server) while Azure VPN Gateway and ER Gateways need not be.
https://docs.microsoft.com/en-us/azure/route-server/expressroute-vpn-support

## Target State Architecture
![AzureNetworkingConcepts - Vpn-ER-RouteServer](https://user-images.githubusercontent.com/13979783/136538587-df9fc17f-7599-4428-b003-664a3252e672.png)

### Key Points from the Architecture
1. VPN Gateway instances are deployed in active-active mode
   - instance ips: 10.0.2.14 and 10.0.2.15
2. Route Server is also deployed in an active-active mode
   - instance ips:10.0.10.4
3. The following table is Azure VPN Gateway's BGP Peers list (you can download this from the portal)  
   - Each instance of VPN-Gw is peered to each instance of Route Server
     - 10.0.2.14 to 10.0.10.4 and 10.0.10.4
     - 10.0.2.15 to 10.0.10.4 and 10.0.10.5
   - Each instance of the VPN-Gw is peered to the On-Prem VPN Device, the RRAS server in this case. If the On-Prem VPN device is also run in a highly-available mode then the peering would be to both instances of the VPN device 
     - 10.0.2.14 to 192.168.29.52 &
     - 10.0.2.15 to 192.168.29.52
   - When the state of all the peers are in the connected state, the On-Premise routes that the VPN Gateway instances learn would have been advertised to the route server instances through iBGP 

| Local address | Peer address  | Asn   | Status    | Connected duration | Routes received | Messages sent | Messages Received |
|---------------|---------------|-------|-----------|--------------------|-----------------|---------------|-------------------|
| 10.0.2.15     | 192.168.29.52 | 65050 | Connected | 09:24.1            | 2               | 31            | 18                |
| 10.0.2.15     | 10.0.2.14     | 65515 | Connected | 18:49.8            | 3               | 185           | 189               |
| 10.0.2.15     | 10.0.2.15     | 65515 | Unknown   | -                  | 0               | 0             | 0                 |
| 10.0.2.15     | 10.0.10.5     | 65515 | Connected | 09:07.1            | 3               | 20            | 23                |
| 10.0.2.15     | 10.0.10.4     | 65515 | Connected | 09:07.1            | 3               | 19            | 23                |
| 10.0.2.14     | 192.168.29.52 | 65050 | Connected | 09:21.6            | 2               | 24            | 17                |
| 10.0.2.14     | 10.0.2.14     | 65515 | Unknown   | -                  | 0               | 0             | 0                 |
| 10.0.2.14     | 10.0.2.15     | 65515 | Connected | 18:49.7            | 3               | 187           | 187               |
| 10.0.2.14     | 10.0.10.5     | 65515 | Connected | 09:21.7            | 1               | 20            | 23                |
| 10.0.2.14     | 10.0.10.4     | 65515 | Connected | 09:21.7            | 1               | 20            | 23                |

4. The following table shows the Routes learnt and the corresponding next hop address from Azure VPN-Gw's perspective. This means that the destination address ranges (apart from its own) are those that the On-Premise Site1 can possibly reach. In doing so, which components act as the next hop should be the point of interest. In this implementation the On-Premise site-1 would learn the routes to 
   - Azure Virtual Networks
     - Hub (10.0.0.0/16) &
     - Spoke (10.1.0.0/16)
   - On-Premise Site2
     - 172.31.255.0/24
5. On-Premise Site-2 would have learnt the routes to On-Premise Site-1 from the Route Server
6. In each case, the Gateway instances (VPN Gateway or the ER Gateway) act as the next hop to the hybrid networks that they are connecting to Azure 

| Network          | Next hop      | Local address | AS path     | Weight | Origin  | Source peer   |
|------------------|---------------|---------------|-------------|--------|---------|---------------|
| 10.0.0.0/16      | -             | 10.0.2.14     | -           | 32768  | Network | 10.0.2.14     |
| 10.1.0.0/16      | -             | 10.0.2.14     | -           | 32768  | Network | 10.0.2.14     |
| 192.168.29.0/24  | 192.168.29.52 | 10.0.2.14     | 65050       | 32768  | EBgp    | 192.168.29.52 |
| 192.168.29.0/24  | 10.0.2.15     | 10.0.2.14     | 65050       | 32768  | IBgp    | 10.0.2.15     |
| 192.168.29.50/32 | 192.168.29.52 | 10.0.2.14     | 65050       | 32768  | EBgp    | 192.168.29.52 |
| 192.168.29.50/32 | 10.0.2.15     | 10.0.2.14     | 65050       | 32768  | IBgp    | 10.0.2.15     |
| 192.168.29.52/32 | -             | 10.0.2.14     | -           | 32768  | Network | 10.0.2.14     |
| 192.168.29.52/32 | 10.0.2.15     | 10.0.2.14     | -           | 32768  | IBgp    | 10.0.2.15     |
| 172.31.255.0/24  | 10.0.2.4      | 10.0.2.14     | 12076-65501 | 32768  | IBgp    | 10.0.10.4     |
| 172.31.255.0/24  | 10.0.2.4      | 10.0.2.14     | 12076-65501 | 32768  | IBgp    | 10.0.10.5     |
| 10.0.0.0/16      | -             | 10.0.2.15     | -           | 32768  | Network | 10.0.2.15     |
| 10.1.0.0/16      | -             | 10.0.2.15     | -           | 32768  | Network | 10.0.2.15     |
| 192.168.29.0/24  | 192.168.29.52 | 10.0.2.15     | 65050       | 32768  | EBgp    | 192.168.29.52 |
| 192.168.29.0/24  | 10.0.2.14     | 10.0.2.15     | 65050       | 32768  | IBgp    | 10.0.2.14     |
| 192.168.29.0/24  | 10.0.2.14     | 10.0.2.15     | 65050       | 32768  | IBgp    | 10.0.10.5     |
| 192.168.29.0/24  | 10.0.2.14     | 10.0.2.15     | 65050       | 32768  | IBgp    | 10.0.10.4     |
| 192.168.29.50/32 | 192.168.29.52 | 10.0.2.15     | 65050       | 32768  | EBgp    | 192.168.29.52 |
| 192.168.29.50/32 | 10.0.2.14     | 10.0.2.15     | 65050       | 32768  | IBgp    | 10.0.2.14     |
| 192.168.29.50/32 | 10.0.2.14     | 10.0.2.15     | 65050       | 32768  | IBgp    | 10.0.10.5     |
| 192.168.29.50/32 | 10.0.2.14     | 10.0.2.15     | 65050       | 32768  | IBgp    | 10.0.10.4     |
| 192.168.29.52/32 | -             | 10.0.2.15     | -           | 32768  | Network | 10.0.2.15     |
| 192.168.29.52/32 | 10.0.2.14     | 10.0.2.15     | -           | 32768  | IBgp    | 10.0.2.14     |
| 172.31.255.0/24  | 10.0.2.4      | 10.0.2.15     | 12076-65501 | 32768  | IBgp    | 10.0.10.4     |
| 172.31.255.0/24  | 10.0.2.4      | 10.0.2.15     | 12076-65501 | 32768  | IBgp    | 10.0.10.5     |

**Note**: I have added the downloaded BGP Peers, Routes Learnt CSV files in the Artifacts folder  
7. Routes advertised and learnt 
   - Advertised from Azure to On-Premise Site-1 (through the VPN Gateway)
      - 10.0.0.0/16
      - 10.1.0.0/16
      - 172.31.255.0/24
   - Learnt from On-Premise Site-1
     - 192.168.29.0/24
   -  Advertised from Azure to On-Premise Site-2 (through the ER Gateway)
      - 10.0.0.0/16
      - 10.1.0.0/16
      - 192.168.29.0/24
   - Learnt from On-Premise Site-2
     - 172.31.255.0/24


### Post-Deployment Script
Branch to Branch routing can be enabled from within the same ARM template that deploys the Route Server or through a post-deployment powershell script.
```
# Update the Azure Route sever object to allow branch to branch traffic
Update-AzRouteServer -RouteServerName $routeServerName -ResourceGroupName $ResourceGroupName -AllowBranchToBranchTraffic
```

