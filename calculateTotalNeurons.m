% % Date: 07/26/2023
% Author: Atanu Giri

% This script calculates 'total number of neurons' and 'number of neurons in individual group'
% for a particular neuron type

clearvars -except twdbs; clc;

% Ask user for neuron type
neuronType = input("Enter the neuron type for analysis: 'FSI', 'Striosome', 'PLS', or 'PL': ",'s');

% Folder where the .mat files are located
databaseType = input("Enter the databse: 'Control','Stress': ",'s');

if strcmpi(databaseType, 'Control')
    folderPath = sprintf(['/Users/atanugiri/Downloads/final stress project/AtanuCode/' ...
        'Grouped Neurons From Same Session/Same session %s neuron/Control db Results/' ...
        'Session Data of %s Neuron in Control db'], neuronType, neuronType);

elseif strcmpi(databaseType, 'Stress')
    folderPath = sprintf(['/Users/atanugiri/Downloads/final stress project/AtanuCode/' ...
        'Grouped Neurons From Same Session/Same session %s neuron/Stress db Results/' ...
        'Session Data of %s Neuron in Stress db'], neuronType, neuronType);

else
    disp("Please check your input.\n");
end

% Get a list of all .mat files in the folder
matFiles = dir(fullfile(folderPath, '*.mat'));

% Extract total neurons
groupNeuronCount = zeros(1, numel(matFiles));

for fileIdx = 1:numel(matFiles)
    matFileName = matFiles(fileIdx).name;
    fullFilePath = fullfile(folderPath, matFileName);

    loadFile = load(fullFilePath);
    allSessionNeuron = loadFile.groupedNeuron;
    allSessionNeuron = allSessionNeuron(~cellfun(@isempty, allSessionNeuron));
    groupNeuron = [];
    for session = 1:numel(allSessionNeuron)
        groupNeuron = [groupNeuron, allSessionNeuron{session}];
    end
    groupNeuronCount(fileIdx) = numel(groupNeuron);
    % Display result for the group
    fprintf("%s: Sessions: %d, Neurons: %d\n", matFileName, numel(allSessionNeuron), ...
        numel(groupNeuron));
end

% Return total neuron count
totalCount = sum(groupNeuronCount);
fprintf("Total number of neuron: %d\n", totalCount);