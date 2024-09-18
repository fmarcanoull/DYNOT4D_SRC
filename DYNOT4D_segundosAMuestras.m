function muestras = DYNOT4D_segundosAMuestras(parametrosDYNOT4D)
    SamplingRate = parametrosDYNOT4D.SamplingRate;
    time_point_N = parametrosDYNOT4D.time_point_N;
    segundosDeRellenoParaFiltros = parametrosDYNOT4D.segundosDeRellenoParaFiltros; 

    muestras = round(segundosDeRellenoParaFiltros * SamplingRate);
    muestras (muestras > time_point_N)= time_point_N;
    muestras (muestras < 1) = 1;
    muestras = unique(muestras);
end