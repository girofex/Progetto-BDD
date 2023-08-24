/*
Parte II - SQL.

Per ulteriori informazioni consultare la documentazione
allegata (Parte I), le informazioni in essa contenute
insieme a quelle qui presenti forniscono lo schema
completo.

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
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
Parte II.4 - Creazione schema del Social Market.
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/

CREATE schema socialmarket;
set search_path to socialmarket;

/*
AUTORIZZATORE
*/
CREATE TABLE Autorizzatore(
	CodiceAutorizzatore BIGINT PRIMARY KEY,
	Tipologia TEXT NOT NULL,
	Nome TEXT NOT NULL,
	Città TEXT NOT NULL,
	Via TEXT NOT NULL,
	NumeroCivico TEXT NOT NULL
);

/*
FAMIGLIA
*/

CREATE TABLE Famiglia(
	CodiceFamiglia BIGINT PRIMARY KEY,
	NumeroComponenti INTEGER NOT NULL,
	Reddito INTEGER NOT NULL,
	Patrimonio INTEGER NOT NULL,
	SaldoPuntiMensile INTEGER NOT NULL,
	SaldoPuntiAttuale INTEGER NOT NULL,

	CONSTRAINT famiglia_valori_non_negativi 
	CHECK(NumeroComponenti > 0 AND Reddito >= 0 AND Patrimonio >= 0),
	CONSTRAINT famiglia_saldi_tra_0_e_60
	CHECK(SaldoPuntiMensile >= 0 AND SaldoPuntiMensile <= 60 AND 
	SaldoPuntiAttuale >= 0 AND SaldoPuntiAttuale <= 60),
	CONSTRAINT famiglia_saldo_attuale_non_maggiore_di_saldo_mensile
	CHECK(SaldoPuntiAttuale <= SaldoPuntiMensile)
);

/*
CLIENTE

Nota:
La ridondanza del codice cliente e del codice fiscale deriva solamente dalla richiesta
della specifica.
I dati di contatto possono essere opzionali in quanto dei clienti in condizioni economiche
di disagio potrebbero non avere un telefono fisso/cellulare, e non è neanche nell'interesse
del social market avere per forza questi dati perchè è un servizio che serve ai clienti.

La scelta di non inserire ON DELETE CASCADE su Autorizzatore deriva dal fatto che
i clienti, una volta autorizzati e comunque inseriti nella base di dati, sono
svincolati da chi li autorizza.
*/

CREATE TABLE Cliente(
	CodiceCliente BIGINT PRIMARY KEY,
	CodiceFiscale CHAR(16) UNIQUE NOT NULL,
	Nome TEXT NOT NULL,
	Cognome TEXT NOT NULL,
	DataNascita DATE NOT NULL,
	NumeroTelefono BIGINT,
	Email TEXT,
	ReferenteFamiglia BOOLEAN,
	DataInizioAutorizzazione DATE,
	CodiceAutorizzatore BIGINT NOT NULL,
	CodiceFamiglia BIGINT NOT NULL,
	
	FOREIGN KEY (CodiceAutorizzatore) REFERENCES Autorizzatore(CodiceAutorizzatore)
	ON UPDATE CASCADE,
	FOREIGN KEY (CodiceFamiglia) REFERENCES Famiglia(CodiceFamiglia)
	ON UPDATE CASCADE ON DELETE CASCADE
);

/*
DONATORE

Nota: Molti attributi opzionali per rispettare la privacy.
*/

CREATE TABLE Donatore(
	CodiceFiscale CHAR(16) PRIMARY KEY,
	Tipologia TEXT NOT NULL CHECK (Tipologia IN ('privato', 'associazione', 'esercizio commerciale')),
	Nome TEXT,
	Città TEXT,
	Via TEXT,
	NumeroCivico TEXT,
	NumeroTelefono BIGINT,
	Email TEXT
);

/*
SERVIZIO

Nota:
E' stato deciso di non inserire ulteriori codici e non limitare i servizi a 
quelli elencati nella specifica per giustificare la tabella e permettere un 
futuro inserimento di altre tipologie di servizio.
*/

CREATE TABLE Servizio(
	Tipologia TEXT PRIMARY KEY
);

/*
VOLONTARIO
*/

CREATE TABLE Volontario(
	CodiceFiscale CHAR(16) PRIMARY KEY,
	Nome TEXT NOT NULL,
	Cognome TEXT NOT NULL,
	NumeroTelefono BIGINT NOT NULL,
	Email TEXT,
	Associazione TEXT NOT NULL
);

/*
VEICOLO

Nota: Inserito ON DELETE CASCADE in quanto i veicoli sono
legati e di proprietà dei singoli volontari.
*/

CREATE TABLE Veicolo(
	Targa CHAR(10) PRIMARY KEY,
	ModelloVeicolo TEXT NOT NULL,
	Conducente CHAR(16) NOT NULL,
	
	FOREIGN KEY (Conducente) REFERENCES Volontario(CodiceFiscale)
	ON UPDATE CASCADE ON DELETE CASCADE
);

/*
TURNO
*/

CREATE TABLE Turno(
	CodiceTurno BIGINT PRIMARY KEY,
	DataOraInizio TIMESTAMP NOT NULL,
	DataOraFine TIMESTAMP NOT NULL,
	TipologiaServizio TEXT NOT NULL,

	CONSTRAINT dataorafine_antecedente_a_dataorainizio 
	CHECK (DataOraFine > DataOraInizio),

	UNIQUE(DataOraInizio, DataOraFine, TipologiaServizio)
);

/*
TURNAZIONE
*/

CREATE TABLE Turnazione(
	CodiceID BIGINT PRIMARY KEY,
	CodiceVolontario CHAR(16) NOT NULL,
	CodiceTurno BIGINT NOT NULL,
	
	FOREIGN KEY (CodiceVolontario) REFERENCES Volontario(CodiceFiscale)
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (CodiceTurno) REFERENCES Turno(CodiceTurno)
	ON UPDATE CASCADE ON DELETE CASCADE,
	
	UNIQUE(CodiceVolontario, CodiceTurno)
);

