function datosSalida = DYNOT4D_filtradoDatosPasoAlto(datosEntrada,parametrosDYNOT4D)
    pasoAltoFrecuenciaCorte = parametrosDYNOT4D.pasoAltoFrecuenciaCorte;
    SamplingRate = parametrosDYNOT4D.SamplingRate;
    time_point_N = parametrosDYNOT4D.time_point_N;
    epsilonParaFiltro = parametrosDYNOT4D.epsilonParaFiltro;
    
    if (isempty(datosEntrada))
        datosSalida = [];
        return
    end
    muestrasDeRelleno = DYNOT4D_segundosAMuestras(parametrosDYNOT4D); 
    rango_relleno_inicio = muestrasDeRelleno:-1:1;
    rango_relleno_final = time_point_N:-1:(time_point_N-muestrasDeRelleno-1);
    datos_relleno_inicio = datosEntrada(rango_relleno_inicio,:);
    datos_relleno_final = datosEntrada(rango_relleno_final,:);
    mediaDatosEntrada = mean(datosEntrada);
    SB = pasoAltoFrecuenciaCorte;
    SB = pasoAltoFrecuenciaCorte - min(0.1,SB-epsilonParaFiltro/2);
    dbutter = designfilt('highpassiir','PassbandFrequency',pasoAltoFrecuenciaCorte,...  
        'StopbandFrequency', SB , ...
        'PassbandRipple',1,...
        'StopbandAttenuation',60,'SampleRate',SamplingRate,'DesignMethod','ellip');
    datosSalida = filtfilt(dbutter,[datos_relleno_inicio;datosEntrada;datos_relleno_final]);
    datosSalida = datosSalida((length(rango_relleno_inicio)+1):(end-length(rango_relleno_final)),:);
    datosSalida = datosSalida + repmat(mediaDatosEntrada,[size(datosSalida,1),1]);
end