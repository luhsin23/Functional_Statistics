%% 1) and 2) the point porcess and the intensity function

%% Clear wrokspace
clear

%% Load Data
year = 2015;
data_sets = {'2015_N1_N_2571'};
data = load(data_sets{1});
% d2571 =  load('2015_N1_N_2820.mat');
% d2820 =  load('2015_N1_N_2820.mat');

time_data = load('data_time.mat');
time = time_data.time;
names = {'Weekday', 'Holiday'};
daytype_component = {'RD|WAH|WBH','HAW|HBW'};
detail = zeros(4,10);
% make_floder = sprintf('PointProcess');
% mkdir(make_floder);
make_floder = sprintf('plot');
mkdir(make_floder);

for i = 1 : length(names)
%     make_floder1=sprintf('%s/%s', make_floder, names{i});
%     mkdir(make_floder1);
    
    date_ind = find(~cellfun('isempty',regexp(data.day_info,daytype_component{i})) == 1);
    % Here it could be it!
    date = [];
    
    for jj = 1 : size(date_ind,2) / 720
        ii = jj * 720;
        date = [date; data.day_cell(date_ind(ii))];
    end
    daytype_m = data.segment_matrix(date_ind, :);
    day_agg = 1 : 720 : (size(daytype_m, 1));
    location_cd = zeros(1, 209);
    location_ct = zeros(1, 209);
    for location = 1 : 209
        data_plot = [];
        for j = 1 : (length(day_agg))
            star_day = day_agg(j);
            end_day = star_day + 719;
            temp = daytype_m(star_day : end_day, location)';
            data_plot = [data_plot; temp];
        end
        location_cd(location) = sum(sum(data_plot, 2) > 0) / (length(day_agg));
        location_ct(location) = sum(sum(data_plot)) * 2 / 60;
    end
    
    %% select group
    select_cd_index = find(location_cd > 0.5);
    ctm = mean(location_ct(select_cd_index));
    cts = std(location_ct(select_cd_index));
    high = find(location_cd > 0.5 & location_ct > ctm + 2 * cts);
    median = find(location_cd > 0.5 & location_ct > ctm & location_ct < ctm + cts);
    low = find(location_cd < 0.5 & location_ct < ctm);
    
    groups = [16, 16, low(1)];
    
    detail(i,1:2) = [mean(location_cd) std(location_cd)];
    detail(i,3:4) = [mean(location_ct) std(location_ct)];
    detail(i,5:10) = [location_cd(high(1)) location_ct(high(1)) location_cd(median(1)) location_ct(median(1)) location_cd(low(1)) location_ct(low(1))];
    %% select group
    levels_names={'high'};
    data_to_agg = data.segment_matrix(date_ind, :);
    l = 1;
    data_plot = [];
    day_agg = 1 : 720 : (size(data_to_agg, 1) + 1);
    for j = 1 : (length(day_agg) - 1)
        star_day = day_agg(j);
        end_day = day_agg(j + 1) - 1;
        temp = data_to_agg(star_day : end_day, groups(l))';
        data_plot = [data_plot; temp];
    end
    
    check_congestion_occ_day = sum(data_plot, 2) > 0;
    
    %% Plot the intensity function
        figure('Position', [40, 80, 9000, 250], 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8,8])
        set(gcf,'color',[1 1 1])
        set(gca, 'LineWidth', 4)
        Intensity_plot = sum(data_plot, 1) / size(data_plot, 1);
        Intensity_plot_m = [];
        for j = 1 : 144
            start = (j - 1) * 5 +1;
            ends = start + 4;
            Intensity_plot_m = [Intensity_plot_m mean(Intensity_plot(start : ends))];
        end
        
        h1 = plot(1 : 144, Intensity_plot_m, 'LineWidth', 3.5', 'color', 'b');
        set(gca, 'FontSize', 20)
        set(gca,'box','on','layer','top','TickDir','in');
        set(gca,'XTick',0 : 6 : 144);
        set(gca,'XTickLabel', {0 : 1 : 24})
        
        ax = gca;
        ax.XAxis.MinorTick = 'on';
        ax.XAxis.MinorTickValues = 0 : 3 : 144;
        ax.XMinorGrid = 'on';
        ax.TickDir = 'out';
        ax.TickLength = [0.01 0.01];
        ax.LineWidth = 1.5;
        
        xlim([0,144])
        ypdf_high = max(Intensity_plot) + 0.05;
        ylim([-0.01, ypdf_high])
        ylabel('Intensity','FontSize',25);
        xlabel('Time (hr)','FontSize',25);
        
        llname = sprintf('\\color{gray} %s, Loc.ID=%d', names{i}, groups(l));
        h = legend(h1([1]),llname);
        set(h,'Fontsize', 13);
        legend('boxoff')
        
        picnames=sprintf('%s/intensity_%s',make_floder,names{i});
        K = getframe(gcf);
        temp =frame2im(K) ;
        imwrite(temp, [picnames '.png'])
        
        %% Randomly select the n locations where no contain missing data or not published any congestion information
        picture_matrix=[];
        index_day=[];
        for ll = 1 : size(data_plot, 1)
            if sum(data_plot(ll, :), 2) > 5
                index_day = [index_day ll];
            end
        end
        index_day = sort(randsample(index_day, 50));
        
        for dday = 1 : length(index_day)
            figure('Position', [40, 80, 9000, 30], 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8,8])
            set(gcf,'color',[1 1 1])
            if dday ~= length(index_day)
                for ts = 1 : 720
                    if data_plot(index_day(dday), ts) > 0
                        plot([ts ts],[0 0.4],'color', [0.6 0 0.2],'linestyle','-','LineWidth',2')
                        hold on
                    end
                end
                ax = gca;
                ax.XAxis.MinorTick = 'on';
                ax.XAxis.MinorTickValues = 0 : 15 : 720;
                ax.XMinorGrid = 'on';
                ax.TickDir = 'out';
                ax.TickLength = [0.01 0.01];
                ax.LineWidth = 0.5;
                ylim([0,0.4]);
                xlim([0,720]);
                set(gca, 'LineWidth', 1)
                replace_word = sprintf('%d/',year);
                % there is a bug here, I don't know only the 2571 will
                % encounter the problem
                newStr = strrep(date{index_day(dday)}, replace_word,'');
                set(gca,'XTick',0:30:720,'XTickLabel',[]);
                %                 set(gca,'LooseInset',get(gca,'TightInset'))
                set(gca,'YTick',0.4, 'YTickLabel',newStr,'FontSize', 18);
                set(gca,'box','off','layer','top','TickDir','out');
                %                 if check_congestion_occ_day(dday)==1
                ax.YTickLabel = ['\color{black}' ax.YTickLabel];
                %                 end
                ax.MinorGridColor = [0 0 0];
                F = getframe(gcf);
                temp =frame2im(F) ;
                picture_matrix=[picture_matrix;temp];
            else
                figure('Position', [40, 80, 9000, 100], 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8,8])
                set(gcf,'color',[1 1 1])
                for ts=1:720
                    if data_plot(index_day(dday),ts)>0
                        plot([ts ts],[0 0.4],'color', [0.6 0 0.2],'linestyle','-','LineWidth',2')
                        hold on
                    else
                        %                         plot(ts,data_plot(index_day(dday),ts),'k.','LineWidth',4')
                        %                         plot(ts,  0,'k.')
                        hold on
                    end
                end
                ax = gca;
                ax.XAxis.MinorTick = 'on';
                ax.XAxis.MinorTickValues = 0:15:720;
                ax.XMinorGrid = 'on';
                ax.TickDir = 'out';
                ax.TickLength = [0.01 0.01];
                ax.LineWidth = 0.5;
                ylim([0,0.4]);
                xlim([0,720]);
                set(gca, 'LineWidth', 1)
                newStr = strrep(date{index_day(dday)}, replace_word,'');
                set(gca,'XTick',0:30:720,'XTickLabel',0 : 1 : 24,'FontSize', 30);
                set(gca,'YTick',0.4, 'YTickLabel',newStr,'FontSize', 18);
                set(gca,'box','off','layer','top','TickDir','out');
                %                 if check_congestion_occ_day(dday)==1
                ax.YTickLabel = ['\color{black}' ax.YTickLabel];
                %                 end
                %                 set(gca,'LooseInset',get(gca,'TightInset'))
                %                 end
                ax.MinorGridColor = [0 0 0];
                xlabel('Time (hr)','FontSize',20);
                F = getframe(gcf);
                temp =frame2im(F) ;
                picture_matrix = [picture_matrix; temp];
            end
        end
        picnames=sprintf('%s/pointprocess_%s',make_floder,names{i});
        imwrite(picture_matrix, [picnames '.png'])
        close all
end