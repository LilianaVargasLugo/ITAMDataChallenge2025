library(sf)
library(dplyr)
library(readr)
library(geosphere)

# =========================================================================
# === PARTE 1: CRUCE ESPACIAL (POINT-IN-POLYGON) ===
# =========================================================================

# 1. Cargar el GeoJSON de Colonias y la base de datos de Airbnb
# ⚠ADVERTENCIA: Revisa el path (ruta) y el nombre del archivo GeoJSON si es diferente
colonias_cdmx <- st_read("/Users/lily/Downloads/catlogo-de-colonias.json")

# Cargamos la base de datos limpia (CSV)
airbnb_final <- read_csv("/Users/lily/Downloads/airbnb_datos_finales_limpios.csv")

# 2. Convertir la Base de Airbnb a Puntos Espaciales
airbnb_puntos <- st_as_sf(
  airbnb_final,
  coords = c("longitud", "latitud"), # Orden (X, Y) o (longitud, latitud)
  crs = 4326 # WGS 84
)

# 3. Corregir Geometrías No Válidas (Para evitar el error "degenerate vertex")
colonias_cdmx_validas <- st_make_valid(colonias_cdmx)

# 4. Realizar la Unión Espacial (Point-in-Polygon)
# Usamos el objeto 'colonias_cdmx_validas'
airbnb_con_colonia_completo <- st_join(
  airbnb_puntos,
  colonias_cdmx_validas,
  join = st_intersects,
  left = TRUE
)

# 5. Selección y Limpieza Final
# ⚠AJUSTAR: Revisa names(colonias_cdmx) para verificar el nombre de la columna
# que contiene la colonia en el NUEVO GeoJSON y AJÚSTALO aquí si es diferente a 'colonia'.
# Usaré 'neighbourhood' como referencia del script anterior, si es 'colonia' déjalo.
airbnb_final_geo <- airbnb_con_colonia_completo %>%
  as_tibble() %>%
  select(
    id:`huéspedes permitidos`,
    colonia = cve_col # <-- ¡AJUSTA ESTE NOMBRE DE COLUMNA SI ES NECESARIO!
  )

# =========================================================================
# === PARTE 2: CÁLCULO DE DISTANCIA PROMEDIO A PUNTOS TURÍSTICOS ===
# =========================================================================

# 1. Definir las Coordenadas de los Puntos Turísticos
puntos_turisticos <- data.frame(
  nombre = c(
    "Museo_Antropologia", "Castillo_Chapultepec", "Palacio_Bellas_Artes",
    "Basilica_Guadalupe", "Fuente_Coyotes", "Museo_Frida_Kahlo",
    "Museo_Soumaya", "Zocalo", "Acuario_Michin", "Angel_Independencia"
  ),
  lon = c(
    -99.18611, -99.18167, -99.14139, -99.11700, -99.16333,
    -99.16250, -99.20472, -99.13278, -99.09650, -99.16778
  ),
  lat = c(
    19.42611, 19.42056, 19.43528, 19.48400, 19.34917,
    19.35528, 19.44056, 19.43333, 19.48200, 19.42694
  )
)

# Coordenadas de los Airbnb para el cálculo de distancias
coordenadas_airbnb <- airbnb_final %>%
  select(longitud, latitud)

# 2. Calcular la Matriz de Distancias (en Kilómetros)
matriz_distancias_metros <- distm(
  coordenadas_airbnb,
  puntos_turisticos[, c("lon", "lat")],
  fun = distHaversine
)

# Convertir la matriz a data frame y a KILÓMETROS
distancias_km <- as.data.frame(matriz_distancias_metros / 1000)
names(distancias_km) <- paste0("dist_", puntos_turisticos$nombre, "_km")

# 3. Agregar la Distancia Promedio a la Base Final
distancias_km <- distancias_km %>%
  mutate(
    promedio_distancia_turistica_km = rowMeans(.)
  )

# 4. Unir las nuevas columnas de distancia a la base de datos final
airbnb_final_geo <- cbind(airbnb_final_geo, distancias_km)

# =========================================================================
# === VERIFICACIÓN FINAL ===
# =========================================================================

# Mostrar las primeras filas con las nuevas variables
print(head(select(airbnb_final_geo, colonia, starts_with("dist"))))

###EXPORTAR

write_csv(
  airbnb_final_geo, 
  file = "/Users/lily/Downloads/airbnb_dist_colonia_clave.csv"
)




