% Date: 07/19/2023
% Author: Atanu Giri
% This function plots eigenvalues of neurons from cavariance matrix of neurons

loadFile = load("sessionDataOfSTRIO_ControlDB_TR_5_30_filteredBins.mat");

% Extract the file name without the extension from 'loadFile'
[~, fileNameWithoutExt, ~] = fileparts("sessionDataOfSTRIO_ControlDB_TR_5_30_filteredBins");

covarianceResults = loadFile.covarianceResults;
binCountData = loadFile.binCtMatrixData;

noOfRow = 4;
noOfCol = 4;
figure('Position', [100, 100, 1200, 800]);
subplotCounter = 1;

% Dynamically get output file name
fileName = sprintf('eigen_bar_plots_%s.pdf', fileNameWithoutExt);

% Use regular expressions to extract the desired part of the file name for
% title 
pattern = 'sessionDataOf(.+)_filteredBins'; % Matches any characters between 'sessionDataOf' and '_filteredBins'
match = regexp(fileNameWithoutExt, pattern, 'tokens');
if ~isempty(match)
    titlePart = match{1}{1}; % Extract the desired part from the matched tokens
else
    titlePart = 'Unknown'; % Default title in case the pattern is not found
end

groupNo = 0;

for col = 1:size(covarianceResults,2)
    for row = 1:size(covarianceResults,1)
        if isempty(covarianceResults{row, col})
            continue;
        else
            groupNo = groupNo + 1;
            subplot(noOfRow,noOfCol,subplotCounter);

            % bar plot of Neuron x Neuron covariance data
            [V, D] = eig(covarianceResults{row, col});
            bar(sort(diag(D)/sum(D,'all'), 'descend'));
            % Label the axes
            xlabel('Neuron or Eigenvalue Index');
            ylabel('Normalized Eigenvalues');
            title(sprintf("Eigen value of neurons:\n  group no: %d", groupNo));

            % Add title for the current page
            if subplotCounter == 1
                sgtitle(titlePart, 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'latex');
            end

            subplotCounter = subplotCounter + 1;
            if subplotCounter > noOfRow * noOfCol
                % Save the current figure as a PDF page
                exportgraphics(gcf, fileName, 'ContentType', 'vector', 'Append', true);
                close gcf;
                figure('Position', [100, 100, 1200, 800]);
                subplotCounter = 1;
            end
        end
    end
end
% If there are remaining subplots, save the current figure as the last PDF page
if subplotCounter > 1
    exportgraphics(gcf, fileName, 'ContentType', 'vector', 'Append', true);
    close gcf;
end