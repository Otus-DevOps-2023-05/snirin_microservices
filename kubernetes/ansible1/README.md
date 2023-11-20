Пробная установка kubernetes по инструкции
https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-16-04-ru

Для запуска прописать IP в файле hosts

Список команд локально
```
ansible-playbook -i hosts full.yml
```

На мастере
```
kubectl get nodes;
sudo kubectl create deployment nginx --image=nginx;
kubectl get deployments;
kubectl expose deploy nginx --port 80 --target-port 80 --type NodePort;
kubectl get services;
curl http://worker_1_ip:nginx_port_from_get_services
kubectl delete service nginx;
kubectl get services;
kubectl delete deployment nginx;
kubectl get deployments;
```