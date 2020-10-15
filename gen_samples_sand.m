tic
clear all
close all
clc
%Run time: 144.88s with n_samples=1e5
%% 1. Load data
ant=open('eff_ant.mat');
sand=open('eff_sand.mat');
delta_sand=open('do_consump.mat');
sand.delta_do_sand=delta_sand.delta_do_sand;
ant.delta_do_sand=delta_sand.delta_do_sand;
%Remove field from structure
ant=rmfield(ant,'do_ant');
%Number of random samples
n_samples=1e4;

%% 2. Excel file
%Name of Excel file
filename='samples_sand.xlsx';

%% 3. Nodes with 2 parents (DOC)
field_2parents={'doc_sand','delta_do_sand'};
parents.delta_do_sand={'uva254_ant','doc_ant'};
parents.doc_sand={'uva254_ant','doc_ant'};
%Order of distributions: child, then parents (ordered as in structure
%parents.PARAMETER)
distribution.delta_do_sand={'GEV','lognormal','GEV'};
distribution.doc_sand={'GEV','lognormal','GEV'};

for i=1:length(field_2parents)
    for j=1:length(parents.(field_2parents{i}))
        %Find mutual dates between parents
        dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){j})=...
            sand.(field_2parents{i}){1}(find(ismember...
            (datetime(sand.(field_2parents{i}){1}),...
            datetime(ant.(parents.(field_2parents{i}){j}){1}),'rows')));
    end
    %Find mutual dates with child node
    if length(dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){1}))<...
            length(dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){2}))
        
        dates.(field_2parents{i})=dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){1})...
            (find(ismember(datetime(dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){1}))...
            ,datetime(dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){2})),'rows')));
    else
        dates.(field_2parents{i})=dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){2})...
            (find(ismember(datetime(dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){2}))...
            ,datetime(dates_parents.(field_2parents{i}).(parents.(field_2parents{i}){1})),'rows')));
    end
    %Extract child node values to their corresponding mutual dates between
    %the 3 nodes
    data_nataf.(field_2parents{i}).(field_2parents{i})=sand.(field_2parents{i}){2}...
        (find(ismember(datetime(sand.(field_2parents{i}){1})...
        ,datetime(dates.(field_2parents{i})),'rows')));
    %Extract parent nodes values to their corresponding mutual dates between
    %the 3 nodes
    for j=1:length(parents.(field_2parents{i}))
        data_nataf.(field_2parents{i}).(parents.(field_2parents{i}){j})=...
            ant.(parents.(field_2parents{i}){j}){2}...
            (find(ismember(datetime(ant.(parents.(field_2parents{i}){j}){1})...
            ,datetime(dates.(field_2parents{i})),'rows')));
    end
    %Computation of correlation matrix
    %Set matrix with entries of parents and child (child in the first column)
    set_rho.(field_2parents{i})=[data_nataf.(field_2parents{i}).(field_2parents{i})...
        ,data_nataf.(field_2parents{i}).(parents.(field_2parents{i}){1})...
        ,data_nataf.(field_2parents{i}).(parents.(field_2parents{i}){2})];
    columns=size(set_rho.(field_2parents{i}));
    st_dev=std(set_rho.(field_2parents{i}));
    %Loop to compute correlation matrix - Rho
    for j=1:columns(2)
        si=mean(set_rho.(field_2parents{i})(:,j));
        for k=1:columns(2)
            no=mean(set_rho.(field_2parents{i})(:,k));
            a=sum((set_rho.(field_2parents{i})(:,j)-si).*(set_rho.(field_2parents{i})(:,k)-no));
            rho.(field_2parents{i})(k,j)=a/((length(set_rho.(field_2parents{i}))-1)...
                *st_dev(j)*st_dev(k));
        end
    end
    %Nataf transformation
    %Distribution fittings for Nataf transformation
    %Same order as distribution structure
    %Child
    fit_nataf.(field_2parents{i})(1)=ERADist(...
        distribution.(field_2parents{i}){1},'DATA',...
        data_nataf.(field_2parents{i}).(field_2parents{i}));
    %Parent 1
    fit_nataf.(field_2parents{i})(2)=ERADist(...
        distribution.(field_2parents{i}){2},'DATA',...
        data_nataf.(field_2parents{i}).(parents.(field_2parents{i}){1}));
    %Parent 2
    fit_nataf.(field_2parents{i})(3)=ERADist(...
        distribution.(field_2parents{i}){3},'DATA',...
        data_nataf.(field_2parents{i}).(parents.(field_2parents{i}){2}));
    %Apply Nataf transformation
    %Object with distribution fittings and correlation matrix Rho
    transf_nataf.(field_2parents{i})=ERANataf(fit_nataf.(field_2parents{i}),...
        rho.(field_2parents{i}));
    %Generate random samples
    set_nataf.(field_2parents{i})=transf_nataf.(field_2parents{i}).random(n_samples)';
    %Avoid having negative quantities
    set_nataf.(field_2parents{i})(find(set_nataf.(field_2parents{i})<=0))=0;
    %Samples child
    samples_sand.(field_2parents{i}).(field_2parents{i})=set_nataf.(field_2parents{i})(:,1);
    %Samples parent 1
    samples_sand.(field_2parents{i}).(parents.(field_2parents{i}){1})=...
        set_nataf.(field_2parents{i})(:,2);
    %Samples parent 2
    samples_sand.(field_2parents{i}).(parents.(field_2parents{i}){2})=...
        set_nataf.(field_2parents{i})(:,3);
    %Matrix with values of samples, ordered as vector of field_data
    genie_samples=[samples_sand.(field_2parents{i}).(field_2parents{i})...
        ,samples_sand.(field_2parents{i}).(parents.(field_2parents{i}){1})...
        ,samples_sand.(field_2parents{i}).(parents.(field_2parents{i}){2})];
    %Save headers in Excel file
    xlswrite(filename,field_2parents(i),i,'A1');
    xlswrite(filename,parents.(field_2parents{i}),i,'B1');
    %Save values in Excel file
    xlswrite(filename,string(genie_samples),i,'A2');
