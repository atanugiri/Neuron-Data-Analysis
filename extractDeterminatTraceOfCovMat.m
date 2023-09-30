% Date: 07/24/2023
% Author: Atanu Giri
% This script will find the determinant of a covariance matrix of neuron
% signals in a session.

clearvars -except twdbs; clc; % To clean workspace

matFileName = "sessionDataOfFSIneuronsINcontrol.mat";
loadFile = load(matFileName);
covarianceResults = loadFile.covarianceResults;

% Create a empty container for output results
normDetCovMatArray = [];
normTraceCovMatArray = [];

groupNo = 0;
for ratID = 1:size(covarianceResults,2)
    for sessionID = 1:size(covarianceResults,1)
        if isempty(covarianceResults{sessionID, ratID})
            continue;
        else
            groupNo = groupNo + 1;
            numDim = size(covarianceResults{sessionID, ratID}, 1);

            % Calculate normalized determinant
            normDetCovMatrix = det(covarianceResults{sessionID, ratID})^(1/numDim);
            normDetCovMatArray = [normDetCovMatArray, normDetCovMatrix];

            % Calculate normalized trace
            normTraceCovMatrix = trace(covarianceResults{sessionID, ratID})/numDim;
            normTraceCovMatArray = [normTraceCovMatArray, normTraceCovMatrix];
        end
    end
end

% Save the results back to the same .mat file
save(matFileName, 'normDetCovMatArray', 'normTraceCovMatArray', '-append');
