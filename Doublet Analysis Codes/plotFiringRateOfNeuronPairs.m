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
    match = regexp('pairsTableControl', 'pairsTable(.+)', 'tokens', 'once');

elseif strcmpi(dataTable, 'twdb_stress')
    loadFile = load('pairsTableStress.mat');
    match = regexp('pairsTableStress', 'pairsTable(.+)', 'tokens', 'once');

else
    loadFile = load('pairsTableStress2.mat');
    match = regexp('pairsTableStress2', 'pairsTable(.+)', 'tokens', 'once');

end

% Select which pair you want to plot
neuronPair = input("Which pair do you want to plot ('fsiStriosomePairs' or 'fsiMatrixPairs')? ",'s');

if strcmpi(neuronPair, 'fsiStriosomePairs')
    pairsToAnalyze = loadFile.pairsTable{1};
    N2label = pairsToAnalyze.Properties.VariableNames{2}(1:9);

elseif strcmpi(neuronPair, 'fsiMatrixPairs')
    pairsToAnalyze = loadFile.pairsTable{2};
    N2label = pairsToAnalyze.Properties.VariableNames{2}(1:6);

else
    sprintf('Check input.')
end


%% Analysis
coeffA = NaN(size(pairsToAnalyze, 1), 1);
coeffB = NaN(size(pairsToAnalyze, 1), 1);
allGOF = NaN(size(pairsToAnalyze, 1), 1);
xValArray = cell(size(pairsToAnalyze, 1), 1);
yValArray = cell(size(pairsToAnalyze, 1), 1);
RvalArray = NaN(size(pairsToAnalyze, 1), 1);

for row = 1:size(pairsToAnalyze,1)
    FSIindex = pairsToAnalyze.(1)(row);
    N2index = pairsToAnalyze.(2)(row);

    FSIspikes = database(FSIindex).trial_spikes;
    N2spikes = database(N2index).trial_spikes;

    % Get the output values
    try
        [fitresult, gof, xnew, ynew, Rval, Pval] = plotDynamicsDoublet( ...
            FSIspikes, N2spikes, 1.33, 1);

        % Store the result in the array
        coeffA(row) = fitresult.a;
        coeffB(row) = fitresult.b;
        allGOF(row) = gof.rsquare;
        xValArray{row} = xnew;
        yValArray{row} = ynew;
        RvalArray(row) = Rval;
    catch
        fprintf('Skipping iteration %d due to an error.\n', row);
    end
end

% If you want negative slope
negR = RvalArray <= 0;
coeffA = coeffA(negR);
coeffB = coeffB(negR);
allGOF = allGOF(negR);
xValArray = xValArray(negR);
yValArray = yValArray(negR);


%% Plotting
% Create a PDF file for saving the figures
pdf_file = sprintf('doublet_plots_Fsivs%s%s.pdf', N2label, match{1});

% Initialize the subplot counter
subplot_count = 0;
% Create a new figure
figure('Position', [100, 100, 1200, 800]);

for row = 1:size(coeffA, 1)
    try
        % Increase subplot_count
        subplot_count = subplot_count+1;
        subplot(5, 5, subplot_count);
        x = xValArray{row};
        y = yValArray{row};

        plot(x, y, 'o', 'Color', 'blue');
        hold on;
        x_fit = linspace(min(x), max(x), 100);
        y_fit = coeffA(row)*x_fit + coeffB(row);
        plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'blue');
        hold off;
        xlabel("FSI Firing Rate", "Interpreter","latex");
        ylabel(sprintf("%s Firing Rate", N2label),"Interpreter","latex");

        title(sprintf("FSI: %d, %s: %d\n R^2 = %.2f, a = %.2f, b = %.2f", ...
        pairsToAnalyze.(1)(row), N2label, pairsToAnalyze.(2)(row), ...
        allGOF(row), coeffA(row), coeffB(row)));

    catch
        fprintf("Plotting error\n");
    end

    % Save the figure as a PDF file
    if subplot_count == 25 || row == size(coeffA, 1)
        sgtitle(sprintf("FSI vs %s Firing Rate: Stress", N2label));
        % Save the current page and reset the subplot counter
        exportgraphics(gcf, pdf_file, 'ContentType', 'vector', 'Append', true);
        subplot_count = 0;
        % Create a new figure
        figure('Position', [100, 100, 1200, 800]);
    end

end