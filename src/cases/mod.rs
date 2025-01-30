mod ai_institute;
mod jet_validation;
mod sbli;
mod variable_dt;

pub(crate) use sbli::SbliError;

use crate::prelude::*;
use anyhow::Result;

pub(crate) fn cases(args: cli::Cases) -> Result<()> {
    match args {
        cli::Cases::Sbli(x) => sbli::sbli_cases(x)?,
        cli::Cases::JetValidation(x) => jet_validation::jet_validation(x)?,
        cli::Cases::VariableDt(x) => variable_dt::variable_dt(x)?,
        cli::Cases::AiInstitute(x) => ai_institute::ai_institute(x)?,
    }

    Ok(())
}

trait PrepareDistribute {
    fn sif_path(&self) -> &Path;
    fn update_solver_sif(&mut self, new_path: PathBuf);
    fn output_directory(&self) -> &Path;
    fn should_copy_sif(&self) -> bool;
    fn setup_output_directory(&mut self) -> Result<()>;
}

impl PrepareDistribute for cli::SbliCases {
    fn sif_path(&self) -> &Path {
        &self.solver_sif
    }

    fn update_solver_sif(&mut self, new_path: PathBuf) {
        self.solver_sif = new_path;
    }

    fn output_directory(&self) -> &Path {
        &self.output_directory
    }
    fn should_copy_sif(&self) -> bool {
        self.copy_sif
    }
    fn setup_output_directory(&mut self) -> Result<()> {
        if !self.database_bl.exists() {
            return Err(SbliError::DatabaseBlMissing(self.database_bl.clone()).into());
        }

        // error if the directory already exists, otherwise create the directory
        if self.output_directory.exists() {
            return Err(SbliError::OutputPathExists(self.output_directory.clone()).into());
        } else {
            fs::create_dir(&self.output_directory).with_context(|| {
                format!(
                    "failed to create output directory {}",
                    self.output_directory.display()
                )
            })?;
        }

        // copy the database_bl file to the output folder we have created
        let destination_bl = self.output_directory.join("database_bl.dat");
        fs::copy(&self.database_bl, &destination_bl).with_context(|| {
            format!(
                "failed to copy database_bl file {} to {}",
                self.database_bl.display(),
                destination_bl.display()
            )
        })?;

        self.database_bl = destination_bl;

        Ok(())
    }
}

impl PrepareDistribute for cli::JetValidation {
    fn sif_path(&self) -> &Path {
        &self.solver_sif
    }

    fn update_solver_sif(&mut self, new_path: PathBuf) {
        self.solver_sif = new_path;
    }

    fn output_directory(&self) -> &Path {
        &self.output_directory
    }
    fn should_copy_sif(&self) -> bool {
        self.copy_sif
    }
    fn setup_output_directory(&mut self) -> Result<()> {
        if !self.database_bl.exists() {
            anyhow::bail!(
                "database_bl.dat file at {} was missing",
                self.database_bl.display()
            );
        }

        // error if the directory already exists, otherwise create the directory
        if self.output_directory.exists() {
            return Err(SbliError::OutputPathExists(self.output_directory.clone()).into());
        } else {
            fs::create_dir(&self.output_directory).with_context(|| {
                format!(
                    "failed to create output directory {}",
                    self.output_directory.display()
                )
            })?;
        }

        // copy the database_bl file to the output folder we have created
        let destination_bl = self.output_directory.join("database_bl.dat");
        fs::copy(&self.database_bl, &destination_bl).with_context(|| {
            format!(
                "failed to copy database_bl file {} to {}",
                self.database_bl.display(),
                destination_bl.display()
            )
        })?;

        self.database_bl = destination_bl;

        Ok(())
    }
}

/// verify the cli options passed are valid
///
/// this includes the file paths are valid, and whether or not to canonicalize the paths
fn check_options_copy_files<T: PrepareDistribute>(args: &mut T) -> Result<()> {
    // if we are not copying over the .sif file (it takes up lots of space)
    // then lets make sure that the path specified is global and not relative
    if !args.should_copy_sif() {
        let canonical_path = args.sif_path().canonicalize().with_context(|| {
            format!(
                "failed to canonicalize sif path {}",
                args.sif_path().display()
            )
        })?;
        args.update_solver_sif(canonical_path);
    }

    args.setup_output_directory()?;

    // copy the sif file to the output folder (if requested)
    if args.should_copy_sif() {
        let dest_dir = args.output_directory().join("streams.sif");
        fs::copy(&args.sif_path(), &dest_dir).with_context(|| {
            format!(
                "failed to copy .sif file to output directory: {}",
                args.sif_path().display()
            )
        })?;
    }

    Ok(())
}
