%% This network eliminates the task attribute nodes in the pure condition. 
% Instead top-down input is sent to the RO units directlyand intermittantly
% on the excel sheet vtop-input is the input to the RO during the gap
% between updates, and vtop-rep is the large top-down input on update
% cycle. the overall top-down input is vtop-rep*vTA_Yes and
% vtop-rep*vTA_Yes. In contrast to the mixed condiiton, top-down update
% makes the network more likely to commit comission error, and is
% detrimental to task performance.
%vselectiontime=1 for inhibition, 2 for excitation

clear all
ppath=cd;

fpath=[ppath,'/results/temporary1/'];
vreadfile=input('read excel file: ','s');
if isempty(vreadfile)
vnetwork= input('number of network parameters: '); % 20 trials to each condition (total 80 trials)
end

vno_subject=input('[no. of subjects:] ');
vnblock= input('[no. of blocks (8 trials in each ''PPMMM'' block) (5 blocks x 8= 40 trials in each condition):] '); 
call_condition = input('[Condition P=pure, M=mixed (default "Pure Pure Mixed Mixed Mixed") \nEnter for default:] ', 's');
if strcmp(call_condition, 'M')==1 || isempty(call_condition)
    freqswitch=input('[how often to switch trial? 1=every other trial, 2=every 4 trials] ');
end

%% if using the same stimuli throughout
samestimuli= input('[repeat the same stimulus=1 unique=2 random=3 or uniselection=4 (only in Mixed)] ');
population=input('[Simulate Fixed or population networks? Fixed=1, Population=2] ');
if population==1
    setinterval=input('[Set Update Probability for Pure, Rep and Swi trials (3 numbers)] ', 's');
    setinterval=str2num(setinterval);
end
    
prepallowed=1; %input('[Preparation allowed in Repetition and Pure trials? Yes=1, No=0] ');

if samestimuli==1
    whichstimulus=input('[whatstimulus do you want? ]','s');
    switch whichstimulus
        case 'DV'
            initial_vis=[1 0];
            initial_aud=[0 0];
        case 'DA'
            initial_vis=[0 0];
            initial_aud=[1 0];
        case 'BV'
            initial_vis=[0 1];
            initial_aud=[0 0];
        case 'BA'
            initial_vis=[0 0];
            initial_aud=[0 1];
        case 'DVBA'
            initial_vis=[1 0];
            initial_aud=[0 1];
        case 'DABV'
            initial_vis=[0 1];
            initial_aud=[1 0];
    end
elseif samestimuli==2
     initial_vis=[3 3];
     initial_vis=[3 3];
end

%%
if strcmpi(call_condition, 'M')
    call_condition=repmat('M',1,3);
elseif strcmpi(call_condition, 'P')
    call_condition=repmat('P',1,3);
else
    call_condition='PPMMM';
end


%% set parameter
if isempty(vreadfile)
        for i=1:vnetwork
        whatisfile= input('save the file as): ', 's'); 
        filename(i*2+1-2:i*2,:)={whatisfile};
        [zparameter, PureAnswer, MixedAnswer]=parameter_dialogueA3_dynamic(filename(i));
        inputans=[struct2cell(PureAnswer)';struct2cell(MixedAnswer)']; %2x length of queries
        inputans=['1',inputans(1,:);'2',inputans(2,:)];
        inputanswer(i*2+1-2:i*2,:)=str2double(inputans);
        inputcell=num2cell(inputanswer);
        zparameter=[zparameter;inputcell];
        end
else

        [inputanswer,TXT,~]=xlsread(vreadfile);
        vnetwork=size(inputanswer,1)/2;
        zparameter=TXT(1,3:size(TXT,2));
        inputcell=num2cell(inputanswer);
        zparameter=[zparameter;inputcell];
        filename=TXT(2:size(inputanswer,1)+1,1);
        agename=TXT(2:size(inputanswer,1)+1,2);
        clearvars TXT
end

%% set names

