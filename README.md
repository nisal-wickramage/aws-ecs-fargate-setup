# aws-ecs-fargate-setup 

Push nginx to ecr private repo

docker pull nginx

docker tag nginx:latest {account-id}.dkr.ecr.ap-southeast-1.amazonaws.com/my-personal-web:latest

Login to ECR
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin {account-id}.dkr.ecr.ap-southeast-1.amazonaws.com/my-personal-web

docker push {account-id}.dkr.ecr.ap-southeast-1.amazonaws.com/my-personal-web:latest

aws ecs execute-command --cluster my-personal-web-api-cluster --task {task-id} --container my-personal-web-api  --interactive --command "/bin/sh"

aws ssm start-session --target {task-id}

./check-ecs-exec.sh my-personal-web-api-cluster {task-id}

arn:aws:ecs:ap-southeast-1:{account-id}:task/my-personal-web-api-cluster/{task-id}
