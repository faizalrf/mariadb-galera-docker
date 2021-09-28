# MariaB Galera Cluster
 
The purpose of this docker-compose is to implement the following architecture. To keep it simple, we will have one MaxScale on each DC instead of two.
 
![image info](./Images/GaleraArchitecture.png)
 
## Setup
 
This setup uses MariaDB 10.5 Community with MaxScale 2.5; the following folder structure contains the essential files for reference.
 
- `galera/`
 - Contains the `Dockerfile` and the yml script to set up 2x3 node Galera clusters.
- `galera/config/`
 - Contains the server.cnf and `galera.cnf` for each of the 3 nodes in both data centers
- `Dockerfile`
 - Implements builds the MariaDB container image to spin up a Galera with the first node as the `bootstrap` node.
- `maxscale/`
 - Contains the `Dockerfile` and the yml script to set up two nodes of MaxScale 2.5
- `maxscale/config/`
 - Contains the MaxScale configuration files for both data centers. These will also deploy the `monitor.sh` script responsible for the automatic setup of the slave nodes for the remote MaxScale.
- `test-scripts/`
 - This folder contains three scripts with the following names
   - `dc`
     - This script connects to the MaxScale on the DC and starts pushing some transactions (INSERT, UPDATE, and SELECT) statements. Keep it running to test the replication and failover scenarios
   - `dr`
     - This script connects to the MaxScale on the DR and starts pushing some transactions (INSERT, UPDATE, and SELECT) statements. Keep it running to test the replication and failover scenarios
   - `report`
     - This executes `count(*)` queries on all nodes for `tab1` and `tab2` to generate a report for replication validation
 
***Note:** Script for the [monitor.sh](./maxscale/monitor.sh) can be found here.*
 
The repository contains the **`deploy`** script, execute it to destroy and recreate the two Galera clusters + MaxScale nodes as in the above image.
 
```
❯ ./deploy
[+] Running 7/7
⠿ Network static-network  Created                                                                                                                                                      0.0s
⠿ Container drg1          Started                                                                                                                                                      0.4s
⠿ Container dcg1          Started                                                                                                                                                      0.5s
⠿ Container drg3          Started                                                                                                                                                      1.4s
⠿ Container drg2          Started                                                                                                                                                      1.3s
⠿ Container dcg3          Started                                                                                                                                                      1.3s
⠿ Container dcg2          Started                                                                                                                                                      1.4s
...
...
...
Copying the config files for the cluster and server
Test 1: dcg1
Test 1: Container dcg1 ping successful
.....
Container dcg1 Status Verified
 
Test 1: drg1
Test 1: Container drg1 ping successful
.....
Container drg1 Status Verified
 
Test 1: dcg2
Test 1: Container dcg2 ping successful
.....
Container dcg2 Status Verified
 
Test 1: drg2
Test 1: Container drg2 ping successful
.....
Container drg2 Status Verified
 
Test 1: dcg3
Test 1: Container dcg3 ping successful
.....
Container dcg3 Status Verified
 
Test 1: drg3
Test 1: Container drg3 ping successful
.....
Container drg3 Status Verified.
 
.
Set bootstrap for DC Node 1 and DR Node 1
Node dcg1 is set to bootstrap next time the cluster starts
Node drg1 is set to bootstrap next time the cluster starts
.
Restarting Cluster one last time
Stopping MariaDB process for node dcg1
Stopping MariaDB process for node drg1
Stopping MariaDB process for node dcg2
Stopping MariaDB process for node drg2
Stopping MariaDB process for node dcg3
Stopping MariaDB process for node drg3
.
Starting up Cluster with Galera configuration
Test 1: dcg1
Test 1: Container dcg1 ping successful
.....
Container dcg1 Status Verified
 
Test 1: drg1
Test 1: Container drg1 ping successful
.....
Container drg1 Status Verified
 
Test 1: dcg2
Test 1: Container dcg2 ping successful
.....
Container dcg2 Status Verified
 
Test 1: drg2
Test 1: Container drg2 ping failed!
Test 2: drg2
Test 2: Container drg2 ping successful
.....
Container drg2 Status Verified
 
Test 1: dcg3
Test 1: Container dcg3 ping successful
.....
Container dcg3 Status Verified
 
Test 1: drg3
Test 1: Container drg3 ping failed!
Test 2: drg3
Test 2: Container drg3 ping successful
.....
Container drg3 Status Verified
 
Setting up GTID for dcg1
Setting up GTID for drg1
Setting up GTID for dcg2
Setting up GTID for drg2
Setting up GTID for dcg3
Setting up GTID for drg3
.
Cluster restarted, setting up MaxScale.
[+] Building 3.1s (18/18) FINISHED
=> CACHED [ 3/12] RUN apt-get -y update &&     apt-get -y install gnupg2 ca-certificates less sysstat wget curl &&     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-k  0.0s
=> CACHED [ 4/12] RUN wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup                                                                   [+] Running 2/2
...
...
...
⠿ Container drmxs  Started                                                                                                                                                             0.4s
⠿ Container dcmxs  Started                                                                                                                                                             0.4s
MaxScale up and ready
.
Setting up replication between dcg1 <-> drmxs & drg1 <-> dcmxs
 
DC -> DR
Slave_IO_Running: Yes Slave_SQL_Running: Yes
Replication DC to DR validated
 
DR -> DC
Slave_IO_Running: Yes Slave_SQL_Running: Yes
Replication DC to DR validated
 
Clusters are ready...
```
 
The setup will create the following containers.
 
```
❯ docker container ls
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                                                                  NAMES
3a3da1da9a0c   mxs       "maxscale -d -U maxs…"   13 minutes ago   Up 13 minutes   0.0.0.0:5001->4006/tcp, :::5001->4006/tcp, 0.0.0.0:8985->8989/tcp, :::8985->8989/tcp   dcmxs
67390ad6e32c   mxs       "maxscale -d -U maxs…"   13 minutes ago   Up 13 minutes   0.0.0.0:8989->8989/tcp, :::8989->8989/tcp, 0.0.0.0:5002->4006/tcp, :::5002->4006/tcp   drmxs
1f878c7d20da   mdbg      "docker-entrypoint.s…"   15 minutes ago   Up 14 minutes   0.0.0.0:4007->3306/tcp, :::4007->3306/tcp                                              drg2
3197e459d620   mdbg      "docker-entrypoint.s…"   15 minutes ago   Up 14 minutes   0.0.0.0:4003->3306/tcp, :::4003->3306/tcp                                              dcg2
1b3135e75ad0   mdbg      "docker-entrypoint.s…"   15 minutes ago   Up 13 minutes   0.0.0.0:4004->3306/tcp, :::4004->3306/tcp                                              dcg3
e21283910ddf   mdbg      "docker-entrypoint.s…"   15 minutes ago   Up 13 minutes   0.0.0.0:4008->3306/tcp, :::4008->3306/tcp                                              drg3
aa3ecf98b7b2   mdbg      "docker-entrypoint.s…"   15 minutes ago   Up 14 minutes   0.0.0.0:4002->3306/tcp, :::4002->3306/tcp                                              dcg1
106c261c64df   mdbg      "docker-entrypoint.s…"   15 minutes ago   Up 14 minutes   0.0.0.0:4006->3306/tcp, :::4006->3306/tcp                                              drg1
```
 
The containers can be connected using the following.
 
```
# To connect to MaxScale container
❯ docker container exec -it dcmxs bash
 
# To connect to the DC Galera 1 node
❯ docker container exec -it dcg1 bash
```
 
Executing the following two commands will provide the Cluster status and MaxScale output for both data centers.the 
 
For DC Cluster
 
```
❯ docker container exec -it dcmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬─────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DC-Galera-1 │ 172.20.0.2 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-1,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DC-Galera-2 │ 172.20.0.3 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-1,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DC-Galera-3 │ 172.20.0.4 │ 3306 │ 0           │ Slave, Synced, Running  │ 70-7000-1,80-8000-1 │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴─────────────────────┘
```
 
For DR cluster
 
