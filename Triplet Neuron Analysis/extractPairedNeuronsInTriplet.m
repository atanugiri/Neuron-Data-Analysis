% Date: 10/12/2023
% This function extracts unique pairs of 2 different types of neuron in 
% PLS, FSI, and Striosome triplets.

function pairsInTriplet = extractPairedNeuronsInTriplet
% Load pair data
pairData = cell(1,3);
pairData{1} = load('pairsTableControl.mat');
pairData{2} = load('pairsTableStress.mat');
pairData{3} = load('pairsTableStress2.mat');

% Extract triplet for each database
fsiPlsStrioTriplets = cell(1,3);

for group = 1:3
    fsiPlsPairs = pairData{group}.pairsTable{3};
    fsiStriosomePairs = pairData{group}.pairsTable{1};
    % Get the triplets
    fsiPlsStrioTriplets{group} = innerjoin(fsiPlsPairs, fsiStriosomePairs, ...
        'Keys', 'fsiIndex');
end

% Divide triplet in each database into 3 combination of pairs
pairsInTriplet = cell(1,3);
pairsInTripletLabel = {'fsiPlsPair', 'fsiStrioPair', 'plsStrioPair'};

for group = 1:3
    pairsInTriplet{group}{1} = fsiPlsStrioTriplets{group}(:,[2,1]);
    pairsInTriplet{group}{2} = fsiPlsStrioTriplets{group}(:,[1,3]);
    pairsInTriplet{group}{3} = fsiPlsStrioTriplets{group}(:,[2,3]);
end

% Remove duplicate pairs
for group = 1:3
    for pair = 1:3
        neuronPair = pairsInTriplet{group}{pair};
        column1 = neuronPair.Properties.VariableNames{1};
        column2 = neuronPair.Properties.VariableNames{2};

        uniquePair = [];

        for row = 1:height(neuronPair)
            curreantPair = [neuronPair.(1)(row), neuronPair.(2)(row)];
            if isempty(uniquePair) || ~ismember(curreantPair, uniquePair, 'rows')
                uniquePair = [uniquePair; curreantPair];
            end
        end
        pairsInTriplet{group}{pair} = array2table(uniquePair, 'VariableNames', ...
            {column1, column2});
    
    end % End of neuron pair

end % End of neuron group