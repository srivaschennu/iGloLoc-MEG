function plotcluster(sesslist,condlist,modality,varargin)

loadsubj
loadpaths

colorlist = {
    'loc. std.'    [0         0    1.0000]
    'loc. dev.'    [0    0.5000         0]
    'glo. std.'    [1.0000    0         0]
    'glo. dev.'    [0    0.7500    0.7500]
    'omi.'         [0.7500    0    0.7500]
    'ctrl.'        [0.7500    0.7500    0]
    'attend-auditory'      [0    0.5000    0.5000]
    'attend-visual'  [0.5000    0    0.5000]
    %     'interference'      [0    0.2500    0.7500]
    %     'early glo. std.'   [0.5000    0.5000    0]
    %     'late glo. std.'    [0.2500    0.5000    0]
    };

param = finputcheck(varargin, { 'ylim', 'real', [], []; ...
    'clim', 'real', [], []; ...
    'dir', 'string', {'pos','neg','both'}, 'both'; ...
    'alpha', 'real', [], 0.05; ...
    'plotwin', 'real', [], [-200 700]; ...
    'statwin', 'real', [], [-200 700]; ...
    'xlim', 'real', [], [-100 300]; ...
    'xlabel', 'string', {'on','off'}, 'off'; ...
    'ylabel', 'string', {'on','off'}, 'off'; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'colorbar', 'string', {'on','off'}, 'off'; ...
    'legendstrings', 'cell', {}, {}; ...
    'legendlocation', 'string', {}, 'Best'; ...
    });

switch modality
    case 'EEG'
        if isempty(param.ylim)
            param.ylim = [-4 4];
        end
        plotunits = '\muV';
    case 'MEGMAG'
        if isempty(param.ylim)
            param.ylim = [-200 200];
        end
        plotunits = 'fT';
    case 'MEGPLANAR'
        if isempty(param.ylim)
            param.ylim = [-2 2];
        end
        plotunits = 'fT/mm';
    case 'MEGCOMB'
        if isempty(param.ylim)
            param.ylim = [-2 2];
        end
        plotunits = 'fT/mm';
end

%sampling period of data
samptime = 5;

%% load contrast and identify clusters

for c = 1:length(condlist)
    contname{c} = sprintf('%s_%s',sesslist{c},condlist{c});
end

load(sprintf('%s%s-%s_stat_%s.mat',filepath,contname{1},contname{2},modality),'stat');

%% plot data
fontsize = 16;

for subjidx = 1:length(subjlist)
    subjcond1vol = spm_read_vols(spm_vol(sprintf('%simages/%s_%s_%d-%d_%s.nii',filepath,lower(subjlist{subjidx,1}),contname{1},param.plotwin(1),param.plotwin(2),modality)));
    subjcond2vol = spm_read_vols(spm_vol(sprintf('%simages/%s_%s_%d-%d_%s.nii',filepath,lower(subjlist{subjidx,1}),contname{2},param.plotwin(1),param.plotwin(2),modality)));
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


diffcond = cond1vol-cond2vol;
timeline = param.plotwin(1):samptime:param.plotwin(2);

if ~isempty(stat.clusters)
    statwinidx = intersect(find(timeline>=stat.statwin(1)),find(timeline<=stat.statwin(2)));
    
    %select clusters within specified time window
    selectclusters = timeline(statwinidx(1) + cell2mat({stat.clusters.tstart}) - 1) >= param.statwin(1) & ...
        timeline(statwinidx(1) + cell2mat({stat.clusters.tstop}) - 1) <= param.statwin(2);
    stat.clusters = stat.clusters(selectclusters);
    
    %select clusters in specified direction (positive/negative clusters)
    selectclusters = false(1,length(stat.clusters));
    for c = 1:length(stat.clusters)
        plottimeidx = statwinidx(1) + stat.clusters(c).tmax -1;
        clustpeak = diffcond(:,:,plottimeidx);
        clustsum = sum(clustpeak(stat.mask(:,:,stat.clusters(c).tmax) == stat.clusters(c).clusternum));
        if (strcmp(param.dir,'both') || strcmp(param.dir,'pos')) && clustsum > 0
            selectclusters(c) = true;
        elseif (strcmp(param.dir,'both') || strcmp(param.dir,'neg')) && clustsum < 0
            selectclusters(c) = true;
        end
    end
    stat.clusters = stat.clusters(selectclusters);
end

if ~isempty(stat.clusters)
    [~,maxclustidx] = max(cell2mat({stat.clusters.clustersize}));
    plottimeidx = statwinidx(1) + stat.clusters(maxclustidx).tmax -1;
    plotpntidx = stat.clusters(maxclustidx).pmax;
else
    warning('No clusters found!');
    maxclustidx = [];
    
    statwinidx = intersect(find(timeline>=param.statwin(1)),find(timeline<=param.statwin(2)));
    
    if strcmp(param.dir,'both') || strcmp(param.dir,'pos')
        [maxvals,maxtimes] = max(diffcond(:,:,statwinidx),[],3);
        [~,maxtidx] = max(maxvals(:));
        plottimeidx = statwinidx(1) +maxtimes(maxtidx) -1;
        
        [maxvals,maxridx] = max(diffcond(:,:,plottimeidx),[],1);
        [~,plotpntidx(2)] = max(maxvals);
        plotpntidx(1) = maxridx(plotpntidx(2));
        
    elseif strcmp(param.dir,'neg')
        [minvals,mintimes] = min(diffcond(:,:,statwinidx),[],3);
        [~,mintidx] = min(minvals(:));
        plottimeidx = statwinidx(1) +mintimes(mintidx) -1;
        
        [minvals,minridx] = min(diffcond(:,:,plottimeidx),[],1);
        [~,plotpntidx(2)] = min(minvals);
        plotpntidx(1) = minridx(plotpntidx(2));
    end
