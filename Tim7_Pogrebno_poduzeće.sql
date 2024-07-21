-- IZRADA BAZE PODATAKA

DROP DATABASE IF EXISTS pogrebno_poduzeće;
CREATE DATABASE pogrebno_poduzeće;
USE Pogrebno_poduzeće;

-- STVARANJE TABLICA

CREATE TABLE grad( 
		id_grad INTEGER PRIMARY KEY,
        grad VARCHAR(25) NOT NULL,
        postanski_broj INTEGER NOT NULL,
        CONSTRAINT check_postanski_broj CHECK (postanski_broj BETWEEN 10000 AND 53999)
        );
        
-- u ovoj tablici atribut id_grad označuje grad u kojem se nalazi grobno mjesto odnosno gdje su pokojnici pokopani
CREATE TABLE grobno_mjesto( 
		id_grobno_mjesto INTEGER PRIMARY KEY,
        id_grad INTEGER NOT NULL, 
        vrsta VARCHAR(12) NOT NULL,
        FOREIGN KEY (id_grad) REFERENCES grad(id_grad)
        );

CREATE TABLE klijent(  
	id_klijent INTEGER PRIMARY KEY,
    ime VARCHAR(20) NOT NULL,
    prezime VARCHAR(30) NOT NULL,
    telefonski_broj VARCHAR(15) NOT NULL,
    CONSTRAINT check_telefonski_broj CHECK (telefonski_broj LIKE '0%')
    );
    
CREATE TABLE crkva(
	id_crkva INTEGER PRIMARY KEY,
    id_grad INTEGER NOT NULL,
    naziv VARCHAR(50) NOT NULL,
    adresa VARCHAR(40) NOT NULL,
    FOREIGN KEY(id_grad) REFERENCES grad(id_grad),
    CONSTRAINT check_naziv_crkve CHECK (naziv LIKE 'Crkva%')
    );
    
CREATE TABLE prijevoz(
	id_prijevoz INTEGER PRIMARY KEY,
    registracija_vozila VARCHAR (15) NOT NULL UNIQUE,
    prijevozno_sredstvo VARCHAR (13) NOT NULL,
    CONSTRAINT check_prijevozno_sredstvo CHECK (prijevozno_sredstvo IN ('mrtvačka kola', 'kombi'))
    );
    
-- u ovoj tablici atribut id_grad označuje grad odakle su pokojnici
CREATE TABLE pokojnik (
	id_pokojnik INTEGER PRIMARY KEY,
    ime VARCHAR(20) NOT NULL,
    prezime VARCHAR(25) NOT NULL, 
    godina_rođenja INTEGER NOT NULL,
    godina_smrti INTEGER NOT NULL,
	id_grad INTEGER NOT NULL,
    id_klijent INTEGER NOT NULL,
    id_crkva INTEGER, 
    id_grobno_mjesto INTEGER NOT NULL,
    id_prijevoz INTEGER NOT NULL,
    FOREIGN KEY (id_grad) REFERENCES grad(id_grad),
    FOREIGN KEY (id_klijent) REFERENCES klijent(id_klijent),
    FOREIGN KEY (id_crkva) REFERENCES crkva(id_crkva),
    FOREIGN KEY (id_grobno_mjesto) REFERENCES grobno_mjesto(id_grobno_mjesto),
    FOREIGN KEY (id_prijevoz) REFERENCES prijevoz(id_prijevoz),
    CONSTRAINT check_god_smrti CHECK (godina_smrti < 2023),
    CONSTRAINT check_godina_rođenja CHECK (CHAR_LENGTH(CAST(godina_rođenja AS CHAR(4))) = 4),
    CONSTRAINT check_godina_smrti CHECK (CHAR_LENGTH(CAST(godina_smrti AS CHAR(4))) = 4)
    );
    
CREATE TABLE lijesovi_i_urne( 
		id_lijes INTEGER PRIMARY KEY,
        id_pokojnik INTEGER NOT NULL UNIQUE, 
        materijal VARCHAR(30) NOT NULL,
        cijena_lijesa NUMERIC(6,2) NOT NULL,
        velicina_lijesa CHAR(3) NOT NULL,
        FOREIGN KEY(id_pokojnik) REFERENCES pokojnik(id_pokojnik) 
       );

CREATE TABLE vrsta_ukopa(
		id_vrsta_ukopa INTEGER PRIMARY KEY,
        vrsta VARCHAR(25) NOT NULL,
        CONSTRAINT check_vrsta CHECK (vrsta IN ('ukop u zemlju', 'kremacija'))
        );

-- napomena: svećenik može raditi u samo jednoj crkvi
CREATE TABLE svecenik(
	id_svecenik INTEGER PRIMARY KEY,
    ime VARCHAR(20) NOT NULL,
    prezime VARCHAR(25) NOT NULL,
    id_crkva INTEGER NOT NULL,
    FOREIGN KEY (id_crkva) REFERENCES crkva(id_crkva)
    );

