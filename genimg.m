function genimg(subjname,imgtype,modality)

subjname = lower(subjname);

loadpaths
loadcont

sesslist = {'global','visual'};

timeshift = 0;

outdir = 'images/';
if ~exist([filepath outdir],'dir')
    mkdir([filepath outdir]);
end

% filesuffix = '_cond';
filesuffix = '_comb';

file2conv = sprintf('%s%s%s.mat',filepath,subjname,filesuffix);
fprintf('\nGenerating images from %s.\n',file2conv);
D = spm_eeg_load(file2conv);

for sessidx = 1:length(sesslist)
    sessname = sesslist{sessidx};
    
    for clidx = 1:size(condlists,1)
        condlist = condlists{clidx,1};
        timewin = condlists{clidx,2};

        if strcmp(imgtype,'source')
            val = modality;
            if ~val
                error('Could not find inversion for %s %s-%s during %d-%dms.\n',sessname,condlist{1},condlist{2},timewin);
            else
                fprintf('Using inversion %d for %s %s-%s during %d-%dms.\n',val,sessname,condlist{1},condlist{2},timewin);
            end
            
            D.val = val;
            D.inv{val}.contrast.woi  = timeshift+timewin;
            D.inv{val}.contrast.fboi = [0 0];
            D.inv{val}.contrast.type = 'evoked';
            D = spm_eeg_inv_results(D);
            D.inv{val}.contrast.display   = 0;
            D.inv{val}.contrast.space     = 1;
            D.inv{val}.contrast.smoothing = 8;
            D = spm_eeg_inv_Mesh2Voxels(D);
            
        elseif strcmp(imgtype,'sensor')
            S = [];
            S.D = D;
            S.channels = modality;
            S.mode = 'scalp x time';
            S.timewin = timeshift+timewin;
            spm_eeg_convert2images(S);
        end
        
        for condidx = 1:length(condlist)
            condname = condlist{condidx};
            filecondname = sprintf('%s_%s',sessname,condname);
            filecondidx = find(strcmp(filecondname,D.conditions));
            
            if strcmp(imgtype,'source')
                outimgfile = sprintf('%s%s%s_%s_%d-%d_%d.nii',filepath,outdir,subjname,filecondname,timewin,val);
                copyfile(sprintf('%s%s%s_%d_t%d_%d_f_%d.nii',filepath,subjname,filesuffix,val,timeshift+timewin,filecondidx),...
                    outimgfile,'f');
            elseif strcmp(imgtype,'sensor')
                outimgfile = sprintf('%s%s%s_%s_%d-%d_%s.nii',filepath,outdir,subjname,filecondname,timewin,modality);
                imgdir = sprintf('%s%s%s/',filepath,subjname,filesuffix);
                imgfile = sprintf('%scondition_%s.nii',imgdir,filecondname);
                copyfile(imgfile,outimgfile,'f');
            end
        end
        
        if strcmp(imgtype,'source')
            delete(sprintf('%s%s%s_%d_t%d_%d_f_*.nii',filepath,subjname,filesuffix,val,timeshift+timewin));
        elseif strcmp(imgtype,'sensor')
            rmdir(sprintf('%s%s%s',filepath,subjname,filesuffix),'s')
        end
    end
end