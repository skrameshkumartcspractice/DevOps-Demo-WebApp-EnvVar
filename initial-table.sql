ALTER USER postgres WITH PASSWORD 'password';
CREATE SEQUENCE public.ticket_sequence INCREMENT 1 START 1000;
CREATE TABLE public.avt(tnum bigint default nextval('ticket_sequence'::regclass));
\dt
ALTER TABLE avt ADD COLUMN product varchar(100);
ALTER TABLE avt ADD COLUMN pdesc varchar(1000);
ALTER TABLE avt ADD COLUMN cont varchar(10);
ALTER TABLE avt ADD COLUMN datee varchar(100);
ALTER TABLE avt ADD COLUMN statuss varchar(100);
INSERT INTO public.avt(product, pdesc, cont, datee, statuss ) VALUES ('DIGITALTV', 'NW Issue','9884970793','15/03/2017','OPEN' ) RETURNING *;
INSERT INTO public.avt(pdesc) VALUES ('NOT WORKING') RETURNING *;
INSERT INTO public.avt(cont) VALUES ('9884570793') RETURNING *;
INSERT INTO public.avt(datee) VALUES ('20/03/2017') RETURNING *;
INSERT INTO public.avt(statuss) VALUES ('NEW') RETURNING *;
SELECT * FROM avt;