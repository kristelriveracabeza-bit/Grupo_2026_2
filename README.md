# Grupo_2026_2
# DermaCloud - Descripción Detallada del Flujo Arquitectónico

A continuación, se detalla el ciclo de vida y el flujo operativo extremo a extremo de la plataforma, dividida en sus fases de automatización, lógica de negocio, persistencia y observabilidad avanzada.

---

## **1. Ciclo de Vida: Integración y Despliegue Continuo (CI/CD)**

El ciclo de vida del sistema comienza en la fase de automatización de infraestructura y código:

* **Infraestructura como Código (IaC):** **Terraform** se encarga de "escribir", provisionar y replicar de forma automatizada toda la infraestructura de AWS (redes VPC, bases de datos y clústeres de servidores).
* **Seguridad Estática (DevSecOps):** Antes de desplegar en AWS, **Checkov** analiza estáticamente los archivos de Terraform para asegurar el cumplimiento de políticas de seguridad, evitando configuraciones inseguras como puertos expuestos o permisos excesivos de IAM.
* **Configuración Interna:** **Ansible** interviene posterior al aprovisionamiento para configurar internamente los sistemas operativos de los servidores y dejar listas las dependencias requeridas.
* **Empaquetado e Inmutabilidad:** El código fuente de los microservicios de la clínica se empaqueta en contenedores ligeros utilizando **Docker**, garantizando un comportamiento idéntico en desarrollo, pruebas y producción.
* **Orquestación del Pipeline:** **Jenkins** junto con **GitHub Actions** coordinan todo el flujo de CI/CD de punta a cabo:
  1. Cuando un desarrollador realiza un *push* de código, **SonarQube** analiza automáticamente la calidad y seguridad del software, detectando vulnerabilidades, bugs y *code smells* antes de continuar.
  2. Una vez superado el análisis de calidad, se compilan las imágenes Docker y se almacenan en **Amazon ECR**.
  3. Finalmente, se gatilla el despliegue automatizado en la nube (CD) garantizando cero tiempo de caída (*Zero Downtime*), protegiendo la atención continua de las citas de los pacientes.

---

## **2. Flujo Operativo en Tiempo de Ejecución (Run-Time)**

En el día a día, el procesamiento de las interacciones de los pacientes sigue una ruta estructurada a través de las capas de la arquitectura de AWS:

### **Capa de Presentación y Perímetro Seguro**
* El flujo se activa cuando el paciente ingresa a la aplicación web. **Amazon Route 53** resuelve las consultas DNS y **AWS WAF** protege el perímetro bloqueando amenazas del OWASP Top 10 y ataques DDoS.
* La solicitud es recibida por la Red de Entrega de Contenido (CDN) **Amazon CloudFront**, que sirve el frontend estático almacenado de forma segura en **Amazon S3** con baja latencia desde el borde de la red.

### **Capa Lógica, Microservicios y Orquestación**
* Para peticiones dinámicas (ej. agendar un turno), **Amazon API Gateway** actúa como puerta de entrada única. Valida la identidad del paciente interactuando con **Amazon Cognito** y gestiona las autorizaciones a través de políticas de **AWS IAM**.
* El tráfico validado se redirige al balanceador de carga **Application Load Balancer (ALB)** dentro de una VPC privada.
* El ALB distribuye las solicitudes de manera equitativa a los microservicios alojados en **Amazon ECS** y **Kubernetes (Amazon EKS)**:
  * El primer microservicio se especializa en la **Reserva de Citas Dermatológicas**.
  * El segundo microservicio administra la **Gestión de Pacientes y Especialistas**.
* Los microservicios operan con alta disponibilidad apoyándose en:
  * **Amazon ECR:** Para descargar las imágenes Docker correspondientes.
  * **AWS Auto Scaling:** Para escalar horizontalmente y añadir recursos elásticos de cómputo ante campañas masivas.
  * **AWS Cloud Map:** Para permitir el descubrimiento automático y dinámico de servicios a través de nombres lógicos, eliminando la necesidad de gestionar direcciones IP estáticas.

---

## **3. Capa de Datos, Mensajería y Asincronía**

* **Persistencia NoSQL:** Los perfiles de los usuarios, registros médicos e historias clínicas se consolidan en **Amazon DynamoDB**, que ofrece latencias de un solo dígito de milisegundo a escala, respaldado por snapshots centralizados con **AWS Backup**.
* **Caché y Filtrado de Alta Velocidad:** **Amazon ElastiCache (Redis)** agiliza en tiempo récord la visualización de los horarios y slots médicos disponibles, mientras que **Amazon OpenSearch** procesa las búsquedas de doctores mediante filtros avanzados de texto completo.
* **Mensajería Asíncrona Decoupled:** Cuando el sistema requiere ejecutar tareas intensivas en cómputo (como generar recetas dermatológicas en PDF o despachar notificaciones masivas), delega la carga a una arquitectura dirigida por eventos utilizando **Amazon SQS (FIFO)**, funciones **AWS Lambda** y **Amazon SNS**, garantizando que el hilo principal de la web nunca se bloquee ante el paciente.

---

## **4. Stack de Observabilidad Renovado y Gobernanza**

La integridad y el monitoreo transversal del ecosistema se gestionan mediante una suite especializada de observabilidad de vanguardia:

