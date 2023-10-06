% Date: 08/03/2023
% Author: Atanu Giri

% This function plots doublets with best bintime for each pair of neuron.
% Extracts fitresult, xnew, and ynew for each pair

%% Invokes plotDynamicsDoublet function
%% fitTypeChoice: PLS vs FSI (1), FSI vs Srio (2), PLS vs Strio (3)

clearvars -except twdbs; clc;

% twdbs = load("twdbs.mat");
% Ask user which database they want to analyze
dataTable = input("Which database you want to analyze ('twdb_control', 'twdb_stress', 'twdb_stress2'): ", 's');
database = twdbs.(sprintf('%s', dataTable));

if strcmpi(dataTable, 'twdb_control')
    binData = load('gofForAllBinsOffsiPlsPairsInControl.mat');
    [~, fileName] = fileparts('gofForAllBinsOffsiPlsPairsInControl');
    pairData = load("pairsTableControl.mat");

elseif strcmpi(dataTable, 'twdb_stress')
    binData = load('gofForAllBinsOffsiPlsPairsInStress.mat');
    [~, fileName] = fileparts('gofForAllBinsOffsiPlsPairsInStress');
    pairData = load("pairsTableStress.mat");

elseif strcmpi(dataTable, 'twdb_stress2')
    binData = load('gofForAllBinsOffsiPlsPairsInStress2.mat');
    [~, fileName] = fileparts('gofForAllBinsOffsiPlsPairsInStress2');
    pairData = load("pairsTableStress2.mat");
end

% Which pair you want to analyze
fsiPlsPairs = pairData.pairsTable{3};

% Extract best bin time for individual pairs
bestBin = binData.bestBin;
% bestBin = ones(size(loadFile.bestBin, 1),1); % You can customize this

% Declare fitTypeChoice
fitTypeChoice = 1;

%% Data analysis
% Initialize empty arrays
fitresultArray = cell(size(fsiPlsPairs, 1), 1);
rValArray = zeros(size(fsiPlsPairs, 1), 1);
pValArray = zeros(size(fsiPlsPairs, 1), 1);
xValArray = cell(size(fsiPlsPairs, 1), 1);
yValArray = cell(size(fsiPlsPairs, 1), 1);

% Check the plot shape with current bin time
for row = 1:size(fsiPlsPairs,1)
    FSIindex = fsiPlsPairs.fsiIndex(row);
    PLSindex = fsiPlsPairs.plsIndex(row);

    FSIspikes = database(FSIindex).trial_spikes;
    PLSspikes = database(PLSindex).trial_spikes;

    % Get the output values
    try
        [fitresult, gof, Rval, Pval, xnew, ynew] = plotDynamicsDoublet( ...
            PLSspikes, FSIspikes, bestBin(row), fitTypeChoice);

        % Store the result in the array
        fitresultArray{row} = fitresult;
        rValArray(row) = Rval;
        pValArray(row) = Pval;
        xValArray{row} = xnew;
        yValArray{row} = ynew;
    catch
        fprintf('Skipping iteration %d due to an error.\n', row);
        continue;
    end
end

% Save outputs
save(fileName, 'xValArray', 'yValArray', 'fitresultArray', 'rValArray', 'pValArray', '-append');

%% Plotting
% Create a PDF file for saving the figures
pdf_file = 'doublet_plots_PLSvFSIbestBinContrl.pdf';
% Initialize the subplot counter
subplot_count = 0;
% Create a new figure
figure('Position', [100, 100, 1200, 800]);

for i = 1:size(fsiPlsPairs,1)
    % Increase subplot_count
    subplot_count = subplot_count+1;
    subplot(3, 5, subplot_count);
    try
        PLSindex = fsiPlsPairs.plsIndex(i);
        FSIindex = fsiPlsPairs.fsiIndex(i);
        PLSspikes = database(PLSindex).trial_spikes;
        FSIspikes = database(FSIindex).trial_spikes;
        plotDynamicsDoublet(PLSspikes, FSIspikes, bestBin(i), fitTypeChoice);
        current_title = get(gca, 'Title').String;
        % Create the new title text with additional information
        new_title = sprintf('%s\nPLS: %d, SWN: %d', current_title, PLSindex, FSIindex);

        % Set the new title text
        title(new_title);

        % Adjust the font size
        set(gca, 'FontSize', 10);

        % Add more space between subplots
        set(gca, 'LooseInset', get(gca, 'TightInset') + [0.05, 0.05, 0.05, 0.05]);

        % Save the figure as a PDF file
        if subplot_count == 15 || i == size(fsiPlsPairs, 1)
            % Save the current page and reset the subplot counter
            exportgraphics(gcf, pdf_file, 'ContentType', 'vector', 'Append', true);
            subplot_count = 0;
            % Create a new figure
            figure('Position', [100, 100, 1200, 800]);
        end

    catch
        fprintf('Skipping iteration %d due to an error.\n', i);
        continue;
    end
end

% Close all figure windows
close all;