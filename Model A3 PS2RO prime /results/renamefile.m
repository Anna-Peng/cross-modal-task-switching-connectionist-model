% scatterplot for the TA activation level, PS activation level and RO

close all
clear all

%% get folder and files
oldfolder=input('[load which folder?] ', 's');
newfolder=input('[move to which folder] ', 's');

ppath=cd;
f1 = strcat(ppath, filesep, oldfolder);
f2= strcat(ppath, filesep, newfolder);

addpath(f1)
filePattern = fullfile(f1, '*.mat');

Ref=dir(filePattern);

Ref={Ref.name}';

for i=1:length(Ref)
    name=cell2mat(Ref(i));
    [~, filename, ~]=fileparts(name);
    name_record{i,:}=filename(1:5);
end

network_type=unique(name_record);

x=num2cell(1:length(network_type));

[x',network_type]

oldname=input('[enter file reference to be renamed] ', 's');
oldname=str2num(oldname);

for m=1:length(oldname)
newname{m}=input('[new name as] ', 's');
end

%% plot scatter for specific network
for j=1:length(oldname) % cycling through different network architectures (number of graphs)
    
    tofind=cell2mat(network_type(oldname(j)));
    index=strfind(Ref, tofind);   
    tf = cellfun('isempty',index);
    index(tf) = {0} ;
    index=cell2mat(index);
    current_network=find(index==1);
    
    
    for h=1:length(current_network) % cycling within the network type (no. of participants)
    newName = fullfile(f2, sprintf('%s%d.mat', newname{j}, h) );
    current_name=fullfile(f1, Ref(current_network(h)));
    [SUCCESS,~,~] = movefile(current_name{1}, newName);
    SUCCESS
    end

    
end
    
    

