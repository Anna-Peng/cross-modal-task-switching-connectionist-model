
close all
clear all

%% get folder and files
folder=input('load which folder? ', 's');

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

answer=input('load which files? (specify number index) ''enter'' for all: ', 's');

if isempty(answer)
    answer=[1:length(network_type)]';
    else
    answer=str2num(answer);
end

vartype=[1, 1, 2, 4, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1];
%% plot scatter for specific network
for j=1:length(answer) % cycling through different network architectures (number of graphs)
    
    tofind=cell2mat(network_type(answer(j)));
    index=strfind(Ref, tofind);   
    tf = cellfun('isempty',index);
    index(tf) = {0} ;
    index=cell2mat(index);
    current_network=find(index==1);
    
    
    for h=1:length(current_network) % cycling within the network type (no. of participants)
    current_load=fullfile(f, Ref(current_network(h)));
    load(current_load{1});
    
    tosaveas=Ref(current_network(h));
    task=zall_data(2:end,3);
    response=zall_data(2:end,8);
    change=0;
    for i=1:length(response)
        if ~isempty(response{i})
            if cell2mat(strfind(response{i}, task{i}))==1
                zall_data{i+1,10}=1;      
            elseif cell2mat(strfind(response{i}, task{i}))==0
                zall_data{i+1,10}=0;
                zall_data{i+1,11}=0;
                change=change+1;
            end
            
        end
    end
    total_change(h,1)=change;
 
%     save(toasveas, 'zall_data','current_parameter')
    end
    networkchange=sum(total_change);
change_record(j,1)=networkchange
end
    


