/* TODAS ESTAS CONSULTAS ESTÁN LISTAS PARA SER COPIADAS
ENTERAS Y TIRADAS EN LA CONSOLA (excepto la 5 en 2 partes) */


/* 1) Informar ganador y tiempo utilizado de la prueba 
que se desarrolló en la mayor cantidad de jornadas*/

set @NPrueba = (
select NPrueba 
    from Pista_Prueba 
        group by NPrueba
            having count(CodPP) = (
                        select max(e) 
                            from (select count(CodPP) as "e"
                                    from Pista_Prueba
                                        group by NPrueba) A));
select @NPrueba;

set @NPartInd = (
    select NPartInd
        from Prueba_Ind PI, Tiempo_Tot_Ind TTI, Posicion_Ind P
            where Posicion = 1
            and PI.NPrueba = @NPRUEBA
            and PI.CodIndPrb = TTI.CodIndPrb
            and TTI.CodTTInd = P.CodTTInd);
select @NPartInd;


set @TiempoTot = (
    select TTI.TiempoTot
        from Prueba_Ind PI, Tiempo_Tot_Ind TTI, Posicion_Ind P
            where Posicion = 1
            and PI.NPrueba = @NPRUEBA
            and PI.CodIndPrb = TTI.CodIndPrb
            and TTI.CodTTInd = P.CodTTInd);
select @TiempoTot;


select Concat(Nombre, " ", Apellido) as "Nombre y Apellido", @NPrueba, @TiempoTot
    from Persona P, Esquiador E, Participante_Ind PI
        where PI.NPartInd = @NPartInd
        and PI.CodEsq = E.CodEsq
        and E.CodP = P.CodP;









/* 2) Listar cada una de las pruebas junto el identificador de pista,
la dificultad y en caso de estar compuesta por otras pistas la cantidad
de pistas que la componen */

select PP.NPrueba, PP.Npista, P.Dificultad, Compuesta as "Comp"
    from pista_prueba PP, pista P
        where PP.NPista = P.NPista;


select NPistaComp, count(NPista) as "CantPistas"
    from Pista_Comp
        group by NPistaComp
            having NPistaComp in (select PP.Npista
                                    from pista_prueba PP
                                        inner join pista P 
                                        on PP.NPista = P.NPista
                                            and compuesta = 1);

select PP.NPrueba, PP.Npista, P.Dificultad, Compuesta as "Comp", CantPistas
  from pista_prueba PP, pista P, (select NPistaComp, count(NPista) as "CantPistas"
                                    from Pista_Comp
                                      group by NPistaComp
                                        having NPistaComp in (select PP.Npista
                                                                from pista_prueba PP
                                                                  inner join pista P 
                                                                    on PP.NPista = P.NPista
                                                                      and compuesta = 1)) A
        where PP.NPista = P.NPista
        and P.NPista = A.NPistaComp;

select PP.NPrueba, PP.Npista, P.Dificultad, Compuesta as "Comp", @NULL as "CantPistas"
    from pista_prueba PP, pista P
        where PP.NPista = P.NPista
        and compuesta = 0;



(select PP.NPrueba, PP.Npista, P.Dificultad, Compuesta as "Comp", @NULL as "CantPistas"
    from pista_prueba PP, pista P
        where PP.NPista = P.NPista
        and compuesta = 0
            order by PP.NPista)
UNION
(select PP.NPrueba, PP.Npista, P.Dificultad, Compuesta as "Comp", CantPistas
  from pista_prueba PP, pista P, (select NPistaComp, count(NPista) as "CantPistas"
                                    from Pista_Comp
                                      group by NPistaComp
                                        having NPistaComp in (select PP.Npista
                                                                from pista_prueba PP
                                                                  inner join pista P 
                                                                    on PP.NPista = P.NPista
                                                                      and compuesta = 1)) A
        where PP.NPista = P.NPista
        and P.NPista = A.NPistaComp)
order by NPrueba;








