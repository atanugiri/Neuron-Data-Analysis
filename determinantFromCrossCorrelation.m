% Date: 08/01/2023
% Author: Atanu Giri
% This script takes matrix of all neurons in same session for
% cross-correlation calculation

clearvars -except twdbs; clc; close all;

% twdbs = load("twdbs.mat");

% Ask user for neuron type
neuronType = input("Enter neuron type for analysis: ('FSI', 'Striosome', " + ...
    "'PLS', 'PL', or 'Matrix'): ", 's');

databaseData = cell(1, 3);
databaseDataLabel = {'controlData', 'stressData', 'stress2Data'};

% Load data
databaseData{1} = load(sprintf("sessionDataOf%sneuronsINcontrol.mat", neuronType));
databaseData{2} = load(sprintf("sessionDataOf%sneuronsINstress.mat", neuronType));
databaseData{3} = load(sprintf("sessionDataOf%sneuronsINstress2.mat", neuronType));

% place holder for all data
allData = cell(1,3);

% Load the grouped neuron matrix
for group = 1:numel(databaseData)
    binCtMatrixData = databaseData{group}.binCountMatrixWoNorm;
    binCtMatrixData = binCtMatrixData(~cellfun(@isempty, binCtMatrixData));

    % Cross-correlation container
    crossCorrelationResults = cell(numel(binCtMatrixData), 1);

    % Calculate cross-correlation for pairs of neurons within each session
    maxLag = 5;  % Maximum lag for cross-correlation

    for session = 1:numel(binCtMatrixData)
        sessionData = binCtMatrixData{session};
        numNeurons = size(sessionData, 1);

        crossCorrelationMatrix = zeros(numNeurons);

        for neuron1 = 1:numNeurons
            for neuron2 = neuron1:numNeurons
                timeSeries1 = sessionData(neuron1, :);
                timeSeries2 = sessionData(neuron2, :);

                crossCorr = xcorr(timeSeries1, timeSeries2, maxLag, 'coeff');

                crossCorrelationMatrix(neuron1, neuron2) = max(crossCorr);
                crossCorrelationMatrix(neuron2, neuron1) = max(crossCorr);
            end
        end

        crossCorrelationResults{session} = crossCorrelationMatrix;
    end

    allData{group} = crossCorrelationResults;
end

% place holder for average data and standard error
avgDet = zeros(1,3);
stdErr = zeros(1,3);
allDet = cell(1,3);

for group = 1:numel(databaseData)
    determinantArray = zeros(numel(allData{group}), 1);
    % Calculate Determinant
    for session = 1:numel(allData{group})
        determinantArray(session) = det(allData{group}{session});
    end

    % Obtain average and standard error
    determinantArray = determinantArray(isfinite(determinantArray));
    allDet{group} = determinantArray;
    avgDet(group) = mean(determinantArray);
    stdErr(group) = std(determinantArray)/sqrt(numel(determinantArray));
end

bar(avgDet);
hold on;
errorbar(1:numel(avgDet), avgDet, stdErr, 'k.', 'LineWidth', 1.5);
ylabel('Determinant','Interpreter', 'latex', 'FontSize', 20);
title(sprintf('Determinant Plot of %s', neuronType), ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');

% t-test2
[~, pValue1] = ttest2(allDet{1}, allDet{2});
[~, pValue2] = ttest2(allDet{1}, allDet{3});

try
    text(2, 1.1 * max(avgDet), ['p = ', num2str(pValue1)], 'Interpreter', 'latex', ...
        'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);

    text(3, 1.1 * max(avgDet), ['p = ', num2str(pValue2)], 'Interpreter', 'latex', ...
        'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);

    text(3.5, 0.75*max(avgDet), sprintf('n_{Control} = %d\n n_{Stress} = %d\n n_{Stress2} = %d', ...
    numel(allDet{1}), numel(allDet{2}), numel(allDet{3})), 'FontSize', 30, 'FontWeight', 'bold');
catch
    disp('Something went wrong.')
end