# Prueba de Conocimiento – Full Stack

Este repositorio contiene los entregables solicitados:

- **Frontend** (React + Vite)
- **Backend** (API REST en PHP)
- **SQL** (CRUD, consultas analíticas, scripts reproducibles)
- **Python** (análisis: promedio, top 3 clientes)
- **Diseño Web** (replicación HTML + CSS)
- **Moodle** (capturas de instalación local)

---

## 🚀 Guía de instalación y ejecución

### 1) Requisitos

**Comunes**
- Git  
- MySQL 
- Editor recomendado: VS Code  

**Backend (PHP)**
- PHP v8.3.26 con PDO MySQL habilitado  

**Frontend (React)**
- Node v20.17.0 y npm v10.8.2

**Analisis de datos (SQL + Python)**
- SQL v8.0.40 y python v3.12.6

### 2) Estructura esperada

2) Estructura esperada

2) Estructura esperada

```plaintext
├── Analytics/
│   ├── code.py
│   ├── .env.example
│   └── analyticsdb.sql
├── backend/
│   ├── api/
│   │   └── items.php
│   ├── cors.php
│   ├── db.php
│   └── .env.example
├── Diseno Web/
│   ├── index.html
│   ├── style.css
│   └── Assets/
├── evidencias_moodle/
│   ├── configuracion.pdf
│   └── vesion3.8.txt
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   └── App.jsx
│   │   ├── main.jsx
│   │   └── api.js
│   ├── styles.css
│   ├── index.css
│   └── vite.config.js          
├── sql/
│   └── crud_queries.sql
└── README.md
```

### 3) Clonar el repositorio
```bash
git clone <URL_DEL_REPOSITORIO>
cd Prueba-de-Conocimiento
```

### 4) Base de Datos
- Inicia MySQL y conéctate
- Ejecuta: sql/crud_queries.sql y analyticsdb.sql
- Verifica que existe la vista del reporte (o crea la vista): SELECT * FROM vw_reporte_clientes ORDER BY total DESC;


### 5) Inicio y instalacción de dependencias

**Backend**
```bash
php -S localhost:8080 -t backend
```
API base: http://localhost:8080/api/items.php

**Frontend**
```bash
npm install 
npm run dev
```
URL: http://localhost:5173

**Analisis de datos**
```bash
pip install mysql-connector-python
```
Ejecutar: python code.py

**Replicación Diseño Web**
<div style="page-break-after: always;"></div>
Abrir directamente en navegador: diseno_web/index.html

**Instalación Local de Moodle**
<div style="page-break-after: always;"></div>
Explicación completa con capturas en evidencias_moodle/
