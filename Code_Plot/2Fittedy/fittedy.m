%% 3) fitted_y (run this after the CMS_KCFC)
clear
%% load detail data
data_sets = {'weekday_7', 'holiday_5'}; 
for names_set_i = 1 : 2
dirnames = sprintf('./plot/%s', data_sets{names_set_i});
mkdir(dirnames);
data = load(sprintf('./detail_%s.mat',data_sets{names_set_i}));

T=[ 0           0.4470      0.7410;
    0.8500      0.3250      0.0980;
    0.4940      0.1840      0.5560;
    0.4660      0.6740      0.1880;
    0.3010      0.7450      0.9330;
    0.6350      0.0780      0.1840;
    0           0.4470      0.7410;
    0.8500      0.3250      0.0980;
    0.8         0.6         0;
    0           0           0;
    0.4940      0.1840      0.5560;
    0.4         0.2         0.8;];

uc = unique(data.result.newCluster);
%% Clustering Results
for pictures = 1 : length(uc)
% for pictures = 1 : length(uc)
    detail_plot=data.result.(['detail_',num2str(pictures)]);
    ind_smooth_mu = find(data.result.newCluster == uc(pictures));

    %% plot fitted y
    fitted_val = detail_plot{22};
    figure('Position', [40, 80, 800, 800], 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8,8]);
    mu_t = detail_plot{8};
    sumsd = zeros(1,144);
    for sdd = 1 : size(detail_plot{3}, 2)
        temp_sdd=detail_plot{5}(:,sdd);
        bandw=gcv_lwls(temp_sdd',1:180,'epan', 1, 3, 0, 2, 'off',1);
        [invalid,temp_sdd]=lwls( bandw,'epan',1,3,0,(1:180)*144/180,temp_sdd,ones(1,180),1:144,0);
        sumsd=sumsd+temp_sdd.*temp_sdd*detail_plot{3}(sdd);
    end
    confidentp = mu_t + 1.96 * sqrt(sumsd);
    confidentn = mu_t - 1.96 * sqrt(sumsd);
    confident = [confidentp; confidentn];
    maxY1vsY2 = max(confident);
    minY1vsY2 = min(confident);
    yForFill = [maxY1vsY2, fliplr(minY1vsY2)];
    xForFill = [1 : 144, fliplr(1 : 144)];
    fill(xForFill, yForFill, 'c', 'FaceAlpha', 0.2, 'EdgeAlpha', 1, 'EdgeColor', 'c');
    hold on
    h1 = plot(1 : 144, zeros(1, 144), 'w');
    hold on
    
    for fitted = 1 : size(fitted_val, 2)
        tk = plot(1 : 144, fitted_val{fitted},'LineWidth', 3, 'color', T(fitted, :));
        hold on
        T = [T ; tk.Color];
    end
    
    llname=sprintf('\\color{gray}  n=%d',size(fitted_val,2));
    h = legend(h1([1]), llname);
    ax = gca;
    ax.TickDir = 'out';
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = 0 : 6 : 144;
    %     ax.XMinorGrid = 'on';
    set(gca,'linewidth', 1)
    set(h,'Fontsize', 35);
    legend('boxoff')
    set(gca, 'FontSize', 25)
    set(gca,'box','on', 'layer', 'top', 'TickDir', 'out');
    set(gca,'XTick', 0 : 12 : 144);
    set(gca,'XTickLabel', {0 : 2 : 24})
    xlim([0, 144])
%     if names_set_i == 1
%         ylim([-0.005, 0.7])
%     else
%         ylim([-0.005, 1])
%     end
    ylim([-0.005, 1])
    ylabel('Intensity', 'FontSize', 30);
    xlabel('Time (hr)', 'FontSize', 30);
    file_names = sprintf('%s/fitted_y_cluster%d_%d.eps', dirnames, data.result.nc_kcfc, pictures);
    print('-depsc', file_names);
end

%% Removed Data plot (for the low intensity curve)
year = 2015;
remove_location=setdiff(1:209,data.result.location_save_ind);
%% Revove the special locaiton index = 18
if names_set_i==1 && year == 2015
    spl=find( remove_location == 18);
    remove_location(spl) = [];
end

if names_set_i == 2 && year == 2015
    spl=find(remove_location == 20);
    remove_location(spl) = [];
end    
figure('Position', [40, 80, 800, 300], 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8, 8]);
h1=plot(1 : 144, zeros(1, 144), 'w');
hold on
h2=plot(1 : 144, data.result.raw_data(remove_location, :), 'LineWidth', 2);
axis normal
llname=sprintf('\\color{gray}  n=%d',length(h2));
h=legend(h1([1]), llname);
set(h, 'Fontsize', 35);
legend('boxoff')
ax = gca;
ax.TickDir = 'out';
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = 0 : 6 : 144;
%     ax.XMinorGrid = 'on';
set(gca, 'linewidth', 1)
set(gca, 'XTick',0 : 6 : 144);
set(gca, 'XTickLabel',0 : 6 : 24)
set(gca, 'FontSize', 25)
set(gca, 'box','on', 'layer', 'top', 'TickDir', 'out');
set(gca, 'XTick', 0 : 12 : 144);
set(gca, 'XTickLabel',{0 : 2 : 24})
xlim([0, 144])
if names_set_i == 1
    ylim([-0.005, 0.7])
else
    ylim([-0.005,1])
end
ylabel('Intensity','FontSize',30);
xlabel('Time (hr)','FontSize',30);
file_names3=sprintf('%s/remove_data.eps',dirnames);
print('-depsc',file_names3);
end
