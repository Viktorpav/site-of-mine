# site-of-mine
Static Site S3 of Mine, fully managed by CloudFormation!

The idea to create a skillet of fully automated flow of creating static website, with which people can use it for their needs and build it without manual intervantion.

### Docs how to use:

##### Create the website via launching script.sh localy on your laptop

1. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) :shipit:
2. [Configuration of AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) *insert your own AWS account values as described in the link.*
3. Create Hosted zone record in Route53 
aws route53 create-hosted-zone --name <your domain name> \
--caller-reference <any unique string>\
--hosted-zone-config Comment='using aws cli',PrivateZone=false \
4. [Add hosted zone records of NS to DNS provider(move to AWS records) or choose and create in AWS](https://www.virtuallyboring.com/migrate-godaddy-domain-and-dns-to-aws-route-53/)

5. Get project from GitHub:
```
git clone https://github.com/Viktorpav/site-of-mine.git
cd site-of-mine
```
6. Execute script.sh to initiate the project and infrastructure
#-In case of --profile need, add to each command
#--In case of first run with 2 paramiter
#---Run - ./script.sh <domain name> <any uniq value>

—————

<details><summary>Arhitecture overview</summary>
<p>

#### Structure of the project
For example, Mermaid can render flow charts, sequence diagrams, pie charts and more. For more information, see the Mermaid documentation (https://mermaid-js.github.io/mermaid/#/).
```mermaid
graph TD;
    User-->GoDady Domain DNS;
    GoDady Domain DNS-->Route53 Hosted Zone;
    Route53 Hosted Zone-->CloudFront CDN Disribution;
    CloudFront CDN Disribution-->ACM Certificate Manager;
    CloudFront CDN Disribution-->S3 Staic Web Site;
```

![1*PMCYsWaHDIzcaXhI1PSLXA](https://user-images.githubusercontent.com/32811955/211201513-52938964-ee1a-48f1-97f3-b2ad3f610edc.png)

</p>
</details>

—————

- [x] [Create user for boto3 via terraform](https://github.com/Viktorpav/iooding/commit/b05e3b96ba98f6d4403d18835934efbad1e8e520)
- [x] terraform apply -exclude=module.aws_ec2_public_instance
    - Run terraform apply after extract output and one more time terraform apply

- [x] Setup S3 bucket
- [x] Should be written in CloudFormation all setupSetup Route53
- [x] Handle CloudFront
- [x] Fully managed site creation from scratch(domain required)Site blogs which I like: https://www.rosswickman.com/experienceGitHub actions:  - to sync S3 bucket 
- [x] To deploy CloudFormation stack 1.ACM and 2.Main stack 


- [x] Automate of fetching info:
 	HostedZoneId - in acm-certificate cli

	Certificate Founding - in static-site cli
	
	--distribution-id=E2046M05Q79E1L - in s3 sync cli



- [x] Configure Price Class of CloudFront 

- [x] Create dns record in Route53




AWS Amplify Console for S3 static siteDocumentation:
