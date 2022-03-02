# Data Formats

## [MATPOWER](https://matpower.org/)

A more in-depth documentation of MATPOWER can be found [here](https://matpower.org/docs/MATPOWER-manual.pdf)

### M-file (Case Format 1)

`TODO`

### M-file (Case Format 2)

This format consists of a `.m` file containing the instantiation of a MATLAB struct with the following fields:

| Field name | Type   | Description                                                        |
|------------|--------|--------------------------------------------------------------------|
| `baseMVA`  | Scalar | System MVA base used for converting power into per unit quantities |
| `bus`      | Matrix | Bus data                                                           |
| `branch`   | Matrix | Branch data                                                        |
| `gen`      | Matrix | Generators data                                                    |
| `gencost`  | Matrix | Generators cost data                                               |
| `dcline`   | Matrix | Direct current line data                                           |

The name of the instance corresponds to the function name used to define the struct. (Ex: `function mpc = case6ww`)

Here's a small example:

```Matlab
function mpc = case6ww
%CASE6WW  Power flow data for 6 bus, 3 gen case from Wood & Wollenberg.
%   Please see CASEFORMAT for details on the case file format.
%
%   This is the 6 bus example from pp. 104, 112, 119, 123-124, 549 of
%   "Power Generation, Operation, and Control, 2nd Edition",
%   by Allen. J. Wood and Bruce F. Wollenberg, John Wiley & Sons, NY, Jan 1996.

%   MATPOWER

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	1	1.05	0	230	1	1.05	1.05;
	2	2	0	0	0	0	1	1.05	0	230	1	1.05	1.05;
	3	2	0	0	0	0	1	1.07	0	230	1	1.07	1.07;
	4	1	70	70	0	0	1	1	0	230	1	1.05	0.95;
	5	1	70	70	0	0	1	1	0	230	1	1.05	0.95;
	6	1	70	70	0	0	1	1	0	230	1	1.05	0.95;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	0	0	100	-100	1.05	100	1	200	50	0	0	0	0	0	0	0	0	0	0	0;
	2	50	0	100	-100	1.05	100	1	150	37.5	0	0	0	0	0	0	0	0	0	0	0;
	3	60	0	100	-100	1.07	100	1	180	45	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.1	0.2	0.04	40	40	40	0	0	1	-360	360;
	1	4	0.05	0.2	0.04	60	60	60	0	0	1	-360	360;
	1	5	0.08	0.3	0.06	40	40	40	0	0	1	-360	360;
	2	3	0.05	0.25	0.06	40	40	40	0	0	1	-360	360;
	2	4	0.05	0.1	0.02	60	60	60	0	0	1	-360	360;
	2	5	0.1	0.3	0.04	30	30	30	0	0	1	-360	360;
	2	6	0.07	0.2	0.05	90	90	90	0	0	1	-360	360;
	3	5	0.12	0.26	0.05	70	70	70	0	0	1	-360	360;
	3	6	0.02	0.1	0.02	80	80	80	0	0	1	-360	360;
	4	5	0.2	0.4	0.08	20	20	20	0	0	1	-360	360;
	5	6	0.1	0.3	0.06	40	40	40	0	0	1	-360	360;
];

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	3	0.00533	11.669	213.1;
	2	0	0	3	0.00889	10.333	200;
	2	0	0	3	0.00741	10.833	240;
];
```

## [PSS®E](https://new.siemens.com/global/en/products/energy/energy-automation-and-smart-grid/pss-software/pss-e.html)

A more in-depth documentation of the RAW and RAWX(json) format can be found [here](https://www.powsybl.org/pages/documentation/grid/formats/psse.html)

### RAW

The RAW format consists of multiple data blocks seperated by a value of zero and a description of the new data blocks. For example between the bus and load data blocks we will have the following line `0 / END OF BUS DATA, BEGIN LOAD DATA`.

Here's a small example: ([source](https://www.powsybl.org/pages/documentation/grid/formats/psse.html))

```
 0,      100.0, 35, 0, 0, 60.00       / October 27, 2020 18:37:53
 PSS(R)E Minimum RAW Case

0 / END OF SYSTEM-WIDE DATA, BEGIN BUS DATA
    1,'Slack-Bus   ', 138.0000,3
    2,'Load-Bus    ', 138.0000,1
0 / END OF BUS DATA, BEGIN LOAD DATA
    2,'1 ',1,,,   40.000,    15.000
0 / END OF LOAD DATA, BEGIN FIXED SHUNT DATA
0 / END OF FIXED SHUNT DATA, BEGIN GENERATOR DATA
    1,'1 ',   40.350,   10.870
0 / END OF GENERATOR DATA, BEGIN BRANCH DATA
    1,     2,'1 ', 0.01938, 0.05917,0.05280
0 / END OF BRANCH DATA, BEGIN SYSTEM SWITCHING DEVICE DATA
0 / END OF SYSTEM SWITCHING DEVICE DATA, BEGIN TRANSFORMER DATA
0 / END OF TRANSFORMER DATA, BEGIN AREA DATA
0 / END OF AREA DATA, BEGIN TWO-TERMINAL DC DATA
0 / END OF TWO-TERMINAL DC DATA, BEGIN VOLTAGE SOURCE CONVERTER DATA
0 / END OF VOLTAGE SOURCE CONVERTER DATA, BEGIN IMPEDANCE CORRECTION DATA
0 / END OF IMPEDANCE CORRECTION DATA, BEGIN MULTI-TERMINAL DC DATA
0 / END OF MULTI-TERMINAL DC DATA, BEGIN MULTI-SECTION LINE DATA
0 / END OF MULTI-SECTION LINE DATA, BEGIN ZONE DATA
0 / END OF ZONE DATA, BEGIN INTER-AREA TRANSFER DATA
0 / END OF INTER-AREA TRANSFER DATA, BEGIN OWNER DATA
0 / END OF OWNER DATA, BEGIN FACTS CONTROL DEVICE DATA
0 / END OF FACTS CONTROL DEVICE DATA, BEGIN SWITCHED SHUNT DATA
0 / END OF SWITCHED SHUNT DATA, BEGIN GNE DEVICE DATA
0 / END OF GNE DEVICE DATA, BEGIN INDUCTION MACHINE DATA
0 / END OF INDUCTION MACHINE DATA, BEGIN SUBSTATION DATA
0 / END OF SUBSTATION DATA
Q
```

### RAWX (json)

The RAWX format consist of a json file where each field is either a Parameters Sets or a Data Tables.

* A Parameters Sets is composed of a list of fieldnames and their corresponding values.

```json
"caseid":{
    "fields":["ic", "sbase", "rev", "xfrrat", "nxfrat", "basfrq", "title1"],
    "data":[0, 100.00, 35, 0, 0, 60.00, "PSS(R)E Minimum RAWX Case"]
}
```

* A Data Tables is composed of a list of column names and an 2 dimensional array of corresponding values.

```json
"bus":{
    "fields":["ibus", "name", "baskv", "ide"],
    "data":[
        [1, "Slack-Bus", 138.0, 3],
        [2, "Load-Bus", 138.0 1]
    ]
}
```


Here's a small example: ([source](https://www.powsybl.org/pages/documentation/grid/formats/psse.html))

```json
{
     "network":{
         "caseid":{
             "fields":["ic", "sbase", "rev", "xfrrat", "nxfrat", "basfrq", "title1"],
             "data":[0, 100.00, 35, 0, 0, 60.00, "PSS(R)E Minimum RAWX Case"]
         },
         "bus":{
             "fields":["ibus", "name", "baskv", "ide"],
             "data":[
                 [1, "Slack-Bus", 138.0, 3],
                 [2, "Load-Bus", 138.0 1]
             ]
         },
         "load":{
             "fields":["ibus", "loadid", "stat", "pl", "ql"],
             "data":[
                 [2, "1", 1, 40.0, 15.0]
             ]
         },
         "generator":{
             "fields":["ibus", "machid", "pg", "qg"],
             "data":[
                 [1, "1", "40.35", "10.87"]
             ]
         },
         "acline":{
             "fields":["ibus", "jbus", "ckt", "rpu", "xpu", "bpu"],
             "data":[
                 [1, 2, "1", 0.01938, 0.05917, 0.05280]
             ]
         }
    }
}
```

## [GOCOMPETITION](https://gocompetition.energy.gov/)

### RAWGO

The RAW format of the Grid Optimization (GO) Competition is similar to the PSS®E RAW format but with more fields. A more in-depth description of this format 
can be found [here](https://gocompetition.energy.gov/sites/default/files/Challenge2_Problem_Formulation_20210531.pdf)

Here's a small example:

```
0,100.0,33,0,0,50.0
GRID OPTIMIZATION COMPETITION CHALLENGE 2
INPUT DATA FILES ARE RAW JSON CON
1,'            ',100.0,3,1,1,1,1.06,0.0,1.1,0.9,1.1,0.9
2,'            ',100.0,2,1,1,1,1.045,-4.9826,1.1,0.9,1.1,0.9
3,'            ',100.0,2,1,1,1,1.01,-12.7251,1.1,0.9,1.1,0.9
4,'            ',100.0,1,1,1,1,1.01767,-10.3129,1.1,0.9,1.1,0.9
5,'            ',100.0,1,1,1,1,1.01951,-8.7739,1.1,0.9,1.1,0.9
6,'            ',100.0,2,1,1,1,1.07,-14.221,1.1,0.9,1.1,0.9
7,'            ',100.0,1,1,1,1,1.06152,-13.3596,1.1,0.9,1.1,0.9
8,'            ',100.0,2,1,1,1,1.09,-13.3596,1.1,0.9,1.1,0.9
9,'            ',100.0,1,1,1,1,1.05593,-14.9385,1.1,0.9,1.1,0.9
10,'            ',100.0,1,1,1,1,1.05098,-15.0973,1.1,0.9,1.1,0.9
11,'            ',100.0,1,1,1,1,1.05691,-14.7906,1.1,0.9,1.1,0.9
12,'            ',100.0,1,2,1,1,1.05519,-15.0756,1.1,0.9,1.1,0.9
13,'            ',100.0,1,1,1,1,1.05038,-15.1563,1.1,0.9,1.1,0.9
14,'            ',100.0,1,1,1,1,1.03553,-16.0336,1.1,0.9,1.1,0.9
0 / END OF BUS DATA BEGIN LOAD DATA
1,'1',0,1,1,93.05130213,9.52761968,0.0,0.0,0.0,0.0,1,1,0
2,'1',1,1,1,16.8107012,11.00486003,0.0,0.0,0.0,0.0,1,1,0
3,'1',1,1,1,80.66188947,22.24943677,0.0,0.0,0.0,0.0,1,1,0
4,'1',1,1,1,51.23531309,-3.56688794,0.0,0.0,0.0,0.0,1,1,0
5,'1',1,1,1,7.1251291,2.06001615,0.0,0.0,0.0,0.0,1,1,0
6,'1',1,1,1,10.98278334,5.44991708,0.0,0.0,0.0,0.0,1,1,0
9,'1',1,1,1,24.68380574,15.82498583,0.0,0.0,0.0,0.0,1,1,0
10,'1',1,1,1,8.82165655,5.55372651,0.0,0.0,0.0,0.0,1,1,0
11,'1',1,1,1,3.84630233,1.45320338,0.0,0.0,0.0,0.0,1,1,0
12,'1',1,1,1,5.64341563,1.74133085,0.0,0.0,0.0,0.0,1,1,0
13,'1',1,1,1,11.66567328,5.28130269,0.0,0.0,0.0,0.0,1,1,0
14,'1',1,1,1,13.05130213,4.52761968,0.0,0.0,0.0,0.0,1,1,0
0 / END OF LOAD DATA BEGIN FIXED SHUNT DATA
9,'1',1,0.0,19.0
10,'1',0,0.0,19.0
0 / END OF FIXED SHUNT DATA BEGIN GENERATOR DATA
1,'1',232.393,-16.549,76.06114563,-132.20215728,1.06,0,100.0,0.0,1.0,0.0,0.0,1.0,1,100.0,245.44508658,37.96496068,1,1.0,0,1.0,0,1.0,0,1.0,0,1.0
2,'1',40.0,43.557,36.16681776,-76.98124849,1.045,0,100.0,0.0,1.0,0.0,0.0,1.0,1,100.0,157.50255639,48.14826636,1,1.0,0,1.0,0,1.0,0,1.0,0,1.0
3,'1',0.0,25.075,48.51225182,-0.87933042,1.01,0,100.0,0.0,1.0,0.0,0.0,1.0,1,100.0,82.49986204,5.80178827,1,1.0,0,1.0,0,1.0,0,1.0,0,1.0
6,'1',0.0,12.731,19.47136874,-19.11302463,1.07,0,100.0,0.0,1.0,0.0,0.0,1.0,1,100.0,110.50327558,11.46109347,1,1.0,0,1.0,0,1.0,0,1.0,0,1.0
8,'1',0.0,17.623,19.23728257,-8.03365315,1.09,0,100.0,0.0,1.0,0.0,0.0,1.0,1,100.0,80.14478049,0.31982867,1,1.0,0,1.0,0,1.0,0,1.0,0,1.0
10,'1',0.0,0.0,19.47136874,-19.11302463,1.05098,0,100.0,0.0,1.0,0.0,0.0,1.0,0,100.0,110.50327558,11.46109347,1,1.0,0,1.0,0,1.0,0,1.0,0,1.0
0 / END OF GENERATOR DATA BEGIN BRANCH DATA
1,2,'1',0.01938,0.05917,0.0528,141.6,188.4,188.4,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
1,5,'1',0.05403,0.22304,0.0492,51.6,68.4,68.4,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
2,3,'1',0.04699,0.19797,0.0438,210.0,280.8,280.8,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
2,4,'1',0.05811,0.17632,0.034,109.2,145.2,145.2,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
2,5,'1',0.05695,0.17388,0.0346,73.2,98.4,98.4,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
3,4,'1',0.06701,0.17103,0.0128,122.4,162.0,162.0,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
4,5,'1',0.01335,0.04211,0.0,458.4,610.8,610.8,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
6,11,'1',0.09498,0.1989,0.0,175.2,232.8,232.8,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
6,12,'1',0.12291,0.25581,0.0,51.6,68.4,68.4,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
6,13,'1',0.06615,0.13027,0.0,176.4,235.2,235.2,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
7,8,'1',0.0,0.17615,0.0,56.4,75.6,75.6,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
7,9,'1',0.0,0.11001,0.0,124.8,166.8,166.8,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
9,10,'1',0.03181,0.0845,0.0,255.6,340.8,340.8,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
9,14,'1',0.12711,0.27038,0.0,48.0,63.6,63.6,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
10,11,'1',0.08205,0.19207,0.0,156.0,208.8,208.8,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
10,14,'1',0.17093,0.34802,0.0,85.2,114.0,114.0,0.0,0.0,0.0,0.0,0,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
12,13,'1',0.22092,0.19988,0.0,38.4,50.4,50.4,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
13,14,'1',0.17093,0.34802,0.0,85.2,114.0,114.0,0.0,0.0,0.0,0.0,1,1,0.0,1,1.0,0,1.0,0,1.0,0,1.0
0 / END OF BRANCH DATA BEGIN TRANSFORMER DATA
4,7,0,'1',1,1,1,0.0,0.0,2,'0',1,1,1.0,0,1.0,0,1.0,0,1.0,'0'
0.0,0.20912,100.0
0.978,60.0,0.0,41.0,55.0,55.0,0,0,0.0,0.0,1.5,0.51,1,0,0.0,0.0,0.0
1.0,100.0
4,9,0,'1',1,1,1,0.0,0.0,2,'0',1,1,1.0,0,1.0,0,1.0,0,1.0,'0'
0.0,0.55618,100.0
0.969,60.0,0.0,24.0,31.0,31.0,0,0,0.0,0.0,1.5,0.51,1,0,0.0,0.0,0.0
1.0,100.0
5,6,0,'1',1,1,1,0.0,0.0,2,'0',1,1,1.0,0,1.0,0,1.0,0,1.0,'0'
0.0,0.25202,100.0
0.932,60.0,0.0,116.0,154.0,154.0,0,0,0.0,0.0,1.5,0.51,1,0,0.0,0.0,0.0
1.0,100.0
7,9,0,'2',1,1,1,0.0,0.0,2,'0',0,1,1.0,0,1.0,0,1.0,0,1.0,'0'
0.0,0.25202,100.0
0.932,60.0,0.0,116.0,154.0,154.0,0,0,0.0,0.0,1.5,0.51,1,0,0.0,0.0,0.0
1.0,100.0
0 / END OF TRANSFORMER DATA BEGIN AREA DATA
1,0,0.0,10.0,'            '
2,0,0.0,10.0,'            '
0 / END OF AREA DATA BEGIN TWO-TERMINAL DC DATA
0 / END OF TWO-TERMINAL DC DATA BEGIN VSC DC LINE DATA
0 / END OF VSC DC LINE DATA BEGIN IMPEDANCE CORRECTION DATA
0 / END OF IMPEDANCE CORRECTION DATA BEGIN MULTI-TERMINAL DC DATA
0 / END OF MULTI-TERMINAL DC DATA BEGIN MULTI-SECTION LINE DATA
0 / END OF MULTI-SECTION LINE DATA BEGIN ZONE DATA
0 / END OF ZONE DATA BEGIN INTER-AREA TRANSFER DATA
0 / END OF INTER-AREA TRANSFER DATA BEGIN OWNER DATA
0 / END OF OWNER DATA BEGIN FACTS DEVICE DATA
0 / END OF FACTS DEVICE DATA BEGIN SWITCHED SHUNT DATA
11,2,0,1,2.0,0.5,0,100.0,'0',0.0,1,40.0
13,2,0,0,2.0,0.5,0,100.0,'0',0.0,1,50.0
0 / END OF SWITCHED SHUNT DATA BEGIN GNE DATA
0 / END OF GNE DATA BEGIN INDUCTION MACHINE DATA
0 / END OF INDUCTION MACHINE DATA
Q
```


# Columns connection


## RAWGO

* `mpc.bus`

| **MATPOWER-M** | **DATA BLOCK** | **COLUMN** | **COLUMN_ID** |
|----------------|----------------|------------|---------------|
| BUS_I          | _Bus_          | I          | 1             |
| BUS_TYPE       |                |            |               |
| PD             | _Load_         | PL         | 6             |
| QD             | _Load_         | QL         | 7             |
| GS             | _FixedShunts_  | GL         | 4             |
| BS             | _FixedShunts_  | BL         | 5             |
| BUS_AREA       | _Bus_          | AREA       | 5             |
| VM             | _Bus_          | VM         | 8             |
| VA             | _Bus_          | VA         | 9             |
| BASE_KV        | _Bus_          | BASEKV     | 3             |
| ZONE           | _Bus_          | ZONE       | 6             |
| VMAX           | _Bus_          | NVHI       | 10            |
| VMIN           | _Bus_          | NVLO       | 11            |
| LAM_P          |                |            |               |
| LAM_Q          |                |            |               |
| MU_VMAX        |                |            |               |
| MU_VMIN        |                |            |               |

* `mpc.gen`

| **MATPOWER-M** | **DATA BLOCK** | **COLUMN** | **COLUMN_ID** |
|----------------|----------------|------------|---------------|
| GEN_BUS        | _Generator_    | I          | 1             |
| PG             | _Generator_    | PG         | 3             |
| QG             | _Generator_    | QG         | 4             |
| QMAX           | _Generator_    | QT         | 5             |
| QMIN           | _Generator_    | QB         | 6             |
| VG             |                |            |               |
| MBASE          | _Generator_    | MBASE      | 9             |
| GEN_STATUS     | _Generator_    | STAT       | 10            |
| PMAX           | _Generator_    | PT         | 12            |
| PMIN           | _Generator_    | PB         | 13            |
| PC1            |                |            |               |
| PC2            |                |            |               |
| QC1MIN         |                |            |               |
| QC1MAX         |                |            |               |
| QC2MIN         |                |            |               |
| QC2MAX         |                |            |               |
| RAMP_AGC       |                |            |               |
| RAMP_10        |                |            |               |
| RAMP_30        |                |            |               |
| RAMP_Q         |                |            |               |
| APF            |                |            |               |
| MU_PMAX        |                |            |               |
| MU_PMIN        |                |            |               |
| MU_QMAX        |                |            |               |
| MU_QMIN        |                |            |               |

* `mpc.branch`

| **MATPOWER-M** | **DATA BLOCK** | **COLUMN** | **COLUMN_ID** |
|----------------|----------------|------------|---------------|
| F_BUS          | _Branch_       | I          | 1             |
| T_BUS          | _Branch_       | J          | 2             |
| BR_R           | _Branch_       | R          | 4             |
| BR_X           | _Branch_       | X          | 5             |
| BR_B           | _Branch_       | B          | 6             |
| RATE_A         | _Branch_       | RATEA      | 7             |
| RATE_B         | _Branch_       | RATEB      | 8             |
| RATE_C         | _Branch_       | RATEC      | 9             |
| TAP            |                |            |               |
| SHIFT          |                |            |               |
| BR_STATUS      | _Branch_       | ST         | 14            |
| ANGMIN         |                |            |               |
| ANGMAX         |                |            |               |
| PF             |                |            |               |
| QF             |                |            |               |
| PT             |                |            |               |
| QT             |                |            |               |
| MU_SF          |                |            |               |
| MU_ST          |                |            |               |
| MU_ANGMIN      |                |            |               |
| MU_ANGMAX      |                |            |               |

* `mpc.gencost`

| **MATPOWER-M** | **DATA BLOCK** | **COLUMN** | **COLUMN_ID** |
|----------------|----------------|------------|---------------|
| MODEL          |                |            |               |
| STARTUP        |                |            |               |
| SHUTDOWN       |                |            |               |
| NCOST          |                |            |               |
| COST           |                |            |               |
