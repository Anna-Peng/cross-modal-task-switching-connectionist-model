clear all

% New version. This records Priming Cost on Trial Types (Yes responses
% only), and Mixing and Switch cost. In pure variable, the Codnition cost
% is Mixing cost, in Rep and Swi variable, the ConditionCost is Switch Cost
% folder=input('load which folder? ', 's');
% 
% ppath=cd;
% f = strcat(ppath, filesep, folder);
% addpath(f)
whichdatefile=input('[load which file? only last few bits ]','s');
file2load=sprintf('withinstatsYes%s.mat', whichdatefile);
load(file2load);

datefile=strcat('comparemodelsYes', whichdatefile, '.mat');

if ~exist(datefile,'file') 
    save(datefile)
end

Ref=Pure.Parameter(2:end,1);
[~, name_record, ~]=cellfun(@fileparts, Ref, 'uni',0);

name_record=cellfun(@(x) x(1:4), name_record,'uni',0);

network_type=unique(name_record);

x=num2cell(1:length(network_type));

[x', network_type]

answer=[];%input('compare which models? Enter Model index. ', 's');

if isempty(answer)
    answer=[1:length(network_type)]';
    else
    answer=str2num(answer);
end

Index=cell(size(Pure.RT,1), length(answer));
for i=1:length(answer)
Index(:,i)=strfind(Pure.Parameter(:,1), cell2mat(network_type(answer(i)))); % extract the networks with the specific architecture
end

fr=cellfun('isempty', Index);
Index(fr)={0};
Index=cell2mat(Index);

[RTCI.Pure, RTCI.Rep, RTCI.Swi]=deal([Pure.RT(1,:), 'PrimeBenefit','MSE_V','MSE_A','ConditionRTCost','CondAccuCost']);
[RT.Pure, RT.Rep, RT.Swi]=deal([Pure.RT(1,:), 'PrimeBenefit','MSE_V','MSE_A','ConditionRTCost','CondAccuCost']);

[Error.Pure, Error.Rep, Error.Swi]=deal(Pure.Error(1,:));
[ErCI.Pure, ErCI.Rep, ErCI.Swi]=deal(Pure.Error(1,:));
p=1;

for k=1:length(answer)
PureRT=cell2mat(Pure.RT(Index(:,k)==1,2:end));
PureRT(:,end+1)=PureRT(:,12)-PureRT(:,11); % Prime Cost
PureRT(:,end+1)=PureRT(:,6)-PureRT(:,5); % MSE_V
PureRT(:,end+1)=PureRT(:,9)-PureRT(:,8); % MSE_A
PureCI=1.96* nanstd(PureRT, 0, 1)/sqrt(size(PureRT,1));


RepRT=cell2mat(Repetition.RT(Index(:,k)==1,2:end));
RepRT(:,end+1)=RepRT(:,12)-RepRT(:,11);
RepRT(:,end+1)=RepRT(:,6)-RepRT(:,5); % MSE_V
RepRT(:,end+1)=RepRT(:,9)-RepRT(:,8); % MSE_A
RepCI=1.96* nanstd(RepRT, 0, 1)/sqrt(size(RepRT,1));


SwiRT=cell2mat(Swi.RT(Index(:,k)==1,2:end));
SwiRT(:,end+1)=SwiRT(:,12)-SwiRT(:,11);
SwiRT(:,end+1)=SwiRT(:,6)-SwiRT(:,5); % MSE_V
SwiRT(:,end+1)=SwiRT(:,9)-SwiRT(:,8); % MSE_A
SwiCI=1.96* nanstd(SwiRT, 0, 1)/sqrt(size(SwiRT,1));

MixCost(:,1)=RepRT(:,1)-PureRT(:,1); MixCost(:,2)=RepRT(:,2)-PureRT(:,2);
MixCostCI=1.96* nanstd(MixCost, 0, 1)/sqrt(size(MixCost,1));
PureRT(:,end+1:end+2)=MixCost;
PureCI(:,end+1:end+2)=MixCostCI;

SwiCost(:,1)=SwiRT(:,1)-RepRT(:,1); SwiCost(:,2)=SwiRT(:,2)-RepRT(:,2);
SwiCostCI=1.96* nanstd(SwiCost, 0, 1)/sqrt(size(SwiCost,1));
RepRT(:,end+1:end+2)=SwiCost;
RepCI(:,end+1:end+2)=SwiCostCI;
SwiRT(:,end+1:end+2)=SwiCost;
SwiCI(:,end+1:end+2)=SwiCostCI;


PureRT=nanmean(PureRT,1);
RepRT=nanmean(RepRT,1);
SwiRT=nanmean(SwiRT,1);

PureError=cell2mat(Pure.Error(Index(:,k)==1,2:end));
PureErCI=1.96* nanstd(PureError, 0, 1)/sqrt(size(PureError,1));
PureError=nanmean(PureError,1);
RepError=cell2mat(Repetition.Error(Index(:,k)==1,2:end));
RepErCI=1.96* nanstd(RepError, 0, 1)/sqrt(size(RepError,1));
RepError=nanmean(RepError,1);
SwiError=cell2mat(Swi.Error(Index(:,k)==1,2:end));
SwiErCI=1.96* nanstd(SwiError, 0, 1)/sqrt(size(SwiError,1));
SwiError=nanmean(SwiError,1);


RT.Pure(k+1,:)=[network_type(k),num2cell(PureRT)];
RT.Rep(k+1,:)=[network_type(k),num2cell(RepRT)];
RT.Swi(k+1,:)=[network_type(k),num2cell(SwiRT)];

RTCI.Pure(k+1,:)=[network_type(k),num2cell(PureCI)];
RTCI.Rep(k+1,:)=[network_type(k),num2cell(RepCI)];
RTCI.Swi(k+1,:)=[network_type(k),num2cell(SwiCI)];

ErCI.Pure(k+1,:)=[network_type(k),num2cell(PureErCI)];
ErCI.Rep(k+1,:)=[network_type(k),num2cell(RepErCI)];
ErCI.Swi(k+1,:)=[network_type(k),num2cell(SwiErCI)];

Error.Pure(k+1,:)=[network_type(k),num2cell(PureError)];
Error.Rep(k+1,:)=[network_type(k),num2cell(RepError)];
Error.Swi(k+1,:)=[network_type(k),num2cell(SwiError)];

PureRT=[];RepRT=[];SwiRT=[]; MixCost=[]; SwiCost=[];


end

% meanRT=cellfun(@nanmean, Data, 'uni',0);
% meanRTCI=cellfun(@(x) std(x)/sqrt(size(x,1)), Data, 'uni',0);
% meanError=cellfun(@nanmean, Error, 'uni',0);
% meanErrorCI=cellfun(@(x) std(x)/sqrt(size(x,1)), Error, 'uni',0);
% 
% RTtitle=Pure.RT(1,2:end);
% Errtitle=Pure.Error(1,2:end);
% Block={'Pure'; 'Repetition'; 'Switch'};




save(datefile, 'RT','Error', 'RTCI', 'ErCI', 'whichdatefile');



% k=length(answer);
% 
% 
% table(Pure.RT(1,2:end)',meanRT{1}(:),meanRT{2}(:))
% 
% 
% clearvars 'Pure''Repetition' 'Swi'
