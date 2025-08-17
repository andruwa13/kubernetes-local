# Victoria Metrics Operator - Збір метрик з ingress-nginx

Цей проєкт демонструє, як налаштувати `VMUser` для збору метрик з `ingress-nginx` за допомогою Victoria Metrics Operator.

## Що таке VMUser?

`VMUser` — це конфігуруємий ресурс, який дозволяє керувати користувачами та їхніми привілеями в рамках Victoria Metrics. За допомогою `VMUser` можна створювати користувачів з різними рівнями доступу до метрик та інших ресурсів.

Основні риси `VMUser`:
- **Керування користувачами**: Створення і управління користувачами в Victoria Metrics.
- **Контроль доступу**: Налаштування рівнів доступу для різних користувачів.
- **Інтеграція**: Підтримка інтеграції з іншими мікросервісами та інструментами через авторизованих користувачів.

## Вимоги

- Kubernetes кластер
- Встановлений Victoria Metrics Operator

## Настройка VMUser

Створіть файл конфігурації `VMUser` з наступним вмістом:

```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMUser
metadata:
  name: ingress-nginx-user
  namespace: ingress-nginx
spec:
  username: ingress-metrics-collector
  password: MySecurePassword123
  permissions:
    read: true
    write: false
  targets:
    - ingress-nginx:8428
  url: http://vmselect.ingress-nginx.svc:8428
  tlsConfig:
    insecureSkipVerify: true
```

Цей `VMUser` конфігураційний файл створює користувача з іменем `ingress-metrics-collector`, який має права лише на читання метрик.

## Пояснення конфігурації

- `username`: Ім'я користувача для підключення до Victoria Metrics.
- `password`: Пароль для підключення користувача.
- `permissions`: Права доступу користувача.
    - `read`: Дозвіл на читання метрик (true).
    - `write`: Дозвіл на запис метрик (false).
- `targets`: Список таргетів, для яких користувач має доступ.
- `url`: URL сервера Victoria Metrics.
- `tlsConfig`: Налаштування TLS.
    - `insecureSkipVerify`: Пропуск перевірки сертифікатів (true).

## Деплой конфігурації

Створіть ресурс в Kubernetes кластері за допомогою наступної команди:
```sh
kubectl apply -f your-vmuser-file.yaml
```

Замість `your-vmuser-file.yaml` використайте назву вашого файлу конфігурації.

## Висновок

Тепер ваш `VMUser` налаштован для доступу до збору метрик з `ingress-nginx`. Використовуйте наданого користувача для підключення до Victoria Metrics і спостереження за метриками!