% Date: 10/09/2023
% This function extracts fitting parameters of pairs between two
% different types of neuron. Then it plots the parameters.
% Please note that that this is not same pairs as of triplet.

% twdbs = load("twdbs.mat");

% Load database data
databaseData = cell(1,3);
databaseData{1} = twdbs.twdb_control;
databaseData{2} = twdbs.twdb_stress;
databaseData{3} = twdbs.twdb_stress2;
databaseDataLabel = {'control Data', 'stress Data', 'stress2 Data'};

% Load pair data
pairData = cell(1,3);
pairData{1} = load('pairsTableControl.mat');
pairData{2} = load('pairsTableStress.mat');
pairData{3} = load('pairsTableStress2.mat');


%% Analysis
coeffA = cell(1, 3);
coeffB = cell(1, 3);
allGOF = cell(1, 3);
RvalArray = cell(1, 3);

for group = 1:3
    loadFile = pairData{group};
    fsiStrioPairs = loadFile.pairsTable{1}; % Carefully choose pair

    for row = 1:size(fsiStrioPairs,1)
        FSIindex = fsiStrioPairs.(1)(row);
        STRIOindex = fsiStrioPairs.(2)(row);

        data = databaseData{group};
        FSIspikes = data(FSIindex).trial_spikes;
        STRIOspikes = data(STRIOindex).trial_spikes;

        % Get the output values
        try
            [fitresult, gof, xnew, ynew, Rval, Pval] = plotDynamicsDoublet( ...
                FSIspikes, STRIOspikes, 1.33, 1);

            coeffA{group}(row) = fitresult.a;
            coeffB{group}(row) = fitresult.b;
            allGOF{group}(row) = gof.rsquare;
            RvalArray{group}(row) = Rval;

        catch
            fprintf('Skipping iteration %d due to an error.\n', row);
        end

    end % neuron pair loop

    % If you want negative slope
    negR = RvalArray{group} <= 0;
    coeffA{group} = coeffA{group}(negR);
    coeffB{group} = coeffB{group}(negR);
    allGOF{group} = allGOF{group}(negR);

end % database loop


% Extract average data and standard error
aData = cell(1,3);
bData = cell(1,3);
gofData = cell(1,3);

avgA = zeros(1,3);
avgB = zeros(1,3);
avgGOF = zeros(1,3);

sdErrA = zeros(1,3);
sdErrB = zeros(1,3);
sdErrGOF = zeros(1,3);

for group = 1:3
    aData{group} = coeffA{group}(coeffA{group} ~= 0);
    bData{group} = coeffB{group}(coeffB{group} ~= 0);
    gofData{group} = allGOF{group}(allGOF{group} > 0 & allGOF{group} <= 1);

    avgA(group) = mean(aData{group}, 'omitnan');
    avgB(group) = mean(bData{group}, 'omitnan');
    avgGOF(group) = mean(gofData{group}, 'omitnan');

    sdErrA(group) = std(aData{group})/sqrt(numel(aData{group}));
    sdErrB(group) = std(bData{group})/sqrt(numel(bData{group}));
    sdErrGOF(group) = std(gofData{group})/sqrt(numel(gofData{group}));

end

figure(1);
set(gcf, 'Windowstyle', 'docked');
subplot(1,2,1);
bar(avgA);
hold on;
errorbar(1:numel(avgA), avgA, sdErrA, 'k.', 'LineWidth', 1.5);
% Perform two-sample t-tests and print on the figure
myStat(aData, avgA, databaseDataLabel);

subplot(1,2,2);
bar(avgB);
hold on;
errorbar(1:numel(avgB), avgB, sdErrB, 'k.', 'LineWidth', 1.5);
hold off;
myStat(bData, avgB, databaseDataLabel);

figure(2);
set(gcf, 'Windowstyle', 'docked');
bar(avgGOF);
hold on;
errorbar(1:numel(avgGOF), avgGOF, sdErrGOF, 'k.', 'LineWidth', 1.5);
hold off;
myStat(gofData, avgGOF, databaseDataLabel);