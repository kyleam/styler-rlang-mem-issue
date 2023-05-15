library(dplyr)
library(ggplot2)

read_mem <- function(fname, label) {
  readr::read_table(fname, col_types = "dd") %>%
    mutate(
      label = label,
      seconds = time - min(time),
      mem_used_mi = mem_used / 2^20
    )
}

mem <- bind_rows(
  read_mem("output/good.mem.stdout", "rlang v1.0.6-145-gd3dc2d84b"),
  read_mem("output/bad.mem.stdout", "rlang v1.0.6-146-g35e879084"),
  read_mem("output/latest.mem.stdout", "rlang latest"),
  read_mem("output/styler-unreleased.mem.stdout", "rlang latest, styler latest"),
  read_mem("output/styler-revert.mem.stdout", "rlang latest, styler latest + revert")
) %>%
  mutate(
    label = forcats::fct_inorder(label)
)

p <- ggplot(mem, aes(seconds, mem_used_mi)) +
  geom_point(alpha = 0.9) +
  geom_line(alpha = 0.6) +
  facet_wrap(~ label) +
  labs(title = "styler check", y = "system memory use (MiB)") +
  theme_bw() +
  theme(
    legend.key = element_rect(color = NA, fill = NA),
    legend.background = element_rect(color = NA, fill = NA),
    legend.justification = c(0.02, 0.95),
    legend.text = element_text(size = 9),
    legend.position = c(0, 1),
    plot.title = element_text(hjust = 0.5)
  )
ggsave("output/mem.svg", p, width = 9, height = 5)
