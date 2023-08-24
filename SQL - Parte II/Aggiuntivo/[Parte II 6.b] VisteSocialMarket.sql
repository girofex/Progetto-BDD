/*
Parte II.6 - Viste e Interrogazioni.

Corso di laurea Basi di Dati in Informatica classe 
L-31 presso l'Universita` degli Studi di Genova 
anno accademico 2021/2022.
Script SQL Team28

Alessio De Vincenzi 4878315
Edoardo Risso       5018707
Federica Tamerisco  4942412
Mattia Cacciatore   4850100
*/

set search_path to socialmarket;
set datestyle to 'DMY';

/*
B. La definizione di una vista che fornisca alcune informazioni riassuntive per ogni nucleo familiare: il numero di 
punti mensili a disposizione, i punti residui per il mese corrente, il numero di persone autorizzate per l’accesso 
al market, il numero di componenti totali e quelli appartenenti alla fascia d’età più bassa, il numero di 
spese effettuate nell’ultimo anno, i punti eventualmente non utilizzati nell’ultimo anno, la percentuale di punti 
utilizzata per prodotti deperibili e non deperibili nell’ultimo anno.

N.B.
Per poter gestire in maniera accurata, precisa e corretta questa vista è stato necessario generare più sotto-viste
da unire poi con il NATURAL LEFT OUTER JOIN.
La fascia più bassa, date le scarse e vaghe informazioni date e richieste dalla specifica e dalla vista, è stata intepretata
come la fascia d'età al di sotto dei 16 anni, tramite l'unico riferimento presente nella specifica, su base discrezionale.

6 mesi = 6*30 = 180 giorni.
16 anni = (16*365) + 4 = 5844 giorni.

Le spese vengono considerate quegli appuntamenti presenti nella base di dati la cui data è compresa tra oggi e un anno fa,
per cui appuntamenti con 0 prodotti registrati contano come spese di 0 prodotti.
La percentuale è mostrata in scala 0-100.
*/


--Il numero dei componenti del nucleo familiare appartenenti alla fascia d’età più bassa [FUNZIONANTE E TESTATA].

CREATE OR REPLACE VIEW InformazioniGiovani AS
SELECT c.CodiceFamiglia, COUNT(c.CodiceCliente) AS NumeroGiovani
FROM Cliente c
WHERE ((CURRENT_DATE - c.DataNascita) <= 5844)
GROUP BY c.CodiceFamiglia
ORDER BY c.CodiceFamiglia;



--Il numero di persone autorizzate ad accedere al market [FUNZIONANTE E TESTATA].

CREATE OR REPLACE VIEW InformazioniAutorizzati AS
SELECT c.CodiceFamiglia, COUNT(c.CodiceCliente) AS NumeroAutorizzati
FROM Cliente c 
WHERE ((CURRENT_DATE - c.DataInizioAutorizzazione) <= 180)
GROUP BY c.CodiceFamiglia
ORDER BY c.CodiceFamiglia;


--Il numero di spese effettuate nell’ultimo anno [FUNZIONANTE E TESTATA].

