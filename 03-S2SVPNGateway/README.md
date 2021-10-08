## VPN Gateway Deployment Mode
Azure VPN Gateway needs to be deployed in an Active-Active Mode and have the ASN set to 65515 for the Inter-Branch routing scenario to work. This is a requirement that has been stated in the documentation.

### Deployment Topology
![image](https://user-images.githubusercontent.com/13979783/136536088-cc11ecee-5664-475f-9179-24ad75a15dd4.png)  
**Documentation Source**- https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-highlyavailable#active-active-vpn-gateways

### Key Points from the documentation
1. In this configuration, each Azure gateway instance will have a unique public IP address, and *each will establish an IPsec/IKE S2S VPN tunnel to your on-premises VPN device specified in your local network gateway and connection*
2. Note that both VPN tunnels are actually part of the same connection. You will still need to configure your on-premises VPN device to accept or *establish two S2S VPN tunnels to those two Azure VPN gateway public IP addresses*.
3. Because the Azure gateway instances are in active-active configuration, the *traffic from your Azure virtual network to your on-premises network will be routed through both tunnels simultaneously, even if your on-premises VPN device may favor one tunnel over the other*.

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
