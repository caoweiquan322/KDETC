function integration = calculate_integration_hist(data2d, x_range, y_range, num_grids)

bw_x = diff(x_range)/num_grids;
bw_y = diff(y_range)/num_grids;
% We reserver a zero column/row at the left/top border for easy calculation of Rk(i,j)
hist_k = zeros(num_grids+1, num_grids+1);
sub_size = size(data2d, 1);
x_idx = min(max(ceil((data2d(:,1)-x_range(1))/bw_x), 1), num_grids)+1;
y_idx = min(max(ceil((data2d(:,1)-y_range(1))/bw_y), 1), num_grids)+1;
for i=1:sub_size
    hist_k(y_idx(i), x_idx(i)) = hist_k(y_idx(i), x_idx(i))+1;
end
integration = cumsum(cumsum(hist_k, 1), 2);

end