CREATE TABLE ukop( 
		id_ukop INTEGER PRIMARY KEY,
        id_lijes INTEGER UNIQUE, 
        datum DATE NOT NULL, 
        dan_ukopa VARCHAR(11) NOT NULL,
        cijena_ukopa NUMERIC(7,2) NOT NULL,
        id_vrsta_ukopa INTEGER NOT NULL, 
        id_svecenik INTEGER, 
        FOREIGN KEY (id_lijes) REFERENCES lijesovi_i_urne(id_lijes),
        FOREIGN KEY (id_vrsta_ukopa) REFERENCES vrsta_ukopa(id_vrsta_ukopa),
        FOREIGN KEY (id_svecenik) REFERENCES svecenik(id_svecenik)
        );

CREATE TABLE osmrtnica( 
		id_osmrtnica INTEGER PRIMARY KEY,
        id_ukop INTEGER NOT NULL UNIQUE, 
        broj INTEGER NOT NULL,
        FOREIGN KEY (id_ukop) REFERENCES ukop(id_ukop)
        );
        
CREATE TABLE vrsta_cvjetnog_aranzmana(
		id_vrsta_cvjetnog_aranzmana INTEGER PRIMARY KEY,
        kolicina INTEGER NOT NULL,
        velicina VARCHAR(10) NOT NULL,
        cijena_aranzmana NUMERIC(4,2) NOT NULL
        );
        
CREATE TABLE aranzman_na_ukopu( 
	id_aranzman_na_ukopu INTEGER PRIMARY KEY,
    id_vrsta_cvjetnog_aranzmana INTEGER NOT NULL, 
    id_ukop INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (id_vrsta_cvjetnog_aranzmana) REFERENCES vrsta_cvjetnog_aranzmana(id_vrsta_cvjetnog_aranzmana),
    FOREIGN KEY (id_ukop) REFERENCES ukop(id_ukop) 
    );

CREATE TABLE novine(
	id_novine INTEGER PRIMARY KEY,
    naziv_novina VARCHAR(25) NOT NULL UNIQUE,
    cijena NUMERIC(4,2) NOT NULL
    );
    
CREATE TABLE osmrtnica_u_novinama(
	id_osmrtnica_u_novinama INTEGER PRIMARY KEY,
    id_osmrtnica INTEGER NOT NULL, 
    id_novine INTEGER NOT NULL, 
    FOREIGN KEY (id_osmrtnica) REFERENCES osmrtnica(id_osmrtnica),
    FOREIGN KEY (id_novine) REFERENCES novine(id_novine)
    );
    
CREATE TABLE glazba( 
	id_glazba INTEGER PRIMARY KEY,
    naziv_skladbe VARCHAR(40) NOT NULL,
    instrument VARCHAR(20) NOT NULL
    );
    
CREATE TABLE glazba_na_ukopu(
	id_glazba_na_ukopu INTEGER PRIMARY KEY,
    id_glazba INTEGER NOT NULL,
    id_ukop INTEGER NOT NULL UNIQUE, 
    FOREIGN KEY (id_glazba) REFERENCES glazba(id_glazba),
    FOREIGN KEY (id_ukop) REFERENCES ukop (id_ukop)
    );

CREATE TABLE radnik(  
	id_radnik INTEGER PRIMARY KEY,
    ime VARCHAR(20) NOT NULL,
    prezime VARCHAR(30) NOT NULL,
    radni_staz NUMERIC (3,1) NOT NULL,
    dnevnica NUMERIC (5,2) NOT NULL
    );
    
CREATE TABLE radnik_na_ukopu(
	id_radnik_na_ukopu INTEGER PRIMARY KEY,
    id_ukop INTEGER NOT NULL, 
    id_radnik INTEGER NOT NULL, 
    FOREIGN KEY(id_radnik) REFERENCES radnik (id_radnik),
    FOREIGN KEY(id_ukop) REFERENCES ukop (id_ukop)
    );
    
CREATE TABLE donacije(
	id_donacija INTEGER PRIMARY KEY,
    id_klijent INTEGER NOT NULL, 
    iznos NUMERIC(5,2) NOT NULL,
    opis VARCHAR(15) NOT NULL,
    FOREIGN KEY(id_klijent) REFERENCES klijent(id_klijent)
    );

-- UVRŠTAVANJE PODATAKA U BAZU PODATAKA 

-- NAPOMENA: sva imena i nazivi u bazi podataka su nasumično generirani te svaka sličnost sa stvarnim osobama i mjestima nije bila namjerna, ništa od ovog nije zlonamjerno.
INSERT INTO grad VALUES
(201, 'Pula', 52100),
(202, 'Pazin', 52000),
(203, 'Poreč', 52440),
(204, 'Labin', 52220),
(205, 'Rijeka', 51000),
(206, 'Zagreb', 10000),
(207, 'Gospić', 53000),
(208, 'Opatija', 51410),
(209, 'Osijek', 31000),
(210, 'Zadar', 23000);

