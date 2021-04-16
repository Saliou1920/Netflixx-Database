-- Creation de la table NETFLIX_ACTEURS qui enregistre le nom des acteurs.

CREATE TABLE NETFLIX_ACTEURS
( 
    ACTEUR_ID NUMBER(4) NOT NULL CONSTRAINT NETFLIX_ACTEURS_PK PRIMARY KEY ,
    SURNOM_ACTEUR VARCHAR2(50) NOT NULL,
    PRENOM_ACTEUR VARCHAR2(50) NOT NULL,
    
    CONSTRAINT NETFLIX_ACTEURS_UK1 UNIQUE (SURNOM_ACTEUR)
);

-- Sequence identification des lignes inseres dans la table NETFLIX_ACTEURS

CREATE SEQUENCE NETFLIX_ACTEURS_SEQ
    MINVALUE 1
    NOMAXVALUE
    START WITH 1
    INCREMENT BY 1
    NOCYCLE
    ORDER;
    
-- Table directeur film

CREATE TABLE NETFLIX_DIRECTEURS
( 
    DIRECTEUR_ID NUMBER(4) NOT NULL CONSTRAINT NETFLIX_DIRECTEURS_PK PRIMARY KEY ,
    SURNOM_DIRECTEUR VARCHAR2(50) NOT NULL,
    PRENOM_DIRECTEUR VARCHAR2(50) NOT NULL,
    
    CONSTRAINT NETFLIX_DIRECTEURS_UK1 UNIQUE (SURNOM_DIRECTEUR)
);

-- Sequence identification des lignes inseres dans la table NETFLIX_DIRECTEURS
CREATE SEQUENCE NETFLIX_DIRECTEURS_SEQ
    MINVALUE 1
    NOMAXVALUE
    START WITH 1
    INCREMENT BY 1
    NOCYCLE
    ORDER;

-- une table qui servira à enregistrer les films Netflix

CREATE TABLE NETFLIX_FILMS
( 
    FILM_ID NUMBER(4) NOT NULL CONSTRAINT NETFLIX_FILM_PK PRIMARY KEY ,
    TITRE VARCHAR2(100) NOT NULL,
    ANNEE_SORTIE NUMBER(4) NOT NULL,
    DURATION NUMBER(4) NOT NULL,
    DESCRIPTION VARCHAR2(4000) NOT NULL,
    
    CONSTRAINT NETFLIX_FILMS_UK1 UNIQUE (TITRE)
);

-- Sequence identification des lignes inseres dans la table NETFLIX_FILMS
CREATE SEQUENCE NETFLIX_FILMS_SEQ
    MINVALUE 1
    NOMAXVALUE
    START WITH 1
    INCREMENT BY 1
    NOCYCLE
    ORDER;

-- La table journaliere

CREATE TABLE NETFLIX_FILMS_JN
( 
    JN_OPERATION VARCHAR2(1) NOT NULL,
    JN_ORACLE_USER VARCHAR2(30) NOT NULL,
    JN_DATETIME DATE DEFAULT SYSTIMESTAMP NOT NULL,
    FILM_ID NUMBER(4) NOT NULL,
    OLD_TITRE VARCHAR2(100),
    NEW_TITRE VARCHAR2(100),
    OLD_ANNEE_SORTIE NUMBER(4),
    NEW_ANNEE_SORTIE NUMBER(4),
    OLD_DURAION NUMBER(4),
    NEW_DURAION NUMBER(4),
    OLD_DESCRIPTION VARCHAR2(4000),
    NEW_DESCRIPTION VARCHAR2(4000)
);

-- QUESTION

-- OUI on doit mettre une cle primaire sur la table journaliere
-- Parce que cela peut aider lors de la restauration des donnes

