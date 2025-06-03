#Plotten
 # drei Beispiel Läner als Beispielplot
data_long %>%
  filter(Country %in% c("Belgium", "France", "Germany")) %>%
  ggplot(aes(x = Datum, y = Wert, color = Country)) +
  geom_line() +
  labs(title = "Zeitverlauf – ausgewählte Länder", x = "Datum", y = "Wert") +
  scale_y_continuous(breaks = seq(0, 200, by = 20)) +  # z. B. von 0 bis 200
  scale_x_date(date_breaks = "6 months", date_labels = "%Y-%m") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#Lineplot mit fiktivem treatment marker

data_long %>%
  filter(Country %in% c("Belgien", "Frankreich", "Deutschland")) %>%
  ggplot(aes(x = Datum, y = Wert, color = Country)) +
  geom_line() +
  # <treatment-marker>
  geom_vline(xintercept = as.Date("2021-01-01"), linetype = "dashed", color = "red") +
  annotate("text", x = as.Date("2021-01-01"), y = 180, label = "Treatment", angle = 90, vjust = -0.5, color = "red") +
  # </treatment-marker>
  labs(title = "Zeitverlauf – ausgewählte Länder", x = "Datum", y = "Wert") +
  scale_y_continuous(breaks = seq(0, 200, by = 20)) +
  scale_x_date(date_breaks = "6 months", date_labels = "%Y-%m") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#Fläche zwischen zwei ländern plottebn

data_wide <- data_long %>%
  filter(Country %in% c("Deutschland", "Frankreich")) %>%
  pivot_wider(names_from = Country, values_from = Wert)

ggplot(data_wide, aes(x = Datum)) +
  geom_ribbon(aes(ymin = pmin(Deutschland, Frankreich),
                  ymax = pmax(Deutschland, Frankreich)),
              fill = "lightblue", alpha = 0.4) +
  geom_line(aes(y = Deutschland, color = "Deutschland"), size = 1) +
  geom_line(aes(y = Frankreich, color = "Frankreich"), size = 1) +
  labs(title = "Differenz zwischen Deutschland und Frankreich",
       y = "Wert", x = "Datum") +
  scale_color_manual(values = c("Deutschland" = "blue", "Frankreich" = "red")) +
  theme_minimal()