PSname={'DogV','BirdV';'DogA','BirdA'}; % visual; auditory (N=neutral)
TAname={'Dog','Bird'};
ROname={'DogY','DogN','BirdY','BirdN'};
MREname={'V'; 'A'};
vfeature_num=2;
vout_num=2;
vtask_num=2;
vtask_bias=-2;
%intialize patterns
PSpattern=[1,0; 0,1; 0,0]; % dog, bird, neutral
task_node=zeros(1, vtask_num);  %TA nodes
node=[1,2];
%initialize all possible priming connections
[PSvis_TA_prime, PSaud_TA_prime]=deal(zeros(2, vfeature_num)); % PS units to task demand Dog connections [0 0] x2
PS2TAprime=zeros(1,vfeature_num);
[PSaud_RO_prime,PSvis_RO_prime, PS2ROprime_all]=deal(zeros(4,2));

%% start iteration of parameters, networks, condition and trials

for no_s=1:vnetwork


for vsubject=1:vno_subject
    
    zall_data={'trial_no','trial_type','task','stimulus','target_modality',...
        'premod','modshift',...
        'response','index','set_correct','correct',...
        'DogPrime','BirdPrime',...
        'DogPS2TA','BirdPS2TA',...
        'DY','DN','BY','BN',...
        'DogPrep','BirdPrep',...
        'DogTAend','BirdTAend',...
        'DogTAinput','BirdTAinput',...
        'PS',...
        'V','A','time','updatefreq','ta','PSinitial'};%,'DYendNet','DNendNet','BYendNet','BNendNet',...
        %'DYstaNet','DNstaNet','BYstaNet','BNstaNet'};

        if population==2
           updatefreq=rand(1);
        end
%% start conditions
for condition=1:length(call_condition)
 
    k=[1,2,1,2];
    if strcmpi(call_condition(condition), 'P') % Pure condition          
        for z=1:size(zparameter,2)
            v=genvarname(zparameter{1,z});   
            eval([v '=inputanswer(no_s*2+1-2,z);']);
        end
        all_trials=repmat(k(condition),1,vnblock*8); %% to change to randperm
    else
        for z=2:size(zparameter,2)
            v=genvarname(zparameter{1,z});   
            eval([v '=inputanswer(no_s*2,z);']);
        end
        
        if freqswitch==1, switchpattern=[1 2 2 1 1 2 2 1]; elseif freqswitch==2, switchpattern=[1 1 1 1 2 2 2 2];
        end % mixed condition
        all_trials=repmat(switchpattern,1,vnblock);
    end
    
    if population==2
    xmin=vinterval;
    xmax=vinterval_rep;
    popinterval=xmin+updatefreq*(xmax-xmin); 
    end

%% Load parameters
vcondition=call_condition(condition);
%intialize patterns
PSpattern=[1,0; 0,1; 0,0]; % dog, bird, neutral
task_node=zeros(1, vtask_num);  %TA nodes
task_netinput=[0,0];
max_tasknet=[0,0];
mod_node=zeros(1,2);

switch vcondition
    case 'M'
    PSdog_RO=[1,0;0,1]; %PS dog units connections to RO units [DY, DN; BY, BN] (to be used for visual and auditory inputs seperatedly)
    PSbird_RO=[0,1;1,0]; % PS bird units connections to RO units (to be used for visual and auditory inputs seperatedly)
    case 'P'
        if all_trials(1)==1 % dog task
        PSdog_RO=[1,0;0,0]; 
        PSbird_RO=[0,1;0,0];
        else
        PSdog_RO=[0,0;0,1]; 
        PSbird_RO=[0,0;1,0];
        end
end


counter=1; % counting the number of trials
for trial=1:length(all_trials)
% this part of initialization will return to zero after each trial
ROrecord=[];
PSrecord=[];
PS_inputrecord=[];
PS_node=[0,0;0,0];
[ROdog_node, RObird_node]=deal(zeros(1,vout_num)); % Response output units return to 0 after each trial 
if trial==1
    modality_record=[0,0];
