% Date: 06/29/2023
% This function extract the bintime corresponding to best fit of each pair

% loadFile = load('PLSvsFSIfitResultControl.mat'); % For Triplet Data
loadFile = load("gofForAllBinsOffsiPlsPairsInStress2.mat");

% Dynamically return file name
[~, fileName] = fileparts("gofForAllBinsOffsiPlsPairsInStress2");

binVal = loadFile.bintime;
rsquareVal = loadFile.gofArray;

% Get best bintime for each doublet fit
bestBin = zeros(size(rsquareVal,1),1);

for row = 1:size(rsquareVal,1)
    try
        allRsquare = zeros(1,size(rsquareVal,2));
        for col = 1:size(rsquareVal,2)
            allRsquare(col) = rsquareVal{row,col}.rsquare;
        end
        [maxVal, maxIdx] = max(allRsquare);
        bestBin(row) = binVal(maxIdx);
    catch
        fprintf('Skipped iteration%d due to insufficient data.\n',row);
    end
end

% Append to existing mat file
save(fileName, "bestBin", '-append');