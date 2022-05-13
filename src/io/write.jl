function format_col(col, val)
    return col == 1 ? "\t$val" : val
end


function _get_number_rep(n)
    if isinteger(n) 
        @sprintf "%.0f" n 
    else
        @sprintf "%.10f" n
    end
end

function _df2matpowermcsv_dfrow(row)
    row = [_get_number_rep(v) for v in row]
    return "\t" * join(row, "\t") * ";\n"
end

function _df2matpowermcsv(df)
    df_str = join(_df2matpowermcsv_dfrow.(eachrow(df))) 
end

function write_pfn(io::IO, network::PowerFlowNetwork)
    text = """function mpc = $(network.name)\n
%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = $(network.baseMVA);

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
$(_df2matpowermcsv(network.bus))];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
$(_df2matpowermcsv(network.gen))];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
$(_df2matpowermcsv(network.branch))];

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
$(_df2matpowermcsv(network.gencost))];"""
    write(io, text)
end

function write_pfn(file::AbstractString, network::PowerFlowNetwork)
    io = open(file, "w")
    write_pfn(io, network)
end
