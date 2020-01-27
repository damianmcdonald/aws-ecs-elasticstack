#!/bin/bash

###########################################################################
#                                                                         #
# This sample demonstrates the following concepts:                        #
#                                                                         #
# * AWS CLI                                                               #
# * AWS Cloudformation                                                    #
# * VPC creation                                                          #
# * Subnet creation                                                       #
# * Internet Gateway creation and attach it to the VPC                    #
# * Route Table creation for internet routing                             #
# * Route Table association to subnet                                     #
# * Define the subnet behaviour to auto-assign a public ip to instances   #
# * Create a KeyPair for EC2 instance access                              #
# * Create a security group and ingress rule                              #
# * Create an Autoscaling group                                           #
# * Create an ASG Launch configuration                                    #
# * Create an EC2 instance with Security Group                            #
# * Create an Application Load Balancer                                   #
# * Create an ECS cluster                                                 #
# * Create an ECS Service                                                 #
# * Create ECS task definitions                                           #
# * Create Cloudwatch log group (awslogs)                                 #
# * Associate ECS task definitions (target group) with load balancer      #
# * Cleans up all the resources created                                   #
#                                                                         #
###########################################################################

# Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Global variable declarations
SLEEP_TIME=15
KEY_PAIR_NAME=MY_KEY_PAIR
IAM_CAPABILITIES=CAPABILITY_IAM
ECS_CLUSTER_STACK_NAME=elasticstack-cluster
ECS_CLUSTER_TEMPLATE=cluster-template.yml
ECS_CLUSTER_INSTANCE_TYPE=c5.4xlarge
ECS_SERVICE_TEMPLATE=service-template.yml
ECS_SERVICE_STACK_NAME=elasticstack-service
UNDEPLOY_FILE=aws-undeploy.sh

###########################################################
#                                                         #
#  Validate the CloudFormation templates                  #
#                                                         #
###########################################################

echo -e "[${LIGHT_BLUE}INFO${NC}] Validating CloudFormation template ${YELLOW}$ECS_CLUSTER_TEMPLATE${NC} ...";
cat $ECS_CLUSTER_TEMPLATE | xargs -0 aws cloudformation validate-template --template-body
# assign the exit code to a variable
ECS_CLUSTER_TEMPLATE_VALIDAION_CODE="$?"

# check the exit code, 255 means the CloudFormation template was not valid
if [ $ECS_CLUSTER_TEMPLATE_VALIDAION_CODE != "0" ]; then
    echo -e "[${RED}FATAL${NC}] CloudFormation template ${YELLOW}$ECS_CLUSTER_TEMPLATE${NC} failed validation with non zero exit code ${YELLOW}$ECS_CLUSTER_TEMPLATE_VALIDAION_CODE${NC}. Exiting.";
    exit 999;
fi

echo -e "[${GREEN}SUCCESS${NC}] CloudFormation template ${YELLOW}$ECS_CLUSTER_TEMPLATE${NC} is valid.";

echo -e "[${LIGHT_BLUE}INFO${NC}] Validating CloudFormation template ${YELLOW}$ECS_SERVICE_TEMPLATE${NC} ...";
cat $ECS_SERVICE_TEMPLATE | xargs -0 aws cloudformation validate-template --template-body
# assign the exit code to a variable
ECS_SERVICE_TEMPLATE_VALIDAION_CODE="$?"

# check the exit code, 255 means the CloudFormation template was not valid
if [ $ECS_SERVICE_TEMPLATE_VALIDAION_CODE != "0" ]; then
    echo -e "[${RED}FATAL${NC}] CloudFormation template ${YELLOW}$ECS_SERVICE_TEMPLATE${NC} failed validation with non zero exit code ${YELLOW}$ECS_SERVICE_TEMPLATE_VALIDAION_CODE${NC}.. Exiting.";
    exit 999;
fi

