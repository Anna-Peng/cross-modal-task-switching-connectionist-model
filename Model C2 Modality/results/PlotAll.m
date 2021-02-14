close all
clear all

% this plots all the RTs in all ages with different parameter setting in
% all trial types
% x axis has parameter setting in different trial types e.g. top down 1:10
% in pure, rep and switch trials
% different lines represent different ages
% input files should be 3 age groups with consistent change of parameter
% every +3 network files
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
x1=num2cell(1:length(filename))';
[x1,filename]
analysefile=input('[which files to plot? ] ','s');
whatRT=input('[Plot RT or Accuracy? Accuracy=1, RT=2, MSEv=3, MSEa=4] ');
if whatRT==1
    yname='Accuracy';
else
    yname='Time (cycles)';
end
  

  condition={'Pure','Rep','Swi'};
if whatRT==1
    locaRT=3;
    type='allRT';
elseif whatRT==2
    locaRT=18;
    type='YesRT';
elseif whatRT==3
    locaRT=21;
    type='MSE_V';
elseif whatRT==4
    locaRT=22;
    type='MSE_A';
end

if isempty(analysefile) analysefile=[1:length(filename)]'; else analysefile=str2num(analysefile); end


Pure=RT.Pure;
PureCI=RTCI.Pure;

Rep=RT.Rep;
RepCI=RTCI.Rep;

Swi=RT.Swi;
SwiCI=RTCI.Swi;


for i=1:length(analysefile)/3 tickname{i}=input('[Enter x tick name] ','s'); end

name=input('save file as ', 's');
legendname={'Adult','Middle','Young'};
currentage=['a','b','c'];

h=figure(1); 
style={'b-*','r-*','g-*'};
g=length(analysefile)/3;
for age=1:3   
    
    ageindex=strfind(RT.Pure(:,1),currentage(age));
    ft=cellfun('isempty',ageindex);
    ageindex(ft)={0};
    ageindex=cell2mat(ageindex);
    indexA=logical(ageindex(    (analysefile(1):analysefile(end)+1)>0)  );


    for j=1:3 % condition
        if j==1
        RTdata=Pure;
        RTCIdata=PureCI;
        elseif j==2
        RTdata=Rep;
        RTCIdata=RepCI;
        elseif j==3
        RTdata=Swi;
        RTCIdata=SwiCI;
        end

        
        y1=RTdata(indexA,locaRT); % all the same age
        y1CI=RTCIdata(indexA, locaRT);
        

        y1=cell2mat(y1);
        y1CI=cell2mat(y1CI);
        errorbarinterval=size(y1,1)/size(y1,2);
        errorbaraxis=[0:errorbarinterval:size(y1,1);0+errorbarinterval:errorbarinterval:size(y1,1)+errorbarinterval]';
        x1=(j-1)*length(analysefile)/3+1:j*length(analysefile)/3;
        H1(j)=plot(x1,y1,style{age});
        hold on

        y(j).CI=y1CI;
        clear y1 y1CI
    end


% 
%     for j=1:3  
%       xData = H1(j).XData;
%       yData=H1(j).YData;
%       errorbar(xData,yData,y(j).CI,'k.', 'LineWidth', 1);
%     end
    


end


  set(gca,'Xtick',1:1:length(analysefile))
  set(gca,'XTickLabel',tickname);
  colorname='brg';
  
  dim=[0.82 0.4 0.5 0.5; 0.82 0.36 0.5 0.5; 0.82 0.32 0.5 0.5];
  for i=1:3   
  t(i)=annotation('textbox',dim(i,:), 'String',legendname(i), 'FontSize', 20);%,'FitBoxToText','on');
  t(i).Color=colorname(i);
  t(i).EdgeColor='none';
  end
%   annotation('textbox',[0.8 0.77 0.1 0.13]);
  box off
  set(gca, 'LineWidth',1.4);

  xname='Pure                          Repetition                                Switch';
  
  xlabel({xname});
  ylabel({yname});
  width=1000;
height=400;
set(gca,'FontSize',20)
set(gcf, 'PaperUnits','points')
set(gcf, 'PaperPosition', [0 0 width height]);
  name2=sprintf('%s',name);
  
  
  
titlename={name2};
title(titlename)
    

    
   figurename=strcat(titlename, whichdatefile, '.png');
   figurename=cell2mat(figurename);
   saveas(h,figurename);

   close all


