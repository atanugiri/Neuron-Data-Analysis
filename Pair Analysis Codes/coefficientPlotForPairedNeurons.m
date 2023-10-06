% Date: 08/04/2023
% Author: Atanu Giri

% This script will plot coefficients of paired neurons of FSI and PLS

clearvars -except twdbs; clc;

%% Analysis
databaseData = cell(1, 3);
databaseDataLabel = {'control Data', 'stress Data', 'stress2 Data'};

% Load data
databaseData{1} = load("pairsTableControl.mat");
databaseData{2} = load("pairsTableStress.mat");
databaseData{3} = load("pairsTableStress2.mat");

fitData = cell(1, 3);
fitData{1} = databaseData{1}.fitData;
fitData{2} = databaseData{2}.fitData;
fitData{3} = databaseData{3}.fitData;

plotType = input("Enter desired plot: 'PLSvsFSI', 'FSIvsSTRIO', or 'PLSvsSTRIO': ",'s');

if strcmpi(plotType, 'PLSvsFSI')
    fitResultArray_Pair = 'fitresultArray_PLSvsFSI';
    rValArray_Pairs = 'rValArray_PLSvsFSI';
    pValArray_Pairs = 'pValArray_PLSvsFSI';
    neuronType1 = 'plsIndex';
    neuronType2 = 'fsiIndex';
    coeff1 = 'a';
    coeff2 = 'b';
    gof = 'gofArray_PLSvsFSI';


elseif strcmpi(plotType, 'PLSvsSTRIO')
    fitResultArray_Pair = 'fitResultArray_PLSvsSTRIO';
    rValArray_Pairs = 'rValArray_PLSvsSTRIO';
    pValArray_Pairs = 'pValArray_PLSvsSTRIO';
    neuronType1 = 'plsIndex';
    neuronType2 = 'striosomeIndex';
    coeff1 = 'c';
    coeff2 = 'd';
    gof = 'gofArray_PLSvsSTRIO';

end

% Placeholder for a and b
coeffA = cell(1, numel(databaseData));
coeffB = cell(1, numel(databaseData));
Rstat = cell(1, numel(databaseData));
Pstat = cell(1, numel(databaseData));
allGOF = cell(1, numel(databaseData));

% Do not collect duplicate entries
uniquePairs = cell(1, numel(databaseData));

% Extract a and b
for group = 1:numel(fitData)
    fitresultArray = fitData{group}.(fitResultArray_Pair);
    rValArray = fitData{group}.(rValArray_Pairs);
    pValArray = fitData{group}.(pValArray_Pairs);
    filter = rValArray >= 0 & pValArray <= 0.05;
    gofArray = fitData{group}.(gof);
    uniquePairs{group} = [nan, nan];

    % If you want only positive slope and good fit
    %     for row = 1:numel(fitresultArray)
    %         try
    %             abResult = coeffvalues(fitresultArray{row});
    %
    %             if filter(row)
    %                 coeffA{group} = [coeffA{group}; abResult(1)];
    %                 coeffB{group} = [coeffB{group}; abResult(2)];
    %             end
    %         catch
    %             disp("No fit data for this pair.")
    %         end
    %     end

    for row = 1:numel(fitresultArray)
        try
            rowPair = [fitData{group}.(neuronType1)(row), fitData{group}.(neuronType2)(row)];
            if ~ismember(rowPair, uniquePairs{group}, 'rows')
                uniquePairs{group} = [uniquePairs{group};
                    [fitData{group}.(neuronType1)(row), fitData{group}.(neuronType2)(row)]];
                fitResult = fitresultArray{row};
                coeffA{group} = [coeffA{group}; fitResult.(coeff1)];
                coeffB{group} = [coeffB{group}; fitResult.(coeff2)];
                Rstat{group} = [Rstat{group}; fitData{group}.(rValArray_Pairs)(row)];
                Pstat{group} = [Pstat{group}; fitData{group}.(pValArray_Pairs)(row)];
                currentGof = fitData{group}.(gof){row};
                allGOF{group} = [allGOF{group}; currentGof.rsquare]; 
            else
                continue
            end

        catch
            fprintf("Fittng data not found.\n")
        end

    end

end


%% Dot plot
% figure(1);
% plotColor = ['r', 'g', 'b'];
% for group = 1:numel(databaseData)
%     plot(coeffA{group}, coeffB{group}, '.', 'MarkerSize', 20, 'Color', plotColor(group));
%     hold on;
% end
% hold off;
% legend(["Control", "Stress", "Stress2"]);
% xlabel("coefficient a", "Interpreter","latex","FontSize",20);
% ylabel("coefficient b", "Interpreter","latex","FontSize",20);
% title("PLS vs FSI Coefficient Plot", "Interpreter", "latex", "FontSize", 30);

%% Bar plot of a and b

