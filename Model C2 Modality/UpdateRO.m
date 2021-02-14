%% Update RO nodes
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

if vTAon==0
    Yes=1;
    No=1;
else
    Yes=vTA_Yes;
    No=vTA_No;
end

TA2ROnet=task_node(t,:)'*[Yes, No]; % TA to RO net 2x2: 1st row DY DN, 2nd row BY BN  

                ROall=[ROdog_node(end,:);RObird_node(end,:)]; %[Y N; Y N];
                g=[2,1]; % k index the outer response set (rows in ROall)
                net=zeros(2);
                update=PSdog_RO+PSbird_RO; % 1,1;0,0 frist row for dog, second row for bird
                for i=1:2 % cycling through response sets
                    for j=1:2 % cycling through RO nodes
                    RO_inner_li_node=ROall(i,:);
                    RO_inner_li_node(j)=0;
                    
                    if rem(t, vinhiinterval)==0 && j==1 % when the lateral inhibition is asymmetric at update & is RO-Yes
                        inner_li=vliNo2Yes_weight; %no2yes lateral inibition weight
                    else
                        inner_li=vli_weight;
                    end
                    
                    RO_inner_li=sum(RO_inner_li_node.* -inner_li); 
                    RO_outer_li_node=ROall(g(i),:);
%                     RO_outer_li_node(RO_outer_li_node<0)=0;
                    RO_outer_li=sum(RO_outer_li_node.* -vli_weight); % using the same value of lateral inhibition for all weights between response sets
                        switch vcondition
                            case 'M'
                            net(i,j)=PS2ROnet(i,j) + TA2ROnet(i,j)+ RO_outer_li+RO_inner_li+ voutput_bias+PS2ROprime(i,j);
                            case 'P'
                            if update(i,j)==1            
                                net(i,j)=PS2ROnet(i,j) + TA2ROnet(i,j)+ +RO_inner_li+ voutput_bias+PS2ROprime(i,j)+voutput_input; % netinput to the other RO is turned off=0
                            else
                                net(i,j)=0;
                            end
                            
                        end
                    end
                end
                net_dog=net(1,:);
                net_bird=net(2,:);
%                 if t==1;
%                     netstart=[net_dog(1,:),net_bird(1,:)];
%                 end
                
                for i=1:2 % no response output to the other response set        
                    dog_update= eta(net_dog(i), ROdog_node(t,i), vStep, vminact, vmaxact);
                    ROdog_node(t+1, i)= activation( ROdog_node(t,i), dog_update, vnoise_sd, vminact, vmaxact);
                    bird_update= eta(net_bird(i), RObird_node(t,i), vStep, vminact, vmaxact);
                    RObird_node(t+1, i)= activation(RObird_node(t,i), bird_update, vnoise_sd, vminact, vmaxact);
                end
                
               if strcmp(vcondition, 'P') % turn off RO nodes in the competing task in pure condition
                    if isequal(current_task,[1,0]); % if dog task in pure condition
                      RObird_node(t+1, :)=[0,0];
                    else
                      ROdog_node(t+1, :)=[0,0];
                    end
               end
