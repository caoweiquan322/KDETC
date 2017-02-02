function demo_cv(stk)
    % Load stk variable outside the function call.
    % stk = load('starkey.mat');

    % Set the specified year and month.
    month_fix = 7;
    days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    num_folds = 5;
    num_repeat = 50;
    
    train_method = @kde_train;
    test_method = @kde_test;

    % The main procedure.
    for year=1995
        for month = month_fix
            % Filter out the specified time range.
            day = days(month);
            [id, t, label, x, y] = filter_starkey_by_month(stk.id, stk.t,...
                stk.label, stk.x, stk.y, year, month, day);

            % Re-organize the data as trajectories.
            trajs = organize_starkey(id, t, label, x, y);
            num_trajs = size(trajs, 1);
            Y = zeros(num_trajs, 1);
            for i=1:num_trajs
                if strcmp('"C"', trajs{i, 2})
                    Y(i) = 1;
                elseif strcmp('"D"', trajs{i, 2})
                    Y(i) = 2;
                elseif strcmp('"E"', trajs{i, 2})
                    Y(i) = 3;
                else
                    fprintf('Unrecognized label type: %s\n', trajs{i, 2});
                end
            end
            
            performance = zeros(num_repeat, 3);
            for n=1:num_repeat
                % Partition into train/test sub-set.
                total_idx = randperm(num_trajs);
                num_train = round(num_trajs*(num_folds-1)/num_folds);
                train_idx = total_idx(1:num_train);
                test_idx = total_idx(num_train+1:end);

                % Training.
                tic;
                %model = mdl_rect_train(trajs(train_idx', :), Y(train_idx'), 3);
                model = train_method(trajs(train_idx', :), Y(train_idx'), 3);
                train_time = toc;
                % Testing
                tic;
                %correct_rate = mdl_rect_test(model, trajs(test_idx', :), Y(test_idx'), 3);
                correct_rate = test_method(model, trajs(test_idx', :), Y(test_idx'), 3);
                test_time = toc;
                % Collect the results.
                performance(n, :) = [train_time, test_time, correct_rate];
            end
            % Display the results.
            avg_performance = mean(performance, 1);
            fprintf('Average training time is %.2f seconds. Testing time is %.2f seconds.\n',...
                avg_performance(1), avg_performance(2));
            fprintf('Average correct rate is %.2f%%.\n', avg_performance(3)*100);
            fprintf('Standard variance of correct rate is %.2f.\n', std(performance(:, 3)));
        end
    end

end

function [model] = kde_train(trajs, y, num_classes)

    % Collect the raw points categoried by class labels.
    data = collect_xy(trajs, y, num_classes);

    % Prepare parameters for density estimation.
    N = 256; % The number of grids in x/y for density estimation.
    % Estimate the boundary.
    sub_min = zeros(num_classes, 2);
    sub_max = zeros(num_classes, 2);
    for k=1:num_classes
        sub_min(k, :) = min(data{k}, [], 1);
        sub_max(k, :) = max(data{k}, [], 1);
    end
    MAX=max(sub_max,[],1); MIN=min(sub_min,[],1); Range=MAX-MIN;
    MAX_XY=MAX+Range/8; MIN_XY=MIN-Range/8;

    % Estimate density distribution.
    densities = cell(num_classes, 1);
    for k=1:num_classes
        [~, densities{k}, ~, ~] = kde2d(data{k}, N, MIN_XY, MAX_XY);
    end

    % Visualize the densities.
    visualize = false;
    if visualize
        styles = {'+r', '+g', '+k'};
        figure;
        for k=1:num_classes
            contour3(X, Y, densities{k}, 10, styles{k});
            hold on;
        end
        legend('Cattle', 'Deer', 'Elk');
    end

    % Package the output parameters.
    model = {};
    model.N = N;
    model.MIN_XY = MIN_XY;
    model.MAX_XY = MAX_XY;
    model.Range = Range;
    model.STP = (MAX_XY-MIN_XY)/(N-1);
    model.densities = densities;

end

function [correct_rate] = kde_test(model, trajs, y, num_classes)

    % Unpackage the model.
    MIN_XY = model.MIN_XY;
    STP = model.STP;
    densities = model.densities;
    N = model.N;

    % Do predicting.
    num_trajs = size(trajs, 1);
    pred_Y = zeros(num_trajs, 1);
    for i=1:num_trajs
        data = trajs{i, 3};
        acc = zeros(num_classes, 1);
        for k=1:num_classes
            for m=1:size(data, 1)
                IDX_XY = round((data(m, 1:2) - MIN_XY)./STP)+1;
                IDX_XY = min(max(IDX_XY, 1), N);
                acc(k) = acc(k) + log(densities{k}(IDX_XY(2), IDX_XY(1))+1);
            end
        end
        [~, pred_Y(i)] = max(acc);
    end

    % Calculate the performance.
    correct_rate = sum(abs(y-pred_Y)<0.5)/num_trajs;

end

function [model] = mdl_rect_train(trajs, y, num_classes)
    % Parameters.
    finest_grid_size = 1000;
    min_num = 60;
    
    % Extract mdl rectangles.
    data = collect_xy(trajs, y, num_classes);
    rects = mdl_rectangles(data, finest_grid_size, min_num);
    num_rects = size(rects, 1);
    
    % Visualize.
    if false
        figure;
        hold on;
        styles = {'r+', 'go', 'kx'};
        for k=1:num_classes
            sub_data = data{k};
            plot(sub_data(:, 1), sub_data(:, 2), styles{k});
        end
        for i=1:size(rects,1)
            plot([rects(i,1) rects(i,2) rects(i,2) rects(i,1) rects(i,1)],...
                [rects(i,3) rects(i,3) rects(i,4) rects(i,4) rects(i,3)],...
                [styles{rects(i,5)}(1), '-']);
        end
    end
    
    % Convert the trajs into region based statistics.
    num_trajs = size(trajs, 1);
    X = zeros(num_trajs, num_rects);
    for i=1:num_trajs
            X(i, :) = traj_to_region(trajs{i, 3}, rects);
    end
    
    % Training.
    classifier = fitcecoc(X, y);
    
    % Package parameters.
    model = {};
    model.rects = rects;
    model.classifier = classifier;

end

function [correct_rate] = mdl_rect_test(model, trajs, y, num_classes)

    % Convert to features.
    num_trajs = size(trajs, 1);
    num_rects = size(model.rects, 1);
    X = zeros(num_trajs, num_rects);
    for i=1:num_trajs
            X(i, :) = traj_to_region(trajs{i, 3}, model.rects);
    end
    
    % Predict and calculate the statistics.
    pred_Y = predict(model.classifier, X);
    correct_rate = sum(abs(y-pred_Y)<0.5)/num_trajs;

end

function [data] = collect_xy(trajs, y, num_classes)

    data = cell(num_classes, 1);
    for k=1:num_classes
        data{k} = cell2mat(trajs(y==k, 3));
        data{k} = data{k}(:, 1:2);
    end

end

