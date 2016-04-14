function statdcm

loadpaths

% % compare attend-auditory omissions vs omission controls
% sesstypes = {'global','global'};
% % compare attend-visual omissions vs omission controls
sesstypes = {'visual','visual'};

% trialtypes = {'ld','ls'};
trialtypes = {'od','oc'};
modality = 'EEG';
timewin = [0 300];

fprintf('\nConditions:\n');
for t = 1:length(trialtypes)
    condnames{t} = sprintf('%s_%s',sesstypes{t},trialtypes{t});
    fprintf('%s\n',condnames{t});
end
fprintf('\nModality: %s.\n',modality);


fileprefix = sprintf('%s-%s_%d-%d_%s',condnames{1},condnames{2},timewin(1),timewin(2),modality);

load(sprintf('%sDCM_avg_%s.mat',filepath,fileprefix));

plotdcm(DCM);
export_fig(gcf,sprintf('figures/DCM_%s.eps',fileprefix));
close(gcf);

for s = 1:size(DCM.models,1)
    subjDCM = load(DCM.models(s,:));
    allB(s,:,:) = subjDCM.DCM.Ep.B{1};
end
avgB = squeeze(mean(allB,1));
for i = 1:size(avgB,2)
    for j = 1:size(avgB,1)
        if avgB(j,i) ~= 0
            [h,pval,~,stats] = ttest(allB(:,j,i));
            if h == 1
                fprintf('%d%% from %d to %d: t(%d) = %.2f, p = %.4f.\n',...
                    round(avgB(j,i)*100),i,j,stats.df,stats.tstat,pval);
            end
        end
    end
end
