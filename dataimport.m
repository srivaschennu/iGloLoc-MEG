function dataimport(subjidx)


loadpaths
loadsubj

chanfile = [filepath 'chan_select.mat'];   % Channels to read: MEG+EEG+EOG+ECG+STI101
chans2read = load(chanfile);

%% Start Preprocessing...
subjname = subjlist{subjidx,1};
sub_wd = fullfile(srcpath,subjname);
if ~exist(sub_wd,'dir')
    error('Could not access source directory.');
end

for sessidx = 1:size(subjlist{subjidx,2},1)
    sesstype = subjlist{subjidx,2}{sessidx,1};
    runlist = subjlist{subjidx,2}{sessidx,2};
    
    fprintf('\nImporting data from %s session of %s...\n',sesstype,subjname);
    
    for run = runlist
        %% load/convert data
        fprintf('\nProcessing run_%02d_tsss.fif\n',run);
        S = [];
        S.usetrials = 1;
        S.dataset = fullfile(sub_wd,sprintf('run_%02d_tsss.fif',run));
        S.outfile =  fullfile(filepath,sprintf('%s_run%02d.mat',lower(subjname),run));
        S.channels = chans2read.label;
        S.continuous = 1;
        S.checkboundary = 0;
        D = spm_eeg_convert(S);
        
        % Just some tidying-up of Vectorview-specific issues!
        c = strmatch('EOG061',D.chanlabels);
        D = chanlabels(D,c,'HEOG061');
        
        c = strmatch('EOG062',D.chanlabels);
        D = chanlabels(D,c,'VEOG062');
        
        ch = D.indchannel('STI101');  % Just re-scale trigger so can see EOG/ECG at same time
        trig_chan = D(ch,:,:);
        D(ch,:,:) = trig_chan/10^7;
        D.save;
        
        %% Downsample
        fsample_new = 200;
        fprintf('\nDownsampling to %d Hz...\n',fsample_new);
        S = [];
        S.D = D;
        S.fsample_new = fsample_new;
        S.prefix = 'd';
        D = spm_eeg_downsample(S);
        delete(S.D);
        
        %% Lowpass filter
        lpfreq = 25;
        fprintf('\nLow-pass filtering below %d Hz...\n',lpfreq);
        S=[];
        S.D = D;
        S.type  = 'butterworth';
        S.order = 5;
        S.band  = 'low';
        S.freq   = lpfreq;
        S.dir   = 'twopass';
        D = spm_eeg_filter(S);
        delete(S.D); % delete intermediate steps
        
        %% Highpass filter
        hpfreq = 0.5;
        fprintf('\nHigh-pass filtering above %.1f Hz...\n',hpfreq);
        S=[];
        S.D = D;
        S.type  = 'butterworth';
        S.order = 5;
        S.band  = 'high';
        S.freq   = hpfreq;
        S.dir   = 'twopass';
        D = spm_eeg_filter(S);
        delete(S.D); % delete intermediate steps
        
        %% copy data over to final file
        S = [];
        S.D = D;
        S.outfile = sprintf('%s%s_%s_run%02d.mat',filepath,lower(subjname),sesstype,run);
        fprintf('\nCopying to %s.\n',S.outfile);
        spm_eeg_copy(S);
        delete(S.D);
    end
end