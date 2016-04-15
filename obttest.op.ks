// orbiter startup script
// Andy Greenwood
// Based on work by Kevin Gisi

{
 for dependency in list(
   "hillclimb.ks",
   "ascent.ks",
   "ascent_finder.ks"
 ) if not exists(dependency) copy dependency from 0.
 
  run hillclimb.ks.
  run ascent.ks.
  run ascent_finder.ks.
  
  ascent_finder["seek"]().
}