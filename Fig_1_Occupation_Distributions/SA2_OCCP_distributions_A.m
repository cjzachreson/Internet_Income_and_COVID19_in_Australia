

% SA2_list = dlmread('GMel_GSyd_SA2s_above_median_isec.csv');
% 
% output_filename = 'GMel_GSyd_OCCP_dist_above_median_sorted_by_count';

SA2_list = dlmread('GMel_GSyd_SA2s_below_median_isec.csv');

output_filename = 'GMel_GSyd_OCCP_dist_below_median_sorted_by_count';

% generate distribution of jobs in these SA2s

OCCP_by_SA2 = readtable('OCCP_by_SA2_codes_ABS_2016.csv', 'ReadRowNames', true, 'ReadVariableNames', true);

% re-name variable names to match 5-digit codes

SA2_9 = OCCP_by_SA2.Properties.VariableNames;

SA2_5 = {};

for i = 1:numel(SA2_9)
    
    SA2_9_i = SA2_9{i};
    SA2_5{i, 1} = [SA2_9_i(1:2), SA2_9_i(end-3:end)];
end

OCCP_by_SA2.Properties.VariableNames = SA2_5;


OCCP_list = OCCP_by_SA2.Properties.RowNames;

OCCP_to_count_map = containers.Map(OCCP_list, zeros(numel(OCCP_list), 1));

for i = 1:numel(SA2_list)
    
    for j = 1:numel(OCCP_list)
        
        SA2_i = ['x' num2str(SA2_list(i))];
        OCCP_j = OCCP_list{j};
        
        count_ij = OCCP_by_SA2(OCCP_j,SA2_i);
        
        OCCP_to_count_map(OCCP_j) = OCCP_to_count_map(OCCP_j) + count_ij.(SA2_i);
        
    end
    
    
end




% map OCCP codes to position titles, for reference.

OCCP_code_to_name = readtable('OCCP_code_to_name.ods', 'ReadVariableNames', false);

OCCP_names = {};

OCCP_codes = {};

for i = 1:numel(OCCP_code_to_name.Var1)
    
    entry_i = OCCP_code_to_name.Var1{i};
    
    OCCP_codes{i,1} = str2double(entry_i(2:5));
    
    OCCP_names{i,1} = entry_i(8:end);
    
end

OCCP_code_to_name_map = containers.Map(OCCP_codes, OCCP_names);



% make an output table

count = [];

OCCP_name = {};

code = [];


iterator = 0;

for i = 1:numel(OCCP_list)
    
    OCCP_i = OCCP_list{i};
    
    if OCCP_to_count_map(OCCP_i) > 0 && isKey(OCCP_code_to_name_map, str2double(OCCP_i))
        
        iterator = iterator + 1;
        
        OCCP_name{iterator, 1} = OCCP_code_to_name_map(str2double(OCCP_i));
        
        code(iterator, 1) = str2double(OCCP_i);
        
        count(iterator, 1) = OCCP_to_count_map(OCCP_i);
    end
    
end

% get income security score for each occupation for ranking
OCCP_income_sec_table = readtable('income_security_by_ANZSCO_code.csv');

code_to_sec_map = containers.Map(OCCP_income_sec_table.code4, OCCP_income_sec_table.income_security);

income_security = [];

for i = 1:numel(code)
    
    if isKey(code_to_sec_map, code(i))
        
        income_security(i, 1) = code_to_sec_map(code(i));
        
    else
        
        income_security(i, 1) = NaN;
        
    end
end


% bin counts for histogram representation

total = sum(count);

bin_width = 0.025;

bin_edges = bin_width:bin_width:1;

bin_values = zeros(size(bin_edges));

max_count = zeros(size(bin_edges));

bin_names = {};

for i = 1:numel(income_security)
    
    s_i = income_security(i);
    
    if ~isnan(s_i)
        
        count_i = count(i);
        
        bin_edge_i = bin_edges(bin_edges > s_i & (bin_edges - bin_width) <= s_i);
        
        edge_index = round(bin_edge_i / bin_width);
        
        %bin_values(bin_edges == bin_edge_i) = bin_values(bin_edges == bin_edge_i) + count(i);
        
        bin_values(edge_index) = bin_values(edge_index) + count(i);
        
        if count_i > max_count(edge_index)
            max_count(edge_index) = count_i;
            bin_names{edge_index, 1} = OCCP_name{i, 1};
        end
    end
    
end

for i = 1:size(max_count, 2)
    
    if i > size(bin_names, 1)
        bin_names{i, 1} = 'none';
    end
    
    if isempty(bin_names{i, 1})
        bin_names{i, 1} = 'none';
    end
end
    
    

bin_P = bin_values ./ total;
figure(2)
bar(bin_edges, bin_P)

isec_bins = bin_edges';
bin_count = bin_values';
bin_P = bin_P';
max_count = max_count';

hist_out = table(isec_bins, bin_count, bin_P, bin_names, max_count);

count_P = count ./ sum(count);

output_table = table(OCCP_name, code, count, count_P, income_security);

output_table = sortrows(output_table, 'count', 'descend');

%output_table = sortrows(output_table, 'income_security', 'ascend');

%writetable(output_table, 'Melb_odd_bunch_OCCP_count.csv')
%writetable(output_table, 'Syd_comparison_group_OCCP_count.csv')
%writetable(output_table, 'Melb_comparison_group_OCCP_count.csv')
writetable(output_table, [output_filename, '.csv']);

writetable(hist_out, [output_filename, '_hist.csv']);



