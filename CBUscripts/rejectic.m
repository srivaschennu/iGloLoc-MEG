function rejectic(basename)

loadpaths

basename = lower(basename);

icafile = [filepath basename '_icainfo.mat'];
filename = [basename '_clean.mat'];

fprintf('Reading %s%s.\n',filepath,filename);
D = spm_eeg_load([filepath filename]);
fprintf('Loading %s.\n',icafile);
load(icafile,'icainfo');

modalities = {'EEG' 'MEGMAG' 'MEGPLANAR'};
tramat = eye(size(D,1));

fprintf('\n');
for m = 1:length(modalities)
    ncomps = size(icainfo(m).weights,1);
    if isfield(icainfo(m),'rejectics')
        rejectics = icainfo(m).rejectics;
        fprintf('%s (%s): projecting out %d ICs: ', basename, modalities{m}, length(rejectics));
        fprintf('comp%d, ',rejectics(1:end));
        fprintf('\n');
        
        if ~isempty(rejectics)
            keepics = setdiff(1:ncomps,rejectics);
            iweights = pinv(icainfo(m).weights);
            tramat(icainfo(m).icachansind,icainfo(m).icachansind) = iweights(:,keepics) * icainfo(m).weights(keepics,:);
        end
    end
end
fprintf('\n');

%% project out marked ICs
S = [];
S.D = D;
S.montage.labelorg = D.chanlabels;
S.montage.labelnew = S.montage.labelorg;
S.montage.tra = tramat;
D = spm_eeg_montage(S);

%% copy data over to final file
S = [];
S.D = D;
S.outfile = sprintf('%s_ica.mat',basename);
fprintf('\nCopying to %s.\n',S.outfile);
spm_eeg_copy(S);
delete(S.D);
