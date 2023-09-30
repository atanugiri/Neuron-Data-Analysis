% Date: 07/27/2023
% Author: Atanu Giri

% This script plots bar of detreminants, trace and variance for control vs stress
% vs stress2 database without splliting them by task type or concentration

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

% Ask user for fetaure
feature = input("Which feature do you want to analyze ('Determinant', 'Trace' or " + ...
    "'Variance'): ", 's');

if strcmpi(feature, 'Determinant')
    fld = "binCountMatrixWoNorm";
elseif strcmpi(feature, 'Trace')
    fld = "binCountMatrixWoNorm";
elseif strcmpi(feature, 'Variance')
    fld = "binCountMatrixWoNorm";
    matrixDim = input("Which variance you want to analyze? ('withinNeuron', " + ...
        "'betweenNeuron'): ",'s');
else
    disp("Please check your input.\n");
    return;
end

% place holder for average data and standard error
avData = zeros(1,3);
stdErr = zeros(1,3);
allData = cell(1,3);
neuronCount = zeros(1,3);
allBinCountData = cell(1,3);


for group = 1:numel(databaseData)
    data = databaseData{group}.(sprintf("%s", fld));

    % Because Determinant has both real and imaginary part
    if strcmpi(feature, 'Determinant')
        binCountData = data(~cellfun(@isempty, data));
        featureVal = zeros(numel(binCountData),1);
        for session = 1:numel(binCountData)
            covMat = cov(binCountData{session}');
            covDet = det(covMat);
            numNeuron = size(covMat,1);
            featureVal(session, 1) = covDet / prod(diag(covMat))^numNeuron;
        end
    end

    if strcmpi(feature, 'Variance') && strcmpi(matrixDim, 'withinNeuron')
        % Remove empty cells of session for Variance analysis
        binCountData = data(~cellfun(@isempty, data));
        variances = cellfun(@(x) var(x, 0, 2, 'omitnan'), binCountData, 'UniformOutput', false);
        featureVal = vertcat(variances{:});
    end

    if strcmpi(feature, 'Variance') && strcmpi(matrixDim, 'betweenNeuron')
        binCountData = data(~cellfun(@isempty, data));
        binCountData = cell2mat(binCountData);
        featureVal = mean(binCountData,2,"omitnan");
    end

    featureVal = featureVal(isfinite(featureVal));
    allData{group} = featureVal;
    avData(group) = mean(featureVal);
    stdErr(group) = std(featureVal)/sqrt(numel(featureVal));
end

%% Bar plot
if strcmpi(feature, 'Variance') && strcmpi(matrixDim, 'betweenNeuron')
    % Calculate variance data
    varData = zeros(1, numel(allData));
    for group = 1:numel(allData)
        varData(group) = var(allData{group});
    end

    % Bar plot
    bar(varData);
    hold on;

    % Calculate lower and upper confidence interval
    upperCI = zeros(1, numel(allData));
    lowerCI = zeros(1, numel(allData));
    for group = 1:numel(allData)
        dF = numel(allData{group}) - 1;
        A = chi2inv(0.975, dF);
        B = chi2inv(0.025, dF);
        lowerCI(group) = (dF * varData(group)) / A;
        upperCI(group) = (dF * varData(group)) / B;
    end
    errorbar(1:numel(varData), varData, lowerCI, upperCI, 'k.', 'LineWidth', 1.5);
else
    bar(avData);
    hold on;
    errorbar(1:numel(avData), avData, stdErr, 'k.', 'LineWidth', 1.5);
end

hold off;
xticks(1:numel(databaseData));
xticklabels(databaseDataLabel);
xtickangle(45);

xlabel('Group', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(sprintf('Average %s', feature), 'Interpreter', 'latex', 'FontSize', 20);
title(sprintf('%s Plot of %s', feature, neuronType), ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');


%% Statistics
if strcmpi(feature, 'Variance') && strcmpi(matrixDim, 'betweenNeuron')
    % Perform F-test
    [~, pValue1] = vartest2(allData{1}, allData{2});
    [~, pValue2] = vartest2(allData{1}, allData{3});
else
    % Perform two-sample t-tests and print on the figure
    [~, pValue1] = ttest2(allData{1}, allData{2});
    [~, pValue2] = ttest2(allData{1}, allData{3});
end

% print on figure
try
    text(2, 1.1*max(avData), ['p = ', num2str(pValue1)], 'Interpreter', 'latex', ...
        'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);

    text(3, 1.1*max(avData), ['p = ', num2str(pValue2)], 'Interpreter', 'latex', ...
        'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Rotation', 45, 'Color', [0.8 0 0]);

    text(3.5, 0.75*max(avData), sprintf('n_{Control} = %d\n n_{Stress} = %d\n n_{Stress2} = %d', ...
    numel(allData{1}), numel(allData{2}), numel(allData{3})), ...
    'FontSize', 30, 'FontWeight', 'bold');

catch
    disp('Something went wrong.')
end

% save figure
% savefig(gcf, sprintf('barPlotOf%sFor%swoDataSplitting.fig', feature, neuronType));