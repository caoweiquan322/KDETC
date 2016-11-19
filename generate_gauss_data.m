function data = generate_gauss_data(num_centroids, d, miu_range,...
    sigma_range, size_range)

%% Specify sub-clusters parameters.
miu = miu_range(1)+diff(miu_range).*rand(num_centroids, d);
sigma = sigma_range(1)+diff(sigma_range).*rand(num_centroids, d);
csize = size_range(1)-1+randi(diff(size_range)+1, num_centroids, 1);

%% Generate data.
data = zeros(sum(csize), d);
count = 0;
for i=1:num_centroids
    for j=1:d
        data(count+1:count+csize(i), j) = normrnd(miu(i, j), sigma(i, j),...
            csize(i), 1);
    end
    count = count + csize(i);
end

end