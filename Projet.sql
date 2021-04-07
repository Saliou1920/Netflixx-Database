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
    OLD_TITRE VARCHAR2(100) NOT NULL,
    NEW_TITRE VARCHAR2(100) NOT NULL,
    OLD_ANNEE_SORTIE NUMBER(4) NOT NULL,
    NEW_ANNEE_SORTIE NUMBER(4) NOT NULL,
    OLD_DURAION NUMBER(4) NOT NULL,
    NEW_DURAION NUMBER(4) NOT NULL,
    OLD_DESCRIPTION VARCHAR2(4000) NOT NULL,
    NEW_DESCRIPTION VARCHAR2(4000) NOT NULL
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
);

-- table de référence qui servira à enregistrer les acteurs de chaque film.

CREATE TABLE NETFLIX_ACTEURS_REF 
(
    ACTEUR_ID NUMBER(4) NOT NULL,
    FILM_ID NUMBER(4) NOT NULL,
    
    CONSTRAINT NETFLIX_ACTEURS_REF_PK PRIMARY KEY (ACTEUR_ID, FILM_ID),
    FOREIGN KEY (ACTEUR_ID) REFERENCES NETFLIX_ACTEURS(ACTEUR_ID),
    FOREIGN KEY (FILM_ID) REFERENCES NETFLIX_FILMS(FILM_ID)
);

-- Vue

CREATE VIEW NETFLIX_DETAILS_V1 AS
SELECT TITRE, ANNEE_SORTIE,DURATION,DESCRIPTION, SURNOM_DIRECTEUR, PRENOM_DIRECTEUR,
        SURNOM_ACTEUR, PRENOM_ACTEUR
FROM NETFLIX_FILMS a, NETFLIX_DIRECTEURS b, NETFLIX_ACTEURS c, NETFLIX_ACTEURS_REF d, NETFLIX_DIRECTEURS_REF e 
WHERE c.ACTEUR_ID = d.ACTEUR_ID AND d.FILM_ID = a.FILM_ID AND a.FILM_ID = e.FILM_ID AND 
      e.DIRECTEUR_ID = b.DIRECTEUR_ID;


























