use crate::prelude::*;
use anyhow::Result;
use cli::FlowType;
use cli::JetActuator;

pub(crate) fn jet_validation(mut args: cli::JetValidation) -> Result<()> {
    super::check_options_copy_files(&mut args)?;
    let args = args;

    //let amplitudes = [0.2, 0.4, 0.6, 0.8, 1.0];
    let amplitudes = [1.0];
    //let signs = [1.0, -1.0];
    let signs = [1.0];
    let y_points = [300];

    // smaller number means better grid concentration towards the bottom
    let rly_wr = 0.5;

    let base_config = Config {
        reynolds_number: 250.0,
        mach_number: 0.0,
        shock_angle: 8.0,
        //x_length: 70.0,
        x_length: 3.0,
        x_divisions: 300,
        y_length: 3.,
        y_divisions: 300,
        z_length: 3.8,
        z_divisions: 100,
        mpi_x_split: 4,
        steps: args.steps,
        probe_io_steps: 0,
        span_average_io_steps: 100,
        blowing_bc: JetActuator::None,
        snapshots_3d: true,
        use_python: true,
        fixed_dt: None,
        python_flowfield_steps: Some(1000),
        rly_wr,
        nymax_wr: 99,
        probe_locations_x: Vec::new(),
        probe_locations_z: Vec::new(),
        flow_type: FlowType::BoundaryLayer,
        sensor_threshold: 0.1,
        shock_impingement: 15.,
    };

    let slot_start = 100;
    let slot_end = 200;

    let cases = itertools::iproduct!(
        amplitudes.into_iter(),
        signs.into_iter(),
        y_points.into_iter()
    )
    .map(|(amplitude, sign, y_points)| {
        let mut new_config = base_config.clone();
        new_config.blowing_bc = JetActuator::Constant {
            slot_start,
            slot_end,
            amplitude: amplitude * sign,
        };
        new_config.y_divisions = y_points;
        let case_name = if sign > 0. {
            format!(
                "jet_validation_pos_{}_amplitude_{y_points}_points",
                amplitude * sign
            )
        } else {
            format!(
                "jet_validation_neg_{}_amplitude_{y_points}_points",
                amplitude * sign
            )
        };

        (new_config, case_name)
    })
    .collect::<Vec<_>>();

    let mem = Some(crate::config_generator::Megabytes(11 * 10usize.pow(3)));
    let mut jobs = Vec::new();

    for (config, case_name) in cases {
        config
            .validate(mem)
            .with_context(|| format!("failed to validate case {case_name}"))?;

        let output_path = args.output_directory.join(format!("{case_name}.json"));
        config.to_file(&output_path)?;

        let job = distribute::apptainer::Job::new(
            case_name,
            vec![distribute::common::File::with_alias(
                output_path,
                "input.json",
            )?],
        );

        jobs.push(job);
    }

    let meta = distribute::Meta {
        batch_name: args.batch_name,
        namespace: "streams_jet_validation".into(),
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
