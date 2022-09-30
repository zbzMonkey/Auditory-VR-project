%% Annova for compare multiple elements 

function [tbl] = annova_multiple(varias)

[p,tbl,stats] = anova1(varias);
results = multcompare(stats);
tbl = array2table(results,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
end