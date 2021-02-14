clear all    
whichdatefile=input('[input date file] ','s'); 
datefile=strcat('withinstats', whichdatefile, '.mat');
load(datefile);

Ref=Pure.Parameter(2:end,1);
[~, name_record, ~]=cellfun(@fileparts, Ref, 'uni',0);

name_record=cellfun(@(x) x(1:4), name_record,'uni',0);

network_type=unique(name_record);

x=num2cell(1:length(network_type));

[x', network_type]

    no_file=input('[how many files?] ');
    
    for i=1:no_file
    tofind=input('[filename] ','s');
    findall{i}=tofind;
    end
    n=input('[which network participant?] ');
    
    for i=1:no_file
    curren_find=findall{i};
    index=strfind(Pure.RT(:,1), curren_find);   
    tf = cellfun('isempty',index);
    index(tf) = {0} ;
    index=[0;cell2mat(index)];
    k=find(index==1);
    j=k(n);
   
    Puredata(:,i)=cell2mat(Pure.RT(j,2:end))';
    Repdata(:,i)=cell2mat(Repetition.RT(j,2:end))';
    Swidata(:,i)=cell2mat(Swi.RT(j,2:end))';
    Purepa(:,i)=cell2mat(Pure.Parameter(j,2:end))';
    Swipa(:,i)=cell2mat(Repetition.Parameter(j,2:end))';
    
    name(i)=Pure.RT(j,1);
    
    end

    Puredata=[name; num2cell(Puredata)];
    Repdata=[name; num2cell(Repdata)];
    Swidata=[name; num2cell(Swidata)];
    
    table(Pure.RT(1,:)',Puredata, Repdata, Swidata)
    
    
    
    Purepa=[name; num2cell(Purepa)];
    Swipa=[name; num2cell(Swipa)];
    
    Paraname=Pure.Parameter(1,:)';
    table(Paraname, Purepa, Swipa)