function [ sub_features ] = slide_features( xin, yin, tin, win, shift )

%% Parameter validation.
if length(xin) < win, sub_features = []; return; end

%% Extract features by sliding window.
n = length(xin);
rows = floor((n-win+shift)/shift);
sub_features = zeros(rows, 9);
count = 1;
for i=1:shift:n
    f = fixed_feature(xin, yin, tin, win);
    if isempty(f), continue; end
    sub_features(count, :) = f;
    count = count+1;
end

%% Check if the number of sub-features is valid.
if count > rows
    fprintf('Expect count being less than or equal to rows. But got %d-%d.\n', count, rows);
elseif count < rows
    sub_features = sub_features(1:count, :);
end

%% Plot the velocity.
% pltX = cumsum(dt);
% pltY = vel*3.6;
% pltLen = min(length(pltX), 300);
% plot(pltX(1:pltLen), pltY(1:pltLen));
% ylim([0, 60]);
% xlim([0, 400]);
% % title(file_path);
% pause;

end

