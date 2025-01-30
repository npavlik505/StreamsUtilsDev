use super::check_options_copy_files;
use crate::prelude::*;
use cli::SbliCases;

use anyhow::Result;

#[derive(thiserror::Error, Debug)]
pub(crate) enum SbliError {
    #[error("The output path {} already exists. Its contents would be overwritten by this run.", .0.display())]
    OutputPathExists(PathBuf),
    #[error("The database_bl file {} does not exist", .0.display())]
    DatabaseBlMissing(PathBuf),
    #[error("{0}")]
    Copy(CopyFile),
}

#[derive(Debug, Display, Constructor)]
#[display(
    fmt = "failed to copy file from {} to {}. Error: {}",
    "source.display()",
    "dest.display()",
    error
)]
pub(crate) struct CopyFile {
    source: PathBuf,
    dest: PathBuf,
    error: io::Error,
}

pub(crate) fn sbli_cases(mut args: SbliCases) -> Result<()> {
    check_options_copy_files(&mut args)?;
    // remove mutability on args
    let args = args;

    match args.mode {
        cli::SbliMode::Sweep => sweep_cases(args)?,
        cli::SbliMode::CheckBlowingCondition => check_blowing_condition(args)?,
        cli::SbliMode::CheckProbes => check_probes(args)?,
        cli::SbliMode::OneCase => one_case(args)?,
    };

    Ok(())
}

/// helper function to add a bunch of cases to the cases vector
/// with two simple callbacks (one to create the name, one to update
/// the value in the config that is desired)
fn create_cases<T, V, Val>(
    create_case_name: T,
    update_config: V,
    cases: &mut Vec<cli::ConfigGenerator>,
    values: &[Val],
    output_directory: &Path,
) where
    T: Fn(usize, &Val) -> String,
    V: Fn(&mut cli::ConfigGenerator, Val),
    Val: Copy,
{
    for (idx, update_value) in values.into_iter().enumerate() {
        //let case_name = format!("reynolds_number_{idx}.json");
        let case_name = create_case_name(idx, update_value);
        let case_path = output_directory.join(case_name);
        let mut config = cli::ConfigGenerator::with_path(case_path);
        update_config(&mut config, *update_value);
        cases.push(config)
    }
}

/// generate a sweep over combinations of shock angles and mach numbers
fn sweep_cases(args: SbliCases) -> Result<()> {
    // angle of the shock (degrees)
    let shock_angle = [6., 8., 10.];

    // mach numbers (rm)
    let mach_numbers = [2., 2.25, 2.5];

    let mut permutations = Vec::new();
    let mut cases = Vec::new();

    // other configurable information
    let steps = 50_000;
    let span_average_steps = 20;
    let probe_io_steps = 20;

    for angle in shock_angle {
        for mach in mach_numbers {
            permutations.push((angle, mach));
        }
    }

    let path_format = |_idx, values: &(f64, f64)| {
        let (shock_angle, mach_number) = values;
        format!("shock_{}_mach_{}.json", shock_angle, mach_number)
    };

    // set up how each value will change on a per-case basis
    let adj_value = |config: &mut cli::ConfigGenerator, (angle, mach)| {
        config.mach_number = mach;
        config.shock_angle = angle;

        // constant parameters
        config.probe_io_steps = probe_io_steps;
        config.span_average_io_steps = span_average_steps;
        config.steps = steps;
    };

    create_cases(
        path_format,
        adj_value,
        &mut cases,
        &permutations,
        &args.output_directory,
    );

    // pull all of the input.dat files that we need to write to a distribute file
    let input_files: Vec<PathBuf> = cases
        .iter()
        .map(|config| config.output_path.clone())
        .collect();

    for case in cases {
        // first, make sure that the case itself is valid
        let gpu_memory = Some(crate::config_generator::Megabytes(11 * 10usize.pow(3)));

        let output_path = case.output_path.clone();
        let case = case.into_serializable();

        case.validate(gpu_memory)?;

        let file = fs::File::create(&output_path)
            .with_context(|| format!("failed to create file at {}", output_path.display()))?;

        // write the case data to a file so that the actual input file can be generated later
        serde_json::to_writer_pretty(file, &case)?;
    }

    distribute_gen(&args, input_files)?;

    Ok(())
}

