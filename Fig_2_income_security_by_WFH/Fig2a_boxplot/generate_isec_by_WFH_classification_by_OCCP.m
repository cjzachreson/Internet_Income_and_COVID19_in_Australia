isec_by_occp = readtable('income_security_by_OCCP_4dig.csv')

wfh_by_occp = readtable('TeleWork_by_OCCP4dig.csv')

occp = isec_by_occp.code4;
wfh_raw = wfh_by_occp.tele_work;
isec = isec_by_occp.income_security;

% removes any entries with indeterminate work-from-home classification
% indeterminate income security (because job security dataset from HILDA
% was incomplete)
% or 0 income security (to remove NaNs from log-transform). 
occp_out = occp(wfh_raw ~= 0.5 & isec ~= 0 & ~isnan(isec))
isec_out = isec(wfh_raw ~= 0.5 & isec ~= 0 & ~isnan(isec))
wfh_out = round(wfh_raw(wfh_raw ~= 0.5 & isec ~= 0 & ~isnan(isec)))

OCCP4dig = occp_out;
log_income_security = log(isec_out);
wfh_classification = wfh_out;

output_table = table(OCCP4dig, log_income_security, wfh_classification);

writetable(output_table, 'OCCP_by_WFH_group_and_log_income_security.csv')