```
❯ docker container exec -it drmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬─────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DR-Galera-1 │ 172.20.0.6 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-1,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DR-Galera-2 │ 172.20.0.7 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-1,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DR-Galera-3 │ 172.20.0.8 │ 3306 │ 0           │ Slave, Synced, Running  │ 70-7000-1,80-8000-1 │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴─────────────────────┘
```
 
To monitor the logs for monitor.sh running on both MaxScale nodes.
 
```
❯ docker container exec -it dcmxs bash -c "tail -f /var/log/maxscale/monitor.log"
 
and
 
❯ docker container exec -it drmxs bash -c "tail -f /var/log/maxscale/monitor.log"
```
 
### Stopping and Starting Nodes
 
To Stop a MariaDB Galera Node, doing this will automatically set the DC Galera 2 (dcg2) node as a Slave to the DR MaxScale by `monitor.sh`
 
Start and Stop a node is done by executing the `./node` script. Doing a `docker stop` might create problems.
 
```
❯ ./node stop dcg1
Stopping node dcg1
 
❯ docker container exec -it dcmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬─────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DC-Galera-1 │ 172.20.0.2 │ 3306 │ 0           │ Down                    │                     │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DC-Galera-2 │ 172.20.0.3 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-1,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────┤
│ DC-Galera-3 │ 172.20.0.4 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-1,80-8000-1 │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴─────────────────────┘
```
 
Start the node using the same `./node` script.
 
```
❯ ./node start dcg1
Starting node dcg1
Test 1: dcg1
Test 1: Container dcg1 ping successful
.....
Container dcg1 Status Verified.
 
❯ docker container exec -it dcmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬────────────────────────────────────────────┬─────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                                      │ GTID                │
├─────────────┼────────────┼──────┼─────────────┼────────────────────────────────────────────┼─────────────────────┤
│ DC-Galera-1 │ 172.20.0.2 │ 3306 │ 0           │ Slave, Synced, Running                     │ 70-7000-1,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼────────────────────────────────────────────┼─────────────────────┤
│ DC-Galera-2 │ 172.20.0.3 │ 3306 │ 1           │ Master, Synced, Master Stickiness, Running │ 70-7000-1,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼────────────────────────────────────────────┼─────────────────────┤
│ DC-Galera-3 │ 172.20.0.4 │ 3306 │ 1           │ Slave, Synced, Running                     │ 70-7000-1,80-8000-1 │
└─────────────┴────────────┴──────┴─────────────┴────────────────────────────────────────────┴─────────────────────┘
```
 
### GTID
 
The cluster in DC has GTID in the range of `70-7000` while the DR is `80-8000` that can be seen by MaxScale `maxctrl list servers` output.
 
When the data is inserted in DC, the `70-7000-*` will increase for all nodes in DC while only one node on the DR will show the increasing `70-7000-*` GTIDs, but the data will get replicated across all the DR nodes even though the GTID only updates one node.
 
Same way, for the transactions done on the DR, only the `80-8000-*` will increase, and in DC, only the current slave will have the `80-8000-*` part increase. As a sample, we will execute the `test-scripts/dc` script to pump some data in DC. We can then monitor the GTID across the cluster and on the DR
 
```
test-scripts❯ ./dc
SELECT FROM tab1 on dcg3 -> fb9b9dd21c8b7e8a  Record Found
SELECT FROM tab1 on dcg3 -> 364c2536cd2281d1  Record Found
SELECT FROM tab1 on dcg2 -> 552b3bf9207a8798  Record Found
SELECT FROM tab1 on dcg2 -> e5de4f4081cf5ec5  Record Found
SELECT FROM tab1 on dcg3 -> 70150024db66021d  Record Found
...
...
...
```
 
We have generated some data on the DC. Let’s check MaxScale output for both DC and DR clusters.
 
