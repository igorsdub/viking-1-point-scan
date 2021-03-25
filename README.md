# 1-point mutational scan
This job scans through 25 equally spaced values of ENM's custom spring constants from 0.25 to 4.00 with the center at 1.00 (wild-type) for chosen residue number in a PDB file.

## Scripts and files
#### scan_1point.sh
Runs a 1-point mutational scan over 23 custom spring values for chosen cutoff and residue sequnce number.

    ./scan_1point.sh pdb/1c3b.1.pdb 8.0 145
    Output: 1c3b.1.0145.1point.energy

#### configure_dir.sh
Configures root directory for the job submission: gives permisions to scripts and binaries; creates `logs/` and `errors/` directories.

#### job_1point.sh
Batch script splits the job into multiple arrays equal to residue sequnce number length and runs `scan_1point.sh` for given PDB structure and cutoff.

    ./scan_1point.sh pdb/1c3b.1.pdb 8.0

#### concat_1point_results.sh
Concatinates 1-point mutational scan results into a single file multi-column`.csv` file. Provide PDB ID and form index number.

    ./concat_1point_results.sh 1c3b 1
    Output: 1c3b.1.1point.energy.csv

## Usage
1. Rename PDB file forms as follows in the table and place them into the `pdb/` directory. 

| Protein Form | File name      |
|--------------|----------------|
| apo          | `xxxx.0.pdb`   |
| holo1        | `xxxx.1.pdb`   |
| holo2        | `xxxx.2.pdb`   |

2. Configure job script.
    - Name the job: `--job-name=xxxx_1d`
    - Add your IT username to receive emails when the job starts, ends or fails: `--mail-user=username@york.ac.uk`
    - Specify memory per CPU: `--mem=100mb`
    - Specify runtime limit: `--time=00:45:00`. 
    - Enter your project account name: `--account=project-account-name`
    - Enter residue number to be sacnned: `--array=1-100`. `SLURM` supports array slicing (See  [Job Array Support](https://slurm.schedmd.com/job_array.html)).

**Note** To get a rough idea how much time is requred for the whole job, run the job script just for one residue. Once time per residue is known, submit the job for all residues.

3. Just in case, convert `configure_dir.sh` to Unix format. Then, give the script executing permission and run it.

```shell
dos2unix configure_dir.sh
chmod u+x configure_dir.sh
./configure_dir.sh
```

4. Submit a job to `SLURM` manager using `batch` command.
```shell
sbatch job_1point.sh 1c3b.1.pdb 8.0
```

5. Once the job is complete. run `concat_1point_results.sh` from the results directory. 
```shell
../../results.sh 1c3b 1
```

6. You can copy results form Viking to your local machine. If you're on campus then:
```bash
#For an individual file
scp filename viking.york.ac.uk:~/scratch/
 
#For a folder with lots of files
scp -r dirname viking.york.ac.uk:~/scratch/
```

If you're off-campus, first establish VPN for a secure connection (See [UoY VPN webpage](https://www.york.ac.uk/it-services/services/vpn/)). Next, use `scp` with jumphost template `-J`:

```bash
scp -J abc123@ssh.york.ac.uk abc123@viking.york.ac.uk:/path/to/files /path/to/destination
```