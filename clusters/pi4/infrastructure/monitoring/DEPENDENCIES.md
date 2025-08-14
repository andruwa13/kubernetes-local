# Залежності компонентів моніторингу

## Діаграма залежностей

```
prometheus-operator-crds
├── victoria-metrics-operator
│   └── vmcluster (VMCluster CRD)
├── kube-state-metrics
└── node-exporter
```

## Детальний опис залежностей

### 1. prometheus-operator-crds
- **Залежності**: немає
- **Призначення**: Встановлює CRD (Custom Resource Definitions) для Prometheus Operator
- **Namespace**: vm
- **Чарт**: prometheus-operator-crds

### 2. victoria-metrics-operator
- **Залежності**: prometheus-operator-crds
- **Призначення**: Встановлює Victoria Metrics Operator
- **Namespace**: vm
- **Чарт**: victoria-metrics-operator

### 3. vmcluster
- **Залежності**: victoria-metrics-operator
- **Призначення**: Створює Victoria Metrics Cluster
- **Namespace**: vm
- **Тип**: Custom Resource (VMCluster)

### 4. kube-state-metrics
- **Залежності**: prometheus-operator-crds
- **Призначення**: Експортує метрики стану Kubernetes об'єктів
- **Namespace**: vm
- **Чарт**: kube-state-metrics

### 5. node-exporter
- **Залежності**: prometheus-operator-crds
- **Призначення**: Експортує системні метрики з вузлів
- **Namespace**: vm
- **Чарт**: prometheus-node-exporter

## Порядок розгортання

1. **prometheus-operator-crds** - перший
2. **victoria-metrics-operator** - після CRDs
3. **vmcluster** - після оператора
4. **kube-state-metrics** - паралельно з victoria-metrics-operator
5. **node-exporter** - паралельно з victoria-metrics-operator

## Перевірка залежностей

```bash
# Перевірка статусу HelmRelease
kubectl get helmrelease -n vm

# Перевірка залежностей
kubectl describe helmrelease victoria-metrics-operator -n vm
kubectl describe helmrelease vmcluster -n vm

# Перевірка подів
kubectl get pods -n vm
```

## Troubleshooting

### Якщо victoria-metrics-operator не запускається:
1. Перевірте, чи встановлені CRDs:
```bash
kubectl get crd | grep prometheus
```

2. Перевірте статус prometheus-operator-crds:
```bash
kubectl get helmrelease prometheus-operator-crds -n vm
```

### Якщо vmcluster не створюється:
1. Перевірте, чи працює victoria-metrics-operator:
```bash
kubectl get pods -n vm -l app.kubernetes.io/name=victoria-metrics-operator
```

2. Перевірте CRD для VMCluster:
```bash
kubectl get crd | grep victoriametrics
```
