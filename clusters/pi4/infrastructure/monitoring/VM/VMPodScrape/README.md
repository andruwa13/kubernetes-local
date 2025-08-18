# Victoria Metrics Operator - Збір метрик з ingress-nginx

Цей проєкт демонструє, як налаштувати `VMPodScrape` для збору метрик з `ingress-nginx` за допомогою Victoria Metrics Operator.

## Що таке VMPodScrape?

`VMPodScrape` — це конфігуруємий ресурс для збору метрик з подів у кластері Kubernetes за допомогою Victoria Metrics. Він дозволяє налаштовувати збирання метрик з конкретних подів з використанням шляхів, портів та інтервалів запитів.

Основні риси `VMPodScrape`:
- **Цільове джерело метрик**: Збір метрик безпосередньо з подів в Kubernetes.
- **Гнучкі налаштування**: Налаштування шляхів та портів для збору метрик.
- **Автоматизація**: Використання лейблів для автоматичного визначення цільових подів.

## Вимоги

- Kubernetes кластер
- Налаштований Ingress NGINX
- Встановлений Victoria Metrics Operator

## Настройка VMPodScrape

Створіть файл конфігурації `VMPodScrape` з наступним вмістом:

```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMPodScrape
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  jobLabel: ingress-nginx
  targetLabels:
    - pod
  podMetricsEndpoints:
    - port: metrics
      interval: 30s
      path: /metrics
      scrapeTimeout: 10s
      scheme: http
      relabelings:
        - sourceLabels: [__meta_kubernetes_pod_label_app_kubernetes_io_instance]
          targetLabel: instance
        - sourceLabels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
          targetLabel: app
        - sourceLabels: [__meta_kubernetes_pod_name]
          targetLabel: pod
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
  namespaceSelector:
    matchNames:
      - ingress-nginx
```

Цей `VMPodScrape` конфігураційний файл сканує всі поди в неймспейсі `ingress-nginx`, які мають мітку `app.kubernetes.io/name: ingress-nginx`, збирає метрики з порту `metrics`, і виставляє їх на шлях `/metrics`.

## Пояснення конфігурації

- `jobLabel`: Лейбл завдання для збору метрик.
- `targetLabels`: Лейбли, які додаються до метрик.
- `podMetricsEndpoints`: Конфігурація для кінцевих точок метрик подів.
  - `port`: Порт для збору метрик (зазначено `metrics`).
  - `interval`: Інтервал збору метрик (30 секунд).
  - `path`: Шлях для отримання метрик (припустимий `/metrics`).
  - `scrapeTimeout`: Максимальний час очікування для збору метрик.
  - `scheme`: Схема для збору метрик (HTTP).
  - `relabelings`: Конфігурація для обробки/зміни лейблів метрик.
    - `sourceLabels`: Початкові лейбли метрик.
    - `targetLabel`: Цільовий лейбл.
- `selector`: Умови для вибору відповідних подів.
- `namespaceSelector`: Умови для вибору неймспейсу.

### Relabeling Examples

- `__meta_kubernetes_pod_label_app_kubernetes_io_instance` перетворюється на `instance`.
- `__meta_kubernetes_pod_label_app_kubernetes_io_name` перетворюється на `app`.
- `__meta_kubernetes_pod_name` перетворюється на `pod`.

## Деплой конфігурації

Створіть ресурс в Kubernetes кластері за допомогою наступної команди:
```sh
kubectl apply -f your-vmpodscrape-file.yaml
```

Замість `your-vmpodscrape-file.yaml` використайте назву вашого файлу конфігурації.

Обов’язково переконайтеся, що вказаний шлях та порт для збору метрик дійсні для вашої конфігурації `ingress-nginx`.

## Висновок

Тепер ваш `VMPodScrape` налаштован для збору метрик з `ingress-nginx`. Спостерігайте за своїми метриками в інтерфейсі Victoria Metrics!