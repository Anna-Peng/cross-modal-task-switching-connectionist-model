close all
clear all

%% get folder and files
folder=input('load which folder containing data? ', 's');


ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
filePattern = fullfile(f, 'A**.mat');

Ref=dir(filePattern);

Ref={Ref.name}';

for i=1:length(Ref)
    name=cell2mat(Ref(i));
    [~, filename, ~]=fileparts(name);
    name_record{i,:}=filename(1:4);
end

network_type=unique(name_record);

x=num2cell(1:length(network_type));

[x',network_type]

answer=input('load which files? (specify number index): ', 's');
blockindex=input('[Plot which condition? Pure=1, Mixed=3] ');
trialno=input('[Plot how many trial repeats (in pairs)?] ');

maxy=input('[Max Time?] ');
if isempty(answer)
    answer=[1:length(network_type)]';
    else
    answer=str2num(answer);
end


for j=1:length(answer)
    
    tofind=cell2mat(network_type(answer(j)));
    whatfind=strfind(Ref, tofind);   
    tf = cellfun('isempty', whatfind);
    whatfind(tf) = {0} ;
    whatfind=cell2mat(whatfind);
    current_network=find(whatfind==1);
    randnetwork=randi(length(current_network));
    current_load=fullfile(f, Ref(current_network(randnetwork)));
    load(current_load{1});


    time=zall_data(2:end,27);
    time=cell2mat(time);
    index=zall_data(2:end,2);
    index=cell2mat(index);
    task=zall_data(2:end,9);
    task=cell2mat(task);
    correct=zall_data(2:end,11);
    correct=cell2mat(correct);
    incorrect=double(correct==0);
    
    k=find(index==blockindex);
    

    stimulusname=zall_data(2:end,4);
    prime=[zall_data(2:end,12), zall_data(2:end,13)];
    prime=cell2mat(prime);
    prime=sum(prime,2);
 
    filler=repmat(NaN,1,trialno*2);
    y1=filler;
    if blockindex==3
    y2=prime(k(1):k(trialno)+1);
    else
    y2=prime(k(1):k(trialno*2));
    end
    x2=1:trialno*2;

    
    
    h=figure(1);
    [AX,H1,H2]=plotyy(x2, y1, x2, y2, 'plot','bar');
    
    set(AX, 'XTick',x2);
    set(AX(1), 'YTick',[0:50:maxy]);
    set(AX(2), 'ytick', [0:.5:round(max(y2))+1]);
    ylim(AX(1), [-50 maxy]);
    ylim(AX(2), [0 10]);
    xlim(AX(1), [0 x2(end)+1]);
    xlim(AX(2), [0 x2(end)+1]);
%     
%     set(H1, 'marker','*');
%     set(H1, 'LineStyle','none');
%     set(H1, 'MarkerEdgeColor','red');
    
    set(H2, 'BarWidth',0.4);
    set(H2, 'FaceColor','r');
    hold(AX(1),'on')
    
    if blockindex==3
    x3=find(incorrect(k(1):k(trialno)+1)==1);
    timesection=time(k(1):k(trialno)+1);
    y3=timesection(x3);
    else
       x3=find(incorrect(k(1:trialno*2)==1));
       timesection=time(k(1:trialno*2));
       y3=timesection(x3);
    end
    
    
    scatter(AX(1), x3, y3, 'r*');

    hold(AX(1),'on')
    
    for i=1:trialno
    
    x=2*i-1:2*i;
    y=time(k(i):k(i)+1);
    
    if task(k(i))==1
    H=plot(AX(1), x,y,'b-');
    elseif task(k(i))~=1
    H=plot(AX(1), x,y,'g-');
    end
    
    labels ={stimulusname(k(i)), stimulusname(k(i)+1)};
    text(x,y+10,labels,'HorizontalAlignment','center','VerticalAlignment','middle');
    hold on
    end

    box off
    hold on
    if blockindex==1
        textblock='Pure';
    else
        textblock='Mixed';
    end
    figurename=strcat(tofind, 'PlotTrials',textblock);

    xlim(gca, [0 trialno*2+1]);

%     set(gca,'xtick', 1:trialno*2);
    
    
    title(figurename)
    set(get(AX(1),'Ylabel'),'String','Time (cycles)')
    set(get(AX(2),'Ylabel'),'String','Prime Net Input')
    set(gca,'XTickLabel',{'S', 'R'});
    h = zeros(3, 1);
    h(1) = plot(AX(1),0,0,'-b', 'visible', 'off');
    h(2) = plot(AX(1),0,0,'-g', 'visible', 'off');
    h(3) = plot(AX(1),0,0,'*r', 'visible', 'off');
    legend(h, 'Dog', 'Bird', 'Error');

    
    width=1000;
    height=500;

    set(AX,'FontSize',15)
    set(gcf, 'PaperUnits','points')
    set(gcf, 'PaperPosition', [0 0 width height]);
    saveas(gcf,figurename, 'png');
    hold off
    close all

end