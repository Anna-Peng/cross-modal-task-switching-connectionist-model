close all
clear all

% folder=input('load which folder? ', 's');
folder='PlotData'
ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
whichdatefile=input('[input date file] ','s'); 

% whichdatefile='Yestest2'
datefile=strcat('zcomparemodels', whichdatefile, '.mat');
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
PlotAgeorCon=input('Plot Age Group or network update probablity? Age=1, Probability=2, Top-Down=3 ');

if colorselect==1
    color=[0, 0.85, 0];
elseif colorselect==2
    color=[0, 0.4, 0.9];
else
    color=[0.85, 0, 0];
end

if isempty(analysefile) analysefile=[1:length(filename)]'; else analysefile=str2num(analysefile); end

if PlotAgeorCon==2
    ageindex=input('[Age? 1=adult, 2=middle, 3=young] ');
    agename={'Adult','Middle','Young'};
    ageinput=cell2mat(agename(ageindex));
    TAindex=input('[TA present or not? yes=1, no=0] ');
%     if TAindex==1
%     probability=[0,10,20,40,80,100];
%     else
    probability=[0:10:100];
%     end
    for i=1:length(analysefile) legendname{i}=sprintf('%s %d%%', ageinput, probability(i)); end %input('[Enter legend name] ','s'); end
elseif PlotAgeorCon==1
    legendname={'Adult','Middle','Young'};

elseif PlotAgeorCon==3
    ageindex=input('[Age? 1=adult, 2=middle, 3=young] ');
    agename={'Adult','Middle','Young'};
    ageinput=cell2mat(agename(ageindex));
    probability=3:10;
    for i=1:length(analysefile) legendname{i}=sprintf('Signal=%d', probability(i)); end
end


    for i=1:length(analysefile)
    index=strfind(RT.Pure(:,1),cell2mat(filename(analysefile(i))));
    ft=cellfun('isempty', index);
    index(ft)={0};
    index=cell2mat(index);
    indexA(:,i)=logical(index);
    name(i)=filename(analysefile(i));
    end
    

    for ii=1:size(indexA,2)
        if locaRT<23
        y1(:,ii)=[RT.Pure(indexA(:,ii),locaRT);RT.Rep(indexA(:,ii),locaRT);RT.Swi(indexA(:,ii),locaRT)];
        y1CI(:,ii)=[RTCI.Pure(indexA(:,ii),locaRT);RTCI.Rep(indexA(:,ii),locaRT);RTCI.Swi(indexA(:,ii),locaRT)];
        else
        y1(:,ii)=[RT.Pure(indexA(:,ii),locaRT);RT.Rep(indexA(:,ii),locaRT)];
        y1CI(:,ii)=[RTCI.Pure(indexA(:,ii),locaRT);RTCI.Rep(indexA(:,ii),locaRT)];
        end
    end
    

    y1=cell2mat(y1);
    y1CI=cell2mat(y1CI);
    
    if locaRT==24
        y1=y1*100;
        y1CI=y1CI*100;
    end

    errorbarinterval=size(y1,1)/size(y1,2);
    errorbaraxis=[0:errorbarinterval:size(y1,1);0+errorbarinterval:errorbarinterval:size(y1,1)+errorbarinterval]';
    
    
    y1max=max(max(y1));
    
    if locaRT==24
        y1=-y1;
    end
    
    h=figure(1);
    H=bar(y1);
   
    hold on
   
   if locaRT>19 && locaRT<24
       gap=5;
       miny=-100;
       set(gca,'ytick', miny:20:toplimit)
   elseif locaRT==24
       gap=10;
       miny=-20;
       set(gca,'ytick', miny:5:toplimit)
   else
       gap=10;
       set(gca,'ytick', miny:50:toplimit)
   end
   ylim([miny toplimit]);
   
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

%   if min(y1(:))<-1
%        miny=min(y1(:))-5; 
%   else
%        miny=0;
%   end

   
   for i=1:length(H)
   set(H(i), 'FaceColor', color);
   color=color*0.56;
   end
   
   set(H, 'EdgeColor','none');
   

   if y1max<1
   ylabel('Accuracy Cost in %');
   else
   ylabel('Time in Cycles');
   end

   
   if size(y1,1)>2
   set(gca,'XTickLabel',{'Pure','Rep', 'Switch'});
   else
   set(gca,'XTickLabel',{'Mixing Cost', 'Switch Cost'});
   end
   set(findall(h, '-property', 'FontSize'), 'FontSize', 22);%, 'fontWeight', 'bold')

   name2=cell2mat(name);
   name2=sprintf('%s%s',name2, v{locaRT});
   
   titlename={name2};
   legend(legendname)

%    title(titlename)
   

   
   figurename=strcat(titlename, '.png');
   figurename=cell2mat(figurename);
   saveas(h,figurename);
   close all


