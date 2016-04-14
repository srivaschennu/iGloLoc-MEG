function runstats(sesslist,condlist,varargin)

loadpaths
loadsubj

param = finputcheck(varargin, { ...
    'channame', 'string', '', 'EEG034'; ... %EEG013 = Fz, EEG034 = Cz
    'timewin', 'real', [], []; ...
    });

if ischar(param)
    error(param);
end

if ischar(sesslist)
    sesslist = repmat({sesslist},size(condlist));
end

filesuffix = '_cond';

for c = 1:length(condlist)
        filecondname{c} = sprintf('%s_%s',sesslist{c},condlist{c});
end

for s = 1:size(subjlist,1);
    subjname = lower(subjlist{s,1});
    file2load = sprintf('%s%s%s.mat',filepath,subjname,filesuffix);
    fprintf('Loading %s.\n',file2load);
    D = spm_eeg_load(file2load);
    timewinidx = [find(min(abs(D.time-param.timewin(1))) == abs(D.time-param.timewin(1))) ...
        find(min(abs(D.time-param.timewin(2))) == abs(D.time-param.timewin(2)))];
    
    for c = 1:length(condlist)
        filecondidx = find(strcmp(filecondname{c},D.conditions));
        statdata(s,c) = mean(D(find(strcmp(D.chanlabels,param.channame)),timewinidx(1):timewinidx(2),filecondidx));
    end
end

datatable = table(statdata(:,1),statdata(:,2),statdata(:,3),statdata(:,4),...
    'VariableNames',filecondname);
design = table(filecondname','VariableNames',{'conditions'});
rmmodel = fitrm(datatable,'global_ld-visual_ls~1','WithinDesign',design);

ranova(rmmodel,'WithinModel',[1 -1 -1 1]')
