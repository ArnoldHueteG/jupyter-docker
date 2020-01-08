## 1 Choose an AMI

An AMI ([Amazon Machine Image](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)) is virtual machine image ready to run a determined SO (Linux or Windows). I recommend using the latest Ubuntu Server realease. At this time is Ubuntu Server 18.04 LTS (HVM) , SSD Volume Type.

![choose_ami](images/launch_ec2_1_choose_ami.png)

## 2 Choose an instance Type

A micro instance is enough for the initial setup.

![choose_instance_type](images/launch_ec2_2_choose_instance_type.png)

## 3 Configure instance details

For our purpose, this tab can be ignore. Just so you know, here you can choose to create several instances, request spot instances, choose vpc between ohers. 

![choose_configure_instance_details](images/launch_ec2_3_configure_instance_details.png)

## 4 Add Storage

I recommend to use 16 GBs. That would be enoguh to install docker and jupyter image. To store datasets we are going to use S3.

![choose_add_storage](images/launch_ec2_4_add_storage.png)

## 5 Add Tags

For our purpose, this tab can be ignore. 

![choose_add_tags](images/launch_ec2_5_add_tags.png)

## 6 Configure Security Group

Choose "Create a new security group". Then give a name for the security group, for example "jupyter-docker-security-group". Then give a description for example "Ports: 22,8888,2376,443".

Then configure the following security rules as in the image:  

![configure_security_group](images/launch_ec2_6_configure_security_group.png)

## 7 Review Instance Launch

This tab shows a resume for the configuration of the ec2 instance. Verify and then just click launch.

![review_instance_launch](images/launch_ec2_7_review_instance_launch.png)

## 8 Create a Key Pair

They are going to ask you to select or create a new key pair. We are going to create a new one. Just put a name to the key and then save it. Its important not to lose the key pair because you wont be able to get later.

![](images/launch_ec2_8_key_pair.png)


## 9 Setting a Static IP Adress

Before connecting to the ec2 instance, we are going to set a static ip adress. Each time an instance is run, AWS assigns a public ip to reach through internet. So each time you run the instance you are going to get a different public ip. You can deal with that but I prefer to have a static ip. This way your string connection won't change.

To create a static ip you have to allocate an elastic ip adress. To do that go to the left panel in "Network & Security" group you are going to find "Elastic IPs". Then click on "Allocate Elastic IP address" 

![](images/elastic_ip_1_allocate.png)

Then just click on "Allocate".

![](images/elastic_ip_2_allocate.png)


Then we have to associate the elastic ip address to the ec2 instance we launched before. To do that click on "Actions", then "Associate Elastic IP Adress".

![](images/elastic_ip_4_actions.png)

Then select the instance and then click on "Associate".

![](images/elastic_ip_5_associate.png)

## 10 Connect to your instance

To connect to your instance you need an ssh client. It can be git bash, putty, moba exterm, or even power shell. I going to use "visual studio code" because you can edit files like they are local and send commands through console in the same workspace.

So after installing vscode. Go to extensions in the left panel and type "remote development". Install the first option.

![](images/vscode_setup_1_getting_extension.png)

Then go to aws, make sure the instance is running. 

Locate your aws key pair into "C:\Users\UserName"

Then add a new connection in SSH Targets.

![](images/connect_ec2_1_ssh.png)
 
```
ssh -i "[aws key pair name]" ubuntu@[elastic ip address]
```
![](images/connect_ec2_2_ssh.png)

![](images/connect_ec2_3_config_file.png)

![](images/connect_ec2_4_connect.png)

Press control + "ñ" to open the terminal.

![](images/connect_ec2_6_terminal.png)

sudo apt update
sudo apt-get upgrade -y
sudo apt install python-pip -y

## 11 Create alarm to stop ec2 instance if inactivity

Since this instance is going to be use for development purpose, its recommended creating a cloudwatch alarm to stop the ec2 instance in case it is not used. This way we avoid unexpected charges.

![](images/create_cloudwatch_alarm_0_press_button.png)

### 11.1 Creating Cloudwatch Alarm

Services -> CloudWatch

#### 11.1.2 Specify metric and conditions

First you will select the metric to use to set a threshold. Just click en select metric.

![](images/create_cloudwatch_alarm_1_select_metric.png)

Then select "EC2" metrics.
![](images/create_cloudwatch_alarm_1_1_select_metric_ec2.png)

Then select "Per-Instance Metrics"
![](images/create_cloudwatch_alarm_1_2_select_metric_ec2_per_instance.png)

Then filter your instanceid and filter "cpuutilization"(1). Then select your instanceid-metric(2). Then just click the button "Select metric" (3).
![](images/create_cloudwatch_alarm_1_3_select_metric_ec2_per_instance_search_select.png)