INSERT INTO grobno_mjesto VALUES
(301, 201, 'Vanjsko'),
(302, 201, 'Unutarnje'),
(303, 201, 'Grobnica'),
(304, 205, 'Vanjsko'),
(305, 205, 'Unutarnje'),
(306, 205, 'Grobnica'),
(307, 206, 'Vanjsko'),
(308, 206, 'Unutarnje'),
(309, 206, 'Grobnica'),
(310, 209, 'Vanjsko'),
(311, 209, 'Unutarnje'),
(312, 209, 'Grobnica');

INSERT INTO klijent VALUES -- levanant i lepčin su grobnice, pa imaju istog klijenta
(1401, 'Ivan', 'Jezdec', '0992752134'),
(1402, 'Metod', 'Juršević', '0985754371'),
(1403, 'Ivana', 'Gregorić', '095680882'),
(1404, 'Patricia', 'Voščak', '0999784767'),
(1405, 'Erika', 'Dubroja', '098927885'),
(1406, 'Božen', 'Levanant', '0953540239'),
(1407, 'Emilia', 'Lepčin', '0991857143'),
(1408, 'Ramon', 'Hrastić', '0984363445'),
(1409, 'Samuela', 'Klaso', '0958582399'),
(1410, 'Marino', 'Skelić', '0992715019'),
(1411, 'Filipa', 'Klaso', '0995642782'),
(1412, 'Vojmir', 'Kozari', '095756512'),
(1413, 'Janica', 'Klaso', '099584342'),
(1414, 'Johan', 'Dardalić', '0983721622'),
(1415, 'Anuka', 'Klaso', '0952423196'),
(1416, 'Berti', 'Celent', '0993144610'),
(1417, 'Bonita', 'Viher', '0984319926');

INSERT INTO crkva VALUES
(1901, 206, 'Crkva sv. Marko', 'Marulićeva 34'),
(1902, 206, 'Crkva sv. Franjo', 'Frankopanova 15'),
(1903, 205, 'Crkva Gospa Lurdska', 'Nazorova 55'),
(1904, 205, 'Crkva sv. Dominik', 'Gortanova 21'),
(1905, 201, 'Crkva Gospa od mora', 'Jeretova 12'),
(1906, 201, 'Crkva sv. Josip', 'Radićeva 11'),
(1907, 209, 'Crkva sv. Donat', 'Dubrovačka 4');

INSERT INTO prijevoz VALUES
(1301, 'PU-647-UG', 'kombi'),
(1302, 'PU-5384-KI', 'mrtvačka kola'),
(1303, 'RI-777-KT', 'mrtvačka kola'),
(1304, 'RI-376-GH', 'mrtvačka kola'),
(1305, 'ZG-2098-EL', 'kombi'),
(1306, 'ZG-494-SP', 'mrtvačka kola'),
(1307, 'OS-7943-UF', 'mrtvacka kola'),
(1308, 'OS-849-TZ', 'kombi');

INSERT INTO pokojnik VALUES 
(1, 'Dujko', 'Jezdec', 1988, 2012, 203, 1401, 1901, 307, 1305),
(2, 'Aaron', 'Juršević', 1955, 2021, 203, 1402, 1902, 308, 1306),
(3, 'Jagoda', 'Voščak', 1930, 2005, 204, 1404, NULL, 307, 1305),
(4, 'Kuzma', 'Kočijašević', 1970, 1999, 204, 1403, 1903, 304, 1303),
(5, 'Dominik', 'Levanant', 1944, 1977, 202, 1406, 1904, 306, 1304),
(6, 'Edina', 'Borovnjak', 1988, 2022, 205, 1405, 1905, 301, 1302),
(7, 'Vanja', 'Lepčin', 1898, 1965, 201, 1407, 1906, 303, 1301),
(8, 'Ivana', 'Levanat', 1899, 1978, 202, 1406, 1904, 306, 1304),
(9, 'Marija', 'Klaso', 2001, 2017, 205, 1409, NULL, 308, 1305),
(10, 'Nikola', 'Skelić', 1957, 2005, 206, 1410, 1901, 308, 1305),
(11, 'Jagoda', 'Bubič', 1893, 1977, 206, 1408, 1902, 309, 1306),
(12, 'Rozalija', 'Lepčin', 1953, 2021, 201, 1407, 1906, 303, 1301),
(13, 'Nikola', 'Klaso', 1961, 2008, 207, 1411, 1905, 301, 1301),
(14, 'Nikolina', 'Kozari', 1896, 1961, 208, 1412, NULL, 305, 1303),
(15, 'Marko', 'Klaso', 1925, 2005, 209, 1413, 1901, 308, 1306),
(16, 'Cvijetka', 'Dardalić', 1909, 1977, 210, 1414, 1904, 305, 1304),
(17, 'Cvijetka', 'Lepčin', 1920, 1944, 201, 1407,  1906, 303, 1302),
(18, 'Jagoda', 'Klaso', 2005, 2022, 206, 1415, NULL, 310, 1308),
(19, 'Nikola', 'Celent', 1915, 1968, 207, 1416, 1907, 311, 1307),
(20, 'Blaško', 'Trotić', 2002, 2021, 208, 1417, NULL, 302, 1302);

