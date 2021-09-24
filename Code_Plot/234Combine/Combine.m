clear
%% load detail data
data_sets = {'weekday_7', 'holiday_5'};

for names_set_i = 1 : 2
dirnames0 = sprintf('./plot/%s', data_sets{names_set_i});
mkdir(dirnames0);
data = load(sprintf('./detail_%s.mat',data_sets{names_set_i}));

%% 3) fitted_y (run this after the CMS_KCFC)
dirnames = sprintf('./plot/%s', data_sets{names_set_i});
mkdir(dirnames);
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
% Clustering Results
for pictures = 1 : length(uc)
% for pictures = 1 : length(uc)
    detail_plot=data.result.(['detail_',num2str(pictures)]);
    ind_smooth_mu = find(data.result.newCluster == uc(pictures));

    % plot fitted y
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

% Removed Data plot (for the low intensity curve)
year = 2015;
remove_location=setdiff(1:209,data.result.location_save_ind);
% Revove the special locaiton index = 18
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


%% 4) Heatmap
color_choose=[
    1 0 0;
    0 0 1;
    0.2 0.4 0.2;
    1 0 1;
    0.6 0.2 0;
    1 0.4 0;
    0.4 0.2 0.8;
    0 0 0;
    0.8 0.6 0;
    0 1 1;
    0.6 0 1.0;
    0 0.2 0.4;
    ];

names_table = readtable('location_list.csv','ReadVariableNames',false);
%     data = load(sprintf('./detail_%s.mat',data_sets{names_set_i}));

    names_inds=data.result.location_save_ind;
    data_names={};
    
    for nn=1:length(names_inds)
       check_ind= names_inds( nn);
       temp=table2array(names_table(check_ind,12));
        data_names{nn} = temp{1};
    end
   
    cluster_list=data.result.newCluster;
    list_array=ones(1,length(unique(cluster_list)));
    data_heat=[];
    
    nameT={};
    names_ind=1;

    Label_for_color=[];
   uc= unique(data.result.newCluster);

   for locations = 1 : length(unique(data.result.newCluster))
      indexs = find(data.result.newCluster == uc(locations));
       data_heat = [data_heat;data.result.data(indexs,:)];
       for names_T = 1 : length(indexs)
          nameT{ names_ind} = data_names{indexs(names_T)};
          names_ind = names_ind + 1;
          
       end
       Label_for_color = [Label_for_color repmat(locations,1,length(indexs))];
   end

figure('Position', [40, 80, 800, 900], 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 28, 34])
    imagesc(data_heat * 100)
    xlim([36 144])
    caxis([0 100])
    

    color_heatmap=[
        %最高的部分
        1 0 0;
        1 0.4 0;
        1 0.8 0;
        0.4 1 0.4;
        
        0 0.6 0.2
        
        0 1   1 ;
        0 0.4 1;
        0 0 1;
        
        170/255 170/255 180/255;
        200/255 200/255 200/255
        ];
    color_heatmap = flipud(color_heatmap);
    colormap(gca, color_heatmap)
    h= colorbar('Ticks',[0 10 20 30 40 50 60 70 80 90 100],...
        'TickLabels',{'0','10','20','30','40','50','60','70','80','90','100'});
    
    set(h.Label, 'String', '(%)','Units','Normalized', 'Position', [0.5, -0.01], 'FontSize', 10);
    h.Label.Rotation=0;
    grid on
    grid minor

    set(gca,'ygrid','on','GridColor',[150/255 150/255 150/255])
    ax = gca;
    axpos = ax.Position;
    h.Position(3) = 0.7*h.Position(3);
    ax.Position = axpos;
    ax.TickLength = [0.01 0.01];
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = 36:1:144;
    ax.XMinorGrid = 'on';
    ax.TickDir = 'out';
    set(gca,'linewidth',2)
    set(gca,'XTick',36:6:144);
    set(gca,'XTickLabel',6:1:24)
    set(gca,'YTick',1:length(data.result.location_save_ind));
    set(gca, 'FontSize', 30)
    %     ax.XAxis.FontSize = 25;
    %     ax.YAxis.FontSize = 15;
    set(gca,'YTickLabel',nameT)
    for color_L=1:length(ax.YTickLabel)
       temp_color= Label_for_color(color_L);
        temp_color_fill_in=sprintf('\\color[rgb]{%d,%d,%d}',color_choose(temp_color,1),color_choose(temp_color,2),color_choose(temp_color,3));
        ax.YTickLabel{color_L}=[temp_color_fill_in, ax.YTickLabel{color_L}];
    end 
    xlabel('Time (Hr)','FontSize',40)
    picnames = sprintf('%s/heatmap_gray_grid_%s.eps', dirnames0, data_sets{names_set_i});
    print('-depsc',picnames);


