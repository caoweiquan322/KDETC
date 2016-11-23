% Load stk variable.
% stk = load('starkey.mat');

% Plot specified year and month.
month_fix = 7;
days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
for year=1995%1993:1996
    for month = month_fix:month_fix%4:8
        day = days(month);
        [id, t, label, x, y] = filter_starkey_by_month(stk.id, stk.t,...
            stk.label, stk.x, stk.y, year, month, day);
        
        close all;
        figure; hold on;
        trajs = organize_starkey(id, t, label, x, y);
        for i=1:size(trajs, 1)
            data = trajs{i, 3};
            if strcmp('"C"', trajs{i, 2})
                plot(data(:,1), data(:,2), 'r-+');
            elseif strcmp('"D"', trajs{i, 2})
                plot(data(:,1), data(:,2), 'g-s');
            elseif strcmp('"E"', trajs{i, 2})
                plot(data(:,1), data(:,2), 'b-*');
            else
                fprintf('Unrecognized label type: %s\n', trajs{i, 2});
            end
            %pause;
        end
%         cidx=strcmp('"C"',label);plot(x(cidx),y(cidx),'r.');
%         hold on;
%         cidx=strcmp('"D"',label);plot(x(cidx),y(cidx),'g.');
%         cidx=strcmp('"E"',label);plot(x(cidx),y(cidx),'b.');
%         title(sprintf('%d/%d/%d', year, month, day));
%         legend('Cattle', 'Deer', 'Elk');
%         hold off;
%         pause;
    end
end
