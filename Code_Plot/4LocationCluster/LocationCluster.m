%% 5)location_cluster_flat plot

%% Clear wrokspace
clear
%% load detail data
data_sets = {'weekday_7', 'holiday_5'}; 
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
    file_names3 = sprintf('%s/%s.eps',dirnames,data_sets{names_set_i});
    imwrite(temp, [file_names3 '.png'])
    close all
end