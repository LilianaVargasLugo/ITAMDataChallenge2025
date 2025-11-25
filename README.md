# ITAMDataChallenge2025
Econometric analysis of Airbnb listings in CDMX to identify the top three neighborhoods with the highest investment potential.

---

## 1. Resumen del repositorio

Este repositorio contiene todo el material utilizado en el Data Challenge, cuyo objetivo es identificar las tres colonias de la Ciudad de México con mayor potencial de rendimiento para invertir en propiedades destinadas a Airbnb.  

Aquí se incluyen:

- **Bases de datos** Proporcionadas por el profesor de Airbnb y de la CDMX y las bases de datos externas que extrajo el equipo.  
- **Scripts de código** utilizados para limpieza, análisis estadístico y estimación de los dos modelos: precios hedónicos por colonia y gop por propiedad.  
- **Gráficos y tablas** generadas para el informe final.  
- **El documento final en PDF** conforme a los lineamientos del Data Challenge.

La estructura del repositorio es:

DataChallenge-Airbnb-CDMX

│  \
├── data  \
│ └── Bases CLEAN  \
│ └── Bases RAW  \
│  \
├── scripts  \
│ ├── Liliana Vargas   \
│ ├── Alexis Capdevielle   \
│ └── Aldo Muller    \
│  \
├── outputs  \
│ ├── figures  \
│ └── tables  \
│  \
├── report  \
│ └── DataChallenge_2025.pdf  \
│  \
└── README.md

---

## 2. Descripción de carpetas

### **`data/`**
- `clean/`: datos procesados y listos para análisis (por ejemplo `airbnb_cdmx_clean.csv`).

### **`scripts/`**
- `01_cleaning.R`: procesamiento, merges, creación de variables y limpieza general.  
- `02_analysis.R`: regresiones hedónicas OLS, tablas, descritivos.  
- `03_graphics.R`: mapas, distribuciones y gráficas finales para el informe.

### **`outputs/`**
- `figures/`: todas las gráficas incluidas en el PDF.  
- `tables/`: tablas exportadas si corresponde.

### **`report/`**
- `DataChallenge_2025.pdf`: documento final del reto.

---

## 3. Contribución de cada integrante

### **Alexis Capdevielle Harrison**
- Realizó la **búsqueda de bibliografía** (papers académicos) para fundamentar la estrategia econométrica.  
- Se encargó de la **estimación de los modelos econométricos**, incluyendo la versión final del modelo hedónico OLS.  
- Contribuyó al **5-pager**, especialmente en la parte metodológica y de interpretación de resultados.

---

### **Liliana Vargas Lugo**
- Participó en la **búsqueda de bibliografía** para justificar el enfoque empírico.  
- Realizó la **limpieza completa de la base de datos de Airbnb**, filtrado de anuncios y depuración de variables.  
- Hizo el **merge con la base geoespacial de la CDMX**, asignando cada listado a su polígono/colonia correspondiente.  
- Integró la **base externa**, calculó distancias promedio hacia lugares turísticos y generó métricas a nivel colonia.  
- Hizo el **merge con la base de claves de colonias** para estandarizar identificadores.  
- Contribuyó al **5-pager**, incluyendo narrativa, estructura y secciones descriptivas.  
- Creó y ordenó el **repositorio completo** en GitHub.

---

### **Aldo Muller Quintero**
- Buscó y procesó la **base externa de crimen** a nivel colonia para incorporarla en el modelo.  
- Estimó el **indicador de ingreso potencial por colonia** usado en el ranking final.  
- Contribuyó al **5-pager**, principalmente en la interpretación y motivación del indicador de rendimiento.  
- Generó los **mapas de calor de la ciudad**, mostrando las colonias con mayor potencial.

---

## 4. Uso de herramientas de IA

El equipo utilizó herramientas de IA generativa exclusivamente para:

- Apoyar en la estructura y explicación del modelo hedónico del paper principal.  
- Revisar la estructura de LaTeX del documento final.  
- Asistir en la documentación del repositorio y organización narrativa.  
- Explorar y resumir literatura relevante.
- Apoyo con el código para validar que el merge de las bases sea correcto

Todos los análisis, datos, modelos, cálculos, gráficos y decisiones metodológicas fueron realizados manualmente por el equipo.


---

## 5. Referencias

Merino, Juan José, y Edwin Muñoz-Rodríguez (2024).  
*Professional Airbnb Hosts in Mexico City: A First Approximation*.  
Documento de Trabajo, Centro de Estudios Económicos, El Colegio de México.


---

