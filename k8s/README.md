## Orchestrating `helloworld` container on k8s

### Assumptions:

* Kubernetes (k8s) HA setup running on AWS managed via. [KOPS](https://github.com/kubernetes/kops).
* Ingress with `kube-ingress-aws-controller`. Refer [this URL for configuration](https://github.com/kubernetes/kops/blob/master/addons/kube-ingress-aws-controller/README.md).
* Status checks **ready**:

````
$ kops validate cluster
Using cluster from kubectl context: kops-spike.shyamsundar.org

Validating cluster kops-spike.shyamsundar.org

INSTANCE GROUPS
NAME			ROLE	MACHINETYPE	MIN	MAX	SUBNETS
bastions		Bastion	t2.micro	1	1	utility-us-west-2a,utility-us-west-2b,utility-us-west-2c
master-us-west-2a	Master	t2.large	1	1	us-west-2a
master-us-west-2b	Master	t2.large	1	1	us-west-2b
master-us-west-2c	Master	t2.large	1	1	us-west-2c
nodes			Node	t2.large	3	3	us-west-2a,us-west-2b,us-west-2c

NODE STATUS
NAME						ROLE	READY
ip-x-y-35-177.us-west-2.compute.internal	master	True
ip-x-y-42-188.us-west-2.compute.internal	node	True
ip-x-y-69-246.us-west-2.compute.internal	master	True
ip-x-y-72-157.us-west-2.compute.internal	node	True
ip-x-y-97-0.us-west-2.compute.internal	node	True
ip-x-y-99-227.us-west-2.compute.internal	master	True

Your cluster kops-spike.shyamsundar.org is ready
````
````
$ kubectl cluster-info
Kubernetes master is running at https://api.kops-spike.shyamsundar.org
KubeDNS is running at https://api.kops-spike.shyamsundar.org/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
````

### Creating `helloworld` Deployment:

In Kubernetes, a `Deployment` that configures a `ReplicaSet` is the recommended way to run a stateless application. `Service` can be configured for ingress within clusters and from external world. High-Availability and Scaling (Replicasets), Updates (Rolling Updates) can be easily updated at run-time.

The below deployment and service defenition file will create a deployment that has an replicaset of 3 pods (instances) of the `helloworld` application. They are exposed via ELB on both HTTP/HTTPS with a certificate referenced from AWS Certificate Manager (ACM). (Note: The SSL cert. ARN has to be updated with a real one before running this.)


````
$ cat helloworld-deployment-and-service.yml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: helloworld-deployment
spec:
  selector:
    matchLabels:
      app: helloworld
  replicas: 3
  template:
    metadata:
      labels:
        app: helloworld
    spec:
      containers:
      - name: helloworld
        image: shyam/helloworld:v1
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld-svc
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:us-west-2:xxxxx:certificate/xxxx-xxx-xxx-xxx-xxxx"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
spec:
  selector:
    app: helloworld
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 8080
    - name: https
      protocol: TCP
      port: 443
      targetPort: 8080
  type: LoadBalancer
````

The following command will create the deployment and configure the service. 

````
$ kubectl apply -f helloworld-deployment-and-service.yml
deployment "helloworld-deployment" created
service "helloworld-svc" created
````

Verify if the deployments, replicasets, pods and service are created.

````
$ kubectl get deployments
NAME                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
helloworld-deployment   3         3         3            3           2m
````

````
$ kubectl get rs
NAME                               DESIRED   CURRENT   READY     AGE
helloworld-deployment-5f7486f749   3         3         3         2m
````

````
$ kubectl get pods
NAME                                     READY     STATUS    RESTARTS   AGE
helloworld-deployment-5f7486f749-4rsm4   1/1       Running   0          3m
helloworld-deployment-5f7486f749-nhmxg   1/1       Running   0          3m
helloworld-deployment-5f7486f749-tqrpx   1/1       Running   0          3m
````

````
$ kubectl get svc
NAME             TYPE           CLUSTER-IP     EXTERNAL-IP        PORT(S)                      AGE
helloworld-svc   LoadBalancer   100.70.98.55   a61d978090f28...   80:32154/TCP,443:30310/TCP   3m
kubernetes       ClusterIP      100.64.0.1     <none>             443/TCP                      8d
````

Describe the service to get the ELB CNAME.

````
$ kubectl describe svc helloworld-svc
Name:                     helloworld-svc
Namespace:                default
Labels:                   <none>
Annotations:              kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"Service","metadata":{"annotations":{"service.beta.kubernetes.io/aws-load-balancer-backend-protocol":"http","service.beta.kub...
                          service.beta.kubernetes.io/aws-load-balancer-backend-protocol=http
                          service.beta.kubernetes.io/aws-load-balancer-ssl-cert=arn:aws:acm:us-west-2:xxxxx:certificate/xxxx-xxx-xxx-xxx-xxxx
                          service.beta.kubernetes.io/aws-load-balancer-ssl-ports=443
Selector:                 app=helloworld
Type:                     LoadBalancer
IP:                       100.70.98.55
LoadBalancer Ingress:     a61d978090f28XXXXXXXXXXXXXXXXXXXXX.us-west-2.elb.amazonaws.com
Port:                     http  80/TCP
TargetPort:               8080/TCP
NodePort:                 http  32154/TCP
Endpoints:                100.100.0.2:8080,100.108.0.2:8080,100.116.0.2:8080
Port:                     https  443/TCP
TargetPort:               8080/TCP
NodePort:                 https  30310/TCP
Endpoints:                100.100.0.2:8080,100.108.0.2:8080,100.116.0.2:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  4m    service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   4m    service-controller  Ensured load balancer
````

Finally visiting the ELB URL should yield a screen similar to the one below.

![Demo/Image](k8s-helloworld-elb-https.png) 