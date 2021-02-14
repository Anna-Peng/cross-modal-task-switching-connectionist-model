%% Task Preparation
% Looping through preparation time with clamped input from task control to
% task demand units (x2)
% (for word task, task control=6; for color task, task control=15)
% inhibitory connection between task demand units
% all other inputs are at zero

if prepallowed==0 && (type==2 || type==1)
    prepinterval=1;
    prep_taskcontrol=[0,0];
elseif prepallowed==1 && (type==2 || type==1)
    prepinterval=vpreparation_rep;
    prep_taskcontrol=vtask_control;
else
    prepinterval=vpreparation_swi;
    prep_taskcontrol=vtask_control;
end



for p=1:prepinterval % task preparation starts
    switch vcondition
        case 'M'
            
            for n=1:vtask_num
            task_li_node=task_node(p,:);
            task_li_node(n)=0;
            task_li= sum(task_li_node.*-vli_weight); % task lateral inhibition
            task_netinput=prep_taskcontrol(n)+ task_li + vtask_bias; % x=net input (task control input - lateral inhibition + task bias); task bias is in '-'
            task_update= eta(task_netinput, task_node(p,n), vStep, vminact, vmaxact); % calculate changes in activity
            task_node(p+1, n)= activation(task_node(p,n), task_update, vnoise_sd, vminact, vmaxact ); % update node activities    
            end        
          
        case 'P'            
            if vTA_Yes~=0
            task_netinput(1,1)=prep_taskcontrol(current_task==1)+ vtask_bias;
            task_update= eta(task_netinput(1,1), task_node(p,current_task==1), vStep, vminact, vmaxact); 
            task_node(p+1, current_task==1)= activation(task_node(p,current_task==1), task_update, vnoise_sd, vminact, vmaxact ); 
            end

    end % end switch condition (M & P)
end % end of task preparation

