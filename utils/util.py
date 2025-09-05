import os

# Third Party Libraries
import yaml

# Local Libraries
from utils.paths import to_absolute_path


def load_config(config_path: str = "config.yaml") -> dict:
    """Load the configuration from YAML file."""
    config_path = to_absolute_path(config_path)
    if not os.path.exists(config_path):
        config_path = to_absolute_path("config.local.yaml")
    with open(config_path, "r") as f:
        return yaml.safe_load(f)
