%% CORRELATIONS AND SCATTER PLOTS BETWEEN ANTHRACITE AND SAND COLUMNS EFFLUENTS
clear all
close all
clc
%% 1. Load data of anthracite effluent, anthracite column effluent and delta DO in anthracite column
%Data sets
ant=open('eff_ant.mat');
sand=open('eff_sand.mat');
delta_sand=open('do_consump.mat');
ant.delta_do_sand=delta_sand.delta_do_sand;
sand.delta_do_sand=delta_sand.delta_do_sand;

%Call fields in loop to enter structures
field_ant_delta={'uva254_ant', 'doc_ant', 'benzo_ant', 'carba_ant', 'diclo_ant'...
    , 'gaba_ant', 'delta_do_sand'};
field_sand={'uva254_sand', 'doc_sand', 'benzo_sand', 'carba_sand', 'diclo_sand', 'gaba_sand'...
    , 'delta_do_sand'};

%Axis of subplots
axis_plot_ant_delta={'UVA 254 - Ant [1/m]', 'DOC - Ant [mg/L]'...
    , 'Benzotriazole - Ant [ng/L]', 'Carbamazepine - Ant [ng/L]'...
    , 'Diclofenac - Ant [ng/L]', 'Gabapentin - Ant [ng/L]'...
    , '\DeltaDO - Sand [mg/L]'};
axis_plot_sand={'UVA 254 - Sand [1/m]', 'DOC - Sand [mg/L]',...
    'Benzotriazole - Sand [ng/L]', 'Carbamazepine - Sand [ng/L]'...
    , 'Diclofenac - Sand [ng/L]', 'Gabapentin - Sand [ng/L]'...
    , '\DeltaDO - Sand [mg/L]'};
%Titles subplots
title_figure_ant_delta={'UVA 254 (Anthracite)', 'DOC (Anthracite)'...
    , 'Benzotriazole (Anthracite)', 'Carbamazepine (Anthracite)'...
    , 'Diclofenac (Anthracite)', 'Gabapentin (Anthracite)'...
    , 'DO consumption (Sand)'};
title_subplot_ant_delta={'UVA 254 (Ant)', 'DOC (Ant)'...
    , 'Benzotriazole (Ant)', 'Carbamazepine (Ant)'...
    , 'Diclofenac (Ant)', 'Gabapentin (Ant)'...
    , '\DeltaDO (Sand)'};
title_subplot_sand={'UVA 254 (Sand)', 'DOC (Sand)',...
    'Benzotriazole (Sand)', 'Carbamazepine (Sand)'...
    , 'Diclofenac (Sand)', 'Gabapentin (Sand)'...
    , '\DeltaDO (Sand)'};
%Numbering of figures
prefix_figure={'a)', 'b)', 'c)', 'd)', 'e)', 'f)', 'g)'};

%% 2. Excel file
%Name of Excel file
filename='matlab_correlations_ant_sand.xlsx';
%Sheet in Excel file
sheet=1;
%Positions in Excel file
position={'B3', 'F3', 'J3', 'N3', 'B13', 'F13', 'J13'};

%% 3. Computations
for i=1:length(field_ant_delta)
    figure('Name', strcat('Scatter -',32,title_figure_ant_delta{i}), 'NumberTitle', 'off');
    for j=1:length(field_sand)
        %Find mutual dates
        if length(sand.(field_sand{j}){1})<length(ant.(field_ant_delta{i}){1})
            dates_ant.(field_ant_delta{i}).(field_sand{j})=sand.(field_sand{j}){1}(find(...
                ismember(datetime(sand.(field_sand{j}){1}),datetime(ant.(field_ant_delta{i}){1}),'rows')));
        else
            dates_ant.(field_ant_delta{i}).(field_sand{j})=ant.(field_ant_delta{i}){1}(find(...
                ismember(datetime(ant.(field_ant_delta{i}){1}),datetime(sand.(field_sand{j}){1}),'rows')));
        end
        %Select data with matching dates
        x=ant.(field_ant_delta{i}){2}(find(ismember(datetime(ant.(field_ant_delta{i}){1}),...
            datetime(dates_ant.(field_ant_delta{i}).(field_sand{j})),'rows')));
        y=sand.(field_sand{j}){2}(find(ismember(datetime(sand.(field_sand{j}){1}),...
            datetime(dates_ant.(field_ant_delta{i}).(field_sand{j})),'rows')));
        %Calculate correlation coefficient
        z=corr([x y]);
        correlation_ant_delta.(field_ant_delta{i}).(field_sand{j})=z(2);
        data_points.(field_ant_delta{i}).(field_sand{j})=length(dates_ant.(field_ant_delta{i}).(field_sand{j}));
        data_excel_ant_sand.(field_ant_delta{i})(1,j)=z(2);
        %Store structure - the order of the table is the same as the order
        %of the stored variables
        data_excel_ant_sand.(field_ant_delta{i})(2,j)=length(dates_ant.(field_ant_delta{i}).(field_sand{j}));
        %Generate scatter plots between variables
        subplot(2,4,j);
        scatter(x,y)
        title(strcat(prefix_figure{j},32,title_subplot_ant_delta{i}...
            ,32,'-',32,title_subplot_sand{j}))
        xlabel(axis_plot_ant_delta{i})
        ylabel(axis_plot_sand{j})
    end
    data_excel_ant_sand.(field_ant_delta{i})=data_excel_ant_sand.(field_ant_delta{i})';
    %Store correlation coefficients in Excel file
    xlswrite(filename,data_excel_ant_sand.(field_ant_delta{i}),sheet,position{i});
end