/*
FASCIA ORARIA
*/

CREATE TABLE FasciaOraria(
	CodiceID BIGINT PRIMARY KEY,
	DataOraInizio TIMESTAMP NOT NULL,
	DataOraFine TIMESTAMP NOT NULL,

	CONSTRAINT dataorafine_meno_recente_di_dataorainizio 
	CHECK (DataOraFine > DataOraInizio),

	UNIQUE(DataOraInizio, DataOraFine)
);

/*
DISPONIBILITA'

Nota: Inserito ON DELETE CASCADE in quanto sia i volontari
che gli orari sono legati in questa relazione/tabella, in
assenza di uno di essi la disponibilità viene rimossa.
*/

CREATE TABLE Disponibilità(
	CodiceDisponibilità BIGINT PRIMARY KEY,
	CodiceVolontario CHAR(16) NOT NULL,
	CodiceFasciaOraria BIGINT NOT NULL,
	
	FOREIGN KEY (CodiceVolontario) REFERENCES Volontario(CodiceFiscale)
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (CodiceFasciaOraria) REFERENCES FasciaOraria(CodiceID)
	ON UPDATE CASCADE ON DELETE CASCADE,
	
	UNIQUE(CodiceVolontario, CodiceFasciaOraria)
);

/*
PREZZARIO

Nota: Per separare il concetto di prezzo dai lotti dei prodotti.
*/

CREATE TABLE Prezzario(
	NomeProdotto TEXT PRIMARY KEY,
	PrezzoPunti INTEGER NOT NULL,

	CONSTRAINT prezzopunti_non_negativo CHECK (PrezzoPunti >= 0)
);

/*
PRODOTTO

Nota:
La DataCommestibilità può non esserci se si parla di prodotti che non scadono
(es. rotolo di carta).

Per la DataScadenza è stata resa obbligatoria e parte della chiave alternativa per
permettere di registrare i prodotti in lotti in base alla data di scadenza e
consentire così la ricerca/eliminazione di prodotti scaduti o in scadenza in maniera 
facile e comoda anche per l'operazione di scarico.

La scelta di non inserire ON DELETE CASCADE su NomeProdotto è voluta. Prezzario è
solo un registro che associa ai prodotti un prezzo, la sua eliminazione non implica
la rimozione del prodotto dal social market (anche per mantenere consistenza nella
base dati).
*/

CREATE TABLE Prodotto(
	CodiceLotto BIGINT PRIMARY KEY,
	Quantità INTEGER NOT NULL,
	DataCommestibilità DATE,
	DataScadenza DATE NOT NULL,
	NomeProdotto TEXT NOT NULL,
	Tipologia TEXT NOT NULL,
	
	FOREIGN KEY (NomeProdotto) REFERENCES Prezzario(NomeProdotto) ON UPDATE CASCADE,
	CONSTRAINT datacommestibilità_più_recente_di_datascadenza 
	CHECK (DataCommestibilità >= DataScadenza),
	CONSTRAINT quantità_non_negativa CHECK (Quantità >= 0),

	UNIQUE (DataScadenza, NomeProdotto)
);

/*
INGRESSO MERCE

Nota:
La DataOra segna ogni singola operazione, per poterla registrare
è stato deciso che servisse la presenza di un volontario ricevitore
inteso anche come ricevitore di operazioni da registrare.
Codice Donatore opzionale perchè non tutte le operazioni registrate
sono associate ad una donazione.
Si registrano anche le operazioni di cassa.
*/

CREATE TABLE IngressoMerce(
	DataOra TIMESTAMP PRIMARY KEY,
	Importo NUMERIC(12,2) NOT NULL,
	Tipologia TEXT NOT NULL CHECK (Tipologia IN 
	('denaro', 'prodotto', 'spesa di gestione', 'acquisto')),
	CodiceDonatore CHAR(16),
	CodiceRicevitore CHAR(16) NOT NULL,
	
	FOREIGN KEY (CodiceDonatore) REFERENCES Donatore(CodiceFiscale),
	FOREIGN KEY (CodiceRicevitore) REFERENCES Volontario(CodiceFiscale)
);

/*
TRASPORTO 

Nota: DataOra nonostante sia UNIQUE può essere NULL. Come suggerito dalla specifica e dal buonsenso
i trasporti possono venir registrati perchè programmati per i giorni successivi, senza dover
già registrare l'operazione in INGRESSO MERCE, aka il ricevimento in magazzino, dei prodotti.
Tuttavia se il trasporto è avvenuto e il ricevimento dei prodotti è registrato, ogni trasporto
deve avere una sua univoca registrazione in INGRESSO MERCE così da rispettare la cardinalità
dei vincoli dello schema ER.

La scelta di non inserire ON DELETE CASCADE su Volontario deriva dal fatto che anche se un volontario
dovesse smettere di prestare volontariato, e dunque, venisse eliminato dalla base di dati, non avrebbe
senso cancellare le informazioni legate ad un trasporto effettuato.
*/

CREATE TABLE Trasporto(
	CodiceTrasporto BIGINT PRIMARY KEY,
	NumeroCestelli INTEGER NOT NULL,
	Città TEXT NOT NULL,
	Via TEXT NOT NULL,
	NumeroCivico TEXT NOT NULL,
	DataOra TIMESTAMP UNIQUE, --Nota: può essere NULL.
	CodiceTrasportatore CHAR(16) NOT NULL,
	
	FOREIGN KEY (DataOra) REFERENCES IngressoMerce(DataOra) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (CodiceTrasportatore) REFERENCES Volontario(CodiceFiscale) ON UPDATE CASCADE,
	CONSTRAINT numerocestelli_non_negativo CHECK (NumeroCestelli >= 0)
);

/*
INVENTARIO

Nota:
L'inventario funge solo da registro operazioni di ricezione dei prodotti,
la mancanza di ON DELETE CASCADE deriva dal fatto che i prodotti in PRODOTTO
vengono cancellati quando vengono scaricati (tipicamente), per cui non ha
senso cancellare anche la registrazione dell'entrata in automatico.
*/

