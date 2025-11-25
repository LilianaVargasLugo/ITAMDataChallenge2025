

# Cargamos la base de datos limpia (CSV)
airbnb_final_geo <- read_csv("/Users/lily/Downloads/airbnb_dist_colonia_clave.csv")

names(airbnb_final_geo)

# 1. CARGA del catálogo de colonias
df_catalogo_nombres <- read_delim(
  "/Users/lily/Downloads/georef-mexico-colonia.csv",
  delim = ";",
  col_names = TRUE,
  show_col_types = FALSE
)


# =========================================================================
# === PASO 1: PREPARAR EL CATÁLOGO DE NOMBRES (df_catalogo_nombres) ===
# =========================================================================

df_lookup <- df_catalogo_nombres %>%
  
  # 1. Seleccionamos las columnas de clave y nombre (usando los nombres con espacios)
  select(
    Colonia_code_Raw = "Colonia code", # Guardamos la clave original para trabajar
    Colonia_name = "Colonia name"
  ) %>%
  
  # 2. Estandarizar la clave del catálogo: "12-086" -> "12086"
  mutate(
    # Quitamos guiones y cualquier carácter no numérico para limpieza total
    clave_join = str_replace_all(as.character(Colonia_code_Raw), '[^0-9]', ''),
    
    # Nos aseguramos de tomar los últimos 5 dígitos para la unión
    clave_join = str_sub(clave_join, -5, -1)
  ) %>%
  
  # 3. Limpieza final y renombrado
  distinct(clave_join, .keep_all = TRUE) %>% # Eliminamos duplicados
  rename(nombre_colonia_completo = Colonia_name) %>%
  select(clave_join, nombre_colonia_completo)


# =========================================================================
# === PASO 2: PREPARAR AIRBNB Y REALIZAR LA UNIÓN (airbnb_final_geo) ===
# =========================================================================

airbnb_final_geo <- airbnb_final_geo %>%
  
  # 1. Estandarizar la clave de Airbnb: "004-033" -> "04033"
  mutate(
    # a. Limpiar la clave: Quitar guiones (ej. "004-033" -> "004033")
    clave_geo_limpia = str_replace_all(as.character(colonia), '[^0-9]', ''),
    
    # b. Corregir: Obtener los ÚLTIMOS 5 caracteres, eliminando el cero extra
    clave_join = str_sub(clave_geo_limpia, -5, -1)
  ) %>%
  
  # 2. Realizar la Unión (LEFT JOIN)
  left_join(
    df_lookup,
    by = "clave_join"
  ) %>%
  
  # 3. Limpieza y renombramiento
  rename(clave_colonia_geojson = colonia) %>% # Renombramos la clave GeoJSON original
  select(-clave_geo_limpia, -clave_join) # Eliminamos las columnas de trabajo temporales

# =========================================================================
# === VERIFICACIÓN FINAL ===
# =========================================================================

print("--- Resultado Final: Primeras Filas ---")
print(head(select(airbnb_final_geo, clave_colonia_geojson, nombre_colonia_completo, promedio_distancia_turistica_km)))

# Conteo final de éxito
listados_con_nombre <- sum(!is.na(airbnb_final_geo$nombre_colonia_completo))
print(paste("Total de listados con nombre de colonia agregado:", listados_con_nombre, "de", nrow(airbnb_final_geo)))

# =========================================================================
# === CÁLCULO DE NAs (Fallas en el Match) ===
# =========================================================================

# 1. Contar el total de filas
total_listados <- nrow(airbnb_final_geo)

# 2. Contar los listados con un valor NA en el nombre de la colonia (los que fallaron el match)
fallas_en_el_match <- sum(is.na(airbnb_final_geo$nombre_colonia_completo))

# 3. Calcular el porcentaje de fallas
porcentaje_fallas <- round((fallas_en_el_match / total_listados) * 100, 2)

# =========================================================================
# === RESULTADOS ===
# =========================================================================

print("--- Resumen de Errores en la Clasificación de Colonias ---")
print(paste("Total de listados de Airbnb:", total_listados))
print(paste("Listados que NO hicieron match (NA):", fallas_en_el_match))
print(paste("Porcentaje de listados sin nombre de colonia (NA):", porcentaje_fallas, "%"))



write_csv(
  airbnb_final_geo, 
  file = "/Users/lily/Downloads/airbnb_final_colonias_distancias_1.csv"
)

