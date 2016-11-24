function [ sub_features ] = slide_features( xin, yin, tin, win, shift )

%% Parameter validation.
if length(xin) < win, sub_features = []; return; end

%% Extract features by sliding window.
n = length(xin);
rows = floor((n-win+shift)/shift);
sub_features = zeros(rows, 9);
count = 0;
for i=1:shift:(n-win)
    f = fixed_feature(xin(i:i+win-1), yin(i:i+win-1), tin(i:i+win-1), win);
    if isempty(f), continue; end
    count = count+1;
    sub_features(count, :) = f;
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

