Borderleaf is the access to the internet.

- Please configure it to add a "external". 
- Put the tointernet interface in that vrf
- Change the configuration so that the default route is towards the ip of the "internet" container
- Leak routes from external to red / blue and viceversa
- Add the "external" vrf to leaf1 / leaf2

We must be abple to ping 8.8.8.9 from each server
