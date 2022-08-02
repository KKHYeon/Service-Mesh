# EKS
### ~~VPC & Subnet 정보~~
```shell
aws ec2 describe-vpcs --profile deali-security --region ap-northeast-2 --filters "Name=tag:Name,Values=khy-project-vpc" | grep VpcId | grep -oh "vpc-\w*" >> ~/.bash_profile
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
--vpc-public-subnets subnet-0fd835ea3171080a4, subnet-0c391d20b1fc9700d \
--vpc-private-subnets subnet-06cb3b4e241f3191b, subnet-0a3cb9dcd105895fb \
--profile deali-security \
--nodegroup-name khy-cluster-nodegroup \
--node-type t3.micro
```

다른 AZ에 있는 최소 2개의 public subnet or private subnet을 지정해줘야함 

→ _Amazon EKS는 최소 2개의 가용 영역에 서브넷이 필요하며, 노드와의 제어 플레인 통신을 용이하게 하기 위해 이러한 서브넷에 최대 4개의 네트워크 인터페이스를 생성합니다._ 

⇢ API 서버 다중 AZ때문인가?? etcd는??

> **오류 발생**
![](../img/스크린샷 2022-06-13 오후 2.46.09.png)
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
![](../img/스크린샷 2022-06-13 오후 4.30.44.png)
### 노드 상태 확인
```shell
kubectl get nodes
```
![](../img/스크린샷 2022-06-13 오후 4.31.03.png)

### Control Plane & Data Plane / Master Node & Worker Node
#### Control Plane => master node에서 돌어감?
* AWS가 관리하는 계정에서 실행
* worker node와 pod를 관리
* 구성요소: api server, etcd, scheduler, controller mamager
### 워크로드
#### Deployment
pod와 replicaset에 대한 선언적인 업데이트</br>
파드를 정의
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
context마다 네이스페이스를 지정할 수 있음</br>
각 파드는 네임스페이스에 속할 수 있으며 노드는 네임스페이스에 속할 수 없음</br>
하나의 파드는 하나의 네임스페이스에 속한다
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
Auto Scaling 그룹으로 프로비저닝</br>
노드 그룹은 서비스별로 나눠도 되고 타입별로 나눠도 됨
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

### EKS config yaml 배포
```shell
eksctl create cluster -f cluster.yaml --profile deali-security
eksctl upgrade cluster -f cluster.yaml --profile deali-security
eksctl delete cluster -f cluster.yaml --profile deali-security
```
`Error: the watcher channel for the nodes was closed by Kubernetes due to an unknown error`
=> Nat Gateway 없어서
### nginx 서버 배포
```shell
kubectl apply -f ~/Service-Mesh/EKS/nginx-deployment.yaml
```
### service(load balancer) 배포
```shell
kubectl apply -f ~/Service-Mesh/EKS/nginx-svc.yaml
```
nginx 연결 성공

### apache(httpd) 서버 배포
```shell
kubectl apply -f ~/Service-Mesh/EKS/apache-deployment.yaml
```
### apache(httpd) service(load balancer) 배포
```shell
kubectl apply -f ~/Service-Mesh/EKS/apache-svc.yaml
```
httpd 연결 성공

