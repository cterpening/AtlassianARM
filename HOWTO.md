# Deployment customizations

The [Jira Software](jira/mainTemplate.json), [Jira Service Desk](servicedesk/mainTemplate.json), [Confluence](confluence/mainTemplate.json), and [Crowd](crowd/mainTemplate.json) templates in this repository provide common parameters for customizing your deployment.

## Basic customizations

You can configure these settings through the available Azure Marketplace interface *or* through a _custom parameters template_ during a CLI deployment.

### Custom domain name

Azure doesn't register domain names, so you'll have to secure yours through a separate third-party domain provider like GoDaddy or CloudFlare. You can set your custom domain name through the Azure Marketplace templates in the *Configure Domain* step. For CLI deployments, use the `cname` parameter:

```
    {
        "parameters": {
            "cname": {
                "value": "mycustomdomainname.com"
            }
        }
    }
```

When you set a custom domain like `mycustomdomainname.com`, our templates will create a DNS Zone called `jira.mycustomdomainname.com` configured with the relevant Azure DNS Name Servers. You can add these Azure Name Servers to your domain configuration to provide a public endpoint of http://jira.mycustomdomainname.com.

For more information, see https://docs.microsoft.com/en-us/azure/dns/dns-zones-records.

### SSL

From the Azure Marketplace templates, you can enable HTTPS/SSL and configure it through the *Configure Domain* step. There, you'll be asked to provide your own _Base64-encoded PFX certificate_ and its corresponding password.

For CLI deployments, use the `sslBase64EncodedPfxCertificate` and `sslPfxCertificatePassword` parameters:

```
    {
        "parameters": {
            "sslBase64EncodedPfxCertificate": {
                "value": "-----BEGIN CERTIFICATE-----MIIF2zCCBMOgAwIBAgIQMj8HjgweXkb..."
            }
            "sslPfxCertificatePassword": {
                "value": "Myazurepassword1!"
            }
        }
    }
```

With HTTPS enabled, all incoming HTTP traffic will be redirected to HTTPS for added security. For more information, see https://docs.microsoft.com/en-us/azure/application-gateway/redirect-http-to-https-cli.

## Advanced customizations

You can only configure the following customizations through the CLI.

### Linux Distribution

