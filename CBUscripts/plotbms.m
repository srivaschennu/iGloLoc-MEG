function plotbms

loadpaths

%% UNCOMMENT AS NEEDED
% compare attend-auditory omissions vs omission controls
sesstypes = {'global','global'};
% compare attend-visual omissions vs omission controls
% sesstypes = {'visual','visual'};

trialtypes = {'ld','ls'};
% trialtypes = {'od','oc'};

modality = 'EEG';
% modality = 'MEG';
% modality = 'MEGPLANAR';

timewin = [0 300];
% timewin = [0 150];

nameprefix = 'M';

%------------------------------------------------------------------------
winmodidx = 6;
nameprefix = '';
% 
% winmodidx = 18;
% conidx = 3;
%------------------------------------------------------------------------
%%

% ylimits = [0 6000];

fprintf('\nConditions:\n');
for t = 1:length(trialtypes)
    condnames{t} = sprintf('%s_%s',sesstypes{t},trialtypes{t});
    fprintf('%s\n',condnames{t});
end
fprintf('\nModality: %s.\n',modality);

if exist('winmodidx','var')
    fileprefix = sprintf('%s-%s_%d-%d_%s_DCM%d',condnames{1},condnames{2},timewin(1),timewin(2),modality,winmodidx);
else
    fileprefix = sprintf('%s-%s_%d-%d_%s',condnames{1},condnames{2},timewin(1),timewin(2),modality);
end

%% plot results
load(sprintf('%s%s_BMS.mat',filepath,fileprefix));

fontsize = 20;
tickdist = 2;
numuniqmod = length(BMS.DCM.ffx.SF);

xtick = 2:tickdist:numuniqmod;
xticklabels = [];
if exist('winmodidx','var')
    for m = xtick
        xticklabels = cat(1,xticklabels,{sprintf('%s%d.%d',nameprefix,winmodidx,m)});
    end
else
    for m = xtick
        xticklabels = cat(1,xticklabels,{sprintf('%s%d',nameprefix,m)});
    end
end

figure('Color','white');
bardata = BMS.DCM.ffx.SF-min(BMS.DCM.ffx.SF);
bar(bardata);
set(gca,'XLim',[0 numuniqmod+1],'XTick',xtick,'XTickLabel',xticklabels,'FontSize',fontsize);
if exist('ylimits','var')
    ylim(ylimits);
end
ylabel('Relative log-evidence');
export_fig(gcf,sprintf('figures/%s_LE.eps',fileprefix));
close(gcf);

figure('Color','white');
bardata = BMS.DCM.ffx.model.post();
bar(bardata);
set(gca,'XLim',[0 numuniqmod+1],'YLim',[0 1],'XTick',xtick,'XTickLabel',xticklabels,'FontSize',fontsize);
ylabel('Posterior probability');
export_fig(gcf,sprintf('figures/%s_PP.eps',fileprefix));
close(gcf);

sortedevidence = sort(BMS.DCM.ffx.SF-min(BMS.DCM.ffx.SF),'descend');
winmodidx = find(BMS.DCM.ffx.model.post == max(BMS.DCM.ffx.model.post));
fprintf('Winning model is %s%d.\nSecond-best is %s%d, delta(F) = %d.\n',nameprefix,...
    winmodidx,...
    nameprefix,...
    find(sortedevidence(2) == (BMS.DCM.ffx.SF-min(BMS.DCM.ffx.SF))),...
    round(sortedevidence(1)-sortedevidence(2)));
