function [id, t, label, x, y] = filter_AIS_by_month(id, t, label, x, y, year, month, day)

%time_base = datenum(1987,12,31,0,0,0);
time_start = datenum(year,month,1,0,0,0);%(datenum(year,month,1,0,0,0)-time_base)*24*3600;
time_end = datenum(year,month,day,23,59,59);%(datenum(year,month,day,23,59,59)-time_base)*24*3600;
filter_idx = t>=time_start & t<=time_end;
id = id(filter_idx,:);
t = t(filter_idx,:);
label = label(filter_idx,:);
x = x(filter_idx,:);
y = y(filter_idx,:);

end