
compute_coeff_map = true;


OCCP_by_SA2_table = readtable('OCCP_by_SA2_codes_ABS_2016.csv', 'ReadRowNames', true, 'ReadVariableNames', true);

OCCP_to_composite_table = readtable('income_security_by_OCCP_4dig.csv');

OCCP_to_score = containers.Map(OCCP_to_composite_table.code4, OCCP_to_composite_table.income_security);

SA2_to_score_map = containers.Map('KeyType', 'char', 'ValueType', 'double');


% compute coefficients for each job type - this is just the proportion of
% that job type to the total number of employed people in each SA2

n_OCCP = size(OCCP_by_SA2_table, 1);

n_SA2 = size(OCCP_by_SA2_table, 2) - 1; %last column is total

SA2_codes = OCCP_by_SA2_table.Properties.VariableNames;

OCCP_codes = OCCP_by_SA2_table.Properties.RowNames;

OCCP_codes_not_included = [];

if compute_coeff_map
    %%
    
    pair_coeff_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    for i = 1:n_SA2
        
        tot_SA2 = sum(OCCP_by_SA2_table(:, i).(1));
        
        for j = 1:n_OCCP
            
            SA2_label = SA2_codes{i};
            
            OCCP_label = OCCP_codes{j};
            
            pair_label = [OCCP_label, SA2_label];
            
            numerator = OCCP_by_SA2_table.(SA2_label)(OCCP_label);
            
            if numerator == 0
                coeff = 0;
            else
                
                coeff = numerator / tot_SA2;
            end
            
            if isnan(coeff)
                'NaN detected'
            end
            
            pair_coeff_map(pair_label) = coeff;
            
        end
        
    end
    
end

% once OCCPxSA2 label to coefficient map is generated, the composit job
% security measures can be computed for each region. This is a linear
% combination of the composit measure for each occupation represented in
% each SA2, weighted by the proportion of employed people in that
% occupation

pairs = pair_coeff_map.keys;

for i = 1:size(pairs, 2)
    
    pair_label = pairs{i};
    
    OCCP_label = pair_label(1:4);
    SA2_label = pair_label(6:end);
    
    OCCP_code = str2double(OCCP_label);
    
    if isKey(OCCP_to_score, OCCP_code)
        
        if isKey(SA2_to_score_map, SA2_label)
            
            if ~isinf(OCCP_to_score(OCCP_code)) && ~isnan(OCCP_to_score(OCCP_code))
                
                SA2_to_score_map(SA2_label) =...
                    SA2_to_score_map(SA2_label) +...
                    OCCP_to_score(OCCP_code) * pair_coeff_map(pair_label);
            end
            
            if isnan(SA2_to_score_map(SA2_label))
                'NaN detected'
            end
            
        else
            
            if ~isinf(OCCP_to_score(OCCP_code)) && ~isnan(OCCP_to_score(OCCP_code))
                SA2_to_score_map(SA2_label) = ...
                    OCCP_to_score(OCCP_code) * pair_coeff_map(pair_label);
                
                if isnan(SA2_to_score_map(SA2_label))
                    'NaN detected'
                end
                
            end
        end
        
    else
        
        disp(['could not match OCCP code ' OCCP_label ' to income security score'])
    end
    
end

SA2_code = keys(SA2_to_score_map)';
income_security = values(SA2_to_score_map)';

output = table(SA2_code, income_security);

writetable(output, 'SA2_income_security.csv');



