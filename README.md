도서관리 시스템 CI/CD 환경 구축 프로젝트

프로젝트 개요 이번 프로젝트는 도서관리 시스템 웹 서비스를 위한 CI/CD(지속적 통합 및 지속적 배포) 기반의 자동화된 환경 구축 프로젝트입니다. 프론트엔드와 백엔드로 구성된 소스코드를 활용하여, AWS 클라우드 인프라 상에서 확장성과 안정성을 갖춘 자동 배포 파이프라인을 구현하는 것을 목적으로 합니다.

프로젝트 목표 CI/CD 파이프라인 구축: AWS 기반의 CI/CD 자동화 환경 설계 및 구축 능력을 습득합니다.

클라우드 네이티브 환경 구현: 웹 서비스 배포 및 운영 환경을 클라우드 네이티브 구조로 구현합니다.

인프라 확장성 및 안정성 확보: 서비스 확장성과 안정성을 보장하는 운영 환경(Auto Scaling, Load Balancer)을 설계합니다.

실시간 모니터링 체계 마련: CloudWatch 기반 모니터링 및 알림 시스템 설정 능력을 확보합니다.

DevOps 문화 경험: DevOps 실무에 기반한 협업과 자동화 중심의 개발 생태계를 경험합니다.

시스템 아키텍처 Frontend: React와 Vite, Node.js 20 환경을 기반으로 구축되었습니다.
Backend: Java 17 환경에서 Spring Boot, JPA, Spring Security(BCrypt)를 사용하며 H2 데이터베이스를 연동합니다.

CI/CD 파이프라인:

GitHub를 소스 저장소로 사용하며, 커밋 발생 시 AWS CodeBuild를 통해 프론트엔드와 백엔드가 빌드됩니다.

이후 AWS CodeDeploy를 통해 EC2 인스턴스 환경으로 애플리케이션이 자동 배포됩니다.

인프라 및 확장성: AWS Application Load Balancer(ALB)와 Auto Scaling Group을 연계하여 다수의 EC2 인스턴스에 트래픽을 분산하고 고가용성을 유지합니다.

모니터링: Amazon CloudWatch를 통해 CPU 사용량 등의 지표와 배포 로그를 수집하고 시각화된 대시보드로 시스템을 모니터링합니다.

프로젝트 구조 frontend/ : React 기반의 프론트엔드 웹 애플리케이션 소스코드 및 의존성 파일 (package.json, vite.config.js 등).
backend/ : Spring Boot 기반의 도서관리 백엔드 애플리케이션 소스코드 및 빌드 설정 파일 (build.gradle 등).

deploy-scripts/ : application_start.sh, before_install.sh, validate_service.sh 등 AWS CodeDeploy가 배포 생명주기에 맞추어 실행하는 쉘 스크립트 디렉토리.

buildspec.yml : AWS CodeBuild 단계에서 프론트엔드 종속성 설치, 백엔드 빌드, 스크립트 실행 권한 부여 등을 수행하기 위한 빌드 환경 구성 파일.

appspec.yml : AWS CodeDeploy를 이용한 EC2 인스턴스 배포 및 스크립트 매핑 설정 파일.

팀 역할 이름 담당 역할 상세 업무 이소은 조장 / Dev 개발 관련 이슈 관리 및 소스코드 검토
전징형 발표 / Dev 최종 결과물 발표 및 기능 개발 보조 유정환 검토 담당자 / Infra 인프라 아키텍처 구성 및 AWS 환경 설정 최종 검토 박희우 서기 / Infra 회의록 작성 및 AWS 배포 인프라 초기 구축 세팅 김주형 타임키퍼 / Monitoring 프로젝트 전체 일정 관리 및 CloudWatch 연동 설정 김진영 PPT 제작자 / Monitoring 조별 발표 자료(PPT) 제작 및 대시보드/로그 수집 환경 구성 6. 프로젝트 일정 1일차: CI 기본 구축 및 파이프라인 설계 요구사항 분석 및 아키텍처 설계: 조별 미팅을 통해 소스코드를 선정하고 전체 인프라/모니터링 아키텍처를 설계합니다.

소스 저장소 구성: GitHub 리포지토리를 생성하여 소스코드를 연동합니다.

CI 파이프라인 1차 완성: buildspec.yml을 작성하여 AWS CodePipeline의 Source(GitHub)와 Build(CodeBuild) 스테이지를 구성하고, 자동 빌드 테스트 및 에러를 해결합니다.

2일차: 자동 배포 환경 구축 (CD) 배포 전략 논의: Rolling, Blue/Green 등 적합한 배포 방식 및 전략을 결정합니다.

서버 환경 구성: EC2 생성, IAM 역할 부여, Security Group 설정 등 배포 환경을 세팅합니다.

CD 파이프라인 연동: CodePipeline에 Deploy 스테이지를 추가하고, CodeDeploy Agent와 appspec.yml을 기반으로 자동화 배포를 구성합니다.

전체 파이프라인 테스트: Commit > Build > Deploy로 이어지는 End-to-End 흐름을 검증합니다.

3일차: 인프라 확장성 구성 및 모니터링 적용 확장성 확보 (Auto Scaling & ALB): 로드 밸런서(ALB) 및 Target Group을 구성하고, 트래픽에 대응하기 위한 Auto Scaling 그룹을 생성 및 연결합니다.

모니터링 및 로깅 구축: CloudWatch Metric 기반 Scaling 정책을 설정하고, CloudWatch Agent를 활용해 서버 로그 수집 및 대시보드를 생성합니다.

운영 테스트 및 마무리: CPU 부하 등 실전 시나리오로 인프라 동작을 테스트하고, 최종 발표 자료 제작 및 산출물을 제출합니다.