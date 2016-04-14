function prepintradcm(subjname)

loadpaths

chanlist = {'H'' 1','T'' 1','OR'' 1'};

D = spm_eeg_load(sprintf('%s%s_cond.mat',filepath,subjname));

S = [];
S.D = D;
S.channels = chanlist;
D = spm_eeg_crop(S);

fprintf('Re-ordering channels.\n');
for c = 1:length(chanlist)
    chanidx = find(strcmp(chanlist{c},S.D.chanlabels));
    if length(chanidx) == 1
        D(c,:,:) = S.D(chanidx,:,:);
        D = chanlabels(D,c,S.D.chanlabels{chanidx});
    else
        error('Channel %s not found in %s%s_cond.mat.',chanlist{c},filepath,subjname);
    end
end

% %% Lowpass filter
% lpfreq = 25;
% fprintf('\nLow-pass filtering below %d Hz...\n',lpfreq);
% S=[];
% S.D = D;
% S.type  = 'butterworth';
% S.order = 5;
% S.band  = 'low';
% S.freq   = lpfreq;
% S.dir   = 'twopass';
% D = spm_eeg_filter(S);
% delete(S.D);
% 
% %% Highpass filter
% hpfreq = 1;
% fprintf('\nHigh-pass filtering below %d Hz...\n',hpfreq);
% S=[];
% S.D = D;
% S.type  = 'butterworth';
% S.order = 5;
% S.band  = 'high';
% S.freq   = hpfreq;
% S.dir   = 'twopass';
% D = spm_eeg_filter(S);
% delete(S.D);

% %% Baseline correction
% S = [];
% S.D = D;
% S.timewin = [-200 0];
% D = spm_eeg_bc(S);
% delete(S.D);

%% Copy to output file
S = [];
S.outfile = sprintf('%s%s_dcm.mat',filepath,subjname);
S.D = D;
D = spm_eeg_copy(S);
delete(S.D);

fprintf('done.\n');