* **Recolección de Métricas:** **Prometheus** se encarga de recolectar métricas detalladas en tiempo real de todos los componentes de la infraestructura (clústeres de ECS, nodos de Kubernetes, balanceadores ALB, rendimiento de DynamoDB, ejecuciones de Lambda y el rendimiento interno de los microservicios). Proporciona almacenamiento de series temporales y motores de alarmas avanzadas.
* **Centralización de Logs:** **Grafana Loki** indexa de forma eficiente las trazas de logs de los contenedores y sistemas operativos de la clínica, disminuyendo los costes de almacenamiento y optimizando las búsquedas mediante metadatos compartidos.
* **Visualización Unificada:** **Grafana** centraliza el control operativo actuando como el tablero unificado principal. Correlaciona visualmente los tableros de métricas provenientes de Prometheus con los registros de logs estructurados en Loki, permitiendo realizar auditorías y encontrar cuellos de botella en minutos.
* **Auditoría de Configuración:** **AWS CloudTrail** opera de forma paralela registrando continuamente el 100% de las acciones administrativas y llamadas de API de la infraestructura para auditoría médica y forense forense.
* **Gestión de Secretos:** **AWS Secrets Manager** cuida las llaves de acceso cifradas de la plataforma, rotando credenciales de forma automática y protegiendo la conexión hacia las bases de datos o APIs externas.
* **Control Financiero:** **AWS Budgets** vigila de manera estricta el consumo financiero de todos los recursos elásticos de la clínica, despachando alertas tempranas al equipo de DevOps cuando los costes proyectados se aproximan a los presupuestos mensuales establecidos.
---
![Texto alternativo](https://raw.githubusercontent.com/USUARIO/REPOSITORIO/RAMA/ruta/Captura%20de%20pantalla%202026-06-28%20193627.png)
# Dermatologia (AWS + IaC)



## 0) Flujo Git

Ramas:
- main: solo releases (tags, por ejemplo v1.0.0)
- develop: integración
- feature/*: trabajo diario

Comandos sugeridos:
bash
```
git checkout -b feature/infra-inicial
git push -u origin feature/infra-inicial
git tag v1.0.0
git push --tags
```

---

## 1) Requisitos en tu PC

### 1.1 Software
Instalar:
- *Git*
- *Docker Desktop*
- *Python 3.11+*
- *Terraform 1.6+*
- *AWS CLI v2*

Verificación:
bash
```
git --version
docker --version
python --version
terraform -version
aws --version
```

### 1.2 Acceso AWS
Configurar credenciales "perfil":
bash
```
aws configure --profile seabook
aws sts get-caller-identity --profile dermatologia
```

---

## 2) Estructura de carpetas

- iac/: Infraestructura como Código (Terraform)
- src/: Microservicios, lambdas, frontend
- config/: scripts / ansible (.sh)
- serverapps/: SonarQube, Checkov, Jenkins, Grafana (local)

---

## 3) Desarrollo local para probar endpoints)

### 3.1 Microservicio Catálogo
bash
```
cd src/microservicios/catalogo
python -m venv .venv
# .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:api --host 0.0.0.0 --port 8001
```

Prueba:
bash
```
curl http://localhost:8001/salud
curl "http://localhost:8001/catalogo/buscar?q=aws"
```

### 3.2 Microservicio Reservas
bash
```
cd src/microservicios/reservas
python -m venv .venv
pip install -r requirements.txt
uvicorn app:api --host 0.0.0.0 --port 8002
```

Prueba:
bash
```
curl http://localhost:8002/salud
curl -X POST http://localhost:8002/reservas   -H "Content-Type: application/json"   -d '{"id_libro":"LIB-001","id_usuario":"USR-999"}'
```

> Advertencia : para publicar a "SNS" se requiere "SNS_TEMA_ARN" y credenciales AWS/IAM. Si no existe, la API devuelve error controlado.

---

## 4) Calidad de aplicación (SonarQube local)

En otra terminal:
bash
```
cd serverapps
docker compose -f docker-compose.sonarqube.yml up -d
```

Abrir:
- SonarQube: http://localhost:9000

Luego (ejemplo con Catálogo):
bash
```
cd src/microservicios/catalogo
pip install -r requirements-dev.txt
pytest -q --junitxml=reportes/junit.xml
sonar-scanner # Sonar scanner requiere token
```

---

## 5) Test de vulnerabilidades (Checkov con Docker Compose)

bash
```
cd serverapps
docker compose -f docker-compose.checkov.yml run --rm checkov
```

---

## 6) Infraestructura (Terraform) en AWS

### 6.1 Variables
# Dominio si se usa ACM/CloudFront con TLS
Copia:
bash
```
cd iac/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edita terraform.tfvars
- region
- prefijo
- dominio 
- certificado_acm_arn


### 6.2 Deploy
bash
```
cd iac/terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

### 6.3 Destroy
bash
```
terraform destroy
```

---

## 7) Observabilidad

### 7.1 Qué se demuestra
- Métricas: ECS (CPU/Memoria) + SQS (mensajes) + Dynamodb
- Logs: CloudWatch Logs + Logs Insights
- Trazas: X-Ray (microservicios y Lambda)
- Alertas: CloudWatch Alarms -> SNS (notificación)

### 7.2 Demostración final
1. Abrir Frontend CloudFront/S3 y ejecuta una búsqueda.
2. Crea una reserva ALB -> microservicio Reservas.
3. Verifica en CloudWatch:
   - Logs del servicio
   - Métrica de ECS - CPU/Memoria
4. Verificar en X-Ray:
   - Trace con correlation_id propagado
5. Generar una carga, varias reservas y mostrar:
   - Aumento de mensajes en SQS FIFO
   - Alarmas si supera umbral configurado

---

## 8) Archivos clave

- docs/PREVIEW_DESARROLLO.md: guía ordenada
- serverapps/docker-compose.*.yml: SonarQube, Grafana, Jenkins, Checkov
- iac/terraform/: IaC completa
