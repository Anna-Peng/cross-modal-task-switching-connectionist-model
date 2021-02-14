close all
clear all

% folder=input('load which folder? ', 's');
folder='PlotData'
ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
% whichdatefile=input('[input date file] ','s'); 

whichdatefile='YesB2-5'
datefile=strcat('zcomparemodels', whichdatefile, '.mat');
load(datefile);

filename=RT.Pure(2:end,1);
x=num2cell(1:length(filename))';
[x,filename]
analysefile=input('[which files to plot? ] ','s');
whatRT=2; %input('[which kind of RT to plot? 1=All RTs, 2=Yes RT only ] ');
% whichcondition=1:3;
whichcondition=input('[input trial type to plot. Pure=1, Rep=2, Swi=3] '); 
condition={'Pure','Repetition','Switch'};

xname='Intrinsic/Top-down signal'; %input('[input trial x-axis label] ', 's'); 
if whatRT==1
    locaRT=2;
    type='allRT';
elseif whatRT==2
    locaRT=18;
    type='YesRT';
end

if isempty(analysefile) analysefile=[1:length(filename)]'; else analysefile=str2num(analysefile); end


    
    switch whichcondition
        case 1
        RTdata=RT.Pure;
        RTCIdata=RTCI.Pure;
        case 2
        RTdata=RT.Rep;
        RTCIdata=RTCI.Rep;
        case 3
        RTdata=RT.Swi;
        RTCIdata=RTCI.Swi;
    end

% for i=1:length(analysefile) tickname{i}=input('[Enter x tick name] ','s'); end

if length(analysefile)==11
interval=[0:10:100];
tickname=num2cell(interval);
else 
tickname={'3' '4' '5' '6' '7' '8' '9' '10'};%;
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
    y1(:,ii)=RTdata(indexA(:,ii),locaRT);
    y1CI(:,ii)=RTCIdata(indexA(:,ii), locaRT);
    y2(:,ii)=RTdata(indexA(:,ii),3);
    y2CI(:,ii)=RTCIdata(indexA(:,ii),3);
    end
    
    y1=cell2mat(y1);
    y1CI=cell2mat(y1CI);
        
    y2=cell2mat(y2);
    y2CI=cell2mat(y2CI);
    
    errorbarinterval=size(y1,1)/size(y1,2);
    errorbaraxis=[0:errorbarinterval:size(y1,1);0+errorbarinterval:errorbarinterval:size(y1,1)+errorbarinterval]';

    
    y1max=max(max(y1));
    
    h=figure(1);
    
    [AX, H1, H2]= plotyy(1:length(analysefile), y1, 1:length(analysefile),y2, 'bar','plot');
    box off
    ylim(AX(1),[0 y1max+200])
    ylim(AX(2),[0 1.4])
    set(AX,'ycolor', 'k');
    set(AX(1),'ytick', 0:50:round(y1max,-2)+100)
    set(AX(2),'ytick', 0:0.1:1, 'FontSize',14)
    
    style={'-','--',':','-.'};
    starting_color=[0.9290, 0.8140, 0.1150];
    end_color=[0.8, 0.3, 0.07];
    
    if length(H1)>1
    color_change=(starting_color-end_color)/(length(H1)-1);
    else
    color_change=starting_color-end_color;
    end
%     starting_color=end_color-color_change;
    
%     for i=1:length(H1)
%     set(H1(i), 'FaceColor', end_color-color_change+color_change*i);
%     set(H1(i), 'EdgeColor','none');
%     set(H2(i), 'LineStyle',style{i});
%     end
    
    set(H2, 'Color','k');
    set(H2, 'LineWidth',1.4);
    set(gca,'XTickLabel',tickname);
    
    set(H1, 'FaceColor',[0.6 0.6 0.6]);
    set(H1, 'EdgeColor','none');
    
%     if length(H1)>1
%     set(H1(2), 'FaceColor',[0.8300+200*i, 0.3050+200*i, 0.0780+200*i]);
%     set(H1(2), 'EdgeColor','none');
%     set(H2(2), 'LineStyle','-');
%     end
    xData = 1:length(analysefile);
    angle=30;   
    rot = angle;
    while rot>360, rot=rot-360; end
    while rot<0, rot=rot+360; end
    if rot>=180, strDir='right'; else strDir='left'; end
    
    hold(AX(2), 'on');
    errorbar(AX(2), y2,y2CI,'k.', 'LineWidth', 1)
    labels = arrayfun(@(value) num2str(value,'%2.2f'),y2,'UniformOutput',false);
    text(xData,y2+0.1,labels,'HorizontalAlignment','center',...
    'rotation', rot, 'FontSize', 14, 'VerticalAlignment','middle', 'parent',AX(2));

    hold(AX(1), 'on');
    errorbar(AX(1), y1,y1CI,'k.', 'LineWidth', 1)
    
    labels = arrayfun(@(value) num2str(value,'%2.0f'),y1,'UniformOutput',false);
    text(xData,y1+20,labels,'HorizontalAlignment','center',...
    'rotation', rot, 'FontSize', 14, 'VerticalAlignment','middle');


% 
%    for ib = 1:size(y1,2)
%     %XData property is the tick labels/group centers; XOffset is the offset
%     %of each distinct group
%     xData = H1(ib).XData+H1(ib).XOffset;
%     errorbar(xData,y1(:,ib),y1CI(:,ib),'k.', 'LineWidth', 1)
%     
%     % label data
%     labels = arrayfun(@(value) num2str(value,'%2.0f'),y1(:,ib),'UniformOutput',false);
%     text(xData,y1(:,ib)+10,labels,'HorizontalAlignment','center',...
%     'rotation', rot, 'FontSize', 8, 'VerticalAlignment','middle');
%    end
   
   name1=condition(whichcondition);
   name1=cell2mat(name1);
   
   name=cell2mat(name);
   name3=sprintf('%s%s',name,name1);
   
%    for i=1:length(analysefile)
%    titlename={name2};
%    legend(AX(1),legendname)
%    legend(AX(2),legendname)
%    end
   titlename={name1};
   title(titlename)
   set(get(AX(1),'Ylabel'),'String','Time (cycles)')
   set(get(AX(2),'Ylabel'),'String','Accruracy')
   xlabel({xname});
   set(gca, 'FontSize',14);
   figurename=strcat(name3, whichdatefile, '.png');
%    figurename=cell2mat(figurename);
   saveas(h,figurename);

   close all


