# 2. faza: Uvoz podatkov

#Delnice
#Simboli:
#Apple(AAPL), Nvidia Corporation(NVDA), Amazon.com(AMZN), Microsoft(MSFT),
#AMD(AMD), Intel Corp(INTC), Alphabet Inc(GOOGL), Adobe(ADBE), Sony(SNE)

library(quantmod)
library(xml2)
library(dplyr)
library(tidyr)
library(devtools)
library(shiny)
library(rvest)
install_github("jaanos/rvest", ref="table-span-filling-v0.3.6.196")


uvozi.delnice <- function() {
symbols <- c("GOOGL","AAPL","NVDA","AMZN","MSFT","AMD", "INTC","ADBE", "SNE")

getSymbols(symbols, src = "yahoo", from = "2010-01-01", to = "2020-11-01", auto.assign = TRUE, getSymbols.warning4.0=FALSE)

aapl <- data.frame(AAPL) %>%
  tibble::rownames_to_column("Datum") 

adbe <- data.frame(ADBE) %>%
  tibble::rownames_to_column("Datum")

amd <- data.frame(AMD) %>%
  tibble::rownames_to_column("Datum") 

amzn <- data.frame(AMZN) %>%
  tibble::rownames_to_column("Datum") 

googl <- data.frame(GOOGL) %>%
  tibble::rownames_to_column("Datum")

intc <- data.frame(INTC) %>%
  tibble::rownames_to_column("Datum")

msft <- data.frame(MSFT) %>%
  tibble::rownames_to_column("Datum")

nvda <- data.frame(NVDA) %>%
  tibble::rownames_to_column("Datum")

sne <- data.frame(SNE) %>%
  tibble::rownames_to_column("Datum")

zdruzena <- left_join(aapl, adbe, by="Datum") %>% #združi vse tabele v eno
  left_join(amd, by="Datum") %>%
  left_join(msft, by="Datum") %>%
  left_join(intc, by="Datum") %>%
  left_join(googl, by="Datum") %>%
  left_join(nvda, by="Datum") %>%
  left_join(sne, by="Datum") %>%
  left_join(amd, by="Datum") %>%
  pivot_longer(-Datum, names_to = "Ime", values_to="Vrednost") %>%
  separate(Ime,c("Ime","Tip"),"[.]")

return(zdruzena)

}


#HTML

uvozi.kapitalizacijo <- function() {
  url <- "https://en.wikipedia.org/wiki/List_of_stock_exchanges"
  stran <- read_html(url)
  html_tabela <- stran %>%
    html_nodes(xpath="//table[@class='wikitable sortable']") %>% .[[1]]
  tabela <- html_tabela %>% html_table(dec=".", fill = TRUE)
  for (i in 1:ncol(tabela)) {
    if (is.character(tabela[[i]])) {
      Encoding(tabela[[i]]) <- "UTF-8"
    }
  }

  colnames(tabela) <- c("Rang", "Leto", "Borza","Simbol", "Regija", "Kraj",
                        "Market_cap", "Monthly_volume",
                        "Casovni_pas", "Sprememba", "DST", "Odprtje", "Zaprtje",
                        "Kosilo", "Odprtje(UTC)", "Zaprtje(UTC)")
  
  #Izbris stolpcev
  tabela[8:16] <- list(NULL)
  
  vrstice <- html_tabela %>% html_nodes(xpath=".//tr") %>% .[-1]
  borze <- vrstice %>% html_nodes(xpath="./td[3]") %>% html_text()
  kraji <- vrstice[1:14] %>% html_nodes(xpath="./td[6]") %>% lapply(. %>% html_nodes(xpath="./a") %>% html_text())
  borze.kraji <- data.frame(borza=lapply(1:length(kraji),
                                         . %>% { rep(borze[.], length(kraji[[.]])) }) %>% unlist(),
                            kraj=unlist(kraji))
  
  return(tabela)
}


