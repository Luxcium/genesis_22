# System Patterns

- Use layered instructions to gate repository evolution; each layer verifies prerequisites before adding new artifacts.
- Keep shell scripts idempotent and well-logged so they can be run repeatedly without side effects.
- Store reusable prompt, chat mode, and instruction metadata in the memory-bank triad to centralize AI guidance.
- Prefer additive changes and avoid overwriting existing files unless layers explicitly authorize modifications.

## Notebook Infrastructure Patterns

### Directory Organization
- **`notebooks/`**: Canonical template infrastructure for Jupyter-based work
  - **Environment files**: `.python-version` (3.12), `requirements.txt`, `requirements-dev.txt`, `.gitignore`
  - **Template notebook**: `canonical-template.ipynb` serves as flagship example
  - **Documentation**: Comprehensive `README.md` with setup, best practices, troubleshooting
  - **Data structure**: `data/raw/` (immutable), `data/processed/` (transformed)
  - **Artifacts**: `models/` (saved models), `outputs/` (figures, reports)

### Code Quality Standards
- **Type safety**: Full type hints following PEP 484/585
- **Documentation**: NumPy-style docstrings for all functions
- **Formatting**: PEP 8 compliance, enforced by Black and isort
- **Testing**: Notebook validation with nbval, pytest for code cells
- **Reproducibility**: Fixed random seeds, version logging, pinned dependencies

### Notebook Structure Pattern
1. **Environment Setup**: Imports, configuration, constants
2. **Data Loading & Validation**: Ingestion, quality checks, schema validation
3. **Exploratory Data Analysis**: Distributions, correlations, relationships
4. **Statistical Analysis**: Hypothesis testing, validation
5. **Visualization**: Static (Matplotlib/Seaborn) and interactive (Plotly)
6. **Results & Conclusions**: Findings, interpretations, recommendations
7. **Cleanup**: Memory management, export results

### Visualization Standards
- **Consistent styling**: Seaborn themes, defined color palettes
- **High resolution**: 300 DPI for publication-ready outputs
- **Interactive options**: Plotly for exploratory work
- **Proper labeling**: Descriptive titles, axis labels, legends
- **Save outputs**: Always export figures to `outputs/` directory

### Memory Management
- **Optimize dtypes**: Use categorical for strings, smallest int types
- **Chunked processing**: For large datasets, process in batches
- **Cleanup**: Explicitly delete large objects and call garbage collection
- **Monitor usage**: Track memory consumption throughout analysis
