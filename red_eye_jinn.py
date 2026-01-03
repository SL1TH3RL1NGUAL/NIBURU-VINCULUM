#!/usr/bin/env python3
"""
red_eye_jinn.py

Red-eye Jinn orchestrator for Blackcorp.me / SL1TH3RL1NGUAL-project.

Pipeline:
  LP Event (stdin JSON) →
    codex classification →
    guild routing →
    trust radius enforcement →
    topology annotation →
    Vinculum context →
    Jurisdiction Shield decision →
    avatar update →
    violation logging (reserve) →
    stdout decision object
"""

import sys
import json
from pathlib import Path
from typing import Dict, Any

# ----------------------------------------------------------------------
# IMPORT PATH SETUP
# ----------------------------------------------------------------------

CURRENT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = CURRENT_DIR.parent
sys.path.insert(0, str(PROJECT_ROOT / "engines"))

import codex_loader          # type: ignore
import guild_router          # type: ignore
import trust_radius          # type: ignore
import watchdog              # type: ignore
import vinculum              # type: ignore
import jurisdiction_shield   # type: ignore
import avatar_state          # type: ignore
import topology              # type: ignore


# ----------------------------------------------------------------------
# CLASSIFICATION / POLICIES
# ----------------------------------------------------------------------

def classify_event(event: Dict[str, Any], codex: Dict[str, Any]) -> str:
    """
    Simple classification using event type.
    """
    event_type = event.get("type", "UNKNOWN")
    return f"EVENT::{event_type}"


def apply_policies(event: Dict[str, Any], codex: Dict[str, Any]) -> Dict[str, Any]:
    """
    Attach codex policies directly to the event.
    """
    policies = codex.get("policies", [])
    event["applied_policies"] = policies
    return event


# ----------------------------------------------------------------------
# MAIN HANDLER
# ----------------------------------------------------------------------

def handle_event(
    event: Dict[str, Any],
    codex: Dict[str, Any],
    trust_cfg: Dict[str, Any],
    guild_cfg: Dict[str, Any],
    topo_cfg: Dict[str, Any],
) -> Dict[str, Any]:
    """
    Full orchestration for a single LP event.
    """

    # Codex classification + policies
    event["classification"] = classify_event(event, codex)
    event = apply_policies(event, codex)

    # Guild-based routing
    event = guild_router.apply_guild_routing(event, guild_cfg)

    # Trust radius enforcement
    event = trust_radius.enforce_trust_radius(event, trust_cfg)

    # Topology annotation (conceptual ENU/spherical + domain)
    event = topology.annotate_event_with_topology(event, topo_cfg)

    # Vinculum + jurisdiction
    ctx = vinculum.build_jurisdiction_context(event)
    decision = jurisdiction_shield.evaluate_jurisdiction(ctx)
    event["jurisdiction"] = decision

    # Avatar update (symbolic "Snap Map" analog)
    avatar = avatar_state.update_avatar_from_event(event)
    event["avatar_view"] = avatar_state.to_public_view(avatar)

    # Reserve watchdog on violations
    if decision["decision"] == "BLOCKED":
        watchdog.log_violation(event)

    return event


# ----------------------------------------------------------------------
# STREAM PROCESSING
# ----------------------------------------------------------------------

def process_stream(
    codex: Dict[str, Any],
    trust_cfg: Dict[str, Any],
    guild_cfg: Dict[str, Any],
    topo_cfg: Dict[str, Any],
) -> None:
    """
    Read JSON lines from stdin, process each event, write JSON to stdout.
    """
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            print(f"Invalid JSON: {line}", file=sys.stderr)
            continue

        result = handle_event(event, codex, trust_cfg, guild_cfg, topo_cfg)
        print(json.dumps(result))


# ----------------------------------------------------------------------
# CLI ENTRYPOINT
# ----------------------------------------------------------------------

if __name__ == "__main__":
    codex = codex_loader.build_codex()
    trust_cfg = trust_radius.load_trust_config()
    guild_cfg = guild_router.load_guild_routing()
    topo_cfg = topology.load_topology_config()
    process_stream(codex, trust_cfg, guild_cfg, topo_cfg)

