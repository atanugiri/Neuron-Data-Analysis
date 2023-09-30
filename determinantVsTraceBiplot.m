% Date: 07/24/2023
% Author: Atanu Giri

% This script plots determinant vs trace of session matrix

clearvars -except twdbs; clc;

% Ask user for neuron type
neuronType = input("Enter neuron type for analysis: ('PL' or 'PLS'): ", 's');

databaseData = cell(1, 3);
databaseDataLabel = {'controlData', 'stressData', 'stress2Data'};

% Load data
databaseData{1} = load(sprintf("sessionDataOf%sneuronsINcontrol.mat", neuronType));
databaseData{2} = load(sprintf("sessionDataOf%sneuronsINstress.mat", neuronType));
databaseData{3} = load(sprintf("sessionDataOf%sneuronsINstress2.mat", neuronType));

% Store feature for each database
detArray = cell(1,3);
traceArray = cell(1,3);


for index = 1:numel(databaseData)
    detArrayComplex = databaseData{index}.normDetCovMatArray;
    detArray{index} = sqrt(abs(detArrayComplex).^2);
    traceArray{index} = databaseData{index}.normTraceCovMatArray;
end


plotColor = {'b', 'r', 'g'};
% Plot data
for i = 1:numel(databaseData)
    scatter(detArray{i}, traceArray{i}, 25, plotColor{i}, 'filled');
    hold on;
end

hold off;
xlim([0 0.5*10^(-3)]);
ylim([0 0.004]);
