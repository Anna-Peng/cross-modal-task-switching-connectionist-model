close all
clear all

% folder=input('load which folder? ', 's');
folder='PlotData'
ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
whichdatefile=input('[input date file] ','s'); 

% whichdatefile='180325'
datefile=strcat('zcomparemodels', whichdatefile, '.mat');
load(datefile);

filename=RT.Pure(2:end,1);
x=num2cell(1:length(filename))';
[x,filename]
analysefile=input('[which files to plot? ] ','s');
titletitle=input('[Title on top? ] ','s');
whatRT=2;%input('[which kind of RT to plot? 1=All RTs, 2=Yes RT only ] ');
standard=input('Standard legnend on Age or other setting? 1=Yes, 0=No ');
graphsize=input('large graph/ small graph 1=large, 2=small ');
if whatRT==1
    locaRT=2;
    type='allRT';
elseif whatRT==2
    locaRT=18;
    type='YesRT';
end

if isempty(analysefile) analysefile=[1:length(filename)]'; else analysefile=str2num(analysefile); end


    if standard==1; 
        legendname={'Old', 'Middle', 'Young'};
    else
        for i=1:length(analysefile) 
        legendname{i}=input('[Enter legend name] ','s');
        end
    end


    for i=1:length(analysefile)
    index=strfind(RT.Pure(:,1),cell2mat(filename(analysefile(i))));
    ft=cellfun('isempty', index);
    index(ft)={0};
    index=cell2mat(index);
    indexA(:,i)=logical(index);
    name(i)=filename(analysefile(i));
    end
    
    % plot overall RT and accuracy

    for ii=1:size(indexA,2)
    y1(:,ii)=[RT.Pure(indexA(:,ii),locaRT);RT.Rep(indexA(:,ii),locaRT);RT.Swi(indexA(:,ii),locaRT)];
    y1CI(:,ii)=[RTCI.Pure(indexA(:,ii),locaRT);RTCI.Rep(indexA(:,ii),locaRT);RTCI.Swi(indexA(:,ii),locaRT)];
    end
    
    y1=cell2mat(y1);
    y1CI=cell2mat(y1CI);
    errorbarinterval=size(y1,1)/size(y1,2);
    errorbaraxis=[0:errorbarinterval:size(y1,1);0+errorbarinterval:errorbarinterval:size(y1,1)+errorbarinterval]';
    
    for ii=1:size(indexA,2)
    y2(:,ii)=[RT.Pure(indexA(:,ii),3);RT.Rep(indexA(:,ii),3);RT.Swi(indexA(:,ii),3)];
    y2CI(:,ii)=[RTCI.Pure(indexA(:,ii),3);RTCI.Rep(indexA(:,ii),3);RTCI.Swi(indexA(:,ii),3)];
    end
    y2=cell2mat(y2);
    y2CI=cell2mat(y2CI);
    
    y1max=max(max(y1));
    
    h=figure(1);
    
    [AX, H1, H2]= plotyy(1:3, y1, 1:3, y2, 'bar','plot');
    box off
    ylim(AX(1),[0 600]);%y1max+100])
    ylim(AX(2),[0 1.4])
    set(AX,'ycolor', 'k');
    set(AX(1),'ytick', 0:50:600)%round(y1max,-2)+100)
    set(AX(2),'ytick', 0:0.1:1)
    
    style={'-','--',':','-.'};
    starting_color=[0.9290, 0.8140, 0.1150];
    end_color=[0.8, 0.3, 0.07];
    
    if length(H1)>1
    color_change=(starting_color-end_color)/(length(H1)-1);
    else
    color_change=starting_color-end_color;
    end
%     starting_color=end_color-color_change;
    
    for i=1:length(H1)
    set(H1(i), 'FaceColor', end_color-color_change+color_change*i);
    set(H1(i), 'EdgeColor','none');
    set(H2(i), 'LineStyle',style{i});
    end
    
    set(H2, 'Color','k');
    set(H2, 'LineWidth',1.4);

    set(gca,'XTickLabel',{'Pure','Rep', 'Switch'});
    
%     if length(H1)>1
%     set(H1(2), 'FaceColor',[0.8300+200*i, 0.3050+200*i, 0.0780+200*i]);
%     set(H1(2), 'EdgeColor','none');
%     set(H2(2), 'LineStyle','-');
% end

   hold(AX(2), 'on');

   errorbar(AX(2), y2,y2CI,'k.', 'LineWidth', 1)
   
   hold(AX(1), 'on');

    angle=30;   
    rot = angle;
    while rot>360, rot=rot-360; end
    while rot<0, rot=rot+360; end
    if rot>=180, strDir='right'; else strDir='left'; end
    
   for ib = 1:size(y1,2)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = H1(ib).XData+H1(ib).XOffset;
    errorbar(xData,y1(:,ib),y1CI(:,ib),'k.', 'LineWidth', 1)
%     
%     % label data
%     labels = arrayfun(@(value) num2str(value,'%2.0f'),y1(:,ib),'UniformOutput',false);
%     text(xData,y1(:,ib)+10,labels,'HorizontalAlignment','center',...
%     'rotation', rot, 'FontSize', 12, 'VerticalAlignment','middle');
   end
   set(AX(1),'FontSize',16)
   set(AX(2),'FontSize',16)
   
   name2=cell2mat(name);
   name2=sprintf('%s%s',name2, type);
   
   for i=1:length(analysefile)
   lgd1=legend(AX(1),legendname);
   lgd2=legend(AX(2),legendname);
   lgd1.FontSize = 14;
   lgd2.FontSize = 14;
   end
   
   title(titletitle)
   set(get(AX(1),'Ylabel'),'String','Reaction Time (cycles)')
   set(get(AX(2),'Ylabel'),'String','Accruracy %')

%    
%    if graphsize==1
%    width=400;
%    height=400;
%    set(gca,'OuterPosition',[0.05 0.01 0.9 0.9])
%    elseif graphsize==2
%    width=300;
%    height=400;
%    set(gca,'OuterPosition',[0.05 0.01 0.9 0.9])
%    end
%    
%    set(gcf, 'PaperUnits','points')
%    set(gcf, 'PaperPosition', [0 0 width height]);

   
   
   
   figurename=strcat(name2, '.png');
%    figurename=cell2mat(figurename);
   saveas(h,figurename);
%    savefig(h,figurename, 'compact');
   close all


