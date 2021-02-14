% scatterplot for the TA activation level, PS activation level and RO

close all
clear all

%% get folder and files
folder=input('load which folder? ', 's');
% folder='2503 Data';

ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
filePattern = fullfile(f, 'A*.mat');

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

if isempty(answer)
    answer=[1:length(network_type)]';
    else
    answer=str2num(answer);
end

vartype=[1, 1, 2, 4, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1,1, 3, 1];
%% plot scatter for specific network
for j=1:length(answer) % cycling through different network architectures (number of graphs)
    
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
    TAend=max(TAend, [], 2);
    
    Puredata= trial_type==1 & correct==1;
    Repdata= trial_type==2 & correct==1;
    Swidata= trial_type==3 & correct==1;
    
    
    
    x1=time(Puredata); x2=time(Repdata); x3=time(Swidata);
    y1=TAend(Puredata); y2=TAend(Repdata); y3=TAend(Swidata);
    
    h=figure(1);
    AX=plot(x1, y1, 'r.', x2, y2, 'g.', x3, y3, 'b.');
    
    
    hold on
    
    
    
    end
   
    
    
   figurename=strcat(tofind, 'TAandRO');
   
   
   if nnetwork==1
   lsline
   tbl1 = table(y1 , x1); tbl2 = table(y2 , x2);tbl3 = table(y3 , x3);
   mdl1 = fitlm(tbl1,'linear'); mdl2 = fitlm(tbl2,'linear'); mdl3 = fitlm(tbl3,'linear');
   set(AX, 'MarkerSize',10)
   save(figurename, 'tbl1', 'tbl2', 'tbl3', 'mdl1', 'mdl2', 'mdl3')
   end
   
   
   ylim([0 1.2])
   xlim([0 600])
   
   ax=legend('Pure', 'Rep', 'Switch');

   title(tofind)
   ylabel('TA activation');
   xlabel('Time in Cycles');
   
   
  
   saveas(h,figurename, 'png');
   
   
   hold off
   close all

    
end
    
    

