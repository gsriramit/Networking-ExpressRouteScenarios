# Networking-ExpressRouteScenarios
This repository consists of some of the common Express Route scenarios &amp; architectures that are used in Azure hybrid networking.

## Map of the scenarios in this repository

| Repo Folder           | Scenario                                                                                                                                                                                                                                                                      |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 01-BaseNetworkSetup   | Setup of a hub and spoke network with the appropriate segmentation                                                                                                                                                                                                            |
| 02-ExpressRoute       | Setup of an express route connection from an express route gateway in the hub network to a site that represents the On-Premise DC or branch                                                                                                                                   |
| 03- S2S VPN with BGP  | Setup of a VPN connection with a Site in an active-active mode with redundant azure gateway instances                                                                                                                                                                         |
| 04-InterBranchRouting | Setup of inter-branch routing  between 2 branches/sites(one connected through ER-Gw in step2 & another through VPN-Gw in step3) that do not have direct connectivity. The connectivity in this case is made possible through a route server deployed in the Azure Hub Network |

## RRAS to simulate a Site to Site VPN Connection
In a lab setup, Microsoft's RRAS (Routing & Remote Access Server) can be used to establish a site to site VPN connection. If you want to understand how a S2S connection works in general, I have written a blog that has captured the important details-[Working of S2S VPN](https://ramsaztechbytes.in/2021/05/07/azure-s2s-vpn-exploration-with-rras/)  
The blog also has an internal reference to a youtube video that helps you setup the S2S VPN connection using a VM that runs RRAS (probably in your laptop)-[Setting up S2S with RRAS](https://www.youtube.com/watch?v=Ty4O51U_0Ds&t=266s)  



## GitHub Actions for Deployment
If you do not have a dedicated DevOps setup for the deployment of the ARM templates, you can use the workflow files provided in this repo. The following table provides a mapping of the workflows to the scenarios.  
**Note**: The actions are dependent on the following data and are to be saved as secrets in the repository
1. An Azure Service Principal that has access to the target environment
2. The subscription Id of the target subscription
3. Resource Group to which the resources would be deployed
4. Any other secure information that needs to be read from the secrets

| Scenario                                           | Workflow file                                             |
|----------------------------------------------------|-----------------------------------------------------------|
| 01-BaseNetworkSetup                                | deployBaseNetworks.yml                                    |
| 02-ExpressRoute                          | deployExpressRouteGateway.yml                             |
| 03- S2S VPN with BGP                      | deployVpnGateway.yml                                       |
| 04-InterBranchRouting               | deployInterBranchResources.yml                               |


### Prerequisites before every fresh deployment
If you cleanup the virtual wan and associated resources after every scenario, be sure to complete the prerequisites before every fresh run
1. Create a resource group named "rg-networking-dev01". The name could vary depending on the name that you choose for your deployment resource group. The same should be updated in the GitHub Secrets.Include this step in all of your workflows if get rid of the entire resource group after the completion of every scenario
2. Modify the public ip of the vpn site (local network gateway in the params file) if you are using an RRAS machine and the router's Public IP changes with every restart. 

### GitHub Secrets for the Workflows
Add the following GitHub Secrets to be able to refer to them in the actions (workflows). Please note that you can enhance the workflows as per your needs.
| GitHub Secret            | Value                                                                                                                    |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------|
| AZURE_CREDENTIALS        | "{   ""clientId"": """",
  ""name"": """",
  ""clientSecret"": """",
  ""subscriptionId"": """",
  ""tenantId"": """"
}" |
| AZURE_SUBSCRIPTION_PAYG  | Id of the subscription                                                                                                   |
| AZURE_RG                 | Resource Group Name string                                                                                               |

### GitHub Trigger
All the workflows in this repository would be kicked off using a **workflow_dispatch** which is a manual trigger. If you need the deployment to be triggered on the completion of a PR or a code checkin to DEV, be sure to change that part of the code
```
on: workflow_dispatch
```
## Cost-Saving Measures
1. The author of this [vWan Playground repository](https://github.com/StefanIvemo/vwan-playground)
) has provided a way to delete the vWan resource group using an empty RG deployment. This has not worked for me 100% of the time. However it is always good to try. The same concept can be applied to the resource group that hosts all the virtual networking resources
2. Stop/Deallocate all the test virtual machines if you aren't using them. This wont delete the machines but would turn them off so that you dont have to pay for the compute resources.
3. Delete the bastion hosts when you you dont have a need to RDP into the machines to test the connectivity test cases
4. A common measure known to all- for lab exercises choose to deploy the VPN and express route gateways in a region where the resource costs are less and also has support for all the express route requirements and scalability needs
