# Declare the variables
$ResourceGroupName = "rg-networking-dev01" 
$routeServerName =" routeserver";

# Update the Azure Route sever object to allow branch to branch traffic
Update-AzRouteServer -RouteServerName $routeServerName -ResourceGroupName $ResourceGroupName -AllowBranchToBranchTraffic

