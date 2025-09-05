# Changelog
## [0.2.0] - 2025-09-05
### Added
- PyPI package support (`pip install remote-twin-baker`).
- Centralized path handling in `remote_twin_baker.utils.paths`.
- Package structure with `remote_twin_baker/` and `__init__.py` files.
- `remote_twin_baker.utils.util` for additional utilities.
- `remote_twin_baker.app.app_server` as an alternative server implementation.
- `tests/` directory for improved test organization.
### Changed
- Updated imports to use `remote_twin_baker` package structure.
- Renamed Nginx config to `nginx/nginx_remote_twin_baker.txt`.
- Enhanced README with PyPI installation and updated project structure.
- Improved path resolution with `pathlib` in `utils/paths.py`.

## [0.1.0] - 2025-08-XX
### Added
- Initial release with remote execution, file sync, and environment validation.
- Core functionality in `app/server.py`, `client/remote_execution.py`, and `utils/merge_env_requirements.py`.