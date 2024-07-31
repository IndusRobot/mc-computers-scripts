Script was built in 1.12.2 at a time when draconic evolution seemed to slowly remove peripheral support for computer mods. Don't expect this to work on any other version!

Terminology: 
onsite - the computer that directly controls the DE reactor. This could be in an AE2 spatial storage cell, a different dimension or otherwise very far away. Compact machines do not have enough space to fit this setup
offsite - the computer at your home base that communicates wirelessly to the onsite computer, pulling data values to display on your monitors and pushing reactor changes. Use an ender modem on both computers

For the computer onsite add an adapter to each flux gate and the injector. Edit the config for these peripheral addresses, and a computer channel ID so data packets are sent and received correctly. 

For the monitors offsite add a computer channel ID as well, and add a number of monitors for each reactor you wish to view. Add 1 additional monitor for an "offsite" energy storage sphere that resides on the same network as the offsite computer. Hook it up to a energy IO block, and edit the config for these peripheral addresses 

Emergency shutdown thresholds are configured onsite in case of blackouts or unexpected errors. Pretty much any computer error with the offsite monitor program will cause the reactor to shut down automatically due to a communication failure. Any errors onsite though will cause the reactor to become completely uncontrollable!

Lastly this program was never configured for restarting the onsite program with an internal clock or shell checker, nor was a secondary power source shutoff ever setup for emergencies (I never had an emergency :)). If these are desired you'll have to modify the program 