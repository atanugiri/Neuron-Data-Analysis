% Date: 06/27/2023
% This function plots the fit between PLS and FSI or FSI and Striosome for
% FSI, PLS, and Striosome triplets. This function is used to extract
% all goodness of fit corresponding to each bin size.

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

% Check Which triplet you want to analyze
firstPair = loadFile.pairsTable{3}; % fsiPlsPairs
secondPair = loadFile.pairsTable{1}; % fsiStriosomePairs

% Get the triplets
fsiPlsStrioTriplets = innerjoin(firstPair, secondPair, 'Keys', 'fsiIndex');

% You can play with bintime
bintime = [0.5, 1:10]; % bintime = 0.5:0.25:3;
fitTypeChoice = 1;

% Initialize empty arrays
fitresultArray = cell(size(fsiPlsStrioTriplets, 1), numel(bintime));
gofArray = cell(size(fsiPlsStrioTriplets, 1), numel(bintime));
xValArray = cell(size(fsiPlsStrioTriplets, 1), numel(bintime));
yValArray = cell(size(fsiPlsStrioTriplets, 1), numel(bintime));


% Check the plot shape with current bin time
for bintimeIdx = 1:numel(bintime)
    for i = 1:size(fsiPlsStrioTriplets,1)
        FSIindex = fsiPlsStrioTriplets.fsiIndex(i);
        STRIOindex = fsiPlsStrioTriplets.striosomeIndex(i);
        PLSindex = fsiPlsStrioTriplets.plsIndex(i);

        FSIspikes = database(FSIindex).trial_spikes;
        STRIOspikes = database(STRIOindex).trial_spikes;
        PLSspikes = database(PLSindex).trial_spikes;

        try
            switch fitTypeChoice
                case 1
                    [fitresult, gof, xnew, ynew] = plotDynamicsDoublet(PLSspikes, FSIspikes, bintime(bintimeIdx), fitTypeChoice);
                case 2
                    [fitresult, gof, xnew, ynew] = plotDynamicsDoublet(FSIspikes, STRIOspikes, bintime(bintimeIdx), fitTypeChoice);
            end
            % Store the result in the array
            fitresultArray{i,bintimeIdx} = fitresult;
            gofArray{i,bintimeIdx} = gof;
            xValArray{i,bintimeIdx} = xnew;
            yValArray{i,bintimeIdx} = ynew;

        catch
            fprintf('Skipping iteration %d due to an error.\n', i);
        end
    end
end

% Close all figure windows
close all;