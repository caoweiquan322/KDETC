function [id, t, label, x, y] = read_AIS_data(fname)

% Data parsing.
[id,x,y,t_str,label] = textread(fname,...
    '%s%f%f%s%s',...
    'delimiter', ',', 'headerlines', 0);

format = 'yyyy-mm-dd hh:MM:ss';
t = datenum(t_str, format);
% N = size(t_str, 1);
% t = zeros(N, 1);
% for i=1:N
%     t(i) = datenum(t_str{i}, format);
% end


end