-- Table reference qui servira a enregistrer le directeur de chaque film
CREATE TABLE NETFLIX_DIRECTEURS_REF 
(
    DIRECTEUR_ID NUMBER(4) NOT NULL,
    FILM_ID NUMBER(4) NOT NULL,
    
    CONSTRAINT NETFLIX_DIRECTEURS_REF_PK PRIMARY KEY (DIRECTEUR_ID, FILM_ID),
    FOREIGN KEY (DIRECTEUR_ID) REFERENCES NETFLIX_DIRECTEURS(DIRECTEUR_ID),
    FOREIGN KEY (FILM_ID) REFERENCES NETFLIX_FILMS(FILM_ID)
     -- Si une ligne est supprime dans le taleau parent, elle sera supprimee automatiquement dans
    -- le tabeau NETFLIX_DIRECTEURS_REF
    ON DELETE CASCADE
);

-- table de référence qui servira à enregistrer les acteurs de chaque film.

CREATE TABLE NETFLIX_ACTEURS_REF 
(
    ACTEUR_ID NUMBER(4) NOT NULL,
    FILM_ID NUMBER(4) NOT NULL,
    
    CONSTRAINT NETFLIX_ACTEURS_REF_PK PRIMARY KEY (ACTEUR_ID, FILM_ID),
    FOREIGN KEY (ACTEUR_ID) REFERENCES NETFLIX_ACTEURS(ACTEUR_ID),
    FOREIGN KEY (FILM_ID) REFERENCES NETFLIX_FILMS(FILM_ID)
    -- Si une ligne est supprime dans le taleau parent, elle sera supprimee automatiquement dans
    -- le tabeau NETFLIX_ACTEURS_REF
    ON DELETE CASCADE
);

-- Vue

CREATE VIEW NETFLIX_DETAILS_V1 AS
SELECT TITRE, ANNEE_SORTIE,DURATION,DESCRIPTION, SURNOM_DIRECTEUR, PRENOM_DIRECTEUR,
        SURNOM_ACTEUR, PRENOM_ACTEUR
FROM NETFLIX_FILMS a, NETFLIX_DIRECTEURS b, NETFLIX_ACTEURS c, NETFLIX_ACTEURS_REF d, NETFLIX_DIRECTEURS_REF e 
WHERE c.ACTEUR_ID = d.ACTEUR_ID AND d.FILM_ID = a.FILM_ID AND a.FILM_ID = e.FILM_ID AND 
      e.DIRECTEUR_ID = b.DIRECTEUR_ID;



select * from netflix_films_jn;

-- Declencheurs

CREATE OR REPLACE TRIGGER NETFLIX_FILMS_TR1
   AFTER INSERT OR UPDATE OR DELETE ON NETFLIX_FILMS
   FOR EACH ROW
   DECLARE
      JN_ORACLE_USER VARCHAR2(30) ;
      --JN_OPERATION NETFLIX_FILMS_JN.JN_OPERATION%TYPE;
   BEGIN
    SELECT USER INTO JN_ORACLE_USER FROM dual;
      --Insert
      IF INSERTING THEN
         INSERT INTO NETFLIX_FILMS_JN (
                JN_OPERATION,
                JN_ORACLE_USER,
                JN_DATETIME,
                FILM_ID,
                NEW_TITRE,
                NEW_ANNEE_SORTIE,
                NEW_DURAION,
                NEW_DESCRIPTION
            )
            VALUES (
                'I',
                JN_ORACLE_USER,
                TO_CHAR(SYSDATE, 'DD-MM-YYYY'),
                :NEW.FILM_ID,
                :NEW.TITRE,
                :NEW.ANNEE_SORTIE, 
                :NEW.DURATION,
                :NEW.DESCRIPTION
            );
   -- Delete
      ELSIF DELETING THEN
         INSERT INTO NETFLIX_FILMS_JN (
                JN_OPERATION,
                JN_ORACLE_USER,
                JN_DATETIME,
                FILM_ID,
                OLD_TITRE,
                OLD_ANNEE_SORTIE,
                OLD_DURAION,
                OLD_DESCRIPTION
        )
        VALUES (
                'D',
                JN_ORACLE_USER,
                TO_CHAR(SYSDATE, 'DD-MM-YYYY'),
                :OLD.FILM_ID,
                :OLD.TITRE,
                :OLD.ANNEE_SORTIE,
                :OLD.DURATION,
                :OLD.DESCRIPTION
            );
   -- Update
      ELSE
         INSERT INTO NETFLIX_FILMS_JN
            VALUES (
                'U', 
                JN_ORACLE_USER, 
                TO_CHAR(SYSDATE, 'DD-MM-YYYY'),
                :NEW.FILM_ID,
                :OLD.TITRE, 
                :NEW.TITRE, 
                :OLD.ANNEE_SORTIE, 
                :NEW.ANNEE_SORTIE, 
                :OLD.DURATION,
                :NEW.DURATION, 
                :OLD.DESCRIPTION, 
                :NEW.DESCRIPTION
            );

      END IF;