end

figname = sprintf('%s-%s',contname{1},contname{2});
figure;
figpos = get(gcf,'Position');
figpos(3) = figpos(3)*(2/3);
set(gcf,'Name',figname,'Position',figpos);

subplot(2,1,1);
hold all
% gridscale = 128;

topoimg = rot90(diffcond(:,:,plottimeidx));
% xi = 1:size(topoimg,1);
% yi = 1:size(topoimg,2);
% [~,~,topoimg] = griddata(xi,yi,topoimg,linspace(1,max(xi),gridscale),linspace(1,max(yi),gridscale)');
if ~isempty(param.clim)
    topoimg(topoimg < param.clim(1)) = param.clim(1);
    topoimg(topoimg > param.clim(2)) = param.clim(2);
    topoimg(isnan(topoimg)) = param.clim(1) - 2*(param.clim(2)-param.clim(1))/size(colormap,1);
    caxis([param.clim(1) - 2*(param.clim(2)-param.clim(1))/size(colormap,1) param.clim(2)]);
else
    topoimg(isnan(topoimg)) = min(topoimg(:)) - 2*(max(topoimg(:))-min(topoimg(:)))/size(colormap,1);
end
colormap([1 1 1;colormap]);
imagesc(topoimg);

climits = caxis; axis square;
hold on

scaledpntidx = round(plotpntidx * size(topoimg,1)/size(diffcond,1));
scaledpntidx(2) = size(topoimg,1) - scaledpntidx(2);
scatter(scaledpntidx(1),scaledpntidx(2),80,[1 1 1],'filled');

if ~isempty(maxclustidx) && stat.clusters(maxclustidx).clusterpval < param.alpha
    topomask = rot90(stat.stat(:,:,stat.clusters(maxclustidx).tmax));
    topomask(rot90(stat.mask(:,:,stat.clusters(maxclustidx).tmax)) ~= stat.clusters(maxclustidx).clusternum) = 0;
%     [~,~,topomask] = griddata(xi,yi,topomask,linspace(1,max(xi),gridscale),linspace(1,max(yi),gridscale)');
    contour(topomask > 0,1,'k','LineWidth',2);
    caxis(climits);
end

if strcmp(param.colorbar,'on')
    colorbar
else
    cb_h = colorbar;
    set(cb_h,'Visible','off');
end

set(gca,'FontSize',fontsize,'YDir','reverse','XLim',[1 size(topoimg,1)],'YLim',[1 size(topoimg,2)],'Visible','off');

subplot(2,1,2);

plotdata = [squeeze(cond1vol(plotpntidx(1),plotpntidx(2),:)) squeeze(cond2vol(plotpntidx(1),plotpntidx(2),:))];

if isempty(param.legendstrings)
    param.legendstrings = contname;
end

curcolororder = get(gca,'ColorOrder');
colororder = zeros(length(param.legendstrings),3);
for str = 1:length(param.legendstrings)
    cidx = strcmp(param.legendstrings{str},colorlist(:,1));
    if sum(cidx) == 1
        colororder(str,:) = colorlist{cidx,2};
    else
        colororder(str,:) = curcolororder(str,:);
    end
end

set(gca,'ColorOrder',cat(1,colororder,[0 0 0]));
hold on
plot(timeline,plotdata','LineWidth',2);
box on

set(gca,'XLim',param.xlim,'YLim',param.ylim,'FontSize',fontsize);

line([0 0],param.ylim,'LineStyle',':','Color','black','LineWidth',0.5);
line(xlim,[0 0],'LineStyle',':','Color','black','LineWidth',0.5);
line([timeline(plottimeidx) timeline(plottimeidx)],param.ylim,'LineStyle','--','Color','red','LineWidth',2);

set(suptitle(sprintf('%dms',timeline(plottimeidx))),'FontSize',fontsize);

if ~isempty(maxclustidx) && stat.clusters(maxclustidx).clusterpval < param.alpha
    if stat.clusters(maxclustidx).clusterpval >= 0.00001
        title(sprintf('p = %.5f',stat.clusters(maxclustidx).clusterpval));
    else
        title(sprintf('p = %.1e',stat.clusters(maxclustidx).clusterpval));
    end
    
    line(timeline(statwinidx(1) + [stat.clusters(maxclustidx).tstart stat.clusters(maxclustidx).tstop]-1),...
        [param.ylim(1) param.ylim(1)],'LineStyle','-','Color','blue','LineWidth',8);
else
    title(' ');
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

if strcmp(param.legend,'on')
        legend(param.legendstrings,'Location',param.legendlocation,'Interpreter','none');
        legend('boxoff')
end

export_fig(gcf,sprintf('figures/%s_%s_%d-%d.eps',figname,modality,param.statwin(1),param.statwin(2)));
close(gcf);


