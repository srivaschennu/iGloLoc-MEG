function calcerp(subjname)

subjname = lower(subjname);

loadpaths

load conds.mat

sesslist = {'global','visual'};
condlist = {'ld','ls','gd','gs','od','oc','x1','x2','x3','y1','y2','y3','xc','yc'};

fullfilename = sprintf('%s%s.mat',filepath,subjname);
fprintf('Reading %s.\n',fullfilename);
Depochs = spm_eeg_load(fullfilename);

if exist(sprintf('%s%s_inv.mat',filepath,subjname),'file')
    subjinv = load(sprintf('%s%s_inv.mat',filepath,subjname));
end

contidx = 1;
contmat = zeros(length(sesslist)*length(condlist),Depochs.ntrials);

fprintf('\n');
for sessidx = 1:length(sesslist)
    sessname = sesslist{sessidx};
    
    for condidx = 1:length(condlist)
        condname = condlist{condidx};
        contlist{contidx} = sprintf('%s_%s',sessname,condname);
        
        selectevents = conds.(condname).events;
        if isfield(conds.(condname),'prop')
            selectprop = conds.(condname).prop;
        else
            selectprop = 1;
        end
        
        for e = 1:length(selectevents)
            evidx = find(strcmp([upper(sessname(1)) selectevents{e}],Depochs.conditions));
            switch selectprop
                case 2
                    evidx = evidx(1:floor(length(evidx)/2));
                case 3
                    evidx = evidx(floor(length(evidx)/2)+1:end);
            end
            contmat(contidx,evidx) = 1;
        end
        
        fprintf('%s: %d epochs\n',contlist{contidx},sum(contmat(contidx,:)));
        
        %this line ensures that spm_eeg_contrast means over epochs
        %selected, rather than summing
        contmat(contidx,:) = contmat(contidx,:) ./ sum(contmat(contidx,:));
        
        contidx = contidx+1;
    end
end
fprintf('\n');

S = [];
S.D = Depochs;
S.c = contmat;
S.label = contlist;
S.weighted = 0;
D = spm_eeg_contrast(S);

if exist('subjinv','var')
    val = 1;
    D.val = val;
    D.inv{val} = subjinv.inv{1};
end

S = [];
S.D = D;
S.outfile = sprintf('%s_erp',subjname);
D = spm_eeg_copy(S);
delete(S.D);
