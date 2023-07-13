# samsung_PoC

## SDS Hybrid Cloud DevOps향 IaC 도입 PoC - 배포/제거 process 개선안

본 PoC는 Hybrid Cloud 근무자의 업무 효율성 증진을 위한 DevOps향 IaC 도입 안으로 업무 효율성을 증진하고 기존 업무 Process를 개선하는데 목표를 두었습니다.

## DevOps향 IaC 적용 기대 값은 아래와 같습니다.

1. CSP – Project(배포 건) 별로 Instance 배포/제거 하며 현황 파악이 편리합니다.

2. 현 배포 결재 메일과 동일한 Code Architecture로 개발하였기에 고객사의 프로젝트 별 현황 파악 Data Sync에 적합합니다.

3. 신규 장비 DNS 등록 후 해당 인시던트 내용을 Copy&Paste하는 작업 만으로 배포가 이루어져Human-Error를 방지합니다.

4. Back-End 및 DynamoDB Lock 설정으로 state file을 Managed Storage인 S3에 저장하여 state file 의 유실을 방지하고, 여러 사용자의 동시 사용으로 인한 state file의 변경을 방지합니다.

5. API Call을 받아 DynamoDB가 주체가 되어 S3에 보관 되어 있는 state file 의 업데이트가 이루어 집니다.

6. GitHub(Lab) PR&Merge를 통해 code 형상관리하고 Backend - S3 Versioning 을 통해 배포 형상관리를 합니다.

```
.
├── AWS
│   └── department
│       ├── foundry
│       │   ├── maker.tf
│       │   ├── output.tf
│       │   └── project
│       │       ├── A_project.tf
│       │       ├── DNS
│       │       │   └── A_project_DNS.txt
│       │       ├── output.tf
│       │       └── variables.tf
│       └── memory
│           ├── maker.tf
│           ├── output.tf
│           └── project
│               ├── B_project.tf
│               ├── C_project.tf
│               ├── DNS
│               │   ├── B_project_DNS.txt
│               │   └── C_project_DNS.txt
│               ├── output.tf
│               └── variables.tf
├── Azure
│   └── department
│       └── memory
│           ├── maker.tf
│           ├── output.tf
│           ├── project
│           │   ├── DNS
│           │   │   └── D_project_DNS.txt
│           │   ├── D_project.tf
│           │   ├── bootstrap.sh
│           │   ├── output.tf
│           │   └── variables.tf
│           └── secret.tf
├── backend
│   ├── maker.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── parsing.txt
├── script_prd.py
└── script_stg.py

14 directories, 28 files
```
