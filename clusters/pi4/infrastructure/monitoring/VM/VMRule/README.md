# Victoria Metrics Operator - Збір метрик з ingress-nginx

Цей проєкт демонструє, як налаштувати `VMRule` для збору метрик з `ingress-nginx` за допомогою Victoria Metrics Operator.

## Що таке VMRule?

`VMRule` — це конфігуруємий ресурс для створення правил запису та алертів у Victoria Metrics. Він дозволяє налаштовувати правила агрегування метрик, створення обчислюваних метрик та налаштування алертуючих умов.

Основні риси `VMRule`:
- **Алерти**: Визначення умов для створення алертів на основі метрик.
- **Правила запису**: Створення нових метрик на основі існуючих.
- **Гнучкість конфігурації**: Підтримка складних логічних та математичних виразів для умов алертингу та створення нових метрик.

## Вимоги

- Kubernetes кластер
- Встановлений Victoria Metrics Operator

## Настройка VMRule

Створіть файл конфігурації `VMRule` з наступним вмістом:

```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMRule
metadata:
  name: ingress-nginx-rules
  namespace: ingress-nginx
spec:
  groups:
    - name: ingress-nginx.rules
      rules:
        - alert: HighRequestLatency
          expr: histogram_quantile(0.95, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket[5m])) by (le)) > 0.5
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: High request latency on {{ $labels.instance }}
            description: Request latency is above 0.5 seconds on {{ $labels.instance }}.

        - record: job:http_inprogress_requests:sum
          expr: sum by (job) (http_inprogress_requests)
```

Цей `VMRule` конфігураційний файл створює правило алертингу для високої латентності запитів та правило запису для обчислення нової метрики кількості поточних HTTP запитів.

## Пояснення конфігурації

- `groups`: Список груп правил.
  - `name`: Назва групи правил.
  - `rules`: Список правил у групі.
    - `alert`: Назва алерту.
    - `expr`: Виписане в PromQL вираз для визначення умови алерту/правила запису.
    - `for`: Час, протягом якого умова має бути істинною для генерації алерту.
    - `labels`: Додаткові лейбли для алерту.
    - `annotations`: Анотації для алерту, які можуть містити більше деталей.
    - `record`: Назва нової метрики для запису.
    - `expr`: Виписаний в PromQL вираз для визначення нової метрики.

### Приклад алерту

- `HighRequestLatency`: Алерт, який спрацьовує, якщо 95-й процентиль тривалості запиту перевищує 0.5 секунд.
  - `expr`: Використовує PromQL вираз для визначення умов.
  - `for`: Умова має бути істинною протягом 10 хвилин для генерації алерту.
  - `labels`: Лейбли, зокрема `severity: critical`.
  - `annotations`: Пояснення для алерту, яке включає опис та резюме.

### Приклад правила запису

- `job:http_inprogress_requests:sum`: Правило запису, яке обчислює суму поточних HTTP запитів для всіх робіт (jobs).

## Деплой конфігурації

Створіть ресурс в Kubernetes кластері за допомогою наступної команди:
```sh
kubectl apply -f your-vmrule-file.yaml
```

Замість `your-vmrule-file.yaml` використайте назву вашого файлу конфігурації.

## Висновок

Тепер ваш `VMRule` налаштован для створення алертів та нових правил запису метрик з `ingress-nginx`. Використовуйте створені правила для покращення моніторингу та обробки метрик у Victoria Metrics!