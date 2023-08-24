/*
Parte II.8 - Triggers.

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
a. Verifica del vincolo che nessun volontario possa essere assegnato a più attività contemporanee
(suggerimento: utilizzare il predicato OVERLAPS);

N.B. 
(NuovaDataOraInizio,NuovaDataOraFine) OVERLAPS ANY (SELECT DataOraInizio, DataOraFine FROM Turno NATURAL JOIN Turnazione WHERE CodiceVolontario = NEW.CodiceVolontario)
                                               /\ 
ERRORE DI SINTASSI

(https://www.postgresql.org/docs/9.0/functions-datetime.html) - OVERLAPS
This expression yields true when two time periods (defined by their endpoints) overlap, false when they do not overlap. 
The endpoints can be specified as pairs of dates, times, or time stamps; or as a date, time, or time stamp followed by an interval.
*/

CREATE OR REPLACE FUNCTION VerificaTurnazioneVolontario() 
RETURNS TRIGGER AS 
$$
DECLARE
NuovaDataOraInizio TIMESTAMP;
NuovaDataOraFine TIMESTAMP;

BEGIN
--L'inserimento/aggiornamento è avvenuto in turnazione che registra solamente i codici
--per cui si estrapolano le date e gli orari di inizio e fine del nuovo turno assegnato.
	NuovaDataOraInizio := DataOraInizio FROM Turno tr WHERE tr.CodiceTurno = NEW.CodiceTurno;
	NuovaDataOraFine := DataOraFine FROM Turno tr WHERE tr.CodiceTurno = NEW.CodiceTurno;
--Si presume che nella base dati il suddetto volontario, dato un determinato giorno e fascia oraria
--non abbia alcun compito assegnato o, al massimo, ne abbia uno. Si contano le tuple dove appare il
--volontario da considerare e dove avviene una sovrapposizione di orari e date. Se vi è più di una
--sovrapposizione (viene considerata la tupla OLD che sovrappone se stessa) si annulla l'inserimento/
--aggiornamento e lo si segnala.
	IF((SELECT COUNT(*) 
	    FROM Turno tr NATURAL JOIN Turnazione tz
	    WHERE CodiceVolontario = NEW.CodiceVolontario AND ((NuovaDataOraInizio, NuovaDataOraFine) OVERLAPS (tr.DataOraInizio, tr.DataOraFine))) > 1) THEN
		RAISE EXCEPTION 'Inserimento/aggiornamento di: % annullato.', NEW;
		RAISE EXCEPTION 'Non si possono assegnare più attività contemporaneamente ad un volontario.';
		ROLLBACK;
	END IF;

	RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER ControlloTurnazioneVolontario
AFTER INSERT OR UPDATE 
ON Turnazione
FOR EACH ROW
EXECUTE PROCEDURE VerificaTurnazioneVolontario();

--TEST con PopolamentoSocialMarket caricato.

--INSERT INTO Turnazione VALUES(12,'VTFFJP39L53L740S', 12); --Sovrapporre (10:00,13:00) con (12:00,14:00) stesso giorno.
--INSERT INTO Turnazione VALUES(13,'VTFFJP39L53L740S', 13); --Sovrapporre (13:00,15:00) con (12:00,14:00) stesso giorno.
--INSERT INTO Turnazione VALUES(14,'VTFFJP39L53L740S', 14); --Sovrapporre (10:00,15:00) con (12:00,14:00) stesso giorno.
--INSERT INTO Turnazione VALUES(15,'VTFFJP39L53L740S', 15); --Sovrapporre (12:30,13:00) con (12:00,14:00) stesso giorno.

/*
--Legittimo, cambio/aggiornamento turno.
UPDATE Turnazione
SET CodiceTurno = 15
WHERE CodiceId = 11;
*/

/*
--Sovrappone (12:30,13:00) con (12:00,14:00) stesso giorno.
UPDATE Turnazione
SET CodiceTurno = 16
WHERE CodiceId = 11;
*/

/*
--Aggiornamento per Volontario, sovrappone (08:00,10:00) con (08:00,10:00) stesso giorno.
UPDATE Turnazione
SET CodiceTurno = 4
WHERE CodiceVolontario = 'CNSNVP35P44B666D' AND CodiceTurno = 3;
*/

/*
b. Mantenimento della disponibilità corrente dei prodotti.

N.B.
Le funzioni vengono invocate dopo che è avvenuto un inserimento una modifica o una cancellazione,
quindi è stato passato il controllo sul vincolo chiave esterna e il CodiceLotto,
ergo il prodotto c'è, non serve controllarlo, e la quantità non è negativa.
La necessità di spezzare il singolo trigger in 3 funzioni con 6 trigger deriva dal fatto che
vi sono 2 relazioni/tabelle che agiscono su di essa direttamente, ossia Spesa e Scarica e
le operazioni di inserimento (riduzione quantità), aggiornamento (riduzione o aggiunta) e
eliminazione (aggiunta quantità) richiedono diversi UPDATE di PRODOTTO.
*/

--TRIGGER INSERT - INSERIMENTO [TESTATA E FUNZIONANTE]

CREATE OR REPLACE FUNCTION VerificaDisponibilitàProdotto() 
RETURNS TRIGGER AS 
$VerificaDisponibilitàProdotto$
BEGIN
--Controllo se la quantità indicata in Spesa/Scarica è maggiore di quella attualmente registrata
--in PRODOTTO, se lo è si annulla l'operazion e si segnala.
	IF((SELECT p.Quantità FROM Prodotto p WHERE p.CodiceLotto = NEW.CodiceLotto) < NEW.Quantità) THEN
		RAISE EXCEPTION 'Tupla inserita: % con quantità superiore a quella disponibile. Inserimento annullato.', NEW;
		ROLLBACK;
	ELSE