/* 3) Informar los datos de los esquiadores que pertenecen 
a los equipos que superen el promedio de integrantes 
de esquiadores de todos los equipos. */

select count(*) "a"
    from Integrante
        group by NEq;

set @PromedioInt = (
    select round (avg(a), 0)
        from (select count(*) "a"
                from Integrante
                    group by NEq) a);
select @PromedioInt;


select NEq
    from Integrante
        group by NEq
            having count(NEq) > @PromedioInt;

select concat(Nombre, " ", Apellido) as "Nombre Completo", NEq, TipoDoc, NroDoc
    from Integrante I
        inner join Esquiador E on E.CodEsq = I.CodEsq 
        inner join Persona P on P.codP = E.codP
            where I.NEq in(select NEq
                                from Integrante
                                    group by NEq
                                        having count(NEq) > @PromedioInt);





/* 4) Mostrar a cada entrenador junto a la cantidad
de equipos que entrena en las olimpiadas.*/

select CodEntr, count(NEq)
    from Equipo
        group by CodEntr;

select Nombre, Apellido, CodEntr
    from Persona P
        inner join Entrenador E 
        on P.CodP = E.CodP;

select E.CodEntr, concat(P.Nombre, " ", P.Apellido) AS "Entrenador", count(NEq) as "Cant Equipos"
    from Entrenador E
        inner join Equipo Eq on Eq.CodEntr = E.CodEntr
        inner join Persona P on E.CodP = P.CodP
            group by CodEntr;






/* 5) Listar nombre y federación de todos los participantes (individual
o en equipo) que compitieron en la inauguración de las olimpiadas */

/* - INDIVIDUAL - INAUGURACIÓN- */

set @FInaug = (
    select min(FPistaPrueba)
        from Pista_Prueba);
select @FInaug;

set @CodPP = (
    select CodPP   
        from Pista_Prueba
            where FPistaPrueba = @FInaug);
select @CodPP;

select NPartInd                                     
    from Tiempo_Ind                                      
        where CodPP = @CodPP;                                                  

select concat(P.Nombre, " ", Apellido) as "Nombre y Apellido", F.Nombre "Federacion"
    from Participante_Ind PI
        inner join Esquiador E on PI.CodEsq = E.CodEsq
        inner join Persona P on E.CodP = P.CodP
        inner join Federacion F on E.NFed = F.NFed
            where PI.NPartInd in (select NPartInd                
                                    from Tiempo_Ind            
                                        where CodPP = @CodPP);



/* - EQUIPO - CIERRE - */

set @FCierre = (
    select max(FPistaPrueba)
        from Pista_Prueba);
select @FCierre;

set @CodPP = (
    select CodPP   
        from Pista_Prueba
            where FPistaPrueba = @FCierre);
select @CodPP;


select NInt                                     
    from Tiempo_Int                                      
        where CodPP = @CodPP;                                                  

select concat(P.Nombre, " ", Apellido) as "Nombre y Apellido", F.Nombre "Federacion"
    from Integrante I
        inner join Esquiador E on I.CodEsq = E.CodEsq
        inner join Persona P on E.CodP = P.CodP
        inner join Federacion F on E.NFed = F.NFed
            where I.NInt in (select NInt                      
                                      from Tiempo_Int            
                                          where CodPP = @CodPP);






/* 6) Identificar los esquiadores que al final de la competencia 
no participaron en ninguna prueba y formaban parte de un equipo, 
junto al nombre del equipo;   ordenado por equipo. */

select NInt
    from Tiempo_Int
        group by NInt;

select NInt, NEq
    from Integrante
        where Nint not in (select NInt
                            from Tiempo_Int
                                group by NInt);

select I.CodEsq, concat(P.Nombre, " ", P.Apellido) as "Nombre y Apellido", EQ.Nombre "Equipo"
  from Integrante I
    inner join Esquiador E on I.CodEsq = E.CodEsq
    inner join Persona P on E.CodP = P.CodP
    inner join Equipo EQ on I.NEq = EQ.NEq
      where Nint not in (select NInt
                          from Tiempo_Int
                            group by NInt)
        order by EQ.NEq;