end

%% 4. Nodes with 3 parents (UVA254)
field_3parents={'uva254_sand'};
parents.uva254_sand={'delta_do_sand','uva254_ant','doc_ant'};
%Order of distributions: child, then parents (ordered as in structure
%parents.PARAMETER)
distribution.uva254_sand={'GEV','GEV','lognormal','GEV'};

for i=1:length(field_3parents)
    for j=1:length(parents.(field_3parents{i}))
        %Find mutual dates between parents
        dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){j})=...
            sand.(field_3parents{i}){1}(find(ismember...
            (datetime(sand.(field_3parents{i}){1}),...
            datetime(ant.(parents.(field_3parents{i}){j}){1}),'rows')));
    end
    %Find mutual dates with first two parents
    if length(dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){1}))<...
            length(dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){2}))
        
        dates_3parents.(field_3parents{i})=...
            dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){1})...
            (find(ismember(datetime(dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){1}))...
            ,datetime(dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){2})),'rows')));
    else
        dates_3parents.(field_3parents{i})=...
            dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){2})...
            (find(ismember(datetime(dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){2}))...
            ,datetime(dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){1})),'rows')));
    end
    %Common dates between the 4 nodes
    dates.(field_3parents{i})=dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){3})...
        (find(ismember(datetime(dates_parents.(field_3parents{i}).(parents.(field_3parents{i}){3}))...
            ,datetime(dates_3parents.(field_3parents{i})),'rows')));
    %Extract child node values to their corresponding mutual dates between
    %the 4 nodes
    data_nataf.(field_3parents{i}).(field_3parents{i})=sand.(field_3parents{i}){2}...
        (find(ismember(datetime(sand.(field_3parents{i}){1})...
        ,datetime(dates.(field_3parents{i})),'rows')));
    %Extract parent nodes values to their corresponding mutual dates between
    %the 4 nodes
    for j=1:length(parents.(field_3parents{i}))
        data_nataf.(field_3parents{i}).(parents.(field_3parents{i}){j})=...
            ant.(parents.(field_3parents{i}){j}){2}...
            (find(ismember(datetime(ant.(parents.(field_3parents{i}){j}){1})...
            ,datetime(dates.(field_3parents{i})),'rows')));
    end
    %Computation of correlation matrix
    %Set matrix with entries of parents and child (child in the first column)
    set_rho.(field_3parents{i})=[data_nataf.(field_3parents{i}).(field_3parents{i})...
        ,data_nataf.(field_3parents{i}).(parents.(field_3parents{i}){1})...
        ,data_nataf.(field_3parents{i}).(parents.(field_3parents{i}){2})...
        ,data_nataf.(field_3parents{i}).(parents.(field_3parents{i}){3})];
    columns=size(set_rho.(field_3parents{i}));
    st_dev=std(set_rho.(field_3parents{i}));
    %Loop to compute correlation matrix - Rho
    for j=1:columns(2)
        si=mean(set_rho.(field_3parents{i})(:,j));
        for k=1:columns(2)
            no=mean(set_rho.(field_3parents{i})(:,k));
            a=sum((set_rho.(field_3parents{i})(:,j)-si).*(set_rho.(field_3parents{i})(:,k)-no));
            rho.(field_3parents{i})(k,j)=a/((length(set_rho.(field_3parents{i}))-1)...
                *st_dev(j)*st_dev(k));
        end
    end
    %Nataf transformation
    %Distribution fittings for Nataf transformation
    %Same order as distribution structure
    %Child
    fit_nataf.(field_3parents{i})(1)=ERADist(...
        distribution.(field_3parents{i}){1},'DATA',...
        data_nataf.(field_3parents{i}).(field_3parents{i}));
    %Parent 1
    fit_nataf.(field_3parents{i})(2)=ERADist(...
        distribution.(field_3parents{i}){2},'DATA',...
        data_nataf.(field_3parents{i}).(parents.(field_3parents{i}){1}));
    %Parent 2
    fit_nataf.(field_3parents{i})(3)=ERADist(...
        distribution.(field_3parents{i}){3},'DATA',...
        data_nataf.(field_3parents{i}).(parents.(field_3parents{i}){2}));
    %Parent 3
    fit_nataf.(field_3parents{i})(4)=ERADist(...
        distribution.(field_3parents{i}){4},'DATA',...
        data_nataf.(field_3parents{i}).(parents.(field_3parents{i}){3}));
    %Apply Nataf transformation
    %Object with distribution fittings and correlation matrix Rho
    transf_nataf.(field_3parents{i})=ERANataf(fit_nataf.(field_3parents{i}),...
        rho.(field_3parents{i}));
    %Generate random samples
    set_nataf.(field_3parents{i})=transf_nataf.(field_3parents{i}).random(n_samples)';
    %Avoid having negative quantities
    set_nataf.(field_3parents{i})(find(set_nataf.(field_3parents{i})<=0))=0;
    %Samples child
    samples_sand.(field_3parents{i}).(field_3parents{i})=set_nataf.(field_3parents{i})(:,1);
    %Samples parent 1
    samples_sand.(field_3parents{i}).(parents.(field_3parents{i}){1})=...
        set_nataf.(field_3parents{i})(:,2);
    %Samples parent 2
    samples_sand.(field_3parents{i}).(parents.(field_3parents{i}){2})=...
        set_nataf.(field_3parents{i})(:,3);
    %Samples parent 3
    samples_sand.(field_3parents{i}).(parents.(field_3parents{i}){3})=...
        set_nataf.(field_3parents{i})(:,4);
    %Matrix with values of samples, ordered as vector of field_data
    genie_samples=[samples_sand.(field_3parents{i}).(field_3parents{i})...
        ,samples_sand.(field_3parents{i}).(parents.(field_3parents{i}){1})...
        ,samples_sand.(field_3parents{i}).(parents.(field_3parents{i}){2})...
        ,samples_sand.(field_3parents{i}).(parents.(field_3parents{i}){3})];
    %Save headers in Excel file
    xlswrite(filename,field_3parents(i),i+length(field_2parents),'A1');
    xlswrite(filename,parents.(field_3parents{i}),i+length(field_2parents),'B1');
    %Save values in Excel file
    xlswrite(filename,string(genie_samples),i+length(field_2parents),'A2');
