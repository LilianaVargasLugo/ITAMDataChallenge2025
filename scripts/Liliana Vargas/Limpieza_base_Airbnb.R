
library(dplyr)
library(readr)
library(stringr)
library(VIM) # Para la imputación kNN

# =========================================================================
# === PARTE 1: CARGA DE DATOS Y SELECCIÓN INICIAL ===
# =========================================================================

# 1. Leer base de airbnb
airbnb <- read_csv("/Users/lily/Downloads/listings_scraped.csv")

# Definir las columnas que quieres conservar (incluyendo las nuevas necesarias)
columnas_a_conservar <- c(
  "id", "listing_url", "last_scraped", "description",
  "host_is_superhost", "neighbourhood_cleansed", 
  "latitude", "longitude", "property_type", "room_type", 
  "accommodates", "bathrooms", "bedrooms", "amenities", 
  "price", "review_scores_accuracy", "reviews_per_month", 
  "review_scores_location", "availability_365"
)

# Aplicar la selección
airbnb_limpio <- airbnb %>%
  select(all_of(columnas_a_conservar))


# =========================================================================
# === PARTE 2: PROCESAMIENTO DE VARIABLES ===
# =========================================================================

# --- [NUEVO] VARIABLE REVIEWS PER MONTH: quitar NAs y poner 0
airbnb_limpio <- airbnb_limpio %>%
  mutate(reviews_per_month = replace_na(reviews_per_month, 0))

# --- [NUEVO] VARIABLE AMENITIES: contar amenidades
airbnb_limpio <- airbnb_limpio %>%
  mutate(
    # 1. Limpiar la cadena de amenities (quitar {}, " y espacios extra)
    amenities_limpio = str_remove_all(amenities, pattern = "[{}\"\\s]"), # Limpieza robusta
    
    # 2. Contar amenidades: Si la cadena no está vacía, cuenta las comas y suma 1. Si está vacía, es 0.
    num_amenidades = if_else(
      amenities_limpio == "", 
      0L, 
      str_count(amenities_limpio, pattern = ",") + 1L
    )
  ) %>%
  select(-amenities, -amenities_limpio)


# VARIABLE SUPER HOST: hacerla binaria
airbnb_limpio <- airbnb_limpio %>%
  # 1. NA -> FALSE (0)
  mutate(host_is_superhost = replace_na(host_is_superhost, FALSE)) %>%
  # 2. TRUE/FALSE -> 1/0
  mutate(host_is_superhost_binario = as.numeric(host_is_superhost)) %>%
  select(-host_is_superhost)


# VARIABLE PROPERTY TYPE: hacerla binaria
airbnb_limpio <- airbnb_limpio %>%
  mutate(
    tipo_propiedad_clasificado = case_when(
      # 1. CLASIFICACIÓN COMO DEPARTAMENTO
      str_detect(property_type, "(?i)unit|condo|loft|apartment|aparthotel") ~ "Departamento",
      # 2. CLASIFICACIÓN COMO CASA
      str_detect(property_type, "(?i)home|house|villa|townhouse|bungalow") ~ "Casa",
      # 3. CLASIFICACIÓN COMO OTRO / TEMPORAL
      str_detect(property_type, "(?i)hotel|guesthouse|bed and breakfast|suite|private room|casa particular") ~ "Otro/Temporal",
      # 4. DEFAULT
      TRUE ~ "Sin Clasificar" 
    )
  )


# VARIABLE ROOM TYPE: quedarnos solo con los alojamientos completos
airbnb_limpio <- airbnb_limpio %>%
  filter(str_detect(room_type, "(?i)Entire home/apt"))


# VARIABLE PRICE: Imputación KNN
# ----------------------------------------------------

# 1. Limpiar la columna Price
airbnb_limpio <- airbnb_limpio %>%
  mutate(
    price = str_replace_all(price, "\\$|,", ""), # Eliminar '$' y ','
    price = as.numeric(price)                   # Convertir el resultado a numérico
  )

# --- PASO 1: Configuración de la Imputación ---
df_para_knn <- airbnb_limpio %>%
  select(
    price, 
    latitude, 
    longitude, 
    accommodates, 
    bedrooms,
    bathrooms,
    num_amenidades,
    host_is_superhost_binario,
    tipo_propiedad_clasificado,
    review_scores_location,
    review_scores_accuracy
  ) 

# --- PASO 2: Ejecutar la Imputación kNN ---
price_imputado_df <- kNN(
  df_para_knn, 
  variable = "price", 
  k = 10, 
  impNA = TRUE 
)

# --- PASO 3: Reemplazar la Columna Imputada ---
airbnb_imputado_knn <- airbnb_limpio %>%
  mutate(price = price_imputado_df$price)


# VARIABLE REVIEW SCORE ACCURACY: binaria <> 4 (manteniendo la original)
airbnb_score <- airbnb_imputado_knn %>%
  mutate(
    accuracy_score_binario = case_when(
      review_scores_accuracy > 4 ~ 1, 
      review_scores_accuracy <= 4 ~ 0,
      is.na(review_scores_accuracy) ~ 0 
    )
  )


# VARIABLE REVIEW SCORE LOCATION: binaria <> 4
airbnb_score_location <- airbnb_score %>%
  mutate(
    location_score_binario = case_when(
      review_scores_location > 4 ~ 1, 
      review_scores_location <= 4 ~ 0,
      is.na(review_scores_location) ~ 0 
    )
  )


# VARIABLE BATHROOMS: de continua a discreta
airbnb_score_limpio <- airbnb_score_location %>%
  # A. Corrección de NA y 0 a 1
  mutate(
    bathrooms = coalesce(bathrooms, 0),
    bathrooms = if_else(bathrooms == 0, 1, bathrooms),
    # B. Redondeo de Medios Baños (x.5 al siguiente entero)
    bathrooms = ceiling(bathrooms)
  )


# =========================================================================
# === PARTE 3: BASE FINAL Y EXPORTACIÓN ===
# =========================================================================

#### BASE FINAL: Seleccionar y renombrar todas las columnas solicitadas
airbnb_final <- airbnb_score_limpio %>%
  select(
    # Columnas originales y renombradas
    id,
    last_scraped,
    alcaldia = neighbourhood_cleansed,
    latitud = latitude,
    longitud = longitude,
    baños = bathrooms,
    recamaras = bedrooms,
    precio = price,
    superhost = host_is_superhost_binario,
    tipo = tipo_propiedad_clasificado,
    rating = accuracy_score_binario,
    ratingloc = location_score_binario,
    disponibilidad = availability_365,
    
    # Columnas NUEVAS y conservadas
    amenidades = num_amenidades,                                 # Conteo de amenidades
    `rating original` = review_scores_accuracy,                  # Puntuación original de accuracy
    reviews = reviews_per_month,                                 # Reviews/mes (con NA->0)
    `huéspedes permitidos` = accommodates                        # Huéspedes permitidos
  )

### EXPORTAR
write_csv(
  airbnb_final, 
  file = "/Users/lily/Downloads/airbnb_datos_finales_limpios.csv"
)