/* 7) Identificar a las estaciones de esquí que sean administradas por 
más de una federación, indicando nombre, km esquiables y cantidad de
pistas, ordenadas alfabéticamente. */

select NEst
	from administracion
		group by NEst
			having count(NFed) > 1;

select E.NEst, E.Nombre, count(NPista) as "Cantidad de Pistas", E.TotalKM
	from pista P, estacion E
		where E.NEst = P.NEst
			group by NEst
				having NEst in (select NEst
									from administracion
										group by NEst
											having count(NFed) > 1)
					order by Nombre;




/* 8)   SITUACIÓN LÓGICA
Dada la cantidad de participantes en las olimpiadas se decidió habilitar una nueva estación
de esquí llamada “Sur/Norte”. Para administrar se pensó en la federación que tiene asignada
una sola estación junto a la federación que tiene la mayor cantidad de estaciones asignadas. 
Para determinar cuántos km esquiables tendrá se pensó en tomar el promedio de km totales 
que tiene toda la competencia. Las pistas aún no serán asignadas porque deben evaluar si hay 
algún recorte de las ya existentes */

set @TotalKM = (
    select round(avg(TotalKM), 1)
        from Estacion);
select @TotalKM;

set @NEstNuevo = (
    select max(NEst) +1
        from Estacion);
select @NEstNuevo;

insert into Estacion values
(@NEstNuevo, "Sur / Norte", "Av. El Bosque 86, Las Condes", "+56957638114", @TotalKM);


set @MaxF =(
select max(F)
    from (select count(NFed) as "F"
            from Administracion A
            inner join Estacion E on A.NEst = E.NEst
                group by A.NFed)A);
select @MaxF;

set @NFedMayor = (
select NFed
    from Administracion
        group by NFed   
            having count(NFed) = @MaxF);
select @NFedMayor;

set @NFedMenor = (
select NFed
    from Administracion
        group by NFed   
            having count(NFed) = 1);
select @NFedMenor;

insert into Administracion values
(@NFedMenor,@NEstNuevo),
(@NFedMayor,@NEstNuevo);

set @Nest = (
    select Nest
        from contacto
            group by Nest
            having count(*) = @MinContact);
select @NEst;





/* 9)   SITUACIÓN LÓGICA  A
Debido a los decepcionantes resultados de la ultima prueba, los
administradores del equipo que quedó en ultimo puesto han decidido cambiar 
su entrenador, y contratar  al entrenador del equipo que resultó ganador, 
y de esta manera en un futuro conseguir mejores resultados */


set @UltNPrueba = (
	select NPrueba
		from Prueba
			where Inicio = (select max(Inicio)
		                        from Prueba));
select @UltNPrueba;

select CodEqPrb
	from equipo_prueba
		where NPrueba = @UltPrueba;

select P.Posicion, P.CodTTEq, CodEqPrb
    from Posicion_Eq P
        inner join Tiempo_Tot_Eq TT on P.CodTTEq = TT.CodTTEq
        where CodEqPrb in (select CodEqPrb
                            from equipo_prueba
                                where NPrueba = @UltPrueba) 
            order by Posicion;

set @UltPosic = (
select max(P.Posicion)
    from Posicion_Eq P
        inner join Tiempo_Tot_Eq TT on P.CodTTEq = TT.CodTTEq
        where CodEqPrb in (select CodEqPrb
                            from equipo_prueba
                                where NPrueba = @UltPrueba) 
            order by Posicion); select @UltPosic;

set @NEqPerdedor = (
select E.NEq
    from Posicion_Eq P
        inner join Tiempo_Tot_Eq TT on P.CodTTEq = TT.CodTTEq
        inner join Equipo_Prueba EP on TT.CodEqPrb = EP.CodEqPrb
        inner join Participante_Eq PE on EP.NPartEq = PE.NPartEq
        inner join Equipo E on PE.NEq = E.NEq
        where EP.CodEqPrb in (select CodEqPrb
                            from equipo_prueba
                                where NPrueba = @UltPrueba) 
        and Posicion = @UltPosic
        ); select @NEqPerdedor;

