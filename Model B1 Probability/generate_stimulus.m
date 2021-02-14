stimulus_change=1; %whether to reselect stimulus or not

if all_trials(trial)==1 
    current_task=[1,0];
    trial_index=1;
else
    current_task=[0,1];
    trial_index=2;
end


while stimulus_change==1

    current_vis=PSpattern(randperm(3,1),:); % random select visual input
    current_aud=PSpattern(randperm(3,1),:); % random select auditory input
    
    if strcmpi(call_condition(condition), 'M')
        switch samestimuli
            case 3 % random

                    if isequal(current_vis, current_aud) || (sum(current_vis)+sum(current_aud))==0 % if the two elements from the same animal category or if two neutrals
                        stimulus_change=1; % change the stimulus
                    else
                        stimulus_change=0;
                    end

            case 2 % unique
                if counter==1
                previous_vis=initial_vis;
                previous_aud=initial_aud;
                end
                redraw(1)=double(isequal(current_vis, current_aud));
                redraw(2)=double(sum(current_vis)+sum(current_aud)==0);
                redraw(3)=double(isequal(current_vis, previous_vis));
                redraw(4)=double(isequal(current_aud, previous_aud));
                if any(redraw)~=0
                    stimulus_change=1; % change the stimulus
                else
                    stimulus_change=0;
                end
            case 1 % fixed
                current_vis=initial_vis;
                current_aud=initial_aud;
                stimulus_change=0;
        end
       
    elseif strcmpi(call_condition(condition), 'P')
                if (sum(current_vis)+sum(current_aud))~=1 % all stimulus are unimodal
                    stimulus_change=1;
                else
                    stimulus_change=0;
                end
    end % end strcmpi(call_condition(condition), 'M')
    

end % end while

current_stimulus=[PSname(1,current_vis==1),PSname(2,current_aud==1)]; % stimulus name

if (sum(current_vis)+sum(current_aud)) > 1
    select_attention=1;
else
    select_attention=0;
end


% Record Target Modality
if isequal(current_vis,current_task)
    target_modality=1; %visual target
elseif isequal(current_aud,current_task)
    target_modality=2;
else
    target_modality=0;
end

% Record Trial Type (switch or rep or pure)
if counter==1
    type=0; %first trial
elseif counter~=1 && strcmpi(vcondition,'P')
    type=1;
elseif counter~=1 && strcmpi(vcondition,'M') && freqswitch==1
    if rem(trial,2)==1
    type=2; %repetition trial
    else
    type=3; %switch trial
    end

elseif counter~=1 && strcmpi(vcondition,'M') && freqswitch==2
    if rem(trial,4)~=1
    type=2; %repetition trial
    else
    type=3; %switch trial
    end

end

if type==1 || type==2 % Pure and Repetition trials
vtask_control=current_task.*vtop_rep;
else % switch trial and first trial
vtask_control=current_task.*vtop_input;
end


