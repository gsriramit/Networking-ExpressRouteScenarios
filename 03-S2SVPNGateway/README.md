## VPN Gateway in Active-Active Mode - Diagram

### Key Points from the documentation


## Pre-requisites
1. Creation of 2 VPN Demand Dial Interfaces with different route weights

## Explanation of Script
1. One of the 2 interfaces is made the primary connection by assigning a higher weight. The other is assigned a lesser weight. When the S2S connection is established with the azure VPN gateway instances, we will have 2 VPN tunnels in active-active mode.
**Note**: Replace the Destination address with the Public IP addresses of the Azure VPN Gateway Instances
```
$ipv4SubnetAddresses = @('10.0.0.0/16:100')
Set-VpnS2SInterface -Name AzureVPNS2SConnection-Primary -Destination 13.76.191.33 -IPv4Subnet $ipv4SubnetAddresses5
#assign a lower routing weight to the secondary interface
$ipv4SubnetAddresses = @('10.0.0.0/16:50')
Set-VpnS2SInterface -Name AzureVPNS2SConnection-Secondary -Destination 13.76.190.50 -IPv4Subnet $ipv4SubnetAddresses
```
2. Add BGP router to the RRAS server (if this is not done already)
```
#Enable BGP Router on this RRAS Server
Add-BgpRouter -BgpIdentifier 192.168.29.52 -LocalASN 65050
```
3. Add BGP peering between the RRAS server and the azure VPN gateway. This step will be done twice, once for each active instance of the VPN Gateway. To complete this step you need to know the BGP peer IP address of VPN Gateway instances. The suggested ASN for this scenario is 65515  
```
#Add BGP peering between the RRAS and the two azure VPN gateway instances
Add-BgpPeer -Name AzureVPN-Primary -LocalIPAddress 192.168.29.52 -PeerIPAddress 10.0.2.14 -LocalASN 65050 -PeerASN 65515
```
Add-BgpPeer -Name AzureVPN-Secondary -LocalIPAddress 192.168.29.52 -PeerIPAddress 10.0.2.15 -LocalASN 65050 -PeerASN 65515
4. Get Information of the added BGP Peers
```
Get-BgpPeer
```
![image](https://user-images.githubusercontent.com/13979783/134956527-c2dbe104-9cc2-4282-a74f-eceec26d53b3.png)  
5.Get Information of the routes advertised by the BGP Peers
```
Get-BgpRouteInformation
```
![image](https://user-images.githubusercontent.com/13979783/134956647-e3897af9-dd6d-493e-848a-f68998d47968.png)  
6. Advertise the Address spaces of the LAN that uses this Gateway to connect to Azure 
```
Add-BgpCustomRoute -Network 192.168.29.0/24 -PassThru
```
![image](https://user-images.githubusercontent.com/13979783/134956780-67eb8528-7aac-463a-ae80-3b37e22dec4c.png)  
