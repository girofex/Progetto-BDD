/*
Parte II.4.A - Creazione schema del Social Market.

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

Molti attributi opzionali per rispettare la privacy.
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

Deciso di non inserire ulteriori codici e non limitare i servizi a quelli elencati
nella specifica per giustificare la tabella e permettere un futuro inserimento
di altre tipologie di servizio.
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

N.B. Se un volontario venisse rimosso dalla base dati non avrebbe senso 
mantenere informazioni sui suoi veicoli.
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

N.B. Se venissero cancellati volontari e/o fasce orarie, non avrebbe 
senso mantenere registrata l'associazione.
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
*/
CREATE TABLE Prezzario(
	NomeProdotto TEXT PRIMARY KEY,
	PrezzoPunti INTEGER NOT NULL,

	CONSTRAINT prezzopunti_non_negativo CHECK (PrezzoPunti >= 0)
);

/*
PRODOTTO

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

La DataOra segna ogni singola operazione, per poterla registrare
è stato deciso che servisse la presenza di un volontario ricevitore
inteso anche come ricevitore di operazioni da registrare.
Codice Donatore opzionale perchè non tutte le operazioni registrate
sono associate ad una donazione.
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

La scelta di non inserire ON DELETE CASCADE deriva dal fatto che anche se un
volontario venisse rimosso dalla base dati (es. perchè non offre più servizio)
l'operazione di scarico andrebbe comunque mantenuta. Se un lotto venisse eliminato
non avrebbe senso cancellarne anche l'operazione di scarico.

N.B. DataScarico e non Data perchè PostgreSQL non accetta la sintassi.
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