library(dplyr)
library(ggplot2)

read_mem <- function(fname, commit) {
  readr::read_table(fname, col_types = "dd") %>%
    mutate(
      rlang = commit,
      seconds = time - min(time),
      mem_used_mi = mem_used / 2^20
    )
}

mem <- bind_rows(
  read_mem("output/good.mem.stdout", "v1.0.6-145-gd3dc2d84b"),
  read_mem("output/bad.mem.stdout", "v1.0.6-146-g35e879084"),
  read_mem("output/latest.mem.stdout", "v1.1.1-3-g194c085b0")
)

p <- ggplot(mem, aes(seconds, mem_used_mi, color = rlang)) +
  geom_point(alpha = 0.9) +
  geom_line(alpha = 0.6) +
  labs(title = "styler check", y = "system memory use (MiB)") +
  scale_color_manual(values = c("#000000", "#a0132f", "#531ab6")) +
  theme_bw() +
  theme(
    legend.key = element_rect(color = NA, fill = NA),
    legend.background = element_rect(color = NA, fill = NA),
    legend.justification = c(0.02, 0.95),
    legend.text = element_text(size = 9),
    legend.position = c(0, 1),
    plot.title = element_text(hjust = 0.5)
  )
ggsave("output/mem.svg", p, width = 6, height = 3.5)
