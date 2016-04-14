function spmbatch(modality)

loadpaths
loadsubj
loadcont

if ischar(modality)
    modality_or_val = modality;
elseif isnumeric(modality)
    modality_or_val = sprintf('%d',modality);
end

imgdir = 'images/';
sesstypes = {'global','visual'};

S.imgfiles = {};

for subjidx = 1:size(subjlist,1)
    subjname = lower(subjlist{subjidx,1});
    S.imgfiles{1}{subjidx} = [];
    
    for sessidx = 1:length(sesstypes)
        sesstype = sesstypes{sessidx};
        
        for clidx = 1:size(condlists,1)
            condlist = condlists{clidx,1};
            timewin = condlists{clidx,2};
            
            for condidx = 1:length(condlist)
                condname = condlist{condidx};
                imgfile = sprintf('%s%s%s_%s_%s_%d-%d_%s.nii',filepath,imgdir,subjname,sesstype,condname,timewin,modality_or_val);
                
                if isempty(S.imgfiles{1}{subjidx})
                    S.imgfiles{1}{subjidx} = imgfile;
                else
                    S.imgfiles{1}{subjidx} = char(S.imgfiles{1}{subjidx},imgfile);
                end
            end
        end
    end
end

spm_unlink(sprintf('%sstats/%s/mask.nii',filepath,modality_or_val));

spm('defaults','EEG');
cur_wd = pwd;
S.outdir = sprintf('%sstats/%s/',filepath,modality_or_val);
S.contrasts = contrasts;
batch_spm_anova(S);
cd(cur_wd);
