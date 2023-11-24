library(RSelenium)
library(tidyverse)
library(rvest)

rD <- rsDriver(browser = "firefox", chromever = NULL)
remDr <- rD$client

remDr$navigate("https://www.cnbc.com/world/")
query <- "people activity in beach area"
search <- remDr$findElement(using = "css selector", ".SearchEntry-suggestNotActiveInput")
search$getElementAttribute("placeholder")
search$clearElement()
search$sendKeysToElement(list(query, key = "enter"))

links <- remDr$findElements(using = "css selector", "#searchcontainer a.resultlink")
length(links)

titles <- sapply(links, function(x) x$getElementText())
urls <- sapply(links, function(x) x$getElementAttribute("href"))

titles
view(titles)
urls

df <- tibble(title = character(), link = character(),news = character(), name = character(),waktu = character())

for(i in 1:length(urls)){
  title <- titles[[i]]
  url <- urls[[i]]
  getNews <- read_html(url) %>%
    html_elements("#MakeItRegularArticle-ArticleBody-5 p") %>%
    html_text2() %>%
    paste(collapse = " ")
  news <- c(news, getNews)
  df <- df %>%
        add_row(title, link = url, news = getNews, name = "Rensa", waktu = str_extract(url, "\\b\\d{4}/\\d{2}/\\d{2}\\b"))
}

df

view(df)

df <- df %>%
  filter(news != "")

write.csv(df, "data_ekstrak_tugas_kelompok.csv")

remDr$close()
rD$server$stop()
