function n = Rk_xy(integrations, k, x1, x2, y1, y2)

itg = integrations{k};
x2 = x2+1;
y2 = y2+1;
n = itg(y1, x1)+itg(y2,x2)-itg(y1,x2)-itg(y2,x1);

end