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
INTERROGAZIONI - QUERIES

C.a - Determinare i nuclei familiari che, pur avendo punti assegnati, non hanno effettuato spese nell’ultimo mese;
[TESTATA E FUNZIONANTE]

In questa interrogazione è stato considerato anche il caso particolare (seconda condizione del WHERE) di famiglie
appena registrate ma che non hanno mai effettuato spese, per cui non hanno mai fissato appuntamenti.
*/

/*
SELECT f.CodiceFamiglia
FROM Famiglia f NATURAL LEFT OUTER JOIN Cliente c 
                NATURAL LEFT OUTER JOIN Appuntamento a 
WHERE (f.SaldoPuntiMensile > 0 AND a.DataOraInizio NOT BETWEEN (CURRENT_TIMESTAMP - interval '1 month') AND CURRENT_TIMESTAMP)
      OR (f.SaldoPuntiMensile > 0 AND f.CodiceFamiglia IN (SELECT c2.CodiceFamiglia
                                                           FROM  Cliente c2
                                                           GROUP BY c2.CodiceFamiglia
                                                           EXCEPT 
                                                           SELECT c3.CodiceFamiglia
                                                           FROM Cliente c3 JOIN Appuntamento a2 ON c3.CodiceCliente = a2.CodiceCliente
                                                           GROUP BY c3.CodiceFamiglia))
GROUP BY f.CodiceFamiglia
ORDER BY f.CodiceFamiglia;
*/

/*
C.b - Determinare le tipologie di prodotti acquistate nell’ultimo anno da tutte le famiglie
(cioè ogni famiglia ha acquistato almeno un prodotto di tale tipologia nell’ultimo anno).
[TESTATA E FUNZIONANTE]

Questa interrogazione è piuttosto complessa e richiede il caricamento e l'analisi di 4 tabelle.
Fissato il limite temporale sulle spese e riordinando per tipologia di prodotti, si conta il numero
di volte che la stessa tipologia si ripete per famiglie diverse, se quel numero è uguale al numero
delle famiglie, allora significa che tutte le famiglie hanno comprato quella tipologia.
Si tiene volutamente conto di tutte le famiglie, e non solo di quelle che hanno comprato qualcosa,
come richiesto dall'interrogazione.
*/

--Per avere una stampa non vuota basata sullo script PopolamentoSocialMarket, eseguire questa istruzione.

--DELETE FROM famiglia WHERE codicefamiglia = 5;

/*
SELECT p.Tipologia AS TipologiaProdottoAcquistataDaTutti
FROM (SELECT p.Tipologia, c.CodiceFamiglia
      FROM Prodotto p JOIN Spesa s ON p.CodiceLotto = s.CodiceLotto
                      JOIN Appuntamento a ON s.DataOraInizio = a.DataOraInizio
                      JOIN Cliente c ON a.CodiceCliente = c.CodiceCliente
      WHERE s.DataOraInizio <= CURRENT_TIMESTAMP AND (s.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP
      GROUP BY p.Tipologia, c.CodiceFamiglia
      ORDER BY p.Tipologia) AS p
GROUP BY p.Tipologia
HAVING COUNT(p.Tipologia) >= (SELECT COUNT(*) FROM Famiglia);
*/

/*
C.c - Determinare i prodotti che vengono scaricati (cioè non riescono ad essere distribuiti alle famiglie) 
in quantitativo maggiore rispetto al quantitativo medio scaricato per prodotti della loro tipologia
(es. di tipologia: pasta/riso, tonno sottolio, olio, caffè, ecc.). [TESTATA E FUNZIONANTE]
*/

/*
SELECT p.NomeProdotto, q.Tipologia, s.Quantità AS QuantitàScaricata
FROM Scarica s JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
               JOIN (SELECT p.Tipologia, (SUM(s.Quantità) / COUNT(s.CodiceLotto)) AS QuantitativoMedioScaricato
                     FROM Scarica s JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
                     GROUP BY p.Tipologia) AS q ON p.Tipologia = q.Tipologia
WHERE s.Quantità > q.QuantitativoMedioScaricato
GROUP BY q.Tipologia, p.NomeProdotto, s.Quantità;
*/