echo -e "[${GREEN}SUCCESS${NC}] CloudFormation template ${YELLOW}$ECS_SERVICE_TEMPLATE${NC} is valid.";

###########################################################
#                                                         #
#  KeyPair creation                                       #
#                                                         #
###########################################################

# delete any previous instance of the keypair file
if [ -f "$KEY_PAIR_NAME.pem" ]; then
    rm -fv $KEY_PAIR_NAME.pem
fi

echo -e "[${LIGHT_BLUE}INFO${NC}] Deleting KeyPair ${YELLOW}$KEY_PAIR_NAME${NC} ....";
aws ec2 delete-key-pair --key-name $KEY_PAIR_NAME
sleep $SLEEP_TIME

echo -e "[${LIGHT_BLUE}INFO${NC}] Creating a KeyPair to allow for EC2 instance access ...";
aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --query 'KeyMaterial' --output text > $KEY_PAIR_NAME.pem

echo -e "[${LIGHT_BLUE}INFO${NC}] Waiting for KeyPair to be created ...";
aws ec2 wait key-pair-exists --key-names $KEY_PAIR_NAME

# verify creation of the keypair file
if [ ! -f "$KEY_PAIR_NAME.pem" ]; then
    echo -e "[${RED}FATAL${NC}] KeyPair file ${YELLOW}$KEY_PAIR_NAME.pem${NC} not created successfully ...";
    exit 999;
fi

echo -e "[${LIGHT_BLUE}INFO${NC}] Secure the use of the KeyPair ${YELLOW}$KEY_PAIR_NAME.pem${NC} to the executing user account ...";
chmod 400 $KEY_PAIR_NAME.pem

###########################################################
#                                                         #
# ECS cluster creation                                    #
#                                                         #
###########################################################

# Create the VPC
echo -e "[${LIGHT_BLUE}INFO${NC}] Creating ECS cluster using template ${YELLOW}$ECS_CLUSTER_TEMPLATE${NC} ....";
aws cloudformation deploy --template-file $ECS_CLUSTER_TEMPLATE \
    --stack-name $ECS_CLUSTER_STACK_NAME \
    --parameter-overrides "InstanceType=$ECS_CLUSTER_INSTANCE_TYPE" \
    --capabilities $IAM_CAPABILITIES

echo -e "[${LIGHT_BLUE}INFO${NC}] Waiting for the creation of cluster ${YELLOW}$ECS_CLUSTER_STACK_NAME${NC} ....";
aws cloudformation wait stack-create-complete --stack-name $ECS_CLUSTER_STACK_NAME

###########################################################
#                                                         #
# ECS tasks creation                                      #
#                                                         #
###########################################################

# sp-insights services
echo -e "[${LIGHT_BLUE}INFO${NC}] Creating ECS tasks ${YELLOW}$ECS_SERVICE_STACK_NAME${NC} ....";
aws cloudformation deploy --template-file $ECS_SERVICE_TEMPLATE \
    --stack-name $ECS_SERVICE_STACK_NAME \
    --parameter-overrides "StackName=$ECS_CLUSTER_STACK_NAME"  \
    --capabilities $IAM_CAPABILITIES

echo -e "[${LIGHT_BLUE}INFO${NC}] Waiting for the creation of cluster ${YELLOW}$ECS_SERVICE_STACK_NAME${NC} ....";
aws cloudformation wait stack-create-complete --stack-name $ECS_SERVICE_STACK_NAME

echo -e "[${LIGHT_BLUE}INFO${NC}] Describing the stacks:"
aws cloudformation describe-stacks

echo -e "[${LIGHT_BLUE}INFO${NC}] Verify that the EC2 instance is running";
INSTANCE_ID=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text)
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

###########################################################
#                                                         #
# Print the connection details                            #
#                                                         #
###########################################################

