function [ e ] = eta( net, act, step, minact, maxact )
% Calculate eta from the current input and the previous activation

if (net > 0)
    e = step * net * (maxact - act);
elseif (net < 0)
    e = step * net * (act - minact);
else 
    e = 0.0;
end

end

