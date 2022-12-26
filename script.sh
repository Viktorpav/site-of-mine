# In case of git host provider switch
git remote remove origin
git remote add origin <url here>  #https://git-codecommit.eu-central-1.amazonaws.com/v1/repos/site-of-mine

# In case of issues with git line
git config pull.rebase true
git pull origin main

# Register a Hosted Zone in Route53


# Running CloudFormation stack to create cerificate in us-east-1 only
cd cloudformation

aws cloudformation deploy \
--template-file acm-certificate.yaml \
--stack-name mystaticwebsite-acm-certificate \
--region us-east-1 \
--parameter-overrides \
DomainName=pavlyshyn.space \
HostedZoneId=Z0064882QATAQY6LFYUT


# Create S3 buckets for static site

aws cloudformation deploy \
--template-file cloudformation/static-site.yaml \
--stack-name mystaticwebsite-s3-cloudfront \
--region eu-central-1 \
--parameter-overrides \
DomainName=pavlyshyn.space \
CertificateManagerArn=arn:aws:acm:us-east-1:788431431124:certificate/4caff333-948d-4186-8122-ac64b79893e7

# Copy static site to S3 bucket
aws s3 cp ./ s3://mystaticwebsite-s3-cloudfront \
--acl public-read \
--recursive \
--exclude "*" \
--include index.html \
--include 404.html
#--profile AWS_PROFILE




# Clear CloudFront cache
aws cloudfront create-invalidation --distribution-id=E2046M05Q79E1L --paths /*