# AFMR
Official MATLAB implementation of AFMR for Raman spectral denoising and reconstruction.

## 1. Overview
AFMR (Adaptive Frequency Mask Reconstruction) is the method proposed in our paper:
> Peng et al., Recognition of Foodborne Pathogens in Single-Cell Raman Spectroscopy Based on the Adaptive Frequency Mask Reconstruction (AFMR) Method, Food Research International, 2026.

This repository provides the MATLAB code to reproduce the main results of the paper. It is designed to be **easy to run**, even without access to the full experimental dataset.

---

## 2. Repository Structure
<pre>
AFMR/
├─ README.md # This file
├─ LICENSE # MIT License
├─ .gitignore # Ignore temporary / data files
├─ code/ # Core MATLAB scripts
│   ├─ train.m
│   ├─ test.m
│   └─ utils/ # Helper functions
├─ data/ # Demo data only
│   └─ demo_data.mat
├─ experiments/ # Scripts to reproduce figures in the paper
│   └─ reproduce_fig3.m
└─ results/ # Example output
    └─ example_output.png
</pre>

> **Note:** Full experimental data is not publicly available. Demo data is provided for verification purposes.

---

## 3. Requirements

- MATLAB R2022a or later  
- Optional: Deep Learning Toolbox if you want to run full experiments

---

## 4. Usage

1. Download or clone this repository.  
2. Navigate to the `experiments/` folder.  
3. Run a demo script to reproduce a figure.

---

## 6. Citation
@article{Peng2026AFMR,
  title={Recognition of Foodborne Pathogens in Single-Cell Raman Spectroscopy Based on the Adaptive Frequency Mask Reconstruction (AFMR) Method},
  author={Peng, Y. and others},
  journal={Food Research International},
  year={2026}
}

---

## 7. License
This repository is released under the MIT License. See LICENSE for details.
