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
mod=input('plot which modality? Visual=1 Auditory=2 ');

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
    
    for i=1:2
        if i==1
            p=1;
            condition='pure';
        else
            p=2;
            condition='rep';
        end

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
                    end % END Q

               V2V= premod==1 & modshift==1 & trial_type==p & correct==1;
               A2V= premod==2 & modshift==1 & trial_type==p & correct==1;
               A2A= premod==2 & modshift==2 & trial_type==p & correct==1;
               V2A= premod==1 & modshift==2 & trial_type==p & correct==1;

               if mod==1
                   P=A;
                   MR=V2V;
                   MS=A2V;
                   type='Vis';
                   color={'g','r'};

               else
                   P=V;
                   MR=A2A;
                   MS=V2A;
                   type='Aud';
                   color={'b','m'};

               end

               x1=P(MR); x2=P(MS);
               y1=(PS(MR,:)-PSinitial(MR,:)); y2=(PS(MS,:)-PSinitial(MS,:)); 
               y1=sum(y1,2);
               y2=sum(y2,2);

               figurename=strcat(tofind, 'MAandPSCorrect', condition, type);

               MRre(h)=nanmean(y1);
               MRir(h)=nanmean(x1);
               MSre(h)=nanmean(y2);
               MSir(h)=nanmean(x2);

               h=figure(i);
               if mod==1
               AX=plot(x1, y1,'g.',x2, y2,'r.');
               else 
               AX=plot(x1, y1,'b.', x2, y2, 'm.'); 
               end

               set(AX, 'MarkerSize',10)
               hold on
            end % end nnetworks

           if mod==1
           ax=legend('V2V', 'A2V');
           else
           ax=legend('A2A', 'V2A');
           end
           
           MRre_all=mean(MRre);
           MRir_all=mean(MRir);
           MSre_all=mean(MSre);
           MSir_all=mean(MSir);

            plot([0 0], [-.5 .5],'k:', [-1 1], [0 0],'k:', [-1 1], [MRre_all MRre_all], color{1}, [MRir_all MRir_all], [-.5,.5], color{1},...
                [-1 1],[MSre_all MSre_all], color{2}, [MSir_all MSir_all], [-.5,.5], color{2});

%             txt1 = sprintf('%0.2f \n%0.2f' ,MRre_all, MRir_all);
%             txt2 = sprintf('%0.2f \n%0.2f' ,MSre_all, MSir_all);
%             str={txt1,txt2};
%             xtext=[MRir_all+0.01,MSir_all+0.01];
%             ytext=[MRre_all-0.01,MSre_all-0.01];
%             H=text(xtext, ytext, str);
%             
% 
%             set(H, 'FontSize', 12);

            hold on

           ylim([0-.3 .5])
           xlim([-1 .5])

           
           title(tofind)

           ylabel('PS unit activation update');
           xlabel('Activation to cross-modal MA unit');

           saveas(h,figurename, 'png');


           hold off
           close all

    end % END i condition
   
end
    
    

