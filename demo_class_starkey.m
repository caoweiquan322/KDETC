% Load stk variable.
% stk = load('starkey.mat');

% Plot specified year and month.
month_fix = 7;
days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
for year=1996%1993:1996
    for month = month_fix:month_fix%4:8
        day = days(month);
        [id, t, label, x, y] = filter_starkey_by_month(stk.id, stk.t,...
            stk.label, stk.x, stk.y, year, month, day);
        
        % Prepare the training data.
        num_classes = 3;
        styles = {'r.', 'g.', 'k.'};
        d = 2;
        finest_grid_size = 1000;
        data = cell(num_classes, 1);
        num_instances = 0;
        known_labels = {'"C"', '"D"', '"E"'};
        for k=1:num_classes
            sub_idx = strcmp(known_labels{k}, label);
            data{k} = [x(sub_idx), y(sub_idx)];
            num_instances = num_instances + size(data{k}, 1);
        end
        
        % Get the optimal partitions.
        rects = mdl_rectangles(data, finest_grid_size, 60);
        
        % Plot the clustering results.
        figure;
        hold on;
        for k=1:num_classes
            sub_data = data{k};
            plot(sub_data(:, 1), sub_data(:, 2), styles{k});
        end
        for i=1:size(rects,1)
            plot([rects(i,1) rects(i,2) rects(i,2) rects(i,1) rects(i,1)],...
                [rects(i,3) rects(i,3) rects(i,4) rects(i,4) rects(i,3)],...
                [styles{rects(i,5)}(1), '-']);
        end
        
        % Convert trajectories to statistics features.
        trajs = organize_starkey(id, t, label, x, y);
%         trajs = trajs(strcmp('"E"', trajs(:, 2)) | strcmp('"C"', trajs(:,2)), :);
        num_trajs = size(trajs, 1);
        num_rects = size(rects, 1);
        X = zeros(num_trajs, num_rects);
        Y = zeros(num_trajs, 1);
        for i=1:num_trajs
            data = trajs{i, 3};
            if strcmp('"C"', trajs{i, 2})
                Y(i) = 1;
            elseif strcmp('"D"', trajs{i, 2})
                Y(i) = 2;
            elseif strcmp('"E"', trajs{i, 2})
                Y(i) = 3;
            else
                fprintf('Unrecognized label type: %s\n', trajs{i, 2});
            end
            X(i, :) = traj_to_region(data, rects);
        end
        
        % Cross validation.
        % Randomly partitions observations into a training set and a test
        % set using stratified holdout
%         P = cvpartition(Y,'Holdout',0.20);
%         % Use a linear support vector machine classifier
%         svmStruct = svmtrain(X(P.training,:),Y(P.training),'showplot',true);
%         C = svmclassify(svmStruct,X(P.test,:),'showplot',true);
%         errRate = sum(Y(P.test)~= C)/P.TestSize  %mis-classification rate
%         conMat = confusionmat(Y(P.test),C) % the confusion matrix
        
        % Cross validation by using multi-class classification.
        tmp_svm = templateSVM('Standardize',1);
        mdl = fitcecoc(X,Y,'Learners',tmp_svm);
        cv_mdl = crossval(mdl);
        oos_loss = kfoldLoss(cv_mdl);
        fprintf('The 10-fold cross validation error rate is %.3f\n', oos_loss);
    end
end
