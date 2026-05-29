-- Zadanie 1. 
DECLARE
  v_kursanci NUMBER;
  v_kursy NUMBER;
  v_wykladowcy NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_kursanci FROM kursanci;
  SELECT COUNT(*) INTO v_kursy FROM kursy;
  SELECT COUNT(*) INTO v_wykladowcy FROM wykladowcy;
  
  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || v_kursanci);
  DBMS_OUTPUT.PUT_LINE('Liczba kursów: ' || v_kursy);
  DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: ' || v_wykladowcy);
END;
/

-- Zadanie 2. 
DECLARE
  v_suma_bydgoszcz NUMBER;
BEGIN
  SELECT SUM(r.cena) INTO v_suma_bydgoszcz
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';
  
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || v_suma_bydgoszcz || ' zł');
END;
/

-- Zadanie 3.
DECLARE
  v_miasto VARCHAR2(20) := 'BYDGOSZCZ';
  v_liczba_umow NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_liczba_umow FROM umowy WHERE miasto = v_miasto;
  
  IF v_liczba_umow = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta');
  ELSIF v_liczba_umow < 50 THEN
    DBMS_OUTPUT.PUT_LINE('Mała liczba umów');
  ELSIF v_liczba_umow BETWEEN 50 AND 100 THEN
    DBMS_OUTPUT.PUT_LINE('Średnia liczba umów');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Duża liczba umów');
  END IF;
END;
/

-- Zadanie 4.
BEGIN
  FOR r IN (
    SELECT k.kurs_id, rz.nazwa, rz.godz, rz.cena, w.imie, w.nazwisko
    FROM kursy k
    JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
    JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' || r.godz || 'h, ' || r.cena || ' zł, prowadzący: ' || r.imie || ' ' || r.nazwisko);
  END LOOP;
END;
/

-- Zadanie 5. 
CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2) IS
  v_liczba_umow NUMBER;
  v_suma_wartosci NUMBER;
  v_srednia_wartosc NUMBER;
BEGIN
  SELECT COUNT(*), NVL(SUM(rz.cena), 0), NVL(AVG(rz.cena), 0)
  INTO v_liczba_umow, v_suma_wartosci, v_srednia_wartosc
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
  WHERE u.miasto = p_miasto;
  
  DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || p_miasto);
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba_umow);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_suma_wartosci || ' zł');
  DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: ' || ROUND(v_srednia_wartosc, 2) || ' zł');
END;
/

-- Zadanie 6.
CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER) 
RETURN NUMBER IS
  v_cena NUMBER;
BEGIN
  SELECT rz.cena INTO v_cena
  FROM kursy k
  JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
  WHERE k.kurs_id = p_kurs_id;
  
  RETURN v_cena;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

-- Zadanie 7. 
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER) IS
  v_imie varchar2(20);
  v_nazwisko varchar2(30);
