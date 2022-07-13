from sqlite3 import connect
import pandas as pd
import matplotlib.pyplot as plt
import pathlib
from pathlib import Path
from matplotlib import rcParams
rcParams.update({'figure.autolayout': True})


con = connect('./data/PowerFlowNetworks.sqlite')


def plot_boxplot(df, column, out, y_lim=None):
    fig, ax = plt.subplots()
    df.boxplot(column=column)
    ax.set_xticklabels(ax.get_xticklabels(), rotation=90)
    if y_lim is not None:
        ax.set_ylim(y_lim)
    fig.savefig(out)


def plot_boxplot_pop(df, var):
    plot_boxplot(df, [f"{var}_min", f"{var}_max", f"{var}_mean", f"{var}_median", f"{var}_var"], f"fig_{var}.png")


def plot_report_instance(instance):
    id = instance["id"]
    decompositions = pd.read_sql(f'SELECT * FROM decompositions WHERE origin_id = {id} AND solving_time IS NOT NULL AND extension_alg NOT LIKE "interpolte:%"', con)
    if len(decompositions.index) == 0:
        return

    # Features variations
    plot_boxplot(decompositions, ["degree_min", "degree_max", "degree_mean", "degree_median", "degree_var", "global_clustering_coefficient", "density", "diameter", "radius", "nb_edge"], f"reports/plots/graph_{id}.png")
    plot_boxplot(decompositions, ["nb_clique", "clique_size_max", "clique_size_min", "clique_size_mean", "clique_size_median", "clique_size_var"], f"reports/plots/clique_{id}.png")
    plot_boxplot(decompositions, ["solving_time"], f"reports/plots/solve_{id}.png")


def plot_report_instances(instances):
    plot_boxplot(instances, ["nbus", "nbranch", "nbranch_unique", "ngen"], "reports/plots/fig_graph.png")


    plot_boxplot_pop(instances, "PD")
    plot_boxplot_pop(instances, "QD")
    plot_boxplot_pop(instances, "GS")
    plot_boxplot_pop(instances, "BS")
    plot_boxplot_pop(instances, "VM")
    plot_boxplot_pop(instances, "VA")
    plot_boxplot_pop(instances, "VMAX")

    plot_boxplot_pop(instances, "PG")
    plot_boxplot_pop(instances, "QG")
    plot_boxplot_pop(instances, "QMAX")
    plot_boxplot_pop(instances, "QMIN")
    plot_boxplot_pop(instances, "PMAX")
    plot_boxplot_pop(instances, "PMIN")

    plot_boxplot_pop(instances, "BR_R")
    plot_boxplot_pop(instances, "BR_X")
    plot_boxplot_pop(instances, "BR_B")

    instances.apply(plot_report_instance, axis=1)



def make_report_instance(instance):
    plot_path = Path("reports/plots").mkdir()
    id = instance["id"]
    decompositions = pd.read_sql(f'SELECT * FROM decompositions WHERE origin_id = {id} AND solving_time IS NOT NULL AND extension_alg NOT LIKE "interpolte:%"', con)
    if len(decompositions.index) == 0:
        return ""
    graph_path = Path(f"reports/plots/graph_{id}.png").resolve()
    clique_path = Path(f"reports/plots/clique_{id}.png").resolve()
    solve_path = Path(f"reports/plots/solve_{id}.png").resolve()
    string = f"""
## {instance["name"]} {{.tabset}}

### Graph

![]({graph_path})

### Clique

![]({clique_path})

### Solving time

![]({solve_path})

"""
    return string


def make_report_instances(instances):
    plot_report_instances(instances)
    string = "# Features report per instance{.tabset}\n\n" + "\n\n".join(instances.apply(make_report_instance, axis=1))
    global_features = ["graph",
                       "PD", "QD", "GS", "BS", "VM", "VA", "VMAX", "PG", "QG", "QMAX", "QMIN", "PMAX", "PMIN",
                       "BR_R", "BR_X", "BR_B"]
    string += "\n\n# Features report {.tabset}\n\n"
    for f in global_features:
        path = Path(f"reports/plots/fig_{f}.png").resolve()
        string += f"\n## {f} \n\n![]({path})\n"
    with open("reports/report_features.Rmd", "w") as io:
        io.write(string)



instances = pd.read_sql('SELECT * FROM instances', con)
make_report_instances(instances)
