let mes;
let dia;
let año;

function randomf() {
dia = Math.floor(Math.random() * (30 - 1 + 1)) + 1;
mes = Math.floor(Math.random() * (12 - 1 + 1)) + 1;
año = Math.floor(Math.random() * (2001 - 1976 + 1)) + 1976;
return(año + "/" + mes + "/" + dia);
};

for(var i = 0; i < 140; i++) {
    randomf();
}

function randomf() {
    dia = Math.floor(Math.random() * (30 - 1 + 1)) + 1;
    mes = Math.floor(Math.random() * (12 - 1 + 1)) + 1;
    año = Math.floor(Math.random() * (2001 - 1976 + 1)) + 1976;
    return(año + "/" + mes + "/" + dia);
    };
    
    for(var i = 0; i < 140; i++) {
        randomf();
}
