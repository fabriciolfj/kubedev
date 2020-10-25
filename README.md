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

**MONTANDO UM CLUSTER**
- Crie 2 maquinas e cada uma ja instalada no microk8s
- Entre no master e execute: microk8s add-node e copie o join
- Entre no node filho e execute: microk8s join 10.249.20.132:25000/QaOdTZSVnyKWVioYSiGqrHpxhzENAaRI (join vindo do master)

**TESTANDO AMBIENTE**

- multipass exec k8s -- /snap/bin/microk8s.kubectl create deployment nginx --image=nginx
- multipass exec k8s -- /snap/bin/microk8s.kubectl get pods

**ACESSANDO REMOTAMENTE**

- multipass exec k8s -- /snap/bin/microk8s.kubectl config view --raw (vai imprimir as configurações)
- abra a pasta .kube e no arquivo config, cole os dados.

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
```
kubectl port-forward service/nome portalocal:portapod
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

###### Node Affinity
Crio regras de obrigatoriedade ou preferência, no que tange, em que node meu pod executará.Exemplo: quero que o pod rode aonde possua hd ssd, mas se não existir, pode executar em um node com hd mecânico.

###### Pode affinity e Pode Antiaffinity
Regras de afinidade direto no pod, afim de definir para qual node o mesmo será schedulado. Exemplo: quero que meu pode seja schedulado, no mesmo node do redis.

###### Taint e Tolerations
Cria uma antiafinidade baseada no node, ou seja, o node que defini qual pode será executado nele. Exsitem 3 tipos de efeitos:
- no execute -> não seja executado no node. Há casos que foi agendado mas não será executado. (em um pode o master fica com essa opção ativa)
- before no scheduled -> o pod preferêncialmente não seja agendade neste node.
- no scheduled -> jamais seja agendade no node.

Tolerations: para o pod conseguir ser executado dentro de um taint, precisamos de um tolerations. Configuração:
```
tolerations:
        - key: "special" 
          operator: "Equal"
          value: "valor1"
          effect: "NoExecute" tolero node onde tenha um traint, com chave special, com valor equal valor1.
````

###### network policy
Inserir regras na comunicação entre pods, ou seja, bloqueio quem não pode ser acessado ou libero acesso a determinados pods.
Para habilitar o netowrk policy no microk8s, execute o comando abaixo:
-  microk8s.enable cilium

Para listar os networks policy
```
kubectl get networkpolicy
```
Observação:

```
  ingress:
    - from:
      - podSelector: #considero apenas pods deste namespace
          matchLabels:
            app: ubuntu
        namespaceSelector: #desta forma consigo acessar esse pod de outro namepsace
          matchLabels:
            ns: nginx
```
acima: aceito os pods com labels ubuntu no namespace nginx
```
  ingress:
    - from:
      - podSelector: #considero apenas pods deste namespace
          matchLabels:
            app: ubuntu
      - namespaceSelector: #desta forma consigo acessar esse pod de outro namepsace
          matchLabels:
            ns: nginx
```
acima: aceito os pods com labels ubuntu ou qualquer chamada do namespace nginx

###### Service account
- Conta própria do pod
- É boa prática criar um service account, com o minimo de permissão possível.
- Refinamento de permissões: RBAC, baseadas em regras (roles) e bindings (liga a permissão ao service account)
- Sempre que crio um pod e não específico um service account, cria-se um default automaticamente.
```
kubectl get secrets
```
###### Modo iterativo com pod
```
kubectl exec -i --tty k8s-dashboard-deploy-548794d697-c46td  -- /bin/bash
```

