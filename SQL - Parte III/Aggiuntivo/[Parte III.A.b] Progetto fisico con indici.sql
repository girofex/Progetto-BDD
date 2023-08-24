/*
Parte III.A.b - Progetto fisico con indici.

Corso di laurea Basi di Dati in Informatica classe 
L-31 presso l'Universita` degli Studi di Genova 
anno accademico 2021/2022.
Script SQL Team28

Alessio De Vincenzi 4878315
Edoardo Risso       5018707
Federica Tamerisco  4942412
Mattia Cacciatore   4850100
*/

/*
INDICI aggiuntivi per la creazione dello schema fisico.
*/

/*
Interrogazione 1 (con JOIN). Indici superflui.
Creazione di indici già pre-esistenti nella base dati dato che PostgresSQL
fornisce già indici di tipo B-Tree sugli attributi PRIMARY KEY e UNIQUE.
(Ma potrebbe non essere così per altri DBMS)
*/

CREATE INDEX IndiceOrariAppuntamento ON Appuntamento(DataOraInizio);
CLUSTER Appuntamento USING IndiceOrariAppuntamento;
CREATE INDEX IndiceFamiglia ON Cliente(CodiceFamiglia);
CLUSTER Cliente USING IndiceFamiglia;

/*
Interrogazione 2 (con condizione complessa).
Creazione e clusterizzazione (aka ordinamento) dell'indice di tipo B-Tree
utile per migliorare l'efficienza dell'interrogazione permettendo un
numero inferiore di accessi disco ed evitando la scansione sequenziale.
*/

CREATE INDEX IndiceCliente ON Appuntamento(CodiceCliente);
CLUSTER Appuntamento USING IndiceCliente;

/*
Interrogazione 3.
Creazione e clusterizzazione (aka ordinamento) dell'indice di tipo B-Tree
su attributo facente parte della chiave alternativa UNIQUE (DataScadenza,
NomeProdotto), che permette di migliorare leggermente l'efficienza 
dell'interrogazione potendo contare su un indice ad albero bilanciato con
foglie ordinate sull'attributo d'interesse.
*/

CREATE INDEX IndiceScadenzaProdotto ON Prodotto(DataScadenza);
CLUSTER Prodotto USING IndiceScadenzaProdotto;