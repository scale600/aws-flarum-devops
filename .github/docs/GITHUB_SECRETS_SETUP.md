# GitHub Secrets 설정 가이드

이 문서는 RiderHub 프로젝트의 GitHub Actions CI/CD 파이프라인에서 사용할 시크릿들을 설정하는 방법을 설명합니다.

## 📋 목차

- [필수 GitHub Secrets](#필수-github-secrets)
- [GitHub Secrets 설정 방법](#github-secrets-설정-방법)
- [AWS 자격 증명 생성](#aws-자격-증명-생성)
- [AWS Amplify 설정](#aws-amplify-설정)
- [추가 권장 시크릿들](#추가-권장-시크릿들)
- [보안 모범 사례](#보안-모범-사례)
- [설정 완료 후 확인](#설정-완료-후-확인)

## 🔐 필수 GitHub Secrets

GitHub Actions에서 사용할 다음 시크릿들을 설정해야 합니다:

| 시크릿 이름 | 설명 | 예시 값 |
|------------|------|---------|
| `AWS_ACCESS_KEY_ID` | AWS 액세스 키 ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS 시크릿 액세스 키 | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AMPLIFY_APP_ID` | AWS Amplify 앱 ID | `d1234567890` |

## 🛠️ GitHub Secrets 설정 방법

### 1. GitHub 저장소 접속
- https://github.com/scale600/aws-flarum-devops-serverless

### 2. Settings 탭 클릭
- 저장소 상단의 "Settings" 탭을 클릭합니다.

### 3. Secrets 메뉴 접근
- 왼쪽 메뉴에서 "Secrets and variables" → "Actions"를 클릭합니다.

### 4. 새 시크릿 추가
- "New repository secret" 버튼을 클릭합니다.
- Name과 Secret 값을 입력하고 "Add secret"을 클릭합니다.

## 🔑 AWS 자격 증명 생성

### IAM 사용자 생성

```bash
# 1. IAM 사용자 생성
aws iam create-user --user-name riderhub-ci-cd

# 2. IAM 정책 생성 (RiderHubCIPolicy.json 파일 생성)
cat > RiderHubCIPolicy.json << 'EOF'
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
EOF

# 3. IAM 정책 생성
aws iam create-policy \
  --policy-name RiderHubCIPolicy \
  --policy-document file://RiderHubCIPolicy.json

# 4. 정책을 사용자에게 연결
aws iam attach-user-policy \
  --user-name riderhub-ci-cd \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/RiderHubCIPolicy

# 5. 액세스 키 생성
aws iam create-access-key --user-name riderhub-ci-cd
```

### 액세스 키 정보 확인

위 명령어 실행 후 다음과 같은 출력을 받게 됩니다:

```json
{
    "AccessKey": {
        "UserName": "riderhub-ci-cd",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "Status": "Active",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "CreateDate": "2024-01-01T00:00:00Z"
    }
}
```

**중요**: `SecretAccessKey`는 한 번만 표시되므로 안전한 곳에 저장하세요.

## 🚀 AWS Amplify 설정

### Amplify 앱 생성

```bash
# 1. Amplify 앱 생성
aws amplify create-app \
  --name riderhub \
  --repository https://github.com/scale600/aws-flarum-devops-serverless \
  --platform WEB \
  --environment-variables '{"_LIVE_UPDATES":"[{\"name\":\"\",\"pkg\":\"\",\"type\":\"\",\"version\":\"\"}]"}'

# 2. App ID 확인
aws amplify list-apps --query 'apps[?name==`riderhub`].appId' --output text
```

### 브랜치 생성

```bash
# main 브랜치 생성
aws amplify create-branch \
  --app-id YOUR_APP_ID \
  --branch-name main \
  --description "Main branch for RiderHub"
```

## 📝 추가 권장 시크릿들

더 안전하고 유연한 설정을 위해 다음 시크릿들도 추가하는 것을 권장합니다:

| 시크릿 이름 | 설명 | 기본값 |
|------------|------|--------|
| `AWS_REGION` | AWS 리전 | `us-east-1` |
| `ECR_REPOSITORY` | ECR 저장소 이름 | `riderhub` |
| `LAMBDA_FUNCTION_NAME` | Lambda 함수 이름 | `riderhub-api` |
| `DYNAMODB_POSTS_TABLE` | DynamoDB 포스트 테이블 | `riderhub-posts` |
| `DYNAMODB_COMMENTS_TABLE` | DynamoDB 댓글 테이블 | `riderhub-comments` |
| `S3_MEDIA_BUCKET` | S3 미디어 버킷 | `riderhub-media` |

## 🔒 보안 모범 사례

### 1. 최소 권한 원칙
- IAM 사용자에게 필요한 최소한의 권한만 부여
- 프로덕션 환경에서는 더 제한적인 권한 사용

### 2. 정기적 로테이션
- 액세스 키를 90일마다 교체
- 이전 키는 즉시 비활성화

### 3. 환경별 분리
- 개발/스테이징/프로덕션 환경별로 다른 자격 증명 사용
- 환경별로 별도의 IAM 사용자 생성

### 4. 모니터링
- CloudTrail을 통한 API 호출 모니터링
- 비정상적인 활동 감지 시 알림 설정

## ✅ 설정 완료 후 확인

### 1. 시크릿 설정 확인
GitHub 저장소의 Settings → Secrets and variables → Actions에서 모든 시크릿이 올바르게 설정되었는지 확인합니다.

### 2. CI/CD 파이프라인 테스트
```bash
# main 브랜치에 푸시하여 파이프라인 트리거
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

### 3. 워크플로우 실행 확인
- GitHub 저장소의 "Actions" 탭에서 워크플로우 실행 상태 확인
- 각 단계별 로그를 확인하여 오류가 없는지 검증

### 4. AWS 리소스 생성 확인
- AWS 콘솔에서 다음 리소스들이 생성되었는지 확인:
  - ECR 저장소
  - Lambda 함수
  - DynamoDB 테이블
  - S3 버킷
  - API Gateway
  - Amplify 앱

## 🚨 문제 해결

### 일반적인 오류들

1. **AWS 자격 증명 오류**
   - IAM 사용자 권한 확인
   - 액세스 키가 올바르게 설정되었는지 확인

2. **ECR 권한 오류**
   - ECR 관련 권한이 IAM 정책에 포함되어 있는지 확인

3. **Amplify 배포 오류**
   - Amplify 앱이 올바르게 생성되었는지 확인
   - App ID가 정확한지 확인

### 로그 확인 방법

```bash
# GitHub Actions 로그 확인
gh run list --repo scale600/aws-flarum-devops-serverless
gh run view [RUN_ID] --repo scale600/aws-flarum-devops-serverless
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. [GitHub Actions 문서](https://docs.github.com/en/actions)
2. [AWS IAM 문서](https://docs.aws.amazon.com/iam/)
3. [AWS Amplify 문서](https://docs.aws.amazon.com/amplify/)

---

**참고**: 이 가이드는 AWS Free Tier를 기준으로 작성되었습니다. 프로덕션 환경에서는 추가적인 보안 조치가 필요할 수 있습니다.
