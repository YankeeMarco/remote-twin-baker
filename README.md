# remote-twin-baker
Pythonic decorator to simplify heavy/traffic-blocked task execution with remote twin runtime by automating file synchronization, environment validation, and result retrieval. 
Using a decorator-based approach, it allows developers to write local Python functions and execute them on a remote server without modifying core business logic. The system ensures that only necessary files are transferred, environments are consistent, and results (both Python objects and files) are seamlessly returned to the client.

## Features
- **Decorator-Based Workflow**: Add a `@remote_execution_decorator` to any Python function to enable remote execution with automatic file synchronization.
- **Selective File Transfer**: Only new or modified files are transferred, using MD5 hash comparison to avoid redundant uploads.
- **Environment Consistency**: Compares client and server environments, generating a report if discrepancies are found (manual repair required).
- **Result Retrieval**: Automatically syncs back Python objects and generated files, with a 10-second polling mechanism for new files.
- **Flexible Deployment**: Runs a FastAPI server on port 7777, with Nginx handling HTTPS in production.
- **Broad Applicability**: Suitable for data science, AI, edge computing, and collaborative development scenarios.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone git@github.com:YankeeMarco/remote-twin-baker.git  or git clone https://github.com/YankeeMarco/remote-twin-baker.git
   cd remote_twin_baker
   ```

2. **Set Up Conda/Virtual Environment**:
   Use Python 3.12 and install dependencies, you should merge the requirements file with your own:
   ```bash
   conda create -n remote_twin_baker python=3.12
   conda activate remote_twin_baker
   pip install -r requirements.txt
   ```

3. **Configure the Server**:
   Update `rem_shop.yaml` with the appropriate server URL:
   - For local testing: `url: http://localhost:7777`
   - For production: `url: https://your-server.com` (requires Nginx setup).

## Usage

1. **Run the Server**:
   Start the FastAPI server locally:
   ```bash
   python server.py
   ```
   The server runs on `http://localhost:7777`. In production, configure Nginx to map HTTPS to this port.

2. **Use the Decorator**:
   Apply the `@remote_execution_decorator` to any function that requires remote execution. Example:
   ```python
   from remote_execution import remote_execution_decorator
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
   This will:
   - Sync `data.xlsx` to the server (if new or modified).
   - Execute the function remotely.
   - Return the statistical summary and sync `result.xlsx` back to the client.

3. **Test the System**:
   Run the test script to verify functionality:
   ```bash
   python -m pytest test_server.py -v
   ```
   Tests cover server connectivity, function execution, file synchronization, and environment comparison.

## Project Structure
- `remote_execution.py`: Client-side logic with the decorator for file sync and remote execution.
- `server.py`: FastAPI server handling file uploads, execution, and downloads on port 7777.
- `rem_shop.yaml`: Configuration file for server URL and endpoints.
- `test_server.py`: Test script for local validation of the workflow.
- `requirements.txt`: Dependencies for both client and server environments.

## Developer Tasks
- **Nginx Configuration**: Map HTTPS to `localhost:7777` in production with proper SSL/TLS settings.
- **Environment Management**: Ensure identical Conda/virtual environments on client and server. Fix mismatches manually based on the environment comparison report.
- **Server Deployment**: Deploy `server.py` on the remote host, ensuring port 7777 is accessible.
- **Configuration**: Update `rem_shop.yaml` with the production server URL.

## Testing Locally
1. Ensure the environment is set up with `requirements.txt`.
2. Start the server:
   ```bash
   python server.py
   ```
3. Run tests:
   ```bash
   python -m pytest test_server.py -v
   ```
4. Check the output for test results and environment mismatch reports (if any).

## Use Cases
- **Data Science/AI**: Offload large-scale data processing or model training to a remote GPU server.
- **Collaborative Development**: Ensure environment consistency across teams for testing and deployment.
- **Edge Computing/IoT**: Enable resource-constrained devices to leverage remote compute power.
- **Personal Projects**: Use local machines for development while executing heavy tasks on a cloud server.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for bugs, features, or improvements.