INSERT INTO lijesovi_i_urne VALUES 
(501, 1, 'smreka', 183.99, 'SML'),
(502, 2, 'smreka', 192.49, 'MED'),
(503, 3, 'smreka', 223.49, 'LRG'),
(504, 4, 'bakar', 90.99, 'MED'),
(505, 5, 'hrast', 257.49, 'MED'),
(506, 6, 'hrast', 300.99, 'LRG'),
(507, 7, 'bor', 213.89, 'SML'),
(508, 8, 'hrast', 210.99, 'SML'),
(509, 9, 'mramor', 112.99, 'LRG'),   
(510, 10, 'cedar', 237.99, 'SML'),
(511, 11, 'cedar', 283.59, 'MED'),
(512, 12, 'bor', 312.99, 'LRG'),
(513, 13, 'bakar', 112.59, 'LRG'), 
(514, 14, 'mramor', 95.77, 'MED'),   
(515, 15, 'lim', 199.99, 'SML'),
(516, 16, 'lim', 243.59, 'MED'),
(517, 17, 'bor', 213.89, 'SML'),
(518, 18, 'aluminij', 55.89, 'SML'), 
(519, 19, 'breza', 256.33, 'MED'),
(520, 20, 'aluminij', 89.49, 'LRG'); 

INSERT INTO vrsta_ukopa VALUES
(601, 'ukop u zemlju'),
(602, 'kremacija');

INSERT INTO svecenik VALUES
(2001, 'Zvonko', 'Vuco', 1901),
(2002, 'Marko', 'Kavić', 1902),
(2003, 'Dario', 'Aganović', 1903),
(2004, 'Filko', 'Dableić', 1904),
(2005, 'Mergim', 'Moritz', 1905),
(2006, 'Simon', 'Forkapa', 1906),
(2007, 'Miroljub', 'Krile', 1907),
(2008, 'Rafo', 'Mrljak', 1901),
(2009, 'Jadran', 'Krizmanić', 1905),
(2010, 'Pjeter', 'Štumfol', 1907),
(2011, 'Miran', 'Stivanović', 1902),
(2012, 'Karlo', 'Tilon', 1906),
(2013, 'Emilian', 'Hvarović', 1901);

INSERT INTO ukop VALUES 
(401, 501, STR_TO_DATE('10.01.2012.', '%d.%m.%Y.'), 'Utorak', 2789.99, 601, 2001), 
(402, 502, STR_TO_DATE('16.05.2021.', '%d.%m.%Y.'), 'Nedjelja', 1805.59, 601,  2002),
(403, 503, STR_TO_DATE('21.11.2005.', '%d.%m.%Y.'), 'Ponedjeljak', 2200.00, 601, NULL),
(404, 504, STR_TO_DATE('01.12.1999.', '%d.%m.%Y.'), 'Srijeda', 200.00, 602, 2003),
(405, 505, STR_TO_DATE('05.12.1977.', '%d.%m.%Y.'), 'Ponedjeljak', 2809.49, 601, 2004),
(406, 506, STR_TO_DATE('18.02.2022.', '%d.%m.%Y.'), 'Petak', 1999.49, 601, 2009),
(407, 507, STR_TO_DATE('11.04.1965.', '%d.%m.%Y.'), 'Nedjelja', 2739.89, 601, 2006),
(408, 508, STR_TO_DATE('28.08.1978.', '%d.%m.%Y.'), 'Ponedjeljak',1650.50, 601, 2004),
(409, 509, STR_TO_DATE('25.11.2017.', '%d.%m.%Y.'), 'Subota', 185.95, 602, NULL),
(410, 510, STR_TO_DATE('14.02.2005.', '%d.%m.%Y.'), 'Ponedjeljak', 2050.39, 601, 2008),
(411, 511, STR_TO_DATE('16.06.1977.', '%d.%m.%Y.'), 'Četvrtak', 2105.39, 601, 2011),
(412, 512, STR_TO_DATE('07.07.2021.', '%d.%m.%Y.'), 'Srijeda', 2587.28, 601, 2012),
(413, 513, STR_TO_DATE('18.05.2008.', '%d.%m.%Y.'), 'Nedjelja', 249.59, 602, 2005),
(414, 514, STR_TO_DATE('23.03.1961.', '%d.%m.%Y.'), 'Četvrtak', 195.45, 602, NULL),
(415, 515, STR_TO_DATE('13.09.1968.', '%d.%m.%Y.'), 'Petak', 2939.51, 601, 2013),
(416, 516, STR_TO_DATE('19.04.1977.', '%d.%m.%Y.'), 'Utorak', 2300.79, 601, 2004),
(417, 517, STR_TO_DATE('22.10.1944.', '%d.%m.%Y.'), 'Nedjelja', 1900.49, 601, 2006),
(418, 518, STR_TO_DATE('11.07.2022.', '%d.%m.%Y.'), 'Ponedjeljak', 212.79, 602, NULL),
(419, 519, STR_TO_DATE('12.08.1968.', '%d.%m.%Y.'), 'Ponedjeljak', 2901.21, 601, 2010),
(420, 520, STR_TO_DATE('28.09.2021.', '%d.%m.%Y.'), 'Utorak', 245.74, 602, NULL);

