function [pure_data, labels] = reorganize_data(data)

%% Ge number of instances.
num_classes = length(data);
d = size(data{1}, 2);
num_instances = 0;
for k=1:num_classes
    num_instances = num_instances + size(data{k}, 1);
end

%% Re-organize data.
pure_data = zeros(num_instances, d);
labels = zeros(num_instances, 1);
count = 0;
for k=1:num_classes
    sub_data = data{k};
    rows = size(sub_data, 1);
    pure_data(count+1:count+rows, :) = sub_data;
    labels(count+1:count+rows) = k*ones(rows, 1);
    count = count+rows;
end

end