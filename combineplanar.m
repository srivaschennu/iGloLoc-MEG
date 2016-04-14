function combineplanar(subjname)

loadpaths

subjname = lower(subjname);

D = spm_eeg_load(sprintf('%s%s_cond.mat',filepath,subjname));

%% combine MEGMAG and MEGPLANAR
S = [];
S.D = D;
D = spm_eeg_combineplanar(S);

S = [];
S.D = D;
S.timewin = [-200 0];
D = spm_eeg_bc(S);
delete(S.D);

%% copy data over to final file
S = [];
S.D = D;
S.outfile = sprintf('%s_comb.mat',subjname);
fprintf('\nCopying to %s.\n',S.outfile);
spm_eeg_copy(S);
delete(S.D);