CREATE TABLE Inventario(
	CodiceID BIGINT PRIMARY KEY,
	NomeProdotto TEXT NOT NULL,
	DataScadenza DATE NOT NULL,
	DataOra TIMESTAMP NOT NULL,
	
	FOREIGN KEY (NomeProdotto, DataScadenza) REFERENCES Prodotto(NomeProdotto, DataScadenza)
	ON UPDATE CASCADE,
	FOREIGN KEY (DataOra) REFERENCES IngressoMerce(DataOra) ON UPDATE CASCADE,
	
	UNIQUE(NomeProdotto, DataOra)
);

/*
APPUNTAMENTO

Nota:
La scelta di non inserire ON DELETE CASCADE su titolare deriva dal fatto che non ha senso
cancellare un appuntamento registrato solo se viene cancellato il titolare che l'ha fissato.
*/

CREATE TABLE Appuntamento(
	DataOraInizio TIMESTAMP PRIMARY KEY,
	SaldoIniziale INTEGER NOT NULL,
	SaldoFinale INTEGER NOT NULL,
	CodiceCliente BIGINT NOT NULL,
	CodiceTitolare BIGINT NOT NULL,
	CodiceVolontario CHAR(16) NOT NULL,

	FOREIGN KEY (CodiceCliente) REFERENCES Cliente(CodiceCliente) ON UPDATE CASCADE,
	FOREIGN KEY (CodiceTitolare) REFERENCES Cliente(CodiceCliente) ON UPDATE CASCADE,
	FOREIGN KEY (CodiceVolontario) REFERENCES Volontario(CodiceFiscale)
	ON UPDATE CASCADE,

	CONSTRAINT saldo_valido_tra_0_e_60 
	CHECK (SaldoFinale <= SaldoIniziale AND SaldoIniziale >= 0 AND
	SaldoFinale >= 0 AND SaldoIniziale <= 60 AND SaldoFinale <= 60)
);


/*
FORNIRE SERVIZIO
*/

CREATE TABLE FornireServizio(
	CodiceID BIGINT PRIMARY KEY,
	CodiceVolontario CHAR(16) NOT NULL,
	TipologiaServizio TEXT NOT NULL,
	
	FOREIGN KEY (CodiceVolontario) REFERENCES Volontario(CodiceFiscale)
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (TipologiaServizio) REFERENCES Servizio(Tipologia)
	ON UPDATE CASCADE ON DELETE CASCADE,

	UNIQUE(CodiceVolontario, TipologiaServizio)
);

/*
SCARICA

Nota:
La scelta di non inserire ON DELETE CASCADE deriva dal fatto che anche se un
volontario venisse rimosso dalla base dati (es. perchè non offre più servizio)
l'operazione di scarico andrebbe comunque mantenuta. Se un lotto venisse eliminato
non avrebbe senso cancellarne anche l'operazione di scarico.

DataScarico e non Data perchè PostgreSQL non accetta la sintassi.
Ma questo non viene modificato nella documentazione essendo una problematica
legata ad uno specifico applicativo e non valido per qualsiasi base di dati.
*/

CREATE TABLE Scarica(
	CodiceScaricamento BIGINT PRIMARY KEY,
	CodiceVolontario CHAR(16) NOT NULL,
	CodiceLotto BIGINT UNIQUE NOT NULL,
	DataScarico DATE NOT NULL,
	Quantità INTEGER NOT NULL,
	
	FOREIGN KEY (CodiceVolontario) REFERENCES Volontario(CodiceFiscale) ON UPDATE CASCADE,
	FOREIGN KEY (CodiceLotto) REFERENCES Prodotto(CodiceLotto) ON UPDATE CASCADE,

	CONSTRAINT quantità_dev_essere_positiva CHECK (Quantità > 0)
);

/*
SPESA

La scelta di non inserire ON DELETE CASCADE su CodiceLotto deriva dal fatto che
i lotti vengono tipicamente cancellati se vengono, per esempio, scaricati, non ha quindi
senso cancellare le informazioni riguardo la spesa fatta dai clienti.
Se un appuntamento viene cancellato, la spesa che registra l'uscita del prodotto rimane per
mantere registro delle uscite e la disponibilità prodotti aggiornata.
*/

CREATE TABLE Spesa(
	CodiceSpesa BIGINT PRIMARY KEY,
	DataOraInizio TIMESTAMP NOT NULL,
	Quantità INTEGER NOT NULL,
	CodiceLotto BIGINT NOT NULL,
	
	FOREIGN KEY (DataOraInizio) REFERENCES Appuntamento(DataOraInizio)
	ON UPDATE CASCADE,
	FOREIGN KEY (CodiceLotto) REFERENCES Prodotto(CodiceLotto)
	ON UPDATE CASCADE,

	CONSTRAINT quantità_non_negativa CHECK (Quantità >= 0),

	UNIQUE(DataOraInizio, CodiceLotto)
);