else
    modality_record=[modality_record(2),target_modality];
end
%% Generate stimulus

    run generate_stimulus
    previous_vis=current_vis;
    previous_aud=current_aud;
    current_taskcontrol=vtask_control;

    run preparation

%% Stimulus presentations t=1 processes
t=1; % record no. of iteration 
ta=1;

% Initiate PS nodes calculate netinputs from PS units to RO units
% 
% if vminPSact<1 && vselectiontime==2 % excitation update

% else
    
PS_node=[current_vis'.*vPS_startv,current_aud'.*vPS_starta];
% end

if isequal(current_vis, [1,0]) % if the current visual stimulus is dog
   netvis=PSdog_RO.*PS_node(1,1).*vPSvis_RO; % the PS connection to RO units are [1,0;0,1] * Vis weight
elseif isequal(current_vis, [0,1]) % if the current visual stimulus is bird
   netvis=PSbird_RO.*PS_node(2,1).*vPSvis_RO; % the PS connection to RO units are [0,1;1,0] * Vis weight
else
   netvis=[0,0;0,0];
end

if isequal(current_aud, [1,0]) % if the current auditory stimulus is dog
   netaud=PSdog_RO.*PS_node(1,2).*vPSaud_RO; % the PS connection to RO units are [1,0,0,1] * aud weight
elseif isequal(current_aud, [0,1]) % if the current visual stimulus is bird
   netaud=PSbird_RO.*PS_node(2,2).*vPSaud_RO; % the PS connection to RO units are [0,1,1,0] * aud weight
else
   netaud=[0,0;0,0];
end

PS2ROnet=netvis+netaud;

% netinput from PS units to TA units via N-1 connections

PS2TAprime(current_task==1)=sum((PSvis_TA_prime(:,current_task==1)'*PS_node(:,1))+(PSaud_TA_prime(:,current_task==1)'*PS_node(:,2)));
PS2TAprime(current_task==0)=sum((PSvis_TA_prime(:,current_task==0)'*PS_node(:,1))+(PSaud_TA_prime(:,current_task==0)'*PS_node(:,2)));% N-1 connection x current stimulus to dog TA
PS2ROprime_all=PSvis_RO_prime*PS_node(:,1)+PSaud_RO_prime*PS_node(:,2);
PS2ROprime_all=PS2ROprime_all';
PS2ROprime=[PS2ROprime_all(1:2);PS2ROprime_all(3:4)];
PS2ROprime(PS2ROprime<0)=0;


%% End of preparation 

if vTAon==0 % if no TA node
task_node=vtask_control;
preparation_history=task_node;
else
preparation_history=task_node(end,:); % to delete
task_node=task_node(end,:); 
end


