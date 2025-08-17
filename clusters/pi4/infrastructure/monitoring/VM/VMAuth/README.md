# Victoria Metrics Operator - Збір метрик з ingress-nginx

Цей проєкт демонструє, як налаштувати `VMAuth` для управління доступом до метрик з `ingress-nginx` за допомогою Victoria Metrics Operator.

## Що таке VMAuth?

`VMAuth` — це конфігуруємий ресурс для налаштування та управління аутентифікацією та авторизацією доступу до метрик у Victoria Metrics. Він дозволяє створювати політики доступу та забезпечувати безпечний доступ до ваших метрик.

Основні риси `VMAuth`:
- **Управління доступом**: Створення правил аутентифікації та авторизації для доступу до метрик.
- **Інтеграція**: Підтримка інтеграції з різними сервісами для аутентифікації.
- **Гнучкість конфігурації**: Налаштування різних політик доступу для різних користувачів та сервісів.

## Вимоги

- Kubernetes кластер
- Встановлений Victoria Metrics Operator

## Настройка VMAuth

Створіть файл конфігурації `VMAuth` з наступним вмістом:

```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAuth
metadata:
  name: vmauth
  namespace: monitoring
spec:
  users:
  - user: "admin"
    password: "AdminSecurePassword"
    url_prefix: "http://vmselect.monitoring.svc:8481/select/0/prometheus"
    bearers:
    - "secureBearerToken"
    headers:
      - "X-Scope-OrgID: admin"
  - user: "reader"
    password: "ReaderSecurePassword"
    url_prefix: "http://vmselect.monitoring.svc:8481/select/0/prometheus"
    bearers:
    - "readerBearerToken"
    headers:
      - "X-Scope-OrgID: reader"
  auth:
    externalAuthURL: "https://auth-provider.com/validate"
    customHeaders:
      X-Custom-Header: "HeaderValue"
```

Цей `VMAuth` конфігураційний файл налаштовує двох користувачів (`admin` та `reader`) з різними URL-префіксами, Bearer-токенами та заголовками для аутентифікації.

## Пояснення конфігурації

- `users`: Перелік користувачів та їх політик доступу.
    - `user`: Ім'я користувача (`admin` або `reader`).
    - `password`: Пароль для доступу (замініть на ваші реальні значення).
    - `url_prefix`: URL-префікс для доступу до метрик.
    - `bearers`: Список Bearer-токенів для аутентифікації.
    - `headers`: Додаткові заголовки для запитів.
- `auth`: Налаштування зовнішньої аутентифікації.
    - `externalAuthURL`: URL для зовнішньої аутентифікації.
    - `customHeaders`: Користувацькі заголовки для зовнішньої аутентифікації.

## Деплой конфігурації

Створіть ресурс в Kubernetes кластері за допомогою наступної команди:
```sh
kubectl apply -f your-vmauth-file.yaml
```

Замість `your-vmauth-file.yaml` використайте назву вашого файлу конфігурації.

## Висновок

Тепер ваш `VMAuth` налаштований для управління доступом до метрик у Victoria Metrics. Використовуйте налаштовані політики доступу для безпечного управління та моніторингу метрик з `ingress-nginx`!