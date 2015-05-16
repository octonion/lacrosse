begin;

create index pk_idx
on ncaa_pbp.box_scores (game_id,section_id,player_name,position);

delete from ncaa_pbp.box_scores bs
where bs.ctid <>
(select min(dup.ctid)
 from ncaa_pbp.box_scores dup
 where (dup.game_id,dup.section_id,dup.player_name,dup.position) =
       (bs.game_id,bs.section_id,bs.player_name,bs.position)
);

drop index ncaa_pbp.pk_idx;

commit;