PS2TA=(current_vis.*PS2TAweight+current_aud.*PS2TAweight); % 1x2
            
            
while true 
        %% check response outputs
    %% Checking Response 
   
        ROnode=[ROdog_node(end,:),RObird_node(end,:)];
        ROanswer=ROnode>vResponse_Threshold;
        if sum(ROanswer>0)==1
            if  any(ROdog_node(end,:)>vResponse_Threshold)% if any dog RO unit exceed response threshold
                if ~isempty(strfind(ROname{1,ROanswer==1}, TAname{current_task==1})) % check if the chosen response set corresponds to the current task set
                    respset_correct=1; % if it is, the correct response set
                    if ~isempty(strfind(ROname{ROanswer==1}, 'Y')) && ~isempty(strfind(strjoin(current_stimulus), TAname{current_task==1})) %check if the chosen response is Y and the stimulus contains current task word
                        response_correct=1; 
                    elseif ~isempty(strfind(ROname{ROanswer==1}, 'N')) && isempty(strfind(strjoin(current_stimulus), TAname{current_task==1})) %check if the chosen response is Y and the stimulus contains current task word
                            response_correct=1; 
                    else
                            response_correct=0;
                    end
                else
                    respset_correct=0;
                    response_correct=0;
                end % end/ ~isempty(strfind(ROname{1,ROanswer==1}, TAname{current_task==1}))
            break
            elseif  any(RObird_node(end,:)>vResponse_Threshold)  % if bird outputs exceed response threshold
                if ~isempty(strfind(ROname{ROanswer==1}, TAname{current_task==1})) % check if the chosen response set corresponds to the current task set
                    respset_correct=1; % if it is, the correct response set
                    if ~isempty(strfind(ROname{ROanswer==1}, 'Y')) && ~isempty(strfind(strjoin(current_stimulus), TAname{current_task==1})) %check if the chosen response is Y and the stimulus contains current task word
                        response_correct=1; 
                    elseif ~isempty(strfind(ROname{ROanswer==1}, 'N')) && isempty(strfind(strjoin(current_stimulus), TAname{current_task==1})) %check if the chosen response is Y and the stimulus contains current task word
                            response_correct=1; 
                    else
                            response_correct=0;
                    end
                else
                    respset_correct=0;
                    response_correct=0;
                end % end ~isempty(strfind(ROname{2,ROanswer==1}, TAname{current_task==1}))
                break
            end % end for checking RO==1
        

        elseif t>timeout % stop if time exceeds timeout
                    respset_correct=0;
                    response_correct=0;
        break
        
        elseif sum(ROanswer>0)>1 % double answers
                respset_correct=0;
                response_correct=0;
        break

        end % end sum(ROanswer>0)==1 / if word outputs exceed response threshold

                
%% update TA, MA & PS nodes
switch vcondition
    case 'M'       
            %% Update PS nodes (Mixed)
            if vselectiontime==2 % if it is late selection (excitation (both TA2PS and MA2PS))
                PS_netinput=mod_node(end,:).*[vmod_MA2PSv,vmod_MA2PSa]+vPSinput;
            elseif vselectiontime==1  % if it is inhibitoy (both TA2PS and MA2PS), early selection
                PS_netinput=mod_node(end,:).*[-vmod_MA2PSa,-vmod_MA2PSv];
                PS_netinput=fliplr(PS_netinput)+vPSinput;
            else
                PS_netinput=[0,0];    
            end
            
            for j=1:vtask_num
                    %update PS nodes
                    for mod=1:2 % no of modalities
                        if PS_node(j,mod)~=0 && vminPSact<1
                        PS_update=eta(PS_netinput(mod), PS_node(j,mod), vStep, vminPSact, vmaxact);
                        PS_node(j,mod)=activation(PS_node(j,mod), PS_update, vnoise_sd, vminPSact, vmaxact);
                        end
                    end
            end
                
            if (type==3 || type==0) && population==1 % if fixed network, first trial or switch trial
                interval=setinterval(3); % set fixed probability
            elseif type==2 && population==1
                interval=setinterval(2);
            elseif population==2 % set population probability by range (min & max)
                interval=popinterval;
            end
             
            if rand(1)<interval
                current_taskcontrol=vtask_control;
            else
                current_taskcontrol(current_task==1)=0;
            end
            
            %% Calculate PS to MA netinput and update MA units
            maxTop=[0,sum(vtask_control)]; % only to auditory unit

            for j=1:size(mod_node,2)
                mod_li_node=mod_node(t,:); % activation of modality nodes from the last iteration
                mod_li_node(j)=0; % exclude the current task node from calculation of lateral inhibition 

                if j==1 %visual node
                    vlimod_weight=vli_A2V;
                    Top2MA=0;
                    vmod_PS2MA=vmod_PS2MAv;
                elseif j==2 
                    
                    if sum(current_taskcontrol)~=0
                    Top2MA=1; % only auditory units receive activation from top-down (articulatory rehearsal).
                    else
                    Top2MA=0;
                    end
                    vlimod_weight=vli_V2A;
                    vmod_PS2MA=vmod_PS2MAa;

                end

            
            PS2MA_net=sum(PS_node(:,j)).*vmod_PS2MA; % netinput from PS units to MA units
            
            if j==1 && t>vPSthreshold
            Top2MA_net=Top2MA.*vmod_Top2MAv;% netinput from Top-down freq to MA units
            elseif j==2 && t>vPSthreshold
            Top2MA_net=Top2MA.*vmod_Top2MAa;
            else
            Top2MA_net=0;
            end
            
            mod_li= sum(mod_li_node.* vlimod_weight); % lateral inhibition for modality node
            mod_netinput(j)=PS2MA_net + Top2MA_net - mod_li+ vtask_bias; % netinput to task node (j)
