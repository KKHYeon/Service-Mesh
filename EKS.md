# EKS
### ~~VPC & Subnet 정보~~
```shell
aws ec2 describe-vpcs --profile deali-security --region ap-northeast-2 --filters "Name=tag:Name,Values
=khy-project-vpc" | grep VpcId | grep -oh "vpc-\w*"
aws ec2 describe-subnets --profile deali-security --region ap-northeast-2 --filters Name=vpc-id,Values=vpc-0f414ba95ca3ece97 Name=tag:Name,Values="*public*" | grep SubnetId | grep -oh "subnet-\w*"
```
### 도구
#### kubectl
#### kubelet
#### eksctl
### EKS 클러스터 생성
```shell
eksctl create cluster \
--name khy-cluster \
--region ap-northeast-2 \
--vpc-public-subnets subnet-0bec54f41e2fa2c17,subnet-03a20d18d9487d480 \
--profile deali-security \
--nodegroup-name khy-cluster-nodegroup \
--node-type t3.micro
```

다른 AZ에 있는 최소 2개의 public subnet or private subnet을 지정해줘야함 

→ _Amazon EKS는 최소 2개의 가용 영역에 서브넷이 필요하며, 노드와의 제어 플레인 통신을 용이하게 하기 위해 이러한 서브넷에 최대 4개의 네트워크 인터페이스를 생성합니다._ 

⇢ API 서버 다중 AZ때문인가?? etcd는??

> **오류 발생**
![](img/스크린샷 2022-06-13 오후 2.46.09.png)
Code=Ec2SubnetInvalidConfiguration, Message=One or more Amazon EC2 Subnets of [subnet-..., subnet-...] for node group khy-cluster-nodegroup does not automatically assign public IP addresses to instances launched into it. If you want your instances to be assigned a public IP address, then you need to enable auto-assign public IP address for the subnet.
</br>→ subnet의 Enable auto-assign public IPv4 address 활성화
### EKS 클러스터 삭제
```shell
eksctl delete cluster --region=ap-northeast-2 --name=khy-cluster --profile deali-security
```

### kubeconfig 설정 확인
```shell
kubectl config get-contexts
```
현재 context → 현재 kubectl이 통신하고 설정 정보를 수정하는 쿠버네티스 클러스터
![](img/스크린샷 2022-06-13 오후 4.30.44.png)
### 노드 상태 확인
```shell
kubectl get nodes
```
![](img/스크린샷 2022-06-13 오후 4.31.03.png)

### Control Plane & Data Plane / Master Node & Worker Node
#### Control Plane => master node에서 돌어감?
* AWS가 관리하는 계정에서 실행
* worker node와 pod를 관리
* 구성요소: api server, etcd, scheduler, controller mamager
### 워크로드
#### Deployment
pod와 replicaset에 대한 선언적인 업데이트??
#### ReplicaSet
리플리카 파드 셋의 실행을 안정적으로 유지하기 위해 파드에 장애가 생기면 자동으로 재시작하도록 함
#### Pod
쿠버네티스에서 생성하고 관리할 수 있는 배포 가능한 가장 작은 컴퓨팅 단위로 하나 이상의 컨테이너를 합쳐놓은 오브젝트
</br>
파드 안 컨테이너들을 로컬 호스트로 서로 통신 가능하며 스토리지 공유가 가능
#### Service
#### DaemonSet
#### StatefulSet
파드가 종료되어도 사용했던 볼퓸을 계속 사용할 수 있도록 하는 것
</br>
스테이트풀 애플리케이션을 동작시키는 것은 추천하지 X
### 클러스터
#### 노드
virtual machine or physical machine
#### 네임스페이스
클러스터를 네임스페이스라는 그룹으로 격리하기 위한 논리적인 개념</br>
context마다 네이스페이스를 지정할 수 있음
* default
* kube-node-lease
* kube-public: 모든 사용자가 참조할 수 있는 네임스페이스
* kube-system: 쿠버네티스에 의해 생성되는 오브젝트가 사용하는 네임스페이스
#### API 서비스

### EKS가 관리해주는 것
Master Node
* API 서버
* Controller Manager
* Scheduler
* etcd
### Managed Node Group
노드의 프로비저닝 및 lifecycle 관리를 자동화</br>
Auto Scaling 그룹으로 프로비저닝
### Cluster Autoscaler 
파드를 배치할 때만 스케일링 판단 </br>
requests와 limits 값을 적절하게 설정해야함 </br>
### Horizaontal Pod Autoscaler
더 많은 파드를 배포해야 하는지
### EKS AZ
Control Plane은 2개 이상의 서버 인스턴스</br>
3개의 가용 영역에서 실행되는 3개의 etcd 인스턴스
### EKS Role
* Cluster Role: 클러스터 전체 권한
* Role: 특정 네임스페이스 내 권한
### EKS CNI
* Container Networking Interface
* VPC의 IP 주소를 파드에 할당  

### API 어플리케이션 배포
```shell
cd backend-app
sudo chmod 755 ./gradlew
./gradlew clean build  
```
### 프론트엔드 배포
```shell

```

출처: https://kubernetes.io/ko/docs/concepts/, https://aws.github.io/aws-eks-best-practices
