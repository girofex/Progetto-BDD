/*
Parte III.A.a - Interrogazioni su carichi di lavoro.

Corso di laurea Basi di Dati in Informatica classe 
L-31 presso l'Universita` degli Studi di Genova 
anno accademico 2021/2022.
Script SQL Team28

Alessio De Vincenzi 4878315
Edoardo Risso       5018707
Federica Tamerisco  4942412
Mattia Cacciatore   4850100

NOTA: le interrogazioni sono scritte tenendo conto dell'attuale data e ora
in cui vengono eseguite, essendo il popolamento della base di dati un po' datato,
potrebbe rivelarsi necessario inserire date a mano per effettuare il testing.
*/

set search_path to socialmarket;
set datestyle to 'DMY';

--1. Lista appuntamenti futuri con le famiglie (con JOIN).
--Utile sapere quali sono i prossimi appuntamenti per successive organizzazioni.

SELECT f.CodiceFamiglia, a.DataOraInizio
FROM Cliente c JOIN Famiglia f ON c.CodiceFamiglia = f.CodiceFamiglia
               JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
WHERE a.DataOraInizio > CURRENT_TIMESTAMP
GROUP BY f.CodiceFamiglia, a.DataOraInizio
ORDER BY a.DataOraInizio, f.CodiceFamiglia;

--2. Per ogni famiglia, la lista dei membri autorizzati che non hanno mai effettuato una spesa.
--Utile sapere quali sono i membri autorizzati non attivi per eventuali ricerche.

SELECT *
FROM Cliente c
WHERE ((CURRENT_DATE - c.DataInizioAutorizzazione) <= 180)
--WHERE ((date '2021-07-01' - c.DataInizioAutorizzazione) <= 180) 
      AND c.CodiceCliente NOT IN (SELECT a.CodiceCliente
				  FROM Appuntamento a
				  WHERE a.CodiceCliente = c.CodiceCliente AND a.DataOraInizio <= CURRENT_TIMESTAMP);

--3. Prodotti che scadono questo mese con data di scadenza in ordine crescente. 
--Utile sapere quali sono i prossimi prodotti che scadono per poterli consigliare ai clienti.

SELECT NomeProdotto, DataScadenza
FROM Prodotto
WHERE DataScadenza BETWEEN CURRENT_DATE AND (CURRENT_DATE + interval '1' month)
--WHERE DataScadenza BETWEEN CURRENT_DATE AND (CURRENT_DATE + interval '1000' month)
ORDER BY DataScadenza;