%             max_MAnet(j)=PS2MA_net + vmod_Top2MA- task_li + vtask_bias;
            MA_update= eta (mod_netinput(j), mod_node(t,j), vStep, vminact, vmaxact);
            mod_node(t+1, j)= activation(mod_node(t,j), MA_update, vnoise_sd, vminact, vmaxact);
            end 
            
            %% UPDATE TA NODES (Mixed)
            if t>vPSthreshold %sum(PS_node(:)>vPSthreshold)~=0 % if PS node exceeds PS threshold then start update TA & RO)
            PS2TA=(PS_node(:,1).*PS2TAweight+PS_node(:,2).*PS2TAweight); % 1x2 BOTTOM-UP INPUT TO TA
                for j=1:vtask_num
                    task_li_node=task_node(t,:); % activation of task nodes from the last iteration
                    task_li_node(j)=0; % exclude the current task node from calculation of lateral inhibition 
                    task_li= sum(task_li_node.* vli_weight); % lateral inhibition for task node (j) 
                    task_netinput(j)=current_taskcontrol(j)+ PS2TAprime(1,j) - task_li + vtask_bias+PS2TA(j); % netinput to task node (j)
                    max_tasknet(j)=vtask_control(j)+ PS2TAprime(1,j) - task_li + vtask_bias+PS2TA(j);
                    task_update= eta (task_netinput(j), task_node(t,j), vStep, vminact, vmaxact);

                    if sum(current_taskcontrol)~=0 % if the nodes are being updated by task control (task-relevant positive input, task-irrelevant negative input by bias)
                    task_node(t+1, j)= activation(task_node(t,j), task_update, vnoise_sd, vminact, vmaxact);
                    else % TA gravitates towards towards 0 (min activation set to the current activation * squashing value)
                    task_node(t+1, j)= activation(task_node(t,j), task_update, vnoise_sd, task_node(t,j)*vrho, vmaxact);  
                    end

                end
            
            else
                task_node(t+1,:)=task_node(end,:);
            end % end sum(PS_node>0.5)~=0

    case 'P'         
                %% Update PS Nodes (Pure)
                % calculate netinput to PS nodes (MA2PS)
                if vselectiontime==2 % if it is late selection (excitation (MA2PS))
                    PS_netinput=mod_node(end,:).*[vmod_MA2PSv,vmod_MA2PSa]+vPSinput;
                elseif vselectiontime==1  % if it is inhibitoy (bothand MA2PS), early selection
                    PS_netinput=mod_node(end,:).*[-vmod_MA2PSa,-vmod_MA2PSv];
                    PS_netinput=fliplr(PS_netinput)+vPSinput;
                else
                    PS_netinput=[0,0];    
                end
                
                for j=1:vtask_num % update all the PS nodes
                        %update PS nodes
                        for mod=1:2 % no of modalities
                            if PS_node(j,mod)~=0 && vminPSact<1
                            PS_update=eta(PS_netinput(mod), PS_node(j,mod), vStep, vminPSact, vmaxact);
                            PS_node(j,mod)=activation(PS_node(j,mod), PS_update, vnoise_sd, vminPSact, vmaxact);
                            end
                        end
                end
              %% Calculate PS to MA netinput and update MA units                     
                if population==1
                interval=setinterval(1);
                elseif population==2
                interval=popinterval;
                end
                
                randomRO=randperm(2,1);

                if vTAon==0 % if pure condition has no TA unit, randomly select a RO node to send top-down input  
                    if rand(1)<interval
                        current_taskcontrol(node==randomRO)=vtask_control(current_task==1).*vTA_Yes; %
                        current_taskcontrol(node~=randomRO)=vtask_control(current_task==1).*vTA_No; %-voutput_bias; %bias value
                    else
                        current_taskcontrol=[0 0];
                    end

                    task_node(t+1, :)= current_taskcontrol;%activation(task_node(t,current_task==1), task_update, vnoise_sd, vminact, vmaxact);
                    
                else  % if TA unit is present  
                    
                    if rand(1)<interval
                        current_taskcontrol(current_task==1)=vtask_control(current_task==1);
                    else
                        current_taskcontrol(current_task==1)=0;
                    end
                    
                    
                    if t>vPSthreshold %sum(PS_node(:)>vPSthreshold)~=0% if any PS exceeds threshold, start update TA
                        PS2TA(1,current_task==1)=(PS_node(current_task==1,1).*PS2TAweight+PS_node(current_task==1,2).*PS2TAweight); % 1x2
                        task_netinput(1,1)=current_taskcontrol(current_task==1)+ PS2TAprime(1,current_task==1) + vtask_bias+PS2TA(1,current_task==1); % netinput to task node (j)
                        max_tasknet(1,1)=vtask_control(current_task==1)+ PS2TAprime(1,current_task==1) + vtask_bias+PS2TA(1,current_task==1);
                        task_update= eta (task_netinput, task_node(t,current_task==1), vStep, vminact, vmaxact);

                        if sum(current_taskcontrol)~=0 % if task control is online
                        task_node(t+1, current_task==1)= activation(task_node(t,current_task==1), task_update, vnoise_sd, vminact, vmaxact);
                        task_node(t+1, current_task==0)= 0; %task node is always 0
                        else % TA gravitates towards 0
                        task_node(t+1, current_task==1)= activation(task_node(t,current_task==1), task_update, vnoise_sd, vminsct*vrho, vmaxact*vrho);
                        task_node(t+1, current_task==0)= 0; %task node is always 0
                        end   
                    else
                        task_node(t+1,:)=task_node(end,:);
                        
                    end
                    
                end % if vTAon==0
                
                
                for j=1:size(mod_node,2)
                    mod_li_node=mod_node(t,:); % activation of modality nodes from the last iteration
                    mod_li_node(j)=0; % exclude the current task node from calculation of lateral inhibition 

                    if j==1 % visual node
                        vlimod_weight=vli_A2V; 
                        vmod_PS2MA=vmod_PS2MAv;
                        if vTAon==0
                            if sum(current_taskcontrol)>0
                            Top2MA=0;
                            else
                            Top2MA=0;
                            end
                        else
                        Top2MA=1;
                        end   

                    elseif j==2 % only auditory units receive activation from top-down (articulatory rehearsal).
                        vlimod_weight=vli_V2A;                      
                        vmod_PS2MA=vmod_PS2MAa;

                        if vTAon==0
                            if sum(current_taskcontrol)>0
                            Top2MA=0;
                            else
                            Top2MA=0;
                            end
                        else
                        Top2MA=1;
                        end 
                    end

                PS2MA_net=sum(PS_node(:,j)).*vmod_PS2MA; % netinput from PS units to MA units
                
                if j==1 && t>vPSthreshold
                Top2MA_net=Top2MA.*vmod_Top2MAv; % netinput from Top-down control to MA units
                elseif j==2 && t>vPSthreshold
                Top2MA_net=Top2MA.*vmod_Top2MAa;
                else
                Top2MA_net=0;  
                end
                
                mod_li= sum(mod_li_node.* vlimod_weight); % lateral inhibition for modality node
                mod_netinput(j)=PS2MA_net + Top2MA_net- mod_li+ vtask_bias; % netinput to task node (j)
                MA_update= eta (mod_netinput(j), mod_node(t,j), vStep, vminact, vmaxact);
                mod_node(t+1, j)= activation(mod_node(t,j), MA_update, vnoise_sd, vminact, vmaxact);
                end
  
            