END;

-- Insertion des donnees dans les tableaux NETFLIX_FILMS, NETFLIX_ACTEURS, NETFLIX_DIRECTEURS

-- FILM #1
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'Philadelphia', 1993, 126,'Philadelphia attorney Andrew Beckett launches a wrongful termination suit against his law firm when they fire him because he''s gay and HIV-positive.');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Hanks', 'Tom');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Washington', 'Denzel');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Robards', 'Jason');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Demme','Jonathan');

-- FILM #2
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'The Book of Eli', 2010, 118,'Determined to protect a sacred text that promises to save humanity, Eli goes on a quest westward across the barren, postapocalyptic country.');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Washington', 'Denzel');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Oldman', 'Gary');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Kunis', 'Mila');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Demme','Jonathan');

-- FILM 3
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'The Taking of Pelham 123', 2009, 106,'When a group of hijackers takes passengers aboard a subway train hostage and
demand a ransom, it''s up to dispatcher Walter Garber to bring them down.');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Washington', 'Denzel');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Travolta', 'John');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Guzmain', 'Luis');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Scott','Tony');

-- FILM 4
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'Fallen', 1998, 124,'A tough homicide cop faces his most dangerous assignment when he must stop a murderous evil spirit who can move from one host to the next');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Washington', 'Denzel');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Goodman', 'John');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Sutherland', 'Donald');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Hoblit','Gregory');

-- FILM 5
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'Runaway Bride', 1999, 116,'Sparks fly when a newspaper columnist writes a one-sided, sexist story about a commitment-phobic bride who abandoned three men at the altar.');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Roberts', 'Julia');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Gere', 'Richard');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Cusack', 'Joan');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Marshall','Garry');

-- FILM 6
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'Hook', 1991, 142,'Peter Pan, now grown up and a workaholic, must return to Neverland to save his kids from the clutches of vengeful pirate Captain Hook.');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Hoffman', 'Dustin');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Williams', 'Robin');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Roberts', 'Julia');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Spielberg','Steven');

-- FILM 7
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'Kate &'||' Leopold', 2001, 118,'A present-day woman takes responsibility for guiding a charming time-traveling 19th-century nobleman through the 21st century.');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Ryan', 'Meg');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Jackman', 'Hugh');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Schreiber', 'Liev');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Mangold','James');

-- FILM 8
INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) VALUES (NETFLIX_FILMS_SEQ.nextval,
    'The Ugly Truth', 2019, 96,'A chauvinistic morning-show commentator tries to prove the relationship theories he espouses on a segment called ''The Ugly Truth''.');

INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Heigl', 'Katherine');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Butler', 'Gerard');
INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) VALUES (NETFLIX_ACTEURS_SEQ.nextval,'Winter', 'Eric');

INSERT INTO NETFLIX_DIRECTEURS (DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) VALUES (NETFLIX_DIRECTEURS_SEQ.nextval,'Luketic','Robert');

-- Section D - Paquetage