% Placeholder for average data and standard error
avgDataOfA = zeros(1, numel(databaseData));
avgDataOfB = zeros(1, numel(databaseData));
avgDataOfR = zeros(1, numel(databaseData));
avgDataOfP = zeros(1, numel(databaseData));
avgDataOfGOF = zeros(1, numel(databaseData));


stdErrOfA = zeros(1, numel(databaseData));
stdErrOfB = zeros(1, numel(databaseData));
stdErrOfR = zeros(1, numel(databaseData));
stdErrOfP = zeros(1, numel(databaseData));
stdErrOfGOF = zeros(1, numel(databaseData));


% Extract average data and standard error
for group = 1:numel(databaseData)
    aData = coeffA{group}(isfinite(coeffA{group}));
    bData = coeffB{group}(isfinite(coeffB{group}));
    rData = Rstat{group}(isfinite(Rstat{group}));
    pData = Pstat{group}(isfinite(Pstat{group}));
    gofData = allGOF{group}(isfinite(allGOF{group}));

    coeffA{group} = aData;
    coeffB{group} = bData;
    Rstat{group} = rData;
    Pstat{group} = pData;
    allGOF{group} = gofData;

    avgDataOfA(group) = mean(aData);
    avgDataOfB(group) = mean(bData);
    avgDataOfR(group) = mean(rData);
    avgDataOfP(group) = mean(pData);
    avgDataOfGOF(group) = mean(gofData);

    stdErrOfA(group) = std(aData)/sqrt(numel(aData));
    stdErrOfB(group) = std(bData)/sqrt(numel(bData));
    stdErrOfR(group) = std(rData)/sqrt(numel(rData));
    stdErrOfP(group) = std(pData)/sqrt(numel(pData));
    stdErrOfGOF(group) = std(gofData)/sqrt(numel(gofData));

end

figure(1);
subplot(1,2,1);
bar(avgDataOfA);
hold on;
errorbar(1:numel(avgDataOfA), avgDataOfA, stdErrOfA, 'k.', 'LineWidth', 1.5);
% Perform two-sample t-tests and print on the figure
myStat(coeffA, avgDataOfA, databaseDataLabel);

if strcmpi(plotType, 'PLSvsFSI')
    title("PLS vs FSI correlation: Coeff. A");
elseif strcmpi(plotType, 'PLSvsSTRIO')
    title("PLS vs STRIO correlation: Coeff. C");
end

subplot(1,2,2);
bar(avgDataOfB);
hold on;
errorbar(1:numel(avgDataOfB), avgDataOfB, stdErrOfB, 'k.', 'LineWidth', 1.5);
hold off;
myStat(coeffB, avgDataOfB, databaseDataLabel);

if strcmpi(plotType, 'PLSvsFSI')
    title("PLS vs FSI correlation: Coeff. B");
elseif strcmpi(plotType, 'PLSvsSTRIO')
    title("PLS vs STRIO correlation: Coeff. D");
end

figure(2);
bar(avgDataOfGOF);
hold on;
errorbar(1:numel(avgDataOfGOF), avgDataOfGOF, stdErrOfGOF, 'k.', 'LineWidth', 1.5);
hold off;
myStat(allGOF, avgDataOfGOF, databaseDataLabel);

if strcmpi(plotType, 'PLSvsFSI')
    title("PLS vs FSI correlation: R^{2}");
elseif strcmpi(plotType, 'PLSvsSTRIO')
    title("PLS vs STRIO correlation: R^{2}");
end

%% R and P plot
% figure(3);
% subplot(1,2,1);
% bar(avgDataOfR);
% hold on;
% errorbar(1:numel(avgDataOfR), avgDataOfR, stdErrOfR, 'k.', 'LineWidth', 1.5);
% myStat(Rstat, avgDataOfR, databaseDataLabel);
% title("PLS vs STRIO correlation: R statistics");
%
% subplot(1,2,2);
% bar(avgDataOfP);
% hold on;
% errorbar(1:numel(avgDataOfP), avgDataOfP, stdErrOfP, 'k.', 'LineWidth', 1.5);
% hold off;
% myStat(Pstat, avgDataOfP, databaseDataLabel);
% title("PLS vs STRIO correlation: P statistics");

%% Histogram of a and b
% figure(3);
% for group = 1:numel(databaseData)
%     subplot(1,3,group);
%     histogram(coeffA{group}, 40, 'Normalization','probability');
%     ylim([0 1]);
%     xlabel('a value');
% end
% sgtitle("Histogram of coefficient a");
%
% figure(4);
% for group = 1:numel(databaseData)
%     subplot(1,3,group);
%     histogram(coeffB{group}, 40, 'Normalization','probability');
%     ylim([0 1]);
%     xlabel('b value');
% end
% sgtitle("Histogram of coefficient b");


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