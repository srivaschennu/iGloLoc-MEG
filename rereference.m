function rereference(basename)

loadpaths

basename = lower(basename);

D = spm_eeg_load(sprintf('%s%s.mat',filepath,basename));

%% re-reference to average
S=[];
S.D = D;
S.refchan = 'average';
D = spm_eeg_reref_eeg(S);

%% copy data over to final file
S = [];
S.D = D;
S.outfile = sprintf('%s.mat',basename);
fprintf('\nCopying to %s.\n',S.outfile);
spm_eeg_copy(S);
delete(S.D);
