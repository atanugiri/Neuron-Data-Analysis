% Date: 08/03/2023
% This function plots the fit between PLS and FSI or FSI and Striosome
% pairs. This function is used to extract all goodness of fit corresponding
% to each bin size.

%% Invokes plotDynamicsDoublet function

clearvars -except twdbs; clc;

% Load the data file.
% twdbs = load("twdbs.mat");
% Ask user which database they want to analyze
dataTable = input("Which database you want to analyze ('twdb_control', 'twdb_stress', 'twdb_stress2'): ", 's');
database = twdbs.(sprintf('%s', dataTable));

if strcmpi(dataTable, 'twdb_control')
    loadFile = load('pairsTableControl.mat');
elseif strcmpi(dataTable, 'twdb_stress')
    loadFile = load('pairsTableStress.mat');
elseif strcmpi(dataTable, 'twdb_stress2')
    loadFile = load('pairsTableStress2.mat');
end

% Which pair you want to analyze
fsiPlsPairs = loadFile.pairsTable{3};

% You can play with bintime
bintime = [0.5, 1:10]; % bintime = 0.5:0.25:3 (FSI vs Strio Plot)
fitTypeChoice = 1;

% Initialize empty arrays
gofArray = cell(size(fsiPlsPairs, 1), numel(bintime));

% Check the plot shape with current bin time
for bintimeIdx = 1:numel(bintime)
    for i = 1:size(fsiPlsPairs,1)
        FSIindex = fsiPlsPairs.fsiIndex(i);
        PLSindex = fsiPlsPairs.plsIndex(i);

        FSIspikes = database(FSIindex).trial_spikes;
        PLSspikes = database(PLSindex).trial_spikes;

        try
            switch fitTypeChoice
                case 1
                    [~, gof, ~, ~] = plotDynamicsDoublet(PLSspikes, FSIspikes, bintime(bintimeIdx), fitTypeChoice);
                case 2
                    [~, gof, ~, ~] = plotDynamicsDoublet(FSIspikes, STRIOspikes, bintime(bintimeIdx), fitTypeChoice);
            end
            % Store the result in the array
            gofArray{i, bintimeIdx} = gof;

        catch
            fprintf('Skipping iteration %d due to an error.\n', i);
        end
    end
end

% Close all figure windows
close all;

% Example how to save
% save ("gofForAllBinsOffsiPlsPairsInControl", 'bintime', 'gofArray')