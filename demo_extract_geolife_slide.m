
%% Settings.
MAX_INTERVAL = 10.0;
MIN_LENGTH = 1000;
WND = round(MIN_LENGTH/2);
SHIFT = round(WND/2);

folder = '/Users/fatty/Code/GeoLife1.3/labeled';
feature_file = '/Users/fatty/Code/GeoLife1.3/features/matlab_accurate.csv';
fclose(fopen(feature_file, 'w'));
modes = {'walk', 'bike', 'car', 'taxi', 'bus'};
styles = {'r.', 'gx', 'bs', 'co', 'm+'};

%% Process all trajectory files one by one.
num_classes = length(modes);
trajs = cell(15000, 3);
num_instances = 0;
for i=1:num_classes
    fprintf('Processing mode: %s\n', modes{i});
    files = dir([folder '/' modes{i} '_*.txt']);
    feature = zeros(length(files)*20, 9);
    count = 0;
    for j=1:length(files)
        file_path = [folder '/' files(j).name];
        [xin,yin,tin]=read_clean_geo_label_data(file_path, MAX_INTERVAL, MIN_LENGTH);
        if isempty(xin), continue; end % Data that is too short.
        fprintf('\tProcessing file: %s, (%d/%d)\n', file_path, j, length(files));
        
        % Extract features.
        sub_features = slide_features(xin, yin, tin, WND, SHIFT);
        rows = size(sub_features, 1);
        if isempty(sub_features), continue; end
        
        % Update the total feature.
        feature(count+1:count+rows, :) = sub_features;
        count = count+rows;
        num_instances = num_instances + 1;
        trajs{num_instances, 1} = 1; % For compatibility only.
        trajs{num_instances, 2} = i;
        trajs{num_instances, 3} = sub_features;
    end
    feature = feature(1:count, :);
end
trajs = trajs(1:num_instances, :);

