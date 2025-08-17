# Victoria Metrics Cluster

Цей каталог містить конфігурацію для Victoria Metrics, який працює як заміна Prometheus.

## Компоненти

- **VMCluster** - основний ресурс кластера (рекомендований для production)
- **VMSingle** - простий single-instance (для тестування або малих кластерів)
- **VMAgent** - агент для збору метрик

## Порты

### VMCluster
- `8481` - vmselect (веб-інтерфейс та API)
- `8480` - vminsert (прийом метрик)
- `8482` - vmstorage (зберігання даних)

### VMSingle
- `8428` - HTTP API та веб-інтерфейс

### VMAgent
- `8429` - HTTP API та веб-інтерфейс

## Налаштування

1. Змініть домени в конфігураціях на ваші
2. При потребі налаштуйте `storageClassName`
3. Змініть розміри storage відповідно до ваших потреб

## Доступ

Після розгортання Victoria Metrics буде доступна за адресами:
- VMCluster: `http://vm.pi4.local`
- VMSingle: `http://vmsingle.pi4.local`
- VMAgent: `http://vmagent.pi4.local`

## Моніторинг

Для перевірки статусу:
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

## Вибір компонента

- **VMCluster** - для production з високою доступністю
- **VMSingle** - для тестування або малих кластерів
- **VMAgent** - для збору метрик з різних джерел

## Інтеграція з Flux

Цей компонент автоматично розгортається через Flux CD разом з іншими компонентами моніторингу.
