function subcond(subjname)

subjname = lower(subjname);

loadpaths

sesslist = {'global','visual'};

timeshift = 600; %milliseconds

condlists = {
    {'ld','oc'}
    {'ls','oc'}
    {'gd','oc'}
    {'gs','oc'}
    {'od','oc'}
    {'x2','xc'}
    {'y2','yc'}
    {'xc','yc'}
    };

fullfilename = sprintf('%s%s_erp.mat',filepath,subjname);
fprintf('Reading %s.\n',fullfilename);
Derp = spm_eeg_load(fullfilename);

% contidx = 1;
% contmat = zeros(length(sesslist)*length(condlists),Derp.ntrials);
% 
% fprintf('\n');
% for sessidx = 1:length(sesslist)
%     sessname = sesslist{sessidx};
%     
%     for clidx = 1:length(condlists)
%         condlist = condlists{clidx};
%         contlist{contidx} = sprintf('%s_%s-%s',sessname,condlist{1},condlist{2});
%         
%         contmat(contidx,strcmp(sprintf('%s_%s',sessname,condlist{1}),Derp.conditions)) = 1;
%         contmat(contidx,strcmp(sprintf('%s_%s',sessname,condlist{2}),Derp.conditions)) = -1;
%         
%         fprintf('%s: %s - %s\n',contlist{contidx},...
%             sprintf('%s_%s',sessname,condlist{1}),sprintf('%s_%s',sessname,condlist{2}));
%         
%         contidx = contidx+1;
%     end
% end
% fprintf('\n');
% 
% S = [];
% S.D = Derp;
% S.c = contmat;
% S.label = contlist;
% S.weighted = 0;
% D = spm_eeg_contrast(S);

D = Derp;

D = timeonset(D,D.timeonset-(timeshift/1000));

S = [];
S.D = D;
S.timewin = [-200 0];
D = spm_eeg_bc(S);
% delete(S.D);

if isfield(Derp,'inv')
    D.inv = Derp.inv;
end

S = [];
S.D = D;
S.outfile = sprintf('%s_cond',subjname);
D = spm_eeg_copy(S);
delete(S.D);
