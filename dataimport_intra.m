function dataimport_intra(subjname)


loadpaths

sub_wd = subjname;
%% Start Preprocessing...

sesslist = {'global','visual'};

for sessidx = 1:length(sesslist)
    sesstype = sesslist{sessidx};
    
    fprintf('\nImporting data from %s session of %s...\n',sesstype,subjname);
    
    %% load/convert data
    fprintf('\nProcessing %s_%s.set\n',subjname,sesstype);
    S = [];
    S.usetrials = 1;
    S.dataset = fullfile(filepath,sub_wd,sprintf('%s_%s.set',subjname,sesstype));
    S.outfile =  fullfile(filepath,sprintf('%s_%s.mat',subjname,sesstype));
    S.continuous = 1;
    S.checkboundary = 0;
    D = spm_eeg_convert(S);
    D = chantype(D,1:D.nchannels,'LFP');
    D = units(D,1:D.nchannels,'uV');
    
%     %% Downsample
%     fsample_new = 256;
%     fprintf('\nDownsampling to %d Hz...\n',fsample_new);
%     S = [];
%     S.D = D;
%     S.fsample_new = fsample_new;
%     S.prefix = 'd';
%     D = spm_eeg_downsample(S);
%     delete(S.D);
%     
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
    S.outfile = fullfile(filepath,sprintf('%s_%s.mat',subjname,sesstype));
    fprintf('\nCopying to %s.\n',S.outfile);
    spm_eeg_copy(S);
    delete(S.D);
end