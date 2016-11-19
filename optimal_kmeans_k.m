function optimal_k = optimal_kmeans_k(data, k_range)

range = k_range(1):k_range(end);
performance = zeros(length(range), 1);
for k=1:length(range)
    try
        c = kmeans(data, range(k));
        s = silhouette(data, c);
        performance(k) = sum(s);
    catch
        performance(k) = 0;
    end
end

[~, idx] = max(performance);
optimal_k = range(idx);

end