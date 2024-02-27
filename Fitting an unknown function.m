clear all;
clc;
load('proj_fit_34.mat'); %incarcare fisier

map=[0 1 1
     1 0 1]; %culori pt mesh

x1=id.X{1};
x2=id.X{2};
y1=id.Y;
mesh(id.X{1},id.X{2},y1); %plotare 2D
colormap(map);
title('Datele de identificare');
xlabel('X{1}');
ylabel('X{2}');
zlabel('Y');

mseidv=[];
msevalv=[];

for m=1:20

[x1_id,x2_id]=meshgrid(x1,x2); %toate combinatiile posibile de x1 cu x2
phi_id=ones(id.dims(1)*id.dims(2),1); %41*41 linii
for i=1:m
    phi_id=[phi_id,x1_id(:).^i,x2_id(:).^i]; %x1 la putere ; x2 la putere
end

for i=1:(m-1)
    for j=1:(m-1)
        if i+j<=m
    phi_id=[phi_id,x1_id(:).^i.*x2_id(:).^j]; %combinatiile la puteri
        end
    end
end

k=1;
for i=1:length(id.Y)
    for j=1:length(id.Y)
      yy(1,k)=id.Y(j,i); %transform Y in linie
      k=k+1;
    end
end

theta=phi_id\yy';
y_hat_id=phi_id*theta;
r1=reshape(y_hat_id,[id.dims(1),id.dims(2)]);

x3=val.X{1};
x4=val.X{2};
y2=val.Y;
[x1_val,x2_val]=meshgrid(x3,x4);
phi_val=ones(val.dims(1)*val.dims(2),1); %31*31 linii
for i=1:m
    phi_val=[phi_val,x1_val(:).^i,x2_val(:).^i];
end

for i=1:(m-1)
    for j=1:(m-1)
        if i+j<=m
    phi_val=[phi_val,x1_val(:).^i.*x2_val(:).^j];
        end
    end
end

y_hat_val=phi_val*theta;
r2=reshape(y_hat_val,[val.dims(1),val.dims(2)]);

MSEid=1/length(x1)*sum((y1-r1).^2); 
msefinalid=sum(MSEid)/id.dims(1);
MSEval=1/length(x3)*sum((y2-r2).^2);
msefinalval=sum(MSEval)/val.dims(1);

mseidv=[mseidv msefinalid];
msevalv=[msevalv msefinalval];

end

figure();
mesh(val.X{1},val.X{2},y2); %plotare 2D
colormap(map);
title('Datele de validare');
xlabel('X{1}');
ylabel('X{2}');
zlabel('Y');

figure();
mesh(id.X{1},id.X{2},y1,FaceColor="g");
hold on
mesh(id.X{1},id.X{2},r1,FaceColor="r");
title('Aproximator identificare');
xlabel('X{1}');
ylabel('X{2}');
zlabel('Y');
legend('identificare','aproximare');

figure();
mesh(val.X{1},val.X{2},y2,FaceColor="g");
hold on
mesh(val.X{1},val.X{2},r2,FaceColor="r");
title('Aproximator validare');
xlabel('X{1}');
ylabel('X{2}');
zlabel('Y');
legend('validare','aproximare');

figure();
[x,indx]=min(msevalv,[],'all','linear'); %indx e gradul; x e valoarea
plot(msevalv);
hold on
plot(indx,x,'r*');
title('MSE');
xlabel('X');
ylabel('Y');
