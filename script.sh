# In case of git host provider switch
git remote remove origin
git remote add origin <url here>  #https://git-codecommit.eu-central-1.amazonaws.com/v1/repos/site-of-mine

# In case of issues with git line
git config pull.rebase true
git pull origin main

# Register a Hosted Zone in Route53


# Fetch HostedZoneId from Route53
aws route53 list-hosted-zones-by-name --dns-name pavlyshyn.space | jq -r '.HostedZones| .[] | .Id' | cut -d/ -f3


# Running CloudFormation stack to create cerificate in us-east-1 only and generate HostedZoneId
HostedZoneId=$(aws route53 list-hosted-zones-by-name --dns-name pavlyshyn.space --query "HostedZones[].Id" --output=text | cut -d/ -f3)
aws cloudformation deploy \
--template-file cloudformation/acm-certificate.yaml \
--stack-name mystaticwebsite-acm-certificate \
--region us-east-1 \
--parameter-overrides \
DomainName=pavlyshyn.space \
HostedZoneId=$HostedZoneId


# Create S3 buckets for static site
CertificateManagerArn=$(aws acm list-certificates --region us-east-1 --query "(CertificateSummaryList[?DomainName=='pavlyshyn.space'].CertificateArn)[0]" --output=text)
aws cloudformation deploy \
--template-file cloudformation/static-site.yaml \
--stack-name mystaticwebsite-s3-cloudfront \
--region eu-central-1 \
--parameter-overrides \
DomainName=pavlyshyn.space \
CertificateManagerArn=$CertificateManagerArn

# Copy static site to S3 bucket
aws s3 cp ./ s3://pavlyshyn.space \
--acl public-read \
--recursive \
--exclude "*" \
--include index.html \
--include 404.html
#--profile AWS_PROFILE



# Clear CloudFront cache
DistributionId=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin:Origins.Items[0].Id}[?origin=='pavlyshyn.space'].id" --output text)
aws cloudfront create-invalidation --distribution-id $DistributionId --paths '/*'