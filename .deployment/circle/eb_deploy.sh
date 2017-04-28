#!/bin/bash

set -e

DOCKER_REPOSITORY=$1
UNIQUEID=$2
EB_ENVIRONMENT=$3

if [ -z "$EB_REGION" ]; then
  EB_REGION=us-east-1
fi

EB_BUCKET=elasticbeanstalk-us-east-1-819318868604
if [ -z "$EB_APPLICATION" ]; then
  EB_APPLICATION=libpostal
fi

if [ -z "$EB_REGION" ]; then
  EB_REGION=us-east-1
fi


DOCKERRUN_TEMPLATE=./.deployment/circle/Dockerrun.aws.json.template
EB_VERSION_PATH=./.deployment/eb_version
ZIP_FILE=$UNIQUEID-version.zip
ZIP_PATH=$EB_VERSION_PATH/$ZIP_FILE
ZIP_S3_PATH=CircleCI_versions/$EB_APPLICATION/$ZIP_FILE
DOCKERRUN_FILE=$EB_VERSION_PATH/Dockerrun.aws.json

# Create new Elastic Beanstalk version
echo Creating $DOCKERRUN_FILE
sed -e "s/<TAG>/$UNIQUEID/;s/<DOCKER_REPOSITORY>/$(echo $DOCKER_REPOSITORY | sed -e 's/\//\\\//g')/" < $DOCKERRUN_TEMPLATE > $DOCKERRUN_FILE

# Create zip
echo Creating $ZIP_PATH
pushd $EB_VERSION_PATH
zip -r $ZIP_FILE .
popd

echo Uploading $ZIP_PATH to s3://$EB_BUCKET/$ZIP_S3_PATH
aws s3 cp $ZIP_PATH s3://$EB_BUCKET/$ZIP_S3_PATH

echo Creating version $UNIQUEID
aws elasticbeanstalk --region $EB_REGION create-application-version \
    --application-name $EB_APPLICATION \
    --version-label $UNIQUEID \
    --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIP_S3_PATH


# Update Elastic Beanstalk environment to new version
echo Deploying $UNIQUEID on $EB_ENVIRONMENT
aws elasticbeanstalk --debug --region $EB_REGION update-environment --environment-name $EB_ENVIRONMENT --version-label $UNIQUEID
