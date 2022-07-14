from pca import plot_pca
from sqlite3 import connect
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from matplotlib import rcParams
rcParams.update({'figure.autolayout': True})


con = connect('./data/PowerFlowNetworks.sqlite')
highlight = ["case89pegase"]
instances = pd.read_sql('SELECT * FROM instances', con)
decompositions = pd.read_sql('SELECT * FROM decompositions WHERE solving_time IS NOT NULL AND solving_time != "NaN"', con)
features_dict = {
    "decompositions": ["nb_edge", "nb_vertex",
                       "degree_max", "degree_min", "degree_mean", "degree_median", "degree_var",
                       "global_clustering_coefficient", "density", "diameter",
                       "clique_size_max", "clique_size_min", "clique_size_mean", "clique_size_median", "clique_size_var"],
    "instances": ["nbus", "nbranch", "nbranch_unique", "ngen",
                  "degree_max", "degree_min", "degree_mean", "degree_median", "degree_var",
                  "global_clustering_coefficient", "density", "diameter",
                  "PD_max", "PD_min", "PD_mean", "PD_median", "PD_var",
                  "QD_max", "QD_min", "QD_mean", "QD_median", "QD_var",
                  "GS_max", "GS_min", "GS_mean", "GS_median", "GS_var",
                  "BS_max", "BS_min", "BS_mean", "BS_median", "BS_var",
                  "VM_max", "VM_min", "VM_mean", "VM_median", "VM_var",
                  "VA_max", "VA_min", "VA_mean", "VA_median", "VA_var",
                  "VMAX_max", "VMAX_min", "VMAX_mean", "VMAX_median", "VMAX_var",
                  "VMIN_max", "VMIN_min", "VMIN_mean", "VMIN_median", "VMIN_var",

                  "PG_max", "PG_min", "PG_mean", "PG_median", "PG_var",
                  "QG_max", "QG_min", "QG_mean", "QG_median", "QG_var",
                  "QMAX_max", "QMAX_min", "QMAX_mean", "QMAX_median", "QMAX_var",
                  "QMIN_max", "QMIN_min", "QMIN_mean", "QMIN_median", "QMIN_var",
                  "PMAX_max", "PMAX_min", "PMAX_mean", "PMAX_median", "PMAX_var",
                  "PMIN_max", "PMIN_min", "PMIN_mean", "PMIN_median", "PMIN_var",

                  "BR_R_max", "BR_R_min", "BR_R_mean", "BR_R_median", "BR_R_var",
                  "BR_X_max", "BR_X_min", "BR_X_mean", "BR_X_median", "BR_X_var",
                  "BR_B_max", "BR_B_min", "BR_B_mean", "BR_B_median", "BR_B_var"
        ]

}


def boxplot(df, column, out, y_lim=None, highlight=[]):
    fig, ax = plt.subplots()
    df.boxplot(column=column)
    for h in highlight:
        values = df.loc[df[df["name"] == h].index].iloc[0, :][column].tolist()
        ax.scatter(np.arange(len(values)), values, color='r')
    ax.set_xticklabels(ax.get_xticklabels(), rotation=90)
    if y_lim is not None:
        ax.set_ylim(y_lim)
    fig.savefig(out)


def boxplot_pop(df, var, highlight=[]):
    boxplot(df, [f"{var}_min", f"{var}_max", f"{var}_mean", f"{var}_median"], f"reports/plots/fig_{var}.png", highlight=highlight)


def boxplot_column_by(df, column, by, suffix=""):
    fig, ax = plt.subplots()
    df.boxplot(column=column, by=by, ax=ax, rot=90)
    fig.savefig(f"reports/plots/boxplot_{column[0]}{suffix}.png")


def plot_report(instances, decompositions):
    for f in features_dict["decompositions"]:
        boxplot_column_by(decompositions, [f], by="origin_name", suffix="_decompositions")

    boxplot_pop(instances, "PD", highlight=highlight)
    boxplot_pop(instances, "QD", highlight=highlight)
    boxplot_pop(instances, "GS", highlight=highlight)
    boxplot_pop(instances, "BS", highlight=highlight)
    boxplot_pop(instances, "VM", highlight=highlight)
    boxplot_pop(instances, "VA", highlight=highlight)
    boxplot_pop(instances, "VMAX", highlight=highlight)

    boxplot_pop(instances, "PG", highlight=highlight)
    boxplot_pop(instances, "QG", highlight=highlight)
    boxplot_pop(instances, "QMAX", highlight=highlight)
    boxplot_pop(instances, "QMIN", highlight=highlight)
    boxplot_pop(instances, "PMAX", highlight=highlight)
    boxplot_pop(instances, "PMIN", highlight=highlight)

    boxplot_pop(instances, "BR_R", highlight=highlight)
    boxplot_pop(instances, "BR_X", highlight=highlight)
    boxplot_pop(instances, "BR_B", highlight=highlight)

    # PCA
    decompositions["category"] = decompositions["origin_name"].isin(highlight) + 0
    instances["category"] = instances["name"].isin(highlight) + 0
    groups = decompositions[["solving_time", "origin_name"]].groupby("origin_name")
    mean, std = groups.transform("mean"), groups.transform("std")
    decompositions["solving_time_normalized"] = (decompositions[mean.columns] - mean) / std
    plot_pca(decompositions,
             features_dict["decompositions"],
             out_dir="reports/plots/",
             suffix="_decompositions",
             hue=decompositions["solving_time_normalized"],
             symbol=decompositions["category"])
    plot_pca(instances,
             features_dict["instances"],
             out_dir="reports/plots/",
             suffix="_instances",
             hue=instances["category"],
             symbol=instances["category"])




def make_report_instances(instances, decompositions):
    path_plot = Path("reports/plots")
    path_plot.mkdir(exist_ok=True)

    plot_report(instances, decompositions)


    string = "# Per features\n\n"
    string += "\n## Decompositions {.tabset}\n"
    for f in features_dict["decompositions"]:
        path = path_plot.joinpath(f"boxplot_{f}_decompositions.png").resolve()
        string += f"\n### {f} \n![]({path})\n"

    path_scree_instances = path_plot.joinpath("scree_plot_instances.png").resolve()
    path_scree_decompositions = path_plot.joinpath("scree_plot_decompositions.png").resolve()
    path_pca_1_instances = path_plot.joinpath("pca_1_instances.png").resolve()
    path_pca_1_decompositions = path_plot.joinpath("pca_1_decompositions.png").resolve()
    path_pca_2_instances = path_plot.joinpath("pca_2_instances.png").resolve()
    path_pca_2_decompositions = path_plot.joinpath("pca_2_decompositions.png").resolve()
    path_pca_3_instances = path_plot.joinpath("pca_3_instances.html").resolve()
    path_pca_3_decompositions = path_plot.joinpath("pca_3_decompositions.html").resolve()
    string += f"""

# PCA {{.tabset}}

## Instances

![]({path_pca_1_instances})

![]({path_pca_2_instances})

![]({path_scree_instances})

[3D plot]({path_pca_3_instances})

## Decompositions

![]({path_pca_1_decompositions})

![]({path_pca_2_decompositions})

![]({path_scree_decompositions})

[3D plot]({path_pca_3_decompositions})
"""


    # Write to rmarkdown file
    with open("reports/report_features.Rmd", "w") as io:
        io.write(string)



make_report_instances(instances, decompositions)
