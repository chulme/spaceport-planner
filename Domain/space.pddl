(define (domain space)
    (:requirements
        :strips :typing :conditional-effects
    )

    (:types 
        object
        captain navigator engineer scientist - personnel
        empty nebula asteroidBelt planet - spaceRegion
        earth - planet
        bridge launchBay engineering scienceLab canteen - shipSection
        mav probe lander - vehicle
        plasma scan - item
        touchdownScan planetaryScan - scan
        antenna
    )    

    (:predicates
        ;Personnel
        (personnelAt ?p - personnel ?pl - shipSection)
        (personnelHungry ?p - personnel)
        (personnelHolding ?p - personnel ?i - item)

        ;Spacecraft
        (spacecraftAt ?sl - spaceRegion)
        (spacecraftDamaged)
        (orderlocation ?ol - spaceRegion)


        ;Vehicles
        (vehicleHoldingScan ?v - vehicle ?s - scan)
        (vehicleOnShip ?v - vehicle)
        (vehicleDestroyed ?v - vehicle)

        (probeHoldingPlasma ?p - probe)    
        
        (landerOnPlanet ?l - lander ?p - planet)
        
        (antennaUp ?l - lander ?a - antenna)
        (antennaOneUp ?l - lander)
        (antennasDeployed ?l - lander)

        ;Items
        (itemAt ?i - item ?il - shipSection)
        
        (plasmaStudied ?p - plasma)

        (scanUploaded ?s - scan)
        (scanPlanet ?s - scan ?p - planet)

        (studiesAndScansUploaded)
        
        ;Misc
        (path ?x - shipSection ?y - shipSection)
        (planetHighRad ?p - planet)

    )


;Order spacecraft to move to ?x, provided captain & navigator is on the bridge
(:action spacecraftOrderToMove
    :parameters 
        (?x - spaceRegion ?b - bridge ?c - captain ?n - navigator)
    :precondition 
    (and 
        (personnelAt ?c ?b)
        (personnelAt ?n ?b)
    )
    :effect 
    (and 
        (orderlocation ?x)
    )
)

;Move Spacecraft to ?y, provided navigator is on bridge, spacecraft isn't damaged & ordered to move
(:action spacecraftMove
    :parameters
        (?x - spaceRegion ?y - spaceRegion ?b - bridge ?n - navigator)
    :precondition
        (and
           (spacecraftAt ?x)
           (personnelAt ?n ?b)
           (not(spacecraftDamaged))
           (orderlocation ?y)

           (forall (?p - probe)
                (vehicleOnShip ?p)
           )

           (forall (?m - mav)
                (vehicleOnShip ?m)
           )

           

        )
    :effect
        (and
            (spacecraftAt ?y)
            (not(spacecraftAt ?x))

            (forall (?ab - asteroidBelt)
                (when (= ?y ?ab)
                    (spacecraftDamaged)
                )
             )


        )
)

;Move personnel ?p from ?x to ?y, provided a path between ?x & ?y exists
(:action personnelMove
    :parameters
        (?x - shipSection ?y - shipSection ?p - personnel)
    :precondition
        (and
           (personnelAt ?p ?x)
           (path ?x ?y)
        )
    :effect
        (and
            (personnelAt ?p ?y)
            (not(personnelAt ?p ?x)
)
        )
)

;Repair the ship, given that there is a monitoring engineer in engineering & a MAV deployed (with a 'reparing engineer')
;Physically Intensive Action - Hunger
(:action repairShip
    :parameters
        (?repairingEngineer - engineer ?monitoringEngineer - engineer ?m - mav ?e - engineering  ?lb - launchBay)
    :precondition
        (and
            (personnelAt ?monitoringEngineer ?e)
            (personnelAt ?repairingEngineer ?lb)

            (spacecraftDamaged)
            (not(vehicleOnShip ?m))
            (not(vehicleDestroyed ?m))

            (not(personnelHungry ?monitoringEngineer))
            (not(personnelHungry ?repairingEngineer))
        )
    :effect
        (and
            (not(spacecraftDamaged))
            (personnelHungry ?monitoringEngineer)
            (personnelHungry ?repairingEngineer)
        )
)

;Using the probe, collect plasma from the nebula
(:action collectPlasma
    :parameters
        (?pr - probe ?n - nebula)
    :precondition
        (and
            (spacecraftAt ?n)
            (not(probeHoldingPlasma ?pr))
            (not(vehicleOnShip ?pr))
            (not(vehicleDestroyed ?pr))

        )
    :effect
        (and
            (probeHoldingPlasma ?pr)
        )
)

;Using the probe, scan for a touchdown location of a planet
(:action scanPlanetForTouchdownLocal
    :parameters
        (?pr - probe ?pl - planet ?s - touchdownScan)
    :precondition
        (and
            (spacecraftAt ?pl)
            (not(vehicleOnShip ?pr))
            (not(vehicleHoldingScan ?pr ?s))
            (not(vehicleDestroyed ?pr))


        )
    :effect
        (and
            (vehicleHoldingScan ?pr ?s)
            (ScanPlanet ?s ?pl)
        )
)

;Launch a vehicle, provided an engineer is present in the launchbay
;Probes will be destroyed if launched into asteroid belt
;MAVs will be 'disabled' if launched into a nebula
(:action launchVehicle
    :parameters
        (?v - vehicle ?eng - engineer ?lb - launchBay ?x - spaceRegion)
    :precondition
        (and
            (personnelAt ?eng ?lb)
            (vehicleOnShip ?v)
            (spacecraftAt ?x)
            (not(vehicleDestroyed ?v))
            
        )
    :effect
        (and
            (not(vehicleOnShip ?v))

            (forall (?p - probe)
                (forall (?ab - asteroidBelt)
                    (when (and (= ?x ?ab) (= ?v ?p))
                        (vehicleDestroyed ?v)
                    )
            
                ) 
            )

            (forall (?m - mav)
                (forall (?n - nebula)
                    (when (and (= ?x ?n) (= ?v ?m))
                        (vehicleDestroyed ?v)
                    )
            
                )
            )

        )
)

;Retreive a vehicle, provided an engineer is present in the launchbay
(:action retreiveVehicle
    :parameters
        (?v - vehicle ?eng - engineer ?lb - launchBay)
    :precondition
        (and
            (personnelAt ?eng ?lb)
            (not(vehicleOnShip ?v))
            (not(vehicleDestroyed ?v))
        )
    :effect
        (and
            (vehicleOnShip ?v)
        )
)

;Probe will drop plasma to the launch bay
(:action plasmaToLaunchBay
    :parameters (?pr - probe ?lb - launchBay ?p - plasma)
    :precondition
        (and
            (vehicleOnShip ?pr)
            (probeHoldingPlasma ?pr)
         )
    :effect
        (and
            (itemAt ?p ?lb)
            (not(probeHoldingPlasma ?pr))
        )
)

;Probe will upload touchdown scan to the spacecraft central computer
(:action touchdownScanToComputer
    :parameters (?pr - probe ?lb - launchBay ?s - touchdownScan)
    :precondition
        (and
            (vehicleOnShip ?pr)
            (vehicleHoldingScan ?pr ?s)
            (not(scanUploaded ?s))
         )
    :effect
        (and
            (itemAt ?s ?lb)
            (scanUploaded ?s)
        )
)

;Scientist will pick up plasma
(:action pickupPlasma
    :parameters (?sci - scientist ?p - plasma ?l - shipSection)
    :precondition
        (and
            (personnelAt ?sci ?l)
            (itemAt ?p ?l)
            (not(personnelHolding ?sci ?p))
        )
    :effect
        (and
            (personnelHolding ?sci ?p)
        )
)

;Scientist will study plasma, provided the scientist is in the science lab and holding plasma
;Physically Intensive Action - Hunger
(:action studyPlasma
    :parameters (?sci - scientist ?p - plasma ?sl - scienceLab)
    :precondition
        (and
            (personnelAt ?sci ?sl)
            (personnelHolding ?sci ?p)
            (not(personnelHungry ?sci))
        )
    :effect
        (and
            (not(personnelHolding ?sci ?p))
            (itemAt ?p ?sl)
            (plasmaStudied ?p)
            (personnelHungry ?sci)
        )
)

;Lander will land on planet, provided the scan of the planet has been uploaded
(:action landOnPlanet
    :parameters (?p - planet ?l - lander ?s - touchdownScan)
    :precondition
        (and
            (not(vehicleOnShip ?l))
            (spacecraftAt ?p)
            (scanUploaded ?s)
            (scanPlanet ?s ?p)
        )
    :effect
        (and
            (landerOnPlanet ?l ?p)
        )
)

;Lander will scan planet
(:action scanPlanetForPlanetaryScan
    :parameters (?p - planet ?l - lander ?s - planetaryScan)
    :precondition
        (and
            (landerOnPlanet ?l ?p)
        )
    :effect
        (and
            (scanPlanet ?s ?p)
            (vehicleHoldingScan ?l ?s)
        )
)

;Lander will rise 1 antenna if on low rad planet
;Lander will rise 2 antennas if on high rad planet
(:action riseAntenna
    :parameters (?p - planet ?l - lander ?a - antenna ?s - planetaryScan)
    :precondition
        (and
            (landerOnPlanet ?l ?p)
            (vehicleHoldingScan ?l ?s)
            (not(antennaUp ?l ?a))
        )
    :effect
        (and
            (when (planetHighRad ?p)
                (and
                    (antennaUp ?l ?a)
                    (antennaOneUp ?l)
                )
            )

            (when (or (not (planetHighRad ?p)) (antennaOneUp ?l))
                (and
                    (antennaUp ?l ?a)
                    (antennasDeployed ?l)
                )
            )
            
        )
)

;Lander will upload scan once appropriate number of antenna have been raised
(:action planetaryScanUpload
    :parameters (?l - lander ?s - planetaryScan ?p - planet)
    :precondition
        (and
            (vehicleHoldingScan ?l ?s)
            (not(scanUploaded ?s))
            (antennasDeployed ?l)
        
        )
    :effect 
        (and
            (scanUploaded ?s)
        )
)

;Communicate scans and studies to mission control once returned to earth
(:action communicateToMissionControl
    :parameters (?e - earth ?s - scan ?p - plasma)
    :precondition
        (and
            (spacecraftAt ?e)
            (or (plasmaStudied ?p) (scanUploaded ?s))
        )
    :effect 
        (and
            (studiesAndScansUploaded)
        )
)

;Personnel will eat once in canteen
(:action personnelEat
    :parameters (?p - personnel ?c - canteen)
    :precondition
        (and
            (personnelHungry ?p)
            (personnelAt ?p ?c)
        )
    :effect 
        (and
            (not(personnelHungry ?p))
        )
)

)