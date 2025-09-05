# Remote Twin Baker

**Remote Twin Baker** is a Python framework for seamless remote task execution. By adding a decorator to your Python functions, it automates file synchronization, environment validation, and result retrieval between a local client and a remote server. Designed for data science, AI, edge computing, and collaborative development, it ensures environment consistency and minimizes manual overhead.

## Key Features
- **Decorator-Based Execution**: Use `@remote_execution_decorator` to run local Python functions on a remote server.
- **Efficient File Sync**: Transfers only new or modified files using MD5 hash checks.
- **Environment Validation**: Compares client and server environments, reporting mismatches.
- **Environment Sync**: Use `utils/merge_env_requirements.py` to merge base and custom requirements and update the remote server.
- **Robust Path Handling**: Uses `utils/paths.py` to resolve file paths relative to the project root.
- **Result Retrieval**: Returns Python objects and new files, with 10-second polling for asynchronous file sync.
- **Scalable Deployment**: Runs a FastAPI server on port 7777, with Nginx for HTTPS in production.
- **PyPI Availability**: Install via `pip install remote-twin-baker` for easy integration.

## Project Structure
```
remote-twin-baker/
├── LICENSE
├── README.md
├── CHANGELOG.md              # Release notes and version history
├── pyproject.toml            # Package configuration for PyPI
├── requirements.txt          # Base dependencies for development
├── custom_requirements.txt   # Optional custom dependencies
├── config.yaml               # Production configuration
├── config.local.yaml         # Local testing configuration
├── nginx/
│   ├── Readme.md             # Nginx setup instructions
│   └── nginx_remote_twin_baker.txt # Nginx configuration for HTTPS
├── remote_twin_baker/
│   ├── __init__.py           # Marks project as a package
│   ├── app/
│   │   ├── __init__.py
│   │   ├── server.py         # FastAPI server for remote execution
│   │   └── app_server.py     # Alternative server implementation
│   ├── client/
│   │   ├── __init__.py
│   │   └── remote_execution.py # Client-side decorator logic
│   ├── config.yaml           # Package-level production configuration
│   └── utils/
│       ├── __init__.py
│       ├── paths.py          # Path handling utilities
│       ├── merge_env_requirements.py # Environment sync utility
│       └── util.py           # Additional utilities
├── tests/
│   ├── __init__.py
│   └── test_server.py        # Test script for local validation
```

## Installation

### Option 1: Install from PyPI (Recommended for Users)
```bash
pip install remote-twin-baker
```

### Option 2: Install from Source (Development)
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/remote-twin-baker.git
   cd remote-twin-baker
   ```

2. **Set Up Environment**:
   Create a Python 3.12 Conda/virtual environment:
   ```bash
   conda create -n remote_twin_baker python=3.12
   conda activate remote_twin_baker
   pip install -r requirements.txt
   ```

3. **Install as a Package**:
   ```bash
   pip install -e .
   ```

## Configuration
- **Local Testing**: Use `config.local.yaml` (sets `url: http://localhost:7777`).
- **Production**: Update `config.yaml` with your server URL (e.g., `https://xxx.com/twin_baker`).
- **Nginx (Production)**:
  - Copy `nginx/nginx_remote_twin_baker.txt` to `/etc/nginx/conf.d/remote_twin_baker.conf`.
  - Update SSL certificate paths.
  - Test and reload Nginx:
    ```bash
    nginx -t
    systemctl reload nginx
    ```

## Usage

1. **Start the Server**:
   ```bash
   python -m remote_twin_baker.app.server
   ```
   The server runs on `http://localhost:7777`. In production, Nginx proxies `https://xxx.com/twin_baker` to this port.

2. **Use the Decorator**:
   Apply the decorator to any function:
   ```python
   from remote_twin_baker.client.remote_execution import remote_execution_decorator
   import pandas as pd

   @remote_execution_decorator
   def process_big_excel(file_path: str) -> str:
       df = pd.read_excel(file_path)
       result = df.describe().to_string()
       output_path = "result.xlsx"
       df.to_excel(output_path, index=False)
       return result

   result = process_big_excel(file_path="data.xlsx")
   print(result)
   ```
   This syncs `data.xlsx` to the server, executes the function remotely, and returns the result and `result.xlsx`.

3. **Sync Environments**:
   If an environment mismatch is detected, run:
   ```bash
   python -m remote_twin_baker.utils.merge_env_requirements
   ```
   - Merges `requirements.txt` with `custom_requirements.txt` (if exists) into `merged_requirements.txt`.
   - Uploads the merged file to the server.
   - Triggers `pip install` on the server to align environments.
   - Note: Create `custom_requirements.txt` in the root directory for additional packages.

4. **Run Tests**:
   Validate the system locally:
   ```bash
   python -m pytest tests/test_server.py -v
   ```
   Tests verify connectivity, execution, file sync, and environment consistency.

## Developer Tasks
- **Nginx Setup**: Configure SSL certificates and DNS for `xxx.com`. Ensure HTTPS requests to `/twin_baker` proxy to `localhost:7777`.
- **Environment Sync**: Run `python -m remote_twin_baker.utils.merge_env_requirements` to align environments. Fix mismatches manually based on test reports.
- **Server Deployment**: Deploy `remote_twin_baker.app.server` on the remote host, ensuring port 7777 is accessible.
- **Configuration**: Update `config.yaml` with the production URL (`https://xxx.com/twin_baker`).
- **Path Handling**: Use `remote_twin_baker.utils.paths.to_absolute_path` for consistent file path resolution.

## Testing Locally
1. Activate the environment:
   ```bash
   conda activate remote_twin_baker
   ```
2. Start the server:
   ```bash
   python -m remote_twin_baker.app.server
   ```
3. Run tests:
   ```bash
   python -m pytest tests/test_server.py -v
   ```
4. Check for test results and environment mismatch reports.

## Use Cases
- **Data Science/AI**: Offload large Excel processing or model training to remote GPUs.
- **Team Collaboration**: Ensure environment consistency across development, testing, and ops.
- **Edge Computing/IoT**: Enable resource-constrained devices to leverage remote compute power.
- **Personal Projects**: Develop locally while executing heavy tasks on cloud servers.

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## Contributing
Submit pull requests or open issues at [https://github.com/your-username/remote-twin-baker](https://github.com/your-username/remote-twin-baker). Follow the coding style in existing files.

## License
MIT License