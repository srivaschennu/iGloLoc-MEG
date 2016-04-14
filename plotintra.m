function plotintra(subjname,sesslist,condlist,chanlist,varargin)

loadpaths
loadsubj

timeshift = 0;%600; %milliseconds

param = finputcheck(varargin, { 'ylim', 'real', [], [-50 50]; ...
    'subcond', 'string', {'on','off'}, 'off'; ...
    'condnames', 'cell', {}, {}; ...
    'timewin', 'real', [], []; ...    
    'refchan', 'string', [], ''; ...
    });

if ischar(param)
    error(param);
end


if ischar(sesslist)
    sesslist = repmat({sesslist},size(condlist));
end

scalefactor = 1;
yunits = 'uV';

file2load = sprintf('%s%s_cond.mat',filepath,subjname);
fprintf('Loading %s.\n',file2load);
D = spm_eeg_load(file2load);

EEG = pop_fileio(file2load);
chanidx = find(ismember(D.chanlabels,chanlist));
if isempty(chanidx)
    (D.chanlabels)'
    error('No matching channels found!');
end

badchannels = D.badchannels;
% find and exclude bad channels
if ~isempty(badchannels)
    fprintf('\nFound %d bad channels: ', length(badchannels));
    for ch=1:length(badchannels)-1
        fprintf('%s ',EEG.chanlocs(badchannels(ch)).labels);
    end
    fprintf('%s\n',EEG.chanlocs(badchannels(end)).labels);
else
    fprintf('No bad channel info found.\n');
end

if ~isempty(param.refchan)
    refchanidx = find(strncmp(param.refchan,D.chanlabels,length(param.refchan)));
    refchanidx = setdiff(refchanidx,badchannels);
    fprintf('Re-referencing to '); disp(D.chanlabels(refchanidx)); fprintf('\n');
    if isempty(refchanidx)
        (D.chanlabels)'
        error('No matching reference channels found!');
    end
    EEG = pop_reref(EEG,refchanidx,'keepref','on');
end

EEG = pop_select(EEG,'channel',setdiff(chanidx,badchannels));

for c = 1:length(condlist)
    filecondname = sprintf('%s_%s',sesslist{c},condlist{c});
    filecondidx = find(strcmp(filecondname,D.conditions));
    erpdata(:,:,c) = EEG.data(:,:,filecondidx);
    fprintf('Number of trials in %s_%s_%s: %d\n',subjname,sesslist{c},condlist{c},D.repl(filecondidx));
end
fprintf('\n');

if strcmp(param.subcond, 'on') && length(condlist) == 2
    erpdata(:,:,3) = erpdata(:,:,1) - erpdata(:,:,2);
    condlist = cat(2,condlist,{sprintf('%s-%s',condlist{1},condlist{2})});
    plotcond = 3;
else
    plotcond = 1:length(condlist);
end

if isempty(param.condnames)
    param.condnames = strcat(sesslist,'_',condlist(1:2));
    if strcmp(param.subcond,'on')
        param.condnames = cat(2,param.condnames,{sprintf('%s-%s',param.condnames{1},param.condnames{2})});
    end
end

% %% SAVING
% savefile = sprintf('%s-%s_%s',param.condnames{1},param.condnames{2},param.modality);
% save([savefile '.mat'],'sesslist','condlist','erpdata','timeshift','param')
% save([savefile '.mat'],'-append','-struct','EEG','chanlocs','times');

%% PLOTTING

figname = sprintf('%s_%s-%s-%s',subjname,param.condnames{1},param.condnames{2},chanlist{1});
figure('Name',figname,'Color','white');
hold all

% if isempty(param.timewin)
%     param.timewin = [0 EEG.times(end)-timeshift];
% end
% latpnt = find(EEG.times-timeshift >= param.timewin(1) & EEG.times-timeshift <= param.timewin(2));
% [maxval, maxidx] = max(abs(plotdata(:,latpnt)),[],2);
% [~, maxmaxidx] = max(maxval);
% plottime = EEG.times(latpnt(1)-1+maxidx(maxmaxidx));
% if plottime == EEG.times(end)
%     plottime = EEG.times(end-1);
% end

for c = plotcond
    plotdata = erpdata(:,:,c)*scalefactor;
    %plot ERP data
    plot(EEG.times-timeshift,plotdata','LineWidth',2,'DisplayName',param.condnames{c});
end

set(gca,'XLim',[EEG.times(1)-timeshift EEG.times(end)-timeshift],'YLim',param.ylim,'FontSize',16);
xlabel('Time relative to 5th tone (ms)','FontSize',16);
ylabel('Amplitude (\muV)','FontSize',16);
set(legend('toggle'),'Interpreter','none');

xlimits = xlim;
ylimits = ylim;
line(xlimits,[0 0],'LineStyle',':','Color','black');
line([0 0],ylimits,'LineStyle',':','Color','black');
line([-150 -150],ylimits,'LineStyle',':','Color','black');
line([-300 -300],ylimits,'LineStyle',':','Color','black');
line([-450 -450],ylimits,'LineStyle',':','Color','black');
line([-600 -600],ylimits,'LineStyle',':','Color','black');

export_fig(gcf,sprintf('figures/%s.pdf',figname));