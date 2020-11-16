/* 1) Informar ganador y tiempo utilizado de la prueba 
que se desarrolló en la mayor cantidad de jornadas*/

SET @NPrueba = (
select NPrueba 
    from Pista_Prueba 
        group by NPrueba
            having count(CodPP) = (
                        select max(e) 
                            from (select count(CodPP) as "e"
                                    from Pista_Prueba
                                        group by NPrueba) A));
select @NPrueba;

SET @NPartInd = (
    select NPartInd
        from Prueba_Ind PI, Tiempo_Tot_Ind TTI, Posicion_Ind P
            where Posicion = 1
            and PI.NPrueba = @NPRUEBA
            and PI.CodIndPrb = TTI.CodIndPrb
            and TTI.CodTTInd = P.CodTTInd);
select @NPartInd;


SET @TiempoTot = (
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

select round(avg(TotalKM), 1)
    from estacion;

