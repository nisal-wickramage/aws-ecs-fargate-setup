# aws-ecs-fargate-setup 

Push nginx to ecr private repo

docker pull nginx

docker tag nginx:latest {account-id}.dkr.ecr.ap-southeast-1.amazonaws.com/my-personal-web:latest

Login to ECR
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin {account-id}.dkr.ecr.ap-southeast-1.amazonaws.com/my-personal-web

docker push {account-id}.dkr.ecr.ap-southeast-1.amazonaws.com/my-personal-web:latest

aws ecs execute-command --cluster my-personal-web-api-cluster --task {task-id} --container my-personal-web-api  --interactive --command "/bin/sh"

curl internal-my-personal-web-lb-tf-585805291.ap-southeast-1.elb.amazonaws.com

aws ssm start-session --target {task-id}

export AWS_REGION=ap-southeast-1

./check-ecs-exec.sh my-personal-web-api-cluster {task-id}

arn:aws:ecs:ap-southeast-1:{account-id}:task/my-personal-web-api-cluster/{task-id}
