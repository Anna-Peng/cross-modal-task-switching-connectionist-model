% scatterplot for the TA activation to TA activation level (task-relevant
% to task-irrelevant). Only applicable to Repetition Trial and Switch trial
% Since pure trial has no competing TA unit
close all
clear all

%% get folder and files
folder=input('load which folder? ', 's');
% folder='2503 Data';

ppath=cd;
f = strcat(ppath, filesep, folder);
addpath(f)
filePattern = fullfile(f, 'C*.mat');

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
Whatnode=input('plot what unit actiavtion? TA2TA=1 MA2MA=2 ');


if isempty(answer)
    answer=[1:length(network_type)]';
    else
    answer=str2num(answer);
end

vartype=[1, 1, 2, 4, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1, 3,1,1, 1,1,1,1,3]; %1=single number, 2=cell, 3=multiple doubles, 4=cells with various charactor arrays
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
    for g=1:length(index)
        if index(g)==1
            TAre(g)=DogTAend(g);
            TAir(g)=BirdTAend(g);
        else
            TAre(g)=BirdTAend(g);
            TAir(g)=DogTAend(g);
        end
    end
    
    
    
    Repdata= trial_type==2 & correct==1;
    Swidata= trial_type==3 & correct==1;
    
    
    if Whatnode==1
    x2=TAir(Repdata); x3=TAir(Swidata);
    y2=TAre(Repdata); y3=TAre(Swidata);
    figurename=strcat(tofind, 'TAandTACorrect');
    elseif Whatnode==2
    x2=V(Repdata); x3=V(Swidata);
    y2=A(Repdata); y3=A(Swidata);
    figurename=strcat(tofind, 'MAandMACorrect');
    end
    
    h=figure(1);
    AX=plot(x2, y2, 'g.', x3, y3, 'b.');
    
    
    hold on
    
    
    
    end
   
    plot([0 0], [-1 1],'k', [-1,1], [0 0], 'k');
    hold on
    
    
  
   
   
   
   ylim([-1 1])
   xlim([-1 1])
   
   ax=legend('Rep', 'Switch');

   title(tofind)
   if Whatnode==1
   ylabel('Activation to task-relevant TA unit');
   xlabel('Activation to task-irrelevant TA unit');
   elseif Whatnode==1
   ylabel('Activation to task-relevant MA unit');
   xlabel('Activation to task-irrelevant MA unit');
   end
   
   
   
  
   saveas(h,figurename, 'png');
   
   
   hold off
   close all

    
end
    
    

