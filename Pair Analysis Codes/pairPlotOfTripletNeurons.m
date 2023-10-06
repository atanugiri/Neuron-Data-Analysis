% Date: 09/05/2023
% Coefficient Plot of paired neurons in triplet

twdbs = load("twdbs.mat");

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


% Create a PDF file for saving the figures
pdf_file = 'doublet_plots_PLSvFSIstress2_test.pdf'; % User defined

% Initialize the subplot counter
subplot_count = 0;
% Create a new figure
figure('Position', [100, 100, 1200, 800]);

if strcmpi(plotType, 'PLSvsFSI')
    for row = 1:size(fitData, 1)
        % Increase subplot_count
        subplot_count = subplot_count+1;
        subplot(3, 5, subplot_count);
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
            sgtitle("PLS vs FSI Firing Rate: Stress2");
            % Save the figure as a PDF file
            if subplot_count == 15 || row == size(fitData, 1)
                % Save the current page and reset the subplot counter
                exportgraphics(gcf, pdf_file, 'ContentType', 'vector', 'Append', true);
                subplot_count = 0;
                % Create a new figure
                figure('Position', [100, 100, 1200, 800]);
            end
        catch
            fprintf("Plotting error\n");
            continue;
        end
    end

elseif strcmpi(plotType, 'FSIvsSTRIO')
    for row = 1:size(fitData, 1)
        % Increase subplot_count
        subplot_count = subplot_count+1;
        subplot(3, 5, subplot_count);
        try
            fitResult2 = fitData.fitresultArray_PLSvsSTRIO{row};
            c = fitResult2.c;
            d = fitResult2.d;
            g = fitResult2.g;
            h = fitResult2.h;

            x = fitData.yValArray_PLSvsFSI{row};
            PLS_fr = fitData.xValArray_PLSvsFSI{row};
            %             y = fitData.yValArray_PLSvsSTRIO{row};
            y = c./(1 + exp(d - (g*PLS_fr + h)./x));
            plot(x, y, 'o', 'Color', 'm');
            hold on;
            x_fit = linspace(min(x), max(x), size(PLS_fr,1));
            y_fit = c./(1 + exp(d - (g*PLS_fr + h)./x_fit));
            plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'm');
            hold off;
            xlabel("FSI Firing Rate","Interpreter","latex");
            ylabel("Strio Firing Rate","Interpreter","latex");
            title(sprintf("FSI: %d, Strio: %d", fitData.fsiIndex(row), ...
                fitData.striosomeIndex(row)));

            % Save the figure as a PDF file
            if subplot_count == 15 || row == size(fitData, 1)
                % Save the current page and reset the subplot counter
                exportgraphics(gcf, pdf_file, 'ContentType', 'vector', 'Append', true);
                subplot_count = 0;
                % Create a new figure
                figure('Position', [100, 100, 1200, 800]);
            end
        catch
            fprintf("Plotting error\n");
        end
    end

elseif strcmpi(plotType, 'PLSvsSTRIO')
    for row = 1:size(fitData, 1)
        % Increase subplot_count
        subplot_count = subplot_count+1;
        subplot(3, 5, subplot_count);
        try

            %% For Polyfit
%             fitResult1 = fitData.fitresultArray_PLSvsFSI{row};
%             a = fitResult1.a;
%             b = fitResult1.b;
%             fitResult2 = fitData.fitresultArray_PLSvsSTRIO{row};
%             c = fitResult2.c;
%             d = fitResult2.d;
%             g = fitResult2.g;
%             h = fitResult2.h;

            %% For linear fit
            fitResult = fitData.fitResultArray_PLSvsSTRIO{row};
            c = fitResult.c;
            d = fitResult.d;

            x = fitData.xValArray_PLSvsSTRIO{row};
            y = fitData.yValArray_PLSvsSTRIO{row};
            plot(x, y, 'o', 'Color', 'r');
            hold on;
            x_fit = linspace(min(x), max(x), 100);

            %% For Polyfit
%             y_fit = c./(1+exp(d - (g*x_fit+h)./(a*x_fit+b)));

            %% For linear fit
            y_fit = c*x_fit + d;

            plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'r');
            hold off;
            xlabel("PLS Firing Rate","Interpreter","latex");
            ylabel("Strio Firing Rate","Interpreter","latex");
            title(sprintf("PLS: %d, Strio: %d", fitData.plsIndex(row), ...
                fitData.striosomeIndex(row)));
            sgtitle("PLS vs Strio Firing Rate: Stress2");

            % Save the figure as a PDF file
            if subplot_count == 15 || row == size(fitData, 1)
                % Save the current page and reset the subplot counter
                exportgraphics(gcf, pdf_file, 'ContentType', 'vector', 'Append', true);
                subplot_count = 0;
                % Create a new figure
                figure('Position', [100, 100, 1200, 800]);
            end
        catch
            fprintf("Plotting error\n");
        end
    end
end
close all;