INSERT INTO osmrtnica VALUES
(701, 401, 3),
(702, 402, 12),
(703, 403, 4),
(704, 404, 5),
(705, 405, 7),
(706, 406, 4),
(707, 407, 5),
(708, 408, 6),
(709, 409, 15),
(710, 410, 12),
(711, 411, 3),
(712, 412, 9),
(713, 413, 13),
(714, 414, 14),
(715, 415, 3),
(716, 416, 4),
(717, 417, 8),
(718, 418, 11),
(719, 419, 7),
(720, 420, 4);

INSERT INTO vrsta_cvjetnog_aranzmana VALUES -- small=8.12, medium=11.53, large=15,21
(801, 3, 'small', 24.36),
(802, 1, 'large', 15.21),
(803, 2, 'medium', 23.06),
(804, 5, 'small', 40.60),
(805, 1, 'medium', 11.53), 
(806, 3, 'medium', 34.59),
(807, 4, 'small', 32.48),
(808, 2, 'large', 30.42),
(809, 4, 'medium', 46.12),
(810, 1, 'small', 8.12);

INSERT INTO aranzman_na_ukopu VALUES
(901, 801, 401),
(902, 802, 402),
(903, 803, 403),
(904, 804, 404),
(905, 805, 405),
(906, 806, 406),
(907, 807, 407),
(908, 808, 408),
(909, 809, 409),
(910, 810, 410),
(911, 805, 411),
(912, 808, 412),
(913, 803, 413),
(914, 807, 414),
(915, 809, 415),
(916, 808, 416),
(917, 802, 417),
(918, 808, 418),
(919, 804, 419),
(920, 806, 420);

INSERT INTO novine VALUES 
(1801, 'Jutarnj list', 13.37),
(1802, 'Večernji list', 21.11),
(1803, 'Narodne novine', 15.89),
(1804, 'Glas Koncila', 33.08),
(1805, '24Sata', 28.22),
(1806, 'Novi list', 30.99),
(1807, 'Glas Naroda', 16.89),
(1808, 'Vjesnik', 15.55), 
(1809, 'Hrvatski tjednik', 37.00), 
(1810, 'Nacional', 24.49);

INSERT INTO osmrtnica_u_novinama VALUES
(1001, 701, 1801),
(1002, 702, 1802),
(1003, 703, 1803),
(1004, 704, 1804),
(1005, 705, 1805),
(1006, 706, 1806),
(1007, 707, 1807),
(1008, 708, 1808),
(1009, 709, 1809),
(1010, 710, 1809),
(1011, 711, 1801),
(1012, 712, 1802),
(1013, 713, 1803),
(1014, 714, 1804),
(1015, 715, 1805),
(1016, 716, 1806),
(1017, 717, 1807),
(1018, 718, 1808),
(1019, 719, 1809),
(1020, 720, 1809),
(1021, 709, 1801),
(1022, 709, 1805),
(1023, 712, 1807),
(1024, 717, 1806),
(1025, 701, 1804);

INSERT INTO glazba VALUES
(1101, 'Anđele moj', 'gitara'),
(1102, 'Anđele moj', 'klavir'),
(1103, 'Anđele moj', 'violina'),
(1104, 'Nadgrobnica', 'gitara'),
(1105, 'Nadgrobnica', 'klavir'),
(1106, 'Nadgrobnica', 'violina'),
(1107, 'Duga cesta', 'gitara'),
(1108, 'Duga cesta', 'klavir'),
(1109, 'Duga cesta', 'violina'),
(1110, 'Anđele moj', 'solo truba'),
(1111, 'Nadgrobnica', 'solo truba'),
(1112, 'Duga cesta', 'solo truba'),
(1113, 'Oči u oči', 'solo truba');

