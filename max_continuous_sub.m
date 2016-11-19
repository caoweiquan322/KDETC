function [start_end] = max_continuous_sub(tin, max_interval)

dt = diff(tin);
n = length(tin);
exceeds = find(dt>max_interval);
if size(tin,1) == 1
    exceeds = [0, exceeds, n];
else
    exceeds = [0; exceeds; n];
end
[~, idx] = max(diff(exceeds));
start_end = [exceeds(idx)+1, exceeds(idx+1)];

end