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

filename=Error.Pure(2:end,1);
x=num2cell(1:length(filename))';
[x,filename]
analysefile=input('[which file to plot?] ','s');
v=Error.Pure(1,:)';
x=num2cell(1:length(v));
[x',v]
% variableplot=input('[which variables to plot?] ','s');

variableplot=2:7;

savefileas=input('[filename?] ','s');

if isempty(analysefile)
    analysefile=[1:length(filename)]';
    else
    analysefile=str2num(analysefile);
end

% if isempty(variableplot)
%     variableplot=[2 3 4 5 6 7];
%     else
%     variableplot=str2num(variableplot);
% end

legendname=Error.Pure(1,variableplot);

    for i=1:length(analysefile)
    index=strfind(Error.Pure(:,1),cell2mat(filename(analysefile(i))));
    ft=cellfun('isempty', index);
    index(ft)={0};
    index=cell2mat(index);
    indexA(:,i)=logical(index);
    name(i)=filename(analysefile(i));
    end
    
    % plot overall Error and accuracy

for ii=1:size(indexA,2)
        for p=1:length(variableplot)
        ya(:,p)=[Error.Pure(indexA(:,ii),variableplot(p));Error.Rep(indexA(:,ii),variableplot(p));Error.Swi(indexA(:,ii),variableplot(p))];
        yaCI(:,p)=[ErCI.Pure(indexA(:,ii),variableplot(p));ErCI.Rep(indexA(:,ii),variableplot(p));ErCI.Swi(indexA(:,ii),variableplot(p))];
        end
        
    y1=cell2mat(ya);
    y1CI=cell2mat(yaCI);

    h=figure(1);
    H=bar(y1);
    name2=cell2mat(name(ii));
   
   hold on
   legend(legendname)

   titlename=strcat(name2, savefileas);

%    set(H, 'EdgeColor','none');
   ylim([0 40]);%max(max(y1))+10]);
   ylabel('Number of Errors');
   set(gca,'XTickLabel',{'Pure','Rep', 'Switch'});
   title(titlename)
   
   
   figurename=strcat(titlename, '.png');
%     figurename=cell2mat(figurename);
    saveas(h,figurename);
    close all
end
   
    


