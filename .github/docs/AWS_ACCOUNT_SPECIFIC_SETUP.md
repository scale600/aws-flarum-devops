# AWS 계정별 설정 가이드

**AWS 계정 ID**: `753523452116`  
**리전**: `us-east-1`

이 문서는 특정 AWS 계정에 맞춘 구체적인 설정 방법을 제공합니다.

## 🔐 GitHub Secrets 설정 값

### **필수 시크릿들**

| 시크릿 이름             | 값         | 설명                          |
| ----------------------- | ---------- | ----------------------------- |
| `AWS_ACCESS_KEY_ID`     | `AKIA...`  | IAM 사용자의 액세스 키 ID     |
| `AWS_SECRET_ACCESS_KEY` | `wJalr...` | IAM 사용자의 시크릿 액세스 키 |
| `AMPLIFY_APP_ID`        | `d...`     | Amplify 앱 ID                 |

### **추가 권장 시크릿들**

| 시크릿 이름               | 값                        | 설명                   |
| ------------------------- | ------------------------- | ---------------------- |
| `AWS_REGION`              | `us-east-1`               | AWS 리전               |
| `ECR_REPOSITORY`          | `riderhub`                | ECR 저장소 이름        |
| `LAMBDA_FUNCTION_NAME`    | `riderhub-api`            | Lambda 함수 이름       |
| `DYNAMODB_POSTS_TABLE`    | `riderhub-posts`          | DynamoDB 포스트 테이블 |
| `DYNAMODB_COMMENTS_TABLE` | `riderhub-comments`       | DynamoDB 댓글 테이블   |
| `S3_MEDIA_BUCKET`         | `riderhub-media-xxxxxxxx` | S3 미디어 버킷         |

## 🏗️ AWS 리소스 ARN 정보

### **ECR 저장소**

```
Repository URI: 753523452116.dkr.ecr.us-east-1.amazonaws.com/riderhub
```

### **Lambda 함수**

```
Function ARN: arn:aws:lambda:us-east-1:753523452116:function:riderhub-api
```

### **DynamoDB 테이블**

```
Posts Table ARN: arn:aws:dynamodb:us-east-1:753523452116:table/riderhub-posts
Comments Table ARN: arn:aws:dynamodb:us-east-1:753523452116:table/riderhub-comments
```

### **S3 버킷**

```
Media Bucket ARN: arn:aws:s3:::riderhub-media-xxxxxxxx
```

### **API Gateway**

```
API Gateway ARN: arn:aws:execute-api:us-east-1:753523452116:xxxxxxxxxx/*
```

## 🔑 IAM 정책 설정

### **RiderHubCIPolicy.json**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "lambda:ListFunctions",
        "iam:PassRole",
        "iam:GetRole",
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:UpdateTable",
        "dynamodb:DeleteTable",
        "dynamodb:ListTables",
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketVersioning",
        "s3:ListBucket",
        "s3:PutBucketVersioning",
        "s3:PutBucketPublicAccessBlock",
        "apigateway:*",
        "sns:CreateTopic",
        "sns:ListTopics",
        "amplify:StartDeployment",
        "amplify:GetApp",
        "amplify:ListApps",
        "cloudformation:CreateStack",
        "cloudformation:UpdateStack",
        "cloudformation:DeleteStack",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeStackEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

## 🚀 AWS CLI 명령어 (계정별)

### **IAM 사용자 생성**

```bash
# IAM 사용자 생성
aws iam create-user --user-name riderhub-ci-cd

# 정책 생성
aws iam create-policy \
  --policy-name RiderHubCIPolicy \
  --policy-document file://RiderHubCIPolicy.json

# 정책 연결
aws iam attach-user-policy \
  --user-name riderhub-ci-cd \
  --policy-arn arn:aws:iam::753523452116:policy/RiderHubCIPolicy

# 액세스 키 생성
aws iam create-access-key --user-name riderhub-ci-cd
```

### **ECR 저장소 생성**

```bash
# ECR 저장소 생성
aws ecr create-repository \
  --repository-name riderhub \
  --region us-east-1

# 로그인 토큰 확인
aws ecr get-login-password --region us-east-1
```

### **Amplify 앱 생성**

```bash
# Amplify 앱 생성
aws amplify create-app \
  --name riderhub \
  --repository https://github.com/scale600/aws-flarum-devops-serverless \
  --platform WEB \
  --region us-east-1

# App ID 확인
aws amplify list-apps --region us-east-1 --query 'apps[?name==`riderhub`].appId' --output text
```

## 🔍 AWS 콘솔 직접 링크

### **IAM 콘솔**

```
https://console.aws.amazon.com/iam/home?region=us-east-1#/users
```

### **ECR 콘솔**

```
https://console.aws.amazon.com/ecr/repositories?region=us-east-1
```

### **Lambda 콘솔**

```
https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions
```

### **DynamoDB 콘솔**

```
https://console.aws.amazon.com/dynamodb/home?region=us-east-1#tables:
```

### **S3 콘솔**

```
https://console.aws.amazon.com/s3/home?region=us-east-1
```

### **Amplify 콘솔**

```
https://console.aws.amazon.com/amplify/home?region=us-east-1#/
```

### **API Gateway 콘솔**

```
https://console.aws.amazon.com/apigateway/main/apis?region=us-east-1
```

## 📊 리소스 확인 명령어

### **모든 리소스 상태 확인**

```bash
# AWS 계정 정보 확인
aws sts get-caller-identity

# ECR 저장소 확인
aws ecr describe-repositories --repository-names riderhub --region us-east-1

# Lambda 함수 확인
aws lambda list-functions --region us-east-1 --query 'Functions[?FunctionName==`riderhub-api`]'

# DynamoDB 테이블 확인
aws dynamodb list-tables --region us-east-1 --query 'TableNames[?contains(@, `riderhub`)]'

# S3 버킷 확인
aws s3 ls | grep riderhub

# Amplify 앱 확인
aws amplify list-apps --region us-east-1 --query 'apps[?name==`riderhub`]'
```

## 🚨 문제 해결

### **권한 오류 시**

```bash
# 현재 사용자 권한 확인
aws iam list-attached-user-policies --user-name $(aws sts get-caller-identity --query 'Arn' --output text | cut -d'/' -f2)

# 정책 내용 확인
aws iam get-policy --policy-arn arn:aws:iam::753523452116:policy/RiderHubCIPolicy
```

### **리소스 생성 오류 시**

```bash
# CloudFormation 스택 확인
aws cloudformation list-stacks --region us-east-1 --query 'StackSummaries[?contains(StackName, `riderhub`)]'

# Terraform 상태 확인
cd terraform
terraform show
```

## 📋 체크리스트

### **GitHub Secrets 설정 전 확인사항**

- [ ] AWS CLI가 올바르게 설정되었는지 확인
- [ ] IAM 사용자가 생성되었는지 확인
- [ ] 필요한 권한이 부여되었는지 확인
- [ ] ECR 저장소가 생성되었는지 확인
- [ ] Amplify 앱이 생성되었는지 확인

### **GitHub Secrets 설정 후 확인사항**

- [ ] 모든 필수 시크릿이 설정되었는지 확인
- [ ] 시크릿 값이 올바른지 확인
- [ ] CI/CD 파이프라인이 정상 실행되는지 확인
- [ ] AWS 리소스가 올바르게 생성되는지 확인

---

**참고**: 이 설정은 AWS 계정 `753523452116`에 특화되어 있습니다. 다른 계정을 사용하는 경우 계정 ID를 변경해야 합니다.
