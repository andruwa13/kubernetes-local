# Розгортання Victoria Metrics

## Передумови

1. Flux CD встановлений та налаштований
2. Victoria Metrics Operator розгорнутий
3. Ingress Controller працює

## Вибір компонента

### VMCluster (рекомендований для production)
- Високодоступний кластер з розділенням на vmselect, vminsert, vmstorage
- Підходить для великих кластерів з високим навантаженням

### VMSingle (для тестування/малих кластерів)
- Простий single-instance
- Менше ресурсів, простіше налаштування

### VMAgent (для збору метрик)
- Агент для збору метрик з різних джерел
- Може працювати разом з VMCluster або VMSingle

## Кроки розгортання

### 1. Перевірка залежностей

```bash
# Перевірте, що Victoria Metrics Operator працює
kubectl get pods -n vm -l app.kubernetes.io/name=victoria-metrics-operator

# Перевірте, що Ingress Controller працює
kubectl get pods -n ingress-nginx
```

### 2. Налаштування компонентів

Відредагуйте `kustomization.yaml` та розкоментуйте потрібні компоненти:

```yaml
resources:
  - vmcluster.yaml
  # - vmagent.yaml  # Розкоментуйте якщо потрібен VMAgent
  # - vmsingle.yaml  # Розкоментуйте якщо потрібен VMSingle замість VMCluster
```

### 3. Розгортання через Flux

```bash
# Застосуйте конфігурацію
kubectl apply -k clusters/pi4/

# Або якщо використовуєте flux CLI
flux apply --kustomization pi4
```

### 4. Перевірка статусу

```bash
# VMCluster
kubectl get vmcluster -n vm
kubectl get pods -n vm -l app.kubernetes.io/name=vmcluster

# VMSingle
kubectl get vmsingle -n vm
kubectl get pods -n vm -l app.kubernetes.io/name=vmsingle

# VMAgent
kubectl get vmagent -n vm
kubectl get pods -n vm -l app.kubernetes.io/name=vmagent
```

### 5. Налаштування DNS

Додайте записи в ваш DNS або /etc/hosts:
```
<IP-адреса-кластера> vm.pi4.local
<IP-адреса-кластера> vmsingle.pi4.local
<IP-адреса-кластера> vmagent.pi4.local
```

### 6. Перевірка доступу

Відкрийте браузер та перейдіть на:
- VMCluster: `http://vm.pi4.local`
- VMSingle: `http://vmsingle.pi4.local`
- VMAgent: `http://vmagent.pi4.local`

## Troubleshooting

### Проблеми з storage

Якщо поди не запускаються через проблеми з storage:

1. Перевірте доступні StorageClass:
```bash
kubectl get storageclass
```

2. Оновіть конфігурацію з правильним `storageClassName`

### Проблеми з ресурсами

Якщо поди не запускаються через нестачу ресурсів:

1. Зменшіть ліміти в конфігурації
2. Або додайте більше ресурсів до кластера

### Проблеми з мережею

Якщо не можете доступитися до веб-інтерфейсу:

1. Перевірте Ingress:
```bash
kubectl get ingress -n vm
```

2. Перевірте логи Ingress Controller:
```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### Перевірка логів

```bash
# Логи VMCluster
kubectl logs -n vm -l app.kubernetes.io/name=vmcluster

# Логи VMSingle
kubectl logs -n vm -l app.kubernetes.io/name=vmsingle

# Логи VMAgent
kubectl logs -n vm -l app.kubernetes.io/name=vmagent
```
