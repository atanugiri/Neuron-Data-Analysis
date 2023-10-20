% Date: 10/16/2023
% Author: Atanu Giri
% Statistics of coefficients between different pairs

loadFile1 = load('FSIvsStrioFitResults.mat');
loadFile2 = load('FSIvsMatrixFitResults.mat');

aResults = NaN(1,3);
bResults = NaN(1,3);
gofResults = NaN(1,3);

for group = 1:3
    [~, aResults(group)] = ttest2(loadFile1.aData{group}, loadFile2.aData{group});
    [~, bResults(group)] = ttest2(loadFile1.bData{group}, loadFile2.bData{group});
    [~, gofResults(group)] = ttest2(loadFile1.gofData{group}, loadFile2.gofData{group});

end