/*
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
Parte II.4 - Popolamento base dello schema del Social Market.
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/

set datestyle to 'DMY';

--Donatori
INSERT INTO Donatore VALUES ('GYHVGI51H50A612C','privato','Goyah',NULL,NULL,NULL,3335456811,NULL);
INSERT INTO Donatore VALUES ('JNRBNH98H56C359P','privato','Joner',NULL,NULL,NULL,3316884419,'Ben.Maribarski5@yahoo.it');
INSERT INTO Donatore VALUES ('MWJZSV99S44B669J','privato',NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO Donatore VALUES ('0125557489690123','esercizio commerciale','Conad','Genova','Delle campane',17,3312041888,NULL);
INSERT INTO Donatore VALUES ('PJTDZV43H12C991K','associazione','Scout','Chiavari','Delle rose',2,NULL,'Jen.Maribarski@yahoo.it');

--Volontari
INSERT INTO Volontario VALUES ('CNSNVP35P44B666D','Canesi','Novapa',3312659885,NULL,'scout');
INSERT INTO Volontario VALUES ('VYPGKB90R59B664C','Voyap','Gokab',3342659886,'FredPoplock2@kpn.it','scout');
INSERT INTO Volontario VALUES ('JWPMGM79T45F857G','Jiwapo','Magomi',3352629187,NULL,'scout');
INSERT INTO Volontario VALUES ('VTFFJP39L53L740S','Vitof','Fojep',3362609888,NULL,'scout');
INSERT INTO Volontario VALUES ('KSABPD77D07L382D','Kasa','Bapido',3372257889,'PBogdanovich@mail.it','scout');

--Prezzari
INSERT INTO Prezzario VALUES ('Acqua naturale saguaro',1);
INSERT INTO Prezzario VALUES ('Pane integrale',2);
INSERT INTO Prezzario VALUES ('Merluzzo',3);
INSERT INTO Prezzario VALUES ('Rotolo carta scottex',4);
INSERT INTO Prezzario VALUES ('Nebbiolo',5);

INSERT INTO Prezzario VALUES ('Acqua frizzante saguaro',1);
INSERT INTO Prezzario VALUES ('Pane di triora',2);
INSERT INTO Prezzario VALUES ('Pane siciliano',2);
INSERT INTO Prezzario VALUES ('Orata',3);
INSERT INTO Prezzario VALUES ('Nasello',3);
INSERT INTO Prezzario VALUES ('Barbera alba',5);
INSERT INTO Prezzario VALUES ('Rossese',5);

--Prodotti
INSERT INTO Prodotto VALUES (1,5,'13.08.2022','12.08.2022','Pane integrale', 'Pane');
INSERT INTO Prodotto VALUES (2,12,'15.08.2022','14.08.2022','Merluzzo', 'Pesce');
INSERT INTO Prodotto VALUES (3,5,'16.08.2022','15.08.2022','Merluzzo', 'Pesce');
INSERT INTO Prodotto VALUES (4,5,'12.09.2022','12.09.2022','Acqua naturale saguaro', 'Acqua');
INSERT INTO Prodotto VALUES (5,15,NULL,'01.01.3000','Rotolo carta scottex', 'Carta');
--Per test INTERROGAZIONE.
INSERT INTO Prodotto VALUES (6,0,'25.08.2020','20.08.2020','Orata', 'Pesce');         --10
INSERT INTO Prodotto VALUES (7,0,'15.08.2020','12.08.2020','Pane di triora', 'Pane'); --50
INSERT INTO Prodotto VALUES (8,0,'31.12.2021','11.08.2021','Rossese', 'Vino');        --30
INSERT INTO Prodotto VALUES (9,0,'31.12.2021','11.08.2021','Barbera alba', 'Vino');   --40

--IngressiMerce
INSERT INTO IngressoMerce VALUES ('11.08.2022 08:00:00',30,'prodotto',NULL,'KSABPD77D07L382D');
INSERT INTO IngressoMerce VALUES ('11.08.2022 09:00:00',10,'prodotto',NULL,'KSABPD77D07L382D');
INSERT INTO IngressoMerce VALUES ('11.08.2022 10:00:00',12,'prodotto',NULL,'KSABPD77D07L382D');
INSERT INTO IngressoMerce VALUES ('11.08.2022 11:00:00',-100,'acquisto',NULL,'KSABPD77D07L382D');
INSERT INTO IngressoMerce VALUES ('11.08.2022 12:00:00',100,'denaro','PJTDZV43H12C991K','KSABPD77D07L382D');

INSERT INTO IngressoMerce VALUES ('11.08.2020 10:00:00',200,'prodotto',NULL,'KSABPD77D07L382D');

--Inventario
INSERT INTO Inventario VALUES (1,'Rotolo carta scottex','01.01.3000','11.08.2022 08:00:00');
INSERT INTO Inventario VALUES (2,'Merluzzo','15.08.2022','11.08.2022 08:00:00');
INSERT INTO Inventario VALUES (3,'Pane integrale','12.08.2022','11.08.2022 09:00:00');
INSERT INTO Inventario VALUES (4,'Merluzzo','14.08.2022','11.08.2022 10:00:00');
INSERT INTO Inventario VALUES (5,'Acqua naturale saguaro','12.09.2022','11.08.2022 08:00:00');

--Trasporti
INSERT INTO Trasporto VALUES (1,4,'Genova','Delle rimembranze','5',NULL,'CNSNVP35P44B666D');
INSERT INTO Trasporto VALUES (2,10,'Genova','Dei vini','5','11.08.2022 08:00:00','CNSNVP35P44B666D');
INSERT INTO Trasporto VALUES (3,12,'Genova','Dei soldati','18',NULL,'CNSNVP35P44B666D');
INSERT INTO Trasporto VALUES (4,11,'Genova','Dei cannoni','19/A','11.08.2022 09:00:00','CNSNVP35P44B666D');
INSERT INTO Trasporto VALUES (5,11,'Genova','Del giacinto','2B','11.08.2022 10:00:00','CNSNVP35P44B666D');

INSERT INTO Trasporto VALUES (6,100,'Genova','Dello scoglio','11','11.08.2020 10:00:00','CNSNVP35P44B666D');

--Famiglie
INSERT INTO Famiglia VALUES (1,4,50000,100000,35,0);
INSERT INTO Famiglia VALUES (2,3,40000,90000,45,37);
INSERT INTO Famiglia VALUES (3,1,15000,80000,50,19);
INSERT INTO Famiglia VALUES (4,1,10000,70000,55,47);
--Per test VISTA.
INSERT INTO Famiglia VALUES (5,1,5000,10000,60,60);

--Autorizzatori
INSERT INTO Autorizzatore VALUES (1,'servizio sociale','Cuore','Sestri Levante','Dei telefoni','20');
INSERT INTO Autorizzatore VALUES (2,'centro ascolto','Sole','Chiavari','Dei gatti','17');
INSERT INTO Autorizzatore VALUES (3,'servizio sociale','Amore','Genova','Dei cani','13');
INSERT INTO Autorizzatore VALUES (4,'centro ascolto','Vita','Varazze','Dei criceti','17');
INSERT INTO Autorizzatore VALUES (5,'centro ascolto','Gioia','Genova','Dei megafoni','1');

--Clienti
INSERT INTO Cliente VALUES (1,'LHHHOI80M16I258X','Lahah','Hoi','16.05.1980',3385596454,NULL,TRUE,'17.05.2022',2,1);
INSERT INTO Cliente VALUES (2,'KTNRGC80M11E949X','Katon','Ragocu','11.05.1980',3395895454,NULL,TRUE,'20.05.2022',2,2);
INSERT INTO Cliente VALUES (3,'LWZLZD82C11A452X','Lowaz','Lozez','11.05.1982',3375296453,NULL,TRUE,'18.05.2022',1,3);
INSERT INTO Cliente VALUES (4,'TMRFDR85M13E184R','Federica','Tamerisco','13.02.1985',3365591454,NULL,TRUE,'22.05.2022',1,4);
--Per test VISTA e INTERROGAZIONI.
INSERT INTO Cliente VALUES (5,'DVNLSS12R28E250I','Alessio','De Vincenzi','28.06.2012',3798659881,NULL,NULL,NULL,2,1);
INSERT INTO Cliente VALUES (6,'CCCMTT10G22E250P','Mattia','Cacciatore','22.03.2010',3805031864,NULL,NULL,NULL,2,1);
INSERT INTO Cliente VALUES (7,'MDRFBA11M10S130K','Fabio','Medori','10.07.2011',3371122334,NULL,NULL,NULL,1,2);
INSERT INTO Cliente VALUES (8,'FNTLCU08M02E111K','Luca','Fenotti','02.07.2008',3342233558,NULL,NULL,'21.05.2022',1,2);
INSERT INTO Cliente VALUES (9,'RSSDRD90M08E184Z','Edoardo','Risso','08.01.1990',3326658491,NULL,NULL,'15.05.2022',2,1);

INSERT INTO Cliente VALUES (10,'CTNLSS79I22D277C','Alessandro','Catena','22.02.1979',3335566784,NULL,TRUE,'21.05.2022',2,5);

--Appuntamenti
INSERT INTO Appuntamento VALUES ('11.08.2022 12:00:00',35,33,1,1,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 12:20:00',33,31,1,1,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 12:40:00',30,28,3,3,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 13:00:00',55,53,4,4,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 13:20:00',45,43,2,2,'VTFFJP39L53L740S');

INSERT INTO Appuntamento VALUES ('11.08.2022 13:40:00',53,50,4,4,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 14:00:00',50,47,4,4,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 14:20:00',43,40,2,2,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 14:40:00',40,37,2,2,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 15:00:00',28,25,3,3,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 15:20:00',25,22,3,3,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 15:40:00',22,19,3,3,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2022 16:00:00',31,0,9,1,'VTFFJP39L53L740S');

INSERT INTO Appuntamento VALUES ('11.08.2020 13:20:00',50,48,3,3,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2020 13:40:00',48,45,3,3,'VTFFJP39L53L740S');
INSERT INTO Appuntamento VALUES ('11.08.2020 14:00:00',45,43,2,2,'VTFFJP39L53L740S');

INSERT INTO Appuntamento VALUES ('11.08.2025 13:20:00',45,45,2,2,'VTFFJP39L53L740S');

--Spese
INSERT INTO Spesa VALUES (1,'11.08.2022 12:00:00',1,1);
INSERT INTO Spesa VALUES (2,'11.08.2022 12:20:00',1,1);
INSERT INTO Spesa VALUES (3,'11.08.2022 12:40:00',1,1);
INSERT INTO Spesa VALUES (4,'11.08.2022 13:00:00',1,1);
INSERT INTO Spesa VALUES (5,'11.08.2022 13:20:00',1,1);

INSERT INTO Spesa VALUES (7,'11.08.2022 13:40:00',1,2);
INSERT INTO Spesa VALUES (8,'11.08.2022 14:00:00',1,2);
INSERT INTO Spesa VALUES (9,'11.08.2022 14:20:00',1,2);
INSERT INTO Spesa VALUES (10,'11.08.2022 14:40:00',1,2);
INSERT INTO Spesa VALUES (11,'11.08.2022 15:00:00',1,2);
INSERT INTO Spesa VALUES (12,'11.08.2022 15:20:00',1,2);
INSERT INTO Spesa VALUES (13,'11.08.2022 15:40:00',1,2);

INSERT INTO Spesa VALUES (14,'11.08.2022 16:00:00',3,5);

--Scarica
/*
Nota: Da inserire solo per testing della creazione dello schema e per 
le interrogazioni, altrimenti impedisce la procedura di scarico.
*/
/*
INSERT INTO Scarica VALUES (1,'VYPGKB90R59B664C',1,'14.08.2022', 1);
INSERT INTO Scarica VALUES (2,'VYPGKB90R59B664C',2,'16.08.2022', 1);
INSERT INTO Scarica VALUES (3,'VYPGKB90R59B664C',3,'17.08.2022', 1);
INSERT INTO Scarica VALUES (4,'VYPGKB90R59B664C',4,'18.08.2022', 1);
INSERT INTO Scarica VALUES (5,'VYPGKB90R59B664C',5,'19.08.2022', 1);

INSERT INTO Scarica VALUES (6,'VYPGKB90R59B664C',6,'26.08.2020',10); --Orata
INSERT INTO Scarica VALUES (7,'VYPGKB90R59B664C',7,'26.08.2020',50); --Pane di triora
INSERT INTO Scarica VALUES (8,'VYPGKB90R59B664C',8,'26.08.2020',30); --Rossese
INSERT INTO Scarica VALUES (9,'VYPGKB90R59B664C',9,'26.08.2020',40); --Barbera alba
*/

