clc;
clear;
%% ��ʼ����Ҫ�õ��ı����������ݵ�Ԥ�������
% base parameters ��������
Num_region = 4; % number of region ��������
Num_boat = 6; % total number of boat; �洬����

% region's parameters
% Survival rate �˴�ע�͵���Ϊ�ɴ���
% alpha(1) = 0.2;
% alpha(2) = 0.30;
% alpha(3) = 0.45;
% alpha(4) = 0.6;

% ��ʼ����������ʣ���������ÿ������Ĵ����
r_alp = unifrnd(0.2, 0.6, Num_region);
%�������0.2-0.6֮�����������һ��ȫ��������ľ�������Ϊr_alp
% unifrnd �� ���µ�randi��matlab��װ�õĺ�����ֱ�ӵ��ں����ã�֪������Ϊ���������������
for al = 1:Num_region
    alpha(al) = r_alp(1,al); %������ѭ�����ʣ����򣬸�ÿ���������θ�ֵ��ֵΪr_alp�����е�Ԫ��
end

% Fish inflow �˴�ע�͵���Ϊ�ɴ���
% beta(1) = 300;
% beta(2) = 450;
% beta(3) = 350;
% beta(4) = 200;
% ��ʼ����������������ÿ���������������
r_bet = randi([200 450],1,Num_region); 
for be = 1:Num_region
    beta(be) = r_bet(1,be);
end

Beta = diag(alpha); % create a new diagonal matrix
A = beta';
% x(:,1) = [200, 300, 150, 250]'; % initial fish num
x(:,1) = randi([150 300],1,Num_region);
% x(:,1) = [1000, 1000, 1000, 1000]';
% no fishing dynamic
x_no(:,1) = x(:,1);
for t = 1:100
%     x_no(:,t+1) = A*x_no(:,t)+Beta; % xi(t+1)=Ai+Bixi(t)
        x_no(:,t+1) = A+Beta*x_no(:,t);
end

% boat's parameters �˴�ע�͵���Ϊ�ɴ���
% gamma(1) = 0.08;
% gamma(2) = 0.1;
% gamma(3) = 0.12;
% gamma(4) = 0.15;
% gamma(5) = 0.20;
% gamma(6) = 0.28;
% r_gamma = unifrnd(0.08, 0.28, Num_boat);
r_gamma = unifrnd(0.01, 0.05, Num_boat);
for ga = 1:Num_boat
    gamma(ga) = r_gamma(1,ga);
end
B_total=[];
Gam = cell(Num_boat,1);
for gam = 1:Num_boat
    Gam{gam} = eye(Num_region)*gamma(gam);
    B_total = [B_total,Gam{gam}];
end
N = 15; %prediction horizon

%% grand coalition ������
%% ���⺯��
% global xeb;
fprintf('grand coalition begin');
fprintf('\n');
B = B_total;
x0 = x(:,1);
Num_alleffort = Num_boat * Num_region; %number of efforts in one time
fprintf('equilibrium begin');
tic;
% <--equilibrium��using fmincon��a fun��a eqnonlcon��% simple compute the initial value ��-->
% ���þ��⺯��ȥ�������ľ���������xeb�����洬�ļƻ�uֵ��veb��
[veb,Jeq]= equilibrium(A,Beta,B,Num_alleffort,Num_region,Num_boat,x0); 
xeb = veb(Num_alleffort+1:end,1);
% <------------------------------------------------------------------->
fprintf('equilibrium end��');
toc
Time_equilibrium = toc;

%% �������mpc
fprintf('iterative mpc_solver');
tic;
max_iter = 720; %������720�죬������720�Σ���Ӧpaper�е�time step
% ������⣬Ŀ���ǵõ��洬ÿ��ʵ�ʹ���ʱ��uֵ�����Ӧ�Ĳ�����
for t_d = 1:1:max_iter % time
    tic
    x0 = x(:,end);
    % �����⺯����õļƻ�uֵ��effort�������veb����xebֵ������ľ�������������mpc���õ��Ż���uֵ���洬ʵ�ʽ��й���ʱ��uֵ����
    [v,J_sum(t_d),J(t_d)]  = mpc_solver(A,Beta,N,B,x0,Num_region,xeb,veb); % J is the fish catches
    u = v(1:Num_alleffort,1); % effort
    for a_n = 1:1:Num_boat % number of boats
    % ����uֵ����ÿ�Ҵ�ÿ��Ĳ�����������J_agent��
        J_agent(a_n,t_d) = sum(B_total(1:Num_region,(a_n-1)*Num_region+1:a_n*Num_region)*u((a_n-1)*Num_region+1:a_n*Num_region,1).*x(:,end));
    end
    % ������x��x��ÿ���ʵ������������һ�����ʱҪ��x0 = x(:,end);
    x(:,1+t_d) = Beta*x(:,end)+A-B*u.*x(:,end);
    toc
end
fprintf('iterative end��');
toc
Time_mpc_solver = toc;
fprintf('grand coalition end��time(s)��');
Time_grand = Time_equilibrium + Time_mpc_solver;
disp(Time_grand);
