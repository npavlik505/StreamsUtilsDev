use crate::prelude::*;
use anyhow::Result;

/// generate some fixed-dt data for a given grid resoltuion
pub(crate) fn ai_institute(mut args: cli::JetValidation) -> Result<()> {
    super::check_options_copy_files(&mut args)?;
    let args = args;

    let x_length = 27.;
    let y_length = 6.;
    let z_length = 3.8;

    let fixed_dt = 0.0008439;

    let base_config = Config {
        reynolds_number: 250.0,
        mach_number: 2.28,
        shock_angle: 8.0,
        x_length,
        x_divisions: 600,
        y_length,
        y_divisions: 208,
        z_length,
        z_divisions: 100,
        mpi_x_split: 4,
        steps: args.steps,
        probe_io_steps: 0,
        span_average_io_steps: 10,
        blowing_bc: cli::JetActuator::None,
        snapshots_3d: false,
        use_python: true,
        fixed_dt: Some(fixed_dt),
        python_flowfield_steps: Some(1000),
        rly_wr: 2.5,
        nymax_wr: 201,
        probe_locations_x: Vec::new(),
        probe_locations_z: Vec::new(),
        flow_type: cli::FlowType::ShockBoundaryLayer,
        sensor_threshold: 0.1,
        shock_impingement: 15.,
    };

    let amplitude = 1.0;
    let angular_frequency = std::f64::consts::PI / 2.;
    let slot_start = 100;
    let slot_end = 149;

    let jet_actuation = [
        ("no_actuator", cli::JetActuator::None),
        (
            "constant_positive",
            cli::JetActuator::Constant {
                amplitude,
                slot_start,
                slot_end,
            },
        ),
        (
            "constant_negative",
            cli::JetActuator::Constant {
                amplitude: -1. * amplitude,
                slot_start,
                slot_end,
            },
        ),
        (
            "sinusoidal",
            cli::JetActuator::Sinusoidal {
                amplitude: -1. * amplitude,
                slot_start,
                slot_end,
                angular_frequency,
            },
        ),
    ];

    let mut jobs = Vec::new();

    for (case_name, actuator) in jet_actuation {
        let output_json_path = args.output_directory.join(format!("{case_name}.json"));
        let mut config = base_config.clone();
        config.blowing_bc = actuator;

        config.to_file(&output_json_path)?;

        let input_config = distribute::common::File::with_alias(output_json_path, "input.json")?;

        let job = distribute::apptainer::Job::new(case_name.to_string(), vec![input_config]);
        jobs.push(job)
    }

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

    let apptainer = distribute::apptainer::Description::new(init, jobs);
    let dist_config = distribute::ApptainerConfig::new(meta, apptainer);

    let jobs_path = args.output_directory.join("distribute-jobs.yaml");
    let file = fs::File::create(&jobs_path)
        .with_context(|| format!("failed to write jobs file at {}", jobs_path.display()))?;
    distribute::Jobs::from(dist_config).to_writer(file)?;

    Ok(())
}
