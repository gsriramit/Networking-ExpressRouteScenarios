
#Install the Remote Access Server Role/Feature
Install-RemoteAccess -VpnType RoutingOnly

#Get info of the s2s vpn interface
$azS2SVpnPrimaryInterface = Get-VpnS2SInterface -Name AzureVPNS2SConnection-Primary

# Update the S2S VPN Interface (VPN GW's public IP and the CIDR would have changed)
# Feed the updated private ip address spaces in the CIDR:Metric-Weight format
$ipv4SubnetAddresses = @('10.0.0.0/16:100')
Set-VpnS2SInterface -Name AzureVPNS2SConnection-Primary -Destination 13.76.191.33 -IPv4Subnet $ipv4SubnetAddresses5
#assign a lower routing weight to the secondary interface
$ipv4SubnetAddresses = @('10.0.0.0/16:50')
Set-VpnS2SInterface -Name AzureVPNS2SConnection-Secondary -Destination 13.76.191.33 -IPv4Subnet $ipv4SubnetAddresses


#Set-VpnS2SInterface -Name AzureVPNS2SConnection -Destination 52.230.36.36 -IPv4Subnet 10.0.0.0/16:10


#Enable BGP Router on this RRAS Server
Add-BgpRouter -BgpIdentifier 192.168.29.52 -LocalASN 65050


# Add BGP peering between the RRAS and the two azure VPN gateway instances
Add-BgpPeer -Name AzureVPN-Primary -LocalIPAddress 192.168.29.52 -PeerIPAddress 10.0.2.14 -LocalASN 65050 -PeerASN 65515

Add-BgpPeer -Name AzureVPN-Secondary -LocalIPAddress 192.168.29.52 -PeerIPAddress 10.0.2.15 -LocalASN 65050 -PeerASN 65515

#Get Information of the BGP Peers
Get-BgpPeer

# Get Information of the routes advertised by the BGP Peers
Get-BgpRouteInformation

# Advertise the Address spaces of the LAN that uses this Gateway to connect to Azure 
#Add-BgpCustomRoute -Network 192.168.29.52/32 -PassThru
Add-BgpCustomRoute -Network 192.168.29.0/24 -PassThru