set @NEqGanador = (
select E.NEq
    from Posicion_Eq P
        inner join Tiempo_Tot_Eq TT on P.CodTTEq = TT.CodTTEq
        inner join Equipo_Prueba EP on TT.CodEqPrb = EP.CodEqPrb
        inner join Participante_Eq PE on EP.NPartEq = PE.NPartEq
        inner join Equipo E on PE.NEq = E.NEq
        where EP.CodEqPrb in (select CodEqPrb
                            from equipo_prueba
                                where NPrueba = @UltPrueba) 
        and Posicion = 1
        ); select @NEqGanador;


set @EntrPerdedor = (
    select CodEntr
        from Equipo
            where NEq = @NEqPerdedor);
select @EntrPerdedor;

set @EntrGanador = (
    select CodEntr
        from equipo
            where NEq = @NEqGanador);
select @EntrGanador;

select * from Equipo;
update Equipo
	set CodEntr = @EntrGanador
		where CodEntr = @EntrPerdedor;
select * from Equipo;





/* 9)   SITUACIÓN LÓGICA  B
Debido que hay entrenadores que por un largo tiempo no pudieron
conseguir estar en un equipo, han estado en una situación economica
bastante inestable y la oportunidad que se les presentó fue ser parte
de contactos,siendo ellos parte de la lista de contactos de la estación
con la menor cantidad de contactos.
*/

/*Vemos cuantos contactos tiene cada estación*/

select Nest,count(*)"CantContact"
        from contacto
            group by Nest;

/*Averiguamos la minima cantidad de contactos que tiene una estacion*/

set @MinContact = (select min(CantContact)
                    from  (select Nest,count(*)"CantContact"
                                from contacto
                                    group by Nest)a);
select @MinContact;

/* Buscamos la estación que tenga esa cantidad de contactos*/

set @Nest = (
    select Nest
        from contacto
            group by Nest
            having count(*) = @MinContact);
select @NEst;


/*Nos fijamos cuales son los CodP de los entrenadores sin equipos(son 4 pero lo hacemos de esta manera)*/
select E.CodP
from entrenador E
where E.CodEntr not in (select EQ.CodEntr
                            from Equipo EQ);
							
set @CodPers1 = (select E.CodP
                    from entrenador E
                        where E.CodEntr not in (select EQ.CodEntr
                                    from Equipo EQ)limit 1);
select @CodPers1;

/*Para luego borrar el @CodPers1 que está en entrenador*/
delete from entrenador where
CodP = @CodPers1;
											

/*Estos 3 pasos lo repetimos 4 vecs hasta que no haya ningún CodP sin equipo en entrenador*/
set @CodPers2 = (select E.CodP
                    from entrenador E
                        where E.CodEntr not in (select EQ.CodEntr
                                    from Equipo EQ)limit 1);
select @CodPers2;					

delete from entrenador where
CodP = @CodPers2;



set @CodPers3 = (select E.CodP
                    from entrenador E
                        where E.CodEntr not in (select EQ.CodEntr
                                    from Equipo EQ)limit 1);
select @CodPers3;

delete from entrenador where
Codp = @CodPers3;



set @CodPers4 = (select E.CodP
                    from entrenador E
                        where E.CodEntr not in (select EQ.CodEntr
                                    from Equipo EQ)limit 1);
select @CodPers4;

delete from entrenador where
CodP = @CodPers4;

/*Y finalmente lo que tenemos que hacer es el insert en contactos de todas las personas 
No hace falta poner una nueva PK, la tabla ya tiene auto_increment*/
insert into contacto values
("",@CodPers1,@Nest),
("",@CodPers2,@Nest),
("",@CodPers3,@Nest),
("",@CodPers4,@Nest);
