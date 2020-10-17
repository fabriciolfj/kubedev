### Curso kubedev


###### Multipass
**INSTALANDO MULTIPASS**
```
snap install multipass
```
**COMANDOS BÁSICOS**

- multipass launch -n k8s -c (cpu) 2 -m (ram) 4gb -d (disco) 20gb
- multipass list (lista as máquinas criadas)
- multipass shell k8s (acessar minha máquina)
- multipass exec k8s -- cat teste.txt (executar algum comando na maquina, sem entrar nela)
- multipass mount diretio da minha maquina k82:/externo (maquina:/diretorio que quero vincular ou mapear)
- multipass umount k8s (retirar o mapeamento)
- multipass info k8s
- multipass delete k8s
- multipass recover k8s
- multipass start k8s
- multipass delete k8s depois multipass purge, para eliminar realmente.

**INSTALANDO AMBIENTE KUBERNETES DENTRO DO MULTIPASS**

- multipass exec k8s -- sudo snap install microk8s --classic --channel=1.18/stable
- multipass exec k8s -- sudo usermod -a -G microk8s ubuntu
- multipass exec k8s -- sudo chown -f -R ubuntu ~/.kube
- multipass restart k8s

**TESTANDO AMBIENTE**

- multipass exec k8s -- /snap/bin/microk8s.kubectl create deployment nginx --image=nginx
- multipass exec k8s -- /snap/bin/microk8s.kubectl get pods

**ACESSANDO REMOTAMENTE**

- multipass exec k8s -- /snap/bin/microk8s.kubectl config view --raw (vai imprimir as configurações)

**ADICIONANDO UM NÓ**

- multipass shell k82, microk8s add-node

**REMOVENDO UM NÓ**

- multipass shell k8s, microk8s remove-node k8s2
- multipass hell k8s2, microk8s leave

**HABILITANDO RECURSOS**
- microk8s.enable ingress
- microk8s enable dns
- microk8s.enable storage
- microk8s enable metrics-server
- microk8s.enable istio

###### Azure
- az login 
- az aks get-credentials --resource-group kubedev --name kubedev --overwrite-existing (baixar as credenciais)

## Iniciando kubernetes

- Ao criar o manifesto, para saber qual api version utilizar em qual recurso, execute o comando abaixo e veja se possui algum dado na coluna apigroup. Caso esteja ausente, use v1.
```
kubectl api-resources
```

###### Apply recursivo
```
kubectl apply -f ./ -R
```

###### Redirecionando porta
```
kubectl port-forward pod/nome portalocal:portapod
```

###### Selecionando com base na label
```
kubectl get pods -l versao=verde
```

###### Aumentando o número de replcias.
```
kubectl scale replicaset nome do replicaset --replicas=10
```

###### Realizar rollout no deployment (voltar a versão)
```
kubectl rollout undo deployment meuprimeirodeployment
```

###### Mudando a imagem do deployment via linha de comando.
```
kubectl set image deployment meuprimeirodeployment meucontainer=kubedevio/nginx-color:blue
```

###### comandos diversos
```
kubectl get pods -o wide ## para mostrar mais detalhes do pod
```

###### Listando todos os deployments de todos os namespaces
```
kubectl get deployments --all-namespaces
```

###### Para acessar o serviço que está em outro namespace
```
http://nome do serviço.nome do namespace.svc.cluster.local
http://service-nginx-color.blue.svc.cluster.local
```
Para simplicicar o acesso, posso criar um service do tipo ExternalName:
```
apiVersion: v1
kind: Service
metadata:
  name: service-nginx-green
spec:
  type: ExternalName
  externalName: service-nginx-color.green.svc.cluster.local

```
###### Para ver quais recursos não são separados por namespace
```
kubectl api-resources --namespaced=false
```

##### Criando configmap e secret via comando
```
kubectl create configmap literal-configmap --from-literal=Mongo__Host=mongodb-service (usando chave valor)
kubectl create confimap file-configmap --from-file=prometheus.yaml (via arquivo)
kubectl create secret generic literal-secret --from-literal=MONGO_PWD=mongopwd (usando chave valor)
kubectl create secret generic file-secret --from-file=password.txt (via arquivo)
```

##### Os dados devem ser em base 64
```
echo -n 'linuxhint.com' | base64
echo 'bGludXhoaW50LmNvbQo=' | base64 --decode
```


###### Persistent volume

- Uso o persistent volume, vinculo a um persistent claim e vinculo este a um deployment.
- Para uso em multiplos nodes, use um storageclass, onde criará um pv dinâmico e distributído (os serviços de number provêm tal recurso).
Comandos:
```
kubectl get storageclass
kubectl get pv
kubectl get pvc
```
###### Recursos que são ou não separados por namespace

```
kubectl api-resources --namespaced=false ou true
```

###### StatefulSet -> outra forma de deploy
Quando necessito uma forma mais ordenada/sequencial a escalabilidade dos meus pods ou querer um volume por pod. Outro ponto que o stateful possui é o padrão de nomenclatura: nome do replicaset - ordem que estão escaladas (nginx-1 por exemplo).
O statefulset, no caso de replicas acima de 1, ele inicia a próxima réplica caso a anterior esteja up.


###### DaemonSet -> garante o número de réplicas com base no número de nós

##### Para rotinas batch
- Job - executa uma rotina
- CronJob - schedula uma rotina (use o site https://crontab-generator.org/ para geração do cron).


### Gerenciando a distribuição dos pods

###### Node selector
Uso labels no meu node no cluster e seletores na especificação do meu pod, para exigir que esse pod seja executado naquele node.

- Adicionando um label ao node:
```
kubectl label node k8s database=mongodb
```

- Para adicionar a label:
```
kubectl label node k8s database-
```
