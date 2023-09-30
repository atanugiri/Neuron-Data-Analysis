% Date: 07/17/2023
% Author: Atanu Giri
% This script takes the grouped neuron data in a session as input and plot
% the heatmap of covariance matrix

loadFile = load("sessionDataOfPLS_ControlDB_CB_5_30_filteredBins.mat");
covData = loadFile.covarianceResults;

noOfRow = 4;
noOfCol = 4;
figure('Position', [100, 100, 1200, 800]);
subplotCounter = 1;
fileName = 'covariance_plots_PLS_ControlDB_CB_5_30_filteredBins.pdf';
for col = 1:size(covData,2)
    for row = 1:size(covData,1)
        if isempty(covData{row, col})
            continue;
        else
            subplot(noOfRow,noOfCol,subplotCounter);
            heatmap(covData{row, col});
            % Increment the subplot counter
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