--Se supera il controllo allora esegue l'update su PRODOTTO mantenendo la base dati aggiornata.
		UPDATE Prodotto p
		SET Quantità = (Quantità - NEW.Quantità)
		WHERE p.CodiceLotto = NEW.CodiceLotto;
		RAISE NOTICE 'Aggiornato il lotto % in PRODOTTO (quantità -%)', NEW.CodiceLotto, NEW.Quantità;
	END IF;
	
	RETURN NEW;
END;
$VerificaDisponibilitàProdotto$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER ControlloDisponibilitàProdottoScarica
AFTER INSERT
ON Scarica
FOR EACH ROW
EXECUTE PROCEDURE VerificaDisponibilitàProdotto();

CREATE OR REPLACE TRIGGER ControlloDisponibilitàProdottoSpesa
AFTER INSERT
ON Spesa
FOR EACH ROW
EXECUTE PROCEDURE VerificaDisponibilitàProdotto();

--TEST con PopolamentoSocialMarket caricato.

--INSERT INTO Spesa VALUES (16,'11.08.2022 16:00:00',500,4); --Non legit (quantità superiore).
--INSERT INTO Scarica VALUES (10,'VYPGKB90R59B664C',4,'19.08.2022', 500); --Non legit (quantità superiore).

--TRIGGER UPDATE - AGGIORNAMENTO [TESTATA E FUNZIONANTE]

CREATE OR REPLACE FUNCTION AggiornaDisponibilitàProdotto() 
RETURNS TRIGGER AS 
$AggiornaDisponibilitàProdotto$
BEGIN
--Controllo sulla quantità indicata in Spesa è maggiore di quella attualmente registrata
--in PRODOTTO, se lo è si annulla l'operazion e si segnala.
	IF((SELECT (p.Quantità + OLD.Quantità) FROM Prodotto p WHERE p.CodiceLotto = NEW.CodiceLotto) < NEW.Quantità) THEN
		RAISE EXCEPTION 'Tupla inserita: % con quantità superiore a quella disponibile. Inserimento/aggiornamento annullato.', NEW;
		ROLLBACK;
	ELSE
--Se supera il controllo allora esegue l'update su PRODOTTO mantenendo la base dati aggiornata.
		UPDATE Prodotto p
		SET Quantità = (Quantità + OLD.Quantità - NEW.Quantità)
		WHERE p.CodiceLotto = NEW.CodiceLotto;
		RAISE NOTICE 'Aggiornato il lotto % in PRODOTTO.', NEW.CodiceLotto;
		RAISE NOTICE 'Vecchia quantità = %, Nuova quantità = %', OLD.Quantità, NEW.Quantità;
	END IF;
	
	RETURN NEW;
END;
$AggiornaDisponibilitàProdotto$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER ControlloDisponibilitàProdottoScarica
AFTER UPDATE
ON Scarica
FOR EACH ROW
EXECUTE PROCEDURE AggiornaDisponibilitàProdotto();

CREATE OR REPLACE TRIGGER ControlloDisponibilitàProdottoSpesa
AFTER UPDATE
ON Spesa
FOR EACH ROW
EXECUTE PROCEDURE AggiornaDisponibilitàProdotto();

--TEST con PopolamentoSocialMarket caricato.

/*
--Legit (tolta una sola unità dal lotto 5 anzichè quattro).
UPDATE Spesa
SET Quantità = 4 --Prima era 3.
WHERE CodiceSpesa = 14;
*/

/*
--Non legit, quantità superiore.
UPDATE Spesa
SET Quantità = 200
WHERE CodiceSpesa = 14;
*/

--TRIGGER - CANCELLAZIONE [TESTATA E FUNZIONANTE]

CREATE OR REPLACE FUNCTION RipristinaDisponibilitàProdotto() 
RETURNS TRIGGER AS 
$RipristinaDisponibilitàProdotto$
BEGIN
--Non c'è bisogno di effettuare controlli, una cancellazione presume inserimenti e modifiche legittime,
--serve solo ripristinare la quantità per mantenere la disponibilità prodotti aggiornata e consistente.
--Una cancellazione, tipicamente, avviene quando si annulla un'operazione di spesa (es. un cliente che
--restituisce un prodotto appena comprato) o di scarica (es, quando un operatore si accorge di aver
--erroneamente cancellato un prodotto presente e/o non scaduto).
	UPDATE Prodotto p
	SET Quantità = Quantità + OLD.Quantità
	WHERE p.CodiceLotto = OLD.CodiceLotto;

	RAISE NOTICE 'Cancellazione in Spesa/Scarica, ripristinato il lotto % in PRODOTTO (quantità +%)', OLD.CodiceLotto, OLD.Quantità;
	
	RETURN NEW;
END;
$RipristinaDisponibilitàProdotto$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER RipristinaDisponibilitàProdottoScarica
AFTER DELETE
ON Scarica
FOR EACH ROW
EXECUTE PROCEDURE RipristinaDisponibilitàProdotto();

CREATE OR REPLACE TRIGGER RipristinaDisponibilitàProdottoSpesa
AFTER DELETE
ON Spesa
FOR EACH ROW
EXECUTE PROCEDURE RipristinaDisponibilitàProdotto();

--TEST con PopolamentoSocialMarket caricato.

--DELETE FROM Spesa WHERE CodiceLotto = 5; --Legit.
--DELETE FROM Scarica WHERE CodiceLotto = 1; --Legit.