--Turni
INSERT INTO Turno VALUES (1,'11.08.2022 12:00:00','11.08.2022 14:00:00','accoglienza');
INSERT INTO Turno VALUES (2,'11.08.2022 08:00:00','11.08.2022 10:00:00','trasporto');
INSERT INTO Turno VALUES (3,'11.08.2022 10:00:00','11.08.2022 12:00:00','trasporto');
INSERT INTO Turno VALUES (4,'11.08.2022 08:00:00','11.08.2022 10:00:00','ricezione');
INSERT INTO Turno VALUES (5,'11.08.2022 10:00:00','11.08.2022 12:00:00','ricezione');
INSERT INTO Turno VALUES (6,'14.08.2022 08:00:00','14.08.2022 10:00:00','riordino');
INSERT INTO Turno VALUES (7,'16.08.2022 08:00:00','16.08.2022 10:00:00','riordino');
INSERT INTO Turno VALUES (8,'17.08.2022 08:00:00','17.08.2022 10:00:00','riordino');
INSERT INTO Turno VALUES (9,'18.08.2022 08:00:00','18.08.2022 10:00:00','riordino');
INSERT INTO Turno VALUES (10,'19.08.2022 08:00:00','19.08.2022 10:00:00','riordino');
--Per test TRIGGER.
INSERT INTO Turno VALUES(11, '14.08.2022 12:00:00', '14.08.2022 14:00:00', 'accoglienza');
INSERT INTO Turno VALUES(12, '14.08.2022 10:00:00', '14.08.2022 13:00:00', 'trasporto');
INSERT INTO Turno VALUES(13, '14.08.2022 13:00:00', '14.08.2022 15:00:00', 'riordino');
INSERT INTO Turno VALUES(14, '14.08.2022 10:00:00', '14.08.2022 15:00:00', 'ricezione');
INSERT INTO Turno VALUES(15, '14.08.2022 12:30:00', '14.08.2022 13:00:00', 'collaborazione');
INSERT INTO Turno VALUES(16, '11.08.2022 12:30:00', '11.08.2022 13:00:00', 'collaborazione');
INSERT INTO Turno VALUES(17, '11.08.2025 12:30:00', '11.08.2025 13:00:00', 'collaborazione');

