# AWS 설정 가이드

이 문서는 RiderHub 프로젝트를 위한 AWS 환경 설정 방법을 설명합니다.

## 📋 목차

- [AWS 계정 설정](#aws-계정-설정)
- [AWS CLI 설치 및 설정](#aws-cli-설정)
- [Terraform 설치](#terraform-설정)
- [로컬 개발 환경 설정](#로컬-개발-환경-설정)
- [AWS Free Tier 한도 확인](#aws-free-tier-한도-확인)

## 🏗️ AWS 계정 설정

### 1. AWS 계정 생성
- [AWS Free Tier](https://aws.amazon.com/free/) 계정 생성
- 이메일 인증 및 결제 정보 입력 (Free Tier 사용 시 요금 발생하지 않음)

### 2. AWS Free Tier 한도 확인
- EC2: 750시간/월 (t2.micro 인스턴스)
- Lambda: 1M 요청/월, 400,000 GB-초
- DynamoDB: 25GB 저장소, 25 읽기/쓰기 용량 단위
- S3: 5GB 저장소, 20,000 GET 요청, 2,000 PUT 요청
- API Gateway: 1M API 호출/월
- SNS: 1M 요청/월

## 💻 AWS CLI 설치 및 설정

### macOS
```bash
# Homebrew를 사용한 설치
brew install awscli

# 또는 pip 사용
pip3 install awscli
```

### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install awscli

# CentOS/RHEL
sudo yum install awscli
```

### Windows
```powershell
# Chocolatey 사용
choco install awscli

# 또는 MSI 설치 파일 다운로드
# https://aws.amazon.com/cli/
```

### AWS CLI 설정
```bash
# AWS 자격 증명 설정
aws configure

# 다음 정보 입력:
# AWS Access Key ID: [YOUR_ACCESS_KEY]
# AWS Secret Access Key: [YOUR_SECRET_KEY]
# Default region name: us-east-1
# Default output format: json

# 설정 확인
aws sts get-caller-identity
```

## 🏗️ Terraform 설치

### macOS
```bash
# Homebrew 사용
brew install terraform

# 또는 직접 다운로드
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_darwin_amd64.zip
unzip terraform_1.6.0_darwin_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Linux
```bash
# Ubuntu/Debian
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# 또는 패키지 매니저 사용
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

### Windows
```powershell
# Chocolatey 사용
choco install terraform

# 또는 직접 다운로드
# https://releases.hashicorp.com/terraform/
```

### Terraform 설정 확인
```bash
terraform version
```

## 🐳 Docker 설치

### macOS
```bash
# Docker Desktop 설치
# https://www.docker.com/products/docker-desktop/

# 또는 Homebrew 사용
brew install --cask docker
```

### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# CentOS/RHEL
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Docker 설정 확인
```bash
docker --version
docker-compose --version
```

## 🔧 로컬 개발 환경 설정

### 1. 프로젝트 클론
```bash
git clone https://github.com/scale600/aws-flarum-devops-serverless.git
cd aws-flarum-devops-serverless
```

### 2. 환경 변수 설정
```bash
# .env 파일 생성
cat > .env << 'EOF'
AWS_REGION=us-east-1
PROJECT_NAME=riderhub
ENVIRONMENT=dev
EOF
```

### 3. Terraform 초기화
```bash
cd terraform
terraform init
terraform plan
```

### 4. 로컬 테스트
```bash
# Docker 이미지 빌드 테스트
cd docker/riderhub
docker build -t riderhub-test .

# 컨테이너 실행 테스트
docker run -p 8080:8080 riderhub-test
```

## 📊 AWS Free Tier 한도 모니터링

### CloudWatch 대시보드 설정
```bash
# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
  --dashboard-name "RiderHub-FreeTier" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/Lambda", "Invocations"],
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits"],
            ["AWS/S3", "BucketSizeBytes"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Free Tier Usage"
        }
      }
    ]
  }'
```

### 비용 알림 설정
```bash
# SNS 토픽 생성
aws sns create-topic --name riderhub-cost-alerts

# CloudWatch 알람 생성
aws cloudwatch put-metric-alarm \
  --alarm-name "RiderHub-Cost-Alert" \
  --alarm-description "Alert when estimated charges exceed $5" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 5.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

## 🚀 첫 배포

### 1. Terraform 배포
```bash
cd terraform
terraform apply -auto-approve
```

### 2. 배포 확인
```bash
# Lambda 함수 확인
aws lambda list-functions --query 'Functions[?FunctionName==`riderhub-api`]'

# DynamoDB 테이블 확인
aws dynamodb list-tables --query 'TableNames[?contains(@, `riderhub`)]'

# S3 버킷 확인
aws s3 ls | grep riderhub
```

### 3. API 테스트
```bash
# API Gateway URL 확인
aws apigateway get-rest-apis --query 'items[?name==`riderhub-api`].id' --output text

# API 테스트
curl -X GET https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev/posts
```

## 🔍 문제 해결

### 일반적인 문제들

1. **권한 오류**
   ```bash
   # IAM 정책 확인
   aws iam list-attached-user-policies --user-name YOUR_USERNAME
   ```

2. **리전 불일치**
   ```bash
   # 현재 리전 확인
   aws configure get region
   
   # 리전 변경
   aws configure set region us-east-1
   ```

3. **Terraform 상태 오류**
   ```bash
   # Terraform 상태 초기화
   terraform init -reconfigure
   ```

### 로그 확인
```bash
# CloudWatch 로그 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/riderhub"

# Lambda 로그 확인
aws logs get-log-events \
  --log-group-name "/aws/lambda/riderhub-api" \
  --log-stream-name "LATEST"
```

## 📚 추가 리소스

- [AWS Free Tier 사용량 확인](https://console.aws.amazon.com/billing/home#/freetier)
- [AWS CLI 명령어 참조](https://docs.aws.amazon.com/cli/latest/reference/)
- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker 공식 문서](https://docs.docker.com/)

---

**주의**: 이 가이드는 AWS Free Tier를 기준으로 작성되었습니다. 프로덕션 환경에서는 추가적인 보안 및 모니터링 설정이 필요합니다.
