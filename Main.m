clc
clear
beep off

addpath('../Rinex_obs/constell');
set(groot,'defaultLineLineWidth',2)
set(groot,'defaultAxesFontSize',15)

% % Read Rinex 3.04
% [ Header, GPS_obsdata, GAL_obsdata, GLO_obsdata, BEI_obsdata, obsdata ]...
%     = readRinexObs('RINEX_304.22O', 1);

% sort number of satellites
load('obsdata.mat')
obs = obsdata;
[nSV, nSV_SSI] = get_nSV(obs);

%% plot number of satellites
figure(1)
plot(1:length(nSV),nSV)
hold on
plot(1:length(nSV),nSV_SSI)
xlim([1,length(nSV)])
ylim([0,35])
xlabel('time steps')
ylabel('number of satellites')
legend('original nSVs','processed nSVs','Location','southwest')


%%
function [nSV, nSV_SSI] = get_nSV(obs)

temp = find(diff(obs(:,2)));
nSV = diff(temp);
clear temp

% sort number of satellites whoes SSI > 5, NaN, or 0
temp = isnan(obs(:,5));
obs(temp,:) = [];
clear temp
temp = isnan(obs(:,6));
obs(temp,:) = [];
clear temp
temp = isnan(obs(:,7));
obs(temp,:) = [];
clear temp
temp = obs(:,7)==0;
obs(temp,:) = [];
clear temp
temp = obs(:,5)<6;
obs(temp,:) = [];
clear temp

temp = find(diff(obs(:,2)));
nSV_SSI = diff(temp);
end
