
%% Settings.
MAX_INTERVAL = 10.0;
MIN_LENGTH = 100;
WND = round(MIN_LENGTH/2);
SHIFT = round(WND/2);

folder = '/Users/fatty/Code/GeoLife1.3/labeled';
feature_file = '/Users/fatty/Code/GeoLife1.3/features/matlab_accurate.csv';
fclose(fopen(feature_file, 'w'));
modes = {'walk', 'bike', 'car', 'taxi', 'bus'};
styles = {'r.', 'gx', 'bs', 'co', 'm+'};

%% Process all trajectory files one by one.
gm_models = cell(size(modes));
for i=1:length(modes)
    fprintf('Processing mode: %s\n', modes{i});
    files = dir([folder '/' modes{i} '_*.txt']);
    feature = zeros(length(files)*10, 9);
    count = 1;
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
        feature(count:count+rows-1, :) = sub_features;
        count = count+rows;
    end
    feature = feature(1:count, :);
    gm = fitgmdist(feature, min(count/20, 20));
    gm_models{i} = gm;
end

