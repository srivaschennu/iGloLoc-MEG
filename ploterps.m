function ploterps

loadsubj

sesslist = {'global','visual'};
sessnames = {'attend auditory','attend visual'};
modalities = {'EEG'};%,'MEGMAG','MEGPLANAR'};

condlists = {
    {'ld-oc','ls-oc'} 200 + [-100 100] {'local deviant','local standard'}
    {'gd-oc','gs-oc'} 450 + [-150 150] {'global deviant','global standard'}
    {'od-oc'}         200 + [-100 100] {'omission'}
%     {'od-oc'}         450 + [-150 150] {'omission'}
%     {'x2-xc','y2-yc'} 450 + [-150 150] {'x omission','y omission'}
    };

% condlists = {
%     {'ld','ls'} 200 + [-100 100] {'local deviant','local standard'}
%     {'gd','gs'} 450 + [-150 150] {'global deviant','global standard'}
%     {'od','oc'} 200 + [-100 100] {'omission','omission control'}
% %     {'od','oc'} 450 + [-150 150] {'omission','omission control'}
%     };

P = cbupool(size(condlists,1));
matlabpool(P);

for sessidx = 1:length(sesslist)
    sesstype = sesslist{sessidx};
    sessname = sessnames{sessidx};
    parfor c = 1:size(condlists,1);
        condlist = condlists{c,1};
        timewin = condlists{c,2};
        condnames = condlists{c,3};
        condnames = strcat(sessname,'_',condnames);
        for m = 1:length(modalities)
            ploterp(sesstype,condlist,'topowin',timewin,'subcond','off',...
                'condnames',condnames,'modality',modalities{m});
            close all
        end
    end
end

matlabpool close