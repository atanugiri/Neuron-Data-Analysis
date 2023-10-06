% Date: 07/20/2023
% Author: Atanu Giri
% This function plots PCA over time for same session neurons provided bin
% count natrix of neurons from the session

loadFile = load("sessionDataOfFSI_ControlDB_CB_5_30_filteredBins.mat");
binCountData = loadFile.binCtMatrixData;

% Extract the file name without the extension from 'loadFile'
[~, fileNameWithoutExt, ~] = fileparts("sessionDataOfFSI_ControlDB_CB_5_30_filteredBins");

noOfRow = 4;
noOfCol = 4;
figure('Position', [100, 100, 1200, 800]);
subplotCounter = 1;

% Dynamically get output file name
fileName = sprintf('PCA_plot_%s.pdf', fileNameWithoutExt);

% Use regular expressions to extract the desired part of the file name for
% title 
pattern = 'sessionDataOf(.+)_filteredBins'; % Matches any characters between 'sessionDataOf' and '_filteredBins'
match = regexp(fileNameWithoutExt, pattern, 'tokens');
if ~isempty(match)
    titlePart = match{1}{1}; % Extract the desired part from the matched tokens
else
    titlePart = 'Unknown'; % Default title in case the pattern is not found
end

% Create a container for PC1, PC2, and PC3 to plot them together
PC = cell(1,3);

groupNo = 0;
for col = 1:size(binCountData,2)
    for row = 1:size(binCountData,1)
        if isempty(binCountData{row, col})
            continue;
        else
            groupNo = groupNo + 1;
            subplot(noOfRow,noOfCol,subplotCounter);
            % Plot of bin count data in each time bin
            binCountOfSession = binCountData{row, col};
            binCountOfSessionCentered = binCountOfSession - mean(binCountOfSession,2);
            %             plot(binCountOfSessionCentered');
            [U, S, V] = svd(binCountOfSessionCentered);
            principal_components = S*V;

            % Store PC1, PC2, and PC3 values
            for PCidx = 1:3
                try
                    PC{PCidx} = [PC{PCidx}; principal_components(PCidx,:)];
                catch
                    PC{PCidx} = [PC{PCidx}; nan(1, 10)];
                end
            end

            plot(principal_components', 'LineWidth', 2);
            legendLabels = num2str((1:size(principal_components, 2))');
            legend(legendLabels, 'Location','eastoutside');
            title(sprintf("PCs over time, neurons group no: %d", groupNo));

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