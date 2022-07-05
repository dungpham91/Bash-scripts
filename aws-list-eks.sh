#!/bin/bash
#
# Author: Dung Pham
# Site: https://devopslite.com
# Date: 05/07/2022
# Purpose: this script use to list all EKS clusters on AWS without known the region
# Use script: chmod +x aws-list-eks.sh && ./aws-list-eks.sh

## Requirement
# You have to install AWS CLI via this link: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# Then you have to configure AWS CLI with your IAM Secret Key by the command: aws configure

for region in `aws ec2 describe-regions --output text | cut -f4`
do
     echo -e "\nListing Clusters in region: $region..."
     aws eks list-clusters --region $region --output text --no-cli-pager
done