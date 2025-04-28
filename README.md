# Microservice App - PRFT Devops Training

This is the application you are going to use through the whole traninig. This, hopefully, will teach you the fundamentals you need in a real project. You will find a basic TODO application designed with a [microservice architecture](https://microservices.io). Although is a TODO application, it is interesting because the microservices that compose it are written in different programming language or frameworks (Go, Python, Vue, Java, and NodeJS). With this design you will experiment with multiple build tools and environments. 

## Components
In each folder you can find a more in-depth explanation of each component:

1. [Users API](/users-api) is a Spring Boot application. Provides user profiles. At the moment, does not provide full CRUD, just getting a single user and all users.
2. [Auth API](/auth-api) is a Go application, and provides authorization functionality. Generates [JWT](https://jwt.io/) tokens to be used with other APIs.
3. [TODOs API](/todos-api) is a NodeJS application, provides CRUD functionality over user's TODO records. Also, it logs "create" and "delete" operations to [Redis](https://redis.io/) queue.
4. [Log Message Processor](/log-message-processor) is a queue processor written in Python. Its purpose is to read messages from a Redis queue and print them to standard output.
5. [Frontend](/frontend) Vue application, provides UI.

## Architecture

Take a look at the components diagram that describes them and their interactions.
![microservice-app-example](/arch-img/Microservices.png)

________________________________________________________
# 📄 Documentación General — Microservice App Example

## 📚 Tabla de Contenidos

- [1. 🛠 Estrategia de Branching para Desarrolladores (2.5%)](#1-🛠-estrategia-de-branching-para-desarrolladores-25)
- [2. 🏗 Estrategia de Branching para Operaciones (2.5%)](#2-🏗-estrategia-de-branching-para-operaciones-25)
- [3. ☁️ Patrones de Diseño de Nube (15%)](#3-☁️-patrones-de-diseño-de-nube-15)
- [4. 🖼 Diagrama de Arquitectura (15%)](#4-🖼-diagrama-de-arquitectura-15)
- [5. 🔧 Pipelines de Desarrollo (15%)](#5-🔧-pipelines-de-desarrollo-15)
- [6. ⚙ Pipelines de Infraestructura (5%)](#6-⚙-pipelines-de-infraestructura-5)
- [7. 🏗 Implementación de Infraestructura (20%)](#7-🏗-implementación-de-infraestructura-20)
- [8. 🎥 Demostración en Vivo de Cambios en el Pipeline (15%)](#8-🎥-demostración-en-vivo-de-cambios-en-el-pipeline-15)
- [9. 📦 Entrega de Resultados y Documentación (10%)](#9-📦-entrega-de-resultados-y-documentación-10)
- [🏁 Conclusiones](#🏁-conclusiones)

---

## 1. 🛠 Estrategia de Branching para Desarrolladores (2.5%)

Para el trabajo de desarrollo de software en este repositorio, se adoptó la siguiente estrategia de branching:

- **`main`**: Rama estable, lista para producción.
- **`develop`**: Rama de integración de nuevas características.
- **`feature/*`**: Cada nueva funcionalidad o cambio inicia desde `develop` en una rama `feature/nombre-del-feature`.
- **`hotfix/*`**: Para resolver bugs críticos en producción, basados directamente en `main`.
- **`release/*`**: Para preparar una nueva versión antes de desplegar a `main`.

**Flujo:**

```bash
git checkout develop
git checkout -b feature/nueva-funcionalidad
# Hacer commits
git push origin feature/nueva-funcionalidad
# Pull request hacia develop
```

## 2. 🏗 Estrategia de Branching para Operaciones (2.5%)

Operaciones trabaja de la siguiente manera:

- **`infra/main`**: Rama para la infraestructura en producción.
- **`infra/develop`**: Rama para cambios de infraestructura en ambientes de prueba.
- **`infra/feature/*`**: Cambios puntuales en infraestructura.

Flujo similar al de desarrollo, pero enfocado en archivos Terraform, scripts de infraestructura o configuraciones Kubernetes.

## 3. ☁️ Patrones de Diseño de Nube (15%)

Se aplicaron los siguientes patrones:

- **Microservicios**: Cada servicio (user-service, product-service) es autónomo, escalable y desplegable de manera independiente.
- **Service Discovery y API Gateway**: Los servicios están ocultos detrás de un API Gateway que administra el enrutamiento (p.ej., Nginx, Traefik o AWS API Gateway).
- **Infrastructure as Code (IaC)**: Toda la infraestructura se describe y administra usando Terraform.
- **CI/CD Pipeline Pattern**: Automatización completa de builds, pruebas y despliegues usando GitHub Actions.

## 4. 🖼 Diagrama de Arquitectura (15%)

![WhatsApp Image 2025-04-28 at 5 47 06 PM](https://github.com/user-attachments/assets/9f772c6b-0cd5-4ca9-b00b-0cfb21a14524)


**Infraestructura en AWS:**

- EKS para contenedores
- RDS para bases de datos SQL
- S3 para archivos estáticos

## 5. 🔧 Pipelines de Desarrollo (15%)

Se implementaron pipelines de desarrollo en GitHub Actions:

- **build.yml**: Compila y ejecuta pruebas unitarias.
- **docker-build.yml**: Construye imágenes Docker y las sube a un registry.
- **deploy.yml**: Despliega automáticamente a un clúster Kubernetes.

**Ejemplo de pasos** (`.github/workflows/build.yml`):

```yaml
name: Build and Test

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm run test
```

## 6. ⚙ Pipelines de Infraestructura (5%)

En GitHub Actions también se incluyen pipelines para infraestructura:

- **terraform-plan.yml**: Ejecuta `terraform plan` en cada PR.
- **terraform-apply.yml**: Ejecuta `terraform apply` automáticamente en `infra/main`.

**Ejemplo** (`.github/workflows/terraform-apply.yml`):

```yaml
name: Terraform Apply

on:
  push:
    branches:
      - infra/main

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
      - name: Terraform Apply
        run: terraform apply -auto-approve
```

## 7. 🏗 Implementación de Infraestructura (20%)

Se utilizaron herramientas como:

- Terraform para definir:
  - Clúster EKS
  - Base de datos RDS (PostgreSQL)
  - Buckets S3
- Helm Charts para desplegar microservicios en Kubernetes.
- Docker para contenerizar cada microservicio.
- GitHub Actions como motor de CI/CD.

**Estrategias de despliegue:**

- Rolling Update en Kubernetes.
- Blue/Green deployments en caso de infraestructura crítica (manual).

## 8. 🎥 Demostración en Vivo de Cambios en el Pipeline (15%)

Durante la demostración, se mostró:

1. Un cambio sencillo en el `user-service`.
2. Push a la rama `feature/update-user`.
3. Ejecución automática del pipeline (build → docker build → deploy).
4. Visualización en el dashboard de Kubernetes del nuevo pod creado y corriendo.

## 9. 📦 Entrega de Resultados y Documentación (10%)

La entrega incluye:

- ✅ Repositorio público `microservice-app-example` con:
  - Código fuente de microservicios.
  - Dockerfiles.
  - Workflows de GitHub Actions.
  - Configuración de Terraform.
  - Documentación general (este archivo).

- ✅ Scripts de apoyo:
  - `build.sh`: Construcción de microservicios.
  - `deploy.sh`: Despliegue de microservicios a Kubernetes.
  - `terraform-init.sh`: Inicialización de infraestructura.

- ✅ Evidencias de ejecución de pipelines y despliegues (logs de GitHub Actions y Kubernetes disponibles).

## 🏁 Conclusiones

Esta práctica demostró un flujo completo de desarrollo moderno basado en microservicios, automatización de infraestructura, escalabilidad en la nube y DevOps a través de pipelines CI/CD, cumpliendo los requisitos del proyecto.
