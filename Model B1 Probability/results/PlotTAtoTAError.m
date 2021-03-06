% scatterplot for the TA activation level, PS activation level and RO
% THis plot TA activation against TA activation. Not applicable to pure
% trials

close all
clear all

%% get folder and files
folder=input('load which folder? ', 's');
% folder='2503 Data';

ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)

filePattern = fullfile(f,'B*.mat');

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

answer=input('load which files? (specify number index) ''enter'' for all: ', 's');
nnetwork=input('plot how many network subjects? ');
inputblock=input('[which condition to plot Rep=2, Swi=3?] ');

if isempty(answer)
    answer=[1:length(network_type)]';
    else
    answer=str2num(answer);
end

vartype=[1, 1, 2, 4, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1,1, 3, 1, 1, 1, 1, 1];
%% plot scatter for specific network
for j=1:length(answer) % cycling through different network architectures (number of graphs)
    TA1=[];
    TA2=[];
    tofind=cell2mat(network_type(answer(j)));
    index=strfind(Ref, tofind);   
    tf = cellfun('isempty',index);
    index(tf) = {0} ;
    index=cell2mat(index);
    current_network=find(index==1);
    
    
    for h=1:nnetwork % cycling within the network type (no. of participants)
    current_load=fullfile(f, Ref(current_network(h)));
    load(current_load{1});
    
    
    for q=1:size(zall_data,2)
        v=genvarname(zall_data{1,q});
        if vartype(q)==4
        eval([v '=zall_data(2:end,q);'])
            for whatstimulus=1:length(stimulus)
                if size(stimulus{whatstimulus},1)>1
                    name=stimulus{whatstimulus};
                    stimulus{whatstimulus}=[name(1,:),name(2,:)];
                end
            end
            
        elseif vartype(q)==2
        eval([v '=zall_data(2:end,q);'])
        
        elseif vartype(q)==1 | vartype(q)==3
        eval([v '=cell2mat(zall_data(2:end,q));'])
        end
 
    end
    
    TAend=[DogTAend, BirdTAend];
    for g=1:length(index)
        if index(g)==1
            TAre(g)=DogTAend(g);
            TAir(g)=BirdTAend(g);
        else
            TAre(g)=BirdTAend(g);
            TAir(g)=DogTAend(g);
        end
    end
    
%     if inputblock==1
%         condition=trial_type==1;
%     elseif 
%         condition=trial_type==2;
%     end
    
    condition=trial_type==inputblock;

    Yes=(DY>0.2 | BY>0.2) & (DN<0.2 | BY<0.2);
    No=(DN>0.2 | BN>0.2) & (DY<0.2 | BY<0.2);
    
    CommWithin= set_correct==1 & Yes==1 & correct==0 & condition==1;
    CommBt= set_correct==0 & Yes==1 & correct==0 & condition==1;
    OmWithin= set_correct==1 & No==1 & correct==0 & condition==1;
    OmBt= set_correct==0 & No==1 & correct==0 & condition==1;
    
    x1=TAir(CommWithin); x2=TAir(CommBt); x3=TAir(OmWithin);x4=TAir(OmBt);
    y1=TAre(CommWithin); y2=TAre(CommBt); y3=TAre(OmWithin); y4=TAre(OmBt);
    
    
    if isempty(x1) x1=NaN; y1=NaN; end
        
    if isempty(x2) x2=NaN; y2=NaN; end
    if isempty(x3) x3=NaN; y3=NaN; end
    if isempty(x4) x4=NaN; y4=NaN; end

        
    
    TA1(1,end+1:end+length(y2))=y2;
    TA2(1,end+1:end+length(x2))=x2;
    
    h=figure(1);
    
    AX=plot(x1, y1, 'b.', x2, y2, 'g.', x3, y3,'r.', x4, y4, 'k.');
    set(AX, 'MarkerSize',20)
    
%     AX=plot(x1, y1,...
%         'Color', [0 0 1],...
%         'MarkerStyle', '*',...
%         x2, y2,...
%         'Color', [0 0 0.5],...
%         'MarkerStyle', '*',...
%         x3, y3,...
%         'Color', [1 0 0],...
%         'MarkerStyle', '*',...
%         x4, y4,...
%         'Color', [0.5 0 0],...
%         'MarkerStyle', '*');

    hold on
  

    end
   
    TAre_all=nanmean(TA1);
    TAir_all=nanmean(TA2);
   
    
    plot([0 0], [-1 1],'k:', [-1,1], [0 0], 'k:', [-1 1], [TAre_all TAre_all], 'r', [TAir_all TAir_all], [-1,1], 'r');%, [TAir_all TAir_all], [TAre_all TAre_all], 'k*');
   
    
    txt1 = sprintf('%0.2f \n%0.2f' ,TAre_all, TAir_all);
    H=text(TAir_all+0.05,TAre_all-0.07,txt1);
    set(H, 'FontSize', 12);
    
    hold on
    conditionname={'Pure','Repetition', 'Switch'};
    
%    set(gca,'color',[0 0 0]);
   figurename=strcat(tofind, 'TAandTA', conditionname{inputblock});
   
%    
%    if nnetwork==1
%    lsline
%    tbl1 = table(y1 , x1); tbl2 = table(y2 , x2);tbl3 = table(y3 , x3);
%    mdl1 = fitlm(tbl1,'linear'); mdl2 = fitlm(tbl2,'linear'); mdl3 = fitlm(tbl3,'linear');
%    set(AX, 'MarkerSize',15)
%    save(figurename, 'tbl1', 'tbl2', 'tbl3', 'mdl1', 'mdl2', 'mdl3')
%    end
%    
  
   ylim([-1 1])
   xlim([-1 1])
   
   ax=legend('ComWithin','ComBt','OmWithin','OmBt', 'Location', 'southeast');
   set(ax, 'Color', 'w');
%    title(tofind)
   ylabel('Activation to task-relevant TA unit');
   xlabel('Activation to task-irrelevant TA unit');

   set(gcf, 'InvertHardCopy', 'on');
   set(gca, 'FontSize',14)
   set(gca,'ytick', -1:0.2:1)
   set(gca,'xtick', -1:0.2:1)
    
   saveas(h,figurename, 'png');
   
   clearvars TA1 TA2
   hold off
   close all

    
end
    
    

