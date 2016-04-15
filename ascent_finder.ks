// Ascent Finder
// Andy Greenwood
// Version 0.0.1

{
  local INFINITY IS 2^64.
  local TARGET_ALTITIDE is 100000.
  local COMPASS is 90.
  local TARGET_INCLINATION is 0.
  local AP_SCORE_SCALE is 10.
  local EC_SCORE_SCALE is 5.
  local FL_SCORE_SCALE is 1.
  local FINAL_SCORE_SCALE is 0.001.
  
  global ascent_finder is lex(
    "version", "0.0.1",
    "find_ascent", find_ascent@
  ).
  
  function find_ascent {
    // initialize logging
	init_logs().
    // get starting data
	local data is starting_data().
	logdebug("starting data is " + data:dump).
	// call hillclimb functions with starting data
	local last_data is data.
	until 0 {
  	  set data to hillclimb["seek"](data, ascent_fitness, 1).
	  // leave if we didn't take a step.
	  if (last_data = data) break.
	  set lastdata to data.
	}
	// get out of here.
	logdebug("program done. final value:" + data.dump).
	return.
  }
  
  function ascent_fitness {
    function fitness_fn {
	  parameter data.
	  // do the ascent
	  ascent["ascent"](TARGET_ALTITIDE, COMPASS, data[0], data[1], data[2], data[3]).

	  // score the ascent.
	  logdebug("scoring ascent: " + data:dump).
	  local fuel is 0.
	  for resource in ship:resources {
	    if resource:name = "LiquidFuel" set fuel to resource.
	  }
	
	  // Penalty score
	  local alt_score is min(ship:apoapsis / TARGET_ALTITIDE, 1).
	
	  // Real scores
	  local ap_score is gaussian(ship:apoapsis, TARGET_ALTITIDE, TARGET_ALTITIDE / 2).
	  local ec_score is gaussian(obt:eccentricity, 0, 0.5).
	  local fl_score is gaussian(fuel:amount / fuel:capacity, 1, 2).
	
	  local total is 0.
	  set total to total + (ap_score * AP_SCORE_SCALE).
	  set total to total + (ec_score * EC_SCORE_SCALE).
	  set total to total + (fl_score * FL_SCORE_SCALE).
	
	  // scale total score to max of (AP_SCORE_SCALE + EC_SCORE_SCALE + FL_SCORE_SCALE) / (FINAL_SCORE_SCALE)
	  set total to total / max(1 - alt_score, FINAL_SCORE_SCALE).
	
  	  logdebug("ascent scored: " + total).
      logdebug("reverting to launch").
	  kuniverse:reverttolaunch().
	  logdebug("returning score").
	  return total.
	}
	return fitness_fn@.
  }
  
  function gaussian {
    parameter value, target, width.
    return constant:e^(-1 * (value-target)^2 / (2* width^2)).
  }
  
  function starting_data {
    // holdUpTime, leanAmount, holdLeanTime, switchOrbit
    return list(5, 15, 15, 975).
  }
  
  function init_logs {
    if addons:rt:hasconnection(ship) {
      switch to 0.
  	  log "" to "ascent_finder_debug.txt".
	  delete "ascent_finder_debug.txt".
	
	  log "" to "flightdata.csv".
	  delete "flightdata.csv".
	  log "Score,Apoapsis_score,Eccentricity_score,Fuel_score,HoldUpTime,LeanAmount,HoldLeanTime,SwitchOrbit" to "flightdata.csv".
	  switch to 1.
	} else {
	  kuniverse:debuglog("can't get RT connection to KSC in init_logs").
	}
  }
  
  function logFlightData {
    parameter score, ap_score, ec_score, fl_score, data.
	local msg is score + "," + ap_score + "," + ec_score + fl_score.
	for datum in data {
	  set msg to msg + "," + datum.
	}
    if addons:rt:hasconnection(ship) {
	  switch to 0.
	  log msg to "flightdata.csv".
	  switch to 1.
	} else {
	  kuniverse:debuglog("can't get RT connection to KSC in logFlightData").
	}
  }
  
  function logdebug {
    parameter msg.
	if addons:rt:hasconnection(ship) {
 	  switch to 0.
	  log msg to "ascent_finder_debug.txt".
	  switch to 1.
	} else {
	  kuniverse:debuglog("can't get RT connection to KSC in logdebug").
	}
  }
}