end % END OF CASE SWITCH (PURE VS. MIXED)
               
                %% Update RO nodes
                if t>vPSthreshold %sum(PS_node(:)>vPSthreshold)~=0
                run UpdateRO
                ta=ta+1;
                else
                    RObird_node(t+1,:)=[0 0];
                    ROdog_node(t+1, :)=[0 0];
                end
                
                %% Record
                
                ROrecord(t,:)=[ROdog_node(end,:),RObird_node(end,:)];
                PSrecord(t,:)=[PS_node(1,:), PS_node(2,:)];
                PS_inputrecord(t,:)=PS_netinput;
                
                if t==vPSthreshold
                PSinitial=[PS_node(1,:),PS_node(2,:)];
                end
                t=t+1;
               
end % end response check
%sprintf('current task is %s,\n current stimulus is %s,\n current response is %s,\n response is correct=%d,\n time is %d',  char(TAname(current_task==1)), char(current_stimulus)', char(ROname(ROall==max(ROall(:)))), response_correct, t)
tasknode_record=task_node;
modrecord=mod_node;

primedNode=task_node(end,:).*current_task;
PSvis_TA_prime=PS_node(:,1)*primedNode*vpriming; % 2 x 2 column task to PS connections (dog-DA; dog-BA) & (bird-DA; bird-BA)
PSaud_TA_prime=PS_node(:,2)*primedNode*vpriming;
PSvis_RO_prime=ROnode'*PS_node(:,1)'*vROpriming; % 4x2 matrix [DY;DN;BY;BN]*[DV,BV]
PSaud_RO_prime=ROnode'*PS_node(:,2)'*vROpriming;

mod_end_node=mod_node(end,:);
task_end_node=task_node(end,:);

switch vcondition
        case 'M'
        task_node=task_node(end,:).*vrho;
        
        if modality_record(2)==0
        mod_node=[0 0];
        else
        mod_node=mod_node(end,:).*vrho_mod;
        end

        PS_record=[PS_node(1,:),PS_node(2,:)];
        case 'P'
            if vTAon~=0
            task_node=task_node(end,:).*vrho;
            else
            task_node=task_node(end,:);
            end
        if modality_record(2)==0
            mod_node=[0 0];
        else
        mod_node=mod_node(end,:).*vrho_mod;
        end
        PS_record=[PS_node(1,:),PS_node(2,:)];
end

    

modality_record=[modality_record(2),target_modality];

    

    zall_data(end+1,:)={counter, type, TAname(current_task==1), char(current_stimulus), target_modality,...
        modality_record(1),modality_record(2),...
        ROname(ROnode(:)>vResponse_Threshold), trial_index, respset_correct, response_correct,...
        PS2TAprime(1),PS2TAprime(2),...
        PS2TA(1),  PS2TA(2),...
        ROnode(1),ROnode(2),ROnode(3),ROnode(4),...
        preparation_history(1),preparation_history(2),...
        task_end_node(1),task_end_node(2),...
        max_tasknet(1), max_tasknet(2),...
        PS_record,mod_end_node(1),mod_end_node(2),t, interval, ta, PSinitial}; %,net_dog(1,1), net_dog(1,2), net_bird(1,1), net_bird(1,2),...
        %netstart(1), netstart(2), netstart(3), netstart(4)};% PS2ROprime(1,1),PS2ROprime(1,2), PS2ROprime(2,1), PS2ROprime(2,2)};
        counter=counter+1;

    
end % end trial


end

parameterlabel=[zparameter(1,:),'interval'];
intervalvalue={interval;interval};
parametervalue=[zparameter(no_s*2:no_s*2+1,:), intervalvalue];
name=sprintf('%s%s_%d',filename{no_s*2-1,:},agename{no_s*2-1,:}, vsubject);
current_parameter=[parameterlabel;parametervalue];

save([fpath,name],'zall_data', 'current_parameter')
% write_results(zall_data, name)

end % end of number of subject


end % end number of vnetwork
