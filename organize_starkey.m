function trajs = organize_starkey(id, t, label, x, y)

% Sort data.
[id, idx] = sort(id);
xyt = [x(idx) y(idx) t(idx)];
label = label(idx);

% Extract single trajectory one by one.
seq = 1:(length(id)-1);
diff_idx = [0 seq(strcmp(id(1:end-1), id(2:end))==0) length(id)];
nt = length(diff_idx)-1;
all_size = zeros(nt, 1); % For validation.
trajs = cell(nt, 3);
for i=1:nt
    sub_idx = (diff_idx(i)+1):(diff_idx(i+1));
    trajs{i, 3} = sortrows(xyt(sub_idx',:), 3);
    trajs{i, 2} = label{sub_idx(1)};
    trajs{i, 1} = id{sub_idx(1)};
    all_size(i) = length(sub_idx);
end
if sum(all_size) ~= length(label),
    fprintf('Error: expect size of all sub-trajectories equals to #points.\n');
end

end