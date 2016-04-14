function plotcluster2(sesslist,condlist,modality,varargin)

loadsubj
loadpaths
loadcont

param = finputcheck(varargin, { 'ylim', 'real', [], []; ...
    'condnames', 'cell', {}, {}; ...
    'alpha', 'real', [], 0.05; ...
    'xlim', 'real', [], [-200 700]; ...
    'plotwin', 'real', [], [-200 700]; ...
    'xlabel', 'string', {'on','off'}, 'off'; ...
    'ylabel', 'string', {'on','off'}, 'off'; ...
    });

switch modality
    case 'EEG'
        if isempty(param.ylim)
            param.ylim = [-4 4];
        end
    case 'MEGMAG'
        if isempty(param.ylim)
            param.ylim = [-150 150];
        end
    case 'MEGPLANAR'
        if isempty(param.ylim)
            param.ylim = [-4 4];
        end
end

%% load contrast and identify clusters

for c = 1:length(condlist)
    contname{c} = sprintf('%s_%s',sesslist{c},condlist{c});
end

load(sprintf('%s%s-%s_stat_%s.mat',filepath,contname{1},contname{2},modality),'stat');

%% plot data
fontsize = 16;
filesuffix = '_cond';
file2load = sprintf('%sallsubj%s.mat',filepath,filesuffix);

D = spm_eeg_load(file2load);

plotdata = D(find(strcmp(modality,D.chantype)),:,find(strcmp(contname{1},D.conditions))) - ...
    D(find(strcmp(modality,D.chantype)),:,find(strcmp(contname{2},D.conditions)));
plotunits = D.units{find(strcmp(modality,D.chantype),1,'first')};

for subjidx = 1:length(subjlist)
    subjcond1vol = spm_read_vols(spm_vol(sprintf('%simages/%s_%s_%d-%d_%s.nii',filepath,lower(subjlist{subjidx,1}),contname{1},condlists{2}(1),condlists{2}(2),modality)));
    subjcond2vol = spm_read_vols(spm_vol(sprintf('%simages/%s_%s_%d-%d_%s.nii',filepath,lower(subjlist{subjidx,1}),contname{2},condlists{2}(1),condlists{2}(2),modality)));
    if subjidx == 1
        cond1vol = subjcond1vol;
        cond2vol = subjcond2vol;
    else
        cond1vol = cond1vol + subjcond1vol;
        cond2vol = cond2vol + subjcond2vol;
    end
end
cond1vol = cond1vol / length(subjlist);
cond2vol = cond2vol / length(subjlist);

stattimeidx = find(round(D.time*1000)==condlists{2}(1),1,'first');

if ~isempty(stat.clusters)
    selectclusters = D.time(stattimeidx + cell2mat({stat.clusters.tstart}) - 1)*1000 >= param.plotwin(1) & ...
        D.time(stattimeidx + cell2mat({stat.clusters.tstop}) - 1)*1000 <= param.plotwin(2);
    stat.clusters = stat.clusters(selectclusters);
end

if ~isempty(stat.clusters)
    [~,maxclustidx] = max(cell2mat({stat.clusters.clustersize}));
    plottimeidx = stat.clusters(maxclustidx).tmax;
else
    warning('No clusters found!');
    maxclustidx = [];
    plotwinidx = intersect(find(round(D.time*1000)>=param.plotwin(1)),find(round(D.time*1000)<=param.plotwin(2)));
    plotwinidx = plotwinidx - stattimeidx + 1;
    
    [maxvals,maxtimes] = max(cond1vol(:,:,plotwinidx)-cond2vol(:,:,plotwinidx),[],3);
    [~,maxidx] = max(maxvals(:));
    plottimeidx = plotwinidx(1)+maxtimes(maxidx)-1;
end

figname = sprintf('%s-%s',contname{1},contname{2});
figure;
figpos = get(gcf,'Position');
figpos(3) = figpos(3)*(2/3);
set(gcf,'Name',figname,'Position',figpos);

subplot(2,1,1);

gridscale = 128;

topoimg = rot90(cond1vol(:,:,plottimeidx)-cond2vol(:,:,plottimeidx));
xi = 1:size(topoimg,2);
yi = 1:size(topoimg,1);
[~,~,topoimg] = griddata(xi,yi,topoimg,linspace(1,max(xi),gridscale),linspace(1,max(yi),gridscale)');
topoimg(isnan(topoimg)) = min(topoimg(:)) - 2*(max(topoimg(:))-min(topoimg(:)))/size(colormap,1);
imagesc(topoimg);
colormap([1 1 1;colormap]);
climits = caxis; axis square;
hold on

% if ~isempty(maxclustidx) && stat.clusters(maxclustidx).clusterpval < param.alpha
%     topomask = rot90(stat.stat(:,:,plottime));
% %     topomask(rot90(stat.mask(:,:,plottime)) ~= stat.clusters(maxclustidx).clusternum) = 0;
%     [~,~,topomask] = griddata(xi,yi,topomask,linspace(1,max(xi),gridscale),linspace(1,max(yi),gridscale)');
%     contour(topomask > 0,1,'k','LineWidth',2);
%     caxis(climits);
% end

colorbar
set(gca,'FontSize',fontsize,'YDir','reverse','XLim',[1 size(topoimg,1)],'YLim',[1 size(topoimg,2)],'Visible','off');

subplot(2,1,2);
plot(D.time*1000,plotdata','Color','black');
hold all
set(gca,'XLim',param.xlim,'YLim',param.ylim,'FontSize',fontsize);

line([0 0],param.ylim,'LineStyle',':','Color','black','LineWidth',0.5);
line(xlim,[0 0],'LineStyle',':','Color','black','LineWidth',0.5);
line([D.time(stattimeidx+plottimeidx-1) D.time(stattimeidx+plottimeidx-1)]*1000,param.ylim,'LineStyle','--','Color','red','LineWidth',2);

set(suptitle(sprintf('%dms',round(D.time(stattimeidx+plottimeidx-1)*1000))),'FontSize',fontsize);

if ~isempty(maxclustidx) && stat.clusters(maxclustidx).clusterpval < param.alpha
    if stat.clusters(maxclustidx).clusterpval >= 0.00001
        title(sprintf('p = %.5f',stat.clusters(maxclustidx).clusterpval));
    else
        title(sprintf('p = %.1e',stat.clusters(maxclustidx).clusterpval));
    end
    
    line(D.time(stattimeidx + [stat.clusters(maxclustidx).tstart stat.clusters(maxclustidx).tstop]-1)*1000,...
        [param.ylim(1) param.ylim(1)],'LineStyle','-','Color','blue','LineWidth',8);
end

set(gcf,'Color','white');
if strcmp(param.xlabel,'on')
    xlabel('Time relative to fifth tone (ms)','FontSize',fontsize);
else
    xlabel(' ','FontSize',fontsize);
end

if strcmp(param.ylabel,'on')
    ylabel(sprintf('Amplitude (%s)',plotunits),'FontSize',fontsize);
else
    ylabel(' ','FontSize',fontsize);
end

export_fig(gcf,sprintf('figures/%s_%s_%d-%d.eps',figname,modality,param.plotwin(1),param.plotwin(2)));
close(gcf);


