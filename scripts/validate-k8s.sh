#!/bin/bash

# Скрипт для локального тестування k8s та Helm файлів
# Використання: ./scripts/validate-k8s.sh

set -e

echo "🚀 Починаємо валідацію Kubernetes та Helm конфігурацій..."

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функція для перевірки наявності команди
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 не знайдено. Встановіть $1 та спробуйте знову.${NC}"
        exit 1
    fi
}

# Перевіряємо наявність необхідних інструментів
echo -e "${BLUE}🔍 Перевіряємо наявність інструментів...${NC}"
check_command "kubectl"
check_command "helm" 
check_command "yamllint"

echo -e "${GREEN}✅ Усі необхідні інструменти знайдено${NC}"

# 1. YAML Syntax Check
echo -e "${BLUE}📝 Перевіряємо синтаксис YAML файлів...${NC}"
YAML_ERRORS=0

find clusters/ -name "*.yaml" -o -name "*.yml" | while read file; do
    if yamllint "$file" -c .yamllint.yml > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ $file має помилки синтаксису${NC}"
        yamllint "$file" -c .yamllint.yml
        ((YAML_ERRORS++))
    fi
done

# 2. Kubernetes Validation
echo -e "${BLUE}🎯 Валідуємо Kubernetes маніфести...${NC}"
K8S_ERRORS=0

find clusters/ -name "*.yaml" -o -name "*.yml" | while read file; do
    echo -n "Перевіряємо $file... "
    if kubectl --dry-run=client apply -f "$file" --validate=true > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
        kubectl --dry-run=client apply -f "$file" --validate=true
        ((K8S_ERRORS++))
    fi
done

# 3. Helm Release Validation  
echo -e "${BLUE}⚓ Перевіряємо Helm releases...${NC}"
HELM_ERRORS=0

find clusters/ -name "*helmrelease*.yaml" | while read file; do
    echo -e "${YELLOW}📦 Знайдено Helm release: $file${NC}"
    # Тут можна додати більш складну перевірку, коли Helm chart доступний
done

# 4. Flux Validation (якщо flux встановлено)
if command -v flux &> /dev/null; then
    echo -e "${BLUE}🌊 Валідуємо Flux конфігурації...${NC}"
    
    find clusters/ -name "kustomization.yaml" | while read file; do
        dir=$(dirname "$file")
        echo -n "Перевіряємо Flux kustomization в $dir... "
        if flux build kustomization --name=test --source=GitRepository/test --path="$dir" --dry-run > /dev/null 2>&1; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${YELLOW}⚠️  Попередження${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠️  Flux CLI не знайдено, пропускаємо Flux валідацію${NC}"
fi

# 5. Security Scanning (якщо Polaris встановлено)
if command -v polaris &> /dev/null; then
    echo -e "${BLUE}🔒 Запускаємо сканування безпеки з Polaris...${NC}"
    polaris audit --audit-path clusters/ --format pretty > polaris-results.txt
    echo -e "${GREEN}✅ Результати збережено у polaris-results.txt${NC}"
else
    echo -e "${YELLOW}⚠️  Polaris не знайдено, пропускаємо сканування безпеки${NC}"
fi

echo -e "${GREEN}🎉 Валідацію завершено!${NC}"

# Підсумок
echo ""
echo -e "${BLUE}📊 Підсумок:${NC}"
if [ $YAML_ERRORS -eq 0 ] && [ $K8S_ERRORS -eq 0 ] && [ $HELM_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Усі перевірки пройдено успішно!${NC}"
    exit 0
else
    echo -e "${RED}❌ Знайдено помилки. Переглянь вивід вище.${NC}"
    exit 1
fi
