clear all
% folder=input('which folder contains result? ', 's');
% addpath([cd,filesep,folder]);

whichdatefile=input('[input date file] ','s'); 
datefile=strcat('withinstatsYes', whichdatefile, '.mat');

if ~exist(datefile,'file') 
    save(datefile)
end

load(datefile);

files=dir('A**.mat');
files={files.name}';
x=num2cell(1:length(files))';
[x,files]

vartype=[1, 1, 2, 4, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1,3, 1]; %1=single number, 2=cell, 3=multiple doubles, 4=cells with various charactor arrays
%      vartype to correspond to zall_data names 
% k={'trial_no','trial_type','task','stimulus','target_modality',...  
%     'premod','modshift','response','index','set_correct','correct',...
%     'DogPrime','BirdPrime','DogPS2TA','BirdPS2TA','DY','DN','BY','BN',...
%     'DogPrep','BirdPrep','DogTAend','DogTAend','PS','time'}

no_files=input('load which files? (specify number index) ''enter'' for all: ', 's');

if isempty(no_files)
    no_files=[1:length(files)]';
    else
    no_files=str2num(no_files);
end


for h=1:length(no_files);
    current_load=files{no_files(h)}
    
    if ~strcmp(current_load,'withinstats.mat')
    load(current_load);
    
    for j=1:size(zall_data,2)
        v=genvarname(zall_data{1,j});
        if vartype(j)==4
        eval([v '=zall_data(2:end,j);'])
            for k=1:length(stimulus)
                if size(stimulus{k},1)>1
                    name=stimulus{k};
                    stimulus{k}=[name(1,:),name(2,:)];
                end
            end
            
        elseif vartype(j)==2
        eval([v '=zall_data(2:end,j);'])
        
        elseif vartype(j)==1 | vartype(j)==3
        eval([v '=cell2mat(zall_data(2:end,j));'])
        end

    end

    
    allcondition=[1,2,3];

        for p=1:length(allcondition)
        k=allcondition(p);

        noTrial=sum(trial_type==k);
        curtrials= trial_type==k & correct==1; % all correct trials in the k condition -logical
        Prime=(DogPrime>0 | BirdPrime>0);
        Yes=(DY>0.2 | BY>0.2);
        No=(DN>0.2 | BN>0.2);
        YesPrime=Prime==1 & Yes==1;
        YesUnprime=Prime==0 & Yes==1;
        NoPrime=Prime==1 & No==1;
        NoUnprime=Prime==0 & No==1;
        % general performance
        nameTrial{1}=mean(time(curtrials & Yes)); % overall RT
        nameTrial{2}=mean(correct(trial_type==k)); % Overall Accuracy

        % modality

        nameTrial{3}= time(curtrials==1 & target_modality==1 & Yes); % visual trial
        nameTrial{4}= time(curtrials==1 & target_modality==2 & Yes); % auditory trial

        % modality shift
        nameTrial{5}= time(curtrials==1 & target_modality==1 & premod==1 & modshift==1 & Yes); % visual Mod Rep Trial
        nameTrial{6}= time(curtrials==1 & target_modality==1 & premod==2 & modshift==1 & Yes); % visual Mod Shift Trial
        nameTrial{7}= time(curtrials==1 & target_modality==1 & premod==0 & modshift==1 & Yes); % visual Mod Single Trial
        nameTrial{8}= time(curtrials==1 & target_modality==2 & premod==2 & modshift==2 & Yes); % Aud Mod Rep Trial
        nameTrial{9}= time(curtrials==1 & target_modality==2 & premod==1 & modshift==2 & Yes); % Aud Mod Swi Trial
        nameTrial{10}= time(curtrials==1 & target_modality==2 & premod==0 & modshift==2 & Yes); % Aud Mod Single Trial
        % Primed Trials
        
        nameTrial{11}= time(curtrials==1 & YesPrime==1); % Primed Yes Trials
        nameTrial{12}= time(curtrials==1 & YesUnprime==1); % Unprimed Yes Trials
        %% to be deleted?
        nameTrial{13}= time(curtrials==1 & NoPrime==1); % Primed No Trials
        nameTrial{14}= time(curtrials==1 & NoUnprime==1); % Unprimed No Trials
        nameTrial{15}= time(curtrials==1 & Prime==1); % Primed No Trials
        nameTrial{16}= time(curtrials==1 & Prime==0); % Unprimed No Trials
        nameTrial{17}= time(curtrials==1 & Yes==1); % Yes Trials
        nameTrial{18}= time(curtrials==1 & No==1); % No Trials
        %%
        % Error Types
        for i=1:length(nameTrial)
            meanRT(i)=mean(cell2mat(nameTrial(i)));
        end

        [vCommBtTrial, vOmiBtTrial, vCommWithinTrial, vOmiWithinTrial, vDbTrial, vTimeout]=deal(zeros(length(curtrials),1));

        % extract the responses
        for i=1:length(response)
            if size(response{i},2)==1 && correct(i)==0 && trial_type(i)==k
                if ~isempty(cell2mat(strfind(response{i},'Y'))) && set_correct(i)==1 % Yes response between response set
                    vCommWithinTrial(i)=1;
                elseif ~isempty(cell2mat(strfind(response{i},'Y'))) && set_correct(i)==0
                    vCommBtTrial(i)=1;
                elseif ~isempty(cell2mat(strfind(response{i},'N'))) && set_correct(i)==1
                    vOmiWithinTrial(i)=1;
                elseif ~isempty(cell2mat(strfind(response{i},'N'))) && set_correct(i)==0
                    vOmiBtTrial(i)=1;
                end
            elseif isempty(response{i}) && correct(i)==0 && trial_type(i)==k
                vTimeout(i)=1;
            elseif size(response{i},2)>1 && correct(i)==0 && trial_type(i)==k
                vDbTrial(i)=1;
            end
        end

        error=[sum(vCommBtTrial), sum( vCommWithinTrial), sum(vOmiBtTrial), sum(vOmiWithinTrial), sum(vDbTrial), sum(vTimeout)]; % main result
        
        meanRT2=num2cell(meanRT); error2=num2cell(error);
        
        if ~exist('Pure', 'var')
        [Pure.RT, Repetition.RT, Swi.RT] = deal({'Ref','meanRT', 'meanAccu','Vis', 'Aud', 'V2V', 'A2V', 'Vonly', 'A2A', 'V2A', 'Aonly', 'YesPrimed', 'YesUnprimed', 'NoPrimed', 'NoUnprimed', 'Primed', 'Unprimed', 'Yes','No'});
        [Pure.Error, Repetition.Error, Swi.Error]=deal({'Ref','ComBt', 'ComWithin', 'OmBt', 'OmWithin', 'Double', 'Timeout'});
        Pure.Parameter(1,:)=['Ref',current_parameter(1,:)];
        Repetition.Parameter(1,:)=['Ref',current_parameter(1,:)];
        Swi.Parameter(1,:)=['Ref',current_parameter(1,:)];
        end

        if k==1
            Pure.RT(end+1,:)=[current_load,meanRT2];
            Pure.Error(end+1,:)=[current_load,error2];
        elseif k==2
            Repetition.RT(end+1,:)=[current_load,meanRT2];
            Repetition.Error(end+1,:)=[current_load,error2];
        elseif k==3
            Swi.RT(end+1,:)=[current_load,meanRT2];
            Swi.Error(end+1,:)=[current_load,error2];
        end
        clearvars 'nameTrial' 
        end % end of condition
        


    
    % save result
    
    Pure.Parameter(end+1,:)=[current_load,current_parameter(2,:)];
    Repetition.Parameter(end+1,:)=[current_load,current_parameter(3,:)];
    Swi.Parameter(end+1,:)=[current_load,current_parameter(3,:)];

    else
        break
    end %end strcmp
%     
end % end for loop


save(datefile,'Pure', 'Repetition','Swi', 'whichdatefile')
%     