### unhealthy
ingress path를 /khy/nginx -> /nginx로 변경해줬더니 unhealthy가 됐다!</br>
ingress controller nlb의 타겟그룹은 unhealty</br>
나머지 서비스 nlb의 타겟그룹은 healthy -> 접속 잘됨</br>
#### ingress-nginx-controller 파드 로그
```shell
-------------------------------------------------------------------------------
NGINX Ingress controller
  Release:       v0.35.0
  Build:         54ad65e32bcab32791ab18531a838d1c0f0811ef
  Repository:    https://github.com/kubernetes/ingress-nginx
  nginx version: nginx/1.19.2

-------------------------------------------------------------------------------

I0615 07:53:50.709422       8 flags.go:205] Watching for Ingress class: nginx
W0615 07:53:50.709462       8 flags.go:210] Ingresses with an empty class will also be processed by this Ingress controllernginx
W0615 07:53:50.709655       8 flags.go:252] SSL certificate chain completion is disabled (--enable-ssl-chain-completion=false)
W0615 07:53:50.709691       8 client_config.go:552] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
I0615 07:53:50.709872       8 main.go:231] Creating API client for https://10.100.0.1:443
I0615 07:53:50.724190       8 main.go:275] Running in Kubernetes cluster version v1.22+ (v1.22.9-eks-a64ea69) - git (clean) commit 540410f9a2e24b7a2a870ebfacb3212744b5f878 - platform linux/amd64
I0615 07:53:51.288356       8 main.go:105] SSL fake certificate created /etc/ingress-controller/ssl/default-fake-certificate.pem
I0615 07:53:51.292403       8 main.go:113] Enabling new Ingress features available since Kubernetes v1.18
W0615 07:53:51.294541       8 main.go:125] No IngressClass resource with name nginx found. Only annotation will be used.
I0615 07:53:51.298354       8 ssl.go:528] loading tls certificate from certificate path /usr/local/certificates/cert and key path /usr/local/certificates/key
I0615 07:53:51.352501       8 nginx.go:263] Starting NGINX Ingress controller
I0615 07:53:51.372431       8 event.go:278] Event(v1.ObjectReference{Kind:"ConfigMap", Namespace:"ingress-nginx", Name:"ingress-nginx-controller", UID:"da7c4862-49b2-47b7-9b2e-6fad1e7cab37", APIVersion:"v1", ResourceVersion:"54475", FieldPath:""}): type: 'Normal' reason: 'CREATE' ConfigMap ingress-nginx/ingress-nginx-controller
E0615 07:53:52.458276       8 reflector.go:178] k8s.io/client-go@v0.18.6/tools/cache/reflector.go:125: Failed to list *v1beta1.Ingress: the server could not find the requested resource
E0615 07:53:53.889728       8 reflector.go:178] k8s.io/client-go@v0.18.6/tools/cache/reflector.go:125: Failed to list *v1beta1.Ingress: the server could not find the requested resource
E0615 07:53:57.003405       8 reflector.go:178] k8s.io/client-go@v0.18.6/tools/cache/reflector.go:125: Failed to list *v1beta1.Ingress: the server could not find the requested resource
E0615 07:54:03.353975       8 reflector.go:178] k8s.io/client-go@v0.18.6/tools/cache/reflector.go:125: Failed to list *v1beta1.Ingress: the server could not find the requested resource
E0615 07:54:13.603136       8 reflector.go:178] k8s.io/client-go@v0.18.6/tools/cache/reflector.go:125: Failed to list *v1beta1.Ingress: the server could not find the requested resource
E0615 07:54:32.235258       8 reflector.go:178] k8s.io/client-go@v0.18.6/tools/cache/reflector.go:125: Failed to list *v1beta1.Ingress: the server could not find the requested resource
I0615 07:54:46.465460       8 main.go:179] Received SIGTERM, shutting down
I0615 07:54:46.465487       8 nginx.go:380] Shutting down controller queues
I0615 07:54:46.465509       8 status.go:118] updating status of Ingress rules (remove)
E0615 07:54:46.465932       8 store.go:186] timed out waiting for caches to sync
I0615 07:54:46.465971       8 nginx.go:307] Starting NGINX process
I0615 07:54:46.466543       8 leaderelection.go:242] attempting to acquire leader lease  ingress-nginx/ingress-controller-leader-nginx...
E0615 07:54:46.468741       8 queue.go:78] queue has been shutdown, failed to enqueue: &ObjectMeta{Name:initial-sync,GenerateName:,Namespace:,SelfLink:,UID:,ResourceVersion:,Generation:0,CreationTimestamp:0001-01-01 00:00:00 +0000 UTC,DeletionTimestamp:<nil>,DeletionGracePeriodSeconds:nil,Labels:map[string]string{},Annotations:map[string]string{},OwnerReferences:[]OwnerReference{},Finalizers:[],ClusterName:,ManagedFields:[]ManagedFieldsEntry{},}
I0615 07:54:46.468831       8 nginx.go:327] Starting validation webhook on :8443 with keys /usr/local/certificates/cert /usr/local/certificates/key
I0615 07:54:46.497484       8 status.go:137] removing address from ingress status ([a1c1efd886d434c93af27946b1a7e206-b15a2cdf6ba9dcb1.elb.ap-northeast-2.amazonaws.com])
I0615 07:54:46.497517       8 nginx.go:388] Stopping admission controller
I0615 07:54:46.497547       8 nginx.go:396] Stopping NGINX process
E0615 07:54:46.497785       8 nginx.go:329] http: Server closed
I0615 07:54:46.499158       8 leaderelection.go:252] successfully acquired lease ingress-nginx/ingress-controller-leader-nginx
I0615 07:54:46.499211       8 status.go:86] new leader elected: ingress-nginx-controller-fb4747f56-qt8k2
E0615 07:54:46.499310       8 queue.go:78] queue has been shutdown, failed to enqueue: &ObjectMeta{Name:sync status,GenerateName:,Namespace:,SelfLink:,UID:,ResourceVersion:,Generation:0,CreationTimestamp:0001-01-01 00:00:00 +0000 UTC,DeletionTimestamp:<nil>,DeletionGracePeriodSeconds:nil,Labels:map[string]string{},Annotations:map[string]string{},OwnerReferences:[]OwnerReference{},Finalizers:[],ClusterName:,ManagedFields:[]ManagedFieldsEntry{},}
2022/06/15 07:54:46 [notice] 39#39: signal process started
I0615 07:54:50.506409       8 nginx.go:409] NGINX process has stopped
I0615 07:54:50.506444       8 main.go:187] Handled quit, awaiting Pod deletion
I0615 07:55:00.506615       8 main.go:190] Exiting with 0
```
ingress-controller.yaml 파일을 새 버전 & aws 용으로
#### ingress-controller의 타겟그룹에 2a만 healthy 뜨고 2b는 unhealthy 뜸
https://aws.amazon.com/ko/premiumsupport/knowledge-center/eks-unhealthy-worker-node-nginx/
</br> => ingress-controller-nlb.yaml에 ingress-nginx-controller service에 spec.externalTrafficPolicy를 Local에서 Cluster로 변경해주면 healthy가 뜸
</br> => 그래도 접속은 안됨
#### ingress-controller pod 로그
```shell
"Ignoring ingress because of error while validating ingress class" ingress="default/khy-ingress" error="ingress does not contain a valid IngressClass"
```
해결: ingress.yaml 에 annotation 추가
`kubernetes.io/ingress.class: "nginx"`
</br>=> 접속됨</br>
위에 unhealthy 해결 안하고 이거만 해결해도 접속은 됨 => ??</br>
> nginx ingress controller 파드 로그
> </br>`54.180.72.55 - - [16/Jun/2022:05:53:09 +0000] "GET /nginxTest HTTP/1.1" 200 615 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15" 440 0.003 [default-khy-nginx-nlb-80] [] 192.168.9.97:80 615 0.000 200 69621af0fc185a0a3926b289c5c48766`

출처: https://kubernetes.io/ko/docs/concepts/, https://aws.github.io/aws-eks-best-practices
