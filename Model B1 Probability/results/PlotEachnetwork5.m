close all
clear all

% folder=input('load which folder? ', 's');
folder='PlotData';

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
analysefile=input('[which file to plot?] ','s');
v=[RT.Pure(1,:)'; 'MS_V';'MS_A';'PrimeCost_Yes';'PrimeCost_No'];
x=num2cell(1:length(v));
[x',v]
variableplot=input('[which two variables to plot? (enter for accuracy & RT plot)] ','s');
colorselect=input('[input color, green=1, blue=2, red=3] '); 
toplimit=input('[ylimit] '); 
if colorselect==1
    color=[0, 0.85, 0];
elseif colorselect==2
    color=[0, 0.4, 0.9];
else
    color=[0.85, 0, 0];
end

for i=1:2 legendlabel{i}=input('[Enter legend name] ','s'); end

savefileas=input('[filename?] ','s');

if isempty(analysefile)
    analysefile=[1:length(filename)]';
    else
    analysefile=str2num(analysefile);
end

variableplot=str2num(variableplot);

if isequal(variableplot, [20 21])
    indexa=7;
    indexb=10;
elseif isequal(variableplot, [22 23])
    indexa=13;
    indexb=15;
end

k=length(x);

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
        if any(variableplot<20)
        ya(:,1)=[RT.Pure(indexA(:,ii),variableplot(1));RT.Rep(indexA(:,ii),variableplot(1));RT.Swi(indexA(:,ii),variableplot(1))];
        yaCI(:,1)=[RTCI.Pure(indexA(:,ii),variableplot(1));RTCI.Rep(indexA(:,ii),variableplot(1));RTCI.Swi(indexA(:,ii),variableplot(1))];

        ya(:,2)=[RT.Pure(indexA(:,ii),variableplot(2));RT.Rep(indexA(:,ii),variableplot(2));RT.Swi(indexA(:,ii),variableplot(2))];
        yaCI(:,2)=[RTCI.Pure(indexA(:,ii),variableplot(2));RTCI.Rep(indexA(:,ii),variableplot(2));RTCI.Swi(indexA(:,ii),variableplot(2))];

        y1=cell2mat(ya);
        y1CI=cell2mat(yaCI);
        
        else
        Aa=[RT.Pure(indexA(:,ii),indexa); RT.Rep(indexA(:,ii),indexa); RT.Swi(indexA(:,ii),indexa)];
        Ab=[RT.Pure(indexA(:,ii),indexa-1); RT.Rep(indexA(:,ii),indexa-1); RT.Swi(indexA(:,ii),indexa-1)];
        Aa=cell2mat(Aa); Ab=cell2mat(Ab);
        y1(:,1)=Aa-Ab;
        Ba=[RT.Pure(indexA(:,ii),indexb); RT.Rep(indexA(:,ii),indexb); RT.Swi(indexA(:,ii),indexb)];
        Bb=[RT.Pure(indexA(:,ii),indexb-1); RT.Rep(indexA(:,ii),indexb-1); RT.Swi(indexA(:,ii),indexb-1)];
        Ba=cell2mat(Ba); Bb=cell2mat(Bb);
        y1(:,2)=Ba-Bb;
        y1CI=[0 0;0 0;0 0];
        end

    h=figure(1);
    H=bar(y1);
    name2=cell2mat(name(ii));
   
   hold on
   
   if any(variableplot>20)
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


   titlename=strcat(name2, savefileas);
   legend(legendlabel{1},legendlabel{2})

   if min(y1(:))<0
       miny=min(y1(:))-5; 
   else
       miny=0;
   end
   
   
   set(H(1), 'FaceColor', color); set(H(2), 'FaceColor', color.*0.56);
   set(H, 'EdgeColor','none');
   ylim([miny toplimit]);%max(max(y1))+100]);
   ylabel('Time in Cycles');
   set(gca,'XTickLabel',{'Pure','Rep', 'Switch'});
   title(titlename)
   
   
   figurename=strcat(titlename, '.png');
%     figurename=cell2mat(figurename);
    saveas(h,figurename);
    close all
end
   
    


