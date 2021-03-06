% load visual_probe_plot.SD -mat;
%% plot cross-trial Mean with STD
function [MEAN_SS_down, MEAN_CCA_down, tHRF_ds] = plot_block(MEAN_SS, MEAN_CCA, CORR_SS, CORR_CCA, MSE_SS, MSE_CCA, HRFmin, HRFmax, fq, pOxy_SS, pOxy_CCA,ss,STD_SS,STD_CCA, tHRF, timelag, sts, ctr, fpath,lstHrfAdd, nohrflist, hrf, nTrial)

cd(fpath)
load visual_probe_plot.SD -mat
coor_xy = [(SD.SrcPos(SD.MeasList(1:size(SD.MeasList,1)/2,1),1) + SD.DetPos(SD.MeasList(1:size(SD.MeasList,1)/2,2),1))/5,(SD.SrcPos(SD.MeasList(1:size(SD.MeasList,1)/2,1),2)+ SD.DetPos(SD.MeasList(1:size(SD.MeasList,1)/2,2),2))/5];
% F=size(K);
a = coor_xy(:,1);
b = coor_xy(:,2);

nf = 30;


% baseline correct the mean for the plots
% for HbO and HbR
for i = 1:size(MEAN_SS,3)
    for j = 1:size(MEAN_SS,2)
        Baseline(j,i) = squeeze(mean(MEAN_SS(1:abs(fq*HRFmin),j,i),1));
        MEAN_SS(:,j,i) = squeeze(MEAN_SS(:,j,i)) - squeeze(Baseline(j,i));
        Baseline(j,i) = mean(MEAN_CCA(1:abs(fq*HRFmin),j,i),1);
        MEAN_CCA(:,j,i) = MEAN_CCA(:,j,i) - Baseline(j,i);
    end
end

% downsample for visualization
for i = 1:size(MEAN_SS,3)
    for j = 1:size(MEAN_SS,2)
        MEAN_SS_down(:,j,i) = downsample(MEAN_SS(:,j,i),nf);
        STD_SS_down(:,j,i) = downsample(STD_SS(:,j,i),nf);
        MEAN_CCA_down(:,j,i) = downsample(MEAN_CCA(:,j,i),nf);
        STD_CCA_down(:,j,i) = downsample(STD_CCA(:,j,i),nf);
    end
end
tHRF = downsample(tHRF,nf);
tHRF_ds = tHRF;



% % z1 = 0.02; % normalize
% % z2 = 0.95;

z1 = 0.12; % normalize
z2 = 0.75;% adjust this for different probes

a1 = (a*(z2-z1)/(max(a)-min(a)));
a1 = a1+ z1-min(a1);

b1 = ( b*(z2-z1)/(max(b)-min(b)));
b1 = b1+ z1-min(b1);

%get rid of the short-separation channels
rhoSD_ssThresh = 15;
ml = SD.MeasList;
mlAct = SD.MeasListAct;
lst = find(ml(:,4)==1);
rhoSD = zeros(length(lst),1);
posM = zeros(length(lst),3);
for iML = 1:length(lst)
    rhoSD(iML) = sum((SD.SrcPos(ml(lst(iML),1),:) - SD.DetPos(ml(lst(iML),2),:)).^2).^0.5;
    posM(iML,:) = (SD.SrcPos(ml(lst(iML),1),:) + SD.DetPos(ml(lst(iML),2),:)) / 2;
end
lstLL = lst(find(rhoSD>=rhoSD_ssThresh & mlAct(lst)==1));

ylim1 = -0.5e-6;
ylim2 = 0.8e-6;
xlim1 = HRFmin;
xlim2 = max(tHRF);


