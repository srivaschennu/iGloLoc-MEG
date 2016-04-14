function plotdcmsrc(condlist,modality,modelnum,varargin)

loadpaths
loadsubj

dcmdir = 'DCM-final/';

param = finputcheck(varargin, { 'ylim', 'real', [], []; ...
    'xlabel', 'string', {'on','off'}, 'off'; ...
    'ylabel', 'string', {'on','off'}, 'off'; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'legendstrings', 'cell', {}, {}; ...
    'legendlocation', 'string', {}, 'Best'; ...
    });

fontsize = 16;

for s = 1:size(subjlist,1)
    subjname = subjlist{s,1};
    fprintf('Processing %s.\n',subjname);
    for c = 1:length(condlist)
        load(sprintf('%s%s%s_%s_0-300_%s_DCM%d.mat',filepath,dcmdir,lower(subjname),condlist{c},modality,modelnum));
        if s == 1
            DCMs(c) = DCM;
        else
            for k = 1:length(DCM.K)
                DCMs(c).K{k} = DCMs(c).K{k} + DCM.K{k};
            end
        end
    end
end

for c = 1:length(condlist)
    for k = 1:length(DCM.K)
        DCMs(c).K{k} = DCMs(c).K{k}/size(subjlist,1);
    end
end

DCM = DCMs(1);

xY  = DCM.xY;                   % data
ns  = size(DCM.A{1},1);       % Nr of sources
np  = size(DCM.K{1},2)/ns;    % Nr of population per source
nt  = length(xY.y);             % Nr trial types
t   = xY.pst;                   % PST

for i = 1:ns
    figure('Color','white','Name',DCM.Sname{i});
    hold all
    legendstr = {};
    for j = 1:np
        for k = 1:nt
            if j == np
                h_line = plot(t, DCMs(1).K{k}(:,i + ns*(j - 1)),'LineWidth',3);
                legendstr = cat(1,legendstr,sprintf('trial %i (pop. %i)\n',k,j));
                plot(t, DCMs(2).K{k}(:,i + ns*(j - 1)),'LineStyle','--','LineWidth',3,'Color',get(h_line,'Color'));
                legendstr = cat(1,legendstr,sprintf('trial %i (pop. %i)\n',k,j));
            end
        end
    end
    set(gca,'FontName','Helvetica','FontSize',fontsize);
    xlim([t(1) t(end)]);
    if strcmp(param.legend,'on')% && i == 1
        if isempty(param.legendstrings)
            legend(legendstr,'Location',param.legendlocation);
        else
            legend(param.legendstrings,'Location',param.legendlocation);
        end
    end
    
    if strcmp(param.xlabel,'on')
        xlabel('Time relative to fifth tone (ms)','FontSize',fontsize);
    else
        xlabel(' ','FontSize',fontsize);
    end
    
    if strcmp(param.ylabel,'on')
        ylabel('Source activation','FontSize',fontsize);
    else
        ylabel(' ','FontSize',fontsize);
    end
    
    if ~isempty(param.ylim)
        ylim(param.ylim);
    end
    
    box on
    title(DCM.Sname{i});
    print(gcf,sprintf('figures/%s_DCM%d_%s.tiff',modality,modelnum,DCM.Sname{i}),'-dtiff');
    close(gcf);
end