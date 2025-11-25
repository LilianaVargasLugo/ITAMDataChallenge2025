# ITAMDataChallenge2025
Econometric analysis of Airbnb listings in CDMX to identify the top three neighborhoods with the highest investment potential.

---

## 1. Resumen del repositorio

Este repositorio contiene todo el material utilizado en el Data Challenge, cuyo objetivo es identificar las tres colonias de la Ciudad de México con mayor potencial de rendimiento para invertir en propiedades destinadas a Airbnb.  

Aquí se incluyen:

- **Bases de datos** Proporcionadas por el profesor de Airbnb y de la CDMX y las bases de datos externas que extrajo el equipo.  
- **Scripts de código** utilizados para limpieza, análisis estadístico y estimación de los dos modelos: precios hedónicos por colonia y gop por propiedad.  
- **Gráficos y tablas** generadas para el informe final.  
- **El documento final en PDF** conforme a los lineamientos del Data Challenge. Está compuesto de la siguiente manera: el resumen ejecutivo es la primera hoja, después viene el reporte y aparte incluimos un anexo metodológico en donde detallamos información que creemos que no es tan relevante para un inversionista pero que si aporta en el plano académico.

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
├── report  \
│ └── DataChallenge_2025.pdf  \
│  \
└── README.md


## 2. Contribución de cada integrante

### **Alexis Capdevielle Harrison**
- Realizó la **búsqueda de bibliografía** (papers académicos) para fundamentar la estrategia econométrica.
- Hizo el planteamiento teórico de los modelos a estimar, tanto a nivel propiedad como a nivel colonia y métricas de rentabilidad.
- Se encargó de la **estimación de los modelos econométricos**, incluyendo la versión final del modelo hedónico OLS.  
- Contribuyó al **5-pager**, especialmente en la introducción, resumen ejecutivo, parte metodológica y de interpretación de resultados.

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
- Buscó y procesó la **base externa de crimen y de metro y metrobus** a nivel colonia para incorporarla en el modelo.
- Buscó y procesó la base externa de estaciones de metro y metrobus a nivel colonia para incorporarla en el modelo usando QGIS, e hizo el merge con la base geoespacial de la CDMX, asignando cada listado a su polígono/colonia correspondiente.
- Procesó la **base externa de precios de m2 promedio** del  artículo "Gentrification and access to housing in Mexico City during 2000 to 2022" a nivel colonia para incorporarla en el modelo y estimar un costo de adquisición e hizo el merge con la base geoespacial de la CDMX, asignando cada listado a su polígono/colonia correspondiente. 
- Estimó el indicador de número de Airbnbs por colonia. 
- Contribuyó al **5-pager**, principalmente en la interpretación y motivación del indicador de rendimiento.  
- Generó los **mapas de calor de la ciudad**, mostrando las colonias con mayor potencial.
### **Victor Zamora**
- Encontró la **base externa de precios de m2 promedio" del artículo "Gentrification and access to housing in Mexico City during 2000 to 2022" de PNAS. 
- Encontró un par de artículos académicos para la revisión de literatura.
---

## 3. Uso de herramientas de IA

El equipo utilizó herramientas de IA generativa exclusivamente para:

- Apoyar en la estructura y explicación del modelo hedónico del paper principal.  
- Revisar la estructura de LaTeX del documento final.  
- Asistir en la documentación del repositorio y organización narrativa.  
- Explorar y resumir literatura relevante.
- Apoyo con el código para validar que el merge de las bases sea correcto

Todos los análisis, datos, modelos, cálculos, gráficos y decisiones metodológicas fueron realizados manualmente por el equipo.


---

## 4. Referencias

López Tamayo, Diego Alberto y Aurora A. Ramírez-Álvarez (2021)
*Análisis de Precios Hedónicos para AIRBNB en la CDMX*
Documento de Trabajo, Centro de Estudios Económicos, El Colegio de México.
Merino, Juan José, y Edwin Muñoz-Rodríguez (2024).  

*Professional Airbnb Hosts in Mexico City: A First Approximation*.  
Documento de Trabajo, Centro de Estudios Económicos, El Colegio de México.

Aguilar-Velázquez, D., Rivera Islas, I., Romero Tecua, G., & Valenzuela-Aguilera, A. (2024). Gentrification and access to housing in Mexico City during 2000 to 2022. Proceedings of the National Academy of Sciences of the United States of America, 121(10), Article e2314455121. https://doi.org/10.1073/pnas.2314455121
---

