function format_col(col, val)
    return col == 1 ? "\t$val" : val
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
\t"""
    write(io, text)
    CSV.write(io, network.bus; delim='\t', append=true, newline=";\n\t")
    text = """];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
\t"""
    write(io, text)
    CSV.write(io, network.gen; delim='\t', append=true, newline=";\n\t")
    text = """];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
\t"""
    write(io, text)
    CSV.write(io, network.branch; delim='\t', append=true, newline=";\n\t")
    text = """];

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
\t"""
    write(io, text)
    CSV.write(io, network.gencost; delim='\t', append=true, newline=";\n\t")
    text = "];"
    write(io, text)
end

function write_pfn(file::AbstractString, network::PowerFlowNetwork)
    io = open(file, "w")
    write_pfn(io, network)
end
