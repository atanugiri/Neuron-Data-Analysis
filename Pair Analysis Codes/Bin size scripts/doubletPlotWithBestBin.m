% Date: 06/29/2023
% Author: Atanu Giri
% This function plots doublets with best bintime for each pair. Extracts
% fitresult, xnew, and ynew for each pair

%% Invokes plotDynamicsDoublet function

%% fitTypeChoice: PLS vs FSI (1), FSI vs Srio (2), PLS vs Strio (3)

% twdbs = load("twdbs.mat");
twdb_control = twdbs.twdb_control;

loadFile1 = load('fsiPlsPairsControl.mat');
fsiPlsPairs = loadFile1.fsiPlsPairs;

loadFile2 = load('fsiStriosomePairsControl.mat');
fsiStriosomePairs = loadFile2.fsiStriosomePairs;

% Get the triplets
fsiPlsStrioTriplets = innerjoin(fsiPlsPairs, fsiStriosomePairs, 'Keys', 'fsiIndex');

% load best bin size
loadFile3 = load('optimalBinPlsvsFsiControl.mat');
bestBin = loadFile3.bestBin;
% bestBin = ones(size(fsiPlsStrioTriplets, 1),1); % This is for test

% Declare fitTypeChoice
fitTypeChoice = 2;

%% Data analysis
% Initialize empty arrays
fitresultArray = cell(size(fsiPlsStrioTriplets, 1), 1);
xValArray = cell(size(fsiPlsStrioTriplets, 1), 1);
yValArray = cell(size(fsiPlsStrioTriplets, 1), 1);

% Check the plot shape with current bin time
for row = 1:size(fsiPlsStrioTriplets,1)
    FSIindex = fsiPlsStrioTriplets.fsiIndex(row);
    STRIOindex = fsiPlsStrioTriplets.striosomeIndex(row);
    PLSindex = fsiPlsStrioTriplets.plsIndex(row);

    FSIspikes = twdb_control(FSIindex).trial_spikes;
    STRIOspikes = twdb_control(STRIOindex).trial_spikes;
    PLSspikes = twdb_control(PLSindex).trial_spikes;

    % Get the output values
    try
        switch fitTypeChoice
            case 1
                [fitresult, gof, xnew, ynew] = plotDynamicsDoublet(PLSspikes, FSIspikes, bestBin(row), fitTypeChoice);
            case 2
                [fitresult, gof, xnew, ynew] = plotDynamicsDoublet(FSIspikes, STRIOspikes, bestBin(row), fitTypeChoice);
            case 3
                [fitresult, gof, xnew, ynew] = plotDynamicsDoublet(PLSspikes, STRIOspikes, bestBin(row), fitTypeChoice);
        end

        % Store the result in the array
        fitresultArray{row} = fitresult;
        xValArray{row} = xnew;
        yValArray{row} = ynew;
    catch
        fprintf('Skipping iteration %d due to an error.\n', row);
        continue;
    end
end
close all;

%% Plotting
% % Create a PDF file for saving the figures
% pdf_file = 'doublet_plots_PLSvFSIbestBinControl.pdf';
% % Initialize the subplot counter
% subplot_count = 0;
% % Create a new figure
% figure('WindowState', 'maximized');
%
% % Get unique doublets
% switch fitTypeChoice
%     case 1
%         fsiPlsStrioTriplets.striosomeIndex = [];
%         [doublets, index] = unique(fsiPlsStrioTriplets,"rows");
%         bestBin = bestBin(index);
%     case 2
%         fsiPlsStrioTriplets.plsIndex = [];
%         [doublets, index] = unique(fsiPlsStrioTriplets,"rows");
%         bestBin = bestBin(index);
%     case 3
%         fsiPlsStrioTriplets.fsiIndex = [];
%         [doublets, index] = unique(fsiPlsStrioTriplets,"rows");
%         bestBin = bestBin(index);
% end
% 
% for i = 1:size(doublets,1)
%     % Increase subplot_count
%     subplot_count = subplot_count+1;
%     subplot(5, 4, subplot_count);
%     try
%         switch fitTypeChoice
%             case 1
%                 PLSindex = doublets.plsIndex(i);
%                 FSIindex = doublets.fsiIndex(i);
%                 PLSspikes = twdb_control(PLSindex).trial_spikes;
%                 FSIspikes = twdb_control(FSIindex).trial_spikes;
%                 plotDynamicsDoublet(PLSspikes, FSIspikes, bestBin(i), fitTypeChoice);
%                 current_title = get(gca, 'Title').String;
%                 % Create the new title text with additional information
%                 new_title = sprintf('%s\nPLS: %d, SWN: %d', current_title, PLSindex, FSIindex);
%             case 2
%                 FSIindex = doublets.fsiIndex(i);
%                 STRIOindex = doublets.striosomeIndex(i);
%                 FSIspikes = twdb_control(FSIindex).trial_spikes;
%                 STRIOspikes = twdb_control(STRIOindex).trial_spikes;
%                 plotDynamicsDoublet(FSIspikes, STRIOspikes, bestBin(i), fitTypeChoice);
%                 current_title = get(gca, 'Title').String;
%                 new_title = sprintf('%s\nSWN: %d, STRIO: %d', current_title, FSIindex, STRIOindex);
%             case 3
%                 PLSindex = doublets.plsIndex(i);
%                 STRIOindex = doublets.striosomeIndex(i);
%                 PLSspikes = twdb_control(PLSindex).trial_spikes;
%                 STRIOspikes = twdb_control(STRIOindex).trial_spikes;
%                 plotDynamicsDoublet(PLSspikes, STRIOspikes, bestBin(i), fitTypeChoice);
%                 current_title = get(gca, 'Title').String;
%                 new_title = sprintf('%s\nPLS: %d, STRIO: %d', current_title, PLSindex, STRIOindex);
%         end
% 
%         % Set the new title text
%         title(new_title);
% 
%         % Adjust the font size
%         set(gca, 'FontSize', 10);
% 
%         % Add more space between subplots
%         set(gca, 'LooseInset', get(gca, 'TightInset') + [0.05, 0.05, 0.05, 0.05]);
% 
%         % Save the figure as a PDF file
%         if subplot_count == 20 || i == size(doublets, 1)
%             % Save the current page and reset the subplot counter
%             exportgraphics(gcf, pdf_file, 'ContentType', 'vector', 'Append', true);
%             subplot_count = 0;
%             % Create a new figure
%             figure('WindowState', 'maximized');
%         end
% 
%     catch
%         fprintf('Skipping iteration %d due to an error.\n', i);
%         continue;
%     end
% end
% 
% % Close all figure windows
% close all;