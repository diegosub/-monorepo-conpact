--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.21
-- Dumped by pg_dump version 9.5.21

-- Started on 2020-10-05 21:42:02

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 132892)
-- Name: sc_cuc; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sc_cuc;


ALTER SCHEMA sc_cuc OWNER TO spg;

--
-- TOC entry 2335 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA sc_cuc; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA sc_cuc IS 'schema de controle de unico cadastro';


--
-- TOC entry 8 (class 2615 OID 132893)
-- Name: sc_grl; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sc_grl;


ALTER SCHEMA sc_grl OWNER TO spg;

--
-- TOC entry 2336 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA sc_grl; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA sc_grl IS 'schema geral';


--
-- TOC entry 9 (class 2615 OID 132894)
-- Name: sc_sgr; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sc_sgr;


ALTER SCHEMA sc_sgr OWNER TO spg;

--
-- TOC entry 2337 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA sc_sgr; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA sc_sgr IS 'schema de seguranca';


--
-- TOC entry 1 (class 3079 OID 12355)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2338 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 217 (class 1255 OID 132895)
-- Name: adicionar_mes(date, numeric); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.adicionar_mes(vp_data date, qt_meses numeric) RETURNS date
    LANGUAGE plpgsql
    AS $$
Declare

retorno date;
cont numeric := 1;

Begin

     retorno := vp_data;

     while cont < qt_meses loop

        retorno := retorno + interval '1 month';
	cont := cont + 1;

     end loop;

     return retorno;
End;
$$;


ALTER FUNCTION sc_grl.adicionar_mes(vp_data date, qt_meses numeric) OWNER TO spg;

