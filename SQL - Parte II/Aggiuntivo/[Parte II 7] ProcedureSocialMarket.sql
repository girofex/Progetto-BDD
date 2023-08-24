/*
Parte II.7 - Procedure e funzioni.

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
a. Funzione che realizza lo scarico dall’inventario dei prodotti scaduti. [TESTATA E FUNZIONANTE]
*/

--Funzione che prende in input il codice fiscale del volontario che deve registrare lo scaricamento.

CREATE OR REPLACE FUNCTION ScaricoInventario(IN CodVol CHAR(16))
RETURNS void AS
$$
DECLARE
CodLotto BIGINT;
QuantitàProd INTEGER;
DataCom DATE;
DataScad DATE;
NomeProd TEXT;
TipoProd TEXT;
CodSca BIGINT;
--Non si elimina la tupla in PRODOTTO, si azzera semplicemente la quantità così da
--non avere casini di inconsistenza con i CodiceLotto.
ProdottiScaduti CURSOR FOR SELECT *
                           FROM Prodotto
                           WHERE DataScadenza < CURRENT_DATE AND Quantità > 0;

BEGIN
--Se il codice fiscale del volontario non è presente tra i volontari, l'operazione non viene eseguita per
--preservare la consistenza della base dati (verrebbe eseguito l'update ma non l'insert).
	IF((SELECT COUNT(*) FROM Volontario WHERE CodiceFiscale = CodVol) < 1) THEN
		RAISE EXCEPTION 'Volontario % non presente nella base dati', CodVol;
		RETURN;
	END IF;

--Si tiene conto del codice progressivo per l'aggiornamento di Scarica.
	CodSca := COUNT(*) FROM Scarica;
	OPEN ProdottiScaduti;
	FETCH ProdottiScaduti INTO CodLotto, QuantitàProd, DataCom, DataScad, NomeProd, TipoProd;
		WHILE FOUND LOOP
--Si incrementa il CodiceScaricamento per poter effettuare gli inserimenti in Scarica.
			CodSca = CodSca + 1;
--Si aggiorna Scarica.
			INSERT INTO Scarica VALUES (CodSca, CodVol, CodLotto, CURRENT_DATE, QuantitàProd);
--Si azzera la quantità del suddetto lotto scaduto, ma lo si mantiene nella base dati per mantere la consistenza.
--L'aggiornamento viene fatto dopo per non entrare in conflitto con il TRIGGER.
			UPDATE Prodotto 
			SET Quantità = 0
			WHERE CodiceLotto = CodLotto;
--Si continua la ricerca dei prodotti scaduti fino alla fine della tabella.			
			FETCH ProdottiScaduti INTO CodLotto, QuantitàProd, DataCom, DataScad, NomeProd, TipoProd;
		END LOOP;
	CLOSE ProdottiScaduti;
END;
$$
LANGUAGE plpgsql;

--TEST su script PopolamentoSocialMarket.

--SELECT * FROM ScaricoInventario('VYPGKB90R59B664C');

/*
b. Funzione che corrisponde alla seguente query parametrica: dato un volontario e due date, 
determinare i turni assegnati al volontario nel periodo compreso tra le due date. [TESTATA E FUNZIONANTE]
*/

CREATE OR REPLACE FUNCTION TurnazioneVolontario(IN CodVol CHAR(16), IN DataInizio DATE, IN DataFine DATE)
RETURNS TABLE (CodiceFiscaleVolontario CHAR(16), DataOraInizioTurno TIMESTAMP, DataOraFineTurno TIMESTAMP, TipoServizio TEXT) 
AS $$
DECLARE
BEGIN
	RETURN QUERY SELECT tz.CodiceVolontario, tr.DataOraInizio, tr.DataOraFine, tr.TipologiaServizio
	             FROM Turnazione tz JOIN Turno tr ON tz.CodiceTurno = tr.CodiceTurno
                     WHERE tz.CodiceVolontario = CodVol AND tr.DataOraInizio > DataInizio AND tr.DataOraFine < DataFine;
END;
$$
LANGUAGE plpgsql;

--TEST su script PopolamentoSocialMarket.

--SELECT * FROM TurnazioneVolontario('VTFFJP39L53L740S', '11.08.2010 08:00:00', '11.08.2050 08:00:00');
--SELECT * FROM TurnazioneVolontario('VTFFJP39L53L740S', '11.08.2030 08:00:00', '11.08.2050 08:00:00');