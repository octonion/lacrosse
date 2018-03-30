begin;

-- Add primary key to cleaned statistics table

alter table ncaa.statistics
add primary key (year,player_id);

commit;
