function calcbehav

loadpaths

load([filepath 'behaviour.mat']);

for s = 1:size(atargcount,1)
    expblockcount = atargcount(s,atargcount(s,:) < 40);
    expblockrep = atargrep(s,atargcount(s,:) < 40);
    audaccu(s) = mean((1 - (abs(expblockcount - expblockrep) ./ expblockcount)) * 100);
    visaccu(s) = mean((1 - (abs(vtargcount(s,:) - vtargrep(s,:)) ./ vtargcount(s,:))) * 100);
end

fprintf('Auditory accuracy mean = %d%% s.d. = %d%%.\n',round(mean(audaccu)),round(std(audaccu))); 
fprintf('Visual accuracy mean = %d%% s.d. = %d%%.\n',round(mean(visaccu)),round(std(visaccu))); 