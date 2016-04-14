function grandaverage

loadpaths

loadsubj

filelist = {};

filesuffix = '_cond';

fprintf('Loading data...\n');
for subjidx = 1:size(subjlist,1)
    subjname = lower(subjlist{subjidx,1});
    fullfilename = sprintf('%s%s%s.mat',filepath,subjname,filesuffix);
    filelist = cat(1,filelist,fullfilename);
end

fprintf('Averaging over:\n');
disp(filelist);

gafilename = 'allsubj';
S = [];
S.D = char(filelist);
S.weighted = 0;
S.outfile = sprintf('%s%s.mat',gafilename,filesuffix);
D = spm_eeg_grandmean(S);
D = rmfield(D,'inv');
D.inv{1} = [];
D.save

%% construct template head model

matlabbatch{1}.spm.meeg.source.headmodel.D = {sprintf('%s%s%s.mat',filepath,gafilename,filesuffix)};
matlabbatch{1}.spm.meeg.source.headmodel.val = 1;
matlabbatch{1}.spm.meeg.source.headmodel.comment = '';
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.template = 1;
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshres = 2;
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'Nasion';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.select = 'nas';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'LPA';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.select = 'lpa';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'RPA';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.select = 'rpa';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
matlabbatch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
matlabbatch{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';

spm_jobman('initcfg');
spm_jobman('run',matlabbatch);