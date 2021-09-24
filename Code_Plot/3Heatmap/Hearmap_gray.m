%前面的1)和2)因為和clustering的結果沒有關係
%如果之後要跑的話就回去plot_all_20200828的檔案的最前面跑就可以了！

%% 3) fitted_y (run this after the CMS_KCFC)
% load detail data
make_floder = sprintf('plot');
mkdir(make_floder);

%直接改這個data_sets就可以了
%然後一次跑一組data_sets
%跑出來的圖會全部都在make_floder的路徑之下
%全部複製貼上到mac快捷路徑上面中plot20200811然後用.tex檔案把圖print出來

data_sets = {
    'detail_weekday_7'
    'detail_holiday_5'
};

for names_set_i = 1 : 2
data = load(sprintf('%s.mat',data_sets{names_set_i}));

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
    
    %%
%     color_heatmap=[
%         %最高的部分
%         1 0 0;
%         1 0.4 0;
%         1 0.8 0;
%         0.4 1 0.4;
%         
%         0 0.6 0.2
%         
%         0 1 1 ;
%         0 0.4 1;
%         0 0 1;
%         
%         170/255 170/255 180/255;
%         200/255 200/255 200/255
%         ];
    %
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
    picnames = sprintf('%s/heatmap_gray_grid_%s.eps', make_floder, data_sets{names_set_i});
    print('-depsc',picnames);
end