%% 5LocationCluster
color_choose=[
    1 0 0;
    0 0 1;
    0.2 0.4 0.2;
    1 0 1;
    0.6 0.2 0;
    1 0.4 0;
    0.4 0.2 0.8;
    0 0 0;
    0.4 0.4 0;
    0 1 1;
    0.6 0 1.0;
    0 0.2 0.4;
    ];
fid = fopen('location_list.csv', 'rt');
segment_point = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
segment_point = segment_point{ : };
interval_names = segment_point;

% location_interval.txt存切割的切點
fid2 = fopen('location_interval.txt','rt');
segment_point2 = textscan(fid2, '%d', 'Delimiter', '\n');
fclose(fid2);
segment_point2 = segment_point2{ : };

names_table = readtable('location_list.csv', 'ReadVariableNames', false);
for names_set_i = 1 : 2
    names_set = data_sets{names_set_i};
    dirnames = sprintf('plot');
    mkdir(dirnames);
    data = load(sprintf('./detail_%s.mat',data_sets{names_set_i}));
    names_inds = data.result.location_save_ind;
    %% type 1
    location_new_index = [];
    new_plot_x_array = [];
    for  ll = 1 : 209
        temp_data_index = data.result.raw_data(ll, :); % data.result.raw_data: 209 * 144的塞車資訊
        temp_data_index(temp_data_index < 0) = 0;
        temp_array = 0;
        for jj = 1 : size(temp_data_index, 2)
          temp_array = temp_array + 10 * temp_data_index(jj);
        end
        location_new_index = [location_new_index, temp_array];
    end
    ylim_m = 5;
    
    %% I think the plot starts here!
    figure('Position', [0, 0, 2000, 120], 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8,8])
    set(gcf, 'color', [1 1 1])
    for location = 1 : 209
        start_m = double(segment_point2(location));
        end_m = double(segment_point2(location+1));
        ICI_i = location_new_index(location);
        %% color define
        define_color = find(names_inds == location);
        if isempty(define_color) ~= 1
            color_choose1 = color_choose(data.result.newCluster(define_color), :);
            plot_location = start_m;
            barWidth = end_m - plot_location;
            bar(plot_location, repmat(15, length(plot_location), 1), 'BarWidth', 1 * 1, 'FaceColor', color_choose1, 'EdgeColor', [1 1 1])
            hold on
        end
%         plot_location = (start_m + end_m) / 2; 
        
    end
    set(gca,'box', 'off')
    ax = gca;
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = 0 : 1 : 375;
    ax.XMinorGrid = 'on';
    ax.TickDir = 'out';
    ax.TickLength = [0.01 0.01];
    ax.LineWidth = 1;
    xlim([-2, 375.5]);
    xlabel('Mileage (Km)','FontSize', 30)
    set(gca, 'LineWidth', 1)
    set(gca, 'XTick', 0 : 10 : 375, 'XTickLabel', 0 : 10 : 375, 'FontSize', 15);
    set(gca, 'YTick', []);
    set(gca, 'Ycolor', [1 1 1])
    ax.XTickLabelRotation = 45;
    set(gca, 'looseInset',[0 0 0 0]);
    F = getframe(gcf);
    temp =frame2im(F) ;
    file_names3 = sprintf('%s/%s.eps',dirnames0,data_sets{names_set_i});
    imwrite(temp, [file_names3 '.png'])
    close all
    



end
end
