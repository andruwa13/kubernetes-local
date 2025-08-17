# Файли Flux для cert-manager

На основі вашого прикладу з Home Assistant створені файли для cert-manager.

## Структура проекту

### Для Helm (cert-manager контролер):
```
infrastructure/controllers/cert-manager/
├── namespace.yaml                 # Namespace для cert-manager
├── helmrepository.yaml           # Helm репозиторій jetstack
├── helmrelease.yaml              # HelmRelease для cert-manager
└── kustomization.yaml            # Flux Kustomization для контролера
```

### Для Kustomize (cert-manager issuer для dev):
```
infrastructure/configs/cert-manager-issuer/dev/
├── clusterissuers.yaml           # ClusterIssuer ресурси
├── kustomization.yaml            # Kustomize конфігурація
└── flux-kustomization.yaml       # Flux Kustomization для issuer
```

## Опис файлів

### 1. namespace.yaml
Створює namespace `cert-manager` для компонентів.

### 2. helmrepository.yaml
Визначає Helm репозиторій jetstack у namespace `flux-system`.

### 3. helmrelease.yaml
Конфігурує cert-manager Helm release:
- Версія "1.x" з автооновленням
- installCRDs: true
- Оптимізовані ресурси для dev середовища
- Зменшені ресурси CPU/memory
- Відключений prometheus

### 4. kustomization.yaml (для контролера)
Flux Kustomization для розгортання cert-manager контролера:
- Перевіряє health check трьох deployment'ів
- Timeout 5 хвилин

### 5. clusterissuers.yaml
Містить два ClusterIssuer:
- `letsencrypt-staging-dev`: для Let's Encrypt staging (безпечно для тестів)
- `selfsigned-dev`: для self-signed сертифікатів

### 6. kustomization.yaml (для issuer)
Kustomize конфігурація з labels для dev середовища.

### 7. flux-kustomization.yaml
Flux Kustomization для issuer з залежністю від cert-manager контролера.

## Встановлення

1. Розмістіть файли згідно структури проекту
2. Додайте Flux Kustomization до основного flux-system
3. Змініть email у clusterissuers.yaml на ваш
4. Для production змініть staging URL на production у clusterissuers.yaml

## Використання

Після розгортання ви можете використовувати issuer в Certificate або Ingress:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-cert
  namespace: default
spec:
  secretName: example-cert-tls
  issuerRef:
    name: letsencrypt-staging-dev
    kind: ClusterIssuer
  dnsNames:
    - example.dev.com
```

Або в Ingress:
```yaml
annotations:
  cert-manager.io/cluster-issuer: letsencrypt-staging-dev
```