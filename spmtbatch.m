function spmebatch(subjidx,conname,convec,condlist)

loadpaths

sesstypes = {'global','visual'};
%condlist = {'ld','ls','gd','gs','od','oc'};

subjname = sprintf('sub%02d',subjidx);
S.imgfiles = {};

fprintf('Loading images...\n');
for sessidx = 1:length(sesstypes)
    sesstype = sesstypes{sessidx};
    
    for condidx = 1:length(condlist)
        condname = condlist{condidx};
        S.imgfiles{((sessidx-1)*length(condlist))+condidx}{1} = [];
        
        D = spm_eeg_load(sprintf('%sp%s_%s_%s_epochs.mat',filepath,subjname,sesstype,condname));
        
        for epochidx = 1:length(D.conditions)
            imgfile = sprintf('%sp%s_%s_%s_epochs/type_%s/strial%04d.img,1',...
                filepath,subjname,sesstype,condname,D.conditions{epochidx},epochidx);

            S.imgfiles{((sessidx-1)*length(condlist))+condidx}{epochidx} = imgfile;
        end
    end
end

S.outdir = filepath;
S.sub_effects = 0;
S.contrasts{1}.c = zeros(1,length(sesstypes)*length(condlist));
S.contrasts{1}.c(1:length(convec)) = convec;
S.contrasts{1}.type = 'T';
S.contrasts{1}.name = conname;
cur_wd = pwd;
spm('defaults','EEG');
batch_spm_anova(S);

dispcon_job{1}.spm.stats.results.spmmat = {[filepath 'SPM.mat']};
dispcon_job{1}.spm.stats.results.conspec.titlestr = conname;
dispcon_job{1}.spm.stats.results.conspec.contrasts = Inf;
dispcon_job{1}.spm.stats.results.conspec.threshdesc = 'FWE';
dispcon_job{1}.spm.stats.results.conspec.thresh = 0.05;
dispcon_job{1}.spm.stats.results.conspec.extent = 0;
dispcon_job{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
dispcon_job{1}.spm.stats.results.units = 2;
dispcon_job{1}.spm.stats.results.print = false;
spm_jobman('initcfg');
spm_jobman('serial',dispcon_job);

cd(cur_wd);
delete([filepath 'mask.img']);