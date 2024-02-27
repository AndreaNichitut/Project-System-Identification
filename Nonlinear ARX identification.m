clear all; clc; close all;
load('iddata-16.mat');

u_id=id.InputData;
u_val=val.InputData;
y_id=id.OutputData;
y_val=val.OutputData;

% AFIȘARE DATE DE IDENTIFICARE ȘI VALIDARE
subplot(2,1,1);
plot(u_id);
grid; xlabel('t'); ylabel('u'); title('Grafic pentru datele de intrare - identificare');
subplot(2,1,2);
plot(y_id);
grid; xlabel('t'); ylabel('y'); title('Grafic pentru datele de iesire - identificare');

figure;
subplot(2,1,1);
plot(u_val);
grid; xlabel('t'); ylabel('u'); title('Grafic pentru datele de intrare - validare');
subplot(2,1,2);
plot(y_val);
grid; xlabel('t'); ylabel('y'); title('Grafic pentru datele de iesire - validare');

% VALORI CONFIGURABILE PENTRU na, nb, m
na_c = 3; nb_c = 3; m_c = 4;

% VECTORII PENTRU ERORILE MINIME PE IDENTIFICARE ȘI VALIDARE
mse_min_id = zeros(1, 4); %SE REȚINE VALOAREA MSE MIN, na, nb ȘI m PENTRU IDENTIFICARE
mse_vect_id = [];
mse_min_val = zeros(1, 4); %SE REȚINE VALOAREA MSE MIN, na, nb ȘI m PENTRU VALIDARE
mse_vect_val = [];

for na = 1:na_c
   nb = na;
        for m = 1:m_c
            %GENERAREA COMBINAȚIILOR DE PUTERI PE IDENTIFICARE
            puteri_posibile = cell(1, na+nb);
            for i = 1 : na+nb
                puteri_posibile{i} = 0:m;
            end
            %MATRICEA CU TOATE COMBINAȚIILE DE PUTERI
            [puteri_posibile{:}] = ndgrid(puteri_posibile{:});
            puteri_posibile = cellfun(@(x) x(:), puteri_posibile, 'UniformOutput', false);
            puteri_posibile = cat(2, puteri_posibile{:});
            puteri=[];
            k=1;
            for i=1:length(puteri_posibile)
                if(sum(puteri_posibile(i,:))<=m)
                    puteri(k,:)=puteri_posibile(i,:);
                    k=k+1;
                end
            end
            matrice_sortata = sortrows(puteri);
            pe=[];
            pe(1,:)=matrice_sortata(1,:);
            matrice_sortata(1,:)=[];
            matrice_sortata(end+1,:)=pe;
            %PREDICȚIE
            %CALCULĂM VECTORUL phi_d_id
            phi_d_id = zeros(length(u_id), na+nb);
            for i=1:length(u_id)
                for j=1:(na+nb)
                    if(i-j>0 && j<=na)
                        phi_d_id(i,j)=y_id(i-j);
                    end
                    if(i-j+na>0 && j>na)
                        phi_d_id(i,j)=u_id(i-j+na);
                    end
                end
            end
            phi_id=[];
            phi_id_p=[];
            k=1;
            for i=1:length(phi_d_id)
                for j=1:length(matrice_sortata)
                    phi_id(k,:)=phi_d_id(i,:).^matrice_sortata(j,:);
                    phi_id_p(i,j)=prod(phi_id(k,:));
                    k=k+1;
                end
            end
            theta_pol = phi_id_p\y_id;
            y_pol_id=phi_id_p*theta_pol;

            %AFLAREA ERORII MINIME PE PREDICȚIE
            mse_id_predictie=1/length(u_id)*sum(y_id-y_pol_id).^2;
            mse_vect_id = [mse_vect_id, mse_id_predictie];
            if (mse_id_predictie < mse_min_id(1) || (na == 1 && nb== 1 && m == 1))
                mse_min_id(1) = mse_id_predictie;
                mse_min_id(2) = na;
                mse_min_id(3) = nb;
                mse_min_id(4) = m;
                y_pol_min_id = y_pol_id;
                theta_min_id = theta_pol;
                mat_sortata_id = matrice_sortata;
                puteri_min_id = puteri;
            end

            %VALIDARE
            %CALCULĂM VECTORUL phi_d_val
            phi_d_val = zeros(length(u_val), na+nb);
            for i=1:length(u_val)
                for j=1:(na+nb)
                    if(i-j>0 && j<=na)
                        phi_d_val(i,j)=y_val(i-j);
                    end
                    if(i-j+na>0 && j>na)
                        phi_d_val(i,j)=u_val(i-j+na);
                    end
                end
            end
            phi_val=[];
            phi_val_p=[];
            k=1;
            for i=1:length(phi_d_val)
                for j=1:length(matrice_sortata)
                    phi_val(k,:)=phi_d_val(i,:).^matrice_sortata(j,:);
                    phi_val_p(i,j)=prod(phi_val(k,:));
                    k=k+1;
                end
            end
            y_pol_val=phi_val_p*theta_pol;

            %AFLAREA ERORII MINIME PE VALIDARE
            mse_val_predictie=1/length(u_val)*sum(y_val-y_pol_val).^2;
            mse_vect_val = [mse_vect_val, mse_val_predictie];
            if mse_val_predictie < mse_min_val(1)  || (na==1 && nb==1 && m ==1)
                mse_min_val(1) = mse_val_predictie;
                mse_min_val(2) = na;
                mse_min_val(3) = nb;
                mse_min_val(4) = m;
                y_pol_min_val = y_pol_val;
                theta_min_val = theta_pol;
                mat_sortata_val = matrice_sortata;
                puteri_min_val = puteri;
            end
        end