--Servizi
INSERT INTO Servizio VALUES ('trasporto');
INSERT INTO Servizio VALUES ('accoglienza');
INSERT INTO Servizio VALUES ('riordino');
INSERT INTO Servizio VALUES ('ricezione');
INSERT INTO Servizio VALUES ('collaborazione');

--FornireServizi
INSERT INTO FornireServizio VALUES (1,'VYPGKB90R59B664C','riordino');
INSERT INTO FornireServizio VALUES (2,'VTFFJP39L53L740S','accoglienza');
INSERT INTO FornireServizio VALUES (3,'CNSNVP35P44B666D','trasporto');
INSERT INTO FornireServizio VALUES (4,'KSABPD77D07L382D','ricezione');
INSERT INTO FornireServizio VALUES (5,'JWPMGM79T45F857G','collaborazione');

--Veicoli
INSERT INTO Veicolo VALUES ('ITCA256FE','camion','CNSNVP35P44B666D');
INSERT INTO Veicolo VALUES ('ITMH765RR','moto','CNSNVP35P44B666D');
INSERT INTO Veicolo VALUES ('ITKJ333GH','auto','CNSNVP35P44B666D');
INSERT INTO Veicolo VALUES ('ITLL145AS','motocarro','CNSNVP35P44B666D');
INSERT INTO Veicolo VALUES ('ITWC782NF','trattore','CNSNVP35P44B666D');

--FasceOrarie
INSERT INTO FasciaOraria VALUES (1,'11.08.2022 08:00:00','11.08.2022 10:00:00');
INSERT INTO FasciaOraria VALUES (2,'11.08.2022 10:00:00','11.08.2022 12:00:00');
INSERT INTO FasciaOraria VALUES (3,'11.08.2022 12:00:00','11.08.2022 14:00:00');
INSERT INTO FasciaOraria VALUES (4,'12.08.2022 08:00:00','12.08.2022 10:00:00');
INSERT INTO FasciaOraria VALUES (5,'12.08.2022 10:00:00','12.08.2022 12:00:00');
INSERT INTO FasciaOraria VALUES (6,'14.08.2022 08:00:00','14.08.2022 10:00:00');
INSERT INTO FasciaOraria VALUES (7,'16.08.2022 08:00:00','16.08.2022 10:00:00');
INSERT INTO FasciaOraria VALUES (8,'17.08.2022 08:00:00','17.08.2022 10:00:00');
INSERT INTO FasciaOraria VALUES (9,'18.08.2022 08:00:00','18.08.2022 10:00:00');
INSERT INTO FasciaOraria VALUES (10,'19.08.2022 08:00:00','19.08.2022 10:00:00');

--Disponibilità
INSERT INTO Disponibilità VALUES (1,'CNSNVP35P44B666D',1);
INSERT INTO Disponibilità VALUES (2,'CNSNVP35P44B666D',2);
INSERT INTO Disponibilità VALUES (3,'VTFFJP39L53L740S',3);
INSERT INTO Disponibilità VALUES (4,'VYPGKB90R59B664C',6);
INSERT INTO Disponibilità VALUES (5,'VYPGKB90R59B664C',7);
INSERT INTO Disponibilità VALUES (6,'VYPGKB90R59B664C',8);
INSERT INTO Disponibilità VALUES (7,'VYPGKB90R59B664C',9);
INSERT INTO Disponibilità VALUES (8,'VYPGKB90R59B664C',10);
INSERT INTO Disponibilità VALUES (9,'KSABPD77D07L382D',1);
INSERT INTO Disponibilità VALUES (10,'KSABPD77D07L382D',2);

--Turnazioni
INSERT INTO Turnazione VALUES (1,'VTFFJP39L53L740S',1);
INSERT INTO Turnazione VALUES (2,'CNSNVP35P44B666D',2);
INSERT INTO Turnazione VALUES (3,'CNSNVP35P44B666D',3);
INSERT INTO Turnazione VALUES (4,'KSABPD77D07L382D',4);
INSERT INTO Turnazione VALUES (5,'KSABPD77D07L382D',5);
INSERT INTO Turnazione VALUES (6,'VYPGKB90R59B664C',6);
INSERT INTO Turnazione VALUES (7,'VYPGKB90R59B664C',7);
INSERT INTO Turnazione VALUES (8,'VYPGKB90R59B664C',8);
INSERT INTO Turnazione VALUES (9,'VYPGKB90R59B664C',9);
INSERT INTO Turnazione VALUES (10,'VYPGKB90R59B664C',10);
--Per test TRIGGER.
INSERT INTO Turnazione VALUES(11,'VTFFJP39L53L740S',11);