Then you have to select the statistic and the period. In Statictics, select "Average". In period, select "1 minute". It should appear as in the image.

![](images/create_cloudwatch_alarm_1_5_select_metric_change_period.png)

Then you have to set the conditions. First select "Static" as thresold type(1). Then in "Whenever CPUUtilization is..." select "Lower"(2).
Then define the threshold at 5 percent(3). At this time I recommend to use this value. If you experiment that your ec2 instance turns off unexpectedly while your are working on the ec2 instance then decrease this value.

Then define the number of datapoints will cause the ALARM state. Each datapoint has one minute of period. "a out of b" means if "a" points of the last "b" points are out of threshold, the alarm will go to ALARM state.
I recommend to use 30 of 30 (4). This means that is going to pass 30 minutes of cpu utilization less than 5% . Again if you experiment that your ec2 instance turns off unexpectedly while your are working on the ec2 instance then increase this value. 

Finally select "Treat missing data as bad (breaching threshold)" just in case we dont have the datapoint we are going to treat it as a bad point (5).

![](images/create_cloudwatch_alarm_1_6_select_metric_set_conditions.png)

#### 11.1.2 Configure Actions

First, remove the notification. We dont want to be aware of alarms states. We want to stop the ec2 instance smoothly.

![](images/create_cloudwatch_alarm_2_1_configure_actions_remove_notification.png)

Then click on "Add ec2 action". 

![](images/create_cloudwatch_alarm_2_2_configure_actions_add_action.png)

In "Whenever this alarm state is" select "in Alarm". Then select the action "Stop this instance"

![](images/create_cloudwatch_alarm_2_4_configure_actions_add_action_review.png)

#### 11.1.3 Add Description

Then define a unique name and a description for the alarm. For example, "Stop inactive ec2 instance : i-0d1e1d80f7d901dd8" as an alarm name. And a description like "Stop ec2 instance when cpu utilization is less than 5%". Then click on "Next"

![](images/create_cloudwatch_alarm_3_add_description.png)

#### 11.1.4 Preview and Create

Finally you get a preview just to confirm the configurations. Click on "Create".

![](images/create_cloudwatch_alarm_4_review.png)

Then you are going to be send to the panel of active alarms. You can see in the image that the alarm has been setup.

![](images/create_cloudwatch_alarm_5_successfull.png)


### 11.2 Add a cpu stress in the initialization file of the ec2 instance

The alarm we just created, have two status "In Alarm" and "OK". When the instance is stopped the default status is "In Alarm". When we run the instance, it doesn't change to "OK" automatically, because the startup process don't consume enough cpu to make change the alarm to status. And if the alarm doesn't change to "OK", the instance wont turn off because the alarm needs a change in the status from "OK" to "In Alarm" to turn off the instance.

To force to change the status to "OK" we are going to add a cpu stress when the instance initialize. First install "stress-ng" and then create the file "rc.local". This file is executed at startup.


https://wiki.ubuntu.com/Kernel/Reference/stress-ng

```shell
sudo apt install stress-ng -y
sudo nano /etc/systemd/system/rc-local.service

[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target

printf '%s\n' '#!/bin/bash' 'exit 0' | sudo tee -a /etc/rc.local

sudo chmod +x /etc/rc.local
```

```shell
sudo systemctl enable rc-local
sudo systemctl start rc-local.service
sudo systemctl status rc-local.service
```

sudo nano /etc/rc.local
```
#!/bin/bash
stress-ng -c 0 -l 50 -t 120

exit 0
```
```
sudo reboot
```
## 12 Creating S3 Bucket

In order to share datasets and models we make, we are going to use "S3".

![](images/create_bucket_0_s3_service.png)

Then click on "Create Bucket".

![](images/create_bucket_1_create_bucket.png)

Then put a name to your bucket. For example my bucket name is "s3-jupyter-docker-aws-20200102-1238". Bucket name is unique across all existing bucket names in S3, So in my example I added the date I created "yyyyMMdd-hhmm".

![](images/create_bucket_1_name_bucket.png)

This step can be ignore.

![](images/create_bucket_2_configure.png)

For default all s3 buckets are block. So leave this step asis.

![](images/create_bucket_3_set_permisions.png)

Finally click on "Create Bucket"

![](images/create_bucket_4_review.png)

## 13 Access Key to S3 Bucket

To save files in s3 programtically, we are going to use awscli (command line) and boto3 (python). In order to do that we need credentials or access keys. So go "IAM" service.

![](images/create_access_key_0_service.png)

Then on the left panel click on "Users".

