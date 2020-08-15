%% DISTRIBUTION FITTINGS IN SAND COLUMN EFFLUENT
clear all
close all
clc
%% 1. Load sand effluent data and labeling
%Structure with data set
sand=open('eff_sand.mat');
%Remove unnecesary field from structure
sand=rmfield(sand,'do_sand_eff');
%Call fields in loop to enter structure
field_sand={'uva254_sand', 'doc_sand', 'benzo_sand', 'carba_sand', 'diclo_sand', 'gaba_sand'};
%Axis of subplots
axis_plot_sand={'UVA 254 - Sand [1/m]', 'DOC - Sand [mg/L]'...
    , 'Benzotriazole - Sand [ng/L]', 'Carbamazepine - Sand [ng/L]'...
    , 'Diclofenac - Sand [ng/L]', 'Gabapentin - Sand [ng/L]'};
%Titles subplots
title_figure_sand={'UVA 254 (Sand)', 'DOC (Sand)'...
    , 'Benzotriazole (Sand)', 'Carbamazepine (Sand)'...
    , 'Diclofenac (Sand)', 'Gabapentin (Sand)'};
%Headers of table with maximum likelihood estimation (MLE)
mle_sand={'Variable' 'Distribution' 'log(MLE)' 'Data points'};

%% 2. Fit distributions
dist={'Poisson'; 'Exponential'; 'Gamma'; 'ExtremeValue'...
    ; 'Weibull'; 'Rayleigh'; 'GeneralizedExtremeValue'...
    ; 'Normal'; 'Lognormal'};
%Stop run if number of distributions different than 9 - it will ruin the
%layout of the Excel file
if length(dist)~=9
    error('Vector "dist" must only contain 9 distributions - Check file and correct');
end
%String necessary to create a loop to evaluate distribution by distribution
rows=mod(length(dist),3);
if rows==1
    rows_plot=length(dist)/3+2/3;
elseif rows==2
    rows_plot=length(dist)/3+1/3;
else
    rows_plot=length(dist)/3;
end

%% 3. Excel file
%Name of Excel file
filename='matlab_distribution_fittings_eff_sand.xlsx';
%Sheet in Excel file
sheet=1;
%Positions in Excel file
position={'A9', 'D9', 'G9', 'J9', 'A20', 'D20', 'G20'};

%% 4. Computations
%Loop to fit distribution to all the variables of interest
for i=1:length(field_sand)
    %Title of figure
    figure('Name', strcat('Probability plot -',32,title_figure_sand{i}), 'NumberTitle', 'off');
    %Headers for tables with likelihood per variable
    like_var={strcat('Distribution -',32,title_figure_sand{i}), 'log(MLE)'};
    for j=1:length(dist)
        %Fit distribution and store
        data.(field_sand{i}).(dist{j})=fitdist(sand.(field_sand{i}){2}...
            ,dist{j});
        %Extract parameters from distribution fitting
        par.(field_sand{i}).(dist{j})=data.(field_sand{i}).(dist{j})...
            .ParameterValues;
        %Empty structure to be filled
        fit.(field_sand{i}).(dist{j})=zeros(1,length...
            (sand.(field_sand{i}){2}))';
        %Conditional statement for different number of parameters in a
        %distribution
        if length(par.(field_sand{i}).(dist{j}))==1  %Distributions with just 1 parameter
            fit.(field_sand{i}).(dist{j})=pdf(dist{j}, sand.(field_sand{i}){2}...
                , par.(field_sand{i}).(dist{j})(1));
        elseif length(par.(field_sand{i}).(dist{j}))==2  %Distributions with 2 parameters
            fit.(field_sand{i}).(dist{j})=pdf(dist{j}, sand.(field_sand{i}){2}...
                , par.(field_sand{i}).(dist{j})(1), par.(field_sand{i}).(dist{j})(2));
        elseif length(par.(field_sand{i}).(dist{j}))==3  %Distributions with 3 parameters
            fit.(field_sand{i}).(dist{j})=pdf(dist{j}, sand.(field_sand{i}){2}...
                , par.(field_sand{i}).(dist{j})(1), par.(field_sand{i}).(dist{j})(2)...
                , par.(field_sand{i}).(dist{j})(3));
        end
        %Compute likelihood per variable and fit distribution
        like.(field_sand{i}).(dist{j})=log(prod(fit.(field_sand{i}).(dist{j})));
        %Compute probability plots
        subplot(rows_plot,3,j);
        probplot(data.(field_sand{i}).(dist{j}),sand.(field_sand{i}){2});
        hold on
        title(strcat('Fitting -',32,dist{j}))
        xlabel(axis_plot_sand{i})
    end
    %Extract values of likelihood structure (like) and store them in a cell
    dummy_like.(field_sand{i})={dist cell2mat(struct2cell(like.(field_sand{i})))};
    %Loop to sort and store likelihood in descending order
    sort_like.(field_sand{i})=sort(dummy_like.(field_sand{i}){2},'descend');
    for k=1:length(dummy_like.(field_sand{i}){2})
        dummy_sort=find(sort_like.(field_sand{i})(k)==dummy_like.(field_sand{i}){2});
        %Structure to store likelihoods
        likelihood.(field_sand{i})(k,:)={dummy_like.(field_sand{i}){1}(dummy_sort)...
            ,dummy_like.(field_sand{i}){2}(dummy_sort)};
        %Tables with likelihoods per variable
        like_var(k+1,:)=likelihood.(field_sand{i})(k,:);
    end
    %Report MLEs in a table
    mle_sand(i+1,:)={title_figure_sand(i), likelihood.(field_sand{i}){1,1}...
        , likelihood.(field_sand{i}){1,2}, length(sand.(field_sand{i}){2})};
    %Store table with likelihoods per variable and distributions
    xlswrite(filename,string(like_var),sheet,position{i});
end
%Exclude headers
excel_mle_sand=mle_sand(2:end,2:end);
xlswrite(filename,string(excel_mle_sand),sheet,'B2');