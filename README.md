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

###### Azure
 - az login 

