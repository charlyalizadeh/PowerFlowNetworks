from sqlite3 import connect
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.legend_handler import HandlerPatch
import seaborn as sns
from cmap import cmap, sns_colorcmap
import plotly.express as px
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from pathlib import Path


def scree_plot(pca, n=None, ax=None):
    ax = ax or plt.gca()
    n = n or pca.n_components_
    return sns.lineplot(x=range(n),
                        y=pca.explained_variance_ratio_[:n],
                        markers=True,
                        ax=ax)


def ind_factor_map(X, hue, symbol, c=(0, 1), ax=None, log_x=False, log_y=False):
    ax = ax or plt.gca()
    nunique_hue = len(np.unique(hue))
    palette = None
    if nunique_hue > 2:
        palette = sns.color_palette("flare", as_cmap=True)
    else:
        palette = sns.color_palette("hls", nunique_hue)
    plot = sns.scatterplot(x=X[:, c[0]], y=X[:, c[1]], hue=hue, style=symbol, size=symbol.replace({0: 1, 1: 0}), ax=ax,
                           palette=palette)
    if log_x:
        plt.xscale('log', base=10)
    if log_y:
        plt.yscale('log', base=10)
    return plot


def var_factor_map(pca, c=(0, 1), columns=None, ax=None, select=lambda x: True, rem_prefix=False):
    ax = ax or plt.gca()
    columns = columns or [f'Axe {i}' for i in range(pca.components_.shape[1])]
    circle = plt.Circle(xy=(0, 0), radius=1, color='red', fill=False)
    ax.add_patch(circle)
    for k in range(pca.components_.shape[1]):
        if select(columns[k]):
            ax.arrow(0, 0, pca.components_[c[0], k], pca.components_[c[1], k])
            text = columns[k] if not rem_prefix or '.' not in columns[k] else columns[k].split('.')[1]
            ax.text(pca.components_[c[0], k], pca.components_[c[1], k], text, fontsize='small')
    ax.set_xlim(-1.1, 1.1)
    ax.set_ylim(-1.1, 1.1)
    return ax


def get_info_ax(pca, axs):
    return {
        'variance': pca.explained_variance_[axs],
        'variance%': pca.explained_variance_ratio_[axs],
    }


def format_info_ax(pca, ax):
    ax = ax if type(ax) == list else [ax]
    info = get_info_ax(pca, ax)
    df = pd.DataFrame.from_dict(info, orient='index', columns=[f'Axe {a}' for a in ax])
    return df.to_markdown()


def plot_pca(df, X_cols, out_dir, hue=None, symbol=None, suffix=""):
    out_dir = Path(out_dir)
    X = df[X_cols]
    X = X.dropna(axis='columns').to_numpy()
    sc = StandardScaler()
    X = sc.fit_transform(X)

    pca = PCA(svd_solver='full')
    X_pca = pca.fit_transform(X)

    fig, (ax1, ax2) = plt.subplots(2)
    fig.suptitle('Scree plot')
    scree_plot(pca, ax=ax1)
    ax1.set_title(f'Scree plot (n_components={pca.n_components_})')
    scree_plot(pca, 3, ax=ax2)
    ax2.set_title('Scree plot (n_components=3)')
    fig.savefig(out_dir.joinpath(f"scree_plot{suffix}.png"))

    fig_pca_1, ax_pca_1 = plt.subplots()
    ind_factor_map(X_pca, hue, symbol=symbol, ax=ax_pca_1, log_x=False, log_y=False)
    fig_pca_2, ax_pca_2 = plt.subplots()
    ind_factor_map(X_pca[:, 1:], hue, symbol=symbol, ax=ax_pca_2, log_x=False, log_y=False)
    fig_pca_1.savefig(out_dir.joinpath(f"pca_1{suffix}.png"))
    fig_pca_1.savefig(out_dir.joinpath(f"pca_2{suffix}.png"))

    df = pd.DataFrame({'Axis 1': X_pca[:, 0],
                       'Axis 2': X_pca[:, 1],
                       'Axis 3': X_pca[:, 2],
                       'category': symbol})
    fig_pca_3 = px.scatter_3d(df, x='Axis 1', y='Axis 2', z='Axis 3',
                              color=hue,
                              color_continuous_scale=['red', 'orange', 'green'],
                              symbol=symbol,
                              size=[15] * (len(df.index) - 5) + [1] * 5,
                              log_x=False,
                              log_y=False,
                              log_z=False)
    fig_pca_3.update_traces(marker=dict(size=4, line=dict(width=2, color='DarkSlateGrey')),
                            selector=dict(mode='markers'))
    fig_pca_3.write_html(out_dir.joinpath(f"pca_3{suffix}.html"), )
