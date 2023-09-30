% Date: 08/14/2023
% Author: Atanu Giri

% This script plots Mean Firing Rate and Fano Factor for control vs stress
% vs stress2 database for a particular neuron type.

%% Analysis
clearvars -except twdbs; clc; close all;

% Ask user for neuron type
neuronType = input("Enter neuron type for analysis: ('FSI', 'Striosome', " + ...
    "'PLS', 'PL', or 'Matrix'): ", 's');

databaseData = cell(1, 3);
databaseDataLabel = {'controlData', 'stressData', 'stress2Data'};

% Load data
databaseData{1} = load(sprintf("sessionDataOf%sneuronsINcontrol.mat", neuronType));
databaseData{2} = load(sprintf("sessionDataOf%sneuronsINstress.mat", neuronType));
databaseData{3} = load(sprintf("sessionDataOf%sneuronsINstress2.mat", neuronType));

% Placeholder for Fano factor
fanoFactorOfAllGroup = cell(1, numel(databaseData));
avgFanoFactor = zeros(1, numel(databaseData));
stdErrFanoFactor = zeros(1, numel(databaseData));

firingRateOfGroup = cell(1, numel(databaseData));
meanFiringRateOfGroup = zeros(1, numel(databaseData));
stdErrFiringRateOfGroup = zeros(1, numel(databaseData));

for group = 1:numel(databaseData)
    firingRateData = databaseData{group}.binCountMatrixWoNorm;
    firingRateData = firingRateData(~cellfun(@isempty, firingRateData));
    variances = cellfun(@(x) var(x, 0, 2, 'omitnan'), firingRateData, ...
        'UniformOutput', false);
    variances = vertcat(variances{:});
    avgFiringRateNeuron = cellfun(@(x) mean(x, 2, 'omitnan'), firingRateData, ...
        'UniformOutput', false);
    avgFiringRateNeuron = vertcat(avgFiringRateNeuron{:});

    % Fano factor calculation
    fanoFactor = variances./avgFiringRateNeuron;
    fanoFactor = fanoFactor(isfinite(fanoFactor));
    fanoFactorOfAllGroup{group} = fanoFactor;
    avgFanoFactor(group) = mean(fanoFactor);
    stdErrFanoFactor(group) = std(fanoFactor)/sqrt(numel(fanoFactor));

    % Mean firing rate calculation
    avgFiringRateNeuron = avgFiringRateNeuron(isfinite(avgFiringRateNeuron));
    firingRateOfGroup{group} = avgFiringRateNeuron;
    meanFiringRateOfGroup(group) = mean(avgFiringRateNeuron);
    stdErrFiringRateOfGroup(group) = std(avgFiringRateNeuron)/ ...
        sqrt(numel(avgFiringRateNeuron));
end


%% Plotting
figure(1);
myBarPlot(avgFanoFactor, stdErrFanoFactor, fanoFactorOfAllGroup);
xticklabels(databaseDataLabel);
ylabel(sprintf('Average Fano Factor Data'), 'Interpreter', 'latex', 'FontSize', 20);
title(sprintf('Fano Factor Plot of %s', neuronType), ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');

figure(2);
myBarPlot(meanFiringRateOfGroup, stdErrFiringRateOfGroup, firingRateOfGroup);
xticklabels(databaseDataLabel);
ylabel(sprintf('Mean Firing Rate'), 'Interpreter', 'latex', 'FontSize', 20);
title(sprintf('Mean Firing Rate Plot of %s', neuronType), ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');


%% Description of myBarPlot
function myBarPlot(avgData, stdError, allData)
bar(avgData);
hold on;
errorbar(1:numel(avgData), avgData, stdError, 'k.', 'LineWidth', 1.5);
xtickangle(45);
xlabel('Group', 'Interpreter', 'latex', 'FontSize', 20);

% Statistics
[~, pValue1] = ttest2(allData{1}, allData{2});
[~, pValue2] = ttest2(allData{1}, allData{3});

% print statistics on figure
try
    text(2, 0.9*max(avgData), ['p = ', num2str(pValue1)], 'Interpreter', 'latex', ...
        'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);

    text(3, 0.9*max(avgData), ['p = ', num2str(pValue2)], 'Interpreter', 'latex', ...
        'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);

    text(3.5, 0.75*max(avgData), sprintf('n_{Control} = %d\n n_{Stress} = %d\n n_{Stress2} = %d', ...
    numel(allData{1}), numel(allData{2}), numel(allData{3})), ...
    'FontSize', 30, 'FontWeight', 'bold');

catch
    disp('Something went wrong.')
end
end