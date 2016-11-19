function [xin, yin, tin] = read_clean_geo_label_data(file_path, max_interval, min_length)

%% Load data.
[lat, lon, tin] = read_geo_label_data(file_path);

%% Maximum continuous sub-sequence.
start_end = max_continuous_sub(tin, max_interval);
if diff(start_end)+1 < min_length % Needs no more processing.
    xin = []; yin = []; tin = []; return;
end

%% Mercator projection.
left = start_end(1);
right = start_end(2);
[xin, yin, ~] = mercator_proj(lat(left:right), lon(left:right));
tin = tin(left:right);

end