--
-- TOC entry 218 (class 1255 OID 132896)
-- Name: eh_dia_util(timestamp with time zone); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.eh_dia_util(vp_data timestamp with time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$Declare

retorno boolean;
existe numeric;

Begin

     retorno := (date_part('dow', vp_data) <> 0 And date_part('dow', vp_data) <> 6);

     if retorno then

        -- testa se nao eh feriado

        select coalesce(count(*),0)
          into existe
        from sc_grl.tbl_frd
        where dt_frd = vp_data;

        if existe > 0 then
          retorno := false;
        end if;

     end if;

     return retorno;
End;
$$;


ALTER FUNCTION sc_grl.eh_dia_util(vp_data timestamp with time zone) OWNER TO spg;

--
-- TOC entry 219 (class 1255 OID 132897)
-- Name: get_proximo_dia_util(timestamp with time zone); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.get_proximo_dia_util(vp_data timestamp with time zone) RETURNS date
    LANGUAGE plpgsql
    AS $$

declare

vl_data date;

Begin

     vl_data := vp_data + interval '1 day';

     while not sc_grl.eh_dia_util(vl_data) loop
       vl_data := vl_data + interval '1 day';
     end loop;

     return vl_data;
End;
$$;


ALTER FUNCTION sc_grl.get_proximo_dia_util(vp_data timestamp with time zone) OWNER TO spg;

--
-- TOC entry 220 (class 1255 OID 132898)
-- Name: sem_acento(text); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.sem_acento(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
select
translate($1,'áàâãäéèêëíìïóòôõöúùûüÁÀÂÃÄÉÈÊËÍÌÏÓÒÔÕÖÚÙÛÜçÇ','aaaaaeeeeiiiooooouuuuAAAAAEEEEIIIOOOOOUUUUcC');
$_$;


ALTER FUNCTION sc_grl.sem_acento(text) OWNER TO spg;

--
-- TOC entry 233 (class 1255 OID 132899)
-- Name: ultimo_dia_mes(date); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.ultimo_dia_mes(vp_data date) RETURNS numeric
    LANGUAGE plpgsql
    AS $$declare

vl_data_referencia date;

begin

 vl_data_referencia := vp_data + interval '1 month';

 vl_data_referencia := to_date ('01/' || to_char(vl_data_referencia,'mm/yyyy'),'dd/mm/yyyy');

 vl_data_referencia := vl_data_referencia - 1;

 return to_char(vl_data_referencia,'dd')::numeric;

end;$$;


ALTER FUNCTION sc_grl.ultimo_dia_mes(vp_data date) OWNER TO spg;

--
-- TOC entry 234 (class 1255 OID 132900)
-- Name: valida_cnpj(numeric); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.valida_cnpj(vp_cnpj numeric) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
 v_caldv1 int4;
 v_caldv2 int4;
 v_dv1 int4;
 v_dv2 int4;
 v_array1 text[] ;
 v_array2 text[] ;
 v_tst_string int4;
 vl_cnpj varchar(14);
BEGIN
  vl_cnpj := cast(vp_cnpj as varchar);

  -- preenchendo a variavel de cpf com zeros a esquerda ate completar 11 digitos
  while char_length(vl_cnpj) < 14 loop
    vl_cnpj := '0' || vl_cnpj;
  end loop;

  SELECT INTO v_array1 '{5,4,3,2,9,8,7,6,5,4,3,2}';
  SELECT INTO v_array2 '{6,5,4,3,2,9,8,7,6,5,4,3,2}';
  v_dv1 := (substring(vl_cnpj, 13, 1))::int4;
  v_dv2 := (substring(vl_cnpj, 14, 1))::int4;

  /* COLETA DIG VER 1 CNPJ */
  v_caldv1 := 0;
  FOR va IN 1..12 LOOP
    v_caldv1 := v_caldv1 + ((SELECT substring(vl_cnpj, va, 1))::int4 * (v_array1[va]::int4));
  END LOOP;

  v_caldv1 := v_caldv1 % 11;

  IF (v_caldv1 = 0) OR (v_caldv1 = 1) THEN
    v_caldv1 := 0;
  ELSE
    v_caldv1 := 11 - v_caldv1;
  END IF;

  /* COLETA DIG VER 2 CNPJ */
  v_caldv2 := 0;
  FOR va IN 1..13 LOOP
    v_caldv2 := v_caldv2 + ((SELECT substring(vl_cnpj || v_caldv1::text, va, 1))::int4 * (v_array2[va]::int4));
  END LOOP;

  v_caldv2 := v_caldv2 % 11;
  IF (v_caldv2 = 0) OR (v_caldv2 = 1) THEN
    v_caldv2 := 0;
  ELSE
    v_caldv2 := 11 - v_caldv2;
  END IF;

  /* TESTA */
  IF (v_caldv1 = v_dv1) AND (v_caldv2 = v_dv2) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
end;
$$;


ALTER FUNCTION sc_grl.valida_cnpj(vp_cnpj numeric) OWNER TO spg;

--
-- TOC entry 235 (class 1255 OID 132901)
-- Name: valida_cpf(numeric); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.valida_cpf(vp_cpf numeric) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
-- ROTINA DE VALIDAÇÃO DE CPF
-- Conversão para o PL/ PGSQL: Cláudio Leopoldino - http://postgresqlbr.blogspot.com/
-- Algoritmo original: http://webmasters.neting.com/msg07743.html
-- Retorna 1 para CPF correto.
DECLARE
  x real;
  y real; --Variável temporária
  soma integer;
  dig1 integer; --Primeiro dígito do CPF
  dig2 integer; --Segundo dígito do CPF
  len integer; -- Tamanho do CPF
  contloop integer; --Contador para loop
  vl_cpf varchar(11);
BEGIN
  vl_cpf := cast(vp_cpf as varchar);

  -- preenchendo a variavel de cpf com zeros a esquerda ate completar 11 digitos
  while char_length(vl_cpf) < 11 loop
    vl_cpf := '0' || vl_cpf;
  end loop;

  -- Inicialização
  x := 0;
  soma := 0;
  dig1 := 0;
  dig2 := 0;
  contloop := 0;
  len := char_length(vl_cpf);
  x := len -1;

  --Loop de multiplicação - dígito 1
  contloop :=1;
  WHILE contloop <= (len -2) LOOP
    y := CAST(substring(vl_cpf from contloop for 1) AS NUMERIC);
    soma := soma + ( y * x);
    x := x - 1;
    contloop := contloop +1;
  END LOOP;

  dig1 := 11 - CAST((soma % 11) AS INTEGER);
  if (dig1 = 10) THEN dig1 :=0 ; END IF;
  if (dig1 = 11) THEN dig1 :=0 ; END IF;

  -- Dígito 2
  x := 11; soma :=0;
  contloop :=1;
  WHILE contloop <= (len -1) LOOP
    soma := soma + CAST((substring(vl_cpf FROM contloop FOR 1)) AS REAL) * x;
    x := x - 1;
    contloop := contloop +1;
  END LOOP;

  dig2 := 11 - CAST ((soma % 11) AS INTEGER);
  IF (dig2 = 10) THEN dig2 := 0; END IF;
  IF (dig2 = 11) THEN dig2 := 0; END IF;

  --Teste do CPF
  IF ((dig1 || '' || dig2) = substring(vl_cpf FROM len-1 FOR 2)) THEN
    RETURN true;
  ELSE
    return false;
  END IF;
END;
$$;


ALTER FUNCTION sc_grl.valida_cpf(vp_cpf numeric) OWNER TO spg;

--
-- TOC entry 236 (class 1255 OID 132902)
-- Name: valida_email(character varying); Type: FUNCTION; Schema: sc_grl; Owner: postgres
--

CREATE FUNCTION sc_grl.valida_email(vp_email character varying) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
declare
  vl_pos_arroba integer;
  vl_pos_1_ponto integer;
  vl_pos_2_ponto integer;
  vl_pos_espaco integer;

  vl_email varchar;
begin
  --retirando os espacos no inicio e no final do e-mail
  vl_email := trim(vp_email);
  if length(vl_email) < 8 then
    return false;
  end if;

  --verificando se existe espaco no meio do e-mail, se tiver retorna invalido
  vl_pos_espaco := position(' ' in vl_email);
  if vl_pos_espaco > 0 then
    return false;
  end if;

  --verificando se existe @ no meio do e-mail, se não tiver retorna invalido
  vl_pos_arroba := position('@' in vl_email);
  if vl_pos_arroba <= 0 then
    return false;
  end if;

  --verificando se existe . apos a @ no e-mail, se não tiver retorna invalido
  vl_pos_1_ponto := position('.' in substring(vl_email,vl_pos_arroba+1));
  if vl_pos_1_ponto <= 0 then
    return false;
  end if;

  --verificando se existe um segundo . apos o primeiro . no e-mail,
  --se tiver deve estar a dois caracteres antes do final do e-mail e três caracteres depois do primeiro ponto
  vl_pos_2_ponto := position('.' in substring(vl_email,vl_pos_1_ponto+1));
  if vl_pos_2_ponto > 0 and (vl_pos_2_ponto <> length(vl_email) - 2 or vl_pos_1_ponto <> vl_pos_2_ponto - 4) then
    return false;
  end if;

  --senão tiver o primeiro ponto deve estar a três caracteres antes do final do e-mail
  if vl_pos_2_ponto <= 0 and vl_pos_1_ponto <> length(vl_email) - 3 then
    return false;
  end if;

  return true;
end;$$;


ALTER FUNCTION sc_grl.valida_email(vp_email character varying) OWNER TO spg;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 132903)
-- Name: sq_ctt; Type: SEQUENCE; Schema: sc_cuc; Owner: postgres
--

CREATE SEQUENCE sc_cuc.sq_ctt
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_cuc.sq_ctt OWNER TO spg;

--
-- TOC entry 186 (class 1259 OID 132905)
-- Name: sq_cun; Type: SEQUENCE; Schema: sc_cuc; Owner: postgres
--

CREATE SEQUENCE sc_cuc.sq_cun
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_cuc.sq_cun OWNER TO spg;

--
-- TOC entry 187 (class 1259 OID 132907)
-- Name: sq_edr; Type: SEQUENCE; Schema: sc_cuc; Owner: postgres
--

CREATE SEQUENCE sc_cuc.sq_edr
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_cuc.sq_edr OWNER TO spg;

--
-- TOC entry 188 (class 1259 OID 132909)
-- Name: sq_tlf; Type: SEQUENCE; Schema: sc_cuc; Owner: postgres
--

CREATE SEQUENCE sc_cuc.sq_tlf
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_cuc.sq_tlf OWNER TO spg;

--
-- TOC entry 189 (class 1259 OID 132911)
-- Name: tbl_cpf; Type: TABLE; Schema: sc_cuc; Owner: postgres
--

CREATE TABLE sc_cuc.tbl_cpf (
    cd_cun numeric(10,0) NOT NULL,
    nr_rg_cpf numeric(14,0),
    nm_mae_cpf character varying(80),
    dt_nsc_cpf date,
    sexo_cpf character varying(1)
);


ALTER TABLE sc_cuc.tbl_cpf OWNER TO spg;

--
-- TOC entry 2339 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE tbl_cpf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON TABLE sc_cuc.tbl_cpf IS 'EXTENSAO DA TABELA DE CADASTRO UNICO QUE ARMAZENA OS DADOS ESPECIFICOS DE PESSOA FISICA';


--
-- TOC entry 2340 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN tbl_cpf.cd_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpf.cd_cun IS 'codigo do cadastro unico';


--
-- TOC entry 2341 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN tbl_cpf.nr_rg_cpf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpf.nr_rg_cpf IS 'numero do RG';


--
-- TOC entry 2342 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN tbl_cpf.nm_mae_cpf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpf.nm_mae_cpf IS 'nome da mae';


--
-- TOC entry 2343 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN tbl_cpf.dt_nsc_cpf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpf.dt_nsc_cpf IS 'data de nascimento';


--
-- TOC entry 2344 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN tbl_cpf.sexo_cpf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpf.sexo_cpf IS 'sexo (M-masculino; F-feminino; O-outro)';


--
-- TOC entry 190 (class 1259 OID 132914)
-- Name: tbl_cpj; Type: TABLE; Schema: sc_cuc; Owner: postgres
--

CREATE TABLE sc_cuc.tbl_cpj (
    cd_cun numeric(10,0) NOT NULL,
    nm_fts_cpj character varying(50),
    nr_ins_edl_cpj numeric(14,0),
    dt_reg_cpj date
);


ALTER TABLE sc_cuc.tbl_cpj OWNER TO spg;

--
-- TOC entry 2345 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE tbl_cpj; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON TABLE sc_cuc.tbl_cpj IS 'EXTENSAO DA TABELA DE CADASTRO UNICO QUE ARMAZENA OS DADOS ESPECIFICOS DE PESSOA JURIDICA';


--
-- TOC entry 2346 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN tbl_cpj.cd_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpj.cd_cun IS 'cadastro unico';


--
-- TOC entry 2347 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN tbl_cpj.nm_fts_cpj; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpj.nm_fts_cpj IS 'nome fantasia';


--
-- TOC entry 2348 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN tbl_cpj.nr_ins_edl_cpj; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpj.nr_ins_edl_cpj IS 'numero de inscricao estadual';


--
-- TOC entry 2349 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN tbl_cpj.dt_reg_cpj; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cpj.dt_reg_cpj IS 'data do registro do CNPJ';


--
-- TOC entry 191 (class 1259 OID 132917)
-- Name: tbl_ctt; Type: TABLE; Schema: sc_cuc; Owner: postgres
--

CREATE TABLE sc_cuc.tbl_ctt (
    cd_ctt numeric(10,0) NOT NULL,
    cd_cun numeric(10,0) NOT NULL,
    cd_crg numeric(5,0),
    nm_ctt character varying(50) NOT NULL,
    dt_nsc_ctt date,
    eml_ctt character varying(50),
    cd_inc_usr numeric(5,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(5,0),
    dt_alt_usr time(6) without time zone,
    tp_ctt numeric,
    fg_atv_ctt boolean NOT NULL
);


ALTER TABLE sc_cuc.tbl_ctt OWNER TO spg;

--
-- TOC entry 2350 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE tbl_ctt; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON TABLE sc_cuc.tbl_ctt IS 'TABELA DE CONTATOS DE PESSOA JURIDICA';


--
-- TOC entry 2351 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.cd_ctt; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.cd_ctt IS 'codigo';


--
-- TOC entry 2352 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.cd_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.cd_cun IS 'codigo do cadastro unico';


--
-- TOC entry 2353 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.cd_crg; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.cd_crg IS 'cargo (ver dominio)';


--
-- TOC entry 2354 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.nm_ctt; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.nm_ctt IS 'nome';


--
-- TOC entry 2355 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.dt_nsc_ctt; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.dt_nsc_ctt IS 'data de nascimento';


--
-- TOC entry 2356 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.eml_ctt; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.eml_ctt IS 'e-mail';


--
-- TOC entry 2357 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.cd_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.cd_inc_usr IS 'usuario de inclusao';


--
-- TOC entry 2358 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.dt_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.dt_inc_usr IS 'data de inclusao';


--
-- TOC entry 2359 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.cd_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.cd_alt_usr IS 'usuario que realizou a ultima alteracao';


--
-- TOC entry 2360 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.dt_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.dt_alt_usr IS 'data da ultima alteracao';


--
-- TOC entry 2361 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.tp_ctt; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.tp_ctt IS 'tipo do contato (tabela de domínio)';


--
-- TOC entry 2362 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN tbl_ctt.fg_atv_ctt; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_ctt.fg_atv_ctt IS 'flag de ativo';


--
-- TOC entry 192 (class 1259 OID 132923)
-- Name: tbl_cun; Type: TABLE; Schema: sc_cuc; Owner: postgres
--

CREATE TABLE sc_cuc.tbl_cun (
    cd_cun numeric(10,0) NOT NULL,
    nm_cun character varying(80) NOT NULL,
    eml_cun character varying(2000),
    nr_cpf_cnpj_cun numeric(14,0) NOT NULL,
    tp_pss_cun character(1) NOT NULL,
    cd_inc_usr numeric(10,0),
    cd_alt_usr numeric(10,0),
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    dt_alt_usr timestamp(6) without time zone,
    ft_cun character varying(100)
);


ALTER TABLE sc_cuc.tbl_cun OWNER TO spg;

--
-- TOC entry 2363 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE tbl_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON TABLE sc_cuc.tbl_cun IS 'TABELA DE CADASTRO UNICO';


--
-- TOC entry 2364 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.cd_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.cd_cun IS 'pk - codigo';


--
-- TOC entry 2365 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.nm_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.nm_cun IS 'nome ou razao social';


--
-- TOC entry 2366 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.eml_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.eml_cun IS 'email';


--
-- TOC entry 2367 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.nr_cpf_cnpj_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.nr_cpf_cnpj_cun IS 'cpf ou cnpj';


--
-- TOC entry 2368 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.tp_pss_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.tp_pss_cun IS 'tipo de pessoa (F-Fisica; J-Juridica)';


--
-- TOC entry 2369 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.cd_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.cd_inc_usr IS 'usuario de inclusao';


--
-- TOC entry 2370 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.cd_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.cd_alt_usr IS 'usuario que realizou a ultima alteracao';


--
-- TOC entry 2371 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.dt_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.dt_inc_usr IS 'data de inclusao';


--
-- TOC entry 2372 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.dt_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.dt_alt_usr IS 'data da ultima alteracao';


--
-- TOC entry 2373 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN tbl_cun.ft_cun; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_cun.ft_cun IS 'caminho da pasta da foto do usuario';


--
-- TOC entry 193 (class 1259 OID 132929)
-- Name: tbl_edr; Type: TABLE; Schema: sc_cuc; Owner: postgres
--

CREATE TABLE sc_cuc.tbl_edr (
    cd_edr numeric(10,0) NOT NULL,
    nsu_org_edr numeric(10,0),
    cep_edr numeric(8,0) NOT NULL,
    nr_edr character varying(30) NOT NULL,
    cpl_edr character varying(150),
    cd_inc_usr numeric(10,0) NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    dt_alt_usr timestamp(6) without time zone,
    tp_edr numeric(2,0) NOT NULL,
    pt_ref_edr character varying(100),
    tp_org_edr numeric(10,0),
    fg_atv_edr boolean NOT NULL
);


ALTER TABLE sc_cuc.tbl_edr OWNER TO spg;

--
-- TOC entry 2374 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE tbl_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON TABLE sc_cuc.tbl_edr IS 'TABELA DE ENDERECO';


--
-- TOC entry 2375 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.cd_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.cd_edr IS 'codigo';


--
-- TOC entry 2376 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.nsu_org_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.nsu_org_edr IS 'nsu origem (codigo de acordo com o tipo de origem)';


--
-- TOC entry 2377 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.cep_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.cep_edr IS 'cep';


--
-- TOC entry 2378 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.nr_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.nr_edr IS 'numero';


--
-- TOC entry 2379 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.cpl_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.cpl_edr IS 'complemento';


--
-- TOC entry 2380 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.cd_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.cd_inc_usr IS 'usuario de inclusao';


--
-- TOC entry 2381 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.cd_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.cd_alt_usr IS 'usuario que realizou a ultima alteracao';


--
-- TOC entry 2382 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.dt_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.dt_inc_usr IS 'data de inclusao';


--
-- TOC entry 2383 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.dt_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.dt_alt_usr IS 'data da ultima alteracao';


--
-- TOC entry 2384 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.tp_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.tp_edr IS 'ver tabela de dominio';


--
-- TOC entry 2385 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.pt_ref_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.pt_ref_edr IS 'ponto de referencia do endereco';


--
-- TOC entry 2386 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.tp_org_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.tp_org_edr IS 'tipo de origem (ver dominio)';


--
-- TOC entry 2387 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN tbl_edr.fg_atv_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_edr.fg_atv_edr IS 'flag de ativo';


--
-- TOC entry 194 (class 1259 OID 132932)
-- Name: tbl_eex; Type: TABLE; Schema: sc_cuc; Owner: postgres
--

CREATE TABLE sc_cuc.tbl_eex (
    cd_edr numeric(10,0) NOT NULL,
    nm_log_eex character varying(300) NOT NULL,
    nm_brr_eex character varying(50) NOT NULL,
    nm_loc_eex character varying(50) NOT NULL,
    uf_eex character(2) NOT NULL
);


ALTER TABLE sc_cuc.tbl_eex OWNER TO spg;

--
-- TOC entry 2388 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE tbl_eex; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON TABLE sc_cuc.tbl_eex IS 'EXTENSAO DA TABELA DE ENDERECO';


--
-- TOC entry 2389 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN tbl_eex.cd_edr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_eex.cd_edr IS 'codigo';


--
-- TOC entry 2390 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN tbl_eex.nm_log_eex; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_eex.nm_log_eex IS 'logradouro';


--
-- TOC entry 2391 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN tbl_eex.nm_brr_eex; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_eex.nm_brr_eex IS 'bairro';


--
-- TOC entry 2392 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN tbl_eex.nm_loc_eex; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_eex.nm_loc_eex IS 'localidade';


--
-- TOC entry 2393 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN tbl_eex.uf_eex; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_eex.uf_eex IS 'uf';


--
-- TOC entry 195 (class 1259 OID 132935)
-- Name: tbl_tlf; Type: TABLE; Schema: sc_cuc; Owner: postgres
--

CREATE TABLE sc_cuc.tbl_tlf (
    cd_tlf numeric(10,0) NOT NULL,
    nr_ddd_tlf numeric(2,0) NOT NULL,
    nr_tlf numeric(10,0) NOT NULL,
    tp_tlf numeric(2,0) NOT NULL,
    tp_org_tlf numeric(2,0) NOT NULL,
    nsu_org_tlf numeric(10,0) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    dt_alt_usr timestamp(6) without time zone,
    fg_wap boolean DEFAULT false NOT NULL,
    fg_prp_tlf character varying(1) NOT NULL,
    fg_atv_tlf boolean NOT NULL
);


ALTER TABLE sc_cuc.tbl_tlf OWNER TO spg;

--
-- TOC entry 2394 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE tbl_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON TABLE sc_cuc.tbl_tlf IS 'TABELA DE TELEFONE';


--
-- TOC entry 2395 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.cd_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.cd_tlf IS 'codigo';


--
-- TOC entry 2396 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.nr_ddd_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.nr_ddd_tlf IS 'ddd';


--
-- TOC entry 2397 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.nr_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.nr_tlf IS 'numero';


--
-- TOC entry 2398 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.tp_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.tp_tlf IS 'tipo de telefone (ver tabela de dominio)';


--
-- TOC entry 2399 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.tp_org_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.tp_org_tlf IS 'tipo de origem (1-Pessoa Fisica; 2-Pessoa Juridica)';


--
-- TOC entry 2400 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.nsu_org_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.nsu_org_tlf IS 'se o tipo de origem for pessoa fisica eh o codigo do cadastro unico, se for pessoa juridica eh o codigo do contato';


--
-- TOC entry 2401 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.cd_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.cd_inc_usr IS 'usuario de inclusao';


--
-- TOC entry 2402 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.cd_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.cd_alt_usr IS 'usuario que realizou a ultima alteracao';


--
-- TOC entry 2403 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.dt_inc_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.dt_inc_usr IS 'data de inclusao';


--
-- TOC entry 2404 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.dt_alt_usr; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.dt_alt_usr IS 'data da ultima alteracao';


--
-- TOC entry 2405 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.fg_wap; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.fg_wap IS 'flag whatsapp';


--
-- TOC entry 2406 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.fg_prp_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.fg_prp_tlf IS 'flag principal';


--
-- TOC entry 2407 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN tbl_tlf.fg_atv_tlf; Type: COMMENT; Schema: sc_cuc; Owner: postgres
--

COMMENT ON COLUMN sc_cuc.tbl_tlf.fg_atv_tlf IS 'flag de ativo';


--
-- TOC entry 196 (class 1259 OID 132939)
-- Name: sq_dmn; Type: SEQUENCE; Schema: sc_grl; Owner: postgres
--

CREATE SEQUENCE sc_grl.sq_dmn
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_grl.sq_dmn OWNER TO spg;

--
-- TOC entry 197 (class 1259 OID 132941)
-- Name: sq_prm; Type: SEQUENCE; Schema: sc_grl; Owner: postgres
--

CREATE SEQUENCE sc_grl.sq_prm
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_grl.sq_prm OWNER TO spg;

--
-- TOC entry 198 (class 1259 OID 132943)
-- Name: tbl_dmn; Type: TABLE; Schema: sc_grl; Owner: postgres
--

CREATE TABLE sc_grl.tbl_dmn (
    cd_dmn numeric(10,0) NOT NULL,
    vl_cmp_dmn numeric(5,0) NOT NULL,
    nm_vlr_dmn character varying(100) NOT NULL,
    nm_cmp_dmn character varying(50) NOT NULL
);


ALTER TABLE sc_grl.tbl_dmn OWNER TO spg;

--
-- TOC entry 2408 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE tbl_dmn; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON TABLE sc_grl.tbl_dmn IS 'TABELA DE DOMINIO';


--
-- TOC entry 2409 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN tbl_dmn.cd_dmn; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_dmn.cd_dmn IS 'codigo';


--
-- TOC entry 2410 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN tbl_dmn.vl_cmp_dmn; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_dmn.vl_cmp_dmn IS 'valor do campo';


--
-- TOC entry 2411 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN tbl_dmn.nm_vlr_dmn; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_dmn.nm_vlr_dmn IS 'nome do valor';


--
-- TOC entry 2412 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN tbl_dmn.nm_cmp_dmn; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_dmn.nm_cmp_dmn IS 'nome do campo';


--
-- TOC entry 199 (class 1259 OID 132946)
-- Name: tbl_frd; Type: TABLE; Schema: sc_grl; Owner: postgres
--

CREATE TABLE sc_grl.tbl_frd (
    dt_frd date NOT NULL,
    ds_frd character varying(80) NOT NULL,
    tp_frd character varying(1) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone
);


ALTER TABLE sc_grl.tbl_frd OWNER TO spg;

--
-- TOC entry 2413 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE tbl_frd; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON TABLE sc_grl.tbl_frd IS 'FERIADO';


--
-- TOC entry 2414 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN tbl_frd.dt_frd; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_frd.dt_frd IS 'DATA';


--
-- TOC entry 2415 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN tbl_frd.ds_frd; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_frd.ds_frd IS 'DESCRICAO';


--
-- TOC entry 2416 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN tbl_frd.tp_frd; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_frd.tp_frd IS 'TIPO (E-ESTADUAL,M-MUNICIPAL,F-FEDERAL)';


--
-- TOC entry 2417 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN tbl_frd.cd_inc_usr; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_frd.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2418 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN tbl_frd.dt_inc_usr; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_frd.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2419 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN tbl_frd.cd_alt_usr; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_frd.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2420 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN tbl_frd.dt_alt_usr; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_frd.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 200 (class 1259 OID 132949)
-- Name: tbl_prm; Type: TABLE; Schema: sc_grl; Owner: postgres
--

CREATE TABLE sc_grl.tbl_prm (
    cd_prm numeric(5,0) NOT NULL,
    nm_prm character varying(50) NOT NULL,
    vl_prm character varying(15000) NOT NULL,
    ds_prm character varying(200) NOT NULL,
    fg_edt_prm character varying(1) DEFAULT 'S'::"char" NOT NULL,
    CONSTRAINT ck_fg_edt_prm CHECK (((fg_edt_prm)::text = ANY (ARRAY[('N'::"char")::text, ('S'::"char")::text])))
);


ALTER TABLE sc_grl.tbl_prm OWNER TO spg;

--
-- TOC entry 2421 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE tbl_prm; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON TABLE sc_grl.tbl_prm IS 'TABELA DE PARAMETROS GERAIS DO SISTEMA';


--
-- TOC entry 2422 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN tbl_prm.cd_prm; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_prm.cd_prm IS 'CODIGO DO PARAMETRO';


--
-- TOC entry 2423 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN tbl_prm.nm_prm; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_prm.nm_prm IS 'NOME DO PARAMETRO';


--
-- TOC entry 2424 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN tbl_prm.vl_prm; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_prm.vl_prm IS 'VALOR DO PARAMETRO';


--
-- TOC entry 2425 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN tbl_prm.ds_prm; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_prm.ds_prm IS 'DESCRICAO DO PARAMETRO';


--
-- TOC entry 2426 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN tbl_prm.fg_edt_prm; Type: COMMENT; Schema: sc_grl; Owner: postgres
--

COMMENT ON COLUMN sc_grl.tbl_prm.fg_edt_prm IS 'FLAG DE EDITAVEL DO PARAMETRO';


--
-- TOC entry 201 (class 1259 OID 132957)
-- Name: sq_grp; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_grp
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_grp OWNER TO spg;

--
-- TOC entry 202 (class 1259 OID 132959)
-- Name: sq_grp_rol; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_grp_rol
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_grp_rol OWNER TO spg;

--
-- TOC entry 203 (class 1259 OID 132961)
-- Name: sq_menu; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_menu
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_menu OWNER TO spg;

--
-- TOC entry 204 (class 1259 OID 132963)
-- Name: sq_rol; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_rol
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_rol OWNER TO spg;

--
-- TOC entry 205 (class 1259 OID 132965)
-- Name: sq_rol_sis; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_rol_sis
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_rol_sis OWNER TO spg;

--
-- TOC entry 206 (class 1259 OID 132967)
-- Name: sq_sis; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_sis
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_sis OWNER TO spg;

--
-- TOC entry 207 (class 1259 OID 132969)
-- Name: sq_usr; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_usr
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_usr OWNER TO spg;

--
-- TOC entry 208 (class 1259 OID 132971)
-- Name: sq_usr_grp; Type: SEQUENCE; Schema: sc_sgr; Owner: postgres
--

CREATE SEQUENCE sc_sgr.sq_usr_grp
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_sgr.sq_usr_grp OWNER TO spg;

--
-- TOC entry 209 (class 1259 OID 132973)
-- Name: tbl_grp; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_grp (
    cd_grp numeric(10,0) NOT NULL,
    ds_grp character varying(100) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    cd_sis numeric(10,0) NOT NULL,
    fg_atv_grp boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_grp OWNER TO spg;

--
-- TOC entry 2427 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE tbl_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_grp IS 'GRUPO';


--
-- TOC entry 2428 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.cd_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.cd_grp IS 'CODIGO';


--
-- TOC entry 2429 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.ds_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.ds_grp IS 'DESCRICAO';


--
-- TOC entry 2430 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2431 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2432 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2433 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 2434 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.cd_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.cd_sis IS 'sistema';


--
-- TOC entry 2435 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN tbl_grp.fg_atv_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp.fg_atv_grp IS 'flag de ativo';


--
-- TOC entry 210 (class 1259 OID 132977)
-- Name: tbl_grp_rol; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_grp_rol (
    cd_grp_rol numeric(10,0) NOT NULL,
    cd_grp numeric(10,0) NOT NULL,
    cd_rol numeric(10,0) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    fg_atv_grp_rol boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_grp_rol OWNER TO spg;

--
-- TOC entry 2436 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE tbl_grp_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_grp_rol IS 'GRUPO ROLES';


--
-- TOC entry 2437 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.cd_grp_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.cd_grp_rol IS 'codigo';


--
-- TOC entry 2438 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.cd_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.cd_grp IS 'GRUPO';


--
-- TOC entry 2439 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.cd_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.cd_rol IS 'ROLE';


--
-- TOC entry 2440 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2441 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2442 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2443 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 2444 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN tbl_grp_rol.fg_atv_grp_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_grp_rol.fg_atv_grp_rol IS 'flag de ativo';


--
-- TOC entry 211 (class 1259 OID 132981)
-- Name: tbl_menu; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_menu (
    cd_menu numeric(10,0) NOT NULL,
    cd_sis numeric(10,0) NOT NULL,
    cd_rol numeric(10,0),
    cd_pai_menu numeric(10,0),
    fg_flh_menu character varying(1) NOT NULL,
    nvl_menu numeric(2,0) NOT NULL,
    dsc_menu character varying(100) NOT NULL,
    act_menu character varying(100),
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    img_menu character varying(50),
    nr_ord_imp_menu numeric(5,0) NOT NULL,
    fg_atv_menu boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_menu OWNER TO spg;

--
-- TOC entry 2445 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE tbl_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_menu IS 'MENU';


--
-- TOC entry 2446 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.cd_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.cd_menu IS 'CODIGO';


--
-- TOC entry 2447 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.cd_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.cd_sis IS 'SISTEMA';


--
-- TOC entry 2448 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.cd_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.cd_rol IS 'ACESSO';


--
-- TOC entry 2449 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.cd_pai_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.cd_pai_menu IS 'MENU PAI';


--
-- TOC entry 2450 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.fg_flh_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.fg_flh_menu IS 'FLAG FOLHA';


--
-- TOC entry 2451 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.nvl_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.nvl_menu IS 'NIVEL';


--
-- TOC entry 2452 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.dsc_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.dsc_menu IS 'DESCRICAO';


--
-- TOC entry 2453 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.act_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.act_menu IS 'ACTION';


--
-- TOC entry 2454 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2455 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2456 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2457 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 2458 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.img_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.img_menu IS 'IMAGEM DO MENU';


--
-- TOC entry 2459 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.nr_ord_imp_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.nr_ord_imp_menu IS 'ORDEM DE IMPRESSÃO NA TELA';


--
-- TOC entry 2460 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN tbl_menu.fg_atv_menu; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_menu.fg_atv_menu IS 'flag de ativo';


--
-- TOC entry 212 (class 1259 OID 132984)
-- Name: tbl_rol; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_rol (
    cd_rol numeric(10,0) NOT NULL,
    nm_rol character varying(100) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    nm_pth_rol character varying(255) NOT NULL,
    fg_atv_rol boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_rol OWNER TO spg;

--
-- TOC entry 2461 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE tbl_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_rol IS 'role';


--
-- TOC entry 2462 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.cd_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.cd_rol IS 'codigo';


--
-- TOC entry 2463 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.nm_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.nm_rol IS 'nome';


--
-- TOC entry 2464 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2465 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2466 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2467 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 2468 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.nm_pth_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.nm_pth_rol IS 'nome do path da role';


--
-- TOC entry 2469 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tbl_rol.fg_atv_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol.fg_atv_rol IS 'flag de ativo';


--
-- TOC entry 213 (class 1259 OID 132988)
-- Name: tbl_rol_sis; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_rol_sis (
    cd_rol_sis numeric(10,0) NOT NULL,
    cd_rol numeric(10,0) NOT NULL,
    cd_sis numeric(10,0) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    fg_atv_rol_sis boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_rol_sis OWNER TO spg;

--
-- TOC entry 2470 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE tbl_rol_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_rol_sis IS 'TABELA ROLE SISTEMA';


--
-- TOC entry 2471 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.cd_rol_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.cd_rol_sis IS 'CODIGO';


--
-- TOC entry 2472 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.cd_rol; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.cd_rol IS 'ROLE';


--
-- TOC entry 2473 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.cd_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.cd_sis IS 'SISTEMA';


--
-- TOC entry 2474 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2475 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2476 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2477 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 2478 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN tbl_rol_sis.fg_atv_rol_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_rol_sis.fg_atv_rol_sis IS 'flag de ativo';


--
-- TOC entry 214 (class 1259 OID 132991)
-- Name: tbl_sis; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_sis (
    cd_sis numeric(10,0) NOT NULL,
    nm_sis character varying(50) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    fg_atv_sis boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_sis OWNER TO spg;

--
-- TOC entry 2479 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE tbl_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_sis IS 'SISTEMA';


--
-- TOC entry 2480 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tbl_sis.cd_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_sis.cd_sis IS 'CODIGO';


--
-- TOC entry 2481 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tbl_sis.nm_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_sis.nm_sis IS 'NOME';


--
-- TOC entry 2482 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tbl_sis.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_sis.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2483 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tbl_sis.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_sis.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2484 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tbl_sis.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_sis.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2485 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tbl_sis.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_sis.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 2486 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tbl_sis.fg_atv_sis; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_sis.fg_atv_sis IS 'flag de ativo';


--
-- TOC entry 215 (class 1259 OID 132994)
-- Name: tbl_usr; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_usr (
    cd_usr numeric(10,0) NOT NULL,
    nm_usr character varying(80) NOT NULL,
    lgn_usr character varying(20),
    snh_usr character varying(50) NOT NULL,
    cd_cun numeric(10,0),
    st_usr numeric(3,0) DEFAULT 1 NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    fg_adm_usr boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_usr OWNER TO spg;

--
-- TOC entry 2487 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE tbl_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_usr IS 'tabela de usuarios';


--
-- TOC entry 2488 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.cd_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.cd_usr IS 'codigo';


--
-- TOC entry 2489 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.nm_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.nm_usr IS 'nome';


--
-- TOC entry 2490 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.lgn_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.lgn_usr IS 'login';


--
-- TOC entry 2491 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.snh_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.snh_usr IS 'senha';


--
-- TOC entry 2492 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.cd_cun; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.cd_cun IS 'cadastro unico';


--
-- TOC entry 2493 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.st_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.st_usr IS 'situacao (ver tabela de dominio)';


--
-- TOC entry 2494 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.cd_inc_usr IS 'usuario de inclusao';


--
-- TOC entry 2495 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.dt_inc_usr IS 'data de inclusao';


--
-- TOC entry 2496 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.cd_alt_usr IS 'usuario que realizou a ultima alteracao';


--
-- TOC entry 2497 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN tbl_usr.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr.dt_alt_usr IS 'data da ultima alteracao';


--
-- TOC entry 216 (class 1259 OID 132998)
-- Name: tbl_usr_grp; Type: TABLE; Schema: sc_sgr; Owner: postgres
--

CREATE TABLE sc_sgr.tbl_usr_grp (
    cd_usr_grp numeric(10,0) NOT NULL,
    cd_usr numeric(10,0) NOT NULL,
    cd_grp numeric(10,0) NOT NULL,
    cd_inc_usr numeric(10,0) NOT NULL,
    dt_inc_usr timestamp(6) without time zone NOT NULL,
    cd_alt_usr numeric(10,0),
    dt_alt_usr timestamp(6) without time zone,
    fg_atv_usr_grp boolean NOT NULL
);


ALTER TABLE sc_sgr.tbl_usr_grp OWNER TO spg;

--
-- TOC entry 2498 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE tbl_usr_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON TABLE sc_sgr.tbl_usr_grp IS 'USUARIO GRUPO';


--
-- TOC entry 2499 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.cd_usr_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.cd_usr_grp IS 'codigo';


--
-- TOC entry 2500 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.cd_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.cd_usr IS 'USUARIO';


--
-- TOC entry 2501 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.cd_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.cd_grp IS 'GRUPO';


--
-- TOC entry 2502 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.cd_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.cd_inc_usr IS 'USUARIO INCLUSAO';


--
-- TOC entry 2503 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.dt_inc_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.dt_inc_usr IS 'DATA INCLUSAO';


--
-- TOC entry 2504 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.cd_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.cd_alt_usr IS 'USUARIO ALTERACAO';


--
-- TOC entry 2505 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.dt_alt_usr; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.dt_alt_usr IS 'DATA ALTERACAO';


--
-- TOC entry 2506 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tbl_usr_grp.fg_atv_usr_grp; Type: COMMENT; Schema: sc_sgr; Owner: postgres
--

COMMENT ON COLUMN sc_sgr.tbl_usr_grp.fg_atv_usr_grp IS 'flag de ativo';

--
-- TOC entry 2507 (class 0 OID 0)
-- Dependencies: 185
-- Name: sq_ctt; Type: SEQUENCE SET; Schema: sc_cuc; Owner: postgres
--

SELECT pg_catalog.setval('sc_cuc.sq_ctt', 1, false);


--
-- TOC entry 2508 (class 0 OID 0)
-- Dependencies: 186
-- Name: sq_cun; Type: SEQUENCE SET; Schema: sc_cuc; Owner: postgres
--

SELECT pg_catalog.setval('sc_cuc.sq_cun', 1, true);


--
-- TOC entry 2509 (class 0 OID 0)
-- Dependencies: 187
-- Name: sq_edr; Type: SEQUENCE SET; Schema: sc_cuc; Owner: postgres
--

SELECT pg_catalog.setval('sc_cuc.sq_edr', 1, false);


--
-- TOC entry 2510 (class 0 OID 0)
-- Dependencies: 188
-- Name: sq_tlf; Type: SEQUENCE SET; Schema: sc_cuc; Owner: postgres
--

SELECT pg_catalog.setval('sc_cuc.sq_tlf', 1, false);


--
-- TOC entry 2299 (class 0 OID 132911)
-- Dependencies: 189
-- Data for Name: tbl_cpf; Type: TABLE DATA; Schema: sc_cuc; Owner: postgres
--

COPY sc_cuc.tbl_cpf (cd_cun, nr_rg_cpf, nm_mae_cpf, dt_nsc_cpf, sexo_cpf) FROM stdin;
1	\N	\N	1988-07-14	M
\.


--
-- TOC entry 2300 (class 0 OID 132914)
-- Dependencies: 190
-- Data for Name: tbl_cpj; Type: TABLE DATA; Schema: sc_cuc; Owner: postgres
--

COPY sc_cuc.tbl_cpj (cd_cun, nm_fts_cpj, nr_ins_edl_cpj, dt_reg_cpj) FROM stdin;
\.


--
-- TOC entry 2301 (class 0 OID 132917)
-- Dependencies: 191
-- Data for Name: tbl_ctt; Type: TABLE DATA; Schema: sc_cuc; Owner: postgres
--

COPY sc_cuc.tbl_ctt (cd_ctt, cd_cun, cd_crg, nm_ctt, dt_nsc_ctt, eml_ctt, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, tp_ctt, fg_atv_ctt) FROM stdin;
\.


--
-- TOC entry 2302 (class 0 OID 132923)
-- Dependencies: 192
-- Data for Name: tbl_cun; Type: TABLE DATA; Schema: sc_cuc; Owner: postgres
--

COPY sc_cuc.tbl_cun (cd_cun, nm_cun, eml_cun, nr_cpf_cnpj_cun, tp_pss_cun, cd_inc_usr, cd_alt_usr, dt_inc_usr, dt_alt_usr, ft_cun) FROM stdin;
1	Carlos Diego de Lima Chaves	cdiego.lima@gmail.com	2346024309	F	\N	\N	2020-10-03 17:28:24.637593	\N	\N
\.


--
-- TOC entry 2303 (class 0 OID 132929)
-- Dependencies: 193
-- Data for Name: tbl_edr; Type: TABLE DATA; Schema: sc_cuc; Owner: postgres
--

COPY sc_cuc.tbl_edr (cd_edr, nsu_org_edr, cep_edr, nr_edr, cpl_edr, cd_inc_usr, cd_alt_usr, dt_inc_usr, dt_alt_usr, tp_edr, pt_ref_edr, tp_org_edr, fg_atv_edr) FROM stdin;
\.


--
-- TOC entry 2304 (class 0 OID 132932)
-- Dependencies: 194
-- Data for Name: tbl_eex; Type: TABLE DATA; Schema: sc_cuc; Owner: postgres
--

COPY sc_cuc.tbl_eex (cd_edr, nm_log_eex, nm_brr_eex, nm_loc_eex, uf_eex) FROM stdin;
\.


--
-- TOC entry 2305 (class 0 OID 132935)
-- Dependencies: 195
-- Data for Name: tbl_tlf; Type: TABLE DATA; Schema: sc_cuc; Owner: postgres
--

COPY sc_cuc.tbl_tlf (cd_tlf, nr_ddd_tlf, nr_tlf, tp_tlf, tp_org_tlf, nsu_org_tlf, cd_inc_usr, cd_alt_usr, dt_inc_usr, dt_alt_usr, fg_wap, fg_prp_tlf, fg_atv_tlf) FROM stdin;
\.


--
-- TOC entry 2511 (class 0 OID 0)
-- Dependencies: 196
-- Name: sq_dmn; Type: SEQUENCE SET; Schema: sc_grl; Owner: postgres
--

SELECT pg_catalog.setval('sc_grl.sq_dmn', 114, true);


--
-- TOC entry 2512 (class 0 OID 0)
-- Dependencies: 197
-- Name: sq_prm; Type: SEQUENCE SET; Schema: sc_grl; Owner: postgres
--

SELECT pg_catalog.setval('sc_grl.sq_prm', 12, true);


--
-- TOC entry 2308 (class 0 OID 132943)
-- Dependencies: 198
-- Data for Name: tbl_dmn; Type: TABLE DATA; Schema: sc_grl; Owner: postgres
--

COPY sc_grl.tbl_dmn (cd_dmn, vl_cmp_dmn, nm_vlr_dmn, nm_cmp_dmn) FROM stdin;
3	3	COMERCIAL	TP_EDR
4	4	CORRESPONDÊNCIA	TP_EDR
9	1	RESPONSÁVEL PELA EMPRESA	TP_CTT
10	2	CONTATO COM O EMPREGADOR	TP_CTT
11	3	RESPONSÁVEL JUNTO A postgres	TP_CTT
13	1	RESIDÊNCIA	TP_TLF
14	2	CELULAR	TP_TLF
15	3	COMERCIAL	TP_TLF
1	1	RESIDÊNCIA	TP_EDR
21	1	SOLTEIRO	CD_EST_CIVIL_CPF
22	2	CASADO	CD_EST_CIVIL_CPF
23	3	VIUVO	CD_EST_CIVIL_CPF
24	4	DIVORCIADO	CD_EST_CIVIL_CPF
111	1	ATIVO	ST_USR
112	2	INATIVO	ST_USR
113	3	BLOQUEADO	ST_USR
\.


--
-- TOC entry 2309 (class 0 OID 132946)
-- Dependencies: 199
-- Data for Name: tbl_frd; Type: TABLE DATA; Schema: sc_grl; Owner: postgres
--

COPY sc_grl.tbl_frd (dt_frd, ds_frd, tp_frd, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr) FROM stdin;
2058-02-25	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2021-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2019-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2019-03-04	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2019-03-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2019-04-19	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2019-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2019-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2019-06-20	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2019-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2019-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2019-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2019-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2019-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2020-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2020-02-24	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2020-02-25	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2020-04-10	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2020-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2020-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2020-06-11	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2020-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2020-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2020-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2020-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2020-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2021-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2021-02-15	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2021-02-16	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2021-04-02	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2021-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2021-06-03	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2021-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2021-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2021-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2021-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2021-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2022-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2022-02-28	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2022-03-01	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2022-04-15	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2022-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2022-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2022-06-16	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2022-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2022-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2022-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2022-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2022-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2023-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2023-02-20	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2023-02-21	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2023-04-07	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2023-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2023-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2023-06-08	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2023-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2023-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2023-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2023-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2023-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2024-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2024-02-12	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2024-02-13	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2024-03-29	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2024-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2024-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2024-05-30	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2024-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2024-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2024-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2024-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2024-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2025-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2025-03-03	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2025-03-04	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2025-04-18	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2025-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2025-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2025-06-19	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2025-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2025-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2025-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2025-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2025-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2026-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2026-02-16	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2026-02-17	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2026-04-03	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2026-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2026-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2026-06-04	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2026-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2026-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2026-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2026-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2026-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2027-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2027-02-08	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2027-02-09	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2027-03-26	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2027-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2027-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2027-05-27	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2027-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2027-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2027-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2027-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2027-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2028-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2028-02-28	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2028-02-29	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2028-04-14	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2028-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2028-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2028-06-15	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2028-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2028-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2028-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2028-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2028-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2029-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2029-02-12	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2029-02-13	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2029-03-30	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2029-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2029-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2029-05-31	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2029-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2029-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2029-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2029-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2029-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2030-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2030-03-04	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2030-03-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2030-04-19	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2030-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2030-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2030-06-20	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2030-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2030-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2030-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2030-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2030-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2031-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2031-02-24	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2031-02-25	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2031-04-11	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2031-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2031-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2031-06-12	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2031-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2031-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2031-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2031-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2031-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2032-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2032-02-09	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2032-02-10	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2032-03-26	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2032-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2032-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2032-05-27	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2032-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2032-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2032-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2032-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2032-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2033-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2033-02-28	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2033-03-01	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2033-04-15	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2033-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2033-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2033-06-16	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2033-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2033-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2033-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2033-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2033-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2034-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2034-02-20	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2034-02-21	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2034-04-07	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2034-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2034-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2034-06-08	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2034-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2034-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2034-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2034-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2034-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2035-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2035-02-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2035-02-06	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2035-03-23	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2035-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2035-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2035-05-24	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2035-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2035-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2035-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2035-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2035-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2036-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2036-02-25	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2036-02-26	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2036-04-11	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2036-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2036-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2036-06-12	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2036-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2036-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2036-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2036-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2036-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2037-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2037-02-16	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2037-02-17	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2037-04-03	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2037-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2037-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2037-06-04	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2037-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2037-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2037-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2037-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2037-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2038-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2038-03-08	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2038-03-09	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2038-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2038-04-23	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2038-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2038-06-24	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2038-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2058-06-13	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2038-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2038-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2038-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2038-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2039-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2039-02-21	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2039-02-22	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2039-04-08	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2039-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2039-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2039-06-09	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2039-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2039-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2039-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2039-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2039-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2040-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2040-02-13	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2040-02-14	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2040-03-30	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2040-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2040-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2040-05-31	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2040-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2040-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2040-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2040-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2040-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2041-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2041-03-04	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2041-03-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2041-04-19	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2041-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2041-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2041-06-20	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2041-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2041-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2041-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2041-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2041-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2042-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2042-02-17	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2042-02-18	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2042-04-04	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2042-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2042-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2042-06-05	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2042-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2042-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2042-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2042-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2042-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2043-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2043-02-09	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2043-02-10	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2043-03-27	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2043-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2043-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2043-05-28	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2043-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2043-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2043-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2043-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2043-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2044-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2044-02-29	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2044-03-01	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2044-04-15	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2044-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2044-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2044-06-16	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2044-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2044-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2044-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2044-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2044-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2045-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2045-02-20	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2045-02-21	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2045-04-07	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2045-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2045-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2045-06-08	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2045-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2045-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2045-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2045-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2045-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2046-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2046-02-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2046-02-06	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2046-03-23	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2046-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2046-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2046-05-24	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2046-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2046-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2046-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2046-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2046-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2047-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2047-02-25	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2047-02-26	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2047-04-12	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2047-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2047-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2047-06-13	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2047-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2047-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2047-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2047-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2047-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2048-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2048-02-17	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2048-02-18	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2048-04-03	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2048-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2048-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2048-06-04	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2048-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2048-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2048-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2048-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2048-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2049-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2049-03-01	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2049-03-02	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2049-04-16	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2049-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2049-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2049-06-17	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2049-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2049-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2049-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2049-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2049-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2050-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2050-02-21	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2050-02-22	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2050-04-08	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2050-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2050-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2050-06-09	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2050-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2050-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2050-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2050-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2050-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2051-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2051-02-13	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2051-02-14	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2051-03-31	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2051-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2051-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2051-06-01	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2051-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2051-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2051-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2051-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2051-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2052-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2052-03-04	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2052-03-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2052-04-19	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2052-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2052-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2052-06-20	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2052-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2052-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2052-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2052-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2052-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2053-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2053-02-17	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2053-02-18	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2053-04-04	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2053-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2053-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2053-06-05	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2053-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2053-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2053-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2053-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2053-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2054-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2054-02-09	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2054-02-10	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2054-03-27	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2054-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2054-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2054-05-28	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2054-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2054-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2054-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2054-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2054-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2055-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2055-03-01	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2055-03-02	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2055-04-16	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2055-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2055-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2055-06-17	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2055-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2055-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2055-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2055-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2055-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2056-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2056-02-14	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2056-02-15	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2056-03-31	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2056-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2056-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2056-06-01	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2056-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2056-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2056-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2056-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2056-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2057-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2057-03-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2057-03-06	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2057-04-20	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2057-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2057-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2057-06-21	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2057-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2057-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2057-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2057-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2057-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2058-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2058-02-26	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2058-04-12	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2058-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2058-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2058-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2058-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2058-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2058-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2058-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2059-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2059-02-10	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2059-02-11	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2059-03-28	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2059-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2059-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2059-05-29	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2059-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2059-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2059-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2059-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2059-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2060-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2060-03-01	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2060-03-02	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2060-04-16	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2060-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2060-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2060-06-17	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2060-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2060-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2060-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2060-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2060-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2061-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2061-02-21	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2061-02-22	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2061-04-08	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2061-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2061-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2061-06-09	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2061-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2061-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2061-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2061-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2061-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2062-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2062-02-06	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2062-02-07	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2062-03-24	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2062-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2062-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2062-05-25	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2062-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2062-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2062-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2062-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2062-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2063-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2063-02-26	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2063-02-27	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2063-04-13	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2063-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2063-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2063-06-14	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2063-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2063-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2063-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2063-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2063-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2064-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2064-02-18	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2064-02-19	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2064-04-04	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2064-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2064-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2064-06-05	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2064-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2064-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2064-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2064-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2064-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2065-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2065-02-09	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2065-02-10	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2065-03-27	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2065-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2065-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2065-05-28	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2065-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2065-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2065-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2065-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2065-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2066-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2066-02-22	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2066-02-23	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2066-04-09	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2066-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2066-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2066-06-10	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2066-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2066-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2066-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2066-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2066-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2067-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2067-02-14	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2067-02-15	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2067-04-01	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2067-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2067-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2067-06-02	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2067-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2067-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2067-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2067-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2067-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2068-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2068-03-05	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2068-03-06	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2068-04-20	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2068-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2068-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2068-06-21	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2068-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2068-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2068-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2068-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2068-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2069-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2069-02-25	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2069-02-26	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2069-04-12	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2069-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2069-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2069-06-13	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2069-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2069-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2069-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2069-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2069-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2070-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2070-02-10	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2070-02-11	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2070-03-28	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2070-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2070-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2070-05-29	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2070-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2070-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2070-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2070-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2070-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2071-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2071-03-02	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2071-03-03	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2071-04-17	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2071-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2071-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2071-06-18	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2071-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2071-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2071-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2071-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2071-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2072-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2072-02-22	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2072-02-23	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2072-04-08	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2072-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2072-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2072-06-09	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2072-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2072-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2072-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2072-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2072-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2073-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2073-02-06	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2073-02-07	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2073-03-24	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2073-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2073-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2073-05-25	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2073-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2073-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2073-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2073-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2073-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2074-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2074-02-26	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2074-02-27	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2074-04-13	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2074-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2074-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2074-06-14	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2074-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2074-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2074-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2074-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2074-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2075-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2075-02-18	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2075-02-19	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2075-04-05	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2075-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2075-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2075-06-06	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2075-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2075-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2075-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2075-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2075-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2076-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2076-03-02	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2076-03-03	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2076-04-17	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2076-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2076-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2076-06-18	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2076-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2076-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2076-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2076-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2076-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2077-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2077-02-22	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2077-02-23	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2077-04-09	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2077-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2077-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2077-06-10	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2077-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2077-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2077-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2077-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2077-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2078-01-01	CONFRATERNIZAÇÃO UNIVERSAL	F	1	2018-08-02 11:23:39.221	\N	\N
2078-02-14	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2078-02-15	CARNAVAL	F	1	2018-08-02 11:23:39.221	\N	\N
2078-04-01	PAIXÃO DE CRISTO	F	1	2018-08-02 11:23:39.221	\N	\N
2078-04-21	TIRADENTES	F	1	2018-08-02 11:23:39.221	\N	\N
2078-05-01	DIA DO TRABALHO	F	1	2018-08-02 11:23:39.221	\N	\N
2078-06-02	CORPUS CHRISTI	F	1	2018-08-02 11:23:39.221	\N	\N
2078-09-07	INDEPENDÊNCIA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2078-10-12	NOSSA SR.A APARECIDA - PADROEIRA DO BRASIL	F	1	2018-08-02 11:23:39.221	\N	\N
2078-11-02	FINADOS	F	1	2018-08-02 11:23:39.221	\N	\N
2078-11-15	PROCLAMAÇÃO DA REPÚBLICA	F	1	2018-08-02 11:23:39.221	\N	\N
2078-12-25	NATAL	F	1	2018-08-02 11:23:39.221	\N	\N
2019-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2020-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2021-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2022-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2023-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2024-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2025-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2026-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2027-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2028-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2029-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2030-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2031-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2032-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2033-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2034-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2035-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2036-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2037-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2038-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2039-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2040-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2041-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2042-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2043-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2044-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2045-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2046-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2047-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2048-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2049-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2050-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2051-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2052-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2053-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2054-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2055-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2056-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2057-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2058-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2059-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2060-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2061-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2062-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2063-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2064-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2065-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2066-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2067-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2068-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2069-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2070-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2071-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2072-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2073-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2074-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2075-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2076-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2077-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
2078-12-31	SEM EXPEDIENTE BANCARIO	F	1	2018-08-02 11:23:39.221	\N	\N
\.


--
-- TOC entry 2310 (class 0 OID 132949)
-- Dependencies: 200
-- Data for Name: tbl_prm; Type: TABLE DATA; Schema: sc_grl; Owner: postgres
--

COPY sc_grl.tbl_prm (cd_prm, nm_prm, vl_prm, ds_prm, fg_edt_prm) FROM stdin;
\.


--
-- TOC entry 2513 (class 0 OID 0)
-- Dependencies: 201
-- Name: sq_grp; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_grp', 2, true);


--
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 202
-- Name: sq_grp_rol; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_grp_rol', 1, false);


--
-- TOC entry 2515 (class 0 OID 0)
-- Dependencies: 203
-- Name: sq_menu; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_menu', 1, false);


--
-- TOC entry 2516 (class 0 OID 0)
-- Dependencies: 204
-- Name: sq_rol; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_rol', 2, true);


--
-- TOC entry 2517 (class 0 OID 0)
-- Dependencies: 205
-- Name: sq_rol_sis; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_rol_sis', 1, false);


--
-- TOC entry 2518 (class 0 OID 0)
-- Dependencies: 206
-- Name: sq_sis; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_sis', 1, false);


--
-- TOC entry 2519 (class 0 OID 0)
-- Dependencies: 207
-- Name: sq_usr; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_usr', 1, true);


--
-- TOC entry 2520 (class 0 OID 0)
-- Dependencies: 208
-- Name: sq_usr_grp; Type: SEQUENCE SET; Schema: sc_sgr; Owner: postgres
--

SELECT pg_catalog.setval('sc_sgr.sq_usr_grp', 1, false);


--
-- TOC entry 2319 (class 0 OID 132973)
-- Dependencies: 209
-- Data for Name: tbl_grp; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_grp (cd_grp, ds_grp, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, cd_sis, fg_atv_grp) FROM stdin;
\.


--
-- TOC entry 2320 (class 0 OID 132977)
-- Dependencies: 210
-- Data for Name: tbl_grp_rol; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_grp_rol (cd_grp_rol, cd_grp, cd_rol, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, fg_atv_grp_rol) FROM stdin;
\.


--
-- TOC entry 2321 (class 0 OID 132981)
-- Dependencies: 211
-- Data for Name: tbl_menu; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_menu (cd_menu, cd_sis, cd_rol, cd_pai_menu, fg_flh_menu, nvl_menu, dsc_menu, act_menu, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, img_menu, nr_ord_imp_menu, fg_atv_menu) FROM stdin;
\.


--
-- TOC entry 2322 (class 0 OID 132984)
-- Dependencies: 212
-- Data for Name: tbl_rol; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_rol (cd_rol, nm_rol, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, nm_pth_rol, fg_atv_rol) FROM stdin;
\.


--
-- TOC entry 2323 (class 0 OID 132988)
-- Dependencies: 213
-- Data for Name: tbl_rol_sis; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_rol_sis (cd_rol_sis, cd_rol, cd_sis, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, fg_atv_rol_sis) FROM stdin;
\.


--
-- TOC entry 2324 (class 0 OID 132991)
-- Dependencies: 214
-- Data for Name: tbl_sis; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_sis (cd_sis, nm_sis, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, fg_atv_sis) FROM stdin;
\.


--
-- TOC entry 2325 (class 0 OID 132994)
-- Dependencies: 215
-- Data for Name: tbl_usr; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_usr (cd_usr, nm_usr, lgn_usr, snh_usr, cd_cun, st_usr, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, fg_adm_usr) FROM stdin;
1	Carlos Diego de Lima Chaves	diego	202cb962ac59075b964b07152d234b70	1	1	1	2020-10-03 17:35:04.801959	\N	\N	t
\.


--
-- TOC entry 2326 (class 0 OID 132998)
-- Dependencies: 216
-- Data for Name: tbl_usr_grp; Type: TABLE DATA; Schema: sc_sgr; Owner: postgres
--

COPY sc_sgr.tbl_usr_grp (cd_usr_grp, cd_usr, cd_grp, cd_inc_usr, dt_inc_usr, cd_alt_usr, dt_alt_usr, fg_atv_usr_grp) FROM stdin;
\.

--
-- TOC entry 2103 (class 2606 OID 133003)
-- Name: pk_cpf; Type: CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_cpf
    ADD CONSTRAINT pk_cpf PRIMARY KEY (cd_cun);


--
-- TOC entry 2105 (class 2606 OID 133005)
-- Name: pk_cpj; Type: CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_cpj
    ADD CONSTRAINT pk_cpj PRIMARY KEY (cd_cun);


--
-- TOC entry 2107 (class 2606 OID 133007)
-- Name: pk_ctt; Type: CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_ctt
    ADD CONSTRAINT pk_ctt PRIMARY KEY (cd_ctt);


--
-- TOC entry 2109 (class 2606 OID 133009)
-- Name: pk_cun; Type: CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_cun
    ADD CONSTRAINT pk_cun PRIMARY KEY (cd_cun);


--
-- TOC entry 2111 (class 2606 OID 133011)
-- Name: pk_edr; Type: CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_edr
    ADD CONSTRAINT pk_edr PRIMARY KEY (cd_edr);


--
-- TOC entry 2113 (class 2606 OID 133013)
-- Name: pk_eex; Type: CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_eex
    ADD CONSTRAINT pk_eex PRIMARY KEY (cd_edr);


--
-- TOC entry 2115 (class 2606 OID 133015)
-- Name: pk_tlf; Type: CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_tlf
    ADD CONSTRAINT pk_tlf PRIMARY KEY (cd_tlf);


--
-- TOC entry 2117 (class 2606 OID 133017)
-- Name: pk_dmn; Type: CONSTRAINT; Schema: sc_grl; Owner: postgres
--

ALTER TABLE ONLY sc_grl.tbl_dmn
    ADD CONSTRAINT pk_dmn PRIMARY KEY (cd_dmn);


--
-- TOC entry 2121 (class 2606 OID 133019)
-- Name: pk_frd; Type: CONSTRAINT; Schema: sc_grl; Owner: postgres
--

ALTER TABLE ONLY sc_grl.tbl_frd
    ADD CONSTRAINT pk_frd PRIMARY KEY (dt_frd);


--
-- TOC entry 2123 (class 2606 OID 133021)
-- Name: pk_prm; Type: CONSTRAINT; Schema: sc_grl; Owner: postgres
--

ALTER TABLE ONLY sc_grl.tbl_prm
    ADD CONSTRAINT pk_prm PRIMARY KEY (cd_prm);


--
-- TOC entry 2125 (class 2606 OID 133023)
-- Name: uk_nm_prm; Type: CONSTRAINT; Schema: sc_grl; Owner: postgres
--

ALTER TABLE ONLY sc_grl.tbl_prm
    ADD CONSTRAINT uk_nm_prm UNIQUE (nm_prm);


--
-- TOC entry 2119 (class 2606 OID 133025)
-- Name: uk_vl_cmp_nm_cmp_dmn; Type: CONSTRAINT; Schema: sc_grl; Owner: postgres
--

ALTER TABLE ONLY sc_grl.tbl_dmn
    ADD CONSTRAINT uk_vl_cmp_nm_cmp_dmn UNIQUE (vl_cmp_dmn, nm_cmp_dmn);


--
-- TOC entry 2127 (class 2606 OID 133027)
-- Name: pk_grp; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp
    ADD CONSTRAINT pk_grp PRIMARY KEY (cd_grp);


--
-- TOC entry 2129 (class 2606 OID 133029)
-- Name: pk_grp_rol; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp_rol
    ADD CONSTRAINT pk_grp_rol PRIMARY KEY (cd_grp_rol);


--
-- TOC entry 2131 (class 2606 OID 133031)
-- Name: pk_menu; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_menu
    ADD CONSTRAINT pk_menu PRIMARY KEY (cd_menu);


--
-- TOC entry 2133 (class 2606 OID 133033)
-- Name: pk_rol; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (cd_rol);


--
-- TOC entry 2135 (class 2606 OID 133035)
-- Name: pk_rol_sis; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol_sis
    ADD CONSTRAINT pk_rol_sis PRIMARY KEY (cd_rol_sis);


--
-- TOC entry 2137 (class 2606 OID 133037)
-- Name: pk_sis; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_sis
    ADD CONSTRAINT pk_sis PRIMARY KEY (cd_sis);


--
-- TOC entry 2139 (class 2606 OID 133039)
-- Name: pk_usr; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr
    ADD CONSTRAINT pk_usr PRIMARY KEY (cd_usr);


--
-- TOC entry 2141 (class 2606 OID 133041)
-- Name: pk_usr_grp; Type: CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr_grp
    ADD CONSTRAINT pk_usr_grp PRIMARY KEY (cd_usr_grp);

--
-- TOC entry 2142 (class 2606 OID 133042)
-- Name: fk_cpf_cun; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_cpf
    ADD CONSTRAINT fk_cpf_cun FOREIGN KEY (cd_cun) REFERENCES sc_cuc.tbl_cun(cd_cun);


--
-- TOC entry 2143 (class 2606 OID 133047)
-- Name: fk_cpj_cun; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_cpj
    ADD CONSTRAINT fk_cpj_cun FOREIGN KEY (cd_cun) REFERENCES sc_cuc.tbl_cun(cd_cun);


--
-- TOC entry 2144 (class 2606 OID 133052)
-- Name: fk_ctt_alt_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_ctt
    ADD CONSTRAINT fk_ctt_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2145 (class 2606 OID 133057)
-- Name: fk_ctt_cun; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_ctt
    ADD CONSTRAINT fk_ctt_cun FOREIGN KEY (cd_cun) REFERENCES sc_cuc.tbl_cun(cd_cun);


--
-- TOC entry 2146 (class 2606 OID 133062)
-- Name: fk_ctt_inc_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_ctt
    ADD CONSTRAINT fk_ctt_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2147 (class 2606 OID 133067)
-- Name: fk_cun_alt_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_cun
    ADD CONSTRAINT fk_cun_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2148 (class 2606 OID 133072)
-- Name: fk_cun_inc_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_cun
    ADD CONSTRAINT fk_cun_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2149 (class 2606 OID 133077)
-- Name: fk_edr_alt_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_edr
    ADD CONSTRAINT fk_edr_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2150 (class 2606 OID 133082)
-- Name: fk_edr_inc_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_edr
    ADD CONSTRAINT fk_edr_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2151 (class 2606 OID 133087)
-- Name: fk_eex_edr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_eex
    ADD CONSTRAINT fk_eex_edr FOREIGN KEY (cd_edr) REFERENCES sc_cuc.tbl_edr(cd_edr);


--
-- TOC entry 2152 (class 2606 OID 133092)
-- Name: fk_tlf_alt_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_tlf
    ADD CONSTRAINT fk_tlf_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2153 (class 2606 OID 133097)
-- Name: fk_tlf_inc_usr; Type: FK CONSTRAINT; Schema: sc_cuc; Owner: postgres
--

ALTER TABLE ONLY sc_cuc.tbl_tlf
    ADD CONSTRAINT fk_tlf_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2154 (class 2606 OID 133102)
-- Name: fk_grp_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp
    ADD CONSTRAINT fk_grp_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2155 (class 2606 OID 133107)
-- Name: fk_grp_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp
    ADD CONSTRAINT fk_grp_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2156 (class 2606 OID 133112)
-- Name: fk_grp_rol_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp_rol
    ADD CONSTRAINT fk_grp_rol_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2157 (class 2606 OID 133117)
-- Name: fk_grp_rol_grp; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp_rol
    ADD CONSTRAINT fk_grp_rol_grp FOREIGN KEY (cd_grp) REFERENCES sc_sgr.tbl_grp(cd_grp);


--
-- TOC entry 2158 (class 2606 OID 133122)
-- Name: fk_grp_rol_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp_rol
    ADD CONSTRAINT fk_grp_rol_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2159 (class 2606 OID 133127)
-- Name: fk_grp_rol_rol; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_grp_rol
    ADD CONSTRAINT fk_grp_rol_rol FOREIGN KEY (cd_rol) REFERENCES sc_sgr.tbl_rol(cd_rol);


--
-- TOC entry 2160 (class 2606 OID 133132)
-- Name: fk_menu_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_menu
    ADD CONSTRAINT fk_menu_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2161 (class 2606 OID 133137)
-- Name: fk_menu_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_menu
    ADD CONSTRAINT fk_menu_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2162 (class 2606 OID 133142)
-- Name: fk_menu_pai_menu; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_menu
    ADD CONSTRAINT fk_menu_pai_menu FOREIGN KEY (cd_menu) REFERENCES sc_sgr.tbl_menu(cd_menu);


--
-- TOC entry 2163 (class 2606 OID 133147)
-- Name: fk_menu_rol; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_menu
    ADD CONSTRAINT fk_menu_rol FOREIGN KEY (cd_rol) REFERENCES sc_sgr.tbl_rol(cd_rol);


--
-- TOC entry 2164 (class 2606 OID 133152)
-- Name: fk_menu_sis; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_menu
    ADD CONSTRAINT fk_menu_sis FOREIGN KEY (cd_sis) REFERENCES sc_sgr.tbl_sis(cd_sis);


--
-- TOC entry 2165 (class 2606 OID 133157)
-- Name: fk_rol_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol
    ADD CONSTRAINT fk_rol_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2166 (class 2606 OID 133162)
-- Name: fk_rol_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol
    ADD CONSTRAINT fk_rol_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2167 (class 2606 OID 133167)
-- Name: fk_rol_sis_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol_sis
    ADD CONSTRAINT fk_rol_sis_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2168 (class 2606 OID 133172)
-- Name: fk_rol_sis_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol_sis
    ADD CONSTRAINT fk_rol_sis_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2169 (class 2606 OID 133177)
-- Name: fk_rol_sis_rol; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol_sis
    ADD CONSTRAINT fk_rol_sis_rol FOREIGN KEY (cd_rol) REFERENCES sc_sgr.tbl_rol(cd_rol);


--
-- TOC entry 2170 (class 2606 OID 133182)
-- Name: fk_rol_sis_sis; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_rol_sis
    ADD CONSTRAINT fk_rol_sis_sis FOREIGN KEY (cd_sis) REFERENCES sc_sgr.tbl_sis(cd_sis);


--
-- TOC entry 2171 (class 2606 OID 133187)
-- Name: fk_sis_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_sis
    ADD CONSTRAINT fk_sis_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2172 (class 2606 OID 133192)
-- Name: fk_sis_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_sis
    ADD CONSTRAINT fk_sis_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2173 (class 2606 OID 133197)
-- Name: fk_usr_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr
    ADD CONSTRAINT fk_usr_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2174 (class 2606 OID 133202)
-- Name: fk_usr_cun; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr
    ADD CONSTRAINT fk_usr_cun FOREIGN KEY (cd_cun) REFERENCES sc_cuc.tbl_cun(cd_cun);


--
-- TOC entry 2176 (class 2606 OID 133207)
-- Name: fk_usr_grp_alt_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr_grp
    ADD CONSTRAINT fk_usr_grp_alt_usr FOREIGN KEY (cd_alt_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2177 (class 2606 OID 133212)
-- Name: fk_usr_grp_grp; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr_grp
    ADD CONSTRAINT fk_usr_grp_grp FOREIGN KEY (cd_grp) REFERENCES sc_sgr.tbl_grp(cd_grp);


--
-- TOC entry 2178 (class 2606 OID 133217)
-- Name: fk_usr_grp_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr_grp
    ADD CONSTRAINT fk_usr_grp_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2179 (class 2606 OID 133222)
-- Name: fk_usr_grp_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr_grp
    ADD CONSTRAINT fk_usr_grp_usr FOREIGN KEY (cd_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2175 (class 2606 OID 133227)
-- Name: fk_usr_inc_usr; Type: FK CONSTRAINT; Schema: sc_sgr; Owner: postgres
--

ALTER TABLE ONLY sc_sgr.tbl_usr
    ADD CONSTRAINT fk_usr_inc_usr FOREIGN KEY (cd_inc_usr) REFERENCES sc_sgr.tbl_usr(cd_usr);


--
-- TOC entry 2334 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2020-10-05 21:42:02

--
-- PostgreSQL database dump complete
--






-----------------------------------------------------






--
-- TOC entry 11 (class 2615 OID 17830)
-- Name: sc_cad; Type: SCHEMA; Schema: -; Owner: spg
--

CREATE SCHEMA sc_cad;


ALTER SCHEMA sc_cad OWNER TO spg;

--
-- TOC entry 12 (class 2615 OID 17861)
-- Name: sc_dsp; Type: SCHEMA; Schema: -; Owner: spg
--

CREATE SCHEMA sc_dsp;


ALTER SCHEMA sc_dsp OWNER TO spg;

--
-- TOC entry 249 (class 1255 OID 17918)
-- Name: atualizar_agrupador_mes(numeric); Type: FUNCTION; Schema: sc_dsp; Owner: spg
--

CREATE FUNCTION sc_dsp.atualizar_agrupador_mes(vp_agrupador_mes numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare

	vl_valor_total numeric;

begin

	-- valor total despesas do agm
	select coalesce(sum(d.vl_dsp), 0)
	  into vl_valor_total
      from sc_dsp.tbl_dsp d
	 where d.cd_agm = vp_agrupador_mes
	   and d.fg_atv_dsp = true;

	 -- atualizando valor agm
	 update sc_dsp.tbl_agm
	    set vl_agm = vl_valor_total
	  where cd_agm = vp_agrupador_mes;

end;
$$;


ALTER FUNCTION sc_dsp.atualizar_agrupador_mes(vp_agrupador_mes numeric) OWNER TO spg;

--
-- TOC entry 220 (class 1259 OID 17844)
-- Name: sq_agr; Type: SEQUENCE; Schema: sc_cad; Owner: spg
--

CREATE SEQUENCE sc_cad.sq_agr
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_cad.sq_agr OWNER TO spg;

--
-- TOC entry 222 (class 1259 OID 17859)
-- Name: sq_ctg; Type: SEQUENCE; Schema: sc_cad; Owner: spg
--

CREATE SEQUENCE sc_cad.sq_ctg
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_cad.sq_ctg OWNER TO spg;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 219 (class 1259 OID 17831)
-- Name: tbl_agr; Type: TABLE; Schema: sc_cad; Owner: spg
--

CREATE TABLE sc_cad.tbl_agr (
    cd_agr numeric NOT NULL default nextval('sc_cad.sq_agr'),
    ds_agr character varying(100) NOT NULL,
    cd_cun numeric NOT NULL,
    fg_atv_agr boolean NOT NULL,
    dt_inc_agr timestamp without time zone NOT NULL,
    dt_alt_agr timestamp without time zone
);


ALTER TABLE sc_cad.tbl_agr OWNER TO spg;

--
-- TOC entry 2297 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE tbl_agr; Type: COMMENT; Schema: sc_cad; Owner: spg
--

COMMENT ON TABLE sc_cad.tbl_agr IS 'Tabela de agrupador';


--
-- TOC entry 221 (class 1259 OID 17846)
-- Name: tbl_ctg; Type: TABLE; Schema: sc_cad; Owner: spg
--

CREATE TABLE sc_cad.tbl_ctg (
    cd_ctg numeric NOT NULL,
    ds_ctg character varying(100) NOT NULL,
    cd_cun numeric NOT NULL,
    fg_atv_ctg boolean NOT NULL,
    dt_inc_ctg timestamp without time zone NOT NULL,
    dt_alt_ctg timestamp without time zone
);


ALTER TABLE sc_cad.tbl_ctg OWNER TO spg;

--
-- TOC entry 2298 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE tbl_ctg; Type: COMMENT; Schema: sc_cad; Owner: spg
--

COMMENT ON TABLE sc_cad.tbl_ctg IS 'Tabela de categoria';


--
-- TOC entry 226 (class 1259 OID 17895)
-- Name: sq_agm; Type: SEQUENCE; Schema: sc_dsp; Owner: spg
--

CREATE SEQUENCE sc_dsp.sq_agm
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_dsp.sq_agm OWNER TO spg;

--
-- TOC entry 228 (class 1259 OID 17915)
-- Name: sq_dsp; Type: SEQUENCE; Schema: sc_dsp; Owner: spg
--

CREATE SEQUENCE sc_dsp.sq_dsp
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_dsp.sq_dsp OWNER TO spg;

--
-- TOC entry 224 (class 1259 OID 17875)
-- Name: sq_mes; Type: SEQUENCE; Schema: sc_dsp; Owner: spg
--

CREATE SEQUENCE sc_dsp.sq_mes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sc_dsp.sq_mes OWNER TO spg;

--
-- TOC entry 225 (class 1259 OID 17877)
-- Name: tbl_agm; Type: TABLE; Schema: sc_dsp; Owner: spg
--

CREATE TABLE sc_dsp.tbl_agm (
    cd_agm numeric NOT NULL,
    cd_agr numeric NOT NULL,
    cd_mes numeric NOT NULL,
    vl_agm numeric(10,2),
    fg_atv_agm boolean NOT NULL,
    dt_inc_agm timestamp without time zone NOT NULL,
    dt_alt_agm timestamp without time zone
);


ALTER TABLE sc_dsp.tbl_agm OWNER TO spg;

--
-- TOC entry 2299 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE tbl_agm; Type: COMMENT; Schema: sc_dsp; Owner: spg
--

COMMENT ON TABLE sc_dsp.tbl_agm IS 'Tabela de agrupamento por mes';


--
-- TOC entry 227 (class 1259 OID 17897)
-- Name: tbl_dsp; Type: TABLE; Schema: sc_dsp; Owner: spg
--

CREATE TABLE sc_dsp.tbl_dsp (
    cd_dsp numeric NOT NULL,
    cd_agm numeric NOT NULL,
    cd_ctg numeric NOT NULL,
    ds_dsp character varying(100) NOT NULL,
    vl_dsp numeric(10,2) NOT NULL,
    fg_atv_dsp boolean NOT NULL,
    dt_inc_dsp timestamp without time zone NOT NULL,
    dt_alt_dsp timestamp without time zone
);


ALTER TABLE sc_dsp.tbl_dsp OWNER TO spg;

--
-- TOC entry 2300 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE tbl_dsp; Type: COMMENT; Schema: sc_dsp; Owner: spg
--

COMMENT ON TABLE sc_dsp.tbl_dsp IS 'Tabela de despesa';


--
-- TOC entry 223 (class 1259 OID 17862)
-- Name: tbl_mes; Type: TABLE; Schema: sc_dsp; Owner: spg
--

CREATE TABLE sc_dsp.tbl_mes (
    cd_mes numeric NOT NULL,
    cd_cun numeric NOT NULL,
    nr_mes numeric NOT NULL,
    nr_ano numeric NOT NULL,
    vl_mes numeric(10,2),
    dt_inc_mes timestamp without time zone NOT NULL,
    dt_alt_mes timestamp without time zone,
    vl_ent_mes numeric(10,2),
    vl_met_mes numeric(10,2)
);


ALTER TABLE sc_dsp.tbl_mes OWNER TO spg;

--
-- TOC entry 2301 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE tbl_mes; Type: COMMENT; Schema: sc_dsp; Owner: spg
--

COMMENT ON TABLE sc_dsp.tbl_mes IS 'Tabela de mes por cadastro unico';


--
-- TOC entry 2302 (class 0 OID 0)
-- Dependencies: 220
-- Name: sq_agr; Type: SEQUENCE SET; Schema: sc_cad; Owner: spg
--

SELECT pg_catalog.setval('sc_cad.sq_agr', 0, true);


--
-- TOC entry 2303 (class 0 OID 0)
-- Dependencies: 222
-- Name: sq_ctg; Type: SEQUENCE SET; Schema: sc_cad; Owner: spg
--

SELECT pg_catalog.setval('sc_cad.sq_ctg', 0, true);


--
-- TOC entry 2282 (class 0 OID 17831)
-- Dependencies: 219
-- Data for Name: tbl_agr; Type: TABLE DATA; Schema: sc_cad; Owner: spg
--

COPY sc_cad.tbl_agr (cd_agr, ds_agr, cd_cun, fg_atv_agr, dt_inc_agr, dt_alt_agr) FROM stdin;

\.


--
-- TOC entry 2284 (class 0 OID 17846)
-- Dependencies: 221
-- Data for Name: tbl_ctg; Type: TABLE DATA; Schema: sc_cad; Owner: spg
--

COPY sc_cad.tbl_ctg (cd_ctg, ds_ctg, cd_cun, fg_atv_ctg, dt_inc_ctg, dt_alt_ctg) FROM stdin;
\.


--
-- TOC entry 2304 (class 0 OID 0)
-- Dependencies: 226
-- Name: sq_agm; Type: SEQUENCE SET; Schema: sc_dsp; Owner: spg
--

SELECT pg_catalog.setval('sc_dsp.sq_agm', 0, true);


--
-- TOC entry 2305 (class 0 OID 0)
-- Dependencies: 228
-- Name: sq_dsp; Type: SEQUENCE SET; Schema: sc_dsp; Owner: spg
--

SELECT pg_catalog.setval('sc_dsp.sq_dsp', 0, true);


--
-- TOC entry 2306 (class 0 OID 0)
-- Dependencies: 224
-- Name: sq_mes; Type: SEQUENCE SET; Schema: sc_dsp; Owner: spg
--

SELECT pg_catalog.setval('sc_dsp.sq_mes', 0, true);


--
-- TOC entry 2288 (class 0 OID 17877)
-- Dependencies: 225
-- Data for Name: tbl_agm; Type: TABLE DATA; Schema: sc_dsp; Owner: spg
--

COPY sc_dsp.tbl_agm (cd_agm, cd_agr, cd_mes, vl_agm, fg_atv_agm, dt_inc_agm, dt_alt_agm) FROM stdin;
\.


--
-- TOC entry 2290 (class 0 OID 17897)
-- Dependencies: 227
-- Data for Name: tbl_dsp; Type: TABLE DATA; Schema: sc_dsp; Owner: spg
--

COPY sc_dsp.tbl_dsp (cd_dsp, cd_agm, cd_ctg, ds_dsp, vl_dsp, fg_atv_dsp, dt_inc_dsp, dt_alt_dsp) FROM stdin;
\.


--
-- TOC entry 2286 (class 0 OID 17862)
-- Dependencies: 223
-- Data for Name: tbl_mes; Type: TABLE DATA; Schema: sc_dsp; Owner: spg
--

COPY sc_dsp.tbl_mes (cd_mes, cd_cun, nr_mes, nr_ano, vl_mes, dt_inc_mes, dt_alt_mes, vl_ent_mes, vl_met_mes) FROM stdin;
\.


--
-- TOC entry 2152 (class 2606 OID 17838)
-- Name: pk_agr; Type: CONSTRAINT; Schema: sc_cad; Owner: spg
--

ALTER TABLE ONLY sc_cad.tbl_agr
    ADD CONSTRAINT pk_agr PRIMARY KEY (cd_agr);


--
-- TOC entry 2154 (class 2606 OID 17853)
-- Name: pk_ctg; Type: CONSTRAINT; Schema: sc_cad; Owner: spg
--

ALTER TABLE ONLY sc_cad.tbl_ctg
    ADD CONSTRAINT pk_ctg PRIMARY KEY (cd_ctg);


--
-- TOC entry 2158 (class 2606 OID 17884)
-- Name: pk_agm; Type: CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_agm
    ADD CONSTRAINT pk_agm PRIMARY KEY (cd_agm);


--
-- TOC entry 2160 (class 2606 OID 17904)
-- Name: pk_dsp; Type: CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_dsp
    ADD CONSTRAINT pk_dsp PRIMARY KEY (cd_dsp);


--
-- TOC entry 2156 (class 2606 OID 17869)
-- Name: pk_mes; Type: CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_mes
    ADD CONSTRAINT pk_mes PRIMARY KEY (cd_mes);


--
-- TOC entry 2161 (class 2606 OID 17839)
-- Name: fk_agr_cun; Type: FK CONSTRAINT; Schema: sc_cad; Owner: spg
--

ALTER TABLE ONLY sc_cad.tbl_agr
    ADD CONSTRAINT fk_agr_cun FOREIGN KEY (cd_cun) REFERENCES sc_cuc.tbl_cun(cd_cun);


--
-- TOC entry 2162 (class 2606 OID 17854)
-- Name: fk_ctg_cun; Type: FK CONSTRAINT; Schema: sc_cad; Owner: spg
--

ALTER TABLE ONLY sc_cad.tbl_ctg
    ADD CONSTRAINT fk_ctg_cun FOREIGN KEY (cd_cun) REFERENCES sc_cuc.tbl_cun(cd_cun);


--
-- TOC entry 2164 (class 2606 OID 17885)
-- Name: fk_agm_agr; Type: FK CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_agm
    ADD CONSTRAINT fk_agm_agr FOREIGN KEY (cd_agr) REFERENCES sc_cad.tbl_agr(cd_agr);


--
-- TOC entry 2165 (class 2606 OID 17890)
-- Name: fk_agm_mes; Type: FK CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_agm
    ADD CONSTRAINT fk_agm_mes FOREIGN KEY (cd_mes) REFERENCES sc_dsp.tbl_mes(cd_mes);


--
-- TOC entry 2163 (class 2606 OID 17870)
-- Name: fk_ctg_cun; Type: FK CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_mes
    ADD CONSTRAINT fk_ctg_cun FOREIGN KEY (cd_cun) REFERENCES sc_cuc.tbl_cun(cd_cun);


--
-- TOC entry 2166 (class 2606 OID 17905)
-- Name: fk_dsp_agm; Type: FK CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_dsp
    ADD CONSTRAINT fk_dsp_agm FOREIGN KEY (cd_agm) REFERENCES sc_dsp.tbl_agm(cd_agm);


--
-- TOC entry 2167 (class 2606 OID 17910)
-- Name: fk_dsp_ctg; Type: FK CONSTRAINT; Schema: sc_dsp; Owner: spg
--

ALTER TABLE ONLY sc_dsp.tbl_dsp
    ADD CONSTRAINT fk_dsp_ctg FOREIGN KEY (cd_ctg) REFERENCES sc_cad.tbl_ctg(cd_ctg);


-- Completed on 2021-07-01 16:47:05 -03

--
-- PostgreSQL database dump complete
--

