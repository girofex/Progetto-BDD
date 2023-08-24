/*
Parte II.4.A - Popolamento base dello schema del Social Market.

La scelta di separare lo script del popolamento della base dati
da quello della sua creazione è voluta e basata sulla necessità
di differenziare le varie parti l'una dall'altra.

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

/*
--Scarica
--NOTA: da inserire solo per testing della creazione dello schema e per le interrogazioni,
--altrimenti impedisce la procedura di scarico.
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