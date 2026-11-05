import logging
import click
from pathlib import Path
import triggers_cli.core

LOGGER = logging.getLogger()

@click.group()
def cli():
    """Trigger CLI"""

@click.command()
@click.argument(
    'trigger_file_path',
    required=True,
    type=click.Path(
        exists=True, file_okay=True, dir_okay=True, path_type=Path
    ),
    help='File path to the Python AWS trigger'
)
def trigger(trigger_file_path: Path):
    """Run an AWS Trigger"""
    triggers_cli.core.run(trigger_file_path)

@click.command()
def trigger_all():
    triggers_cli.core.run_all()

cli.add_command(trigger)
cli.add_command(trigger_all)

if __name__ == "__main__":
    cli()