CREATE OR REPLACE VIEW InformazioniSpese AS
SELECT c.CodiceFamiglia, COUNT(a.DataOraInizio) AS NumeroSpese
FROM Cliente c JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
WHERE (a.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP AND a.DataOraInizio <= CURRENT_TIMESTAMP
GROUP BY c.CodiceFamiglia
ORDER BY c.CodiceFamiglia;



--I punti eventualmente non utilizzati nell’ultimo anno [FUNZIONANTE E TESTATA].

CREATE OR REPLACE VIEW InformazioniPuntiNonSpesi AS
SELECT f.CodiceFamiglia, (f.SaldoPuntiMensile * 12) - SUM(a.SaldoIniziale - a.SaldoFinale) AS TotalePuntiNonSpesi
FROM Famiglia f JOIN Cliente c ON f.CodiceFamiglia = c.CodiceFamiglia JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
WHERE (a.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP AND a.DataOraInizio <= CURRENT_TIMESTAMP
GROUP BY f.CodiceFamiglia
ORDER BY f.CodiceFamiglia;



--La percentuale di punti utilizzata per prodotti deperibili nell’ultimo anno [TESTATA].

CREATE OR REPLACE VIEW InformazioniPuntiSuProdottiDeperibili AS
SELECT f.CodiceFamiglia, ((SUM(a.SaldoIniziale - a.SaldoFinale) * 100) / (f.SaldoPuntiMensile * 12)) AS PercentualePuntiProdottiDeperibili
FROM Famiglia f JOIN Cliente c ON f.CodiceFamiglia = c.CodiceFamiglia
	        JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
	        JOIN Spesa s ON a.DataOraInizio = s.DataOraInizio
	        JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
WHERE s.DataOraInizio <= CURRENT_TIMESTAMP AND ((s.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP) AND p.DataCommestibilità IS NOT NULL
GROUP BY f.SaldoPuntiMensile, f.CodiceFamiglia
ORDER BY f.CodiceFamiglia;



--La percentuale di punti utilizzata per prodotti NON deperibili nell’ultimo anno [TESTATA].

CREATE OR REPLACE VIEW InformazioniPuntiSuProdottiNonDeperibili AS
SELECT f.CodiceFamiglia, ((SUM(a.SaldoIniziale - a.SaldoFinale) * 100) / (f.SaldoPuntiMensile * 12)) AS PercentualePuntiProdottiNonDeperibili
FROM Famiglia f JOIN Cliente c ON f.CodiceFamiglia = c.CodiceFamiglia
	        JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
	        JOIN Spesa s ON a.DataOraInizio = s.DataOraInizio
	        JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
WHERE s.DataOraInizio <= CURRENT_TIMESTAMP AND ((s.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP) AND p.DataCommestibilità IS NULL
GROUP BY f.SaldoPuntiMensile, f.CodiceFamiglia
ORDER BY f.CodiceFamiglia;



--VISTA
--[TESTATA]

CREATE OR REPLACE VIEW InformazioniFamiglie (Famiglia, PuntiMensili, PuntiAttuali, NumeroComponenti, NumeroAutorizzati, 
						NumeroGiovani, NumeroSpeseUltimoAnno, PuntiNonSpesiUltimoAnno, 
						PercentualePuntiProdottiDeperibiliUltimoAnno, PercentualePuntiProdottiNonDeperibiliUltimoAnno) AS
SELECT f.CodiceFamiglia, f.SaldoPuntiMensile, f.SaldoPuntiAttuale, f.NumeroComponenti, if.NumeroAutorizzati, if.NumeroGiovani, NumeroSpese, 
	TotalePuntiNonSpesi, PercentualePuntiProdottiDeperibili, PercentualePuntiProdottiNonDeperibili
FROM Famiglia f NATURAL LEFT OUTER JOIN (InformazioniAutorizzati NATURAL LEFT OUTER JOIN InformazioniGiovani) if 
	        NATURAL LEFT OUTER JOIN InformazioniSpese
	        NATURAL LEFT OUTER JOIN InformazioniPuntiNonSpesi 
	        NATURAL LEFT OUTER JOIN InformazioniPuntiSuProdottiDeperibili 
	        NATURAL LEFT OUTER JOIN InformazioniPuntiSuProdottiNonDeperibili
ORDER BY f.CodiceFamiglia;


--SELECT * FROM InformazioniFamiglie;

/*
CANCELLAZIONE SOTTO-VISTE E VISTE

drop view InformazioniGiovani CASCADE;
drop view InformazioniAutorizzati CASCADE;
drop view InformazioniSpese;
drop view InformazioniPuntiNonSpesi;
drop view InformazioniPuntiSuProdottiDeperibili;
drop view InformazioniPuntiSuProdottiNonDeperibili;
drop view InformazioniFamiglie CASCADE;
*/