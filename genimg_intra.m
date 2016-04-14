function genimg_intra(subjname,channame)

loadpaths

load conds.mat

condlists = {
    {'ld','ls'} 175 + [-50 50]
    {'gd','gs'} 175 + [-50 50]
    {'od','oc'} 175 + [-50 50]
    %     {'od','oc'} 450 + [-150 150]
    };

sesslist = {'global','visual'};

timeshift = 600;

outdir = sprintf('images/%s/',subjname);
if exist([filepath outdir],'dir')
    rmdir([filepath outdir],'s')
end
mkdir([filepath outdir]);

file2conv = sprintf('%s%s.mat',filepath,subjname);
fprintf('\nProcessing %s.\n',file2conv);
Depochs = spm_eeg_load(file2conv);

chanidx = find(strcmpi(channame,Depochs.chanlabels));
if isempty(chanidx)
    error('Channel %s not found in %s.\n',channame,file2conv);
end

Depochs = timeonset(Depochs,Depochs.timeonset-(timeshift/1000));

S = [];
S.D = Depochs;
S.timewin = [-200 0];
Depochs = spm_eeg_bc(S);

for sessidx = 1:length(sesslist)
    sessname = sesslist{sessidx};
    
    for clidx = 1:size(condlists,1)
        condlist = condlists{clidx,1};
        timewin = condlists{clidx,2};
        
        for condidx = 1:length(condlist)
            condname = condlist{condidx};
            filecondname = sprintf('%s_%s',sessname,condname);
            
            D = Depochs;
            selectevents = conds.(condname).events;
            D = badtrials(D,1:D.ntrials,1);
            for e = 1:length(selectevents)
                D = badtrials(D,find(strcmp([upper(sessname(1)) selectevents{e}],Depochs.conditions)),0);
            end
            fprintf('\n%s: found %d events.\n',filecondname,D.ntrials-length(D.badtrials));
            
            S = [];
            S.D = D;
            D = spm_eeg_remove_bad_trials(S);
            
            for t = 1:D.ntrials
                D = conditions(D,t,sprintf('trial%04d',t));
            end
            
            S = [];
            S.D = D;
            S.channels = {channame};
            D = spm_eeg_crop(S);
            delete(S.D);
            
            S = [];
            S.D = D;
            S.channels = 'EEG';
            S.mode = 'time';
            S.timewin = timewin;
            spm_eeg_convert2images(S);
            delete(S.D);
            
            srcimgdir = sprintf('%sprb%s/',filepath,subjname);
            destimgdir = sprintf('%s%s%s/',filepath,outdir,filecondname);
            movefile(srcimgdir,destimgdir);
            
%             imgdir = sprintf('%s%s%s/',filepath,outdir,filecondname);
%             if exist(imgdir,'dir')
%                 rmdir(imgdir,'s');
%             end
%             mkdir(imgdir);
%             fprintf('Saving images for condition %s in:\n%s\n',filecondname,imgdir);
%             
%             for t = 1:D.ntrials
%                 D = conditions(D,t,sprintf('trial%04d',t));
% 
%                 imgfname = sprintf('%strial%04d.nii',imgdir,t);
%                 imgdata = squeeze(D(chanidx,:,t))';
%                 imgdt = 1000/D.fsample;
%                 imgzero = find(min(abs(D.time)) == abs(D.time));
%                 
%                 Nf = size(imgdata,1);
%                 N = nifti;
%                 DIM = [Nf 1 1];
%                 dat = file_array(imgfname,[DIM 1],'FLOAT32');
%                 N.dat = dat;
%                 V     = [imgdt 1 1]; %./ DIM;   % new voxel size
% %                 C     = [imgzero 1 1];       % new origin
%                 C     = [803.1250 0 0];       % new origin
%                 N.mat = [...
%                     V(1)  0     0               -C(1);...
%                     0     V(2)  0               -C(2);...
%                     0     0     V(3)            -C(3);...
%                     0     0     0               1];
%                 N.mat_intent = 'Aligned';
%                 create(N);
%             end
%             delete(D);
        end
    end
end
delete(Depochs);