% computes correlation of income_security by SA2 with ability to work from
% home by SA2

data = readtable('data_by_SA2_GSYD_GMEL.csv')

[rho, CI_hi, CI_low] = Pearsons_and_CI(data.WFH_score, data.income_security)