end

%% 5. Nodes with 4 parents (benzo, diclo and gaba)
field_4parents={'benzo_sand','diclo_sand','gaba_sand'};
parents.benzo_sand={'delta_do_sand','uva254_ant','doc_ant','benzo_ant'};
parents.diclo_sand={'delta_do_sand','uva254_ant','doc_ant','diclo_ant'};
parents.gaba_sand={'delta_do_sand','uva254_ant','doc_ant','gaba_ant'};
%Order of distributions: child, then parents (ordered as in structure
%parents.PARAMETER)
distribution.benzo_sand={'lognormal','GEV','lognormal','GEV','lognormal'};
distribution.diclo_sand={'lognormal','GEV','lognormal','GEV','lognormal'};
distribution.gaba_sand={'gamma','GEV','lognormal','GEV','lognormal'};

for i=1:length(field_4parents)
    for j=1:length(parents.(field_4parents{i}))
        %Find mutual dates between parents and child
        dates_parents.(field_4parents{i}).(parents.(field_4parents{i}){j})=...
            sand.(field_4parents{i}){1}(find(ismember...
            (datetime(sand.(field_4parents{i}){1}),...
            datetime(ant.(parents.(field_4parents{i}){j}){1}),'rows')));
        %Matrix to store length of date vector and their corresponding
        %parameters
        x(1,j)=length(dates_parents.(field_4parents{i}).(parents.(field_4parents{i}){j}));
        y(1,j)={(parents.(field_4parents{i}){j})};
    end
    %Parameter with the least number of dates
    dummy_date=y(find(x==min(x)));
    dates_parents_dummy=dates_parents;
    for k=1:length(parents.(field_4parents{i}))
        for j=1:length(parents.(field_4parents{i}))
            %Find mutual dates between the parents
            dates_4parents.(field_4parents{i}).(parents.(field_4parents{i}){j})=...
                ant.(parents.(field_4parents{i}){j}){1}(find(ismember(datetime...
                (ant.(parents.(field_4parents{i}){j}){1}),...
                datetime(dates_parents_dummy.(field_4parents{i}).(dummy_date{1})),'rows')));
            %Matrix to store length of date vector and their corresponding
            %parameters
            x(1,j)=length(dates_4parents.(field_4parents{i}).(parents.(field_4parents{i}){j}));
            y(1,j)={(parents.(field_4parents{i}){j})};
        end
        %Date with the least number of matching dates
        dummy_date=y(find(x==min(x)));
        dates_parents_dummy=dates_4parents;
    end
    dates_4parents=dates_parents_dummy;
    %Common dates between the 5 nodes
    dates.(field_4parents{i})=dates_4parents.(field_4parents{i}).(dummy_date{1});
    %Extract child node values to their corresponding mutual dates between
    %the 5 nodes
    data_nataf.(field_4parents{i}).(field_4parents{i})=sand.(field_4parents{i}){2}...
        (find(ismember(datetime(sand.(field_4parents{i}){1})...
        ,datetime(dates.(field_4parents{i})),'rows')));
    %Extract parent nodes values to their corresponding mutual dates between
    %the 5 nodes
    for j=1:length(parents.(field_4parents{i}))
        data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){j})=...
            ant.(parents.(field_4parents{i}){j}){2}...
            (find(ismember(datetime(ant.(parents.(field_4parents{i}){j}){1})...
            ,datetime(dates.(field_4parents{i})),'rows')));
    end
    %Computation of correlation matrix
    %Set matrix with entries of parents and child (child in the first column)
    set_rho.(field_4parents{i})=[data_nataf.(field_4parents{i}).(field_4parents{i})...
        ,data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){1})...
        ,data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){2})...
        ,data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){3})...
        ,data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){4})];
    columns=size(set_rho.(field_4parents{i}));
    st_dev=std(set_rho.(field_4parents{i}));
    %Loop to compute correlation matrix - Rho
    for j=1:columns(2)
        si=mean(set_rho.(field_4parents{i})(:,j));
        for k=1:columns(2)
            no=mean(set_rho.(field_4parents{i})(:,k));
            a=sum((set_rho.(field_4parents{i})(:,j)-si).*(set_rho.(field_4parents{i})(:,k)-no));
            rho.(field_4parents{i})(k,j)=a/((length(set_rho.(field_4parents{i}))-1)...
                *st_dev(j)*st_dev(k));
        end
    end
    %Nataf transformation
    %Distribution fittings for Nataf transformation
    %Same order as distribution structure
    %Child
    fit_nataf.(field_4parents{i})(1)=ERADist(...
        distribution.(field_4parents{i}){1},'DATA',...
        data_nataf.(field_4parents{i}).(field_4parents{i}));
    %Parent 1
    fit_nataf.(field_4parents{i})(2)=ERADist(...
        distribution.(field_4parents{i}){2},'DATA',...
        data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){1}));
    %Parent 2
    fit_nataf.(field_4parents{i})(3)=ERADist(...
        distribution.(field_4parents{i}){3},'DATA',...
        data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){2}));
    %Parent 3
    fit_nataf.(field_4parents{i})(4)=ERADist(...
        distribution.(field_4parents{i}){4},'DATA',...
        data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){3}));
    %Parent 4
    fit_nataf.(field_4parents{i})(5)=ERADist(...
        distribution.(field_4parents{i}){5},'DATA',...
        data_nataf.(field_4parents{i}).(parents.(field_4parents{i}){4}));
    %Apply Nataf transformation
    %Object with distribution fittings and correlation matrix Rho
    transf_nataf.(field_4parents{i})=ERANataf(fit_nataf.(field_4parents{i}),...
        rho.(field_4parents{i}));
    %Generate random samples
    set_nataf.(field_4parents{i})=transf_nataf.(field_4parents{i}).random(n_samples)';
    %Avoid having negative quantities
    set_nataf.(field_4parents{i})(find(set_nataf.(field_4parents{i})<=0))=0;
    %Samples child
    samples_sand.(field_4parents{i}).(field_4parents{i})=set_nataf.(field_4parents{i})(:,1);
    %Samples parent 1
    samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){1})=...
        set_nataf.(field_4parents{i})(:,2);
    %Samples parent 2
    samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){2})=...
        set_nataf.(field_4parents{i})(:,3);
    %Samples parent 3
    samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){3})=...
        set_nataf.(field_4parents{i})(:,4);
    %Samples parent 4
    samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){4})=...
        set_nataf.(field_4parents{i})(:,5);
        %Matrix with values of samples, ordered as vector of field_data
    genie_samples=[samples_sand.(field_4parents{i}).(field_4parents{i})...
        ,samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){1})...
        ,samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){2})...
        ,samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){3})...
        ,samples_sand.(field_4parents{i}).(parents.(field_4parents{i}){4})];
    %Save headers in Excel file
    xlswrite(filename,field_4parents(i),i+length(field_2parents)+length(field_3parents)...
        ,'A1');
    xlswrite(filename,parents.(field_4parents{i}),i+length(field_2parents)+length(field_3parents)...
        ,'B1');
    %Save values in Excel file
    xlswrite(filename,string(genie_samples),i+length(field_2parents)+length(field_3parents)...
        ,'A2');
end
%Save file
save('samples_sand','samples_sand')
toc