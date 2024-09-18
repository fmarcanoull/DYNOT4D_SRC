function datosFiltrados = DYNOT4D_Filtrado(datosEntrada,canalesMostrados,filtro,pasoAltoFrecuenciaCorte,pasoBajoFrecuenciaCorte,SamplingRate,time_point_N,epsilonParaFiltro,segundosDeRellenoParaFiltros)
    datosFiltrados = zeros(size(datosEntrada));

    parametrosDYNOT4D = struct();
    parametrosDYNOT4D.pasoAltoFrecuenciaCorte = pasoAltoFrecuenciaCorte;
    parametrosDYNOT4D.pasoBajoFrecuenciaCorte = pasoBajoFrecuenciaCorte;
    parametrosDYNOT4D.SamplingRate = SamplingRate;
    parametrosDYNOT4D.time_point_N = time_point_N;
    parametrosDYNOT4D.epsilonParaFiltro = epsilonParaFiltro;
    parametrosDYNOT4D.segundosDeRellenoParaFiltros = segundosDeRellenoParaFiltros; 
    switch(filtro)
        case 'Paso bajo'                        
            datosFiltrados(:,canalesMostrados) = DYNOT4D_filtradoDatosPasoBajo(datosEntrada(:,canalesMostrados), parametrosDYNOT4D);
        case 'Paso alto + media'
            datosFiltrados(:,canalesMostrados) = DYNOT4D_filtradoDatosPasoAlto(datosEntrada(:,canalesMostrados), parametrosDYNOT4D);
        case 'Paso banda'
            datosFiltrados(:,canalesMostrados) = DYNOT4D_filtradoDatosPasoBanda(datosEntrada(:,canalesMostrados),parametrosDYNOT4D);
        %case 'DRIFTER'
        %case 'Wavelet'
        otherwise
           datosFiltrados(:,canalesMostrados) = datosEntrada(:,canalesMostrados);
    end
end