INSERT INTO glazba_na_ukopu VALUES
(1201, 1101, 401), 
(1202, 1102, 402),
(1203, 1103, 403),
(1204, 1104, 404),
(1205, 1105, 405),
(1206, 1106, 406),
(1207, 1108, 407),
(1208, 1109, 408),
(1209, 1110, 409),
(1210, 1105, 410),
(1211, 1107, 411),
(1212, 1113, 412),
(1213, 1106, 413),
(1214, 1108, 414),
(1215, 1103, 415),
(1216, 1110, 416),
(1217, 1111, 417),
(1218, 1110, 418),
(1219, 1107, 419),
(1220, 1107, 420);

INSERT INTO radnik VALUES
(1501, 'Ferdi', 'Hvastek', 20.5, 32.80),
(1502, 'Marketa', 'Paštrović', 2.7, 28.00),
(1503, 'Melanija', 'Brdarević', 4.4, 28.00),
(1504, 'Milenko', 'Gojanović', 5.5, 28.00),
(1505, 'Domenico', 'Pohiba', 16.0, 30.49),
(1506, 'Arnes', 'Lalović', 1.5, 26.12),
(1507, 'Giuliana', 'Kosihajda', 19.5, 32.80),
(1508, 'Stephanie', 'Fernežir', 2.2, 28.00),
(1509, 'Ragib', 'Pomykalo', 5.0, 26.39), 
(1510, 'Kazimira', 'Gotvald', 2.2, 28.00),
(1511, 'Smail', 'Fitz', 15.0, 30.49),
(1512, 'Vedrana', 'Bassanese', 3.3, 29.49);

INSERT INTO radnik_na_ukopu VALUES
(1601, 401, 1501),
(1602, 401, 1502),
(1603, 401, 1503),
(1604, 402, 1504),
(1605, 402, 1506),
(1606, 402, 1505),
(1607, 403, 1505),
(1608, 403, 1507),
(1609, 403, 1508),
(1610, 404, 1509),
(1611, 404, 1510),
(1612, 404, 1511),
(1613, 405, 1512),
(1614, 405, 1501),
(1615, 405, 1502),
(1616, 406, 1503),
(1617, 406, 1504),
(1618, 406, 1505),
(1619, 407, 1506),
(1620, 407, 1507),
(1621, 407, 1508),
(1622, 408, 1509),
(1623, 408, 1510),
(1624, 409, 1511),
(1625, 409, 1512),
(1626, 409, 1501),
(1627, 410, 1502),
(1628, 410, 1503),
(1629, 410, 1504),
(1630, 411, 1505),
(1631, 411, 1506),
(1632, 411, 1507),
(1633, 412, 1508),
(1634, 412, 1509),
(1635, 412, 1510),
(1636, 413, 1511),
(1637, 413, 1512),
(1638, 413, 1501),
(1639, 414, 1502),
(1640, 414, 1503),
(1641, 414, 1504),
(1642, 415, 1505),
(1643, 415, 1506),
(1644, 415, 1507),
(1645, 416, 1508),
(1646, 416, 1509),
(1647, 416, 1510),
(1648, 417, 1511),
(1649, 417, 1512),
(1650, 417, 1501),
(1651, 417, 1502),
(1652, 418, 1503),
(1653, 418, 1504),
(1654, 418, 1505),
(1655, 419, 1506), 
(1656, 419, 1507),
(1657, 419, 1502),
(1658, 420, 1508),
(1659, 420, 1509),
(1660, 420, 1511);

INSERT INTO donacije VALUES
(1701, 1401, 50.00, 'za Crkvu'), 
(1702, 1402, 100.00, 'za glazbu'),
(1703, 1402, 50.00, 'za Crkvu'),
(1704, 1403, 25.00, 'za glazbu'),
(1705, 1404, 75.00, 'za glazbu'),
(1706, 1405, 150.00, 'za glazbu'),
(1707, 1407, 175.00, 'za Crkvu'),
(1708, 1408, 35.00, 'za glazbu'),
(1709, 1409, 25.00, 'za radnike'),
(1710, 1409, 55.00, 'za glazbu'),
(1711, 1409, 100.00, 'za cvijeće'),
(1712, 1410, 250.00, 'za Crkvu'),
(1713, 1413, 135.00, 'za radnike'),
(1714, 1413, 150.00, 'za poduzeće'),
(1715, 1415, 45.00, 'za glazbu'),
(1716, 1416, 65.00, 'za crkvu'),
(1717, 1417, 80.00, 'za glazbu');

-- UPITI --

-- 1. Prikaz gradova s dodatnim stupcem koji prikazuje koliko ljudi je pokopano tamo --

 SELECT grad.*, COUNT(id_pokojnik) AS broj_pokojnika 
 FROM grad LEFT OUTER JOIN pokojnik ON grad.id_grad=pokojnik.id_grad
 GROUP BY id_grad;
 
-- 2. Prikaz klijenta koji je donirao najveću svotu novca -- 
SELECT *
FROM klijent
WHERE id_klijent IN (SELECT id_klijent FROM donacije WHERE iznos IN (SELECT MAX(iznos) FROM donacije));