BEGIN
  SELECT imie, nazwisko INTO v_imie, v_nazwisko FROM kursanci WHERE kursant_id = p_kursant_id;
  DBMS_OUTPUT.PUT_LINE(v_imie || ' ' || v_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/

CREATE OR REPLACE PROCEDURE pokaz_kursanta_nazwisko(p_nazwisko IN VARCHAR2) IS
  v_imie varchar2(20);
  v_nazwisko varchar2(30);
BEGIN
  SELECT imie, nazwisko INTO v_imie, v_nazwisko FROM kursanci WHERE nazwisko = p_nazwisko;
  DBMS_OUTPUT.PUT_LINE(v_imie || ' ' || v_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o nazwisku: ' || p_nazwisko);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Znaleziono wielu kursantów o nazwisku: ' || p_nazwisko);
END;
/

-- Zadanie 8
DECLARE
  CURSOR c_umowy IS
    SELECT u.umowa_id, kr.imie, kr.nazwisko, rz.nazwa, rz.cena
    FROM umowy u
    JOIN kursanci kr ON u.kursant_id = kr.kursant_id
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';
    
  v_umowa_id umowy.umowa_id%TYPE;
  v_imie kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
  v_nazwa_kursu rodzaje.nazwa%TYPE;
  v_cena rodzaje.cena%TYPE;
BEGIN
  OPEN c_umowy;
  LOOP
    FETCH c_umowy INTO v_umowa_id, v_imie, v_nazwisko, v_nazwa_kursu, v_cena;
    EXIT WHEN c_umowy%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Umowa ' || v_umowa_id || ' | ' || v_imie || ' ' || v_nazwisko || ' | ' || v_nazwa_kursu || ' | ' || v_cena || ' zł');
  END LOOP;
  CLOSE c_umowy;
END;
/

-- Zadanie 9. 
CREATE OR REPLACE PROCEDURE raport_umow_szczecin IS
BEGIN
  FOR r IN (
    SELECT u.umowa_id, kf.imie, kf.nazwisko, rf.nazwa AS nazwa_kursu, rf.cena, u.miasto
    FROM umowy u
    JOIN kursanciFilia kf ON u.kursant_id = kf.kursant_id
    JOIN kursyFilia kf_k ON u.kurs_id = kf_k.kurs_id
    JOIN rodzajeFilia rf ON kf_k.rodzaj_id = rf.rodzaj_id
    WHERE u.miasto = 'SZCZECIN'
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Umowa ' || r.umowa_id || ' | ' || r.imie || ' ' || r.nazwisko || ' | ' || r.nazwa_kursu || ' | ' || r.cena || ' zł | ' || r.miasto);
  END LOOP;
END;
/

-- Zadanie 10. 
CREATE OR REPLACE PROCEDURE raport_uczelni IS
  v_l_byd NUMBER; v_s_byd NUMBER; v_d_byd VARCHAR2(50); v_p_byd VARCHAR2(50);
  v_l_szcz NUMBER; v_s_szcz NUMBER; v_d_szcz VARCHAR2(50); v_p_szcz VARCHAR2(50);
BEGIN
  SELECT COUNT(*), NVL(SUM(rz.cena), 0) INTO v_l_byd, v_s_byd
  FROM umowy u JOIN kursy k ON u.kurs_id = k.kurs_id JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  SELECT max_nazwa INTO v_d_byd FROM (
    SELECT rz.nazwa AS max_nazwa FROM kursy k JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id ORDER BY rz.cena DESC
  ) WHERE ROWNUM = 1;

  SELECT pop_nazwa INTO v_p_byd FROM (
    SELECT rz.nazwa AS pop_nazwa FROM umowy u JOIN kursy k ON u.kurs_id = k.kurs_id JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id WHERE u.miasto = 'BYDGOSZCZ' GROUP BY rz.nazwa ORDER BY COUNT(*) DESC
  ) WHERE ROWNUM = 1;

  SELECT COUNT(*), NVL(SUM(rf.cena), 0) INTO v_l_szcz, v_s_szcz
  FROM umowy u JOIN kursyFilia kf ON u.kurs_id = kf.kurs_id JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
  WHERE u.miasto = 'SZCZECIN';

  SELECT max_nazwa INTO v_d_szcz FROM (
    SELECT rf.nazwa AS max_nazwa FROM kursyFilia kf JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id ORDER BY rf.cena DESC
  ) WHERE ROWNUM = 1;

  SELECT pop_nazwa INTO v_p_szcz FROM (
    SELECT rf.nazwa AS pop_nazwa FROM umowy u JOIN kursyFilia kf ON u.kurs_id = kf.kurs_id JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id WHERE u.miasto = 'SZCZECIN' GROUP BY rf.nazwa ORDER BY COUNT(*) DESC
  ) WHERE ROWNUM = 1;

  DBMS_OUTPUT.PUT_LINE('RAPORT UCZELNI');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_l_byd);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_s_byd || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_d_byd);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_p_byd);
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_l_szcz);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_s_szcz || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_d_szcz);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_p_szcz);
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('PODSUMOWANIE');
  DBMS_OUTPUT.PUT_LINE('Liczba wszystkich umów: ' || (v_l_byd + v_l_szcz));
  DBMS_OUTPUT.PUT_LINE('Łączna wartość wszystkich umów: ' || (v_s_byd + v_s_szcz) || ' zł');
END;
/
