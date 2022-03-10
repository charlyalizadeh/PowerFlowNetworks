function create_instances_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS instances(
        name TEXT NOT NULL,
        scenario INTEGER NOT NULL,
        source_path TEXT NOT NULL,
        source_type TEXT NOT NULL,
        source_pfn TEXT,
        source_graph TEXT,
        mat_path TEXT,
        ctr_path TEXT,
        date TEXT NOT NULL,

        nbus INTEGER, nbranch INTEGER, nbranch_unique INTEGER, ngen INTEGER,

        nb_edge INTEGER,
        nb_vertex INTEGER,
        degree_max INTEGER, degree_min INTEGER, degree_mean REAL, degree_median REAL, degree_var REAL,
        global_clustering_coefficient REAL,
        density REAL,
        diameter INTEGER,
        radius INTEGER,

        PD_max REAL, PD_min REAL, PD_mean REAL, PD_median REAL, PD_var REAL,
        QD_max REAL, QD_min REAL, QD_mean REAL, QD_median REAL, QD_var REAL,
        GS_max REAL, GS_min REAL, GS_mean REAL, GS_median REAL, GS_var REAL,
        BS_max REAL, BS_min REAL, BS_mean REAL, BS_median REAL, BS_var REAL,
        VM_max REAL, VM_min REAL, VM_mean REAL, VM_median REAL, VM_var REAL,
        VA_max REAL, VA_min REAL, VA_mean REAL, VA_median REAL, VA_var REAL,
        VMAX_max REAL, VMAX_min REAL, VMAX_mean REAL, VMAX_median REAL, VMAX_var REAL,
        VMIN_max REAL, VMIN_min REAL, VMIN_mean REAL, VMIN_median REAL, VMIN_var REAL,

        PG_max REAL, PG_min REAL, PG_mean REAL, PG_median REAL, PG_var REAL,
        QG_max REAL, QG_min REAL, QG_mean REAL, QG_median REAL, QG_var REAL,
        QMAX_max REAL, QMAX_min REAL, QMAX_mean REAL, QMAX_median REAL, QMAX_var REAL,
        QMIN_max REAL, QMIN_min REAL, QMIN_mean REAL, QMIN_median REAL, QMIN_var REAL,
        PMAX_max REAL, PMAX_min REAL, PMAX_mean REAL, PMAX_median REAL, PMAX_var REAL,
        PMIN_max REAL, PMIN_min REAL, PMIN_mean REAL, PMIN_median REAL, PMIN_var REAL,

        BR_R_max REAL, BR_R_min REAL, BR_R_mean REAL, BR_R_median REAL, BR_R_var REAL,
        BR_X_max REAL, BR_X_min REAL, BR_X_mean REAL, BR_X_median REAL, BR_X_var REAL,
        BR_B_max REAL, BR_B_min REAL, BR_B_mean REAL, BR_B_median REAL, BR_B_var REAL,

        PRIMARY KEY(name, scenario)
    )
    """
    SQLite.execute(db, createtable_query)
end

function create_decompositions_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS decompositions(
        id INTEGER NOT NULL,
        uuid TEXT NOT NULL,
        origin_name TEXT NOT NULL,
        origin_scenario INTEGER NOT NULL,

        extension_alg TEXT,
        preprocess_path TEXT,
        date TEXT,

        clique_path TEXT,
        cliquetree_path TEXT,

        nb_added_edge_dec INTEGER,
        nb_edge INTEGER,
        nb_vertex INTEGER,
        degree_max INTEGER, degree_min INTEGER, degree_mean REAL, degree_median REAL, degree_var REAL,
        global_clustering_coefficient REAL,
        density REAL,
        diameter INTEGER,
        radius INTEGER,

        nb_clique INTEGER,
        cliques_size_max INTEGER, cliques_size_min INTEGER, cliques_size_mean REAL, cliques_size_median REAL, cliques_size_var REAL,
        nb_lc INTEGER,

        PRIMARY KEY(id),
        FOREIGN KEY(origin_name, origin_scenario) REFERENCES instances(name, scenario)
    )
    """
    SQLite.execute(db, createtable_query)
end

function create_mergers_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS mergers(
        in_id INTEGER NOT NULL,
        out_id INTEGER NOT NULL,
        merge_type TEXT NOT NULL,
        merge_criterion TEXT NOT NULL,
        merge_treshold TEXT NOT NULL,

        PRIMARY KEY(in_id, merge_type, merge_criterion, merge_treshold),
        FOREIGN KEY(in_id) REFERENCES decompositions(id),
        FOREIGN KEY(out_id) REFERENCES decompositions(id)
    )
    """
    SQLite.execute(db, createtable_query)
end

function create_combinations_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS combinations(
        in_id1 INTEGER NOT NULL,
        in_id2 INTEGER NOT NULL,
        out_id INTEGER NOT NULL,
        combine_type TEXT NOT NULL,

        PRIMARY KEY(in_id1, in_id2, out_id),
        FOREIGN KEY(in_id1) REFERENCES decompositions(id),
        FOREIGN KEY(in_id2) REFERENCES decompositions(id),
        FOREIGN KEY(out_id) REFERENCES decompositions(id)
    )
    """
    SQLite.execute(db, createtable_query)
end

function create_solve_results_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS solve_results(
        id INTEGER NOT NULL,
        solve_config_path TEXT,
        date TEXT NOT NULL,
        solve_log_path TEXT,
        decomposition_id INTEGER NOT NULL,

        PRIMARY KEY(id),
        FOREIGN KEY(decomposition_id) REFERENCES decompositions(id)
    )
    """
    SQLite.execute(db, createtable_query)
end

function setup_db(name)
    db = SQLite.DB(name)
    create_instances_table(db)
    create_decompositions_table(db)
    create_mergers_table(db)
    create_combinations_table(db)
    create_solve_results_table(db)
    return db
end
