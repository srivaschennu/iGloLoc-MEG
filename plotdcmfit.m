function plotdcmfit(condlist,topowin,modality,modelnum,varargin)

loadpaths
loadsubj

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

dcmdir = 'DCM-final/';

param = finputcheck(varargin, { 'ylim', 'real', [], []; ...
    'clim', 'real', [], []; ...
    'xlabel', 'string', {'on','off'}, 'off'; ...
    'ylabel', 'string', {'on','off'}, 'off'; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'colorbar', 'string', {'on','off'}, 'off'; ...
    'legendstrings', 'cell', {}, {}; ...
    'legendlocation', 'string', {}, 'Best'; ...    
    'dir', 'string', {'pos','neg','both'}, 'both'; ...
    'plotchan', 'string', {}, ''; ...
    });

fontsize = 16;

% for s = 1:size(subjlist,1)
%     subjname = subjlist{s,1};
%     fprintf('Processing %s.\n',subjname);
%     for c = 1:length(condlist)
%         load(sprintf('%s%s%s_%s_0-300_EEG_DCM%d.mat',filepath,dcmdir,lower(subjname),condlist{c},modelnum));
%         if s == 1
%             DCMs(c) = DCM;
%         else
%             for k = 1:length(DCM.K)
%                 DCMs(c).K{k} = DCMs(c).K{k} + DCM.K{k};
%             end
%         end
%     end
% end
%

for s = 1:size(subjlist,1)
    subjname = lower(subjlist{s,1});
    fprintf('Processing %s.\n',subjname);
    load(sprintf('%s%s%s_%s_0-300_%s_DCM%d.mat',filepath,dcmdir,subjname,condlist,modality,modelnum));
    D = spm_eeg_load(sprintf('%s%s_cond.mat',filepath,subjname));
    
    if s == 1
        xY  = DCM.xY;                   % data
        nt  = length(xY.y);             % Nr trial types
        ne  = size(xY.y{1},2);          % Nr electrodes
        nb  = size(xY.y{1},1);          % Nr time bins
        timeline   = xY.pst;                   % PST
        avgfit = zeros(nb,ne,nt,size(subjlist,1));
    end
    
    % get spatial projector
    % -----------------------------------------------------------------
    try
        U = DCM.M.U';
    catch
        U = 1;
    end
    
    for c = 1:2
        thisfit  = DCM.H{c}*U;
        for b = D.badchannels
            thisfit = [thisfit(:,1:b-1) NaN(nb,1) thisfit(:,b:end)];
        end
        avgfit(:,:,c,s) = thisfit;
    end
end
avgfit = nanmean(avgfit,4);

topowinidx = [find(abs(timeline-topowin(1)) == min(abs(timeline-topowin(1)))) find(abs(timeline-topowin(2)) == min(abs(timeline-topowin(2))))];
diffcond = avgfit(topowinidx(1):topowinidx(2),:,1) - avgfit(topowinidx(1):topowinidx(2),:,2);

if strcmp(param.dir,'pos')
    [maxchanvals, plottimeidx] = max(diffcond);
    [~,plotchanidx] = max(maxchanvals);
    plottimeidx = plottimeidx(plotchanidx);
elseif strcmp(param.dir,'neg')
    [minchanvals, plottimeidx] = min(diffcond);
    [~,plotchanidx] = min(minchanvals);
    plottimeidx = plottimeidx(plotchanidx);
elseif strcmp(param.dir,'both')
    [maxchanvals, plottimeidx] = max(abs(diffcond));
    [~,plotchanidx] = max(maxchanvals);
    plottimeidx = plottimeidx(plotchanidx);
end
plottimeidx = plottimeidx + topowinidx(1) - 1;

[~,dcmname] = fileparts(DCM.name);

figure;
figpos = get(gcf,'Position');
figpos(3) = figpos(3)*(2/3);
set(gcf,'Name',dcmname,'Position',figpos,'Color','white');

try
    pos = DCM.xY.coor2D;
catch
    [xy, label]  = spm_eeg_project3D(DCM.M.dipfit.sens, DCM.xY.modality);
    [sel1, sel2] = spm_match_str(DCM.xY.name, label);
    pos = xy(:, sel2);
end

in           = [];
in.type      = DCM.xY.modality;
in.f         = gcf;
in.noButtons = 1;
in.cbar      = 0;
in.plotpos   = 1;
in.ParentAxes = subplot(2,1,1);

if ~isempty(param.plotchan)
    in.plotchan = find(strcmp(param.plotchan,DCM.xY.name));
else
    in.plotchan = plotchanidx;
end

plotdata = (avgfit(plottimeidx,:,1) - avgfit(plottimeidx,:,2))';
% plotdata = (avgfit(plottimeidx,:,1))';

if ~isempty(param.clim)
    plotdata(plotdata < param.clim(1)) = param.clim(1);
    plotdata(plotdata > param.clim(2)) = param.clim(2);
end
    
spm_eeg_plotScalpData2(plotdata, pos , DCM.xY.name, in);

if ~isempty(param.clim)
    caxis([param.clim(1) - (param.clim(2)-param.clim(1))/(size(colormap,1)-1) param.clim(2)]);
end

if strcmp(param.colorbar,'on')
    colorbar
else
    cb_h = colorbar;
    set(cb_h,'Visible','off');
end


set(gca,'FontSize',fontsize);
set(suptitle(sprintf('%dms',round(timeline(plottimeidx)))),'FontSize',fontsize);

subplot(2,1,2);
hold all

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

plotdata = [avgfit(:,in.plotchan,1) avgfit(:,in.plotchan,2)];
plotdata = plotdata - repmat(plotdata(1,:),size(plotdata,1),1);
plot(timeline,plotdata,'LineWidth',2);

xlim([-100 timeline(end)]);

set(gca,'FontName','Helvetica','FontSize',fontsize);

if strcmp(param.xlabel,'on')
    xlabel('Time relative to fifth tone (ms)','FontSize',fontsize);
else
    xlabel(' ','FontSize',fontsize);
end

if strcmp(param.ylabel,'on')
    ylabel('Predicted response','FontSize',fontsize);
else
    ylabel(' ','FontSize',fontsize);
end

if ~isempty(param.ylim)
    ylim(param.ylim);
end
line([timeline(plottimeidx) timeline(plottimeidx)],ylim,'LineStyle','--','Color','red','LineWidth',2);
line([0 0],ylim,'LineStyle',':','Color','black','LineWidth',0.5);
line(xlim,[0 0],'LineStyle',':','Color','black','LineWidth',0.5);

if strcmp(param.legend,'on')
        legend(param.legendstrings,'Location',param.legendlocation,'Interpreter','none');
        legend('boxoff')
end

box on
set(gcf,'Color','white');
export_fig(gcf,sprintf('figures/%s_%d-%dms.eps',dcmname,topowin));
close(gcf);
end