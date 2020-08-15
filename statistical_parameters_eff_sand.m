%% STATISTICAL PARAMETERS IN SAND COLUMN EFFLUENT
clear all
close all
clc
%% 1. Load data and labeling
sand=open('eff_sand.mat');
%Remove field from structure
sand=rmfield(sand,'do_sand_eff');
%Call fields in loop
field_sand={'uva254_sand', 'doc_sand', 'benzo_sand', 'carba_sand', 'diclo_sand', 'gaba_sand'};
%Headers
var_sand={'UVA 254 [1/m]', 'DOC [mg/L]', 'Benzotriazole [ng/L]', 'Carbamazepine [ng/L]'...
    , 'Diclofenac [ng/L]', 'Gabapentin [ng/L]'};
%Headers
par_sand={'Variable' 'Mean value' 'Standard deviation' 'c.o.v' 'Data points'};
%Strings for plot titles
name_plot_sand={'UVA 254 Sand', 'DOC Sand', 'Benzotriazole Sand',...
    'Carbamazepine Sand', 'Diclofenac Sand', 'Gabapentin Sand'};
%Strings for y axis
units={'[1/m]', '[mg/L]', '[ng/L]', '[ng/L]', '[ng/L]', '[ng/L]'};

%% 2. Excel file
%Name of Excel file
filename='matlab_statistical_parameters.xlsx';
%Sheet in Excel file
sheet=1;

%% 3. Computations
%Loop to calculate statistical parameters (mean, std, c.o.v)
for i=1:length(field_sand)
    par_sand(i+1,:)={var_sand(i), mean(sand.(field_sand{i}){2}), std(sand.(field_sand{i}){2})...
        , std(sand.(field_sand{i}){2})/mean(sand.(field_sand{i}){2})...
        , length(sand.(field_sand{i}){2})};
end

%Loop for scatters of concentration vs. dates
figure('Name', 'Scatter - Sand column', 'NumberTitle', 'off');
for i=1:length(field_sand)
    subplot(2,3,i)
    scatter(datenum(sand.(field_sand{i}){1},'yyyy-mm-dd'),sand.(field_sand{i}){2});
    title(name_plot_sand(i));
    xlabel('Date');
    ylabel(units(i));
end
%Store only values from summary table
excel_par_sand=par_sand(2:end,2:end);
%Store statistical parameters in an Excel file
xlswrite(filename,excel_par_sand,sheet,'B2');