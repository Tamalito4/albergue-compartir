--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8
-- Dumped by pg_dump version 16.8

-- Started on 2025-12-12 09:36:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 235 (class 1255 OID 17569)
-- Name: log_adopcion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_adopcion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO auditoria_adopcion(usuario, nombre_animal, mensaje)
    VALUES (NEW.usuario, NEW.nombre_animal, 'Solicitud de adopción registrada');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_adopcion() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 17570)
-- Name: registrar_auditoria_adopcion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_auditoria_adopcion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Solo registrar si cambió el estado
  IF NEW.estado IS DISTINCT FROM OLD.estado THEN
    INSERT INTO auditoriaadopcion(usuario, nombre_animal, estado_anterior, estado_nuevo)
    VALUES (NEW.usuario, NEW.nombre_animal, OLD.estado, NEW.estado);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.registrar_auditoria_adopcion() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 17571)
-- Name: registrar_auditoria_donacion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_auditoria_donacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO auditoria_donacion(usuario, metodo_pago, monto, fecha_donacion, mensaje)
  VALUES (NEW.usuario, NEW.metodo_pago, NEW.monto, NEW.fecha, 'Donación registrada');
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.registrar_auditoria_donacion() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 17572)
-- Name: registrar_cambio_contrasena(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_cambio_contrasena() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.contrasena <> OLD.contrasena THEN
        INSERT INTO auditoria_contrasena(usuario, mensaje, contrasena_anterior, fecha_cambio, usuario_id)
        VALUES (OLD.usuario, 'Contraseña cambiada', OLD.contrasena, CURRENT_TIMESTAMP, OLD.id);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.registrar_cambio_contrasena() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 17573)
-- Name: registrar_cambio_estado(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_cambio_estado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.estado IS DISTINCT FROM OLD.estado THEN
    INSERT INTO auditoria_adopcion(adopcion_id, accion)
    VALUES (OLD.id, 'Cambio de estado a ' || NEW.estado);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.registrar_cambio_estado() OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 17574)
-- Name: registrar_cambios(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_cambios() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_animales (animal_id, accion, datos)
        VALUES (NEW.id, 'INSERT', row_to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_animales (animal_id, accion, datos)
        VALUES (NEW.id, 'UPDATE', row_to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_animales (animal_id, accion, datos)
        VALUES (OLD.id, 'DELETE', row_to_json(OLD));
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.registrar_cambios() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 17575)
-- Name: registrar_cambios_usuario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_cambios_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_usuarios (usuario_id, accion, datos)
        VALUES (NEW.id, 'INSERT', row_to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_usuarios (usuario_id, accion, datos)
        VALUES (NEW.id, 'UPDATE', row_to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_usuarios (usuario_id, accion, datos)
        VALUES (OLD.id, 'DELETE', row_to_json(OLD));
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.registrar_cambios_usuario() OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 17576)
-- Name: registrar_devolucion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_devolucion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.estado = 'devuelto' THEN
    INSERT INTO auditoria_adopcion(usuario, nombre_animal, mensaje)
    VALUES (NEW.usuario, NEW.nombre_animal, 'El animal fue devuelto y está disponible nuevamente.');
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.registrar_devolucion() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 17577)
-- Name: adopcion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adopcion (
    id integer NOT NULL,
    usuario text NOT NULL,
    nombre_animal text NOT NULL,
    estado text DEFAULT 'pendiente'::text,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    motivo text
);


ALTER TABLE public.adopcion OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17584)
-- Name: adopcion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adopcion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adopcion_id_seq OWNER TO postgres;

--
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 216
-- Name: adopcion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adopcion_id_seq OWNED BY public.adopcion.id;


--
-- TOC entry 217 (class 1259 OID 17585)
-- Name: animal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.animal (
    id bigint NOT NULL,
    nombre character varying(255) NOT NULL,
    especie character varying(255) NOT NULL,
    raza character varying(255) NOT NULL,
    edad integer NOT NULL
);


ALTER TABLE public.animal OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17590)
-- Name: animal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.animal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animal_id_seq OWNER TO postgres;

--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 218
-- Name: animal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.animal_id_seq OWNED BY public.animal.id;


--
-- TOC entry 219 (class 1259 OID 17591)
-- Name: auditoria_adopcion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_adopcion (
    id integer NOT NULL,
    usuario text,
    nombre_animal text,
    mensaje text,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.auditoria_adopcion OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17597)
-- Name: auditoria_adopcion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoria_adopcion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditoria_adopcion_id_seq OWNER TO postgres;

--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 220
-- Name: auditoria_adopcion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoria_adopcion_id_seq OWNED BY public.auditoria_adopcion.id;


--
-- TOC entry 221 (class 1259 OID 17598)
-- Name: auditoria_animales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_animales (
    id integer NOT NULL,
    animal_id integer NOT NULL,
    accion text NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datos jsonb
);


ALTER TABLE public.auditoria_animales OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17604)
-- Name: auditoria_animales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoria_animales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditoria_animales_id_seq OWNER TO postgres;