% figure;
% % SS
% j = 1; % HbO
% foo = 1;
% for i =lstLL'
%     h=subplot('Position',[a1(i),b1(i),0.06,0.1]);
%     hold on;
%     if pOxy_SS(i,j)<=0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),STD_SS_down(:,i,j)/sqrt(nTrial),STD_SS_down(:,i,j)/sqrt(nTrial),'r','LineWidth',2);
%         title(['    p = ' (num2str(pOxy_SS(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_SS(i,j)>0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),STD_SS_down(:,i,j)/sqrt(nTrial),STD_SS_down(:,i,j)/sqrt(nTrial),'color',[0.5 0.5 0.5],'LineWidth',2);
%     end
%     if any(lstHrfAdd(:,1) == i)
%         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
%         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
%         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j));
%     end
%     txt = ['ch ' num2str(i)];
%     ylabel(txt);
%     grid; ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
% end
% suptitle(['GLM with SS - HbO - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
%
%
% figure;
% % CCA
% foo = 1;
% for i =lstLL'
%     j = 1; % HbO
%     h=subplot('Position',[a1(i),b1(i),0.06,0.1]);
%     hold on;
%     if pOxy_CCA(i,j)<=0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),STD_CCA_down(:,i,j)/sqrt(nTrial),STD_CCA_down(:,i,j)/sqrt(nTrial),'r','LineWidth',2);
%         title(['    p = ' (num2str(pOxy_CCA(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_CCA(i,j)>0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),STD_CCA_down(:,i,j)/sqrt(nTrial),STD_CCA_down(:,i,j)/sqrt(nTrial),'color',[0.5 0.5 0.5],'LineWidth',2);
%     end
%     if any(lstHrfAdd(:,1) == i)
%         First_line = ['HRF, Corr: ' num2str(CORR_CCA(foo,j),'%0.2g')];
%         Second_line =  [' MSE: ' num2str(MSE_CCA(foo,j),'%0.2g') ];
%         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j));
%     end
%     txt = ['ch ' num2str(i)];
%     ylabel(txt);
%     grid; ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
% end
% suptitle(['GLM with CCA - HbO - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
%
%
%
% figure;
% % SS
% j = 2; % HbR
% foo = 1;
% for i =lstLL'
%     h=subplot('Position',[a1(i),b1(i),0.06,0.1]);
%     hold on;
%     if pOxy_SS(i,j)<=0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),STD_SS_down(:,i,j)/sqrt(nTrial),STD_SS_down(:,i,j)/sqrt(nTrial),'r','LineWidth',2);
%         title(['    p = ' (num2str(pOxy_SS(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_SS(i,j)>0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),STD_SS_down(:,i,j)/sqrt(nTrial),STD_SS_down(:,i,j)/sqrt(nTrial),'color',[0.5 0.5 0.5],'LineWidth',2);
%     end
%     if any(lstHrfAdd(:,1) == i)
%         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
%         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
%         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j));
%     end
%     txt = ['ch ' num2str(i)];
%     ylabel(txt);
%     grid; ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
% end
% suptitle(['GLM with SS - HbR - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
%
%
% figure;
% % CCA
% foo = 1;
% for i =lstLL'
%     j = 2; % HbR
%     h=subplot('Position',[a1(i),b1(i),0.06,0.1]);
%     hold on;
%     if pOxy_CCA(i,j)<=0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),STD_CCA_down(:,i,j)/sqrt(nTrial),STD_CCA_down(:,i,j)/sqrt(nTrial),'r','LineWidth',2);
%         title(['    p = ' (num2str(pOxy_CCA(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_CCA(i,j)>0.05
%         errorbar(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),STD_CCA_down(:,i,j)/sqrt(nTrial),STD_CCA_down(:,i,j)/sqrt(nTrial),'color',[0.5 0.5 0.5],'LineWidth',2);
%     end
%     if any(lstHrfAdd(:,1) == i)
%         First_line = ['HRF, Corr: ' num2str(CORR_CCA(foo,j),'%0.2g')];
%         Second_line =  [' MSE: ' num2str(MSE_CCA(foo,j),'%0.2g') ];
%         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j));
%     end
%     txt = ['ch ' num2str(i)];
%     ylabel(txt);
%     grid; ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
% end
% suptitle(['GLM with CCA - HbR - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
%
%
%
%
%
% %% figures for paper
% % figures for paper
%
% figure;
% % SS
% j = 1; % HbO
% foo = 1;
% for i =lstLL'
%     h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
%     hold on;
%
%     if any(lstHrfAdd(:,1) == i)
%         %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
%         %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
%         %         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
%     end
%
%     if pOxy_SS(i,j)<=0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'r','LineWidth',2);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'r-.','LineWidth',1);
%         end
%         %         title(['    p = ' (num2str(pOxy_SS(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_SS(i,j)>0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'-.','color',[1 0.4 0.8],'LineWidth',1);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'color',[1 0.4 0.8],'LineWidth',2);
%         end
%     end
%
%     %     txt = ['ch ' num2str(i)];
%     %     ylabel(txt);
%     %     grid;
%     ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
%
% end
%
% % SS
% j = 2; % HbR
% foo = 1;
% for i =lstLL'
%     h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
%     hold on;
%     if any(lstHrfAdd(:,1) == i)
%         %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
%         %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
%         %         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
%     end
%     if pOxy_SS(i,j)<=0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'b','LineWidth',2);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'b-.','LineWidth',1);
%         end
%         %         title(['    p = ' (num2str(pOxy_SS(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_SS(i,j)>0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'-.','color',[0.3010 0.7450 0.9330],'LineWidth',1);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'color',[0.3010 0.7450 0.9330],'LineWidth',2);
%         end
%     end
%
%     %     axis off
%     %     txt = ['ch ' num2str(i)];
%     %     ylabel(txt);
%     %     grid;
%     ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
%     if i ~=13
%         set(gca,'xtick',[])
%         set(gca,'ytick',[])
%     end
%     if i == 13
%         ylabel('\Delta C / Mol')
%         xlabel('t / s')
%     end
% end
% % suptitle(['GLM with SS - HbO/HbR - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
% suptitle('GLM with SS - HbO/HbR') ;
%
%
%
%
%
% figure;
% % CCA
% j = 1; % HbO
% foo = 1;
% for i =lstLL'
%     h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
%     hold on;
%
%     if any(lstHrfAdd(:,1) == i)
%         %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
%         %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
%         %         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
%     end
%
%     if pOxy_CCA(i,j)<=0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'r','LineWidth',2);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'r-.','LineWidth',1);
%         end
%         %         title(['    p = ' (num2str(pOxy_CCA(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_CCA(i,j)>0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'-.','color',[1 0.4 0.8],'LineWidth',1);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'color',[1 0.4 0.8],'LineWidth',2);
%         end
%     end
%
%     %     txt = ['ch ' num2str(i)];
%     %     ylabel(txt);
%     %     grid;
%     ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
%
% end
%
% % CCA
% j = 2; % HbR
% foo = 1;
% for i =lstLL'
%     h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
%     hold on;
%     if any(lstHrfAdd(:,1) == i)
%         %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
%         %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
%         %         xlabel({First_line;Second_line})
%         foo = foo + 1;
%         plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
%     end
%     if pOxy_CCA(i,j)<=0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'b','LineWidth',2);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'b-.','LineWidth',1);
%         end
%         %         title(['    p = ' (num2str(pOxy_CCA(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
%     elseif pOxy_CCA(i,j)>0.05
%         if any(lstHrfAdd(:,1) == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'-.','color',[0.3010 0.7450 0.9330],'LineWidth',1);
%         elseif any(nohrflist == i)
%             plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'color',[0.3010 0.7450 0.9330],'LineWidth',2);
%         end
%     end
%     %     axis off
%     %     txt = ['ch ' num2str(i)];
%     %     ylabel(txt);
%     %     grid;
%     ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
%     if i ~=13
%         set(gca,'xtick',[])
%         set(gca,'ytick',[])
%     end
%
% end
% % suptitle(['GLM with SS - HbO/HbR - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
% suptitle('GLM with CCA - HbO/HbR') ;
%
%
%
% figure;
% subplot(1,4,1);
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'r','LineWidth',2);
% hold;
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'b','LineWidth',2);
% title('True Positive')
% axis off
% legend('\color{red} HbO', '\color{blue} HbR');
%
%
% subplot(1,4,2);
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'r-.','LineWidth',1);
% hold;
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'b-.','LineWidth',1);
% title('False Positive')
% axis off
%
% subplot(1,4,3);
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'color',[1 0.4 0.8],'LineWidth',2);
% hold;
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'color',[0.3010 0.7450 0.9330],'LineWidth',2);
% title('True Negative')
% axis off
% legend('\color[rgb]{1 0.4 0.8} HbO', '\color[rgb]{0.3010 0.7450 0.9330} HbR');
%
% subplot(1,4,4);
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'-.','color',[1 0.4 0.8],'LineWidth',1);
% hold;
% plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'-.','color',[0.3010 0.7450 0.9330],'LineWidth',1);
% title('False Negative')
% axis off


% paper figure, alternative

figure;
% SS
j = 1; % HbO
foo = 1;
for i =lstLL'
    h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
    hold on;
    
    if any(lstHrfAdd(:,1) == i)
        %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
        %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
        %         xlabel({First_line;Second_line})
        foo = foo + 1;
        plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
    end
    
    if pOxy_SS(i,j)<=0.05
        if any(lstHrfAdd(:,1) == i)  % True Positives
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'g','LineWidth',2);
        elseif any(nohrflist == i)  % False Positives
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'r','LineWidth',2);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
        %         title(['    p = ' (num2str(pOxy_SS(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
    elseif pOxy_SS(i,j)>0.05
        if any(lstHrfAdd(:,1) == i) % False Negatives
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'r-.','LineWidth',1);
        elseif any(nohrflist == i) % True Negatives
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'g-.','LineWidth',1);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
    end
    
    
    
    %     txt = ['ch ' num2str(i)];
    %     ylabel(txt);
    %     grid;
    ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
    
end

% SS
j = 2; % HbR
foo = 1;
for i =lstLL'
    h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
    hold on;
    if any(lstHrfAdd(:,1) == i)
        %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
        %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
        %         xlabel({First_line;Second_line})
        foo = foo + 1;
        plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
    end
    if pOxy_SS(i,j)<=0.05
        if any(lstHrfAdd(:,1) == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'g','LineWidth',2);
        elseif any(nohrflist == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'r','LineWidth',2);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
        %         title(['    p = ' (num2str(pOxy_SS(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
    elseif pOxy_SS(i,j)>0.05
        if any(lstHrfAdd(:,1) == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'r-.','LineWidth',1);
        elseif any(nohrflist == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'g-.','LineWidth',1);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
    end
    
    %     axis off
    %     txt = ['ch ' num2str(i)];
    %     ylabel(txt);
    %     grid;
    ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
    if i ~=13
        set(gca,'xtick',[])
        set(gca,'ytick',[])
    end
    if i == 13
        ylabel('\Delta C / Mol')
        xlabel('t / s')
    end
end
% suptitle(['GLM with SS - HbO/HbR - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
suptitle('GLM with SS - HbO/HbR') ;


figure;
% CCA
j = 1; % HbO
foo = 1;
for i =lstLL'
    h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
    hold on;
    
    if any(lstHrfAdd(:,1) == i)
        %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
        %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
        %         xlabel({First_line;Second_line})
        foo = foo + 1;
        plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
    end
    
    if pOxy_CCA(i,j)<=0.05
        if any(lstHrfAdd(:,1) == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'g','LineWidth',2);
        elseif any(nohrflist == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'r','LineWidth',2);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
        %         title(['    p = ' (num2str(pOxy_CCA(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
    elseif pOxy_CCA(i,j)>0.05
        if any(lstHrfAdd(:,1) == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'r-.','LineWidth',1);
        elseif any(nohrflist == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'g-.','LineWidth',1);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
    end
    
    %     txt = ['ch ' num2str(i)];
    %     ylabel(txt);
    %     grid;
    ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
    
end

% CCA
j = 2; % HbR
foo = 1;
for i =lstLL'
    h=subplot('Position',[a1(i),b1(i)*0.8,0.06,0.1]);
    hold on;
    if any(lstHrfAdd(:,1) == i)
        %         First_line = ['HRF, Corr: ' num2str(CORR_SS(foo,j),'%0.2g')];
        %         Second_line =  [' MSE: ' num2str(MSE_SS(foo,j),'%0.2g') ];
        %         xlabel({First_line;Second_line})
        foo = foo + 1;
        plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,j),'k','LineWidth',1);
    end
    if pOxy_CCA(i,j)<=0.05
        if any(lstHrfAdd(:,1) == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'g','LineWidth',2);
        elseif any(nohrflist == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'r','LineWidth',2);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
        %         title(['    p = ' (num2str(pOxy_CCA(i,j),1))],'FontSize',15,'FontWeight','bold','color','k') ;
    elseif pOxy_CCA(i,j)>0.05
        if any(lstHrfAdd(:,1) == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'r-.','LineWidth',1);
        elseif any(nohrflist == i)
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_CCA_down,1)-1):max(tHRF),MEAN_CCA_down(:,i,j),'g-.','LineWidth',1);
        else
            plot(min(tHRF):(max(tHRF) -min(tHRF))/(size(MEAN_SS_down,1)-1):max(tHRF),MEAN_SS_down(:,i,j),'Color', [0.5 0.5 0.5]);
        end
    end
    %     axis off
    %     txt = ['ch ' num2str(i)];
    %     ylabel(txt);
    %     grid;
    ylim([ylim1 ylim2]);xlim([xlim1 xlim2]);
    if i ~=13
        set(gca,'xtick',[])
        set(gca,'ytick',[])
    end
    
end
% suptitle(['GLM with SS - HbO/HbR - Subject # '  num2str(ss) ',  t_l_a_g= ' num2str(timelag) ' sec,  stpsize= ' num2str(sts) ' samples,  cthresh= ' num2str(ctr)]) ;
suptitle('GLM with CCA - HbO/HbR') ;



figure;
subplot(1,4,1);
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'g','LineWidth',2);
hold;
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'g','LineWidth',2);
title('True Positive')
axis off
% legend('\color{green} HbO', '\color{green} HbR');


subplot(1,4,2);
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'r-','LineWidth',2);
hold;
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'r-','LineWidth',2);
title('False Positive')
axis off

subplot(1,4,3);
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'g-.','LineWidth',2);
hold;
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'g-.','LineWidth',2);
title('True Negative')
axis off
% legend('\color{red} HbO', '\color{red} HbR');

subplot(1,4,4);
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,1),'r-.','LineWidth',2);
hold;
plot([0:1/fq:max(hrf.t_hrf+1/fq)],hrf.hrf_conc(:,2),'r-.','LineWidth',2);
title('False Negative')
axis off



