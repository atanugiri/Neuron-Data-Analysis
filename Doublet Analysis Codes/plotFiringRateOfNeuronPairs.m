% Date: 10/06/2023
% This function extracts fitting parameters of pairs between two
% different types of neuron. Please note that this is not same pairs
% as of triplet.

% twdbs = load("twdbs.mat");
% Input struct of twdbs
dataTable = input("Enter the struct you want for analysis: 'twdb_control' or " + ...
    "'twdb_stress', 'twdb_stress2': ",'s');
database = twdbs.(sprintf('%s', dataTable));

if strcmpi(dataTable, 'twdb_control')
    loadFile = load('pairsTableControl.mat');
    [~, fileName] = fileparts('pairsTableControl');
elseif strcmpi(dataTable, 'twdb_stress')
    loadFile = load('pairsTableStress.mat');
    [~, fileName] = fileparts('pairsTableStress');
else
    loadFile = load('pairsTableStress2.mat');
    [~, fileName] = fileparts('pairsTableStress2');
end

fsiMatrixPairs = loadFile.pairsTable{2}; % Carefully choose pair

%% Analysis
fitresultArray = cell(size(fsiMatrixPairs, 1), 1);
gofArray = cell(size(fsiMatrixPairs, 1), 1);
xValArray = cell(size(fsiMatrixPairs, 1), 1);
yValArray = cell(size(fsiMatrixPairs, 1), 1);
rValArray = zeros(size(fsiMatrixPairs, 1), 1);
pValArray = zeros(size(fsiMatrixPairs, 1), 1);

bestBin = 1.33;
fitTypeChoice = 1;

for row = 1:size(fsiMatrixPairs,1)
    FSIindex = fsiMatrixPairs.fsiIndex(row);
    MATRIXindex = fsiMatrixPairs.matrixIndex(row);

    FSIspikes = database(FSIindex).trial_spikes;
    MATRIXspikes = database(MATRIXindex).trial_spikes;

    % Get the output values
    try
        [fitresult, gof, xnew, ynew, Rval, Pval] = plotDynamicsDoublet( ...
            MATRIXspikes, FSIspikes, bestBin, fitTypeChoice);

        % Store the result in the array
        fitresultArray{row} = fitresult;
        gofArray{row} = gof;
        xValArray{row} = xnew;
        yValArray{row} = ynew;
        rValArray(row) = Rval;
        pValArray(row) = Pval;

    catch
        fprintf('Skipping iteration %d due to an error.\n', row);
    end
end

%% Plotting
% Create a PDF file for saving the figures
pdf_file = 'doublet_plots_FsivsMstrixStress.pdf'; % User defined

% Initialize the subplot counter
subplot_count = 0;
% Create a new figure
figure('Position', [100, 100, 1200, 800]);

for row = 1:size(fitresultArray, 1)
    try
        % Increase subplot_count
        subplot_count = subplot_count+1;
        subplot(5, 5, subplot_count);
        fitResult = fitresultArray{row};
        a = fitResult.a;
        b = fitResult.b;
        x = xValArray{row};
        y = yValArray{row};

        plot(x, y, 'o', 'Color', 'blue');
        hold on;
        x_fit = linspace(min(x), max(x), 100);
        y_fit = a*x_fit + b;
        plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'blue');
        hold off;
        xlabel("Matrix Firing Rate","Interpreter","latex");
        ylabel("FSI Firing Rate","Interpreter","latex");
        title(sprintf("Matrix: %d, FSI: %d", fsiMatrixPairs.matrixIndex(row), ...
            fsiMatrixPairs.fsiIndex(row)));

    catch
        fprintf("Plotting error\n");
    end

    % Save the figure as a PDF file
    if subplot_count == 25 || row == size(fitresultArray, 1)
        sgtitle("Matrix vs FSI Firing Rate: Stress");
        % Save the current page and reset the subplot counter
        exportgraphics(gcf, pdf_file, 'ContentType', 'vector', 'Append', true);
        subplot_count = 0;
        % Create a new figure
        figure('Position', [100, 100, 1200, 800]);
    end

end