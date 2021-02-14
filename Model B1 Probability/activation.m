function [ new_activation ] = activation ( old_act, eta, noise_sd, minact, maxact )
% Calculate the new activation
%   
new_activation= old_act + eta + random('norm', 0.0, noise_sd);

if new_activation> maxact
    new_activation= maxact;
elseif new_activation < minact
    new_activation= minact;
end

end

