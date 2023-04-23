#!/bin/bash

#-In case of --profile need, add to each command
#--In case of first run, uncommit below command and run with 2 paramiter
#---Run - ./script.sh <domain name> <any uniq value>

# Register a Hosted Zone in Route53
aws route53 create-hosted-zone --name $1 \
--caller-reference $2 \
--hosted-zone-config Comment='using aws cli',PrivateZone=false


# Running CloudFormation stack to create cerificate in us-east-1 only and Fetch HostedZoneId from Route53
HostedZoneId=$(aws route53 list-hosted-zones-by-name --dns-name $1 --query "HostedZones[].Id" --output=text | cut -d/ -f3) 
aws cloudformation deploy \
--template-file cloudformation/acm-certificate.yaml \
--stack-name mystaticwebsite-acm-certificate \
--region us-east-1 \
--parameter-overrides \
DomainName=$1 \
HostedZoneId=$HostedZoneId

wait 

# Create S3 buckets for static site
CertificateManagerArn=$(aws acm list-certificates --region us-east-1 --query "(CertificateSummaryList[?DomainName=='$1'].CertificateArn)[0]" --output=text) 
aws cloudformation deploy \
--template-file cloudformation/static-site.yaml \
--stack-name mystaticwebsite-s3-cloudfront \
--region eu-central-1 \
--parameter-overrides \
DomainName=$1 \
CertificateManagerArn=$CertificateManagerArn

wait

# Copy static site to S3 bucket
aws s3 sync . s3://$1 --acl public-read --exclude "*" --include index.html --include 404.html --include 503.html --include "video/*"

# Clear CloudFront cache
DistributionId=$(aws cloudfront list-distributions --region us-east-1 --query "DistributionList.Items[*].{id:Id,origin:Origins.Items[0].Id}[?origin=='$1'].id" --output text)
aws cloudfront create-invalidation --region us-east-1 --distribution-id $DistributionId --paths '/*'