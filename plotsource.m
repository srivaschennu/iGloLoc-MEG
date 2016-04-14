function plotcoord = plotsource(sesslist,condlist,varargin)

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

param = finputcheck(varargin, { 'dim', 'string', {'2d','3d'}, '2d' ; ...
    'xlim', 'real', [], [-200 700]; ...
    'ylim', 'real', [], []; ...
    'xlabel', 'string', {'on','off'}, 'off'; ...
    'ylabel', 'string', {'on','off'}, 'off'; ...
    'val', 'real', [], 3; ...
    'plotcoord', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'legendstrings', 'cell', {}, {}; ...
    'legendlocation', 'string', {}, 'Best'; ...    
    });

for c = 1:length(condlist)
    contname{c} = sprintf('%s_%s',sesslist{c},condlist{c});
end

fontsize = 20;
plotunits = '';
val = param.val;

%% plot source locations
D = spm_eeg_load([filepath 'allsubj_cond.mat']);
load(sprintf('%s%s-%s_stat_%d.mat',filepath,contname{1},contname{2},val),'xSPM');

if isempty(param.plotcoord)
    [~,maxidx] = max(xSPM.Z);
    plotcoord = xSPM.XYZmm(:,maxidx)';
else
    plotcoord = param.plotcoord;
end

if strcmpi(param.dim,'2d')
    D.inv{1}.contrast.fname = {sprintf('%s%s-%s_stat_%d.nii',filepath,contname{1},contname{2},val)};
    D.inv{1}.contrast.format = 'image';
    spm_eeg_inv_image_display(D,1);
    spm_orthviews('Reposition',plotcoord);
    pause
    plotcoord = spm_orthviews('Pos')';
    set(gca,'FontSize',fontsize);
    
elseif strcmpi(param.dim,'3d')
    plotdata = struct('XYZ', xSPM.XYZ,...
        't',   xSPM.Z',...
        'mat', xSPM.M,...
        'dim', xSPM.DIM);
    
    global prevrend
    prevrend.rendfile = '/home/sc03/MATLAB/spm12/rend/render_single_subj.mat';
    prevrend.brt = 1;
    prevrend.col = [
        1     0     0
        0     1     0
        0     0     1
        ];
    
    spm_render(plotdata,1,prevrend.rendfile);
end

figname = sprintf('%s-%s',contname{1},contname{2});
export_fig(gcf,sprintf('figures/%s_%d.tif',figname,val),'-r300');
close(gcf);

%% extract and plot source time course

fontsize = 16;
fprintf('Plotting activation time courses at [%.3f %.3f %.3f].\n',plotcoord);
D.val = val;
D.inv{val}.source.XYZ = plotcoord;
D.inv{val}.source.type = 'trials';
Dsrc = spm_eeg_inv_extract(D);
plotdata = squeeze(Dsrc(1,:,[find(strcmp(contname{1},Dsrc.conditions)) find(strcmp(contname{2},Dsrc.conditions))]));


figure;
figpos = get(gcf,'Position');
figpos(3) = figpos(3)*(2/3);
figpos(4) = figpos(4)*(1/2);
set(gcf,'Name',figname,'Position',figpos);

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

plot(Dsrc.time*1000,plotdata','LineWidth',2);
set(gca,'XLim',param.xlim,'FontSize',fontsize);
box on

if ~isempty(param.ylim)
    set(gca,'YLim',param.ylim);
end

line([0 0],ylim,'LineStyle',':','Color','black','LineWidth',0.5);
line(xlim,[0 0],'LineStyle',':','Color','black','LineWidth',0.5);

set(gcf,'Color','white');
if strcmp(param.xlabel,'on')
    xlabel('Time relative to fifth tone (ms)','FontSize',fontsize);
else
    xlabel(' ','FontSize',fontsize);
end

if strcmp(param.ylabel,'on')
    if isempty(plotunits)
        ylabel('Source amplitude','FontSize',fontsize);
    else
        ylabel(sprintf('Source amplitude (%s)',plotunits),'FontSize',fontsize);
    end
else
    ylabel(' ','FontSize',fontsize);
end

if strcmp(param.legend,'on')
        legend(param.legendstrings,'Location',param.legendlocation,'Interpreter','none');
end

delete(Dsrc);
export_fig(gcf,sprintf('figures/%s_%d.eps',figname,val));
close(gcf);


