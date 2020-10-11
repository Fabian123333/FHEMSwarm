# FHEMSwarm
FHEM deployment on docker swarm

Docker Deployment on swarm - please fix registry IP accordly

``` 
 docker build --tag 192.168.0.210:5000/fhem-web .
 docker push 192.168.0.210:5000/fhem-web

 docker stack deploy -c swarm.yml fhem
```

This will setup a ready to use fhem with MySQL Database backend
