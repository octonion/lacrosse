
-- Remove commas, convert to appropriate data type

begin;

update ncaa_pbp.player_summaries
set pen_time = replace(pen_time, ',', ''),
    g_min = replace(g_min, ',', ''),
    gaa = replace(gaa, ',', '');

-- Some pen_time entries use interval notation
-- Convert to minutes, recast back to text

update ncaa_pbp.player_summaries
set pen_time = (split_part(pen_time,':',1)::integer*60+
                split_part(pen_time,':',2)::integer)::text
where pen_time like '%:%';

-- Some g_min entries use interval notation
-- Convert to minutes, recast back to text

update ncaa_pbp.player_summaries
set g_min = (split_part(g_min,':',1)::integer*60+
             split_part(g_min,':',2)::integer)::text
where g_min like '%:%';

alter table ncaa_pbp.player_summaries
  alter column pen_time
    type integer using (pen_time::integer);

alter table ncaa_pbp.player_summaries
  alter column g_min
    type integer using (g_min::integer);

alter table ncaa_pbp.player_summaries
  alter column gaa
    type float using (gaa::float);

commit;
