function [able, new_rect] = rect_could_merge(rc1, rc2)

new_rect = [];
able = false;
if rc1(5) ~= rc2(5)
    return;
end

if rc1(1) == rc2(1) && rc1(2) == rc2(2)
    if rc1(3) == rc2(4)+1 || rc2(3) == rc1(4)+1
        able = true;
        new_rect = [rc1(1), rc1(2), min(rc1(3),rc2(3)), max(rc1(4),rc2(4)), rc1(5)];
        return;
    end
end

if rc1(3) == rc2(3) && rc1(4) == rc2(4)
    if rc1(1) == rc2(2)+1 || rc2(1) == rc1(2)+1
        able = true;
        new_rect = [min(rc1(1),rc2(1)), max(rc1(2),rc2(2)), rc1(3), rc1(4), rc1(5)];
        return;
    end
end

end