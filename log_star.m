function l = log_star(n)

l = log2(2.865);
while n>1
    n = log2(n);
    l = l + n;
end

end