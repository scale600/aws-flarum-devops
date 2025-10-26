# AWS Resources for RiderHub Project

**Last Updated:** 2025-10-26 23:05 UTC  
**AWS Account:** 753523452116  
**Region:** us-east-1

## Current Resources

### Lambda Functions

| Resource Name | ARN                                                         | Status | Last Modified                | Environment Variables                                                                                                            |
| ------------- | ----------------------------------------------------------- | ------ | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| riderhub-api  | arn:aws:lambda:us-east-1:753523452116:function:riderhub-api | Active | 2025-10-26T22:33:45.835+0000 | S3_MEDIA_BUCKET: riderhub-media-21idsvsh<br/>DYNAMODB_COMMENTS_TABLE: riderhub-comments<br/>DYNAMODB_POSTS_TABLE: riderhub-posts |

### API Gateway

| Resource Name | ID         | Description          | Created Date              | Status           |
| ------------- | ---------- | -------------------- | ------------------------- | ---------------- |
| riderhub-api  | j00a1r94gf | RiderHub API Gateway | 2025-10-26T15:40:55-07:00 | Active (Latest)  |
| riderhub-api  | 5vzoqgu8db | RiderHub API Gateway | 2025-10-26T15:05:34-07:00 | Pending Deletion |
| riderhub-api  | 6hxj40yld0 | RiderHub API Gateway | 2025-10-26T11:45:33-07:00 | Pending Deletion |
| riderhub-api  | 797g9x52je | RiderHub API Gateway | 2025-10-26T14:18:27-07:00 | Pending Deletion |
| riderhub-api  | 81o219l95k | RiderHub API Gateway | 2025-10-26T11:39:40-07:00 | Pending Deletion |
| riderhub-api  | d7eu4taia8 | RiderHub API Gateway | 2025-10-26T14:01:20-07:00 | Pending Deletion |
| riderhub-api  | eymd5pi782 | RiderHub API Gateway | 2025-10-25T22:55:56-07:00 | Pending Deletion |
| riderhub-api  | j1y44ncrzi | RiderHub API Gateway | 2025-10-26T14:11:30-07:00 | Pending Deletion |
| riderhub-api  | l7bqtiylga | RiderHub API Gateway | 2025-10-26T11:51:29-07:00 | Pending Deletion |
| riderhub-api  | mq47kv0aah | RiderHub API Gateway | 2025-10-26T14:06:15-07:00 | Pending Deletion |
| riderhub-api  | su6o59irf9 | RiderHub API Gateway | 2025-10-26T11:36:08-07:00 | Pending Deletion |

**Note:** Multiple API Gateway instances exist from previous deployments. Cleanup in progress (rate limited).

### S3 Buckets

| Bucket Name             | Created Date        | Purpose       | Status  |
| ----------------------- | ------------------- | ------------- | ------- |
| riderhub-media-21idsvsh | 2025-10-26 15:40:56 | Media storage | Active  |
| riderhub-media-pvpcvkrm | 2025-10-26 15:56:03 | Media storage | Deleted |
| riderhub-media-wr763jkn | 2025-10-26 15:32:12 | Media storage | Deleted |

**Note:** Duplicate S3 buckets have been cleaned up. Only the latest bucket remains.

### SNS Topics

| Topic Name             | ARN                                                       | Purpose       |
| ---------------------- | --------------------------------------------------------- | ------------- |
| riderhub-notifications | arn:aws:sns:us-east-1:753523452116:riderhub-notifications | Notifications |

### IAM Roles

| Role Name            | ARN                                                 | Purpose               | Created Date              |
| -------------------- | --------------------------------------------------- | --------------------- | ------------------------- |
| riderhub-lambda-role | arn:aws:iam::753523452116:role/riderhub-lambda-role | Lambda execution role | 2025-10-26T22:56:02+00:00 |

### DynamoDB Tables

| Table Name        | Status   | Purpose          |
| ----------------- | -------- | ---------------- |
| riderhub-posts    | DELETING | Posts storage    |
| riderhub-comments | DELETING | Comments storage |

**Note:** DynamoDB tables are currently being deleted and will be recreated by Terraform.

### ECR Repositories

| Repository Name | Status  | Purpose              |
| --------------- | ------- | -------------------- |
| riderhub        | DELETED | Docker image storage |

**Note:** ECR repository was deleted and will be recreated by Terraform.

### Amplify Apps

| App Name | Status | Purpose          |
| -------- | ------ | ---------------- |
| None     | -      | Frontend hosting |

**Note:** No Amplify apps found. May need to be created separately.

## Resource Cleanup Status

✅ **S3 Buckets:** Cleaned up - 2 duplicate buckets deleted, 1 active bucket remaining  
🔄 **API Gateway:** Cleanup in progress - 1 deleted, 11 pending deletion (rate limited)  
✅ **DynamoDB Tables:** Cleaned up - tables deleted and will be recreated by Terraform  
✅ **ECR Repository:** Cleaned up - repository deleted and will be recreated by Terraform  
✅ **IAM Role:** Cleaned up - role deleted and recreated

## Cost Estimation

- **Lambda:** ~$0.20 per 1M requests + compute time
- **API Gateway:** ~$3.50 per 1M API calls
- **DynamoDB:** Pay-per-request (no minimum)
- **S3:** ~$0.023 per GB per month
- **SNS:** $0.50 per 1M requests

## Monitoring

- CloudWatch Logs: `/aws/lambda/riderhub-api`
- CloudWatch Metrics: Available for all services
- X-Ray Tracing: Not enabled

## Security

- IAM roles follow least privilege principle
- S3 buckets have public access blocked
- API Gateway has no authentication (consider adding)
- Lambda function has appropriate permissions for DynamoDB and S3

---

_This file is automatically updated during deployments. Last updated: 2025-10-26 23:05 UTC_
