function plotdcm(DCM)

% plot attributes
fontname = 'Times';
fontsize = 12;
fontweight = 'bold';
linewidth = 2;

vsize = 1200;
vcol = 'black';
gap = 2.5;

figure('Color','white','Name',mfilename);
figpos = get(gcf,'Position');
figpos = [figpos(1) figpos(2) figpos(3)*2 figpos(4)*2];
set(gcf,'Position',figpos);

if isfield(DCM,'name')
    [~,modelname] = fileparts(DCM.name);
    set(gcf,'Name',modelname);
end

% plot nodes
hScat = scatter3(DCM.Lpos(1,:)', DCM.Lpos(2,:)', DCM.Lpos(3,:)',...
    vsize, vcol, 'MarkerEdgeColor', [0 0 0],'LineWidth',linewidth);

hold all

% plot node labels
for v = 1:length(DCM.Sname)
    text(DCM.Lpos(1,v)-2.5*gap,DCM.Lpos(2,v),DCM.Lpos(3,v),DCM.Sname{v},...
        'FontName',fontname,'FontSize',fontsize,'FontWeight',fontweight);
end

hAnnotation = get(hScat,'Annotation');
hLegendEntry = get(hAnnotation,'LegendInformation');
set(hLegendEntry,'IconDisplayStyle','off')

set(gca,'Visible','off','DataAspectRatioMode','manual');
view(0,90);

if isfield(DCM,'Ep')
    DCM.Ep.B{1} = (exp(DCM.Ep.B{1}))-1;
end

% plot forward (green), backward (red) and lateral (blue) connections
for from = 1:size(DCM.A{1},2)
    for to = 1:size(DCM.A{1},1)
        if DCM.B{1}(to,from)
            linestyle = '--';
        else
            linestyle = '-';
        end
        if DCM.A{1}(to,from)
            line([DCM.Lpos(1,from)+gap DCM.Lpos(1,to)+gap],[DCM.Lpos(2,from)+gap DCM.Lpos(2,to)+gap],[DCM.Lpos(3,from)+gap DCM.Lpos(3,to)+gap],...
                'Color','green','LineWidth',linewidth,'LineStyle',linestyle);
            scatter3(DCM.Lpos(1,to)+gap,DCM.Lpos(2,to)+gap,DCM.Lpos(3,to)+gap,150,'green','filled');
        end
        if DCM.A{2}(to,from)
            line([DCM.Lpos(1,from)-gap DCM.Lpos(1,to)-gap],[DCM.Lpos(2,from)-gap DCM.Lpos(2,to)-gap],[DCM.Lpos(3,from)-gap DCM.Lpos(3,to)-gap],...
                'Color','red','LineWidth',linewidth,'LineStyle',linestyle);
            scatter3(DCM.Lpos(1,to)-gap,DCM.Lpos(2,to)-gap,DCM.Lpos(3,to)-gap,150,'red','filled');
        end
        if DCM.A{3}(to,from)
            line([DCM.Lpos(1,from) DCM.Lpos(1,to)],[DCM.Lpos(2,from) DCM.Lpos(2,to)],[DCM.Lpos(3,from) DCM.Lpos(3,to)],...
                'Color','blue','LineWidth',linewidth,'LineStyle',linestyle);
            scatter3(DCM.Lpos(1,to),DCM.Lpos(2,to),DCM.Lpos(3,to),150,'blue','filled');
        end
        
        % display posterior Bs alongside connections
        if DCM.B{1}(to,from)
            if isfield(DCM,'stats')
                textstr = sprintf('%.2f (%.2f)',DCM.Pp.B{1}(to,from),DCM.stats.pvalB(to,from));
%             elseif isfield(DCM,'Pp')
%                 textstr = sprintf('%.2f',DCM.Pp.B{1}(to,from));
            elseif isfield(DCM,'Ep')
                textstr = sprintf('%.2f',DCM.Ep.B{1}(to,from));
            end
            
            if to ~= from
                if DCM.A{1}(to,from)
                    gaps = [gap 0 0];
                    textcolor = 'green';
                elseif DCM.A{2}(to,from)
                    gaps = [0 gap 0];
                    textcolor = 'red';
                elseif DCM.A{3}(to,from)
                    gaps = [gap 0 gap];
                    textcolor = 'blue';
                end
            else
                % plot intrinsic local connections
                gaps = [-5*gap,2*gap,0];
                textcolor = 'black';
                scatter3(DCM.Lpos(1,to)+5*gap,DCM.Lpos(2,to),DCM.Lpos(3,to),150,'o','black','LineWidth',linewidth);
            end
            if exist('textstr','var')
                text((DCM.Lpos(1,from)+DCM.Lpos(1,to))/2+gaps(1), (DCM.Lpos(2,from)+DCM.Lpos(2,to))/2+gaps(2), (DCM.Lpos(3,from)+DCM.Lpos(3,to))/2+gaps(3),...
                    textstr,'FontName',fontname,'FontSize',fontsize,'Color',textcolor);
            end
        end
    end
end

% highlight nodes with inputs
for i = 1:length(DCM.C)
    if DCM.C(i)
        scatter3(DCM.Lpos(1,i)-5*gap,DCM.Lpos(2,i),DCM.Lpos(3,i),150,'d','black','filled');
        if isfield(DCM,'stats')
            textstr = sprintf('%.2f (%.2f)',DCM.Pp.C(i),DCM.stats.pvalC(i));
        elseif isfield(DCM,'Pp')
            textstr = sprintf('%.2f',DCM.Pp.C(i));
        end
        textcolor = 'black';
        if exist('textstr','var')
            text(DCM.Lpos(1,i)+6*gap,DCM.Lpos(2,i),DCM.Lpos(3,i),...
                textstr,'FontName',fontname,'FontSize',fontsize,'Color',textcolor);
        end
    end
end