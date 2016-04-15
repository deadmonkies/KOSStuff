// Hillclimber
// Andy Greenwood, based on work by Kevin Gisi
// version 0.1.0

{
  local INFINITY is 2^64.
  local DEFAULT_STEP_SIZE is 1.
  
  global hillclimb is lex(
    "version", "0.1.0",
	"seek", seek@
  ).
  
  function seek {
    // main seeking loop
	parameter data, fitness_fn, step_size is DEFAULT_STEP_SIZE.
	local next_data is best_neighbor(data, fitness_fn, step_size).
	print "entering seek loop".
	
	switch to 0.
	log "calling fitness_fn with next_data:" + next_data:dump to "hillclimb.deb".
	switch to 1.

	switch to 0.
	log "calling fitness_fn with data:" + data:dump to "hillclimb.deb".
	switch to 1.
	
	until fitness_fn(next_data) < fitness_fn(data) {
	  set data to next_data.
	  set next_data to best_neighbor(data, fitness_fn, step_size).
	}
	return data.
  }
  
  function best_neighbor {
    parameter data, fitness_fn, step_size.
	local best_fitness is -INFINITY.
	local best is 0.
	for neighbor in neighbors(data, step_size) {
	
  	  switch to 0.
	  log "calling fitness_fn with neighbor:" + neighbor:dump to "hillclimb.deb".
	  switch to 1.
	  
	  local fitness is fitness_fn(neighbor).
	  if fitness > best_fitness {
	    set best to neighbor.
		set best_fitness to fitness.
		
		switch to 0.
		log "current best is " + best:dump to "hillclimb_best.deb".
		log "current best_fitness is " + best_fitness to "hillclimb_best.deb".
		switch to 1.
	  }
	}
	print best:dump.
	return best.
  }
  
  function neighbors {
    parameter data, step_size, results is list().
	for i in range(0, data:length) {
	  local increment is data:copy.
	  local decrement is data:copy.
	  set increment[i] to increment[i] + step_size.
	  set decrement[i] to decrement[i] - step_size.
	  results:add(increment).
	  results:add(decrement).
	}
	return results.
  }
}