/// validate that the blowing boundary condition on the bottom plate of the
/// simulation is working correctly
fn check_blowing_condition(args: SbliCases) -> Result<()> {
    let mut case =
        cli::ConfigGenerator::with_path(args.output_directory.join("check_blowing_condition.json"));

    case.steps = 50_000;
    case.blowing_bc = cli::JetActuator::Constant {
        amplitude: 1.,
        slot_start: 100,
        slot_end: 200,
    };

    let output_path = case.output_path.clone();
    let case = case.into_serializable();

    let gpu_memory = Some(crate::config_generator::Megabytes(11 * 10usize.pow(3)));
    case.validate(gpu_memory)?;

    let file = fs::File::create(&output_path)
        .with_context(|| format!("failed to create file at {}", output_path.display()))?;

    // write the case data to a file so that the actual input file can be generated later
    serde_json::to_writer_pretty(file, &case)?;

    distribute_gen(&args, vec![output_path])?;

    Ok(())
}

/// validate that the probe data is being collected as we expect it to be
fn check_probes(args: SbliCases) -> Result<()> {
    let case = cli::ConfigGenerator::with_path(args.output_directory.join("check_probes.json"));

    let output_path = case.output_path.clone();
    let mut case = case.into_serializable();

    case.steps = 100;

    let gpu_memory = Some(crate::config_generator::Megabytes(11 * 10usize.pow(3)));
    case.validate(gpu_memory)?;

    let file = fs::File::create(&output_path)
        .with_context(|| format!("failed to create file at {}", output_path.display()))?;

    // write the case data to a file so that the actual input file can be generated later
    serde_json::to_writer_pretty(file, &case)?;

    distribute_gen(&args, vec![output_path])?;

    Ok(())
}

/// validate that the blowing boundary condition on the bottom plate of the
/// simulation is working correctly
fn one_case(args: SbliCases) -> Result<()> {
    let case =
        cli::ConfigGenerator::with_path(args.output_directory.join("check_blowing_condition.json"));

    let output_path = case.output_path.clone();
    let mut case = case.into_serializable();

    case.steps = 30_000;
    case.blowing_bc = cli::JetActuator::None;

    let gpu_memory = Some(crate::config_generator::Megabytes(11 * 10usize.pow(3)));
    case.validate(gpu_memory)?;

    let file = fs::File::create(&output_path)
        .with_context(|| format!("failed to create file at {}", output_path.display()))?;

    // write the case data to a file so that the actual input file can be generated later
    serde_json::to_writer_pretty(file, &case)?;

    distribute_gen(&args, vec![output_path])?;

    Ok(())
}

/// create a distribute-jobs.yaml file from the input configuration files
fn distribute_gen(args: &cli::SbliCases, input_files: Vec<PathBuf>) -> anyhow::Result<()> {
    let capabilities = vec!["gpu", "apptainer"]
        .into_iter()
        .map(|x| x.into())
        .collect();

    let batch_name = args
        .output_directory
        .file_name()
        .unwrap()
        .to_string_lossy()
        .to_string();

    let meta = distribute::Meta {
        batch_name,
        namespace: "streams_sbli".into(),
        matrix: args.matrix.clone(),
        capabilities,
    };

    // initialization specification
    let mounts = vec![];
    let init = distribute::apptainer::Initialize::new(
        distribute::common::File::new(args.solver_sif.clone())?,
        vec![distribute::common::File::with_alias(
            &args.database_bl,
            "database_bl.dat",
        )?],
        mounts,
    );

    let jobs: Result<Vec<_>> = input_files
        .into_iter()
        .map(|file| {
            let job_name = file.file_stem().unwrap().to_string_lossy().to_string();
            let job = distribute::apptainer::Job::new(
                job_name,
                vec![distribute::common::File::with_alias(file, "input.json")?],
            );
            Ok(job)
        })
        .collect();
    let jobs = jobs?;

    let apptainer = distribute::apptainer::Description::new(init, jobs);
    let jobs = distribute::ApptainerConfig::new(meta, apptainer);

    let jobs_path = args.output_directory.join("distribute-jobs.yaml");
    let file = fs::File::create(&jobs_path)
        .with_context(|| format!("failed to write jobs file at {}", jobs_path.display()))?;

    distribute::Jobs::from(jobs).to_writer(file)?;

    Ok(())
}
