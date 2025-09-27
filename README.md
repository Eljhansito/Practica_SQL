# Practica_SQL# KeepCoding – Entrega SQL

Entrega del módulo SQL aplicada a un caso de IVR. El trabajo abarca modelado, creación de esquema relacional y construcción de indicadores clave a nivel de llamada, con especial foco en limpieza de datos y agregaciones.

---

## 🧭 Alcance (en breve)
- **Modelado de datos**: diseño entidad–relación del dominio académico y de la IVR.
- **Esquema relacional**: definición de tablas y relaciones (claves primarias/foráneas).
- **Procesamiento analítico**: integración de ficheros de llamadas, módulos y pasos; generación de un detalle a nivel de paso y un resumen por llamada con métricas e indicadores (segmentación, idioma, duración, listas de módulos, identificación por documento/teléfono, indicadores de incidencias, y repetición de llamadas en ±24h).
- **Utilidades**: función de limpieza de enteros para estandarización de nulos.

---

## 🛠️ Herramientas utilizadas
- **BigQuery** (región EU) para el procesamiento analítico y construcción de indicadores.
- **PostgreSQL** para el esquema relacional acorde al diagrama.
- **TablePlus** como cliente de base de datos en pruebas locales/remotas.
- **Visual Studio Code** para edición y organización de scripts.

---

## 📦 Estructura del repositorio (simplificada)
```
.
├─ erd/                 # Diagrama (editable)
├─ postgres/            # DDL del esquema relacional
├─ bigquery/            # Scripts analíticos y transformaciones
└─ README.md
```

---

## 🔍 Metodología 
- Normalización de identificadores y tipos para joins consistentes.
- Limpieza de campos con trim/regex y homogenización de formatos.
- Selección del “primer dato válido” por llamada mediante funciones ventana.
- Agregación de atributos y construcción de flags de negocio (identificación, incidencias, repetición temporal).
- Consolidación final a una vista/tabla de resumen de llamada con métricas esenciales.