EXTERNAL_IP=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
EXTERNAL_URL=$(aws cloudformation describe-stacks --stack-name $ECS_CLUSTER_STACK_NAME | jq -r '.Stacks | .[0] | .Outputs | .[] | select(.OutputKey=="ExternalUrl") | .OutputValue')
echo -e "[${LIGHT_BLUE}INFO${NC}] Stack services can be accessed at the external URL shown below:";
echo "";
echo -e "${GREEN}$EXTERNAL_URL${NC}";
echo ""
echo -e "[${LIGHT_BLUE}INFO${NC}] You can access the EC2 instance with SSH using the command below:";
echo "";
echo -e "${GREEN}ssh -i $KEY_PAIR_NAME.pem -o \"StrictHostKeyChecking no\" ec2-user@$EXTERNAL_IP${NC}";
echo ""
echo -e "[${YELLOW}ATTENTION${NC}] Don't forget to create the beat dashboards in Kibana!";
echo ""
echo "*********** METRICBEAT ***********"
echo ""
echo 'METRICBEAT_ID=$(docker ps | grep "damianmcdonald/metricbeat-cloud:1.1.0" | awk '"'"'{ print $1 }'"'"');'
echo ""
echo 'docker exec -t $METRICBEAT_ID /bin/sh -c "metricbeat --strict.perms=false setup -v"';
echo ""
echo "*********** FILEBEAT ***********"
echo ""
echo 'FILEBEAT_ID=$(docker ps | grep "damianmcdonald/filebeat-cloud:1.1.0" | awk '"'"'{ print $1 }'"'"');'
echo ""
echo 'docker exec -t $FILEBEAT_ID /bin/sh -c "filebeat --strict.perms=false setup -v"';
echo ""
echo "*********** HEARTBEAT ***********"
echo ""
echo 'HEARTBEAT_ID=$(docker ps | grep "damianmcdonald/heartbeat-cloud:1.1.0" | awk '"'"'{ print $1 }'"'"');'
echo ""
echo 'docker exec -t $HEARTBEAT_ID /bin/sh -c "heartbeat --strict.perms=false setup -v"';
echo ""

###########################################################
#                                                         #
# Undeployment file creation                              #
#                                                         #
###########################################################

# delete any previous instance of undeploy.sh
if [ -f "$UNDEPLOY_FILE" ]; then
    rm $UNDEPLOY_FILE
fi

cat > $UNDEPLOY_FILE <<EOF
#!/bin/bash

# Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "[${LIGHT_BLUE}INFO${NC}] Terminating ECS service stack ${YELLOW}$ECS_SERVICE_STACK_NAME${NC} ....";
aws cloudformation delete-stack --stack-name $ECS_SERVICE_STACK_NAME

echo -e "[${LIGHT_BLUE}INFO${NC}] Waiting for the deletion of cluster ${YELLOW}$ECS_SERVICE_STACK_NAME${NC} ....";
aws cloudformation wait stack-delete-complete --stack-name $ECS_SERVICE_STACK_NAME

echo -e "[${LIGHT_BLUE}INFO${NC}] Terminating ECS cluster stack ${YELLOW}$ECS_CLUSTER_STACK_NAME${NC} ....";
aws cloudformation delete-stack --stack-name $ECS_CLUSTER_STACK_NAME

echo -e "[${LIGHT_BLUE}INFO${NC}] Waiting for the deletion of cluster ${YELLOW}$ECS_CLUSTER_STACK_NAME${NC} ....";
aws cloudformation wait stack-delete-complete --stack-name $ECS_CLUSTER_STACK_NAME

echo -e "[${LIGHT_BLUE}INFO${NC}] Deleting KeyPair ${YELLOW}$KEY_PAIR_NAME${NC} ....";
aws ec2 delete-key-pair --key-name $KEY_PAIR_NAME
sleep $SLEEP_TIME

# delete any previous instance of the keypair file
if [ -f "$KEY_PAIR_NAME.pem" ]; then
    rm -fv $KEY_PAIR_NAME.pem
fi

aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE
EOF

chmod +x $UNDEPLOY_FILE
