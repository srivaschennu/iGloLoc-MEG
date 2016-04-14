function condrepl = statrepl(sesslist,condlist)

loadpaths
loadsubj

for c = 1:length(condlist)
    condnames{c} = sprintf('%s_%s',sesslist{c},condlist{c});
end

condrepl = zeros(size(subjlist,1),length(condlist));

for s = 1:size(subjlist,1)
    subjname = lower(subjlist{s,1});
    fprintf('Processing %s.\n',subjname);
    
    D = spm_eeg_load(sprintf('%s%s_cond.mat',filepath,subjname));
    for c = 1:length(condlist)
        condidx = find(strcmp(condnames{c},D.condlist));
        condrepl(s,c) = D.repl(condidx);
    end
    
end

condrepl

[h,p,ci,stats] = ttest(condrepl(:,1),condrepl(:,2))
