function spmbatch_intra(subjname)

loadpaths

sesstypes = {'global','visual'};

condlists = {
    {'ld','ls'} 100 + [-50 50]
    {'gd','gs'} 450 + [-50 50]
    {'od','oc'} 175 + [-50 50]
%     {'od','oc'} 450 + [-150 150]
    };

contrasts = {
    struct('name','auditory local','type','T','c',    [1  -1  0   0   0   0   0   0   0   0   0   0 ])
    struct('name','auditory global','type','T','c',   [0  0   1   -1  0   0   0   0   0   0   0   0 ])
    struct('name','auditory omissions','type','T','c',[0  0   0   0   1   -1  0   0   0   0   0   0 ])
    struct('name','visual local','type','T','c',      [0  0   0   0   0   0   1   -1  0   0   0   0 ])
    struct('name','visual global','type','T','c',     [0  0   0   0   0   0   0   0   1   -1  0   0 ])
    struct('name','visual omissions','type','T','c',  [0  0   0   0   0   0   0   0   0   0   1   -1])
    };

S.imgfiles = {};
condnum = 1;
fprintf('Loading images...\n');
for sessidx = 1:length(sesstypes)
    sesstype = sesstypes{sessidx};
    
    for clidx = 1:size(condlists,1)
        condlist = condlists{clidx,1};
        for condidx = 1:length(condlist)
            condname = condlist{condidx};
            
            imgdir = sprintf('%simages/%s/%s_%s/',filepath,subjname,sesstype,condname);
            imglist = dir(sprintf('%s/*.nii',imgdir));
            for imgidx = 1:length(imglist)
                imgfile = sprintf('%s%s',imgdir,imglist(imgidx).name);
                S.imgfiles{condnum}{imgidx} = imgfile;
            end
            condnum = condnum+1;
        end
    end
end

spm('defaults','EEG');
cur_wd = pwd;
S.outdir = filepath;
S.contrasts = contrasts;
batch_spm_anova(S);
cd(cur_wd);