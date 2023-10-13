% Date: 10/11/2023
% Author: Atanu Giri
% This function plots the fitting parameters of pairs between two
% different types of neuron in PLS-FSI-Strio triplet.

% twdbs = load("twdbs.mat");
close all;
databaseDataLabel = {'control Data', 'stress Data', 'stress2 Data'};

% Invoke function extractPairedNeuronsInTriplet
pairsInTriplet = extractPairedNeuronsInTriplet;

% Invoke function extarctFitParameters
[coeffA, coeffB, allGOF] = extarctLinearFitParameters(pairsInTriplet, twdbs);

[aData, avgA, sdErrA] = extractPlotValues(coeffA);
[bData, avgB, sdErrB] = extractPlotValues(coeffB);
[gofData, avgGof, sdErrGof] = extractPlotValues(allGOF);

pairsTypeLabel = {'fsiPlsPair', 'fsiStrioPair', 'plsStrioPair'};

aDataSorted = sortData(aData);
bDataSorted = sortData(bData);
gofDataSorted = sortData(gofData);

avgAsorted = sortData(avgA);
avgBsorted = sortData(avgB);
avgGOFsorted = sortData(avgGof);

sdErrAsorted = sortData(sdErrA);
sdErrBsorted = sortData(sdErrB);
sdErrGOFsorted = sortData(sdErrGof);



for pairType = 1:3
    figure(pairType);
    set(gcf, 'Windowstyle', 'docked');
    subplot(1,2,1);
    bar(avgAsorted{pairType});
    hold on;
    errorbar(1:3, avgAsorted{pairType}, sdErrAsorted{pairType}, ...
        'k.', 'LineWidth', 1.5);
    % Perform two-sample t-tests and print on the figure
    myStat(aDataSorted{pairType}, avgAsorted{pairType}, databaseDataLabel);
    hold off;

    subplot(1,2,2);
    bar(avgBsorted{pairType});
    hold on;
    errorbar(1:3, avgBsorted{pairType}, sdErrBsorted{pairType}, ...
        'k.', 'LineWidth', 1.5);
    myStat(bDataSorted{pairType}, avgBsorted{pairType}, databaseDataLabel);
    hold off;

end

for pairType = 1:3
    figure(pairType+3);
    set(gcf, 'Windowstyle', 'docked');
    bar(avgGOFsorted{pairType});
    ylim([0 1]);
    hold on;
    errorbar(1:3, avgGOFsorted{pairType}, sdErrGOFsorted{pairType}, ...
        'k.', 'LineWidth', 1.5);
    myStat(gofDataSorted{pairType}, avgGOFsorted{pairType}, databaseDataLabel);
    hold off;
end


%% Description of sortData
function sortedData = sortData(data)

sortedData = cell(1,3);

if iscell(data{1})
    for pairType = 1:3
        for group = 1:3
            sortedData{pairType}{group} = data{group}{pairType};
        end
    end

elseif isa(data{1}, 'double')
    for pairType = 1:3
        for group = 1:3
            sortedData{pairType}(group) = data{group}(pairType);
        end
    end

else
    fprintf('Check input data');
end

end

%% Description of extractPlotValues
function [cleanedData, avg, sdErr] = extractPlotValues(rawData)

cleanedData = cell(1,3);
avg = cell(1,3);
sdErr = cell(1,3);

for group = 1:3
    for pair = 1:3
        cleanedData{group}{pair} = rawData{group}{pair}(isfinite(rawData{group}{pair}));
        avg{group}(pair) = mean(cleanedData{group}{pair});
        sdErr{group}(pair) = std(cleanedData{group}{pair})/sqrt(numel(cleanedData{group}{pair}));
    end

end
end

%% Description of myStat
function myStat(coeffientData, averageData, databaseDataLabel)

% Perform two-sample t-tests and print on the figure
[~, pValue1] = ttest2(coeffientData{1}, coeffientData{2});
[~, pValue2] = ttest2(coeffientData{1}, coeffientData{3});
text(2, 0.9*max(averageData), ['p = ', num2str(pValue1)], 'Interpreter', 'latex', ...
    'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'Rotation', 45, 'Color', [0.8 0 0]);
text(3, 0.9*max(averageData), ['p = ', num2str(pValue2)], 'Interpreter', 'latex', ...
    'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'Rotation', 45, 'Color', [0.8 0 0]);

xticks(1:numel(databaseDataLabel));
xticklabels(databaseDataLabel);
xtickangle(45);
text(3.5, max(averageData), sprintf('n_{Control} = %d\n n_{Stress} = %d\n n_{Stress2} = %d', ...
    numel(coeffientData{1}), numel(coeffientData{2}), numel(coeffientData{3})), ...
    'FontSize', 30, 'FontWeight', 'bold');

end