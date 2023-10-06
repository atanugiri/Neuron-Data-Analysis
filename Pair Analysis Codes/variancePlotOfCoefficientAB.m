% Date: 08/15/2023
% Author: Atanu Giri

% This script plots variance of coefficients (a, b) of paired neurons of
% FSI and PLS

clearvars -except twdbs; clc;

%% Analysis
databaseData = cell(1, 3);
databaseDataLabel = {'control Data', 'stress Data', 'stress2 Data'};

% Load data
databaseData{1} = load("gofForAllBinsOffsiPlsPairsInControl.mat");
databaseData{2} = load("gofForAllBinsOffsiPlsPairsInStress.mat");
databaseData{3} = load("gofForAllBinsOffsiPlsPairsInStress2.mat");

% Placeholder for a and b
coeffA = cell(1, numel(databaseData));
coeffB = cell(1, numel(databaseData));

% Extract a and b
for group = 1:numel(databaseData)
    fitresultArray = databaseData{group}.fitresultArray;
    rValArray = databaseData{group}.rValArray;
    pValArray = databaseData{group}.pValArray;
    filter = rValArray >= 0 & pValArray <= 0.05;

    for row = 1:numel(fitresultArray)
        try
            abResult = coeffvalues(fitresultArray{row});

            if filter(row)
                coeffA{group} = [coeffA{group}; abResult(1)];
                coeffB{group} = [coeffB{group}; abResult(2)];
            end
        catch
            disp("No fit data for this pair.")
        end
    end
end

% Variance plot of a and b
[varOfA, lowerCI_A, upperCI_A] = varianceCalculation(coeffA);
myPlot(varOfA, lowerCI_A, upperCI_A, coeffA, databaseDataLabel);
ylabel("Variance of Coeff A", 'Interpreter', 'latex', 'FontSize', 20);
title("Coefficient Plot: PLS vs FSI", ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');

[varOfB, lowerCI_B, upperCI_B] = varianceCalculation(coeffB);
myPlot(varOfB, lowerCI_B, upperCI_B, coeffB, databaseDataLabel);
ylabel("Variance of Coeff B", 'Interpreter', 'latex', 'FontSize', 20);
title("Coefficient Plot: PLS vs FSI", ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');



%% Description of varianceCalculation
function [varianceData, lowerCI, upperCI] = varianceCalculation(coeffData)
varianceData = zeros(numel(coeffData), 1);
lowerCI = zeros(numel(coeffData), 1);
upperCI = zeros(numel(coeffData), 1);

for group = 1:numel(coeffData)
    varianceData(group) = var(coeffData{group},'omitnan');
    dF = numel(coeffData{group}) - 1;
    A = chi2inv(0.975, dF);
    B = chi2inv(0.025, dF);
    lowerCI(group) = (dF * varianceData(group)) / A;
    upperCI(group) = (dF * varianceData(group)) / B;
end
end

%% Description of myPlot
function myPlot(varianceData, lowerCI, upperCI, coeffData, databaseDataLabel)
figure;
bar(varianceData);
hold on;
errorbar(1:numel(varianceData), varianceData, lowerCI, upperCI, ...
    'k.', 'LineWidth', 1.5);
xticklabels(databaseDataLabel);
xtickangle(45);

% Perform F-test
[~, pValue1] = vartest2(coeffData{1}, coeffData{2});
[~, pValue2] = vartest2(coeffData{1}, coeffData{3});

% print statistics on figure
try
    text(2, 1.1*max(varianceData), ['p = ', num2str(pValue1)], 'Interpreter', 'latex', ...
        'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);

    text(3, 1.1*max(varianceData), ['p = ', num2str(pValue2)], 'Interpreter', 'latex', ...
        'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);
catch
    disp('Something went wrong.')
end
end