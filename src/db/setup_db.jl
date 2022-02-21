function create_instances_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS instances(
        name TEXT NOT NULL,
        scenario INTEGER NOT NULL,
        source_path TEXT NOT NULL,
        source_type TEXT NOT NULL,
        mat_path TEXT,
        ctr_path TEXT,
        date TEXT NOT NULL,

        nb_edge INTEGER,
        nb_vertex INTEGER,
        degree_max INTEGER, degree_min INTEGER, degree_mean REAL,
        global_clustering_coefficient REAL,
        density REAL,
        diameter INTEGER,
        radius INTEGER,

        PD_max REAL, PD_min REAL, PD_mean REAL,
        QD_max REAL, QD_min REAL, QD_mean REAL,
        GS_max REAL, GS_min REAL, GS_mean REAL,
        BS_max REAL, BS_min REAL, BS_mean REAL,
        VM_max REAL, VM_min REAL, VM_mean REAL,
        VA_max REAL, VA_min REAL, VA_mean REAL,
        VMAX_max REAL, VMAX_min REAL, VMAX_mean REAL,
        VMIN_max REAL, VMIN_min REAL, VMIN_mean REAL,

        PG_max REAL, PG_min REAL, PG_mean REAL,
        QG_max REAL, QG_min REAL, QG_mean REAL,
        QMAX_max REAL, QMAX_min REAL, QMAX_mean REAL,
        QMIN_max REAL, QMIN_min REAL, QMIN_mean REAL,
        PMAX_max REAL, PMAX_min REAL, PMAX_mean REAL,
        PMIN_max REAL, PMIN_min REAL, PMIN_mean REAL,

        BR_R_max REAL, BR_R_min REAL, BR_R_mean REAL,
        BR_X_max REAL, BR_X_min REAL, BR_X_mean REAL,
        BR_B_max REAL, BR_B_min REAL, BR_B_mean REAL,

        PRIMARY KEY(name, scenario)
    )
    """
    SQLite.execute(db, createtable_query)
end

function create_decompositions_table(db)
    createtable_query = """
    CREATE TABLE IF NOT EXISTS decompositions(
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        origin_name TEXT NOT NULL,
        origin_scenario INTEGER NOT NULL,

        pre_process_path TEXT,
        nb_added_edge_dec INTEGER,
        date TEXT,

        clique_path TEXT,
        cliquetree_path TEXT,

        nb_edge INTEGER,
        nb_vertex INTEGER,
        degree_max INTEGER, degree_min INTEGER, degree_mean REAL,
        global_clustering_coefficient REAL,
        density REAL,
        diameter INTEGER,
        radius INTEGER,

        nb_clique INTEGER,
        clique_size_max INTEGER, clique_size_min INTEGER, clique_size_mean REAL, clique_size_var REAL,
        nb_lnkctr INTEGER,

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
