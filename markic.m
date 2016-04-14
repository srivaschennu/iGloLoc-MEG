function markic(basename,corrwitheog)

loadpaths

alpha = 0.05;

if exist('corrwitheog','var') && corrwitheog == true
    numcomptoplot = 10;
else
    numcomptoplot = 24;
end

basename = lower(basename);

icafile = [filepath basename '_icainfo.mat'];
filename = [basename '_clean.mat'];

fprintf('Reading %s%s.\n',filepath,filename);
D = spm_eeg_load([filepath filename]);
alldata = pop_fileio([filepath filename]);
eogdata = reshape(D(find(strcmp('EOG',D.chantype)),:,:),sum(strcmp('EOG',D.chantype)),D.nsamples*D.ntrials)';

fprintf('Loading %s.\n',icafile);
load(icafile,'icainfo');

writeloc(D);

modalities = {'EEG' 'MEGMAG' 'MEGPLANAR'};

evalin('base','eeglab');

for m = 1%:length(modalities)
    fprintf('\n%s: displaying %s ICs.\n',basename,modalities{m});
    switch modalities{m}
        case 'EEG'
            scalefactor = 1;
        case {'MEGMAG' 'MEGPLANAR'}
            scalefactor = 1;
    end
    
    EEG = pop_select(alldata,'channel',icainfo(m).icachansind);
    EEG.data = EEG.data * scalefactor;
    EEG.chanlocs = pop_readlocs(sprintf('%s%s_clean_%s.xyz',filepath,basename,modalities{m}));
    EEG.icaweights = icainfo(m).weights;
    EEG.icasphere = icainfo(m).sphere;
    EEG.icachansind = 1:EEG.nbchan;
    EEG.icawinv = pinv(EEG.icaweights*EEG.icasphere);
    EEG.setname = sprintf('%s (%s)',basename,modalities{m});
    if isfield(icainfo(m),'rejectics')
        EEG.reject.gcompreject = zeros(1,size(icainfo(m).weights,1));
        EEG.reject.gcompreject(icainfo(m).rejectics) = 1;
    end
    EEG = eeg_checkset(EEG);
    
    assignin('base','EEG',EEG);
    evalin('base','[ALLEEG EEG index] = eeg_store(ALLEEG,EEG); eeglab redraw');
    
    if exist('corrwitheog','var') && corrwitheog == true
        icaact = (EEG.icaweights*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts);
        [eogcorr, pvals] = corr(icaact',eogdata);
        eogcorr = abs(eogcorr(:));
        pvals = pvals(:);
        [~, sortidx] = sort(eogcorr,'descend');
        pvals = pvals(sortidx);
        plotcomps = repmat((1:size(icaact,1))',2,1);
        plotcomps = plotcomps(sortidx);
        plotcomps = plotcomps(pvals < alpha);
        plotcomps = unique(plotcomps,'stable');
    else
        plotcomps = (1:size(icainfo(m).weights,1))';
    end
    plotcomps = plotcomps(1:min(numcomptoplot,length(plotcomps)))';

    EEG = VisEd(EEG,2,['[' num2str(plotcomps) ']'],{});
    comptimefig = gcf;
    set(comptimefig,'Name',sprintf('%s (%s)',basename,modalities{m}));
    g = get(comptimefig, 'UserData');
    badchan_old = cell2mat({g.eloc_file.badchan});
    
    pop_selectcomps(EEG, plotcomps);
    uiwait;
    EEG = evalin('base','EEG');
    
    if ishandle(comptimefig)
        g = get(comptimefig, 'UserData');
        badchan_new = cell2mat({g.eloc_file.badchan});
        
        for c = 1:length(badchan_old)
            if badchan_old(c) == 0 && (badchan_new(c) == 1 || EEG.reject.gcompreject(plotcomps(c)) == 1)
                g.eloc_file(c).badchan = 1;
            elseif badchan_old(c) == 1 && (badchan_new(c) == 0 || EEG.reject.gcompreject(plotcomps(c)) == 0)
                g.eloc_file(c).badchan = 0;
            end
        end
        set(comptimefig, 'UserData', g);
        eegplot('drawp',0,[],comptimefig);
    end
    
    if ishandle(comptimefig)
        uiwait(comptimefig);
    end
    
    EEG = evalin('base','EEG');
    
    rejectics = find(EEG.reject.gcompreject);
    
    fprintf('\n%d ICs marked for rejection: ', length(rejectics));
    fprintf('comp%d, ',rejectics(1:end));
    fprintf('\n');
    
    icainfo(m).rejectics = rejectics;
end

fprintf('Saving marked ICs to %s.\n',icafile);
save(icafile,'icainfo');

