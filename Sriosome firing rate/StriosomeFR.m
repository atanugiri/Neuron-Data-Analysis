% Date: 10/19/2023
% Striosome firing rate

% twdbs = load("twdbs.mat");
twdbData = {twdbs.twdb_control, twdbs.twdb_stress, twdbs.twdb_stress2};
dbs = {'control', 'stress', 'stress2'}; 
strs = {'Control', 'Stress', 'Stress2'}; 

BLstart = 60; BLend = 240;
window_starts = [316,316,321,321,310,310];
window_ends = [330,330,335,335,320,320];

neuron_types = {'PL Neurons', 'PLS Neurons', 'Striosomes', 'Matrix Neurons', 'HFNs', 'SWNs'};

% Initialize variables to store firing rates and zscores by neuron type
neuron_type_FRs = cell(1,length(neuron_types));

for neuron_type_idx = 3:3 %1:length(neuron_types)
    % Initialize variables to store firing rates and zscores by database
    neuron_type_FRs{neuron_type_idx} = cell(1,length(dbs));
    load('cb_ids.mat');
    neuron_type_ids = cb_ids{neuron_type_idx};
    
    for db = 1:length(dbs)
        for neuron_idx = 1:length(neuron_type_ids{db})
            % For each neuron, calculate zscore and firing rate during the
            % active period.
            [zscore, ~, ~, ~, FR, ~] = quantify_neuron_activity(twdbData{db},...
                                    neuron_type_ids{db}(neuron_idx),'spikes',...
                                    BLstart,BLend,window_starts(neuron_type_idx),...
                                    window_ends(neuron_type_idx));
            
            neuron_type_FRs{neuron_type_idx}{db} = [neuron_type_FRs{neuron_type_idx}{db} FR];
        end
       
    end
end

for neuron_type_idx = 3:3 %1:length(neuron_types)
    disp(['CDFs of CBC Task Activity Firing Rates For ' neuron_types{neuron_type_idx}]);
    
    % Make bar graph
    f = figure;
    means = cellfun(@(x) mean(x(~isnan(x))),neuron_type_FRs{neuron_type_idx});
    stderrs = cellfun(@(x) std(x(~isnan(x)))/sqrt(length(x(~isnan(x)))),neuron_type_FRs{neuron_type_idx});
    barwitherr(stderrs,means);
    strs = {'Control', 'Stress', 'Stress2'};
    set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
    
    %Run ttest2
    [~,p1,~] = ttest2(neuron_type_FRs{neuron_type_idx}{1}, neuron_type_FRs{neuron_type_idx}{2});
    [~,p2,~] = ttest2(neuron_type_FRs{neuron_type_idx}{1}, neuron_type_FRs{neuron_type_idx}{3});

    title({['Mean Firing Rates of ' neuron_types{neuron_type_idx} ' Across Experimental Groups'], ...
            ['Control vs Stress ttest2 p = ' num2str(p1)], ...
            ['Control vs Stress2 ttest2 p = ' num2str(p2)]});
end