![](images/create_access_key_1_users.png)

Then "Add user".

![](images/create_access_key_2_add_user.png)

Put a Name to your user. For example my user name is "iam-user-jupyter-docker". Then checked both ways of access type.
Then unchecked "Require password reset"

![](images/create_access_key_2_add_user_1.png)

Then we are going to set permissions to the user. We are going to create an specific policy. Click on "Create Policy".

![](images/create_access_key_2_add_user_2_set_permisions.png)

A new window is going to open. Go to "JSON" tab. Copy and paste the snippet above.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::s3-jupyter-docker-aws-20200102-1238"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::s3-jupyter-docker-aws-20200102-1238/*"
            ]
        }
    ]
}
```

Then click on "Review policy".

![](images/create_access_key_2_add_user_3_create_policy.png)

Then click on "Create policy".

![](images/create_access_key_2_add_user_3_create_policy_review.png)

Then you are going to see a success message.

![](images/create_access_key_2_add_user_3_create_policy_ready.png)

Then we are going to apply the policy to the user. Type the name of the policy to search and then select it.

![](images/create_access_key_2_add_user_4_select_policy.png)

Skip this window.

![](images/create_access_key_2_add_user_5_add_tags.png)

Then click on "Create user".

![](images/create_access_key_2_add_user_6_review.png)

Then you have to download the credentials before close the window.

![](images/create_access_key_2_add_user_7_close.png)

Here you can see the credentials.

![](images/create_access_key_3_credentials.png)


## 14 AWS CLI

AWS CLI is the command line interface to interact with aws services programatically. You can install it with pip. Then configure the access key as is in the pictures. In "region name" put "us-east-2". In "output format" just press enter.

```shell
sudo pip install awscli
aws configure
```
![](images/aws_cli_1_configure.PNG)

To test the connection execute this command.

```shell
aws s3 ls
```

![](images/aws_cli_2_s3_ls.png)

To test you can upload files.

```shell
touch file.txt
aws s3 cp file.txt s3://s3-jupyter-docker-aws-20200102-1238/file.txt
aws s3 ls s3-jupyter-docker-aws-20200102-1238
```

![](images/aws_cli_2_s3_cp.png)

You can verify the file has been upload in aws console.

![](images/aws_cli_2_s3_bk.png)

## 15 Cloning git repository

Clone the git repository to get the basic Dockerfile to build the image.

```shell
mkdir wd
cd wd
git clone https://github.com/ArnoldHueteG/jupyter-docker.git
```

## 15 Installing Docker

We are going to use docker to install Jupyter. In order to install it, copy and paste the code above. The final command will restart the instance.

```shell
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu
sudo reboot
```

## 16 Building Docker image

Then we have to build the image we are going to use with a Dockerfile. In this file we can put the libraries we need additionally from the base image "jupyter/scipy-notebook". 

Verify you have the credential files in "./aws" folder.

```shell
cd
cat .aws/credentials
```

```
[default]
aws_access_key_id = AKI**************2ZJ
aws_secret_access_key = GCt********LXsxvckV********/jWlRxrJTgF
```
```shell
cat .aws/config
```
```
[default]
region = us-east-2
```

Then just copy the folder ".aws" inside "wd" folder. 
```shell
cd wd
cp -avr ~/.aws .aws
chmod 664 .aws/*
```

Then build the image.

```
docker build -t jupyter_docker_aws .
docker build --no-cache=true -t jupyter_docker_aws .
```

## Launching Jupyter Notebook

To launch Jupyter execute the command above.

```
docker run --name jupyter -v /home/ubuntu/wd:/home/jovyan/work/ -d -p 8888:8888 --user root jupyter_docker_aws
```

It wont launch the token. To see the token.

```
docker logs jupyter
```
![](images/launch_jupyter_1_token.png)

Change the link below with your elastic ip and token. Then copy the link to a browser.

```
http://3.136.67.189:8888/lab?token=62e558c74e33bf55714bdeb367bba5f3f42bf4a8aab83bcf
http://18.225.25.66:8888/lab?token=b32a61e7074f79fc99ba865de342cc544f4fa1013db0e94d
```

To launch jupyter at the startup of the instance add the code below in "/etc/rc.local".

```shell
sudo nano /etc/rc.local
```

```
#!/bin/bash
docker stop jupyter && docker rm jupyter && docker run --name jupyter -v /home/ubuntu/wd:/home/jovyan/work/ -d -p 8888:8888 --user root jupyter_docker_aws
stress-ng -c 0 -l 50 -t 60

exit 0
```

Then restart the instance to test.

```shell
sudo reboot
```

## Writing and Reading from s3 with Pandas



## Using Parquet

