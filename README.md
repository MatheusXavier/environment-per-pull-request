# Environment per pull request

## Secret provider class helm
You can check how we have configured the secret provider class helm in `.\deploy\k8s\helm\csi-secret-provider-class`. You can deploy it to your AKS with:

```
helm upgrade --install "<release-name>" --namespace <namespace> -f csi-secret-provider-class/values.<env>.yaml --set serviceProviderClassName="<provider-class-name>" --set  tenantId="<tenantId>" --set userAssignedIdentityID="<userAssignedIdentityID>" --set keyvaultName="<keyvaultName>" csi-secret-provider-class
```