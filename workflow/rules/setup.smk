import os
import tempfile
import functools as ft

from snakebids import bids, generate_inputs

from pathlib import Path
from snakeboost import Tar, Pyscript, ScriptDict, XvfbRun, PipEnv, Boost, Datalad

###
# Input Globals
###
inputs = generate_inputs(
    bids_dir=config['bids_dir'],
    pybids_inputs=config['pybids_inputs'],
    derivatives=config.get('preprocessed_data', None),
    participant_label=config.get("participant_label", None),
    use_bids_inputs=True
)

wildcards = inputs.input_wildcards['preproc_dwi']

###
# Output Globals
###
work = Path(
    os.environ.get(config.get('tmpdir', ""), tempfile.mkdtemp(prefix="sn-tmp."))
)/'prepdwi-recon'

output = config['output_dir'] + "/prepdwi_recon"
qc = Path(output)/"qc"

# Unique ID for easy naming in temporary files
uid = '.'.join(wildcards.values())

###
# bids Partials
###
bids_output_dwi = ft.partial(bids, root=output, space="T1w", datatype="dwi", **wildcards)
bids_output_anat = ft.partial(bids, root=output, space="orig", datatype="anat", **wildcards)

###
# Utility functions
###
tar = Tar(work)
xvfb_run = XvfbRun(config.get('x11_srv', False))
boost = Boost(work)
datalad = Datalad(output)

###
# Pipenvs
###
wma_env = PipEnv(
    packages = [
        'whitematteranalysis',
        'vtk==8.1.2',
        '/scratch/knavynde/snakeboost'
    ],
    flags = config["pip-flags"],
    root = work
)

test_env = PipEnv(
    packages = [
        'colorama',
        'numpy',
        'black',
        '../snakeboost/'
    ],
    root = work
)