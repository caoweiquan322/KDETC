
% 使用高斯分布（正态分布）
% 随机生成3个中心以及标准差
s = rng(5,'v5normal');
mu = round((rand(3,2)-0.5)*19)+1;
sigma = round(rand(3,2)*40)/10+1;
X = [mvnrnd(mu(1,:),sigma(1,:),200); ...
     mvnrnd(mu(2,:),sigma(2,:),300); ...
     mvnrnd(mu(3,:),sigma(3,:),400)];

% 等高线
options = statset('Display','off');
gm = fitgmdist(X,3,'Options',options);
P6 = figure;clf
scatter(X(:,1),X(:,2),10,'ro');
hold on
ezcontour(@(x,y) pdf(gm,[x,y]),[-15 15],[-15 10]);
hold off
P7 = figure;clf
scatter(X(:,1),X(:,2),10,'ro');
hold on
ezsurf(@(x,y) pdf(gm,[x,y]),[-15 15],[-15 10]);
hold off
view(33,24)


