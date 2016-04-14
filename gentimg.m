function gentimg(subjname,modality)

loadpaths

load conds.mat

if ~exist('modality','var') || isempty(modality)
    modality = 'EEG';
end

condlists = {
    {'ld','ls'} 100 + [-50 50]
    {'gd','gs'} 450 + [-150 150]
    {'od','oc'} 175 + [-50 50]
    %     {'od','oc'} 450 + [-150 150]
    };

sesslist = {'global','visual'};

timeshift = 600;

outdir = sprintf('images/%s/',subjname);
if ~exist([filepath outdir],'dir')
    mkdir([filepath outdir]);
end

file2conv = sprintf('%s%s.mat',filepath,subjname);
fprintf('\nProcessing %s data in %s.\n',modality,file2conv);
Depochs = spm_eeg_load(file2conv);

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
            S.channels = modality;
            S.mode = 'scalp';
            S.timewin = timewin;
            spm_eeg_convert2images(S);
            delete(S.D);
            
            srcimgdir = sprintf('%srb%s/',filepath,subjname);
            destimgdir = sprintf('%s%s%s/',filepath,outdir,filecondname);
            movefile(srcimgdir,destimgdir);
        end
    end
end
delete(Depochs);