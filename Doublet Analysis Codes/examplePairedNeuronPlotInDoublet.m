% Date: 10/17/2023
% Firing rate Plot of single paired neurons in doublet

% twdbs = load("twdbs.mat");
% Input struct of twdbs
dataTable = input("Enter the struct you want for analysis: 'twdb_control' or " + ...
    "'twdb_stress', 'twdb_stress2': ",'s');
database = twdbs.(sprintf('%s', dataTable));

if strcmpi(dataTable, 'twdb_control')
    loadFile = load('pairsTableControl.mat');

elseif strcmpi(dataTable, 'twdb_stress')
    loadFile = load('pairsTableStress.mat');

else
    loadFile = load('pairsTableStress2.mat');

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

row = input("Which row do you want to plot? ");
FSIindex = pairsToAnalyze.(1)(row);
N2index = pairsToAnalyze.(2)(row);

FSIspikes = database(FSIindex).trial_spikes;
N2spikes = database(N2index).trial_spikes;

% Get the output values
try
    [fitresult, gof, xnew, ynew, Rval, Pval] = plotDynamicsDoublet( ...
        N2spikes, FSIspikes, 1.33, 1);
    coeffA = fitresult.a;
    coeffB = fitresult.b;
    plot(xnew, ynew, 'o', 'Color', 'blue');
    hold on;
    x_fit = linspace(min(xnew), max(xnew), 100);
    y_fit = coeffA*x_fit + coeffB;
    plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'blue');
    hold off;
    xlabel("FSI Firing Rate", "Interpreter","latex");
    ylabel(sprintf("%s Firing Rate", N2label),"Interpreter","latex");
    title(sprintf("FSI: %d, %s: %d\n R^2 = %.2f, a = %.2f, b = %.2f", ...
        pairsToAnalyze.(1)(row), N2label, pairsToAnalyze.(2)(row), ...
        gof.rsquare, coeffA, coeffB));

catch
    fprintf('Error');
end