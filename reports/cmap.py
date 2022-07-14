from matplotlib.colors import LinearSegmentedColormap
import matplotlib.cm as cm
import seaborn as sns

c = ["darkred", "red", "darkorange", "orange", "darkgreen", "green"]
v = [0, .15, .4, 0.6, .9, 1.]
l = list(zip(v, c))
cmap = LinearSegmentedColormap.from_list('rg', l, N=256)


def sns_colorcmap(cmap, n_colors, desat=1):
    cm.register_cmap("mycolormap", cmap)
    cpal = sns.color_palette("mycolormap", n_colors=n_colors, desat=desat)
    return cpal

