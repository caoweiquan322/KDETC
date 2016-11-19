function [entropy, N_sum] = C_xy(integrations, x1, x2, y1, y2)

num_classes = length(integrations);
N = zeros(num_classes, 1);
for k=1:num_classes
   N(k) = Rk_xy(integrations, k, x1, x2, y1, y2);
end
N = N(N>0.5);
if isempty(N)
    entropy = 0;
    N_sum = 0;
else
    N_sum = sum(N);
    entropy = -sum(N.*log2(N/N_sum));
end

end