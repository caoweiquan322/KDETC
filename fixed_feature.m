function [f] = fixed_feature(xin, yin, tin, fix_size)

%% Check parameter validation.
if length(xin) ~= fix_size, f = []; return; end

%% Extract statistic features.
dx = diff(xin);
dy = diff(yin);
dt = diff(tin);
index = dt>0.5 & dt<5;
if sum(index)<20
    f = [];
    return;
end
dx = dx(index);
dy = dy(index);
dt = dt(index);
theta = atan2(dy, dx);
dtheta = diff(theta);
dtheta(dtheta>=pi)=dtheta(dtheta>=pi)-2*pi;
dtheta(dtheta<=-pi)=dtheta(dtheta<=-pi)+2*pi;
rho = sqrt(dx.*dx+dy.*dy);
vel = rho./dt;
vel = medfilt1(vel, 5);
acc = diff(vel)./((dt(1:end-1)+dt(2:end))/2);

total_distance = sum(rho);
sr = sum(vel<3.4)/total_distance;
vcr = sum(abs(diff(vel))./vel(1:end-1)>0.26)/total_distance;
hcr = sum(abs(dtheta)>19/180.0*pi)/total_distance;

stable_vel = sort(vel);
num_avoid = round(length(stable_vel)*0.1);
stable_vel = stable_vel(num_avoid:end-num_avoid);
stable_acc = sort(abs(acc));
num_avoid = round(length(stable_acc)*0.1);
stable_acc = stable_acc(num_avoid:end-num_avoid);

%% Organize the features.
f = [mean(stable_vel), std(stable_vel), stable_vel(end),...
    mean(stable_acc), std(stable_acc), stable_acc(end),...
    sr, vcr, hcr];

end