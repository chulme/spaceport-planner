(define (problem problem1)
  (:domain space)

     (:objects
     empty1 empty2 - empty
     planet1 - planet
     earth1 - earth
     nebula1 - nebula
     asteroidBelt1 - asteroidBelt

     captain1 - captain
     navigator1 - navigator
     e1 e2 - engineer
     sci1 - scientist

     bridge1 - bridge
     engineering1 - engineering
     launchBay1 - launchBay
     scienceLab1 - scienceLab
     canteen1 - canteen

     mav1 - mav
     probe1 - probe
     lander1 - lander
     
     plasma1 - plasma
     touchDscan1 - touchdownScan
     planetaryScan1 - planetaryScan

     antenna1 antenna2 - antenna

    )

    (:init
        (spacecraftAt empty1)

        (personnelAt navigator1 bridge1)
        (personnelAt captain1 bridge1)
        (personnelAt sci1 bridge1)
        (personnelAt e1 bridge1)
        (personnelAt e2 bridge1)

        (path bridge1 engineering1)
        (path engineering1 bridge1)

        (path bridge1 launchBay1)
        (path launchBay1 bridge1)

        (path bridge1 scienceLab1)
        (path scienceLab1 bridge1)

        (path canteen1 bridge1)
        (path bridge1 canteen1)

        (vehicleOnShip mav1)
        (vehicleOnShip probe1)
        (vehicleOnShip lander1)

    )

    (:goal
        (and            
            (plasmaStudied plasma1)
        )
    )
)