```
❯ docker container exec -it dcmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬───────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                  │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼───────────────────────┤
│ DC-Galera-1 │ 172.20.0.2 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-170,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼───────────────────────┤
│ DC-Galera-2 │ 172.20.0.3 │ 3306 │ 0           │ Slave, Synced, Running  │ 70-7000-170,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼───────────────────────┤
│ DC-Galera-3 │ 172.20.0.4 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-170,80-8000-1 │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴───────────────────────┘
 
❯ docker container exec -it drmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬───────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                  │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼───────────────────────┤
│ DR-Galera-1 │ 172.20.0.6 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-170,80-8000-1 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼───────────────────────┤
│ DR-Galera-2 │ 172.20.0.7 │ 3306 │ 0           │ Slave, Synced, Running  │ 70-7000-1,80-8000-1   │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼───────────────────────┤
│ DR-Galera-3 │ 172.20.0.8 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-1,80-8000-1   │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴───────────────────────┘
```
 
We can see the DC all nodes have `70-7000-170,,80-8000-1` and on the DR, only the designated "Master" node gets `70-7000-170,80-8000-1` but doing a count of table records across all the DR nodes, the data is replicated across the DR, just the "asynchronous" replicated data only updates GTID to the direct slave.
Similarly
Now executing the `test-scripts/dr` script, we will monitor the GTIDs flow from DR to DC.
 
```
❯ ./dr
SELECT FROM tab2 on drg2 -> 9b1d4c8425c2e801  Record Found
SELECT FROM tab2 on drg3 -> b57fb8607c7f2181  Record Found
SELECT FROM tab2 on drg2 -> 70a102af9e9fb60c  Record Found
SELECT FROM tab2 on drg2 -> b564eb7abb738363  Record Found
SELECT FROM tab2 on drg3 -> 28f2ad5eedaf1bf0  Record Found
...
...
...
```
 
Let's check both DC and DR MaxScale nodes.
 
```
❯ docker container exec -it drmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬─────────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                    │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DR-Galera-1 │ 172.20.0.6 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-170,80-8000-103 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DR-Galera-2 │ 172.20.0.7 │ 3306 │ 0           │ Slave, Synced, Running  │ 70-7000-1,80-8000-103   │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DR-Galera-3 │ 172.20.0.8 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-1,80-8000-103   │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴─────────────────────────┘
 
❯ docker container exec -it dcmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬─────────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                    │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DC-Galera-1 │ 172.20.0.2 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-170,80-8000-103 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DC-Galera-2 │ 172.20.0.3 │ 3306 │ 0           │ Slave, Synced, Running  │ 70-7000-170,80-8000-1   │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DC-Galera-3 │ 172.20.0.4 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-170,80-8000-1   │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴─────────────────────────┘
```
 
We can see the same behavior. The GTID for all nodes on DR increased to `80-8000-103` as we performed 103 transactions on the DR cluster. While only the DC Galera 1 (dcg1) node got the GTIDs replicated from DR and currently show `70-7000-170,80-8000-103`
 
If we were to stop the `dcg1` node, the GTID for the `dcg2` would automatically be set by the `monitor.sh` to the correct value to start replication as per the standard norm.
 
```
❯ ./node stop dcg1
Stopping node dcg1
 
❯ docker container exec -it dcmxs maxctrl list servers
┌─────────────┬────────────┬──────┬─────────────┬─────────────────────────┬─────────────────────────┐
│ Server      │ Address    │ Port │ Connections │ State                   │ GTID                    │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DC-Galera-1 │ 172.20.0.2 │ 3306 │ 0           │ Down                    │                         │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DC-Galera-2 │ 172.20.0.3 │ 3306 │ 1           │ Master, Synced, Running │ 70-7000-170,80-8000-103 │
├─────────────┼────────────┼──────┼─────────────┼─────────────────────────┼─────────────────────────┤
│ DC-Galera-3 │ 172.20.0.4 │ 3306 │ 1           │ Slave, Synced, Running  │ 70-7000-170,80-8000-1   │
└─────────────┴────────────┴──────┴─────────────┴─────────────────────────┴─────────────────────────┘
```
 
We can see now that the DC Node 2 (dcg2)'s GTID changed from `70-7000-170,80-8000-1` to `70-7000-170,80-8000-10` automatically done by `monitor.sh` and is the expected behavior so that Node 2 can continue replication from where Node 1 left off.
 
### Thanks.
#### faisal@mariadb.com

