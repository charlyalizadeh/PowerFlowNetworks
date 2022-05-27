function create_instances_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS instances(
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        scenario INTEGER NOT NULL,
        source_path TEXT NOT NULL,
        source_type TEXT NOT NULL,
        network_path TEXT,
        graph_path TEXT,
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

        UNIQUE(name, scenario),
        PRIMARY KEY(id)
    )
    """
    SQLite.execute(db, createtable_query)
end

function create_decompositions_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS decompositions(
        id INTEGER NOT NULL,
        uuid TEXT NOT NULL,
        origin_id INTEGER NOT NULL,
        origin_name TEXT NOT NULL,
        origin_scenario INTEGER NOT NULL,

        extension_alg TEXT,
        preprocess_path TEXT,
        preprocess_key TEXT,
        date TEXT,

        clique_path TEXT,
        cliquetree_path TEXT,
        graph_path TEXT,

        nb_added_edge_dec INTEGER,
        nb_edge INTEGER,
        nb_vertex INTEGER,
        degree_max INTEGER, degree_min INTEGER, degree_mean REAL, degree_median REAL, degree_var REAL,
        global_clustering_coefficient REAL,
        density REAL,
        diameter INTEGER,
        radius INTEGER,

        nb_clique INTEGER,
        clique_size_max INTEGER, clique_size_min INTEGER, clique_size_mean REAL, clique_size_median REAL, clique_size_var REAL,
        nb_lc INTEGER,

        date_solving TEXT,
        solve_log_path TEXT,
        objective REAL, nb_iter INTEGER, m REAL,
        solving_time REAL,


        PRIMARY KEY(id),
        FOREIGN KEY(origin_name, origin_scenario) REFERENCES instances(name, scenario)
    )
    """
    SQLite.execute(db, createtable_query)
end

function create_merges_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS merges(
        in_id INTEGER NOT NULL,
        out_id INTEGER NOT NULL,
        heuristics TEXT NOT NULL,
        treshold_name TEXT NOT NULL,
        treshold_percent REAL NOT NULL,

        nb_added_edge INT NOT NULL,

        PRIMARY KEY(in_id, out_id),
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
        how TEXT NOT NULL,
        extension_alg TEXT NOT NULL,

        PRIMARY KEY(in_id1, in_id2, out_id),
        FOREIGN KEY(in_id1) REFERENCES decompositions(id),
        FOREIGN KEY(in_id2) REFERENCES decompositions(id),
        FOREIGN KEY(out_id) REFERENCES decompositions(id)
    )
    """
    SQLite.execute(db, createtable_query)
end

function setup_db(name; delete_if_exists=false)
    db = SQLite.DB(name)
    if delete_if_exists
        delete_table(db, table) = DBInterface.execute(db, "DROP TABLE IF EXISTS $table")
        delete_table(db, "instances")
        delete_table(db, "decompositions")
        delete_table(db, "merges")
        delete_table(db, "combinations")
    end
    create_instances_table(db)
    create_decompositions_table(db)
    create_merges_table(db)
    create_combinations_table(db)
    return db
end