CREATE OR REPLACE PACKAGE NETFLIX_PKG AS 
   -- Inserer un nouveau film  
   PROCEDURE InsertFilm(
    film NETFLIX_FILMS.TITRE%type, 
    sortie  NETFLIX_FILMS.ANNEE_SORTIE%type, 
    duration  NETFLIX_FILMS.DURATION%type, 
    description NETFLIX_FILMS.DESCRIPTION%type
    ); 
   
   -- Inserer une nouvelle actrice ou acteur 
   PROCEDURE InsertActeur(
    --acteur_id  NETFLIX_ACTEURS.ACTEUR_ID%type,
    surnom NETFLIX_ACTEURS.SURNOM_ACTEUR%type, 
    prenom  NETFLIX_ACTEURS.PRENOM_ACTEUR%type
    ); 

    -- Inserer une nouvelle directrice ou actrice 
   PROCEDURE InsertDirecteur(
    --directeur_id  NETFLIX_DIRECTEURS.DIRECTEUR_ID%type,
    surnom NETFLIX_DIRECTEURS.SURNOM_DIRECTEUR%type, 
    prenom  NETFLIX_DIRECTEURS.PRENOM_DIRECTEUR%type
    );

    -- Inserer une nouvelle actrice ou acteur 
   PROCEDURE ActeurFilm(
    surnom NETFLIX_ACTEURS.SURNOM_ACTEUR%type, 
    prenom  NETFLIX_ACTEURS.PRENOM_ACTEUR%type,
    film NETFLIX_FILMS.TITRE%type
    ); 

     -- Inserer une nouvelle directrice ou directeur 
   PROCEDURE DirecteurFilm(
    surnom NETFLIX_ACTEURS.SURNOM_ACTEUR%type, 
    prenom  NETFLIX_ACTEURS.PRENOM_ACTEUR%type,
    film NETFLIX_FILMS.TITRE%type
    );

     -- Inserer une nouvelle actrice ou acteur 
   PROCEDURE DetailsFilm(
    film NETFLIX_FILMS.TITRE%type
    );
    -- Supprimer un film
    PROCEDURE DeleteFilm(
    film NETFLIX_FILMS.TITRE%type
    );
   
  
END NETFLIX_PKG; 

-- Creer le package body

