% Date: 07/25/2023
% Author: Atanu Giri

% This script plots bar of detreminants and trace for control vs stress 
% database while splliting them by task type and concentration

clearvars -except twdbs; clc;

% Ask user for neuron type
neuronType = input("Enter neuron type for analysis: ('PL' or 'PLS'): ", 's');

% Folder where the .mat files are located: Control db
folderPathControl = sprintf(['/Users/atanugiri/Downloads/final stress project/AtanuCode/' ...
    'Grouped Neurons From Same Session/Same session %s neuron/Control db Results/' ...
    'Session Data of %s Neuron in Control db'], neuronType, neuronType);

% Get a list of all .mat files in the folder
matFilesControl = dir(fullfile(folderPathControl, '*.mat'));

% Invoke function 'detAndTraceData' to calculate determinant data
[detDataArrayControl, traceDataArrayControl] = detAndTraceData(matFilesControl, ...
    folderPathControl);

% Invoke function 'avgAndStdErrData' to calculate average and std error of
% deterinant data per group

% Ask user for data type
feature = input("Which feature do you want to analyze ('Determinant' or 'Trace'): ", 's');
if strcmpi(feature, 'Determinant')
    [avDataPerGroupInControl, stdErrDataPerGroupInControl] = avgAndStdErrData(detDataArrayControl);
elseif strcmpi(feature, 'Trace')
    [avDataPerGroupInControl, stdErrDataPerGroupInControl] = avgAndStdErrData(traceDataArrayControl);
else
    disp("Please check your input.\n");
    return;
end

% Group name lebel
controlGroupNames = {'CB 5-30, Ctrl', 'CB 60-NaN, Ctrl', 'EQR, Ctrl', 'RevCB 5-61, Ctrl', ...
    'RevCB 70-70, Ctrl', 'TR 5-30, Ctrl', 'TR 45-65, Ctrl', 'TR 70-100, Ctrl'};

% Create the bar plot
subplot(1,2,1);
myBar(avDataPerGroupInControl, stdErrDataPerGroupInControl, controlGroupNames);
ylabel(sprintf('Average %s Data', feature), 'Interpreter', 'latex', 'FontSize', 20);
title(sprintf('Bar Plot of %s in Control', neuronType), ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');

% Add number of sessions for each group
printSessionCount(detDataArrayControl, avDataPerGroupInControl)
hold off;



%% Do same operations on Stress DB
folderPathStress = sprintf(['/Users/atanugiri/Downloads/final stress project/AtanuCode/' ...
    'Grouped Neurons From Same Session/Same session %s neuron/Stress db Results/' ...
    'Session Data of %s Neuron in Stress db'], neuronType, neuronType);

matFilesStress = dir(fullfile(folderPathStress, '*.mat'));

[detDataArrayStress, traceDataArrayStress] = detAndTraceData(matFilesStress, folderPathStress);

if strcmpi(feature, 'Determinant')
    [avDataPerGroupInStress, stdErrDataPerGroupInStress] = avgAndStdErrData(detDataArrayStress);
elseif strcmpi(feature, 'Trace')
    [avDataPerGroupInStress, stdErrDataPerGroupInStress] = avgAndStdErrData(traceDataArrayStress);
end

stressGroupNames = {'CB, Stress', 'TR 10-50, Stress', 'TR 60-70, Stress', ...
    'TR 75-NaN, Stress'};

% Create the bar plot
subplot(1,2,2);
myBar(avDataPerGroupInStress, stdErrDataPerGroupInStress, stressGroupNames);
ylabel(sprintf('Average %s Data', feature), 'Interpreter', 'latex', 'FontSize', 20);
title(sprintf('Bar Plot of %s in Stress', neuronType), ...
    'Interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold');
printSessionCount(detDataArrayStress, avDataPerGroupInStress)
hold off;

%% Function to add number of sessions for each group
function printSessionCount(detDataArray, avDataPerGroup)
for i = 1:numel(detDataArray)
    numSessions = numel(detDataArray{i});
    yPos = 2*mean(avDataPerGroup,'omitnan');
    text(i, yPos, [num2str(numSessions), ' session'], ...
        'Interpreter', 'latex', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', ...
        'center', 'Rotation', 45, 'Color', [0 0.5 0]);
end
end

%% function for customized bar plot
function myBar(avgDataArray, stdErrArray, groupNames)
bar(avgDataArray);
xticks(1:numel(groupNames));
xticklabels(groupNames);
xtickangle(45);

% Add error bars using the errorbar function
hold on;
errorbar(1:numel(avgDataArray), avgDataArray, stdErrArray, 'k.', 'LineWidth', 1.5);

% Add labels and limit
xlabel('Group', 'Interpreter', 'latex', 'FontSize', 20);
ylim([0 0.007]);
end

%% function to fetch average and standard error data for each group
function [avData, stdErr] = avgAndStdErrData(dataArray)
% Create container of average data and std err for each group
avData = zeros(1, numel(dataArray));
stdErr = zeros(1, numel(dataArray));

for group = 1:numel(dataArray)
    % normalized determinant has both real and complex part
    dataArray{group} = real(dataArray{group});
    data = dataArray{group}(isfinite(dataArray{group}));
    avData(group) = mean(data);
    stdErr(group) = std(data)/sqrt(numel(data));
end
end


%% function to fetch determinant and trace data provided mat files of
%% session and folder path
function [detDataArray, traceDataArray] = detAndTraceData(matFiles, folderPath)
% Initialize arrays to store the extracted data from each .mat file
detDataArray = cell(1, numel(matFiles));
traceDataArray = cell(1, numel(matFiles));

% Loop through each .mat file and load the data
for fileIdx = 1:numel(matFiles)
    matFileName = matFiles(fileIdx).name;
    fullFilePath = fullfile(folderPath, matFileName);

    loadFile = load(fullFilePath);
    detDataArray{fileIdx} = loadFile.normDetCovMatArray;
    traceDataArray{fileIdx} = loadFile.normTraceCovMatArray;
end
end