/*
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
Parte II.6 - Vista.
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/

/*
B. La definizione di una vista che fornisca alcune informazioni riassuntive per ogni nucleo familiare: il numero di 
punti mensili a disposizione, i punti residui per il mese corrente, il numero di persone autorizzate per l’accesso 
al market, il numero di componenti totali e quelli appartenenti alla fascia d’età più bassa, il numero di 
spese effettuate nell’ultimo anno, i punti eventualmente non utilizzati nell’ultimo anno, la percentuale di punti 
utilizzata per prodotti deperibili e non deperibili nell’ultimo anno.

Nota:
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


--Il numero dei componenti del nucleo familiare appartenenti alla fascia d’età più bassa.

CREATE OR REPLACE VIEW InformazioniGiovani AS
SELECT c.CodiceFamiglia, COUNT(c.CodiceCliente) AS NumeroGiovani
FROM Cliente c
WHERE ((CURRENT_DATE - c.DataNascita) <= 5844)
GROUP BY c.CodiceFamiglia
ORDER BY c.CodiceFamiglia;

--Il numero di persone autorizzate ad accedere al market.

CREATE OR REPLACE VIEW InformazioniAutorizzati AS
SELECT c.CodiceFamiglia, COUNT(c.CodiceCliente) AS NumeroAutorizzati
FROM Cliente c 
WHERE ((CURRENT_DATE - c.DataInizioAutorizzazione) <= 180)
GROUP BY c.CodiceFamiglia
ORDER BY c.CodiceFamiglia;

--Il numero di spese effettuate nell’ultimo anno.

CREATE OR REPLACE VIEW InformazioniSpese AS
SELECT c.CodiceFamiglia, COUNT(a.DataOraInizio) AS NumeroSpese
FROM Cliente c JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
WHERE (a.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP AND a.DataOraInizio <= CURRENT_TIMESTAMP
GROUP BY c.CodiceFamiglia
ORDER BY c.CodiceFamiglia;

--I punti eventualmente non utilizzati nell’ultimo anno.

CREATE OR REPLACE VIEW InformazioniPuntiNonSpesi AS
SELECT f.CodiceFamiglia, (f.SaldoPuntiMensile * 12) - SUM(a.SaldoIniziale - a.SaldoFinale) AS TotalePuntiNonSpesi
FROM Famiglia f JOIN Cliente c ON f.CodiceFamiglia = c.CodiceFamiglia JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
WHERE (a.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP AND a.DataOraInizio <= CURRENT_TIMESTAMP
GROUP BY f.CodiceFamiglia
ORDER BY f.CodiceFamiglia;

--La percentuale di punti utilizzata per prodotti deperibili nell’ultimo anno.

CREATE OR REPLACE VIEW InformazioniPuntiSuProdottiDeperibili AS
SELECT f.CodiceFamiglia, ((SUM(a.SaldoIniziale - a.SaldoFinale) * 100) / (f.SaldoPuntiMensile * 12)) AS PercentualePuntiProdottiDeperibili
FROM Famiglia f JOIN Cliente c ON f.CodiceFamiglia = c.CodiceFamiglia
	        JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
	        JOIN Spesa s ON a.DataOraInizio = s.DataOraInizio
	        JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
WHERE s.DataOraInizio <= CURRENT_TIMESTAMP AND ((s.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP) AND p.DataCommestibilità IS NOT NULL
GROUP BY f.SaldoPuntiMensile, f.CodiceFamiglia
ORDER BY f.CodiceFamiglia;

--La percentuale di punti utilizzata per prodotti NON deperibili nell’ultimo anno.

CREATE OR REPLACE VIEW InformazioniPuntiSuProdottiNonDeperibili AS
SELECT f.CodiceFamiglia, ((SUM(a.SaldoIniziale - a.SaldoFinale) * 100) / (f.SaldoPuntiMensile * 12)) AS PercentualePuntiProdottiNonDeperibili
FROM Famiglia f JOIN Cliente c ON f.CodiceFamiglia = c.CodiceFamiglia
	        JOIN Appuntamento a ON c.CodiceCliente = a.CodiceCliente
	        JOIN Spesa s ON a.DataOraInizio = s.DataOraInizio
	        JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
WHERE s.DataOraInizio <= CURRENT_TIMESTAMP AND ((s.DataOraInizio + interval '1 year') >= CURRENT_TIMESTAMP) AND p.DataCommestibilità IS NULL
GROUP BY f.SaldoPuntiMensile, f.CodiceFamiglia
ORDER BY f.CodiceFamiglia;

--Vista principale.

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

--TEST con PopolamentoSocialMarket caricato (dovrebbe stampare 5 famiglie).

--SELECT * FROM InformazioniFamiglie;

/*
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
Parte II.6 - Interrogazioni.
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/

/*
C.a - Determinare i nuclei familiari che, pur avendo punti assegnati, non hanno effettuato spese nell’ultimo mese;

Nota:
In questa interrogazione è stato considerato anche il caso particolare (seconda condizione del WHERE) di famiglie
appena registrate ma che non hanno mai effettuato spese, per cui non hanno mai fissato appuntamenti.
*/

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

/*
C.b - Determinare le tipologie di prodotti acquistate nell’ultimo anno da tutte le famiglie
(cioè ogni famiglia ha acquistato almeno un prodotto di tale tipologia nell’ultimo anno).

Nota:
Questa interrogazione è piuttosto complessa e richiede il caricamento e l'analisi di 4 tabelle.
Fissato il limite temporale sulle spese e riordinando per tipologia di prodotti, si conta il numero
di volte che la stessa tipologia si ripete per famiglie diverse, se quel numero è uguale al numero
delle famiglie, allora significa che tutte le famiglie hanno comprato quella tipologia.
Si tiene volutamente conto di tutte le famiglie, e non solo di quelle che hanno comprato qualcosa,
come richiesto dall'interrogazione (TUTTE le famiglie).
*/

