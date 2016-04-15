// ascent function library
// Andy Greenwood
// Version 0.0.1

{
  local SWITCH_ORBIT_SCALER is 1000.

  global ascent is lex(
    "version", "0.0.1",
    "ascent", ascent@
  ).
  
  function ascent {
    parameter targetAlt.			// Target altitude we should ascend to
    parameter compass.			// Heading
    parameter holdUpTime.		// How long to hold straight up (seconds)
    parameter leanAmount.		// How many degrees to leanAmount
    parameter holdLeanTime.		// How long to hold the specified lean (seconds)
    parameter switchOrbit.		// How parallel the srfprograde and prograde
                                //   need to be before switching to prograde
                                //   should be close to 1000 for most cases
    set mode to 0.
    set ascention to 90.
    lock steering to heading(compass, ascention).
    set start to time:seconds.
    lock throttle to 1.
    set done to 0.
    stage.
    until done {
      if (mode = 0) and (time:seconds - start >= holdUpTime)  {
        // time to start leaning
        set ascention to 90-leanAmount.
        set start to time:seconds.
        set mode to 1.
      }

      if (mode = 1) and (time:seconds - start >= holdLeanTime)  {
        // time to stop leaning
        lock steering to srfprograde.
        set mode to 2.
      }

      if (mode = 2) and ((vdot(srfprograde:forevector, prograde:forevector) * SWITCH_ORBIT_SCALER) >= switchOrbit) {
        // time to point orbital prograde
        lock steering to prograde.
      }

      if (alt:radar > 70000) {
        // enable antenna
        lights on.
        set done to 1.
      }

      if (ship:apoapsis >= targetAlt) {
        //we're high enough, stop!
        set throttle to 0.
      }
    }
  }
}
