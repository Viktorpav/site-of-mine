# Copy static site to S3 bucket
aws s3 sync . s3://$1 --exclude "*" --include index.html --include 404.html --include 503.html --include favicon.ico --include "video/*" --include "lambda-layers/*"

# Clear CloudFront cache
DistributionId=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin:Origins.Items[0].Id}[?origin=='$1'].id" --output text)
aws cloudfront create-invalidation --distribution-id $DistributionId --paths '/*'