clear
clc

rng(123123)
a=table;
a.id=[1 1 1 2 2 3 3 5 5 5 6]';
a.var1=randi(10,height(a),1);
a.var2=randi(10,height(a),1);

b=struct;
b.min=@min;
b.max=@max;

c=stataCollapse('id',a,{'var1','var2'},{'c_min','c_max'},'customFun',b);

%% Big test
clc
rng(123453123)
% Few ids, many obs
t1=table;
t1.id=randi(10,1e6,1);
t1.v=randn(height(t1),1);
t1=sortrows(t1,'id');

% Many ids, many obs
t2=table;
t2.id=randi(1e6,1e6,1);
t2.v=randn(height(t1),1);
t2=sortrows(t2,'id');

iters=2;

for i=1:2
    if(i==1)
        t=t1;
    else
        t=t2;
    end
    
    
tic
for j=1:iters
    res_a=stataCollapse('id',t,{'v','v'},{'sum','count'});
end
toc

tic
for j=1:iters
    res_b=stataCollapse('id',t,{'v','v'},{'c_','count'},'customfun',@sum);
end
toc

tic
for j=1:iters
    %res_c=stataCollapse2('id',t,{'v','v'},{'sum','count'});
end
toc

end

assert(all(table2array(res_a)==table2array(res_b),'all'))

res_d=stataCollapse('id',t,{'v','v','v','v','v','v','v'},{'pos1','first','pos1last','last','pos3','third','pos100000000'});
res_e=stataCollapse('id',t,{'v','v','v'},{'first','last','third'});
assert(all(res_d.v_first==res_d.v_pos1))
assert(all(res_d.v_last==res_d.v_pos1last))

