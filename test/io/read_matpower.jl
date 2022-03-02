@testset "Read MATPOWER" begin
    path = "./test/data/case6ww.m"
    network = PowerFlowNetwork(path; format="MATPOWER-M")
    @test network.baseMVA == 100
    bus = zeros(6, 17)
    bus[:, 1:13] = [1  3  0   0   0  0  1  1.05  0  230  1  1.05  1.05;
                    2  2  0   0   0  0  1  1.05  0  230  1  1.05  1.05;
                    3  2  0   0   0  0  1  1.07  0  230  1  1.07  1.07;
                    4  1  70  70  0  0  1  1     0  230  1  1.05  0.95;
                    5  1  70  70  0  0  1  1     0  230  1  1.05  0.95;
                    6  1  70  70  0  0  1  1     0  230  1  1.05  0.95;]
    gen = zeros(3, 25)
    gen[:, 1:21] = [1  0   0  100  -100  1.05  100  1  200  50    0  0  0  0  0  0  0  0  0  0  0;
                    2  50  0  100  -100  1.05  100  1  150  37.5  0  0  0  0  0  0  0  0  0  0  0;
                    3  60  0  100  -100  1.07  100  1  180  45    0  0  0  0  0  0  0  0  0  0  0;]
    branch = zeros(11, 21)
    branch[:, 1:13] = [1  2  0.1   0.2   0.04  40  40  40  0  0  1  -360  360;
                       1  4  0.05  0.2   0.04  60  60  60  0  0  1  -360  360;
                       1  5  0.08  0.3   0.06  40  40  40  0  0  1  -360  360;
                       2  3  0.05  0.25  0.06  40  40  40  0  0  1  -360  360;
                       2  4  0.05  0.1   0.02  60  60  60  0  0  1  -360  360;
                       2  5  0.1   0.3   0.04  30  30  30  0  0  1  -360  360;
                       2  6  0.07  0.2   0.05  90  90  90  0  0  1  -360  360;
                       3  5  0.12  0.26  0.05  70  70  70  0  0  1  -360  360;
                       3  6  0.02  0.1   0.02  80  80  80  0  0  1  -360  360;
                       4  5  0.2   0.4   0.08  20  20  20  0  0  1  -360  360;
                       5  6  0.1   0.3   0.06  40  40  40  0  0  1  -360  360;]
    colnames = Dict(
        "bus" => ["ID", "TYPE", "PD", "QD", "GS", "BS", "BUS_AREA", "VM", "VA", "BASE_KV", "ZONE", "VMAX", "VMIN", "LAM_P",
                  "LAM_Q", "MU_VMAX", "MU_VMIN"],
        "gen" => ["ID", "PG", "QG", "QMAX", "QMIN", "VG", "MBASE", "GEN_STATUS", "PMAX", "PMIN", "PC1", "PC2", "QC1MIN",
                  "QC1MAX", "QC2MIN", "QC2MAX", "RAMP_AGC", "RAMP_10", "RAMP_30", "RAMP_Q", "APF", "MU_PMAX", "MU_PMIN",
                  "MU_QMAX", "MU_QMIN"],
        "branch" => ["SRC", "DST", "BR_R", "BR_X", "BR_B", "RATE_A", "RATE_B", "RATE_C", "TAP", "SHIFT", "BR_STATUS",
                     "ANGMIN", "ANGMAX", "PF", "QF", "PT", "QT", "MU_SF", "MU_ST", "MU_ANGMIN", "MU_ANGMAX"],
        "gencost" => ["MODEL", "STARTUP", "SHUTDOWN", "NCOST", "COST"]
    )    
    @test network.bus == DataFrame(bus, colnames["bus"])
    @test network.gen == DataFrame(gen, colnames["gen"])
    @test network.branch == DataFrame(branch, colnames["branch"])
    @test nbus(network) == nbus(path; format="MATPOWER-M")
    @test nbranch(network) == nbranch(path; format="MATPOWER-M")
    @test nbranch(network, distinct_pair=true) == nbranch(path; format="MATPOWER-M", distinct_pair=true)
end
