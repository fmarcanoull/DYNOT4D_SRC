function datosSalida = DYNOT4D_filtradoDatosPasoBanda(datosEntrada,parametrosDYNOT4D)
    datosSalida = DYNOT4D_filtradoDatosPasoBajo(datosEntrada,parametrosDYNOT4D);
    datosSalida = DYNOT4D_filtradoDatosPasoAlto(datosSalida,parametrosDYNOT4D);
end