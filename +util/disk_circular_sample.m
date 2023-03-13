function pts = disk_circular_sample(center, r, k)
dr = r / k;
alpha = 1;
num = k^2 * alpha - alpha + 1;
pts = zeros(num, 2);

q_store = zeros(num, 1);
ind = 1;
for i = 2:k
    tmp_n = (2*i - 1) * alpha;
    tmp_r = (i - 0.5) * dr;
    dq = 2*pi/tmp_n;
    tmp_q = 0:dq:2*pi;
    tmp_q = tmp_q(1:tmp_n);
    
    tmp_q_store = q_store(1:ind);
    diff_q = diff(sort(tmp_q_store));
    [max_diff_q, qi] = max(diff_q);
    
    if ~isempty(qi)
        tmp_q = mod(tmp_q + tmp_q_store(qi) + max_diff_q / 2, 2*pi);
    end
    q_store(ind+(1:tmp_n)) = tmp_q;
    
    pts(ind+(1:tmp_n), :) = [cos(tmp_q(:)), sin(tmp_q(:))] * tmp_r;
    ind = ind + tmp_n;
end

pts = bsxfun(@plus, pts, center(:)');
end