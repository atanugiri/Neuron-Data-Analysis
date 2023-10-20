% Date: 09/27/2023
% Firing rate plot of single paired neurons in triplet

% twdbs = load("twdbs.mat");

% Input struct of twdbs
dataTable = input("Enter the struct you want for analysis: 'twdb_control', " + ...
    "'twdb_stress', or 'twdb_stress2': ",'s');
database = twdbs.(sprintf('%s', dataTable));

if strcmpi(dataTable, 'twdb_control')
    loadFile = load('pairsTableControl.mat');
elseif strcmpi(dataTable, 'twdb_stress')
    loadFile = load('pairsTableStress.mat');
else
    loadFile = load('pairsTableStress2.mat');
end

fitData = loadFile.fitData;

plotType = input("Enter desired plot: 'PLSvsFSI', 'FSIvsSTRIO', or 'PLSvsSTRIO': ",'s');

if strcmpi(plotType, 'PLSvsFSI')
     row = input("Which row do you want to plot? ");
        try
            fitResult1 = fitData.fitresultArray_PLSvsFSI{row};
            a = fitResult1.a;
            b = fitResult1.b;
            x = fitData.xValArray_PLSvsFSI{row};
            y = fitData.yValArray_PLSvsFSI{row};
            plot(x, y, 'o', 'Color', 'blue');
            hold on;
            x_fit = linspace(min(x), max(x), 100);
            y_fit = a*x_fit + b;
            plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'blue');
            hold off;
            xlabel("PLS Firing Rate","Interpreter","latex");
            ylabel("FSI Firing Rate","Interpreter","latex");
            title(sprintf("PLS: %d, FSI: %d", fitData.plsIndex(row), fitData.fsiIndex(row)));
            
        catch
            fprintf("Plotting error\n");
        end

elseif strcmpi(plotType, 'FSIvsSTRIO')
    disp("Work on it.")

elseif strcmpi(plotType, 'PLSvsSTRIO')
     row = input("Which row do you want to plot? ");
        
        try
            %% For linear fit
            fitResult = fitData.fitResultArray_PLSvsSTRIO{row};
            c = fitResult.c;
            d = fitResult.d;

            x = fitData.xValArray_PLSvsSTRIO{row};
            y = fitData.yValArray_PLSvsSTRIO{row};
            plot(x, y, 'o', 'Color', 'r');
            hold on;
            x_fit = linspace(min(x), max(x), 100);

            %% For linear fit
            y_fit = c*x_fit + d;

            plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'r');
            hold off;
            xlabel("PLS Firing Rate","Interpreter","latex");
            ylabel("Strio Firing Rate","Interpreter","latex");
            title(sprintf("PLS: %d, Strio: %d", fitData.plsIndex(row), ...
                fitData.striosomeIndex(row)));
            
        catch
            fprintf("Plotting error\n");
        end
end
set(gcf, 'Windowstyle', 'docked');