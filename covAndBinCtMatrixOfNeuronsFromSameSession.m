% Date: 07/16/2023
% Author: Atanu Giri
% This script makes matrix of all neurons in same session for variance and
% covariance calculation. It also plots the histograms all each neurons in
% a session and save them as pdf files.

clearvars -except twdbs;
clc;

% twdbs = load("twdbs.mat");

% Load the grouped neuron matrix
loadFile = load("sameSessionStriosomeneuronsINstress.mat");
groupedNeuron = loadFile.groupedNeuronIdx;

% Extract the file name without the extension
[~, fileNameWithoutExt, ~] = fileparts("sameSessionStriosomeneuronsINstress");
fileName = sprintf('Histogram_%s.pdf', fileNameWithoutExt);

% Input struct of twdbs
dataTable = input("Enter the struct you want for analysis: 'twdb_control' or " + ...
    "'twdb_stress', 'twdb_stress2': ",'s');
dataBase = twdbs.(sprintf('%s', dataTable));

% Create container for variane and covariane results
covarianceResults = cell(size(groupedNeuron));
binCtMatrixData = cell(size(groupedNeuron));

% Use regular expressions to extract the desired part of the file name for
% title
pattern = 'sameSession(.+)'; % Matches any characters between 'sessionDataOf' and '_filteredBins'
match = regexp(fileNameWithoutExt, pattern, 'tokens');
if ~isempty(match)
    titlePart = match{1}{1}; % Extract the desired part from the matched tokens
else
    titlePart = 'Unknown'; % Default title in case the pattern is not found
end


% Ask user if wants to normalize bin count
normalizeCt = input("Do you want to normalize firing rate? ('y' or 'n'): ", 's');

% For loop to store covarianceResults and plot histogram
for ratID = 1:size(groupedNeuron,2)
    for sessionID = 1:size(groupedNeuron,1)
        neuronArray = groupedNeuron{sessionID, ratID};


        % Create a figure for the histogram
        %             figure('Position', [100, 100, 1200, 800]);
        %             subplot_count = 0;

        % Make a matrix of bin counts for neurons in each session
        numBin = 30;
        binCountMatrix = zeros(numel(neuronArray), numBin);

        for neuron = 1:numel(neuronArray)
            try
                neuronIdx = neuronArray(neuron);
                neuronSpikes = dataBase(neuronIdx).trial_spikes;
%                 neuronSpikes = neuronSpikes(~cellfun(@isempty, neuronSpikes)); %% Check again
                % Put all trial spikes together for the neuron
                concatNeuronSpikes = vertcat(neuronSpikes{:});
                concatNeuronSpikes = concatNeuronSpikes(isfinite(concatNeuronSpikes));

                if strcmpi(normalizeCt, 'y')
                    count = histcounts(concatNeuronSpikes, numBin, 'Normalization', 'probability');
                    % Divide by trial number
                    count = (count./numel(neuronSpikes))*(3/4);
                    binCountMatrix(neuron,:) = 100*count;
                elseif strcmpi(normalizeCt, 'n')
                    count = histcounts(concatNeuronSpikes, numBin);
                    count = (count./numel(neuronSpikes))*(3/4);
                    binCountMatrix(neuron,:) = count;
                end

                % Plot
%                 subplot_count = subplot_count + 1;
%                 subplot(5, 5, subplot_count);
%                 histogram(concatNeuronSpikes, numBin, 'Normalization', 'probability', ...
%                     'FaceAlpha',0.5);
%                 xlim([-20 20]);
%                 title(sprintf('Neuron Id: %d',neuronIdx));

                % Add title for the current page
%                 if subplot_count == 1
%                     sgtitle(titlePart, 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'latex');
%                 end

                % Save the figure as a PDF
%                 set(gca, 'FontSize', 10);
%                 set(gca, 'LooseInset', get(gca, 'TightInset') + [0.05, 0.05, 0.05, 0.05]);
%                 exportgraphics(gcf, fileName, 'ContentType', 'vector', 'Append', true);
%                 close(gcf);

            catch
                disp("Something went wrong.")
            end
        end

        % Remove Rows with NaN entries for binCountMatrix
        binCountMatrix = binCountMatrix(~any(isnan(binCountMatrix), 2), :);
        binCtMatrixData{sessionID, ratID} = binCountMatrix;
        covarianceResults{sessionID, ratID} = cov(binCountMatrix');
    end
end

% Save output files in a mat file.
newMatFileName = sprintf('sessionDataOf%s', titlePart);

if strcmpi(normalizeCt, 'y')
    save(newMatFileName,'groupedNeuron','covarianceResults','binCtMatrixData');
else
    binCountMatrixWoNorm = binCtMatrixData;
    save(newMatFileName,'binCountMatrixWoNorm', '-append');
end
close all;