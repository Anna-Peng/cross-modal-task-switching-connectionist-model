close all
clear all

% folder=input('load which folder? ', 's');
folder='PlotData'
ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
whichdatefile='YesC2-31';%input('[input date file] ','s'); 

% whichdatefile='180325'
datefile=strcat('zcomparemodels', whichdatefile, '.mat');
load(datefile);

filename=RT.Pure(2:end,1);
x=num2cell(1:length(filename))';
[x,filename]
analysefile=input('[which files to plot? ] ','s');
whichcondition=input('[input trial type to plot. Pure=1, Rep=2, Swi=3] '); 

v=[RT.Pure(1,:)'];
x=num2cell(1:length(v));
[x',v]
% locaRT=input('[which two variable to plot?','s');
locaRT=[4 5];%str2num(locaRT);

toplimit=input('[ylimit] '); 
titletitle=input('[Title on top? ] ','s');

condition={'Pure','Repetition','Switch'};

if isempty(analysefile) analysefile=[1:length(filename)]'; else analysefile=str2num(analysefile); end

for i=1:length(locaRT) 
        legendname{i}=input('[Enter legend name] ','s');
end
graphsize=input('large graph/ small graph 1=large, 2=small ');

    
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
    

    for i=1:length(analysefile)
    index=strfind(RT.Pure(:,1),cell2mat(filename(analysefile(i))));
    ft=cellfun('isempty', index);
    index(ft)={0};
    index=cell2mat(index);
    indexA(:,i)=logical(index);
    name(i)=filename(analysefile(i));
    end
    
    % plot overall RT and accuracy

    
    for i=1:2
    y1(:,i)=[RTdata(indexA(:,1)==1,locaRT(i)), RTdata(indexA(:,2),locaRT(i)), RTdata(indexA(:,3),locaRT(i))];
    y1CI(:,i)=[RTCIdata(indexA(:,1), locaRT(i)), RTCIdata(indexA(:,2), locaRT(i)), RTCIdata(indexA(:,3), locaRT(i))];
    end
    
    y1=cell2mat(y1);
    y1CI=cell2mat(y1CI);
    
    errorbarinterval=size(y1,1)/size(y1,2);
    errorbaraxis=[0:errorbarinterval:size(y1,1);0+errorbarinterval:errorbarinterval:size(y1,1)+errorbarinterval]';

    y1max=max(max(y1));
    
    h=figure(1)
    H=bar(y1);
    
    
%     [AX, H1, H2]= plotyy(1:length(analysefile), y1, 1:length(analysefile),y2, 'bar','plot');
    box off
    
    
    hold on
    for ib = 1:size(y1,2)
%     XData property is the tick labels/group centers; XOffset is the offset
%     of each distinct group
    xData = H(ib).XData+H(ib).XOffset;
    errorbar(xData,y1(:,ib),y1CI(:,ib),'k.', 'LineWidth', 1);
    
    % label data
%     labels = arrayfun(@(value) num2str(value,'%2.0f'),y1(:,ib),'UniformOutput',false);
%     text(xData,y1(:,ib)+gap,labels,'HorizontalAlignment','center',...
%     'rotation', 0, 'FontSize', 8, 'VerticalAlignment','middle');
    end

   ylim([0 200])
   set(H(1), 'FaceColor', [135/255 206/255 245/255]); % blue
   set(H(2), 'FaceColor', [255/255 170/255 18/255]); % Orange
  
   if min(y1(:))<0
       miny=-20;%miny=min(y1(:))-5; 
  else
      miny=0;
  end
   
   name2=cell2mat(name);
   name2=sprintf('%s%s',name2, condition{whichcondition});
   
%    for i=1:length(analysefile)
%    titlename={name2};
%    legend(AX(1),legendname)
   legend(legendname)
%    end
   titlename={name2};
   
   title(titletitle)
   ylim([miny toplimit]);%max(max(y1))+100]);
   ylabel('Time in Cycles');
   
   set(gca,'XTickLabel',{'Old', 'Middle', 'Young'});
   set(gca,'FontSize',14)
   
   lgd2=legend(legendname);
   lgd2.FontSize=14;
   
   if graphsize==1
   width=400;
   height=400;
   set(gca,'OuterPosition',[0.05 0.01 0.9 0.8])
   sizename={'Large'};
   elseif graphsize==2
   width=300;
   height=400;
   sizename={'Small'};
   set(gca,'OuterPosition',[0.05 0.01 0.9 0.9])
   else
   sizename={''};
   end
   
   set(gcf, 'PaperUnits','points')
   set(gcf, 'PaperPosition', [0 0 width height]);

   
   figurename=strcat(titlename,sizename, '.png');
   figurename=cell2mat(figurename);
   saveas(h,figurename);
   close all
