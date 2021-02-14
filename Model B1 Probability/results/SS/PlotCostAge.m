close all
clear all

% folder=input('load which folder? ', 's');
folder='PlotData'
ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
whichdatefile=input('[input date file] ','s'); 

% whichdatefile='180325'
datefile=strcat('comparemodels', whichdatefile, '.mat');
load(datefile);

filename=RT.Pure(2:end,1);
x=num2cell(1:length(filename))';
[x,filename]
analysefile=input('[which networks to compare? ] ','s');

v=[RT.Pure(1,:)'];
x=num2cell(1:length(v));
[x',v]
locaRT=input('[which one variable to plot?','s');
locaRT=str2num(locaRT);
colorselect=input('[input color, green=1, blue=2, red=3] '); 
toplimit=input('[ylimit] '); 

if colorselect==1
    color=[0, 0.85, 0];
elseif colorselect==2
    color=[0, 0.4, 0.9];
else
    color=[0.85, 0, 0];
end

if isempty(analysefile) analysefile=[1:length(filename)]'; else analysefile=str2num(analysefile); end

for i=1:length(analysefile) legendname{i}=input('[Enter legend name] ','s'); end

    for i=1:length(analysefile)
    index=strfind(RT.Pure(:,1),cell2mat(filename(analysefile(i))));
    ft=cellfun('isempty', index);
    index(ft)={0};
    index=cell2mat(index);
    indexA(:,i)=logical(index);
    name(i)=filename(analysefile(i));
    end
    

    for ii=1:size(indexA,2)
        y1(:,ii)=[RT.Pure(indexA(:,ii),locaRT);RT.Rep(indexA(:,ii),locaRT);RT.Swi(indexA(:,ii),locaRT)];
        y1CI(:,ii)=[RTCI.Pure(indexA(:,ii),locaRT);RTCI.Rep(indexA(:,ii),locaRT);RTCI.Swi(indexA(:,ii),locaRT)];
    end
    

    y1=cell2mat(y1);
    y1CI=cell2mat(y1CI);

    errorbarinterval=size(y1,1)/size(y1,2);
    errorbaraxis=[0:errorbarinterval:size(y1,1);0+errorbarinterval:errorbarinterval:size(y1,1)+errorbarinterval]';
    
    
    y1max=max(max(y1));
    
    if locaRT==24
        y1=-y1;
    end
    
    h=figure(1);
    H=bar(y1);
   
    hold on
   
   if locaRT>19
       gap=1;
   else
       gap=10;
   end

   
   
   for ib = 1:size(y1,2)
%     XData property is the tick labels/group centers; XOffset is the offset
%     of each distinct group
    xData = H(ib).XData+H(ib).XOffset;
    errorbar(xData,y1(:,ib),y1CI(:,ib),'k.', 'LineWidth', 1);
    
    % label data
    labels = arrayfun(@(value) num2str(value,'%2.0f'),y1(:,ib),'UniformOutput',false);
    text(xData,y1(:,ib)+gap,labels,'HorizontalAlignment','center',...
    'rotation', 0, 'FontSize', 8, 'VerticalAlignment','middle');
   end

  if min(y1(:))<-1
       miny=min(y1(:))-5; 
  else
       miny=0;
  end
   
   
   for i=1:length(H)
   set(H(i), 'FaceColor', color);
   color=color*0.56;
   end
   
   set(H, 'EdgeColor','none');
   
   ylim([miny toplimit]);%max(max(y1))+100]);
   
   if min(y1(:))<0 && min(y1(:))>-1
   ylabel('Accuracy Cost in %');
   else
   ylabel('Time in Cycles');
   end
   
   if size(y1,1)>2
   set(gca,'XTickLabel',{'Pure','Rep', 'Switch'});
   else
   set(gca,'XTickLabel',{'Mixing Cost', 'Switch Cost'});
   end
   
   name2=cell2mat(name);
   name2=sprintf('%s%s',name2, v{locaRT});
   
   titlename={name2};
   legend(legendname)

   title(titlename)
   
   ylim([miny toplimit]);%max(max(y1))+100]);
   ylabel('Time in Cycles');
   
   figurename=strcat(titlename, '.png');
   figurename=cell2mat(figurename);
   saveas(h,figurename);
   close all