--Per non avere una stampa vuota basata con lo script PopolamentoSocialMarket, eseguire questa istruzione!!!
--DELETE FROM famiglia WHERE codicefamiglia = 5;

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

/*
C.c - Determinare i prodotti che vengono scaricati (cioè non riescono ad essere distribuiti alle famiglie) 
in quantitativo maggiore rispetto al quantitativo medio scaricato per prodotti della loro tipologia
(es. di tipologia: pasta/riso, tonno sottolio, olio, caffè, ecc.).
*/

SELECT p.NomeProdotto, q.Tipologia, s.Quantità AS QuantitàScaricata
FROM Scarica s JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
               JOIN (SELECT p.Tipologia, (SUM(s.Quantità) / COUNT(s.CodiceLotto)) AS QuantitativoMedioScaricato
                     FROM Scarica s JOIN Prodotto p ON s.CodiceLotto = p.CodiceLotto
                     GROUP BY p.Tipologia) AS q ON p.Tipologia = q.Tipologia
WHERE s.Quantità > q.QuantitativoMedioScaricato
GROUP BY q.Tipologia, p.NomeProdotto, s.Quantità;

/*
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
Parte II.7 - Procedure e funzioni.
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/

/*
a. Funzione che realizza lo scarico dall’inventario dei prodotti scaduti.

Nota:
La funzione deve prendere in input il codice fiscale del volontario per poter registrare lo scaricamento.
Per funzionare correttamente si presume che non siano state effettuate cancellazioni su Scarica [COUNT(*)].
*/

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

--Si tiene conto del codice progressivo per l'aggiornamento di Scarica. COUNT e non MAX perchè MAX
--restituisce null se Scarica è vuota.
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
determinare i turni assegnati al volontario nel periodo compreso tra le due date.
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

/*
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
Parte II.8 - Triggers.
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/

/*
a. Verifica del vincolo che nessun volontario possa essere assegnato a più attività contemporanee
(suggerimento: utilizzare il predicato OVERLAPS);

Nota di servizio:
(NuovaDataOraInizio,NuovaDataOraFine) 
OVERLAPS ANY 
(SELECT DataOraInizio, DataOraFine 
FROM Turno NATURAL JOIN Turnazione 
WHERE CodiceVolontario = NEW.CodiceVolontario)

ERRORE DI SINTASSI

(https://www.postgresql.org/docs/9.6/functions-datetime.html) - OVERLAPS
This expression yields true when two time periods (defined by their endpoints) overlap, false when they do not overlap.
*/

CREATE OR REPLACE FUNCTION VerificaTurnazioneVolontario() 
RETURNS TRIGGER AS 
$VerificaTurnazioneVolontario$
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
$VerificaTurnazioneVolontario$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER ControlloTurnazioneVolontario
AFTER INSERT OR UPDATE 
ON Turnazione
FOR EACH ROW
EXECUTE PROCEDURE VerificaTurnazioneVolontario();

--TEST con PopolamentoSocialMarket caricato.

INSERT INTO Turnazione VALUES(12,'VTFFJP39L53L740S', 12); --Sovrapporre (10:00,13:00) con (12:00,14:00) stesso giorno.
INSERT INTO Turnazione VALUES(13,'VTFFJP39L53L740S', 13); --Sovrapporre (13:00,15:00) con (12:00,14:00) stesso giorno.
INSERT INTO Turnazione VALUES(14,'VTFFJP39L53L740S', 14); --Sovrapporre (10:00,15:00) con (12:00,14:00) stesso giorno.
INSERT INTO Turnazione VALUES(15,'VTFFJP39L53L740S', 15); --Sovrapporre (12:30,13:00) con (12:00,14:00) stesso giorno.

--Legittimo, cambio/aggiornamento turno.

UPDATE Turnazione
SET CodiceTurno = 15
WHERE CodiceId = 11;

--Sovrappone (12:30,13:00) con (12:00,14:00) stesso giorno.

UPDATE Turnazione
SET CodiceTurno = 16
WHERE CodiceId = 11;

--Aggiornamento per Volontario, sovrappone (08:00,10:00) con (08:00,10:00) stesso giorno.

UPDATE Turnazione
SET CodiceTurno = 4
WHERE CodiceVolontario = 'CNSNVP35P44B666D' AND CodiceTurno = 3;

/*
b. Mantenimento della disponibilità corrente dei prodotti.

Nota:
Le funzioni vengono invocate dopo che è avvenuto un inserimento una modifica o una cancellazione,
quindi è stato passato il controllo sul vincolo chiave esterna e il CodiceLotto,
ergo il prodotto c'è, non serve controllarlo, e la quantità non è negativa.
La necessità di spezzare il singolo trigger in 3 funzioni con 6 trigger deriva dal fatto che
vi sono 2 relazioni/tabelle che agiscono su di essa direttamente, ossia Spesa e Scarica e
le operazioni di inserimento (riduzione quantità), aggiornamento (riduzione o aggiunta) e
eliminazione (aggiunta quantità) richiedono diversi UPDATE di PRODOTTO.
*/

--TRIGGER INSERT - INSERIMENTO

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

--Non legit (quantità superiore).
--INSERT INTO Spesa VALUES (16,'11.08.2022 16:00:00',500,4);
--INSERT INTO Scarica VALUES (10,'VYPGKB90R59B664C',4,'19.08.2022', 500);

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
--Legit (tolta una sola unità dal lotto 5 anzichè quattro).

UPDATE Spesa
SET Quantità = 4 --Prima era 3.
WHERE CodiceSpesa = 14;

--Non legit, quantità superiore.

UPDATE Spesa
SET Quantità = 200
WHERE CodiceSpesa = 14;

--TRIGGER - CANCELLAZIONE

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

--Legit.
DELETE FROM Spesa WHERE CodiceLotto = 5;
DELETE FROM Scarica WHERE CodiceLotto = 1;
