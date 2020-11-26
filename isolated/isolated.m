clc;
clear;
%% ��ʼ����Ҫ�õ��ı����������ݵ�Ԥ�������
% base parameters ��������
Num_region = 4; % number of region ��������
Num_boat = 6; % total number of boat; �洬����

%% region's parameters (no fishing)
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

% Fish inflow
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
%  x(:,1) = [1000, 1000, 1000, 1000]';
% no fishing dynamic
x_no(:,1) = x(:,1);
for t = 1:100
%     x_no(:,t+1) = A*x_no(:,t)+Beta; % xi(t+1)=Ai+Bixi(t)
        x_no(:,t+1) = A+Beta*x_no(:,t);
end

% boat's parameters
% gamma(1) = 0.08; �˴�ע�͵���Ϊ�ɴ���
% gamma(2) = 0.1;
% gamma(3) = 0.12;
% gamma(4) = 0.15;
% gamma(5) = 0.20;
% gamma(6) = 0.28;
% Gam = cell(6,1);
% Gam{1} = eye(4)*gamma(1);
% Gam{2} = eye(4)*gamma(2);
% Gam{3} = eye(4)*gamma(3);
% Gam{4} = eye(4)*gamma(4);
% Gam{5} = eye(4)*gamma(5);
% Gam{6} = eye(4)*gamma(6);
% 
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
N = 15; %prediction horizon Ԥ�ⷶΧ

%% isolated coalition ��������
global xeb;
max_iter = 720; %������720�죬������720�Σ���Ӧpaper�е�time step
% ������⣬Ŀ���ǵõ��洬ÿ��ʵ�ʹ���ʱ��uֵ�����Ӧ�Ĳ�����
for t_d = 1:1:max_iter
    tic;
    x0 = x(:,end);
    %% �洬1
    % ֻ����洬1����ΪB=[Gam{1}],�õ���Bֵ��ֻ���洬1�й�
    B = [Gam{1}];
    Num_alleffort = size(B,2);
    % ���þ��⺯��ȥ�������ľ���������xeb�����洬�ļƻ�uֵ��veb��
    [veb,Jeq(1)] = equilibrium(A,Beta,B,Num_alleffort,Num_region,Num_boat,x0);
    xeb = veb(end-Num_region+1:end,1);
    % �����⺯����õļƻ�uֵ��effort�������veb����xebֵ������ľ�������������mpc���õ��Ż���uֵ���洬ʵ�ʽ��й���ʱ��uֵ����
    [v,J_sum,J]  = mpc_solver(A,Beta,N,B,x0,Num_region,xeb,veb);
    u1 = v(1:Num_alleffort,:); 
    
    %% �洬2
    B = [Gam{2}];
    Num_alleffort = size(B,2);
    [veb,Jeq(2)] = equilibrium(A,Beta,B,Num_alleffort,Num_region,Num_boat,x0);
    xeb = veb(end-Num_region+1:end,1);
    [v,J_sum,J]  = mpc_solver(A,Beta,N,B,x0,Num_region,xeb,veb);
    u2 = v(1:Num_alleffort,:);
    %% �洬3
    B = [Gam{3}];
    Num_alleffort = size(B,2);
    [veb,Jeq(3)] = equilibrium(A,Beta,B,Num_alleffort,Num_region,Num_boat,x0);
    xeb = veb(end-Num_region+1:end,1);
    [v,J_sum,J]  = mpc_solver(A,Beta,N,B,x0,Num_region,xeb,veb);
    u3 = v(1:Num_alleffort,:);
    %% �洬4
    B = [Gam{4}];
    Num_alleffort = size(B,2);
    [veb,Jeq(4)] = equilibrium(A,Beta,B,Num_alleffort,Num_region,Num_boat,x0);
    xeb = veb(end-Num_region+1:end,1);
    [v,J_sum,J]  = mpc_solver(A,Beta,N,B,x0,Num_region,xeb,veb);
    u4 = v(1:Num_alleffort,:);
    %% �洬5
    B = [Gam{5}];
    Num_alleffort = size(B,2);
    [veb,Jeq(5)] = equilibrium(A,Beta,B,Num_alleffort,Num_region,Num_boat,x0);
    xeb = veb(end-Num_region+1:end,1);
    [v,J_sum,J]  = mpc_solver(A,Beta,N,B,x0,Num_region,xeb,veb);
    u5 = v(1:Num_alleffort,:);   
    %% �洬6
    B = [Gam{6}];
    Num_alleffort = size(B,2);
    [veb,Jeq(6)] = equilibrium(A,Beta,B,Num_alleffort,Num_region,Num_boat,x0);
    xeb = veb(end-Num_region+1:end,1);
    [v,J_sum,J]  = mpc_solver(A,Beta,N,B,x0,Num_region,xeb,veb);
    u6 = v(1:Num_alleffort,:);
    
    %��6�Ҵ���uֵƴ��һ��uֵ�������Ա���к��������
    u = [u1;u2;u3;u4;u5;u6];
    B_total = [Gam{1} Gam{2} Gam{3} Gam{4} Gam{5} Gam{6}];
    for a_n = 1:1:Num_boat
    % ����uֵ����ÿ�Ҵ�ÿ��Ĳ�����������J_agent��
        J_agent(a_n,t_d) = ones(1,Num_region)*(B_total(1:Num_region,(a_n-1)*Num_region+1:a_n*Num_region)*u((a_n-1)*Num_region+1:a_n*Num_region,1).*x(:,end));
    end
    % ������x��x��ÿ���ʵ������������һ�����ʱҪ��x0 = x(:,end);
    x(:,1+t_d) = Beta*x(:,end)+A-B_total*u.*x(:,end);
    toc;
end
%% function below