By default, our templates will deploy your chosen product on [Ubuntu 18.04 LTS](https://wiki.ubuntu.com/BionicBeaver/ReleaseNotes). You can override this with the following Linux distributions (all supported):

- "Canonical:UbuntuServer:16.04-LTS",
- "RedHat:RHEL:7.5",
- "OpenLogic:CentOS:7.5",
- "credativ:Debian:9-backports"

To use any of these distributions, set the `linuxOsType` parameter. For example, to use Red Hat Enterprise Linux 7.5:

```
    {
        "parameters": {
            "linuxOsType": {
                "value": "RedHat:RHEL:7.5"
            }
        }
    }
```

### Custom Download URL

By default, our templates will only download and install supported releases of each product. If you want to deploy unsupported development versions like [EAP](https://developer.atlassian.com/server/framework/atlassian-sdk/early-access-programs/)s, release candidates, or betas, you need to configure your deployment to download them from a different source.

You can specify this source through the `customDownloadUrl` parameter. You'll also need to set the EAP, beta, or other development version of the product through `jiraVersion` or `confluenceVersion`. See [Jira Development Releases](https://confluence.atlassian.com/adminjira/jira-development-releases-955171963.html) and [Confluence Development Releases](https://confluence.atlassian.com/doc/confluence-development-releases-8163.html) for details on available pre-release versions.

The following snippets demonstrate how to target some pre-release versions:

**Jira Software 8.1.0 EAP**

```
  {
    "parameters": {
      "jiraProduct": {
        "value": "jira-software"
        },
      "jiraVersion": {
        "value": "8.1.0-EAP02"
        },
      "customDownloadUrl": {
        "value": "https://www.atlassian.com/software/jira/downloads/binary/"
        },
      }
    }
```

**Jira Service Desk 4.0.0 Release Candidate**

```
  {
    "parameters": {
      "jiraProduct": {
        "value": "servicedesk"
        },
      "jiraVersion": {
        "value": "4.0.0-RC"
        },
        "customDownloadUrl": {
          "value": "https://www.atlassian.com/software/jira/downloads/binary/"
        },
      }
    }
```

**Confluence 6.15 Milestone**

```
    {
        "parameters": {
          "confluenceVersion": {
            "value": "6.15.0-m30"
            },
          "customDownloadUrl": {
            "value": "https://www.atlassian.com/software/confluence/downloads/binary"
            },
        }
    }
```
### Crowd - Bring Your Own Database
For customers whom may be migrating their entire deployment (servers + database) to Azure to take advantage of the cloud, we provide the ability for customers to specify an existing database to use, as opposed to creating a new database deployment.

The process of exporting an existing database to Azure is out of the scope of this document. The following information assumes the following:

- You have created the resource group which Crowd will be deployed to.
- Within the resource group, you have a database (either Postgres or SQL Server).
- The database is located within the same region as the resource group.
- You have the admin credentials to the database.

**Azure SQL Database**

The following template can be used for Azure SQL deployments: 

```
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "_artifactsLocation": {
        "value": ""
      },
      "_artifactsLocationSasToken": {
        "value": ""
      },
      "location": {
        "value": "northeurope"
      },
      "isMarketplaceDeployment": {
        "value": false
      },
      "crowdVersion": {
        "value": "4.0.0"
      },
      "crowdClusterSize": {
        "value": "trial"
      },
      "clusterVmSize": {
        "value": "Standard_DS2_v2"
      },
      "dbCreateNew": {
        "value": false
      },
      "dbUsername": {
        "value": ""
      },
      "dbPassword": {
        "value": ""
      },
      "dbDatabase": {
        "value": ""
      },
      "dbHost": {
        "value": ""
      },
      "dbPort": {
        "value": "1433"
      },
      "dbType": {
        "value": "Azure SQL DB"
      },
      "dbTier": {
        "value": "Standard"
      },
      "sshKey": {
        "value": ""
      },
      "sshUserName": {
        "value": ""
      },
      "enableEmailAlerts": {
        "value": true
      },
      "enableApplicationInsights": {
        "value": true
      },
      "enableAnalytics": {
        "value": true
      },
      "workspaceSku": {
        "value": ""
      }
    }
  }
```

Particular attention should be made to the dbTier property; due to the fact that newer Azure SQL SKU’s do not support a number of metrics designed to measure DTU consumption. The following tiers are currently supported:

- Basic - Legacy SKU
- Standard - Legacy SKU
- Premium - Legacy SKU
- GeneralPurpose - Newer SKU, used this if you selected one of the vCore options when creating the database.
- BusinessCritical - Newer SKU, used this if you selected one of the vCore options when creating the database.

To execute the deployment using a parameters file is simply a matter of passing a flag and the location of the parameters file to the command given above.

```
az group deployment create --template-file <template path> --parameters <path to parameters file>  --resource-group <resource group name>
```
This will cause the Azure Resouce Manager to begin deployment with the parameters specified in the files.

**Azure Postgres Database**

The following template can be used for Postgres deployments: 

```
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "_artifactsLocation": {
        "value": ""
      },
      "_artifactsLocationSasToken": {
        "value": ""
      },
      "location": {
        "value": "northeurope"
      },
      "isMarketplaceDeployment": {
        "value": false
      },
      "crowdVersion": {
        "value": "4.0.0"
      },
      "crowdClusterSize": {
        "value": "trial"
      },
      "clusterVmSize": {
        "value": "Standard_DS2_v2"
      },
      "dbCreateNew": {
        "value": false
      },
      "dbUsername": {
        "value": ""
      },
      "dbPassword": {
        "value": ""
      },
      "dbDatabase": {
        "value": ""
      },
      "dbHost": {
        "value": ""
      },
      "dbPort": {
        "value": "5432"
      },
      "dbType": {
        "value": "Azure DB for PostgreSQL"
      },
      "sshKey": {
        "value": ""
      },
      "sshUserName": {
        "value": ""
      },
      "enableEmailAlerts": {
        "value": true
      },
      "enableApplicationInsights": {
        "value": true
      },
      "enableAnalytics": {
        "value": true
      },
      "workspaceSku": {
        "value": "PerGB2018"
      }
    }
  }
```

This will cause the Azure Resouce Manager to begin deployment with the parameters specified in the files.