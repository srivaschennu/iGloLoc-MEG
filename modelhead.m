function modelhead(subjname)

loadpaths

subjname = lower(subjname);

mridir = [filepath 'MRI/'];
fidlist = dlmread([mridir 'fiducials.txt']);
invidx = 1;
subjmri = [mridir subjname '.nii'];

fprintf('\nConstructing head model for %s with this structural MRI file:\n%s\n\n',subjname,subjmri);

fprintf('Loading %s%s...\n',filepath,[subjname '_epochs.mat']);
D = spm_eeg_load(sprintf('%s%s',filepath,[subjname '_epochs.mat']));

D.inv{invidx} = [];
D.val = invidx;
D.inv{invidx}.date    = char(date,datestr(now,15));
D.inv{invidx}.comment = '';

%% Create Mesh
D.inv{invidx}.mesh.sMRI = subjmri;
D = spm_eeg_inv_mesh_ui(D, invidx, D.inv{invidx}.mesh.sMRI, 2);
spm_eeg_inv_checkmeshes(D);
saveas(gcf,sprintf('%s%s_mesh.fig',mridir,subjname));

%% Co-registration
MRIfids           = [];
MRIfids.fid.pnt   = reshape(fidlist(subjidx,2:end),3,3)';
MRIfids.fid.label = {'Nasion';'LPA';'RPA'};
MRIfids.pnt       = D.inv{invidx}.mesh.fid.pnt;        % Scalp mesh points from MRI above
MRIfids.unit      ='mm';
MEGfids           = D.fiducials;
MEGfids.pnt       = MEGfids.pnt(~(MEGfids.pnt(:,2)>0 & MEGfids.pnt(:,3)<0),:);
D = spm_eeg_inv_datareg_ui(D, invidx, MEGfids, MRIfids, 1);

for modidx = 1:length(D.inv{invidx}.datareg)
    spm_eeg_inv_checkdatareg(D, invidx, modidx);
    figname = sprintf('%s_datareg_%s',subjname,D.inv{invidx}.datareg(modidx).modality);
    set(gcf,'Name',figname);
    saveas(gcf,sprintf('%s%s.fig',mridir,figname));
end

%% Forward modelling
D.inv{invidx}.forward = struct([]);
for modidx = 1:length(D.inv{invidx}.datareg)
    if strcmp(D.inv{invidx}.datareg(modidx).modality,'EEG')
        D.inv{invidx}.forward(modidx).voltype = 'EEG BEM';
    elseif strcmp(D.inv{invidx}.datareg(modidx).modality,'MEG')
        D.inv{invidx}.forward(modidx).voltype = 'Single Shell';
    end
end
D = spm_eeg_inv_forward(D);

for modidx = 1:length(D.inv{invidx}.datareg)
    spm_eeg_inv_checkforward(D, invidx, modidx);
    figname = sprintf('%s_fmod_%s',subjname,D.inv{invidx}.datareg(modidx).modality);
    set(gcf,'Name',figname);
    saveas(gcf,sprintf('%s%s.fig',mridir,figname));
end

%% Save model
D.save
inv = D.inv;
save(sprintf('%s%s_inv.mat',filepath,subjname),'inv');