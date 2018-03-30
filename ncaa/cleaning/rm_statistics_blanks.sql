begin;

delete from ncaa.statistics
where
  player_id=0;

commit;