end

%AFIȘARE GRAFICE PREDICȚIE PE VALORILE na, nb, m OPTIME 
na_id = mse_min_id(2);
nb_id = mse_min_id(3);
m_id = mse_min_id(4);
y_pol_id = y_pol_min_id;
theta_pol_id = theta_min_id;
matrice_sortata_id = mat_sortata_id;
puteri_id = puteri_min_id;
figure; plot(y_id, "blue"); title("Date reale pe identificare");
figure; plot(y_pol_id, "red"); title("Predicție pe identificare");
figure; plot(y_id, "blue"); hold on; plot(y_pol_id, "red");
title('Suprapunere predicție pe identificare'); legend('y\_id', 'y\_pol\_id');

%AFIȘARE GRAFICE VALIDARE PE VALORILE na, nb, m OPTIME
na_val = mse_min_val(2);
nb_val = mse_min_val(3);
m_val = mse_min_val(4);
theta_pol_val = theta_min_val;
matrice_sortata_val = mat_sortata_val;
puteri_val = puteri_min_val;
y_pol_val = y_pol_min_val;
figure; plot(y_val, "blue"); title("Date reale pe validare");
figure; plot(y_pol_val, "red"); title("Predicție pe validare");
figure; plot(y_val, "blue"); hold on; plot(y_pol_val, "red");
title('Suprapunere predicție pe validare'); legend('y\_val', 'y\_pol\_val');

figure; plot(mse_vect_id); title('MSE Identificare');
figure; plot(mse_vect_val); title('MSE Validare');

% SIMULARE PE IDENTIFICARE
y_id_simulare=zeros(1,length(u_id));
for i=1:length(u_id)
    simulare_id=zeros(1,na_val+nb_val);
    for j=1:na_val+nb_val
        if(i-j>0 && j<=na_val)
            simulare_id(j)=y_id_simulare(i-j);
        end
        if(i-j+na_val>0 && j>na_val)
            simulare_id(j)=u_id(i-j+na_val);
        end
    end
    r=0;
    for k = 1:length(puteri_val)
        phi_id_sim(k,:) = simulare_id.^matrice_sortata_val(k,:);
        p = prod(phi_id_sim(k,:));
        r = r+p*theta_pol_val(k);
    end
    y_id_simulare(i)=r;
end

figure; plot(y_id, "blue"); title("Date reale pe identificare");
figure; plot(y_id_simulare, "red"); title('Simulare pe identificare');
figure; plot(y_id, "blue"); hold on; plot(y_id_simulare, "red");
title('Suprapunere simulare pe identificare'); legend('y\_id', 'y\_id\_simulare');
mse_id_simulare=1/length(u_id)*sum(y_id-y_id_simulare').^2;

%SIMULARE PE VALIDARE
y_val_simulare=zeros(1,length(u_val));
for i = 1:length(u_val)
    simulare_val=zeros(1,na_val+nb_val);
    for j = 1:na_val+nb_val
        if(i-j>0 && j<=na_val)
            simulare_val(j)=y_val_simulare(i-j);
        end
        if(i-j+na_val>0 && j>na_val)
            simulare_val(j)=u_val(i-j+na_val);
        end
    end
    r=0;
    for k = 1:length(puteri_val)
        phi_val_sim(k,:)=simulare_val.^matrice_sortata_val(k,:);
        p=prod(phi_val_sim(k,:));
        r=r+p*theta_pol_val(k);
    end
    y_val_simulare(i)=r;
end

figure; plot(y_val, "blue"); title("Date reale pe validare");
figure; plot(y_val_simulare, "red"); title('Simulare pe validare');
figure; plot(y_val, "blue"); hold on; plot(y_val_simulare, "red");
title('Suprapunere simulare pe validare'); legend('y\_val', 'y\_val\_simulare');
mse_val_simulare=1/length(u_val)*sum(y_val-y_val_simulare').^2;

