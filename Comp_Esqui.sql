drop database if exists CompEsqui;
create database CompEsqui;
use CompEsqui;


create table Persona (
    CodP int not null auto_increment,
    Nombre varchar (30),
    Apellido varchar (40),

    constraint pk_persona primary key (CodP)
);

create table Federacion (
    NFed int not null auto_increment,
    Nombre varchar (60),
    CantFed int,

    constraint pk_federacion primary key (NFed)
);

create table Estacion (
    NEst int not null auto_increment,
    Nombre varchar (60),
    Direccion varchar (60),
    Telefono varchar (15),
    totalkm int,

    constraint pk_estacion primary key (NEst)
);

create table Administracion (
    NFed int not null,
    NEst int not null,

    constraint pk_admin primary key (NFed, NEst),
    constraint fk_admin_Fed foreign key (NFed) references Federacion (NFed),
    constraint fk_admin_Est foreign key (NEst) references Estacion (NEst)
);

create table Contacto (
    CodCont int not null auto_increment,
    CodP int,
    NEst int,

    constraint pk_contacto primary key (CodCont),
    constraint fk_contacto_Pers foreign key (CodP) references Persona (CodP),
    constraint fk_contacto_Est foreign key (NEst) references Estacion (NEst)
);

create table Entrenador (
    CodEntr int not null auto_increment,
    CodP int,

    constraint pk_entrenador primary key (CodEntr),
    constraint fk_entrenador_Pers foreign key (CodP) references Persona (CodP)
);

create table Pista (
    NPista int not null auto_increment,
    NEst int,
    LongitudKM float,
    Dificultad varchar (15),
    Compuesta boolean,

    constraint pk_pistas primary key (NPista),
    constraint fk_pistas foreign key (NEst) references Estacion (NEst)
);

create table Pista_Comp (
    NPistaComp int not null,
    NPista int not null,

    constraint pk_pistacomp_pc primary key (NPistaComp, NPista),
    constraint fk_pistacomp_pc foreign key (NPistaComp) references Pista (NPista),
    constraint fk_pistacomp_p foreign key (NPista) references Pista (NPista)
);

create table Esquiador (
    CodEsq int not null auto_increment,
    CodP int,
    NFed int,
    tipoDoc varchar(15),
    NroDoc varchar(30),
    FNac date,

    constraint pk_esquiador primary key (CodEsq),
    constraint fk_esquiador_pers foreign key (CodP) references Persona (CodP),
    constraint fk_esquiador_fed foreign key (NFed) references Federacion (NFed)
);

create table Equipo (
    NEq int not null auto_increment,
    Nombre varchar(40),
    CodEntr int,

    constraint pk_equipo primary key (NEq),
    constraint fk_equipo_entr foreign key (CodEntr) references Entrenador (CodEntr)
);

create table Integrante (
    NInt int not null auto_increment,
    NEq int,
    CodEsq int,

    constraint pk_integ primary key (NInt),
    constraint fk_integ_equipo foreign key (NEq) references Equipo (NEq),
    constraint fk_integ_esquiador foreign key (CodEsq) references Esquiador (CodEsq)
);

create table Prueba (
    NPrueba int not null auto_increment,
    Nombre varchar(40),
    Inicio date,
    Fin date,
    Tipo varchar(20),
    
    constraint pk_prueba primary key (NPrueba)
);

create table Pista_Prueba (
    CodPP int not null auto_increment,
    NPrueba int,
    NPista int,
    FechaPista date,

    constraint pk_pp primary key (CodPP),
    constraint fk_pp_pista foreign key (NPista) references Pista (NPista),
    constraint fk_pp_prueba foreign key (NPrueba) references Prueba (NPrueba)

);

create table Participante_Eq (
    NPartEq int not null auto_increment,
    NEq int,

    constraint pk_parteq primary key (NPartEq),
    constraint fk_parteq_equipo foreign key (NEq) references Equipo (NEq)
);

create table Equipo_Prueba (
    CodEqPrb int not null auto_increment,
    NPartEq int,
    NPrueba int,

    constraint pk_eqprueba primary key (CodEqPrb),
    constraint fk_eqprueba_parteq foreign key (NPartEq) references Participante_Eq (NPartEq),
    constraint fk_eqprueba_prueba foreign key (NPrueba) references Prueba (NPrueba)
);

create table Tiempo_Int (
    CodPP int not null auto_increment,
    NInt int not null,
    Tiempo time,
    Acabado boolean,

    constraint pk_tiempoint primary key (CodPP, NInt),
    constraint fk_tiempoint_pp foreign key (CodPP) references Pista_Prueba (CodPP),
    constraint fk_tiempoint_int foreign key (NInt) references Integrante (NInt)
);

create table Tiempo_Tot_Eq (
    CodTTEq int not null auto_increment,
    CodEqPrb int,
    TiempoTot time,

    constraint pk_tteq primary key (CodTTEq),
    constraint fk_tteq_eqprb foreign key (CodEqPrb) references Equipo_Prueba (CodEqPrb)
);

create table Posicion_Eq (
    CodPosicEq int not null auto_increment,
    Posicion int,
    CodTTEq int,

    constraint pk_poseq primary key (CodPosicEq),
    constraint fk_poseq_tteq foreign key (CodTTEq) references Tiempo_Tot_Eq (CodTTEq)
);

create table Participante_Ind (
    NPartInd int not null auto_increment,
    CodEsq int,
    Nacionalidad varchar(20),

    constraint pk_partind primary key (NPartInd),
    constraint fk_partind_esq foreign key (CodEsq) references Esquiador (CodEsq)
);

create table Prueba_Ind (
    CodIndPrb int not null auto_increment,
    NPartInd int,
    NPrueba int,

    constraint pk_prbind primary key (CodIndPrb),
    constraint fk_prbind_partind foreign key (NPartInd) references Participante_Ind (NPartInd),
    constraint fk_prbind_prueba foreign key (NPrueba) references Prueba (NPrueba)
);

create table Tiempo_Ind (
    CodPP int,
    NPartInd int,
    Tiempo time,
    Acabado boolean,

    constraint pk_tiempoind primary key (CodPP, NPartInd),
    constraint fk_tiempoind_pp foreign key (CodPP) references Pista_Prueba (CodPP),
    constraint fk_tiempoind_partind foreign key (NPartInd) references Participante_Ind (NPartInd)
);

create table Tiempo_Tot_Ind (
    CodTTInd int not null auto_increment,
    CodIndPrb int,
    TiempoTot time,

    constraint pk_ttind primary key (CodTTInd),
    constraint fk_ttind_pind foreign key (CodIndPrb) references Prueba_Ind (CodIndPrb)
);

create table Posicion_Ind (
    CodPosicInd int not null auto_increment,
    Posicion int,
    CodTTInd int,

    constraint pk_posind primary key (CodPosicInd),
    constraint fk_posind_ttind foreign key (CodTTInd) references Tiempo_Tot_Ind (CodTTInd)
);
