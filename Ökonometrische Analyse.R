
### Ökonometrische Analyse der Daten (Stagered Difference in Difference mit fixed Effects, Eventstudy)

library(fixest)
library(modelsummary)
library(flextable)
library(officer)
library(kableExtra)




###Dieser Code wandelt das panel_yearly Dataframe, welches in "Data preprocessing" vorbereitet wurde
# auf jahresebene um und führt DiD und eventstudy durch


#von Jahres auf Monatsebene

panel_yearly <- data_long

panel_yearly <- panel_yearly %>%
  mutate(Year = year(Datum)) %>%
  group_by(Year, Country) %>%
  summarise(Average_price = mean(Wert,  na.rm = TRUE))

panel_yearly$Year <- as.Date(paste0(panel_yearly$Year, "-01-01"))


# Daten für DiD und Eventstudy vorbereiten
# nötige Dummys erstellen

panel_yearly$treated_date <- as.Date(NA)
panel_yearly$treated_date[panel_yearly$Country == "Deutschland"] <- as.Date("2010-01-01")
panel_yearly$treated_date[panel_yearly$Country == "Ungarn"] <- as.Date("2020-01-01")
panel_yearly$treated_date[panel_yearly$Country == "Irland"] <- as.Date("2011-01-01")
panel_yearly$treated_date[panel_yearly$Country == "Slovakai"] <- as.Date("2019-01-01")



panel_yearly$post <- 0
panel_yearly$post[panel_yearly$Country == "Deutschland" & panel_yearly$Year > panel_yearly$treated_date ] <- 1
panel_yearly$post[panel_yearly$Country == "Ungarn" & panel_yearly$Year > panel_yearly$treated_date ] <- 1
panel_yearly$post[panel_yearly$Country == "Irland" & panel_yearly$Year > panel_yearly$treated_date ] <- 1
panel_yearly$post[panel_yearly$Country == "Slovakai" & panel_yearly$Year > panel_yearly$treated_date ] <- 1


panel_yearly$treated <- 0
panel_yearly$treated[panel_yearly$Country == "Deutschland"] <- 1
panel_yearly$treated[panel_yearly$Country == "Ungarn"] <- 1
panel_yearly$treated[panel_yearly$Country == "Irland"] <- 1
panel_yearly$treated[panel_yearly$Country == "Slovakai"] <- 1



# dummyvariablen für Eventstudy vorbereiten: abstand zu treatment 
panel_yearly$year_diff <- interval(panel_yearly$treated_date, panel_yearly$Year) %/% years(1)
panel_yearly$year_diff <- ifelse(is.na(panel_yearly$year_diff), 0, panel_yearly$year_diff)


#DiD

model <- lm(log(Average_price) ~ post + as.factor(Country)+as.factor(Year), data= panel_yearly)
#print(summary(model))

model_feols <- feols(log(Average_price) ~ post| Country + Year, data = panel_yearly)
print(summary(model_feols))

# Regressionsoutput im R viewer anzeigen lassen
modelsummary(model_feols, output = "flextable", title = "DiD-Modell: Log(Average Price)")
etable(
  model_feols,
  se = "cluster",
  cluster = ~Country,
  tex = FALSE,
  style.tex = FALSE
)

#Eventstudy

model_event_study <- feols(log(Average_price) ~ i(as.factor(year_diff), ref = -1) | Country + Year, data = panel_yearly)
print(summary (model_event_study))

# 📈 Event Study Plot
iplot(model_event_study,
      main = "Event Study: Effekt von Treatment über die Zeit",
      xlab = "Jahre relativ zum Treatment",
      ylab = "Effekt relativ zu Monat -1",
      col.line = "steelblue",
      col.poly = "lightblue",
      ci.level = 0.95)  # 95%-Konfidenzintervall


