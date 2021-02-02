case_timeseries_VIC = readtable('VIC_cases_per_day_2021_01_17.csv');
case_timeseries_NSW = readtable('new_cases_timeseries_NSW.csv');
c_dir = pwd;

nbn_dirname = [c_dir '\mean_daytime_VIC_NSW\'];

nbn_ds_net_filename = [nbn_dirname, 'mean_daytime_downstream_net_aus.csv'];
nbn_ds_filename = [nbn_dirname, 'mean_daytime_downstream_aus.csv'];
nbn_us_net_filename = [nbn_dirname, 'mean_daytime_upstream_net_aus.csv'];
nbn_us_filename = [nbn_dirname, 'mean_daytime_upstream_aus.csv'];

nbn_ds_net = readtable(nbn_ds_net_filename);
nbn_ds = readtable(nbn_ds_filename);
nbn_us_net = readtable(nbn_us_net_filename);
nbn_us = readtable(nbn_us_filename);


nbn_us_VIC = nbn_us(strcmp(nbn_us.state , 'VIC'), :);
nbn_us_NSW = nbn_us(strcmp(nbn_us.state, 'NSW'), :);
nbn_ds_VIC = nbn_ds(strcmp(nbn_ds.state, 'VIC'), :);
nbn_ds_NSW = nbn_ds(strcmp(nbn_ds.state, 'NSW'), :);

nbn_us_VIC = nbn_us(strcmp(nbn_us.state , 'VIC'), :);
nbn_us_NSW = nbn_us(strcmp(nbn_us.state, 'NSW'), :);
nbn_ds_VIC = nbn_ds(strcmp(nbn_ds.state, 'VIC'), :);
nbn_ds_NSW = nbn_ds(strcmp(nbn_ds.state, 'NSW'), :);

t1 = max([min(nbn_us_VIC.date); min(case_timeseries_NSW.date); min(case_timeseries_VIC.date)]);
tf = max(nbn_us_VIC.date);

interval = t1:tf;

cases_vic_wknd = NaN(size(interval, 2), 1);
ds_vic_wknd = NaN(size(interval, 2), 1);
us_vic_wknd = NaN(size(interval, 2), 1);
date_vic_wknd = interval';

cases_nsw_wknd = NaN(size(interval, 2), 1);
ds_nsw_wknd = NaN(size(interval, 2), 1);
us_nsw_wknd = NaN(size(interval, 2), 1);
date_nsw_wknd = interval';

for t_i = 1:numel(interval)
    
    date_t = interval(t_i);
    
        if ~isempty(case_timeseries_VIC.cases(case_timeseries_VIC.date == date_t))
            cases_vic_wknd(t_i, 1) = case_timeseries_VIC.cases(case_timeseries_VIC.date == date_t);
        end
        
        if ~isempty(nbn_ds_VIC.value(nbn_ds_VIC.date == date_t)) && isweekend(date_t)
            ds_vic_wknd(t_i, 1) = nbn_ds_VIC.value(nbn_ds_VIC.date == date_t);
        end
        
        if ~isempty(nbn_us_VIC.value(nbn_us_VIC.date == date_t)) && isweekend(date_t)
            us_vic_wknd(t_i, 1) =  nbn_us_VIC.value(nbn_us_VIC.date == date_t);
        end
        
        date_nsw_wknd(t_i, 1) = date_t;
        
        if ~isempty(case_timeseries_NSW.cases(case_timeseries_NSW.date == date_t))
            cases_nsw_wknd(t_i, 1) = case_timeseries_NSW.cases(case_timeseries_NSW.date == date_t);
        end
        
        if ~isempty(nbn_ds_NSW.value(nbn_ds_NSW.date == date_t)) && isweekend(date_t)
            ds_nsw_wknd(t_i, 1) = nbn_ds_NSW.value(nbn_ds_NSW.date == date_t);
        end
        
        if ~isempty(nbn_us_NSW.value(nbn_us_NSW.date == date_t)) && isweekend(date_t)
            us_nsw_wknd(t_i, 1) =  nbn_us_NSW.value(nbn_us_NSW.date == date_t);
        end
        
end

us_nsw_wknd_7day_avg = movmean(us_nsw_wknd, 7, 'omitnan');
us_vic_wknd_7day_avg = movmean(us_vic_wknd, 7, 'omitnan');
ds_nsw_wknd_7day_avg = movmean(ds_nsw_wknd, 7, 'omitnan');
ds_vic_wknd_7day_avg = movmean(ds_vic_wknd, 7, 'omitnan');
cases_nsw_wknd_7day_avg = movmean(cases_nsw_wknd, 7, 'omitnan');
cases_vic_wknd_7day_avg = movmean(cases_vic_wknd, 7, 'omitnan');

output = table(date_vic_wknd, cases_vic_wknd, ds_vic_wknd, us_vic_wknd, date_nsw_wknd, cases_nsw_wknd, ds_nsw_wknd, us_nsw_wknd);
output_7day_avg = table(us_nsw_wknd_7day_avg, us_vic_wknd_7day_avg, ds_nsw_wknd_7day_avg, ds_vic_wknd_7day_avg, cases_nsw_wknd_7day_avg, cases_vic_7day_avg);

writetable(output, 'timeseries_cases_ds_us_vic_nsw_minus_daily_minimum_weekends.csv')
writetable(output_7day_avg, 'timeseries_ds_us_vic_nsw_7day_avg_weekends.csv')




