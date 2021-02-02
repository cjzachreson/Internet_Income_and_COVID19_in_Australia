% this script will compute the spearman's correlation and confidence
% interval for two input lists

function [A, CI_hi, CI_low] = Pearsons_and_CI(X1 ,X2)

A = corr(X1, X2, 'type', 'Pearson');

[CI_hi, CI_low] = CI_pearsons(A, numel(X1));

end