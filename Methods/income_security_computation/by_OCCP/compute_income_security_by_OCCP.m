wage_table = readtable('ANZSCO_industry_wage.csv');

security_table = readtable('HILDA_insecure_employment.csv');

code4_sec_raw = security_table.rjbmo06;
code4_sec = code4_sec_raw;

for i = 1:numel(code4_sec)
    
    brace_ind_1 = strfind(code4_sec{i}, '[');
    brace_ind_2 = strfind(code4_sec{i}, ']');
    
    code4_i = code4_sec{i}(brace_ind_1 + 1: brace_ind_2 - 1);
    
    code4_sec{i} = code4_i;
    
end
    
% aggregate to 2-digit occupation codes

code4_sec = char(code4_sec);
code4_sec = cellstr(code4_sec(:, 1:4));
code4_sec_unique = unique(code4_sec);

code4_sumofone = NaN( numel(code4_sec_unique), 1);
code4_sumofzero = NaN( numel(code4_sec_unique), 1);

for i = 1:numel(code4_sec_unique)
    
    code4_i = code4_sec_unique{i};
    
    occs_i = {code4_sec{strcmp(code4_sec, code4_i)}}';
    
    sec_i = zeros(1, numel(occs_i));
    unsec_i = zeros(1, numel(occs_i));
    
    for j = 1:numel(occs_i)
        
        occs_j = occs_i{j};
        index = find(strcmp(code4_sec, occs_j));
        sec_i(j) = security_table.sumofzero(index);
        unsec_i(j) = security_table.sumofone(index);
        
    end
    
    code4_sumofone(i) = sum(unsec_i);
    code4_sumofzero(i) = sum(sec_i);
    
end
    
 
% testing a different distribution for v2
%sec_ratio = code4_sumofzero ./ code4_sumofone;

sec_ratio = ((code4_sumofzero) ./ (code4_sumofzero + code4_sumofone) ) ;

code4 = code4_sec_unique;

occ_sec_table = table(code4, sec_ratio);


% compute (population-weighted) average weekly wage for each occpation (2-digit from 4-digit)
    
code4_wage = cellstr(num2str(wage_table.four_digit_code));
weekly_wage = wage_table.weekly_wage;
count_aus = wage_table.geo_aus;
called = false(numel(code4_wage), 1);

code4_wage = char(code4_wage);
code4_wage = cellstr(code4_wage(:, 1:4));
code4_wage_unique = unique(code4_wage);

code4_avg_wage = NaN( numel(code4_wage_unique), 1);

for i = 1:numel(code4_wage_unique)
    
    code4_i = code4_wage_unique{i};
    
    occs_i = {code4_wage{strcmp(code4_wage, code4_i)}}';
    
    wage_i = zeros(1, numel(occs_i));
    pop_i = zeros(1, numel(occs_i));
    
    for j = 1:numel(occs_i)
        
        occs_j = occs_i{j};
        index = find(strcmp(code4_wage, occs_j));
        
        index = index(~called(index));
        
        index = index(1);
        
        wage_i(j) = weekly_wage(index);
        pop_i(j) = count_aus(index);
        called(index) = true;
        
    end
    
    pop_i = pop_i(~isnan(wage_i));
    wage_i = wage_i(~isnan(wage_i));
    
    code4_avg_wage(i) = sum(wage_i .* (pop_i ./ sum(pop_i)));
    
    
end


code4 = code4_wage_unique;
weekly_wage = code4_avg_wage;

occ_wage_table = table(code4, weekly_wage);

% re-scale [0, 1] and map

wage_norm = occ_wage_table.weekly_wage ./ max(occ_wage_table.weekly_wage);

%wage_norm = occ_wage_table.weekly_wage - median(occ_wage_table.weekly_wage);

%sec_norm = occ_sec_table.sec_ratio ./ max(occ_sec_table.sec_ratio(~isinf(occ_sec_table.sec_ratio)));

sec_norm = occ_sec_table.sec_ratio ;


code_to_sec_map = containers.Map(str2double(occ_sec_table.code4), sec_norm);

code_to_wage_map = containers.Map(str2double(occ_wage_table.code4), wage_norm);

code4 = [];
income_security = [];
test_vals = [];

for i  = 1:numel(occ_wage_table.code4)
    
    code4(i, 1) = str2double(occ_wage_table.code4{i});
    
    if isKey(code_to_sec_map, code4(i, 1))
        
    income_security(i, 1) = code_to_sec_map(code4(i, 1)) * code_to_wage_map(code4(i, 1));
    
    test_vals(i, 1) = code4(i, 1);
    test_vals(i, 2) = code_to_sec_map(code4(i, 1));
    test_vals(i, 3) = code_to_wage_map(code4(i, 1));
    else
        income_security(i, 1) = NaN;
        test_vals(i, 1) = NaN;
        test_vals(i, 2) = NaN;
        test_vals(i, 3) = NaN;
        disp(['could not find security score for occupation: ' num2str(code4(i, 1))]);
    end
    
   
end

job_security_score = test_vals(:, 2);

wage_nrm = test_vals(:, 3);

wage_abs = test_vals(:, 3) .* max(occ_wage_table.weekly_wage);

test_table = table(code4, income_security, job_security_score, wage_nrm, wage_abs);

% figure(1);
% histogram((test_table.income_security));
% 
% figure(2)
% scatter(test_table.job_security_score, test_table.wage_abs)
% 
% figure(3)
% scatter(log(test_table.job_security_score), log(test_table.wage_nrm))
% 
% figure(4);
% histogram(log(test_table.income_security));

writetable(test_table, 'income_security_by_OCCP_4dig.csv')

wage_hist = histogram(test_table.wage_abs);
wage_vals = (wage_hist.BinEdges(2:end) - wage_hist.BinWidth/2)';
wage_OCCP_counts = (wage_hist.Values)';
table_out = table(wage_vals, wage_OCCP_counts);
writetable(table_out, 'wage_OCCP_histogram.csv')


security_hist = histogram(test_table.income_security);
security_vals = (security_hist.BinEdges(2:end) - security_hist.BinWidth/2)';
sec_OCCP_counts = (security_hist.Values)';
table_out = table(security_vals, sec_OCCP_counts);
writetable(table_out, 'sec_OCCP_histogram.csv');


isec_hist = histogram(test_table.income_security);
isec_vals = (isec_hist.BinEdges(2:end) - isec_hist.BinWidth/2)';
isec_OCCP_counts = (isec_hist.Values)';
table_out = table(isec_vals, isec_OCCP_counts);
writetable(table_out, 'isec_OCCP_histogram.csv');


log_isec_hist = histogram(log(test_table.income_security));
log_isec_vals = (log_isec_hist.BinEdges(2:end) - log_isec_hist.BinWidth/2)';
log_isec_OCCP_counts = (log_isec_hist.Values)';
table_out = table(log_isec_vals, log_isec_OCCP_counts);
writetable(table_out, 'log_isec_OCCP_histogram.csv');


    