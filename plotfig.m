% function plotfig(filename,plotchan,varargin)
%
% param = finputcheck(varargin, { ...
%     'ylim', 'real', [], []; ...
%     'topowin', 'real', [], []; ...
%     'legendstrings', 'cell', {}, {}; ...
%     });
%
% load(filename);

plotchan = 'EEG049';
param.topowin = [100 200];
param.legendstrings = {'attend sequences','attend visual'};
param.ylim = [-3 3];

fontname = 'Helvetica';
fontsize = 20;
linewidth = 2;

colorlist = {
    'local standard'    [0         0    1.0000]
    'local deviant'     [0    0.5000         0]
    'global standard'   [1.0000    0         0]
    'global deviant'    [0    0.7500    0.7500]
    'omission'          [0.7500    0    0.7500]
    'omission control'  [0.7500    0.7500    0]
    'attend tones'      [0    0.5000    0.5000]
    'attend sequences'  [0.5000    0    0.5000]
    'attend visual'     [0    0.2500    0.7500]
    'early glo. std.'   [0.5000    0.5000    0]
    'late glo. std.'    [0.2500    0.5000    0]
    };

plotdata = mean(erpdata,4);
plotchanidx = find(strcmp(plotchan,{chanlocs.labels}));
latpnt = find(times-timeshift >= param.topowin(1) & times-timeshift <= param.topowin(2));

figure('Color','white');

[maxval, maxidx] = max(abs(plotdata(:,latpnt,1)),[],2);%-plotdata(:,latpnt,2)),[],2);
[~, maxchanidx] = max(maxval);
plottimeidx = latpnt(1)-1+maxidx(maxchanidx);

for c = 1:length(param.condnames)
    subplot(2,2,c);
    topoplot(plotdata(:,plottimeidx,c),chanlocs,'emarker2',{plotchanidx,'o','green',14,1}); colorbar;
    if c == 1
        climits = caxis;
    else
        caxis(climits);
    end
    set(gca,'FontName',fontname,'FontSize',fontsize);
end

subplot(2,2,3:4);
hold all
for c = 1:length(param.condnames)
    plot(times,plotdata(plotchanidx,:,c),'LineWidth',linewidth,...
        'DisplayName',param.legendstrings{c},...
        'Color',colorlist{strcmp(param.legendstrings{c},colorlist(:,1)),2});
end
set(gca,'FontName',fontname,'FontSize',fontsize);
xlim([times(1) times(end)]);
if ~isempty(param.ylim)
    ylim(param.ylim);
else
    param.ylim = ylim;
end

set(gca,'XTick',times(1):200:times(end));
xlabel('Time (ms)','FontName',fontname,'FontSize',fontsize);
ylabel('Voltage (\muV)','FontName',fontname,'FontSize',fontsize);
legend('Location','NorthWest');

line([times(plottimeidx(1)) times(plottimeidx(1))],param.ylim,...
    'LineWidth',linewidth','LineStyle','--','Color','red');

set(gcf,'Color','white');