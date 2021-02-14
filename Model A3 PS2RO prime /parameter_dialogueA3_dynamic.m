function [zparameter, PureAnswer, MixedAnswer]=parameter_dialogueA3_dynamic(filename)
% THIS FUNCTION ACTIVATES THE INPUT DIALOGUE FOR PARAMETER SETTING WITH THE
% PRESET NUMBER OF NETWORK PARAMETER SETTINGS. EACH NETWORK SETTING APPLIES
% TO ONE PURE AND ONE MIXED CONDITION.
% ENTER THE FILENAME FOR SO THE SIMULATION SETTING WOULD BE APPLIED TO THE
% SPECIFIED FILENAME
% ZPARAMETER RETURNS A N BY 3 CELL ARRAY OF THE PROMPT

prompt = {
    'preparation','vpreparation',''
    'timeout','timeout',''
    'PSV2RO','vPSvis_RO',''
    'PSA2RO','vPSaud_RO',''
    'TA2Yes','vTA_Yes',''
    'TA2No','vTA_No',''
    'between li','vli_weight',''
    'within li','vliNo2Yes_weight',''
    'Top down','vtop_input',''
    'prime rate','vpriming',''
    'update rate','vStep',''
    'response threshold','vResponse_Threshold',''
    'squash','vrho',''
    'noise','vnoise_sd',''
    'max act','vmaxact',''
    'min act','vminact',''
    'min PS act','vminPSact',''
    'PS2TAweight','PS2TAweight',''
    'TA2PSweight','TA2PSweight',''
    'stimulus input','vstimulus_input',''
    'lateral activity from inhibited nodes','vlateral_in',''
    'bias','voutput_bias',''
    };

Formats(1,1).required = 'on';  % 'vpreparation','preparation',''
Formats(1,2).required = 'on'; % 'timeout','timeout',''
Formats(2,1).required = 'on'; %  'vPSvis_RO','PSV2RO',''
Formats(2,2).required = 'on'; % 'vPSaud_RO','PSA2RO',''
Formats(3,1).required = 'on';  % 'TA2Yes','vTA_Yes',''
Formats(3,2).required = 'on'; % 'TA2No','vTA_No',''
Formats(4,1).required = 'on'; % 'between_li','vli_weight',''
Formats(4,2).required = 'on';  % 'within_li','vliNo2Yes_weight',''
Formats(5,1).required = 'on'; % 'Top_down','vtop_input',''
% Formats(5,1).span = [1 2];
Formats(6,1).required = 'on'; % 'prime_rate','vpriming',''
Formats(6,2).required = 'on';  % 'update_rate','vStep',''
Formats(7,1).required = 'on'; % 'response_threshold','vResponse_Threshold',''
Formats(7,2).required = 'on'; % 'squash','vrho',''
Formats(8,1).required = 'on';  % 'noise','vnoise_sd',''
Formats(8,1).span = [1 2];
Formats(9,1).required = 'on'; %'max act','vmaxact',''
Formats(9,2).required = 'on'; % 'min act','vminact',''
Formats(10,1).required = 'on'; % 'min PS node act','vminPSact',''
Formats(11,1).required = 'on';  % 'PS2TAweight','PS2TAweight',''
Formats(11,2).required = 'on'; % 'TA2PSweight','TA2PSweight',''
Formats(12,1).required = 'on'; % 'vstimulus'
Formats(12,2).required = 'on'; % 'lateral activity'
Formats(13,1).required = 'on'; % 'output bias'
% Formats(13,1).span = [1 2];
% defaultans={'1','2','3';'4','5','6';'7','8','9';'10','11','12';'13','14','15';'16','17','18'}'

mixed_title = sprintf('Mixed Condition %s',cell2mat(filename(end)));

mixed_defaultans = {'150','700';'2.5','2';'2.5','1.3';'1','1.3';'6','1';'0.0015','0.2';'0.7','0.006';'1','-1';'0','1';'0.3','1';'1','-3'}';

% pure_defaultans = {'150','700';'2.5','2';'2.7','1.6';'1','1.5';'6','1';'0.0015','0.15';'1','0.002';'1','-1';'0','1';'0.3','0.7'}';
pure_defaultans = {'150','700';'2.5','2';'2.5','1.3';'1','1.3';'6','1';'0.0015','0.2';'0.9','0.006';'1','-1';'0','1';'0.3','1';'1','-3'}';

Options.AlignControls = 'on';
[MixedAnswer,Cancelled] = inputsdlg(prompt,mixed_title,Formats,mixed_defaultans,Options);

pure_title=sprintf('PURE , PSV2R%s;PSA2R%s;TA2Yes%s;TA2No;%s;bt%s;within%s;threshold%s', MixedAnswer.vPSvis_RO,...
MixedAnswer.vPSaud_RO, MixedAnswer.vTA_Yes, MixedAnswer.vTA_No, MixedAnswer.vli_weight, MixedAnswer.vliNo2Yes_weight,...
MixedAnswer.vResponse_Threshold);

[PureAnswer,Cancelled] = inputsdlg(prompt,pure_title,Formats,pure_defaultans,Options);

zparameter=prompt(:,2)'; % parameter names
zparameter=['condtion',zparameter];
end