--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 222
-- Name: auditoria_animales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoria_animales_id_seq OWNED BY public.auditoria_animales.id;


--
-- TOC entry 223 (class 1259 OID 17605)
-- Name: auditoria_contrasena; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_contrasena (
    id bigint NOT NULL,
    usuario text,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    mensaje text,
    contrasena_anterior character varying(255),
    fecha_cambio timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    usuario_id bigint NOT NULL
);


ALTER TABLE public.auditoria_contrasena OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17612)
-- Name: auditoria_contrasena_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoria_contrasena_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditoria_contrasena_id_seq OWNER TO postgres;

--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 224
-- Name: auditoria_contrasena_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoria_contrasena_id_seq OWNED BY public.auditoria_contrasena.id;


--
-- TOC entry 225 (class 1259 OID 17613)
-- Name: auditoria_donacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_donacion (
    id integer NOT NULL,
    usuario text,
    metodo_pago text,
    monto numeric(10,2),
    fecha_donacion timestamp without time zone,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    mensaje text
);


ALTER TABLE public.auditoria_donacion OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17619)
-- Name: auditoria_donacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoria_donacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditoria_donacion_id_seq OWNER TO postgres;

--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 226
-- Name: auditoria_donacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoria_donacion_id_seq OWNED BY public.auditoria_donacion.id;


--
-- TOC entry 227 (class 1259 OID 17620)
-- Name: auditoria_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_usuarios (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    accion text NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datos jsonb
);


ALTER TABLE public.auditoria_usuarios OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17626)
-- Name: auditoria_usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoria_usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditoria_usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 228
-- Name: auditoria_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoria_usuarios_id_seq OWNED BY public.auditoria_usuarios.id;


--
-- TOC entry 229 (class 1259 OID 17627)
-- Name: auditoriaadopcion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoriaadopcion (
    id integer NOT NULL,
    usuario text,
    nombre_animal text,
    estado_anterior text,
    estado_nuevo text,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.auditoriaadopcion OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17633)
-- Name: auditoriaadopcion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoriaadopcion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditoriaadopcion_id_seq OWNER TO postgres;

--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 230
-- Name: auditoriaadopcion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoriaadopcion_id_seq OWNED BY public.auditoriaadopcion.id;


--
-- TOC entry 231 (class 1259 OID 17634)
-- Name: donacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donacion (
    id integer NOT NULL,
    usuario text NOT NULL,
    metodo_pago text NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.donacion OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17640)
-- Name: donacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.donacion_id_seq OWNER TO postgres;

--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 232
-- Name: donacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donacion_id_seq OWNED BY public.donacion.id;


--
-- TOC entry 233 (class 1259 OID 17641)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id bigint NOT NULL,
    nombre_completo character varying(255),
    lugar_nacimiento character varying(255),
    fecha_nacimiento date,
    correo character varying(255),
    telefono character varying(255),
    usuario character varying(255),
    contrasena character varying(255),
    rol character varying(255)
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17646)
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_seq OWNER TO postgres;

--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 234
-- Name: usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;


--
-- TOC entry 4788 (class 2604 OID 17647)
-- Name: adopcion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adopcion ALTER COLUMN id SET DEFAULT nextval('public.adopcion_id_seq'::regclass);


--
-- TOC entry 4791 (class 2604 OID 17648)
-- Name: animal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal ALTER COLUMN id SET DEFAULT nextval('public.animal_id_seq'::regclass);


--
-- TOC entry 4792 (class 2604 OID 17649)
-- Name: auditoria_adopcion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_adopcion ALTER COLUMN id SET DEFAULT nextval('public.auditoria_adopcion_id_seq'::regclass);


--
-- TOC entry 4794 (class 2604 OID 17650)
-- Name: auditoria_animales id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_animales ALTER COLUMN id SET DEFAULT nextval('public.auditoria_animales_id_seq'::regclass);


--
-- TOC entry 4796 (class 2604 OID 17651)
-- Name: auditoria_contrasena id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_contrasena ALTER COLUMN id SET DEFAULT nextval('public.auditoria_contrasena_id_seq'::regclass);


--
-- TOC entry 4799 (class 2604 OID 17652)
-- Name: auditoria_donacion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_donacion ALTER COLUMN id SET DEFAULT nextval('public.auditoria_donacion_id_seq'::regclass);


--
-- TOC entry 4801 (class 2604 OID 17653)
-- Name: auditoria_usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_usuarios ALTER COLUMN id SET DEFAULT nextval('public.auditoria_usuarios_id_seq'::regclass);


--
-- TOC entry 4803 (class 2604 OID 17654)
-- Name: auditoriaadopcion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoriaadopcion ALTER COLUMN id SET DEFAULT nextval('public.auditoriaadopcion_id_seq'::regclass);


--
-- TOC entry 4805 (class 2604 OID 17655)
-- Name: donacion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacion ALTER COLUMN id SET DEFAULT nextval('public.donacion_id_seq'::regclass);


