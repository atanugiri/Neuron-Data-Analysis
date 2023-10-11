% date: 07/05/2023
% Author: Atanu Giri

% twdbs = load("twdbs.mat");
twdb_control = twdbs.twdb_stress;

loadFile1 = load('fsiPlsPairsStress.mat');
fsiPlsPairs = loadFile1.fsiPlsPairsStress;

loadFile2 = load('fsiStriosomePairsStress.mat');
fsiStriosomePairs = loadFile2.fsiStriosomePairsStress;

% Get the triplets
fsiPlsStrioTriplets = innerjoin(fsiPlsPairs, fsiStriosomePairs, 'Keys', 'fsiIndex');

% Get fieldvalue for each triplet array
[fsiTaskType, fsiConc] = fieldFetch(fsiPlsStrioTriplets.fsiIndex, twdb_control);
[plsTaskType, plsConc] = fieldFetch(fsiPlsStrioTriplets.plsIndex, twdb_control);
[strioTaskType, strioConc] = fieldFetch(fsiPlsStrioTriplets.striosomeIndex, twdb_control);

% Find the indices where all arrays have entry 'CB'
commonTaskIndices = find(strcmp(fsiTaskType, 'CB') & strcmp(plsTaskType, 'CB') & ...
    strcmp(strioTaskType, 'CB'));
fsiPlsStrioTriplets = fsiPlsStrioTriplets(commonTaskIndices',:);


function [neronTaskType, neuronConc] = fieldFetch(neuronIndices, database)
neronTaskType = {database(neuronIndices).taskType};
neuronConc = [database(neuronIndices).conc];
end