-- 3. Prikaz prosječne cijene ukopa --

SELECT AVG(cijena_ukopa) AS prosjecna_cijena_ukopa
FROM ukop;
-- 4. Prikaz umrlih koji su pokopani u Puli u ovom stoljeću

SELECT pokojnik.ime, pokojnik.prezime, pokojnik.godina_smrti, grad.grad
FROM pokojnik, grad
WHERE grad.id_grad=pokojnik.id_grad AND grad.grad='Pula' AND pokojnik.godina_smrti>=2000;

-- ILI

SELECT pokojnik.ime, pokojnik.prezime, pokojnik.godina_smrti, grad.grad
FROM pokojnik INNER JOIN grad ON grad.id_grad=pokojnik.id_grad 
WHERE grad.grad='Pula' AND pokojnik.godina_smrti>=2000;

-- 5.Prikaz imena i prezimena svećenika te naziva crkvi u kojima su održali pogrebne mise poredanih prema nazivu crkve uzlazno.

SELECT svecenik.ime, svecenik.prezime, crkva.naziv
FROM svecenik INNER JOIN crkva ON svecenik.id_crkva=crkva.id_crkva
ORDER BY crkva.naziv ASC;

-- 6.Prikaz radnika i broja ukopa na kojima su radili.

SELECT radnik.*, COUNT(radnik.id_radnik) AS broj_ukopa
FROM radnik LEFT OUTER JOIN radnik_na_ukopu ON radnik.id_radnik=radnik_na_ukopu.id_radnik
GROUP BY radnik.id_radnik;

-- 7.Prikaz svih ukopa koji su se održali u svibnju s njihovom cijenom, imenom i prezimenom pokojnika te imenom i prezimenom klijenta.

SELECT datum, cijena_ukopa, pokojnik.ime, pokojnik.prezime, klijent.ime, klijent.prezime FROM ukop
INNER JOIN izrada_lijesa_i_urni ON ukop.id_lijes = izrada_lijesa_i_urni.id_lijes
INNER JOIN pokojnik ON izrada_lijesa_i_urni.id_pokojnik = pokojnik.id_pokojnik
INNER JOIN klijent ON pokojnik.id_klijent = klijent.id_klijent
WHERE MONTH(datum) = 5;

-- 8. Prikaz svih pokojnika s njihovim pripadnim grobnim mjestima i vrstama grobnog mjesta.

SELECT pokojnik.ime, pokojnik.prezime, grad.grad, grobno_mjesto.id_grobno_mjesto,grobno_mjesto.vrsta FROM pokojnik
INNER JOIN grobno_mjesto ON pokojnik.id_grobno_mjesto = grobno_mjesto.id_grobno_mjesto
INNER JOIN grad ON grobno_mjesto.id_grad = grad.id_grad
INNER JOIN izrada_lijesa_i_urni ON pokojnik.id_pokojnik = izrada_lijesa_i_urni.id_pokojnik
INNER JOIN ukop ON izrada_lijesa_i_urni.id_lijes = ukop.id_lijes;

-- 9. Prikaz svih pokojnika čija se pogrebna misa održala u crkvi svetog Dominika.

SELECT pokojnik.ime, pokojnik.prezime FROM ukop
INNER JOIN izrada_lijesa_i_urni ON ukop.id_lijes = izrada_lijesa_i_urni.id_lijes
INNER JOIN pokojnik ON izrada_lijesa_i_urni.id_pokojnik = pokojnik.id_pokojnik
INNER JOIN crkva ON pokojnik.id_crkva = crkva.id_crkva
WHERE crkva.naziv = 'Crkva sv. Dominik';

-- 10. Prikaz količine lijesova na svakom pojedinom grobnom mjestu, grupiranih po materijalu.

SELECT izrada_lijesa_i_urni.materijal, COUNT(*) AS broj_lijesova, grobno_mjesto.id_grobno_mjesto
FROM izrada_lijesa_i_urni
JOIN pokojnik ON pokojnik.id_pokojnik = izrada_lijesa_i_urni.id_pokojnik
JOIN grobno_mjesto ON grobno_mjesto.id_grobno_mjesto = pokojnik.id_grobno_mjesto
GROUP BY izrada_lijesa_i_urni.materijal, grobno_mjesto.id_grobno_mjesto;

-- 11. Prikaz starosti najstarijeg i najmlađeg pokojnika te razlike u godinama.

SELECT MAX(godina_smrti - godina_rođenja) AS najstariji,
       MIN(godina_smrti - godina_rođenja) AS najmlađi,
	   MAX(godina_smrti - godina_rođenja) - MIN(godina_smrti - godina_rođenja) AS razlika_u_godinama
FROM pokojnik;


-- 12. Prikaz svih gradova za koje postoji zapisana crkva te broj i prosjek starosti pokojnika čije su se pogrebne mise održale u pojedinoj crkvi. 
-- Ako neki pokojnik nije imao sprovod u crkvi, svejedno ga prikaži.