--
-- TOC entry 4807 (class 2604 OID 17656)
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);


--
-- TOC entry 4809 (class 2606 OID 17658)
-- Name: adopcion adopcion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adopcion
    ADD CONSTRAINT adopcion_pkey PRIMARY KEY (id);


--
-- TOC entry 4811 (class 2606 OID 17660)
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (id);


--
-- TOC entry 4813 (class 2606 OID 17662)
-- Name: auditoria_adopcion auditoria_adopcion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_adopcion
    ADD CONSTRAINT auditoria_adopcion_pkey PRIMARY KEY (id);


--
-- TOC entry 4815 (class 2606 OID 17664)
-- Name: auditoria_animales auditoria_animales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_animales
    ADD CONSTRAINT auditoria_animales_pkey PRIMARY KEY (id);


--
-- TOC entry 4817 (class 2606 OID 17666)
-- Name: auditoria_contrasena auditoria_contrasena_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_contrasena
    ADD CONSTRAINT auditoria_contrasena_pkey PRIMARY KEY (id);


--
-- TOC entry 4819 (class 2606 OID 17668)
-- Name: auditoria_donacion auditoria_donacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_donacion
    ADD CONSTRAINT auditoria_donacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4821 (class 2606 OID 17670)
-- Name: auditoria_usuarios auditoria_usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_usuarios
    ADD CONSTRAINT auditoria_usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4823 (class 2606 OID 17672)
-- Name: auditoriaadopcion auditoriaadopcion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoriaadopcion
    ADD CONSTRAINT auditoriaadopcion_pkey PRIMARY KEY (id);


--
-- TOC entry 4825 (class 2606 OID 17674)
-- Name: donacion donacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacion
    ADD CONSTRAINT donacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4827 (class 2606 OID 17676)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- TOC entry 4829 (class 2606 OID 17678)
-- Name: usuario usuario_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_usuario_key UNIQUE (usuario);


--
-- TOC entry 4831 (class 2620 OID 17679)
-- Name: adopcion trg_auditoria_adopcion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditoria_adopcion AFTER UPDATE ON public.adopcion FOR EACH ROW EXECUTE FUNCTION public.registrar_auditoria_adopcion();


--
-- TOC entry 4832 (class 2620 OID 17680)
-- Name: adopcion trg_devolver_adopcion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_devolver_adopcion AFTER UPDATE ON public.adopcion FOR EACH ROW EXECUTE FUNCTION public.registrar_devolucion();


--
-- TOC entry 4833 (class 2620 OID 17681)
-- Name: adopcion trg_log_adopcion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_adopcion AFTER INSERT ON public.adopcion FOR EACH ROW EXECUTE FUNCTION public.log_adopcion();


--
-- TOC entry 4838 (class 2620 OID 17682)
-- Name: usuario trigger_cambio_contrasena; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_cambio_contrasena AFTER UPDATE ON public.usuario FOR EACH ROW WHEN (((old.contrasena)::text IS DISTINCT FROM (new.contrasena)::text)) EXECUTE FUNCTION public.registrar_cambio_contrasena();


--
-- TOC entry 4834 (class 2620 OID 17683)
-- Name: animal trigger_delete_animales; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_delete_animales AFTER DELETE ON public.animal FOR EACH ROW EXECUTE FUNCTION public.registrar_cambios();


--
-- TOC entry 4839 (class 2620 OID 17684)
-- Name: usuario trigger_delete_usuario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_delete_usuario AFTER DELETE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.registrar_cambios_usuario();


--
-- TOC entry 4837 (class 2620 OID 17685)
-- Name: donacion trigger_donacion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_donacion AFTER INSERT ON public.donacion FOR EACH ROW EXECUTE FUNCTION public.registrar_auditoria_donacion();


--
-- TOC entry 4835 (class 2620 OID 17686)
-- Name: animal trigger_insert_animales; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_insert_animales AFTER INSERT ON public.animal FOR EACH ROW EXECUTE FUNCTION public.registrar_cambios();


--
-- TOC entry 4840 (class 2620 OID 17687)
-- Name: usuario trigger_insert_usuario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_insert_usuario AFTER INSERT ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.registrar_cambios_usuario();


--
-- TOC entry 4836 (class 2620 OID 17688)
-- Name: animal trigger_update_animales; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_animales AFTER UPDATE ON public.animal FOR EACH ROW EXECUTE FUNCTION public.registrar_cambios();


--
-- TOC entry 4841 (class 2620 OID 17689)
-- Name: usuario trigger_update_usuario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_usuario AFTER UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.registrar_cambios_usuario();


--
-- TOC entry 4830 (class 2606 OID 17690)
-- Name: auditoria_contrasena fkqorr1hnc14pvvhi8b1a04c40p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_contrasena
    ADD CONSTRAINT fkqorr1hnc14pvvhi8b1a04c40p FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


-- Completed on 2025-12-12 09:36:15

--
-- PostgreSQL database dump complete
--

