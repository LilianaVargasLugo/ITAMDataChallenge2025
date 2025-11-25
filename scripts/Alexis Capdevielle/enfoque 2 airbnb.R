
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

#definición de la variable y 
#indicador de rentabilidad por airbnb 
datoslimpios$ocupacion<-365-datoslimpios$disponibilidad
summary(datoslimpios$ocupacion)

datoslimpios$IAP<-(datoslimpios$precio*datoslimpios$ocupacion)+1
summary(datoslimpios$IAP)



#promediando por colonia
datos_prom <- datoslimpios %>% 
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




#distribucion del precio promedio por colonia (en logaritmos)
hist(x = log(datos_prom$precio),main="log(precio)")

#regresion hedonica

mco_prom1 <- lm(log(precio) ~ habitaciones+banos+huespedes+amenidades+reviews+superhost+promedio_distancia_turistica_km+metro+metrobus+competencia+robos, data = datos_prom,na.action = na.exclude)
summary(mco_prom1,robust="HC1")
(se1 <- sqrt(diag(vcovHC(mco_prom1,type="HC1"))))

mco_prom2 <- lm(log(precio) ~ habitaciones+banos+huespedes+amenidades+reviews+promedio_distancia_turistica_km+metro+metrobus+competencia, data = datos_prom,na.action = na.exclude)
summary(mco_prom2,robust="HC1")
(se2 <- sqrt(diag(vcovHC(mco_prom2,type="HC1"))))

mco_prom3 <- lm(log(precio) ~ habitaciones+banos+huespedes+amenidades+reviews+promedio_distancia_turistica_km+competencia, data = datos_prom,na.action = na.exclude)
summary(mco_prom3,robust="HC1")
(se3 <- sqrt(diag(vcovHC(mco_prom3,type="HC1"))))


#colonias mas rentables 
datos_prom$y_hat <- fitted(mco_prom3)

top3 <- datos_prom %>% 
  filter(!is.na(rentabilidad)) %>% 
  arrange(desc(rentabilidad)) %>% 
  slice(1:3)

top3

#rentabilidad, elevamos logprecio ajustado
datos_prom$iap<-exp(datos_prom$y_hat)*datos_prom$ocupacion
datos_prom$vpn<-datos_prom$iap*((1-(1.1)^-15)/0.1)

datos_prom$rentabilidad<-datos_prom$vpn-datos_prom$ca


top3 <- datos_prom %>% 
  filter(!is.na(rentabilidad)) %>% 
  arrange(desc(rentabilidad)) %>% 
  slice(1:3)

top3
#analisis 
top3 <- datos_prom %>%
  filter(
    !is.na(rentabilidad),
    peso > mean(peso, na.rm = TRUE)
  ) %>%
  arrange(desc(rentabilidad)) %>%
  slice(1:3)

top3
#tablas regresiones
stargazer(mco_prom1, mco_prom2,mco_prom3, type="text",
          dep.var.labels=c("log(precio)"), 
          out="Desktop/Tabla_MCOAIRBNB enfoque 2.txt",
          star.cutoffs = c(0.1, 0.05, 0.01),  
          star.char = c("*", "**", "***"),         
          notes = "Niveles de significancia: * p<0.1, ** p<0.05, *** p<0.01",
          se = list(se1,se2,se3))

write.csv(summary(datos_prom),"Desktop/estadistica descriptiva promedio colonia.csv")
