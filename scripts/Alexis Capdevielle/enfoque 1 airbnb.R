#estimando rentabilidad por airbnb y luego promediando ponderadamente por colonia

library(sandwich)
library(readr)
library(writexl)
library(ggplot2)
library(dgof)
library(Matching)
library(lmtest)
library(stargazer)
library(margins)
library(dplyr)
library(broom)
library(margins)
library(readxl)
library(dplyr)

#arreglos de algunas variables 
datoslimpios <- read_excel("Desktop/Copia de airbnb_base final.xlsx")
View(datoslimpios)
summary(datoslimpios)

# sintaxis: rename(nuevo_nombre = nombre_viejo), quitar acentos y ñ 
datoslimpios <- datoslimpios %>% 
  rename(
    huespedes = "huÃ©spedes permitidos")

datoslimpios <- datoslimpios %>% 
  rename(
    banos = "baÃ±os")

#recamaras estaba como character, hay que hacerla numerica 
datoslimpios$habitaciones <- as.numeric(datoslimpios$recamaras)
summary(datoslimpios$habitaciones)
datoslimpios$competencia <- as.numeric(datoslimpios$n_airbnb_colonia)
summary(datoslimpios$competencia)
datoslimpios$rentabilidaddiez<-as.numeric(datoslimpios$'ingresos-costoadquisicion 10a')
datoslimpios$robos<-as.numeric(datoslimpios$robos)
datoslimpios$ca<-as.numeric(datoslimpios$'costoadquisicion_estimado')

#definición de la variable y 
#indicador de rentabilidad por airbnb 
datoslimpios$ocupacion<-365-datoslimpios$disponibilidad
summary(datoslimpios$ocupacion)

datoslimpios$IAP<-(datoslimpios$precio*datoslimpios$ocupacion)+1
summary(datoslimpios$IAP)


#asumiendo gastos operativos del 60%:
datoslimpios$GOP<-0.4*datoslimpios$IAP
summary(datoslimpios$GOP)


hist(x = log(datoslimpios$GOP),main="GOP")

# Definir las variables de interés
variables_comunes <- c("habitaciones", "banos", "huespedes", "amenidades", "reviews", 
                       "promedio_distancia_turistica_km", "metro", "metrobus", 
                       "competencia", "robos", "superhost")

# Filtrar el conjunto de datos para incluir solo observaciones completas
datos_comunes <- datoslimpios[complete.cases(datoslimpios[variables_comunes]), ]

# Verifica el tamaño de la nueva muestra
nrow(datos_comunes)



#regresion rentabilidad
mco_1<- lm(log(GOP) ~ habitaciones+banos+huespedes+amenidades+reviews+superhost+promedio_distancia_turistica_km+metro+metrobus+competencia+robos, data = datos_comunes,na.action = na.exclude)
summary(mco_1,robust="HC1")
(se1 <- sqrt(diag(vcovHC(mco_1,type="HC1"))))

mco_2<- lm(log(GOP) ~ habitaciones+huespedes+amenidades+reviews+superhost+promedio_distancia_turistica_km+metro+competencia, data = datos_comunes,na.action = na.exclude)
summary(mco_2,robust="HC1")
(se2 <- sqrt(diag(vcovHC(mco_2,type="HC1"))))


#rentabilidad ajustada
datos_comunes$y_hat <- fitted(mco_2)


#promediando rentabilidad
datos_prom <- datos_comunes %>% 
  group_by(clave_colonia_geojson) %>% 
  mutate(peso = n()) %>%                     # número de Airbnbs en ese grupo
  summarise(
    across(
      where(is.numeric),
      ~ weighted.mean(.x, w = peso, na.rm = TRUE)
    ),
    .groups = "drop"
  )

summary(datos_prom)

#seleccionando colonias
top3 <- datos_prom %>% 
  filter(!is.na(y_hat)) %>% 
  arrange(desc(y_hat)) %>% 
  slice(1:3)

top3

#tomando la media del ponderador como mínimo para q sean representativas las colonias 
top3 <- datos_prom %>%
  filter(
    !is.na(y_hat),
    peso > mean(peso, na.rm = TRUE)
  ) %>%
  arrange(desc(y_hat)) %>%
  slice(1:3)

top3

#tablas regresiones
stargazer(mco_1, mco_2, type="text",
dep.var.labels=c("log(GOP)"), 
out="Desktop/Tabla_MCOAIRBNB enfoque 1 b.txt",
star.cutoffs = c(0.1, 0.05, 0.01),  
star.char = c("*", "**", "***"),         
notes = "Niveles de significancia: * p<0.1, ** p<0.05, *** p<0.01",
se = list(se1,se2))

write.csv(summary(datoslimpios),"Desktop/estadistica descriptiva propiedades.csv")

