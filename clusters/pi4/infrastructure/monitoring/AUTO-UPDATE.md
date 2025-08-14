# Автооновлення для Dev середовища

## Налаштування

У dev середовищі налаштовано автоматичне оновлення всіх компонентів з наступними параметрами:

### Частота перевірки
- **Interval**: 1 хвилина (замість стандартних 2-5 хвилин)
- **Timeout**: 5-10 хвилин залежно від компонента

### Стратегія оновлення
- **Strategy**: Recreate (для швидкого оновлення)
- **Remediation**: 3 спроби при помилках
- **CRDs**: CreateReplace для операторів

## Компоненти з автооновленням

### Інфраструктура
- **ingress-nginx**: 4.11.3+
- **victoria-metrics-operator**: 0.36.0+
- **prometheus-operator-crds**: 16.0.0+
- **kube-state-metrics**: 5.27.0+
- **node-exporter**: 4.42.0+

### Застосунки
- **home-assistant**: 0.3.13+
- **gitlab-agent**: автооновлення вже налаштоване

## ImagePolicy налаштування

```yaml
# Приклад для victoria-metrics-operator
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: victoria-metrics-operator
  namespace: vm
spec:
  imageRepositoryRef:
    name: victoria-metrics-operator
  policy:
    semver:
      range: '>=0.36.0'  # Оновлює до новіших версій
```

## ImageUpdateAutomation

Автоматично оновлює версії в Git репозиторії:
- **Interval**: 1 хвилина
- **Branch**: main
- **Strategy**: Setters
- **Path**: ./clusters/pi4/infrastructure/monitoring

## Перевірка статусу

```bash
# Перевірка HelmRelease
kubectl get helmrelease -n vm
kubectl get helmrelease -n ingress-nginx
kubectl get helmrelease -n home-assistant

# Перевірка ImagePolicy
kubectl get imagepolicy -n vm

# Перевірка ImageUpdateAutomation
kubectl get imageupdateautomation -n vm

# Перевірка логів оновлення
kubectl logs -n flux-system -l app.kubernetes.io/name=flux
```

## Відключення автооновлення

Для відключення автооновлення в конкретному компоненті:

1. Змініть `interval` на більше значення (наприклад, `24h`)
2. Видаліть `upgrade.strategy: Recreate`
3. Видаліть `ImagePolicy` для цього компонента

## Troubleshooting

### Якщо оновлення не працює:
1. Перевірте статус ImagePolicy:
```bash
kubectl describe imagepolicy victoria-metrics-operator -n vm
```

2. Перевірте логи ImageUpdateAutomation:
```bash
kubectl logs -n flux-system -l app.kubernetes.io/name=flux | grep image
```

3. Перевірте права доступу до Git репозиторію

### Якщо оновлення займає забагато часу:
1. Збільшіть `timeout` в HelmRelease
2. Перевірте мережеве з'єднання
3. Перевірте доступність Helm репозиторіїв
