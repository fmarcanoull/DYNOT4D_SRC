function datosSalida = DYNOT4D_filtradoDatosPasoBajo(datosEntrada,parametrosDYNOT4D)
    pasoBajoFrecuenciaCorte = parametrosDYNOT4D.pasoBajoFrecuenciaCorte;
    SamplingRate = parametrosDYNOT4D.SamplingRate;
    time_point_N = parametrosDYNOT4D.time_point_N;
    epsilonParaFiltro = parametrosDYNOT4D.epsilonParaFiltro;

    muestrasDeRelleno = DYNOT4D_segundosAMuestras(parametrosDYNOT4D); 
    SB = (SamplingRate/2 -epsilonParaFiltro - pasoBajoFrecuenciaCorte);
    SB = pasoBajoFrecuenciaCorte + min(0.1,SB);
    dbutter = designfilt('lowpassiir','PassbandFrequency',pasoBajoFrecuenciaCorte,...  
        'StopbandFrequency', SB , ...
        'PassbandRipple',1,...
        'StopbandAttenuation',60,'SampleRate',SamplingRate,'DesignMethod','butter');
    rango_relleno_inicio = muestrasDeRelleno:-1:1;
    rango_relleno_final = time_point_N:-1:(time_point_N-muestrasDeRelleno-1);
    datos_relleno_inicio = datosEntrada(rango_relleno_inicio,:);
    datos_relleno_final = datosEntrada(rango_relleno_final,:);
    datosSalida = filtfilt(dbutter,[datos_relleno_inicio;datosEntrada;datos_relleno_final]);
    datosSalida = datosSalida((length(rango_relleno_inicio)+1):(end-length(rango_relleno_final)),:);
end