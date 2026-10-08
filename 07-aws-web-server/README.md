# 7. 내가 만든 웹사이트를 인터넷에 올려 누구나 쓰게 하기 — AWS (클라우드와 AI API, 40시간, 필수) — 마감 10/31

## 1. 미션 소개
"일단 서버에 올렸는데 외부에서 안 들어와요." 포트를 막아놓으셨습니까, 보안 그룹이 없는 겁니까. 클라우드는 그냥 빠른 컴퓨터가 아니라 네트워크, 보안, IAM이 묶인 환경입니다. VPC로 격리된 네트워크를 직접 설계하고, 최소권한 원칙까지 적용한 서비스 환경을 완성합니다.

이번 미션에서는 VPC로 격리된 네트워크를 구성하고, 가상 서버에 애플리케이션을 배포해 외부에서 접속 가능한 웹 서비스를 완성합니다. 보안 그룹과 IAM 최소권한을 적용하고, 오류 발생 시 로그를 근거로 원인을 분석해 해결합니다.

## 2. 최종 결과물 (4가지)
- **아키텍처 다이어그램 1장**: VPC, Subnet, Internet Gateway, EC2, Security Group 구성 요소와 외부 → 서비스 트래픽 흐름 표현. `docs/architecture.(png|pdf)`
- **웹 서비스 외부 접속 증빙 1개**: (A) 브라우저로 `http://<퍼블릭IP>` 접속 또는 (B) `GET http://<퍼블릭IP>/health` 호출, 정상 응답 확인. 선택 방식과 접속 정보를 README.md에 기재 + 스크린샷 1장 이상
- **트러블슈팅 보고서 1개**: 최소 1건, 증상 → 가설 → 검증 → 조치 → 결과 → 재발방지. `docs/troubleshooting.(md|pdf)`
- **리소스 정리 체크리스트 1개**: `docs/cleanup-checklist.md` + (선택) Billing 화면 또는 리소스 목록 스크린샷

## 3. 과제 목표
- VPC, Subnet, Route Table, Internet Gateway의 역할과 트래픽 흐름을 설명할 수 있다.
- Security Group과 IAM의 역할 차이, 최소 권한 원칙을 왜/어떻게 적용하는지 설명할 수 있다.
- 외부 요청이 EC2 웹 서버까지 도달하기 위한 설정(라우팅/퍼블릭 IP/보안그룹)을 설명할 수 있다.
- 로그/증상을 근거로 원인을 가설화하고 검증 후 조치하는 트러블슈팅 과정을 설명할 수 있다.
- 클라우드 과금 요인을 알고, 실습 리소스를 안전하게 정리하는 순서와 이유를 설명할 수 있다.

## 4. 기능 요구 사항
### 네트워크 구성
- VPC 1개, Public Subnet 1개 생성
- Internet Gateway를 VPC에 연결
- Public Subnet의 Route Table에 0.0.0.0/0 → Internet Gateway 경로
- 인스턴스에서 인터넷 아웃바운드 가능 (`curl https://example.com` 성공)

### 컴퓨트 및 웹 서버 배포
- Public Subnet에 EC2 인스턴스 1대, SSH 접속 가능
- 웹 서버(Nginx 등) 설치 및 실행, `curl http://localhost`가 200 응답

### 접근 제어(보안 그룹)
- 인바운드는 필요한 포트만 허용
- HTTP(80)는 0.0.0.0/0에서 접근 가능
- SSH(22)는 개인 IP(또는 지정 IP 대역)에서만 접근 가능
- 0.0.0.0/0에 전체 포트(0-65535) 허용 규칙 금지

### 권한(IAM) 최소권한
- IAM 사용자(또는 Role) 1개 사용
- EC2/VPC/Security Group 구성에 필요한 범위로 제한, 무관한 서비스(S3/RDS 등) 권한 미부여
- AdministratorAccess 부여 금지

### 외부 접속 검증(택 1)
- (A) 브라우저에서 `http://<퍼블릭IP>` 정상 표시 또는 (B) `GET http://<퍼블릭IP>/health`가 200 + 고정 응답("OK")
- 선택 방식을 README.md에 명시

### 운영 안정성(과금 방지)
- 실습 종료 후 리소스 정리, 체크리스트에 "종료/삭제 완료" 근거
- 최소 정리 확인 항목: EC2, EBS(볼륨), Elastic IP, Internet Gateway, VPC

## 5. 보너스 과제 (선택)
- **보너스 1 – HTTPS 적용**: 무료 서브도메인(또는 보유 도메인) 연결, Let's Encrypt 등으로 인증서 적용
- **보너스 2 – Docker 컨테이너로 배포**: EC2에 Docker 설치, 컨테이너로 웹 서비스 실행, 내부 `curl http://localhost` 200 + 외부 접속 확인, README에 이미지명/실행 방식/포트 매핑/스크린샷 2장(docker ps, 외부 접속 결과)

## 6. 개발 환경
Amazon Web Service

## 7. 제약 사항
- 프리 티어 범위 내, 루트 계정 사용 금지(IAM 사용자/Role로만 접근), 실습 종료 후 모든 리소스 종료/삭제
- 리전: 서울(ap-northeast-2)
- 인스턴스: t2.micro 또는 t3.micro / OS: Ubuntu LTS 또는 Amazon Linux / EBS 8~10GiB / 키페어 1개 안전 보관
- 보안: 필요 포트만 허용, HTTP 80은 전체, SSH 22는 내 IP만, 전체 포트 허용 금지
- 정리 대상 추적: EC2(종료), Elastic IP(Release), NAT Gateway, ELB/ALB, RDS, EBS Volumes, 삭제 후 Billing Dashboard 확인 권장

## 8. 결과 예시
- **아키텍처**: VPC(10.0.0.0/16) > Public Subnet(10.0.1.0/24) > EC2(Nginx, Public IP) — Internet Gateway — Internet
- **외부 접속**: (A) 브라우저 `http://x.x.x.x` → "Welcome to nginx!" 또는 "Hello Cloud" / (B) `GET http://x.x.x.x/health` → 200 OK, OK
- **트러블슈팅 보고서 예시**: 증상(SSH 접속 불가) → 가설(22 포트가 내 IP로 제한되지 않음) → 검증(SG 규칙, VPC Flow Log 확인) → 조치(22 포트 내 IP만 허용) → 결과(SSH 성공) → 재발 방지(배포 전 체크리스트에 "SSH 소스 제한" 추가)
- **리소스 정리 체크리스트**: EC2 Terminated / EBS 볼륨 삭제 / Elastic IP Release / Internet Gateway Detach 및 삭제 / VPC, Subnet, Route Table 삭제 / (해당 시) NAT Gateway, ELB/ALB, RDS 삭제 / Billing Dashboard 확인
