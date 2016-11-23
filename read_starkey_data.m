function [id, t, label, x, y] = read_starkey_data(fname)

% Data parsing.
[~,~,~,id,t,~,~,~,~,~,label,x,y,~,~,~,~] = textread(fname,...
    '%s%s%s%s%f%s%s%s%s%s%s%f%f%s%s%s%s',...
    'delimiter', ',', 'headerlines', 1);


end