function ploterp(sesslist,condlist,varargin)

loadpaths
loadsubj

timeshift = 0;%600; %milliseconds

param = finputcheck(varargin, { 'ylim', 'real', [], []; ...
    'xlim', 'real', [], [-100 300]; ...
    'plotsubj', 'string', '', ''; ...
    'subcond', 'string', {'on','off'}, 'on'; ...
    'topowin', 'real', [], []; ...
    'modality', 'string', {'EEG','MEGMAG','MEGPLANAR','MEGCOMB'}, 'EEG'; ...
    'condnames', 'cell', {}, {}; ...
    });

if ischar(param)
    error(param);
end

if ~isempty(param.plotsubj)
    subjname = param.plotsubj;
else
    subjname = 'allsubj';
end

if ischar(sesslist)
    sesslist = repmat({sesslist},size(condlist));
end

switch param.modality
    case 'EEG'
        scalefactor = 1;
        if isempty(param.ylim)
            param.ylim = [-3 3];
        end
        yunits = 'uV';
    case 'MEGMAG'
        scalefactor = 1;
        if isempty(param.ylim)
            param.ylim = [-150 150];
        end
        yunits = 'fT';
    case 'MEGPLANAR'
        scalefactor = 1;
        if isempty(param.ylim)
            param.ylim = [-4 4];
        end
        yunits = 'fT/mm';
    case 'MEGCOMB'
        scalefactor = 1;
        if isempty(param.ylim)
            param.ylim = [-0.5 5];
        end
        yunits = 'fT/mm';
end

filesuffix = '_comb';
chanlocfile = sprintf('%s.xyz',param.modality);

file2load = sprintf('%s%s%s.mat',filepath,subjname,filesuffix);
fprintf('Loading %s.\n',file2load);
D = spm_eeg_load(file2load);

EEG = pop_fileio(file2load);
chanidx = find(strcmp(param.modality,D.chantype));
EEG = pop_select(EEG,'channel',chanidx);

chanlocs = readlocs(chanlocfile);
erpdata = zeros(EEG.nbchan,EEG.pnts,length(condlist));
EEG.chanlocs = chanlocs;

badchannels = intersect(chanidx,D.badchannels);
badchannels = find(ismember(chanidx,badchannels));
% find and exclude bad channels
if ~isempty(badchannels)
    fprintf('\nFound %d bad channels: ', length(badchannels));
    for ch=1:length(badchannels)-1
        fprintf('%s ',EEG.chanlocs(badchannels(ch)).labels);
    end
    fprintf('%s\n',EEG.chanlocs(badchannels(end)).labels);
    EEG = eeg_interp(EEG,badchannels);
else
    fprintf('No bad channel info found.\n');
end

%     %re-baseline
%     EEG = pop_rmbase(EEG,[-200 0]+timeshift);

for c = 1:length(condlist)
    filecondname = sprintf('%s_%s',sesslist{c},condlist{c});
    filecondidx = find(strcmp(filecondname,D.conditions));
    erpdata(:,:,c) = EEG.data(:,:,filecondidx);
    fprintf('Number of trials in %s_%s_%s: %d\n',subjname,sesslist{c},condlist{c},D.repl(filecondidx));
end
fprintf('\n');

if isempty(param.condnames)
    param.condnames = strcat(sesslist,'_',condlist);
end

if strcmp(param.subcond, 'on') && length(condlist) == 2
    erpdata(:,:,3) = erpdata(:,:,1) - erpdata(:,:,2);
    plotcond = 3;
    param.condnames = cat(2,param.condnames,{sprintf('%s-%s',param.condnames{1},param.condnames{2})});
    savefile = sprintf('%s-%s_%s',param.condnames{1},param.condnames{2},param.modality);
elseif strcmp(param.subcond, 'on') && length(condlist) == 4
    erpdata(:,:,5) = (erpdata(:,:,1) - erpdata(:,:,2)) - (erpdata(:,:,3) - erpdata(:,:,4));
    plotcond = 5;
    param.condnames = cat(2,param.condnames,{sprintf('%s-%s-%s-%s',param.condnames{1},param.condnames{2},param.condnames{3},param.condnames{4})});
    savefile = sprintf('%s-%s-%s-%s_%s',param.condnames{1},param.condnames{2},param.condnames{3},param.condnames{4},param.modality);
else
    plotcond = 1:length(condlist);
    savefile = sprintf('%s-%s_%s',param.condnames{1},param.condnames{2},param.modality);
end

%% SAVING

save([savefile '.mat'],'sesslist','condlist','erpdata','timeshift','param')
save([savefile '.mat'],'-append','-struct','EEG','chanlocs','times');

%% PLOTTING

for c = plotcond
    plotdata = erpdata(:,:,c)*scalefactor;
    
    if isempty(param.topowin)
        param.topowin = [0 EEG.times(end)-timeshift];
    end
    latpnt = find(EEG.times-timeshift >= param.topowin(1) & EEG.times-timeshift <= param.topowin(2));
    [maxval, maxidx] = max(abs(plotdata(:,latpnt)),[],2);
    [~, maxmaxidx] = max(maxval);
    plottime = EEG.times(latpnt(1)-1+maxidx(maxmaxidx));
    if plottime == EEG.times(end)
        plottime = EEG.times(end-1);
    end
    
    %plot ERP data
    if ~isempty(param.plotsubj)
        figname = sprintf('%s_%s_%s',subjname,param.condnames{c},param.modality);
    else
        figname = sprintf('%s_%s',param.condnames{c},param.modality);
    end
    figure('Name',figname,'Color','white');
    timtopo(plotdata,chanlocs,...
        'limits',[EEG.times(1)-timeshift EEG.times(end)-timeshift, param.ylim],...
        'plottimes',plottime-timeshift);
    set(gcf,'Color','white');
    h_axes = get(gcf,'Children');
    set(h_axes(4),'XLim',param.xlim,'FontSize',16,'FontName','Helvetica');
    xlabel(h_axes(4),sprintf('Time relative to fifth tone (%s)', yunits));
    ylabel(h_axes(4),sprintf('Amplitude (%s)', yunits));
%     set(suptitle(figname),'FontSize',16,'FontWeight','bold','Interpreter','none');
    export_fig(gcf,sprintf('figures/%s.tif',figname));
end