SELECT
    grad.grad AS grad,
    COUNT(pokojnik.id_pokojnik) AS broj_pokojnika,
    AVG(pokojnik.godina_smrti - pokojnik.godina_rođenja) AS prosjek_starosti,
    crkva.naziv AS crkva
FROM
    grad
    LEFT JOIN grobno_mjesto ON grad.id_grad = grobno_mjesto.id_grad
    LEFT JOIN pokojnik ON grobno_mjesto.id_grobno_mjesto = pokojnik.id_grobno_mjesto
LEFT JOIN crkva ON pokojnik.id_crkva = crkva.id_crkva
WHERE
    pokojnik.godina_smrti IS NOT NULL
GROUP BY
    grad.grad, crkva.naziv;

-- 13. Prikaz pokojnika koji nisu imali sprovod u crkvi, a za gradove iz kojih potječu ne postoji zapisana crkva.
SELECT *
FROM pokojnik
LEFT OUTER JOIN grad ON pokojnik.id_grad = grad.id_grad
LEFT OUTER JOIN crkva ON pokojnik.id_crkva = crkva.id_crkva
WHERE pokojnik.id_crkva IS NULL AND grad.id_grad IN (
  SELECT id_grad FROM crkva
);

-- 14. Prikaz svih skladbi s dodatnim stupcem koji prikazuje broj sprovoda na kojima su one svirane, sortirane silazno i grupirane prema instrumentu.

SELECT glazba.instrument, glazba.naziv_skladbe, COUNT(glazba_na_ukopu.id_ukop) AS broj_sprovoda
FROM glazba
LEFT OUTER JOIN glazba_na_ukopu ON glazba.id_glazba = glazba_na_ukopu.id_glazba
GROUP BY glazba.instrument, glazba.id_glazba
ORDER BY broj_sprovoda DESC;

-- 15. Prikaz prijevoza s dodatnim stupcem koji prikazuje broj ukopa na kojima se pojedino vozilo koristilo, sortiranih silazno.

SELECT prijevoz.*,
    (SELECT COUNT(*) FROM pokojnik WHERE pokojnik.id_prijevoz = prijevoz.id_prijevoz) AS broj_ukopa
FROM prijevoz
ORDER BY broj_ukopa DESC;

-- NADOGRADNJA: prikaz vozila koje se najviše koristilo
SELECT prijevoz.*,
    (SELECT COUNT(*) FROM pokojnik WHERE pokojnik.id_prijevoz = prijevoz.id_prijevoz) AS broj_ukopa
FROM prijevoz
WHERE (SELECT COUNT(*) FROM pokojnik WHERE pokojnik.id_prijevoz = prijevoz.id_prijevoz) =
      (SELECT MAX(broj_ukopa) FROM (SELECT COUNT(*) AS broj_ukopa FROM pokojnik GROUP BY id_prijevoz) AS ukopi);

-- 16. Prikaz svuh grobnih mjesta na kojima je pokopano više od jednog pokojnika, sortiranih od onog s najviše pokojnika do onog s najmanje.

SELECT grobno_mjesto.*, COUNT(pokojnik.id_grobno_mjesto) AS broj_pokojnika
FROM pokojnik
JOIN grobno_mjesto ON grobno_mjesto.id_grobno_mjesto = pokojnik.id_grobno_mjesto
GROUP BY grobno_mjesto.id_grobno_mjesto
HAVING broj_pokojnika>1
ORDER BY broj_pokojnika DESC;

-- 17. Prikaz instrumenta koji je najviše puta bio prisutan na ukopu.

CREATE VIEW instrumenti AS
SELECT id_glazba, instrument, COUNT(instrument) AS kol_instrument
FROM glazba
GROUP BY instrument;

SELECT instrument 
FROM instrumenti
WHERE kol_instrument IN (SELECT MAX(kol_instrument) FROM instrumenti);

-- 18. Prikaz vrste ukopa koja se više puta izvela i koliko puta se izvela.

CREATE VIEW ukopi AS
SELECT *, COUNT(id_vrsta_ukopa) AS kol_ukopa
FROM ukop
GROUP BY id_vrsta_ukopa;

SELECT vrsta_ukopa.vrsta, ukopi.kol_ukopa
FROM ukopi INNER JOIN vrsta_ukopa ON ukopi.id_vrsta_ukopa=vrsta_ukopa.id_vrsta_ukopa
WHERE kol_ukopa IN (SELECT MAX(kol_ukopa) FROM ukopi);

-- 19. Prikaz top 3 najvećih donacija.
 
SELECT *
FROM donacije
ORDER BY iznos DESC
LIMIT 3;
 
 -- 20. Prikaz ukopa koji su se održali u posljednjih 5 godina.
 
SELECT *
FROM ukop
WHERE datum > NOW() - INTERVAL 5 YEAR;
 