function [ V,L ] = itercol( V,L )
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%    L=[1;1;3;3;5;5];
num = unique(L);  %ȡȥ���Ժ�����˱�ǩ
k=size(num,1);
Data=cell(2,k);

for i=1:k
     w=find(L==num(i));%�ҵ���i���������д���Ӧ�Ĵ��ţ��кţ�
     A=[];
     Y=[];
     for j=1:size(w)
         [I]=V(w(j),:);%��ԭʼ��ֻ������ȡ����Ӧ�кŵĴ�ֻ�����ݣ�����A��
         [X]=w(j);
          A=[A;I];
          Y=[Y;X];
     end
     Data{1,i} = A;
     Data{2,i} = Y;
end

V_Temp = [];
for g = 1:k
    V_Temp = [V_Temp;Data{1,g}(1,:)];
end
D = pdist2(V_Temp,V_Temp);  %�������˼�ľ���
Dnew = D; 
Dnew(Dnew==0)=inf;
[minv,ind]=min(Dnew,[],2);
min_row = min(minv);
dmin = min_row;
% d=0.1;  %��������Ϊ0.1
while min_row == dmin
    z=find(minv==min_row); %���־�����������˺�
    if size(z,1)<2
        break;
    else
        col_left = Data{1,z(1)}(1,:);
        col_right = Data{1,z(2)}(1,:);
        boatnum_left = size(Data{2,z(1)},1);
        boatnum_right = size(Data{2,z(2)},1);
        %����ϲ��������v
        v_temp = (col_left*boatnum_left+col_right*boatnum_right)/(boatnum_left+boatnum_right);
        for left_i = 1:boatnum_left
            l1 = Data{2,z(1)}(left_i,:);
            V(l1,:) = v_temp; %�滻�ɺϲ����v
            L(l1,:) = Data{2,z(1)}(1,:); %�������˺�
        end
        for right_i = 1:boatnum_right
            l2 = Data{2,z(2)}(right_i,:);
            V(l2,:) = v_temp;
            L(l2,:) = Data{2,z(1)}(1,:);
        end
        minv(z(1)) = inf;
        minv(z(2)) = inf;
        min_row = min(minv);
    end
end

end

