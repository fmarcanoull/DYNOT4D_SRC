function output_txt = DYNOT4D_funcionDataTip(obj,event_obj)
% Display data cursor position in a data tip
% obj          Currently not used
% event_obj    Handle to event object
% output_txt   Data tip text, returned as a character vector or a cell array of character vectors

pos = event_obj.Position;

s = std(event_obj.Target.YData);
if (s ~= 0 )
    snr = mean(event_obj.Target.YData)/s;
else
    snr = 0;
end

%********* Define the content of the data tip here *********%

% Display the x and y values:
output_txt = {['X',formatValue(pos(1),event_obj)],...
    ['Y',formatValue(pos(2),event_obj)]};
%***********************************************************%


% If there is a z value, display it:
if length(pos) > 2
    output_txt{end+1} = ['Z',formatValue(pos(3),event_obj)];
end

output_txt{end+1} = ['SNR',formatValue(snr,event_obj)];


%***********************************************************%

function formattedValue = formatValue(value,event_obj)
% If you do not want TeX formatting in the data tip, uncomment the line below.
% event_obj.Interpreter = 'none';
if strcmpi(event_obj.Interpreter,'tex')
    valueFormat = ' \color[rgb]{0 0.6 1}\bf';
    removeValueFormat = '\color[rgb]{.25 .25 .25}\rm';
else
    valueFormat = ': ';
    removeValueFormat = '';
end
formattedValue = [valueFormat num2str(value,4) removeValueFormat];
