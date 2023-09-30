% Date: 07/29/2023
% Author: Atanu Giri

% This script makes matrix of all neurons of a perticular type in desired
% database for covariance calculation. This script is complementary to 
% 'covAndBinCtMatrixOfNeuronsFromSameSession' script

clearvars -except twdbs;
clc;

% twdbs = load("twdbs.mat");

% Load the grouped neuron matrix
loadFile = load("sameSessionPLneuronsINcontrol.mat");
groupedNeuron = loadFile.groupedNeuronIdx;

% Extract the file name without the extension
[~, fileNameWithoutExt, ~] = fileparts("sameSessionPLneuronsINcontrol");

% Use regular expressions to extract the desired part of the file name for
% title
pattern = 'sameSession(.+)'; % Matches any characters between 'sessionDataOf' and '_filteredBins'
match = regexp(fileNameWithoutExt, pattern, 'tokens');
if ~isempty(match)
    titlePart = match{1}{1}; % Extract the desired part from the matched tokens
else
    titlePart = 'Unknown'; % Default title in case the pattern is not found
end

% Sanity Check
loadFileCheck = input("Are your 'loadFile' and 'fileName' input correct? (y, n): ", 's');
if strcmpi(loadFileCheck, 'y')
    disp("Inputs are correct.");
else
    return;
end

dataTable = input("Enter the struct you want for analysis: 'twdb_control' or " + ...
    "'twdb_stress', twdb_stress2: ",'s');
dataBase = twdbs.(sprintf('%s', dataTable));

groupedNeuron = groupedNeuron(~cellfun(@isempty, groupedNeuron))';
allNeuron = horzcat(groupedNeuron{:});

% Make a matrix of bin counts for neurons in each session
numBin = 30;
binCountMatrix = zeros(numel(allNeuron),10);

% Generate covariance matrix
for neuron = 1:numel(allNeuron)
    try
        neuronIdx = allNeuron(neuron);
        neuronSpikes = dataBase(neuronIdx).trial_spikes;
        % Put all trial spikes together for the neuron
        concatNeuronSpikes = vertcat(neuronSpikes{:});
        concatNeuronSpikes = concatNeuronSpikes(isfinite(concatNeuronSpikes));
        count = histcounts(concatNeuronSpikes, numBin, 'Normalization', 'probability');
        count = count(11:20); % Choose only middle bins
        binCountMatrix(neuron,:) = 100*count;
    catch
        disp("Something went wrong.")
    end
end

% Remove Rows with NaN entries for binCountMatrix
binCountMatrix = binCountMatrix(~any(isnan(binCountMatrix), 2), :);

% calculate covariance of the neurons
covarianceOfAllNeuron = cov(binCountMatrix');
numDim = size(covarianceOfAllNeuron, 1);
determinant = det(covarianceOfAllNeuron)^(1/numDim);

% Save covarianceOfAllNeuron results
newMatFileName = sprintf('sessionDataOf%s', titlePart);
% save(newMatFileName, 'covarianceOfAllNeuron', '-append');