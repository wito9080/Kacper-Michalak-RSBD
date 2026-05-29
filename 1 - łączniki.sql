-- Zadanie 5:
CREATE OR REPLACE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE OR REPLACE SYNONYM kursanciSiedziba FOR kursanci;
CREATE OR REPLACE SYNONYM rodzajeSiedziba FOR rodzaje;
CREATE OR REPLACE SYNONYM kursySiedziba FOR kursy;

CREATE OR REPLACE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE OR REPLACE SYNONYM kursanciFilia FOR kursanci@dblinkFilia;
CREATE OR REPLACE SYNONYM rodzajeFilia FOR rodzaje@dblinkFilia;
CREATE OR REPLACE SYNONYM kursyFilia FOR kursy@dblinkFilia;


-- Zadanie 6: 
CREATE OR REPLACE VIEW kursanciAll AS
SELECT imie, nazwisko FROM kursanciSiedziba
UNION
SELECT imie, nazwisko FROM kursanciFilia;

CREATE OR REPLACE VIEW wykladowcyAll AS
SELECT imie, nazwisko FROM wykladowcySiedziba
UNION
SELECT imie, nazwisko FROM wykladowcyFilia;


-- Zadanie 7: 
CREATE OR REPLACE VIEW kursyAll AS
SELECT 
    r.nazwa AS nazwa_kursu,
    w.imie || ' ' || w.nazwisko AS prowadzacy,
    COUNT(u.umowa_id) AS ilosc_uczestnikow,
    k.kurs_id,
    'Siedziba' AS pochodzenie
FROM kursySiedziba k
JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
LEFT JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u ON k.kurs_id = u.kurs_id AND u.miasto = 'BYDGOSZCZ'
GROUP BY r.nazwa, w.imie, w.nazwisko, k.kurs_id

UNION ALL

SELECT 
    r.nazwa AS nazwa_kursu,
    w.imie || ' ' || w.nazwisko AS prowadzacy,
    COUNT(u.umowa_id) AS ilosc_uczestnikow,
    k.kurs_id,
    'Filia' AS pochodzenie
FROM kursyFilia k
JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
LEFT JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u ON k.kurs_id = u.kurs_id AND u.miasto = 'SZCZECIN'
GROUP BY r.nazwa, w.imie, w.nazwisko, k.kurs_id;


-- Zadanie 8: 
SELECT SUM(przychod_kursu) AS przychod_ogolem
FROM (
    SELECT COUNT(u.umowa_id) * r.cena AS przychod_kursu
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN umowy u ON k.kurs_id = u.kurs_id AND u.miasto = 'BYDGOSZCZ'
    GROUP BY k.kurs_id, r.cena
    
    UNION ALL
    
    SELECT COUNT(u.umowa_id) * r.cena AS przychod_kursu
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN umowy u ON k.kurs_id = u.kurs_id AND u.miasto = 'SZCZECIN'
    GROUP BY k.kurs_id, r.cena
);


-- Zadanie 9:
SELECT SUM(koszt_kursu) AS koszty_ogolem
FROM (
    SELECT w.stawka * r.godz AS koszt_kursu
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
    
    UNION ALL
    
    SELECT w.stawka * r.godz AS koszt_kursu
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
);


-- Zadanie 10: 
SELECT 
    pochodzenie,
    kurs_id,
    nazwa_kursu,
    przychody,
    koszty,
    (przychody - koszty) AS zysk_strata
FROM (
    SELECT 
        'Siedziba' AS pochodzenie,
        k.kurs_id,
        r.nazwa AS nazwa_kursu,
        (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id AND u.miasto = 'BYDGOSZCZ') * r.cena AS przychody,
        w.stawka * r.godz AS koszty
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id

    UNION ALL

    SELECT 
        'Filia' AS pochodzenie,
        k.kurs_id,
        r.nazwa AS nazwa_kursu,
        (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id AND u.miasto = 'SZCZECIN') * r.cena AS przychody,
        w.stawka * r.godz AS koszty
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
)
ORDER BY pochodzenie, kurs_id;


-- Zadanie 11:
SELECT 
    SUM(przychody) AS laczne_przychody,
    SUM(koszty) AS laczne_koszty,
    (SUM(przychody) - SUM(koszty)) AS zysk_strata_netto
FROM (
    SELECT 
        (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id AND u.miasto = 'BYDGOSZCZ') * r.cena AS przychody,
        w.stawka * r.godz AS koszty
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id

    UNION ALL

    SELECT 
        (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id AND u.miasto = 'SZCZECIN') * r.cena AS przychody,
        w.stawka * r.godz AS koszty
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
);
