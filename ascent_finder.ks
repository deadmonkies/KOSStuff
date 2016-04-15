// Ascent Finder
// Andy Greenwood
// Version 0.0.1

{
  local INFINITY IS 2^64.
  local TARGET_ALTITIDE is 100000.
  local COMPASS is 90.
  local TARGET_INCLINATION is 0.
  
  global ascent_finder is lex(
    "version", "0.0.1",
	"seek", seek@
  ).
  
  function seek {
	local data is starting_data().
	
	// seek ascent profile
	until 0 {
	  set data to hillclimb["seek"](data, ascent_fitness(), 1).
	}
  }
  
  function ascent_fitness {
    function fitness_fn {
	  parameter data.
	  // do the ascent
	  ascent["ascent"](TARGET_ALTITIDE, COMPASS, data[0], data[1], data[2], data[3]).
	  print "done with ascent".
	  // score the ascent
	  local score is score_orbit().
	  print "score is :" + score.
	  // log the ascent
	  switch to 0.
	  log score + "," + data[0] + "," + data[1] + "," + data[2] + "," + data[3] to "flightscores.csv".
	  switch to 1.
	  kuniverse:reverttolaunch().
	  return score.
	}
	return fitness_fn@.
  }
  
  function score_orbit {
    local fuel is 0.
	for resource in ship:resources {
	  if resource:name = "LiquidFuel" set fuel to resource.
	}
	
	// Penalty score
	local alt_score is min(abs(ship:apoapsis / TARGET_ALTITIDE), 1).
	
	// real scores
	local ap_score is gaussian(ship:apoapsis, TARGET_ALTITIDE, TARGET_ALTITIDE / 2).
	local ec_score is gaussian(obt:eccentricity, 0, 0.5).
	local fl_score is gaussian(fuel:amount / fuel:capacity, 1, 2).
	
	local total is 0.
	set total to total + (ap_score * 10).
	set total to total + (ec_score * 5).
	set total to total + fl_score.
	
	// scale total based on penalty
	set total to total / max(1 - alt_score, 0.001).
	
	return total.
  }
  
  function gaussian {
    parameter value, target, width.
	return constant:e^(-1 * (value-target)^2 / (2* width^2)).
  }
  
  function starting_data {
    // holdUpTime, leanAmount, holdLeanTime, switchOrbit
    return list(5, 15, 15, 975).
  }
}