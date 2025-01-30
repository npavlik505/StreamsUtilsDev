use crate::prelude::*;
use anyhow::Result;

// for now we just reuse jet validation struct since it contains all the data we need to calculate
// everything
pub(crate) fn variable_dt(mut args: cli::JetValidation) -> Result<()> {
    super::check_options_copy_files(&mut args)?;
    let args = args;

    let base_config = Config {
        reynolds_number: 250.0,
        mach_number: 2.28,
        shock_angle: 8.0,
        x_length: 27.0,
        x_divisions: 600,
        y_length: 6.,
        y_divisions: 208,
        z_length: 3.8,
        z_divisions: 100,
        mpi_x_split: 4,
        steps: args.steps,
        blowing_bc: cli::JetActuator::None,
        snapshots_3d: true,
        use_python: true,
        fixed_dt: None,
        python_flowfield_steps: Some(1000),
        rly_wr: 2.5,
        nymax_wr: 201,
        probe_locations_x: Vec::new(),
        probe_locations_z: Vec::new(),
        flow_type: cli::FlowType::ShockBoundaryLayer,
        sensor_threshold: 0.1,
        shock_impingement: 15.,
    };

    let case_name = "variable_dt_data_collection";
    let output_json_path = args.output_directory.join(format!("{case_name}.json"));
    base_config.to_file(&output_json_path)?;

    let input_config = distribute::common::File::with_alias(output_json_path, "input.json")?;

    let job = distribute::apptainer::Job::new(case_name.to_string(), vec![input_config]);

    let meta = distribute::Meta {
        batch_name: args.batch_name,
        namespace: "streams_sbli".into(),
        matrix: args.matrix.clone(),
        capabilities: vec!["gpu", "apptainer", "lab1"]
            .into_iter()
            .map(Into::into)
            .collect(),
    };

    let input_files = vec![distribute::common::File::with_alias(
        &args.database_bl,
        "database_bl.dat",
    )?];

    let init = distribute::apptainer::Initialize::new(
        distribute::common::File::new(args.solver_sif.clone())?,
        // files
        input_files,
        // mounts
        vec![],
    );

    let apptainer = distribute::apptainer::Description::new(init, vec![job]);
    let dist_config = distribute::ApptainerConfig::new(meta, apptainer);

    let jobs_path = args.output_directory.join("distribute-jobs.yaml");
    let file = fs::File::create(&jobs_path)
        .with_context(|| format!("failed to write jobs file at {}", jobs_path.display()))?;
    distribute::Jobs::from(dist_config).to_writer(file)?;

    Ok(())
}
