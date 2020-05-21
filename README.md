# Spaceport Planner
A minor individual university project regarding knowledge representation and automated planning, a subfield of artificial intelligence dedicated to representing information about the world in a form that a computer system can utilize to solve complex tasks.

## Background
### Problem Overview
Operations on board the spacecraft will be controlled by mission plans generated using the automated planner
that will direct the people, autonomous agents, and spacecraft’s controls. The spacecraft itself is a large ship with
multiple sections, including the bridge, launch bay, science lab, engineering, and possibly others. Different types
of personnel serve on board the spacecraft: the captain, engineers, science officers, and navigators. The
spacecraft has also been equipped with a set of autonomous probes and landers, along with a set of maintenance
activity vehicles (MAVs) that personnel can use to perform extravehicular activities (EVAs) outside the spacecraft.

### Automated Planning
Automated planning techniques can build goal-directed plans of action under many conditions, given a suitable description of the problem. A planning problem consists of:
* A representation of the properties and objects in the world (or agent’s knowledge), usually described in a logical language.
* A set of state transforming actions.
* A description of the initial world/knowledge state.
* A set of goal conditions to be achieved.
* A plan is a set of actions that when applied to the initial state transforms.
* the state to produce a state that satisfies the goal conditions.

With this in mind, the spacecraft exploration domain is described in PDDL, defining the properties, objects, and actions that are needed to describe the domain.

## Implementation
### Moving the Spacecraft
Moving the spacecraft is spilt into 2 definite actions. In spacecraftOrderToMove, the captain will
order the ship to move when both the captain and navigator are present in the bridge. This sets an
orderlocation, which is used in spacecraftMove as the destination of the spacecraft.

Follwoing this the planner will check all the probes & MAVs are on the ship. This is because vehicle actions uses the spacecraft’s location to
determine the vehicle’s location. For this to be valid the planner must ensure no ships are left
behind, ie. ensuring the order of actions is correct. To summarise, it prevents the case where a
vehicle is deployed, then the spacecraft moves to a desired space region, then using the same
vehicle in this space region.

### Repairing the Spacecraft
This is a straightforward process. Firstly, as stated in launchVehicle, an engineer inside the launch
bay, will launch a MAV. Note this action is also responsible for detecting and destroying vehicles
when deployed in certain space regions. In the case of the probe, this is achieved by iterating
through all probes, then through all the asteroid belts. When the location of the spacecraft, and thus
the location of where the probe is, is the same as an in iterated asteroid belt, and, the vehicle being
deployed is equal to an iterated probe, the probe that was just launched, is destroyed.

The action repairShip simply updates the spacecraftDamaged predicate in the valid circumstance.

### Obtaining and Studying Plasma
In order to obtain plasma, the ship must move to a nebula, launch a probe, the probe then will
collect the plasma on the nebula, using the spacecraft’s location to determine the probe is in a
nebula.

The probe carrying the plasma must be retrieved using retreiveVehicle, which simply updates the
vehicleOnShip predicate provided an engineer is at the launch bay. Now that the probe has been
returned to the spacecraft’s launch bay, the plasma is dropped off here. It makes use of the itemAt
predicate, which takes the item and the item location as its variables. In this implementation the
only items are plasma and scans (however there are two types of scan).

Now a scientist must pick up the plasma, this is done by checking the scientist and the item are in
the same location, and then setting the scientist to be holding the plasma.
To study the plasma, the scientist will move to the science lab and study the plasma, which simply
updates the plasmaStudied predicate for the plasma item. The scientist will also drop the item in the
science lab, there is no reason for the physical plasma to be interacted with, however the
plasmaStudied predicate of the plasma is important for final mission success.

### Scans
In this implementation there are two types of scans – touchdown scans & planetary scans, due to
their different usages. Obtaining scans is much like obtaining plasma. However, for a planetary scan,
the lander needs to carry out the landOnPlanet action first, using the touchdown scan. Scans are
split into 2 predicates, (scanUploaded ?s) which indicates the scan has been uploaded to the
computer, and thus available for the lander, and (scanPlanet ?s ?p) which indicates what planet the
scan is of.

This implementation does not include an “if no touchdown scan”, as there would be no beneficial
reason for the planner to have such an action.
Uploading a touchdown scan to the spacecraft’s central computer is like the plasma study process –
however it doesn’t need to be physically picked up and transported across the ship. It instead is
uploaded once the probe carrying the touchdown scan has been retrieved onto the ship.

In order to upload the planetary scan, the lander must first rise the appropriate number of antennas.
This is done recursively. First, regardless of the planet radiation, it will rise one antenna. Then, if the
planet has low radiation, the antennasDeployed predicate is set to true – this ends the loop.
However, if the planet has high radiation, the planner will perform riseAntenna for a second time –
rising anther antenna and setting the antennasDeployed predicate to true.

Once the antennasDeployed is true, meaning the required number of antennas have been raised,
the lander can now upload the scan to the computer.

### Personnel Hunger
personnel can experience hunger. This is simply measured by the personnelHungry predicate. Hunger concerns the ‘physically intensive’ actions, meaning repairing
the ship will make the engineers hungry, while studying the plasma will make the scientist hungry.
Being hungry means that the personnel will no longer be able to carry out a physically intensive
action. So, in order to solve this, the personnel will move to the canteen - a new ship section and
eat.

### Spacecraft/Space Layout
This implementation uses  a straightforward layout so to make the movements of personnel
predictable, as well as making implementation for routes easier both physically and visually. So, I
chose to make the bridge act as a central hub, with 2-way connections to every other ship section. In
conclusion, every ship section (other than the bridge) will only have the single 2-way connection to
the bridge.

For the space layout, the ship can move to any space region, from any space region.