CREATE OR REPLACE PACKAGE BODY NETFLIX_PKG AS
    data_found EXCEPTION;
    PROCEDURE InsertFilm(
        film NETFLIX_FILMS.TITRE%type, 
        sortie  NETFLIX_FILMS.ANNEE_SORTIE%type, 
        duration  NETFLIX_FILMS.DURATION%type, 
        description NETFLIX_FILMS.DESCRIPTION%type)
    IS
        titre NETFLIX_FILMS.TITRE%type; 
    BEGIN
        SELECT TITRE INTO titre FROM NETFLIX_FILMS
        WHERE titre = film;

        IF SQL%NOTFOUND THEN
            INSERT INTO NETFLIX_FILMS (FILM_ID,TITRE,ANNEE_SORTIE, DURATION, DESCRIPTION) 
                VALUES (NETFLIX_FILMS_SEQ.nextval, film, sortie, duration, description);
            DBMS_OUTPUT.PUT_LINE ('Film : ' || film || ' ajoute!');
        ELSE
            RAISE data_found;
        END IF;
    EXCEPTION
        WHEN data_found THEN
            DBMS_OUTPUT.PUT_LINE ('Ce film existe deja dans le tableau!');
        WHEN OTHERS THEN
            raise_application_error(-20001,'ERREUR TROUVE - '||SQLCODE||' -ERREUR- '||SQLERRM);
    END InsertFilm;


    -- Inserer une nouvelle actrice ou acteur 
   PROCEDURE InsertActeur(
    surnom NETFLIX_ACTEURS.SURNOM_ACTEUR%type, 
    prenom  NETFLIX_ACTEURS.PRENOM_ACTEUR%type)
    IS
        surnom_acteur NETFLIX_ACTEURS.SURNOM_ACTEUR%type;
        prenom_acteur NETFLIX_ACTEURS.SURNOM_ACTEUR%type; 
    BEGIN
        SELECT SURNOM_ACTEUR, PRENOM_ACTEUR  INTO surnom_acteur, prenom_acteur 
        FROM NETFLIX_ACTEURS
        WHERE surnom_acteur = surnom AND prenom_acteur  = prenom;

        IF SQL%NOTFOUND THEN
            INSERT INTO NETFLIX_ACTEURS (ACTEUR_ID,SURNOM_ACTEUR,PRENOM_ACTEUR) 
                VALUES (NETFLIX_ACTEURS_SEQ.nextval, surnom, prenom);
            DBMS_OUTPUT.PUT_LINE ('Acteur ou actrice : ' || prenom || ' ' || surnom || 'ajoute!');
        ELSE
            RAISE data_found;
        END IF;
    EXCEPTION
        WHEN data_found THEN
            DBMS_OUTPUT.PUT_LINE ('Cet acteur existe deja dans le tableau!');
        WHEN OTHERS THEN
            raise_application_error(-20001,'ERREUR TROUVE - '||SQLCODE||' -ERREUR- '||SQLERRM);
    END InsertActeur;

      -- Inserer une nouvelle directrice ou actrice 
   PROCEDURE InsertDirecteur(
    --directeur_id  NETFLIX_DIRECTEURS.DIRECTEUR_ID%type,
        surnom NETFLIX_DIRECTEURS.SURNOM_DIRECTEUR%type, 
        prenom  NETFLIX_DIRECTEURS.PRENOM_DIRECTEUR%type)
    IS
        surnom_directeur NETFLIX_DIRECTEURS.SURNOM_DIRECTEUR%type;
        prenom_directeur NETFLIX_DIRECTEURS.PRENOM_DIRECTEUR%type;
    BEGIN
        SELECT SURNOM_DIRECTEUR, PRENOM_DIRECTEUR INTO surnom_directeur, prenom_directeur 
        FROM NETFLIX_DIRECTEURS
        WHERE surnom_directeur= surnom AND prenom_directeur = prenom;

        IF SQL%NOTFOUND THEN
            INSERT INTO NETFLIX_DIRECTEURS(DIRECTEUR_ID,SURNOM_DIRECTEUR,PRENOM_DIRECTEUR) 
                VALUES (NETFLIX_DIRECTEURS_SEQ.nextval, surnom, prenom);
            DBMS_OUTPUT.PUT_LINE ('Directeur ou Directrice : ' || prenom || ' ' || surnom || 'ajoute!');
        ELSE
            RAISE data_found;
        END IF;
    EXCEPTION
        WHEN data_found THEN
            DBMS_OUTPUT.PUT_LINE ('Ce directeur ou directrice existe deja dans le tableau!');
        WHEN OTHERS THEN
            raise_application_error(-20001,'ERREUR TROUVE - '||SQLCODE||' -ERREUR- '||SQLERRM);
    END InsertDirecteur;

    -- Inserer une nouvelle actrice ou acteur 
   PROCEDURE ActeurFilm(
    surnom NETFLIX_ACTEURS.SURNOM_ACTEUR%type, 
    prenom  NETFLIX_ACTEURS.PRENOM_ACTEUR%type,
    film NETFLIX_FILMS.TITRE%type
    ) IS
        acteurId NETFLIX_ACTEURS.ACTEUR_ID%type;
        filmID  NETFLIX_FILMS.FILM_ID%type;
    BEGIN
        SELECT ACTEUR_ID INTO acteurId
        FROM NETFLIX_ACTEURS
        WHERE SURNOM_ACTEUR = surnom AND PRENOM_ACTEUR = prenom;

        SELECT FILM_ID INTO filmId
        FROM NETFLIX_FILMS
        WHERE TITRE = film;
        IF SQL%NOTFOUND THEN
            RAISE data_found;
        ELSE
            INSERT INTO NETFLIX_ACTEURS_REF(ACTEUR_ID, FILM_ID) VALUES (acteurId, filmId);
            DBMS_OUTPUT.PUT_LINE ('Film : ' || film || ' Acteur ' || surnom || 'ajoute!');
            
        END IF;
    EXCEPTION
        WHEN data_found THEN
            DBMS_OUTPUT.PUT_LINE ('Ce film existe deja dans le tableau!');
        WHEN OTHERS THEN
            raise_application_error(-20001,'ERREUR TROUVE - '||SQLCODE||' -ERREUR- '||SQLERRM);
    END ActeurFilm;

    -- Inserer une nouvelle directrice ou directeur 
   PROCEDURE DirecteurFilm(
    surnom NETFLIX_ACTEURS.SURNOM_ACTEUR%type, 
    prenom  NETFLIX_ACTEURS.PRENOM_ACTEUR%type,
    film NETFLIX_FILMS.TITRE%type
    )  IS
        directeurId NETFLIX_DIRECTEURS.DIRECTEUR_ID%type;
        filmID  NETFLIX_FILMS.FILM_ID%type;
    BEGIN
        SELECT DIRECTEUR_ID INTO directeurId
        FROM NETFLIX_DIRECTEURS
        WHERE SURNOM_DIRECTEUR = surnom AND PRENOM_DIRECTEUR = prenom;

        SELECT FILM_ID INTO filmId
        FROM NETFLIX_FILMS
        WHERE TITRE = film;
        IF SQL%NOTFOUND THEN
            RAISE data_found;
        ELSE
            INSERT INTO NETFLIX_DIRECTEURS_REF(DIRECTEUR_ID, FILM_ID) VALUES (directeurId, filmId);
            DBMS_OUTPUT.PUT_LINE ('Film : ' || film || ' Directeur ' || surnom || 'ajoute!');
            
        END IF;
    EXCEPTION
        WHEN data_found THEN
            DBMS_OUTPUT.PUT_LINE ('Ce film existe deja dans le tableau!');
        WHEN OTHERS THEN
            raise_application_error(-20001,'ERREUR TROUVE - '||SQLCODE||' -ERREUR- '||SQLERRM);
    END DirecteurFilm;

    -- Inserer une nouvelle actrice ou acteur 
   PROCEDURE DetailsFilm(
    film NETFLIX_FILMS.TITRE%type
    )  IS
        CURSOR Details IS
            SELECT 
                DESCRIPTION, 
                SURNOM_DIRECTEUR, 
                PRENOM_DIRECTEUR, 
                SURNOM_ACTEUR, 
                PRENOM_ACTEUR
            FROM NETFLIX_FILMS a
            INNER JOIN NETFLIX_ACTEURS_REF d ON d.FILM_ID = a.FILM_ID
            INNER JOIN NETFLIX_ACTEURS c ON d.ACTEUR_ID = c.ACTEUR_ID
            INNER JOIN NETFLIX_DIRECTEURS_REF e ON a.FILM_ID = e.FILM_ID
            INNER JOIN NETFLIX_DIRECTEURS b ON e.DIRECTEUR_ID = b.DIRECTEUR_ID 
            WHERE TITRE = film; 
    BEGIN
        OPEN Details;
        FOR d IN Details
        LOOP
          DBMS_OUTPUT.PUT_LINE ('directeur ' || d.PRENOM_DIRECTEUR || d.SURNOM_DIRECTEUR ||
            ' Acteur : '|| d.SURNOM_ACTEUR || d.PRENOM_ACTEUR || d.DESCRIPTION);
        END LOOP;
        CLOSE Details;

    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'ERREUR TROUVE - '||SQLCODE||' -ERREUR- '||SQLERRM);
    END DetailsFilm;

        -- Supprimer un film
    PROCEDURE DeleteFilm(
    film NETFLIX_FILMS.TITRE%type
    ) IS 
    BEGIN
        DELETE FROM NETFLIX_FILMS
        WHERE TITRE = film;
        -- les valeurs correspondantes dans les tables de références 
        -- (NETFLIX_DIRECTEURS_REF et NETFLIX_ACTEURS_REF) SERONT SUPPRIMEES AUTOMATIQUEMENT
        -- AVEC LE ON DELETE CASCADE dans les tables de références
    END DeleteFilm;
END NETFLIX_PKG;

-- Section E
-- permissions pour chaque table
GRANT SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO CHANTALE;
-- permission pour chaque sewuence 
GRANT SELECT ANY SEQUENCE TO CHANTALE;
--Permission pour chaque view
GRANT SELECT ON NETFLIX_DETAILS_V1 TO CHANTALE;

GRANT EXECUTE ANY PROCEDURE TO CHANTALE;
























































