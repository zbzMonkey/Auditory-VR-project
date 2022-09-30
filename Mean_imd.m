% calculate the mean of imd
mean1 = mean(imd_19_20);
std1 = std(imd_19_20);
mean2 = mean(imd_13_14);
std2 = std(imd_13_14);
mean3 = mean(imd_12_16);
std3 = std(imd_12_16);
mean4 = mean(imd_3_4);
std4 = std(imd_3_4);

mean_whole = [mean1 mean2 mean3 mean4];
std_whole = [std1 std2 std3 std4];
errorbar(mean_whole,std_whole)
% xlabel('group')
xlim([1 4])
xticklabels({'CCIF2-19/20k','', 'CCIF3-13/14k','','Common-12/16k','', 'Common-3/4k'})
ylabel('IMD (%)')