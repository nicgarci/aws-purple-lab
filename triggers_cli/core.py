import logging
import importlib
from pathlib import Path

LOGGER = logging.getLogger()

def run(trigger_file_path: Path):
    trigger = importlib.import_module(f"triggers_cli.triggers.{trigger_file_path.stem}")
    trigger.main()