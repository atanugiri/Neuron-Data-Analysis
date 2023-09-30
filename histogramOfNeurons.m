% Date: 07/01/2023
% This function plots boxplot and histogram for FSI, Striosome and PLS
% neurons

close all;
% twdbs = load("twdbs.mat");
% Input struct of twdbs
dataTable = input("Enter the struct you want for analysis: 'twdb_control' or 'twdb_stress':\n",'s');
if strcmpi(dataTable, 'twdb_control')
    database = twdbs.twdb_control;
    loadFile1 = load('fsiPlsPairsControl.mat');
    fsiPlsPairs = loadFile1.fsiPlsPairs;
    loadFile2 = load('fsiStriosomePairsControl.mat');
    fsiStriosomePairs = loadFile2.fsiStriosomePairs;
elseif strcmpi(dataTable, 'twdb_stress')
    database = twdbs.twdb_stress;
    loadFile1 = load('fsiPlsPairsStress.mat');
    fsiPlsPairs = loadFile1.fsiPlsPairsStress;
    loadFile2 = load('fsiStriosomePairsStress.mat');
    fsiStriosomePairs = loadFile2.fsiStriosomePairsStress;
else
    disp("Please check your input.\n");
    return;
end

% Get the triplets
fsiPlsStrioTriplets = innerjoin(fsiPlsPairs, fsiStriosomePairs, 'Keys', 'fsiIndex');

% Select neuron type you want to analyze
neuronType = input("Enter the neuron type for analysis: 'PLS', 'FSI', or 'Striosome'\n",'s');
if strcmpi(neuronType, 'PLS')
    uniqueNeuron = unique(fsiPlsStrioTriplets.plsIndex);
elseif strcmpi(neuronType, 'FSI')
    uniqueNeuron = unique(fsiPlsStrioTriplets.fsiIndex);
elseif strcmpi(neuronType, 'Striosome')
    uniqueNeuron = unique(fsiPlsStrioTriplets.striosomeIndex);
else
    disp("Please check your input.\n");
    return;
end

% Create container of Baseline Firing Rate for each neuron
neuronBLfiringRate = [];

% loop through
for row = 1:numel(uniqueNeuron)
    firingRate = database(uniqueNeuron(row)).baseline_firing_rate_data;
    neuronBLfiringRate = [neuronBLfiringRate, firingRate];
end

[f, numBins] = analysisPlot(neuronBLfiringRate);

% Add Info in the title
titleText = sprintf('%s, %s = %d, Num of bin = %d', dataTable, neuronType, numel(uniqueNeuron), numBins);
title(titleText,'Interpreter','latex','FontSize',30);
figName = sprintf('%s_%s', dataTable, neuronType);
savefig(f,sprintf('%s.fig',figName));

%% Write a function for box plot and histogram
% Boxplot
function [f, numBins] = analysisPlot(spikesArray)
f = figure;
subplot(1,2,1);
boxplot(spikesArray);
hold on;
% Add labels and title
xlabel('Baseline firing rate (Hz)','Interpreter','latex','FontSize',20);
ylabel('Values','Interpreter','latex','FontSize',20);

% Histogram
subplot(1,2,2);
numBins = 30;
spikesArray = spikesArray(~isoutlier(spikesArray));
histogram(spikesArray, numBins);
% histogram(lessThan50, num_bins);
hold off;
% ylim([0, 10]);
xlabel('Baseline firing rate (Hz)','Interpreter','latex','FontSize',20);
ylabel('Values','Interpreter','latex','FontSize',20);
end