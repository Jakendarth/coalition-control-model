%objective function for mpc algorithm

function f = myfun(V_vir,L,v)
% f: a const, all current coalition fish for N times
f=0;

global A;
global Beta;
global N;
global B_total;
global u_ot;
global x0;
global num_u;
global Num_region
global num_ot

x = x0;
Sum = ones(1,Num_region);% Num_region is the number of region
% ��myfun�����Ĺ�ʽ������V_virΪNULLʱ���ã���û�н��кϲ�����
if isempty(V_vir)
    for t = 1:N
    f = -Sum*((B_total*[v(t*num_u-num_u+1:t*num_u,:);u_ot(t*num_ot-num_ot+1:t*num_ot,:)]).*x)+f;
    x = A*x+Beta-(B_total*[v(t*num_u-num_u+1:t*num_u,:);u_ot(t*num_ot-num_ot+1:t*num_ot,:)]).*x;
    end
else
   % ��myfun�����Ĺ�ʽ���������V_virʱ���ã��������˺ϲ�����
   m = 0.001; % miuֵ
   z = unique(L);    
   for t = 1:length(z)
       LIE = find(L==z(t));
       vir_TEMP = [];
       for f = 1:size(LIE)
           h = LIE(f);
           vir_TEMP = [vir_TEMP;V_vir(h*Num_region-Num_region+1:h*Num_region,1)];
       end
       V_vir_NEW = repmat(vir_TEMP,15,1);
       f = -Sum*((B_total*[v(t*num_u-num_u+1:t*num_u,:);u_ot(t*num_ot-num_ot+1:t*num_ot,:)]).*x)+m*sum((v(t*num_u-num_u+1:t*num_u,:)-V_vir_NEW(t*num_u-num_u+1:t*num_u,:)).^2)+f;
       %         f = -Sum*((B_total*[v(t*num_u-num_u+1:t*num_u,:);u_ot(t*num_ot-num_ot+1:t*num_ot,:)]).*x)+f;
       x = A*x+Beta-(B_total*[v(t*num_u-num_u+1:t*num_u,:);u_ot(t*num_ot-num_ot+1:t*num_ot,:)]).*x;
   end
end
end

