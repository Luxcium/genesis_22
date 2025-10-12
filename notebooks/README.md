# Genesis 22 Notebook Templates

This directory contains the canonical Jupyter Notebook infrastructure for the Genesis 22 project. It provides a standardized, professional foundation for all notebook-based data analysis, exploration, and documentation work.

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Environment Setup](#environment-setup)
- [Canonical Template](#canonical-template)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

---

## Overview

The Genesis 22 notebook infrastructure demonstrates:

- ✅ **Professional Structure**: Organized, well-documented notebooks
- ✅ **Reproducibility**: Fixed dependencies, versioning, and random seeds
- ✅ **Type Safety**: Full type hints following PEP 484/585
- ✅ **Code Quality**: PEP 8 compliance, linting, and formatting
- ✅ **Testing**: Notebook validation with `nbval`
- ✅ **Documentation**: Comprehensive markdown and docstrings
- ✅ **Visualization**: Both static and interactive plots
- ✅ **Memory Efficiency**: Best practices for large datasets

---

## Quick Start

### 1. Environment Setup

```bash
# Navigate to notebooks directory
cd notebooks

# Create virtual environment (Python 3.12+)
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# For development work
pip install -r requirements-dev.txt
```

### 2. Launch Jupyter

```bash
# Classic Notebook Interface
jupyter notebook

# JupyterLab (recommended)
jupyter lab
```

### 3. Create Your First Notebook

1. Copy `canonical-template.ipynb` and rename it
2. Update metadata (title, author, date, description)
3. Replace data loading with your data source
4. Customize analysis sections
5. Run cells sequentially

---

## Directory Structure

```
notebooks/
├── README.md                      # This file
├── .python-version                # Python version specification (3.12)
├── .gitignore                     # Notebook-specific ignores
├── requirements.txt               # Production dependencies
├── requirements-dev.txt           # Development dependencies
│
├── canonical-template.ipynb       # 🌟 Flagship template notebook
│
├── data/                          # Data directory
│   ├── raw/                       # Original, immutable data
│   │   └── .gitkeep
│   └── processed/                 # Cleaned, transformed data
│       └── .gitkeep
│
├── models/                        # Saved models
│   └── .gitkeep
│
└── outputs/                       # Generated outputs
    ├── figures/                   # Plots and visualizations
    └── reports/                   # Analysis reports
```

---

## Environment Setup

### Python Version

This project uses **Python 3.12**. The version is specified in `.python-version` for compatibility with `pyenv` and other version managers.

```bash
# Install Python 3.12 with pyenv
pyenv install 3.12

# Set local version
pyenv local 3.12
```

### Dependencies

#### Core Stack

- **Jupyter**: `jupyter`, `jupyterlab`, `notebook`, `ipykernel`, `ipywidgets`
- **Data Science**: `numpy`, `pandas`, `scipy`, `scikit-learn`
- **Visualization**: `matplotlib`, `seaborn`, `plotly`, `ipympl`

#### Development Tools

- **Code Quality**: `black`, `isort`, `pylint`, `mypy`, `ruff`
- **Testing**: `pytest`, `pytest-cov`, `nbval`
- **Documentation**: `sphinx`, `nbsphinx`, `myst-parser`
- **Utilities**: `pre-commit`, `commitizen`, `papermill`

### Installing Dependencies

```bash
# Production only
pip install -r requirements.txt

# Production + Development
pip install -r requirements.txt -r requirements-dev.txt

# Verify installation
jupyter --version
python -c "import pandas; print(f'Pandas: {pandas.__version__}')"
```

---

## Canonical Template

The **`canonical-template.ipynb`** serves as the flagship example and starting point for all notebook work.

### Structure

1. **Environment Setup**
   - Import statements (organized by category)
   - Display configuration
   - Constants and configuration

2. **Data Loading & Validation**
   - Data ingestion
   - Quality checks
   - Schema validation

3. **Exploratory Data Analysis**
   - Distribution analysis
   - Correlation analysis
   - Feature relationships

4. **Statistical Analysis**
   - Hypothesis testing
   - Statistical validation
   - Confidence intervals

5. **Visualization**
   - Static plots (Matplotlib/Seaborn)
   - Interactive plots (Plotly)
   - Publication-ready figures

6. **Results & Conclusions**
   - Key findings
   - Interpretations
   - Recommendations

7. **Cleanup & Best Practices**
   - Memory management
   - Export results
   - Documentation

### Key Features

```python
# Type hints throughout
def validate_data(df: pd.DataFrame) -> Dict[str, Any]:
    """Comprehensive data validation with type safety."""
    pass

# Docstrings following NumPy style
"""
Parameters
----------
n_samples : int, default=1000
    Number of samples to generate
    
Returns
-------
pd.DataFrame
    Generated dataset with features and target
"""

# Named constants (no magic numbers)
RANDOM_STATE: int = 42
TEST_SIZE: float = 0.2
CONFIDENCE_LEVEL: float = 0.95

# Professional visualization
plt.style.use('seaborn-v0_8-darkgrid')
plt.rcParams['figure.figsize'] = (12, 6)
plt.rcParams['figure.dpi'] = 100
```

---

## Best Practices

### Code Organization

1. **Imports First**: Group by standard library, third-party, local
2. **Configuration Next**: Constants, paths, settings
3. **Functions Before Use**: Define helper functions early
4. **Linear Flow**: Tell a story from top to bottom
5. **Clear Sections**: Use markdown headers for navigation

### Documentation

```markdown
## 1. Section Title

### 1.1 Subsection

Brief explanation of what this section does and why.
```

```python
"""Cell-level docstring explaining the purpose."""

def function_name(param: type) -> return_type:
    """
    Brief description.
    
    Detailed explanation if needed.
    
    Parameters
    ----------
    param : type
        Description
        
    Returns
    -------
    return_type
        Description
    """
    pass
```

### Reproducibility

```python
# Always set random seeds
np.random.seed(42)
random.seed(42)

# Document versions
print(f"NumPy: {np.__version__}")
print(f"Pandas: {pd.__version__}")
print(f"Executed: {datetime.now().isoformat()}")

# Use requirements.txt with pinned versions
numpy>=1.26.0
pandas>=2.2.0
```

### Memory Management

```python
# Use appropriate data types
df['category'] = df['category'].astype('category')
df['small_int'] = df['small_int'].astype('int8')

# Clean up when done
del large_dataframe
gc.collect()

# Monitor memory usage
df.memory_usage(deep=True).sum() / 1024**2  # MB
```

### Visualization Standards

```python
# Consistent styling
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("husl")

# Descriptive titles and labels
plt.title('Distribution of Feature X', fontsize=14, fontweight='bold')
plt.xlabel('Feature X (units)', fontsize=12)
plt.ylabel('Frequency', fontsize=12)

# Save high-resolution outputs
plt.savefig('output.png', dpi=300, bbox_inches='tight')
```

### Error Handling

```python
# Validate inputs
assert df is not None, "DataFrame cannot be None"
assert len(df) > 0, "DataFrame cannot be empty"

# Check for missing values
if df.isnull().any().any():
    print("⚠️  Warning: Missing values detected")
    
# Validate assumptions
if not df['column'].is_monotonic_increasing:
    raise ValueError("Column must be sorted")
```

---

## Contributing

### Creating New Notebooks

1. **Copy the template**:
   ```bash
   cp canonical-template.ipynb my-analysis.ipynb
   ```

2. **Update metadata** in first cell:
   ```yaml
   ---
   title: "Your Analysis Title"
   author: "Your Name"
   date: "YYYY-MM-DD"
   ---
   ```

3. **Follow the structure**: Keep the 7-section organization

4. **Test your notebook**:
   ```bash
   pytest --nbval my-analysis.ipynb
   ```

5. **Format code cells**:
   ```bash
   black my-analysis.ipynb
   ```

### Commit Guidelines

Follow Genesis 22 commit conventions:

```bash
# Example commits
git commit -m "✨ feat(notebooks): Add time series analysis template"
git commit -m "📝 docs(notebooks): Update README with visualization guide"
git commit -m "🐛 fix(notebooks): Correct correlation calculation"
```

See [`memory-bank/instructions/conventional-commits-must-be-used.instructions.md`](../memory-bank/instructions/conventional-commits-must-be-used.instructions.md)

---

## Troubleshooting

### Common Issues

#### Kernel Dies or Restarts

```python
# Reduce memory usage
df = pd.read_csv('large.csv', usecols=['col1', 'col2'])  # Read subset
df = df.astype({'category': 'category'})  # Optimize dtypes

# Process in chunks
for chunk in pd.read_csv('large.csv', chunksize=10000):
    process(chunk)
```

#### Import Errors

```bash
# Verify kernel is using correct environment
python -c "import sys; print(sys.executable)"

# Reinstall package
pip install --force-reinstall package-name

# Clear cache and restart kernel
jupyter kernelspec list
jupyter kernelspec remove python3
```

#### Plotly Not Rendering

```python
# Ensure renderer is set
import plotly.io as pio
pio.renderers.default = 'notebook'  # or 'jupyterlab'

# For JupyterLab, install extension
# jupyter labextension install jupyterlab-plotly
```

#### Git Issues with Notebooks

```bash
# Install nbdime for better notebook diffs
pip install nbdime
nbdime config-git --enable --global

# Strip output before committing
jupyter nbconvert --clear-output --inplace *.ipynb
```

### Getting Help

1. **Check the template**: `canonical-template.ipynb` demonstrates solutions
2. **Review Memory Bank**: [`memory-bank/`](../memory-bank/) for project patterns
3. **Consult documentation**: Links in [References](#references) section
4. **Open an issue**: Use project issue tracker

---

## References

### Documentation

- [Jupyter Documentation](https://jupyter.org/documentation)
- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)
- [IPython Documentation](https://ipython.readthedocs.io/)
- [Pandas User Guide](https://pandas.pydata.org/docs/user_guide/)
- [Matplotlib Tutorials](https://matplotlib.org/stable/tutorials/)
- [Seaborn Tutorial](https://seaborn.pydata.org/tutorial.html)
- [Plotly Python](https://plotly.com/python/)

### Genesis 22 Resources

- [Project Brief](../memory-bank/projectbrief.md)
- [System Patterns](../memory-bank/systemPatterns.md)
- [Tech Context](../memory-bank/techContext.md)
- [Copilot Instructions](../.github/copilot-instructions.md)

### Tools & Extensions

- [nbval](https://nbval.readthedocs.io/) - Notebook validation
- [papermill](https://papermill.readthedocs.io/) - Notebook parameterization
- [nbdime](https://nbdime.readthedocs.io/) - Notebook diffing
- [pre-commit](https://pre-commit.com/) - Git hooks framework

---

## License

This template infrastructure is part of the Genesis 22 project and is licensed under the MIT License. See [`../LICENSE`](../LICENSE) for details.

---

**Version**: 1.0.0  
**Last Updated**: 2025-10-11  
**Maintained By**: Genesis 22 Project  
**Python Version**: 3.12+
